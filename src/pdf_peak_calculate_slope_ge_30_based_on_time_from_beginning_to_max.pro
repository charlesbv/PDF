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
; NAME: pdf_peak_calculate_slope_ge_30_based_on_time_from_beginning_to_max.pro;
;
; PURPOSE: calculate the max and the time of the peak using method 2 (PDF of the time between the beginning of the peak and its max). 
;
; CALLING SEQUENCE: none
;
; INPUTS: 
; PARAMETER = parameter to be predicted (ex: speed)
; PARAM_AVERAGE_OK_FROM_START_OF_PEAK_TO_NOW = speed from start of the
; peak to the current time
; X_HIST_TIME_FROM_MIN_TO_MAX_PEAK_EXTRAPOLATED = x axis of the PDF of
; the time between the beginning of the peak and its max
; HIST_TIME_FROM_MIN_TO_MAX_PEAK_PERCENTAGE_EXTRAPOLATED = PDF of
; the time between the beginning of the peak and its max

; KEYWORD PARAMETERS:
; calculate_ensemble = 0 to get only the median
; prediction, 1 to get the  10%, 25%, 75% and 90% quadratiles predictions as well 
;
; OUTPUTS:
; TIME_MAX_FROM_NOW_MEDIAN_METHOD_BEG_TO_MAX = time between the current
; time and the max of the peak as predicted by method 2 (PDF of the
; time between the beginning of the peak and its max) - median of the PDF
; TIME_MAX_FROM_NOW_MP_METHOD_BEG_TO_MAX = time between the current
; time and the max of the peak as predicted by method 2 (PDF of the
; time between the beginning of the peak and its max) - most probable
;                                                       value of the
;                                                       PDF (not used)
; TIME_MAX_FROM_NOW_ENSEMBLE_METHOD_BEG_TO_MAX =  time between the current
; time and the max of the peak as predicted by method 2 (PDF of the
; time between the beginning of the peak and its max) - quadratiles
;                                                       (10%, 25%,
;                                                       75%, 90%) of the PDF
; MAX_PEAK_PREDICTED_MEDIAN_METHOD_BEG_TO_MAX = max predicted by
; method 2 - median of the PDFs
; MAX_PEAK_PREDICTED_MP_METHOD_BEG_TO_MAX = max predicted by method 2 - most probable value of the PDFs (not used) 
; MAX_PEAK_PREDICTED_ENSEMBLE_METHOD_BEG_TO_MAX = max predicted
; by method 1 - quadratiles of the PDFs
;
;
; MODIFICATION HISTORY: 04-07-2015 by Charles Bussy-Virat;
;-



