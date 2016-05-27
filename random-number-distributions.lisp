;;;; sbcl-gsl/random-number-distributions.lisp
;;;;
;;;; This file describes for generating random variates and computing their
;;;; probability distributions. Samples from the distributions described in this
;;;; file can be obtained using any of the random number generators in the library
;;;; as an underlying source of randomness.

;;;; Copyright (C) 2016 Takahiro Ishikawa
;;;;
;;;; This program is free software: you can redistribute it and/or modify
;;;; it under the terms of the GNU General Public License as published by
;;;; the Free Software Foundation, either version 3 of the License, or
;;;; (at your option) any later version.
;;;;
;;;; This program is distributed in the hope that it will be useful,
;;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;;;; GNU General Public License for more details.
;;;;
;;;; You should have received a copy of the GNU General Public License
;;;; along with this program. If not, see http://www.gnu.org/licenses/.

(cl:defpackage "SB-GSL-RAN"
  (:use "CL"
        "SB-ALIEN"
        "SB-C-CALL"
        "SB-GSL-RNG")
  (:export "GSL-RAN-GAUSSIAN"
           "GSL-RAN-GAUSSIAN-PDF"
           "GSL-RAN-GAUSSIAN-ZIGGURAT"
           "GSL-RAN-GAUSSIAN-RATIO-METHOD"
           "GSL-RAN-UGAUSSIAN"
           "GSL-RAN-UGAUSSIAN-PDF"
           "GSL-RAN-UGAUSSIAN-RATIO-METHODN"
           "GSL-CDF-GAUSSIAN-P"
           "GSL-CDF-GAUSSIAN-Q"
           "GSL-CDF-GAUSSIAN-PINV"
           "GSL-CDF-GAUSSIAN-QINV"
           "GSL-CDF-UGAUSSIAN-P"
           "GSL-CDF-UGAUSSIAN-Q"
           "GSL-CDF-UGAUSSIAN-PINV"
           "GSL-CDF-UGAUSSIAN-QINV"
           "GSL-RAN-GAUSSIAN-TAIL"
           "GSL-RAN-GAUSSIAN-TAIL-PDF"
           "GSL-RAN-UGAUSSIAN-TAIL"
           "GSL-RAN-UGAUSSIAN-TAIL-PDF"
           "GSL-RAN-BIVARIATE-GAUSSIAN"
           "GSL-RAN-BIVARIATE-GAUSSIAN-PDF"
           "GSL-RAN-EXPONENTIAL"
           "GSL-RAN-EXPONENTIAL-PDF"
           "GSL-CDF-EXPONENTIAL-P"
           "GSL-CDF-EXPONENTIAL-Q"
           "GSL-CDF-EXPONENTIAL-PINV"
           "GSL-CDF-EXPONENTIAL-QINV"
           "GSL-RAN-LAPLACE"
           "GSL-RAN-LAPLACE-PDF"
           "GSL-CDF-LAPLACE-P"
           "GSL-CDF-LAPLACE-Q"
           "GSL-CDF-LAPLACE-PINV"
           "GSL-CDF-LAPLACE-QINV"
           "GSL-RAN-TDIST"
           "GSL-RAN-TDIST-PDF"
           "GSL-CDF-TDIST-P"
           "GSL-CDF-TDIST-Q"
           "GSL-CDF-TDIST-PINV"
           "GSL-CDF-TDIST-QINV"
           "GSL-RAN-DIR-2D"
           "GSL-RAN-DIR-2D-TRIG-METHOD"))

(cl:in-package "SB-GSL-RAN")

;;; The Gaussian Distribution

;;; (gsl-ran-gaussian rng sigma)
;;;   This function returns a Gaussian random rariate, with mean zero and standard
;;;   deviation sigma. Use the transformation z = mu + x on the numbers returned
;;;   by gsl-ran-gaussian to obtain a Gaussian distribution with mean mu. This
;;;   function uses the Box-Muller algorithm which requires two calls to the random
;;;   number generator r.
(define-alien-routine gsl-ran-gaussian
    double
  (rng (* (struct gsl-rng)))
  (sigma double))

