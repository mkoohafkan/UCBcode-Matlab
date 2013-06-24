clear all
close all

load MinHourlyTemps

[Y,M,D,H,m]=datevec(t);

a = find(M>=5 & M<=8);
% TminSummer = GradTOut(a,:);
TminSummer= TminOut(a,:);
t = t(a)';

clear TminOut

% Develop thresholds

Tevents = cell(1,39);

% Assume a 90% threshold to start with 
alpha = 0.90;

for i = 1:39;
    Tmin = TminSummer(:,i);
    Ts = [t(~isnan(Tmin)) Tmin(~isnan(Tmin))];
    
    TminD = nan(floor(length(t)/24),2);
    
    for j = 1:floor(length(Ts)/24)
        a = (j-1)*24+1:j*24;
        Tm = nanmin(Ts(a,2));
        b = find(Ts(a,2)==Tm);
        TminD(j,2) = Tm;
        TminD(j,1) = Ts(a(b(end)),1);
    
    end
    
    TminD(isnan(TminD(:,2)),:)=[];
    
    n = length(TminD(~isnan(TminD)));
    nalpha = ceil((1-alpha)*n);
    
    if nalpha>0
    TminD = sortrows(TminD,2);
    
    Tevents{i} = sortrows(TminD(1:nalpha,:),1);      % For the case where we look at abs values, we want maxima not minima
    end
    
end

% This code has generated a cell array for each node with a list of the
% time indices at which the 10% coldest hours occurred.  

% The next step is to cycle through each event and do a pairwise comparison
% with events at all other nodes

Qij = zeros(39,39);
dt = datenum(0,0,0,1,0,0);      % 1 day threshold
eps = 10^-6;
for i = 1:39
    for j = 1:39
        
        if i~=j
            Tsi = Tevents{i};
            Tsj = Tevents{j};

            Jij = zeros(length(Tsi),length(Tsj));
            Jji = zeros(length(Tsi),length(Tsj));
                
            si = length(Tsi);
            sj = length(Tsj);
            
            for k = 1:si
                    for l = 1:sj
                        % The events need to occur on the same day for us
                        % to see them as being synchronized
                        deltaTij = Tsi(k,1) - Tsj(l,1);
                        deltaTji = Tsj(l,1) - Tsi(k,1);
                        
                        if abs(deltaTij) < dt-eps
                            Jij(k,l) = 1/2;
                        elseif abs(abs(deltaTij)-dt)<eps
                            Jij(k,l)=1/2;
                        else Jij(k,l)=0;
                        end
                        
                        if abs(deltaTij) < dt-eps 
                            Jji(k,l) = 1/2;
                        elseif abs(abs(deltaTij)-dt)<eps
                            Jji(k,l)=1/2;
                        else Jji(k,l)=0;
                        end
                        
                    end
            end
            
            cij = sum(sum(Jij));
            cji = sum(sum(Jji));
            
            Qij(i,j) = (cij+cji)/sqrt(si*sj);
            qij(i,j) = (cij-cji)/sqrt(si*sj);
            
        end
    end
end

save Synchronization_Tmin_90 Qij qij nodes alpha Coords


