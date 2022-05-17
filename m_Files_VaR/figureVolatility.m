function figureVolatility(y,Time,yName)

figure;
plot(Time(1:length(y)), y, 'k')
xlim([Time(1),Time(length(y))])
xlabel('Year')
ylabel(yName)
% str1 = 'Structual Change Volatility with k=';
% str2 = num2str(K);
% title(strcat(str1,str2))
dateaxis('x' , 10)
set(gcf,'Position',[500 500 900 300]);