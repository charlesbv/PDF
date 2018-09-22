;+
; NAME: plot_pdf_pred_shade.pro
;
; PURPOSE: plot the prediction with the actual speed
;
; INPUTS: 
; name_plot = name of the plot
; result_new_pdf_peak_model_median = median prediction by the PDF model
; result_new_pdf_peak_model_ensemble = quadratiles predictions (10%,
; 25%, 75%, 90%) by the PDF model   
; param_speed = actual speed
; index_now = index (in the ACE data file (basically the line
; number)) of the time representing the current time of the prediction
; time_converted_with_date_conv_ready_to_plot_speed = time in the ACE data
; file in a nice format
; ensemble_or_not = 0 to get only the median prediction, 1 to get the
; 10%, 25%, 75% and 90% quadratiles predictions as well
; time_converted_with_date_conv_ready_to_plot_speed_plus_5_days = same
; as time_converted_with_date_conv_ready_to_plot_speed + the 5 days after the current time
;
; MODIFICATION HISTORY: 04-06-2015 by Charles Bussy-Virat
;
;-
pro plot_pdf_pred_shade, name_plot, result_new_pdf_peak_model_median, result_new_pdf_peak_model_ensemble,param_speed,index_now, time_converted_with_date_conv_ready_to_plot_speed,ensemble_or_not, time_converted_with_date_conv_ready_to_plot_speed_plus_5_days


  ndaysprev = 5.
  day = 24.


  setdevice,name_plot,'p',5
  loadct, 39
  
  space=0.15
  pos_space, 1, space, sizes,nx=1
  get_position, 1, space, sizes, 0, pos
  pos = [0.1, 0.3, 0.9, 0.8]

  last_index_observation = min([index_now+ndaysprev*day-1, n_elements(param_speed)-1])

  if ensemble_or_not eq 1 then begin
     min_yaxis = min([250.,min(result_new_pdf_peak_model_ensemble),min(result_new_pdf_peak_model_median),min(param_speed(index_now:last_index_observation))])
     max_yaxis = max([750.,max(result_new_pdf_peak_model_median),max(result_new_pdf_peak_model_ensemble),max(param_speed(index_now:last_index_observation))])
  endif else begin
     min_yaxis = 250.;min([min(result_new_pdf_peak_model_median),min(param_speed(index_now:last_index_observation))])
     max_yaxis = 750.;max([max(result_new_pdf_peak_model_median),max(param_speed(index_now:last_index_observation))])
  endelse
  min_xaxis = 0
  max_xaxis = ndaysprev*day-1

  plot,result_new_pdf_peak_model_median,xstyle=5,ystyle=9,/nodata,$
       pos = pos,title= 'PDF Model - '+strmid(time_converted_with_date_conv_ready_to_plot_speed(index_now),0,10)+' '+strmid(time_converted_with_date_conv_ready_to_plot_speed(index_now),11,5)+' to '+strmid(time_converted_with_date_conv_ready_to_plot_speed_plus_5_days(index_now+ndaysprev*day),0,10)+' '+strmid(time_converted_with_date_conv_ready_to_plot_speed_plus_5_days(index_now+ndaysprev*day),11,5),ytitle = 'Speed (km/s)',thick = 4, yrange =[min_yaxis, max_yaxis]



;; ;; XAXIS

  oplot,[min_xaxis, max_xaxis], [min_yaxis, min_yaxis]
  oplot,[min_xaxis, max_xaxis], [max_yaxis, max_yaxis]

  delta_max_min_yaxis = max_yaxis - min_yaxis
  height_tick = delta_max_min_yaxis / 60.0
  dt_ticks = 6                                  
  nb_ticks = ( max_xaxis - min_xaxis + 1 ) / dt_ticks 


  for i = 0L, nb_ticks  do begin
     oplot, [i*dt_ticks, i*dt_ticks], [min_yaxis, min_yaxis + height_tick ]
     oplot, [i*dt_ticks, i*dt_ticks], [max_yaxis, max_yaxis - height_tick ]
     if i mod 2 eq 0 then begin
        xyouts, i*dt_ticks, min_yaxis - 3*height_tick, strmid(time_converted_with_date_conv_ready_to_plot_speed_plus_5_days(index_now + i*dt_ticks),5,5),align = 0.5
        xyouts, i*dt_ticks, min_yaxis - 5.7*height_tick, strmid(time_converted_with_date_conv_ready_to_plot_speed_plus_5_days(index_now + i*dt_ticks),11,5),align = 0.5
     endif
  endfor

  xyouts, ( min_xaxis + max_xaxis ) / 2.0,  min_yaxis - 10*height_tick, 'Real time',align = 0.5,CHARTHICK = 0.001


  if ensemble_or_not eq 1 then begin
