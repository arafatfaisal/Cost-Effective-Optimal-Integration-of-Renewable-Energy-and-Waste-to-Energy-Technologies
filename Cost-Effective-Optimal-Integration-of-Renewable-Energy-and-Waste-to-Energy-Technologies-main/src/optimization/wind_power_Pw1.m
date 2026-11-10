%% Widn turbine
 Vref=v;
 Hw=50;   % hight of wind turbine
 Hr=10;   % reference hight at which meterological data taken.
 Vmin=2;  % min wind velocity for power generation
 Vc=40;   % cut out velocy
 Vr=9;    % rated wind verlocity.
 
 % wind calucations for whole year 
 for t =1:8760
     V(t)=Vref(t)*((Hw/Hr).^(1/7));
     
     if V(t)>Vc | V(t)<Vmin
         Pw1(t)=0;
     elseif V(t)<Vc && V(t)>Vr
         Pw1(t)=1;
     else
         Pw1(t)=1*(V(t)-Vmin)/(Vr-Vmin); % wind power formula
     end
 end
 