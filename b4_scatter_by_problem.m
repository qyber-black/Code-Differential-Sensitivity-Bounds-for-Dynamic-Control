%% produces scatter plot of the variable structure bound against the fidelity error on a log-log scale for selected problems  

% saves figures in "figures/algorithm/consolidated_scatter"

% SPDX-FileCopyrightText: Copyright (C) 2023 S Shermer <lw1660@gmail.com>, Swansea University
% SPDX-FileCopyrightText: Copyright (C) 2023 Sean P O'Neil <seanonei@usc.edu>, University of Southern California
% 
% SPDX-License-Identifier: CC-BY-SA-4.0

function b4_scatter_by_problem(step_size)
close all; 
clearvars -except step_size;

disp('b4_scatter_by_problem output: ');

char = ['.','o','+','.','o','+','.','o','+','.','o','+'];
color = ['k','k','k','m','m','m','r','r','r','g','g','g'];

for algo = 1:2

switch algo
    case 1, algorithm = 'quasi-newton';
    case 2, algorithm = 'trust-region';
    otherwise algorithm = 'trust-region';
end

ss = ["10-3","10-4","10-5","10-6","10-7","10-8","10-9"];

dir_tag = sprintf('figures/%s/consolidated_scatter',algorithm);

if exist(dir_tag,'dir') == 0
    mkdir(dir_tag);
end

% choose grouping of problems to plot 
list = [1 2 3 4 5 6 7 8 9 29 47 123464 1234128 123440 581 582 691 692 256 89 124 234];
l = length(list);

for p = 1:l

    prob = list(1,p);

switch prob
    case 1
        tf_list =   [2   2  2   3  3   3   4  4   4   ]; 
        K_list =    [40  64 128 40 64  128 40 64  128 ];
        legend_tag = {'tf=2 K=40','tf=2 K=64','tf=2 K=128','tf=3 K=40','tf=3 K=64','tf=3 K=128','tf=4 K=40','tf=4 K=64','tf=4 K=128'};
    case 2
        tf_list =   [7  7  8  8 ]; 
        K_list =    [40 64 40 64];
        legend_tag = {'tf=7 K=40','tf=7 K=64','tf=8 K=40','tf=8 K=64'};
    case 3
        tf_list = [12 12 15 15 20 20];
        K_list =  [40 64 40 64 40 64];
        legend_tag = {'tf=12 K=40','tf=12 K=64','tf=15 K=40','tf=15 K=64','tf=20 K=40','tf=20 K=64'};
    case 4
        tf_list = [12 12  15 15  25 25];
        K_list =  [64 128 64 128 64 128];
        legend_tag = {'tf=12 K=64','tf=12 K=128','tf=15 K=64','tf=15 K=128','tf=25 K=64','tf=25 K=128'};
    case 5
        tf_list =   [7  7  8  8 ]; 
        K_list =    [40 64 40 64];
        legend_tag = {'tf=7 K=40','tf=7 K=64','tf=8 K=40','tf=8 K=64'};
    case 6
        tf_list =   [7  7  8  8 ]; 
        K_list =    [40 64 40 64];
        legend_tag = {'tf=7 K=40','tf=7 K=64','tf=8 K=40','tf=8 K=64'};
    case 7
        tf_list = [125  150];
        K_list =  [1000 1000];
        legend_tag = {'tf=125 K=1000','tf=150 K=1000'};
    case 8
        tf_list = [10 10 15 15];
        K_list =  [32 64 32 64];
        legend_tag = {'tf=10 K=32','tf=10 K=64','tf=15 K=32','tf=15 K=64'};
    case 9
        tf_list = [10 10 15 15];
        K_list =  [32 64 32 64];
        legend_tag = {'tf=10 K=32','tf=10 K=64','tf=15 K=32','tf=15 K=64'};
    case 29
        prob_list = [ 2  2  2  2   9  9   9  9];
        tf_list =   [ 7  7  8  8  10 10  15 15];
        K_list =    [40 64 40 64  32 64  32 64];
        legend_tag = {'prob2 tf=7 K=40','prob2 tf=7 K=64','prob2 tf=8 K=40','prob2 tf=8 K=64','prob9 tf=10 K=32','prob9 tf=10 K=64','prob9 tf=15 K=32','prob9 tf=15 K=64'};
    case 47
        prob_list = [4  4   4  4   7    7];
        tf_list =   [12 12  15 15  125  150];
        K_list =    [64 128 64 128 1000 1000];
        legend_tag = {'prob4 tf=12 K=64','prob4 tf=12 K=128','prob4 tf=15 K=64','prob4 tf=15 K=128','prob7 tf=125 K=1000','prob7 tf=150 K=1000'};
    case 123464
        prob_list = [   1  1   1   2    2    3   3   3   3   4   4   4];
        tf_list =   [   2  3   4   7    8   12  15  15  20  12  15  25];                                                       
        K_list =    [  64  64 64  64   64   64  64  64  64  64  64  64];                                                   
        legend_tag = {'prob1 tf=2','prob1 tf=3','prob1 tf=4','prob2 tf=7','prob2 tf=8','prob3 tf=12','prob3 tf=15','prob3 tf=20','prob4 tf=12','prob4 tf=15','prob4 tf=25'};
     case 1234128
        prob_list = [1   1    1  4   4   4  ];
        tf_list =   [2   3    4  12  15  25 ];                                                       
        K_list =    [128 128 128 128 128 128];                                                   
        legend_tag = {'prob1 tf=2','prob1 tf=3','prob1 tf=4','prob4 tf=12','prob4 tf=15','prob4 tf=25'};
      case 123440
        prob_list = [   1  1   1   2    2    3   3   3];
        tf_list =   [   2  3   4   7    8   12  15  20];                                                       
        K_list =    [  40  40 40  40   40   40  40  40];                                                   
        legend_tag = {'prob1 tf=2','prob1 tf=3','prob1 tf=4','prob2 tf=7','prob2 tf=8','prob3 tf=12','prob3 tf=15','prob3 tf=20'};
     case 581
        prob_list = [5  8  ];
        tf_list =   [7  10 ]; 
        K_list =    [40 64 ];
        legend_tag = {'prob5 tf=7 K=40','prob8 tf=10 K=64'};
     case 582
        prob_list = [5  8  ];
        tf_list =   [8  15 ]; 
        K_list =    [40 64 ];
        legend_tag = {'prob5 tf=8 K=40','prob8 tf=15 K=64'};
     case 691
        prob_list = [6  9  ];
        tf_list =   [7  10 ]; 
        K_list =    [40 64 ];
        legend_tag = {'prob6 tf=7 K=40','prob9 tf=10 K=64'};
     case 692
        prob_list = [6  9  ];
        tf_list =   [8  15 ]; 
        K_list =    [40 64 ];
        legend_tag = {'prob6 tf=8 K=40','prob9 tf=15 K=64'};
    case 256 
        prob_list = [2  2  5  5  6  6 ]; 
        tf_list =   [7  7  7  7  7  7 ];
        K_list =    [40 64 40 64 40 64];
        legend_tag = {'prob2 K=40','prob2 K=64','prob5 K=40','prob5 K=64','prob6 K=40','prob6 K=64'};
    case 89 
        prob_list = [8  8  9  9 ]; 
        tf_list =   [15 15 15 15];
        K_list =    [32 64 32 64];
        legend_tag = {'prob8 K=32','prob8 K=64','prob9 K=32','prob9 K=64'};
    case 124
        prob_list = [   1  1  2  4   4  ];
        tf_list =   [   3  4  7  12  15 ];                                                       
        K_list =    [  40  40 64 128 128];                                                   
        legend_tag = {'prob1 tf=3 K=40','prob1 tf=4 K=40','prob2 tf=7 K=64','prob4 tf=12 K=128','prob4 tf=15 K=128'};
    case 234
        prob_list = [   2  3  4  4  ];
        tf_list =   [   8  15 15 25 ];                                                       
        K_list =    [  40  64 64 128];                                                   
        legend_tag = {'prob2 tf=8 K=40','prob3 tf=15 K=64','prob4 tf=15 K=64','prob4 tf=25 K=128'};
