%% loop for calculating peformance data (delta_bar)

% SPDX-FileCopyrightText: Copyright (C) 2023 S Shermer <lw1660@gmail.com>, Swansea University
% SPDX-FileCopyrightText: Copyright (C) 2023 Sean P O'Neil <seanonei@usc.edu>, University of Southern California
% 
% SPDX-License-Identifier: CC-BY-SA-4.0

function out_data = calc_performance_loop(ind,results,delta,epsilon,tol,prob,tf,K,ss,algorithm,control)

% input
%   ind - controller index
%   results - results structure output by calc_sens__bounds.m
%   delta - step size for incrementing perturbation 
%   epsilon - performance limit on fidelity error 
%   tol - tolerance to determine when fidelity error exceeds \epsilon 
%   prob - problem index
%   tf - read-out time
%   K - number of control pulses 
%   ss - step-size string 
%   algorithm - algorithm string 

% output 
%   error_f - array of fidelity error evaluated at \delta_bar for each
%   principal uncertainty structure and for the maximum sensitivity
%   direction 
%   delta_bar - minimum perturbation that violates the performance threshold  

% load problem data 
intag = sprintf('problems/problem%d',prob);
load(intag);

% extract system and controller data
M = length(problem.H)-1;
temp = control;             % extract control 
f = reshape(temp,M,K);      % reshape control array 
H = problem.H;              % drift and interaction hamiltonian matrices 
dH = problem.dH;            % extract uncertainty structure matrices 
M2 = length(dH);
dHindex = results.dHindex;   % extact association of structure with Hamiltonian matrices 
Uf = problem.UT;            % target unitary   
dt = tf/K;                      % length of each control pulse 
N = max(size(H{1}));            % system size
H_0 = H{1};
sens = results.sens(ind,:);     % differential sensitivity 
Z = (-1/N)*results.X{ind};      
%delta = 0

% establish array of directions for \delta_bar search 
for ell = 1:K
    direction(ell,:) = Z(ell,:)/norm(Z(ell,:));
end

% create optimized hamiltonian 
for k = 1:K
    Htot{k} = H_0;
    for m = 1:M
        Htot{k} = Htot{k} + f(m,k)*H{m+1};
    end
end

% create perturbed hamiltonian about \delta = 0
Htot_p = Htot;
for k = 1:K
    for p = 1:M2
        mu = dHindex(1,p);
        if mu == M+1
            Htot_p{k} = Htot_p{k}+dH{p}*delta*direction(k,p);
        else     
            Htot_p{k} = Htot_p{k} + delta*f(mu,k)*dH{p}*direction(k,p);
        end
    end
end

% calculate exact perturbed state transition matrix
for k = 1:K
        [Phi_p{k}] = expm(-i*(Htot_p{k})*dt);
end

% produce total perturbed state transition matrix from ordered product 
Phi_tot_p{1} = Phi_p{1};
for k = 2:K
    Phi_tot_p{k} = Phi_p{k}*Phi_tot_p{k-1};
end

% initialize index for iteration on \delta 
c = 1;

phi = trace(transpose(Uf)*conj(Phi_tot_p{K}))/abs(trace(Uf'*Phi_tot_p{K}));
fid_p = (1/N)*abs(trace(Uf'*Phi_tot_p{K}));
err_p(c,1) = 1-fid_p;
clear Phi_p Phi_tot_p ell p k;

% loop to determine \delta_bar
while (epsilon-err_p(c,1)) >= tol

z = zeros(K,M2);

% loop to compute matrix exponential derivative evaluated at c*\delta for each uncertainty structure  
for p = 1:M2
   mu = dHindex(1,p);
   for k = 1:K
       if mu == M+1
           [Phi_p{k},dPhi_p{k}] = dexpma(-i*(Htot_p{k})*dt,-i*dH{p}*dt);
       else
           [Phi_p{k},dPhi_p{k}] = dexpma(-i*(Htot_p{k})*dt,-i*f(mu,k)*dH{p}*dt);
       end
   end

% produce total perturbed state transition matrix at c*\delta
Phi_tot_p{1} = Phi_p{1};
for k = 2:K
    Phi_tot_p{k} = Phi_p{k}*Phi_tot_p{k-1};
end

phi = trace(transpose(Uf)*conj(Phi_tot_p{K}))/abs(trace(Uf'*Phi_tot_p{K}));

% compute Z matrix at c*\delta
for k = 1:K
    if k == 1
        z(k,p) = real(phi*trace(Uf'*Phi_tot_p{K}*Phi_tot_p{k}'*dPhi_p{k}));
    else 
        z(k,p) = real(phi*trace( Phi_tot_p{k-1}*Uf'*Phi_tot_p{K}*Phi_tot_p{k}'*dPhi_p{k} ));
    end
end

clear Phi_p Phi_tot_p
end

% increment step size index 
c = c+1;

temp = (-1*z/N);

for k = 1:length(temp)
    dir(k,:) = temp(k,:)/norm(temp(k,:));
end

% create perturbed hamiltonian at next step of \delta
for k = 1:K
    for ell = 1:M2
        mu = dHindex(1,ell);
        if mu == M+1
            Htot_p{k} = Htot_p{k}+dH{ell}*delta*dir(k,ell);
        else     
            Htot_p{k} = Htot_p{k} + delta*f(mu,k)*dH{ell}*dir(k,ell);
        end
    end
end

% calculate exact perturbed state transition matrix at new \delta
for k = 1:K
        [Phi_p{k}] = expm(-i*(Htot_p{k})*dt);
end

% produce total perturbed state transition matrix at new \delta
Phi_tot_p{1} = Phi_p{1};
for k = 2:K
    Phi_tot_p{k} = Phi_p{k}*Phi_tot_p{k-1};
end

% evalute fidelity error at new value of \delta 
phi = trace(Uf*Phi_tot_p{K}')/abs(trace(Uf*Phi_tot_p{K}'));
fid_p = (1/N)*abs(trace(Uf'*Phi_tot_p{K}));
err_p(c,1) = 1-fid_p;

clear Phi_p Phi_tot_p z

end

delta_bar = delta*(c-1);
clear Htot_p Phi_p Phi_tot_p dir

% recalculate err_p at delta_bar in each basis direction for comparison 

% create perturbed hamiltonian at \delta_bar in principal directions
for p = 1:M2
    mu = dHindex(1,p);
    for k = 1:K
        if mu == M+1
            Htot_f{k} = Htot{k} + dH{p}*delta_bar;
        else
            Htot_f{k} = Htot{k} + delta_bar*f(mu,k)*dH{p};
        end
    end
    
% produced state transision matrix at each time step - perturbed at
% \delta_bar
    for k = 1:K
        [Phi_f{k}] = expm(-i*(Htot_f{k})*dt);
    end

    % produce total perturbed state transition matrix at \delta_bar in
    % given uncertainty direction 
    Phi_tot_f{1} = Phi_f{1};
    for k = 2:K
        Phi_tot_f{k} = Phi_f{k}*Phi_tot_f{k-1};
    end
    
    % compute perturbed fidelity error in each principal direction at
    % \delta_bar for comparison 
    fid_f(1,p) = (1/N)*abs(trace(Uf'*Phi_tot_f{K}));
    err_f(1,p) = 1-fid_f(1,p);

    clear Phi_tot_f;
    clear Htot_f;
    clear Phi_f;

end

error_f(1,:) = [err_f(1,:) err_p(c-1,1)];
out_data = [delta_bar error_f];
outfile = sprintf('results/temp/problem%d_tf%d_K%d_%s_%d_%s',prob,tf,K,ss,ind,algorithm);
save(outfile,'out_data');
