(setq package-archives '(("gnu"    . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("nongnu" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
                         ("melpa"  . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))

;;设置mac按键
(setq mac-option-modifier 'meta
      mac-command-modifier 'super)
(global-set-key (kbd "s-a") 'mark-whole-buffer) ;;对应Windows上面的Ctrl-a 全选
(global-set-key (kbd "s-c") 'kill-ring-save) ;;对应Windows上面的Ctrl-c 复制
(global-set-key (kbd "s-s") 'save-buffer) ;; 对应Windows上面的Ctrl-s 保存
(global-set-key (kbd "s-v") 'yank) ;对应Windows上面的Ctrl-v 粘贴
(global-set-key (kbd "s-z") 'undo) ;对应Windows上面的Ctrol-z 撤销
(global-set-key (kbd "s-x") 'kill-region) ;对应Windows上面的Ctrol-x 剪切

;; Font
;; Download Victor Mono at https://rubjo.github.io/victor-mono/
(set-face-attribute 'default nil :height 165 :weight 'normal)
;; (set-face-attribute 'default nil :family "Victor Mono" :height 170 :weight 'normal)

;; 时间显示设置
(display-time-mode 1)   ;; 启用时间显示设置,在minibuffer上面的那个杠上
(setq display-time-24hr-format t   ;; 时间使用24小时制
      display-time-day-and-date t   ;; 时间显示包括日期和具体时间
      display-time-use-mail-icon t   ;; 时间栏旁边启用邮件设置
      display-time-interval 10   ;; 时间的变化频率
      display-time-format "%A %H:%M")   ;; 显示时间的格式
(setq system-time-locale "zh_CN"        ;设置系统时间显示格式
      echo-keystrokes 0.1               ;尽快显示按键序列
      )

;; 笔记本上显示电量
(unless (string-match-p "^Power N/A" (battery))
  (display-battery-mode 1))


(global-auto-revert-mode 1)       ;; 自动重载更改的文件

;;;
(require-package 'use-package)

;; ;;; 进度条
;; (require-package 'nyan-mode)
;; (use-package nyan-mode
;;   :init
;;   (nyan-mode 1))

(require 'org-tempo)

;;; org-roam
(require-package 'org-roam)
(setq my/all-notes "~/notes/")
;; (setq org-roam-database-connector 'sqlite3)
(use-package org-roam
  :ensure t
  :config
  ;; If using org-roam-protocol
  (require 'org-roam-protocol)
  (org-roam-db-autosync-enable)
  :bind
  ("C-c n l" . org-roam-buffer-toggle)
  ("C-c n f" . org-roam-node-find)
  ("C-c n g" . org-roam-graph)
  ("C-c n i" . org-roam-node-insert)
  ("C-c n c" . org-roam-capture)
  ;; Dailies
  ("C-c n j" . org-roam-dailies-capture-today)
  :custom
  (org-roam-v2-ack t)
  (org-roam-directory (string-join (cons my/all-notes '("content-org")) "/"))
  (org-roam-capture-templates `(("d" "default" plain "%?"
                                 :unnarrowed t
                                 :if-new (file+head "%<%Y%m%d%H%M%S>.org"
                                                    "#+TITLE: ${title}
#+AUTHOR: Jun Gao
#+DATE: %U
#+HUGO_BASE_DIR: ~/notes
#+HUGO_SECTION: ch/docs
")))))

(require-package 'org-superstar)
(use-package org-superstar
  :hook
  (org-mode . (lambda () (org-superstar-mode 1))))

(use-package ox-hugo
             :ensure t   ;Auto-install the package from Melpa
             :pin melpa  ;`package-archives' should already have ("melpa" . "https://melpa.org/packages/")
             :after ox)

;; 图片管理
(require-package 'org-download)
(use-package org-download
             :ensure t
             :config
             ;; Drag-and-drop to `dired`
             (add-hook 'dired-mode-hook 'org-download-enable)
             (require 'org-download)
             :custom
             (org-download-method 'directory)
             (org-download-image-dir "~/notes/images")
             (org-download-heading-lvl nil)
             (org-download-timestamp "%Y%m%d-%H%M%S_")
             ;; 将图片显示大小固定位屏幕宽度的三分之一
             (org-image-actual-width (/ (display-pixel-width) 3))
             (org-download-screenshot-method "/usr/local/bin/pngpaste %s")
             :bind
             ("C-M-y" . org-download-screenshot))

;; 文献管理
(require-package 'zotxt)
(eval-after-load "zotxt" '(setq zotxt-default-bibliography-style "ieee"))

;; 删除当前文件
(defun fdx/delete-current-buffer-file ()
  "Removes file connected to current buffer and kills buffer."
  (interactive)
  (let ((filename (buffer-file-name))
        (buffer (current-buffer))
        (name (buffer-name)))
    (if (not (and filename (file-exists-p filename)))
        (ido-kill-buffer)
      (when (yes-or-no-p "Are you sure you want to remove this file? ")
        (delete-file filename)
        (kill-buffer buffer)
        (message "File '%s' successfully removed" filename)))))

;; 改变任务状态关键词
(setq org-todo-keywords
      '((sequence "TODO(t)" "ONGOING(o)" "MAYBE(m)" "WAIT(w)" "DELEGATED(d)" "|"
                  "DONE(f)" "CANCELLED(c)" "STUCK(s)")))

;; 配置全局任务文件清单和快捷键
(setq org-agenda-files (list "~/notes/content-org/"
                             ))
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)
;; 禁用任务组标签继承
(setq org-tags-exclude-from-inheritance '("TG"))

;; Skip entries which only have timestamp but no TODO keywords.
(defun tjh/org-agenda-skip-only-timestamp-entries ()
  (org-agenda-skip-entry-if 'nottodo 'any))

;; Skip entries which are not deadlines.
(defun tjh/org-agenda-skip-not-deadline-entries ()
  (org-agenda-skip-entry-if 'notdeadline))

;; Skip entries which are not finished.
(defun tjh/org-agenda-skip-unfinished-entries ()
  (org-agenda-skip-entry-if 'nottodo '("DONE")))

;; Skip unscheduled entries.
(defun tjh/org-agenda-skip-scheduled-entries ()
  (org-agenda-skip-entry-if 'timestamp
                            'todo '("ONGOING" "WAIT" "DELEGATED")
                            'regexp ":TG:"))

(setq org-agenda-custom-commands
      '(
        ;; Display general agenda for each project.
        ("A" . "Default agenda view")
        ("Aa" "Agenda for all projects"
         agenda ""
         ((org-agenda-skip-function 'tjh/org-agenda-skip-only-timestamp-entries)
          (org-agenda-overriding-header "Agenda for all projects: "))
         "~/notes/content-org/org-html-exports/Agenda-All.html")

        ;; Display all tasks with deadline.
        ("D" . "Agenda view for deadlines")
        ("Da" "Agenda view for all deadlines"
         agenda ""
         ((org-agenda-skip-function 'tjh/org-agenda-skip-not-deadline-entries)
          (org-agenda-overriding-header "All deadlines: "))
         "~/notes/content-org/org-html-exports/Deadline-All.html")

        ;; Display all finished tasks.
        ("F" . "Agenda view for finished tasks")
        ("Fa" "Agenda view for all finished tasks"
         agenda ""
         ((org-agenda-skip-function 'tjh/org-agenda-skip-unfinished-entries)
          (org-agenda-overriding-header "All finished tasks: "))
         "~/notes/content-org/org-html-exports/Done-All.html")

        ;; Inbox for displaying unscheduled tasks.
        ("I" . "Inbox")
        ("Ia" "Inbox for all unfinished TODOs"
         alltodo ""
         ((org-agenda-skip-function 'tjh/org-agenda-skip-scheduled-entries)
          (org-agenda-overriding-header "Inbox items: "))
         "~/notes/content-org/org-html-exports/Inbox-All.html")
        ))

;; elfeed for rss
(require-package 'elfeed)
;;(setq elfeed-feeds '("http://feeds.feedburner.com/zhihu-daily"))
(use-package elfeed
  :ensure t
  :config
  (setq elfeed-db-directory (expand-file-name ".emacs.d/elfeed" user-emacs-directory) )
                                        ;(setq elfeed-db-directory (expand-file-name "elfeed" user-emacs-directory) elfeed-show-entry-switch 'display-buffer)
  (setf url-queue-timeout 30)
  (setq  elfeed-feeds
         ;;(defvar elfeed-feeds-alist
         '(("https://www.zhihu.com/rss" info)
                                        ;("http://feeds.feedburner.com/zhihu-daily" news)
           ("https://planet.emacslife.com/atom.xml" emacs blogs)

           ("https://www.kexue.fm/feed" blogs)

           ("https://api.feeddd.org/feeds/61aa18e9486e3727fb090b4d" research)

           ("https://api.feeddd.org/feeds/6110783449ef7514d0b91ae1" info)   ;;  差评
           ("https://api.feeddd.org/feeds/61aa18e9486e3727fb090ba1" info)   ;;  新智元

           ("https://api.feeddd.org/feeds/61aa18e9486e3727fb090b97" info)   ;;  微软研究院AI头条
           ("http://arxiv.org/rss/cs.CL?mirror=cn" research)   ;; arxiv nlp
           ("http://export.arxiv.org/api/query?search_query=dialogue+reinforcement+AND+cat:cs.CL" research) ;dialogue reinforcement
           ("http://export.arxiv.org/api/query?search_query=cat:cs.LG&start=0&max_results=300&sortBy=submittedDate&sortOrder=descending" research) ;test
           ("https://bbs.byr.cn/rss/board-Advertising" info)


           ))
  :bind
  ("C-x w" . elfeed ))

;; Optionally specify a number of files containing elfeed
;; configuration. If not set then the location below is used.
;; Note: The customize interface is also supported.
;;(setq rmh-elfeed-org-files (list "~/.emacs.d/elfeed.org"))
(require-package 'elfeed-summary)
(setq elfeed-summary-settings
      '(
        (group (:title . "Blogs")
               (:elements
                (query . (and blogs (not emacs)))
                (group (:title . "Emacs")
                       (:elements
                        (query . (and blogs emacs))))))
        (group (:title . "Research")
               (:elements
                (query . research)))
        (group (:title . "Information")
               (:elements
                (query . info)))
        (group (:title . "GitHub")
               (:elements
                (query . (url . "SqrtMinusOne.private.atom"))
                ))
        (group (:title . "Videos")
               (:elements
                (group
                 (:title . "Music")
                 (:elements
                  (query . (and videos music))))
                (group
                 (:title . "Tech")
                 (:elements
                  (query . (and videos tech))))
                ;; ...
                ))
        ;; ...
        (group (:title . "Miscellaneous")
               (:elements
                (group
                 (:title . "Ungrouped")
                 (:elements :misc))))))

;;backlink buffer
;; for org-roam-buffer-toggle
;; Recommendation in the official manual
(add-to-list 'display-buffer-alist
             '("\\*org-roam\\*"
               (display-buffer-in-direction)
               (direction . right)
               (window-width . 0.33)
               (window-height . fit-window-to-buffer)))

;; ;;; 思维导图
;; (add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp/plantuml-emacs"))
;; (require 'plantuml)
;; (setq plantuml-jar-path "~/.emacs.d/lisp/plantuml.jar"
;;       plantuml-output-type "svg"
;;       plantuml-relative-path "~/notes/images/mindmap/"
;;       plantuml-theme "plain"
;;       plantuml-font "somefont"
;;       plantuml-add-index-number t
;;       plantuml-log-command t
;;       plantuml-mindmap-contains-org-content t
;;       plantuml-org-headline-bold t)

;; ;;; 补全或搜索
;; (require-package 'counsel)
;; (use-package counsel
;;   :custom
;;   (counsel-find-file-at-point t)
;;   :init
;;   (counsel-mode +1)
;;   :bind
;;   ;; ("C-x b" . counsel-switch-buffer)
;;   ;;  ("C-c a p" . counsel-ag)
;;   ;; ("M-y" . counsel-yank-pop)
;;   ;; ("M-x" . counsel-M-x)
;;   ;; ("C-x C-f" . counsel-find-file)
;;   ("<f1> f" . counsel-describe-function)
;;   ("<f1> v" . counsel-describe-variable)
;;   ("<f1> o" . counsel-describe-symbol)
;;   ("<f1> l" . counsel-find-library)
;;   ("<f2> i" . counsel-info-lookup-symbol)
;;   ("<f2> u" . counsel-unicode-char)
;;   ("C-c g" . counsel-git)
;;   ;; ("C-c j" . counsel-git-grep)
;;   ("C-c k" . counsel-ag)
;;   ("C-x l" . counsel-locate)
;;   ("C-S-o" . counsel-rhythmbox)
;;   (:map minibuffer-local-map
;;         (("C-r" . counsel-minibuffer-history))))

;;; Tidy workdir
(make-directory "~/.emacs.d/data/backup/" t)
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/data/backup/" t)) ; Write auto-save files to a separate directory
      backup-directory-alist '(("." . "~/.emacs.d/data/backup/"))          ; Write backup files to a separate directory
      create-lockfiles nil                                                 ; Disable lockfiles as I use only one Emacs instance
      )

;;; 自动保存
(setq
 auto-save-default t
 make-backup-files t)

;; ;;; 输入法
;; (require 'pyim)
;; (require 'pyim-basedict)
;; (require 'pyim-cregexp-utils)

;; ;; 如果使用 popup page tooltip, 就需要加载 popup 包。
;; ;; (require 'popup nil t)
;; ;; (setq pyim-page-tooltip 'popup)

;; ;; 如果使用 pyim-dregcache dcache 后端，就需要加载 pyim-dregcache 包。
;; ;; (require 'pyim-dregcache)
;; ;; (setq pyim-dcache-backend 'pyim-dregcache)

;; (pyim-basedict-enable)

;; (setq default-input-method "pyim")

;; ;; 显示5个候选词。
;; (setq pyim-page-length 5)

;; ;; 金手指设置，可以将光标处的编码，比如：拼音字符串，转换为中文。
;; (global-set-key (kbd "M-j") 'pyim-convert-string-at-point)

;; ;; 按 "C-<return>" 将光标前的 regexp 转换为可以搜索中文的 regexp.
;; (define-key minibuffer-local-map (kbd "C-<return>") 'pyim-cregexp-convert-at-point)

;; ;; 我使用全拼
;; (pyim-default-scheme 'quanpin)
;; ;; (pyim-default-scheme 'wubi)
;; ;; (pyim-default-scheme 'cangjie)

;; ;; 我使用云拼音
;; (setq pyim-cloudim 'baidu)

;; ;; pyim 探针设置
;; ;; 设置 pyim 探针设置，这是 pyim 高级功能设置，可以实现 *无痛* 中英文切换 :-)
;; ;; 我自己使用的中英文动态切换规则是：
;; ;; 1. 光标只有在注释里面时，才可以输入中文。
;; ;; 2. 光标前是汉字字符时，才能输入中文。
;; ;; 3. 使用 M-j 快捷键，强制将光标前的拼音字符串转换为中文。
;; ;; (setq-default pyim-english-input-switch-functions
;; ;;               '(pyim-probe-dynamic-english
;; ;;                 pyim-probe-isearch-mode
;; ;;                 pyim-probe-program-mode
;; ;;                 pyim-probe-org-structure-template))

;; ;; (setq-default pyim-punctuation-half-width-functions
;; ;;               '(pyim-probe-punctuation-line-beginning
;; ;;                 pyim-probe-punctuation-after-punctuation))

;; ;; 开启代码搜索中文功能（比如拼音，五笔码等）
;; (pyim-isearch-mode 1)


;; ;;; rime
;; (require 'rime)
;; (use-package rime
;;   :custom
;;   (default-input-method "rime")
;;   (rime-librime-root "~/.emacs.d/librime/dist"))
;; ;; 默认值
;; (setq rime-translate-keybindings
;;       '("C-f" "C-b" "C-n" "C-p" "C-g" "<left>" "<right>" "<up>" "<down>" "<prior>" "<next>" "<delete>"))
;; ;;; 临时英文模式
;; (setq rime-disable-predicates
;;       '(rime-predicate-evil-mode-p
;;         rime-predicate-after-alphabet-char-p
;;         rime-predicate-prog-in-code-p))

;;; 删除模式
(delete-selection-mode 1)

;;; 高亮当前行
(global-hl-line-mode 1)

;; 文献管理
(package-install 'zotxt)
(eval-after-load "zotxt" '(setq zotxt-default-bibliography-style "ieee"))

;;; python
(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)))

;;; beamer
;; allow for export=>beamer by placing

;; #+LaTeX_CLASS: beamer in org files
(unless (boundp 'org-export-latex-classes)
  (setq org-export-latex-classes nil))
(add-to-list 'org-export-latex-classes
             ;; beamer class, for presentations
             '("beamer"
               "\\documentclass[11pt]{beamer}\n
      \\mode<{{{beamermode}}}>\n
      \\usetheme{{{{beamertheme}}}}\n
      \\usecolortheme{{{{beamercolortheme}}}}\n
      \\beamertemplateballitem\n
      \\setbeameroption{show notes}
      \\usepackage[utf8]{inputenc}\n
      \\usepackage[T1]{fontenc}\n
      \\usepackage{hyperref}\n
      \\usepackage{color}
      \\usepackage{listings}
      \\lstset{numbers=none,language=[ISO]C++,tabsize=4,
  frame=single,
  basicstyle=\\small,
  showspaces=false,showstringspaces=false,
  showtabs=false,
  keywordstyle=\\color{blue}\\bfseries,
  commentstyle=\\color{red},
  }\n
      \\usepackage{verbatim}\n
      \\institute{{{{beamerinstitute}}}}\n
       \\subject{{{{beamersubject}}}}\n"

               ("\\section{%s}" . "\\section*{%s}")

               ("\\begin{frame}[fragile]\\frametitle{%s}"
                "\\end{frame}"
                "\\begin{frame}[fragile]\\frametitle{%s}"
                "\\end{frame}")))

;; letter class, for formal letters

(add-to-list 'org-export-latex-classes

             '("letter"
               "\\documentclass[11pt]{letter}\n
      \\usepackage[utf8]{inputenc}\n
      \\usepackage[T1]{fontenc}\n
      \\usepackage{color}"

               ("\\section{%s}" . "\\section*{%s}")
               ("\\subsection{%s}" . "\\subsection*{%s}")
               ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
               ("\\paragraph{%s}" . "\\paragraph*{%s}")
               ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))

;;; 中文显示latex
(with-eval-after-load 'ox-latex
  (add-to-list 'org-latex-classes
               '("ctexart" "\\documentclass[11pt]{ctexart}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
  (setq org-latex-default-class "ctexart")
  (setq org-latex-compiler "xelatex"))

;;; 设置代理
(defun proxy-socks-show ()
  "Show SOCKS proxy."
  (interactive)
  (when (fboundp 'cadddr)
    (if (bound-and-true-p socks-noproxy)
        (message "Current SOCKS%d proxy is %s:%d"
                 (cadddr socks-server) (cadr socks-server) (caddr socks-server))
      (message "No SOCKS proxy"))))

(defun proxy-socks-enable ()
  "Enable SOCKS proxy."
  (interactive)
  (require 'socks)
  (setq url-gateway-method 'socks
        socks-noproxy '("localhost")
        socks-server '("Default server" "127.0.0.1" 1086 5))
  (setenv "all_proxy" "socks5://127.0.0.1:1086")
  (proxy-socks-show))

(defun proxy-socks-disable ()
  "Disable SOCKS proxy."
  (interactive)
  (require 'socks)
  (setq url-gateway-method 'native
        socks-noproxy nil)
  (setenv "all_proxy" "")
  (proxy-socks-show))

(defun proxy-socks-toggle ()
  "Toggle SOCKS proxy."
  (interactive)
  (require 'socks)
  (if (bound-and-true-p socks-noproxy)
      (proxy-socks-disable)
    (proxy-socks-enable)))

;;; pandoc
(use-package exec-path-from-shell
  :ensure t)                            ;add path
(use-package pandoc-mode
  :ensure t)
(add-hook 'markdown-mode-hook 'pandoc-mode)
(add-hook 'pandoc-mode-hook 'pandoc-load-default-settings)

;;; (add-to-list 'load-path "~/.emacs.d/")
;;; (require 'color-theme)
;;; (color-theme-initialize)
;;; (color-theme-matrix)
;;; (color-theme-oswald)

(provide 'init-local)