;;;;;;;; ;;;;;;;;;;; ;;;;;;;;; SHADE 10-90%
     x_10_90_x = dindgen(ndaysprev*day)
     y_10_y = fltarr(ndaysprev*day)
     y_90_y = fltarr(ndaysprev*day)
     for tyu = 0L, ndaysprev*day - 1 do begin
        y_10_y(tyu) = result_new_pdf_peak_model_ensemble(0,tyu)
        y_90_y(tyu) = result_new_pdf_peak_model_ensemble(3,tyu)
     endfor

     loadct,14

     shade_x_10_90_x = [min(x_10_90_x),x_10_90_x,max(x_10_90_x),reverse(x_10_90_x)]
     shade_10_y_90_y = [ y_90_y(0),y_90_y,y_10_y(n_elements(y_10_y)-1),reverse(y_10_y)]
     POLYFILL, shade_x_10_90_x, shade_10_y_90_y   ,color = 250,thick = 3
;;;;;;;;;;; ;;;;;;;; END OF SHADE 10-90%

;;;;;;;; ;;;;;;;;;;; ;;;;;;;;; SHADE 25-75%
     x_25_75_x = dindgen(ndaysprev*day)
     y_25_y = fltarr(ndaysprev*day)
     y_75_y = fltarr(ndaysprev*day)
     for tyu = 0L, ndaysprev*day - 1 do begin
        y_25_y(tyu) = result_new_pdf_peak_model_ensemble(1,tyu)
        y_75_y(tyu) = result_new_pdf_peak_model_ensemble(2,tyu)
     endfor
     loadct,1
     shade_x_25_75_x = [min(x_25_75_x),x_25_75_x,max(x_25_75_x),reverse(x_25_75_x)]
     shade_25_y_75_y = [ y_75_y(0),y_75_y,y_25_y(n_elements(y_25_y)-1),reverse(y_25_y)]
     POLYFILL, shade_x_25_75_x, shade_25_y_75_y,color = 247
;;;;;;;;;;; ;;;;;;;; END OF SHADE 25-75%

     loadct,39
     for eee = 0L, 4 - 1 do begin
        if eee  eq 0L or eee eq 3L then oplot,result_new_pdf_peak_model_ensemble(eee,*), color = 240,thick = 4
        if eee  eq 1L or eee eq 2L then oplot,result_new_pdf_peak_model_ensemble(eee,*), color = 100,thick = 4
     endfor


  endif

  loadct,39  

  oplot,result_new_pdf_peak_model_median,color = 60, thick = 4
  oplot,param_speed(index_now:last_index_observation), thick = 4

;; YAXIS
  AXIS, YAXIS=1, YSTYLE = 1,ytickname=REPLICATE(' ', 60)


  if n_elements(param_speed(index_now:last_index_observation)) ge 2 then begin
     nrms_observation_prediction = sqrt( mean( ( param_speed(index_now:last_index_observation) - result_new_pdf_peak_model_median(0:last_index_observation-index_now) )^2. ) / mean( ( param_speed(index_now:last_index_observation) )^2. ) )

     correlation_observation_prediction = c_correlate( param_speed(index_now:last_index_observation), result_new_pdf_peak_model_median(0:last_index_observation-index_now), 0 )

     
     xyouts,  min_xaxis + 5,  max_yaxis - 7*height_tick,'N-RMS = '+strtrim(string(nrms_observation_prediction,'(f5.2)'),2)+'.'
     xyouts,  min_xaxis + 5,  max_yaxis - 10*height_tick,'Correlation = '+strtrim(string(correlation_observation_prediction,'(f5.2)'),2)+'.'
  endif
  


  closedevice




end
