function produceFig(y,Time,YLABEL)

figure;
plot(datenum(Time), y, 'k');
xlim([Time(1),Time(end)])
xlabel('Year')
ylabel(YLABEL)
dateaxis('x' , 12)