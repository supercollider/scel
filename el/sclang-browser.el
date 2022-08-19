;;; sclang-browser.el --- SuperCollider documentation browser -*- coding: utf-8; lexical-binding: t -*-
;;
;; Copyright 2003 stefan kersten <steve@k-hornz.de>

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
;; Browser for SuperCollider documentation.

;; TODO: better factoring
;; - derive from view mode, make mode-map pluggable
;; - define derived mode for completion, definition, help
;; - update 'display-buffer-reuse-frames'
;; - update ‘view-return-to-alist’

(require 'sclang-util)
(require 'view)

;;; Code:

(defun sclang-browser-fill-keymap ()
  "Create keymap and bindings."
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map view-mode-map)
    (define-key map "\r" 'sclang-browser-follow-link)
    (define-key map [mouse-2] 'sclang-browser-mouse-follow-link)
    (define-key map "\t" 'sclang-browser-next-link)
    (define-key map [backtab] 'sclang-browser-previous-link)
    (define-key map [(shift tab)] 'sclang-browser-previous-link)
    (define-key map [?q] 'sclang-browser-quit)
    map))

(defvar sclang-browser-mode-map (sclang-browser-fill-keymap))
(defvar sclang-browser-mode-hook nil)
(defvar sclang-browser-show-hook nil)
(defvar sclang-browser-link-function nil)
(defvar sclang-browser-return-method nil)

(defun sclang-browser-beginning-of-link ()
  "Beginning of link."
  (interactive)
  (when (get-text-property (point) 'sclang-browser-link)
    (while (and (not (bobp))
                (get-text-property (point) 'sclang-browser-link))
      (forward-char -1))
    (unless (bobp) (forward-char 1))
    (point)))

(defun sclang-browser-next-link (&optional n)
  "Next  link (or N further)."
  (interactive)
  (let* ((n (or n 1))
         (prop 'sclang-browser-link)
         (fwd (>= n 0))
         (orig (point))
         (beg (if fwd (point-min) (point-max)))
         (end (if fwd (point-max) (point-min)))
         (inc (if fwd 1 -1))
         pos)
    (when (get-text-property (point) prop)
      (while (and (/= (point) beg)
                  (get-text-property (point) prop))
        (forward-char inc))
      (if (= (point) beg) (goto-char end)))
    (while (not (eq pos orig))
      (cond ((get-text-property (point) prop)
             (sclang-browser-beginning-of-link)
             (setq pos orig))
            (t
             (if (= (point) end) (goto-char beg))
             (forward-char inc)
             (setq pos (point)))))))

(defun sclang-browser-previous-link ()
  "Previous link."
  (interactive)
  (sclang-browser-next-link -1))

(defun sclang-browser-follow-link (&optional pos)
  "Follow link (optionally POS)."
  (interactive)
  (let* ((pos (or pos (point)))
         (data (get-text-property pos 'sclang-browser-link)))
    (when (consp data)
      (let ((fun (or (car data) sclang-browser-link-function))
            (arg (cdr data)))
        (when (functionp fun)
          (condition-case nil
              (funcall fun arg)
            (error (sclang-message "Error in link function") nil)))))))

(defun sclang-browser-mouse-follow-link (event)
  "Link.  click.  EVENT."
  (interactive "e")
  (let* ((start (event-start event))
         (window (car start))
         (pos (cadr start)))
    (with-current-buffer (window-buffer window)
      (sclang-browser-follow-link pos))))

(defun sclang-browser-mode ()
  "Major mode for viewing hypertext and navigating references.
Entry to this mode runs the normal hook `sclang-browser-mode-hook'

Commands:
\\{sclang-browser-mode-map}"
  (interactive)
  (view-mode)
  (kill-all-local-variables)
  (use-local-map sclang-browser-mode-map)
  (setq mode-name "Browser")
  (setq major-mode 'sclang-browser-mode)
  (set (make-local-variable 'sclang-browser-link-function) nil)
  (set (make-local-variable 'sclang-browser-return-method) nil)
  (set (make-local-variable 'font-lock-defaults) nil)
  (set (make-local-variable 'minor-mode-overriding-map-alist)
       (list (cons 'view-mode sclang-browser-mode-map)))
  (set (make-local-variable 'view-no-disable-on-exit) t)
  (run-hooks 'sclang-browser-mode-hook))

(defun sclang-browser-mode-setup ()
  "Setup sclang-browser-mode."
  (sclang-browser-mode)
  (setq buffer-read-only nil))

(defun sclang-browser-mode-finish ()
  "Finish sclang-browser-mode."
  (read-only-mode)
  ;; ‘view-return-to-alist’ is an obsolete variable (as of 24.1)
  ;;(setq view-return-to-alist
  ;;      (list (cons (selected-window) sclang-browser-return-method)))
  (view-mode -1)
  (run-hooks 'sclang-browser-show-hook))

(defun sclang-browser-quit ()
  "Quit the sclang help browser."
  (interactive)
  (when (eq major-mode 'sclang-browser-mode)
    (kill-buffer (current-buffer))))

(defun sclang-browser-make-link (link-text &optional link-data link-function)
  "Make a link using LINK-TEXT (optional LINK-DATA and LINK-FUNCTION)."
  (propertize link-text
              'mouse-face 'highlight
              'sclang-browser-link (cons link-function link-data)))

(defun sclang-display-browser (buffer-name output-function)
  "Display browser using BUFFER-NAME and OUTPUT-FUNCTION.
header: what to insert in the buffer.
link-list: list of (link-text link-function link-data)
link-function: function with args (link-text link-data)"
  (let ((temp-buffer-setup-hook '(sclang-browser-mode-setup))
        (temp-buffer-show-hook '(sclang-browser-mode-finish)))
    (with-output-to-temp-buffer buffer-name
      (with-current-buffer standard-output
        ;; record return method
        (setq sclang-browser-return-method
              (cond ((special-display-p (buffer-name standard-output))
                     ;; If the help output buffer is a special display buffer,
                     ;; don't say anything about how to get rid of it.
                     ;; First of all, the user will do that with the window
                     ;; manager, not with Emacs.
                     ;; Secondly, the buffer has not been displayed yet,
                     ;; so we don't know whether its frame will be selected.
                     (cons (selected-window) t))
                    ;; display-buffer-reuse-frames is obsolete since 24.3
                    ;; replace with something like
                    ;;+ (add-to-list 'display-buffer-alist
                    ;;+     '("." nil (reusable-frames . t)))
                    ;;- (display-buffer-reuse-frames
                    ;;-  (cons (selected-window) 'quit-window))
                    ((not (one-window-p t))
                     (cons (selected-window) 'quit-window))
                    ;; This variable is provided mainly for backward compatibility
                    ;; and should not be used in new code.
                    ;;  (pop-up-windows
                    ;;   (cons (selected-window) t))
                    (t
                     (list (selected-window) (window-buffer)
                           (window-start) (window-point)))))
        (funcall output-function)))))

(defmacro with-sclang-browser (buffer-name &rest body)
  "Display browser in BUFFER-NAME and run BODY."
  `(sclang-display-browser ,buffer-name (lambda () ,@body)))

;; =====================================================================
;; module setup
;; =====================================================================

(provide 'sclang-browser)

;;; sclang-browser.el ends here
