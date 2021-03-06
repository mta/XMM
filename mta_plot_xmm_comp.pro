FUNCTION NO_AXIS_LABELS, axis, index, value
; suppress labelling axis
return, string(" ")
end

PRO MTA_PLOT_XMM_COMP, PLOTX=plotx
; 21. Aug 2007 BDS

; first check for license
;  this is dumb, just crashes before continuing if no license
if (NOT have_license()) then return

t_arch=5 ; how many days to plot

xmm_7d_archive='xmm_7day.archive2'
t_start=" 2000-01-00:00:00"  ; last data archived
readcol,xmm_7d_archive, $ 
  time_stamp_arc,le0_arc,le1_arc,le2_arc, $
  hes0_arc,hes1_arc,hes2_arc,hec_arc, $
  format='F,F,F,F,F,F,F,F'
t_start=max(long(time_stamp_arc)) ; assume file is sorted

time_sec_arc=time_stamp_arc

; set-up plotting window
;xwidth=680
;yheight=640
if (keyword_set(plotx)) then begin
  set_plot,'x'
  ;window,0,xsize=xwidth,ysize=yheight
endif else begin
  set_plot,'z'
  ;device,set_resolution = [xwidth,yheight]
endelse ; 

;set colors
loadct,39
back_color=0     ; black
grid_color=255   ; white
le1_color=50     ; dark blue
le2_color=100    ; light blue
hes1_color=230     ;red
hes2_color=215     ; orange
hec_color=190    ; yellow
;green_color=150    ; green
csize=2.0
chancsize=0.7    ; char size for channel labels
  
;!p.multi=[0,1,2,0,0]
!p.multi=[0,1,4,0,0]
xleft=15 ;set xmargin
xright=1

; figure out time ranges and labels
jday=time_stamp_arc/86400.-2190.0-366.-365.-365.
time=jday
xmin=long(max(jday))-t_arch+1
xmax=long(max(jday))+2
doyticks=indgen(xmax-xmin)+floor(min(xmin))
nticks=n_elements(doyticks)
;xticklab=strcompress(string(long(fix(doyticks))),/remove_all)
xticklab=strcompress(string(doyticks),/remove_all)
;print,doyticks  ;debugtime
;print,xticklab  ; debugtime

; just change names, to fit old code
le0=le0_arc
le1=le1_arc
le2=le2_arc
hes0=hes0_arc
hes1=hes1_arc
hes2=hes2_arc
hec=hec_arc

ymin=min(le1(where(le1 gt 0)))
ymax=max([le1_arc,le2,hes1,hes2,hec])
!p.position=[0.10,0.78,0.95,0.96]
plot,time,le2,background=back_color,color=grid_color, $
  xstyle=1,ystyle=1,xrange=[xmin,xmax],yrange=[ymin,ymax],/nodata, $
  charsize=csize, $
  xticks=nticks-1,xtickv=doyticks, /ylog, $
  xtickformat='no_axis_labels',xminor=12
  ;xtickname=xticklab,xminor=12
oplot,time,le1,color=le1_color
oplot,time,le2,color=le2_color
oplot,time,hes1,color=hes1_color
oplot,time,hes2,color=hes2_color
oplot,time,hec,color=hec_color
yline=1L
while(yline lt ymax) do begin
  oplot,[xmin,xmax],[yline,yline],color=grid_color,linestyle=2
  yline=yline*10
endwhile ; while(yline lt ymax) do begin
xyouts,xmin,ymax*1.5,"XMM Radiation and Orbital Profile",/data,charsize=0.9
fit=where(time eq min(time))
fi=fit(0)
;xlabp1=0.03 ;xposition for units labels (norm coords)
;xlabp2=0.055 ;xposition for channel labels (norm coords)
;xyouts,xlabp1,0.70,"counts/sec (protons)",orient=90,align=0.5,/norm
;xyouts,xlabp2,0.42,'1-1.5 MeV',orient=90,color=le1_color, $
       ;/norm,charsize=chancsize
