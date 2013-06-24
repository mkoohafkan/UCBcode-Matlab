clear all
close all

genpath('matlab_bgl');

load Synchronization_Tmin_90

Aij = zeros(size(Qij));
n = length(Aij);

theta = 0.79;

Aij(Qij>theta) = 1;

kQ = mean(sum(Aij)/n)/2;

Aqij = zeros(size(qij));

thetaq  =0.05;
Aqij(qij>abs(thetaq))=1;

kq = mean(sum(Aqij)/n)/2;

AQqij = Aqij*Aij;

% Degree centrality

CDj = sum(Aij)/(n-1);
CDqj = sum(Aqij)/(n-1);

% Clustering Coefficients

A=sparse(Aij);
ccfs = clustering_coefficients(A);

% Betweenness Centrality
bc = betweenness_centrality(A);

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

[kQ,kq]


 
 save Metrics_Tmin_90 Aij Aqij CDj CDqj Ccj ccfs bc kQ nodes theta thetaq