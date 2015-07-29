PRO aia_stack,one31=one31,one71=one71,one93=one93,two11=two11,three04=three04

;#########
;Variables
;#########

level =''
level=(strsplit(level,'.',/ext))(0)
if keyword_set(one31) then level='131'
if keyword_set(one71) then level='171'
if keyword_set(one93) then level='193'
if keyword_set(two11) then level='211'
if keyword_set(three04) then level='304'



    top_dir='/data/ukssdc/STEREO/stereo_work/jjenkins/casestudy_26_07_2013/aia_12s'
    sav_stacks		=	top_dir + '/right/stacks/run2/' + level + '/'
    location_fits	=	top_dir + '/fits/' + level + '/'
    linelocation	=	top_dir + '/right/'



;##########################
;Search for necessary files
;##########################


pos=''
read, pos, prompt='Line specification required? (y/n) : '

if (pos eq 'y') then begin

  filenames=file_search(location_fits,'*.fits',count=cnt)
  
  im2=fltarr(4096,4096)
  for i=0,4 do begin
  read_sdo, filenames[i], hdr, im, /uncomp_delete, /noshell
  im2=im2+im/hdr.exptime
  endfor
  ;im=im/hdr.exptime

  im_aia_prep=im2
  im_aia_prep=im_aia_prep[2047:4095,0:2047]
  im=mgn(im_aia_prep, h=0.95,k=1)
  im2=edge_dog(im)
  im3=(im+(5*im2))/2
  im3=hist_equal(im3,per=0.01)
  im3=255-im3
  ;write_jpeg,sav_aiaprep+anytim2cal(hdr.date_obs,form=8)+'.jpeg',im_aia_prep,quality=100
  ;write_jpeg,sav_mgn+anytim2cal(hdr.date_obs,form=8)+'.jpeg',im3,quality=100
  
  sz=size(im3,/dimension)
 ; print, sz[0]
 ; print, sz[1]
;  window, /free, xsize=sz[0], ysize=sz[1], retain=2
  window, /free, xsize=1024, ysize=1024, retain=2
  plot_image, im3

  ;#############################################
  ;Specify line along which stacks will be taken
  ;#############################################


  cursor,x2,y2
  wait, 0.5
  print,'x2 = ', x2
  print,'y2 = ', y2
  x_2=x2
  y_2=hdr.Y0_MP-y2
  ;print, x_2
  ;print, y_2
  alpha=atan(y_2/x_2)
  print,'alpha = ',alpha
  x1=(hdr.R_SUN*cos(alpha))
  y1=hdr.Y0_MP-(hdr.R_SUN*sin(alpha))
  print,'x1 = ', x1
  print,'y1 = ', y1
  x_mat=[x1,x2]
  y_mat=[y1,y2]

  

 
  ;#######################################
  ;Interpolation of points based on clicks
  ;#######################################
  
  xinterp=interpol(x_mat,indgen(N_elements(x_mat)),findgen(500)*(n_elements(x_mat)-1)/499.)
  yinterp=interpol(y_mat,indgen(N_elements(y_mat)),findgen(500)*(n_elements(y_mat)-1)/499.)

xinterp=transpose(xinterp)
yinterp=transpose(yinterp)
plots, [xinterp, yinterp], psym=3
xinterp=transpose(xinterp)
yinterp=transpose(yinterp)
stop
save, x1, x2, y1, y2, x_2, y_2, xinterp, yinterp, filename = linelocation + '/line_right_2.sav'  
wdelete
endif else begin
  if (pos eq 'n') then begin
  restore, linelocation + '/line_right_2.sav'
  filenames=file_search(location_fits,'*.fits',count=cnt)
  print, xinterp
  print, yinterp

endif
endelse


;###################################################################
;Carry this out for all images in range based on interpolated points
;###################################################################

filenames2=filenames[0]
line=0
Results=fltarr(500, cnt/5)
for ifile=0,cnt-1,5 do begin
  
  im2=fltarr(4096,4096)
  
  for i=ifile,ifile+5 do begin
  read_sdo, filenames[i], hdr, im, /uncomp_delete, /noshell
  im2=im2+im/hdr.exptime
  endfor
  filenames2=[filenames2,filenames[ifile]]
  im_aia_prep=im2/5
  im_aia_prep=im_aia_prep[2047:4095,0:2047]
  im=mgn(im_aia_prep, h=0.95,k=1)
  im2=edge_dog(im)
  im3=(im+(5*im2))/2
  im3=hist_equal(im3,per=0.01)

  Results[*,line]=im3[xinterp,yinterp]
  Results[*,line]=Results[*,line]-(Total(Results[*,line],/Double)/n_elements(results[*,line]))
  line=line+1
;  print, line, '    of', cnt/5
  print, ifile, '    of', cnt

   IF (ifile GE cnt-10) THEN BREAK
;    IF (ifile GT 50) then stop
endfor
results=transpose(results)
sz=size(results)
window, 0, xs=sz[1],ys=sz[2]
tvscl, results
save, x1, x2, y1, y2, x_2, y_2, xinterp, yinterp, Results, hdr, filenames2, filename = sav_stacks + level + '_stack_results.sav'
write_png,sav_stacks+anytim2cal(hdr.date_obs,form=8)+'_'+level+'_stack_500'+'.png',tvrd(/true)





END
