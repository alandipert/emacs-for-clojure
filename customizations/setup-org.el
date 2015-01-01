;; org settings

(define-key global-map "\C-ca" 'org-agenda)
(setq org-hide-leading-stars t
      org-src-window-setup 'current-window
      org-todo-keywords (quote ((sequence "TODO" "ONGOING" "DONE")))
      org-todo-keyword-faces
      '(("ONGOING" . "orange")))
