 function [Anual_cost,Wind_cost,WTE_cost,Solar_cost,DG_cost,Battery_cost,Inverter_Tcost,Bin,Bout]=plot_statistics(x)

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
 
 %% ************************************
[TNPC,WTE_cost,Wind_cost,Solar_cost,DG_cost,Battery_cost,Inverter_Tcost]= NPC_cost(Nbat,Nw,Nsol,WTE,DG_hr,DG_Pro);

Bin=sum(Ech);
Bout=sum(Edch);

assignin('base','Bat_out',Edch);
assignin('base','Bat_in',Ech);
% assignin('base','Edump',Edump);
% Pgrid_Total=sum(Edump)
% assignin('base','Pgrid_Total',Pgrid_Total);

%*************************************************
% Ploting section
%*************************************************
m1=2017;m2=2184;  

t1=1:1:168;
figure
plot(1:1:744,Eb(1:744)*100/Ebmax,'DisplayName','SOC','Color',[0.8500 0.3250 0.0980])
ylabel('SOC(%)');
xlabel('Hours');
xlim([0 744])
xticks(0:62:744);
legend
%legend('Location','best');
grid;
set(gcf, 'PaperPosition', [0 0 7 4]); 
set(gcf, 'PaperSize', [7 4]); 
saveas(gcf, 'SOC 1 month', 'pdf')

figure
plot(t1,load1(m1:m2),'DisplayName','Load','LineWidth',2,'LineStyle','--')
hold
plot(t1,Edch(m1:m2),'DisplayName','Bat out')
temp=Pw(m1:m2);
plot(t1,temp(1:168),'DisplayName','Wind','LineWidth',2)
plot(t1,WTE(m1:m2),'DisplayName','WTE','LineWidth',2)
plot(t1,Ps(m1:m2),'DisplayName','Solar','LineWidth',2,'Color',[0 0.498039215803146 0])
ylabel('Energy(KWh)');
xlabel('Hours');
xlim([0 168])
xticks(0:21:168);
legend
%legend('Location','best');
grid;
set(gcf, 'PaperPosition', [0 0 7 4]); 
set(gcf, 'PaperSize', [7 4]); 
saveas(gcf, 'load V bat out V WTE V Wind V SOlar for 1 week', 'pdf')

figure
plot(t1,load1(m1:m2),'DisplayName','Load','LineWidth',2,'LineStyle','--')
hold
plot(Ech(m1:m2),'DisplayName','Bat Charge','Color',[1 0 0])
temp=Pw(m1:m2)+Edch(m1:m2).*uinv;
plot(t1,temp(1:168),'DisplayName','windPower + Bat discharge','Color',[1 0 0],'LineWidth',2)
plot(t1,Ps(m1:m2),'DisplayName','SolPower','Color',[0 0.498039215803146 0],'LineWidth',2)
ylabel('Energy(KWh)');
xlabel('Hours');
xlim([0 168])
xticks(0:21:168);
legend
%legend('Location','best');
grid;
set(gcf, 'PaperPosition', [0 0 7 4]); 
set(gcf, 'PaperSize', [7 4]); 
saveas(gcf, 'load V bat in V Wind+bat out V SOlar for 1 week', 'pdf')


% figure
% plot(744:1:1487,load1(744:1487),'DisplayName','Load','LineStyle','--')
% hold
% plot(Ech(744:1487),'DisplayName','Bat Charge','Color',[1 0 0])
% temp=Pw(744:1487)+Edch(744:1487).*uinv;
% plot(744:1:1487,temp(744:1487),'DisplayName','windPower + Bat discharge')
% plot(744:1:1487,Ps(744:1487),'DisplayName','SolPower','Color',[0 0.498039215803146 0])
% ylabel('Energy(KWh)');
% xlabel('Hours');
% legend
% legend('Location','best');
% grid;


figure
plot(t1,-Ech(m1:m2),'DisplayName','Bat in')
hold
plot(t1,Edch(m1:m2),'DisplayName','Bat out')
ylabel('Energy(KWh)');
xlabel('Hours');
xlim([0 168])
xticks(0:21:168);
legend
grid;
set(gcf, 'PaperPosition', [0 0 7 4]); 
set(gcf, 'PaperSize', [7 4]); 
saveas(gcf, 'bat in V bat out for 1 wwek','pdf')


