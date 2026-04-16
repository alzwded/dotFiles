#!/usr/bin/env python3
import sys
import os
import sqlite3
import re
import concurrent.futures

def get_db_path():
    return os.environ.get('WORDDBPATH', 'worddb.sqlite3')

def is_text_file(filepath):
    """Fallback for Perl's -T text/binary check"""
    try:
        with open(filepath, 'rb') as f:
            chunk = f.read(1024)
            if b'\0' in chunk:
                return False
            return True
    except Exception:
        return False

# Pre-compile the regex so all threads can use it efficiently
WORD_RE = re.compile(r'[a-zA-Z0-9_]+')

def extract_words_from_file(filepath):
    """Worker function to be run in a thread pool."""
    if not os.path.isfile(filepath) or not is_text_file(filepath):
        return filepath, None
        
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
    except Exception:
        return filepath, None
        
    words_in_file = set(WORD_RE.findall(content))
    if not words_in_file:
        return filepath, None
        
    return filepath, words_in_file

def build_db(args):
    db_path = get_db_path()
    if os.path.exists(db_path):
        try:
            os.remove(db_path)
        except OSError:
            pass 

    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    
    # Fast bulk insertion pragmas
    cur.execute("PRAGMA synchronous = OFF")
    cur.execute("PRAGMA journal_mode = MEMORY")
    
    # executescript auto-commits before running, so we omit manual BEGIN/COMMIT here
    cur.executescript("""
    CREATE TABLE words(id INTEGER PRIMARY KEY AUTOINCREMENT, word, CONSTRAINT unique_words UNIQUE(word) ON CONFLICT IGNORE);
    CREATE TABLE files(id INTEGER PRIMARY KEY AUTOINCREMENT, file, CONSTRAINT unique_files UNIQUE(file) ON CONFLICT IGNORE);
    CREATE TABLE refs(file INTEGER, word INTEGER, FOREIGN KEY(file) REFERENCES files(id), FOREIGN KEY(word) REFERENCES words(id), CONSTRAINT unique_refs UNIQUE(word, file) ON CONFLICT IGNORE);
    """)
    
    files_to_process = []
    for arg in args:
        if arg.startswith('@'):
            list_file = arg[1:]
            if os.path.isfile(list_file):
                with open(list_file, 'r', encoding='utf-8', errors='ignore') as f:
                    for line in f:
                        line = line.strip()
                        if not line: continue
                        if os.path.isdir(line):
                            for root, _, files in os.walk(line):
                                for file in files:
                                    files_to_process.append(os.path.join(root, file))
                        else:
                            files_to_process.append(line)
        else:
            if os.path.isdir(arg):
                for root, _, files in os.walk(arg):
                    for file in files:
                        files_to_process.append(os.path.join(root, file))
            else:
                files_to_process.append(arg)
                
    # Deduplicate before queuing
    seen_files = set()
    unique_filepaths = []
    for filepath in files_to_process:
        #filepath = os.path.abspath(filepath) # left this here because I can never decide if I want to store absolute or relative paths. He he
        # Paths are stored exactly as resolved here (relative or absolute)
        filepath = os.path.normpath(filepath) 
        if filepath not in seen_files:
            seen_files.add(filepath)
            unique_filepaths.append(filepath)
    
    # Launch thread pool to handle I/O and regex parsing
    with concurrent.futures.ThreadPoolExecutor() as executor:
        # Submit all tasks
        futures = [executor.submit(extract_words_from_file, fp) for fp in unique_filepaths]
        
        # Process them as soon as they finish
        for future in concurrent.futures.as_completed(futures):
            filepath, words_in_file = future.result()
            
            if not words_in_file:
                continue
                
            print(filepath) # Mimics the 'echo "$PPPP"' progress output safely from the main thread
            
            # --- SYNCHRONIZED DATABASE INSERTION ---
            # This is strictly single-threaded, ensuring perfectly sequential IDs
            
            cur.execute("INSERT OR IGNORE INTO files(file) VALUES(?)", (filepath,))
            cur.execute("SELECT id FROM files WHERE file = ?", (filepath,))
            file_row = cur.fetchone()
            if not file_row: continue
            file_id = file_row[0]
            
            words_params = [(w,) for w in words_in_file]
            cur.executemany("INSERT OR IGNORE INTO words(word) VALUES (?)", words_params)
            
            word_list = list(words_in_file)
            refs_params = []
            # Batch word lookups to stay within SQLite's parameter limits
            for i in range(0, len(word_list), 900):
                chunk = word_list[i:i+900]
                placeholders = ','.join(['?'] * len(chunk))
                cur.execute(f"SELECT id FROM words WHERE word IN ({placeholders})", chunk)
                word_ids = [row[0] for row in cur.fetchall()]
                refs_params.extend([(file_id, wid) for wid in word_ids])
                
            cur.executemany("INSERT OR IGNORE INTO refs(file, word) VALUES (?, ?)", refs_params)
        
    # Create the index and finalize the transaction safely
    cur.execute("CREATE INDEX aaa ON words(word COLLATE NOCASE);")
    conn.commit()
    conn.close()

