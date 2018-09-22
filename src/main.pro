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
; NAME: main.pro
;
; PURPOSE: run the PDF model
;
; CALLING SEQUENCE: find_index_now, read_param, pdf_final_with_peak, plot_pdf_pred_shade
;
; INPUTS: 
; ensemble_or_not = 0 to get only the median prediction, 1 to get the
; 10%, 25%, 75% and 90% quadratiles predictions as well
; user_want_to_plot = 0 to not make a plot of the prediction, 1 to
; make one
; user_want_file = 0 to not make a results file of the prediction, 1 to 
; make one         
; end_date = date representing the current time of the prediction
;
; OUTPUTS: none
;
; MODIFICATION HISTORY: 04-06-2015 by Charles Bussy-Virat
;
;-


pro main, ensemble_or_not,user_want_to_plot,user_want_file,end_date

;; ;; Calculate index_now
  find_index_now,end_date, index_now
;; ;;

  PATH=!PATH+':'+Expand_Path('+./')

  rotation = 648.0
  ndaysprev = 5.0
  day = 24.0

;; ;; read the ACE data file and get the speed and running average of the speed
  parameter = 'speed'
  read_param, parameter,  end_date, param_speed, param_average_ok_speed, time_converted_with_date_conv_ready_to_plot_speed
;; ;;

;; ;; this represents the value at 10%, 25%, 75%, and 90% quadratiles
  threshold_ensemble = fltarr(4)
  threshold_ensemble(0) = 0.10
  threshold_ensemble(1) = 0.25
  threshold_ensemble(2) = 0.75
  threshold_ensemble(3) = 0.90
;; ;;
  nb_day = float( n_elements( param_speed ) / day ) 
  
;; ;; these are the parameters used in the PDF of the amplitude of the peak as a function of the max slope in the peak
  min_max_slope = 4.77   
  max_max_slope = 50.55
  max_max_slope_for_pdf_slope = 20.0
  bin_slope = 2.0
;; ;;

;;  ;;  LOAD PDFs
;; ;; PDF MAX SLOPE
  restore,'./X_DIST_SLOPE_PDF_EXTRAPOLATED__++__DIST_SLOPE_PDF_EXTRAPOLATED__++__bin_slope_'+strtrim(string(bin_slope,format='(f5.1)'),2)+'++__min_slope_'+strtrim(string(min_max_slope,format='(f6.2)'),2)+'++__max_slope_'+strtrim(string(max_max_slope_for_pdf_slope,format='(f6.2)'),2)+'__'+strtrim('19950101',2)+'_'+strtrim('20111231',2)+'.dat'
;; ;; PDF SLOPE GAUSSIAN
  restore,'./X_DIST_SLOPE_GAUSS_EXTRAPOLATED__++__DIST_SLOPE_GAUSS_EXTRAPOLATED__++__bin_slope_'+strtrim(string(bin_slope,format='(f5.1)'),2)+'++__min_slope_'+strtrim(string(min_max_slope,format='(f6.2)'),2)+'++__max_slope_'+strtrim(string(max_max_slope,format='(f6.2)'),2)+'__'+strtrim('19950101',2)+'_'+strtrim('20111231',2)+'.dat'

;; ;; PDF TIME FROM BEGINNING TO MAX
  restore,'./X_HIST_TIME_FROM_MIN_TO_MAX_PEAK_EXTRAPOLATED__++__HIST_TIME_FROM_MIN_TO_MAX_PEAK_PERCENTAGE_EXTRAPOLATED'+'__'+strtrim('19950101',2)+'_'+strtrim('20111231',2)+'.dat'

;; ;; PDF P1
  restore, './X12_++_P1_'+'speed'+'_'+strtrim(string('19950101'),2)+'_'+strtrim(string('20111231'),2)+'.dat'
;; ;;


;; ;; v_pred = a*v_pdf + b*osra and choose also when to use the persistence model
  a_pdf = fltarr(ndaysprev*day) + 1.0
  b_osra_kill = fltarr(ndaysprev*day) + 1.0
  c_pers = fltarr(ndaysprev*day) + 1.0
