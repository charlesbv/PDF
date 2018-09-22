pro extrapolate_linear, y_to_extrapolate,x_before_extrapolation,x_after_extrapolation,y_extrapolated
;; inputs: y_to_extrapolate, x_before_extrapolation, x_after_extrapolation 
;; output: y_extrapolated


;; ;; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ;;
;; x_after_extrapolation(0) must be equal to x_before_extrapolation(0)
;; x_after_extrapolation(n_elements(x_after_extrapolation)-1) must be
;; equal to x_before_extrapolation(n_elements(x_before_extrapolation)-1)
;; ;; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ;;


y_extrapolated = fltarr(n_elements(x_after_extrapolation))
  a = fltarr(n_elements(x_after_extrapolation) - 1)
  b = fltarr(n_elements(x_after_extrapolation) - 1)

  y_extrapolated(0) = y_to_extrapolate(0)
  y_extrapolated(n_elements(x_after_extrapolation)-1) = y_to_extrapolate(n_elements(y_to_extrapolate)-1)

  for i = 1L, n_elements(x_after_extrapolation) - 2 do begin

     x_min_index = max(where(x_before_extrapolation le x_after_extrapolation(i)))
     x_min = x_before_extrapolation(x_min_index)
     y_min = y_to_extrapolate(x_min_index)
     x_max = x_before_extrapolation(x_min_index+1)
     y_max = y_to_extrapolate(x_min_index+1)

     a(i-1) = (y_max - y_min) / (x_max - x_min)
     b(i-1) = y_max - a(i-1)*x_max

     y_extrapolated(i) = a(i-1)*x_after_extrapolation(i) + b(i-1)

  endfor


  return

end