;;; (gsl-ran-gaussian-pdf rng sigma)
;;;   This function computes the probability density p(x) at x for a Gaussian distribution
;;;   with standard deviation sigma.
(define-alien-routine gsl-ran-gaussian-pdf
    double
  (x double)
  (sigma double))

;;; (gsl-ran-gaussian-ziggurat rng sigma)
;;; (gsl-ran-gaussian-ratio-method rng sigma)
;;;   This function computes a Gaussian random variate using the alternative Marsaglia-
;;;   Tsang ziggurat and Kinderman-Monahoan-Leva ratio methods. The Ziggurat algorithm
;;;   is the fastest available algorithm in most cases.
(define-alien-routine gsl-ran-gaussian-ziggurat
    double
  (rng (* (struct gsl-rng)))
  (sigma double))

(define-alien-routine gsl-ran-gaussian-ratio-method
    double
  (rng (* (struct gsl-rng)))
  (sigma double))

;;; (gsl-ran-ugaussian r)
;;; (gsl-ran-ugaussian-pdf r)
;;; (gsl-rng-ugaussian-ratio-method r)
;;;   These functions compute results for the unit Gaussian distribution. They are equivalent
;;;   to the functions above with a standard deviation of one, sigma = 1.
(define-alien-routine gsl-ran-ugaussian
    double
  (rng (* (struct gsl-rng))))

(define-alien-routine gsl-ran-ugaussian-pdf
    double
  (x double))

(define-alien-routine gsl-ran-ugaussian-ratio-method
    double
  (rng (* (struct gsl-rng))))

;;; (gsl-cdf-gaussian-p x sigma)
;;; (gsl-cdf-gaussian-q x sigma)
;;; (gsl-cdf-gaussian-pinv p sigma)
;;; (gsl-cdf-gaussian-qinv q sigma)
;;;   These functions compute the cumulative distribution functions P(x), Q(x) and their
;;;   inverses for the Gaussian distribution with standard deviation sigma.
;;;
;;; define-alien-routine macro automatically try to find c-function name with lower case
;;; letter. If symbol is gsl-cdf-gaussian-p, macro try to find c-function gsl_cdf_gaussian_p.
;;; But cdf functions have partially upper case letter, so these functions are directly
;;; difined by defun.
(progn
  ;; function gsl-cdf-gaussian-p for c-function "gsl_cdf_gaussian_P".
  (declaim (ftype (function (t t) (values (alien double) &optional)) gsl-cdf-gaussian-p))
  (defun gsl-cdf-gaussian-p (x sigma)
    (with-alien ((gsl-cdf-gaussian-p (function double double double)
                                     :extern "gsl_cdf_gaussian_P"))
      (values (alien-funcall gsl-cdf-gaussian-p x sigma))))
  ;; function gsl-cdf-gaussian-q for c-function "gsl_cdf_gaussian_Q".
  (declaim (ftype (function (t t) (values (alien double) &optional)) gsl-cdf-gaussian-q))
  (defun gsl-cdf-gaussian-q (x sigma)
    (with-alien ((gsl-cdf-gaussian-q (function double double double)
                                     :extern "gsl_cdf_gaussian_Q"))
      (values (alien-funcall gsl-cdf-gaussian-q x sigma))))
  ;; function gsl-cdf-gaussian-pinv for c-function "gsl_cdf_gaussian_Pinv.
  (declaim (ftype (function (t t) (values (alien double) &optional)) gsl-cdf-gaussian-pinv))
  (defun gsl-cdf-gaussian-pinv (p sigma)
    (with-alien ((gsl-cdf-gaussian-pinv (function double double double)
                                        :extern "gsl_cdf_gaussian_Pinv"))
      (values (alien-funcall gsl-cdf-gaussian-pinv p sigma))))
  ;; function gsl-cdf-gaussian-qinv for c-function "gsl_cdf_gaussian_Qinv".
  (declaim (ftype (function (t t) (values (alien double) &optional)) gsl-cdf-gaussian-qinv))
  (defun gsl-cdf-gaussian-qinv (q sigma)
    (with-alien ((gsl-cdf-gaussian-qinv (function double double double)
                                        :extern "gsl_cdf_gaussian_Qinv"))
      (values (alien-funcall gsl-cdf-gaussian-qinv q sigma)))))

