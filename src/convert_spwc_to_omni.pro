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
pro convert_spwc_to_omni, end_date, next_month_or_not

;;PATH=!PATH+':'+Expand_Path('+./data_base/idl_pro') 

name_file_converted = 'PDF_speed_'+strmid(end_date,0,4)+'-'+strmid(end_date,4,2)+'-'+strmid(end_date,6,2)+'-'+strmid(end_date,8,2)+'00'+'.txt'


;;;;;;;; ;;;;;;;;; READ TWO MONTH AGO FILE


  file_to_read =  '../data/two_months_ago.txt'

  close,1
  openr,1,file_to_read

  line1 = ''
c_line1 = 0L
while strpos(line1,'#-------------------------------------------------------------------------') eq -1 do begin
   readf,1,line1
   c_line1 ++
endwhile

tmp = fltarr(10)
nHours1 = file_lines(file_to_read)-c_line1             
year1  = intarr(nHours1)
month1  = fltarr(nHours1)
day1  = fltarr(nHours1)
hour1 = intarr(nHours1)
speed1 = fltarr(nHours1)
dofy = intarr(nHours1)

for i = 0L, nHours1-1 do begin
   readf,1,tmp
   speed1(i)   = tmp(8)
   year1(i)  = uint(tmp(0))
   month1(i)  = tmp(1)
   day1(i)  = tmp(2)
   hour1(i)  = tmp(3)/100.
   dofy(i) = uint(ymd2dn(year1(i),month1(i),day1(i)))
endfor

close, 1

close, 2
fname='../data/'+name_file_converted 
OPENW,2,fname
printf,2,'YEAR','DOY','HR','1',format='(a,1X,a,1X,a,1X,a)'

for i = 0L, nHours1-1 do begin
   PRINTF,2,year1(i),dofy(i),hour1(i),speed1(i), format='(i0,1X,i0,1X,i0,1X,F7.1)'
endfor




;;;;;;;; ;;;;;;;;; END OF READ TWO MONTH AGO FILE



;;;;;;;; ;;;;;;;;; READ ONE MONTH AGO FILE

  file_to_read =  '../data/one_month_ago.txt'

  close,1
  openr,1,file_to_read

  line1 = ''
c_line1 = 0L
while strpos(line1,'#-------------------------------------------------------------------------') eq -1 do begin
   readf,1,line1
   c_line1 ++
endwhile

tmp = fltarr(10)
nHours1 = file_lines(file_to_read)-c_line1             
year1  = intarr(nHours1)
month1  = fltarr(nHours1)
day1  = fltarr(nHours1)
hour1 = intarr(nHours1)
speed1 = fltarr(nHours1)
dofy = intarr(nHours1)

for i = 0L, nHours1-1 do begin
   readf,1,tmp
   speed1(i)   = tmp(8)
   year1(i)  = uint(tmp(0))
   month1(i)  = tmp(1)
   day1(i)  = tmp(2)
   hour1(i)  = tmp(3)/100.
   dofy(i) = uint(ymd2dn(year1(i),month1(i),day1(i)))
endfor

close, 1


for i = 0L, nHours1-1 do begin
   PRINTF,2,year1(i),dofy(i),hour1(i),speed1(i), format='(i0,1X,i0,1X,i0,1X,F7.1)'
endfor


;;;;;;;; ;;;;;;;;; END OF READ ONE MONTH AGO FILE


;;;;;;;; ;;;;;;;;; READ CURRENT MONTH FILE
  file_to_read =  '../data/current_month.txt'

  close,1
  openr,1,file_to_read

  line1 = ''
c_line1 = 0L
while strpos(line1,'#-------------------------------------------------------------------------') eq -1 do begin
   readf,1,line1
   c_line1 ++
endwhile

tmp = fltarr(10)
nHours1 = file_lines(file_to_read)-c_line1             
year1  = intarr(nHours1)
month1  = fltarr(nHours1)
day1  = fltarr(nHours1)
hour1 = intarr(nHours1)
speed1 = fltarr(nHours1)
dofy = intarr(nHours1)

for i = 0L, nHours1-1 do begin
   readf,1,tmp
   speed1(i)   = tmp(8)
   year1(i)  = uint(tmp(0))
   month1(i)  = tmp(1)
   day1(i)  = tmp(2)
   hour1(i)  = tmp(3)/100.
   dofy(i) = uint(ymd2dn(year1(i),month1(i),day1(i)))
endfor

close,1
for i = 0L, nHours1-1 do begin
   PRINTF,2,year1(i),dofy(i),hour1(i),speed1(i), format='(i0,1X,i0,1X,i0,1X,F7.1)'
endfor


if next_month_or_not eq 0 then begin
   for i = 0L, 14 do begin
      printf,2,'END OF FILE',format='(a)'
   endfor
   CLOSE,2
endif

;;;;;;;; ;;;;;;;;; END OF READ CURRENT MONTH FILE

if next_month_or_not eq 1 then begin
;;;;;;;; ;;;;;;;;; READ NEXT MONTH FILE
   file_to_read =  '../data/next_month.txt'

   close,1
   openr,1,file_to_read

   line1 = ''
   c_line1 = 0L
   while strpos(line1,'#-------------------------------------------------------------------------') eq -1 do begin
      readf,1,line1
      c_line1 ++
   endwhile

   tmp = fltarr(10)
   nHours1 = file_lines(file_to_read)-c_line1             
   year1  = intarr(nHours1)
   month1  = fltarr(nHours1)
   day1  = fltarr(nHours1)
   hour1 = intarr(nHours1)
   speed1 = fltarr(nHours1)
   dofy = intarr(nHours1)

   for i = 0L, nHours1-1 do begin
      readf,1,tmp
      speed1(i)   = tmp(8)
      year1(i)  = uint(tmp(0))
      month1(i)  = tmp(1)
      day1(i)  = tmp(2)
      hour1(i)  = tmp(3)/100.
      dofy(i) = uint(ymd2dn(year1(i),month1(i),day1(i)))
   endfor

   close,1
   for i = 0L, nHours1-1 do begin
      PRINTF,2,year1(i),dofy(i),hour1(i),speed1(i), format='(i0,1X,i0,1X,i0,1X,F7.1)'
   endfor



   for i = 0L, 14 do begin
      printf,2,'END OF FILE',format='(a)'
   endfor
   CLOSE,2

endif

;;;;;;;; ;;;;;;;;; END OF READ NEXT MONTH FILE




end
