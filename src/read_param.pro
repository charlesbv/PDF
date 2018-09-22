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
; NAME: read_param.pro
;
; PURPOSE: second and last procedure that reads the ACE data file and
; returns the parameter in the ACE data file and its 11 hrs running
; average (parameter = speed, density, temperature, IMF,
; f107). Performs a linear interpolation for f10.7. It gets rid of
; value like 999 set these values to the most recent correct
;
; CALLING SEQUENCE: read_param_temp
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
;
;-
pro read_param, parameter, end_date, param, param_average_ok, time_converted_with_date_conv_ready_to_plot

  PATH=!PATH+':'+Expand_Path('+./')

  day = 24.0
  rotation = 648.0          

  if parameter ne 'imf' then read_param_temp, parameter, end_date, param, param_average_ok, time_converted_with_date_conv_ready_to_plot

;;   if parameter eq 'imf' then begin
;; ;;;;;;;;;;;;;;;;;; 
;;      parameter = 'bx'
;;      read_param_temp, parameter, end_date, param_bx, param_average_ok_bx, time_converted_with_date_conv_ready_to_plot_bx
;; ;;;;;;;;;;;;;;;;;; 
;;      parameter = 'by'
;;      read_param_temp, parameter,  end_date, param_by, param_average_ok_by, time_converted_with_date_conv_ready_to_plot_by
;; ;;;;;;;;;;;;;;;;;; 
;;      parameter = 'bz'
;;      read_param_temp, parameter, end_date, param_bz, param_average_ok_bz, time_converted_with_date_conv_ready_to_plot_bz

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      imf_magn = fltarr(n_elements(param_bz))
;;      imf_magn = sqrt( param_bx^2.0 + param_by^2.0 + param_bz^2.0 )
;;      param = imf_magn

;;      imf_magn_average = fltarr(n_elements(param_bz))
     
;;      for i=5, n_elements(param_bz)-6 do begin
;;         sp = imf_magn(i-5:i+5)
;;         imf_magn_average(i) = mean(sp)
;;      endfor

;;      imf_magn_average_ok = imf_magn_average
;;      imf_magn_average_oktemp = where(imf_magn_average eq 0)
;;      imf_magn_average_ok(imf_magn_average_oktemp) = imf_magn(imf_magn_average_oktemp)
;;      param_average_ok = imf_magn_average_ok

;;      time_converted_with_date_conv_ready_to_plot = time_converted_with_date_conv_ready_to_plot_bz
;; ;; End of IMF magnitude and running...
;;  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;   endif

  return

end
