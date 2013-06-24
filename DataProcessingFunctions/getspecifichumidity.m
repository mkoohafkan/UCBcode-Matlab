function sh = getspecifichumidity(rh, t)
%Guide to Meteorological Instruments and Methods of Observation (CIMO Guide(WMO, 2008)
p = 945 ;
satvaporpressure = 6.112.*exp(17.62.*t./(243.12 + t) ) ;  %Annex 4.B
vaporpressure = rh.*satvaporpressure./100 ; %eq. 4.A.15
mixingratio = 0.622.*vaporpressure./(p - vaporpressure) ; 
sh = mixingratio./(mixingratio + 1) ;
end