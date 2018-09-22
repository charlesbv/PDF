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
;
; get_position
;
; used in conjunction with pos_space. Determines the position of the current
; plotting region, given the output parameters from pos_space.
;
; Input parameters:
; nb, space, bs, nbx, nby, xoff, yoff, xf, yf - Outputs from pos_space
; pos_num - the number of the plot, ranges from 0 : bs-1
;
; Output parameters:
;
; pos - the position of the plot, used in the plot command
;
; modified to make rectangles on Jan 2, 1998

pro get_position, nb, space, sizes, pos_num, pos, rect = rect,		$
		  xmargin = xmargin, ymargin = ymargin

  xipos = fix(pos_num) mod sizes.nbx
  yipos = fix(pos_num)/sizes.nbx

  yf2 = sizes.yf
  yf = sizes.yf*(1.0-space)
  xf2 = sizes.xf
  xf = sizes.xf*(1.0-space)

  if n_elements(rect) gt 0 then begin

    if n_elements(xmargin) gt 0 then xmar = xmargin(0) 			$
    else xmar = space/2.0

    if n_elements(ymargin) gt 0 then ymar = ymargin(0) 			$
    else ymar = space/2.0

    xtotal = 1.0 - (space*float(sizes.nbx-1) + xmar + xf2*space/2.0)
    xbs = xtotal/(float(sizes.nbx)*xf)

    xoff = xmar - xf2*space/2.0

    ytotal = 1.0 - (space*float(sizes.nby-1) + ymar + yf2*space/2.0)
    ybs = ytotal/(float(sizes.nby)*yf)

    yoff = 0.0

  endif else begin

    xbs  = sizes.bs
    xoff = sizes.xoff
    ybs  = sizes.bs
    yoff = sizes.yoff

  endelse

  xpos0 = float(xipos) * (xbs+space)*xf + xoff + xf2*space/2.0
  xpos1 = float(xipos) * (xbs+space)*xf + xoff + xf2*space/2.0 + xbs*xf

  ypos0 = (1.0-yf2*space/2) - (yipos * (ybs+space)*yf + ybs*yf) - yoff
  ypos1 = (1.0-yf2*space/2) - (yipos * (ybs+space)*yf) - yoff

  pos= [xpos0,ypos0,xpos1,ypos1]

  RETURN

END