;; ;;
;; ;; make prediction  
  pdf_final_with_peak,  'speed', param_average_ok_speed(index_now-12:index_now-1), param_average_ok_speed(index_now), param_speed(index_now),$
                        index_now, param_average_ok_speed,dindgen(2), dindgen(2),$
                        x_dist_slope_pdf_extrapolated, dist_slope_pdf_extrapolated,$
                        x_dist_slope_gauss_extrapolated, dist_slope_gauss_extrapolated,$
                        x_hist_time_from_min_to_max_peak_extrapolated, hist_time_from_min_to_max_peak_percentage_extrapolated,$
                        x12, p1, param_average_ok_speed(index_now-rotation:index_now-rotation+ndaysprev*day-1),param_average_ok_speed(index_now-rotation:index_now-rotation+ndaysprev*day-1),a_pdf, b_osra_kill, c_pers, 0.0,$
                        time_max_from_now_median,time_max_from_now_mp, time_max_from_now_ensemble, $
                        result_new_pdf_peak_model_median,result_new_pdf_peak_model_mp, result_new_pdf_peak_model_ensemble, calculate_ensemble = ensemble_or_not
;; ;;

;; ;; make the plot and the result file
  if user_want_to_plot eq 1 or user_want_file eq 1 then begin


;; ;; get the 5 days after the current time
     time_converted_with_date_conv_ready_to_plot_speed_plus_5_days = strarr(n_elements(time_converted_with_date_conv_ready_to_plot_speed)+ndaysprev*day)

     time_converted_with_date_conv_ready_to_plot_speed_plus_5_days(0:n_elements(time_converted_with_date_conv_ready_to_plot_speed)-1) = time_converted_with_date_conv_ready_to_plot_speed

     time_converted_with_date_conv_ready_to_plot_speed_plus_5_days_temp = strmid(time_converted_with_date_conv_ready_to_plot_speed(n_elements(time_converted_with_date_conv_ready_to_plot_speed)-1),0,10)+' '+strmid(time_converted_with_date_conv_ready_to_plot_speed(n_elements(time_converted_with_date_conv_ready_to_plot_speed)-1),11,5)+':00.00'

     time_converted_with_date_conv_ready_to_plot_speed_plus_5_days_temp_2 = double(fltarr(ndaysprev*day))
     for i = 0L, ndaysprev*day-1 do begin
        time_converted_with_date_conv_ready_to_plot_speed_plus_5_days_temp_2(i) = date_conv(time_converted_with_date_conv_ready_to_plot_speed_plus_5_days_temp,'J') + double(i+1)/24d
        time_converted_with_date_conv_ready_to_plot_speed_plus_5_days(n_elements(time_converted_with_date_conv_ready_to_plot_speed)+i) = strmid(date_conv(time_converted_with_date_conv_ready_to_plot_speed_plus_5_days_temp_2(i),'F'),0,16)
     endfor


;; ;; 
  endif

  if user_want_to_plot eq 1 then begin


     name_plot = '../out/plots/PDF_speed_'+strmid(end_date,0,4)+'-'+strmid(end_date,4,2)+'-'+strmid(end_date,6,2)+'-'+strmid(end_date,8,2)+'00'+'.ps'

     plot_pdf_pred_shade, name_plot,result_new_pdf_peak_model_median, result_new_pdf_peak_model_ensemble,param_speed,index_now,time_converted_with_date_conv_ready_to_plot_speed, ensemble_or_not, time_converted_with_date_conv_ready_to_plot_speed_plus_5_days
     

  endif


  if user_want_file eq 1 then begin
     last_index_observation = min([index_now+ndaysprev*day-1, n_elements(param_speed)-1])
     
     close, 3
     fname_results='../out/files/results_PDF_speed_'+strmid(end_date,0,4)+'-'+strmid(end_date,4,2)+'-'+strmid(end_date,6,2)+'-'+strmid(end_date,8,2)+'00'+'.txt'


     OPENW,3,fname_results

     PRINTF,3,'***********************************************************'
     PRINTF,3,'************************ PDF MODEL ************************'
     PRINTF,3,'***********************************************************'
     PRINTF,3,'** Predictions from '+time_converted_with_date_conv_ready_to_plot_speed_plus_5_days(index_now)+' to '+time_converted_with_date_conv_ready_to_plot_speed_plus_5_days(index_now+ndaysprev*day-1)+' **'
     

  if n_elements(param_speed(index_now:last_index_observation)) ge 2 then begin
     nrms_observation_prediction = sqrt( mean( ( param_speed(index_now:last_index_observation) - result_new_pdf_peak_model_median(0:last_index_observation-index_now) )^2. ) / mean( ( param_speed(index_now:last_index_observation) )^2. ) )

     correlation_observation_prediction = c_correlate( param_speed(index_now:last_index_observation), result_new_pdf_peak_model_median(0:last_index_observation-index_now), 0 )

     PRINTF,3,''
     PRINTF,3,'N-RMS between the observation and the prediction: '+strtrim(string(nrms_observation_prediction,'(f5.2)'),2)+'.'
     PRINTF,3,'Correlation between the observation and the prediction: '+strtrim(string(correlation_observation_prediction,'(f5.2)'),2)+'.'
