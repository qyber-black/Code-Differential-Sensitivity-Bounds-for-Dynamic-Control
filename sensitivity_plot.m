%% create plots of sensitivity and sensitivity bounds 

% plots are saved in "algorithm/figures/sensitivity"

% SPDX-FileCopyrightText: Copyright (C) 2023 S Shermer <lw1660@gmail.com>, Swansea University
% SPDX-FileCopyrightText: Copyright (C) 2023 Sean P O'Neil <seanonei@usc.edu>, University of Southern California
% 
% SPDX-License-Identifier: CC-BY-SA-4.0

function sensitivity_plot(step_choice)
close all; 
clearvars -except step_choice epsilon;

disp('sensitivity_plot output: ');

char = ['square','diamond','o','hexagram','.','x',"pentagram",'*','+','^','v','pentagram'];
color = ['b','g','r','c','m','k','b','g','r','c','m','k'];

for algo = 1:2

switch algo
    case 1, algorithm = 'quasi-newton';
    case 2, algorithm = 'trust-region';
    otherwise algorithm = 'trust-region';
end

ss = ["10-3","10-4","10-5","10-6","10-7","10-8","10-9"];

dir_tag = sprintf('figures/%s/sensitivity',algorithm);

if exist(dir_tag,'dir') == 0
    mkdir(dir_tag);
end

% problem list 
prob_list = [1   1  1   1  1   1   1  1   1   2  2  2  2  3  3  3  3  3  3  4  4   4  4   4  4   5  5  5  5  6  6  6  6  7    7     8  8  8  8  9  9  9  9 ];
tf_list =   [2   2  2   3  3   3   4  4   4   7  7  8  8  12 12 15 15 20 20 12 12  15 15  25 25  7  7  8  8  7  7  8  8  125  150   10 10 15 15 10 10 15 15]; 
K_list =    [40  64 128 40 64  128 40 64  128 40 64 40 64 40 64 40 64 40 64 64 128 64 128 64 128 40 64 40 64 40 64 40 64 1000 1000  32 64 32 64 32 64 32 64];

l = length(prob_list);

for k = 1:l

prob = prob_list(1,k);
tf = tf_list(1,k);
K = K_list(1,k);
probtag = sprintf('problems/problem%d',prob);
load(probtag);
M = length(problem.H) - 1;
M2 = length(problem.dH);
 
% load robustness data 
loadtag = sprintf('results/%s/problem%d_tf%d_K%d_%s_%s.csv',algorithm,prob,tf,K,ss(1,step_choice),algorithm);

if exist(loadtag,'file') == 2

data = readmatrix(loadtag);

%set save path 
outfile1 = sprintf('figures/%s/sensitivity/sensitivity_bounds_problem%d_tf%d_K%d_%s',algorithm,prob,tf,K,algorithm);

% extract sensitivity data 

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
bound = data(:,b);
bound2 = data(:,c);
error_f = data(:,g:x);
delta_bar = data(:,f);
index = 1:num;


% sort data by bound B2
Z=[bound bound2];
Z = sortrows(Z,"descend");
Z(:,1) = [];
bound2 = Z;

Z=[bound error];
Z = sortrows(Z,"descend");
Z(:,1) = [];
error = Z;

Z=[bound sens];
Z = sortrows(Z,"descend");
bound = Z(:,1);
Z(:,1) = [];
sens = Z;

% create plots 
semilogy(index,bound(:,1),'LineWidth',3,'Color',"y");
hold on;
semilogy(index,bound2(:,1),'LineWidth',1,'Color',"r");

for k = 1:M2
    semilogy(index,abs(sens(:,k)),char(k),"MarkerFaceColor",color(k));
end
    title(sprintf('Problem %d - t_f=%d - K=%d - Sensitivity and bounds at delta=0',prob,tf,K));
    xlabel('controller index');
    ylabel('log_{10}[|\zeta_{\mu}(t_f)|]');
    grid on;
           switch prob
            case 1
                legend('B_2','B_3','\zeta_0','\zeta_1','\zeta_2','\zeta_3','\zeta_4','location','best');
            case 2
                legend('B_2','B_3','\zeta_0','\zeta_1','\zeta_2','\zeta_3','\zeta_4','\zeta_5','\zeta_6','location','best');
            case 3
                legend('B_2','B_3','\zeta_0','\zeta_1','\zeta_3(t_f)','\zeta_4(t_f)','\zeta_5(t_f)' ,'\zeta_6(t_f)','\zeta_7(t_f)','\zeta_8(t_f)','location','best');
            case 4
                legend('B_2','B_3','\zeta_0','\zeta_1','\zeta_2','\zeta_3','\zeta_4' ,'\zeta_5','\zeta_6','\zeta_7','\zeta_8','\zeta_9','\zeta_{10}','location','best');
            case 5
                legend('B_2','B_3','\zeta_0','\zeta_1','\zeta_2','\zeta_3','\zeta_4','\zeta_5','\zeta_6','location','best');
            case 6
                legend('B_2','B_3','\zeta_0','\zeta_1','\zeta_2','\zeta_3','\zeta_4','\zeta_5','\zeta_6','location','best');
            case 7
                legend('B_2','B_3','\zeta_0','\zeta_1','\zeta_2','location','best');
            case 8
                legend('B_2','B_3','\zeta_0','\zeta_1','\zeta_2','location','best');
            case 9
                legend('B_2','B_3','\zeta_0','\zeta_1','\zeta_2','location','best');
           end

    savefig(outfile1)
    close;

else 
    disp(sprintf('Data for Problem %d tf=%d K=%d Step Size=%s Algorithm=%s Does not Exists - skipping',prob,tf,K,ss(1,step_choice),algorithm));
end

end
end
