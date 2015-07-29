PRO swap_stack

;#########
;Variables
;#########

top_dir='/data/ukssdc/STEREO/stereo_work/jjenkins/casestudy_26_07_2013/swap'
location_fits		=	top_dir + '/fits/lev1_new/lev1/'
sav_swapprep		=	top_dir + '/images_swapprep/'
sav_mgn			=	top_dir + '/images_mgn/'
sav_stacks		=	top_dir + '/left/stacks/'
location_sav		=	top_dir + '/savfiles/'
location_jpegs		=	top_dir + '/left/jpegs/'
linelocation		=	top_dir + '/left/'
level 			=	'174'


restore, linelocation + '/line_left.sav'
;restore, '/data/ukssdc/STEREO/stereo_work/jjenkins/casestudy_26_07_2013/aia/savfiles/171/20130726125911_171.sav'
filenames=file_search('/data/ukssdc/STEREO/stereo_work/jjenkins/casestudy_26_07_2013/aia_12s/fits/171/','*.fits',count=cnt)
read_sdo, filenames[0], hdr, im, /uncomp_delete
hdraia=hdr
filenames=file_search(location_fits,'*.fits',count=cnt)
mreadfits, filenames, index, data
filedates=filename2date_huw(filenames)
jd=anytim2jd_huw(filedates,/total)


med_crpix1 = MEDIAN( index.crpix1 )
med_crpix2 = MEDIAN( index.crpix2 )

shifts = -1.*transpose([ [index.crpix1 - med_crpix1], [index.crpix2 - med_crpix2] ])

shiftdata=shift_img(data,shifts)
mreadfits,filenames[0],hdr,im

x_mat=[x1,x2]
y_mat=[y1,y2]
xinterp2=interpol(x_mat,indgen(N_elements(x_mat)),findgen(110)*(n_elements(x_mat)-1)/109.)
yinterp2=interpol(y_mat,indgen(N_elements(y_mat)),findgen(110)*(n_elements(y_mat)-1)/109.)
int_pix=lonarr(2,n_elements(xinterp2))
int_pix[0,*]=xinterp2
int_pix[1,*]=yinterp2

wcs_aia=fitshead2wcs(hdraia)
wcs_swap=fitshead2wcs(hdr)
coords_aia=wcs_get_coord(wcs_aia, int_pix)

print, 'coords_aia = ', coords_aia
wcs_convert_from_coord, wcs_aia, coords_aia, 'HG', hgln, hglt
print, 'hgln = ', hgln
print, 'hglt = ', hglt

print, 'hgln = ', hgln
print, 'hglt = ', hglt
wcs_convert_to_coord, wcs_swap, coords_swap, 'HG', hgln, hglt
print, 'coords_swap = ',coords_swap
int_swap=wcs_get_pixel(wcs_swap, coords_swap)

xinterp_swap=int_swap[0,*]
yinterp_swap=int_swap[1,*]
loadct, 0
window, 0, xs=500, ys=500
im=im/hdr.exptime
	

	im_swap_prep=im[hdr.crpix1-(512-hdr.crpix1):1023,0:hdr.crpix2-(512-hdr.crpix2)]
	im=mgn(im_swap_prep, h=0.95,k=1)


TVLCT, 255, 255, 255, 254 ; White color
   TVLCT, 0, 0, 0, 253       ; Black color
   !P.Color = 253
   !P.Background = 254
im=255-im
plot_image, im
plots, [xinterp_swap, yinterp_swap],psym=3
stop
Results=fltarr(110,cnt)

line=0
for i=0,cnt-1 do begin
	im=fltarr(1024,1024,cnt)
	;mreadfits,filenames[i],hdr, im

	im=shiftdata[*,*,i]

	im=im/hdr.exptime
	im_swap_prep=im[hdr.crpix1-(512-hdr.crpix1):1023,0:hdr.crpix2-(512-hdr.crpix2)]
	im=mgn(im_swap_prep, h=0.95,k=1)
	;window,0, xs=500, ys=500
	;plot_image, im
	;plots, [xinterp_swap, yinterp_swap],psym=2
;write_jpeg,location_jpegs+anytim2cal(hdr.date_obs,form=8)+'.jpeg',im,quality=100
	
  
	Results[*,i]=im[xinterp_swap,yinterp_swap]
	Results[*,i]=Results[*,i]-(Total(Results[*,i],/Double)/n_elements(results[*,i]))

	line=line+1
	print, line, '    of', cnt
	;IF (i GT 8) then stop

endfor

results=transpose(results)

sz=size(results)

results=hist_equal(results, per=1)
results=hist_equal(results, per=1)
window, 0, xs=sz[1], ys=sz[2]
tvscl, results
results=255-results
window, 1, xs=sz[1], ys=sz[2]
tvscl, results
stop
write_png,sav_stacks+anytim2cal(hdr.date_obs,form=8)+'_line_centre.png',tvrd(/true)
save, x1, x2, y1, y2, x_2, y_2, xinterp_swap, yinterp_swap, Results, hdr, jd, filename = sav_stacks + level + '_stack_results.sav'
print, 'Completed'

end
