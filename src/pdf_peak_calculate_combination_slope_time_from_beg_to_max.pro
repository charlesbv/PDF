; Licensed to the Apache Software Foundation (ASF) under one
; or more contributor license agreements.  See the NOTICE file
; distributed with this work for additional information
; regarding copyright ownership.  The ASF licenses this file
; to you under the Apache License, Version 2.0 (the
; "License"); you may not use this file except in compliance
; with the License.  You may obtain a copy of the License at

;   http://www.apache.org/licenses/LICENSE-2.0

; Unless required by applicable law or agreed to in writing,
; software distributed under the License is distributed on an
; "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
; KIND, either express or implied.  See the License for the
; specific language governing permissions and limitations
; under the License.
;+
; NAME: pdf_peak_calculate_combination_slope_time_from_beg_to_max.pro 
;
; PURPOSE:
; Predicts the ascending phase of the peak combining method 1 (PDF of
; the amplitude of the peak as a function of the max slope in the peak) and
; method 2 (PDF of the time between the beginning of the peak and its max). 
;
; CALLING SEQUENCE:
; pdf_peak_calculate_slope_ge_30_based_on_max_slope, pdf_peak_calculate_slope_ge_30_based_on_time_from_beginning_to_max;
;
; INPUTS:
; PARAMETER = parameter to be predicted (ex: speed)
; PARAM_AVERAGE_OK_FROM_START_OF_PEAK_TO_NOW = speed from start of the
; peak to the current time
; X_DIST_SLOPE_PDF_EXTRAPOLATED = x axis of the PDF of the amplitude
; of the peak as a function of the max slope in the peak
; DIST_SLOPE_PDF_EXTRAPOLATED = PDF of the amplitude                                                                             
; of the peak as a function of the max slope in the peak 
; X_DIST_SLOPE_GAUSS_EXTRAPOLATED = x axis gaussian distribution of
; the amplitude of the peak as a function of the max slope in the peak 
; DIST_SLOPE_GAUSS_EXTRAPOLATED = gaussian distribution of the
; amplitude of the peak as a function of the max slope in the peak 
; X_HIST_TIME_FROM_MIN_TO_MAX_PEAK_EXTRAPOLATED = x axis of the PDF of
; the time between the beginning of the peak and its max
; HIST_TIME_FROM_MIN_TO_MAX_PEAK_PERCENTAGE_EXTRAPOLATED = PDF of
; the time between the beginning of the peak and its max
;
;
; KEYWORD PARAMETERS:
; calculate_ensemble = 0 to get only the median
; prediction, 1 to get the  10%, 25%, 75% and 90% quadratiles predictions as well 
;
; OUTPUTS:
; TIME_MAX_FROM_NOW_MEDIAN = time between the current time and the max
; predicted by the median
; TIME_MAX_FROM_NOW_MP = time between the current time and the max                                                                           
; predicted by the most probable value of the PDF (not used)
; TIME_MAX_FROM_NOW_ENSEMBLE = time between the current time and the
; max predicted by the quadratiles (10%, 25%, 75%, 90%) = vector 4*1
; PEAK_PREDICTED_MEDIAN = prediction of the  ascending phase of the
; peak by the combination of models 1 and 2 - median of the PDFs
; PEAK_PREDICTED_MP = prediction of the  ascending phase of the
; peak by the combination of models 1 and 2 - most probable value of
;                                             the PDFs (not used)
; PEAK_PREDICTED_ENSEMBLE = prediction of the  ascending phase of the
; peak by the combination of models 1 and 2 - quadratiles (10%, 25%,
;                                             75%, 90%) of the PDFs
; MAX_PEAK_PREDICTED_MEDIAN = value at the max of the predicted peak
; (with PDFs median)
; MAX_PEAK_PREDICTED_MP = value at the max of the predicted peak
; (with PDFs most probable value) (not used)
; TIME_MAX_FROM_NOW_MEDIAN_METHOD_SLOPE = time between the current
; time and the max of the peak as predicted by method 1 (PDF of
; the amplitude of the peak as a function of the max slope in the peak)
; TIME_MAX_FROM_NOW_MEDIAN_METHOD_BEG_TO_MAX = time between the current
; time and the max of the peak as predicted by method 2 (PDF of the
; time between the beginning of the peak and its max - median value of
;                                                      the PDF)
; TIME_MAX_FROM_NOW_MP_METHOD_BEG_TO_MAX = time between the current
; time and the max of the peak as predicted by method 2 (PDF of the
; time between the beginning of the peak and its max - most probable
;                                                      value of the PDF)
;
; MODIFICATION HISTORY: 04-07-2015 by Charles Bussy-Virat
;
;-



pro pdf_peak_calculate_combination_slope_time_from_beg_to_max, parameter, param_average_ok_from_start_of_peak_to_now, $
   x_dist_slope_pdf_extrapolated, dist_slope_pdf_extrapolated,$
   x_dist_slope_gauss_extrapolated, dist_slope_gauss_extrapolated,$
   x_hist_time_from_min_to_max_peak_extrapolated, hist_time_from_min_to_max_peak_percentage_extrapolated,$
   time_max_from_now_median,time_max_from_now_mp,time_max_from_now_ensemble,$
   peak_predicted_median,peak_predicted_mp,peak_predicted_ensemble, $
   max_peak_predicted_median,max_peak_predicted_mp,time_max_from_now_median_method_slope,time_max_from_now_median_method_beg_to_max,time_max_from_now_mp_method_beg_to_max, calculate_ensemble = calculate_ensemble_keyword


  if keyword_set(calculate_ensemble_keyword) eq 1 then begin
;; prediction with method 1
     pdf_peak_calculate_slope_ge_30_based_on_max_slope, parameter,param_average_ok_from_start_of_peak_to_now, $
        x_dist_slope_pdf_extrapolated, dist_slope_pdf_extrapolated,$
        x_dist_slope_gauss_extrapolated, dist_slope_gauss_extrapolated,$
        time_max_from_now_median_method_slope,time_max_from_now_ensemble_method_slope,$
        max_peak_predicted_median_method_slope,max_peak_predicted_ensemble_method_slope, calculate_ensemble = 1

;; prediction with method 2
     pdf_peak_calculate_slope_ge_30_based_on_time_from_beginning_to_max, parameter, param_average_ok_from_start_of_peak_to_now,$
        x_hist_time_from_min_to_max_peak_extrapolated, hist_time_from_min_to_max_peak_percentage_extrapolated,$
        time_max_from_now_median_method_beg_to_max,time_max_from_now_mp_method_beg_to_max,time_max_from_now_ensemble_method_beg_to_max, $
        max_peak_predicted_median_method_beg_to_max,max_peak_predicted_mp_method_beg_to_max,max_peak_predicted_ensemble_method_beg_to_max, calculate_ensemble = 1


     maximum_time_ensemble_between_time_max_from_now_ensemble_method_slope_and_time_max_from_now_ensemble_method_beg_to_max = max([max(time_max_from_now_ensemble_method_slope),max(time_max_from_now_ensemble_method_beg_to_max)])

     peak_predicted_ensemble = fltarr( n_elements(time_max_from_now_ensemble_method_beg_to_max),maximum_time_ensemble_between_time_max_from_now_ensemble_method_slope_and_time_max_from_now_ensemble_method_beg_to_max ) 

     max_peak_predicted_ensemble = fltarr(n_elements(time_max_from_now_ensemble_method_beg_to_max))
     time_max_from_now_ensemble = fltarr(n_elements(time_max_from_now_ensemble_method_beg_to_max))


  endif else begin
;; prediction with method 1
     pdf_peak_calculate_slope_ge_30_based_on_max_slope, parameter, param_average_ok_from_start_of_peak_to_now, $
        x_dist_slope_pdf_extrapolated, dist_slope_pdf_extrapolated,$
        x_dist_slope_gauss_extrapolated, dist_slope_gauss_extrapolated,$
        time_max_from_now_median_method_slope,time_max_from_now_ensemble_method_slope,$
        max_peak_predicted_median_method_slope,max_peak_predicted_ensemble_method_slope, calculate_ensemble = 0
     