;xyouts,xlabp2,0.52,'1.5-4.5 MeV',orient=90,color=le2_color, $
       ;/norm,charsize=chancsize

oplot,time,hes1,psym=3,color=hes1_color
oplot,time,hes2,psym=3,color=hes2_color
yline=1L

xyouts,0.99,0.001,'Created: '+systime()+'ET',/norm,align=1.0,charsize=0.8

Re=6378.0 ; earth radius
xmmfile="/proj/rac/ops/ephem/TLE/xmm.spctrk"
readcol,xmmfile,sec,yy,dd,hh,mm,ss,x_eci,y_eci,z_eci,vx,vy,vz, $
  format='L,I,I,I,I,I,F,F,F,F,F,F',skipline=5
sec=sec-long(8.83613e+08)-86400L
time=sec/60./60./24.
cxofile="/proj/rac/ops/ephem/TLE/cxo.spctrk"
readcol,cxofile,cxo_sec,cxo_yy,cxo_dd,cxo_hh,cxo_mm,cxo_ss, $
  cxo_x_eci,cxo_y_eci,cxo_z_eci,cxo_vx,cxo_vy,cxo_vz, $
  format='L,I,I,I,I,I,F,F,F,F,F,F',skipline=5
cxo_sec=cxo_sec-long(8.83613e+08)-86400L
cxo_time=cxo_sec/60./60./24.

nel=n_elements(sec)-2
es=lonarr(nel)
x_gsm=fltarr(nel)
y_gsm=fltarr(nel)
z_gsm=fltarr(nel)
mon_days=[31,28,31,30,31,30,31,31,30,31,30,31]
for i=0,n_elements(sec)-3 do begin
  mon_days=[31,28,31,30,31,30,31,31,30,31,30,31]
  leap=2000
  while (yy(i) ge leap) do begin
    if (yy(i) eq leap) then mon_days(1)=29
    leap=leap+4
  endwhile ; while (yy(i) ge leap) do begin
  mon=1
  day=dd(i)
  while (day gt mon_days(mon-1)) do begin
    day=day-mon_days(mon-1)
    mon=mon+1
  endwhile ;while (day gt mon_days(mon-1)) do begin
  print,mon,day,yy(i),hh(i),mm(i),ss(i)
  es(i)=date2es(mon,day,yy(i),hh(i),mm(i),ss(i))
  gsm=cxform([x_eci(i),y_eci(i),z_eci(i)],'GEI','GSM',es(i))
  x_gsm(i)=gsm(0)
  y_gsm(i)=gsm(1)
  z_gsm(i)=gsm(2)

  ;printf,tunit,yy(i),dd(i),mon,day,es(i) ;debug
  ;printf,cunit,"ECI ",x_eci(i),y_eci(i),z_eci(i)  ;debug
  ;printf,cunit,"GSM ",x_gsm(i),y_gsm(i),z_gsm(i)  ;debug
  
endfor ;for i=0,n_elements(sec)-1 do begin

nel=n_elements(cxo_sec)-2
es=lonarr(nel)
cxo_x_gsm=fltarr(nel)
cxo_y_gsm=fltarr(nel)
cxo_z_gsm=fltarr(nel)
for i=0,n_elements(cxo_sec)-3 do begin
  mon_days=[31,28,31,30,31,30,31,31,30,31,30,31]
  leap=2000
  while (cxo_yy(i) ge leap) do begin
    if (cxo_yy(i) eq leap) then mon_days(1)=29
    leap=leap+4
  endwhile ; while (yy(i) ge leap) do begin
  mon=1
  day=cxo_dd(i)
  while (day gt mon_days(mon-1)) do begin
    day=day-mon_days(mon-1)
    mon=mon+1
  endwhile ;while (day gt mon_days(mon-1)) do begin
  es(i)=date2es(mon,day,cxo_yy(i),cxo_hh(i),cxo_mm(i),cxo_ss(i))
  gsm=cxform([cxo_x_eci(i),cxo_y_eci(i),cxo_z_eci(i)],'GEI','GSM',es(i))
  cxo_x_gsm(i)=gsm(0)
  cxo_y_gsm(i)=gsm(1)
  cxo_z_gsm(i)=gsm(2)
