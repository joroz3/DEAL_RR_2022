function plotFormat(avlData, fieldx, fieldy, name, xlbl, ylbl, lgnd)


% Create figure
figure1 = figure;
x0 = 1;
y0 = 1;
width  = 6.5;
height = 6.5 ;
set(gcf,'units','inches','position',[x0,y0,width,height])
set(gcf,'color','w');

% Create axes
axes1 = axes('Parent',figure1);

% Create plot
hold on
m = length(avlData);
for i = 1:m
    plot(avlData{i}.(fieldx), avlData{i}.(fieldy),'LineWidth',2);
end
% plot([0, 12], [0, 0], '--r', 'linewidth', 1.5);


set(axes1,'FontName','Times New Roman','FontSize',18);

xlabel(xlbl);
% ylabel(ylbl);
ylabel(ylbl);
% xlim([0 11])
% title(name);
 legend(lgnd, 'Location', 'EastOutside', 'Box', 'Off');

filename = name(name ~= '\');
% saveas(gcf,[filename, '.png'])