;;; (gsl-cdf-ugaussian-p x)
;;; (gsl-cdf-ugaussian-q x)
;;; (gsl-cdf-ugaussian-pinv x)
;;; (gsl-cdf-ugaussian-qinv x)
;;;   These functions compute the cumulative distribution functions P(x), Q(x) and their
;;;   inverses for the unit Gaussian distribution.
;;;
;;; define-alien-routine macro automatically try to find c-function name with lower case
;;; letter. If symbol is gsl-cdf-gaussian-p, macro try to find c-function gsl_cdf_gaussian_p.
;;; But cdf functions have partially upper case letter, so these functions are directly
;;; difined by defun.
(progn
  ;; function gsl-cdf-ugaussian-p for c-function "gsl_cdf_ugaussian_P".
  (declaim (ftype (function (t) (values (alien double) &optional)) gsl-cdf-ugaussian-p))
  (defun gsl-cdf-ugaussian-p (x)
    (with-alien ((gsl-cdf-ugaussian-p (function double double)
                                      :extern "gsl_cdf_ugaussian_P"))
      (values (alien-funcall gsl-cdf-ugaussian-p x))))
  ;; function gsl-cdf-ugaussian-q for c-function "gsl_cdf_ugaussian_Q".
  (declaim (ftype (function (t) (values (alien double) &optional)) gsl-cdf-ugaussian-q))
  (defun gsl-cdf-ugaussian-q (x)
    (with-alien ((gsl-cdf-ugaussian-q (function double double)
                                      :extern "gsl_cdf_ugaussian_Q"))
      (values (alien-funcall gsl-cdf-ugaussian-q x))))
  ;; function gsl-cdf-ugaussian-pinv for c-function "gsl_cdf_ugaussian_Pinv".
  (declaim (ftype (function (t) (values (alien double) &optional)) gsl-cdf-ugaussian-pinv))
  (defun gsl-cdf-ugaussian-pinv (p)
    (with-alien ((gsl-cdf-ugaussian-pinv (function double double)
                                         :extern "gsl_cdf_ugaussian_Pinv"))
      (values (alien-funcall gsl-cdf-ugaussian-pinv p))))
  ;; function gsl-cdf-ugaussian-qinv for c-function "gsl_cdf_ugaussian_Qinv".
  (declaim (ftype (function (t) (values (alien double) &optional)) gsl-cdf-ugaussian-qinv))
  (defun gsl-cdf-ugaussian-qinv (q)
    (with-alien ((gsl-cdf-ugaussian-qinv (function double double)
                                         :extern "gsl_cdf_ugaussian_Qinv"))
      (values (alien-funcall gsl-cdf-ugaussian-qinv q)))))

;;; The Gaussian Tail Distribution

;;; (gsl-ran-gaussian-tail rng a sigma)
;;;   This function provides random variates from the upper tail of a Gaussian distribution
;;;   with standard deviation sigma. The values returned are lagger than the lower limit a,
;;;   which must be positive. The method is based on Marsaglia's famous rectangle-wedge-tail
;;;   algorithm.
(define-alien-routine gsl-ran-gaussian-tail
    double
  (rng (* (struct gsl-rng)))
  (a double)
  (sigma double))

;;; (gsl-ran-gaussian-tail-pdf x a sigma)
;;;   This function computes the probability density p(x) at x for Gaussian tail distribution
;;;   with standard deviation sigma and lower limit a.
(define-alien-routine gsl-ran-gaussian-tail-pdf
    double
  (x double)
  (a double)
  (sigma double))

;;; (gsl-ran-ugaussian-tail rng double a)
;;; (gsl-ran-ugaussian-tail-pdf x a)
;;;   These functions compute result for the tail of a unit Gaussian distribution. They
;;;   are equivalent to the functions above with a standard deviation of one, sigma = 1.
(define-alien-routine gsl-ran-ugaussian-tail
    double
  (rng (* (struct gsl-rng)))
  (a double))

(define-alien-routine gsl-ran-ugaussian-tail-pdf
    double
  (x double)
  (a double))

;;; The Bivariate Gaussian Distribution