pro pdf_peak_calculate_slope_ge_30_based_on_time_from_beginning_to_max, parameter,param_average_ok_from_start_of_peak_to_now, $
   x_hist_time_from_min_to_max_peak_extrapolated, hist_time_from_min_to_max_peak_percentage_extrapolated,$
   time_max_from_now_median_method_beg_to_max,time_max_from_now_mp_method_beg_to_max, time_max_from_now_ensemble_method_beg_to_max, $
   max_peak_predicted_median_method_beg_to_max,max_peak_predicted_mp_method_beg_to_max,max_peak_predicted_ensemble_method_beg_to_max, calculate_ensemble = calculate_ensemble_keyword



  step_slope = 2.0 ;; this parameter has been used to calculate the slope (slope(now) = ( speed(now+step_slope/2.0) - speed(now-step_slope/2.0) ) / step_slope)
  time_from_start_peak_to_now = n_elements( param_average_ok_from_start_of_peak_to_now )
  all_slope_until_now = fltarr(time_from_start_peak_to_now  ) - 1000000.0
  for jjj = 0L, time_from_start_peak_to_now - step_slope - 1 do begin
     all_slope_until_now(jjj) = ( param_average_ok_from_start_of_peak_to_now( jjj + step_slope ) - param_average_ok_from_start_of_peak_to_now( jjj ) ) / step_slope      
     ;;     all_slope_until_now(jjj) = ( param_average_ok_from_start_of_peak_to_now( jjj + floor(step_slope/2.0) ) - param_average_ok_from_start_of_peak_to_now( jjj - floor(step_slope/2.0) ) ) / step_slope      
  endfor
  max_slope_until_now = max(all_slope_until_now( where( all_slope_until_now gt -100000.0 ) ) )
  ;;print,'max_slope_until_now = '+strtrim(string(max_slope_until_now,format='(f5.2)'),2)+' km/s/hour'
  bin_slope = 2.0 ;; if you change this value here than you ened to redo the pdf of amplitudes (DIST_SLOPE_GAUSS_EXTRAPOLATED) in gaussian_max_slope.pro with this new value of bin_slope
  min_max_slope = 4.77
  max_max_slope = 50.55
  nb_slope_bin = floor(  (max_max_slope - min_max_slope)  / bin_slope )

  i = floor( ( max_slope_until_now - min_max_slope ) / bin_slope )
  ;; ;; print,'max_slope_until_now',max_slope_until_now,i


  if i lt 0 or i ge nb_slope_bin then begin print,'' $
     & print,'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'  $
             & print, 'The maximum slope until now is out of the boundaries. The progam will stop.' $
             & print,'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'  $
             & print, ''  & stop
  endif else begin

     threshold_ensemble = fltarr(4)
     threshold_ensemble(0) = 0.10
     threshold_ensemble(1) = 0.25
     threshold_ensemble(2) = 0.75
     threshold_ensemble(3) = 0.90

     time_max_from_now_ensemble_method_beg_to_max = fltarr(n_elements(threshold_ensemble))
     max_peak_predicted_ensemble_method_beg_to_max = fltarr(n_elements(threshold_ensemble))

 ;;; ;;; ;;; the pdf and x have been calculated and saved in the
 ;;; procedure peak_max_stat

     pdf_time_min_to_max_extrapolated = hist_time_from_min_to_max_peak_percentage_extrapolated


     inc = 0L
     median_hist_time_from_min_to_max_peak = 0L
     mp_hist_time_from_min_to_max_peak = 0L
     ensemble_hist_time_from_min_to_max_peak = fltarr(n_elements(threshold_ensemble))

     while total(hist_time_from_min_to_max_peak_percentage_extrapolated(0:inc)) lt total(hist_time_from_min_to_max_peak_percentage_extrapolated)/2d do inc = inc + 1L
     median_hist_time_from_min_to_max_peak = x_hist_time_from_min_to_max_peak_extrapolated(inc)

     if keyword_set(calculate_ensemble_keyword) eq 1 then begin
        for eee = 0L, n_elements(threshold_ensemble) - 1 do begin
           inc = 0L
           while total(hist_time_from_min_to_max_peak_percentage_extrapolated(0:inc)) lt total(hist_time_from_min_to_max_peak_percentage_extrapolated)*threshold_ensemble(eee) do inc = inc + 1L
           ensemble_hist_time_from_min_to_max_peak(eee) = x_hist_time_from_min_to_max_peak_extrapolated(inc)
        endfor
     endif


     the_peak_begins_after = -1.0
     time_beginning_peak = 0.0

     if n_elements( param_average_ok_from_start_of_peak_to_now ) gt 24.0  then begin
        ttt = 0L
        while ttt le n_elements(param_average_ok_from_start_of_peak_to_now) - 1 - 24.0 do begin  
;;           print,'ttt',ttt
           if max( param_average_ok_from_start_of_peak_to_now(ttt:ttt+24.0) ) ge (param_average_ok_from_start_of_peak_to_now(ttt)+70.0) then begin
              where_beginning_peak = min( where( param_average_ok_from_start_of_peak_to_now(ttt:ttt+24.0) ge (param_average_ok_from_start_of_peak_to_now(i)+70.0) ) )
              time_beginning_peak = where_beginning_peak
              ;;     print,'time_beginning_peak inside the while loop',time_beginning_peak
              the_peak_begins_after = 0.0
              ttt = 1000000.0
           endif else ttt = ttt+1.0
           
        endwhile
     endif

     if time_beginning_peak eq 0.0 then begin
        where_max_slope = where( all_slope_until_now eq max_slope_until_now )
        time_beginning_peak = 70.0/max_slope_until_now + where_max_slope(0)
        the_peak_begins_after = 1.0
     endif

     ;;    print,'the_peak_begins_after',the_peak_begins_after
;;      help,'time_beginning_peak',time_beginning_peak
     mean_all_slope_until_now = mean(all_slope_until_now( where( all_slope_until_now gt -100000.0 ) ) )


