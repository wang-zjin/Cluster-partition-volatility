function simulationResults = visualizeVar(returnsPortfolio, marketValuePortfolio)
% Create a sigle variable and plot with subplots to allow for data
% brushing to select returns and see dollar amount losses.
%
% Copyright 2008 - 2009 The MathWorks, Inc

pricesPortfolopSimulated = returnsPortfolio * marketValuePortfolio;
simulationResults = [pricesPortfolopSimulated returnsPortfolio];

figure;
subplot(2,1,1)
plot(simulationResults(:,1))
title('Simulated Portfolio Returns')
xlabel('Time(days)')
ylabel('Returns')
subplot(2,1,2)
hist(simulationResults(:,2),100)
title('Ditribution of Portfolio Returns')
xlabel('Returns')
ylabel('Number of occurences')

end