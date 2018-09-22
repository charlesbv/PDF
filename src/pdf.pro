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
; NAME: pdf.pro 
;
; PURPOSE: prediction of the speeds using the version in Bussy-Virat
; and Ridley [2014] and used in the modifed version in Bussy-Virat and
; Ridley [2015]
;
; CALLING SEQUENCE: none
;
; INPUTS: 
; PARAMETER = parameter to be predicted (ex: speed)
; X12 = x axis of the PDF P1 and P2 (see Bussy-Virat and Ridley
; [2014]) (used in pdf.pro)
; P1 = PDF P1 (see Bussy-Virat and Ridley [2014])
; LAST_12_HOURS = values of parameter in the last 12 hours 
; PARAM_NOW = value of parameter now from the running average
; PARAM_AHEAD_OSRA = parameter one solar rotation ago (redundant with
; param_average_ok_speed) 
; PARAM_AHEAD_OSRA_LAG = arameter one solar rotation ago - optimum lag (redundant
; with param_average_ok_speed)     
; A_PDF = a factor in v_pred (see Bussy-Virat and Ridley [2014])  =
; vector 120* 1 
; B_OSRA_KILL = b factor in v_pred (see Bussy-Virat and Ridley [2014])
; = vector 120*1 
; C_PERS = use or not of the persistence model  (see Bussy-Virat and
; Ridley [2014]) = vector 120*1 
; PRED_PEAK = 0 if a peak is predicted, 1 if not 
;
;; KEYWORD PARAMETERS: calculate_ensemble = 0 to get only the median
;prediction, 1 to get the  10%, 25%, 75% and 90% quadratiles predictions as well 
; OPTIMIZE_A_B = for the used of the PDF in pdf.pro, 1 to use the
; optimize set of a and b as detailed in Bussy-Virat and Ridley
; [2014], 0 to use a and b as chosen as inputs by the user
;
;
; OUTPUTS:
; RESULT_PRED = result of the preditcion by the PDF median,
; RESULT_PRED_ENSEMBLE = result of the preditcion by the PDF quadratiles (10%, 25%, 75%, 90%)
;
;
; MODIFICATION HISTORY: 04-07-2015 by Charles Bussy-Virat
;
;-
pro pdf, parameter, x12, p1, last_12_hours, param_now, param_ahead_osra, param_ahead_osra_lag, a_pdf, b_osra_kill, c_pers, pred_peak, result_pred, result_pred_ensemble,calculate_ensemble = calculate_ensemble_keyword, optimize_a_b = optimize_a_b_keyword

;;; ;;; !!!!!!!!!!!!!!!!!!!!
;; last_12_hours = param_average_ok(indexnow-12:indexnow-1)
;; param_now = param_average_ok(indexnow)
;; param_ahead_osra = param_average_ok(indexnow-rotation:indexnow-rotation+ndaysprev*day-1)
;; param_ahead_osra_lag = param_average_ok(indexnow-rotation-lag_best_per_rot:indexnow-rotation-lag_best_per_rot+ndaysprev*day-1)
;; a_pdf = fltarr(ndaysprev*day)
;; b_osra_kill = fltarr(ndaysprev*day)
;; c_pers = fltarr(ndaysprev*day)+1
;;;;; ;;;; !!!!!!!!!!!!!!!


;;  !PATH=!PATH+':'+Expand_Path('+./data_base/idl_pro')

  parameter_array = ['speed', 'f107', 'bx', 'by', 'bz']
  where_parameter_chosen = where( parameter_array eq strtrim(string(parameter),2) )
  where_parameter_chosen_scalar = where_parameter_chosen(0)
  
  value_range_ok = [ [0.0, 1200.0], $ ;; ATTENTION: if we change these values, we need to change them also in the procedures pdf_calculate.pro and nrms_error.pro
                     [0.0,500.0], $
                     [-80.0, 80.0], $
                     [-80.0, 80.0], $
                     [-200.0, 200.0] ]
  

  min_rangetemp = value_range_ok(0, where_parameter_chosen_scalar)
  max_rangetemp = value_range_ok(1, where_parameter_chosen_scalar)
  min_range = min_rangetemp(0)
  max_range = max_rangetemp(0)


