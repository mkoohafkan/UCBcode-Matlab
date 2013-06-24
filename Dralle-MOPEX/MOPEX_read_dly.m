

%read a specific .dly file, specified by user in this script. See line
%200 to specify
%DailyData is a cell array with the following structure
%DailyData{1}-{3} = dates
%DailyData{4} = daily precip
%DailyData{5} = Potential Evaporation
%DailyData{6} = daily streamflow discharge
%DailyData{7}/{8} = max/min daily air temp



close all;
clear all;

% USGS basin info data:
filename          = 'data/usgs431.txt';
fid               = fopen(filename);
A                 = textscan(fid,'%s %s %s %s %s %s %s %s %s %s %s','delimiter','\t');
fclose(fid);
USGS_basin_ID_ceil   = A{1,1}; 
%longitude       = A{1,2};
%latitude        = A{1,3}; 
elevation       = A{1,4}; 
date_begin      = A{1,5}; 
date_end        = A{1,6}; 
state           = A{1,9}; 
name_basins     = A{1,11};

% greenness indices across basins:
filename        = 'data/GFRAC438.MON';
greeness_data   = load(filename);
% USGS_basin_ID   = greeness_data(:,1); 
% longitude       = greeness_data(:,2); 
% latitude        = greeness_data(:,3); 
area            = greeness_data(:,4);
greeness_fraction = greeness_data(:,5:end);
months           = 1:12;
greeness_data   = 0.; 
 
% NDVI across basins:
filename        = 'data/NDVI_AVG.438';
NDVI_data       = load(filename);
% USGS_basin_ID   = NDVI_data(:,1); 
% longitude       = NDVI_data(:,2); 
% latitude        = NDVI_data(:,3); 
area            = NDVI_data(:,4);
NDVI_fraction   = NDVI_data(:,5);
NDVI_data   = 0.; 
 
% hydrologic yearly ratios:
filename        = 'data/HY_RATIO.438';
annual_cycle    = load(filename);
USGS_basin_ID   = annual_cycle(:,1); 
longitude       = annual_cycle(:,2); 
latitude        = annual_cycle(:,3); 
area            = annual_cycle(:,4);
P_mean_Ep_mean  = annual_cycle(:,5);
R_mean_Ep_mean  = annual_cycle(:,6);
ET_mean_Ep_mean = annual_cycle(:,7);
annual_cycle   = 0.;

% wet_basin_index = find(P_mean_Ep_mean>2);
% USGS_wet_basin  = USGS_basin_ID(wet_basin_index);

% for j=1:length(USGS_wet_basin)
%     for i=1:length(USGS_basin_ID_ceil)
%         if(str2double(USGS_basin_ID_ceil{i})==USGS_wet_basin(j))
%             name_basins{i}
%         end    
%     end
% end

% soil parameters across basins (based on Sacramento model):
filename        = 'data/HYD_PROP.438';
soil_data       = load(filename);
% USGS_basin_ID   = soil_data(:,1); 
porosity        = soil_data(:,2);
w_fc            = soil_data(:,3); %field capacity
w_wilt          = soil_data(:,4);
slope_rention_curve  = soil_data(:,5);
k_sat           = soil_data(:,7);
soil_data   = 0.; 


% Monthly potential adjustment based on Sacramento model:
filename        = 'data/PE_ADJ.438';
PE_adj_data   = load(filename);
% USGS_basin_ID   = PE_adj_data(:,1); 
longitude       = PE_adj_data(:,2); 
latitude        = PE_adj_data(:,3); 
area            = PE_adj_data(:,4);
PE_adj          = PE_adj_data(:,5:end);
PE_adj_data     = 0.;

% Monthly Potential Evaporation values are based on NOAA Freewater evaporation Atlas.
filename        = 'data/PE_CLIM.438';
Ep_data         = load(filename);
% USGS_basin_ID   = Ep_data(:,1); 
longitude       = Ep_data(:,2); 
latitude        = Ep_data(:,3); 
area            = Ep_data(:,4);
Ep              = Ep_data(:,5:end);
Ep_data         = 0.;



