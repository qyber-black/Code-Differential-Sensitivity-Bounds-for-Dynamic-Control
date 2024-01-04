%% find minimum \delta that violates performance requirements on fidelity error 

% SPDX-FileCopyrightText: Copyright (C) 2023 S Shermer <lw1660@gmail.com>, Swansea University
% SPDX-FileCopyrightText: Copyright (C) 2023 Sean P O'Neil <seanonei@usc.edu>, University of Southern California
% 
% SPDX-License-Identifier: CC-BY-SA-4.0

function find_delta_bar(prob,tf,K,step_size,epsilon,algo)

% input
%   prob - problem number
%   tf - read-out time
%   K - number of control pulses 
%   algo - optimization algorithm identifier  
%   step_size - index for size choice to increment \delta for \delta_bar search
%   epsilon - tolerance on the fidelity error 

% output
%       error_f - array of fidelity error evaluated at \delta_bar for each
%       principal uncertainty structure and for the maximum sensitivity
%       direction 
%       delta_bar - minimum perturbation that violates the performance threshold  

switch algo
    case 1, algorithm = 'quasi-newton';
    case 2, algorithm = 'trust-region';
    otherwise algorithm = 'trust-region';
end

% set file location for saving results per controller 
if exist(sprintf('results/temp'),'dir') == 0
    mkdir(sprintf('results/temp'));
end

% load problem data 
intag = sprintf('problems/problem%d',prob);
load(intag);


% set tolerance on exceeding fidelity error limit
tol=10^-10;

% set step size for \delta based on "step_size" index 
step_size_vec = [10^-3 10^-4 10^-5 10^-6 10^-7 10^-8 10^-9];
ss = ["10-3","10-4","10-5","10-6","10-7","10-8","10-9"];
delta = step_size_vec(1,step_size);

% load differential sensitivity results
loadtag = sprintf('results/temp/problem%d_tf%d_K%d_%s',prob,tf,K,algorithm);
load(loadtag);

% set save path 
% outfile2 = sprintf('%s/results/problem%d_tf%d_K%d_%s',algorithm,prob,tf,K,ss(1,step_size));

% extract differential sensitivity results data 
results = results;
err = results.err;
num2 = length(err);
C = results.C;

% filter results for controllers with nominal error less than \epsilon 
et = find(err < epsilon);
num = length(et);

% set number of uncertainty structures and number of Hamiltonian matrices 
M2 = length(problem.dH); 
M = length(problem.H);

% loop to compute \delta_bar (minimum perturbation that violates
% performance requirements on fidelity error)
parfor k = 1:num 
%for k = 1:num
    ind = et(k,1);
    tag = sprintf('results/temp/problem%d_tf%d_K%d_%s_%d_%s.mat',prob,tf,K,ss(1,step_size),k,algorithm);
    if exist(tag,'file') ~= 2
%        disp(sprintf('Computing %d',ind));
        control = C(ind,6:end);
        out_data(k,:) = calc_performance_loop(ind,results,delta,epsilon,tol,prob,tf,K,ss(1,step_size),algorithm,control);
    else
%        disp(sprintf('%d results exists - skipping',ind));
    end
end

% consoidate peformance data from "algorithm/results/completed" directory 
% load problem and controller data 
infile = sprintf('controllers/problem%d_tf%d_K%d_%s.csv',prob,tf,K,algorithm);
data = csvread(infile);
%num = size(C);
%num = num(1,1);

x = (M-1)*K+6;
y = x+M2+1;
z = y+2+M2;

for k = 1:num2
     tag = sprintf('results/temp/problem%d_tf%d_K%d_%s_%d_%s.mat',prob,tf,K,ss(1,step_size),k,algorithm);
        if exist(tag,'file') ~= 0
            load(tag);
            data(k,x) = results.bound2(k,1);
            data(k,x+1) = results.bound3(k,1);
            data(k,(x+2):y) = results.sens(k,:);
            data(k,y+1) = out_data(1,1);
            data(k,(y+2):z) = out_data(2:end);
        else
            data(k,x:z) = 0;
        end
end

savetag = sprintf('results/%s/problem%d_tf%d_K%d_%s_%s.csv',algorithm,prob,tf,K,ss(1,step_size),algorithm);
writematrix(data,savetag);

% remove unneeded temporary files 
file_list = sprintf('results/temp/problem%d_tf%d_K%d_%s_*_%s.mat',prob,tf,K,ss(1,step_size),algorithm);
delete(file_list);





















