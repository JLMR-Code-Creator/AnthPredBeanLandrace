function plotEstimatedvsReal(REAL, PRE1,mark, PRE2, labelPob, lbltitle, lblsubtitle, xlbl, ylbl, val, legends)
   figure1 = figure('DefaultAxesFontSize',20);
   figure1.WindowState = 'maximized';
   axes1 = axes('Parent',figure1);
   hold(axes1,'all');
    hold on
     plot(REAL','ok', MarkerSize=10)
     plot(PRE1',mark, MarkerSize=8)
     %plot(PRE2','pk', MarkerSize=8)
     text(1:46,zeros(1,46)-val,labelPob,'VerticalAlignment','middle','HorizontalAlignment','right', 'FontSize', 12, 'rotation',90);
     set(gca,'FontSize',10,'fontweight','bold','XTickLabelRotation',90)
     grid minor
     xlabel(xlbl, 'FontSize', 13),
     ylabel(ylbl, 'FontSize', 13),
     title(lbltitle, 'FontSize', 15),
     subtitle(lblsubtitle);  
     lgd = legend(legends); %, ...
%                  'AnthEstNet with PMF', '', '', '' );         
%                  'ANN(28:3:1) with PCA of PMF', '', '', '', ...
%                  'AnthEstNet with PMF', '', '', '' );

     lgd.FontSize = 12;
     lgd.FontWeight = 'bold';
     hold off
end
