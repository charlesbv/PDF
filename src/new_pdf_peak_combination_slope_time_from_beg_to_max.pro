;+
; NAME: new_pdf_peak_combination_slope_time_from_beg_to_max.pro
;
; PURPOSE:
; this gives the speeds 5 days advance using the predictions of the
; ascending phase by
; pdf_peak_calculate_combination_slope_time_from_beg_to_max and the
; predictions of the descending phase by pdf
;
; CALLING SEQUENCE:
; pdf_peak_calculate_combination_slope_time_from_beg_to_max, pdf
;
; INPUTS: 
; PARAMETER = parameter to be predicted (ex: speed)
; PARAM_AVERAGE_OK_FROM_START_OF_PEAK_TO_NOW = speed from start of the
; peak to the current time
; LAST_12_HOURS = values of parameter in the last 12 hours (redundant with param_average_ok_speed)
; PARAM_NOW = value of parameter now from the running average
; (redundant with param_average_ok_speed)
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
; X12 = x axis of the PDF P1 and P2 (see Bussy-Virat and Ridley
; [2014]) (used in pdf.pro)
; P1 = PDF P1 (see Bussy-Virat and Ridley [2014]) (used in pdf.pro)
; PARAM_AHEAD_OSRA = parameter one solar rotation ago (redundant with
; param_average_ok_speed) (used in pdf.pro)
; PARAM_AHEAD_OSRA_LAG = arameter one solar rotation ago - optimum lag (redundant
; with param_average_ok_speed)   (used in pdf.pro)  
; A_PDF = a factor in v_pred (see Bussy-Virat and Ridley [2014])  =
; vector 120* 1 (used in pdf.pro)
; B_OSRA_KILL = b factor in v_pred (see Bussy-Virat and Ridley [2014])
; = vector 120*1 (used in pdf.pro)
; C_PERS = use or not of the persistence model  (see Bussy-Virat and
; Ridley [2014]) = vector 120*1 (used in pdf.pro)
;
; OUTPUTS:
; TIME_MAX_FROM_NOW_MEDIAN = time between the current time and the max
; predicted by the median
; TIME_MAX_FROM_NOW_MP = time between the current time and the max                                                                           
; predicted by the most probable value of the PDF (not used)
; TIME_MAX_FROM_NOW_ENSEMBLE = time between the current time and the
; max predicted by the quadratiles (10%, 25%, 75%, 90%) = vector 4*1
; RESULT_NEW_PDF_PEAK_MODEL_MEDIAN = predicted speed in the next 5
; days by the PDF median
; RESULT_NEW_PDF_PEAK_MODEL_MP = predicted speed in the next 5
; days by the PDF most probable value (not used)
; RESULT_NEW_PDF_PEAK_MODEL_ENSEMBLE = predicted speed in the next 5
; days by the PDF quadratiles = vector 120*4
; BESTPRED_NEW_PDF_PEAK_ENSEMBLE = prediction made by the PDF in
; Bussy-Virat and Ridley [2014] (not used)
; TIME_MAX_FROM_NOW_MEDIAN_METHOD_SLOPE = time between the current
; time and the max of the peak as predicted by the PDF of the
; amplitude of the peak as a function of the max slope in the peak
; TIME_MAX_FROM_NOW_MEDIAN_METHOD_BEG_TO_MAX = time between the
; current time and the max of the peak as predicted by the PDF of the
; time between the beginning of the peak and its max
; TIME_MAX_FROM_NOW_MP_METHOD_BEG_TO_MAX = same as
; TIME_MAX_FROM_NOW_MEDIAN_METHOD_BEG_TO_MAX but with the most
; probable value of the PDF instead of its median (not used)
;
; KEYWORD PARAMETERS: 
; calculate_ensemble = 0 to get only the median
; prediction, 1 to get the  10%, 25%, 75% and 90% quadratiles predictions as well 
; OPTIMIZE_A_B = for the used of the PDF in pdf.pro, 1 to use the
; optimize set of a and b as detailed in Bussy-Virat and Ridley
; [2014], 0 to use a and b as chosen as inputs by the user
;
; MODIFICATION HISTORY: 04-06-2015 by Charles Bussy-Virat
;
;-

