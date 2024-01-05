;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Roni Kettunen"
      user-mail-address "Roni Kettunen")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "Fira Code" :size 21 :weight 'medium)
      doom-variable-pitch-font (font-spec :family "sans" :size 22))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-gruvbox)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; This easiers buffer switching
(global-set-key (kbd "C-M-h") 'counsel-switch-buffer)

(map! :after evil
      :gn "C-+" #'doom/increase-font-size
      :gn "C-<kp-equal>" #'doom/reset-font-size)

;; This makes buffer switching work "correctly"
(setq doom-unreal-buffer-functions '(minibufferp))

;; This fulscreens the window
(toggle-frame-fullscreen)

;; This sets projectile path
(setq projectile-project-search-path '("~/Code"))
(setq projectile-auto-discover t)

;; This is a dotnet CLI wrapper
(use-package! sharper
  :init
  (map! :leader :prefix ("o" . "open")
        :desc "sharper" "s" #'sharper-main-transient))

(use-package! protobuf-mode)

(use-package! nasm-mode)
(add-to-list 'auto-mode-alist '("\\.asm\\'" . nasm-mode))

(require 'dap-netcore)

;; SQL stuff
(require 'ejc-sql)
(require 'ejc-company)
(defun k/ejc-after-ejc-mode-hook ()
  (add-to-list 'company-backend 'ejc-company-backend)
  ;; In case of `company-mode' is used by default this can be useful:
  ;; (company-quickhelp-mode)
  )

(add-hook 'ejc-sql-mode-hook 'k/ejc-after-ejc-mode-hook)

(add-hook 'ejc-sql-minor-mode-hook
          (lambda ()
            (company-mode t)))
(setq ejc-completion-system 'standard)

(defhydra my-mc-hydra (:color pink
                       :hint nil
                       :pre (evil-mc-pause-cursors))
  "
^Match^            ^Line-wise^           ^Manual^
^^^^^^----------------------------------------------------
_g_: match all     _J_: make & go down   _o_: toggle here
_m_: make & next   _K_: make & go up     _r_: remove last
_M_: make & prev   ^ ^                   _R_: remove all
_n_: skip & next   ^ ^                   _p_: pause/resume
_N_: skip & prev

Current pattern: %`evil-mc-pattern

"
  ("g" #'evil-mc-make-all-cursors)
  ("m" #'evil-mc-make-and-goto-next-match)
  ("M" #'evil-mc-make-and-goto-prev-match)
  ("n" #'evil-mc-skip-and-goto-next-match)
  ("N" #'evil-mc-skip-and-goto-prev-match)
  ("J" #'evil-mc-make-cursor-move-next-line)
  ("K" #'evil-mc-make-cursor-move-prev-line)
  ("o" #'+multiple-cursors/evil-mc-toggle-cursor-here)
  ("r" #'+multiple-cursors/evil-mc-undo-cursor)
  ("R" #'evil-mc-undo-all-cursors)
  ("p" #'+multiple-cursors/evil-mc-toggle-cursors)
  ("q" #'evil-mc-resume-cursors "quit" :color blue)
  ("<escape>" #'evil-mc-resume-cursors "quit" :color blue))

(map!
 (:when (featurep! :editor multiple-cursors)
   :prefix "g"
   :nv "o" #'my-mc-hydra/body))

(setq! coding-system-for-write 'utf-8-emacs-unix)

(setq inferior-fsharp-program "/usr/bin/fsharpi --readline-")

;; Set modeline font smaller to fit.
(setq doom-modeline-height 1)
(custom-set-faces
 '(mode-line ((t (:family "Fira Code" :height 0.62))))
 '(mode-line-active ((t (:family "Fira Code" :height 0.62)))) ; For 29+
 '(mode-line-inactive ((t (:family "Fira Code" :height 0.62)))))

(let ((ligatures-to-disable '(:true :false :int :float :str :bool :list :lambda :function)))
  (dolist (sym ligatures-to-disable)
    (plist-put! +ligatures-extra-symbols sym nil)))

;; If auto formating is annoying :
;; To enable it, just eval it M-:
;; (add-hook! 'before-save-hook #'+format/buffer)
;; (remove-hook! 'before-save-hook #'+format/buffer)
;; (remove-hook! 'before-save-hook #'ws-butler-before-save)
(add-hook! 'haskell-mode
  (format-all-mode -1))

;; (after! lsp-haskell
;;   (setq lsp-haskell-formatting-provider "brittany"))
;; (add-to-list '+format-on-save-enabled-modes 'haskell-mode)
(setenv "PATH" (concat (getenv "PATH") ":/home/roni/.ghcup/bin/"))
(setq exec-path (append exec-path '("/home/roni/.ghcup/bin/")))

(defun ap/load-doom-theme (theme)
  "Disable active themes and load a Doom theme."
  (interactive (list (intern (completing-read "Theme: "
                                              (->> (custom-available-themes)
                                                   (-map #'symbol-name)
                                                   (--select (string-prefix-p "doom-" it)))))))
  (ap/switch-theme theme)

  (set-face-foreground 'org-indent (face-background 'default)))

(defun ap/switch-theme (theme)
  "Disable active themes and load THEME."
  (interactive (list (intern (completing-read "Theme: "
                                              (->> (custom-available-themes)
                                                   (-map #'symbol-name))))))
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme theme 'no-confirm))

(use-package! lsp-tailwindcss
  :init
  (setq lsp-tailwindcss-add-on-mode t))

;; harpoon
(setq harpoon-project-package '+workspace-current-name)
(setq harpoon-without-project-function '+workspace-current-name)
(map! "C-1" 'harpoon-go-to-1
      "C-2" 'harpoon-go-to-2
      "C-3" 'harpoon-go-to-3
      "C-4" 'harpoon-go-to-4
      "C-5" 'harpoon-go-to-5
      ;; TODO: fix this.
      ;; "C-6" 'harpoon-go-to-6
      "C-7" 'harpoon-go-to-7
      "C-8" 'harpoon-go-to-8
      "C-9" 'harpoon-go-to-9
      "C-0" 'harpoon-clear

      ;; Alternative for faster changing.
      "C-k" 'harpoon-go-to-1
      "C-j" 'harpoon-go-to-2
      "C-q" 'harpoon-go-to-3
      "C-'" 'harpoon-go-to-4

      :leader "a" 'harpoon-add-file)

(defun entry-or-exit-harpoon ()
  (interactive)
  (if (eq major-mode 'harpoon-mode)
      (progn
        (basic-save-buffer)
        (+popup/close))
    (harpoon-toggle-file)
    (+popup/buffer)))
(map! :leader "u" #'entry-or-exit-harpoon)

;; workspace
(map! :nvig "C-<tab>" #'+workspace/switch-right)
(map! :nvig "C-<iso-lefttab>" #'+workspace/switch-left)

;; magit
(map! :nvg "M-g" #'magit-status)

;; compile
(map! :nvg "C-M-c" #'+ivy/project-compile)

(defun compile-maximize ()
  "Execute a compile command from the current project's root and maximizes window."
  (interactive)
  (recompile)
  (doom/window-maximize-buffer))

(map! :nvg "M-C" #'compile-maximize)

;; csharp
;; (defun +csharp/open-repl ()
;;   (interactive)
;;   (call-interactively #'+vterm/here)
;;   (run-with-idle-timer 1 nil (lambda () (insert "acsharprepl\n")))
;;   (current-buffer)
;;   )

;; (defun start-csharp-repl-vterm ()
;;   "Start a C# REPL using csharepl in vterm."
;;   (interactive)
;;   (let* ((vterm-buffer-name "*vterm-csharp*")
;;          (default-directory default-directory))
;;     (unless (get-buffer vterm-buffer-name)
;;       (vterm vterm-buffer-name))
;;     (with-current-buffer vterm-buffer-name
;;       (vterm-send-string (concat "csharprepl " (buffer-file-name) "\n")))))

;; (after! csharp-mode
;;   (set-repl-handler! 'csharp-mode #'start-csharp-repl-buffer))

(set-ligatures! 'csharp-mode
  :for "foreach")

;; eww
(defun my-eww-beautify-source ()
  "Beautify HTML source in eww-view-source buffer."
  (interactive)
  (eww-view-source)
  (when (eq major-mode 'mhtml-mode)
    (setq buffer-read-only nil)
    (web-beautify-html)
    (setq buffer-read-only t)
    (message "Beautified HTML source in eww-view-source buffer.")))

(defun eww-open-dev-server ()
  "Open EWW browser for localhost:6969."
  (interactive)
  (eww "http://localhost:6969/")
  (call-interactively #'+popup/raise))

(map! :leader
      (:prefix ("o" . "open")
       :desc "Open localhost:6969 in EWW" "w" #'eww-open-dev-server))

(after! eww
  (map! :map eww-mode-map
        :n "B" #'my-eww-beautify-source
        :n "r" #'eww-reload))

;; clojure
(defun eval-surrounding-or-next-closure ()
  "Evaluates surrounding closure if found, otherwise the next closure."
  (interactive)
  (save-excursion
    (let ((original-point (point)))
      (evil-visual-char)
      (call-interactively #'evil-a-paren)
      (call-interactively #'+eval:region)
      (goto-char original-point))))

(map! :leader "e" #'eval-surrounding-or-next-closure)

(defun cider-repl-new-buffer ()
  "Wrapper for `cider-jack-in-clj' that avoids splitting the window."
  (interactive)
  (+eval/open-repl-same-window)
  (switch-to-buffer (other-buffer)))

(after! cider
  (map! :leader
        (:prefix ("o" . "open")
         :desc "Open repl in new buffer" "r" #'cider-repl-new-buffer)
        "l" #'cider-load-buffer
        "y" #'cider-kill-last-result))

;; (defun wrap-closure-insert ()
;;   "Wraps the surrounding closure with new paranthesis and starts inserting."
;;   (interactive)
;;   (evil-visual-char)
;;   (call-interactively #'evil-a-paren)
;;   (call-interactively #'evil-surround-region))

(defun wrap-closure-insert ()
  "Wraps the surrounding closure with new parentheses and starts inserting."
  (interactive)
  (evil-visual-char)
  (call-interactively #'evil-a-paren)
  (evil-surround-region (region-beginning) (region-end) ?\( ?\))
  (evil-insert 1)
  (evil-forward-char))

(map! "C-)" #'wrap-closure-insert)

;; doom
(defun open-doom-scratch-buffer-maximized ()
  "Open or close the *doom:scratch* buffer and maximize it."
  (interactive)
  (if (get-buffer-window "*doom:scratch*")
      (switch-to-buffer (other-buffer))
    (doom/open-scratch-buffer)
    (call-interactively #'+popup/raise)))

(map! :leader "x" #'open-doom-scratch-buffer-maximized)

;;
;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
