%% print differential sensitivity plots based on results of find_delta_bar

% plots are saved in "figures/algorithm/performance"

% SPDX-FileCopyrightText: Copyright (C) 2023 S Shermer <lw1660@gmail.com>, Swansea University
% SPDX-FileCopyrightText: Copyright (C) 2023 Sean P O'Neil <seanonei@usc.edu>, University of Southern California
% 
% SPDX-License-Identifier: CC-BY-SA-4.0

function performance_plot(step_choice,epsilon)
close all;
clearvars -except step_choice epsilon;

disp('performance_plot output: ');

char = ['square','diamond','o','hexagram','.','x',"pentagram",'*','+','^','v','pentagram'];
color = ['b','g','r','c','m','k','b','g','r','c','m','k'];

for algo = 1:2

switch algo
    case 1, algorithm = 'quasi-newton';
    case 2, algorithm = 'trust-region';
    otherwise algorithm = 'trust-region';
end

ss = ["10-3","10-4","10-5","10-6","10-7","10-8","10-9"];

dir_tag = sprintf('figures/%s/performance',algorithm);

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
 

loadtag = sprintf('results/%s/problem%d_tf%d_K%d_%s_%s.csv',algorithm,prob,tf,K,ss(1,step_choice),algorithm);

if exist(loadtag,'file') == 2

data = readmatrix(loadtag);

% set save paths
outfile1 = sprintf('figures/%s/performance/performance_problem%d_tf%d_K%d_%s_%s',algorithm,prob,tf,K,ss(1,step_choice),algorithm);

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

err = data(:,5);
num = length(err);
sens = data(:,d:e); 
b3 = data(:,b);
b4 = data(:,c);
error_f = data(:,g:x);
delta_bar = data(:,f);


% sort data by size of \delta_bar
Z=[delta_bar err error_f];
Z = sortrows(Z,"descend");
temp = find(Z(:,1) == 0);
Z(temp,:) = [];
delta_bar = Z(:,1);
Z(:,1) = [];
err = Z(:,1);
Z(:,1) = [];
error_f = Z;
index = 1:length(delta_bar);
ep = epsilon*ones(length(delta_bar),1);

figure;
semilogy(index,ep,'LineWidth',1);
hold on;
semilogy(index,error_f(:,end),char(M2+1),"MarkerFaceColor",color(M2+1));
%semilogy(index,error_f(:,M+1),char(1),"MarkerFaceColor",color(1));
for m = 1:M2
    semilogy(index,error_f(:,m),char(m),"MarkerFaceColor",color(m));
end
ylabel('\epsilon,e_{\mu}(t_f)');
yyaxis right;
semilogy(index,delta_bar,"Linewidth",1.5);
ylabel('\delta_{bar}')
title(sprintf('Problem %d - t_f=%d - K=%d - Performance Bounds - delta increment %s',prob,tf,K,ss(1,step_choice)));
xlabel('Control Index');
grid on;
switch prob
    case 1
        legend('\epsilon','e_{bar}','e_0(t_f)','e_1(t_f)','e_2(t_f)','e_3(t_f)','e_4(t_f)','\delta_{bar}','location','best');
    case 2
        legend('\epsilon','e_{max}','e_0(t_f)','e_1(t_f)','e_2(t_f)','e_3(t_f)','e_4(t_f)' ,'e_5(t_f)','e_6(t_f)','\delta_{max}','location','best');
    case 3
        legend('\epsilon','e_{max}','e_0(t_f)','e_1(t_f)','e_2(t_f)','e_3(t_f)','e_4(t_f)' ,'e_5(t_f)','e_6(t_f)','e_7(t_f)','e_8(t_f)','\delta_{max}','location','best');
    case 4
        legend('\epsilon','e_{max}','e_0(t_f)','e_1(t_f)','e_2(t_f)','e_3(t_f)','e_4(t_f)','e_5(t_f)' ,'e_6(t_f)','e_7(t_f)','e_8(t_f)','e_9(t_f)','e_{10}(t_f)','\delta_{max}','location','best');
    case 5
        legend('\epsilon','e_{max}','e_0(t_f)','e_1(t_f)','e_2(t_f)','e_3(t_f)','e_4(t_f)' ,'e_5(t_f)','e_6(t_f)','\delta_{max}','location','best');
    case 6
        legend('\epsilon','e_{max}','e_0(t_f)','e_1(t_f)','e_2(t_f)','e_3(t_f)','e_4(t_f)' ,'e_5(t_f)','e_6(t_f)','\delta_{max}','location','best');
    case 7
        legend('\epsilon','e_{max}','e_0(t_f)','e_1(t_f)','e_2(t_f)','\delta_{max}','location','best');
    case 8
        legend('\epsilon','e_{max}','e_0(t_f)','e_1(t_f)','e_2(t_f)','\delta_{max}','location','best');
    case 9
        legend('\epsilon','e_{max}','e_0(t_f)','e_1(t_f)','e_2(t_f)','\delta_{max}','location','best');
end

else 
    disp(sprintf('Data for Problem %d tf=%d K=%d Step Size=%s Algorithm=%s Does not Exists - skipping',prob,tf,K,ss(1,step_choice),algorithm));
end

savefig(outfile1);
close;

end
end