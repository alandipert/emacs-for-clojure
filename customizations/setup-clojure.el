;;;;
;; Clojure
;;;;

;; Enable paredit for Clojure
(add-hook 'clojure-mode-hook 'enable-paredit-mode)

;; This is useful for working with camel-case tokens, like names of
;; Java classes (e.g. JavaClassName)
(add-hook 'clojure-mode-hook 'subword-mode)

;; yay rainbows!
(add-hook 'clojure-mode-hook 'rainbow-delimiters-mode)

;; A little more syntax highlighting
(require 'clojure-mode-extra-font-locking)

;;;;
;; Cider
;;;;

;; provides minibuffer documentation for the code you're typing into the repl
(add-hook 'cider-mode-hook 'cider-turn-on-eldoc-mode)

;; go right to the REPL buffer when it's finished connecting
(setq cider-repl-pop-to-buffer-on-connect t)

;; When there's a cider error, show its buffer and switch to it
(setq cider-show-error-buffer t)
(setq cider-auto-select-error-buffer t)

;; Where to store the cider history.
(setq cider-repl-history-file "~/.emacs.d/cider-history")

;; Wrap when navigating history.
(setq cider-repl-wrap-history t)

;; enable paredit in your REPL
(add-hook 'cider-repl-mode-hook 'paredit-mode)

;; Use clojure mode for other extensions

(defvar clojure-extensions
  '("\\.edn$" "\\.boot$" "\\.cljs.*$"))

(dolist (extension clojure-extensions)
  (add-to-list 'auto-mode-alist (cons extension 'clojure-mode)))

;; key bindings, boot-centric

(defun cider-boot-user-ns ()
  (interactive)
  (cider-repl-set-ns "boot.user"))

(eval-after-load 'cider
  '(progn
     (define-key clojure-mode-map (kbd "C-c u") 'cider-boot-user-ns)
     (define-key cider-mode-map (kbd "C-c u") 'cider-user-ns)))

;; run a little Clojure REPL

(defcustom clj-dir "/home/alan/projects/clojure"
  "Path to Clojure source directory."
  :type 'string
  :group 'cljrepl)

(defun cljrepl ()
  "Launch a Clojure REPL."
  (interactive)
  (let ((clj-jar (concat clj-dir "/clojure.jar")))
    (if (file-exists-p clj-jar)
        (inferior-lisp (concat "java -cp " clj-jar " clojure.main"))
      (when (yes-or-no-p "clojure.jar not found.  Build?")
        (if (shell-command (concat "cd " clj-dir " && ant"))
            (cljrepl)
          (message "Building Clojure failed."))))))

;; hlisp

(setq html5-elements
      '(a abbr acronym address applet area article aside audio b base basefont
        bdi bdo big blockquote body br button canvas caption center cite code
        col colgroup command data datalist dd del details dfn dir div dl
        dt em embed eventsource fieldset figcaption figure font footer form frame frameset
        h1 h2 h3 h4 h5 h6 head header hgroup hr html i
        iframe img input ins isindex kbd keygen label legend li link html-map
        mark menu html-meta meter nav noframes noscript object ol optgroup
        option output p param pre progress q rp rt ruby
        s p samp script section select small source span strike strong style sub
        summary sup table tbody td textarea tfoot th thead html-time
        title tr track tt u ul html-var video wbr))

(add-hook 'clojurescript-mode-hook
          '(lambda ()
             (dolist (el html5-elements)
               (put-clojure-indent el 'defun))))

;; mvnrepl

(defgroup mvnrepl nil
  "run mvn clojure:repl from emacs"
  :prefix "mvnrepl-"
  :group 'applications)

(defcustom mvnrepl-mvn "mvn"
  "Maven 'mvn' command."
  :type 'string
  :group 'mvnrepl)

(defun mvnrepl-project-root ()
  "Look for pom.xml file to find project root."
  (let ((cwd default-directory)
        (found nil)
        (max 10))
    (while (and (not found) (> max 0))
      (if (file-exists-p (concat cwd "pom.xml"))
          (setq found cwd)
        (setq cwd (concat cwd "../") max (- max 1))))
    (and found (expand-file-name found))))

(defun mvnrepl ()
  "From a buffer with a file in the project open, run M-x mvn-repl to get a project inferior-lisp"
  (interactive)
  (let ((project-root (mvnrepl-project-root)))
    (if project-root
        (inferior-lisp (concat mvnrepl-mvn " -f " project-root "/pom.xml clojure:repl"))
      (message (concat "Maven project not found.")))))

(provide 'mvnrepl)
