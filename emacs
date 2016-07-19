;; ---------------------------------------------------------------------------
;; Key Map
;; ---------------------------------------------------------------------------

;; C-x C-f           : open
;; C-x C-s           : save
;; C-x C-w           : save as ..
;; C-x 1             : make current window the only one
;; C-x 2             : split window horizontally
;; C-x 3             : split window vertically
;; C-q               : kill current buffer

;; C-s               : search
;; C-r               : query replace

;; C-d               : copy region
;; C-w               : cut region
;; C-y, C-v          : paste region
;; C-a               : undo

;; C-k               : kill cursor -> line end
;; C-o               : insert new line
;; C-f               : jump forward to next window
;; C-e               : goto line
;; C-b               : buffer list

;; M-SPACE           : recenter on cursor position

;; C-Page-Up         : cycle to next buffer
;; C-Page-Down       : cycle to previous buffer

;; S-right           : extend marked region
;; S-left            : extend marked region
;; S-up              : extend marked region
;; S-down            : extend marked region

;; C-right           : scroll to the right
;; C-left            : scroll to the left
;; C-up              : scroll up
;; C-down            : scroll down

;; M-right           : extend window horizontally
;; M-left            : shrink window horizontally
;; M-up              : extend window vertically
;; M-down            : shrink window vertically

;; F1                : manual entry
;; F2                : info
;; F3                : 
;; F4                : eval current buffer

;; F5                :
;; F6                :
;; F7                : 
;; F8                : make

;; F9                :  
;; F10               : calculator
;; F11               : shell
;; F12               : speedbar




;; ---------------------------------------------------------------------------
;; Initialization
;; ---------------------------------------------------------------------------

;; This file is designed to be re-evaled; use the variable first-time
;; to avoid any problems with this.
(defvar first-time t 
  "Flag signifying this is the first time that .emacs has been evaled")

;; start of in dir ..
(cd "/vobs/bil_source")
;(dired "~/sandbox")
(speedbar)

;; extend load path
(setq load-path (cons "~" load-path))
(setq load-path (cons "~/bin" load-path))
(setq load-path (cons "c:/cygwin/home/Administrator/" load-path))

;; localization
(standard-display-european t)
(set-language-environment "latin-1")

