function AxisFormat()
    A=gca;
    set(A.XAxis,'FontName','Helvetica','FontSize',9,'LineWidth',0.75,'Color','k');
    set(A.YAxis,'FontName','Helvetica','FontSize',9,'LineWidth',0.75,'Color','k');
    set(A,'box','off','TickDir','out','TickLength',[0.025 0.025],'FontName','Helvetica','FontSize',15,'FontWeight','Normal')
end