;; Choice of the bin size,  the boundaries of the speed NOW and choice of the boundaries of P1 and P2
  sizebin_arr = [20.0, 3.0, 1.0, 1.0, 1.0] ;; ATTENTION: if we change these values, we need to change them also in the procedure pdf_calculate.pro
  sizebin_temp = sizebin_arr(where_parameter_chosen_scalar)
  sizebin = sizebin_temp(0)

  min_param_now_arr = [240.0, 65.0, -12.0, -14.0, -200.0] ;; ATTENTION: if we change these values, we need to change them also in the procedure pdf_calculate.pro
  min_param_temp = min_param_now_arr(where_parameter_chosen_scalar)
  min_param_now = min_param_temp(0)

  max_param_now_arr = [740.0, 281.0, 12.0, 14.0, 200.0] ;; ATTENTION: if we change these values, we need to change them also in the procedure pdf_calculate.pro
  max_param_temp = max_param_now_arr(where_parameter_chosen_scalar)
  max_param_now = max_param_temp(0)


  if where_parameter_chosen_scalar eq 0 then begin
     param_range_considered = findgen( (max_param_now - min_param_now) / sizebin + 1.0 ) * sizebin + min_param_now ;; the speed NOW can vary between min_param_now and max_param_now km/s
     
  endif else if where_parameter_chosen_scalar eq 1 then begin
     param_range_considered = findgen( (max_param_now - min_param_now) / sizebin + 1.0 ) * sizebin + min_param_now ;; f107 NOW can vary between min_param_now and max_param_now
     
  endif else if where_parameter_chosen_scalar eq 2 then begin
     param_range_considered = findgen( (max_param_now - min_param_now) / sizebin + 1.0 ) * sizebin + min_param_now ;; Bx NOW can vary between min_param_now and max_param_now nT
     
  endif else if where_parameter_chosen_scalar eq 3 then begin
     param_range_considered = findgen( (max_param_now - min_param_now) / sizebin + 1.0 ) * sizebin + min_param_now ;; By NOW can vary between min_param_now and max_param_now nT
     
  endif else if where_parameter_chosen_scalar eq 4 then begin
     param_range_considered = findgen( (max_param_now - min_param_now) / sizebin + 1.0 ) * sizebin + min_param_now ;; Bz NOW can vary between min_param_now and max_param_now nT
     
  end
;; End of choice of the bin sizes...


;; Choice of the boundaries of the slope for P1 and P2
;; ATTENTION: if we change these values, we need to change them also in the procedure pdf_calculate.pro 
  if where_parameter_chosen_scalar eq 0 then begin
     slope_arr = [0.0, 15.0, 50.0]                          ;; Slope boundaries for the speed. Attention: put the boundaries in increasing order
  endif else if where_parameter_chosen_scalar eq 1 then begin
     slope_arr = [0.0]                                           ;; Slope boundaries for f107. Attention: put the boundaries in increasing order
  endif else if where_parameter_chosen_scalar eq 2 then begin
     slope_arr = [0.0]                                             ;; Slope boundaries for Bx. Attention: put the boundaries in increasing order
  endif else if where_parameter_chosen_scalar eq 3 then begin
     slope_arr = [0.0]                                             ;; Slope boundaries for By. Attention: put the boundaries in increasing order
  endif else if where_parameter_chosen_scalar eq 4 then begin
     slope_arr = [0.0]                                             ;; Slope boundaries for Bz. Attention: put the boundaries in increasing order
  end
;; End of choice of the boundaries of the slope...


  day = 24d
  ndaysprev = 5d
  
