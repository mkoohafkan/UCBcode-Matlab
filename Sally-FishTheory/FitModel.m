clear all
close all

RainNames = {'BearValleyRain.csv'};
FlowNames = {'WalkerCreek.csv'};
A = 31.1*2.59*((1000*100)^2);       % In cm^2
Qt = 1.4353e+10;               % In cm^3/day
Qtw = 1*10^11;                 % In cm^3/day

ET = 0.2;                       % cm/day

% Mike -- we can get these from the STATSGO database or Web Soil Survey.  I
% would just pull %clay (which we can use to estiamte s1 and sw), soil
% depth for the catchment and the porosity.

phi = 0.55;                     % porosity
Zr = 50;                        % root zone depth == soil depth cm
s1 = 0.4;                       % Satiation point
sw = 0.24;                      % Wilting point


for n = 1:length(RainNames);
    
    data_p = importdata(RainNames{n});
    [alpha_p, lambda_p] = PProcess(data_p);             % cm and days
    
    data_q=importdata(FlowNames{n});
    [Qm, pQm, dQm, k, mu, sigma]=QProcess(data_q, Qtw(n));                 % m3/day
    
    % Qm -- flow bin centers
    % pQm -- flow probability density
    % dQm -- bin widths
    % k - recession constant == mean catchment response time
    % mu - mean date of last winter storm (day of year)
    % sigma -- standard deviation of that date (assumes normal distribution of
    % last storm date)
    
    % From catchment properties -- definitions from Botter
    gamp=1/(alpha_p/10);   % cm^-1  (the 10 is because alpha_p is in mm
    gam = gamp*phi(n)*Zr(n)*(s1(n)-sw(n));
    eta = ET(n)./(phi(n)*Zr*(s1(n)-sw(n)));
    lambda = eta * exp(-gam)*gam^(lambda_p/eta)/mathgamma(lambda_p/eta,gam);
    gamQ = gamp/(k*A);  %cm^-1
    
    % Flow PDF
    dQ=0.001*A;
    Q = dQ:dQ:(2.8*A);
    pQ = Q.^(lambda./k-1).*exp(-gamQ.*Q);
    
    cstar = 1/sum(pQ*dQ);
    pQ = cstar*pQ;
    
    % Identify the threshold
    Qthresh=Qt(n)/A;
    Wthresh = Qthresh/k;
    
    % Storage PDF at time of last storm
    W = Q/k;
    dW = dQ/k;
    pW = k*cstar*(W*k).^(lambda./k-1).*exp(-gamQ.*W*k);
    sum(pW.*dW)
    pW = pQ*k;
    
    % Storage PDF including water from last storm
    dR = dW;
    R=dR:dR:dR*length(W);
    dZ = dW;
    pR = (gamQ*k)*exp(-(gamQ*k)*R);
    Z = dZ:dZ:dZ*length(W)*2;
    pZ = exp(-k*Z*gamQ)*k.^(2+lambda/k-(k+lambda)/k)*gamQ;
    sum(pZ.*dZ)
    
    % PDF of buffer time to threshold after last storm
    t = max(0,1./-k*log(Wthresh./Z));
    pt = (pZ).*Qthresh.*exp(k*t);
    to = max(0,1./-k*log(Qthresh./Q));
    pto = (pW).*Qthresh.*exp(k*to);
    
    % PDF of dates at which we reach the threshold
    doy = 0:365;
    pdoy=1/sigma/sqrt(2*pi).*exp(-1/2*((doy-mu)./sigma).^2);
    dt=1;
    
    % Resample pt and pto to a linear support
    pt2 = interp1(t,pt,doy);
    pt2(isnan(pt2))=0;
    pto2 = interp1(to,pto,doy);
    pto2(isnan(pto2))=0;
    
    pdry=conv(pt2,pdoy,'full')*dt;
    pdrystor = conv(pto2,pdoy,'full')*dt;
    
    plotpdfs(A,Q,Qm,W,Z,to,t,pQ,pQm,pW,pZ,pto,pt, pdry, pdrystor)
    
end