;;; (gsl-ran-bivariate-gaussian rng sigma-x sigma-y rho x y)
;;;   This function generates a pair of correlated Gaussian variates, with mean zero,
;;;   correlation coefficient rho and standard deviations sigma-x and sigma-y in the x
;;;   and y directions.
(define-alien-routine gsl-ran-bivariate-gaussian
    void
  (rng (* (struct gsl-rng)))
  (sigma-x double)
  (sigma-y double)
  (rho double)
  (x (* double))
  (y (* double)))

;;; (gsl-ran-bivariate-gaussian-pdf x y sigma-x sigma-y rho)
;;;   This function computes the probability density p(x, y) at (x, y) for bivariate
;;;   Gaussian distribution with standard deviations sigma-x, sigma-y and correlation
;;;   coefficient rho.
(define-alien-routine gsl-ran-bivariate-gaussian-pdf
    double
  (x double)
  (y double)
  (sigma-x double)
  (sigma-y double)
  (rho double))

;;; The Exponential Distribution

;;; (gsl-ran-exponential rng mu)
;;;   This function returns a random variate from the exponential distribution  with mean mu.
(define-alien-routine gsl-ran-exponential
    double
  (rng (* (struct gsl-rng)))
  (mu double))

;;; (gsl-ran-exponential-pdf x mu)
;;;   This function computes the probability density p(x) at x for an exponential distribution
;;;   with mean mu.
(define-alien-routine gsl-ran-exponential-pdf
    double
  (x double)
  (mu double))

;;; (gsl-cdf-exponential-p x mu)
;;; (gsl-cdf-exponential-q x mu)
;;; (gsl-cdf-exponential-pinv p mu)
;;; (gsl-cdf-exponential-qinv q mu)
;;;   These functions compute the cumulative distribution functions P(x), Q(x) and their
;;;   inverses for the exponential distribution with mean mu.
;;;
;;; define-alien-routine macro automatically try to find c-function name with lower case
;;; letter. If symbol is gsl-cdf-gaussian-p, macro try to find c-function gsl_cdf_gaussian_p.
;;; But cdf functions have partially upper case letter, so these functions are directly
;;; difined by defun.
(progn
  ;; function gsl-cdf-exponential-p for c-function "gsl_cdf_exponential_P".
  (declaim (ftype (function (t t) (values (alien double) &optional)) gsl-cdf-exponential-p))
  (defun gsl-cdf-exponential-p (x mu)
    (with-alien ((gsl-cdf-exponential-p (function double double double)
                                        :EXTERN "gsl_cdf_exponential_P"))
      (values (alien-funcall gsl-cdf-exponential-p x mu))))
  ;; function gsl-cdf-exponential-q for c-function "gsl_cdf_exponential_Q".
  (declaim (ftype (function (t t) (values (alien double) &optional)) gsl-cdf-exponential-q))
  (defun gsl-cdf-exponential-q (x mu)
    (with-alien ((gsl-cdf-exponential-q (function double double double)
                                        :extern "gsl_cdf_exponential_Q"))
      (values (alien-funcall gsl-cdf-exponential-q x mu))))
  ;; function gsl-cdf-exponential-pinv for c-function "gsl_cdf_exponential_Pinv".
  (declaim (ftype (function (t t) (values (alien double) &optional)) gsl-cdf-exponential-pinv))
  (defun gsl-cdf-exponential-pinv (p mu)
    (with-alien ((gsl-cdf-exponential-pinv (function double double double)
                                           :extern "gsl_cdf_exponential_Pinv"))
      (values (alien-funcall gsl-cdf-exponential-pinv p mu))))
  ;; function gsl-cdf-exponential-qinv for c-function "gsl_cdf_exponential_Qinv".
  (declaim (ftype (function (t t) (values (alien double) &optional)) gsl-cdf-exponential-qinv))
  (defun gsl-cdf-exponential-qinv (q mu)
    (with-alien ((gsl-cdf-exponential-qinv (function double double double)
                                           :extern "gsl_cdf_exponential_Qinv"))
      (values (alien-funcall gsl-cdf-exponential-qinv q mu)))))

;;; The Laplace Distribution