;; ;;if the user chooses to use the set of a and b that optimizes the predictions (cf Bussy-Virat and Ridley, 2014)
  if keyword_set(optimize_a_b_keyword) eq 1 then begin

     b_osra_kill = fltarr(ndaysprev*day) + 1.0 ;; ;; the optimum lag is never used: whatever the prediction horizon, we use the speed exactly 27 days ago. NOTE that in the paper, it says that we should use the optimum lag (and not 27d exactly) for hours beatween 8 and 12. However, the difference in the NMRS error between using the opitmum lag and using 27d exactly is not big for this prediction horizon: less than 0.5%. Therefore, in order to save computational time (by avoiding to calculate the optimum lag each time we make a prediction), we choose to not use the optimum lag at all.
     for a_fill = 1L, 7 do begin
        c_pers(a_fill) = 0L  ;; the values of a and b do not matter because we only use the persistence model for the first 7 hours
     endfor

     a_pdf(8) = 0.9

     for a_fill = 9L, 12 do begin
        a_pdf(a_fill) = 0.8
     endfor

     for a_fill = 13L, 17 do begin
        a_pdf(a_fill) = 0.9
     endfor

     for a_fill = 18L, 32 do begin
        a_pdf(a_fill) = 0.8
     endfor

     for a_fill = 33L, 51 do begin
        a_pdf(a_fill) = 0.7
     endfor

     for a_fill = 52L, 89 do begin
        a_pdf(a_fill) = 0.6
     endfor

     for a_fill = 90L, ndaysprev*day-1 do begin
        a_pdf(a_fill) = 0.5
     endfor

  endif


  b_osra = 1 - a_pdf
  b_osra_lag = 1 - a_pdf

  pers = fltarr(ndaysprev*day)
  result_pred = fltarr(ndaysprev*day)

  result_pred_ensemble = fltarr(4,ndaysprev*day) 
  threshold_ensemble = fltarr(4)
  threshold_ensemble(0) = 0.10
  threshold_ensemble(1) = 0.25
  threshold_ensemble(2) = 0.75
  threshold_ensemble(3) = 0.90

  pers = param_now(0)+fltarr(ndaysprev*day) 

  result_pred(0) = param_now

  if result_pred(0) le min_range || result_pred(0) ge max_range then result_pred(0) = last_12_hours(11)
  if result_pred(0) le min_range || result_pred(0) ge max_range then result_pred(0) = last_12_hours(10)
  if result_pred(0) le min_range || result_pred(0) ge max_range then result_pred(0) = last_12_hours(9)
  if result_pred(0) le min_range || result_pred(0) ge max_range then result_pred(0) = last_12_hours(8)
  if result_pred(0) le min_range || result_pred(0) ge max_range then result_pred(0) = last_12_hours(7)
  if result_pred(0) le min_range || result_pred(0) ge max_range then result_pred(0) = last_12_hours(6)
  if result_pred(0) le min_range || result_pred(0) ge max_range then result_pred(0) = last_12_hours(5)
  if result_pred(0) le min_range || result_pred(0) ge max_range then result_pred(0) = last_12_hours(4)
  if result_pred(0) le min_range || result_pred(0) ge max_range then result_pred(0) = last_12_hours(3)
  if result_pred(0) le min_range || result_pred(0) ge max_range then result_pred(0) = last_12_hours(2)
  if result_pred(0) le min_range || result_pred(0) ge max_range then result_pred(0) = last_12_hours(1)
  if result_pred(0) le min_range || result_pred(0) ge max_range then result_pred(0) = last_12_hours(0)     

  for eee = 0L, 3 do begin
     result_pred_ensemble(eee,0) = result_pred(0)
  endfor

  p1_to_use = fltarr(n_elements(param_range_considered),ndaysprev*day+1,n_elements(x12))

  x_after_extrapolation = dindgen( ( abs(max(x12) - min(x12)) ) + 1) + min( x12 )

  i = floor( (result_pred(0)-min_param_now) / sizebin )