endfor ;for i=0,n_elements(sec)-1 do begin

;set colors
loadct,39
back_color=0     ; black
grid_color=255   ; white
dblue=50     ; dark blue
lblue=100    ; light blue
red=230     ;red
orange=215     ; orange
yellow=190    ; yellow
green=150    ; green
csize=1.0
chancsize=0.7    ; char size for channel labels

curr_time=systime(/sec)-8.83613e8
b=where(sec gt curr_time-7*86400)
sec=sec(b)
x_gsm=x_gsm(b)
y_gsm=y_gsm(b)
z_gsm=z_gsm(b)
x_eci= x_eci(b)
y_eci= y_eci(b)
z_eci= z_eci(b)
vx= vx(b)
vy= vy(b)
vz= vz(b)
b=where(cxo_sec gt curr_time-7*86400)
cxo_sec=cxo_sec(b)
cxo_x_gsm=cxo_x_gsm(b)
cxo_y_gsm=cxo_y_gsm(b)
cxo_z_gsm=cxo_z_gsm(b)
cxo_x_eci= cxo_x_eci(b)
cxo_y_eci= cxo_y_eci(b)
cxo_z_eci= cxo_z_eci(b)
cxo_vx= cxo_vx(b)
cxo_vy= cxo_vy(b)
cxo_vz= cxo_vz(b)
;ymin=min(r_eci)
;ymax=max(r_eci)
;xmin=min([x_gsm,y_gsm,z_gsm,cxo_x_gsm,cxo_y_gsm,cxo_z_gsm])
;xmax=max([x_gsm,y_gsm,z_gsm,cxo_x_gsm,cxo_y_gsm,cxo_z_gsm])
;xmin=-20.0*Re
;xmax=20.0*Re

sec_mark=curr_time
b=where(abs(sec-sec_mark) lt 1000.0,bnum)
orb=0
if (bnum gt 0) then $  ; mark current position
start_x=x_gsm(b(0))
start_y=y_gsm(b(0))
;xyouts,[x_gsm(b(0)),x_gsm(b(0))]/Re,[y_gsm(b(0)),y_gsm(b(0))]/Re, $
;  strcompress(string(orb),/remove_all), color=green
sec_mark=sec_mark-86400L
while (sec_mark gt min(sec)) do begin
  b=where(abs(sec-sec_mark) lt 1000.0,bnum)
  orb=orb+1
  if (bnum gt 0) then $
    ;xyouts,[x_gsm(b(0)),x_gsm(b(0))]/Re,[y_gsm(b(0)),y_gsm(b(0))]/Re, $
    ;  strcompress(string(orb),/remove_all), color=red
  sec_mark=sec_mark-86400L
endwhile ; while (sec_mark gt min(sec)) do begin
;  replot current
;xyouts,[start_x,start_x]/Re,[start_y,start_y]/Re, $
;  strcompress(string(" 0"),/remove_all), color=green

; oplot cxo crm regions
;oplot,cxo_x_gsm/Re,cxo_y_gsm/Re,color=lblue
readcol,'crmreg_cxo.dat',Csec,CR,CXgsm,CYgsm,CZgsm,Ccrmreg, $
  format='L,F,F,F,F,I',skipline=5
crm_color=indgen(n_elements(cxo_sec))
print,cxo_sec(0:5) ; debugcolor
print,Csec(0:5) ; debugcolor
for i=0,n_elements(cxo_sec)-1,1 do begin
  diff=abs(long(cxo_sec(i))-long(Csec))
  b=where(diff eq min(diff))
  print, cxo_sec(i),Csec(b(0)),b(0) ;debugcolor
  if (Ccrmreg(b(0)) eq 1) then crm_color(i)=150
  if (Ccrmreg(b(0)) eq 2) then crm_color(i)=100
  if (Ccrmreg(b(0)) eq 3) then crm_color(i)=190
