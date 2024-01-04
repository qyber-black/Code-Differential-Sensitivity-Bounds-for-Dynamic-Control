%% helper script for main analysis routines calc_sens_bounds and find_delta_bar

% SPDX-FileCopyrightText: Copyright (C) 2023 S Shermer <lw1660@gmail.com>, Swansea University
% SPDX-FileCopyrightText: Copyright (C) 2023 Sean P O'Neil <seanonei@usc.edu>, University of Southern California
% 
% SPDX-License-Identifier: CC-BY-SA-4.0


clear all; close all; clc;

% set problem parameters - must be an exiting problem in
% /problems and controller in /controllers  

% set problem data 
%prob           % problem number
%tf             % read-out time 
%K              % time steps 
epsilon = 0.01;     % tolerance on error fidelity
ss = ["10-3","10-4","10-5","10-6","10-7","10-8","10-9"];
step_choice = 1;    % choice of \delta step size for \delta_bar search 
                    % 1 - 10^-3
                    % 2 - 10^-4
                    % 3 - 10^-5
                    % 4 - 10^-6
                    % 5 - 10^-7 
                    % 6 - 10^-8
                    % 7 - 10^-9

                    % initialize parallel pool for cluster processing 
%parpool;

% problem list 
prob_list = [1   1  1   1  1   1   1  1   1   2  2  2  2  3  3  3  3  3  3  4  4   4  4   4  4   5  5  5  5  6  6  6  6  7    7     8  8  8  8  9  9  9  9 ];
tf_list =   [2   2  2   3  3   3   4  4   4   7  7  8  8  12 12 15 15 20 20 12 12  15 15  25 25  7  7  8  8  7  7  8  8  125  150   10 10 15 15 10 10 15 15]; 
K_list =    [40  64 128 40 64  128 40 64  128 40 64 40 64 40 64 40 64 40 64 64 128 64 128 64 128 40 64 40 64 40 64 40 64 1000 1000  32 64 32 64 32 64 32 64];

num = length(prob_list);

parfor k = 1:num
    prob = prob_list(1,k);
    tf = tf_list(1,k);
    K = K_list(1,k);
    algo = 1;
    algorithm = 'quasi-newton'
    tag = sprintf('results/%s/problem%d_tf%d_K%d_%s_%s.csv',algorithm,prob,tf,K,ss(1,step_choice),algorithm);
    if exist(tag,'file') == 2
        disp(sprintf('problem%d_tf%d_K%d_%s_%s complete - skipping',prob,tf,K,ss(1,step_choice),algorithm));
    else
        disp(sprintf('computing problem%d_tf%d_K%d_%s_%s',prob,tf,K,ss(1,step_choice),algorithm));
        calc_sens_bounds(prob,tf,K,algo);
        find_delta_bar(prob,tf,K,step_choice,epsilon,algo);
    end
    algo = 2;
    algorithm = 'trust-region'
    tag = sprintf('results/%s/problem%d_tf%d_K%d_%s_%s.csv',algorithm,prob,tf,K,ss(1,step_choice),algorithm);
        if exist(tag,'file') == 2
        disp(sprintf('problem%d_tf%d_K%d_%s_%s complete - skipping',prob,tf,K,ss(1,step_choice),algorithm));
    else
        disp(sprintf('computing problem%d_tf%d_K%d_%s_%s',prob,tf,K,ss(1,step_choice),algorithm));
        calc_sens_bounds(prob,tf,K,algo);
        find_delta_bar(prob,tf,K,step_choice,epsilon,algo);
    end
end


