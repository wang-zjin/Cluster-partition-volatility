# Cluster-partition-volatility

Volatility forecast results are executed by 
"exercise_VolForecastRV20220521.mlx" for normal and 
"exercise_VolForecastRV20220521.mlx" for t distributed innovations respectively. 
The actual volatility is proxied by realised volatility. The forecast time is from November 2021 to May 2022.

"exercise_VolForecastRV_robust_20220522.mlx" and "exercise_VolForecastRV_t_robust_20220522.mlx" are for robustness test.

"exercise_VolForecastRV20220613.mlx" is to forecast volatilities from 2022/01/01 to 2022/05. The competing models are GARCH, GJR-GARCH, RS-GARCH and HAR. HAR performs well and RS-GARCH is terrible.
"exercise_VolForecastRV20220704.mlx" is the improved one for "exercise_VolForecastRV20220613.mlx".
"exercise_VolForecastRV20220707.mlx" uses "parfor" to speed up. 
"exercise_VolForecastRV20220708.mlx" uses a function "vol_forecast" to make codes shorter than "exercise_VolForecastRV20220707.mlx". However, it is slower (maybe due to in different computers)

- "exercise_VolForecastRV20220803.mlx" prredict volatility.
- "exercise_VolForecastRV20220804.mlx" makes codes shorter.
- "exercise_VolForecastRV20220807.mlx" prredict volatility with t innovation.
- "exercise_VolForecastRV20220805.mlx" prredict volatility. Fix bug of "min_length" not in every CPs or CP-Is. Merge normal distribution, t distribution. Add 'Window_Size', 'Cluster_Min_Length' and 'Innovation_Distribution' as extra input.
- "exercise_VolForecastRV20220811.mlx" prredict volatility. Fix bug of "min_length" not in every CPs or CP-Is. Merge normal distribution, t distribution. Add 'Window_Size', 'Cluster_Min_Length' and 'Innovation_Distribution' as extra input.


Folder "Volatility predict 20220719" provides a compact project of forecasting volatility of SP500, DAX, FTSE, NIKKIE using GARCH, GJR, RSGARCH and HAR respectively with training size 750 forecast time from 2019-05-19 to 2022-05-18.

Project:

- For a complete process, "exercise_VolForecastRV20220803.mlx" predict volatility of SP500, DAX, FTSE and NIKKIE with normal innovations, estimation window 750, moving window everyday and minimal cluster length 50. Inputs are "XXX_0608.xlsx", results are VolFcst_normal_XXX_size750_20220803.mat and Volatility_forecast_SP500_20220803.xlsx, figures and charts are also in folder "results_VolFcst_normal_XXX_size_750_20220803". 

- Using forecast volatility above, “VaR_SP500_20220805.mlx” produces VaR predict. Inputs are "XXX_0608.xlsx" and "VolFcst_normal_XXX_size750_20220803.mat", outputs are figures and tex in folder "results_XXX_20220805".
