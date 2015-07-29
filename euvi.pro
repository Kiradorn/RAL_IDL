PRO euvi,one71=one71,one95=one95,two84=two84,three04=three04

;#########
;Variables
;#########

level =''
level=(strsplit(level,'.',/ext))(0)
if keyword_set(one71) then level='171'
if keyword_set(one95) then level='195'
if keyword_set(two84) then level='284'
if keyword_set(three04) then level='304'



top_dir='/data/ukssdc/STEREO/stereo_work/jjenkins/casestudy_26_07_2013/euvi/20130726/a/'
sav_im		=	top_dir + 'EUVI_' + level + '/images/jason/zoomed/'
location_fits	=	top_dir + 'EUVI_' + level + '/fits/jason/'

filenames=file_search(location_fits, '*.fts', count=cnt)
;!P.multi=0
;!P. MULTI=[0,5,3]
;!X. MARGIN=[5,3]
;window, 1, xs=1000, ys=750
window, 1, xs=400, ys=500
loadct,0
TVLCT, 255, 255, 255, 254 ; White color
   TVLCT, 0, 0, 0, 253       ; Black color
   !P.Color = 253
   !P.Background = 254

mreadfits, filenames, hdr, im

  im=im[450:750,350:750,*]
  im=hist_equal(im,per=1)
for i=0, cnt-1 do begin

  plot_image, im[*,*,i] ,  title=anytim2cal(hdr[i].date_D$obs)
  write_png, sav_im+anytim2cal(hdr[i].date_d$obs,form=8) + 'movie.png', tvrd(/true)
endfor

stop
line=0
for i=0, cnt-1, 10 do begin
	im_1now=im[*,*,i]
	;im_2now=im[*,*,i-1]
	im_1=im_1now/hdr[i].exptime
	;im_2=im_2now/hdr[i-1].exptime
	im2_1=mgn(im_1, h=0.95,k=1)
	;im2_2=mgn(im_2, h=0.95,k=1)
plot_image, im2_1
stop
	imtmp_1=edge_dog(im2_1)
	;imtmp_2=edge_dog(im2_2)
	im3_1=(im2_1+imtmp_1)/2
	;im3_2=(im2_2+imtmp_1)/2
	im3_1=hist_equal(im3_1,per=2)
	;im3_2=hist_equal(im3_2,per=1)
	im3_1=255-im3_1
	;im3_2=255-im3_2
	;im4=im3_2-im3_1
	;plot_image, im4
	plot_image, im3_1
	line=line+1
	write_png, sav_im+anytim2cal(hdr[i].date_d$obs,form=8) + '_grid_movie.png', tvrd(/true)
	print, line, ' of ', cnt
endfor
stop

end
