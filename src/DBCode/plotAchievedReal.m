function plotAchievedReal(REAL, PRE1, PRE2, labelPob, lbltitle, lblsubtitle, xlbl, ylbl, val)
   figure1 = figure('DefaultAxesFontSize',20);
   figure1.WindowState = 'maximized';
   axes1 = axes('Parent',figure1);
   hold(axes1,'all');
    hold on
     plot(REAL','ok', MarkerSize=10)
     plot(PRE1','dk', MarkerSize=8)
     plot(PRE2','sk', MarkerSize=8)
     text(1:46,zeros(1,46)-val,labelPob,'VerticalAlignment','middle','HorizontalAlignment','right', 'FontSize', 12, 'rotation',90);
     set(gca,'FontSize',10,'fontweight','bold','XTickLabelRotation',90)
     grid minor
     xlabel(xlbl, 'FontSize', 13),
     ylabel(ylbl, 'FontSize', 13),
     title(lbltitle, 'FontSize', 15),
     subtitle(lblsubtitle);  
     lgd = legend('pH Differential Method',  ...
         'DeepGA CNN with 1 PMF ', ...
         'DeepGA CNN with 3 PMF' );         


     lgd.FontSize = 12;
     lgd.FontWeight = 'bold';
     hold off
end