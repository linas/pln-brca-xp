(define-module (pln-bio intensional-similarity)
    #:use-module (opencog)
    #:use-module (opencog exec)
    #:use-module (opencog randgen)
    #:use-module (opencog logger)
    #:use-module (opencog ure)
    #:use-module (opencog pln)
    #:use-module (opencog bioscience)
    #:use-module (pln-bio bio-utils)
    #:use-module (pln-bio preprocess)
)

(define X (Variable "$x"))
(define Y (Variable "$y"))
(define target (IntensionalSimilarity X Y))

(define-public (go-intentional-similarity kbs)
   (define log-filename "intentional-reasoning-test.log")

    ;; (cog-logger-set-timestamp! #f)
    ;; (cog-logger-set-sync! #t)
    (cog-logger-set-level! "info")
    (cog-logger-set-filename! log-filename)
    ;; (ure-logger-set-timestamp! #f)
    ;; (ure-logger-set-sync! #t)
    ; (ure-logger-set-level! "debug")
    ; (ure-logger-set-filename! log-filename)

    (let* ((ss 0.001) (rs 0) (mi 100) (cp 1)
           (param-str (string-append
                   "-rs=" (number->string rs)
                   "-ss=" (number->string ss)
                   "-mi=" (number->string mi)
                   "-cp=" (number->string cp)))
            (output-file (string-append "results/intentional-reasoning-test-asv2" param-str ".scm"))
            (filter-out (lambda (x)
                            (or (GO_term? x)
                                (inheritance-GO_term? x))))
          (filename (preprocess kbs #:filter-out filter-out)))

        ;;clear the atomspace
        (clear)
        ;; Load PLN
        (cog-logger-info "Running BC: Attraction->IntensionalSimilarity")
        (pln-load 'empty)
        (pln-add-rule 'intensional-inheritance-direct-introduction)
        (pln-add-rule 'intensional-similarity-direct-introduction)
        (pln-add-rule 'intensional-difference-direct-introduction)
        
        (load-kbs (list filename) #:subsmp ss)

        (write-atoms-to-file output-file (cog-outgoing-set (pln-bc target #:maximum-iterations mi #:complexity-penalty cp)))
        (cog-logger-info "Done!")))