;; ;; ;; If the param now, one hour and 12 hours ago are in between the range of correct values
  if (param_now gt min_param_now and param_now lt max_param_now and last_12_hours(0) gt min_param_now and last_12_hours(0) lt max_param_now and last_12_hours(11) gt min_param_now and last_12_hours(11) lt max_param_now) then begin

     slope = last_12_hours(11) - last_12_hours(0)
    
     if pred_peak eq 1.0 then slope = -slope

;; If there is at least 2 thresholds in slope_arr
     if n_elements(slope_arr) ge 2 then begin
        if slope le slope_arr(0) then begin
           for hhh = 1L, ndaysprev*day do begin
              p1_to_use(i,hhh,*) = p1(i,hhh,*,0)
           endfor
        endif
        for sss = 0L, n_elements(slope_arr) - 2 do begin
           if slope gt slope_arr(sss) and slope le slope_arr(sss+1) then begin
              for hhh = 1L, ndaysprev*day do begin
                 p1_to_use(i,hhh,*) = p1(i,hhh,*,sss+1)
              endfor
           endif
        endfor
        if slope gt slope_arr(n_elements(slope_arr)-1) then begin
           for hhh = 1L, ndaysprev*day do begin
              p1_to_use(i,hhh,*) = p1(i,hhh,*,n_elements(slope_arr))
           endfor
        endif
;; End if there is at least 2 thresholds in slope_arr
        
     endif else begin
;; ;; If there is only one threshold in slope_arr
        if slope le slope_arr(0) then begin
           for hhh = 1L, ndaysprev*day do begin
              p1_to_use(i,hhh,*) = p1(i,hhh,*,0)
           endfor
        endif else begin
           for hhh = 1L, ndaysprev*day do begin
              p1_to_use(i,hhh,*) = p1(i,hhh,*,1)
           endfor
        endelse
;; ;; End of if there is only one threshold in slope_arr
     endelse


;; Beginning of predictions      
     for j = 1L, ndaysprev*day-1 do begin


        extrapolate_linear, p1_to_use(i,j,*),x12,x_after_extrapolation,y_extrapolated
        p1_to_use_extrapolated = fltarr(n_elements(x_after_extrapolation))
        p1_to_use_extrapolated = y_extrapolated
        
        inc = 0L
        p1_median = 0L
        while total(p1_to_use_extrapolated(0:inc)) lt total(p1_to_use_extrapolated)/2d do inc = inc + 1L
        p1_median = x_after_extrapolation(inc)
        result_pred(j) = ( a_pdf(j)*p1_median + b_osra(j)*param_ahead_osra(j)*b_osra_kill(j) + (1-b_osra_kill(j))*b_osra_lag(j)*param_ahead_osra_lag(j) ) * c_pers(j) + (1-c_pers(j))*pers(j)
        

        ;;;;;; ENSEMBLE ;;;;;
        if keyword_set(calculate_ensemble_keyword) eq 1 then begin
        
           inc_ensemble = fltarr(4)
           p1_ensemble = fltarr(4)
           for eee = 0L, 3 do begin
              while total(p1_to_use_extrapolated(0:inc_ensemble(eee))) lt total(p1_to_use_extrapolated)*threshold_ensemble(eee) do inc_ensemble(eee) = inc_ensemble(eee) + 1L
              p1_ensemble(eee) = x_after_extrapolation(inc_ensemble(eee))
              result_pred_ensemble(eee,j) = (a_pdf(j)*p1_ensemble(eee) + b_osra(j)*param_ahead_osra(j)*b_osra_kill(j) + (1-b_osra_kill(j))*b_osra_lag(j)*param_ahead_osra_lag(j)) * c_pers(j)+(1-c_pers(j))*pers(j)
           endfor
           
        endif
        ;;;;;; END OF ENSEMBLE ;;;;;        

     endfor

             

;; End of beginning of predictions
;; ;; ;; End of if the param now, one hour and 12 hours ago are in between the range of correct values