end

temp = prob;

if prob == 47 | prob == 123440 |prob == 123464 | prob == 1234128 | prob == 29 | prob == 58 | prob == 69 | prob == 581 | prob == 582 | prob == 691 | prob == 692 | prob == 256 | prob == 89 | prob == 124 | prob == 234
    
    temp = prob;
    figure;
    l = length(tf_list);
    outfile1 = sprintf('figures/%s/consolidated_scatter/scatter_prob%d_%s',algorithm,temp,algorithm);

        switch temp
        case 47
            char = ['.','.','.','+','+','+','.','o','+','.','o','+'];
            color = ['k','m','r','k','m','r','r','r','r','g','g','g'];
        case 581
            char = ['.','.','.','+','+','+','.','o','+','.','o','+'];
            color = ['k','m','r','k','m','r','r','r','r','g','g','g'];
        case 582
            char = ['.','.','.','+','+','+','.','o','+','.','o','+'];
            color = ['k','m','r','k','m','r','r','r','r','g','g','g'];
        case 691
            char = ['.','.','.','+','+','+','.','o','+','.','o','+'];
            color = ['k','m','r','k','m','r','r','r','r','g','g','g'];
        case 692
            char = ['.','.','.','+','+','+','.','o','+','.','o','+'];
            color = ['k','m','r','k','m','r','r','r','r','g','g','g'];
        case 256
             char = ['.','.','.','+','+','+','.','o','+','.','o','+'];
            color = ['k','m','r','k','m','r','r','r','r','g','g','g'];
        case 89
            char = ['.','.','.','+','+','+','.','o','+','.','o','+'];
            color = ['k','m','r','k','m','r','r','r','r','g','g','g'];
        case 1234128
            char = ['.','.','.','+','+','+','.','o','+','.','o','+'];
            color = ['k','m','r','k','m','r','r','r','r','g','g','g'];
        case 123440
            char = ['.','.','.','+','+','+','.','o','+','.','o','+'];
            color = ['k','m','r','k','m','r','r','r','r','g','g','g'];
        case 124
            char = ['.','.','.','+','+','+','.','o','+','.','o','+'];
            color = ['k','m','r','k','m','r','r','r','r','g','g','g'];
        case 234
            char = ['.','.','.','+','+','+','.','o','+','.','o','+'];
            color = ['k','m','r','k','m','r','r','r','r','g','g','g'];
        end

    for k = 1:l
        prob = prob_list(1,k);
        tf = tf_list(1,k);
        K = K_list(1,k);
        probtag = sprintf('problems/problem%d',prob);
        load(probtag);
        M = length(problem.H) - 1;
        M2 = length(problem.dH);
        
        loadtag = sprintf('results/%s/problem%d_tf%d_K%d_%s_%s.csv',algorithm,prob,tf,K,ss(1,step_size),algorithm);
        
        if exist(loadtag,'file') == 2

        data = readmatrix(loadtag);

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
        error_f = data(:,g:x);
        delta_bar = data(:,f);
        index = 1:num;
        
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

        loglog(error,b4,char(k),"Color",color(k));
        hold on;
        grid on;
    
    switch temp
        case 47
            title(sprintf('Problem 4 and Problem 7 - B_{vu} vs e(t_f) - Log-Log - %s',algorithm));
        case 29
            title(sprintf('Problem 2 and Problem 9 - B_{vu} vs e(t_f) - Linear - %s',algorithm));
        case 123464
            title(sprintf('Problems 1 through 4 K=64- B_{vu} vs e(t_f) - Log-Log - %s',algorithm));
        case 1234128
            title(sprintf('Problems 1 through 4 K=128 - B_{vu} vs e(t_f) - Log-Log - %s',algorithm));
        case 123440
            title(sprintf('Problems 1 through 4 K=40 - B_{vu} vs e(t_f) - Log-Log - %s',algorithm));
        case 581
            title(sprintf('Problem 5 and Problem 8 - B_{vu} vs e(t_f) - K/tf = 0.175 vs 0.156 - %s',algorithm));
        case 582
            title(sprintf('Problem 5 and Problem 8 - B_{vu} vs e(t_f) - K/tf = 0.20 vs 0.2344 - %s',algorithm));
        case 691
            title(sprintf('Problem 6 and Problem 9 - B_{vu} vs e(t_f) - K/tf = 0.175 vs 0.156 - %s',algorithm));
        case 692
            title(sprintf('Problem 6 and Problem 9 - B_{vu} vs e(t_f) - K/tf = 0.20 vs 0.2344 - %s',algorithm));
        case 256
            title(sprintf('Problem 2 and Problem 5 and Problem 6 - B_{vu} vs e(t_f) - tf=7 - %s',algorithm));
        case 89
            title(sprintf('Problem 8 and Problem 9 - B_{vu} vs e(t_f) - tf=15 - %s',algorithm));
        case 124
            title(sprintf('Problem2 1 to 4 - B_{vu} vs e(t_f) - %s',algorithm));
        case 234
            title(sprintf('Problem2 2 to 4 - B_{vu} vs e(t_f) - %s',algorithm));
    end

    xlabel('log_{10}[e(t_f)]');
    ylabel('log_{10}[B_{vu}]');
    figtag = append(outfile1,'_loglog');
    legend(legend_tag,'location','best');
    savefig(figtag);
    close all;