;; prediction with method 2
     pdf_peak_calculate_slope_ge_30_based_on_time_from_beginning_to_max, parameter, param_average_ok_from_start_of_peak_to_now,$
        x_hist_time_from_min_to_max_peak_extrapolated, hist_time_from_min_to_max_peak_percentage_extrapolated,$
        time_max_from_now_median_method_beg_to_max,time_max_from_now_mp_method_beg_to_max,time_max_from_now_ensemble_method_beg_to_max, $
        max_peak_predicted_median_method_beg_to_max,max_peak_predicted_mp_method_beg_to_max,max_peak_predicted_ensemble_method_beg_to_max, calculate_ensemble = 0

  endelse


  step_slope = 2.0 ;; this parameter has been used to calculate the slope (slope(now) = ( speed(now+step_slope/2.0) - speed(now-step_slope/2.0) ) / step_slope)


;; ;; ;;;;;;;;;;;;;;;;;;  OPTION 1: MEDIAN
  det_a = 0.0
  percentage_speed_at_x3 = 75.0
  percentage_speed_at_x3_normalized = percentage_speed_at_x3 / 100.0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; ORDER 3 80% - THEN ORDER 3 80%-100% ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  if time_max_from_now_median_method_slope le time_max_from_now_median_method_beg_to_max then begin ;; (that is the case most of the time)
;;;;;;;;;;;;;;;;;;;;;;;; ORDER 3  80% ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;; ;;;;;;;; SYSTEM TO SOLVE TO GET THE PARABOLA ;;;;;;;;;;;;;;;;;;
;; ;;; ;;; f(x) = a*x^3 + b*x^2 + c*x + d
;; ;;; ;;; f'(x) = 3*a*x^2 + 2*b*x + c
;; ;;; ;;; x1 = 0 (now)
;; ;;; ;;; x3 = time_max_from_now_median_method_slope 
;; ;;; ;;; f(x1) = param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) (speed now)
;; ;;; ;;; f(x3) =  max_peak_predicted_median_method_slope - (1-percentage_speed_at_x3) * (max_peak_predicted_median_method_slope - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) (the speed at x3 is 80% of the jump (jump = max of the peak - speed(now))
;; ;;; ;;; f'(x1) = ( f(x1) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 - step_slope) ) / step_slope the slope is continuous
;; ;;; ;;; f'(x3) =   (1-percentage_speed_at_x3) * (max_peak_predicted_median_method_slope - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / ( time_max_from_now_median_method_beg_to_max - time_max_from_now_median_method_slope ) ;;; the slope at x3 is the same as a linear increase from f(x3) to f(x2), ie f'(x3) = (f(x2) - f(x3)) / (x2 - x3)

     if time_max_from_now_median_method_slope gt 1 then begin
        a_syst_median = [ [0,0,0,1 ],$ ;; f(x1)
                          [(time_max_from_now_median_method_slope-1)^3.0 ,(time_max_from_now_median_method_slope-1)^2.0, (time_max_from_now_median_method_slope-1),1 ], $ ;; f(x3)
                          [ 0,0, 1,0 ],$                                                                                          ;; f'(x1)
                          [ 3*(time_max_from_now_median_method_slope-1)^2.0, 2*(time_max_from_now_median_method_slope-1), 1,0 ] ] ;; f'(x3)
        b_syst_median = [ param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ), $ ;; f(x1)
                          max_peak_predicted_median_method_slope - (1 - percentage_speed_at_x3_normalized) * (max_peak_predicted_median_method_slope - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ), $ ;; f(x3)
                          ( param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 - step_slope) ) / step_slope,$ ;; f'(x1)
                          (1-percentage_speed_at_x3_normalized) * (max_peak_predicted_median_method_slope - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / ( time_max_from_now_median_method_beg_to_max - time_max_from_now_median_method_slope ) /2 ] ;; f'(x3)   (the /2 at the very end is to look nicer)

        if determ(a_syst_median) ne 0 then begin
   
           result_syst_median = la_linear_equation(a_syst_median, b_syst_median,/double,zero =zero)        
           x_peak_predicted_median_method_slope = dindgen(time_max_from_now_median_method_slope)
           peak_predicted_median_method_slope = fltarr(time_max_from_now_median_method_slope)
           peak_predicted_median_method_slope = result_syst_median(0) * x_peak_predicted_median_method_slope^3.0 + result_syst_median(1) * x_peak_predicted_median_method_slope^2.0 + result_syst_median(2)*x_peak_predicted_median_method_slope + result_syst_median(3) 

           if time_max_from_now_median_method_slope ge 3 then begin
              deriv_function = deriv(x_peak_predicted_median_method_slope,peak_predicted_median_method_slope)
          ;;    print,'DERIV X3',$
                 ;;    deriv_function(time_max_from_now_median_method_slope-1),$
;;                     result_syst_median(0) *3* x_peak_predicted_median_method_slope(time_max_from_now_median_method_slope-1)^2.0 + result_syst_median(1) *2* x_peak_predicted_median_method_slope(time_max_from_now_median_method_slope-1) + result_syst_median(2)
           endif
        endif else det_a = -1000000.0



