clear all
close all

genpath('matlab_bgl');

load Synchronization_Tmin_90

thetas = 0.1:0.1:1;

Aijs = zeros(length(Qij),length(Qij),length(thetas));
kQ = zeros(1,length(thetas));
kq = kQ;
Aqijs = Aijs;
AQqij = Aijs;
CDj = zeros(length(Qij),length(thetas));
CDqj = zeros(length(Qij),length(thetas));
ccfs = CDj;
bs = CDj;
Ccjs = CDj;

for i = 1:length(thetas)
Aij = zeros(size(Qij));
n = length(Aij);

Aij(Qij>thetas(i)) = 1;
Aijs(:,:,i) = Aij;

kQ(i) = mean(sum(Aij)/n)/2;

Aqij = zeros(size(qij));

thetaq  =0.05;
Aqij(qij>abs(thetaq))=1;
Aqijs(:,:,i) = Aqij;
kq(i) = mean(sum(Aqij)/n)/2;

AQqij(:,:,i) = Aqij*Aij;

% Degree centrality

CDj(:,i) = sum(Aij)/(n-1);
CDqj(:,i) = sum(Aqij)/(n-1);

% Clustering Coefficients

A=sparse(Aij);
ccfs(:,i) = clustering_coefficients(A);

% Betweenness Centrality
bc(:,i) = betweenness_centrality(A);

% Closeness centrality

n = size(Aij,1);
 c = repmat(inf,n,n);
 for k = 1:n
   f = k;
   s = 0;
   while ~isempty(f)
     c(k,f) = s;
     s = s+1;
     f = find(any(Aij(f,:),1)&c(k,:)==inf);
   end
 end
 
 c(isinf(c)) = nan;
 
Ccj = nansum(2.^(-c))-1;
Ccj = Ccj./max(Ccj);

Ccjs(:,i) = Ccj;

end

 
 save Metrics_Iterated_Tmin_90 Aijs Aqijs CDj CDqj Ccj ccfs bc kQ nodes thetas thetaq