;; ;; ;;;;;;;;;;;;; OPTION 1: MEDIAN
     if the_peak_begins_after eq 1.0 then begin
        time_max_from_now_median_method_beg_to_max = median_hist_time_from_min_to_max_peak + time_beginning_peak - n_elements(param_average_ok_from_start_of_peak_to_now) ;floor( ( max_peak_predicted_median_method_beg_to_max - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / max_slope_until_now  ) 
        time_max_from_now_median_method_beg_to_max = floor( time_max_from_now_median_method_beg_to_max )

     endif else if the_peak_begins_after eq 0.0 then begin
        time_max_from_now_median_method_beg_to_max = median_hist_time_from_min_to_max_peak - (n_elements(param_average_ok_from_start_of_peak_to_now)-time_beginning_peak)
        time_max_from_now_median_method_beg_to_max = floor( time_max_from_now_median_method_beg_to_max )
     endif


     max_peak_predicted_median_method_beg_to_max = param_average_ok_from_start_of_peak_to_now(n_elements(param_average_ok_from_start_of_peak_to_now)-1) + time_max_from_now_median_method_beg_to_max*max_slope_until_now ;; I observed that the slope tends to keep being at its maximum value until getting closer to the max. We could divide by mean_all_slope_until_now. So I choose the average.



;; ;; ;;;;;;;;;;;;; OPTION 2: MOST PROBABLE

;;      if the_peak_begins_after eq 1.0 then begin
;;         time_max_from_now_mp_method_beg_to_max = mp_hist_time_from_min_to_max_peak + time_beginning_peak - n_elements(param_average_ok_from_start_of_peak_to_now) ;floor( ( max_peak_predicted_mp_method_beg_to_max - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / max_slope_until_now  ) 
;;         time_max_from_now_mp_method_beg_to_max = floor( time_max_from_now_mp_method_beg_to_max )

;;      endif else if the_peak_begins_after eq 0.0 then begin
;;         time_max_from_now_mp_method_beg_to_max = mp_hist_time_from_min_to_max_peak - (n_elements(param_average_ok_from_start_of_peak_to_now)-time_beginning_peak)

;;         time_max_from_now_mp_method_beg_to_max = floor( time_max_from_now_mp_method_beg_to_max )

;;      endif

;;      max_peak_predicted_mp_method_beg_to_max = param_average_ok_from_start_of_peak_to_now(n_elements(param_average_ok_from_start_of_peak_to_now)-1) + time_max_from_now_mp_method_beg_to_max*max_slope_until_now ;; I observed that the slope tends to keep being at its maximum value until getting closer to the max. We could divide by mean_all_slope_until_now. So I choose the average.


;; ;; print,''
;; ;; print,'max_peak_predicted_mp_method_beg_to_max',max_peak_predicted_mp_method_beg_to_max
;; ;; print,'time_max_from_now_mp_method_beg_to_max',time_max_from_now_mp_method_beg_to_max
;; ;; print,''



     if keyword_set(calculate_ensemble_keyword) eq 1 then begin
;; ;; ;;;;;;;;;;;;; ENSEMBLE

        for eee = 0, n_elements(threshold_ensemble) - 1 do begin
           if the_peak_begins_after eq 1.0 then begin
              time_max_from_now_ensemble_method_beg_to_max(eee) = ensemble_hist_time_from_min_to_max_peak(eee) + time_beginning_peak - n_elements(param_average_ok_from_start_of_peak_to_now) ;floor( ( max_peak_predicted_ensemble_method_beg_to_max(eee) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / max_slope_until_now  ) 
              time_max_from_now_ensemble_method_beg_to_max(eee) = floor( time_max_from_now_ensemble_method_beg_to_max(eee) )

           endif else if the_peak_begins_after eq 0.0 then begin
              time_max_from_now_ensemble_method_beg_to_max(eee) = ensemble_hist_time_from_min_to_max_peak(eee) - (n_elements(param_average_ok_from_start_of_peak_to_now)-time_beginning_peak)

              time_max_from_now_ensemble_method_beg_to_max(eee) = floor( time_max_from_now_ensemble_method_beg_to_max(eee) )
              
           endif


           max_peak_predicted_ensemble_method_beg_to_max(eee) = param_average_ok_from_start_of_peak_to_now(n_elements(param_average_ok_from_start_of_peak_to_now)-1) + time_max_from_now_ensemble_method_beg_to_max(eee)*max_slope_until_now ;; I observed that the slope tends to keep being at its maximum value until getting closer to the max. We could divide by mean_all_slope_until_now. So I choose the average.



        endfor

     endif
     
  endelse

  return

end
