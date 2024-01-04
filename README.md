# Differential Sensitivity Bounds for Dynamic Quantum Control

> SPDX-FileCopyrightText: Copyright (C) 2020-2023 SM Shermer <lw1660@gmail.com>\
> SPDX-FileCopyrightText: Copyright (C) 2023 Sean Patrick O'Neil <seanonei@usc.edu>\
> SPDX-License-Identifier: CC-BY-SA-4.0

The implementation of quantum gates for multiple qubits using time-domain dynamic control, usually implemented in the form of piecewise constant control fields, is a core problem in quantum control.  The differential sensitivity is a measure of robustness and can be used to derive performance bounds in particular for systems subject to model uncertainty that can be described by structured perturbations. This data set contains the results for differential sensitivity bounds for a set of dynamic gate control problems and the code to generate such results.

It had been originally computed for

[1] SP O'Neil, CA. Weidner, EA Jonckheere, FC Langbein, SG Schirmer (Shermer), **Robustness of Dynamic Quantum Control: Differential Sensitivity Bounds** [[arXiv: 2401.00301]](https://doi.org/10.48550/arXiv.2401.00301)

based on theoretical results in

[2] SP O'Neil, E Jonckheere, S Schirmer, **Sensitivity Bounds for Quantum Control and Time-Domain Performance Guarantees**
[[arXiv: 2310.17094]](https://arxiv.org/abs/2310.17094)

This repository is developed on [qyber/black](https://qyber.black/) at [https://qyber.black/spinnet/code-differential-sensitivity-bounds-for-dynamic-control](https://qyber.black/spinnet/code-differential-sensitivity-bounds-for-dynamic-control).

## Versions

**Version 1.0.0**: initial release for the paper

## Notation

The files and figures in this project use the following notation:
```
problem# - problem identifier; # ranges from 1 to 9 for original problems included in data set
tf# - gate operation time for problem
K# - number of control pulses for problem
step-size - size of increment for perturbation in search for delta_bar; ranges from 10-3 (for 0.001) through 10-9 (for 10^{-9})
algorithm - optmization routine used in controller synthesis; either "quasi-newton" or "trust-region"
```

## Folder Hierarchy and Data Description

The data, results, and figures are saved in the following heirarchy:   
- `/controllers` - All controller data for each `problem-tf-K-algorithm` combination is saved as a `.csv` file in this folder under the file name `problem#_tf#_K#_algorithm.csv`. This directory must be saved directly subordinate to the root directory before execution of the analysis routines. Each row of the `.csv` spreadsheet provides the data for given controller in the following columns ($M$ denotes the number of interaction Hamiltonians for the problem): 
  | Column Start | Column Stop | Data                                                                                                |
  | ------------ | ----------- | --------------------------------------------------------------------------------------------------- |
  | $1$          | $1$         | `problem#`                                                                                        |
  | $2$          | $2$         | `algorithm`                                                                                       |
  | $3$          | $3$         | `tf#`                                                                                             |
  | $4$          | $4$         | `K#`                                                                                              |
  | $5$          | $5$         | nominal fidelity error                                                                              |
  | $6$          | $MK + 5$    | row array of control pulse magnitudes - reshaped as an $M \times K$ array for execution of analysis |
- `/problems` - data for each problem is saved as a `.mat` file in this folder with the name `problem#.mat.` This directroy must be imported from this repository and saved directly subordinate to the root directory before execution of the analysis routines. Each`.mat` file contains the following data:
    ```
    H  - structure of Hamiltonian matrices
         H{1} is the drift Hamiltonian.
         The remaining M matrices are the interaction Hamiltonians.
    dH - structure of perturbation matrices - normalized to 1 in the Frobenius norm 
    N  - number of qubits in the problem 
    UT - target unitary for the gate operation problem 
    ```
  The nine problems included are the problems used in [1] and [2], however the user may create additional problems by defining different `H` and `dH` structures along with alternate target gates. However, for proper operation of the anaysis routines, the `dH` matrices must be normalized in the Frobenius norm.  
- `/results/algorithm` - the post-analysis data is saved as a `.csv` file in this directory with the file name `problem#_tf#_K#_step-size_algorithm.csv`. The directories are set up automatically upon execution of the analysis routines. The data is arranged by row per controller with the columns arranged in the same manner as the `.csv` files in the `/controllers` directory with the following columns appended ($M_2$ indicates the number of perturbation structures used for the problem):
  | Column Start  | Columns Stop   | Data                                                                                           |
  | ------------- | -------------- | ---------------------------------------------------------------------------------------------- |
  | $MK+6$        | $MK+6$         | Static Uncertainty Bound: $\mathbf{B_{su}}$                                                    |
  | $MK+7$        | $MK +7$        | Variable Uncertaitny Bound: $\mathbf{B_{vu}}$                                                  |
  | $MK +8$       | $MK + M_2 +7$  | Array of differential sensitivity to each perturbation structure: $\zeta_\mu$                  |
  | $MK +M_2 +8$  | $MK + M_2 +8$  | Minimum perturbation causing the fidelity error to exceed $\epsilon$ threhold: $\bar{\delta}$  |
  | $MK +M_2 +9$  | $MK + 2M_2 +8$ | Fidelity error evaluted at $\bar{\delta}$ for each static uncertainty structure $\mu$          |
  | $MK + 2M_2+9$ | $MK + 2M_2 +9$ | Fidelity error evaluated at $\bar{\delta}$ for worst-case variable uncertainty structure       |
- `/results/correlation_data/algorithm` - the post-analysis data showing the correlation between various metrics are saved as `.csv` files in this directory. The directory is created upon execution of the analysis routines. The following files are included:
  1. `b4_vs_delta_algorithm-{Kendall,Pearson}.csv` - table of the Kendall $\tau$ and Pearson $r$ for correlation between $\mathbf{B_{vu}}$ and $\bar{\delta}$ 
  2. `err_vs_b4_algorithm-{Kendall,Pearson}.csv` - table of the Kendall $\tau$ and Pearson $r$ for correlation between $\mathbf{B_{vu}}$ and the nominal fidelity error 
  3. `log-sens_data_algorithm-{Kendall,Pearson}.csv` - table of the Kendall $\tau$ and Pearson $r$ for correlation between the nominal fidelity error and norm of the log-sensitivity 
- `/figures/algorithm` - the post-analysis visualization plots are saved in the following subdirectories which are created upon execution of the analysis routines:
  | Sub-directory             | Plot Description                                                                                                                                                                                                                                                           |
  | ------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
  | `/sensitivity`          | Files saved as `sensitivity_bounds_problem#_tf#_K#_algorithm.fig` and displays plot of $\mathbf{B_{vu}}$, $\mathbf{B_{su}}$, and $\zeta_\mu$ versus controller index.                                                                                                  |
  | `/performance`          | Files saved as `performance_problem#_tf#_K#_step-size_algorithm.fig` and plots fidelity error evaluted at $\bar{\delta}$ for each static uncertainty direction $\mu$ and the worst-case variable uncertainty structure.                                                 |
  | `/log_sens`             | Files saved as `log_sens_prob#_tf#_K#_algorithm.fig` and shows plot of the norm of the log-sensitivity and $\mathbf{B_{vu}}$ versus controller index.                                                                                                                     |
  | `/scatter`              | Files saved as `scatter_B4_v_error_prob#_tf#_K#_algorithm_type.fig` where `type` is either `linear`, `semilog`, or `log-log` and indicates the scale of the plot. Each plot displays $\mathbf{B_{vu}}$ versus the nominal fidelity error.                          |
  | `/condolidated_scatter` | Files saved as `scatter_prob#_algorithm_loglog.fig` and depicts $\mathbf{B_{vu}}$ versus fidelity error for all `tf` and `K` combinations in the problem. This directory also includes combinations of several different problems as indicated in the `prob#` field. |

## Analysis Routines

The following analysis routines are designed to be run from the root directory: 

| Routine                     | Description                                                                                                                                                                                                                                                                                                                                                                                              |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `calc_all_script.m`       | This script executes the anlysis for all `problem-tf-K-algorithm` combinations in the `/controllers` directory and saves the output as a `.csv` file in the `/results/algorithm` directory as described above. It automically calls the routines in the table below.                                                                                                                              |
| `calc_sens_bounds.m`      | This script is called by `calc_all_script.m` and computes $\zeta_\mu$, $\mathbf{B_{vu}}$, and $\mathbf{B_{su}}$ for each `problem-tf-K-algorithm` combination. The script calls on `calc_sens_loop.m` to do the computation for each controller. The data is saved in the `/results/temp` directory for use by `find_delta_bar.m.`                                                           |
| `calc_sens_loop.m`        | This script is called by `calc_sens_bounds.m` and computes $\zeta_\mu$, $\mathbf{B_{vu}}$, and $\mathbf{B_{su}}$ for each controller within a given `problem-tf-K-algorithm` combination.                                                                                                                                                                                                          |
| `find_delta_bar.m`        | This script is called by `calc_all_script.m` and computes $\bar{\delta}$ as well as the fidelity error evaluted at $\bar{\delta}$ for each static uncertainty structure $\mu$ . The routine calls on `calc_performance_loop.m` for computation of the data for each controller in the given `problem-tf-K-algorithm` combination. The output is saved in `/results/algorithm` as described above. |
| `calc_performance_loop.m` | This script is called by `find_delta_bar.m` and computes $\bar{\delta}$ and the fidelity error for each static uncertainty structure $\mu$ at $\bar{\delta}$ for each controller in the given `problem-tf-K-algorithm` combintation.                                                                                                                                                                 |
| `dexpma.m`                | This function is called by `calc_sens_loop.m` and`calc_performance_loop.m` to compute the matrix exponetial and derivative of the matrix exponential to the given perturbation.                                                                                                                                                                                                                       |

## Plot and Correlation Routines

The following plot and correlation routines are designed to be run from the root directory following completion of the analysis routines described the previous section:

| Routine                                | Description                                                                                                                                                                                                                                                                  |
| -------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `plot_all_script.m`                  | Following completion of the analysis routines, this script is run to call each of the routines below to produce the visualization and correlation data.                                                                                                                      |
| `analyze_robustness_b4.m`            | Computes table of the Kendall $\tau$ and Pearson $r$ for correlation between $\mathbf{B_{vu}}$  and $\bar{\delta}$  and saves the result in `/results\correlation_data/algorithm` as `b4_vs_delta_algorithm-{Kendall,Pearson}.csv`.                                      |
| `analyze_error_vs_b4.m`              | Computes table of the Kendall $\tau$ and Pearson $r$ for correlation between $\mathbf{B_{vu}}$ and fidelity error and saves as the result in `/results/correlation_data/algorithm` as `err_vs_b4_algorithm-{Kendall,Pearson}.csv`.                                       |
| `analyze_error_vs_log_sensitivity.m` | Computes table of the Kendall $\tau$ and Pearson $r$ for correlation between norm of the log-sensitivity and fidelity error and saves as the result in `/results/correlation_data/algorithm` as `log-sens_data_algorithm-{Kendall,Pearson}.csv`.                         |
| `performance_plot.m`                 | Plots fidelity error evaluated at $\bar{\delta}$ for each static uncertainty direction $\mu$ and the worst-case variable uncertainty structure and saves plot as `performance_problem#_tf#_K#_step-size_algorithm.fig` in the `/figures/algorithm/performance` directory. |
| `sensitivity_plot.m`                 | Plots $\mathbf{B_{vu}}$, $\mathbf{B_{su}}$, and $\zeta_\mu$ versus controller index and saves result in the `/figures/algorithm/sensitivity` directory as `sensitivity_bounds_problem#_tf#_K#_algorithm.fig`.                                                          |
| `plot_log_sensitivity.m`             | Plots norm of the log-sensitivity and $\mathbf{B_{vu}}$ versus controller index and saves the result in the `/figures/algorithm/log_sens` directory as `log_sens_prob#_tf#_K#_algorithm.fig`.                                                                            |
| `scatter_plot_b4_vs_error.m`         | Plots $\mathbf{B_{vu}}$ versus the nominal fidelity error. Files are saved in the `/figures/algorithm/scatter` directory under the filename `scatter_B4_v_error_prob#_tf#_K#_algorithm_type.fig`.                                                                       |
| `b4_scatter_by_problem.m`            | Plots $\mathbf{B_{vu}}$ versus fidelity error for all `tf` and `K` combinations in the problem and saves in the `/figures/algorithm/consolidated_scatter` directory under `scatter_prob#_algorithm.fig.`                                                             |
