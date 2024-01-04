%% helper script to reproduce correlation data and all figurues 

% SPDX-FileCopyrightText: Copyright (C) 2023 S Shermer <lw1660@gmail.com>, Swansea University
% SPDX-FileCopyrightText: Copyright (C) 2023 Sean P O'Neil <seanonei@usc.edu>, University of Southern California
% 
% SPDX-License-Identifier: CC-BY-SA-4.0


clear all; close all; clc;

epsilon = 0.01;     % set maximum fidelity error
step_choice = 1;    % choice of \delta step size for \delta_bar search 
                    % 1 - 10^-3
                    % 2 - 10^-4
                    % 3 - 10^-5
                    % 4 - 10^-6
                    % 5 - 10^-7 
                    % 6 - 10^-8
                    % 7 - 10^-9

analyze_robustness_b4(step_choice)
disp(' ');
analyze_error_vs_b4(step_choice)
disp(' ');
analyze_error_vs_log_sensitivity(step_choice)
disp(' ');
performance_plot(step_choice,epsilon)
disp(' ');
sensitivity_plot(step_choice)
disp(' ');
scatter_plot_b4_v_error(step_choice)
disp(' ');
plot_log_sensitivity(step_choice)
disp(' ');
b4_scatter_by_problem(step_choice)

