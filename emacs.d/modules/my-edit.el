;; (require 'dash)
(require 'autorevert)
(require 're-builder)
;; (require 'calendar)
;; (require 'reftex)
;; (require 'face-remap)
(require 'conf-mode)
;; (require 'tramp)
;; (require 'elec-pair)
;; (require 'subr-x)
(require 'vc-git)
;; (require 'git-rebase)

(setq-default mode-require-final-newline nil)

;; (use-package git-timemachine)

(eval-after-load 'git-rebase
  '(progn
     (add-hook 'git-rebase-mode-hook (lambda () (read-only-mode -1)))))

(use-package git-commit
  :config
  (setq git-commit-style-convention-checks nil))

(use-package git-gutter
  :diminish git-gutter-mode
  :bind (("C-c p" . 'git-gutter:previous-hunk)
          ("C-c n" . 'git-gutter:next-hunk))
  :config
  (global-git-gutter-mode +1))
(use-package magit
  :diminish magit-auto-revert-mode
  :after (transient)
  :hook ((magit-git-mode . (lambda () (read-only-mode nil)))
          (magit-status-mode . (lambda () (save-some-buffers t))))
  :bind (:map magit-mode-map
          ("|" . evil-window-set-width)
          ("}" . evil-forward-paragraph)
          ("]" . evil-forward-paragraph)
          ("{" . evil-backward-paragraph)
          ("[" . evil-backward-paragraph)
          ("C-d" . evil-scroll-down)
          ("C-u" . evil-scroll-up)
          ("C-s" . isearch-forward)
          ("=" . balance-windows)
          ("C-w" . my/copy-diff-region)
          :map magit-hunk-section-map
          ("r" . magit-reverse)
          ("v" . evil-visual-char)
          :map magit-revision-mode-map
          ("C-s" . isearch-forward)
          ("n" . evil-search-next)
          ("p" . evil-search-previous)
          ("=" . balance-windows)
          :map magit-status-mode-map
          ("\\w" . avy-goto-word-or-subword-1)
          ("\\c" . avy-goto-char))
  :config
  (setq magit-completing-read-function 'ivy-completing-read)
  (setq magit-refresh-status-buffer nil)
  (setq magit-item-highlight-face 'bold)
  (setq magit-diff-paint-whitespace nil)
  (setq magit-ediff-dwim-show-on-hunks t)
  (setq magit-diff-hide-trailing-cr-characters t)
  (setq magit-bury-buffer-function 'magit-mode-quit-window)

  (setq auto-revert-buffer-list-filter 'magit-auto-revert-repository-buffers-p)
  (setq vc-handled-backends (delq 'Git vc-handled-backends))
  (setq magit-blame-styles
    '(
       (margin
         (margin-format " %s%f" " %C %a" " %H")
         (margin-width . 42)
         (margin-face . magit-blame-margin)
         (margin-body-face magit-blame-dimmed))
       (headings
         (heading-format . "%-20a %C %s
"))))

  (add-to-list 'magit-blame-disable-modes 'evil-mode)

  (magit-add-section-hook 'magit-status-sections-hook 'magit-insert-unpushed-to-upstream 'magit-insert-unpushed-to-upstream-or-recent)
  (magit-add-section-hook 'magit-status-sections-hook 'magit-insert-recent-commits 'magit-insert-unpushed-to-upstream-or-recent)
  (remove-hook 'magit-status-sections-hook 'magit-insert-unpushed-to-upstream-or-recent))

(setq vc-follow-symlinks t)

(use-package hydra)
;; (use-package monitor)
;; (use-package popup)
;; (use-package miniedit)
;; (use-package calfw)
(use-package with-editor)  ; dependency for other package
;; (use-package neotree)
;; (use-package multiple-cursors)
(use-package emojify)

(require 'hippie-exp)
(eval-after-load 'hippie-exp
  '(progn
     (setq hippie-expand-try-functions-list
       '(
          ;;yas-hippie-try-expand ; requires yasnippet plugin
          try-expand-all-abbrevs
          try-complete-file-name-partially
          try-complete-file-name
          try-expand-dabbrev
          try-expand-dabbrev-from-kill
          try-expand-dabbrev-all-buffers
          try-expand-list
          try-expand-line
          try-complete-lisp-symbol-partially
          try-complete-lisp-symbol))
     (setq hippie-expand-verbose nil)
     (setq hippie-expand-try-functions-list '())
     (bind-key "M-/" 'hippie-expand)
     (add-to-list 'hippie-expand-try-functions-list 'try-expand-dabbrev t)
     (add-to-list 'hippie-expand-try-functions-list 'try-expand-dabbrev-all-buffers t)
     (add-to-list 'hippie-expand-try-functions-list 'try-expand-dabbrev-from-kill t)
     (add-to-list 'hippie-expand-try-functions-list 'try-complete-lisp-symbol-partially t)
     (add-to-list 'hippie-expand-try-functions-list 'try-complete-lisp-symbol t)
     (add-to-list 'hippie-expand-try-functions-list 'try-expand-list t)
     (add-to-list 'hippie-expand-try-functions-list 'try-expand-line t)

     (defadvice hippie-expand (around hippie-expand-case-fold)
       "Try to do case-sensitive matching (not effective with all functions)."
       (let ((case-fold-search nil))
         ad-do-it))))

(use-package undo-fu)

(use-package diminish
  :config
  (progn
    ;; (diminish 'editorconfig-mode)
    (diminish 'auto-revert-mode)
    (diminish 'eldoc-mode)
    (diminish 'visual-line-mode)
    (diminish 'editorconfig-mode)
    (diminish 'js-mode "JS")
    (diminish 'abbrev-mode)))

(use-package yasnippet
  :diminish yas-minor-mode
  :config
  (progn
    ;; (add-to-list 'yas-key-syntaxes "w w")
    (setq yas-new-snippet-default
"# name: $2
# key: $1
# --
$0`(yas-escape-text yas-selected-text)`")
    (yas-global-mode 1)))

(defhydra hydra-snippet ()
  "Snippet"
  ("s" #'yas-insert-snippet "insert" :exit t)
  ("n" #'yas-new-snippet "new" :exit t)
  ("e" #'yas-visit-snippet-file "edit" :exit t)
  ("r" #'yas-reload-all "reload" :exit t))

(use-package company
  :diminish company-mode
  :config
  (progn
    (global-company-mode 1)

    (setq company-idle-delay 0.0)
    (setq company-show-numbers t)
    (setq company-tooltip-align-annotations t)
    (setq company-minimum-prefix-length 1)
    (setq company-begin-commands '(c-scope-operator c-electric-colon c-electric-lt-gt c-electric-slash))))

(use-package which-key
  :config
  (setq which-key-idle-delay 0.8)
  (which-key-mode))

;; (require 'wgrep)
;; (setq reb-re-syntax 'string)

;; (use-package imenu-anywhere
;;   :config
;;   (progn
;;     (when (fboundp 'evil-mode)
;;       (bind-key "\\a" #'ivy-imenu-anywhere  evil-motion-state-map)
;;     )))

(use-package persistent-scratch
  :config
  (persistent-scratch-setup-default))

(use-package editorconfig
  :diminish editorconfig-mode
  :config
  (editorconfig-mode 1))

(use-package auto-highlight-symbol
  :diminish auto-highlight-symbol-mode
  :config
    (setq ahs-case-fold-search nil)
    (setq ahs-idle-interval 0)
    (unbind-key "<M-right>" auto-highlight-symbol-mode-map)
    (unbind-key "<M-left>" auto-highlight-symbol-mode-map))

;; (require 'speedbar)
;; (eval-after-load 'speedbar
;;   '(progn
;;      (setq speedbar-show-unknown-files t)))
;; (use-package sr-speedbar)

(defhydra hydra-git ()
  "git"
  ("g" #'magit-blame "blame" :exit t)
  ("e" #'magit-ediff-popup "ediff" :exit t)
  ("c" #'vc-resolve-conflicts "conflicts" :exit t) ;; this could be better -> magit?
  ;; ("b" #'magit-bisect-popup "bisect") ;; find a commit that introduces the bug
  ("s" #'magit-status "status" :exit t)
  ("o" #'magit-checkout "checkout" :exit t)
  ("b" #'magit-branch-popup "branch" :exit t)
  ("d" #'magit-diff-popup "diff" :exit t)
  ("h" #'magit-diff-buffer-file "diff file" :exit t)
  ("z" #'magit-stash-popup "stash" :exit t)
  ("l" #'magit-log-popup "log" :exit t)
  ("f" #'magit-log-buffer-file "file log" :exit t))

(defvar my/flip-symbol-alist
  '(("true" . "false")
    ("false" . "true"))
  "symbols to be quick flipped when editing")

(defun my/flip-symbol ()
  "I don't want to type here, just do it for me."
  (interactive)
  (-let* (((beg . end) (bounds-of-thing-at-point 'symbol))
          (sym (buffer-substring-no-properties beg end)))
    (when (member sym (cl-loop for cell in my/flip-symbol-alist
                               collect (car cell)))
      (delete-region beg end)
      (insert (alist-get sym my/flip-symbol-alist "" nil 'equal)))))

;; (use-package transpose-frame)
;; (use-package wgrep
;; 	:config
;; 	(progn
;; 		(if (commandp 'wgrep)
;; 				(progn
;; 					(setq wgrep-enable-key "r")))))

(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-language-environment 'utf-8)

(setq visual-line-fringe-indicators '(left-curly-arrow nil))

(setq-default indent-tabs-mode nil)

(setq
  fill-column 80
  hscroll-margin  1
  hscroll-step 1
  scroll-conservatively 1001 ;; should be 0?
  scroll-preserve-screen-position t ;; ?
  word-wrap t
  compare-ignore-case t
  compare-ignore-whitespace t
  sentence-end-double-space nil
  require-final-newline nil
  revert-without-query '(".*")
  tab-width 2
  ;; undo-limit 1000
  visible-bell nil
  ring-bell-function 'ignore
  show-paren-delay 0
  ns-right-alternate-modifier nil
  save-some-buffers-default-predicate t
  help-window-select t)

(setq create-lockfiles nil)

(setq echo-keystrokes 0)

(setq x-underline-at-descent-line t)
(setq confirm-kill-processe nil)
(setq process-connection-type nil)

(when (string-equal system-type "darwin")
  (setq browse-url-chrome-program "chrome"))

(setq jarfar/pairs-hash-table (make-hash-table :test 'equal))

(when (null (gethash ?\" jarfar/pairs-hash-table))
  (puthash ?\" ?\" jarfar/pairs-hash-table))
(when (null (gethash ?\( jarfar/pairs-hash-table))
  (puthash ?\( ?\) jarfar/pairs-hash-table))
(when (null (gethash ?\[ jarfar/pairs-hash-table))
  (puthash ?\[ ?\] jarfar/pairs-hash-table))
(when (null (gethash ?\' jarfar/pairs-hash-table))
  (puthash ?\{ ?\} jarfar/pairs-hash-table))

; https://www.emacswiki.org/emacs/ElectricPair
(defun jarfar/electric-pair ()
  "If at end of line, insert character pair without surrounding spaces.
   Otherwise, just insert the typed character."
  (interactive)
  (let (parens-require-spaces) (insert-pair)))

(defun jarfar/backward-delete-char-untabify ()
  ""
  (interactive)
  (let* ((char-current (char-before))
          (char-next (char-after))
          (val-current (if (characterp char-current) (gethash char-current jarfar/pairs-hash-table))))
    (if (equal char-next val-current)
      (progn (left-char) (delete-pair))
      (backward-delete-char-untabify 1))))

(dolist (elt (hash-table-keys jarfar/pairs-hash-table))
  (define-key text-mode-map (char-to-string elt) 'jarfar/electric-pair))

(dolist (elt (hash-table-keys jarfar/pairs-hash-table))
  (define-key conf-mode-map (char-to-string elt) 'jarfar/electric-pair))

(setq auto-save-visited-interval 60)

; https://emacs.stackexchange.com/questions/10932/how-do-you-disable-the-buffer-end-beginning-warnings-in-the-minibuffer/20039#20039
(defun my/command-error-function (data context caller)
  "Ignore the buffer-read-only, beginning-of-buffer,
end-of-buffer signals; pass the rest to the default handler."
  (when (not (memq (car data) '(
                                 ;; buffer-read-only
                                 beginning-of-buffer
                                 end-of-buffer)))
    (command-error-default-function data context caller)))

(setq command-error-function #'my/command-error-function)


;; (defun my/set-syntax-entry ()
;;   ""
;;   (when (and (not (eq major-mode "php-mode")) (not (eq major-mode "web-mode")))
    ;; (modify-syntax-entry ?- "w" (syntax-table)))
;;   (modify-syntax-entry ?_ "w" (syntax-table)))

;; (add-hook 'after-change-major-mode-hook #'my/set-syntax-entry)

(when (fboundp 'imagemagick-register-types)
  (imagemagick-register-types))

(setq ack-path (executable-find "ack"))

(defalias 'yes-or-no-p 'y-or-n-p)
(defalias 'ar #'align-regexp)

;; (if ack-path
  ;; (grep-apply-setting 'grep-command "ack --with-filename --nofilter --nogroup ")
  ;; (message "No 'ack' executable found."))

  ;; (setq grep-program grep-command) ; ack
    ;; (setq sr-grep-command grep-program)
    ;; (grep-apply-setting 'grep-command "ack --with-filename --nofilter --nogroup ")
    ;; "ack --with-filename --nofilter --nogroup ")
    ;; (grep-apply-setting 'grep-command "ack --with-filename --nofilter --nogroup ")
    ;; (grep-apply-setting 'grep-find-template "find <D> <X> -type f <F> -exec ack --with-filename --nofilter --nogroup '<R>' /dev/null {} +")

  ;;   (grep-apply-setting 'grep-find-template
  ;;     (concat "find . -type f -exec " ack-path " --with-filename --nofilter --nogroup '<R>' /dev/null {} +"))
  ;;   )
  ;; (message "No 'ack' executable found.")
  ;; )

(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; (require 'grep)
;; (eval-after-load 'grep
;; 	'(progn
;; 		 (add-to-list 'grep-find-ignored-directories "auto-save-list")
;; 		 (add-to-list 'grep-find-ignored-directories "autosaves")
;; 		 (add-to-list 'grep-find-ignored-directories "backups")
;; 		 (add-to-list 'grep-find-ignored-directories "elpa")
;; 		 (add-to-list 'grep-find-ignored-directories "lisp")
;; 		 (add-to-list 'grep-find-ignored-directories "tools"))

;; (add-hook 'minibuffer-inactive-mode-hook
;;   (lambda ()
;;     (message (buffer-name (current-buffer)))
;;     ))

;; (advice-add 'text-scale-adjust )

(defun my/quail-setup-overlays-advice (orig-fun &rest args)
  (let ((res (apply orig-fun args))
         (buf-guidence (get-buffer " *Quail-guidance*"))
         (buf-completions (get-buffer "*Quail Completions*")))
	  ;; (overlay-put quail-overlay 'display 'underline)
	  ;; (overlay-put quail-conv-overlay 'display 'underline)

    (dolist
      (buf (list buf-guidence buf-completions))
      (when (bufferp buf)
        ;; (message (buffer-name buf))
        (with-current-buffer buf
          (set (make-local-variable 'face-remapping-alist)
            `((default :height 3))))))
    res))

;; (advice-add 'quail-setup-overlays :after #'my/quail-setup-overlays-advice)
;; (advice-add 'quail-show-guidance :around #'my/quail-setup-overlays-advice)

(defun my/list-frames (orig-fun &rest args)
  (let ((res (apply orig-fun args)))
    (message "here")
    (frame-list)
    (res))
  )

;; (advice-add 'quail-make-guidance-frame :around #'my/list-frames)

(defun my/minibuffer-setup ()
  (let* (
          ;; (buf (buffer-name (window-buffer (minibuffer-selected-window))))
          (buf (window-buffer (minibuffer-selected-window)))
          (amount (buffer-local-value 'text-scale-mode-amount buf))
          (amount-new
            (cond
              ((= amount 1) 1)
              ((= amount 0) 1)
              ((> amount 1) (* 0.75 amount))
              ((<= amount 0) 1))))

    (set (make-local-variable 'face-remapping-alist)
      `((default :height ,(float amount-new))))
    ))

;; (add-hook 'minibuffer-setup-hook 'my/minibuffer-setup)

    ;; (dolist
      ;; (buf (list "*Quail Completions*" "*code-conversion-work*" " *code-conversion-work*" " *Minibuf-0*" " *Minibuf-1*" " *Echo Area 0*" " *Echo Area 1*"))
      ;; (when (get-buffer buf)

    ;; (when (string= (buffer-name buf) "*Quail Completions*") ;; " *Minibuf-0*" " *Minibuf-1*" " *Echo Area 0*" " *Echo Area 1*")
      ;; (with-current-buffer buf
      ;; (setq-local face-remapping-alist '((default (:height 1))))))))


(setq bookmark-save-flag t)

;; (use-package company-emoji
;;   :config
;;   (progn
;;     (add-to-list 'company-backends 'company-emoji)))

;; (defun my/set-emoji-font (frame)
;;   "Adjust the font settings of FRAME so Emacs can display emoji properly."
;;   (if (eq system-type 'darwin)
;;       ;; For NS/Cocoa
;;       (set-fontset-font t 'symbol (font-spec :family "Apple Color Emoji") frame 'prepend)
;;     ;; For Linux
;;     (set-fontset-font t 'symbol (font-spec :family "Symbola") frame 'prepend)))

;; For when Emacs is started in GUI mode:
;; (my/set-emoji-font nil)

;; Hook for when a frame is created with emacsclient
;; see https://www.gnu.org/software/emacs/manual/html_node/elisp/Creating-Frames.html
;; (add-hook 'after-make-frame-functions 'my/set-emoji-font)

(require 'inc-dec-at-point)
(eval-after-load 'inc-dec-at-point
  '(progn
     (bind-key "C-c +" 'increment-integer-at-point)
     (bind-key "C-c -" 'decrement-integer-at-point)))

(defhydra hydra-buffer ()
  "Buffer"
  ("i" #'ibuffer "ibuffer" :exit t))

;; (defun my/buffer-messages-tail ()
  ;; (let ((messages (get-buffer "*Messages*")))
    ;; (unless (eq (current-buffer) messages)
      ;; (with-current-buffer messages
        ;; (goto-char (point-max))))))

;; http://emacsredux.com/blog/2013/03/27/copy-filename-to-the-clipboard
;; (defun my/copy-file-name-to-clipboard ()
;;   "Copy the current buffer file name to the clipboard."
;;   (interactive)
;;   (let ((filename (if (equal major-mode 'dired-mode)
;;                       default-directory
;;                     (buffer-file-name))))
;;     (when filename
;;       (kill-new filename)
;;       (message "Copied buffer file name '%s' to the clipboard." filename))))

;; (add-hook 'post-command-hook 'my/buffer-messages-tail)

(defun my/copy-file-name ()
  "Copy the current buffer file name to the clipboard."
  (interactive)
  (let ((filename
          (if (equal major-mode 'dired-mode)
            default-directory
            (buffer-file-name))))
    (when filename
      (kill-new filename)
      (message "Copied buffer file name '%s' to the clipboard." filename))))

(defun air-revert-buffer-noconfirm ()
  (interactive)
  (revert-buffer :ignore-auto :noconfirm)
  (message (concat "Buffer '" (file-name-nondirectory buffer-file-name) "' reloaded.")))

(defun my/move-current-window-to-new-frame ()
  (interactive)
  (let ((buffer (current-buffer)))
    (unless (one-window-p)
      (delete-window))
    (display-buffer-pop-up-frame buffer nil)))

(defun my/buffer-tramp-p ()
  "Returns t if buffer is tramp buffer."
  ; file-remote-p
  (interactive)
  (let ((name (buffer-file-name)))
    (and name (string-prefix-p "/ssh:" name))))

(defun my/advice-around-skip (orig-fun &rest args) "")

(defun sudo-dired ()
  (interactive)
  (dired "/sudo::/"))

(defun my/reinstall-package (pkg)
  (interactive (list (intern (completing-read "Reinstall package: " (mapcar #'car package-alist)))))
  (unload-feature pkg)
  (package-reinstall pkg)
  (require pkg))

(defvar epa-key-mode-map (make-sparse-keymap))
(defvar org-mode-map (make-sparse-keymap))
(defvar mu4e:view-mode-map (make-sparse-keymap))
(defvar mu4e-headers-mode-map (make-sparse-keymap))
(defvar mu4e-compose-mode-map (make-sparse-keymap))
;; (defvar flyspell-mode-map (make-sparse-keymap))
(defvar elpy-mode-map (make-sparse-keymap))
(defvar js2-mode-map (make-sparse-keymap))
(defvar eshell-mode-map (make-sparse-keymap))
(defvar php-mode-map (make-sparse-keymap))
(defvar web-mode-map (make-sparse-keymap))

(bind-key "C-x C-r"       'recentf-open-files)
(bind-key "<home>"        'left-word)
(bind-key "<end>"         'right-word)
(bind-key "C-x <left>"    'windmove-left)
(bind-key "C-x <right>"   'windmove-right)
(bind-key "C-x <up>"      'windmove-up)
(bind-key "C-x <down>"    'windmove-down)
(bind-key "C-x s"         (lambda () (interactive) (save-some-buffers t)))
(bind-key "C-x 4 c"       'my/clone-indirect-buffer-new-window)
(bind-key "s-t"           'make-frame-command)

(bind-key "C-x C-SPC"     'rectangle-mark-mode)
(bind-key "C->"           'mc/mark-next-like-this)
(bind-key "C-<"           'mc/mark-previous-like-this)
(bind-key "C-c C-<"       'mc/mark-all-like-this)
(bind-key "s-u"           'air-revert-buffer-noconfirm)
;; (bind-key "C-c O"      'org-open-at-point-global)

(defalias 'qcalc 'quick-calc)

(column-number-mode 1)
(global-auto-revert-mode 1)
(show-paren-mode 1)
(global-visual-line-mode 1)
(global-emojify-mode 1)
(delete-selection-mode 1)
(global-hl-line-mode 1)
;; (auto-save-visited-mode)
(auto-compression-mode 1)
(reveal-mode 1)

(advice-add 'visual-line-mode :around
  (lambda (orig-fun &rest args)
    (unless (memq major-mode (list 'org-agenda-mode))
      (apply orig-fun args))))

(blink-cursor-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(when window-system (tool-bar-mode -1))

(add-to-list 'same-window-buffer-names "*SQL*")

(provide 'my-edit)