;; ;; ;; Predictions if the param now, one hour and 12 hours ago are NOT in between the range of correct values

  endif else if param_now ge max_param_now then begin


     slope = last_12_hours(11) - last_12_hours(0)
     
;; If there is at least 2 thresholds in slope_arr
     if n_elements(slope_arr) ge 2 then begin
        if slope le slope_arr(0) then begin
           for hhh = 1L, ndaysprev*day do begin
              p1_to_use(floor( (max_param_now-min_param_now) / sizebin )-1,hhh,*) = p1(floor( (max_param_now-min_param_now) / sizebin )-1,hhh,*,0)
           endfor
        endif
        for sss = 0L, n_elements(slope_arr) - 2 do begin
           if slope gt slope_arr(sss) and slope le slope_arr(sss+1) then begin
              for hhh = 1L, ndaysprev*day do begin
                 p1_to_use(floor( (max_param_now-min_param_now) / sizebin )-1,hhh,*) = p1(floor( (max_param_now-min_param_now) / sizebin )-1,hhh,*,sss+1)
              endfor
           endif
        endfor
        if slope gt slope_arr(n_elements(slope_arr)-1) then begin
           for hhh = 1L, ndaysprev*day do begin
              p1_to_use(floor( (max_param_now-min_param_now) / sizebin )-1,hhh,*) = p1(floor( (max_param_now-min_param_now) / sizebin )-1,hhh,*,n_elements(slope_arr))
           endfor
        endif
;; End if there is at least 2 thresholds in slope_arr
        
     endif else begin
;; ;; If there is only one threshold in slope_arr
        if slope le slope_arr(0) then begin
           for hhh = 1L, ndaysprev*day do begin
              p1_to_use(floor( (max_param_now-min_param_now) / sizebin )-1,hhh,*) = p1(floor( (max_param_now-min_param_now) / sizebin )-1,hhh,*,0)
           endfor
        endif else begin
           for hhh = 1L, ndaysprev*day do begin
              p1_to_use(floor( (max_param_now-min_param_now) / sizebin )-1,hhh,*) = p1(floor( (max_param_now-min_param_now) / sizebin )-1,hhh,*,1)
           endfor
        endelse
;; ;; End of if there is only one threshold in slope_arr
     endelse

     delta_max_param_now = param_now - ( max_param_now - sizebin )
     for j = 1L, ndaysprev*day-1 do begin

        extrapolate_linear, p1_to_use(floor( (max_param_now-min_param_now) / sizebin )-1,j,*),x12,x_after_extrapolation,y_extrapolated
        p1_to_use_extrapolated = fltarr(n_elements(x_after_extrapolation))
        p1_to_use_extrapolated = y_extrapolated
        inc = 0L
        p1_median = 0L
        while total(p1_to_use_extrapolated(0:inc)) lt total(p1_to_use_extrapolated)/2d do inc = inc + 1L
        p1_median = x_after_extrapolation(inc) + delta_max_param_now
        result_pred(j) = ( a_pdf(j)*p1_median + b_osra(j)*param_ahead_osra(j)*b_osra_kill(j) + (1-b_osra_kill(j))*b_osra_lag(j)*param_ahead_osra_lag(j) ) * c_pers(j) + (1-c_pers(j))*pers(j)
        
        ;;;;;; ENSEMBLE ;;;;;
        if keyword_set(calculate_ensemble_keyword) eq 1 then begin
           inc_ensemble = fltarr(4)
           p1_ensemble = fltarr(4)
           for eee = 0L, 3 do begin
              while total(p1_to_use_extrapolated(0:inc_ensemble(eee))) lt total(p1_to_use_extrapolated)*threshold_ensemble(eee) do inc_ensemble(eee) = inc_ensemble(eee) + 1L
              p1_ensemble(eee) = x_after_extrapolation(inc_ensemble(eee)) + delta_max_param_now
              result_pred_ensemble(eee,j) = (a_pdf(j)*p1_ensemble(eee) + b_osra(j)*param_ahead_osra(j)*b_osra_kill(j) + (1-b_osra_kill(j))*b_osra_lag(j)*param_ahead_osra_lag(j)) * c_pers(j)+(1-c_pers(j))*pers(j)
           endfor
        endif
        ;;;;;; END OF ENSEMBLE ;;;;;        

     endfor
  endif else if param_now le min_param_now then begin


     slope = last_12_hours(11) - last_12_hours(0)
     
