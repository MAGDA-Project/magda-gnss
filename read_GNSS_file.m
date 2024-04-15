clear all

%% path osservazioni GNSS 

%load ./2019_05_9-11_Malpensa_results_with_epn.mat
load ./ita_2022_07_24-29_rainfall.mat
%chiedere valore da Inserire
S=whos;
S=S(strcmp({S.class},'struct'));
for i=1:length(S); elenco{i}=S(i).name; end


%% lettura file 
err_temp=1.5; % 1.5 err per ztd espresso in cm, per PWV 0.5cm

%% selezionare data desiderata
data_val=datenum('20220725000000','yyyymmddHHMMSS');
datasup=datenum( '20220725000013','yyyymmddHHMMSS');
datainf=datenum( '20220725000000','yyyymmddHHMMSS');
datestr(data_val)
l=1;

for i=2:length(elenco)
        
        % istanti presenti nel file
        nome_staz_tmp=elenco{i};
        eval (['istanti_file=',nome_staz_tmp,'.utc_time;']);
        
        for k=1:length(istanti_file)
            
        
            if istanti_file(k) < datasup && istanti_file(k) > datainf 
                %disp(datestr(istanti_file(k)))
                nome_staz=elenco{i}(1:4);
                % selezione del dato
                eval (['dati_ztd(l)=',nome_staz_tmp,'.ztd(k);']);
                %eval (['dati_ztd(l)=',nome_staz_tmp,'.pwv(k);']); %per PWV
                eval (['lon_staz(l)=',nome_staz_tmp,'.lon;']);
                eval (['lat_staz(l)=',nome_staz_tmp,'.lat;']);
                eval (['z_staz(l)=',nome_staz_tmp,'.h_ortho;']);
                name_staz{l}=nome_staz;
                l=l+1;
            
            end
        end        

end

lonZTD=lon_staz(:);
latZTD=lat_staz(:);
zZTD=z_staz(:);
ZTD=dati_ztd(:);

eval (['save ZTD_gnss_',datestr(data_val,'yyyy-mm-dd_HH:MM:SS'),'.mat ZTD zZTD lonZTD latZTD'])


    tab_atm= [ 0    100
        1000 	88.6
        2000 	78.5
        4000    60.8
        6000    46.5
        8000 	35.0
        10000 	26.0
        15000 	11.5
        20000 	6.9
        30000 	1.2
        48500 	0.1
        69400 	0.01];
    tab_atm(:,2)=tab_atm(:,2)/100;
    
staz='FM-114 GPSZD'; %per ZTD
%staz='FM-111 GPSPW';
data=datestr(data_val,'yyyy-mm-dd_HH:MM:SS');
    
 for i=1:length(latZTD)
        nomi_staz{i}='FM-114 GPSZD';
        nome{i}='TTTTT';%asName{i};
        input_id{i}=name_staz{i};%asCode{i};
 end
    
 errori_dati=zeros(11,length(latZTD));
 dati=NaN(11,length(latZTD));
 val_data=data_val;
%  ztd=(ZTD(indici,:));
    for k=1:length(latZTD)
        
          dati(1,k)=lonZTD(k);
          dati(2,k)=latZTD(k);
          dati(3,k)=zZTD(k);
          dati(5,k)=ZTD(k)*100; %ztd espresso in cm
          %dati(5,k)=ZTD(k)*100; %pwv sempre per 100
          dati(4,k)=101325*interp1(tab_atm(:,1),tab_atm(:,2),zZTD(k));
          %dati(4,k)=-888888.000;
          errori_dati(:,k)=err_temp;
          %Errore per la pressione
          errori_dati(4,:)=100.0;
            
 
        dati_tot{1}=dati;
    end
    
 nome_file_out=['ob.ascii',data];
 
%usa 
 mat2obsascii_gnss(data,val_data,nomi_staz,nome,input_id,dati_tot,errori_dati,nome_file_out)