pro new_pdf_peak_combination_slope_time_from_beg_to_max, parameter, param_average_ok_from_start_of_peak_to_now, last_12_hours, param_now, $
   x_dist_slope_pdf_extrapolated, dist_slope_pdf_extrapolated,$
   x_dist_slope_gauss_extrapolated, dist_slope_gauss_extrapolated,$
   x_hist_time_from_min_to_max_peak_extrapolated, hist_time_from_min_to_max_peak_percentage_extrapolated,$   
   x12, p1, param_ahead_osra,param_ahead_osra_lag,a_pdf, b_osra_kill, c_pers,$
   time_max_from_now_median,time_max_from_now_mp, time_max_from_now_ensemble, $
   result_new_pdf_peak_model_median,result_new_pdf_peak_model_mp, result_new_pdf_peak_model_ensemble, $
   bestpred_new_pdf_peak_ensemble,time_max_from_now_median_method_slope,time_max_from_now_median_method_beg_to_max,time_max_from_now_mp_method_beg_to_max,$
   calculate_ensemble = calculate_ensemble_keyword, optimize_a_b = optimize_a_b_keyword
  


  day = 24.0
  ndaysprev = 5.0

  threshold_ensemble = fltarr(4)
  threshold_ensemble(0) = 0.10
  threshold_ensemble(1) = 0.25
  threshold_ensemble(2) = 0.75
  threshold_ensemble(3) = 0.90

;; predict the speeds in the peak and the time when the peak is reached
  if keyword_set(calculate_ensemble_keyword) eq 1 then begin
     pdf_peak_calculate_combination_slope_time_from_beg_to_max, parameter, param_average_ok_from_start_of_peak_to_now,$
        x_dist_slope_pdf_extrapolated, dist_slope_pdf_extrapolated,$
        x_dist_slope_gauss_extrapolated, dist_slope_gauss_extrapolated,$
        x_hist_time_from_min_to_max_peak_extrapolated, hist_time_from_min_to_max_peak_percentage_extrapolated,$
        time_max_from_now_median,time_max_from_now_mp,time_max_from_now_ensemble,$
        peak_predicted_median,peak_predicted_mp,peak_predicted_ensemble,$
        max_peak_predicted_median,max_peak_predicted_mp,time_max_from_now_median_method_slope,time_max_from_now_median_method_beg_to_max,time_max_from_now_mp_method_beg_to_max, calculate_ensemble = 1

     result_new_pdf_peak_model_ensemble = fltarr(n_elements(time_max_from_now_ensemble),ndaysprev*day)
  endif else begin
     pdf_peak_calculate_combination_slope_time_from_beg_to_max, parameter, param_average_ok_from_start_of_peak_to_now,$
        x_dist_slope_pdf_extrapolated, dist_slope_pdf_extrapolated,$
        x_dist_slope_gauss_extrapolated, dist_slope_gauss_extrapolated,$
        x_hist_time_from_min_to_max_peak_extrapolated, hist_time_from_min_to_max_peak_percentage_extrapolated,$        
        time_max_from_now_median,time_max_from_now_mp,time_max_from_now_ensemble,$
        peak_predicted_median,peak_predicted_mp,peak_predicted_ensemble,$
        max_peak_predicted_median,max_peak_predicted_mp,time_max_from_now_median_method_slope,time_max_from_now_median_method_beg_to_max,time_max_from_now_mp_method_beg_to_max, calculate_ensemble = 0

  endelse


  result_new_pdf_peak_model_median = fltarr(ndaysprev*day)
  result_new_pdf_peak_model_mp = fltarr(ndaysprev*day)



