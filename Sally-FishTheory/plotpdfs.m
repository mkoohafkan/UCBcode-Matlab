function plotpdfs(A,Q,Qm,W,Z,to,t,pQ,pQm,pW,pZ,pto,pt, pdry, pdrystor)

subplot(4,1,1)
plot(Q/A,pQ*A,Qm/A,pQm*A,'ro','linewidth',2)
xlim([0,3]);
xlabel('Normalized flow, m/day','fontsize',12,'fontweight','b')
ylabel('P(Q), day/m','fontsize',12,'fontweight','b')

subplot(4,1,2)
plot(W/A,pW*A,Z/A,pZ*A,W/A,pW*A,'ro','linewidth',2)
xlim([0,1]);
ylim([0,3]);
legend('Seasonal Storage','Storage post storm')
xlabel('Storage, m','fontsize',12,'fontweight','b')
ylabel('P(W), cm^-^1','fontsize',12,'fontweight','b')

subplot(4,1,3)
plot(to,pto,t,pt,'linewidth',2)
% xlim([0,140]);
legend('Seasonal buffer','Buffer after last storm')
xlabel('Time to threshold, days','fontsize',12,'fontweight','b')
ylabel('P(t^*), days^-^1','fontsize',12,'fontweight','b')

subplot(4,1,4)
plot(1:366,pdry(1:366),1:366,pdrystor(1:366))
legend('Fragmentation date')
xlabel('Day Of Year','fontsize',12,'fontweight','b')
ylabel('P(doy), days^-^1','fontsize',12,'fontweight','b')