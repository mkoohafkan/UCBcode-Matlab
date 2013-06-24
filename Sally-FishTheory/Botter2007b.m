ET = 0.25;  % cm/day
n = 0.55;   % []
Zr = 30;    % cm
s1 = 0.6;   % []
sw = 0.18;  % []
gamp=1.1;   % cm^-1  
A=1
k=0.6;  %day^-1
gamQ = gamp/(k*A);  %cm^-1


gam =13.3;
mult = gam./gamp;
% gam2 = gamp*n*Zr*(s1-sw);
eta = ET/mult;

lambdap = 0.30;

lambda = eta * exp(-gam)*gam^(lambdap/eta)/mathgamma(lambdap/eta,gam);
lambda=0.08;
dQ=0.001*A;
Q = dQ:dQ:(2.8*A);

pQ = Q.^(lambda./k-1).*exp(-gamQ.*Q);

pQ = pQ/sum(pQ*dQ);

plot(Q/A,pQ*A)

xlim([0,max(Q/A)])
ylim([0,2.5])