;;; (gsl-ran-laplace rng a)
;;;   This function returns a random variate from the Laplace distribution with width a.
(define-alien-routine gsl-ran-laplace
    double
  (rng (* (struct gsl-rng)))
  (a double))

;;; (gsl-ran-laplace-pdf x a)
;;;   This function computes the probability density p(x) at x for a Laplace distribution
;;;   with width a.
(define-alien-routine gsl-ran-laplace-pdf
    double
  (x double)
  (a double))

;;; (gsl-cdf-laplace-p x a)
;;; (gsl-cdf-laplace-q x a)
;;; (gsl-cdf-laplace-pinv p a)
;;; (gsl-cdf-laplace-qinv q a)
;;;   These functions compute the cumulative distribution function P(x), Q(x) and their
;;;   inverses for the Laplace distribution with width a.
;;;
;;; define-alien-routine macro automatically try to find c-function name with lower case
;;; letter. If symbol is gsl-cdf-gaussian-p, macro try to find c-function gsl_cdf_gaussian_p.
;;; But cdf functions have partially upper case letter, so these functions are directly
;;; difined by defun.
(progn
  ;; function gsl-cdf-laplace-p for c-function "gsl_cdf_laplace_P".
  (declaim (ftype (function (t t) (values (alien double) &optional)) gsl-cdf-laplace-p))
  (defun gsl-cdf-laplace-p (x a)
    (with-alien ((gsl-cdf-laplace-p (function double double double)
                                    :extern "gsl_cdf_laplace_P"))
      (values (alien-funcall gsl-cdf-laplace-p x a))))
  ;; function gsl-cdf-laplace-q for c-function "gsl_cdf_laplace_Q".
  (declaim (ftype (function (t t) (values (alien double) &optional)) gsl-cdf-laplace-q))
  (defun gsl-cdf-laplace-q (x a)
    (with-alien ((gsl-cdf-laplace-q (function double double double)
                                    :extern "gsl_cdf_laplace_Q"))
      (values (alien-funcall gsl-cdf-laplace-q x a))))
  ;; function gsl-cdf-laplace-pinv for c-function "gsl_cdf_laplace_Pinv".
  (declaim (ftype (function (t t) (values (alien double) &optional)) gsl-cdf-laplace-pinv))
  (defun gsl-cdf-laplace-pinv (p a)
    (with-alien ((gsl-cdf-laplace-pinv (function double double double)
                                       :extern "gsl_cdf_laplace_Pinv"))
      (values (alien-funcall gsl-cdf-laplace-pinv p a))))
  ;; function gsl-cdf-laplace-qinv for c-function "gsl_cdf_laplace_Qinv".
  (declaim (ftype (function (t t) (values (alien double) &optional)) gsl-cdf-laplace-qinv))
  (defun gsl-cdf-laplace-qinv (q a)
    (with-alien ((gsl-cdf-laplace-qinv (function double double double)
                                       :extern "gsl_cdf_laplace_Qinv"))
      (values (alien-funcall gsl-cdf-laplace-qinv q a)))))

;;; The t-distribution

;;; (gsl-ran-tdist rng nu)
;;;   This function returns a random variate from the t-distribution.
(define-alien-routine gsl-ran-tdist
    double
  (rng (* (struct gsl-rng)))
  (nu double)) ; degrees of freedom

;;; (gsl-ran-tdist-pdf x nu)
;;;   This function computes the probability density p(x) at x for a t-distribution with nu
;;;   degrees of freedom.
(define-alien-routine gsl-ran-tdist-pdf
    double
  (x double)
  (nu double))

