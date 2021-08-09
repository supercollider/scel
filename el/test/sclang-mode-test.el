;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; test/sclang-mode-test.el

(ert-deftest sclang-major-mode-init-test ()
  "Loading a file with an scd extension should init sclang-mode"
  (find-file "fixtures/super-boring.scd")
  (should (eq 'sclang-mode major-mode)))
