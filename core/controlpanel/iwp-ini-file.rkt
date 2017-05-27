#lang racket

;; This module implements IWP ini file functions
;; License GPLv3
;; (c) 2010-2017 Corvideon Ltd 


(provide
;; get the hash of configuration settings
;; (hash-ref (get-config-hash "/Users/seamus/GitHub/InstantWP/core/config/iwp-osx.ini") "QEMUBinary")
 get-config-hash)

;; —————————————————————————————————
;; import and implementation section

(require (only-in
          racket/string
          string-trim
          string-split
          string-join))

;; define a local config hash
(define local-config-hash (make-hash))

;; returns a hash of config items
(define (get-config-hash config-path-string)
  (define ini-file (read-ini-file (open-input-file config-path-string)))
  (define sections (get-section-contents ini-file))
  (get-setting-values sections)
  local-config-hash) 

;; adds settings to config hash
(define (add-setting-to-hash lst)
  (map (λ (l)
         (hash-set! local-config-hash (first l)  (second l)))
       lst))


;; returns a list of settings values
(define (get-setting-values lst)
  (map add-setting-to-hash lst))


;; takes the list of ini file sections and gives back a list of settings
(define (get-section-contents lst)
  (map rest lst))

;; read-ini-file
;; code provided by TonyG at https://github.com/tonyg/racket-inverted-index/blob/master/inifile.rkt
(define (read-ini-file [p (current-input-port)])
  (let loop ((name #f)
	     (acc '())
	     (sections '()))
    (define (finish-section)
      (if name
	  (cons (cons name (reverse acc)) sections)
	  sections))
    (define line (read-line p 'any))
    (if (eof-object? line)
	(reverse (finish-section))
	(let ((line (string-trim line)))
	  (cond
	   [(equal? line "") (loop name acc sections)]
	   [(eqv? (string-ref line 0) #\[) (loop (substring line 1 (- (string-length line) 1))
						 '()
						 (finish-section))]
	   [else
	    (define pieces (string-split line "="))
	    (loop name
		  (cons (list (car pieces) (string-join (cdr pieces) "=")) acc)
		  sections)])))))