;+
; NAME: pdf_final_with_peak.pro;
;
; PURPOSE: last procedure that makes the PDF predictions. See
; Bussy-Virat and Ridley [2015] for description of this procedure
; (tree decisions)
;
; CALLING SEQUENCE:
; new_pdf_peak_combination_slope_time_from_beg_to_max, pdf
;
; INPUTS: 
; PARAMETER = parameter to be predicted (ex: speed)
; LAST_12_HOURS = values of parameter in the last 12 hours (redundant with param_average_ok_speed)
; PARAM_NOW = value of parameter now from the running average
; (redundant with param_average_ok_speed)
; PARAM_NOW_NOT_RUNNING_AVERAGE = value of parameter now (redundant with param_average_ok_speed)
; INDEX_NOW = index of the current time
; PARAM_AVERAGE_OK_SPEED = running average of the speed as read in
; ACE data file
; PARAM_AVERAGE_OK_IMF = running average of the IMF as read in                                                                               
; ACE data file   
; PARAM_AVERAGE_OK_DENSITY = running average of the density as read in   
; ACE data file   
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
; PRED_PEAK = 0 if a peak is predicted, 1 if not (used in pdf.pro)

; KEYWORD PARAMETERS: calculate_ensemble = 0 to get only the median
;prediction, 1 to get the  10%, 25%, 75% and 90% quadratiles predictions as well 
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
;
; MODIFICATION HISTORY: 04-06-2015 by Charles Bussy-Virat
;
;-
pro pdf_final_with_peak, parameter, last_12_hours, param_now,param_now_not_running_average, $
                         index_now, param_average_ok_speed,param_average_ok_imf,param_average_ok_density,$
                         x_dist_slope_pdf_extrapolated, dist_slope_pdf_extrapolated,$
                         x_dist_slope_gauss_extrapolated, dist_slope_gauss_extrapolated,$
                         x_hist_time_from_min_to_max_peak_extrapolated, hist_time_from_min_to_max_peak_percentage_extrapolated,$
                         x12, p1, param_ahead_osra,param_ahead_osra_lag,a_pdf, b_osra_kill, c_pers, pred_peak,$
                         time_max_from_now_median,time_max_from_now_mp, time_max_from_now_ensemble, $
                         result_new_pdf_peak_model_median,result_new_pdf_peak_model_mp, result_new_pdf_peak_model_ensemble, $
                         calculate_ensemble = calculate_ensemble_keyword





  rotation = 648.0
  ndaysprev = 5.0
  day = 24.0

  bin_slope = 2.0       ;; bin of the max slopes for the PDFs of amplitude depending on the max slopes
  min_max_slope = 4.77  ;; min of the max slopes for the PDFs of amplitude depending on the max slopes   
  max_max_slope = 50.55 ;; max of the max slopes for the PDFs of amplitude depending on the max slopes 

  



     if keyword_set(calculate_ensemble_keyword) eq 0 then begin

              slope_step_here = 5.0
              www = 0L
              while param_average_ok_speed( index_now - www ) - param_average_ok_speed( index_now - www - slope_step_here ) ge 0 do begin
                 www++
              endwhile
              while param_average_ok_speed( index_now - www ) ge param_average_ok_speed( index_now - www - 1 ) do begin
                 www++
              endwhile
              
              start_of_peak = index_now - www 
              param_average_ok_from_start_of_peak_to_now = fltarr( index_now - start_of_peak + 1 )
              param_average_ok_from_start_of_peak_to_now = param_average_ok_speed( start_of_peak : index_now)
              
              step_slope = 2.0 
              time_from_start_peak_to_now = n_elements( param_average_ok_from_start_of_peak_to_now )
              
              if time_from_start_peak_to_now ge (step_slope + 1.0) then begin ;; ;; if the increase has started at least 3 hours ago

                 all_slope_until_now = fltarr(time_from_start_peak_to_now  ) - 1000000.0
                 for jjj = 0L, time_from_start_peak_to_now - step_slope - 1 do begin
                    all_slope_until_now(jjj) = ( param_average_ok_from_start_of_peak_to_now( jjj + step_slope ) - param_average_ok_from_start_of_peak_to_now( jjj ) ) / step_slope      
                 endfor
                 max_slope_until_now = max(all_slope_until_now( where( all_slope_until_now gt -100000.0 ) ) )
                 


                 if max_slope_until_now ge min_max_slope and max_slope_until_now lt (max_max_slope - bin_slope) then begin 
                    
                    time_max_from_now_median = -1000000.0

                    new_pdf_peak_combination_slope_time_from_beg_to_max, 'speed', param_average_ok_from_start_of_peak_to_now, param_average_ok_speed(index_now-12:index_now-1), param_average_ok_speed(index_now), $
                       x_dist_slope_pdf_extrapolated, dist_slope_pdf_extrapolated,$
                       x_dist_slope_gauss_extrapolated, dist_slope_gauss_extrapolated,$
                       x_hist_time_from_min_to_max_peak_extrapolated, hist_time_from_min_to_max_peak_percentage_extrapolated,$
                       x12, p1, param_average_ok_speed(index_now-rotation:index_now-rotation+ndaysprev*day-1),param_average_ok_speed(index_now-rotation:index_now-rotation+ndaysprev*day-1),a_pdf, b_osra_kill, c_pers,$
                       time_max_from_now_median,time_max_from_now_mp, time_max_from_now_ensemble, $
                       result_new_pdf_peak_model_median,result_new_pdf_peak_model_mp, result_new_pdf_peak_model_ensemble, $
                       bestpred_new_pdf_peak_ensemble,time_max_from_now_median_method_slope,time_max_from_now_median_method_beg_to_max,time_max_from_now_mp_method_beg_to_max,$
                       calculate_ensemble = 0, optimize_a_b = 0


                 endif else begin
                    pdf, 'speed', x12, p1, last_12_hours, param_now, param_ahead_osra, param_ahead_osra_lag, a_pdf, b_osra_kill, c_pers, pred_peak, result_new_pdf_peak_model_median, result_new_pdf_peak_model_ensemble,calculate_ensemble = 0, optimize_a_b = 1 
                 endelse
                 
              endif else begin
                 pdf, 'speed', x12, p1, last_12_hours, param_now, param_ahead_osra, param_ahead_osra_lag, a_pdf, b_osra_kill, c_pers, pred_peak, result_new_pdf_peak_model_median, result_new_pdf_peak_model_ensemble,calculate_ensemble = 0, optimize_a_b = 1 
              endelse
              
        
     endif



     if keyword_set(calculate_ensemble_keyword) eq 1 then begin

              
              slope_step_here = 5.0
              www = 0L
              while param_average_ok_speed( index_now - www ) - param_average_ok_speed( index_now - www - slope_step_here ) ge 0 do begin
                 www++
              endwhile
              while param_average_ok_speed( index_now - www ) ge param_average_ok_speed( index_now - www - 1 ) do begin
                 www++
              endwhile
              
              start_of_peak = index_now - www 
              param_average_ok_from_start_of_peak_to_now = fltarr( index_now - start_of_peak + 1 )
              param_average_ok_from_start_of_peak_to_now = param_average_ok_speed( start_of_peak : index_now)
              
              step_slope = 2.0 
              time_from_start_peak_to_now = n_elements( param_average_ok_from_start_of_peak_to_now )

              if time_from_start_peak_to_now ge (step_slope + 1.0) then begin ;; ;; if the increase has started at least 3 hours ago

                 all_slope_until_now = fltarr(time_from_start_peak_to_now  ) - 1000000.0
                 for jjj = 0L, time_from_start_peak_to_now - step_slope - 1 do begin
                    all_slope_until_now(jjj) = ( param_average_ok_from_start_of_peak_to_now( jjj + step_slope ) - param_average_ok_from_start_of_peak_to_now( jjj ) ) / step_slope      
                 endfor
                 max_slope_until_now = max(all_slope_until_now( where( all_slope_until_now gt -100000.0 ) ) )
                

 
                 if max_slope_until_now ge min_max_slope and max_slope_until_now lt (max_max_slope - bin_slope) then begin 
                    
                    time_max_from_now_median = -1000000.0

                    new_pdf_peak_combination_slope_time_from_beg_to_max, 'speed', param_average_ok_from_start_of_peak_to_now, param_average_ok_speed(index_now-12:index_now-1), param_average_ok_speed(index_now), $
                       x_dist_slope_pdf_extrapolated, dist_slope_pdf_extrapolated,$
                       x_dist_slope_gauss_extrapolated, dist_slope_gauss_extrapolated,$
                       x_hist_time_from_min_to_max_peak_extrapolated, hist_time_from_min_to_max_peak_percentage_extrapolated,$
                       x12, p1, param_average_ok_speed(index_now-rotation:index_now-rotation+ndaysprev*day-1),param_average_ok_speed(index_now-rotation:index_now-rotation+ndaysprev*day-1),a_pdf, b_osra_kill, c_pers,$
                       time_max_from_now_median,time_max_from_now_mp, time_max_from_now_ensemble, $
                       result_new_pdf_peak_model_median,result_new_pdf_peak_model_mp, result_new_pdf_peak_model_ensemble, $
                       bestpred_new_pdf_peak_ensemble,time_max_from_now_median_method_slope,time_max_from_now_median_method_beg_to_max,time_max_from_now_mp_method_beg_to_max,$
                       calculate_ensemble = 1, optimize_a_b = 0
                 
                    order_in_envelop = fltarr(4,ndaysprev*day)
                    for oie = 0L, ndaysprev*day - 1 do begin
                       order_in_envelop(0,oie) = min( result_new_pdf_peak_model_ensemble(*,oie) )
                       order_in_envelop(1,oie) = min( result_new_pdf_peak_model_ensemble( where( result_new_pdf_peak_model_ensemble(*,oie) gt order_in_envelop(0,oie) ), oie ) ) 
                       order_in_envelop(2,oie) = min( result_new_pdf_peak_model_ensemble( where( result_new_pdf_peak_model_ensemble(*,oie) gt order_in_envelop(1,oie) ), oie ) ) 
                       order_in_envelop(3,oie) = max( result_new_pdf_peak_model_ensemble(*,oie) )                                
                    endfor
                    
                    result_new_pdf_peak_model_ensemble(0,*) = order_in_envelop(0,*)
                    result_new_pdf_peak_model_ensemble(1,*) = order_in_envelop(1,*)
                    result_new_pdf_peak_model_ensemble(2,*) = order_in_envelop(2,*)
                    result_new_pdf_peak_model_ensemble(3,*) = order_in_envelop(3,*)


                 

                 endif else begin
                    pdf, 'speed', x12, p1, last_12_hours, param_now, param_ahead_osra, param_ahead_osra_lag, a_pdf, b_osra_kill, c_pers, pred_peak, result_new_pdf_peak_model_median, result_new_pdf_peak_model_ensemble,calculate_ensemble = 1, optimize_a_b = 1 
                  
                 endelse

              endif else begin
                 pdf, 'speed', x12, p1, last_12_hours, param_now, param_ahead_osra, param_ahead_osra_lag, a_pdf, b_osra_kill, c_pers, pred_peak, result_new_pdf_peak_model_median, result_new_pdf_peak_model_ensemble,calculate_ensemble = 1, optimize_a_b = 1 
               
              endelse
;; ;; this is to correct for the intial value of the prediction
;; (current speed) so that it is equal to the current speed in the ACE
;; data and not the current speed of the running average
              for eee = 0L,  3 do begin
                 result_new_pdf_peak_model_ensemble(eee, *) = result_new_pdf_peak_model_ensemble(eee, *) - param_now(0) + param_now_not_running_average(0)
              endfor
              
        
           endif



;; ;; this is to correct for the intial value of the prediction
;; (current speed) so that it is equal to the current speed in the ACE
;; data and not the current speed of the running average
     result_new_pdf_peak_model_median = result_new_pdf_peak_model_median - param_now(0) + param_now_not_running_average(0)


return

end



