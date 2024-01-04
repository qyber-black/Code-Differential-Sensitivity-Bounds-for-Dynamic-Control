%% calculate differential sensitivity and differential sensitivity bounds

% SPDX-FileCopyrightText: Copyright (C) 2023 S Shermer <lw1660@gmail.com>, Swansea University
% SPDX-FileCopyrightText: Copyright (C) 2023 Sean P O'Neil <seanonei@usc.edu>, University of Southern California
% 
% SPDX-License-Identifier: CC-BY-SA-4.0

% input
%   prob - problem number
%   tf - gate operation time
%   K - number of control pulses 
%   algo - optimization algorithm identifier  

% output 
%   "results" structure saved to "algorithm/results/problem_tf_K"
%   subfields:
%       error - nominal error 
%       sens - differential sensitivity to each perturbation structure 
%       bound2 - norm bound on differential sensitivity for static strucutre
%       bound3 - bound on differential sensitivity for variable structure 
%       direction - uncertainty direction that maximizes "bound"
%       X - cell array of K directions that maximizes "bound2"
%       shouldn't need - Sol - controller data imported from
%       "algorithm/controllers/problem_tf_K"
 
function calc_sens_bounds(prob,tf,K,algo)

switch algo
    case 1, algorithm = 'quasi-newton';
    case 2, algorithm = 'trust-region';
    otherwise algorithm = 'trust-region';
end

if ~exist(append('results/',algorithm),'dir')
    mkdir(append('results/',algorithm));
end

% load problem data 
intag = sprintf('problems/problem%d',prob);
load(intag);

H = problem.H;
dH = problem.dH;
UT = problem.UT;
N = 2^problem.N;

% load controller data 
infile = sprintf('controllers/problem%d_tf%d_K%d_%s.csv',prob,tf,K,algorithm);
C = csvread(infile);
num = size(C);
num = num(1,1);

% set save path
outfile = sprintf('results/%s/problem%d_tf%d_K%d',algorithm,prob,tf,K);

% loop to calcuate differential sensitivity and bounds for each controller 

parfor ind = 1:num     % use parfor for cluster processing 
%for ind = 1:num 
    ind;
    control = C(ind,:);
    out{ind} = calc_sens_loop(ind,H,dH,N,UT,control);
end

for k = 1:num
    error(k,1) = out{k}.err;
    sens(k,:) = out{k}.sens;
    bound2(k,:) = out{k}.bound2;
    bound3(k,:) = out{k}.bound3;
    direction(k,:) = out{k}.direction;
    X{k} = out{k}.X;
end

results.err = error;
results.sens = sens;
results.bound2 = bound2;
results.bound3 = bound3;
results.direction = direction;
results.X = X;
results.C = C;
results.dHindex = out{end}.dHindex;

if ~exist(append('results/temp'),'dir')
    mkdir(append('results/temp'));
end

% set save path
outfile = sprintf('results/temp/problem%d_tf%d_K%d_%s',prob,tf,K,algorithm);

save(outfile,'results');

 

















