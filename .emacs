;; .emacs

(custom-set-variables
 ;; uncomment to always end a file with a newline
 ;'(require-final-newline t)
 ;; uncomment to disable loading of "default.el" at startup
 ;'(inhibit-default-init t)
 ;; default to unified diffs
 '(diff-switches "-u"))

;;; uncomment for CJK utf-8 support for non-Asian users
;; (require 'un-define)
(setq c-default-style "k&r"
      c-basic-offset 4)

(global-display-line-numbers-mode)

;; remember these!
;; (c-set-style "k&r")
;; (global-display-line-numbers-mode)