% Monthly precipitation.
filename        = 'data/PRISMMON.438';
P_data         = load(filename);
% USGS_basin_ID   = P_data(:,1); 
longitude       = P_data(:,2); 
latitude        = P_data(:,3); 
area            = P_data(:,4);
P               = P_data(:,5:end);
P_data          = 0.;




% Soil texture.

% Table 5 - The soil texture classification definitions:
% _____________________________________________________
%      1      S       Sand
%      2      LS      Loamy sand
%      3      SL      Sandy loam
%      4      SIL     Silt loam
%      5      SI      Silt
%      6      L       Loam
%      7      SCL     Sandy clay loam
%      8      SICL    Silty clay loam
%      9      CL      Clay loam
%     10      SC      Sandy clay
%     11      SIC     Silty clay
%     12      C       Clay
%     13      OM      Organic materials
%     14      W       Water
%     15      BR      Bedrock
%     16      O       Other
% _____________________________________________________
% 
% This directory contains the following files.  Each contains one record 
% for each of the 438 MOPEX basins
% 
% S0_10.438 - 0-10cm fractional distribution of 16 soil texture classes
% S0_100.438 - 0-100cm fractional distribution of 16 soil texture classes
% S0_150.438 - 0-150cm fractional distribution of 16 soil texture classes
% S0_150DM.438 - 0-150cm dominant soil texture class
% S0_250DM.438 - 0-250cm dominant soil texture class
% S100_150.438 - 100-150cm fractional distribution of 16 soil texture classes
% S10_40.438 - 10-40cm fractional distribution of 16 soil texture classes
% S40_100.438 - 40-100cm fractional distribution of 16 soil texture classes


% for now uses mean value from 0->150cm
filename          = 'data/S0_150DM.438';
soil_data         = load(filename);
% USGS_basin_ID     = soil_data(:,1); 
soil_mean_class   = soil_data(:,2);
soil_data         = 0.;
 

% Vegetation type:
% _____________________________________________________
%      1      Evergreen Needleleaf Forest
%      2      Evergreen Broadleaf Forest
%      3      Deciduous Needleleaf Forest
%      4      Deciduous Broadleaf Forest
%      5      Mixed Forest
%      6      Closed Shrublands
%      7      Open Shrublands
%      8      Woody Savannah
%      9      Savannahs
%     10      Grasslands
%     11      Permanent Wetlands
%     12      Croplands
%     13      Urban and Built-Up
%     14      Cropland / Natural Vegetation Mosaic
%     15      Snow and Ice
%     16      Barren or Sparsely Vegetated
%     17      Water Bodies
% _____________________________________________________

filename          = 'data/IGBPTABP.438';
veg_data          = load(filename);
% USGS_basin_ID     = veg_data(:,1); 
veg_class_fraction= veg_data(:,2:end);
veg_data         = 0.;

% university of Maryland classification:
filename          = 'data/UMDTABP.438';
veg_data          = load(filename);
% USGS_basin_ID     = veg_data(:,1); 
veg_class_fraction_UMD= veg_data(:,2:end);
veg_data         = 0.;


%Setup variables for data storage
Nb_Basins_Humid = length(find(P_mean_Ep_mean > 1));
Nb_Basins       = length(USGS_basin_ID);
DailyData_Humid_Indices = [];
Precip_6hr_data = cell(Nb_Basins,2);
Precip_1hr_data = cell(Nb_Basins,2);
DailyData       = cell(Nb_Basins,5);
Precip_monthly_data= cell(Nb_Basins,3);
monthly_data   = cell(Nb_Basins,4);





