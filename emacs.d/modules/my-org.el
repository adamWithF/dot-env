﻿;; -*- lexical-binding: t; -*-
(require 'org-agenda)
(require 'org-toc)
(require 'org-habit)
(require 'org-collector)
;; (require 'org-depend)
;; (require 'org-eww)
(require 'org-contrib)
(require 'org-checklist)
(require 'org-table-cell-move)
(require 'org-protocol)

(make-directory my/org-base-path t)

(add-to-list 'org-modules 'org-habit t)
(add-to-list 'org-modules 'org-drill t)
(add-to-list 'org-modules 'org-collector t)
(add-to-list 'org-modules 'org-checklist t)
;; (add-to-list 'org-modules 'org-depend t)
;; (add-to-list 'org-modules 'org-eww t)
(add-to-list 'org-modules 'org-checklist t)

(use-package calfw
  :defer)

(use-package calfw-org
  :requires calfw
  :commands cfw:open-org-calendar)

;; (defalias 'cal #'cfw:open-org-calendar)

(require 'ob-python)

(org-babel-do-load-languages
  'org-babel-load-languages
  '(
     (emacs-lisp . t)
     (ledger . t)
     (python . t)
     (gnuplot . t)
     (shell . t)
     (latex . t)
     ))

(setq org-babel-python-command "python3")

(use-package async
  :straight (:type git
             :host github
             :repo "jwiegley/emacs-async"))

;; This is for async evalaution of org-babel blocks.
(use-package ob-async
  :straight (ob-async
              :type git
              :host github
              :repo "astahlm/ob-async"
              :fork (:host github :repo "adamWithF/ob-async"))
  :config
  (setq ob-async-no-async-languages-alist '("ipython")))

;; (use-package auctex
;;   :hook (LaTeX-mode . turn-on-reftex)
;;   :defer t)

(define-minor-mode my/org-agenda-appt-mode
  "Minor mode for org agenda updating appt"
  :init-value nil
  :lighter " appt"
  (add-hook 'after-save-hook #'my/org-agenda-to-appt-if-not-terminated nil t))

(diminish 'my/org-agenda-appt-mode)

(defvar my/save-buffers-kill-terminal-was-called nil)

(defun my/org-agenda-to-appt-if-not-terminated ()
  (unless my/save-buffers-kill-terminal-was-called
    (org-agenda-to-appt t)))

;; https://stackoverflow.com/questions/9547912/emacs-calendar-show-more-than-3-months
(defun my/calendar-year (&optional year)
  "Generate a one year calendar that can be scrolled by year in each direction.
This is a modification of:  http://homepage3.nifty.com/oatu/emacs/calendar.html
See also: https://stackoverflow.com/questions/9547912/emacs-calendar-show-more-than-3-months"
  (interactive)
  (require 'calendar)
  (let* (
      (current-year (number-to-string (nth 5 (decode-time (current-time)))))
      (month 0)
      (year (if year year (string-to-number (format-time-string "%Y" (current-time))))))
    (switch-to-buffer (get-buffer-create calendar-buffer))
    (when (not (eq major-mode 'calendar-mode))
      (calendar-mode))
    (setq displayed-month month)
    (setq displayed-year year)
    (setq buffer-read-only nil)
    (erase-buffer)
    ;; horizontal rows
    (dotimes (j 4)
      ;; vertical columns
      (dotimes (i 3)
        (calendar-generate-month
          (setq month (+ month 1))
          year
          ;; indentation / spacing between months
          (+ 5 (* 25 i))))
      (goto-char (point-max))
      (insert (make-string (- 10 (count-lines (point-min) (point-max))) ?\n))
      (widen)
      (goto-char (point-max))
      (narrow-to-region (point-max) (point-max)))
    (widen)
    (goto-char (point-min))
    (setq buffer-read-only t)))

(defun my/scroll-year-calendar-forward (&optional arg event)
  "Scroll the yearly calendar by year in a forward direction."
  (interactive (list (prefix-numeric-value current-prefix-arg)
                     last-nonmenu-event))
  (unless arg (setq arg 0))
  (save-selected-window
    (if (setq event (event-start event)) (select-window (posn-window event)))
    (unless (zerop arg)
      (let* (
              (year (+ displayed-year arg)))
        (my/calendar-year year)))
    (goto-char (point-min))
    (run-hooks 'calendar-move-hook)))

(defun my/scroll-year-calendar-backward (&optional arg event)
  "Scroll the yearly calendar by year in a backward direction."
  (interactive (list (prefix-numeric-value current-prefix-arg)
                     last-nonmenu-event))
  (my/scroll-year-calendar-forward (- (or arg 1)) event))

(define-key calendar-mode-map "<" #'my/scroll-year-calendar-backward)
(define-key calendar-mode-map ">" #'my/scroll-year-calendar-forward)

(defalias 'calendar-year #'my/calendar-year)
(defalias 'my/calendar-full #'my/calendar-year)
(defalias 'yearly-calendar #'my/calendar-year)

(defun my/outline-hide-subtree ()
  (interactive)
  (if (org-at-heading-p)
    (outline-hide-subtree)
    (org-shifttab)))

(defun my/org-metaup ()
  (interactive)
  (call-interactively
    (if (org-at-heading-or-item-p)
      'org-metaup
      'drag-stuff-up)))

(defun my/org-metadown ()
  (interactive)
  (call-interactively
    (if (org-at-heading-or-item-p)
      'org-metadown
      'drag-stuff-down)))

;; TODO duplicated block
(use-package org
  :hook ((org-mode . org-indent-mode)
          (org-mode . iscroll-mode))
  :bind (:map org-mode-map
          ("C-c C-l" . hydra-org/body)
          )
  :config
  (pretty-hydra-define hydra-org
    (:hint nil :color teal :quit-key "q" :title (with-fileicon "org" "Org" 1 -0.05))
    ("Action"
      (("t" org-toggle-timestamp-type "timestamp toggle")
        ("l" org-link-archive "link archive")
        ("i" org-toggle-inline-images "images toggle" :toggle t)
        ("r" my/reverse-org-paragraphs-order "reverse paragraph order")
        ("h" org-archive-subtree "archive heading subtree")
        )
      "Navigation"
      (("s" counsel-org-goto "goto heading")
        ("a" counsel-org-file "browse attachments")))
    )

     (setq
       org-startup-with-inline-images nil
       org-blank-before-new-entry '((heading . auto) (plain-list-item . nil))
       org-hide-emphasis-markers t
       org-agenda-start-with-log-mode t
       org-agenda-sort-noeffort-is-high nil
       org-agenda-skip-additional-timestamps-same-entry t
       org-agenda-skip-deadline-prewarning-if-scheduled t
       org-src-preserve-indentation t
       org-table-header-line-p t
       org-image-actual-width 1200
       ;; (setq org-list-end-re "^$")
       org-list-demote-modify-bullet
       '(
          ("+" . "-")
          ("-" . "+")
          ("1." . "-")))

     (bind-keys
       ("C-c c" . org-capture)
       ("C-x a" . org-agenda)
       ("C-c l" . org-store-link)
       ("C-c L" . org-insert-link-global)
       ("C-c j" . org-clock-goto) ;; jump to current task from anywhere
       ("C-c C-o" . org-open-at-point-global)
       :map org-mode-map
       ("C-c l" . org-store-link)
       ("C-c C-x a" . org-archive-subtree-default)
       ("M-}" . forward-paragraph)
       ("M-{" . backward-paragraph)
       ("C-M-<up>" . org-table-move-single-cell-up)
       ("C-M-<down>" . org-table-move-single-cell-down)
       ("C-M-<left>" . org-table-move-single-cell-left)
       ("C-M-<right>" . org-table-move-single-cell-right)
       ("<S-tab>" . my/outline-hide-subtree)
       ("<M-up>" . my/org-metaup)
       ("<M-down>" . my/org-metadown)
       ("<s-mouse-1>" . org-open-at-point)
       ("<S-mouse-1>" . org-open-at-point)
       ([remap backward-paragraph] . nil)
       ([remap forward-paragraph] . nil)
       ("C-x :" . (lambda () (interactive) (save-excursion (org-back-to-heading) (org-set-tags)))))

     (unbind-key "C-'" org-mode-map)
     (unbind-key "C-," org-mode-map)
     (unbind-key "C-c $" org-mode-map) ; removed archive subtree shortcut
     (unbind-key "C-c C-x C-a" org-mode-map) ; remove archive subtree default shortcut
     (unbind-key "C-c C-x C-s" org-mode-map) ; remove archive subtree shortcut
     (unbind-key "C-c C-x A" org-mode-map) ; remove archive to archive siblings shortcut

     (diminish 'org-indent-mode)

  (setq org-refile-targets
    `(
       (,my/org-backlog-file-path :maxlevel . 1)
       (,my/org-tasks-maybe-someday-file-path :maxlevel . 1)
       (,my/org-tasks-file-path :maxlevel . 1)
       (,my/org-taxes-file-path :maxlevel . 1)
       (,my/org-temp-file-path :maxlevel . 1)
       (,my/org-ideas-file-path :maxlevel . 1)
       ))

  ;; https://emacs.stackexchange.com/questions/61101/keep-displaying-current-org-heading-info-in-some-way/61107#61107
  (defun ndk/heading-title ()
    "Get the heading title."
    (save-excursion
      (if (not (org-at-heading-p))
       (org-previous-visible-heading 1))
      (org-element-property :title (org-element-at-point))))

  (defun ndk/org-breadcrumbs ()
    "Get the chain of headings from the top level down to the current heading."
    (let* ((breadcrumbs (org-format-outline-path
                          (org-get-outline-path)
                          (1- (frame-width))
                          nil " > "))
            (title (ndk/heading-title))
            (node (org-roam-node-at-point))
            (filename (if node (org-roam-node-file-title node)))
            (filename (if filename filename (buffer-name))))

      (if title
        (if (string-empty-p breadcrumbs)
          (format "[%s] %s" filename title)
          (format "[%s] %s > %s" filename breadcrumbs title))
        (org-roam-node-file-title (org-roam-node-at-point)))))

  (defun ndk/set-header-line-format ()
    (setq header-line-format '(:eval (ndk/org-breadcrumbs))))

  (add-hook 'org-mode-hook #'ndk/set-header-line-format)

     ;; org mode conflicts resolution: windmove
     ;; (add-hook 'org-shiftup-final-hook #'windmove-up)
     ;; (add-hook 'org-shiftleft-final-hook 'windmove-left)
     ;; (add-hook 'org-shiftdown-final-hook 'windmove-down)
     ;; (add-hook 'org-shiftright-final-hook #'windmove-right)

     (advice-add #'org-refile :after
       (lambda (&rest args) (org-save-all-org-buffers)))

     (advice-add #'org-archive-subtree-default :after
       (lambda () (org-save-all-org-buffers)))

     (advice-add #'org-agenda-archive-default :after
       (lambda () (org-save-all-org-buffers)))

     (advice-add #'org-clock-in  :after (lambda (&rest args) (org-save-all-org-buffers)))
     (advice-add #'org-clock-out :after (lambda (&rest args) (org-save-all-org-buffers)))

     (add-hook 'org-mode-hook
       (lambda ()
         (setq-local
           paragraph-start "[:graph:]+$"
           paragraph-separate "[:space:]*$")))

     ;; refresh agenda after adding new task via org-capture
     (add-hook 'org-capture-after-finalize-hook
       (lambda ()
         (save-excursion
           (when (get-buffer "*Org Agenda*")
             (with-current-buffer "*Org Agenda*" (org-agenda-redo)))))))

(use-package org-contacts
  :after org)

(eval-after-load 'org-agenda
  '(progn
     (bind-keys
       :map org-agenda-mode-map
       ("C-c C-c" . org-agenda-set-tags)
       ("C-d" . evil-scroll-down)
       ("C-u" . evil-scroll-up)
       ("s-t" . make-frame-command)
       ("n" . evil-search-next)
       ("N" . evil-search-previous)
       ("*" . evil-search-word-forward)
       ("'" . org-agenda-filter-by-tag)
       ("\w" . avy-goto-word-or-subword-1)
       ("\c" . avy-goto-word-or-subword-1))

     (unbind-key "\\" org-agenda-mode-map)

     (add-hook 'org-agenda-mode-hook
       (lambda ()
         (hl-line-mode 1)))))

(use-package japanese-holidays
  :straight (
             :type git
             :host github
             :repo "emacs-jp/japanese-holidays"
              :branch "master"))

(defvar calendar-holidays)
(setq
  holiday-local-holidays nil
  diary-show-holidays-flag nil
  calendar-christian-all-holidays-flag t
  ;; calendar-mark-holidays-flag t
  calendar-week-start-day 1
  calendar-date-style 'european)
;; )

(setq
  org-agenda-include-diary t
  org-agenda-search-headline-for-time nil)

(setq diary-number-of-entries 31)

;; (add-hook 'calendar-load-hook
;;   (lambda () (calendar-set-date-style 'european)))

(setq
  org-clock-into-drawer t
  org-log-into-drawer t)
(setq org-clock-persist t) ; or 'history?
(setq org-clock-idle-time 2) ; TODO requires testing
(setq org-lowest-priority 68)
(setq org-highest-priority 65)
(setq org-default-priority 66)
(setq org-log-done 'time)

(setq org-default-notes-file my/org-inbox-file-path)
(setq org-contacts-files `(,my/org-contacts-file-path))
(setq org-contacts-birthday-format "%h (%Y)")
;; (setq org-journal-dir (expand-file-name "journal" user-emacs-directory))
;; (setq org-default-notes-file (expand-file-name "notes.org" org-directory))

(setq org-hide-leading-stars t)
(setq org-startup-indented t)

(setq org-refile-allow-creating-parent-nodes 'confirm)
;; (setq org-refile-targets `(
;;                             (,my/org-tasks-file-path :level . 1) ; pool of tasks
;;                             (,my/org-project-trip-nottingham :level . 1)
;;                             (,my/org-project-trip-edinburgh :level . 1)
;;                             (,my/org-project-become-confident-pua :level . 1)
;;                             (,my/org-project-service-arbitrage :level . 1)
;;                             (,my/org-project-best-offers-club :level . 1)
;;                             (,my/org-project-indie-dev :tag . "PROJECT_ACTIVE")
;;                             (,my/org-project-guru :level . 1)
;;                             (,my/org-project-switch-to-self-accounting :level . 1)
;;                             (,my/org-projects-file-path :level . 1)))

(setq
  org-export-exclude-category (list "private")
  org-export-babel-evaluate t
  org-export-preserve-breaks nil
  org-export-with-toc nil
  org-export-with-smart-quotes t ; could cause problems on babel export
  )

(setq org-group-tag nil)
(setq org-archive-reversed-order t)
(setq org-startup-folded t)
;; (setq org-enforce-todo-dependencies t)
(setq org-agenda-dim-blocked-tasks t)
;; (setq org-track-ordered-property-with-tag t)
(setq org-use-property-inheritance t)
(setq org-use-speed-commands t)
(setq org-edit-src-content-indentation 0)
(setq org-src-fontify-natively t)
(setq org-src-tab-acts-natively t)
(setq org-priority-start-cycle-with-default nil)
(setq org-columns-default-format "%25ITEM(Task) %TODO %3PRIORITY %7Effort %8CLOCKSUM %TAGS")
;; (setq org-completion-use-ido t)
(setq org-confirm-babel-evaluate (lambda (lang body) (not (string= lang "ledger"))))
(setq org-ascii-links-to-notes nil)
(setq org-ascii-headline-spacing '(1 . 1))
(setq org-icalendar-use-scheduled '(todo-start event-if-todo))
(setq org-icalendar-use-deadline '(event-if-todo))
(setq org-icalendar-honor-noexport-tag t) ; this is not supported in my version
(setq org-adapt-indentation nil)
(setq org-cycle-include-plain-lists t)
(setq org-hide-block-startup t)
(setq org-list-description-max-indent 5)
(setq org-agenda-inhibit-startup t)
(setq org-agenda-use-tag-inheritance nil)
(setq org-agenda-fontify-priorities 'cookies)
(setq org-agenda-log-mode-items '(clock))
(setq org-fontify-done-headline t)
(setq org-closed-keep-when-no-todo t)
(setq org-log-done-with-time nil)
(setq org-deadline-warning-days 14)
;; (setq org-tags-column -100)
(setq org-reverse-note-order t)
(setq org-global-properties '(("Effort_ALL" . "0:00 0:15 0:30 1:00 2:00 4:00")))
(setq org-clock-report-include-clocking-task t)
(setq org-clock-out-remove-zero-time-clocks t)
(setq org-pretty-entities t)
(setq org-pretty-entities-include-sub-superscripts nil)

(setq org-clock-in-resume t)
(setq org-clock-persist-query-resume nil)
(setq org-clock-in-switch-to-state "IN-PROCESS")
;; (setq org-clock-out-when-done (list "TODO" "BLOCKED" "WAITING" "DONE" "DELEGATED" "UNDOABLE"))
(setq org-clock-out-when-done t)
(setq org-agenda-scheduled-leaders '("" ""))
;; (setq org-agenda-window-setup 'current-window)
(setq org-return-follows-link nil)
(setq org-link-frame-setup
  '((vm . vm-visit-folder-other-frame)
     (vm-imap . vm-visit-imap-folder-other-frame)
     (gnus . org-gnus-no-new-news)
     (file . find-file)
     (wl . wl-other-frame)))
(setq org-icalendar-timezone "Europe/London") ; or nil
(setq org-icalendar-alarm-time 60)
(setq plstore-cache-passphrase-for-symmetric-encryption t)
(setq org-agenda-file-regexp ".*org\(.gpg\)?$")
(setq org-element-use-cache nil)

(setq org-icalendar-with-timestamps 'active)
(setq org-icalendar-include-todo t)
(setq org-icalendar-include-sexps t)
(setq org-icalendar-store-UID t)
(setq org-habit-show-habits-only-for-today nil)
(setq org-habit-graph-column 62)
(setq org-refile-use-outline-path t)

;; (setq org-blank-before-new-entry nil)
(setq org-agenda-skip-scheduled-if-deadline-is-shown 'not-today)
(setq org-odt-preferred-output-format "doc")
(setq org-agenda-start-on-weekday nil)
(setq org-fast-tag-selection-single-key t) ; expert ?

(if (executable-find "unoconv")
  (setq org-odt-convert-processes '(("unoconv" "unoconv -f %f -o %d %i")))
  (setq org-odt-convert-processes '(("unoconv" "unoconv -f %f -o %d.xls %i")))
  (message "No executable \"unoconv found\".")
  )

(setq org-tags-exclude-from-inheritance '("project" "taskjuggler_project" "taskjuggler_resource") ; prj
      org-stuck-projects '("+project/-DONE" ("TODO") ()))

(defun org-priority-cookie ()
  (format "[#%c]" org-default-priority))

(setq org-todo-keywords
  '( (sequence "TODO(t)" "IN-PROCESS(p!)" "BLOCKED(b!)" "WAITING(w@/!)" "DELEGATED(e@/!)")
     (sequence "|" "DONE(d!)" "SKIP(c@)" "UNDOABLE(u@)")))

(setq org-todo-keyword-faces
  '( ("TODO"       . (:foreground "LimeGreen"   :weight bold))
     ("IN-PROCESS" . (:foreground "IndianRed1"  :weight bold))
     ("BLOCKED"    . (:foreground "tomato3"     :weight bold))
     ("WAITING"    . (:foreground "coral"       :weight bold))
     ("DELEGATED"  . (:foreground "coral"       :weight bold))
     ("NOTE"       . (:foreground "white"       :weight bold))
     ("DONE"       . (:foreground "dark grey"   :weight normal))
     ("SKIP"       . (:foreground "dark grey"   :weight normal))
     ("UNDOABLE"   . (:foreground "dark grey"   :weight normal))))

; from https://emacs.cafe/emacs/orgmode/gtd/2017/06/30/orgmode-gtd.html
(defun my/org-agenda-skip-all-siblings-but-first ()
  "Skip all but the first non-done entry."
  (let (should-skip-entry)
    (unless (my/org-current-is-todo-p)
      (setq should-skip-entry t))
    (save-excursion
      (while (and (not should-skip-entry) (org-goto-sibling t))
        (if (my/org-current-is-todo-p)
          (setq should-skip-entry t)
          (setq should-skip-entry nil))))
    (when should-skip-entry
      (or (outline-next-heading)
          (goto-char (point-max))))))

(defun my/org-current-is-todo-p ()
  (string= "TODO" (org-get-todo-state)))

;; (setq org-agenda-custom-commands
;;   '(("o" "At the office" tags-todo "@office"
;;       ((org-agenda-overriding-header "Office")
;;         (org-agenda-skip-function #'my/org-agenda-skip-all-siblings-but-first)))))

;; (setq org-agenda-custom-commands
;;       '(("o" "At the office" tags-todo "@office"
;;          ((org-agenda-overriding-header "Office")))))

(setq my/org-active-projects (list
                               ;; my/org-project-indie-dev
                               ;; my/org-project-service-arbitrage
                               ;; my/org-project-best-offers-club
                               ;; my/org-project-setup-digital-agency
                               ;; my/org-project-setup-career-it-blog
                               ;; my/org-project-launch-diy-app
                               ;; my/org-project-launch-amazon-business
                               ;; my/org-project-become-confident-pua
                               ;; my/org-project-trip-edinburgh
                               ;; my/org-project-trip-nottingham
                               ))

(setq org-agenda-custom-commands
  '(("co" "TODOs weekly sorted by state, priority, deadline, scheduled, alpha and effort"
      ((agenda "*"))
      ((org-agenda-overriding-header "agenda weekly sorted by state, priority, deadline, scheduled, alpha and effort")
        (org-agenda-sorting-strategy '(todo-state-down priority-down deadline-down scheduled-down alpha-down effort-up))))

     ("cn" "TODOs not sheduled"
       ((todo "*"))
       ((org-agenda-skip-function
           '(or (org-agenda-skip-if nil '(scheduled))))
         (org-agenda-category-filter-preset '("-Holidays"))
         (org-agenda-overriding-header "TODOs not scheduled")
         (org-agenda-sorting-strategy '(deadline-down priority-down alpha-down effort-up))))

     ("cb" "TODOs blocked"
       ((tags "BLOCKED"))
       ((org-agenda-overriding-header "TODOs blocked")
         (org-agenda-sorting-strategy '(priority-down deadline-down alpha-down effort-up))))

     ("cc" "TODOs skip"
       ((todo "SKIP"))
       ((org-agenda-overriding-header "TODOs skip")
         (org-agenda-sorting-strategy '(priority-down alpha-down effort-up))))

     ("cj" "Journal entries"
       ((search ""))
       ((org-agenda-files (list org-journal-dir))
         (org-agenda-overriding-header "Journal")
         (org-agenda-sorting-strategy '(timestamp-down))))

     ("cm" "agenda 1 month ahead"
       ((agenda ""
         ((org-agenda-sorting-strategy '(time-up todo-state-down habit-down))
           (org-agenda-span 'month)
           (org-agenda-remove-tags t)
           (ps-number-of-columns 2)
           (ps-landscape-mode 1)))))

     ("cp" "Active projects"
       ((tags "PROJECT_ACTIVE"))
       ((org-agenda-overriding-header "Active Projects")
         (org-tags-match-list-sublevels nil)
         (org-agenda-remove-tags t)
         (org-agenda-files my/org-active-projects)))

     ("i" "Inbox"
        ((tags "*"
          ((org-agenda-overriding-header "Inbox")
            (org-agenda-remove-tags nil)
            (org-agenda-cmp-user-defined 'my/org-agenda-cmp-user-defined-created-date)
            (org-agenda-sorting-strategy '(user-defined-down alpha-up))
            (org-agenda-files (list my/org-inbox-file-path))))))

     ("b" "Backlog"
        ((todo "TODO"
          ((org-agenda-overriding-header "Backlog")
            (org-agenda-remove-tags nil)
            (org-agenda-cmp-user-defined 'my/org-agenda-cmp-user-defined-created-date)
            (org-agenda-sorting-strategy '(user-defined-down alpha-up))
            (org-agenda-files (list my/org-backlog-file-path))))))

     ("y" "Maybe / Someday"
        ((todo "TODO"
          ((org-agenda-overriding-header "Maybe / Someday")
            (org-agenda-remove-tags nil)
            (org-agenda-cmp-user-defined 'my/org-agenda-cmp-user-defined-created-date)
            (org-agenda-sorting-strategy '(user-defined-down alpha-up))
            (org-agenda-files (list my/org-tasks-maybe-someday-file-path))))))

     ("p" "Active places tasks"
       ((tags "@phone"
          ((org-agenda-overriding-header "Active Phone tasks:")
            (org-agenda-skip-function
              '(or
                 (org-agenda-skip-entry-if 'todo '("DONE" "UNDOABLE" "SKIP" "IN-PROCESS" "WAITING"))
                 (my/org-agenda-skip-if-scheduled-later)
                 ))
            (org-tags-match-list-sublevels nil)
            (org-agenda-remove-tags t)
            (org-agenda-files (append org-agenda-files my/org-active-projects))))
         (tags "@computer"
           ((org-agenda-overriding-header "Active Computer tasks:")
             (org-agenda-skip-function
               '(or
                  (org-agenda-skip-entry-if 'todo '("DONE" "UNDOABLE" "SKIP" "IN-PROCESS" "WAITING"))
                  (my/org-agenda-skip-if-scheduled-later)
                  ))
             (org-tags-match-list-sublevels nil)
             (org-agenda-remove-tags t)
             (org-agenda-files (append org-agenda-files my/org-active-projects))))
         (tags "@office"
           ((org-agenda-overriding-header "Active Office tasks:")
             (org-agenda-skip-function
               '(or
                  (org-agenda-skip-entry-if 'todo '("DONE" "UNDOABLE" "SKIP" "IN-PROCESS" "WAITING"))
                  (my/org-agenda-skip-if-scheduled-later)
                  ))
             (org-tags-match-list-sublevels nil)
             (org-agenda-remove-tags t)
             (org-agenda-files (append org-agenda-files my/org-active-projects))))
         (tags-todo "@home"
           ((org-agenda-overriding-header "Active Home tasks:")
             (org-agenda-skip-function
               '(or
                  (org-agenda-skip-entry-if 'todo '("DONE" "UNDOABLE" "SKIP" "IN-PROCESS" "WAITING"))
                  (my/org-agenda-skip-if-scheduled-later)
                  ))
             (org-tags-match-list-sublevels nil)
             (org-agenda-remove-tags t)
             (org-agenda-files (append org-agenda-files my/org-active-projects))))
         (tags "@delegate"
           ((org-agenda-overriding-header "Active Delegate tasks:")
             (org-agenda-skip-function
               '(or
                  (org-agenda-skip-entry-if 'todo '("DONE" "UNDOABLE" "SKIP" "IN-PROCESS" "WAITING"))
                  (my/org-agenda-skip-if-scheduled-later)
                  ))
             (org-tags-match-list-sublevels nil)
             (org-agenda-remove-tags t)
             (org-agenda-files (append org-agenda-files my/org-active-projects))))))

     ("z" "DONE tasks not archived"
       ((tags "TODO=\"DONE\"|TODO=\"SKIP\"|TODO=\"UNDOABLE\""))
       ((org-agenda-overriding-header "DONE tasks not archived")
         (org-agenda-files (list my/org-tasks-file-path my/org-projects-file-path))))

     ("g" "Goals"
       ((tags-todo "weekly"
          ((org-agenda-skip-function
             '(or (my/org-skip-subtree-if-priority ?A)
                (my/org-skip-subtree-if-habit)
                (org-agenda-skip-if nil '(scheduled deadline))
                (org-agenda-skip-entry-if 'todo '("DONE"))))
            (org-agenda-overriding-header "This Week Goals:")
            (org-tags-match-list-sublevels t)
            (org-agenda-hide-tags-regexp "weekly")
            (org-agenda-todo-keyword-format "")
            ;; (org-agenda-files (list my/org-yearly-goals-file-path)))
          ))
        (tags-todo "monthly"
          ((org-agenda-skip-function
             '(or (my/org-skip-subtree-if-priority ?A)
                (my/org-skip-subtree-if-habit)
                (org-agenda-skip-if nil '(scheduled deadline))
                (org-agenda-skip-entry-if 'todo '("DONE"))))
            (org-agenda-overriding-header "This Month Goals:")
            (org-tags-match-list-sublevels t)
            (org-agenda-hide-tags-regexp "monthly")
            (org-agenda-todo-keyword-format "")
            ;; (org-agenda-files (list my/org-yearly-goals-file-path)))
            ))
        (tags-todo "yearly"
          ((org-agenda-skip-function
             '(or (my/org-skip-subtree-if-priority ?A)
                (my/org-skip-subtree-if-habit)
                (org-agenda-skip-if nil '(scheduled deadline))
                (org-agenda-skip-entry-if 'todo '("DONE"))))
            (org-agenda-overriding-header "This Year Goals:")
            (org-tags-match-list-sublevels t)
            (org-agenda-hide-tags-regexp "yearly")
            (org-agenda-todo-keyword-format "")
            ;; (org-agenda-files (list my/org-yearly-goals-file-path)))
            ))))

     ("f" "Tasks finished"
       ((agenda ""
          ((org-agenda-skip-function '(org-agenda-skip-entry-if 'nottodo '("DONE" "UNDOABLE" "SKIP")))
            (org-agenda-log-mode-items '(closed))
            (org-agenda-overriding-header "Tasks finished this week:")
            (org-agenda-files (append org-agenda-files my/org-active-projects (list my/org-archive-tasks-path)))
            (org-agenda-prefix-format '((agenda . " %-12:c%?-12t [%-4e] ")))
            (org-agenda-start-on-weekday 1)))))

     ("d" "Coprehensive agenda"
       ((tags-todo "PRIORITY=\"A\"|TODO=\"IN-PROCESS\""
          ((org-agenda-skip-function
             '(or
                (org-agenda-skip-entry-if 'todo '("DONE" "UNDOABLE" "SKIP"))
                (and
                  (org-agenda-skip-entry-if 'nottodo '("IN-PROCESS"))
                  (my/org-skip-subtree-if-priority ?A))))
            (org-agenda-remove-tags nil)
            (org-agenda-overriding-header "Tasks in progress:")
            (org-agenda-sorting-strategy '(time-up priority-down effort-down category-keep alpha-up))
            (org-agenda-files (append org-agenda-files  my/org-active-projects `(,my/org-taxes-file-path)))))

         (tags-todo "PRIORITY=\"A\"|TODO=\"IN-PROCESS\"|TODO=\"WAITING\""
           ((org-agenda-skip-function
              '(or
                 (org-agenda-skip-entry-if 'todo '("DONE" "UNDOABLE" "SKIP"))
                 (and
                   (org-agenda-skip-entry-if 'nottodo '("IN-PROCESS" "WAITING"))
                   (my/org-skip-subtree-if-priority ?A))))
             (org-agenda-remove-tags nil)
             (org-agenda-overriding-header "Active Goals:")
             (org-agenda-sorting-strategy '(todo-state-up category-keep alpha-up))
             (org-agenda-sorting-strategy '(time-up todo-state-up priority-down deadline-up scheduled-up user-defined-down effort-down alpha-up))
             (org-agenda-files `(,my/org-goals-file-path))))
        ;; (tags "PROJECT_ACTIVE"
        ;;   ((org-agenda-overriding-header "Active projects:")
        ;;     (org-tags-match-list-sublevels nil)
        ;;     (org-agenda-remove-tags t)
        ;;     (org-agenda-files my/org-active-projects)))
        (tags-todo "TODO=\"WAITING\""
          ((org-agenda-overriding-header "Waiting tasks:")
            (org-agenda-remove-tags t)
            ;; (org-agenda-skip-function 'my/org-agenda-skip-deadline-if-not-today)
            (org-agenda-todo-keyword-format "")
            (org-agenda-sorting-strategy '(tsia-up priority-down category-keep alpha-up))
            (org-agenda-files (append org-agenda-files my/org-active-projects))))
        ;; (tags-todo "TODO=\"BLOCKED\""
        ;;   ((org-agenda-overriding-header "BLOCKED TASKS:")
        ;;     (org-agenda-skip-function '(org-agenda-skip-entry-if 'notscheduled))
        ;;    (org-agenda-remove-tags t)
        ;;    (org-agenda-todo-keyword-format "")
        ;;     (org-agenda-sorting-strategy '(time-up priority-down todo-state-up effort-down category-keep alpha-up)))
        ;;   (org-agenda-files (append org-agenda-files my/org-active-projects)))
       ;; (agenda "weekly"
       ;;   (
       ;;     (org-agenda-skip-function
       ;;       '(or
       ;;          (org-agenda-skip-if nil '(notdeadline))
       ;;          (org-agenda-skip-entry-if 'todo 'done)
       ;;          ))
       ;;      (org-agenda-overriding-header "Weekly Goals:")
       ;;     (org-tags-match-list-sublevels t)
       ;;     (org-agenda-span 'day)
       ;;     (org-deadline-warning-days -7)
       ;;      (org-agenda-hide-tags-regexp "weekly")
       ;;      (org-agenda-todo-keyword-format "")
           ;; (org-agenda-files (list my/org-yearly-goals-file-path))
           ;; ))
        (agenda ""
          ((org-agenda-skip-function
             '(or
                (org-agenda-skip-entry-if 'todo '("WAITING" "IN-PROCESS"))
                ))
            (org-agenda-cmp-user-defined 'my/org-agenda-cmp-user-defined-birthday)
            (org-agenda-sorting-strategy '(time-up todo-state-up priority-down deadline-up scheduled-up user-defined-down effort-down alpha-up))
            (org-agenda-remove-tags nil)
            (org-agenda-prefix-format '((agenda . " %-12:c%?-12t [%-4e] ")))
            (ps-number-of-columns 2)
            (ps-landscape-mode 1)
            (org-agenda-files (append org-agenda-files `(,my/org-events-file-path ,my/org-taxes-file-path))))))))
  )

(defun my/org-agenda-cmp-user-defined-birthday (a b)
  "Org Agenda user function to sort categories against other categories. The birthday category is considered to be behind other category by default."
  (let* (
          (pla (get-text-property 0 'org-category a))
          (plb (get-text-property 0 'org-category b))
          (pla (string-equal pla "Birthday"))
          (plb (string-equal plb "Birthday"))
          )
    (if (or (and pla plb) (and (not pla) (not plb)))
      nil
      (if pla
        -1
        +1))))

(defun my/org-agenda-cmp-user-defined-created-date (a b)
  "Org Agenda user function to sort tasks based on CREATED property."
  (let* (
          (marker-a (get-text-property 0 'org-marker a))
          (marker-b (get-text-property 0 'org-marker b))
          (time-a (if marker-a (org-entry-get marker-a "CREATED") nil))
          (time-b (if marker-b (org-entry-get marker-b "CREATED") nil)))

    (if (and time-a time-b)
      (if (org-time< time-a time-b)
        -1
        (if (org-time> time-a time-b) 1 nil))
      (if time-a -1 1)
      )))

;; https://emacs.stackexchange.com/a/30194/18445
(defun my/org-agenda-skip-deadline-if-not-today ()
"If this function returns nil, the current match should not be skipped.
Otherwise, the function must return a position from where the search
should be continued."
  (ignore-errors
    (let ((subtree-end (save-excursion (org-end-of-subtree t)))
          (deadline-day
            (time-to-days
              (org-time-string-to-time
                (org-entry-get nil "DEADLINE"))))
          (now (time-to-days (current-time))))
       (and deadline-day
            (not (<= deadline-day now))
            subtree-end))))

(defun my/org-calendar-export-limit ()
  "Limit the export to items that have a date, time and a range. Also exclude certain categories."
  (setq org-tst-regexp "<\\([0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\} ... [0-9]\\{2\\}:[0-9]\\{2\\}[^\r\n>]*?\
\)>")
  (setq org-tstr-regexp (concat org-tst-regexp "--?-?" org-tst-regexp))
  (save-excursion
    ; get categories
    (setq mycategory (org-get-category))
    ; get start and end of tree
    (org-back-to-heading t)
    (setq mystart    (point))
    (org-end-of-subtree)
    (setq myend      (point))
    (goto-char mystart)
    ; search for timerange
    (setq myresult (re-search-forward org-tstr-regexp myend t))
    ; search for categories to exclude
    (setq mycatp (member mycategory org-export-exclude-category))
    ; return t if ok, nil when not ok
    (if (and myresult (not mycatp)) t nil)))

;; (defun air-org-cal-export ()
;;   (let ((org-icalendar-verify-function 'my/org-calendar-export-limit))
;;     (org-export-icalendar-combine-agenda-files)))

(defun my/org-skip-subtree-if-priority (priority)
  "Skip an agenda subtree if it has a priority of PRIORITY.
PRIORITY may be one of the characters ?A, ?B, or ?C."
  (let ((subtree-end (save-excursion (org-end-of-subtree t)))
        (pri-value (* 1000 (- org-lowest-priority priority)))
        (pri-current (org-get-priority (thing-at-point 'line t))))
    (if (= pri-value pri-current)
        subtree-end
      nil)))

(defun my/org-skip-subtree-if-habit ()
  "Skip an agenda entry if it has a STYLE property equal to \"habit\"."
  (let ((subtree-end (save-excursion (org-end-of-subtree t))))
    (if (string= (org-entry-get nil "STYLE") "habit")
        subtree-end
      nil)))

(defun my/org-agenda-skip-if-scheduled-later ()
  "If this function returns nil, the current match should not be skipped.
Otherwise, the function must return a position from where the search
should be continued."
  (ignore-errors
    (let ((subtree-end (save-excursion (org-end-of-subtree t)))
           (scheduled-seconds
             (time-to-seconds
               (org-time-string-to-time
                 (org-entry-get nil "SCHEDULED"))))
           (now (time-to-seconds (current-time))))
      (and scheduled-seconds
        (>= scheduled-seconds now)
        subtree-end))))

(defun my/org-state-canceled-timestamp-toggle ()
  "Toggle active/inactive SCHEDULED or DEADLINE timestamp Remove SCHEDULED-cookie is switching state to WAITING."
  (save-excursion
    (let ((state (org-get-todo-state)))
      (cond
        ((equal state "SKIP")
          (when (and
                  (org-get-deadline-time (point))
                  (search-forward-regexp "DEADLINE: .*" nil t)
                  (org-at-timestamp-p 'agenda))
            (org-toggle-timestamp-type))
          (when (and
                  (org-get-scheduled-time (point))
                  (search-forward-regexp "SCHEDULED: .*" nil t)
                  (org-at-timestamp-p 'agenda))
            (org-toggle-timestamp-type)))
        ((equal state "TODO")
          (when (and
                  (org-get-deadline-time (point))
                  (search-forward-regexp "DEADLINE: .*" nil t)
                  (equal (char-to-string (char-before)) "]"))
            (org-toggle-timestamp-type))
          (when (and
                  (org-get-scheduled-time (point))
                  (search-forward-regexp "SCHEDULED: .*" nil t)
                  (equal (char-to-string (char-before)) "]"))
            (org-toggle-timestamp-type)))))
    (when (equal (buffer-name (current-buffer)) "*Org Agenda*")
      (with-current-buffer "*Org Agenda*" (org-agenda-redo)))))

(add-hook 'org-after-todo-state-change-hook 'my/org-state-canceled-timestamp-toggle)

;; https://www.emacswiki.org/emacs/ReverseParagraphs
(defun my/reverse-org-paragraphs-order ()
  (interactive)
  "Reverse the order of paragraphs in a region. From a program takes two point or marker arguments, BEG and END."
  (let ((beg (point-min)) (end (point-max)) (mid))
    (when (> beg end)
      (setq mid end end beg beg mid))
    (save-excursion
      ;; the last paragraph might be missing a trailing newline
      (goto-char end)
      (setq end (point-marker))
      ;; the real work.
      (goto-char beg)
      (let (paragraphs fix-newline)
        (while (< beg end)
          ;; skip to the beginning of the next paragraph instead of
          ;; remaining on the position separating the two paragraphs
          (when (= 0 (forward-paragraph 1))
            (goto-char (1+ (match-end 0))))
          (when (> (point) end)
            (goto-char end))
          (setq paragraphs (cons (buffer-substring beg (point))
                             paragraphs))
          (delete-region beg (point)))
        ;; if all but the last paragraph end with two newlines, add a
        ;; newline to the last paragraph
        (when (and (null (delete 2 (mapcar (lambda (s)
                                             (when (string-match "\n+$" s -2)
                                               (length (match-string 0 s))))
                                     (cdr paragraphs))))
                (when (string-match "\n+$" (car paragraphs) -2)
                  (= 1 (length (match-string 0 (car paragraphs))))))
          (setq fix-newline t)
          (setcar paragraphs (concat (car paragraphs) "\n")))
        ;; insert paragraphs
        (dolist (par paragraphs)
          (insert par))
        (when fix-newline
          (delete-char -1))))))

(org-clock-persistence-insinuate)

(use-package org-review
  :config
  (bind-key "C-c C-r" #'org-review-insert-last-review org-agenda-mode-map))

(use-package org-drill
  :custom
  (org-drill-use-visible-cloze-face-p t)
  (org-drill-hide-item-headings-p t)
  (org-drill-maximum-items-per-session 30)
  (org-drill-maximum-duration 12)
  (org-drill-save-buffers-after-drill-sessions-p t)
  (org-drill-add-random-noise-to-intervals-p t)
  (org-drill-adjust-intervals-for-early-and-late-repetitions-p t)
  (org-drill-learn-fraction 0.3)
  :config
  (defalias 'drill (lambda (&optional scope drill-match) (interactive) (org-drill scope drill-match t)))
  (defalias 'resume-drill #'org-drill-resume))

;; org-diet
(require 'org-diet)
(eval-after-load 'org-diet
  '(progn
     (setq org-diet-file my/org-diet-log-file-path)))

(add-to-list 'safe-local-variable-values '(org-hide-emphasis-markers . t))

(use-package org-roam
  :after (org emacsql emacsql-sqlite)
  :diminish org-roam-mode
  :custom
  (org-roam-directory my/org-roam-directory)
  (org-roam-graph-viewer "/usr/bin/open")
  (org-roam-db-gc-threshold most-positive-fixnum)
  (org-roam-tag-sources '(prop))
  (org-roam-update-db-idle-second 60)
  (org-roam-mode-sections (list
                            #'org-roam-backlinks-section
                            #'org-roam-reflinks-section))
  (org-roam-verbose nil)
  :config
  (require 'org-roam-protocol)

  (org-roam-db-autosync-mode 1)

  (add-to-list 'display-buffer-alist
    '("\\*org-roam\\*"
       (display-buffer-in-direction)
       (direction . right)
       (window-width . 0.35)
       (window-height . fit-window-to-buffer)))

  (make-directory my/org-roam-directory t)

  (add-hook 'org-roam-dailies-find-file-hook #'abbrev-mode)

  (setq org-roam-capture-ref-templates
    '(("r" "ref" plain (function org-roam-capture--get-point)
        "%?"
        :file-name "website/%<%Y%m%d%H%M%S>"
        :head "#+TITLE: ${title}
#+CREATED: %U
#+LAST_MODIFIED: %U
#+ROAM_KEY: ${ref}
#+ROAM_TAGS:

- progress-status ::
- tags :: "
        :unnarrowed t)))

  (setq org-roam-dailies-directory "journal/")

  (setq org-roam-capture-templates
    '(
       ("g" "Guru summary" plain "%?" :target
         (file+head
           "guru/%<%Y%m%d>-${slug}.org"
           "#+TITLE: ${title}
#+ROAM_ALIASES:
#+FILETAGS:
#+CREATED: %t
#+LAST_MODIFIED: %U\n \n
- tags :: \n \n") :unnarrowed t)

       ("c" "Course summary" plain "%?" :target
         (file+head
           "course/%<%Y%m%d>-${slug}.org"
           "#+TITLE: ${title}
#+ROAM_ALIASES:
#+FILETAGS:
#+CREATED: %t
#+LAST_MODIFIED: %U\n \n
- tags :: \n \n") :unnarrowed t)

       ("b" "Book summary" plain "%?" :target
         (file+head
           "book/%<%Y%m%d>-${slug}.org"
           "#+TITLE: ${title}
#+ROAM_ALIASES:
#+FILETAGS:
#+CREATED: %t
#+LAST_MODIFIED: %U\n \n
- tags ::
- author ::
- recommended-by ::
- progress-status :: ") :unnarrowed t)

       ("a" "Article summary" plain "%?" :target
         (file+head
           "article/%<%Y%m%d>-${slug}.org"
           "#+TITLE: ${title}
#+ROAM_ALIASES:
#+FILETAGS:
#+CREATED: %t
#+LAST_MODIFIED: %U\n \n
- tags ::
- author ::
- progress-status :: ") :unnarrowed t)

       ("t" "Topic" plain "%?" :target
         (file+head
           "topic/%<%Y%m%d>-${slug}.org"
           "#+TITLE: ${title}
#+ROAM_ALIASES:
#+FILETAGS:
#+CREATED: %t
#+LAST_MODIFIED: %U\n \n
- tags :: ") :unnarrowed t)

       ("p" "Programming" plain "%?" :target
         (file+head
           "programming/%<%Y%m%d>-${slug}.org"
           "#+TITLE: ${title}
#+ROAM_ALIASES:
#+FILETAGS:
#+CREATED: %t
#+LAST_MODIFIED: %U\n \n
- tags :: ") :unnarrowed t)

       ("r" "Travel" plain "%?" :target
         (file+head
           "travel/%<%Y%m%d>-${slug}.org"
           "#+TITLE: ${title}
#+ROAM_ALIASES:
#+CREATED: %t
#+LAST_MODIFIED: %U
#+FILETAGS: \n \n
- tags :: ") :unnarrowed t)

       ("u" "Business" plain "%?" :target
         (file+head
           "business/%<%Y%m%d>-${slug}.org"
           "#+TITLE: ${title}
#+ROAM_ALIASES:
#+CREATED: %t
#+LAST_MODIFIED: %U
#+FILETAGS: \n \n
- tags :: ") :unnarrowed t)

       ("m" "Marketing" plain "%?" :target
         (file+head
           "marketing/%<%Y%m%d>-${slug}.org"
           "#+TITLE: ${title}
#+ROAM_ALIASES:
#+CREATED: %t
#+LAST_MODIFIED: %U
#+FILETAGS: \n \n
- tags :: ") :unnarrowed t)

       ("r" "Web" plain "%?" :target
         (file+head
           "website/%<%Y%m%d>-${slug}.org"
           "#+TITLE: ${title}
#+ROAM_ALIASES:
#+CREATED: %t
#+LAST_MODIFIED: %U
#+FILETAGS: \n \n
- tags :: ") :unnarrowed t)
       ))

  ;; (defun my/org-roam-find-file-other-window (&rest args)
  ;;   (interactive)
  ;;   (let ((org-roam-find-file-function #'find-file-other-window))
  ;;     (apply #'org-roam-find-file args)))

  (defun my/org-roam-node-find-other-window (&rest args)
    (interactive)
    (let ((org-roam-find-file-function #'find-file-other-window))
      (apply #'org-roam-node-find args)))

  ;; faces
  ;; org-roam-link
  ;; org-roam-link-current


  ;; (defvar my/org-roam-side-mode-map (make-sparse-keymap)
  ;;   "Keymap for `my/org-roam-side-mode'.")

  ;; (define-minor-mode my/org-roam-side-mode
  ;;   "Minor mode for org-roam side org buffer."
  ;;   :init-value nil
  ;;   :keymap my/org-roam-side-mode-map)

  ;; (defvar my/org-roam-mode-map (make-sparse-keymap)
  ;;   "Keymap for `my/org-roam-side-mode'.")

  ;; (define-minor-mode my/org-roam-mode
  ;;   "Minor mode for org-roam org buffers."
  ;;   :init-value nil
  ;;   :keymap my/org-roam-mode-map)

  ;; (defun my/org-roam-mode-hook-org-ram ()
  ;;   (when (string-prefix-p my/org-roam-directory buffer-file-name)
  ;;     (my/org-roam-mode 1))
  ;;   (when (string-equal (buffer-name) "*org-roam*")
  ;;     (my/org-roam-side-mode 1)))

  ;; (add-hook 'org-mode-hook 'my/org-roam-mode-hook-org-ram)


  ;; (add-hook 'after-init-hook 'org-roam-mode)

  (when (fboundp 'org-roam-dailies-today)
    (org-roam-dailies-today))

  (defalias 'roam #'org-roam))

(use-package websocket
  :after org-roam-ui)

(use-package org-roam-ui
  :after org-roam
  :commands org-roam-ui-open
  :config
  (setq
    org-roam-ui-sync-theme t
    org-roam-ui-follow t
    org-roam-ui-update-on-save t
    org-roam-ui-open-on-start t))

;; (use-package org-roam-server
;;   :after org-roam
;;   :config
;;   (setq org-roam-server-host "127.0.0.1")
;;   (setq org-roam-server-port 3333)
;;   (setq org-roam-server-export-inline-images t)
;;   (setq org-roam-server-authenticate nil)
;;   (setq org-roam-server-network-poll t)
;;   (setq org-roam-server-network-arrows nil)
;;   (setq org-roam-server-network-label-truncate t)
;;   (setq org-roam-server-network-label-truncate-length 60)
;;   (setq org-roam-server-network-label-wrap-length 20))

;;--------------------------
;; Handling file properties for CREATED & LAST_MODIFIED
;;--------------------------
(defun zp/org-find-time-file-property (property &optional anywhere)
  "Return the position of the time file PROPERTY if it exists.
When ANYWHERE is non-nil, search beyond the preamble."
  (save-excursion
    (goto-char (point-min))
    (let ((first-heading
            (save-excursion
              (re-search-forward org-outline-regexp-bol nil t))))
      (when (re-search-forward (format "^#\\+%s:" property)
              (if anywhere nil first-heading)
              t)
        (point)))))

(defun zp/org-has-time-file-property-p (property &optional anywhere)
  "Return the position of time file PROPERTY if it is defined.
As a special case, return -1 if the time file PROPERTY exists but
is not defined."
  (when-let ((pos (zp/org-find-time-file-property property anywhere)))
    (save-excursion
      (goto-char pos)
      (if (and (looking-at-p " ")
            (progn (forward-char)
              (org-at-timestamp-p 'lax)))
        pos
        -1))))

(defun zp/org-set-time-file-property (property &optional anywhere pos)
  "Set the time file PROPERTY in the preamble.
When ANYWHERE is non-nil, search beyond the preamble.
If the position of the file PROPERTY has already been computed,
it can be passed in POS."
  (when-let ((pos (or pos
                    (zp/org-find-time-file-property property))))
    (save-excursion
      (goto-char pos)
      (if (looking-at-p " ")
        (forward-char)
        (insert " "))
      (delete-region (point) (line-end-position))
      (let* ((now (format-time-string "[%Y-%m-%d %a %H:%M]")))
        (insert now)))))

(defun zp/org-set-last-modified ()
  "Update the LAST_MODIFIED file property in the preamble."
  (when (and (derived-mode-p 'org-mode) (string-prefix-p my/org-roam-directory buffer-file-name))
    (zp/org-set-time-file-property "LAST_MODIFIED")))

(add-hook 'before-save-hook #'zp/org-set-last-modified 50)

(use-package org-journal
  :after org-roam
  :custom
  (org-journal-dir my/org-roam-journal-directory)
  (org-journal-date-format "%Y-%m-%d")
  :config
  (unbind-key "C-c C-j"))

(defun my/org-link-copy (&optional arg)
  "Extract URL from org-mode link and add it to kill ring."
  (interactive "P")
  (let* ((link (org-element-lineage (org-element-context) '(link) t))
          (type (org-element-property :type link))
          (url (org-element-property :path link))
          (url (concat type ":" url)))
    (kill-new url)
    (message (concat "Copied URL: " url))))

(defun my/org-roam-dailies-find-date-other-window ()
  (interactive)
  (let ((current (current-buffer)))
    (org-roam-dailies-find-date)
    (let ((dailies-buffer (current-buffer)))
      (switch-to-buffer current)
      (switch-to-buffer-other-window dailies-buffer))))

(bind-key "C-x C-l" 'my/org-link-copy org-mode-map)

;; (eval-after-load 'bibtex
;;   '(progn
;;       (setq bibtex-autokey-year-length 4)
;;       (setq bibtex-autokey-name-year-separator "-")
;;       (setq bibtex-autokey-year-title-separator "-")
;;       (setq bibtex-autokey-titleword-separator "-")
;;       (setq bibtex-autokey-titlewords 2)
;;       (setq bibtex-autokey-titlewords-stretch 1)
;;       (setq bibtex-autokey-titleword-length 5)
;;      ))

;; (use-package org-ref
;;   :config
;;   (require 'org-ref-pdf)
;;   (require 'org-ref-url-utils)
;;   (setq org-ref-completion-library 'org-ref-ivy-cite)

;;   (setq org-ref-bibliography-notes "~/Documents/bibliography/notes.org")
;;   (setq org-ref-default-bibliography '("~/Documents/bibliography/references.bib"))
;;   (setq org-ref-pdf-directory "~/Documents/bibliography/bibtex-pdfs/")

;;   (unless (file-exists-p org-ref-pdf-directory)
;;     (make-directory org-ref-pdf-directory t))
;;   )

;; (setq org-latex-pdf-process
;;       '("pdflatex -interaction nonstopmode -output-directory %o %f"
;; 	"bibtex %b"
;; 	"pdflatex -interaction nonstopmode -output-directory %o %f"
;; 	"pdflatex -interaction nonstopmode -output-directory %o %f"))

;; (setq org-latex-default-packages-alist
;;   (-remove-item
;;     '("" "hyperref" nil)
;;     org-latex-default-packages-alist))

;; https://emacs.stackexchange.com/a/48385/18445
(defun my/print-duplicate-headings ()
  "Print duplicate headings from the current org buffer."
  (interactive)
  (with-output-to-temp-buffer "*temp-out*"
    (let ((header-list '())) ; start with empty list
      (org-element-map (org-element-parse-buffer) 'headline
        (lambda (x)
          (let ((header (org-element-property :raw-value x)))
            (when (-contains? header-list header)
              (princ header)
              (terpri))
            (push header header-list)))))))

(straight-use-package
  '(org-link-archive :host github :repo "adamWithF/org-link-archive" :branch "main"))
(require 'org-link-archive)

;; TODO
;; wylaczyc skrot klawiszowy

;; Fixes problem with void function org-clocking-buffer
(defun org-clocking-buffer ())

;; This is an Emacs package that creates graphviz directed graphs from
;; the headings of an org file
(use-package org-mind-map
  :init
  (require 'ox-org)
  ;; :ensure t
  ;; Uncomment the below if 'ensure-system-packages` is installed
  ;;:ensure-system-package (gvgen . graphviz)
  :config
  (setq org-mind-map-engine "dot")       ; Default. Directed Graph
  ;; (setq org-mind-map-engine "neato")  ; Undirected Spring Graph
  ;; (setq org-mind-map-engine "twopi")  ; Radial Layout
  ;; (setq org-mind-map-engine "fdp")    ; Undirected Spring Force-Directed
  ;; (setq org-mind-map-engine "sfdp")   ; Multiscale version of fdp for the layout of large graphs
  ;; (setq org-mind-map-engine "twopi")  ; Radial layouts
  ;; (setq org-mind-map-engine "circo")  ; Circular Layout
  )

(provide 'my-org)
