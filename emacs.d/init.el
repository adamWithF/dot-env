; Folder with manualy added packages
(add-to-list 'load-path "~/.emacs.d/lisp/")

(require 'cl)

(setq package-list '(color-theme-sanityinc-tomorrow
                     persistent-scratch
                     git-gutter
		     centered-cursor-mode
		     auto-highlight-symbol
		     hl-todo
                     ; helm
                     ; projectile
                     ; neotree
                    ))

(setq package-archives '(("elpa" . "http://tromey.com/elpa/")
                         ("gnu" . "http://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))

(package-initialize)

; fetch the list of packages available
(unless package-archive-contents
  (package-refresh-contents))

; install the missing packages
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

;; (require 'centered-cursor-mode)

;; config
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/autosaves/\\1" t)))
(setq visible-bell 1)
(setq ring-bell-function 'ignore)
(setq inhibit-startup-screen t)

(delete-selection-mode 1)
(setq-default word-wrap t)

(setq tab-width 2)
(setq dired-recursive-copies 'always)
(setq dired-recursive-deletes 'always)
(setq ahs-idle-interval 0)
(setq bookmark-save-flag nil)

(setq show-paren-delay 0)
(show-paren-mode 1)


(recentf-mode 1)
(setq recentf-max-menu-items 25)

(global-set-key (kbd "C-x C-b") 'ibuffer)
(global-set-key (kbd "C-x C-r") 'recentf-open-files)

(scroll-bar-mode -1)
(if window-system
  (tool-bar-mode -1)
)

(global-auto-revert-mode 1)
(blink-cursor-mode 0)
(global-linum-mode 1)
(ido-mode t)
(centered-cursor-mode t)

;; programming
(setq devel-buffers '("js" "jsx" "vim" "json" "java" "php" "css" "scss" "html" "md" "xml" "rb" "el"))

(add-hook 'find-file-hook
	  (lambda ()
	    (dolist (i devel-buffers)
	      (when (string= (file-name-extension buffer-file-name) i)
		(hl-line-mode)
		(hl-todo-mode)
		(auto-highlight-symbol-mode)
		(rainbow-mode)))))

;; mode hooks
(setq flyspell-mode-hooks '(text-mode-hook org-mode-hook))

(if (executable-find "aspell")
  (dolist (i flyspell-mode-hooks)
    (add-hook i #'flyspell-prog-mode)))

;; navigation
(require 'framemove)
(windmove-default-keybindings)
(setq windmove-wrap-around t)
(setq framemove-hook-into-windmove t)

;; org mode
(setq org-clock-persist 'history)
(org-clock-persistence-insinuate)

;; org mode conflicts resolution: windmove
(add-hook 'org-shiftup-final-hook 'windmove-up)
(add-hook 'org-shiftleft-final-hook 'windmove-left)
(add-hook 'org-shiftdown-final-hook 'windmove-down)
(add-hook 'org-shiftright-final-hook 'windmove-right)

;; programming
(add-to-list 'auto-mode-alist '("\\.jsx$" . js-mode))

(require 'color-theme-sanityinc-tomorrow)

(if (fboundp 'global-git-gutter-mode)
  (global-git-gutter-mode +1)
)

(if (fboundp 'persistent-scratch-setup-default)
  (persistent-scratch-setup-default)
)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default bold shadow italic underline bold bold-italic bold])
 '(ansi-color-names-vector
   (vector "#4d4d4c" "#c82829" "#718c00" "#eab700" "#4271ae" "#8959a8" "#3e999f" "#d6d6d6"))
 '(custom-enabled-themes (quote (sanityinc-tomorrow-blue)))
 '(custom-safe-themes
   (quote
    ("82d2cac368ccdec2fcc7573f24c3f79654b78bf133096f9b40c20d97ec1d8016" "bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58" "06f0b439b62164c6f8f84fdda32b62fb50b6d00e8b01c2208e55543a6337433a" default)))
 '(fci-rule-color "#d6d6d6")
 '(package-selected-packages
   (quote
    (rainbow-mode auto-highlight-symbol hl-anything hl-todo centered-cursor-mode highlight-symbol git-gutter persistent-scratch tabbar-ruler color-theme-sanityinc-tomorrow)))
 '(vc-annotate-background nil)
 '(vc-annotate-color-map
   (quote
    ((20 . "#c82829")
     (40 . "#f5871f")
     (60 . "#eab700")
     (80 . "#718c00")
     (100 . "#3e999f")
     (120 . "#4271ae")
     (140 . "#8959a8")
     (160 . "#c82829")
     (180 . "#f5871f")
     (200 . "#eab700")
     (220 . "#718c00")
     (240 . "#3e999f")
     (260 . "#4271ae")
     (280 . "#8959a8")
     (300 . "#c82829")
     (320 . "#f5871f")
     (340 . "#eab700")
     (360 . "#718c00"))))
 '(vc-annotate-very-old-color nil))
(custom-set-faces)
(set-cursor-color "#ffffff")
