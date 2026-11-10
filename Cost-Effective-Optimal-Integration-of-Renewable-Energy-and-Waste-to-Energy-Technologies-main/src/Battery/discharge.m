function [Eb,Edch,Ech,DG_hr,DG_Pro,WTE] = discharge(Pw,Ps,WTE,Eb,Pl,t,Ebmin,Edch,Ech,DG_hr,DG_Pro)
 %^^^^^^^^^^^^^^DISCHARGE^^^^^^^^^^^^^^^^^^^
  uconv=0.95;  %converter, inverter and battery efficincies.
  uinv=0.95;
  global P_WTE;
  WTE(t)=P_WTE;
    n_bat=0.9;
    loss=2-n_bat;
    Pdch(t)=(Pl(t)-Ps(t)*uinv-Pw(t)-WTE(t))/uconv;  % deficient ammount of load demand, weither to be met by battery or DG
    Edch(t)=Pdch(t)*1;                              %one hour iteration time
    Ech(t)=0;    
    if(Eb(t-1)-Ebmin)>=(Edch(t)*loss)   % alone battery is sufficient to meet load          
        Eb(t)=Eb(t-1)-Edch(t)*loss;     % load is met by battery
    else                                % else alone battery is not sufficient to meet load demand.
        temp=(Eb(t-1)-Ebmin)/loss;      % temperary intermediate variable, showing what ammount of energy availble in battery
        Eb(t)=Ebmin;                    % battery is fully discharged to allowable SOC.
        EDG=(Edch(t)-temp);             % 
        Edch(t)=temp;                   % ammount of energy discharged by battery to load
        %run load with diesel generator and renewable sources
        %^^^^^^^^^^^^^^^RUN DIESEL GENERATOR ^^^^^^^^^^^^^^
           DG_hr(t)=1;
           DG_Pro(t)=EDG;               % difficient power to be provided by DG.
%        fprintf('additional power taken at %d  of ammount %d grom DGs', t, Egrid_p(t));          
    end