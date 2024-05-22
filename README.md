# Cluster-partition-volatility

```yaml

Author: 'Zijin Wang'

```

Project:

- For a complete process, "exercise_VolForecastRV20220803.mlx" predict volatility of SP500, DAX, FTSE and NIKKIE with normal innovations, estimation window 750, moving window everyday and minimal cluster length 50. Inputs are "XXX_0608.xlsx", results are VolFcst_normal_XXX_size750_20220803.mat and Volatility_forecast_SP500_20220803.xlsx, figures and charts are also in folder "results_VolFcst_normal_XXX_size_750_20220803". 

- Using forecast volatility above, “VaR_SP500_20220805.mlx” produces VaR predict. Inputs are "XXX_0608.xlsx" and "VolFcst_normal_XXX_size750_20220803.mat", outputs are figures and tex in folder "results_XXX_20220805".