figure
plot(t1,DG_Pro(m1:m2),'DisplayName','DG power')
ylabel('Energy(KWh)');
xlabel('Hours');
xlim([0 168])
xticks(0:21:168);
legend
%legend('Location','best');
grid;
set(gcf, 'PaperPosition', [0 0 7 4]); 
set(gcf, 'PaperSize', [7 4]); 
saveas(gcf, 'DG Power for 1 wwek', 'pdf')


figure
yyaxis left
%area(Pbmg(1:48),Pbio(1:48),Pp(1:48))
hold
% area(t1,load1(m1:m2),'DisplayName','Load','FaceColor',[1 1 0])
area((Pw(m1:m2)),'DisplayName','P(wind)')
area(Edch(m1:m2),'DisplayName','Bout','FaceColor','r')
% plot(Pbmg(m1:m2),'DisplayName','P(gasifier)','Color',[1 0 0])
plot(WTE(m1:m2),'DisplayName','WTE','LineWidth',2,'Color',[0.4940 0.1840 0.5560])
% plot(Edump(m1:m2),'c--o','DisplayName','Pgrid')
plot(t1,load1(m1:m2),'DisplayName','Load','LineStyle','--','LineWidth',2)
plot(t1,Ps(m1:m2).*uinv,'DisplayName','Psol','LineStyle','-','LineWidth',2,'Color',[0.4660 0.6740 0.1880])
ylabel('Energy(KWh)');
xlabel('Hours');
xlim([0 168])
xticks(0:21:168);
legend
grid;
set(gcf, 'PaperPosition', [0 0 7 4]); 
set(gcf, 'PaperSize', [7 4]); 
saveas(gcf, 'load V bat out V Wind V WTE V SOlar for 1 week', 'pdf')



% yyaxis right
% plot(t1,Eb(m1:m2)*100/Ebmax,'DisplayName','SOC','LineWidth',1,'Color',[0.850980401039124 0.325490206480026 0.0980392172932625])
% ylabel('SOC(%)');
% legend
%legend('Location','best');

figure
plot(-Ech,'DisplayName','Bat in')
hold
plot(Edch,'DisplayName','Bat out')
ylabel('Energy(KWh)');
xlabel('Hours');
xlim([0 8760])
xticks([0 1000 2000 3000 4000 5000 6000 7000 8000 8760]);
legend
%legend('Location','best');
grid;
set(gcf, 'PaperPosition', [0 0 7 4]); 
set(gcf, 'PaperSize', [7 4]); 
saveas(gcf, 'bat in v bat out for 8760', 'pdf')

figure
plot(Eb*100/Ebmax,'DisplayName','SOC','Color',[0.8500 0.3250 0.0980])
ylabel('SOC(%)');
xlabel('Hours');
xlim([0 8760])
xticks([0 1000 2000 3000 4000 5000 6000 7000 8000 8760]);
legend
%legend('Location','best');
grid;
set(gcf, 'PaperPosition', [0 0 7 4]); 
set(gcf, 'PaperSize', [7 4]); 
saveas(gcf, 'soc for 8760', 'pdf')


figure
tmp=Pw+Ps+WTE;
plot((tmp),'DisplayName','wind power+solar+WTE')
hold
plot(-load1,'DisplayName','load')
ylabel('load(on -yaxis)        wind power+solar ');
xlabel('Hours');
xlim([0 8760])
xticks([0 1000 2000 3000 4000 5000 6000 7000 8000 8760]);
legend
%legend('Location','best');
grid;
set(gcf, 'PaperPosition', [0 0 7 4]); 
set(gcf, 'PaperSize', [7 4]); 
saveas(gcf, 'wind power+solar+WTE V load for 8760', 'pdf')

figure
plot(Pw,'DisplayName','Wind Energy')
ylabel('Wind Energy(KWh)');
xlabel('Hours');
xlim([0 8760])
xticks([0 1000 2000 3000 4000 5000 6000 7000 8000 8760]);
legend
%legend('Location','best');
grid;
set(gcf, 'PaperPosition', [0 0 7 4]); 
set(gcf, 'PaperSize', [7 4]); 
saveas(gcf, 'wind energy', 'pdf')