endfor ; for i=0,n_elements(cxo_sec)-1,1 do begin
;print,crm_color ;debugcolor

;sec_mark=max(cxo_sec)
sec_mark=curr_time
b=where(abs(cxo_sec-sec_mark) lt 1000,bnum)
orb=0
if (bnum gt 0) then begin ; mark current position
  ;xyouts,[cxo_x_gsm(b(0)),cxo_x_gsm(b(0))]/Re, $
  ;  [cxo_y_gsm(b(0)),cxo_y_gsm(b(0))]/Re, $
  ;  strcompress(string(orb),/remove_all),color=green
  print,sec_mark ; debug
  print,b(0),cxo_sec(b(0)),cxo_x_gsm(b(0)),cxo_y_gsm(b(0)),cxo_z_gsm(b(0)) ;debug
  print,cxo_x_eci(b(0)),cxo_y_eci(b(0)),cxo_z_eci(b(0)) ;debug
  print,b(n_elements(b)-1),cxo_sec(b(n_elements(b)-1)),cxo_x_gsm(b(n_elements(b)-1)) ; debug
endif ;if (bnum gt 0) then begin ; mark current position
sec_mark=sec_mark-86400L
while (sec_mark gt min(cxo_sec)) do begin
  b=where(abs(cxo_sec-sec_mark) lt 1000.0,bnum)
  orb=orb+1
  sec_mark=sec_mark-86400.
endwhile ; while (sec_mark gt min(cxo_sec)) do begin
xm=indgen(Re)/Re*7.0
mag_shape=sqrt(49.0-xm^2)
xm=indgen(Re)/Re*3.0

b=n_elements(cxo_x_gsm)-1
;plot,x_gsm,z_gsm,background=back_color,color=grid_color,/isotropic, $
;  xrange=[xmin,xmax],yrange=[xmin,xmax],/nodata, $
;  xtitle="X_GSM",ytitle="Z_GSM"
;oplot,x_gsm,z_gsm,color=red
;oplot,cxo_x_gsm,cxo_z_gsm,color=lblue
;oplot,[0,0],[0,0],psym=1,color=255
;plot,y_gsm,z_gsm,background=back_color,color=grid_color,/isotropic, $
;  xrange=[xmin,xmax],yrange=[xmin,xmax],/nodata, $
;  xtitle="Y_GSM",ytitle="Z_GSM"
;oplot,y_gsm,z_gsm,color=red
;oplot,cxo_y_gsm,cxo_z_gsm,color=lblue
;oplot,[0,0],[0,0],psym=1,color=255

; verify calc
;rdfloat,'/proj/rac/ops/ephem/TLE/xmm.gsme_in_Re',t,gx,gy,gz,x,y,z,y,m,d,h,n,s
;oplot,gx*1000.0,gy*1000.0,color=orange
;rdfloat,'/proj/rac/ops/ephem/TLE/cxo.gsme_in_Re',t,gx,gy,gz,x,y,z,y,m,d,h,n,s
;oplot,gx*1000.0,gy*1000.0,color=orange

