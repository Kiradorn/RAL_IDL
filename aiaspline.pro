PRO aiaspline,one71=one71,one93=one93,two11=two11,three04=three04

;#########
;Variables
;#########

level =''
level=(strsplit(level,'.',/ext))(0)
if keyword_set(one71) then level='171'
if keyword_set(one93) then level='193'
if keyword_set(two11) then level='211'
if keyword_set(three04) then level='304'
void=label_date('%H:%I')
top_dir='/data/ukssdc/STEREO/stereo_work/jjenkins/casestudy_26_07_2013/aia_12s/left'
sav_stacks		=	top_dir + '/stacks/' + level + '/'
sav_dir			=	top_dir+'/bootstrapped/spline/' + level + '/'



restore, sav_stacks + level + '_stack_results.sav'
h=sqrt((xinterp-xinterp[0])^2+(yinterp-yinterp[0])^2)*hdr.cdelt1
filedates=filename2date_huw(filenames2)
jd=anytim2jd_huw(filedates,/total)
yerr=5

loadct,0
TVLCT, 255, 255, 255, 254 ; White color
   TVLCT, 0, 0, 0, 253       ; Black color
   !P.Color = 253
   !P.Background = 254
results=255-results
contour,results,jd,h,$
  /xstyle,/ystyle,$
  ytitle='Arcsecs',$
  xtitle='Time',$
  title='SDO AIA ' + level + ' Angstrom',$
  xtickformat='LABEL_DATE', xtickunit='Time', /fill, nlevels=255, position=[0.25,0.1,0.95,0.95], charsize=1.5
;write_png,sav_stacks+anytim2cal(hdr.date_obs,form=8)+'_'+level+'_stack_scaled_white_500'+'.jpeg',tvrd(/true)

Read, clk, prompt='How many clicks are needed? : '
x_arr=dblarr(clk)
y_arr=dblarr(clk)
for i=0, clk -1 do begin
	cursor, xcur, ycur
	x_arr[i]=xcur
	y_arr[i]=ycur
	wait, 0.2
endfor
y_arr=y_arr*435.1625663/695800
jd3=(x_arr-x_arr[0])*60*24*60




;################################   SPLINE    #################################
;xinterp=interpol(x_arr, indgen(n_elements(x_arr)),findgen(45)*(n_elements(x_arr)-1/44.), /spline)
;yinterp=interpol(y_arr, indgen(n_elements(y_arr)),findgen(45)*(n_elements(y_arr)-1/44.), /spline)
;spline_smooth, x_arr, y_arr, yerr,10,coefficients,yplot, /plot, /silent
;nx = N_ELEMENTS(jd3)
;
; Compute coefficients of the cubic splines
;coeff = SPLINECOEFF(jd3, y_arr, lambda = 1.d3)
;
; Plot the original data and the spline function for given lambda
;y1 = FLTARR(nx-1)
;x1 = jd3[0:nx-2]
;FOR i = 0, N_ELEMENTS(y_arr)-2 DO begin
;	y1[i] = coeff.d[i] + coeff.c[i] * (jd3[i+1]-jd3[i]) + coeff.b[i] * (jd3[i+1]-jd3[i])^2 + coeff.a[i] * (jd3[i+1]-jd3[i])^3
;endfor
;###############################################################################


savgolFilter_0=savgol(4,4,0,2, /double)
savy_arr_0=convol(y_arr, savgolFilter_0, /edge_truncate)

tmp=dblarr(clk)
for i=0,clk-2 do begin
	tmp[i]=jd3[i+1]-jd3[i]
endfor
diff=ave(tmp)

pos=''
Read, pos, prompt='Top (T) or bottom? (B) : '
!P.MULTI = [0,1,3]
!X.MARGIN = [30,30]
!Y.MARGIN = [10,3]
window, 1, xs=800, ys=900

PLOT, x_arr, y_arr, psym = 2, xtickformat='LABEL_DATE', xtickunit='Time', ytitle='Height (solar radii)', xtitle='Date and Time', max_value=x_arr(n_elements(x_arr)-1), xcharsize=2.5, ycharsize=2.5
oplot, x_arr, savy_arr_0

;write_png, sav_dir+pos+'/'+'height_track_'+pos+'.png',tvrd(/true)
wait, 0.5

;window, 1, xs=750, ys=750
order=1.
savgolFilter_1=savgol(4,4,order,2, /double)*(factorial(order)/(diff^order))
savy_arr_1=convol(y_arr,savgolFilter_1, /edge_truncate, /nan)*695800
;savy_arr_1[n_elements(savy_arr_1)-1]=!Values.F_NaN
;savy_arr_1[n_elements(savy_arr_1)-2]=!Values.F_NaN
;savy_arr_1[n_elements(savy_arr_1)-3]=!Values.F_NaN
;savy_arr_1[n_elements(savy_arr_1)-4]=!Values.F_NaN
;x_arr[n_elements(x_arr)-1]=!Values.F_NaN
plot,x_arr,savy_arr_1, xtickformat='LABEL_DATE', xtickunit='Time', ytitle='Velocity (kms^-1)', xtitle='Date and Time', psym=2, max_value=x_arr(n_elements(x_arr)-1), xcharsize=2.5, ycharsize=2.5
oplot,x_arr,savy_arr_1
;write_png, sav_dir+pos+'/'+'velocity_track_'+pos+'.png',tvrd(/true)


;window, 2, xs=750, ys=750
order=2.
savgolFilter_2=savgol(4,4,order,2, /double)*(factorial(order)/(diff^order))
savy_arr_2=convol(y_arr,savgolFilter_2, /edge_truncate, /nan)*695800000
;savy_arr_2[n_elements(savy_arr_2)-1]=!Values.F_NaN
;savy_arr_2[n_elements(savy_arr_2)-2]=!Values.F_NaN
;savy_arr_2[n_elements(savy_arr_2)-3]=!Values.F_NaN
;savy_arr_2[n_elements(savy_arr_2)-4]=!Values.F_NaN
;x_arr[n_elements(x_arr)-1]=!Values.F_NaN
plot,x_arr,savy_arr_2, xtickformat='LABEL_DATE', xtickunit='Time', ytitle='Acceleration (ms^-2)', xtitle='Date and Time',psym=2, max_value=x_arr(n_elements(x_arr)-1), xcharsize=2.5, ycharsize=2.5
oplot,x_arr,savy_arr_2
;write_png, sav_dir+pos+'/'+'acceleration_track_'+pos+'.png',tvrd(/true)
;write_png, sav_dir+pos+'/'+'h_v_a_track_'+pos+'.png',tvrd(/true)


;restore, './idlsave_goes.sav'
;plot, yclean[*,1], ytitle='watts m^-2', xtitle='Time (s)', xcharsize=2, ycharsize=2

stop
END
