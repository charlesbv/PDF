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
PRO DAYCNV, XJD, YR, MN, DAY, HR
;+
; NAME:
;       DAYCNV
; PURPOSE:
;       Converts Julian dates to Gregorian calendar dates
;
; CALLING SEQUENCE:
;       DAYCNV, XJD, YR, MN, DAY, HR
;
; INPUTS:
;       XJD = Julian date, positive double precision scalar or vector
;
; OUTPUTS:
;       YR = Year (Integer)
;       MN = Month (Integer)
;       DAY = Day (Integer)
;       HR = Hours and fractional hours (Real).   If XJD is a vector,
;               then YR,MN,DAY and HR will be vectors of the same length.
;
; EXAMPLE:
;       IDL> DAYCNV, 2440000.D, yr, mn, day, hr    
;
;       yields yr = 1968, mn =5, day = 23, hr =12.   
;
; WARNING:
;       Be sure that the Julian date is specified as double precision to
;       maintain accuracy at the fractional hour level.
;
; METHOD:
;       Uses the algorithm of Fliegel and Van Flandern (1968) as reported in
;       the "Explanatory Supplement to the Astronomical Almanac" (1992), p. 604
;       Works for all Gregorian calendar dates with XJD > 0, i.e., dates after
;       -4713 November 23.
; REVISION HISTORY:
;       Converted to IDL from Yeoman's Comet Ephemeris Generator, 
;       B. Pfarr, STX, 6/16/88
;       Converted to IDL V5.0   W. Landsman   September 1997
;-
 On_error,2
 compile_opt idl2

 if N_params() lt 2 then begin
    print,"Syntax - DAYCNV, xjd, yr, mn, day, hr'
    print,'  Julian date, xjd, should be specified in double precision'
    return
 endif

; Adjustment needed because Julian day starts at noon, calendar day at midnight

 jd = long(xjd)                         ;Truncate to integral day
 frac = double(xjd) - jd + 0.5          ;Fractional part of calendar day
 after_noon = where(frac ge 1.0, Next)
 if Next GT 0 then begin                ;Is it really the next calendar day?
      frac[after_noon] = frac[after_noon] - 1.0
      jd[after_noon] = jd[after_noon] + 1
 endif
 hr = frac*24.0
 l = jd + 68569
 n = 4*l / 146097l
 l = l - (146097*n + 3l) / 4
 yr = 4000*(l+1) / 1461001
 l = l - 1461*yr / 4 + 31        ;1461 = 365.25 * 4
 mn = 80*l / 2447
 day = l - 2447*mn / 80
 l = mn/11
 mn = mn + 2 - 12*l
 yr = 100*(n-49) + yr + l
 return
 end
