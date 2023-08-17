;;; Code:

(setq-default sh-basic-offset tab-width)
(setq-default tags-add-tables nil)

;; (add-hook 'conf-space-mode-hook #'my/breadcrumb-set-local t)
;; (add-hook 'conf-unix-mode-hook #'my/breadcrumb-set-local t)
;; (add-hook 'conf-javaprop-mode-hook #'my/breadcrumb-set-local t)
;; (add-hook 'conf-toml-mode-hook #'my/breadcrumb-set-local t)

(use-package rainbow-delimiters
  :commands rainbow-delimiters-mode)

(use-package eldoc
  :commands eldoc-mode
  :straight nil
  :diminish eldoc-mode
  :custom
  (eldoc-documentation-strategy 'eldoc-documentation-compose-eagerly))

(use-package prog-mode
  :straight nil
  :hook ((prog-mode . eldoc-mode)
          (prog-mode . rainbow-delimiters-mode)
          (prog-mode . my/breadcrumb-set-local)
          (prog-mode . hl-todo-mode)
          (prog-mode . symbol-overlay-mode)
          (prog-mode . company-mode))
  :config
  (evil-define-key 'normal prog-mode-map
    (kbd "<S-up>") 'evil-numbers/inc-at-pt
    (kbd "<S-down>") 'evil-numbers/dec-at-pt
    (kbd ",l") 'hydra-prog/body
    (kbd "C-=") 'er/expand-region
    (kbd "C-+") 'er/contract-region)

  (cond ((and (fboundp 'company-mode) company-mode)
    (evil-define-key 'normal prog-mode-map
      (kbd "C-/") 'company-complete))
    ((and (fbound 'corfu-mode) corfu-mode)
      (evil-define-key 'normal prog-mode-map
        (kbd "C-/") 'corfu-insert)))

  (evil-define-key 'insert prog-mode-map
    (kbd "C-/") 'company-complete)

  (evil-define-key 'normal prog-mode-map
    (kbd "C-c m") 'hydra-merge/body)

  (pretty-hydra-define hydra-prog
    (:hint nil :color amaranth :quit-key "q" :title (with-faicon "code" "Programming" 1 -0.05))
    ("Action"
      (("f" ediff "ediff files" :exit t)
        ("b" ediff-buffers "ediff buffers" :exit t))
      "Find"
      (("d" xref-find-definitions "find definitions" :exit t)
        ("r" xref-find-references "find references" :exit t)
        ("l" counsel-imenu "functions" :exit t)
        ("t" treemacs "treemacs" :toggle t))
      "Syntax"
      (("p" my/prettier-mode "prettier" :toggle t)
        ("c" flycheck-mode "flycheck" :toggle t)
        ("m" flymake-mode "flymake" :toggle t)
        ;; ("o" electric-operator-mode "electric operator" :toggle t)
        ("i" my/dtrt-indent-mode-toggle "Toggle dtrt-indent-mode" :toggle t))
      "AI"
      (("s" starhugger-trigger-suggestion "generate suggestion" :exit t)
        ("a" starhugger-accept-suggestion "accept suggestion" :exit t)
        (">" starhugger-show-next-suggestion "next suggestion" :exit t)
        ("<" starhugger-show-prev-suggestion "previous suggestion" :exit t))))

  (pretty-hydra-define hydra-merge
    (:hint nil :color pink :quit-key "q" :title (with-alltheicon "git" "Merge" 1 -0.05))
    ("Move"
      (("n" smerge-next "next")
        ("p" smerge-prev "previous"))
      "Keep"
      (("l" smerge-keep-lower "lower")
        ("u" smerge-keep-upper "upper"))
      "Diff"
      (("R" smerge-refine "redefine"))))

  (defun my/prog-mode-hook ()
    (modify-syntax-entry ?- "w" (syntax-table))
    (modify-syntax-entry ?_ "w" (syntax-table))
    (modify-syntax-entry ?$ "w" (syntax-table))
    (abbrev-mode -1)
    (flyspell-mode -1)
    (hungry-delete-mode 1)
    (hl-line-mode 1)
    (show-paren-mode 1))

  (add-hook 'prog-mode-hook 'my/prog-mode-hook -50))

(use-package mmm-mode
  :commands mmm-mode
  :custom
  (mmm-submode-decoration-level 0)
  :config
  (mmm-add-classes
    '((mmm-styled-mode
        :submode css-mode
        :front "\\(styled\\|css\\)[.()<>[:alnum:]]?+`"
        :back "`;")))
  (mmm-add-mode-ext-class 'typescript-mode nil 'mmm-styled-mode)
  (mmm-add-mode-ext-class 'rjsx-mode nil 'mmm-styled-mode)

  (mmm-add-classes
    '((mmm-graphql-mode
        :submode graphql-mode
        :front "gr?a?p?h?ql`"
        :back "`;")))
  (mmm-add-mode-ext-class 'typescript-mode nil 'mmm-graphql-mode)
  (mmm-add-mode-ext-class 'rjsx-mode nil 'mmm-graphql-mode)

  ;; (mmm-add-classes
  ;;   '((mmm-jsx-mode
  ;;       :front "\\(return\s\\|n\s\\|(\n\s*\\)<"
  ;;       :front-offset -1
  ;;       :back ">\n?\s*)"
  ;;       :back-offset 1
  ;;       :submode web-mode)))
  ;; (mmm-add-mode-ext-class 'typescript-mode nil 'mmm-jsx-mode)
  )

(define-derived-mode guest-mode fundamental-mode "guest"
  "Major mode for editing as a guest in a file.
Use when `json-mode' or similar get stuck."
  (editorconfig-mode -1))

(use-package dns-mode
  :straight nil
  :mode ("\\.zone?\\'" . zone-mode))

(use-package electric-operator
  :commands electric-operator-mode
  :diminish electric-operator-mode)

(use-package sh-script
  :mode "\\.z?sh\\'"
  :hook (after-save . executable-make-buffer-file-executable-if-script-p))

;; (use-package sql-indent
;;   :after (:any sql sql-interactive-mode)
;;   :diminish sql-indent-mode)

(use-package hl-todo
  :commands hl-todo-mode)

(use-package symbol-overlay
  :commands symbol-overlay-mode
  :diminish symbol-overlay-mode
  :custom
  (symbol-overlay-idle-time 0.1))

;; http://mattbriggs.net/blog/2012/03/18/awesome-emacs-plugins-ctags/
(defun my/ctags-build ()
  (interactive)
  (let ((project-root (projectile-project-root)))
    (if project-root
      (progn
        (if (not (executable-find "ctags"))
          (message "No executable 'ctags' found!")
        (start-process "ctags" nil (format "ctags -e -f -R %s" project-root))
        (my/visit-project-ctags)
        (message "Tags build successfully."))
      (user-error "Cannot generate TAGS, not a projectile project.")))))

(defalias 'ctags 'my/ctags-build)

(defun my/visit-project-ctags ()
  (interactive)
  (let ((project-root (projectile-project-root)))
    (if project-root
      (visit-tags-table (concat project-root "tags"))
      (user-error "Cannot view TAGS table, not a projectile project."))))

(defun my/ctags-update ()
  (interactive)
  (let* ((project-root (projectile-project-root))
          (current-file (file-name-nondirectory (buffer-file-name (current-buffer))))
          (current-file-path (buffer-file-name (current-buffer)))
          (tags-file (concat project-root "TAGS")))
    (if (not (executable-find "ctags"))
      (message "No executable 'ctags' found")
    (when (and project-root (file-readable-p tags-file))
      (start-process "ctags update" nil (format "ctags -e %s" project-root))
      (message (format "Tags for file %s updated." current-file))))))

(use-package yaml-mode
  :mode "\\.ya?ml\\'")

(use-package markdown-mode
  ;; :hook (markdown-mode . my/bind-value-togglers)
  :hook (markdown-mode . my/breadcrumb-set-local)
  :mode (("\\.markdown\\'" . markdown-mode)
          ("\\.mdx?\\'" . markdown-mode)
          ("README\\.md\\'" . gfm-mode))
  ;; :config

  ;; (evil-define-key '(visual normal) markdown-mode-map
  ;;   "{" #'backward-paragraph
  ;;   "}" #'forward-paragraph
  ;;   "M-{" #'backward-paragraph
  ;;   "M-}" #'forward-paragraph
  ;;   )

  ;; (advice-add 'markdown-backward-paragraph :override #'backward-paragraph)
  ;; (advice-add 'markdown-backward-block :override #'backward-paragraph)
  ;; (advice-add 'markdown-forward-paragraph :override #'forward-paragraph)
  ;; (advice-add 'markdown-forward-bblock :override #'forward-paragraph)
  )

(use-package vimrc-mode
  :mode "\\vimrc\\'")

(use-package flycheck
  :commands (flycheck-mode flycheck-buffer)
  :custom
  (flymake-phpcs-show-rule t)
  (flycheck-display-errors-delay .3)
  (flycheck-phpcs-standard "WordPress")
  :config
  (pretty-hydra-define hydra-flycheck
    (:hint nil :color teal :quit-key "q" :title (with-faicon "check" "Flycheck" 1 -0.05))
    ("Checker"
      (("f" flyspell-mode "flyspell" :toggle t)
        ("?" flycheck-describe-checker "describe")
        ("d" flycheck-disable-checker "disable")
        ("m" flycheck-mode "mode")
        ("s" flycheck-select-checker "select"))
      "Errors"
      (("<" flycheck-previous-error "previous" :color pink)
        (">" flycheck-next-error "next" :color pink)
        ("b" flycheck-buffer "check")
        ("l" flycheck-list-errors "list"))
      "Other"
      (("M" flycheck-manual "manual")
        ("v" flycheck-verify-setup "verify setup"))))

  (evil-define-key 'normal global-map
    (kbd "C-c f") 'hydra-flycheck/body)

  (add-to-list 'display-buffer-alist
    `(,(rx bos "*Flycheck errors*" eos)
       (display-buffer-reuse-window
         display-buffer-in-side-window)
       (side            . bottom)
       (reusable-frames . visible)
       (window-height   . 0.33))))

(define-minor-mode my/auto-indent-mode
  "Auto indent buffer on save."
  :init-value nil
  (add-hook 'before-save-hook
    (lambda ()
      (save-excursion
        (unless (eq dtrt-indent-mode t)
          (indent-region (point-min) (point-max))
          (untabify (point-min) (point-max)))))
    nil t))

(use-package eglot
  :commands eglot
  :straight nil)

(use-package lsp-mode
  :disabled t
  :commands (lsp lsp-deferred)
  :hook ((lsp-mode .
           (lambda ()
             (when (bound-and-true-p which-key-mode)
               (lsp-enable-which-key-integration))
             )))
  :custom
  (lsp-enable-snippet t)
  (lsp-enable-semantic-highlighting nil)
  (lsp-enable-symbol-highlighting nil)
  (lsp-enable-file-watchers nil)
  (lsp-headerline-breadcrumb-enable nil)
  (lsp-modeline-code-actions-enable nil)
  (lsp-modeline-diagnostics-enable nil)
  (lsp-signature-render-documentation nil)
  (lsp-eldoc-enable-hover nil)
  (lsp-restart 'auto-restart)
  (lsp-lens-enable nil)
  (lsp-eslint-enable nil)
  (lsp-clients-svlangserver-disableLinting t)
  (lsp-rf-language-server-trace-serve "off")
  ;; (lsp-eslint-server-command '("node" "~/.emacs.d/.extension/vscode/vscode-eslint/server/out/eslintServer.js" "--stdio"))
  :config
  (add-to-list 'lsp-language-id-configuration '(js-jsx-mode . "javascriptreact"))
  (add-to-list 'lsp-language-id-configuration '(graphql-mode . "graphql"))
  (add-to-list 'lsp-language-id-configuration '(".*\\.htm" . "html"))
  (add-to-list 'lsp-language-id-configuration '(".*\\.njk" . "html"))
  (add-to-list 'lsp-disabled-clients
    '(
       (typescript-mode . (eslint))
       (json-mode . (eslint json-ls))
       (js-mode . (eslint))
       (rjsx-mode . (eslint)))))

(use-package lsp-ui
  :disabled t
  :after lsp-mode
	:commands lsp-ui-imenu
  :hook ((lsp-mode . lsp-ui-mode)
          (lsp-mode . lsp-ui-imenu-buffer-mode))
  :custom
  (lsp-ui-doc-enable nil)
  (lsp-ui-doc-show-with-cursor nil)
  (lsp-ui-doc-show-with-mouse nil)
  (lsp-ui-sideline-enable nil)
  (lsp-ui-sideline-enable nil)
  (lsp-ui-imenu-window-width 50)
  (lsp-ui-doc-position 'top)
  (lsp-ui-doc-header t)
  :config
  (evil-define-key 'normal lsp-ui-mode-map
    (kbd ",l") #'lsp-ui-imenu))

(use-package lsp-treemacs
  :disabled t
  :after (lsp-mode treemacs)
  :commands (lsp-treemacs-errors-list lsp-treemacs-call-hierarch)
  :config
  (lsp-treemacs-sync-mode 1))

;; https://emacs-lsp.github.io/lsp-mode/page/installation/#use-package
;; (use-package dap-mode
;;   :after lsp-mode
;;   :config
;;   (require 'dap-chrome)
;;   (dap-chrome-setup)
;;   ;; https://emacs-lsp.github.io/dap-mode/page/configuration/#javascript
;;   (setq dap-chrome-debug-program "~/.vscode/extensions/msjsdiag.debugger-for-chrome-4.12.11/out/src/chromeDebug.js"))

(use-package lsp-ivy
  :disabled t
  :after (lsp-mode ivy))

(use-package dtrt-indent
  :commands (dtrt-indent-mode my/dtrt-indent-mode-toggle)
  :diminish "dtrt"
  :preface
  (defun my/dtrt-indent-mode-toggle ()
    "Toggle dtrt-indent mode."
    (interactive)
    (if (eq dtrt-indent-mode t)
      (dtrt-indent-mode -1)
      (dtrt-indent-mode 1))))

(use-package terraform-mode
  :mode "\\.tf\\'")

;; TODO what it does?
;; (use-package company-web
;; :requires company-mode)

;; (use-package company-quickhelp
;; :requires company-mode)

(use-package dockerfile-mode
  :mode "^Dockerfile\\'")

(use-package graphql-mode
  :commands graphql-mode
  :mode "\\.graphql\\'"
  :custom
  (graphql-indent-level tab-width))

(use-package go-mode
  :mode ("\\.thtml\\'" "\\.gohtml\\'" "\\.tm?pl\\'"))

(use-package tempo
  :defer 0.3
  :straight nil)

(use-package yasnippet
  :disabled t
  :defer 0.3
  :diminish yas-minor-mode
  :custom
  (yas-new-snippet-default
    "# name: $2
# key: $1
# --
$0`(yas-escape-text yas-selected-text)`")
  :config
  (add-hook 'prog-mode-hook (lambda () (yas-reload-all) (yas-minor-mode)))
  (yas-reload-all)

  (pretty-hydra-define hydra-snippet
    (:hint nil :color teal :quit-key "q" :title (with-faicon "sticky-note" "Snippets" 1 -0.05))
    ("Snippet"
      (("s" yas-insert-snippet "insert")
        ("n" yas-new-snippet "new")
        ("e" yas-visit-snippet-file "edit")
        ("r" yas-reload-all "reload"))))

  (evil-define-key 'normal global-map
    (kbd ",i") 'hydra-snippet/body))

;; (use-package plantuml-mode
;;   :mode ("\\.plantuml\\'" "\\.puml\\'")
;;   :custom (plantuml-jar-path (expand-file-name (format "%s/plantuml.jar" xdg-lib))))

(defun my/breadcrumb-set-local ()
  (when buffer-file-name
  (if (projectile-project-p)
    (let* ((path (string-remove-prefix (projectile-project-root) buffer-file-name))
            (tokens (split-string path "/"))
            (path (string-join tokens " > ")))
      (setq-local header-line-format
        `(:eval
           (format "%s %s"
             (propertize (format "[%s]" (projectile-project-name)) 'face 'bold)
             ,path))))
    (setq-local header-line-format
      '(:eval
         (buffer-name (current-buffer)))))))

(use-package elisp-mode
  :commands emacs-lisp-mode
  :hook (emacs-lisp-mode . flycheck-mode)
  :straight nil
  :diminish "Elisp"
  :config
  (unbind-key "C-M-i" emacs-lisp-mode-map)

  (evil-define-key 'normal emacs-lisp-mode-map
    (kbd ",d") 'hydra-debug-elisp/body
    (kbd "<down>") 'evil-next-visual-line
    (kbd "<up>") 'evil-previous-visual-line)

  (pretty-hydra-define hydra-debug-elisp
    (:hint nil :color amaranth :quit-key "q" :title (with-faicon "bug" "Debug" 1 -0.05))
    ("Toggle"
      (("e" afa/edebug-on-entry-on-point "debug function on entry" :exit t)
        ("c" edebug-cancel-on-entry "cancel debug function" :exit t)
        ("r" toggle-debug-on-error "toggle debug on error" :exit t)
        ("q" toggle-debug-on-quit "toggle debug on quit" :exit t)
        ("o" edebug-remove-instrumentation "remove instrumentation" :exit t))
        ;; ("c" edebug-x-kill-breakpoint "kill breakpoint" :exit t)
      "Breakpoint"
      (("s" edebug-set-breakpoint "set breakpoint" :exit t)
        ("u" edebug-unset-breakpoint "unset breakpoint" :exit t)
        ("t" edebug-toggle-disable-breakpoint "toggle disable breakpoint" :exit t))
      "Show"
      (("b" edebug-x-show-breakpoints "show breakpoints" :exit t)
        ("i" edebug-x-show-instrumented "show instrumented functions" :exit t)
        ("d" edebug-x-show-data "show breakpoints and instrumented functions buffer" :exit t)
        ("h" edebug-menu "menu" :exit t)
        ("v" edebug-visit-eval-list "visit eval list" :exit t))
      "Navigation"
      (("x" edebug-next "next" :exit t)
        ("n" edebug-step-in "step in" :exit t)
        ("o" edebug-step-out "step out" :exit t)
        ("g" edebug-goto-here "goto to point" :exit t))))

  (defun afa/edebug-on-entry-on-point (&optional flag)
    "Enhanced `edebug-on-entry'.
ets function symbol on point as initial suggestion."
    (interactive "P")
    (let ((function-name
            (intern
              (funcall
                completing-read-function
                "Edebug on entry to: "
                (mapcar 'symbol-name (apropos-internal ".*"))
                'commandp
                t
                (symbol-name (symbol-at-point))))))
      (edebug-on-entry function-name flag)))

  (defalias 'elisp-mode 'emacs-lisp-mode))

(use-package solidity-mode
  :straight (:type git
              :host github
              :repo "ethereum/emacs-solidity"
              :branch "master")
  :mode "\\.sol\\'"
  :hook ((solidity-mode . (lambda () (setq-local c-basic-offset 4))))
  :custom
  (solidity-flycheck-solium-checker-active t)
  :config
  (when (executable-find "solium")
    (message "Executable 'solium' not found!")))

(use-package company-solidity
  :after company
  :mode "\\.sol\\'")

(use-package jenkinsfile-mode
  :mode "^Jenkinsfile\\'")

(use-package ivy-xref
  :after ivy
  :init
  (when (>= emacs-major-version 27)
    (setq-default xref-show-definitions-function 'ivy-xref-show-defs))
  :custom
  (setq xref-show-xrefs-function 'ivy-xref-show-xrefs))

(require 'my-python)
(require 'my-web)
(require 'my-js)
(require 'my-php)
(require 'my-ruby)

(provide 'my-devel)
;;; my-devel.el ends here
