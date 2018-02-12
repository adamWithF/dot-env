; Folder with manualy added packages
(add-to-list 'load-path "~/.emacs.d/lisp/")

(require 'cl)

(setq package-list '(color-theme-sanityinc-tomorrow
                     persistent-scratch
                     git-gutter
                      centered-cursor-mode
                      auto-highlight-symbol
                      hl-todo
                      rainbow-mode
                      editorconfig
                      ido-completing-read+
                      ido-vertical-mode
                      smex ; better search for ido mode
                      ;; org-journal
                      multiple-cursors
                      ;; swiper
                      neotree
                      wgrep
                                        ; projectile

                    ))

(setq package-archives '(("elpa" . "http://tromey.com/elpa/")
                          ("gnu" . "http://elpa.gnu.org/packages/")
                          ("melpa-stable" . "https://stable.melpa.org/packages/")
                          ("melpa" . "https://melpa.org/packages/")
                          ))

(package-initialize)

; fetch the list of packages available
(unless package-archive-contents
  (package-refresh-contents))

; install the missing packages
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

(require 'framemove)
(require 'sunrise-commander)
(require 'multiple-cursors)
;; (require 'helm)
(require 'neotree)
(require 'ido)
(require 'ido-completing-read+)
(require 'ido-vertical-mode)
(require 'grep)
(require 'wgrep)

;; config
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))
(setq
  backup-by-copying t
  kept-new-versions 5
  kept-old-versions 5
  delete-old-versions t
  version-control t)
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/autosaves/\\1" t)))
(setq visible-bell 1)
(setq ring-bell-function 'ignore)
(setq inhibit-startup-screen t)
(setq ns-right-alternate-modifier nil)
(setq tab-width 2)
(setq
  dired-use-ls-diredto nil
  dired-recursive-copies 'always
  dired-recursive-deletes 'always)
(setq ahs-idle-interval 0)
(setq bookmark-save-flag nil)
(setq show-paren-delay 0)
(setq recentf-max-menu-items 25)
(setq help-window-select t)
(setq-default word-wrap t)

(defalias 'yes-or-no-p 'y-or-n-p)

(when (eq system-type 'darwin)
  (require 'ls-lisp)
  (setq ls-lisp-use-insert-directory-program nil))

(setq diredp-hide-details-initially-flag nil)
(require 'dired+)
(diredp-toggle-find-file-reuse-dir 1)

;; Helm
;; (setq helm-completion-in-region-fuzzy-match t
;;   helm-mode-fuzzy-match t)

;; TODO is it good?
;; (defun spacemacs//helm-hide-minibuffer-maybe ()
;;   "Hide minibuffer in Helm session if we use the header line as input field."
;;   (when (with-helm-buffer helm-echo-input-in-header-line)
;;     (let ((ov (make-overlay (point-min) (point-max) nil nil t)))
;;       (overlay-put ov 'window (selected-window))
;;       (overlay-put ov 'face
;;                    (let ((bg-color (face-background 'default nil)))
;;                      `(:background ,bg-color :foreground ,bg-color)))
;;       (setq-local cursor-type nil))))

;; (add-hook 'helm-minibuffer-set-up-hook
;;           'spacemacs//helm-hide-minibuffer-maybe)

;; (setq helm-autoresize-max-height 0)
;; (setq helm-autoresize-min-height 20)
;; (helm-autoresize-mode 1)

;; ido

;; (setq ido-use-faces nil)

;; sunrise commander
(defun mc ()
  "Open sunrise commander in default directory."
  (interactive)
  (make-frame-command)
  (sunrise default-directory default-directory)
  )

;; delete redundant window in MC mode
(add-hook 'sr-start-hook (lambda ()
                           (delete-window (car (last (window-list))))))

(add-hook 'org-mode-hook (lambda ()
													 (local-unset-key (kbd "C-c $")) ; removed archive subtree shortcut
													 (local-unset-key (kbd "C-c C-x C-a")) ; remove archive subtree default shortcut
													 (local-unset-key (kbd "C-c C-x C-s")) ; remove archive subtree shortcut
													 (local-unset-key (kbd "C-c C-x A")) ; remove archive to archive siblings shortcut
													 ))

;; Mappings / Shortcuts
(global-set-key (kbd "C-x C-b") 'ibuffer) ; list buffers for editing
(global-set-key (kbd "C-x p") #'git-gutter:previous-hunk)
(global-set-key (kbd "C-x n") #'git-gutter:next-hunk)
(global-set-key (kbd "C-c n") #'neotree-toggle)
(global-set-key (kbd "C-x C-r") 'recentf-open-files)
(global-set-key (kbd "C-x e") 'revert-buffer-noconfirm)
;; Org mode
(global-set-key (kbd "\C-cc") #'org-capture)
(global-set-key (kbd "C-x a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

;; Helm
;; (global-set-key (kbd "M-x") #'helm-M-x)
;; (global-set-key (kbd "C-x C-r") #'helm-recentf)
;; (global-set-key (kbd "C-x C-f") #'helm-find-files)
                                        ; (global-set-key (kbd "C-x r b") #'helm-filtered-bookmarks)
;; (global-set-key (kbd "C-x b") #'helm-mini)
;; (global-set-key (kbd "C-c h") #'helm-command-prefix)
;; (define-key helm-map (kbd "<tab>") #'helm-execute-persistent-action) ; rebind tab to do persistent action
;; (define-key helm-map (kbd "C-i") #'helm-execute-persistent-action) ; make TAB works in terminal
;; (define-key helm-map (kbd "C-z")  #'helm-select-action) ; list actions using C-z
(global-unset-key (kbd "C-x c"))
(global-unset-key (kbd "C-x <C-left>"))
(global-unset-key (kbd "C-x <C-right>"))
(global-unset-key (kbd "s-w"))
(global-set-key (kbd "C-x <left>") 'windmove-left)
(global-set-key (kbd "C-x <right>") 'windmove-right)
(global-set-key (kbd "C-x <up>") 'windmove-up)
(global-set-key (kbd "C-x <down>") 'windmove-down)


;; (when (executable-find "curl")
;;   (setq helm-google-suggest-use-curl-p t))

;; (setq helm-split-window-inside-p t
;;   helm-move-to-line-cycle-in-source t
;;   helm-ff-search-library-in-sexp t
;;   helm-scroll-amount 8
;;   helm-ff-file-name-history-use-recentf t
;;   helm-echo-input-in-header-line t)

;; Multiline cursor
(global-set-key (kbd "C->") #'mc/mark-next-like-this)
(global-set-key (kbd "C-<") #'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") #'mc/mark-all-like-this)

(eval-after-load 'dired-mode
  (lambda ()
    (define-key (kbd "t") (dired-toggle-marks)) ; toggle marks
    ))

(add-hook 'dired-mode
  (lambda ()
    (define-key (kbd "<left>") (diredp-up-directory-reuse-dir-buffer))
    ))

(defun revert-buffer-noconfirm ()
  (interactive)
  (revert-buffer :ignore-auto :noconfirm)
  (message (concat "Buffer '" (file-name-nondirectory buffer-file-name) "' reloaded.")))

(if (commandp 'wgrep)
  (progn
    (setq wgrep-enable-key "r")
    )
  )

;; Ido
(ido-mode t)

(setq ido-use-faces t)


(if (commandp 'ido-ubiquitous-mode)
  (progn
    (ido-everywhere 1)
    (ido-ubiquitous-mode 1))
  (message "No 'ido-ubiquitous-mode' found.")
  )

(if (commandp 'ido-vertical-mode)
  (progn
    (ido-vertical-mode 1)
    (setq ido-vertical-define-keys 'C-n-C-p-up-down-left-right)
    (setq ido-vertical-show-count t))
  (message "No 'ido-vertical-mode' found.")
  )

(if (commandp 'smex)
  (progn
    (global-set-key (kbd "M-x") 'smex))
  (message "No 'smex' command found.")
  )

;; General
(setq vc-follow-symlinks t)

;; Modes
(global-auto-revert-mode 1)
(blink-cursor-mode 0)
(global-linum-mode 1)
(editorconfig-mode 1)
(recentf-mode 1)
(show-paren-mode 1)
(delete-selection-mode 1)
(scroll-bar-mode -1)
(if window-system (tool-bar-mode -1))

;; Helm
;; (setq helm-ff-auto-update-initial-value t)

;; programming
(setq devel-buffers '("js" "jsx" "vim" "json" "java" "php" "css" "scss" "html" "md" "xml" "rb" "el"))

(add-hook 'find-file-hook
  (lambda ()
    (let* ((found nil)
            (buf-name (file-name-extension buffer-file-name) ))
	    (dolist (i devel-buffers)
	      (when (string= buf-name i)
          (hl-line-mode)
          (hl-todo-mode)
          (auto-highlight-symbol-mode)
          (rainbow-mode)
          (setq found t)))
        (when (not found)
          ))))

(add-hook 'recentf-dialog-mode-hook
	  (lambda ()
	    (hl-line-mode)
	    )
	  )

;; mode hooks
(setq flyspell-mode-hooks '(text-mode-hook org-mode-hook))

(if (executable-find "aspell")
  (dolist (i flyspell-mode-hooks)
    (add-hook i #'flyspell-prog-mode)))

;; navigation
(windmove-default-keybindings)
(setq windmove-wrap-around t)
(setq framemove-hook-into-windmove t)


(add-to-list 'ido-ignore-files "\\.DS_Store")

;; org mode / journal
(setq org-clock-into-drawer t)
(setq org-clock-persist t) ; or 'history?
(setq org-clock-idle-time 2) ; TODO requires testing
(setq org-default-notes-file (expand-file-name "notes" user-emacs-directory))
(setq org-lowest-priority 68)
(setq org-highest-priority 65)
(setq org-default-priority 68)
(setq org-log-done 'time)
(setq org-completion-use-ido t)
(setq org-adapt-indentation nil)
(setq org-list-description-max-indent 5)
(setq org-closed-keep-when-no-todo t)
(setq org-log-done-with-time nil)
(setq org-tags-column -100)
(setq org-return-follows-link t)
(setq org-directory (expand-file-name "orgs" user-emacs-directory))
(setq org-journal-dir (expand-file-name "journal" user-emacs-directory))
(setq org-default-notes-file (expand-file-name "notes.org" org-directory))
(setq org-agenda-files (list org-directory))
(setq org-refile-targets '((org-agenda-files . (:maxlevel . 6))))
(setq org-capture-templates
  '(("t" "Todo" entry (file (expand-file-name "tasks.org" org-directory))
      "* TODO %?")
     ("j" "Journal" entry (file (expand-file-name "journal.org" org-directory))
       "* [%<%Y-%m-%d>]\n%?")
     ("c" "Add note to currently clocked entry" plain (clock)
       "- Note taken on %U \\\\ \n  %?")
     ))

(set-register ?g (cons 'file (expand-file-name "goals.org" org-directory)))
(set-register ?k (cons 'file (expand-file-name "knowledge.org" org-directory)))
(set-register ?j (cons 'file (expand-file-name "journal.org" org-directory)))
(set-register ?p (cons 'file (expand-file-name "projects.org" org-directory)))
(set-register ?t (cons 'file (expand-file-name "tasks.org" org-directory)))

(setq org-todo-keywords
  '((sequence "TODO(t)" "IN-PROCESS(p)" "BLOCKED(b@/!)" "|" "DONE(d!)" "CANCELED(c@)")))

(setq org-agenda-custom-commands
  '(("d" "TODOs weekly sorted by state, priority, deadline, scheduled, alpha and effort"
      (
        (agenda "*"))
      ((org-agenda-overriding-header "TODOs weekly sorted by state, priority, deadline, scheduled, alpha and effort")
        (org-agenda-sorting-strategy '(todo-state-down priority-down deadline-down scheduled-down alpha-down effort-up))))
     ("cn" "TODOs not sheduled"
       (
         (tags "-SCHEDULED={.+}/!+TODO|+STARTED|+BLOCKED"))
       ((org-agenda-overriding-header "TODOs not scheduled")
         (org-agenda-sorting-strategy '(deadline-down priority-down alpha-down effort-up))))
     ("cb" "TODOs blocked"
       (
         (tags "+BLOCKED"))
       ((org-agenda-overriding-header "TODOs blocked")
         (org-agenda-sorting-strategy '(priority-down deadline-down alpha-down effort-up))))
     ("cc" "TODOs canceled"
       (
         (todo "CANCELED"))
       ((org-agenda-overriding-header "TODOs canceled")
         (org-agenda-sorting-strategy '(priority-down alpha-down effort-up))))
     ("cj" "Journal"
       (
         (search ""))
       ((org-agenda-files (list org-journal-dir))
         (org-agenda-overriding-header "Journal")
         (org-agenda-sorting-strategy '(timestamp-down))))
     )
  )

(org-clock-persistence-insinuate)

(setq org-tag-alist '(("@health" . ?h)
                       ("@fun" . ?f)
                       ("@career" . ?c)
                       ("@family&friends" . ?f)
                       ("@love" . ?l)
                       ("@wealth" . ?w)
                       ))

;; org mode conflicts resolution: windmove
(add-hook 'org-shiftup-final-hook 'windmove-up)
(add-hook 'org-shiftleft-final-hook 'windmove-left)
(add-hook 'org-shiftdown-final-hook 'windmove-down)
(add-hook 'org-shiftright-final-hook 'windmove-right)

;; programming
(add-to-list 'auto-mode-alist '("\\.jsx$" . js-mode))

(if (executable-find "ack")
  (progn
  (setq grep-command "ack --with-filename --nofilter --nogroup ")
  (setq grep-program "ack")
  (setq sr-grep-command "ack ")
  (grep-apply-setting 'grep-find-template "find <D> <X> -type f <F> -exec ack --with-filename --nofilter --nogroup '<R>' /dev/null {} +")
    )
  (message "No 'ack' executable found.")
  )

(if (fboundp 'global-git-gutter-mode)
  (global-git-gutter-mode +1))

(if (fboundp 'persistent-scratch-setup-default)
  (persistent-scratch-setup-default))

(defun reload-config ()
	"Reload config."
	(interactive)
	(load-file (expand-file-name "init.el" user-emacs-directory))
  (message "Config reloaded."))

;; TODO it could be rather based on ring implementation (hard to add new langs)
(defun dict-toggle ()
  "Toggle spell dictionary."
  (interactive)
  (if
    (string= ispell-current-dictionary "en")
    (ispell-change-dictionary "pl")
    (ispell-change-dictionary "en")
    )
  (message (concat "Current spell language is '" ispell-current-dictionary "'."))
  )

(defun goto-match-paren (&optional arg)
  "Go to the matching parenthesis character if one is adjacent to point."
  (interactive "^p")
  (cond ((looking-at "\\s(") (forward-sexp arg))
        ((looking-back "\\s)" 1) (backward-sexp arg))
        ;; Now, try to succeed from inside of a bracket
        ((looking-at "\\s)") (forward-char) (backward-sexp arg))
        ((looking-back "\\s(" 1) (backward-char) (forward-sexp arg))))

(global-set-key (kbd "C-%") 'goto-match-paren)

(set-cursor-color "#ffffff")

(setq local-config-file (expand-file-name "local-config" user-emacs-directory))

(when (file-exists-p (concat local-config-file ".el"))
  (message "local config exists")
  (load local-config-file)
  )

(setq default-font "-*-Menlo-normal-normal-normal-*-12-*-*-*-m-0-iso10646-1")
(set-face-attribute 'default nil :font default-font)

;; temporary
(set-face-foreground 'dired-directory "yellow" )
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (sanityinc-tomorrow-blue)))
  '(custom-safe-themes
     (quote
       ("82d2cac368ccdec2fcc7573f24c3f79654b78bf133096f9b40c20d97ec1d8016" default)))
  '(package-selected-packages
     (quote
       (wgrep smex flx-ido ido-better-flex ido-completing-read+ ido-ubiquitous-mode rainbow-mode persistent-scratch neotree multiple-cursors hl-todo helm git-gutter editorconfig color-theme-sanityinc-tomorrow centered-cursor-mode auto-highlight-symbol))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