figure
plot(WTE,'DisplayName','WTE Energy','Color',[0.4660 0.6740 0.1880])
ylabel('WTE Energy(KWh)');
xlabel('Hours');
xlim([0 8760])
xticks([0 1000 2000 3000 4000 5000 6000 7000 8000 8760]);
legend
%legend('Location','best');
grid;
set(gcf, 'PaperPosition', [0 0 7 4]); 
set(gcf, 'PaperSize', [7 4]); 
saveas(gcf, 'WTE energy', 'pdf')

figure
plot(Ps,'DisplayName','Solar Energy','Color',[0.4940 0.1840 0.5560])
ylabel('Solar Energy(KWh)');
xlabel('Hours');
xlim([0 8760])
xticks([0 1000 2000 3000 4000 5000 6000 7000 8000 8760]);
legend
%legend('Location','best');
grid;
set(gcf, 'PaperPosition', [0 0 7 4]); 
set(gcf, 'PaperSize', [7 4]); 
saveas(gcf, 'solar energy', 'pdf')

% figure
% plot(DG_Pro,'DisplayName','DG power')
% ylabel('Energy(KWh)');
% xlabel('Hours');
% legend

figure
plot(v,'DisplayName','wind speed')
ylabel('wind speed(m/sn)');
xlabel('Hours');
legend
xlim([0 8760])
xticks([0 1000 2000 3000 4000 5000 6000 7000 8000 8760]);
% legend('Location','best');
grid;
set(gcf, 'PaperPosition', [0 0 7 4]); 
set(gcf, 'PaperSize', [7 4]); 
saveas(gcf, 'wind speed', 'pdf')

figure 
plot(G,'DisplayName','Solar irrdiance', 'Color',[0.4940 0.1840 0.5560])
ylabel('Irridiacne(W/m^2)');
xlabel('Hours');
legend
xlim([0 8760])
xticks([0 1000 2000 3000 4000 5000 6000 7000 8000 8760]);
% legend('Location','best');
grid;
set(gcf, 'PaperPosition', [0 0 7 4]); 
set(gcf, 'PaperSize', [7 4]); 
saveas(gcf, 'solar irrad', 'pdf')

figure 
plot(Tamb,'DisplayName','Ambient temperature', 'Color','r')
ylabel('Ambient temperature(°C)');
xlabel('Hours');
xlim([0 8760])
xticks([0 1000 2000 3000 4000 5000 6000 7000 8000 8760]);
legend
%legend('Location','best');
grid;
set(gcf, 'PaperPosition', [0 0 7 4]); 
set(gcf, 'PaperSize', [7 4]); 
saveas(gcf, 'ambient temp', 'pdf')

% figure
% ef=[0.8 .85 .9 .95 1 ]
% lcoe_value=[0.2351 0.2212 0.2089 0.1980 0.1881]
% 
% plot(ef,lcoe_value,'DisplayName','SOC','Marker','*','Color',[1 0 1])
% ylabel('LCOE($/KWh)');
% xlabel('Converter efficiency');

% figure
% plot(Ech,'DisplayName','Charging','LineStyle','--')
% hold
% plot(Edch,'DisplayName','discharging')
% plot(Edump,'DisplayName','Dump','LineStyle','-')
% plot(Eb*100/Ebmax,'DisplayName','SOC')

