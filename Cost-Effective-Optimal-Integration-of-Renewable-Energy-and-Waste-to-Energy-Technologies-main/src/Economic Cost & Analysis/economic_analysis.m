   function [Anual_cost]=economic_analysis(x)
x
global ASC; global P_WTE;   % annualized system cost.
Ren_fraction_req=10;        % Minimum renewable fraction in % as constraint
x(1)=abs(x(1));
x(2)=abs(x(2));
x(3)=abs(x(3));
n_bat =0.9;                 %battery efficiency 
load Data_d G Tamb v Pw1 load1; % this command takes the input data including solar irradiance, wind speed/power and load profile for the whole year
NS=0;
%% WTE
 N_WTE=x(1);                  % size of the WTE plant
 P_WTE=N_WTE*0.6;             % output power of the WTE plant/ with 60% efficiency
%% Wind turbine
 Nw=x(2);%  no. of wind turbine selected by optimization algo
 Vref=v;
 Hw=17;
 Hr=10;
 Vmin=4;
 Vc=35;
 Vr=14;
 Pw_u=0;
 for t =1:8760
     V(t)=Vref(t)*((Hw/Hr).^(0.14));
     
     if V(t)>Vc | V(t)<Vmin
         Pw_u(t)=0;
     elseif V(t)<Vc && V(t)>Vr
         Pw_u(t)=1;
     else
         Pw_u(t)=1*(V(t)-Vmin)/(Vr-Vmin);   % wind power formula
     end
 end
Pw=1*Nw*Pw_u;                               % total wind  power(1.01 is the correction factor for wind power modeeling)

%% solar power
% G=G*1000;% to convert the solar irrdiance KW/m2 to W/m2;
Nsol=x(3);%  no. of solar modules selected by optimization algo/each module is of 1KW.
for i=1:length(G)
     loss(i)=0.0039*(Tamb(i)+(0.0256*G(i))-25); %power degredation due to temperature rise.
    if loss(i)<0
     loss(i)=0;
    end 
Ps(i)=1*Nsol*[(G(i)/1000)*(1-loss(i))];%Solar power output (81.8% is factor includign derating/dust/etc)
end

%% battery 
%#######inputs##############inputs####################inputs##
Nbat=x(4);    % no. of batteries that are slelected by optimization algo

Pl1=load1; % load profile over a year
uinv=0.95;% inverter efficiency
dod=0.8;% battery depth of discharge. it indicates how much %charge can be drawn from battery.

%% MAIN PROGRAM
% Battery bank
Ebmax=Nbat*7;         %Nbat*V*Ah kWh %battery capacity 
Ebmin=Ebmax*(1-dod);    %  maximum battery discharge. 
Eb=zeros(1,8760);       %battery energy 
Edch=zeros(1,8760);     %Bout, battery dischrage energy in KWh
Ech=zeros(1,8760);      % Bin, battery charging energy in KWh
Edump=zeros(1,8760);    % deffered energy/dump energy.
Eb(1,1)=1*Ebmax;        %state of charge for starting time
WTE=zeros(1,8760);      %Energy of the WTE plant

%DGs running hours and hourly power production
DG_hr=zeros(1,8760);%running hours of DG
DG_Pro=zeros(1,8760);% Energy produced by DG
%^^^^^^^^^^^^^^START^^^^^^^^^^^^^^^^^^^^^^^^
Pl=Pl1; % load demand
clear Pl1;


material_KWh=100/(80*1000);             % tons of fuel required per KWh
%^^^^^^^^^^Output power calculation^^^^^^^^
for t=2:1:8760 %8760 hours in a year.
%^^^^^^^^^^^^^^READ INPUTS^^^^^^^^^^^^^^^^^^
% ------------------------------------------
%^^^^^^^^^^^^^^COMPARISON^^^^^^^^^^^^^^^^^^^
    if (P_WTE+Pw(t)+Ps(t)*uinv)>(Pl(t)) % checking whether alone renewable is suffienct to meet the load demand.
    %^^^^^^RUN LOAD WITH  PV and wind^^^^^^
    %^^^^^^^^^^^^^^CHARGE^^^^^^^^^^^^^^^^^^^^^^^^^^        
         [Eb,Ech,Edch,Edump,WTE] = charge(Eb,Ebmax,Edump,Pl,t,Ech,Edch,Pw,Ps,WTE); %charging the battery by using surplus energy after meeting load demand.     
    else                       
   %^^^^^^^^^^^^^^DISCHARGE^^^^^^^^^^^^^^^^^^^
         [Eb,Edch,Ech,DG_hr,DG_Pro,WTE] = discharge(Pw,Ps,WTE,Eb,Pl,t,Ebmin,Edch,Ech,DG_hr,DG_Pro);% taking the deficeint load demand either by batter or DG
    end                               
end
% This function calcualte the cost of the selected system and given total
% and individual costs.
[Anual_cost,WTE_cost,Wind_cost,Solar_cost,DG_cost,Battery_cost,Inverter_Tcost] = economic_cost(Nbat,Nw,Nsol,WTE,DG_hr,DG_Pro);
  Total_load=sum(Pl);%total annual load demand.
  Ren_fraction=100*[1-(sum(DG_Pro)/Total_load)]; % load met by renewable energy sources
  
 if (Ren_fraction>(Ren_fraction_req))% checking whether the required renewable fraction is met or not.
     ASC(length(ASC)+1)=Anual_cost;
 else
     Anual_cost=1e9; % putting penalty on annual cost on voilating constraints.
 end
 Anual_cost