def grep_file(filepath, pattern_re):
    """Mimics: grep -Hn "pattern" filepath"""
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            for i, line in enumerate(f, 1):
                if pattern_re.search(line):
                    print(f"{filepath}:{i}:{line.rstrip()}")
    except Exception:
        pass

def query_db(args):
    if len(args) < 2:
        return
        
    action = args[0]
    db_path = get_db_path()
    if not os.path.exists(db_path):
        return
        
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    
    if action == 'e':
        globpattern = args[1]
        cur.execute("SELECT file FROM files WHERE id IN (SELECT file FROM refs WHERE word IN (SELECT id FROM words WHERE word GLOB ?))", (globpattern,))
        files = [row[0] for row in cur.fetchall()]
        
        # Convert GLOB to regex for internal grep
        regex_str = globpattern.replace('*', '.*').replace('?', '.?')
        pattern_re = re.compile(regex_str)
        for f in files:
            grep_file(f, pattern_re)
            
    elif action == 'w':
        globpattern = args[1]
        cur.execute("SELECT file FROM files WHERE id IN (SELECT file FROM refs WHERE word IN (SELECT id FROM words WHERE word GLOB ?))", (globpattern,))
        for row in cur.fetchall():
            print(row[0])
            
    elif action == 'wn':
        words = args[1:]
        num_words = len(words)
        if num_words == 0: return
        placeholders = ','.join(['?'] * num_words)
        query = f"""
            SELECT f.file FROM files f 
            JOIN refs r ON f.id = r.file JOIN words w ON r.word = w.id 
            WHERE w.word IN ({placeholders}) 
            GROUP BY f.id HAVING COUNT(DISTINCT w.id) = ?
        """
        cur.execute(query, words + [num_words])
        for row in cur.fetchall():
            print(row[0])
            
    elif action == 'en':
        words = args[1:]
        num_words = len(words)
        if num_words == 0: return
        placeholders = ','.join(['?'] * num_words)
        query = f"""
            SELECT f.file FROM files f 
            JOIN refs r ON f.id = r.file JOIN words w ON r.word = w.id 
            WHERE w.word IN ({placeholders}) 
            GROUP BY f.id HAVING COUNT(DISTINCT w.id) = ?
        """
        cur.execute(query, words + [num_words])
        files = [row[0] for row in cur.fetchall()]
        
        # Mimics: grep -Hn -e "word1\|word2" file
        regex_str = '|'.join(re.escape(w) for w in words)
        pattern_re = re.compile(regex_str)
        for f in files:
            grep_file(f, pattern_re)
            
    elif action == 'f':
        globpattern = args[1]
        search_glob = f"*{globpattern}*"
        cur.execute("SELECT DISTINCT file FROM files WHERE file GLOB ?", (search_glob,))
        for row in cur.fetchall():
            print(row[0])

def show_help():
    print("Usage: worddb.py build [paths...]")
    print("       worddb.py query <action> [args...]")
    print("")
    print("BUILD")
    print("=====")
    print("  Builds the word database from the specified paths.")
    print("  - Paths can be relative or absolute (and will be stored as such).")
    print("  - If a path is a directory, it will be recursively searched for files.")
    print("  - If a path starts with '@', it is treated as a list file containing")
    print("    paths (one per line) with the same semantics.")
    print("")
    print("QUERY")
    print("=====")
    print("  w  <glob>      print files containing this pattern")
    print("  e  <glob>      print lines containing this pattern")
    print("  f  <glob>      print files whose path matches pattern")
    print("  wn <words...>  print files containing multiple words")
    print("  en <words...>  print lines from files containing selected words")
    print("")
    print("  The 'e' variants print: file:linenumber: line text")
    print("  The other variants print file names.")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        show_help()
        sys.exit(2)
        
    cmd = sys.argv[1]
    if cmd == 'build':
        if len(sys.argv) < 3:
            show_help()
            sys.exit(2)
        build_db(sys.argv[2:])
    elif cmd == 'query':
        if len(sys.argv) < 3:
            show_help()
            sys.exit(2)
        query_db(sys.argv[2:])
    elif cmd in ('-h', '--help', 'help'):
        show_help()
        sys.exit(0)
    else:
        show_help()
        sys.exit(2)