;;;;;;;;;;;;;;;;;;;;;;;; ORDER  3  80% - 100%;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; ;;;;;;;; SYSTEM TO SOLVE TO GET THE PARABOLA ;;;;;;;;;;;;;;;;;;
;;; ;;; f(x) = a*x^3 + b*x^2.0 + c*x + d
;;; ;;; f'(x) = 3*a*x^2 + 2*b*x + c 
;;; ;;;  x3 = time_max_from_now_median_method_slope 
;;; ;;; x2 = time_max_from_now_median_method_beg_to_max (position of the max of the peak) 
;;; ;;; f(x3) =  max_peak_predicted_median_method_slope - (1-percentage_speed_at_x3) * (max_peak_predicted_median_method_slope - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) (the speed at x3 is 80% of the jump (jump = max of the peak - speed(now))
;;; ;;; f(x2) = max_peak_predicted_median_method_slope (speed at the max of the peak) 
;;; ;;; f'(x3) =   (1-percentage_speed_at_x3) * (max_peak_predicted_median_method_slope - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / ( time_max_from_now_median_method_beg_to_max - time_max_from_now_median_method_slope ) ;;; the slope at x3 is the same as a linear increase from f(x3) to f(x2), ie f'(x3) = (f(x2) - f(x3)) / (x2 - x3)
        ;; We also tried the foloowing but it did not look nice: ( f(x3) - f(x3 - step_slope) ) / step_slope ;;      the slope is continuous at x3
;;; ;;; f'(x2) = 0 (the slope is 0 at the max)

        if det_a gt -10000.0 then begin
           a_syst_median = [ [(time_max_from_now_median_method_slope-1)^3.0 ,(time_max_from_now_median_method_slope-1)^2.0, (time_max_from_now_median_method_slope-1),1 ],$ ;; f(x3)
                             [ (time_max_from_now_median_method_beg_to_max-1)^3.0, (time_max_from_now_median_method_beg_to_max-1)^2.0, (time_max_from_now_median_method_beg_to_max-1),1 ], $ ;; f(x2)
                             [ 3*(time_max_from_now_median_method_slope-1)^2.0, 2*(time_max_from_now_median_method_slope-1), 1,0 ],$ ;; f'(x3)
                             [ 3*(time_max_from_now_median_method_beg_to_max-1)^2.0, 2*(time_max_from_now_median_method_beg_to_max-1), 1,0 ]] ;; f'(x2)

           b_syst_median = [ peak_predicted_median_method_slope(time_max_from_now_median_method_slope-1) , $ ;; f(x3)
                             max_peak_predicted_median_method_slope , $                                      ;; f(x2)
                             (1-percentage_speed_at_x3_normalized) * (max_peak_predicted_median_method_slope - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / ( time_max_from_now_median_method_beg_to_max - time_max_from_now_median_method_slope )*2.0 ,$ ;; f'(x3)    (the very last *2 is to make it nice)
                             0 ] ;; f'(x2)
           
           if determ(a_syst_median) ne 0 then begin
              result_syst_median = la_linear_equation(a_syst_median, b_syst_median,/double,zero =zero)
              
              x_peak_predicted_median_method_beg_to_max = dindgen(time_max_from_now_median_method_beg_to_max-time_max_from_now_median_method_slope)+time_max_from_now_median_method_slope
              peak_predicted_median_method_beg_to_max = fltarr(time_max_from_now_median_method_beg_to_max-time_max_from_now_median_method_slope)
              peak_predicted_median_method_beg_to_max = result_syst_median(0) * x_peak_predicted_median_method_beg_to_max^3.0 + result_syst_median(1) * x_peak_predicted_median_method_beg_to_max^2.0 + result_syst_median(2) * x_peak_predicted_median_method_beg_to_max + result_syst_median(3)


              x_peak_predicted_median = dindgen(time_max_from_now_median_method_beg_to_max)
              peak_predicted_median = fltarr(time_max_from_now_median_method_beg_to_max)
              peak_predicted_median = [peak_predicted_median_method_slope,peak_predicted_median_method_beg_to_max]


              time_max_from_now_median = time_max_from_now_median_method_beg_to_max
              max_peak_predicted_median = max_peak_predicted_median_method_slope

           endif else begin           
              time_max_from_now_median = 0.0
           endelse
           
        endif else begin 

           time_max_from_now_median = 0.0

        endelse

     endif else begin

        time_max_from_now_median = 0.0

     endelse

  endif



  if time_max_from_now_median_method_slope gt time_max_from_now_median_method_beg_to_max then begin 

;;;;;;;;;;;;;;;;;;;;;;;; ORDER 3  80% ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;; ;;;;;;;; SYSTEM TO SOLVE TO GET THE PARABOLA ;;;;;;;;;;;;;;;;;;
;; ;;; ;;; f(x) = a*x^3 + b*x^2 + c*x + d
;; ;;; ;;; f'(x) = 3*a*x^2 + 2*b*x + c
;; ;;; ;;; x1 = 0 (now)
;; ;;; ;;; x2 = time_max_from_now_median_method_beg_to_max
;; ;;; ;;; f(x1) = param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) (speed now)
;; ;;; ;;; f(x2) = max_peak_predicted_median_method_beg_to_max - (1-percentage_speed_at_x3) * (max_peak_predicted_median_method_beg_to_max - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) (the speed at x2 is 80% of the jump (jump = max of the peak - speed(now))
;; ;;; ;;; f'(x1) = ( f(x1) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 - step_slope) ) / step_slope (the slope is continuous)
;; ;;; ;;; f'(x2) =   (1-percentage_speed_at_x3) * (max_peak_predicted_median_method_beg_to_max - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / ( time_max_from_now_median_method_slope - time_max_from_now_median_method_beg_to_max ) ;;; the slope at x2 is the same as a linear increase from f(x2) to f(x3), ie f'(x2) = (f(x2) - f(x3)) / (x2 - x3)

     if time_max_from_now_median_method_beg_to_max gt 1 then begin
        a_syst_median = [ [0,0,0,1 ],$ ;; f(x1)
                          [(time_max_from_now_median_method_beg_to_max-1)^3.0 ,(time_max_from_now_median_method_beg_to_max-1)^2.0, (time_max_from_now_median_method_beg_to_max-1),1 ], $ ;; f(x2)
                          [ 0,0, 1,0 ],$                                                                                        ;; f'(x1)
                          [ 3*(time_max_from_now_median_method_beg_to_max-1)^2.0, 2*(time_max_from_now_median_method_beg_to_max-1), 1,0 ] ] ;; f'(x2)

        b_syst_median = [ param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ), $ ;; f(x1)
                          max_peak_predicted_median_method_beg_to_max - (1 - percentage_speed_at_x3_normalized) * (max_peak_predicted_median_method_beg_to_max - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ), $ ;; f(x2)
                          ( param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 - step_slope) ) / step_slope,$ ;; f'(x1)
                          (1-percentage_speed_at_x3_normalized) * (max_peak_predicted_median_method_beg_to_max - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / ( time_max_from_now_median_method_slope - time_max_from_now_median_method_beg_to_max ) /2] ;; f'(x2)   (the very last /2 is to make it nicer)

        if determ(a_syst_median) ne 0 then begin

           result_syst_median = la_linear_equation(a_syst_median, b_syst_median,/double,zero =zero)        
           x_peak_predicted_median_method_beg_to_max = dindgen(time_max_from_now_median_method_beg_to_max)
           peak_predicted_median_method_beg_to_max = fltarr(time_max_from_now_median_method_beg_to_max)
           peak_predicted_median_method_beg_to_max = result_syst_median(0) * x_peak_predicted_median_method_beg_to_max^3.0 + result_syst_median(1) * x_peak_predicted_median_method_beg_to_max^2.0 + result_syst_median(2)*x_peak_predicted_median_method_beg_to_max + result_syst_median(3) 

           if time_max_from_now_median_method_beg_to_max ge 3. then begin
              deriv_function = deriv(x_peak_predicted_median_method_beg_to_max,peak_predicted_median_method_beg_to_max)
          ;;     print,'DERIV X3',$
;;                     deriv_function(time_max_from_now_median_method_beg_to_max-1),$
;;                     result_syst_median(0) *3* x_peak_predicted_median_method_beg_to_max(time_max_from_now_median_method_beg_to_max-1)^2.0 + result_syst_median(1) *2* x_peak_predicted_median_method_beg_to_max(time_max_from_now_median_method_beg_to_max-1) + result_syst_median(2)

           endif
        endif else det_a = -1000000.0

;;;;;;;;;;;;;;;;;;;;;;;; ORDER  3  80% - 100%;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; ;;;;;;;; SYSTEM TO SOLVE TO GET THE PARABOLA ;;;;;;;;;;;;;;;;;;
;;; ;;; f(x) = a*x^3 + b*x^2.0 + c*x + d
;;; ;;; f'(x) = 3*a*x^2 + 2*b*x + c 
;;; ;;;  x3 = time_max_from_now_median_method_slope (position of the max of the peak) 
;;; ;;; x2 = time_max_from_now_median_method_beg_to_max 
;; ;;; ;;; f(x2) = max_peak_predicted_median_method_beg_to_max - (1-percentage_speed_at_x3) * (max_peak_predicted_median_method_beg_to_max - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) (the speed at x2 is 80% of the jump (jump = max of the peak - speed(now))
;;; ;;; f(x3) = max_peak_predicted_median_method_beg_to_max (speed at the max of the peak) 
;; ;;; ;;; f'(x2) =   (1-percentage_speed_at_x3) * (max_peak_predicted_median_method_beg_to_max - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / ( time_max_from_now_median_method_slope - time_max_from_now_median_method_beg_to_max ) ;;; the slope at x2 is the same as a linear increase from f(x2) to f(x3), ie f'(x2) = (f(x2) - f(x3)) / (x2 - x3)
        ;; We also tried the foloowing but it did not look nice: ( f(x3) - f(x3 - step_slope) ) / step_slope ;;      the slope is continuous at x3
;;; ;;; f'(x3) = 0 (the slope is 0 at the max)

        if det_a gt -10000.0 then begin
           a_syst_median = [ [(time_max_from_now_median_method_slope-1)^3.0 ,(time_max_from_now_median_method_slope-1)^2.0, (time_max_from_now_median_method_slope-1),1 ],$ ;; f(x3)
                             [ (time_max_from_now_median_method_beg_to_max-1)^3.0, (time_max_from_now_median_method_beg_to_max-1)^2.0, (time_max_from_now_median_method_beg_to_max-1),1 ], $ ;; f(x2)
                             [ 3*(time_max_from_now_median_method_slope-1)^2.0, 2*(time_max_from_now_median_method_slope-1), 1,0 ],$ ;; f'(x3)
                             [ 3*(time_max_from_now_median_method_beg_to_max-1)^2.0, 2*(time_max_from_now_median_method_beg_to_max-1), 1,0 ]] ;; f'(x2)

           b_syst_median = [ max_peak_predicted_median_method_beg_to_max , $                                                   ;; f(x3)
                             peak_predicted_median_method_beg_to_max(time_max_from_now_median_method_beg_to_max-1) , $         ;; f(x2)
                             0 ,$                                                                                              ;; f'(x3)   
                             (1-percentage_speed_at_x3_normalized) * (max_peak_predicted_median_method_beg_to_max - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / ( time_max_from_now_median_method_slope - time_max_from_now_median_method_beg_to_max ) *2 ] ;; f'(x2) (the very last *2 is to make it nicer)
           
           if determ(a_syst_median) ne 0 then begin 
              result_syst_median = la_linear_equation(a_syst_median, b_syst_median,/double,zero =zero)
              
              x_peak_predicted_median_method_slope = dindgen(time_max_from_now_median_method_slope-time_max_from_now_median_method_beg_to_max)+time_max_from_now_median_method_beg_to_max
              peak_predicted_median_method_slope = fltarr(time_max_from_now_median_method_slope-time_max_from_now_median_method_beg_to_max)
              peak_predicted_median_method_slope = result_syst_median(0) * x_peak_predicted_median_method_slope^3.0 + result_syst_median(1) * x_peak_predicted_median_method_slope^2.0 + result_syst_median(2) * x_peak_predicted_median_method_slope + result_syst_median(3)


              x_peak_predicted_median = dindgen(time_max_from_now_median_method_slope)
              peak_predicted_median = fltarr(time_max_from_now_median_method_slope)
              peak_predicted_median = [peak_predicted_median_method_beg_to_max,peak_predicted_median_method_slope]

              time_max_from_now_median = time_max_from_now_median_method_slope
              max_peak_predicted_median = max_peak_predicted_median_method_beg_to_max

           endif else begin
              time_max_from_now_median = 0.0
           endelse

        endif else begin
           time_max_from_now_median = 0.0
        endelse


     endif else begin

        time_max_from_now_median = 0.0

     endelse


  endif



;; ;; ;;;;;;;;;;;;;;;;;; OPTION 2: MOST PROBABLE
;;   det_a = 0.0
;;   percentage_speed_at_x3 = 75.0
;;   percentage_speed_at_x3_normalized = percentage_speed_at_x3 / 100.0


;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;;;;;;;;;;;;;;;;;;;;;;; ORDER 3 80% - THEN ORDER 3 80%-100% ;;;;;;;;;;;;;;;;;;
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;   if time_max_from_now_median_method_slope le time_max_from_now_mp_method_beg_to_max then begin ;; (that is the case most of the time)

;; ;;      print,''
;; ;;      print,'x3<x2'
;; ;;      print,''


;; ;;;;;;;;;;;;;;;;;;;;;;;; ORDER 3  80% ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;; ;; ;;;;;;;; SYSTEM TO SOLVE TO GET THE PARABOLA ;;;;;;;;;;;;;;;;;;
;; ;; ;;; ;;; f(x) = a*x^3 + b*x^2 + c*x + d
;; ;; ;;; ;;; f'(x) = 3*a*x^2 + 2*b*x + c
;; ;; ;;; ;;; x1 = 0 (now)
;; ;; ;;; ;;; x3 = time_max_from_now_median_method_slope 
;; ;; ;;; ;;; f(x1) = param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) (speed now)
;; ;; ;;; ;;; f(x3) =  max_peak_predicted_median_method_slope - (1-percentage_speed_at_x3) * (max_peak_predicted_median_method_slope - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) (the speed at x3 is 80% of the jump (jump = max of the peak - speed(now))
;; ;; ;;; ;;; f'(x1) = ( f(x1) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 - step_slope) ) / step_slope the slope is continuous
;; ;; ;;; ;;; f'(x3) =   (1-percentage_speed_at_x3) * (max_peak_predicted_median_method_slope - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / ( time_max_from_now_mp_method_beg_to_max - time_max_from_now_median_method_slope ) ;;; the slope at x3 is the same as a linear increase from f(x3) to f(x2), ie f'(x3) = (f(x2) - f(x3)) / (x2 - x3)

;;      if time_max_from_now_median_method_slope gt 1 then begin
;;         a_syst_mp = [ [0,0,0,1 ],$ ;; f(x1)
;;                       [(time_max_from_now_median_method_slope-1)^3.0 ,(time_max_from_now_median_method_slope-1)^2.0, (time_max_from_now_median_method_slope-1),1 ], $ ;; f(x3)
;;                       [ 0,0, 1,0 ],$                                                                                              ;; f'(x1)
;;                       [ 3*(time_max_from_now_median_method_slope-1)^2.0, 2*(time_max_from_now_median_method_slope-1), 1,0 ] ]     ;; f'(x3)
;;         b_syst_mp = [ param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ), $ ;; f(x1)
;;                       max_peak_predicted_median_method_slope - (1 - percentage_speed_at_x3_normalized) * (max_peak_predicted_median_method_slope - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ), $ ;; f(x3)
;;                       ( param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 - step_slope) ) / step_slope,$ ;; f'(x1)
;;                       (1-percentage_speed_at_x3_normalized) * (max_peak_predicted_median_method_slope - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / ( time_max_from_now_mp_method_beg_to_max - time_max_from_now_median_method_slope ) /2 ] ;; f'(x3)   (the /2 at the very end is to look nicer)

;;         if determ(a_syst_mp) ne 0 then begin
;;            result_syst_mp = la_linear_equation(a_syst_mp, b_syst_mp,/double,zero =zero)        
;;            x_peak_predicted_median_method_slope = dindgen(time_max_from_now_median_method_slope)
;;            peak_predicted_median_method_slope = fltarr(time_max_from_now_median_method_slope)
;;            peak_predicted_median_method_slope = result_syst_mp(0) * x_peak_predicted_median_method_slope^3.0 + result_syst_mp(1) * x_peak_predicted_median_method_slope^2.0 + result_syst_mp(2)*x_peak_predicted_median_method_slope + result_syst_mp(3) 

;;            if time_max_from_now_median_method_slope ge 3 then begin
;;               deriv_function = deriv(x_peak_predicted_median_method_slope,peak_predicted_median_method_slope)
;;            ;;    print,'DERIV X3',$
;; ;;                     deriv_function(time_max_from_now_median_method_slope-1),$
;; ;;                     result_syst_mp(0) *3* x_peak_predicted_median_method_slope(time_max_from_now_median_method_slope-1)^2.0 + result_syst_mp(1) *2* x_peak_predicted_median_method_slope(time_max_from_now_median_method_slope-1) + result_syst_mp(2)
;;            endif

;;         endif else det_a = -1000000.0

;; ;;;;;;;;;;;;;;;;;;;;;;;; ORDER  3  80% - 100%;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; ;; ;;;;;;;; SYSTEM TO SOLVE TO GET THE PARABOLA ;;;;;;;;;;;;;;;;;;
;; ;;; ;;; f(x) = a*x^3 + b*x^2.0 + c*x + d
;; ;;; ;;; f'(x) = 3*a*x^2 + 2*b*x + c 
;; ;;; ;;;  x3 = time_max_from_now_median_method_slope 
;; ;;; ;;; x2 = time_max_from_now_mp_method_beg_to_max (position of the max of the peak) 
;; ;;; ;;; f(x3) =  max_peak_predicted_median_method_slope - (1-percentage_speed_at_x3) * (max_peak_predicted_median_method_slope - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) (the speed at x3 is 80% of the jump (jump = max of the peak - speed(now))
;; ;;; ;;; f(x2) = max_peak_predicted_median_method_slope (speed at the max of the peak) 
;; ;;; ;;; f'(x3) =   (1-percentage_speed_at_x3) * (max_peak_predicted_median_method_slope - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / ( time_max_from_now_mp_method_beg_to_max - time_max_from_now_median_method_slope ) ;;; the slope at x3 is the same as a linear increase from f(x3) to f(x2), ie f'(x3) = (f(x2) - f(x3)) / (x2 - x3)
;;         ;; We also tried the foloowing but it did not look nice: ( f(x3) - f(x3 - step_slope) ) / step_slope ;;      the slope is continuous at x3
;; ;;; ;;; f'(x2) = 0 (the slope is 0 at the max)

;;         if det_a gt -10000.0 then begin
;;            a_syst_mp = [ [(time_max_from_now_median_method_slope-1)^3.0 ,(time_max_from_now_median_method_slope-1)^2.0, (time_max_from_now_median_method_slope-1),1 ],$ ;; f(x3)
;;                          [ (time_max_from_now_mp_method_beg_to_max-1)^3.0, (time_max_from_now_mp_method_beg_to_max-1)^2.0, (time_max_from_now_mp_method_beg_to_max-1),1 ], $ ;; f(x2)
;;                          [ 3*(time_max_from_now_median_method_slope-1)^2.0, 2*(time_max_from_now_median_method_slope-1), 1,0 ],$      ;; f'(x3)
;;                          [ 3*(time_max_from_now_mp_method_beg_to_max-1)^2.0, 2*(time_max_from_now_mp_method_beg_to_max-1), 1,0 ]]     ;; f'(x2)

;;            b_syst_mp = [ peak_predicted_median_method_slope(time_max_from_now_median_method_slope-1) , $     ;; f(x3)
;;                          max_peak_predicted_median_method_slope , $                                          ;; f(x2)
;;                          (1-percentage_speed_at_x3_normalized) * (max_peak_predicted_median_method_slope - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / ( time_max_from_now_mp_method_beg_to_max - time_max_from_now_median_method_slope )*2.0 ,$ ;; f'(x3)    (the very last *2 is to make it nice)
;;                          0 ] ;; f'(x2)
           
;;            if determ(a_syst_mp) ne 0 then begin

;;               result_syst_mp = la_linear_equation(a_syst_mp, b_syst_mp,/double,zero =zero)
              
;;               x_peak_predicted_mp_method_beg_to_max = dindgen(time_max_from_now_mp_method_beg_to_max-time_max_from_now_median_method_slope)+time_max_from_now_median_method_slope
;;               peak_predicted_mp_method_beg_to_max = fltarr(time_max_from_now_mp_method_beg_to_max-time_max_from_now_median_method_slope)
;;               peak_predicted_mp_method_beg_to_max = result_syst_mp(0) * x_peak_predicted_mp_method_beg_to_max^3.0 + result_syst_mp(1) * x_peak_predicted_mp_method_beg_to_max^2.0 + result_syst_mp(2) * x_peak_predicted_mp_method_beg_to_max + result_syst_mp(3)


;;               x_peak_predicted_mp = dindgen(time_max_from_now_mp_method_beg_to_max)
;;               peak_predicted_mp = fltarr(time_max_from_now_mp_method_beg_to_max)
;;               peak_predicted_mp = [peak_predicted_median_method_slope,peak_predicted_mp_method_beg_to_max]


;;               time_max_from_now_mp = time_max_from_now_mp_method_beg_to_max
;;               max_peak_predicted_mp = max_peak_predicted_median_method_slope

;;   ;;             print,'TIME_max_from_now_mp',time_max_from_now_mp
;; ;;               print,'MAX_peak_predicted_median_method_slope',max_peak_predicted_median_method_slope,max(peak_predicted_mp)
;;            endif else begin

;;           ;;    print, 'The predicted mp amplitude is smaller than the speed now'
;;               time_max_from_now_mp = 0.0
;;            endelse

;;         endif else begin

;; ;;           print, 'The predicted mp amplitude is smaller than the speed now'
;;            time_max_from_now_mp = 0.0
;;         endelse
        
        
;;      endif else begin


;;        ;; print, 'The predicted mp amplitude is smaller than the speed now'
;;         time_max_from_now_mp = 0.0

;;      endelse
;;   endif


;;   if time_max_from_now_median_method_slope gt time_max_from_now_mp_method_beg_to_max then begin 


;; ;;      print,''
;; ;;      print,'x3>x2'
;; ;;      print,''


;; ;;;;;;;;;;;;;;;;;;;;;;;; ORDER 3  80% ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;; ;; ;;;;;;;; SYSTEM TO SOLVE TO GET THE PARABOLA ;;;;;;;;;;;;;;;;;;
;; ;; ;;; ;;; f(x) = a*x^3 + b*x^2 + c*x + d
;; ;; ;;; ;;; f'(x) = 3*a*x^2 + 2*b*x + c
;; ;; ;;; ;;; x1 = 0 (now)
;; ;; ;;; ;;; x2 = time_max_from_now_mp_method_beg_to_max
;; ;; ;;; ;;; f(x1) = param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) (speed now)
;; ;; ;;; ;;; f(x2) = max_peak_predicted_mp_method_beg_to_max - (1-percentage_speed_at_x3) * (max_peak_predicted_mp_method_beg_to_max - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) (the speed at x2 is 80% of the jump (jump = max of the peak - speed(now))
;; ;; ;;; ;;; f'(x1) = ( f(x1) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 - step_slope) ) / step_slope (the slope is continuous)
;; ;; ;;; ;;; f'(x2) =   (1-percentage_speed_at_x3) * (max_peak_predicted_mp_method_beg_to_max - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / ( time_max_from_now_median_method_slope - time_max_from_now_mp_method_beg_to_max ) ;;; the slope at x2 is the same as a linear increase from f(x2) to f(x3), ie f'(x2) = (f(x2) - f(x3)) / (x2 - x3)

;;      if time_max_from_now_mp_method_beg_to_max gt 1 then begin
;;         a_syst_mp = [ [0,0,0,1 ],$ ;; f(x1)
;;                       [(time_max_from_now_mp_method_beg_to_max-1)^3.0 ,(time_max_from_now_mp_method_beg_to_max-1)^2.0, (time_max_from_now_mp_method_beg_to_max-1),1 ], $ ;; f(x2)
;;                       [ 0,0, 1,0 ],$                                                                                                   ;; f'(x1)
;;                       [ 3*(time_max_from_now_mp_method_beg_to_max-1)^2.0, 2*(time_max_from_now_mp_method_beg_to_max-1), 1,0 ] ]        ;; f'(x2)

;;         b_syst_mp = [ param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ), $ ;; f(x1)
;;                       max_peak_predicted_mp_method_beg_to_max - (1 - percentage_speed_at_x3_normalized) * (max_peak_predicted_mp_method_beg_to_max - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ), $ ;; f(x2)
;;                       ( param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 - step_slope) ) / step_slope,$ ;; f'(x1)
;;                       (1-percentage_speed_at_x3_normalized) * (max_peak_predicted_mp_method_beg_to_max - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / ( time_max_from_now_median_method_slope - time_max_from_now_mp_method_beg_to_max ) /2] ;; f'(x2)   (the very last /2 is to make it nicer)

        
;;         if determ(a_syst_mp) ne 0 then begin
;;            result_syst_mp = la_linear_equation(a_syst_mp, b_syst_mp,/double,zero =zero)        
;;            x_peak_predicted_mp_method_beg_to_max = dindgen(time_max_from_now_mp_method_beg_to_max)
;;            peak_predicted_mp_method_beg_to_max = fltarr(time_max_from_now_mp_method_beg_to_max)
;;            peak_predicted_mp_method_beg_to_max = result_syst_mp(0) * x_peak_predicted_mp_method_beg_to_max^3.0 + result_syst_mp(1) * x_peak_predicted_mp_method_beg_to_max^2.0 + result_syst_mp(2)*x_peak_predicted_mp_method_beg_to_max + result_syst_mp(3) 

;;            if time_max_from_now_mp_method_beg_to_max ge 3. then begin
;;               deriv_function = deriv(x_peak_predicted_mp_method_beg_to_max,peak_predicted_mp_method_beg_to_max)
;;            ;;    print,'DERIV X3',$
;; ;;                     deriv_function(time_max_from_now_mp_method_beg_to_max-1),$
;; ;;                     result_syst_mp(0) *3* x_peak_predicted_mp_method_beg_to_max(time_max_from_now_mp_method_beg_to_max-1)^2.0 + result_syst_mp(1) *2* x_peak_predicted_mp_method_beg_to_max(time_max_from_now_mp_method_beg_to_max-1) + result_syst_mp(2)

;;            endif

;;         endif else det_a = -1000000.0
;; ;;;;;;;;;;;;;;;;;;;;;;;; ORDER  3  80% - 100%;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; ;; ;;;;;;;; SYSTEM TO SOLVE TO GET THE PARABOLA ;;;;;;;;;;;;;;;;;;
;; ;;; ;;; f(x) = a*x^3 + b*x^2.0 + c*x + d
;; ;;; ;;; f'(x) = 3*a*x^2 + 2*b*x + c 
;; ;;; ;;;  x3 = time_max_from_now_median_method_slope (position of the max of the peak) 
;; ;;; ;;; x2 = time_max_from_now_mp_method_beg_to_max 
;; ;; ;;; ;;; f(x2) = max_peak_predicted_mp_method_beg_to_max - (1-percentage_speed_at_x3) * (max_peak_predicted_mp_method_beg_to_max - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) (the speed at x2 is 80% of the jump (jump = max of the peak - speed(now))
;; ;;; ;;; f(x3) = max_peak_predicted_mp_method_beg_to_max (speed at the max of the peak) 
;; ;; ;;; ;;; f'(x2) =   (1-percentage_speed_at_x3) * (max_peak_predicted_mp_method_beg_to_max - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / ( time_max_from_now_median_method_slope - time_max_from_now_mp_method_beg_to_max ) ;;; the slope at x2 is the same as a linear increase from f(x2) to f(x3), ie f'(x2) = (f(x2) - f(x3)) / (x2 - x3)
;;         ;; We also tried the foloowing but it did not look nice: ( f(x3) - f(x3 - step_slope) ) / step_slope ;;      the slope is continuous at x3
;; ;;; ;;; f'(x3) = 0 (the slope is 0 at the max)
;;         if det_a gt -10000.0 then begin

;;            a_syst_mp = [ [(time_max_from_now_median_method_slope-1)^3.0 ,(time_max_from_now_median_method_slope-1)^2.0, (time_max_from_now_median_method_slope-1),1 ],$ ;; f(x3)
;;                          [ (time_max_from_now_mp_method_beg_to_max-1)^3.0, (time_max_from_now_mp_method_beg_to_max-1)^2.0, (time_max_from_now_mp_method_beg_to_max-1),1 ], $ ;; f(x2)
;;                          [ 3*(time_max_from_now_median_method_slope-1)^2.0, 2*(time_max_from_now_median_method_slope-1), 1,0 ],$       ;; f'(x3)
;;                          [ 3*(time_max_from_now_mp_method_beg_to_max-1)^2.0, 2*(time_max_from_now_mp_method_beg_to_max-1), 1,0 ]]      ;; f'(x2)

;;            b_syst_mp = [ max_peak_predicted_mp_method_beg_to_max , $                                                   ;; f(x3)
;;                          peak_predicted_mp_method_beg_to_max(time_max_from_now_mp_method_beg_to_max-1) , $             ;; f(x2)
;;                          0 ,$                                                                                          ;; f'(x3)   
;;                          (1-percentage_speed_at_x3_normalized) * (max_peak_predicted_mp_method_beg_to_max - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / ( time_max_from_now_median_method_slope - time_max_from_now_mp_method_beg_to_max ) *2 ] ;; f'(x2) (the very last *2 is to make it nicer)

;;            if determ(a_syst_mp) ne 0 then begin        
;;               result_syst_mp = la_linear_equation(a_syst_mp, b_syst_mp,/double,zero =zero)
              
;;               x_peak_predicted_median_method_slope = dindgen(time_max_from_now_median_method_slope-time_max_from_now_mp_method_beg_to_max)+time_max_from_now_mp_method_beg_to_max
              
;;               peak_predicted_median_method_slope = fltarr(time_max_from_now_median_method_slope-time_max_from_now_mp_method_beg_to_max)

;;               peak_predicted_median_method_slope = result_syst_mp(0) * x_peak_predicted_median_method_slope^3.0 + result_syst_mp(1) * x_peak_predicted_median_method_slope^2.0 + result_syst_mp(2) * x_peak_predicted_median_method_slope + result_syst_mp(3)

;;               x_peak_predicted_mp = dindgen(time_max_from_now_median_method_slope)
;;               peak_predicted_mp = fltarr(time_max_from_now_median_method_slope)
;;               peak_predicted_mp = [peak_predicted_mp_method_beg_to_max,peak_predicted_median_method_slope]

;;               time_max_from_now_mp = time_max_from_now_median_method_slope
;;               max_peak_predicted_mp = max_peak_predicted_mp_method_beg_to_max

;; ;;               print,'TIME_max_from_now_median_method_slope',time_max_from_now_median_method_slope
;; ;;               print,'MAX_peak_predicted_mp_method_beg_to_max',max_peak_predicted_mp_method_beg_to_max,max(peak_predicted_mp)
;;            endif else begin

;;             ;;  print, 'The predicted mp amplitude is smaller than the speed now'
;;               time_max_from_now_mp = 0.0

;;            endelse

;;         endif else begin

;;           ;; print, 'The predicted mp amplitude is smaller than the speed now'
;;            time_max_from_now_mp = 0.0

;;         endelse

;;      endif else begin

;;        ;; print, 'The predicted mp amplitude is smaller than the speed now'
;;         time_max_from_now_mp = 0.0

;;      endelse


;;   endif


 if keyword_set(calculate_ensemble_keyword) eq 1 then begin
;; ;; ;;;;;;;;;;;;;;;;;; ENSEMBLE

for eee = 0L, n_elements(time_max_from_now_ensemble_method_beg_to_max) - 1 do begin

  det_a = 0.0
  percentage_speed_at_x3 = 75.0
  percentage_speed_at_x3_normalized = percentage_speed_at_x3 / 100.0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; ORDER 3 80% - THEN ORDER 3 80%-100% ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  if time_max_from_now_ensemble_method_slope(eee) le time_max_from_now_ensemble_method_beg_to_max(eee) then begin ;; (that is the case most of the time)

;;   print,'time_max_from_now_ensemble_method_slope(eee) le time_max_from_now_ensemble_method_beg_to_max(eee) for EEE = ',EEE

;;;;;;;;;;;;;;;;;;;;;;;; ORDER 3  80% ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;; ;;;;;;;; SYSTEM TO SOLVE TO GET THE PARABOLA ;;;;;;;;;;;;;;;;;;
;; ;;; ;;; f(x) = a*x^3 + b*x^2 + c*x + d
;; ;;; ;;; f'(x) = 3*a*x^2 + 2*b*x + c
;; ;;; ;;; x1 = 0 (now)
;; ;;; ;;; x3 = time_max_from_now_ensemble_method_slope(eee) 
;; ;;; ;;; f(x1) = param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) (speed now)
;; ;;; ;;; f(x3) =  max_peak_predicted_ensemble_method_slope(eee) - (1-percentage_speed_at_x3) * (max_peak_predicted_ensemble_method_slope(eee) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) (the speed at x3 is 80% of the jump (jump = max of the peak - speed(now))
;; ;;; ;;; f'(x1) = ( f(x1) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 - step_slope) ) / step_slope the slope is continuous
;; ;;; ;;; f'(x3) =   (1-percentage_speed_at_x3) * (max_peak_predicted_ensemble_method_slope(eee) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / ( time_max_from_now_ensemble_method_beg_to_max(eee) - time_max_from_now_ensemble_method_slope(eee) ) ;;; the slope at x3 is the same as a linear increase from f(x3) to f(x2), ie f'(x3) = (f(x2) - f(x3)) / (x2 - x3)

     if time_max_from_now_ensemble_method_slope(eee) gt 1 then begin
        a_syst_ensemble = [ [0,0,0,1 ],$ ;; f(x1)
                      [(time_max_from_now_ensemble_method_slope(eee)-1)^3.0 ,(time_max_from_now_ensemble_method_slope(eee)-1)^2.0, (time_max_from_now_ensemble_method_slope(eee)-1),1 ], $ ;; f(x3)
                      [ 0,0, 1,0 ],$                                                                                              ;; f'(x1)
                      [ 3*(time_max_from_now_ensemble_method_slope(eee)-1)^2.0, 2*(time_max_from_now_ensemble_method_slope(eee)-1), 1,0 ] ]     ;; f'(x3)
        b_syst_ensemble = [ param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ), $ ;; f(x1)
                      max_peak_predicted_ensemble_method_slope(eee) - (1 - percentage_speed_at_x3_normalized) * (max_peak_predicted_ensemble_method_slope(eee) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ), $ ;; f(x3)
                      ( param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 - step_slope) ) / step_slope,$ ;; f'(x1)
                      (1-percentage_speed_at_x3_normalized) * (max_peak_predicted_ensemble_method_slope(eee) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / ( time_max_from_now_ensemble_method_beg_to_max(eee) - time_max_from_now_ensemble_method_slope(eee) ) /2 ] ;; f'(x3)   (the /2 at the very end is to look nicer)

        if determ(a_syst_ensemble) ne 0 then begin
           result_syst_ensemble = la_linear_equation(a_syst_ensemble, b_syst_ensemble,/double,zero =zero)        
           x_peak_predicted_ensemble_method_slope = dindgen(time_max_from_now_ensemble_method_slope(eee))
           peak_predicted_ensemble_method_slope = fltarr(time_max_from_now_ensemble_method_slope(eee))
           peak_predicted_ensemble_method_slope = result_syst_ensemble(0) * x_peak_predicted_ensemble_method_slope^3.0 + result_syst_ensemble(1) * x_peak_predicted_ensemble_method_slope^2.0 + result_syst_ensemble(2)*x_peak_predicted_ensemble_method_slope + result_syst_ensemble(3) 

           if time_max_from_now_ensemble_method_slope(eee) ge 3 then begin
              deriv_function = deriv(x_peak_predicted_ensemble_method_slope,peak_predicted_ensemble_method_slope)
           ;;    print,'DERIV X3',$
;;                     deriv_function(time_max_from_now_ensemble_method_slope(eee)-1),$
;;                     result_syst_ensemble(0) *3* x_peak_predicted_ensemble_method_slope(time_max_from_now_ensemble_method_slope(eee)-1)^2.0 + result_syst_ensemble(1) *2* x_peak_predicted_ensemble_method_slope(time_max_from_now_ensemble_method_slope(eee)-1) + result_syst_ensemble(2)
           endif

        endif else det_a = -1000000.0

;;;;;;;;;;;;;;;;;;;;;;;; ORDER  3  80% - 100%;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; ;;;;;;;; SYSTEM TO SOLVE TO GET THE PARABOLA ;;;;;;;;;;;;;;;;;;
;;; ;;; f(x) = a*x^3 + b*x^2.0 + c*x + d
;;; ;;; f'(x) = 3*a*x^2 + 2*b*x + c 
;;; ;;;  x3 = time_max_from_now_ensemble_method_slope(eee) 
;;; ;;; x2 = time_max_from_now_ensemble_method_beg_to_max(eee) (position of the max of the peak) 
;;; ;;; f(x3) =  max_peak_predicted_ensemble_method_slope(eee) - (1-percentage_speed_at_x3) * (max_peak_predicted_ensemble_method_slope(eee) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) (the speed at x3 is 80% of the jump (jump = max of the peak - speed(now))
;;; ;;; f(x2) = max_peak_predicted_ensemble_method_slope(eee) (speed at the max of the peak) 
;;; ;;; f'(x3) =   (1-percentage_speed_at_x3) * (max_peak_predicted_ensemble_method_slope(eee) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / ( time_max_from_now_ensemble_method_beg_to_max(eee) - time_max_from_now_ensemble_method_slope(eee) ) ;;; the slope at x3 is the same as a linear increase from f(x3) to f(x2), ie f'(x3) = (f(x2) - f(x3)) / (x2 - x3)
        ;; We also tried the foloowing but it did not look nice: ( f(x3) - f(x3 - step_slope) ) / step_slope ;;      the slope is continuous at x3
;;; ;;; f'(x2) = 0 (the slope is 0 at the max)

        if det_a gt -10000.0 then begin
           a_syst_ensemble = [ [(time_max_from_now_ensemble_method_slope(eee)-1)^3.0 ,(time_max_from_now_ensemble_method_slope(eee)-1)^2.0, (time_max_from_now_ensemble_method_slope(eee)-1),1 ],$ ;; f(x3)
                         [ (time_max_from_now_ensemble_method_beg_to_max(eee)-1)^3.0, (time_max_from_now_ensemble_method_beg_to_max(eee)-1)^2.0, (time_max_from_now_ensemble_method_beg_to_max(eee)-1),1 ], $ ;; f(x2)
                         [ 3*(time_max_from_now_ensemble_method_slope(eee)-1)^2.0, 2*(time_max_from_now_ensemble_method_slope(eee)-1), 1,0 ],$      ;; f'(x3)
                         [ 3*(time_max_from_now_ensemble_method_beg_to_max(eee)-1)^2.0, 2*(time_max_from_now_ensemble_method_beg_to_max(eee)-1), 1,0 ]]     ;; f'(x2)

           b_syst_ensemble = [ peak_predicted_ensemble_method_slope(time_max_from_now_ensemble_method_slope(eee)-1) , $     ;; f(x3)
                         max_peak_predicted_ensemble_method_slope(eee) , $                                          ;; f(x2)
                         (1-percentage_speed_at_x3_normalized) * (max_peak_predicted_ensemble_method_slope(eee) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / ( time_max_from_now_ensemble_method_beg_to_max(eee) - time_max_from_now_ensemble_method_slope(eee) )*2.0 ,$ ;; f'(x3)    (the very last *2 is to make it nice)
                         0 ] ;; f'(x2)
           
           if determ(a_syst_ensemble) ne 0 then begin

              result_syst_ensemble = la_linear_equation(a_syst_ensemble, b_syst_ensemble,/double,zero =zero)
              
              x_peak_predicted_ensemble_method_beg_to_max = dindgen(time_max_from_now_ensemble_method_beg_to_max(eee)-time_max_from_now_ensemble_method_slope(eee))+time_max_from_now_ensemble_method_slope(eee)
              peak_predicted_ensemble_method_beg_to_max = fltarr(time_max_from_now_ensemble_method_beg_to_max(eee)-time_max_from_now_ensemble_method_slope(eee))
              peak_predicted_ensemble_method_beg_to_max = result_syst_ensemble(0) * x_peak_predicted_ensemble_method_beg_to_max^3.0 + result_syst_ensemble(1) * x_peak_predicted_ensemble_method_beg_to_max^2.0 + result_syst_ensemble(2) * x_peak_predicted_ensemble_method_beg_to_max + result_syst_ensemble(3)
       

              time_max_from_now_ensemble(eee) = time_max_from_now_ensemble_method_beg_to_max(eee)
              max_peak_predicted_ensemble(eee) = max_peak_predicted_ensemble_method_slope(eee)

              peak_predicted_ensemble(eee,0:time_max_from_now_ensemble(eee)-1) = [peak_predicted_ensemble_method_slope,peak_predicted_ensemble_method_beg_to_max]

;;               print,'time_max_from_now_ensemble(eee)',time_max_from_now_ensemble(eee)
;;               print,'max_peak_predicted_ensemble_method_slope(eee)',max_peak_predicted_ensemble_method_slope(eee),max(peak_predicted_ensemble)
           endif else begin


          ;;    print, 'The predicted mp amplitude is smaller than the speed now'
              time_max_from_now_ensemble(eee) = 0.0
           endelse

        endif else begin

;;           print, 'The predicted mp amplitude is smaller than the speed now'
           time_max_from_now_ensemble(eee) = 0.0
        endelse
        
        
     endif else begin


       ;; print, 'The predicted mp amplitude is smaller than the speed now'
        time_max_from_now_ensemble(eee) = 0.0

     endelse
  endif


  if time_max_from_now_ensemble_method_slope(eee) gt time_max_from_now_ensemble_method_beg_to_max(eee) then begin 

;;      print,'time_max_from_now_ensemble_method_slope(eee) gt time_max_from_now_ensemble_method_beg_to_max(eee) for EEE =',eee
;;      print,'time_max_from_now_ensemble_method_slope(eee)',time_max_from_now_ensemble_method_slope(eee) 
;;      print,'time_max_from_now_ensemble_method_beg_to_max(eee)',time_max_from_now_ensemble_method_beg_to_max(eee)
;;      print,'max_peak_predicted_ensemble_method_slope(eee)',max_peak_predicted_ensemble_method_slope(eee)
;;      print,'max_peak_predicted_ensemble_method_beg_to_max(eee)',max_peak_predicted_ensemble_method_beg_to_max(eee)
;;;;;;;;;;;;;;;;;;;;;;;; ORDER 3  80% ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;; ;;;;;;;; SYSTEM TO SOLVE TO GET THE PARABOLA ;;;;;;;;;;;;;;;;;;
;; ;;; ;;; f(x) = a*x^3 + b*x^2 + c*x + d
;; ;;; ;;; f'(x) = 3*a*x^2 + 2*b*x + c
;; ;;; ;;; x1 = 0 (now)
;; ;;; ;;; x2 = time_max_from_now_ensemble_method_beg_to_max(eee)
;; ;;; ;;; f(x1) = param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) (speed now)
;; ;;; ;;; f(x2) = max_peak_predicted_ensemble_method_beg_to_max(eee) - (1-percentage_speed_at_x3) * (max_peak_predicted_ensemble_method_beg_to_max(eee) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) (the speed at x2 is 80% of the jump (jump = max of the peak - speed(now))
;; ;;; ;;; f'(x1) = ( f(x1) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 - step_slope) ) / step_slope (the slope is continuous)
;; ;;; ;;; f'(x2) =   (1-percentage_speed_at_x3) * (max_peak_predicted_ensemble_method_beg_to_max(eee) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / ( time_max_from_now_ensemble_method_slope(eee) - time_max_from_now_ensemble_method_beg_to_max(eee) ) ;;; the slope at x2 is the same as a linear increase from f(x2) to f(x3), ie f'(x2) = (f(x2) - f(x3)) / (x2 - x3)

     if time_max_from_now_ensemble_method_beg_to_max(eee) gt 1 then begin
        a_syst_ensemble = [ [0,0,0,1 ],$ ;; f(x1)
                      [(time_max_from_now_ensemble_method_beg_to_max(eee)-1)^3.0 ,(time_max_from_now_ensemble_method_beg_to_max(eee)-1)^2.0, (time_max_from_now_ensemble_method_beg_to_max(eee)-1),1 ], $ ;; f(x2)
                      [ 0,0, 1,0 ],$                                                                                                   ;; f'(x1)
                      [ 3*(time_max_from_now_ensemble_method_beg_to_max(eee)-1)^2.0, 2*(time_max_from_now_ensemble_method_beg_to_max(eee)-1), 1,0 ] ]        ;; f'(x2)

        b_syst_ensemble = [ param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ), $ ;; f(x1)
                      max_peak_predicted_ensemble_method_beg_to_max(eee) - (1 - percentage_speed_at_x3_normalized) * (max_peak_predicted_ensemble_method_beg_to_max(eee) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ), $ ;; f(x2)
                      ( param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 - step_slope) ) / step_slope,$ ;; f'(x1)
                      (1-percentage_speed_at_x3_normalized) * (max_peak_predicted_ensemble_method_beg_to_max(eee) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / ( time_max_from_now_ensemble_method_slope(eee) - time_max_from_now_ensemble_method_beg_to_max(eee) ) /2] ;; f'(x2)   (the very last /2 is to make it nicer)

        
        if determ(a_syst_ensemble) ne 0 then begin
           result_syst_ensemble = la_linear_equation(a_syst_ensemble, b_syst_ensemble,/double,zero =zero)        
           x_peak_predicted_ensemble_method_beg_to_max = dindgen(time_max_from_now_ensemble_method_beg_to_max(eee))
           peak_predicted_ensemble_method_beg_to_max = fltarr(time_max_from_now_ensemble_method_beg_to_max(eee))
           peak_predicted_ensemble_method_beg_to_max = result_syst_ensemble(0) * x_peak_predicted_ensemble_method_beg_to_max^3.0 + result_syst_ensemble(1) * x_peak_predicted_ensemble_method_beg_to_max^2.0 + result_syst_ensemble(2)*x_peak_predicted_ensemble_method_beg_to_max + result_syst_ensemble(3) 

           if time_max_from_now_ensemble_method_beg_to_max(eee) ge 3. then begin
              deriv_function = deriv(x_peak_predicted_ensemble_method_beg_to_max,peak_predicted_ensemble_method_beg_to_max)
           ;;    print,'DERIV X3',$
;;                     deriv_function(time_max_from_now_ensemble_method_beg_to_max(eee)-1),$
;;                     result_syst_ensemble(0) *3* x_peak_predicted_ensemble_method_beg_to_max(time_max_from_now_ensemble_method_beg_to_max(eee)-1)^2.0 + result_syst_ensemble(1) *2* x_peak_predicted_ensemble_method_beg_to_max(time_max_from_now_ensemble_method_beg_to_max(eee)-1) + result_syst_ensemble(2)

           endif

        endif else det_a = -1000000.0
;;;;;;;;;;;;;;;;;;;;;;;; ORDER  3  80% - 100%;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; ;;;;;;;; SYSTEM TO SOLVE TO GET THE PARABOLA ;;;;;;;;;;;;;;;;;;
;;; ;;; f(x) = a*x^3 + b*x^2.0 + c*x + d
;;; ;;; f'(x) = 3*a*x^2 + 2*b*x + c 
;;; ;;;  x3 = time_max_from_now_ensemble_method_slope(eee) (position of the max of the peak) 
;;; ;;; x2 = time_max_from_now_ensemble_method_beg_to_max(eee) 
;; ;;; ;;; f(x2) = max_peak_predicted_ensemble_method_beg_to_max(eee) - (1-percentage_speed_at_x3) * (max_peak_predicted_ensemble_method_beg_to_max(eee) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) (the speed at x2 is 80% of the jump (jump = max of the peak - speed(now))
;;; ;;; f(x3) = max_peak_predicted_ensemble_method_beg_to_max(eee) (speed at the max of the peak) 
;; ;;; ;;; f'(x2) =   (1-percentage_speed_at_x3) * (max_peak_predicted_ensemble_method_beg_to_max(eee) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / ( time_max_from_now_ensemble_method_slope(eee) - time_max_from_now_ensemble_method_beg_to_max(eee) ) ;;; the slope at x2 is the same as a linear increase from f(x2) to f(x3), ie f'(x2) = (f(x2) - f(x3)) / (x2 - x3)
        ;; We also tried the foloowing but it did not look nice: ( f(x3) - f(x3 - step_slope) ) / step_slope ;;      the slope is continuous at x3
;;; ;;; f'(x3) = 0 (the slope is 0 at the max)
        if det_a gt -10000.0 then begin

           a_syst_ensemble = [ [(time_max_from_now_ensemble_method_slope(eee)-1)^3.0 ,(time_max_from_now_ensemble_method_slope(eee)-1)^2.0, (time_max_from_now_ensemble_method_slope(eee)-1),1 ],$ ;; f(x3)
                         [ (time_max_from_now_ensemble_method_beg_to_max(eee)-1)^3.0, (time_max_from_now_ensemble_method_beg_to_max(eee)-1)^2.0, (time_max_from_now_ensemble_method_beg_to_max(eee)-1),1 ], $ ;; f(x2)
                         [ 3*(time_max_from_now_ensemble_method_slope(eee)-1)^2.0, 2*(time_max_from_now_ensemble_method_slope(eee)-1), 1,0 ],$       ;; f'(x3)
                         [ 3*(time_max_from_now_ensemble_method_beg_to_max(eee)-1)^2.0, 2*(time_max_from_now_ensemble_method_beg_to_max(eee)-1), 1,0 ]]      ;; f'(x2)

           b_syst_ensemble = [ max_peak_predicted_ensemble_method_beg_to_max(eee) , $                                                   ;; f(x3)
                         peak_predicted_ensemble_method_beg_to_max(time_max_from_now_ensemble_method_beg_to_max(eee)-1) , $             ;; f(x2)
                         0 ,$                                                                                          ;; f'(x3)   
                         (1-percentage_speed_at_x3_normalized) * (max_peak_predicted_ensemble_method_beg_to_max(eee) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / ( time_max_from_now_ensemble_method_slope(eee) - time_max_from_now_ensemble_method_beg_to_max(eee) ) *2 ] ;; f'(x2) (the very last *2 is to make it nicer)

           if determ(a_syst_ensemble) ne 0 then begin        
              result_syst_ensemble = la_linear_equation(a_syst_ensemble, b_syst_ensemble,/double,zero =zero)
              
              x_peak_predicted_ensemble_method_slope = dindgen(time_max_from_now_ensemble_method_slope(eee)-time_max_from_now_ensemble_method_beg_to_max(eee))+time_max_from_now_ensemble_method_beg_to_max(eee)
              
              peak_predicted_ensemble_method_slope = fltarr(time_max_from_now_ensemble_method_slope(eee)-time_max_from_now_ensemble_method_beg_to_max(eee))

              peak_predicted_ensemble_method_slope = result_syst_ensemble(0) * x_peak_predicted_ensemble_method_slope^3.0 + result_syst_ensemble(1) * x_peak_predicted_ensemble_method_slope^2.0 + result_syst_ensemble(2) * x_peak_predicted_ensemble_method_slope + result_syst_ensemble(3)

            
       

              time_max_from_now_ensemble(eee) = time_max_from_now_ensemble_method_slope(eee)
              max_peak_predicted_ensemble(eee) = max_peak_predicted_ensemble_method_beg_to_max(eee)

              peak_predicted_ensemble(eee,0:time_max_from_now_ensemble(eee)-1) = [peak_predicted_ensemble_method_beg_to_max,peak_predicted_ensemble_method_slope]

 ;;              print,'time_max_from_now_ensemble_method_slope(eee)',time_max_from_now_ensemble_method_slope(eee)
;;               print,'max_peak_predicted_ensemble_method_beg_to_max(eee)',max_peak_predicted_ensemble_method_beg_to_max(eee),max(peak_predicted_ensemble)
           endif else begin

            ;;  print, 'The predicted mp amplitude is smaller than the speed now'
              time_max_from_now_ensemble(eee) = 0.0

           endelse

        endif else begin

          ;; print, 'The predicted mp amplitude is smaller than the speed now'
           time_max_from_now_ensemble(eee) = 0.0

        endelse

     endif else begin

       ;; print, 'The predicted mp amplitude is smaller than the speed now'
        time_max_from_now_ensemble(eee) = 0.0

     endelse


  endif



endfor

endif

;;;;;;;;;;;; ;;;;;;;;;;;;;;;;;;;;;;;; END OF ENSEMBLE

  return

end
