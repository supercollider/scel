;;; sclang.el --- IDE for working with SuperCollider -*- coding: utf-8; lexical-binding: t -*-
;;
;; Copyright 2003 stefan kersten <steve@k-hornz.de>
;;
;; Author: stefan kersten
;; Keywords: supercollider, multimedia, languages, tools
;; Version: 1.1.0
;; Package-Requires: ((emacs "27.1") (w3m "0.0"))
;; URL: https://github.com/supercollider/scel

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2 of the
;; License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301
;; USA

;;; Commentary:
;;
;; This package provides code for interfacing with sclang and scsynth.
;; In order to be useful you need to install SuperCollider and the
;; sc-el Quark.  See the README or https://github.com/supercollider/scel
;; for more information.
;;
;; Recent versions of w3m use tab-line which is only available after 27.1
;; However sclang should work on Emacs 26.3 to 27.1 without the help browser.

;;; Credits:
;;
;; stefan kersten <steve@k-hornz.de>
;; and everyone in...
;;        git shortlog -s | sort -r | cut -c8-


;;; Code:

(defgroup sclang nil
  "IDE for working with the SuperCollider language."
  :group 'languages)

(defgroup sclang-mode nil
  "Major mode for working with SuperCollider source code."
  :group 'sclang)

(defgroup sclang-minor-mode nil
  "Minor mode for working with SuperCollider source code."
  :group 'sclang)

(defgroup sclang-interface nil
  "Interface to the SuperCollider process."
  :group 'sclang)

(defgroup sclang-programs nil
  "Paths to programs used by `sclang-mode'."
  :group 'sclang-interface)

(defgroup sclang-options nil
  "Options for the SuperCollider process."
  :group 'sclang-interface)

;;;###autoload
(defun sclang-customize ()
  "Customize sclang variables."
  (interactive)
  (customize-group 'sclang))

(require 'sclang-util)
(require 'sclang-browser)
(require 'sclang-interp)
(require 'sclang-language)
(require 'sclang-document)
(require 'sclang-mode)
(require 'sclang-minor-mode)
(require 'sclang-help)
(require 'sclang-server)
(require 'sclang-widgets)

(provide 'sclang)

;;; sclang.el ends here
