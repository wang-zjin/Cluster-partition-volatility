function plotMonteCarlo(returnSeries)
% plot all of the simulation raterns from the Monte Carlo simulation.

percentiles = prctile(returnSeries, [1 5 10]);
hist(returnSeries, 100);
% VaR Ïß
var1 = line([percentiles(1) percentiles(1)], ylim, 'color', 'g', 'linewidth', 2, 'displayname', 'VaR @ 1%');
var2 = line([percentiles(2) percentiles(2)], ylim, 'linestyle', '- -', 'color', 'g', 'linewidth', 2, 'displayname', 'VaR @ 5%');
var3 = line([percentiles(3) percentiles(3)], ylim, 'linestyle', '-.', 'color', 'g', 'linewidth', 2, 'displayname', 'VaR @ 10%');
title('Simulated Returns')
xlabel('Simulated Return')
ylabel('Number of Observed Returns')
legend([var1 var2 var3])