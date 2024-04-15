function mat2obsascii_gnss(data,val_data,nomi_staz,nome,input_id,dati_tot,errori_dati,nome_file_out)
data3=datestr(data,'yyyymmddHH');
outpath=['./RO_caso2019/',data3,'/'];
mkdir (outpath)

% MAT2OBSASCII(DATA,NOMI_STAZ,DATI,NOME_FILE)
%
% Input:
%   data = istante di analisi (formato DATENUM)
%   nomi_staz = cell array (1 x nstaz) con i nomi delle stazioni
%   dati = matrice (12 x nstaz), righe:
%           1: longitudine [° est]
%           2: latitudine [° nord]
%           3: quota [m s.l.m.]
%           4: ID stazione (numero intero)
%           5: pressione [Pa]
%           6: pw-ztd [cm]
%           7: temperatura dell'aria [K]
%           8: umidita' relativa dell'aria [%]
%           9: velocita' del vento [m/s]
%          10: direzione del vento [°] (senso orario rispetto al Nord)
%          11: quota [m s.l.m.]
%          12: DewPoint temperature [K]



nstaz=size(dati_tot{1},2);

% scrittura file
fid=fopen([outpath,nome_file_out],'w+');

% scrittura header
fprintf(fid,'TOTAL =  55527, MISS. =-888888.,\n');
fprintf(fid,'SYNOP =      0, METAR =      0, SHIP  =      0, BUOY  =      0, BOGUS =      0, TEMP  =      0, \n');
fprintf(fid,'AMDAR =      0, AIREP =      0, TAMDAR=      0, PILOT =      0, SATEM =      0, SATOB =      0, \n');
fprintf(fid,'GPSPW =      0, GPSZD =  55527, GPSRF =      0, GPSEP =      0, SSMT1 =      0, SSMT2 =      0, \n');
fprintf(fid,'TOVS  =      0, QSCAT =      0, PROFL =      0, AIRSR =      0, OTHER =      0, \n');
fprintf(fid,'PHIC  =  40.00, XLONC = -95.00, TRUE1 =  45.03, TRUE2 =  45.03, XIM11 =   1.00, XJM11 =   1.00,\n');
fprintf(fid,'base_temp= 290.00, base_lapse=  50.00, PTOP  =  5000., base_pres=100000., base_tropo_pres= 20000., base_strat_temp=   215.,\n');
fprintf(fid,'IXC   =     60, JXC   =     90, IPROJ =      1, IDD   =      1, MAXNES=      1,\n');
fprintf(fid,'NESTIX=     60, \n');
fprintf(fid,'NESTJX=     90, \n');
fprintf(fid,'NUMC  =      1, \n');
fprintf(fid,'DIS   =  60.00, \n');
fprintf(fid,'NESTI =      1, \n');
fprintf(fid,'NESTJ =      1, \n');
fprintf(fid,'INFO  = PLATFORM, DATE, NAME, LEVELS, LATITUDE, LONGITUDE, ELEVATION, ID.\n');
fprintf(fid,'SRFC  = SLP, PW (DATA,QC,ERROR).\n');
fprintf(fid,'EACH  = PRES, SPEED, DIR, HEIGHT, TEMP, DEW PT, HUMID (DATA,QC,ERROR)*LEVELS.\n');
fprintf(fid,'INFO_FMT = (A12,1X,A19,1X,A40,1X,I6,3(F12.3,11X),6X,A40)\n');
fprintf(fid,'SRFC_FMT = (F12.3,I4,F7.2,F12.3,I4,F7.3)\n');
fprintf(fid,'EACH_FMT = (3(F12.3,I4,F7.2),11X,3(F12.3,I4,F7.2),11X,3(F12.3,I4,F7.2))\n');
fprintf(fid,'#------------------------------------------------------------------------------#\n');

for k=1:length(dati_tot)
dati=dati_tot{k};  
dati(isnan(dati))=-888888;
flag_qual=zeros(11,nstaz);
flag_qual(dati==-888888)=-88;