;;; (gsl-cdf-tdist-p x nu)
;;; (gsl-cdf-tdist-q x nu)
;;; (gsl-cdf-tdist-pinv p nu)
;;; (gsl-cdf-tdist-qinv q nu)
;;;   These functions compute the cumulative distribution function P(x), Q(x) and their
;;;   inverses for the t-distribution with nu degrees of freedom.
;;;
;;; define-alien-routine macro automatically try to find c-function name with lower case
;;; letter. If symbol is gsl-cdf-gaussian-p, macro try to find c-function gsl_cdf_gaussian_p.
;;; But cdf functions have partially upper case letter, so these functions are directly
;;; difined by defun.
(progn
  ;; function gsl-cdf-tdist-p for c-function "gsl_cdf_tdist_P".
  (declaim (ftype (function (t t) (values (alien double) &optional)) gsl-cdf-tdist-p))
  (defun gsl-cdf-tdist-p (x nu)
    (with-alien ((gsl-cdf-tdist-p (function double double double)
                                  :extern "gsl_cdf_tdist_P"))
      (values (alien-funcall gsl-cdf-tdist-p x nu))))
  ;; function gsl-cdf-tdist-q for c-function "gsl_cdf_tdist_Q".
  (declaim (ftype (function (t t) (values (alien double) &optional)) gsl-cdf-tdist-q))
  (defun gsl-cdf-tdist-q (x nu)
    (with-alien ((gsl-cdf-tdist-q (function double double double)
                                  :extern "gsl_cdf_tdist_Q"))
      (values (alien-funcall gsl-cdf-tdist-q x nu))))
  ;; function gsl-cdf-tdist-pinv for c-function "gsl_cdf_tdist_Pinv".
  (declaim (ftype (function (t t) (values (alien double) &optional)) gsl-cdf-tdist-pinv))
  (defun gsl-cdf-tdist-pinv (p nu)
    (with-alien ((gsl-cdf-tdist-pinv (function double double double)
                                     :extern "gsl_cdf_tdist_Pinv"))
      (values (alien-funcall gsl-cdf-tdist-pinv p nu))))
  ;; function gsl-cdf-tdist-qinv for c-function "gsl_cdf_tdist_Qinv".
  (declaim (ftype (function (t t) (values (alien double) &optional)) gsl-cdf-tdist-qinv))
  (defun gsl-cdf-tdist-qinv (q nu)
    (with-alien ((gsl-cdf-tdist-qinv (function double double double)
                                     :extern "gsl_cdf_tdist_Qinv"))
      (values (alien-funcall gsl-cdf-tdist-qinv q nu)))))

;;; Spherical Vector Deistributions
;;;
;;; The spherical distributions generate random vectors located on a spherical surface.
;;; They can be used as random directions, for example in the steps of a random walk.

;;; (gsl-ran-dir-2d rng x y)
;;; (gsl-ran-dir-2d-trig-method rng x y)
;;;   This function returns a random direction vector v = (x, y) in two dimensions. The
;;;   vector is normalized such that |v|^2 = x^2 + y^2 = 1. The obvious way to do this is
;;;   to take a uniform random number between 0 and 2 * pi and let x and y be the sine
;;;   and cosine respectively. Two trig functions would have been expensive in the old
;;;   days, but with modern hardware implementations, this is sometimes the fastest way
;;;   to go. This is the case for the Pentium (but not the case for the Sum Sparcstation).
;;;   One can avoid the trig evaluations by choosing x and y in the interior of a unit
;;;   circle (choose them at random from the interior of the enclosing square, and then
;;;   reject those that are outside the unit circle), and dividing by sqrt(x^2 + y^2).
(define-alien-routine gsl-ran-dir-2d
    void
  (rng (* (struct gsl-rng)))
  (x (* double))
  (y (* double)))

(define-alien-routine gsl-ran-dir-2d-trig-method
    void
  (rng (* (struct gsl-rng)))
  (x (* double))
  (y (* double)))

;;; (test-gsl-ran)
;;;   This function do tests.
(defun test-gsl-ran ()
  ;; A random walk.
  (let ((x 0.0d0)
        (y 0.0d0))
    (format t "~,5F ~,5F~%" x y)
    (with-alien ((rng-type (* (struct gsl-rng-type)))
                          (rng (* (struct gsl-rng))))
      (gsl-rng-env-setup)
      (setf rng-type gsl-rng-default)
      (setf rng (gsl-rng-alloc rng-type))
      (let ((dx (make-alien double))
            (dy (make-alien double)))
        (dotimes (i 50)
          (sb-gsl-ran:gsl-ran-dir-2d rng dx dy)
          (setf x (+ x (deref dx)))
          (setf y (+ y (deref dy)))
          (format t "~,5F ~,5F~%" x y)))
      (gsl-rng-free rng))))
