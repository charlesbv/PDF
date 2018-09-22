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
; NAME: find_index_now.pro

; PURPOSE: calculate the index (in the ACE data file (basically the line number)) of the time representing the current time of
; the prediction
;
; CALLING SEQUENCE: none
;
; INPUTS: end_date_chosen_idl = date representing the current time of the prediction
;
; OUTPUTS: index_now = index (in the ACE data file (basically the line
; number)) of the time representing the current time of the prediction
;
; MODIFICATION HISTORY: 04-06-2015 by Charles Bussy-Virat
;
;-
pro find_index_now, end_date_chosen_idl, index_now

  name_file_converted = 'PDF_speed_'+strmid(end_date_chosen_idl,0,4)+'-'+strmid(end_date_chosen_idl,4,2)+'-'+strmid(end_date_chosen_idl,6,2)+'-'+strmid(end_date_chosen_idl,8,2)+'00'+'.txt'

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
     time_to_convert_with_date_conv_to_plot(i) =  time_day(i) + time_hr(i)/24d + time_yr(i)*1000d
     time_converted_with_date_conv_ready_to_plot(i) = strmid( date_conv(double(time_to_convert_with_date_conv_to_plot(i)) ,'F'), 0, 16 )
  endfor
  
  close,1

  end_date_find = STRMID(end_date_chosen_idl, 0, 4)+'-'+STRMID(end_date_chosen_idl, 4, 2)+'-'+STRMID(end_date_chosen_idl, 6, 2)+'T'+STRMID(end_date_chosen_idl, 8, 2)+':00'
  index_end_file = where(time_converted_with_date_conv_ready_to_plot eq end_date_find)

  index_now = index_end_file


end