for s=1:nstaz
    
    
    v_platform=nomi_staz{s};
    %v_name=nomi_staz{s};
    v_name=nome{s};
    v_id=input_id{s};
    level=1;
    
    lon=dati(1,s);
    lat=dati(2,s);
    elev=dati(3,s);
    pres=dati(4,s);
    data_pw=dati(5,s);
    temp=dati(6,s);
    humid=dati(7,s);
    speed=dati(8,s);
    direz=dati(9,s);
    height=dati(10,s);
    dew_pt=dati(11,s);
    data_slp=-888888;
    
    err_pres=errori_dati(4,s);
    err_pw=errori_dati(5,s);
    err_temp=errori_dati(6,s);
    err_humid=errori_dati(7,s);
    err_speed=errori_dati(8,s);
    err_direz=errori_dati(9,s);
    err_height=errori_dati(10,s);
    err_dew_pt=errori_dati(11,s);
    error_slp=err_pres;
    
    %qc_pres=flag_qual(4,s);
    qc_pres=-5;
    qc_pw=flag_qual(5,s);
    qc_temp=flag_qual(6,s);
    qc_humid=flag_qual(7,s);
    qc_speed=flag_qual(8,s);
    qc_direz=flag_qual(9,s);
    qc_height=flag_qual(10,s);
    qc_dew_pt=flag_qual(11,s);
    qc_slp=qc_pres;
    
    
    pres=[pres qc_pres err_pres]; %#ok<AGROW>
    speed=[speed qc_speed err_speed]; %#ok<AGROW>
    direz=[direz qc_direz err_direz]; %#ok<AGROW>
    height=[height qc_height err_height]; %#ok<AGROW>
    temp=[temp qc_temp err_temp]; %#ok<AGROW>
    dew_pt=[dew_pt qc_dew_pt err_dew_pt]; %#ok<AGROW>
    humid=[humid qc_humid err_humid]; %#ok<AGROW>
    
    
    %% Per scrivere riga1
    % INFO_FMT = (A12,1X,A19,1X,A40,1X,I6,3(F12.3,11X),6X,A40)
    % INFO  = PLATFORM, DATE, NAME, LEVELS, LATITUDE, LONGITUDE, ELEVATION, ID.
    
    l=length(v_platform);
    if l>=12
        platform=v_platform(1:12);
    elseif l<12
        platform=[v_platform,char(' '*ones(1,12-l))];
    end
    clear l
    l=length(v_name);
    if l>40
        name=v_name(1:40);
    elseif l<40
        name=[v_name,char(' '*ones(1,40-l))];
    end
    clear l
    l=length(v_id);
    if l>40
        id=v_id(1:40);
    elseif l<40
        id=[v_id,char(' '*ones(1,40-l))];
    end
    riga1=sprintf('%s %s %s %6.0f%12.3f           %12.3f           %12.3f                 %s',platform,datestr(val_data(k),'yyyy-mm-dd_HH:MM:SS'),name,level,lat,lon,elev,id);
    
    %% Per scrivere riga2
    
    % SRFC  = SLP, PW (DATA,QC,ERROR).
    % SRFC_FMT = (F12.3,I4,F7.2,F12.3,I4,F7.3)
    
    
    riga2=sprintf('%12.3f%4.0f%7.2f%12.3f%4.0f%7.3f',data_slp,qc_slp,error_slp,data_pw,qc_pw,err_pw);
    
    %% Per scrivere riga3
    
    % EACH  = PRES, SPEED, DIR, HEIGHT, TEMP, DEW PT, HUMID (DATA,QC,ERROR)*LEVELS.
    % EACH_FMT = (3(F12.3,I4,F7.2),11X,3(F12.3,I4,F7.2),11X,3(F12.3,I4,F7.2))
    
    
    riga3=sprintf('%12.3f%4.0f%7.2f%12.3f%4.0f%7.2f%12.3f%4.0f%7.2f           %12.3f%4.0f%7.2f%12.3f%4.0f%7.2f%12.3f%4.0f%7.2f           %12.3f%4.0f%7.2f%12.3f%4.0f%7.2f%12.3f%4.0f%7.2f',pres(1),pres(2),pres(3),speed(1),speed(2),speed(3),direz(1),direz(2),direz(3),height(1),height(2),height(3),temp(1),temp(2),temp(3),dew_pt(1),dew_pt(2),dew_pt(3),humid(1),humid(2),humid(3));
    
%     %% scrivere triplette
%     platformtest=[riga1,riga2,riga3]; 

    fprintf(fid,[riga1,'\n',riga2,'\n',riga3,'\n']);
     
    
end
end
fclose(fid);
