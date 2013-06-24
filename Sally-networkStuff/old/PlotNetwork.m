clear all
close all

load Metrics_Tmin_90
load Coords



x = Coords(:,1);
y = Coords(:,2);

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
        subplot(2,2,1)
        plot([x1 x2], [y1, y2],'-'); hold on 
        subplot(2,2,2)
        plot([x1 x2], [y1, y2],'-'); hold on 
        subplot(2,2,3)
        plot([x1 x2], [y1, y2],'-'); hold on 
        subplot(2,2,4)
        plot([x1 x2], [y1, y2],'-'); hold on 

    end
    
   
    
end



subplot(2,2,1)
scatter(x,y,25,CDj,'filled'); colorbar
title('Degree Centrality, T_m_i_n')
subplot(2,2,2)
scatter(x,y,25,Ccj,'filled'); colorbar
title('Closeness Coefficient, T_m_i_n')
subplot(2,2,3)
scatter(x,y,25,ccfs,'filled'); colorbar
title('Cluster Coefficient, T_m_i_n')
subplot(2,2,4)
scatter(x,y,25,bc,'filled'); colorbar
title('Betweenness Centrality, T_m_i_n')



