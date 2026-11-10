function [Eb,Ech,Edch,Edump,WTE] = charge(Eb,Ebmax,Edump,Pl,t,Ech,Edch,Pw,Ps,WTE)
 %^^^^^^^^^^^^^^CHARGE^^^^^^^^^^^^^^^^^^^^^^^^^^
 uconv=0.95;
 univ=0.95;
 global P_WTE;
           WTE(t)=P_WTE;
           Edump(t)=0;
           Edch(t)=0;
        if (WTE(t)+Pw(t))>Pl(t)
           Pch(t)=(((WTE(t)+Pw(t))-Pl(t))*uconv+Ps(t)); %surplus energy to be used for battery charging.
        else
           Pch(t)=Ps(t)-((Pl(t)-Pw(t)-WTE(t))/uconv); %surplus energy to be used for battery charging.
        end
        %n_bat is battery round trip efficiency.
           Ech(t)=Pch(t);% due to one hour iteration time
        if Ech(t)<=Ebmax-Eb(t-1)
           Eb(t)=Eb(t-1)+Ech(t);
            
        else
           Eb(t)=Ebmax; % max SOC constraint is implemented here, in the else condition, the avaible charging is more than capacity, instaed SOC is limited to 100%(Ebmax) 
           Edump(t)=(Ech(t)-(Ebmax-Eb(t-1)));   % the ammount of  energy supplied to defferaboe load.
           if(Edump(t)>WTE(t))
              Edump(t)=Edump(t)-WTE(t);
              WTE(t)=0; 
           else
              WTE(t)=WTE(t)-Edump(t);
              Edump(t)=0;
           end
           Ech(t)=(Ebmax)-Eb(t-1); 
        end          
    


%         if ((uconv*Ps(t)+Pw(t))>Pl(t))&&()
%            Pch(t)=(uconv*Ps(t)+Pw(t))-Pl(t); %surplus energy to be used for battery charging.
%            WTE(t)=0;