;eci;!p.multi=[0,2,2,0,0]
;eci;xmin=min([x_eci,y_eci,z_eci,cxo_x_eci,cxo_y_eci,cxo_z_eci])
;eci;xmax=max([x_eci,y_eci,z_eci,cxo_x_eci,cxo_y_eci,cxo_z_eci])
;eci;plot,x_eci,y_eci,background=back_color,color=grid_color,/isotropic, $
;eci;  xrange=[xmin,xmax],yrange=[xmin,xmax],/nodata, $
;eci;  xtitle="X_ECI",ytitle="Y_ECI"
;eci;oplot,x_eci,y_eci,color=red
;eci;oplot,cxo_x_eci,cxo_y_eci,color=lblue
;eci;oplot,[0,0],[0,0],psym=1,color=255
;eci;plot,x_eci,z_eci,background=back_color,color=grid_color,/isotropic, $
;eci;  xrange=[xmin,xmax],yrange=[xmin,xmax],/nodata, $
;eci;  xtitle="X_ECI",ytitle="Z_ECI"
;eci;oplot,x_eci,z_eci,color=red
;eci;oplot,cxo_x_eci,cxo_z_eci,color=lblue
;eci;oplot,[0,0],[0,0],psym=1,color=255
;eci;plot,y_eci,z_eci,background=back_color,color=grid_color,/isotropic, $
;eci;  xrange=[xmin,xmax],yrange=[xmin,xmax],/nodata, $
;eci;  xtitle="Y_ECI",ytitle="Z_ECI"
;eci;oplot,y_eci,z_eci,color=red
;eci;oplot,cxo_y_eci,cxo_z_eci,color=lblue
;eci;oplot,[0,0],[0,0],psym=1,color=255
;eci;
;eci; write_gif,'/data/mta4/www/RADIATION/XMM/mta_xmm_plot_eci.gif',tvrd()

crm_color=100
xmm_color=200

sec=(sec-283996863.)/86400.+1
cxo_sec=(cxo_sec-283996863.)/86400.+1
!p.position=[0.10,0.55,0.95,0.78]
ymin=min([x_gsm/Re,cxo_x_gsm/Re])
ymax=max([x_gsm/Re,cxo_x_gsm/Re])
plot,sec,x_gsm/Re,color=grid_color,psym=3, $
  ytitle="X_GSM (R!lE!n)",/nodata, $
  xticks=nticks-1,xtickv=doyticks, $
  xtickformat='no_axis_labels',xminor=12,chars=2,xrange=[xmin,xmax], $
  xstyle=1,ystyle=1,yrange=[ymin,ymax]
oplot,sec,x_gsm/Re,color=xmm_color,linestyle=2
oplot,cxo_sec,cxo_x_gsm/Re,color=crm_color

!p.position=[0.10,0.32,0.95,0.55]
ymin=min([y_gsm/Re,cxo_y_gsm/Re])
ymax=max([y_gsm/Re,cxo_y_gsm/Re])
plot,sec,y_gsm/Re,color=grid_color,psym=3, $
  ytitle="Y_GSM (R!lE!n)",/nodata, $
  xticks=nticks-1,xtickv=doyticks, $
  xtickformat='no_axis_labels',xminor=12,chars=2,xrange=[xmin,xmax], $
  xstyle=1,ystyle=1,yrange=[ymin,ymax]
oplot,sec,y_gsm/Re,color=xmm_color,linestyle=2
oplot,cxo_sec,cxo_y_gsm/Re,color=crm_color

!p.position=[0.10,0.09,0.95,0.32]
ymin=min([z_gsm/Re,cxo_z_gsm/Re])
ymax=max([z_gsm/Re,cxo_z_gsm/Re])
plot,sec,z_gsm/Re,color=grid_color,psym=3, $
  xtitle="time - DOY 2007",ytitle="Z_GSM (R!lE!n)",/nodata, $
  xticks=nticks-1,xtickv=doyticks, $
  xminor=12,chars=2,xrange=[xmin,xmax], $
  xstyle=1,ystyle=1,yrange=[ymin,ymax]
oplot,sec,z_gsm/Re,color=xmm_color,linestyle=2
oplot,cxo_sec,cxo_z_gsm/Re,color=crm_color

plots,[0.50,0.60],[0.98,0.98],linestyle=0,color=crm_color,/norm
xyouts,0.62,0.97,"CXO",color=crm_color,chars=0.9,/norm
plots,[0.7,0.8],[0.98,0.98],linestyle=2,color=xmm_color,/norm
xyouts,0.82,0.97,"XMM",color=xmm_color,chars=0.9,/norm

write_gif,'/data/mta4/www/RADIATION/XMM/mta_plot_xmm_comp.gif',tvrd()

end

