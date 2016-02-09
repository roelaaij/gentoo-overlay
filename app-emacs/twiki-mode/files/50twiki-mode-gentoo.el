(add-to-list 'load-path "@SITELISP@")

(autoload 'twiki-mode "twiki"
  "Major mode for editing documents in twiki markup." t)

(add-to-list 'auto-mode-alist '(".*twiki.*'" . twiki-mode))
