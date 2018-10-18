#!/usr/bin/env sh
# -*- scheme -*-
# this gets faster when confined to Processing Units which are physically separate??
# hwloc-ls gets the layout, on a 12 PU layout with 2 processing units per core, use
# time taskset -c 0-5
exec guile -L $(dirname $(realpath "$0")) -e '(skynet)' -s "$0" "$@"
; !#

(define-module (skynet)
         #:export (main))

(import (fibers)
        (fibers channels)
        (ice-9 threads)
        (ice-9 format))

#!curly-infix

(define levels 6)
(define children 10)


(define (skynet-nothread level index)
  (cond
   ({level >= levels}
    index)
   (else
    (let sum ((remaining children)
              (index {index * children})
              (aggregated 0))
      (if {remaining > 0}
          (sum {remaining - 1}
               {index + 1}
               {aggregated + (skynet-nothread {level + 1} index)})
          aggregated)))))


(define (process-spawn level index)
  (let ((channel (make-channel)))
    (let create ((remaining children)
                 (index {index * children}))
      (when {remaining > 0}
            (spawn-fiber
             (λ() (skynet {level + 1} index channel))
             #:parallel? {level < 2}) ;; stay on processor for later levels
            (create {remaining - 1}
                    {index + 1})))
    (let collect ((remaining children)
                  (sum 0))
      (if {remaining > 0}
          (collect {remaining - 1}
                   (+ sum (get-message channel)))
          sum))))


(define (skynet level index channel)
  (cond
   ({level >= levels}
    (put-message channel index))
   (else
    (put-message channel (process-spawn level index)))))


(define (main args)
  (let
      ((start-time (get-internal-real-time))
       (result 0)
       (serial-runtime 0))
    (set! result (skynet-nothread 0 0))
    (set! serial-runtime {{(get-internal-real-time) - start-time}
                          / internal-time-units-per-second})
    (format #t "serial: Result: ~d in ~f seconds\n" result serial-runtime)
    (let loop ((runs 4))
      (when {runs > 0}
         (let
           ((start-time (get-internal-real-time))
             (result 0)
             (runtime 0))
           (run-fibers
             (λ()
               (let ((channel (make-channel)))
                   (spawn-fiber
                       (λ() (skynet 0 0 channel)))
                   (set! result (get-message channel)))))
           (set! runtime {{(get-internal-real-time) - start-time}
                           / internal-time-units-per-second})
           (format #t "~d: Result: ~d in ~f seconds, speedup of ~f\n" runs result runtime {serial-runtime / runtime}))
         (loop {runs - 1})))))
