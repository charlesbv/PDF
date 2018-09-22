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
; NAME: pdf_peak_calculate_slope_ge_30_based_on_max_slope.pro
;
; PURPOSE: calculate the max and the time of the peak using method 1 (PDF of
; the amplitude of the peak as a function of the max slope in the peak)
;
; CALLING SEQUENCE: none
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
;
; KEYWORD PARAMETERS:
; calculate_ensemble = 0 to get only the median
; prediction, 1 to get the  10%, 25%, 75% and 90% quadratiles predictions as well 
;
;   
; OUTPUTS:
; TIME_MAX_FROM_NOW_MEDIAN_METHOD_SLOPE = time between the current
; time and the max of the peak as predicted by method 1 (PDF of
; the amplitude of the peak as a function of the max slope in the
; peak) - median of the PDFs
; TIME_MAX_FROM_NOW_ENSEMBLE_METHOD_SLOPE = time between the current
; time and the max of the peak as predicted by method 1 (PDF of
; the amplitude of the peak as a function of the max slope in the
; peak) - quadratiles of the PDFs
; MAX_PEAK_PREDICTED_MEDIAN_METHOD_SLOPE = max predicted by
; method 1 - median of the PDFs
; MAX_PEAK_PREDICTED_ENSEMBLE_METHOD_SLOPE = max predicted
; by method 1 - quadratiles of the PDFs
;
; MODIFICATION HISTORY: 04-07-2015 by Charles Bussy-Virat
;
;-


pro pdf_peak_calculate_slope_ge_30_based_on_max_slope, parameter, param_average_ok_from_start_of_peak_to_now, $
   x_dist_slope_pdf_extrapolated, dist_slope_pdf_extrapolated,$
   x_dist_slope_gauss_extrapolated, dist_slope_gauss_extrapolated,$
   time_max_from_now_median_method_slope,time_max_from_now_ensemble_method_slope,$
   max_peak_predicted_median_method_slope,max_peak_predicted_ensemble_method_slope,$
   calculate_ensemble = calculate_ensemble_keyword


  pdf_or_gauss_method_slope = 0.0
  
  step_slope = 2.0 ;; this parameter has been used to calculate the slope (slope(now) = ( speed(now+step_slope/2.0) - speed(now-step_slope/2.0) ) / step_slope)
  time_from_start_peak_to_now = n_elements( param_average_ok_from_start_of_peak_to_now )
  all_slope_until_now = fltarr(time_from_start_peak_to_now  ) - 1000000.0
  for jjj = 0L, time_from_start_peak_to_now - step_slope - 1 do begin
     all_slope_until_now(jjj) = ( param_average_ok_from_start_of_peak_to_now( jjj + step_slope ) - param_average_ok_from_start_of_peak_to_now( jjj ) ) / step_slope      

  endfor
  max_slope_until_now = max(all_slope_until_now( where( all_slope_until_now gt -100000.0 ) ) )

  bin_slope = 2.0 ;; if you change this value here than you ened to redo the pdf of amplitudes (DIST_SLOPE_GAUSS_EXTRAPOLATED) in gaussian_max_slope.pro with this new value of bin_slope
  min_max_slope = 4.77
  max_max_slope = 50.55
  nb_slope_bin = floor(  (max_max_slope - min_max_slope)  / bin_slope )

  i = floor( ( max_slope_until_now - min_max_slope ) / bin_slope )
 ;; ;; print,'max_slope_until_now',max_slope_until_now,i

  threshold_pdf_gaussian = 10.0 
  i_threshold = floor( ( threshold_pdf_gaussian - min_max_slope ) / bin_slope ) + 1 ;; for i below i_threshold, we use the PDFs of amplitudes. For i above i_threshold, we use the gaussian distributions.


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



     if i le i_threshold then begin

        min_max_slope = 4.77
        max_max_slope = 20.00
        
        pdf_or_gauss_method_slope = 1.0

        pdf_slope_extrapolated_to_use = dist_slope_pdf_extrapolated(*,i)

        inc = 0L
        median_slope = 0L
        while total(pdf_slope_extrapolated_to_use(0:inc)) lt total(pdf_slope_extrapolated_to_use)/2d do inc = inc + 1L
        median_slope = x_dist_slope_pdf_extrapolated(inc)

        
        if keyword_set(calculate_ensemble_keyword) eq 1 then begin        
  ;;;;;; ENSEMBLE_PDF ;;;;;
           inc_ensemble_pdf = fltarr(4)
           ensemble_slope = fltarr(4)
           for eee = 0L, 3 do begin
              while total(pdf_slope_extrapolated_to_use(0:inc_ensemble_pdf(eee))) lt total(pdf_slope_extrapolated_to_use)*threshold_ensemble(eee) do inc_ensemble_pdf(eee) = inc_ensemble_pdf(eee) + 1L
              ensemble_slope(eee) = x_dist_slope_pdf_extrapolated(inc_ensemble_pdf(eee))
           endfor
  ;;;;;; END OF ENSEMBLE_PDF ;;;;;        
           
        endif

     endif

     if i gt i_threshold then begin

        pdf_or_gauss_method_slope = 2.0

        pdf_slope_extrapolated_to_use = dist_slope_gauss_extrapolated(*,i)
        
        inc = 0L
        median_slope = 0L
        while total(pdf_slope_extrapolated_to_use(0:inc)) lt total(pdf_slope_extrapolated_to_use)/2d do inc = inc + 1L
        median_slope = x_dist_slope_gauss_extrapolated(inc)

        if keyword_set(calculate_ensemble_keyword) eq 1 then begin        
  ;;;;;; ENSEMBLE ;;;;;
           inc_ensemble = fltarr(4)
           ensemble_slope = fltarr(4)
           for eee = 0L, 3 do begin
              while total(pdf_slope_extrapolated_to_use(0:inc_ensemble(eee))) lt total(pdf_slope_extrapolated_to_use)*threshold_ensemble(eee) do inc_ensemble(eee) = inc_ensemble(eee) + 1L
              ensemble_slope(eee) = x_dist_slope_gauss_extrapolated(inc_ensemble(eee))
           endfor
  ;;;;;; END OF ENSEMBLE ;;;;;        
        endif

     endif

     mean_all_slope_until_now = mean(all_slope_until_now( where( all_slope_until_now gt -100000.0 ) ) )
     max_peak_predicted_median_method_slope = param_average_ok_from_start_of_peak_to_now(0) + median_slope

     time_max_from_now_median_method_slope = floor( ( max_peak_predicted_median_method_slope - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) / max_slope_until_now  ) ;; I observed that the slope tends to keep being at its maximum value until getting closer to the max. We could divide by mean_all_slope_until_now. So I choose the average.


     if keyword_set(calculate_ensemble_keyword) eq 1 then begin
        max_peak_predicted_ensemble_method_slope = fltarr(4)
        time_max_from_now_ensemble_method_slope = fltarr(4)
        for eee = 0L, 3 do begin
           max_peak_predicted_ensemble_method_slope(eee) = param_average_ok_from_start_of_peak_to_now(0) + ensemble_slope(eee)
           time_max_from_now_ensemble_method_slope(eee) = floor( ( max_peak_predicted_ensemble_method_slope(eee) - param_average_ok_from_start_of_peak_to_now( n_elements( param_average_ok_from_start_of_peak_to_now ) - 1 ) ) /  max_slope_until_now ) ;; I observed that the slope tends to keep being at its maximum value until getting closer to the max. We could divide by mean_all_slope_until_now. So I choose the average.
        endfor
     endif

  endelse


  return

end
