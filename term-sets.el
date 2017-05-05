;;; term-sets.el --- Manage terms of notes

;; Copyright (C) 2017 Samuel Flint

;; Author: Samuel W. Flint <swflint@flintfam.org>
;; Version: 1.0
;; Package-Requires: ((buffer-sets "2.5"))
;; Keywords: buffer-management, notes, organization
;; URL: https://git.flintfam.org/swf-projects/buffer-sets


;;; Commentary:
;; 



;;; Code:

(require 'buffer-sets)

(defcustom term-sets-save-mechanism 'customize
  "Method to save term-sets data."
  :type '(choice (const :tag "Customize" customize)
                 (const :tag "File" file)
                 (const :tag "Don't Save" nil))
  :group 'editing)

(defcustom term-sets-save-file "~/.emacs.d/term-sets-data.el"
  "Where to save term-sets data in file save mechanism."
  :type 'file :group 'editing)

(defcustom term-sets-current-year (nth 5 (decode-time))
  "Year to use for finding files."
  :type 'integer :group 'editing)

(defcustom term-sets-current-term "fall"
  "Term to use for finding files."
  :type 'string :group 'editing)

(defcustom term-sets-base-directory "~/org/school"
  "Directory that notes files are contained in."
  :type 'directory :group 'editing)

(defcustom term-sets-template "#+Title: %t\n#+AUTHOR: %u\n#+EMAIL: %e\n#+DATE: %d\n#+OPTIONS: H:5 ':t *:t d:nil stat:nil todo:nil num:nil\n#+LATEX_CLASS_OPTIONS: [10pt,twocolumn]\n#+LATEX_HEADER: \\usepackage[landscape,margin=0.125 in]{geometry}\n#+LATEX_HEADER: \\pagestyle{empty}\n\n"
  "Template for notes file."
  :type 'string :group 'editing)

(defcustom term-sets-buffer-set 'school
  "The name of the buffer-set to use."
  :type 'symbol :group 'editing)

(defun term-sets-find-buffer-set-load-files ()
  "Find the files for the current term."
  (let ((directory (format "%s/%s/%s/"
                           term-sets-base-directory
                           term-sets-current-year
                           term-sets-current-term)))
    (buffer-sets-in-buffers-list term-sets-buffer-set
                                 (find-file directory))
    (dolist (file (directory-files directory t ".*\\.org$"))
      (buffer-sets-in-buffers-list term-sets-buffer-set (find-file file)))))

(defun term-sets-make-new-term-folder (year term)
  "Make new term folder for YEAR and TERM."
  (interactive "nYear: \nsTerm: ")
  (make-directory
   (expand-file-name
    (format "~/org/school/%s/%s/" year term))))

(defun term-sets-make-new-class-notes-file (year term subject number description)
  "Create a new file for YEAR, TERM, SUBJECT, NUMBER and DESCRIPTION."
  (interactive "nYear: \nsTerm: \nsSubject: \nnNumber: \nsDescription: ")
  (let ((filename (expand-file-name
                   (format "~/org/school/%s/%s/%s-%s.org"
                           year
                           term
                           (downcase subject)
                           number)))
        (contents (format-spec term-sets-template
                               (format-spec-make ?t description
                                                 ?d (format-time-string "<%Y-%m-%d %a %H:%M>")
                                                 ?u user-full-name
                                                 ?e user-mail-address
                                                 ?s subject
                                                 ?n number
                                                 ?T term
                                                 ?y year))))
    (with-current-buffer (find-file-literally filename)
      (insert contents)
      (save-buffer)
      (kill-buffer))))

(defun term-sets-set-new-term (year term)
  "Set the new term to YEAR and TERM."
  (interactive "nYear: \nsTerm: ")
  (case term-sets-save-mechanism
    (customize
     (custom-set-variables (list 'term-sets-current-year year)
                           (list 'term-sets-current-term term))
     (custom-save-variables))
    (file
     (with-current-buffer (find-file term-sets-save-file)
       (erase-buffer)
       (insert (format "%S\n" `(setf term-sets-current-term ,term
                                     term-sets-current-year ,year)))
       (save-buffer)
       (kill-buffer))))
  (buffer-sets-unload-buffer-set term-sets-buffer-set)
  (buffer-sets-load-set term-sets-buffer-set))

(provide 'term-sets)

;;; term-sets.el ends here