;; ;; ;;;;;;;;;;;;;; USE OF THE MEDIAN 
;; predict the speed after the peak is reached
  if time_max_from_now_median gt 0.0 then begin

     result_new_pdf_peak_model_median(0:time_max_from_now_median-1) = peak_predicted_median 
     if time_max_from_now_median ge 13.0 then begin
        result_new_pdf_peak_model_median_to_complete_temp = peak_predicted_median
     endif else begin
        result_new_pdf_peak_model_median_to_complete_temp = [ last_12_hours(12+( (time_max_from_now_median-1)-12 ):11), peak_predicted_median ]
     endelse

     result_pdf_model_in_old_pdf = fltarr(ndaysprev*day)

     pdf, parameter,x12,p1, result_new_pdf_peak_model_median_to_complete_temp(0:n_elements(result_new_pdf_peak_model_median_to_complete_temp)-2), result_new_pdf_peak_model_median_to_complete_temp(n_elements(result_new_pdf_peak_model_median_to_complete_temp)-1), fltarr(ndaysprev*day),fltarr(ndaysprev*day),a_pdf, b_osra_kill, c_pers, 1.0,result_pdf_model_in_old_pdf, bestpred_new_pdf_peak_ensemble_starting_from_median ,calculate_ensemble = 0, optimize_a_b = 0

     result_new_pdf_peak_model_median(time_max_from_now_median:ndaysprev*day-1) = result_pdf_model_in_old_pdf(1:ndaysprev*day - time_max_from_now_median )

  endif else begin

     pdf, parameter,x12,p1, last_12_hours, param_now, param_ahead_osra, param_ahead_osra_lag,a_pdf, b_osra_kill, c_pers, 0.0,result_new_pdf_peak_model_median, bestpred_new_pdf_peak_ensemble_starting_from_median,calculate_ensemble = 0, optimize_a_b = 1
     
  endelse



;; predict the speed after the peak is reached 

; ;; ;;;;;;;;;;;;;; USE OF ENSEMBLES. 
  if keyword_set(calculate_ensemble_keyword) eq 1 then begin

     for eee = 0L, n_elements(time_max_from_now_ensemble) - 1 do begin

        eee_invert = n_elements(threshold_ensemble) - 1 - eee   
        
        if time_max_from_now_median gt 0.0 then begin
           
           if threshold_ensemble(eee_invert) gt 0.5 then begin 

              result_new_pdf_peak_model_ensemble(eee_invert,0:time_max_from_now_ensemble(eee_invert)-1) = peak_predicted_ensemble(eee_invert,0:time_max_from_now_ensemble(eee_invert)-1) 
              
              result_new_pdf_peak_model_ensemble(eee_invert,time_max_from_now_ensemble(eee_invert):ndaysprev*day-1) = result_new_pdf_peak_model_median(time_max_from_now_ensemble(eee_invert):ndaysprev*day-1) + ( result_new_pdf_peak_model_ensemble(eee_invert,time_max_from_now_ensemble(eee_invert)-1) - result_new_pdf_peak_model_median(time_max_from_now_ensemble(eee_invert)-1) )


           endif else begin ;; ;; for percentiles below the median (10 and 25 for instance)
              
              result_new_pdf_peak_model_ensemble(eee_invert,*) =  result_new_pdf_peak_model_median - ( result_new_pdf_peak_model_ensemble(n_elements(threshold_ensemble)-1-eee_invert,*) - result_new_pdf_peak_model_median )
              
           endelse

           
        endif else begin
           
           pdf, parameter,x12,p1, last_12_hours, param_now, param_ahead_osra, param_ahead_osra_lag,a_pdf, b_osra_kill, c_pers, 0.0,result_new_pdf_peak_model_ensemble_not_here, bestpred_new_pdf_peak_ensemble, calculate_ensemble = 1, optimize_a_b = 1

           result_new_pdf_peak_model_ensemble(eee_invert,*) = bestpred_new_pdf_peak_ensemble(eee_invert,*)

        endelse

     endfor

  endif
  


  return

end