%January calculations
Jan_solar=sum(Ps(1:744));        %solar energy generated in january 
Jan_wind=sum(Pw(1:744));         %wind energy generated in january
Jan_WTE=sum(WTE(1:744));         %wind energy generated in january
Jan_Batout=sum(Edch(1:744));     %Energy provided by battery in january
Jan_DG=sum(DG_Pro(1:744));       %DG energy generated in january
Jan_surplus=sum(Edump(1:744));   %Defferable energy  in january. It is surplus energy that can be used for defferable load
Jan_demand=-sum(load1(1:744));   %Load (KWh) in january
Jan_Batin=-sum(Ech(1:744));      %Energy used in battery charging in january
Jan_Total=Jan_solar+Jan_wind+Jan_WTE   %Total energy generated in january
%Febuary calculations
Feb_solar=sum(Ps(745:1416));
Feb_wind=sum(Pw(745:1416));
Feb_WTE=sum(WTE(745:1416));
Feb_Batout=sum(Edch(745:1416));
Feb_DG=sum(DG_Pro(745:1416));
Feb_surplus=sum(Edump(745:1416));
Feb_demand=-sum(load1(745:1416));
Feb_Batin=-sum(Ech(745:1416));
Feb_Total=Feb_solar+Feb_wind+Feb_WTE
%March calculations
Mar_solar=sum(Ps(1417:2160));
Mar_wind=sum(Pw(1417:2160));
Mar_WTE=sum(WTE(1417:2160));
Mar_Batout=sum(Edch(1417:2160));
Mar_DG=sum(DG_Pro(1417:2160));
Mar_surplus=sum(Edump(1417:2160));
Mar_demand=-sum(load1(1417:2160));
Mar_Batin=-sum(Ech(1417:2160));
Mar_Total=Mar_solar+Mar_wind+Mar_WTE
%April calculations
Apr_solar=sum(Ps(2161:2880));
Apr_wind=sum(Pw(2161:2880));
Apr_WTE=sum(WTE(2161:2880));
Apr_Batout=sum(Edch(2161:2880));
Apr_DG=sum(DG_Pro(2161:2880));
Apr_surplus=sum(Edump(2161:2880));
Apr_demand=-sum(load1(2161:2880));
Apr_Batin=-sum(Ech(2161:2880));
Apr_Total=Apr_solar+Apr_wind+Apr_WTE
%May calculations
May_solar=sum(Ps(2881:3624));
May_wind=sum(Pw(2881:3624));
May_WTE=sum(WTE(2881:3624));
May_Batout=sum(Edch(2881:3624));
May_DG=sum(DG_Pro(2881:3624));
May_surplus=sum(Edump(2881:3624));
May_demand=-sum(load1(2881:3624));
May_Batin=-sum(Ech(2881:3624));
May_Total=May_solar+May_wind+May_WTE
%Jun calculations
Jun_solar=sum(Ps(3625:4344));
Jun_wind=sum(Pw(3625:4344));
Jun_WTE=sum(WTE(3625:4344));
Jun_Batout=sum(Edch(3625:4344));
Jun_DG=sum(DG_Pro(3625:4344));
Jun_surplus=sum(Edump(3625:4344));
Jun_demand=-sum(load1(3625:4344));
Jun_Batin=-sum(Ech(3625:4344));
Jun_Total=Jun_solar+Jun_wind+Jun_WTE
%July calculations
Jul_solar=sum(Ps(4345:5088));
Jul_wind=sum(Pw(4345:5088));
Jul_WTE=sum(WTE(4345:5088));
Jul_Batout=sum(Edch(4345:5088));
Jul_DG=sum(DG_Pro(4345:5088));
Jul_surplus=sum(Edump(4345:5088));
Jul_demand=-sum(load1(4345:5088));
Jul_Batin=-sum(Ech(4345:5088));
Jul_Total=Jul_solar+Jul_wind+Jul_WTE
%Augest calculations
Aug_solar=sum(Ps(5089:5832));
Aug_wind=sum(Pw(5089:5832));
Aug_WTE=sum(WTE(5089:5832));
Aug_Batout=sum(Edch(5089:5832));
Aug_DG=sum(DG_Pro(5089:5832));
Aug_surplus=sum(Edump(5089:5832));
Aug_demand=-sum(load1(5089:5832));
Aug_Batin=-sum(Ech(5089:5832));
Aug_Total=Aug_solar+Aug_wind+Aug_WTE
%September calculations
Sep_solar=sum(Ps(5833:6552));
Sep_wind=sum(Pw(5833:6552));
Sep_WTE=sum(WTE(5833:6552));
Sep_Batout=sum(Edch(5833:6552));
Sep_DG=sum(DG_Pro(5833:6552));
Sep_surplus=sum(Edump(5833:6552));
Sep_demand=-sum(load1(5833:6552));
Sep_Batin=-sum(Ech(5833:6552));
Sep_Total=Sep_solar+Sep_wind+Sep_WTE
%October calculations
Oct_solar=sum(Ps(6553:7296));
Oct_wind=sum(Pw(6553:7296));
Oct_WTE=sum(WTE(6553:7296));
Oct_Batout=sum(Edch(6553:7296));
Oct_DG=sum(DG_Pro(6553:7296));
Oct_surplus=sum(Edump(6553:7296));
Oct_demand=-sum(load1(6553:7296));
Oct_Batin=-sum(Ech(6553:7296));
Oct_Total=Oct_solar+Oct_wind+Oct_WTE
%November calculations
Nov_solar=sum(Ps(7297:8016));
Nov_wind=sum(Pw(7297:8016));
Nov_WTE=sum(WTE(7297:8016));
Nov_Batout=sum(Edch(7297:8016));
Nov_DG=sum(DG_Pro(7297:8016));
Nov_surplus=sum(Edump(7297:8016));
Nov_demand=-sum(load1(7297:8016));
Nov_Batin=-sum(Ech(7297:8016));
Nov_Total=Nov_solar+Nov_wind+Nov_WTE
%December calculations
Dec_solar=sum(Ps(8017:8760));
Dec_wind=sum(Pw(8017:8760));
Dec_WTE=sum(WTE(8017:8760));
Dec_Batout=sum(Edch(8017:8760));
Dec_DG=sum(DG_Pro(8017:8760));
Dec_surplus=sum(Edump(8017:8760));
Dec_demand=-sum(load1(8017:8760));
Dec_Batin=-sum(Ech(8017:8760));
Dec_Total=Dec_solar+Dec_wind+Dec_WTE
data=[Jan_solar Jan_wind Jan_WTE Jan_Batout Jan_DG Jan_surplus Jan_Total Jan_demand Jan_Batin
      Feb_solar Feb_wind Feb_WTE Feb_Batout Feb_DG Feb_surplus Feb_Total Feb_demand Feb_Batin
      Mar_solar Mar_wind Mar_WTE Mar_Batout Mar_DG Mar_surplus Mar_Total Mar_demand Mar_Batin
      Apr_solar Apr_wind Apr_WTE Apr_Batout Apr_DG Apr_surplus Apr_Total Apr_demand Apr_Batin
      May_solar May_wind May_WTE May_Batout May_DG May_surplus May_Total May_demand May_Batin
      Jun_solar Jun_wind Jun_WTE Jun_Batout Jun_DG Jun_surplus Jun_Total Jun_demand Jun_Batin
      Jul_solar Jul_wind Jul_WTE Jul_Batout Jul_DG Jul_surplus Jul_Total Jul_demand Jul_Batin
      Aug_solar Aug_wind Aug_WTE Aug_Batout Aug_DG Aug_surplus Aug_Total Aug_demand Aug_Batin
      Sep_solar Sep_wind Sep_WTE Sep_Batout Sep_DG Sep_surplus Sep_Total Sep_demand Sep_Batin
      Oct_solar Oct_wind Oct_WTE Oct_Batout Oct_DG Oct_surplus Oct_Total Oct_demand Oct_Batin
      Nov_solar Nov_wind Nov_WTE Nov_Batout Nov_DG Nov_surplus Nov_Total Nov_demand Nov_Batin
      Dec_solar Dec_wind Dec_WTE Dec_Batout Dec_DG Dec_surplus Dec_Total Dec_demand Dec_Batin];
  
