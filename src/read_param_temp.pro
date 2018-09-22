;+
; NAME: read_param_temp.pro
;
; PURPOSE: first procedure that reads the ACE data file and
; returns the parameter in the ACE data file and its 11 hrs running
; average (parameter = speed, density, temperature, bx, by, bz, f107). It gets rid of
; value like 999 set these values to the most recent correct
; value. Performs a linear interpolation for f10.7
;
; CALLING SEQUENCE: extrapolate_linear
;
; INPUTS:
; parameter = the parameter we want to read in the ACE data file =
; speed or density or IMF (need to uncomment for the density and the IMF)
; end_date = date representing the current time of the prediction 
;
; OUTPUTS: 
; param = parameter read in the ACE data file  
; param_average_ok = 11 hrs running average of parameter
; time_converted_with_date_conv_ready_to_plot = time in the ACE data
; file in a nice format
;
; MODIFICATION HISTORY: 04-06-2015 by Charles Bussy-Virat
;-

pro read_param_temp, parameter, end_date, param, param_average_ok, time_converted_with_date_conv_ready_to_plot

;;  !PATH=!PATH+':'+Expand_Path('+./data_base/idl_pro')

  day = 24.0
  rotation = 648.0               ; number of hours during a solar rotation (27 days)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; READ FILE FROM OMNIWEB ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  name_file_converted = 'PDF_speed_'+strmid(end_date,0,4)+'-'+strmid(end_date,4,2)+'-'+strmid(end_date,6,2)+'-'+strmid(end_date,8,2)+'00'+'.txt'
  file_to_read =  '../data/'+name_file_converted

  close,1
  openr,1,file_to_read

  line = ''
  c_line = 0L
  while strpos(line,'YEAR') eq -1 do begin
     readf,1,line
     c_line ++
  endwhile

  tmp = fltarr(4)
  nHours = file_lines(file_to_read)-15.0-c_line ; number of hours in the file to read
  time_yr  = fltarr(nHours)
  time_day  = fltarr(nHours)
  time_hr  = fltarr(nHours)
  param = fltarr(nHours)
  time_to_convert_with_date_conv_to_plot = double(fltarr(nHours))
  time_converted_with_date_conv_ready_to_plot = strarr(nHours)
  for i = 0L, nHours-1 do begin
     readf,1,tmp
     time_yr(i)  = tmp(0)
     time_day(i) = tmp(1)
     time_hr(i)  = tmp(2)
     param(i)    = tmp(3)
     if param(i) eq -9999.9 then param(i) = 9999.0
    time_to_convert_with_date_conv_to_plot(i) =  time_day(i) + time_hr(i)/24d + time_yr(i)*1000d
    time_converted_with_date_conv_ready_to_plot(i) = strmid( date_conv(double(time_to_convert_with_date_conv_to_plot(i)) ,'F'), 0, 16 )
 endfor
  
  close,1

  parameter_array = ['speed', 'f107', 'bx', 'by', 'bz', 'temperature', 'density']
  where_parameter_chosen = where( parameter_array eq strtrim(string(parameter),2) )
  where_parameter_chosen_scalar = where_parameter_chosen(0)
  
;; ;; We remove from param all the values in omniWeb that are not correct
;; ;; (999.9 for instance) and set these values to the most recent
;; ;; correct value
  value_omniWeb_not_correct_array = [9999.0, 999.9, 999.9, 999.9 , 999.9, 9999999.0, 999.9]
  value_omniWeb_not_correct = value_omniWeb_not_correct_array(where_parameter_chosen_scalar)
  value_omniWeb_not_correct_scalar = value_omniWeb_not_correct(0)

  if param(0) eq value_omniWeb_not_correct_scalar then param(0) = mean( param( where( param ne value_omniWeb_not_correct_scalar ) ) )
  for nnn = 1L, nHours - 1 do begin
     if param(nnn) eq value_omniWeb_not_correct_scalar then param(nnn) = param(nnn-1)
  endfor
;; ;;


  if where_parameter_chosen_scalar eq 1.0 then begin

;; ;; Linear interpolation of f10.7

     f107_that_will_be_extrapolated = dindgen(nHours/day+2)
     for eee = 1L, nHours/day do begin
        f107_that_will_be_extrapolated(eee) = param(-12.0+day*eee)
     endfor
     f107_that_will_be_extrapolated(0)  = f107_that_will_be_extrapolated(1)
     f107_that_will_be_extrapolated(nHours/day+1) = f107_that_will_be_extrapolated(nHours/day)
     y_to_extrapolate = f107_that_will_be_extrapolated 

     x_before_extrapolation = fltarr(nHours/day+2)
     for eee = 1L, nHours/day do begin
        x_before_extrapolation(eee) = -12.0 + day*eee
     endfor
     x_before_extrapolation(0) = 0.0
     x_before_extrapolation(nHours/day+1) = nHours-1

     x_after_extrapolation = dindgen(nHours)

     extrapolate_linear, y_to_extrapolate,x_before_extrapolation,x_after_extrapolation,y_extrapolated

     f107_as_in_omniWeb = fltarr(nHours)
     f107_as_in_omniWeb = param

     for eee = 0L, nHours - 1 do begin
        param(eee) = y_extrapolated(eee)
     endfor

  endif
;; ;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END OF READ FILE FROM OMNIWEB ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; RUNNING AVERAGE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  value_range_ok = [ [0.0, 1200.0], $;; ATTENTION: do not change these values
                     [0.0,500.0], $
                     [-80.0, 80.0], $
                     [-80.0, 80.0], $
                     [-200.0, 200.0], $
                     [0.0, 1.0*10^7.0], $
                   [0.0, 120.0] ]
                     
  param_average = fltarr(nHours)

  min_rangetemp = value_range_ok(0, where_parameter_chosen_scalar)
  max_rangetemp = value_range_ok(1, where_parameter_chosen_scalar)
  min_range = min_rangetemp(0)
  max_range = max_rangetemp(0)
  for i=5, nHours-6 do begin
     sp = param(i-5:i+5)
     l = where(sp gt min_range and sp lt max_range,c)
     if c gt 0 then param_average(i) = mean(sp(l)) else param_average(i)=max_range
  endfor

  param_average_ok = param_average
  param_average_oktemp = where(param_average eq 0)
  param_average_ok(param_average_oktemp) = param(param_average_oktemp)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END OF RUNNING AVERAGE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  

  return

end
