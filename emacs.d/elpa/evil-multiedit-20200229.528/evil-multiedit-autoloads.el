;;; evil-multiedit-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "evil-multiedit" "../../../../.emacs.d/elpa/evil-multiedit-20200229.528/evil-multiedit.el"
;;;;;;  "71c5fec5059528394635b26319f55ba8")
;;; Generated autoloads from ../../../../.emacs.d/elpa/evil-multiedit-20200229.528/evil-multiedit.el

(autoload 'evil-multiedit-restore "evil-multiedit" "\
Restore the last group of multiedit regions." t nil)

(autoload 'evil-multiedit-match-all "evil-multiedit" "\
Highlight all matches of the current selection (or symbol under pointer) as
multiedit regions." t nil)
 (autoload 'evil-multiedit-match-symbol-and-next "evil-multiedit" nil t)
 (autoload 'evil-multiedit-match-symbol-and-prev "evil-multiedit" nil t)

(autoload 'evil-multiedit-toggle-marker-here "evil-multiedit" "\
Toggle an arbitrary multiedit region at point." t nil)
 (autoload 'evil-multiedit-operator "evil-multiedit" nil t)
 (autoload 'evil-multiedit-match-and-next "evil-multiedit" nil t)
 (autoload 'evil-multiedit-match-and-prev "evil-multiedit" nil t)

(autoload 'evil-multiedit-toggle-or-restrict-region "evil-multiedit" "\
If in visual mode, restrict the multiedit regions to the selected region.
i.e. disable all regions outside the selection. If in any other mode, toggle the
multiedit region beneath the cursor, if one exists.

\(fn &optional BEG END)" t nil)

(autoload 'evil-multiedit-next "evil-multiedit" "\
Jump to the next multiedit region." t nil)

(autoload 'evil-multiedit-prev "evil-multiedit" "\
Jump to the previous multiedit region." t nil)

(autoload 'evil-multiedit-abort "evil-multiedit" "\
Clear all multiedit regions, clean up and revert to normal state.

\(fn &optional INHIBIT-NORMAL)" t nil)

(autoload 'evil-multiedit-insert-state-escape "evil-multiedit" "\
Exit to `evil-multiedit-state' and move the cursor back one, to be consistent
with behavior when exiting vanilla insert state." t nil)

(autoload 'evil-multiedit-exit-hook "evil-multiedit" "\
Abort the current multiedit session without switching to normal mode." nil nil)
 (autoload 'evil-multiedit-ex-match "evil-multiedit" nil t)

;;;### (autoloads "actual autoloads are elsewhere" "evil-multiedit"
;;;;;;  "../../../../.emacs.d/elpa/evil-multiedit-20200229.528/evil-multiedit.el"
;;;;;;  (0 0 0 0))
;;; Generated autoloads from ../../../../.emacs.d/elpa/evil-multiedit-20200229.528/evil-multiedit.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "evil-multiedit" '("evil-multiedit-" "iedit-o")))

;;;***

;;;***

;;;### (autoloads nil nil ("../../../../.emacs.d/elpa/evil-multiedit-20200229.528/evil-multiedit-autoloads.el"
;;;;;;  "../../../../.emacs.d/elpa/evil-multiedit-20200229.528/evil-multiedit.el")
;;;;;;  (0 0 0 0))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; evil-multiedit-autoloads.el ends here