%month=[{'JAN','FEB','MARCH','MAY','JUNE','JULY','AUG','SEP','OCT','NOV','DEC','APRIL'}];
C = categorical([{'A','B','C','D','E','F','G','H','I','J','K','L'}])
figure1 = figure;
% Create axes
axes1 = axes('Parent',figure1);
bar1=bar(C,data,'Parent',axes1);
% Set the x-axes properties
set(axes1,'XTickLabel',{'JAN','FEB','MAR','APRIL','MAY','JUNE','JULY','AUG','SEP','OCT','NOV','DEC'});
set(bar1(1),'DisplayName','Solar');
set(bar1(2),'DisplayName','Wind');
set(bar1(3),'DisplayName','WTE');
set(bar1(4),'DisplayName','Batout');
set(bar1(5),'DisplayName','DG');
set(bar1(6),'DisplayName','Surplus');
set(bar1(7),'DisplayName','Total Generation');
set(bar1(8),'DisplayName','Demand');
set(bar1(9),'DisplayName','BatteryIn');
legend
% legend('boxoff');
lgd=legend('Location','southeast');
lgd.NumColumns = 4;
lgd.FontSize = 7;
grid;
ylabel('Energy(KWh)');
set(gcf, 'PaperPosition', [0 0 7 4]); 
set(gcf, 'PaperSize', [7 4]); 
saveas(gcf, 'Generation Vs Load', 'pdf')

