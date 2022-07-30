;;; sclang-util.el --- Utility helpers for sclang -*- coding: utf-8;
;;
;; Copyright 2003-2005 stefan kersten <steve@k-hornz.de>

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
;; Utility helpers for sclang

;;; Code:
(defun sclang-message (string &rest args)
  "Create a message from STRING with optional ARGS."
  (message "SCLang: %s" (apply 'format string args)))

(defun sclang-make-buffer-name (name &optional private-p)
  "Set the buffer name to NAME (optimally PRIVATE-P)."
  (concat (and private-p " ") "*SCLang:" name "*"))

(defun sclang-make-prompt-string (prompt default)
  "Return a prompt string using PROMPT and DEFAULT."
  (if (and default (string-match "\\(:\\)\\s *" prompt))
      (replace-match
       (format " (default %s):" default)
       'fixedcase 'literal prompt 1)
    prompt))

(defun sclang-string-to-int32 (str)
  "Convert first 4 bytes of STR (network byteorder) to 32 bit integer."
  (logior (ash (logand (aref str 0) #XFF) 24)
	  (ash (logand (aref str 1) #XFF) 16)
	  (ash (logand (aref str 2) #XFF) 8)
	  (logand (aref str 3) #XFF)))

(defun sclang-int32-to-string (n)
  "Convert 32 bit integer N to 4 byte string (network byte order)."
  (let ((str (make-string 4 0)))
    (aset str 0 (logand (ash n -24) #XFF))
    (aset str 1 (logand (ash n -16) #XFF))
    (aset str 2 (logand (ash n  -8) #XFF))
    (aset str 3 (logand          n  #XFF))
    str))

(defun sclang-compress-newlines (&optional buffer)
  "Compress newlines (optionally in BUFFER)."
  (with-current-buffer (or buffer (current-buffer))
    (save-excursion
      (goto-char (point-min))
      (while (not (eobp))
	(if (and (bolp) (eolp)
		 (save-excursion
		   (forward-line -1)
		   (and (bolp) (eolp))))
	    (delete-char 1)
	  (forward-line 1))))))

(eval-when-compile
  (defmacro sclang-save-buffer-state (varlist &rest body)
    "Bind variables according to VARLIST and eval BODY restoring buffer state."
    `(let* ,(append varlist
		    '((modified (buffer-modified-p)) (buffer-undo-list t)
		      (inhibit-read-only t) (inhibit-point-motion-hooks t)
		      (inhibit-modification-hooks t)
		      deactivate-mark buffer-file-name buffer-file-truename))
       (unwind-protect
	   ,@body
	 (when (and (not modified) (buffer-modified-p))
	   (set-buffer-modified-p nil))))))

;; (defun sclang-create-image (file-name &rest props)
;;   (when (file-exists-p file-name)
;;     (let ((coding-system-for-read 'no-conversion)
;; 	  (coding-system-for-write 'no-conversion)
;; 	  (inhibit-quit t))
;;       (with-temp-buffer
;; 	(when (equal 0 (call-process "anytopnm" file-name (list (current-buffer) nil)))
;; 	  (apply
;; 	   'create-image
;; 	   (buffer-substring-no-properties (point-min) (point-max))
;; 	   nil t props))))))

(provide 'sclang-util)

;;; sclang-util.el ends here
