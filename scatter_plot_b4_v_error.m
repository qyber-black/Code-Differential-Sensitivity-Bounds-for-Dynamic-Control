%% analyze trend betweeen \delta_bar and the variable bound on the sensitiivity 

% saves figures in "figures/algorithm/scatter"

% SPDX-FileCopyrightText: Copyright (C) 2023 S Shermer <lw1660@gmail.com>, Swansea University
% SPDX-FileCopyrightText: Copyright (C) 2023 Sean P O'Neil <seanonei@usc.edu>, University of Southern California
% 
% SPDX-License-Identifier: CC-BY-SA-4.0

function scatter_plot_b4_v_error(step_size)
close all;
clearvars -except step_size 

char = ['*','o','+','x',"square","diamond","pentagram","hexagram",'^','v','.'];
color = ['b','g','r','c','m','k','b','g','r','c','m'];

ss = ["10-3","10-4","10-5","10-6","10-7","10-8","10-9"];

for algo = 1:2

switch algo
    case 1, algorithm = 'quasi-newton';
    case 2, algorithm = 'trust-region';
    otherwise algorithm = 'trust-region';
end

dir_tag = sprintf('figures/%s/scatter',algorithm);

if exist(dir_tag,'dir') == 0
    mkdir(dir_tag);
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
outfile1 = sprintf('figures/%s/scatter/scatter_B4_v_error_prob%d_tf%d_K%d_%s',algorithm,prob,tf,K,algorithm);



% extract data 
a = M*K+5;
b = M*K+6;
c = M*K+7;
d = M*K+8;
e = M*K+M2+7;
f = M*K+M2+8;
g = M*K+M2+9;
h = M*K+2*M2+8;
x = M*K+2*M2+9;

error = data(:,5);
num = length(error);
sens = data(:,d:e); 
b3 = data(:,b);
b4 = data(:,c);

% filter controllers with error greater than \epsilon and sort by nominal
% error 
Z = [error b3 b4 sens];
Q = find(error > 0.01);
Z(Q,:) = [];
Z = sortrows(Z,"descend");
error = Z(:,1);
Z(:,1) = [];
b3 = Z(:,1);
Z(:,1) = [];
b4 = Z(:,1);
Z(:,1) = [];
sens = Z;
N = length(error);
index = 1:N;

figure;
plot(error,b4,"o","MarkerFaceColor","r");
hold on;
grid on;
title(sprintf('Problem %d - t_f=%d - K=%d - B_4 vs e(t_f) - Linear',prob,tf,K));
xlabel('e(t_f)');
ylabel('B_4');
figtag = append(outfile1,'_linear');
savefig(figtag);

figure
loglog(error,b4,"o","MarkerFaceColor","r");
hold on;
grid on;
title(sprintf('Problem %d - t_f=%d - K=%d - B_4 vs e(t_f) - Log-Log',prob,tf,K));
xlabel('log_{10}(e(t_f))');
ylabel('log_{10}(B_4)');
figtag = append(outfile1,'_loglog');
savefig(figtag);

figure
semilogy(error,b4,"o","MarkerFaceColor","r");
hold on;
grid on;
title(sprintf('Problem %d - t_f=%d - K=%d - B_4 vs e(t_f) - Semilog',prob,tf,K));
xlabel('e(t_f)');
ylabel('log_{10}(B_4)');
figtag = append(outfile1,'_semilog');
savefig(figtag);
close all;

else 
    disp(sprintf('Data for Problem %d tf=%d K=%d Step Size=%s Algorithm=%s Does not Exists - skipping',prob,tf,K,ss(1,step_size),algorithm));
end

end
end