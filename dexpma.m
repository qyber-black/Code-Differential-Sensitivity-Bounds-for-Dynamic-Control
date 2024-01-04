%% compute matrix exponential and derivative of matrix exponential 

% SPDX-FileCopyrightText: Copyright (C) 2023 S Shermer <lw1660@gmail.com>, Swansea University
% SPDX-FileCopyrightText: Copyright (C) 2023 Sean P O'Neil <seanonei@usc.edu>, University of Southern California
% 
% SPDX-License-Identifier: CC-BY-SA-4.0

function [F,dF] = dexpma(M,dM)

% input 
%   M - argument for matrix exponential 
%   dM - structure (direction) for evaluation of derivative of matrix
%   exponential 

% output
%   F - matrix exponential of M
%   dF - derivative of matrix exponential of M in direction dM

N   = length(M);
AM  = [M zeros(N);dM M];
PSI = expm(AM);
F   = PSI(1:N,1:N);
dF  = PSI(N+1:2*N,1:N);