%%%% LOOP ON ALL BASINS %%%%%
for i = 1:Nb_Basins
    ['basin number ' num2str(i) ' out of ' num2str(Nb_Basins)]
    basin_index     =  num2str(USGS_basin_ID(i));
    if(length(basin_index)==7)%add first 0 -> has to be 8 char wide
        basin_index = ['0' basin_index];
    end    
     
    % check if data are fine:
    k_loop      =   1; 
    end_loop    =   0; 
    index_basin_ceil = [];
    while(k_loop<length(USGS_basin_ID_ceil) && ~end_loop)
        if(str2num(USGS_basin_ID_ceil{k_loop})==USGS_basin_ID(i))
            index_basin_ceil = k_loop;
            end_loop         = 1;
        end
        k_loop = k_loop + 1;
    end
    
    
    if(~isempty(index_basin_ceil)) % if good data
    
      
    
    
    %%%%%%%%%%%%%%%%%% DAILY DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        % daily ETp and P over basin:

    %      2: mean areal precipitation (mm)
    %      3: climatic potential evaporation (mm)
    %        (based NOAA Freewater Evaporation Atlas)
    %      4: daily streamflow discharge (mm)
    %      5: daily maximum air temperature (Celsius)
    %      6: daily minimum air temperature (Celsius)
 
        base_file_name  = 'data/Us_438_Daily/';
        filename        = [base_file_name basin_index '.dly'];
        fid             = fopen(filename);
        data = fscanf(fid, '%4f %2f %2f %f %f %f %f %f\n',[8 inf]);
        fclose(fid);
        % correct bad reading -? Mopex files are just a mess!!!!
        FirstDateVec    =  [data(1,1) 1 1];
        EndDateVec      =  [data(1,end) 12 31];
        FirstDateNum    =  datenum(FirstDateVec);
        EndDateNum      =  datenum(EndDateVec);
        DatesNum        =  FirstDateNum:EndDateNum;
        DatesVec        =  datevec(DatesNum);

        % correct dates into data:
        data(1,:)       = DatesVec(:,1)';
        data(2,:)       = DatesVec(:,2)';
        data(3,:)       = DatesVec(:,3)';
        
        
        NbOriginalPoints = length(data(1,:));
        % remove bad points:
        index_wrong = find(data(4,:)<0 | data(6,:)<0); %Q<0 or P<0
        index_wrong_begin = unique([index_wrong(1) index_wrong(find(index_wrong(2:end)-index_wrong(1:end-1)>1)+1)]);
        index_wrong_end = unique([index_wrong(find(index_wrong(2:end)-index_wrong(1:end-1)>1)) index_wrong(end)]);
        if(~isempty(index_wrong))
           index_wrong_years = [];        
           for j=1:length(index_wrong_begin)  % remove entire bad years
               index_wrong_years   =  [index_wrong_years data(1,index_wrong_begin(j)):data(1,index_wrong_end(j))]; % wrong years
           end
           
           index_wrong = zeros(size(data(1,:)));
           for j=1:length(index_wrong_years)
                ind = (find(data(1,:) == index_wrong_years(j)));
                index_wrong(ind) = 1;
           end  
           index_right = ~index_wrong;
        else
           index_right = 1:NbOriginalPoints;
        end
         
        
        real_index = find(index_right>0);
        if(data(2,real_index(end))~=12 && data(3,real_index(end))~=31) % if not ending at end of year take previous year
            end_index = ( find(data(1,:)==(data(1,real_index(end))-1)) && find(data(2,:)==12) && find(data(3,:)==31)  );
            index_right(end_index+1:end)=0;
        end
        if(data(2,real_index(1))~=1 && data(3,real_index(1))~=1) % if not starting at year beginning take next year
            start_index = ( find(data(1,:)==(data(1,index_right(1))+1)) && find(data(2,:)==1) && find(data(3,:)==1)  );
            index_right(1:start_index)=0;
        end
         
        % only takes good points
        data           = data(:,index_right);
        DailyData{i,1} = data(1,:);
        DailyData{i,2} = data(2,:);
        DailyData{i,3} = data(3,:);
        DailyData{i,4} = data(4,:);
        DailyData{i,5} = data(5,:);
        DailyData{i,6} = data(6,:);
        DailyData{i,7} = data(7,:);
        DailyData{i,8} = data(8,:);
        
        if (P_mean_Ep_mean(i) > 1)
            DailyData_Humid_Indices = [DailyData_Humid_Indices i];
        end
        
        

   %     years_indices = unique(data(1,:));
   %     index = 1;
   %     for year_index = years_indices
   %         for month_index=1:12
   %             indices_month            = find(data(1,:)==year_index & data(2,:)==month_index);
   %             monthly_data{i,1}(index) = year_index;% year
   %             monthly_data{i,2}(index) = month_index;% month
   %             monthly_data{i,3}(index) = sum(data(4,indices_month));% precip
   %             monthly_data{i,4}(index) = sum(data(5,indices_month));% Ep
   %             monthly_data{i,5}(index) = sum(data(6,indices_month));% Q
   %             index = index+1;
   %         end
   %     end




         %Now resample to have same strarting and ending dates:
    %     base_year_beg = max(monthly_data{i,1}(1),Precip_monthly_data{i,1}(1));
    %     base_year_end = min(monthly_data{i,1}(end),Precip_monthly_data{i,1}(end));
    %     indices       = 1+12*(base_year_beg-monthly_data{i,1}(1)):12+12*(base_year_end-monthly_data{i,1}(1));
    %     indices_precip= 1+12*(base_year_beg-Precip_monthly_data{i,1}(1)):12+12*(base_year_end-Precip_monthly_data{i,1}(1));
         %truncate data
    %     monthly_data{i,1} = monthly_data{i,1}(indices);
    %     monthly_data{i,2} = monthly_data{i,2}(indices);
    %     monthly_data{i,3} = monthly_data{i,3}(indices);
    %     monthly_data{i,4} = monthly_data{i,4}(indices);
    %     monthly_data{i,5} = Precip_monthly_data{i,3}(indices_precip);


    % 
    %     % 6-hourly data:
    %     figure(10)
    %     plot(Precip_6hr_data{i,1},Precip_6hr_data{i,2});
    %     xlabel('Days (abolute)','Interpreter','LaTex','FontSize',14, 'Color',[0 0 0])
    %     ylabel('Precipitation (mm/6hr)','Interpreter','LaTex','FontSize',14, 'Color',[0 0 0] )
    % 
    %     % daily data:
    %     figure(11)
    %     subplot(3,1,1)
    %     plot(DailyData{i,1},DailyData{i,2});
    %     xlabel('Days (abolute)','Interpreter','LaTex','FontSize',14, 'Color',[0 0 0])
    %     ylabel('Precipitation (mm/day)','Interpreter','LaTex','FontSize',14, 'Color',[0 0 0] )
    %     subplot(3,1,2)
    %     plot(DailyData{i,1},DailyData{i,3});
    %     xlabel('Days (abolute)','Interpreter','LaTex','FontSize',14, 'Color',[0 0 0])
    %     ylabel('$E_p$ (mm)','Interpreter','LaTex','FontSize',14, 'Color',[0 0 0] )
    %     subplot(3,1,3)
    %     plot(DailyData{i,1},DailyData{i,4});
    %     xlabel('Days (abolute)','Interpreter','LaTex','FontSize',14, 'Color',[0 0 0])
    %     ylabel('Q (mm)','Interpreter','LaTex','FontSize',14, 'Color',[0 0 0] )
    %     ylim([0 max(DailyData{i,4})])
    % 


        % monthly data:
       %  figure(12)
        % plot(months,greeness_fraction(1,:));
       %  xlabel('Month','Interpreter','LaTex','FontSize',14, 'Color',[0 0 0])
       %  ylabel('Greeness index (\%)','Interpreter','LaTex','FontSize',14, 'Color',[0 0 0] )

     %   months = 1:length(monthly_data{i,1});
    % 
      %   figure(13)
      %   hold all;
      %   plot(months,monthly_data{i,3});
      %   plot(months,monthly_data{i,4});
      %   plot(months,monthly_data{i,5});
      %   xlabel('Month','Interpreter','LaTex','FontSize',14, 'Color',[0 0 0])
      %   ylabel('Precip/$E_p$/$Q$','Interpreter','LaTex','FontSize',14, 'Color',[0 0 0] )
      %   legend('P','E_p','Q','FontSize',14)
      %   ylim([0 200])

        % yearly data:
        % based on monthly data:
      %  Mat_sum = zeros(12*length(years_indices),length(years_indices)); 
      %  for ii=1:length(years_indices)
      %     Mat_sum((1:12)+12*(ii-1),ii) = 1; 
      %  end
      %  P_yearly   = monthly_data{i,3}*Mat_sum;
      %  Ep_yearly  = monthly_data{i,4}*Mat_sum;
      %  Q_yearly   = monthly_data{i,5}*Mat_sum;


        % remove wrong values: 
     %  indices_not_wrong = ~( P_yearly<0 | Q_yearly<0);
     %  P_yearly   = P_yearly(indices_not_wrong);
     %   Ep_yearly  = Ep_yearly(indices_not_wrong);
     %   Q_yearly   = Q_yearly(indices_not_wrong);
     
    %     figure(14)
    %     hold all;
     %    plot(years,Ep_yearly,'-k');
     %    plot(years,Q_yearly,'--b');
     %    plot(years,P_yearly,':r');
     %    xlabel('Years','Interpreter','LaTex','FontSize',14, 'Color',[0 0 0])
     %    ylabel('Precip/$E_p$/$Q$','Interpreter','LaTex','FontSize',14, 'Color',[0 0 0] )
     %    legend('Ep','Q','Precip','FontSize',14)
     %    ylim([0 2000])