;; If there is at least 2 thresholds in slope_arr
     if n_elements(slope_arr) ge 2 then begin
        if slope le slope_arr(0) then begin
           for hhh = 1L, ndaysprev*day do begin
              p1_to_use(0,hhh,*) = p1(0,hhh,*,0)
           endfor
        endif
        for sss = 0L, n_elements(slope_arr) - 2 do begin
           if slope gt slope_arr(sss) and slope le slope_arr(sss+1) then begin
              for hhh = 1L, ndaysprev*day do begin
                 p1_to_use(0,hhh,*) = p1(0,hhh,*,sss+1)
              endfor
           endif
        endfor
        if slope gt slope_arr(n_elements(slope_arr)-1) then begin
           for hhh = 1L, ndaysprev*day do begin
              p1_to_use(0,hhh,*) = p1(0,hhh,*,n_elements(slope_arr))
           endfor
        endif
;; End if there is at least 2 thresholds in slope_arr
        
     endif else begin
;; ;; If there is only one threshold in slope_arr
        if slope le slope_arr(0) then begin
           for hhh = 1L, ndaysprev*day do begin
              p1_to_use(0,hhh,*) = p1(0,hhh,*,0)
           endfor
        endif else begin
           for hhh = 1L, ndaysprev*day do begin
              p1_to_use(0,hhh,*) = p1(0,hhh,*,1)
           endfor
        endelse
;; ;; End of if there is only one threshold in slope_arr
     endelse

     delta_min_param_now = param_now - min_param_now ;; negative
     for j = 1L, ndaysprev*day-1 do begin

        extrapolate_linear, p1_to_use(0,j,*),x12,x_after_extrapolation,y_extrapolated
        p1_to_use_extrapolated = fltarr(n_elements(x_after_extrapolation))
        p1_to_use_extrapolated = y_extrapolated
        
        inc = 0L
        p1_median = 0L
        while total(p1_to_use_extrapolated(0:inc)) lt total(p1_to_use_extrapolated)/2d do inc = inc + 1L
        p1_median = x_after_extrapolation(inc) + delta_min_param_now
        result_pred(j) = ( a_pdf(j)*p1_median + b_osra(j)*param_ahead_osra(j)*b_osra_kill(j) + (1-b_osra_kill(j))*b_osra_lag(j)*param_ahead_osra_lag(j) ) * c_pers(j) + (1-c_pers(j))*pers(j)
        
        ;;;;;; ENSEMBLE ;;;;;
        if keyword_set(calculate_ensemble_keyword) eq 1 then begin
           inc_ensemble = fltarr(4)
           p1_ensemble = fltarr(4)
           for eee = 0L, 3 do begin
              while total(p1_to_use_extrapolated(0:inc_ensemble(eee))) lt total(p1_to_use_extrapolated)*threshold_ensemble(eee) do inc_ensemble(eee) = inc_ensemble(eee) + 1L
              p1_ensemble(eee) = x_after_extrapolation(inc_ensemble(eee)) + delta_min_param_now
              result_pred_ensemble(eee,j) = (a_pdf(j)*p1_ensemble(eee) + b_osra(j)*param_ahead_osra(j)*b_osra_kill(j) + (1-b_osra_kill(j))*b_osra_lag(j)*param_ahead_osra_lag(j)) * c_pers(j)+(1-c_pers(j))*pers(j)
           endfor
        endif
        ;;;;;; END OF ENSEMBLE ;;;;;        

     endfor
  endif





  return

end
