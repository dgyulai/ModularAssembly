# ModularAssembly
This repository inlcudes the models for "Capacity management of modular assembly systems", and also the results of experiments. The method, models and results are published in a [journal paper](https://www.sciencedirect.com/science/article/pii/S0278612517300213) and in the PhD thesis "Production and and capacity planning methods for flexible and reconfigurale assembly systems" by Dávid Gyulai, MTA SZTAKI.

The folllowing description provides information about the benchmark test performed in the PhD thesis: Capacity planning of modular assembly systems, written by Dávid Gyulai, MTA SZTAKI. The benchmark is performed by using several production planning and system configuration scenarios, including random parameters as well. Even though some parameters are random, their generation is described below, moreover, they do not affect the general trends of the results, as several scenarios are generated, and all methods are performed on the same scenarios. Conclusively, the benchmark is considered as a representative comparison of the different methods analyzed in the thesis.

## Requirements
In order to execute the experiments, two kinds of SW tools are needed:
* A solver engine that is capable of dealing with mixed integer linear programs (MILP). The provided mathematical models are implemented in [FICO Xpress®](http://www.fico.com/en/products/fico-xpress-optimization) commercial optimization suite, applying its Mosel language.
  * `benchmark_main.mos`
  * `benchmark_assignment_greedy.mos` 
  * `benchmark_assignment_lookahead_v2.mos`
  * `benchmark_assignment_rollinghorizon.mos`
  * `benchmark_planning_v3.mos`
* An application to fit the regression models on the result of virtual planning scenarios. The data analytics models are implemented in open-source R language.
  * `cost_regression9.R`
* MS Excel to open the workbooks inlcuding the input data and results
  * `benchmarkInput.xls` (note that the file includes a Visual Basic macro)
  * `ModularResults.xlsx`
* C#.NET to run the benchmark aplication that generates orders by running the VB macro, and executes the models sequentially
  * `BenchmarkApp.cs` (requires Xpress' Mosel and Microsoft's Excel references)

Take into consideration that the execution of the models involves the generation of output files to export the data and establish the file link between the applications.

## [benchmarkInput.xls](benchmarkInput.xls)
The `benchmarkInput.xls` file includes all the input needed to run the experiments presented in the benchmark section of the thesis.

The first sheet "Products" includes all the static data corresponding to the products and their modularized assembly lines. Column "A" includes the name of different products P1-P67. The columns WS1-WS8 provide the number of moules from each type, needed to assemble a given product type. The "SetupTime" is the setup time [min] when switching from one product type to another, independently of the system type. The "ProcTime" is the total amount of manual processing times expressed in minutes. The "Reconfiguration" provides in formation about the reconfiguration time in minutes.

The second sheet "Resources" provide information about the reatio of prices of different module types, independently of the system type ("REC", "DED", "FLX").

The worksheets "SimulationScenarios" and "Orders" are strongly interdependent, and they are used for the generation of random production orders for the different scenarios. In "SimulationScenarios", the aggragate volumes of products can be controlled by defining the general volume trend (the bigger the value, the bigger the change in the volume over the horizon), and overwriting the parameters of general trends defined in rows "75:85". These trends define multiplier values that are perutrbated with random number to simulate different product lifecycle curves. Columns "W:AK" provide information about the overall work contents in the different period, also represented by a line chart. This information helps one to see the fluctuation of capacity requirements over the horizon. The worksheet "Orders" is reponsible for random order generation applying the cumulative numbers defined on "SimulationScenarios". The "Create orders" button executes the "OrderCreation" VB macro performing the random order generation and the file export to .dat format. The random parameters can be controlled by adjusting the average number of orders in column "NumOrders" and the average batch sizes in column "AvgOrderVol". Other random parameter control are found inside the VB macro, e.g. the deviation from the previously mentioned average values. Please note that the file path inside the macro need to be overwritten! The orders in a .dat format will be generated to the folder with the designated path in the macro, and the workbook is udated automatically afterwards.

## [cost_regression9.R](cost_regression9.R)
The R file `cost_regression9.R` fits regression models to predict the costs incur in different systems, applying the results of virtual scenarios stored in files planningRegression_(1,2,3).dat. New scenarios can be added, or the existing ones can be replaced by modifying the R script. The R script exports the coefficients of each model to .dat files in the working folder.

## [ModularResults.xlsx](ModularResults.xlsx)
The Excel file `ModularResults.xlsx` contains the results of experiments obtained by solving the strategic level system configuration model. As presented in the thesis, 15 different test cases were generated by applying the BenchmarkInput.xls file for each of the four scenarios (DIV_NORM, DIV_VOL, BAL_NORM, BAL_VOL). 

The results of each scenario are presented on separated woksheets in the file. The columns of these sheets are the followings:

- Run: the number of the test case out of the 15 different ones,
- Method: the applied solution method for the benchmark, including LO(1), RO(2), CR(3) and IR(4). In case of CR and IR, six-six different setting were analysed as presented in the thesis.
- In columns D-I, prefixes "REC","DED" and "FLX" indicate the system types reconfigurable, dedicated, and flexible, respectively. The suffixes "VOL" and "INV" defines the volume and investment costs, respectively. In this way, the volume and investment related costs for each system and scenario can be compared.
- SpaceReq: it defines the total space requirement costs of the complete system, considering the space multiplier factors of the different module types.
- Changes: it defines the costs of change, incur by the reassignment of the products between system types.
- Objective: this is the objective function value, representing the total costs incur over the horizon.
- Columns M:O define the percentage values of space, change and objective function values of the "Run"-s considering on test case.
- Overall column define the average percantage value of the previous three columns.

The "Summary" sheet provide the overall results of the experiments by calculating the parameters of two boxplots as presented in the thesis. The first plot (blue) presents the results considering the average vales of costs, changes and space requirements. In the second plot, the objective function values are presented.


##  [BenchmarkApp.cs](/BenchmarkApp.cs)
This C# application is prepared to execute all scenarios of the benchmark, by executing the order generator VB macro in `benchmarkInput.xls` and running the main Xpress model called `benchmark_main.mos` that executes the Xpress submodely one after another. Please note that commercial Xpress references need to be added to use the applciation.

## [/dat folder](/dat)
The folder `dat` includes the I/O files required and generated by the different models, such as order, regression coefficients or the results of virtual scenarios.

## [/Xpress_models folder](/Xpress_models)
This folder includes the implementations of the mathematical models of the method in FICO Xpress.
 * [`benchmark_main.mos`](/Xpress_models/benchmark_main.mos): The main model for running the benchmark, it is also executed by the `BenchmarkApp.cs`. This models runs on-by-one the "greedy", "lookahead" and "rolling" models to solve the strategic system configuration applying the forecast order volumes. Then, the production planning model `benchmark_planning_v3.mos` is executed as a simulation of planning the real orders on the tactical level (simply, the realization of the strategic plan on a tactical level).
 * [`benchmark_assignment_greedy.mos`](/Xpress_models/benchmark_assignment_greedy.mos): This models simulates the so-called greedy system configuration, which is a the rule based method with different thresholds (IR and CR methods).
 * [`benchmark_assignment_lookahead_v2.mos`](/Xpress_models/benchmark_assignment_lookahead_v2.mos): This models implements the system configuration optimization with the lookahead setting (LO method).
 * [`benchmark_assignment_rollinghorizon.mos`](/Xpress_models/benchmark_assignment_rollinghorizon.mos): This model implements the system configuration optimization on a rliing horizon basis (RO method).
 * [`benchmark_planning_v3.mos`](/Xpress_models/benchmark_planning_v3.mos): This model implements the tactical level production planning, simulating the execution of the strategic level plan on a tectical levele, to evaluate and compare the costs. The assignments are considerd to be fix, and determined by the previous models. The global parameters of the model is adjusted by the `benchmark_main.mos` model.
