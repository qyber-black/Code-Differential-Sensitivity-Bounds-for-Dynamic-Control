%% function to run inside for/parfor loop for sensitivity calculations

% SPDX-FileCopyrightText: Copyright (C) 2023 S Shermer <lw1660@gmail.com>, Swansea University
% SPDX-FileCopyrightText: Copyright (C) 2023 Sean P O'Neil <seanonei@usc.edu>, University of Southern California
% 
% SPDX-License-Identifier: CC-BY-SA-4.0

function out =  calc_sens_loop(ind,H,dH,N,UT,control)

% input 
%   ind - controller index
%   H - cell array of drift and interaction Hamiltonians 
%   dH - cell array of perturbation structures 
%   UT - target gate 
%   N - system size
%   control - row vector of [prob algo tf K error fields]

% output 
%   "out" structure with subfields:
%       err - nominal error 
%       sens - differential sensitivity to each perturbation structure 
%       bound2 - norm bound on differential sensitivity for static strucutre
%       bound3 - bound on differential sensitivity for variable structure 
%       direction - uncertainty direction that maximizes "bound" -
%       shouldn't need 
%       X - cell array of K directions that maximizes "bound2" - shouldn't
%       need

tol = 10^-10;
in = 1;                     % set input spin - do we need? 
M = length(H)-1;            % define number of interaction Hamiltonian matrices
M2 = length(dH);            % define number of perturbation structures
tf = control(1,3);          % extract gate operaton time 
K = control(1,4);           % extract number of control pulses
err = control(1,5);         % nominal fidelity error 
temp = control(1,6:end);    % extract control 
f = reshape(temp,M,K);      % reshape control array 
dt = tf/K;                  % length of each control pulse                 
I = eye(N);                         
H_0 = H{1};                 % drift Hamiltonian 
Uf = UT;                    % target gate 

% check normalization of uncertainty structures 
for ell = 1:M2
    test = trace(dH{ell}'*dH{ell});
    if (test-1) > tol;
        out = 0;
        error('Perturbation Structures Not Normalized!')
    end
end

% test overlap of uncertaitny structures with drift/interaction
% Hamiltonians and assign each structure to a Hamiltonian 

for ell = 1:M2
    for m = 1:(M+1)
            corr(ell,m) = trace(dH{ell}'*H{m});
    end
end

for ell = 1:M2
    for m=1:(M+1)
        if corr(ell,m) ~= 0
            if m ~= 1
                dHindex(ell) = m-1;
            else
                dHindex(ell) = M+1;
            end
        end
    end
end

% create optimized hamiltonian 
for k = 1:K
    Htot{k} = H_0;
    for m = 1:M
        Htot{k} = Htot{k} + f(m,k)*H{m+1};
    end
end

% loop to compute differential sensitivity to each uncertainty structure 
for p=1:M2

mu = dHindex(1,p);

% calculate state transition matrix (Phi) and matrix derivative (dPhi) at each time step
for k = 1:K
    if mu == M+1 
        [Phi{k},dPhi{k}] = dexpma(-i*Htot{k}*dt,-i*dH{p}*dt);
    else
        [Phi{k},dPhi{k}] = dexpma(-i*Htot{k}*dt,f(mu,k)*-i*dH{p}*dt);         
    end
end

% produce total state transition matrix from ordered product of Phi{k}
Phi_tot{1} = Phi{1};
for k = 2:K
    Phi_tot{k} = Phi{k}*Phi_tot{k-1};
end

phi = trace(transpose(Uf)*conj(Phi_tot{K}))/abs(trace(Uf'*Phi_tot{K}));

% compute Gamma and differential sensitivity bounds
for k = 1:K
    if k == 1
        z(k,p) = real(phi*trace(Uf'*Phi_tot{K}*Phi_tot{k}'*dPhi{k}));
    else 
        z(k,p) = real(phi*trace(Phi_tot{k-1}*Uf'*Phi_tot{K}*Phi_tot{k}'*dPhi{k}));
    end
end

% compute sensitivity as per (23) in technical paper 
o = ones(1,K);
sens(1,p) = -o*z(:,p)/N;

clear Phi;
clear Phi_tot;
clear dPhi;

end

bound = norm(o*z/N);            % compute bound for static uncertainty structure 

% compute bound for variable uncertainty structure  
for k = 1:K
    zeta(k,1) = norm(z(k,:));
end
bound2 = sum(zeta)/N;

dir = (-o*z/N)/bound;           % maximum sensitivity direction for static uncertainty structure 
direction = dir;                
X = z;                          % array of maximum sensitivity directions for variable uncertainty structure 

out.err = err;
out.sens = sens;
out.bound2 = bound;
out.bound3 = bound2;
out.direction = direction;
out.X = X;
out.dHindex = dHindex;

