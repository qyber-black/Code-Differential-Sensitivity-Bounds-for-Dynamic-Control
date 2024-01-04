%% analyze trend betweeen fidelity error and the variable bound on the sensitiivity 

% SPDX-FileCopyrightText: Copyright (C) 2023 S Shermer <lw1660@gmail.com>, Swansea University
% SPDX-FileCopyrightText: Copyright (C) 2023 Sean P O'Neil <seanonei@usc.edu>, University of Southern California
% 
% SPDX-License-Identifier: CC-BY-SA-4.0

% results saved as an excel table with the correlation data in
% "results/correlation_data/algorithm/err_vs_b4_algorithm-{Kendall,Pearson}.csv"

function analyze_error_vs_b4(step_choice);
close all;
clearvars -except step_choice;

disp('analyze_error_vs_b4 output: ');

for algo = 1:2

switch algo
    case 1, algorithm = 'quasi-newton';
    case 2, algorithm = 'trust-region';
    otherwise algorithm = 'trust-region';
end

if exist(sprintf('results/correlation_data/%s',algorithm),'dir') == 0
    mkdir(sprintf('results/correlation_data/%s',algorithm));
end

% set save path 
outfileK = sprintf('results/correlation_data/%s/err_vs_b4_%s-Kendall.csv',algorithm,algorithm);
outfileP = sprintf('results/correlation_data/%s/err_vs_b4_%s-Pearson.csv',algorithm,algorithm);

% problem data 
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
 
ss = ["10-3","10-4","10-5","10-6","10-7","10-8","10-9"];

loadtag = sprintf('results/%s/problem%d_tf%d_K%d_%s_%s.csv',algorithm,prob,tf,K,ss(1,step_choice),algorithm);

if exist(loadtag,'file') == 2

%load(loadtag);
data = readmatrix(loadtag);

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
sens = data(:,d:e); 
b3 = data(:,b);
b4 = data(:,c);

% filter controllers with error greater than \epsilon and sort 
test_error = find(error > 0.01);

Z = [error b3 b4 sens];
Z(test_error,:) = [];
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

corr_p(row,1) = prob;
corr_k(row,1) = prob;
corr_p(row,2) = tf;
corr_k(row,2) = tf;
corr_p(row,3) = K;
corr_k(row,3) = K;
corr_p(row,4) = N;
corr_k(row,4) = N;

% get the correlation statistics - kendall and pearson 
corr_p(row,5) = corr(log10(error),log10(b4));
    sigma_p = sqrt(N-2);
    corr_p(row,6) = corr_p(row,5)*sigma_p/sqrt(1 - corr_p(row,5)^2);
    
    if corr_p(row,6) > 0
        corr_p(row,7) = 1*(1-tcdf(corr_p(row,6),N-2));
    else
        corr_p(row,7) = 1*tcdf(corr_p(row,6),N-2);
    end

corr_k(row,5) = corr(log10(error),log10(b4),'type','kendall');
    sigma_k = sqrt(2*(2*N+5)/(9*N*(N-1)));
    corr_k(row,6) = corr_k(row,5)/sigma_k; 
    if corr_k(row,6) > 0
        corr_k(row,7) = 1*(1-normcdf(corr_k(row,6)));
    else
        corr_k(row,7) = 1*normcdf(corr_k(row,6));
    end

else 
    disp(sprintf('Data for Problem %d tf=%d K=%d Step Size=%s Algorithm=%s Does not Exists - skipping',prob,tf,K,ss(1,step_choice),algorithm));
end

end

table_p = array2table(corr_p);
table_k = array2table(corr_k);

headings_k = {'problem','tf','K','#','err_v_B4','Z','p'};
headings_p = {'problem','tf','K','#','err_v_B4','Z','p'};
table_p.Properties.VariableNames = headings_p;
table_k.Properties.VariableNames = headings_k;

writetable(table_k,outfileK);
writetable(table_p,outfileP);

clear corr_p;
clear corr_k;
clear table_p;
clear table_k;
end
