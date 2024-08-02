function plotEstimatedvsRealAll(REAL, PRE1, mark1, PRE2, mark2, ...
                             PRE3, mark3,PRE4, mark4, labelPob, ...
                             lbltitle, lblsubtitle, xlbl, ylbl, ...
                             val, legends)
   figure1 = figure('DefaultAxesFontSize',20);
   figure1.WindowState = 'maximized';
   axes1 = axes('Parent',figure1);
   hold(axes1,'all');
    hold on
     plot(REAL','ok',  MarkerSize=8)
     plot(PRE1',mark1, MarkerSize=8)
     plot(PRE2',mark2, MarkerSize=8)
     plot(PRE3',mark3, MarkerSize=8)
     plot(PRE4',mark4, MarkerSize=8)
     text(1:46,zeros(1,46)-val,labelPob,'VerticalAlignment','middle','HorizontalAlignment','right', 'FontSize', 12, 'rotation',90);
     set(gca,'FontSize',10,'fontweight','bold','XTickLabelRotation',90)
     grid minor
     xlabel(xlbl, 'FontSize', 13),
     ylabel(ylbl, 'FontSize', 13),
     title(lbltitle, 'FontSize', 15),
     subtitle(lblsubtitle);  
     lgd = legend(legends); 
     lgd.FontSize = 12;
     lgd.FontWeight = 'bold';
     hold off
end
