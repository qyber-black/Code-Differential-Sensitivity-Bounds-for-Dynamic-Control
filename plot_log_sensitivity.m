%% plot log-sensitivity, sensitivity, and fidelity error by controller index

% saves plots in figures/algorithm/log_sens

% SPDX-FileCopyrightText: Copyright (C) 2023 S Shermer <lw1660@gmail.com>, Swansea University
% SPDX-FileCopyrightText: Copyright (C) 2023 Sean P O'Neil <seanonei@usc.edu>, University of Southern California
% 
% SPDX-License-Identifier: CC-BY-SA-4.0

function plot_log_sensitivity(step_size);
close all;
clearvars -except step_size;

for algo = 1:2

switch algo
    case 1, algorithm = 'quasi-newton';
    case 2, algorithm = 'trust-region';
    otherwise algorithm = 'trust-region';
end

ss = ["10-3","10-4","10-5","10-6","10-7","10-8","10-9"];

if exist(sprintf('figures/%s/log_sens',algorithm),'dir') == 0
    mkdir(sprintf('figures/%s/log_sens',algorithm));
end


% problem list 
prob_list = [1   1  1   1  1   1   1  1   1   2  2  2  2  3  3  3  3  3  3  4  4   4  4   4  4   5  5  5  5  6  6  6  6  7    7     8  8  8  8  9  9  9  9 ];
tf_list =   [2   2  2   3  3   3   4  4   4   7  7  8  8  12 12 15 15 20 20 12 12  15 15  25 25  7  7  8  8  7  7  8  8  125  150   10 10 15 15 10 10 15 15]; 
K_list =    [40  64 128 40 64  128 40 64  128 40 64 40 64 40 64 40 64 40 64 64 128 64 128 64 128 40 64 40 64 40 64 40 64 1000 1000  32 64 32 64 32 64 32 64];

l = length(prob_list);

for k = 1:l

row = k;
prob = prob_list(1,k);
tf = tf_list(1,k);
K = K_list(1,k);
probtag = sprintf('problems/problem%d',prob);
load(probtag);
M = length(problem.H) - 1;
M2 = length(problem.dH);

% load data 
loadtag = sprintf('results/%s/problem%d_tf%d_K%d_%s_%s.csv',algorithm,prob,tf,K,ss(1,step_size),algorithm);

if exist(loadtag,'file') == 2

data = readmatrix(loadtag);

% set save path 
outfile = sprintf('figures/%s/log_sens/log_sens_prob%d_tf%d_K%d_%s',algorithm,prob,tf,K,algorithm);

% load data 
a = M*K+5;
b = M*K+6;
c = M*K+7;
d = M*K+8;
e = M*K+M2+7;
f = M*K+M2+8;
g = M*K+M2+9;
h = M*K+2*M2+8;
x = M*K+2*M2+9;

err = data(:,5);
num = length(err);
sens = data(:,d:e); 
b3 = data(:,b);
index = 1:num;

fid_test = find(err > 0.01);
err(fid_test,:) = [];
b3(fid_test,:) = [];
sens(fid_test,:) = [];

Z = [err b3 sens];
Z = sortrows(Z,"descend");
err = Z(:,1);
Z(:,1) = [];
b3 = Z(:,1);
Z(:,1) = [];
sens = Z;
log_sens = sens./err;
log_sens = abs(log_sens);
N = length(err);
sens_norm = arrayfun( @(n) norm(sens(n,:)),1:length(sens));
sens_norm = sens_norm';
log_sens_norm = arrayfun(@(n) norm(log_sens(n,:)),1:length(log_sens));
log_sens_norm = log_sens_norm';
index = 1:N;

figure;

semilogy(index,log_sens_norm,"LineWidth",1,"Color",'k');
hold on;
grid on;

semilogy(index,b3,"LineWidth",1,'color','b');
ylabel('log_{10}[B_{su}],log_{10}[||s(t_f)||]');
yyaxis right;

semilogy(index,err,"LineWidth",1,'color','r');
ylabel('e(t_f)','color','r');
title(sprintf('Problem %d - t_f=%d - K=%d - Log-Sensitivity',prob,tf,K));
xlabel('Controller Index');
legend('||s(t_f)||','B_{su}','e(t_f)','location','best');
set(gca,'Ycolor','r');
figtag = append(outfile);
savefig(figtag);
close all;

else 
    disp(sprintf('Data for Problem %d tf=%d K=%d Step Size=%s Algorithm=%s Does not Exists - skipping',prob,tf,K,ss(1,step_size),algorithm));
end


end
end
