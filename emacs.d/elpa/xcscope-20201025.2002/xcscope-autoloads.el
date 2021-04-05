;;; xcscope-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "xcscope" "../../../../.emacs.d/elpa/xcscope-20201025.2002/xcscope.el"
;;;;;;  "f8ac1ed54160f1ecb07308158ea11e0a")
;;; Generated autoloads from ../../../../.emacs.d/elpa/xcscope-20201025.2002/xcscope.el

(autoload 'cscope-minor-mode "xcscope" "\
This cscope minor mode maps cscope keybindings to make cscope
functions more accessible.

If called interactively, enable Cscope minor mode if ARG is
positive, and disable it if ARG is zero or negative.  If called
from Lisp, also enable the mode if ARG is omitted or nil, and
toggle it if ARG is `toggle'; disable the mode otherwise.

Key bindings:
\\{cscope-minor-mode-keymap}

\(fn &optional ARG)" t nil)

(autoload 'cscope-setup "xcscope" "\
Automatically turns on cscope-minor-mode when editing C and
C++ sources" t nil)

;;;### (autoloads "actual autoloads are elsewhere" "xcscope" "../../../../.emacs.d/elpa/xcscope-20201025.2002/xcscope.el"
;;;;;;  (0 0 0 0))
;;; Generated autoloads from ../../../../.emacs.d/elpa/xcscope-20201025.2002/xcscope.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "xcscope" '("cscope-")))

;;;***

;;;***

;;;### (autoloads nil nil ("../../../../.emacs.d/elpa/xcscope-20201025.2002/xcscope-autoloads.el"
;;;;;;  "../../../../.emacs.d/elpa/xcscope-20201025.2002/xcscope.el")
;;;;;;  (0 0 0 0))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; xcscope-autoloads.el ends here