;; Treat 'y' or <CR> as yes, 'n' as no.
(fset 'yes-or-no-p 'y-or-n-p)
(define-key query-replace-map [return] 'act)
(define-key query-replace-map [?\C-m] 'act)

;(setq my-author-name (getenv "USER"))
;(setq user-full-name (getenv "USER"))
(setq my-author-name "Tobias Oberstein")
(setq user-full-name "Tobias Oberstein")
(setq user-mail-address "tobias.oberstein@gmx.de")

;show time on status bar
(setq display-time-day-and-date t )
(setq display-time-24hr-format t)
(display-time)		
						

;; ---------------------------------------------------------------------------
;; Customization Section
;; ---------------------------------------------------------------------------
(custom-set-variables
 '(indent-tabs-mode nil)                  ; use spaces (not tabs) for indenting
 '(efault-fill-column 77)                 ; the column beyond which do word wrap
 '(scroll-preserve-screen-position t)     ; make pgup/dn remember current line
 '(make-backup-files nil)
 '(inhibit-startup-message t)
 '(visible-bell t)	 
 '(frame-title-format (list "%65b %f"))
 '(icon-title-format (list "%b"))
 '(mark-even-if-inactive t)
 '(next-line-add-newlines nil)
 '(compile-command "make")
 '(suggest-key-bindings nil)
 '(column-number-mode t)
 '(confirm-kill-emacs nil)
 '(global-hl-line-mode t nil (hl-line))
 '(mouse-wheel-mode t nil (mwheel))
 '(next-line-add-newlines nil)
 '(pc-selection-mode t nil (pc-select))
 '(require-final-newline (quote ask))
 '(tab-width 4)
 '(transient-mark-mode t)
 '(delete-selection-mode t)
 '(windmove-wrap-around t))
(custom-set-faces
 )


;; ---------------------------------------------------------------------------
;; Key Bindings
;; ---------------------------------------------------------------------------

;; Control tab quotes a tab.
(global-set-key [C-tab] "\C-q\t")


;; buffer handling
(global-set-key "\C-b" 'bs-show)
(global-set-key [C-next] 'bs-cycle-previous)   ;; next == pagedown
(global-set-key [C-prior] 'bs-cycle-next)      ;; prior == pageup
(global-set-key "\C-q" 'kill-buffer) ;; delete-window

;; window handling
;(global-set-key [C-tab] 'other-window)
(global-set-key "\C-f" 'other-window)
(global-set-key "\C-e" 'goto-line)

;; basic editing
(global-set-key "\C-d" 'copy-region-as-kill-nomark)
;(global-set-key "\C-f" 'kill-region)
(global-set-key "\C-v" 'yank)
(global-set-key "\C-a" 'undo)

;; search & replace
(global-set-key "\C-s" 'isearch-forward)
(global-set-key "\C-r" 'query-replace)

;; allow region selection by holding down CTRL key and moving cursor
;; this overrides bindings in: pc-select.el
(define-key global-map [C-right]   'forward-char-mark)
(define-key global-map [C-left]    'backward-char-mark)
(define-key global-map [C-down]    'next-line-mark)
(define-key global-map [C-up]      'previous-line-mark)

;; panning
;;
(defun scrollup (&optional arg)
  (interactive "p")
  (scroll-up-nomark 1))

(defun scrolldown (&optional arg)
  (interactive "p")
  (scroll-down-nomark 1))

(defun scrollleft (&optional arg)
  (interactive "p")
  (scroll-left 1))

(defun scrollright (&optional arg)
  (interactive "p")
  (scroll-right 1))

(define-key global-map [M-up]    'scrolldown)
(define-key global-map [M-down]  'scrollup)
(define-key global-map [M-left]  'scrollright)
(define-key global-map [M-right] 'scrollleft)

;; window resizing
;;
(define-key global-map [M-C-right]   'enlarge-window-horizontally)
(define-key global-map [M-C-left]    'shrink-window-horizontally)
(define-key global-map [M-C-up]      'enlarge-window)
(define-key global-map [M-C-down]    'shrink-window)

;; recenter on cursor position
(define-key global-map "\M- " 'recenter)


;; Function keys
;;
(global-set-key [f1] 'manual-entry)
(global-set-key [f2] 'info)
;(global-set-key [f3] 'xxx)
(global-set-key [f4] 'eval-current-buffer)

;(global-set-key [f5] 'xxx)
;(global-set-key [f6] 'xxx)
;(global-set-key [f7] 'xxx)
(global-set-key [f8] 'compile)

;(global-set-key [f9] 'xxx)
(global-set-key [f10] 'calculator)
(global-set-key [f11] 'shell)
(global-set-key [f12] 'speedbar)


;; ---------------------------------------------------------------------------
;; Mouse
;; ---------------------------------------------------------------------------

;; Mouse
(global-set-key [mouse-3] 'imenu)
    
    

;; ---------------------------------------------------------------------------
;; Appearance
;; ---------------------------------------------------------------------------

;; startup frame size in characters x characters
(setq initial-frame-alist
	  '((top . 1) (left . 1) (width . 123) (height . 43))
	  )


(require 'font-lock)
(global-font-lock-mode t)
(setq font-lock-mode-maximum-decoration t)
(setq font-lock-use-default-fonts nil)
(setq font-lock-use-default-colors nil)

(set-background-color "#333366")
(set-foreground-color "#ffffff")
(set-cursor-color "#ffff00")
(set-mouse-color "#ffff00") 

(set-face-foreground 'modeline "#000000")
(set-face-background 'modeline "#9999aa")
;(set-face-background 'modeline "DarkSlateGrey")


;Used (typically) for comments. 
(copy-face 'default 'font-lock-comment-face)
(set-face-foreground 'font-lock-comment-face "#8888ff")

;Used (typically) for string constants. 
(copy-face 'default 'font-lock-string-face)
(set-face-foreground 'font-lock-string-face "#ffcc99") ;; #ffaacc

;Used (typically) for keywords--names that have special
 ;syntactic significance, like for and if in C. 
(copy-face 'bold 'font-lock-keyword-face)
(set-face-foreground 'font-lock-keyword-face "#ffff66")

;Used (typically) for built-in function names. 
(copy-face 'bold 'font-lock-builtin-face)
(set-face-foreground 'font-lock-builtin-face "#ffcc66")  ;; #ffcc66

;Used (typically) for the name of a function being defined or
;declared, in a function definition or declaration. 
(copy-face 'bold 'font-lock-function-name-face)
(set-face-foreground 'font-lock-function-name-face "#ffffff")

;Used (typically) for the name of a variable being defined or
;declared, in a variable definition or declaration. 
(copy-face 'bold 'font-lock-variable-name-face)
(set-face-foreground 'font-lock-variable-name-face "#ffffff")
 
;Used (typically) for names of user-defined data types,
;where they are defined and where they are used. 
(copy-face 'bold 'font-lock-type-face)
(set-face-foreground 'font-lock-type-face "#66ff66")

;Used (typically) for constant names. 
(copy-face 'default 'font-lock-constant-face )
(set-face-foreground 'font-lock-constant-face  "#ffcc99")   ;; #ffaacc

;Used (typically) for constructs that are peculiar, or that greatly
;change the meaning of other text. For example, this is used for
;`;;;###autoload' cookies in Emacs Lisp, and for #error directives in C. 
(copy-face 'bold 'font-lock-warning-face )
(set-face-foreground 'font-lock-warning-face  "#ff0000")

;(set-default-font "-raster-Fixedsys-normal-r-normal-normal-12-90-96-96-c-80-iso8859-1")
;(set-default-font "-Misc-Fixed-Medium-R-Normal--15-140-75-75-C-90-ISO8859-1")
;(set-default-font "-Misc-Fixed-Medium-R-Normal--15-140-75-75-C-90-ISO8859-1")


;; ---------------------------------------------------------------------------
;; Functions
;; ---------------------------------------------------------------------------

;; convert a buffer from dos ^M end of lines to unix end of lines
(defun dos2unix ()
  (interactive)
  (goto-char (point-min))
  (while (search-forward "\r" nil t) (replace-match "")))

;; convert a buffer from unix end of lines to dos ^M end of lines
(defun unix2dos ()
  (interactive)
  (goto-char (point-min))
  (while (search-forward "\n" nil t) (replace-match "\r\n")))

;; complement to next-error
(defun previous-error (n)
  "Visit previous compilation error message and corresponding source code."
  (interactive "p")
  (next-error (- n)))

;;ASCII table function
(defun ascii-table ()
  "Print the ascii table. Based on a defun by Alex Schroeder <asc@bsiag.com>"
  (interactive)  (switch-to-buffer "*ASCII*")  (erase-buffer)
  (insert (format "ASCII characters up to number %d.\n" 254)) 
  (let ((i 0))
	(while (< i 254)      (setq i (+ i 1))
		   (insert (format "%4d %c\n" i i))))  (beginning-of-buffer))


;; ---------------------------------------------------------------------------
;; Python
;; ---------------------------------------------------------------------------

;(setq auto-mode-alist
;      (cons '("\\.py$" . python-mode) auto-mode-alist))

(setq interpreter-mode-alist
      (cons '("python" . python-mode)
            interpreter-mode-alist))

(autoload 'python-mode "python-mode" "Python editing mode." t)


;; ---------------------------------------------------------------------------
;; Flex/Bison
;; ---------------------------------------------------------------------------

;(setq auto-mode-alist
;      (cons '("\\.y$" . bison-mode) auto-mode-alist))

(autoload 'bison-mode "bison-mode" "Yacc/Bison editing mode." t)


;(setq auto-mode-alist
;      (cons '("\\.l$" . flex-mode) auto-mode-alist))

(autoload 'flex-mode "flex-mode" "Lex/Flex editing mode." t)


;; ---------------------------------------------------------------------------
;; Text mode
;; ---------------------------------------------------------------------------

(defun my-text-mode-hook ()
  (setq auto-fill-mode t) ; make lines wrap automatically in text mode.
  (setq tab-width 4)
  )

(add-hook 'text-mode-hook
          'my-text-mode-hook)

;; ---------------------------------------------------------------------------
;; C/C++
;; ---------------------------------------------------------------------------

;; C++ hook
(defun my-c++-mode-hook ()
  (setq tab-width 4)
  (define-key c++-mode-map "\C-m" 'reindent-then-newline-and-indent)
  (define-key c++-mode-map "\C-ce" 'c-comment-edit)
  (setq c++-auto-hungry-initial-state 'none)
  (setq c++-delete-function 'backward-delete-char)
  (setq c++-tab-always-indent t)
  (setq c-indent-level 4)
  (setq c-continued-statement-offset 4)
  (setq c++-empty-arglist-indent 4)
)
    
;; C hook
(defun my-c-mode-hook ()
  (setq tab-width 4)
  (define-key c-mode-map "\C-m" 'reindent-then-newline-and-indent)
  (define-key c-mode-map "\C-ce" 'c-comment-edit)
  (setq c-auto-hungry-initial-state 'none)
  (setq c-delete-function 'backward-delete-char)
  (setq c-tab-always-indent t)
  (setq c-indent-level 4)
  (setq c-continued-statement-offset 4)
  (setq c-brace-offset -4)
  (setq c-argdecl-indent 0)
  (setq c-label-offset -4)
)
    

;; add C/C++ hooks
(add-hook 'c++-mode-hook 'my-c++-mode-hook)
(add-hook 'c-mode-hook 'my-c-mode-hook)


;; ---------------------------------------------------------------------------
;; Oracle PL/SQL Mode
;; ---------------------------------------------------------------------------

;; sql-mode.el       Jim Lange             SQL*Plus 
;; pls-mode.el       Dmitry Nizhegorodov   SQL*Plus 
;; plsql-mode.el     Karel Sprenger        SQL*Plus 
;; sqlforms-mode.el  Karel Sprenger        SQL*Froms 


;(setq font-lock-use-maximal-decoration-gnu-emacs t)
;(setq font-lock-use-maximal-decoration t)

;(autoload 'pls-mode  "pls-mode" "PL/SQL Editing Mode" t)
;(autoload 'diana-mode  "pls-mode" "DIANA for PL/SQL Browsing Mode" t)

;(setq auto-mode-alist
;      (append '(("\\.pls$"  . pls-mode)
;                ("\\.sql$"  . pls-mode)
;                ("\\.pld$"  . diana-mode)
;                ("\\.vws$"  . pls-mode)
;                ("\\.vwb$"  . pls-mode)
;                ) auto-mode-alist))

;(setq pls-mode-hook '(lambda ()
;                       (font-lock-mode t)
;                       (setq font-lock-use-maximal-decoration-gnu-emacs t)
;                       (setq font-lock-use-maximal-decoration t)
;                       )
;      )



;; ---------------------------------------------------------------------------
;; Oracle PL/SQL Mode
;; ---------------------------------------------------------------------------

(autoload 'plsql-mode  "plsql-mode" "PL/SQL Editing Mode" t)

(setq auto-mode-alist
      (append '(("\\.pls$"  . plsql-mode)
                ("\\.sql$"  . plsql-mode)
                ("\\.vws$"  . plsql-mode)
                ("\\.vwb$"  . plsql-mode)
                ("\\.vrs$"  . plsql-mode)
                ("\\.vrb$"  . plsql-mode)
                ) auto-mode-alist))

(setq plsql-mode-hook '(lambda ()
                         (local-set-key "\C-p" 'align-current)
                         )
      )

(speedbar-add-supported-extension "pls")
(speedbar-add-supported-extension "sql")
(speedbar-add-supported-extension "vws")
(speedbar-add-supported-extension "vwb")
(speedbar-add-supported-extension "vrs")
(speedbar-add-supported-extension "vrb")

;; ---------------------------------------------------------------------------
;; File Extension -> Mode Bindings
;; ---------------------------------------------------------------------------

(if first-time
    (setq auto-mode-alist
          (append '(
					("\\.cpp$" . c++-mode)
					("\\.h$" . c++-mode)
					("\\.i$" . c++-mode)
					("\\.hpp$" . c++-mode)
					("\\.c$" . c-mode)
					("\\.py$" . python-mode)
					("\\.y$" . bison-mode)
					("\\.l$" . flex-mode)
					("\\.lsp$" . lisp-mode)
					("\\.scm$" . scheme-mode)
					("\\.pl$" . perl-mode)
					) auto-mode-alist)))


;; ---------------------------------------------------------------------------
;; Autoloading of font lock modes
;; ---------------------------------------------------------------------------

(defvar font-lock-auto-mode-list 
  (list 'python-mode 'flex-mode 'bison-mode 'c-mode 'c++-mode 'c++-c-mode
		'emacs-lisp-mode 'lisp-mode 'perl-mode 'scheme-mode 'pls-mode 'diana-mode)
  "List of modes to always start in font-lock-mode")
    
(defun font-lock-auto-mode-select ()
  "Automatically select font-lock-mode if the current major mode is
    in font-lock-auto-mode-list"
  (if (memq major-mode font-lock-auto-mode-list) 
      (progn
        (font-lock-mode t))
    )
  )

(add-hook 'find-file-hooks 'font-lock-auto-mode-select)


;; ---------------------------------------------------------------------------
;; Exit
;; ---------------------------------------------------------------------------

;; Indicate that this file has been read at least once
(setq first-time nil)

;; No need to debug anything now
(setq debug-on-error nil)



;(find-file "c:/_emacs")

;(find-file "c:/emacs-21.1/lisp/progmodes/plsql-mode.el")

;(find-file "o:/bil_source/bil_apps/db/vo_sp/rbs_pa_monitoring_manager.vws")
;(find-file "o:/bil_source/bil_apps/db/vo_sp/rbs_pa_monitoring_manager.vwb")

;(find-file "o:/rbi_source/rat/db/vo_sp/rbi_pa_delta_manager.vrs")
;(find-file "o:/rbi_source/rat/db/vo_sp/rbi_pa_delta_manager.vrb")


;; All done
(message "OK, ready to rock.")



(put 'eval-expression 'disabled nil)