%24 hours load plot
figure
bar(load1(1:24),'DisplayName','Load for 24 hours','FaceColor',[0.8500 0.2250 0.0980]);
ylabel('Load demand(KWh)');
xlabel('Hours');
legend
% legend('Location','best');
grid;
set(gcf, 'PaperPosition', [0 0 7 4]); 
set(gcf, 'PaperSize', [7 4]); 
saveas(gcf, '24h load', 'pdf')


%8760 hours load plot
figure
bar(load1(1:8760),'DisplayName','Annual Load Demand', 'FaceColor',[0.8500 0.2250 0.0980]);
ylabel('Load demand(KWh)');
xlabel('Hours');
xlim([0 8760])
xticks([0 1000 2000 3000 4000 5000 6000 7000 8000 8760]);
legend
%legend('Location','best');
grid;
set(gcf, 'PaperPosition', [0 0 7 4]); 
set(gcf, 'PaperSize', [7 4]); 
saveas(gcf, '8760 load', 'pdf')


disp('*******************************************')
disp('                Final design               ')
disp('*******************************************')
disp(sprintf('WTE plant size(KW) =%d, Wind Turbines =%d, Solar Power(KW) =%d, Battery units =%d',x(1),x(2),x(3),x(4)));

disp('Total Wind energy(KWh)=')
disp(sum(Pw));
disp('Total Solar energy(KWh)=')
disp(sum(Ps));
disp('Total DG Energy generation(KWh)=')
disp(sum(DG_Pro));
disp('Total WTE Energy generation(KWh)=')
disp(sum(WTE));

disp('Wasted Energy(KWh)=')
disp(sum(Edump));
disp('Total Load demand(KWh)=')
disp(sum(Pl));
%Wasted energy plot
figure
plot(1:1:8760,Edump(1:8760), 'DisplayName','Wasted Energy(kWh)', 'Color',[0.6350 0.0780 0.1840])
ylabel('Wasted Energy(kWh)');
xlabel('Hours');
xlim([0 8760])
xticks([0 1000 2000 3000 4000 5000 6000 7000 8000 8760]);
legend 
grid;
set(gcf, 'PaperPosition', [0 0 7 4]); 
set(gcf, 'PaperSize', [7 4]); 
saveas(gcf, 'wasted energy', 'pdf')
LCOE_=(Anual_cost/sum(load1))
REF=Ren_fraction
WT_fraction=Ren_fraction*[sum(Pw)/(sum(Pw)+sum(Ps))]
PV_fraction=Ren_fraction*[sum(Ps)/(sum(Pw)+sum(Ps))]
Sox=0.5;
Nox=0.22;
Co2=697;
Co2_WTE=900;
Co2_Emission=(Co2)*sum(DG_Pro)+(Co2_WTE)*sum(WTE)

% Co2 Emission
figure
plot(1:1:8760,Co2*DG_Pro(1:8760)+Co2_WTE*WTE(1:8760),'DisplayName','CO_2 Emission (DG+WTE)','Color','r')
ylabel('Emission(gm/kWh)');
xlabel('Hours');
xlim([0 8760])
xticks([0 1000 2000 3000 4000 5000 6000 7000 8000 8760]);
legend
% legend('Location','best');
grid;
set(gcf, 'PaperPosition', [0 0 7 4]); 
set(gcf, 'PaperSize', [7 4]); 
saveas(gcf, 'CO_2 emission', 'pdf')

TNPC
disp('*******************************************')
disp(' Annualized cost of compponets             ')
disp('*******************************************')