;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; test/sclang-mode-test.el

(ert-deftest sclang-autoloaded-functions ()
  "Some functions should be callable interactively without requiring them"
  (should (commandp 'sclang-start t))
  (should (commandp 'sclang-mode t)))

(ert-deftest sclang-major-mode-init-test ()
  "Loading a file with an scd extension should init sclang-mode"
  (find-file "fixtures/super-boring.scd")
  (should (eq 'sclang-mode major-mode)))