endif

     if ensemble_or_not eq 1 then begin
        
        where_betw_25_75 = where( param_speed(index_now: last_index_observation) ge result_new_pdf_peak_model_ensemble(1,*) and param_speed(index_now: last_index_observation) le result_new_pdf_peak_model_ensemble(2,*), where_betw_25_75c)
        time_betw_25_75 = where_betw_25_75c
        width_25_75 = mean( result_new_pdf_peak_model_ensemble(2,*) - result_new_pdf_peak_model_ensemble(1,*) )
        
        where_betw_10_90 = where( param_speed(index_now: last_index_observation) ge result_new_pdf_peak_model_ensemble(0,*) and param_speed(index_now: last_index_observation) le result_new_pdf_peak_model_ensemble(3,*), where_betw_10_90c)
        time_betw_10_90 = where_betw_10_90c
        width_10_90 = mean( result_new_pdf_peak_model_ensemble(3,*) - result_new_pdf_peak_model_ensemble(0,*) )
        
        PRINTF, 3, ''
        PRINTF,3,'Time the observed speed spent between the 25% and 75% quadratiles: '+strtrim(string(uint(time_betw_25_75)),2)+' hours.'
        PRINTF,3,'Time the observed speed spent between the 10% and 90% quadratiles: '+strtrim(string(uint(time_betw_10_90)),2)+' hours.'
        PRINTF,3,'Mean width at 25%-75%: '+strtrim(string(width_25_75,'(F5.1)'),2)+' km/s.'
        PRINTF,3,'Mean width at 10%-90%: '+strtrim(string(width_10_90,'(F5.1)'),2)+' km/s.'

        PRINTF,3,''
        PRINTF,3,'    '+strtrim('REAL TIME    ACTUAL  PDF    PDF    PDF    PDF    PDF',2)
        PRINTF,3,strtrim('YYYY-MM-DDTHH:MM SPEED  MEDIAN  10%    25%    75%    90%',2) 

        for i = 0L, ndaysprev*day-1 do begin
           if (i+index_now) le last_index_observation then begin
              PRINTF,3,time_converted_with_date_conv_ready_to_plot_speed_plus_5_days(index_now+i),param_speed(index_now+i),result_new_pdf_peak_model_median(i), result_new_pdf_peak_model_ensemble(*,i), format='(a16,1X,F7.2,1X,F7.2,1X,F7.2,1X,F7.2,1X,F7.2,1X,F7.2)'
           endif else begin
              PRINTF,3,time_converted_with_date_conv_ready_to_plot_speed_plus_5_days(index_now+i),'',result_new_pdf_peak_model_median(i), result_new_pdf_peak_model_ensemble(*,i), format='(a16,1X,F7.2,1X,F7.2,1X,F7.2,1X,F7.2,1X,F7.2,1X,F7.2)'
           endelse
        endfor

     endif else begin



        PRINTF,3,''
        PRINTF,3,'    '+strtrim('REAL TIME    ACTUAL  PDF',2)
        PRINTF,3,strtrim('YYYY-MM-DDTHH:MM SPEED  MEDIAN',2) 




        for i = 0L, ndaysprev*day-1 do begin
           if (i+index_now) le last_index_observation then begin
              PRINTF,3,time_converted_with_date_conv_ready_to_plot_speed_plus_5_days(index_now+i),param_speed(index_now+i),result_new_pdf_peak_model_median(i), format='(a16,1X,F7.2,1X,F7.2)'
           endif else begin
              PRINTF,3,time_converted_with_date_conv_ready_to_plot_speed_plus_5_days(index_now+i),'',result_new_pdf_peak_model_median(i), format='(a16,1X,F7.2,1X,F7.2)'
           endelse
        endfor

     endelse

     close,3

  endif
;; ;;



end
