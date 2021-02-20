(when (display-graphic-p)
  (setq-default scroll-up-aggressively 0.01)
  (setq
    mouse-wheel-scroll-amount '(1 ((shift) . 1))
    redisplay-dont-pause t
    scroll-margin 1
    scroll-conservatively 10000
    scroll-preserve-screen-position nil))

(setq
  scroll-step 1
  scroll-margin 0
  scroll-conservatively 101
  auto-window-vscroll nil)

(setq display-buffer-alist '(("*helpful"
                              (display-buffer-reuse-window display-buffer-at-bottom)
                               (window-width . 0.5)
                               (reusable-frames . nil))))

(use-package simple
  :ensure nil
  ;; :hook((prog-mode . turn-on-auto-fill)
  ;;        (text-mode . turn-on-auto-fill))
  :custom
  (set-mark-command-repeat-pop t))

(use-package recentf
  :ensure nil
  :custom
  (recentf-max-saved-items 200)
  (recentf-max-menu-items 15)
  (recentf-exclude '("COMMIT_EDITMSG"
                     "~$"
                     "/scp:"
                     "/ssh:"
                     "/sudo:"
                     "/tmp/"))
  :config
  (recentf-mode 1)
  (run-at-time nil (* 60 5) #'recentf-save-list))

(use-package openwith
  :if (eq system-type 'darwin)
  :custom
  (openwith-associations '(("\\.pdf\\'" "open" (file))))
  :config
  (openwith-mode 1))

(use-package help
  :ensure nil
  :bind (:map help-mode-map
          ("C-w =" . balance-windows)
          ("/" . evil-search-forward)
          ("v" . set-mark-command)
          ("n" . evil-search-next)
          ("N" . evil-search-previous)
          ("w" . evil-forward-word-begin)
          ("e" . evil-forward-word-end)
          ("E" . evil-forward-WORD-end)
          ("b" . evil-backward-word-begin)
          ("B" . evil-backward-WORD-begin)
          ("y" . evil-yank)
          ("<S-tab>" . backward-button)
          ))

(use-package tramp
  :ensure nil
  :custom
  (tramp-default-method "ssh")
  (tramp-inline-compress-start-size 40960)
  (tramp-chunksize 500)
  (tramp-auto-save-directory "~/.emacs.d/tramp-autosaves/")
  (tramp-persistency-file-name  "~/.emacs.d/tramp-persistency.el")
  (tramp-encoding-shell "/bin/sh"))

(use-package anzu
  :diminish anzu-mode
  :bind ("M-%" . 'anzu-query-replace-regexp)
  :config
  (global-anzu-mode 1))

(use-package drag-stuff
  :diminish drag-stuff-mode
  :config
  (add-to-list 'drag-stuff-except-modes 'org-mode)
  ;; (add-to-list 'drag-stuff-except-modes 'my/org-taskjuggler-mode)
  (drag-stuff-global-mode 1)
  (define-key drag-stuff-mode-map (drag-stuff--kbd 'up) 'drag-stuff-up)
  (define-key drag-stuff-mode-map (drag-stuff--kbd 'down) 'drag-stuff-down))

(use-package goto-last-change)

(use-package iscroll)

(use-package smartscan
  :defer t
  :config
  (global-smartscan-mode 1))

(require 'framemove)
(require 'compile)
(require 'grep)
(require 'files)

(defun my/rgrep ()
  (interactive)
  (if (executable-find "ack")
    (let* ((regexp (grep-read-regexp))
            (dir (read-directory-name "Base directory: " nil default-directory t))
            (command (concat "ack '" regexp "' " dir)))
      (unless (file-accessible-directory-p dir)
        (error (concat "directory: '" dir "' is not accessible.")))
	    (compilation-start command 'grep-mode))
    ))

;; (use-package treemacs
;;   :defer t
;;   :commands treeemacs
;;   :config
;;   (treemacs-follow-mode 1)
;;   (treemacs-fringe-indicator-mode 1)
;;   (treemacs-git-mode 'simple)
;;   (treemacs-filewatch-mode 1))

;; (use-package treemacs-projectile
;;   :after projectile treemacs)

;; (use-package treemacs-evil
;;   :after evil treemacs)

;; (use-package treemacs-magit
;;   :after treemacs magit)

(use-package avy
  :bind (:map help-mode-map
          ("\\c" . avy-goto-char)
          ("\\w" . avy-goto-word-or-subword-1)
          :map evil-motion-state-map
          ("\\w" . avy-goto-word-or-subword-1)
          ("\\c" . avy-goto-char)))

;; (use-package ivy-hydra
;;   :after ivy hydra)

(use-package ivy
  :diminish ivy-mode
  :bind (:map ivy-minibuffer-map
          ("<return>" . ivy-alt-done)
          ("C-M-h" . ivy-previous-line-and-call)
          ("C-:" . ivy-dired)
          ("C-c o" . ivy-occur)
          ("C-'" . ivy-avy))
  :custom
  (ivy-switch-buffer-faces-alist
    '((emacs-lisp-mode . swiper-match-face-1)
       (dired-mode . ivy-subdir)
       (org-mode . org-level-4)))
  (ivy-height 15)
  (ivy-use-selectable-prompt t)
  (ivy-count-format "(%d/%d) ")
  (ivy-use-virtual-buffer t)
  (ivy-re-builders-alist '((t . ivy--regex-plus)))
  ;; (ivy-re-builders-alist '((t . ivy--regex-ignore-order)))
  :config
  (ivy-mode 1)

  (defun ivy-dired ()
    (interactive)
    (if ivy--directory
      (ivy-quit-and-run
        (dired ivy--directory)
        (when (re-search-forward
                (regexp-quote
                  (substring ivy--current 0 -1)) nil t)
          (goto-char (match-beginning 0))))
      (user-error
        "Not completing files currently"))))

  ;; (defun ivy-view-backtrace ()
  ;;   (interactive)
  ;;   (switch-to-buffer "*ivy-backtrace*")
  ;;   (delete-region (point-min) (point-max))
  ;;   (fundamental-mode)
  ;;   (insert ivy-old-backtrace)
  ;;   (goto-char (point-min))
  ;;   (forward-line 1)
  ;;   (let (part parts)
  ;;     (while (< (point) (point-max))
  ;;       (condition-case nil
  ;;         (progn
  ;;           (setq part (read (current-buffer)))
  ;;           (push part parts)
  ;;           (delete-region (point-min) (point)))
  ;;         (error
  ;;           (progn
  ;;             (ignore-errors (up-list))
  ;;             (delete-region (point-min) (point)))))))
  ;;   (goto-char (point-min))
  ;;   (dolist (part parts)
  ;;     (lispy--insert part)
  ;;     (lispy-alt-multiline)
  ;;     (insert "\n")))

(use-package counsel
  :after ivy
  :bind (("M-x" . counsel-M-x)
          ("C-x C-f" . counsel-find-file)
          ("<f1> f" . counsel-describe-function)
          ("<f1> v" . counsel-describe-variable)
          ("<f1> l" . counsel-find-library)
          ("<f2> s" . counsel-info-lookup-symbol)
          ("<f2> u" . counsel-unicode-char)
          ("C-h f" . counsel-describe-function)
          ("C-h v" . counsel-describe-variable)
          ("C-h a" . counsel-apropos)
          ("C-x r b" . counsel-bookmark)
          ("C-x b" . counsel-switch-buffer)
          ("C-x B" . counsel-switch-buffer-other-window)
          ("C-x C-r" . counsel-recentf)
          ("C-x C-d" . counsel-dired-jump)
          ("C-x C-h" . counsel-minibuffer-history)
          ("C-x C-l" . counsel-find-library)
          :map read-expression-map
          ("C-r" . counsel-minibuffer-history)
          ("C-r" . counsel-expression-history)
          :map evil-motion-state-map
          ("\\a" . counsel-imenu))
  :custom
  (counsel-rg-base-command "rg -S -M 150 --no-heading --line-number --color never %s")
  (counsel-find-file-ignore-regexp "\\`\\.")
  (counsel-grep-base-command "grep -E -n -i -e %s %s")
  :config
  (defun my/counsel-ibuffer-other-window (&optional name)
    "Use ibuffer to switch to another buffer.
NAME specifies the name of the buffer (defaults to \"*Ibuffer*\")."
    (interactive)
    (setq counsel-ibuffer--buffer-name (or name "*Ibuffer*"))
    (ivy-read "Switch to buffer: " (counsel-ibuffer--get-buffers)
      :history 'counsel-ibuffer-history
      :action 'counsel-ibuffer-visit-buffer-other-window
      :caller 'counsel-ibuffer))

  (advice-add 'counsel-grep :around #'my/counsel-grep-fallback)
  (ivy-set-display-transformer 'counsel-describe-function nil))

(defun my/counsel-grep-fallback (orig-fun &rest args)
  "Fallback counsel-grep to evil-search-forward if exists if not search-forward."
  (when (my/buffer-tramp-p)
    (if (fboundp 'evil-search-forward)
      (apply 'evil-search-forward args)
      (apply 'search-forward args)))
    ;; (apply orig-fun args))

  ;; (if (or (string= major-mode "dired-mode") (string= major-mode "org-mode") (string= major-mode "help-mode") (string= "*scratch*" (buffer-name)) (string= "*Org Agenda*" (buffer-name)) (string-match ".gpg\\'" (buffer-name)))

  (if (fboundp 'swiper)
    (apply 'swiper args)
    (if (fboundp 'evil-search-forward)
      (apply 'evil-search-forward args)
      (apply 'search-forward args))))

;; (use-package undo-tree
;;   :defer t
;;   :diminish undo-tree-mode
;;   :config
;;   (setq undo-tree-visualizer-diff t)
;;   (when (fboundp 'evil-make-overriding-map)
;;     (evil-make-overriding-map undo-tree-visualizer-mode-map 'motion)
;;     (evil-make-overriding-map undo-tree-visualizer-selection-mode-map 'motion)
;;     (evil-make-overriding-map undo-tree-map 'motion)))

(use-package perspective
  :custom
  (persp-sort 'created)
  :config
  (persp-mode)
  (bind-keys
    ("C-x C-b" . persp-counsel-switch-buffer)
    ("C-x C-k" . persp-kill-buffer*)))

(use-package ag
  :defer 3
  :custom
  (ag-reuse-buffers t))

(use-package dashboard
  :preface
  (defun dashboard-load-packages (list-size)
    (insert (make-string (ceiling (max 0 (- dashboard-banner-length 38)) 5) ? )
            (format "%d packages loaded in %s" (length package-activated-list) (emacs-init-time))))
  :custom
  (dashboard-banner-logo-title "Let's do something great today!")
  (dashboard-center-content t)
  (dashboard-items '((packages)
                      (projects . 10)
                      (recents . 10)))
  (dashboard-set-file-icons t)
  (dashboard-set-heading-icons t)
  (dashboard-set-init-info nil)
  (dashboard-set-navigator t)
  (dashboard-startup-banner 'logo)
  :config
  (add-to-list 'dashboard-item-generators '(packages . dashboard-load-packages))
  (dashboard-setup-startup-hook))

(use-package visual-fill-column
  :commands visual-fill-column-mode
  :hook (
          ;; (prog-mode . turn-on-auto-fill)
          ;; (text-mode . turn-on-auto-fill)
          (text-mode . visual-fill-column-mode)
          ))

(use-package nov
  :mode ("\\.epub\\'" . nov-mode)
  :hook ((nov-mode . visual-line-mode)
          (nov-mode . visual-fill-column-mode)
          (nov-mode . (lambda () (setq visual-fill-column-center-text t))))
  :custom
  (nov-text-width t)
  ;; (nov-text-width 75)
  )

;; Bring back window configuration after ediff quits
(defvar my-ediff-bwin-config nil "Window configuration before ediff.")
(defcustom my-ediff-bwin-reg ?b
  "*Register to be set up to hold `my-ediff-bwin-config'
    configuration.")

(defvar my-ediff-awin-config nil "Window configuration after ediff.")
(defcustom my-ediff-awin-reg ?e
  "*Register to be used to hold `my-ediff-awin-config' window
    configuration.")

(defun my-ediff-bsh ()
  "Function to be called before any buffers or window setup for
    ediff."
  (setq my-ediff-bwin-config (current-window-configuration))
  (when (characterp my-ediff-bwin-reg)
    (set-register my-ediff-bwin-reg
		  (list my-ediff-bwin-config (point-marker)))))

(defun my-ediff-ash ()
  "Function to be called after buffers and window setup for ediff."
  (setq my-ediff-awin-config (current-window-configuration))
  (when (characterp my-ediff-awin-reg)
    (set-register my-ediff-awin-reg
		  (list my-ediff-awin-config (point-marker)))))

(defun my-ediff-qh ()
  "Function to be called when ediff quits."
  (when my-ediff-bwin-config
    (set-window-configuration my-ediff-bwin-config)))

(defun my/smarter-move-beginning-of-line (arg)
  "Move point back to indentation of beginning of line.

Move point to the first non-whitespace character on this line.
If point is already there, move to the beginning of the line.
Effectively toggle between the first non-whitespace character and
the beginning of the line.

If ARG is not nil or 1, move forward ARG - 1 lines first.  If
point reaches the beginning or end of the buffer, stop there."
  (interactive "^p")
  (setq arg (or arg 1))

  ;; Move lines first
  (when (/= arg 1)
    (let ((line-move-visual nil))
      (forward-line (1- arg))))

  (let ((orig-point (point)))
    (back-to-indentation)
    (when (= orig-point (point))
      (move-beginning-of-line 1))))

(use-package windmove
  :ensure nil
  :bind (("C-x <left>" . windmove-left)
          ("C-x <right>" . windmove-right)
          ("C-x <up>" . windmove-up)
          ("C-x <down>" . windmove-down))
  :custom
  (windmove-wrap-around t)
  (framemove-hook-into-windmove t)
  :config
  (windmove-default-keybindings))

(defvar my/save-buffers-kill-terminal-was-called nil)

(defun my/save-buffers-kill-terminal ()
  (interactive)
  (setq my/save-buffers-kill-terminal-was-called t)
  (save-buffers-kill-terminal t))

(defun my/kill-all-buffers-except-toolkit ()
  "Kill all buffers except current one and toolkit (*Messages*, *scratch*). Close other windows."
  (interactive)
  (mapc 'kill-buffer (remove-if
                       (lambda (x)
                         (or
                           (some (lambda (window) (string-equal (buffer-name x) (buffer-name (window-buffer window)))) (window-list))
                           ;; (string-equal (buffer-file-name) (buffer-file-name x))
                           (string-equal "*Messages*" (buffer-name x))
                           (string-equal "*scratch*" (buffer-name x))))
                       (buffer-list)))
  (delete-other-frames)
  (message "Closed other buffers and frames."))

(defun my/clone-indirect-buffer-new-window ()
  "Clone indirect buffer in new window."
  (interactive)
  (split-window-right)
  (clone-indirect-buffer nil t)
  (windmove-left))

; https://www.emacswiki.org/emacs/ToggleWindowSplit
(defun my/toggle-window-split ()
  (interactive)
  (if (= (count-windows) 2)
      (let* ((this-win-buffer (window-buffer))
	     (next-win-buffer (window-buffer (next-window)))
	     (this-win-edges (window-edges (selected-window)))
	     (next-win-edges (window-edges (next-window)))
	     (this-win-2nd (not (and (<= (car this-win-edges)
					 (car next-win-edges))
				     (<= (cadr this-win-edges)
					 (cadr next-win-edges)))))
	     (splitter
	      (if (= (car this-win-edges)
		     (car (window-edges (next-window))))
		  'split-window-horizontally
		'split-window-vertically)))
	(delete-other-windows)
	(let ((first-win (selected-window)))
	  (funcall splitter)
	  (if this-win-2nd (other-window 1))
	  (set-window-buffer (selected-window) this-win-buffer)
	  (set-window-buffer (next-window) next-win-buffer)
	  (select-window first-win)
	  (if this-win-2nd (other-window 1))))))

(defun my/evil-jump-to-tag-other-buffer ()
  (interactive)
  (save-excursion
    (evil-window-vsplit)
    (windmove-right)
    (evil-jump-to-tag)))

(bind-keys
  ("C-x |" . my/toggle-window-split)
  ("C-x C-c" . my/save-buffers-kill-terminal)
  ([remap move-beginning-of-line] . my/smarter-move-beginning-of-line)
  ("<s-right>" . ns-next-frame)
  ("<s-left>" . ns-prev-frame)
  ("C-c p" . #'pop-to-mark-command))

(unbind-key "s-l")

(provide 'my-navigation)
