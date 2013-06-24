clear all
close all

load Metrics_Iterated_Tmin_90
load Coords



x = Coords(:,1);
y = Coords(:,2);
kk=0;
for k = 1:5
Aij = Aijs(:,:,k);
kk = kk+1;
for i = 1:length(Aij)
    n2 = nodes;
    n2(Aij(:,i)==0)=[];
    
    n1 = nodes(i)*ones(1,length(n2));
     
    for j = 1:length(n1);
        x1 = x(i);
        y1 = y(i);
        
        a = find(nodes == n2(j));
        
        x2 = x(a);
        y2 = y(a);
        
        subplot(2,3,kk)
        plot([x1 x2], [y1, y2],'-'); hold on 
      
    end
    
   
    
end
end
kk=0;
for k = 5:9
kk = kk+1;
subplot(2,3,kk)
scatter(x,y,25,CDj(:,k),'filled'); colorbar
text(x,y,num2str(nodes'))
title('Degree Centrality, T_m_a_x')
end

CDjnorm = CDj;
for k = 1:10
CDjnorm(:,k) = CDj(:,k)./max(CDj(:,k));
end

% Clusters

C1 = 43:46;
C2 = 22:30;
C3 = [3:16,19,31,35];
CDj_1 = zeros(length(C1),10);
for i =1:length(C1)
CDj_1(i,:) = CDjnorm(nodes==C1(i),:);
end

CDj_2 = zeros(length(C2),10);
for i =1:length(C2)
CDj_2(i,:) = CDjnorm(nodes==C2(i),:);
end

CDj_3 = zeros(length(C3),10);
for i =1:length(C3)
CDj_3(i,:) = CDjnorm(nodes==C3(i),:);
end

subplot(2,3,6)
plot(thetas,mean(CDj_1),thetas,mean(CDj_2),thetas,mean(CDj_3))