function [NPC,WTE_cost,Wind_cost,Solar_cost,DG_cost,Battery_cost,Inverter_Tcost] = NPC_cost(Nbat,Nw,Nsol,WTE,DG_hr,DG_Pro)
% ***********************************
global P_WTE;
Cwte=4000;                       % capital cost of WTE per KW 
WTE_OM=150;                       % operation and maintenance cost 
fuel_WTE=sum(WTE.*(1/500));     % WTE raw material in tons.
Proc_cost_ton=50;             % processing cost per ton
transport_cost_ton=12;         % transporation cost per ton

%wind cost parameters
Cw =1300;       % capital cost of one wind plant 
Cwr =1200;      % replacement cost of one wind plant 
W_OM=200;       %Wind operation and maintenance cost.

% solar cost parameters
Cs =1500;        % =cost of one PV  module 
S_OM=50;        % solar opeationa and maintenance cost

% battery cost parameters                                           
BAT_C=1250;   % batery unit cost
BAT_C_r=1100; %replacement cost
Bat_OM=20;   % opeationa and maintenance cost

% Inverter cost parameters.
INV_C=800;      % Inverter cost 
INV_Cr=750;     % Inverter replacement cost 
INV_OM=20;      % %Operation and maintenance cost of inverter

%economic index
REAL_INTREST=2.07;
%life time of each component
PRJ_LF=20;      %project life
INV_LF=20;      %inveter life
Wind_LF=20;     % wind turbine life
Bate_LF=10;     % battery life
DG_LF=10;       %DG life
ir=REAL_INTREST/100; %interest rate
%% DG caluctions 
% Diesel generator cost calculation
DGsize=max(DG_Pro);
DG_hr=sum(DG_hr);% total running hours
DG_Pro=sum(DG_Pro);% total energy production in kwh
DG_c=175;%capital cost 
DG_Rc=175;%DG replacement cost 
Fuel_=(2.55*DG_hr)+(DG_Pro*0.251);% total fuel/year% [This formula is given by manufactured to calculate DG fuel consumptioin]
Fuel_c=1*Fuel_;      % fuel cost per year, 1 is fuel cost per litre
OM=30*DG_hr; % Operation and maintenance cost per year of Dg

DG_C=1*DGsize*DG_c;% (DG capital cost)// Rated power= 1.12*max_power
DG_Cr=1*DGsize*[((1/((1+ir).^DG_LF))+(1/((1+ir).^(2*DG_LF))))]*(DG_Rc);% DG replacement cost
DG_OM_cost=[(DGsize*(OM))+Fuel_c]/((ir*(1+ir).^(PRJ_LF))/(((1+ir).^PRJ_LF)-1));%OM cost and fuel cost
DG_sal_fr=abs(2*DG_LF-PRJ_LF);
DG_sal_cost =DGsize*(DG_Rc)*[(DG_sal_fr/DG_LF)*(1/((1+ir).^PRJ_LF))];% salvage cost
DG_cost=DG_C+DG_Cr+DG_OM_cost-DG_sal_cost;% Total DG cost /*

%% WTE net present cost
WTE_C=1*P_WTE*(Cwte); % (WTE capital cost)
%WTE_OM_cost=P_WTE*(OM);
Processing_cost=fuel_WTE*Proc_cost_ton/((ir*(1+ir).^(PRJ_LF))/(((1+ir).^PRJ_LF)-1));
Transportation_cost=fuel_WTE*transport_cost_ton/((ir*(1+ir).^(PRJ_LF))/(((1+ir).^PRJ_LF)-1));
WTE_cost=WTE_C+Processing_cost+Transportation_cost;                                   % Total WTE cost annualized/*


%% battery calculations.

% battery net present capital cost
 Battery_costC =Nbat*(BAT_C);
% Battery replacement cost
 Battery_cost_r=Nbat*BAT_C_r*(1/((1+ir).^Bate_LF)); %+(1/((1+ir).^(Bate_LF*2)))
% Battery salvage cost
 Bate_sal_fr=abs(2*Bate_LF-PRJ_LF); %battery salvage fraction
 Battery_sal_cost =Nbat*BAT_C_r*[(Bate_sal_fr/Bate_LF)*(1/((1+ir).^PRJ_LF))];
% Battery Total cost
 Battery_cost =Battery_costC+Battery_cost_r+ [(Nbat*Bat_OM)/((ir*(1+ir).^(PRJ_LF))/(((1+ir).^PRJ_LF)-1))]-Battery_sal_cost;%
 
 
%% wind calcualtions

%Wind net present capital cost
 Wind_cost_c=Nw*(Cw); 
% wind replacement cost
 Wind_cost_r=Nw*(1/((1+ir).^Wind_LF))*[Cwr];
%wind salvage cost
 wind_sal_fr=abs(Wind_LF-PRJ_LF); %wind salvage fraction
 Wind_sal_cost =Nw*[(Cwr*wind_sal_fr/Wind_LF)*(1/((1+ir).^PRJ_LF))];
% wind total cost
 Wind_cost=[(Nw*W_OM)/((ir*(1+ir).^(PRJ_LF))/(((1+ir).^PRJ_LF)-1))]+Wind_cost_c+ Wind_cost_r-Wind_sal_cost;

%% solar net present cost clacultaion

% Solar OM
 Solar_OM_cost=[Nsol*S_OM/((ir*(1+ir).^(PRJ_LF))/(((1+ir).^PRJ_LF)-1))];
% Solar capital cost
 Solar_C_cost=Nsol*(Cs); 
% Solar total present cost
 Solar_cost=Solar_OM_cost+Solar_C_cost

%% inverter cost calcuation
INV_size=37.9;%size of the converter used.
Inverter_C=INV_size*[(INV_C)]; %capital cost
Inverter_Cr=INV_size*[(INV_Cr)*(1/((1+ir).^INV_LF))];% replacement cost
Inverter_OM=INV_size*[(INV_OM)/((ir*(1+ir).^(PRJ_LF))/(((1+ir).^PRJ_LF)-1))];% OM cost
INV_sal_fr=abs(2*INV_LF-PRJ_LF); %Inverter/converter salvage fraction
Inverter_sal_C=INV_size*[(INV_C*INV_sal_fr/INV_LF)*(1/((1+ir).^PRJ_LF))]; %salvage cost
%inverter total net present cost
Inverter_Tcost=Inverter_C+Inverter_Cr+Inverter_OM-Inverter_sal_C;%Inverter total cost

%Total net present cost
NPC=DG_cost+WTE_cost+Inverter_Tcost+Wind_cost+Battery_cost+Solar_cost;  %Total Net present cost(NPC).
end