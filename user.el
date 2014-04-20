;; This is where your customizations should live

;; env PATH
(defun set-exec-path-from-shell-PATH ()
  (let ((path-from-shell (shell-command-to-string "$SHELL -i -c 'echo $PATH'")))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))

;; Default window size when emacs is opened
(setq initial-frame-alist '((top . 0) (left . 0) (width . 157) (height . 43)))

;; Place downloaded elisp files in this directory. You'll then be able
;; to load them.
;;
;; For example, if you download yaml-mode.el to ~/.emacs.d/vendor,
;; then you can add the following code to this file:
;;
;; (require 'yaml-mode)
;; (add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
;; 
;; Adding this code will make Emacs enter yaml mode whenever you open
;; a .yml file
(add-to-list 'load-path "~/.emacs.d/vendor")

;; Replace initial scratch message
(setq initial-scratch-message "...")

;; shell scripts
(setq-default sh-basic-offset 2)
(setq-default sh-indentation 2)

;; some installed themes are at https://github.com/owainlewis/emacs-color-themes
;; Themes
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(add-to-list 'load-path "~/.emacs.d/themes")

;; Set font size. The value is in 1/10pt, so 100 will give you 10pt, etc.
(set-face-attribute 'default nil :height 130)

;; theme
(load-theme 'spolsky t)

;; enable powerline
(powerline-center-theme)

;; Enable clipboard interoperability
(setq x-select-enable-clipboard t)

(delete-selection-mode 1)

;; set scheme version for run-scheme command
(set-variable (quote scheme-program-name) "/usr/local/bin/mit-scheme")

;; Set system font based on OS
(if (eq system-type 'darwin)
    (set-default-font "Monaco")
    (set-default-font "Inconsolata"))

;; Flyspell Often Slows Down editing so it's turned off
(remove-hook 'text-mode-hook 'turn-on-flyspell)

;; Clojure
(add-to-list 'auto-mode-alist '("\\.edn$" . clojure-mode))
(setq nrepl-history-file "~/.emacs.d/nrepl-history")
(setq nrepl-popup-stacktraces t)
(setq nrepl-popup-stacktraces-in-repl t)
(add-hook 'nrepl-connected-hook
          (defun pnh-clojure-mode-eldoc-hook ()
            (add-hook 'clojure-mode-hook 'turn-on-eldoc-mode)
            (add-hook 'nrepl-interaction-mode-hook 'nrepl-turn-on-eldoc-mode)
            (nrepl-enable-on-existing-clojure-buffers)))
(add-hook 'nrepl-mode-hook 'subword-mode)
(eval-after-load "auto-complete"
  '(add-to-list 'ac-modes 'nrepl-mode))
(add-hook 'nrepl-mode-hook 'ac-nrepl-setup)

;; hippie expand - don't try to complete with file names
(setq hippie-expand-try-functions-list (delete 'try-complete-file-name hippie-expand-try-functions-list))
(setq hippie-expand-try-functions-list (delete 'try-complete-file-name-partially hippie-expand-try-functions-list))

(setq ido-use-filename-at-point nil)

;; Save here instead of littering current directory with emacs backup files
(setq backup-directory-alist `(("." . "~/.saves")))

;; activate emacs electric indent mode
(electric-indent-mode 1)

;; Set hippie expand to M-spc instead of the default M-/
(global-set-key "\M- " 'hippie-expand)

;; C indentation

;; my changes
(setq c-default-style "linux" c-basic-offset 4)

;; ;; from wiki
(setq-default c-indent-tabs-mode t     ; Pressing TAB should cause indentation
              c-indent-level 4         ; A TAB is equivilent to four spaces
              c-argdecl-indent 0       ; Do not indent argument decl's extra
              c-tab-always-indent t
              backward-delete-function nil) ; DO NOT expand tabs when
                                ; deleting

(c-add-style "my-c-style" '((c-continued-statement-offset 4))) ; If a
                                        ; statement continues on the
                                        ; next line, indent the
                                        ; continuation by 4

(defun my-c-mode-hook ()
  (c-set-style "my-c-style")
;;   (c-set-offset 'substatement-open '0) ; brackets should be at same indentation level as the statements they open
  (c-set-offset 'inline-open '+)
  (c-set-offset 'block-open '+)
;;   (c-set-offset 'brace-list-open '+)   ; all "opens" should be indented by the c-indent-level
  (c-set-offset 'case-label '+))       ; indent case labels by c-indent-level, too
(add-hook 'c-mode-hook 'my-c-mode-hook)
(add-hook 'c++-mode-hook 'my-c-mode-hook)


;; Autopair https://github.com/capitaomorte/autopair
(require 'autopair)
(autopair-global-mode) ;; enable autopair in all buffers

;; toggles the windows when two windows are split
;; taken from the Emacs rocks guy's blog
(defun rotate-windows ()
  "Rotate your windows"
  (interactive)
  (cond ((not (> (count-windows)1))
         (message "You can't rotate a single window!"))
        (t
         (setq i 1)
         (setq numWindows (count-windows))
         (while  (< i numWindows)
           (let* (
                  (w1 (elt (window-list) i))
                  (w2 (elt (window-list) (+ (% i numWindows) 1)))

                  (b1 (window-buffer w1))
                  (b2 (window-buffer w2))

                  (s1 (window-start w1))
                  (s2 (window-start w2))
                  )
             (set-window-buffer w1  b2)
             (set-window-buffer w2 b1)
             (set-window-start w1 s2)
             (set-window-start w2 s1)
             (setq i (1+ i)))))))

;; makes renaming the file open in the current buffer much easier
;; taken from the Emacs Rocks guy's blog
(defun rename-current-buffer-file ()
  "Renames current buffer and file it is visiting."
  (interactive)
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (let ((new-name (read-file-name "New name: " filename)))
        (if (get-buffer new-name)
            (error "A buffer named '%s' already exists!" new-name)
          (rename-file filename new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil)
          (message "File '%s' successfully renamed to '%s'"
                   name (file-name-nondirectory new-name)))))))

(global-set-key (kbd "C-x C-r") 'rename-current-buffer-file)


;; Functions for opening lines below and above the current line.
;; Makes opening a line mid-sentence much easier.
;; Taken from the Emacs Rocks guy's blog
(defun open-line-below ()
  (interactive)
  (end-of-line)
  (newline)
  (indent-for-tab-command))

(defun open-line-above ()
  (interactive)
  (beginning-of-line)
  (newline)
  (forward-line -1)
  (indent-for-tab-command))

(global-set-key (kbd "<C-return>") 'open-line-below)
(global-set-key (kbd "<C-S-return>") 'open-line-above)

;; toggles the window split from verticle to horizontal and vice versa
;; taken from the Emacs Rocks guy's blog
(defun toggle-window-split ()
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

;; binds toggle-window-split to C-c w
(global-set-key (kbd "C-c w") 'toggle-window-split)

;; Io Mode
(require 'io-mode)
(add-to-list 'auto-mode-alist '("\\.io$" . io-mode))

;; scroll one line at a time
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time
;; (setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling

;; disable auto-fill-mode by default
(auto-fill-mode -1)

;; enable expand-region
(global-set-key (kbd "C-=") 'er/expand-region)

;; change tab-to-tab-stop from default M-i to C-c i
(global-set-key (kbd "C-c i") 'tab-to-tab-stop)

;; change back-to-indentation from M-m to M-i
(global-set-key (kbd "M-i") 'back-to-indentation)

;; set iy-go-to-char to M-m
(global-set-key (kbd "M-m") 'iy-go-to-char)

;; A small minor mode to use a big fringe
(defvar bzg-big-fringe-mode nil)
(define-minor-mode bzg-big-fringe-mode
  "Minor mode to hide the mode-line in the current buffer."
  :init-value nil
  :global t
  :variable bzg-big-fringe-mode
  :group 'editing-basics
  (if (not bzg-big-fringe-mode)
      (set-fringe-style nil)
    (set-fringe-mode
     (/ (- (frame-pixel-width)
           (* 100 (frame-char-width)))
        2))))

;; Now activate this global minor mode
(bzg-big-fringe-mode 0)

;; colors for code in org-mode
(setq org-src-fontify-natively t)

;; org mode visual line mode and auto fill hooks
(add-hook 'org-mode-hook
          (lambda ()
            (visual-line-mode t)
            (auto-fill-mode -1)))

;; Vertical ido-mode
(require 'ido-vertical-mode)
(ido-mode 1)
(ido-vertical-mode 1)

;; Ignore buffers with ido
(ido-mode 'buffers) ;; only use this line to turn off ido for file names!
(setq ido-ignore-buffers '("^ " "*Completions*" "*Shell Command Output*"
               "*Messages*" "Async Shell Command" "*Compile-Log*" "*Buffer List"))


(ido-mode 1)
(ido-everywhere 1)
(flx-ido-mode 1)

;; disable ido faces to see flx highlights.
;; (setq ido-use-faces nil)