%         figure(14)
%         hold all;
%         plot(P_yearly,Ep_yearly,'o');
%         plot(P_yearly,Q_yearly,'+');
%         plot(P_yearly,P_yearly,'--k');
%         xlabel('$\overline{P}$','Interpreter','LaTex','FontSize',14, 'Color',[0 0 0])
%         ylabel('$E_p$/$Q$','Interpreter','LaTex','FontSize',14, 'Color',[0 0 0] )
%         legend('Ep','Q','1:1 line','FontSize',14)
%         ylim([0 max(P_yearly)])
% 
     %   figure(15)
     %   hold all;
     %   plot(Ep_yearly./P_yearly,(P_yearly-Q_yearly)./P_yearly,'+','MarkerSize',0.5);
     %   xlabel('$$\phi = \overline{E_p}  / \overline{P}  $$','Interpreter','LaTex','FontSize',14, 'Color',[0 0 0])
     %   ylabel('$$  \overline{ET}   / \overline{P} $$','Interpreter','LaTex','FontSize',14, 'Color',[0 0 0] )
     %   title('All basins Yearly Budyko Curve','FontSize',14)
     %   xlim([0 5])
     %   ylim([0 1.5])
     %   grid on;


    % 
    %     mean(P_yearly)/mean(Ep_yearly)
    %     mean(P_yearly-Q_yearly)/mean(Ep_yearly)
    %     mean(Q_yearly)/mean(P_yearly)

        % compute mean P, Ep, Q and standard deviation:
     %   P_ens_mean(i)  = mean(P_yearly);
     %   Ep_ens_mean(i) = mean(Ep_yearly);
      %  ET_ens_mean(i) = mean(P_yearly-Q_yearly);
       % Q_ens_mean(i)  = mean(Q_yearly);
       % P_ens_sigma(i) = std(P_yearly);
       % Ep_ens_sigma(i)= std(Ep_yearly);
       % ET_ens_sigma(i)= std(P_yearly-Q_yearly);
       % Q_ens_sigma(i) = std(Q_yearly);
       % cov_mat        = cov(P_yearly',Q_yearly');
       % cov_P_Q_ens(i) = cov_mat(1,2);
      
    else
        
        P_ens_mean(i)  = 0;
        Ep_ens_mean(i) = 0;
        ET_ens_mean(i) = 0;
        Q_ens_mean(i)  = 0;
        P_ens_sigma(i) = 0;
        Ep_ens_sigma(i)= 0;
        ET_ens_sigma(i)= 0;
        Q_ens_sigma(i) = 0;
        cov_mat        = 0;
        cov_P_Q_ens(i) = 0;
        
    end
    
end
    