function displayVaR(onePercent, fivePercent, tenPercent, method) 
% Display the Value at Risk as with a percentage and dollar amount.
switch method
    case 'hs'
        methodString = 'Historical Simulation';
    case 'p'
        methodString = 'Parametric';
    case 'mcp'
        methodString = 'Monte Carlo Simulation (portsim)';
    case 'mcg'
        methodString = 'Monte Carlo Simulation (GBM)';
    case 'mcs'
        methodString = 'Monte Carlo Simulation (SDE)';
    case 'mcsep'
        methodString = 'Monte Carlo Simulation (by security)';
end

outString = sprintf('Value at Risk method: %s\n', methodString);
outString = [outString sprintf('Value at Risk 99%% = %.4f \n',roundn(onePercent,-4))];
outString = [outString sprintf('Value at Risk 99%% = %.4f \n',roundn(fivePercent,-4))];
outString = [outString sprintf('Value at Risk 99%% = %.4f \n',roundn(tenPercent,-4))];
disp(outString)

end
    






 