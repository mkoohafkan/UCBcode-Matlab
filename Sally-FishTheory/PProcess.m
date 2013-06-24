function [alpha_p, lambda_p] = PProcess(data)
tP=datenum(data(:,1),data(:,2),data(:,3));
Pmm = data(:,4); 
Pmm(Pmm==-9999)=NaN;
Pmm(Pmm>100)=NaN;

% Divide by water year
a = data(:,1)<2004;
data(a,1)=NaN;
Years = min(data(:,1)):max(data(:,1));

PWY = zeros(length(Years)-1,120);
tPWY = PWY;

alpha = zeros(length(Years)-1,1);
lambda=alpha;
QC = alpha;

for i = 1:length(Years)-1
    a = find(data(:,1)==Years(i) & data(:,2)>=10);
    b = find(data(:,1)==Years(i)+1 & data(:,2)<10);
    P = [Pmm(a); Pmm(b)];
    T = [tP(a); tP(b)];
    PWY(i,1:length(P)) = P';
    tPWY(i,1:length(T))=T';
    
    alpha(i) = nanmean(PWY(PWY>0));
    
    lambda(i) = length(P(P>0))./length(P);
    QC(i) = sum(isnan(P))./length(P);
end

alpha(QC>0.1)=[];
lambda(QC>0.1)=[];

alpha_p = nanmean(alpha);
lambda_p = nanmean(lambda);