function [Qm, pQm, dQm, K, mu, sigma] = QProcess(data, Qthreshwet)

t = datenum(data(:,1),data(:,2),data(:,3));
Qcfs = data(:,4);
Qm3d = Qcfs * 0.02831684659*3600*24*(100*100*100);        %cm3/day
% QC = data(:,5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Empirical Flow PDF

% Divide by water year
Years = min(data(:,1)):max(data(:,1));

QWY = zeros(length(Years)-1,366);
tWY = QWY;

for i = 2:length(Years)-1
    a = find(data(:,1)==Years(i) & data(:,2)>=10);
    b = find(data(:,1)==Years(i)+1 & data(:,2)<10);
    Q = [Qm3d(a); Qm3d(b)];
    T = [t(a); t(b)];
    QWY(i,1:length(Q)) = Q';
    tWY(i,1:length(T))=T';
end

a = data(:,2)>=10 | data(:,2)<=4; %Winter months

[x,Qm]=hist(Qm3d(a),1000);
pQm = x./sum(x)./(Qm(2)-Qm(1));
plot(Qm,pQm,'o')

dQm =mean(diff(Qm));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimation of recession constant k
% Also need to process to estimate k
% Isolate recession periods
dQdt = zeros(size(Qm3d));
dQdt(2:end-1) = (Qm3d(3:end)-Qm3d(1:end-2))/2;
dQdt(1) = Qm3d(2)-Qm3d(1);
dQdt(end) = Qm3d(end)-Qm3d(end-1);

Q = Qm3d;
Q(dQdt>=0)=NaN;

k=[];
r2=k;

while sum(isnan(Q))<length(Q)
    a=find(~isnan(Q),1,'first');
    Q(1:a-1)=[];
    a = find(isnan(Q),1,'first');
    q = Q(1:a-1);
    Q(1:a-1)=[];

    % Fit an exponential to q if it is long enough
    if length(q)>4;
    p = polyfit(1:length(q),log(q'),1);
    k = [k p(1)];
    r = corrcoef(1:length(q),log(q'));
    r2 = [r2 r(1,2).^2];
    end
    
end

K = nanmean(-k(r2>0.95));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimation of last date of winter storm distribution
% Flow of greater than Qthreshwet?
Qm3dWinter = Qm3d;
Qm3dWinter(Qm3dWinter<Qthreshwet)=NaN;

Years = min(data(:,1)):max(data(:,1));

doy = zeros(1,length(Years));

for i = 2:length(Years)
    a = find(data(:,1)==Years(i) & data(:,2)<=9);
    Q=Qm3d(a);
    b = find(Q>1*10^12,1,'last');
    if ~isempty(b)
    doy(i) = b;
    else
        doy(i)=nan;
    end
end

mu = nanmean(doy);
sigma = nanstd(doy);


% SHOULD ADD SOMETHING HERE TO ESTIMATE GOODNESS OF NORMAL ASSUMPTION