else 
    disp(sprintf('Data for Problem %d tf=%d K=%d Step Size=%s Algorithm=%s Does not Exists - skipping',prob,tf,K,ss(1,step_size),algorithm));
end

end

else

figure;
l = length(tf_list);

outfile1 = sprintf('figures/%s/consolidated_scatter/scatter_prob%d_%s',algorithm,prob,algorithm);

for k = 1:l
    tf = tf_list(1,k);
    K = K_list(1,k);
    probtag = sprintf('problems/problem%d',prob);
    load(probtag);
    M = length(problem.H) - 1;
    M2 = length(problem.dH);
 
    loadtag = sprintf('results/%s/problem%d_tf%d_K%d_%s_%s.csv',algorithm,prob,tf,K,ss(1,step_size),algorithm);

    if exist(loadtag,'file') == 2
    
    data = readmatrix(loadtag);

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
        error_f = data(:,g:x);
        delta_bar = data(:,f);
        index = 1:num;

        Z = [error b4 sens];
        Q = find(error > 0.01);
        Z(Q,:) = [];
        Z = sortrows(Z,"descend");
        error = Z(:,1);
        Z(:,1) = [];
        b4 = Z(:,1);
        Z(:,1) = [];
        sens = Z;
        
        loglog(error,b4,char(k),"Color",color(k));
        hold on;
        grid on;

    else
       disp(sprintf('Data for Problem %d tf=%d K=%d Step Size=%s Algorithm=%s Does not Exists - skipping',prob,tf,K,ss(1,step_size),algorithm));
end
end

title(sprintf('Problem %d- B_{vu} vs e(t_f) - Log-Log',prob));
xlabel('log_{10}(e(t_f))');
ylabel('log_{10}(B_{vu})');
legend(legend_tag,'location','best');
figtag = append(outfile1,'_loglog');
savefig(figtag);
close all;

end
end
end
