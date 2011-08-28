;; 2 spaces tabs
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq indent-line-function 'insert-tab)

(set-scroll-bar-mode 'nil)
(global-font-lock-mode 1)

;; Don't truncate lines in any windows.
(setq truncate-partial-width-windows nil)

;; Global shortcut keys for compiling and running programs.
(setq compile-command "make -k -j")
(global-set-key [f6] 'compile)
(global-set-key [f5] 'shell-command)
(setq compilation-scroll-output "first-error")
(set-face-attribute 'default nil :height 90)

;; Emacs Load Path
(add-to-list 'load-path "~/emacs/color-theme-6.6.0")
(add-to-list 'load-path "~/emacs/color-theme-6.6.0/themes")
(add-to-list 'load-path "~/emacs/revbufs")

;; Hide menu bar and file menu bar
(tool-bar-mode -1)
(menu-bar-mode 0)

;; stop forcing me to spell out "yes"
(fset 'yes-or-no-p 'y-or-n-p) 

;; Set font colors
(require 'color-theme)
(color-theme-initialize)
(color-theme-empty-void)

(custom-set-variables
 '(inhibit-startup-screen t))
(custom-set-faces)

(put 'upcase-region 'disabled nil)

;; Sets up file-type dependent templates
(require 'autoinsert)
(auto-insert-mode)
(setq auto-insert-directory "~/emacs/autoinsert/templates/")
(define-auto-insert "\.tex" "texTemplate.tex")
(define-auto-insert "\.pl"  "perlTemplate.pl")

;; Control F5 should run rev-buffers
(require 'revbufs)
(global-set-key [C-f5] 'revbufs)

;; C-S-o now moves backward one window
(global-set-key "\C-xO" (lambda() (interactive) (other-window -1)))

;;Sets some stuff for org-mode
(require 'org-install)
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)

;; Auto load .lua files in lua-mode
(autoload 'lua-mode "lua-mode" "Lua editing mode." t)
(add-to-list 'auto-mode-alist '("\\.lua$" . lua-mode))
(add-to-list 'interpreter-mode-alist '("lua" . lua-mode))
