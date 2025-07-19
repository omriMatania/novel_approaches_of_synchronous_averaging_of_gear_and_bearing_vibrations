function [estmd_delays] = angular_synchronization(delays_between_sigs, N)
% angular_synchronization estimates the delays of the signals based on the
% estimated delays between them. For each pair, the function creates an
% equation where the delay is converted to a complex value using 
% exp(2*pi*1i*delay/N). Then, the function solves the linear system of
% equations Ax=b using the least squares method, where each equation 
% represents the constraint imposed by the delay between the specific pair
% corresponding to it. To eliminate the trivial solution of x = 0, it is 
% assumed that the value of the first signal is 1, corresponding to a phase
% of 0. Based on the solution x, the function calculates the phases of the 
% signals, and then their delays.
% Inputs:
%   delays_between_sigs - A matrix of delays between the signals. Each cell
%       (ii, jj) corresponds to the delays between signal ii and
%       signal jj.
%   N - Number of samples of each signal.
% Outputs:
%   estmd_delays - The estimated delays of the signals. The delay of the
%   first signal is 0, and the delay of each other signal is the relative
%   delay between it and the first signal.
% ----------------------------------------------------------------------- %

if isempty(delays_between_sigs)
    estmd_delays = 0 ;
    return
end % of if

[edges, edges_values] = convert_delays_to_edges_and_values(delays_between_sigs, N) ;

num_vertices = max(max(edges(:, 1:2))) ;
num_edges = size(edges, 1) ;

% vertex 1 has a special treatment because it is assumed that its phase is
% 0, and therefore its value is equal to exp(2*pi*1i*0), which equals 1. 
% Otherwise, a trivial solution of the system sets all variables to 0.
inds_relate_to_vertix_1 = [find(edges(:, 1)==1), find(edges(:, 2)==1)] ;
sub_edges = edges ;
sub_edges_values = edges_values ;
sub_edges(inds_relate_to_vertix_1, :) = [] ;
sub_edges_values(inds_relate_to_vertix_1) = [] ;
sub_edges = sub_edges - 1 ;

% construct the linear system represented by Ax = b
row_inds = [[1:1:size(sub_edges, 1)].'; [1:1:size(sub_edges, 1)].'] ;
column_inds = [sub_edges(:, 1); sub_edges(:, 2)] ;
mtrx_values = [ones(size(sub_edges(:, 1))); -sub_edges_values] ;
A = sparse(row_inds, column_inds, mtrx_values, num_edges, num_vertices-1) ;
b = sparse(num_edges, 1);

% handle the edges connected to vertex 1
ind = size(sub_edges, 1) + 1 ;
for edgeNum = 1 : num_edges
    if edges(edgeNum, 1) == 1
        b(ind) = -1 ;
        A(ind, edges(edgeNum, 2)-1) = -edges_values(edgeNum) ;
    elseif edges(edgeNum, 2) == 1
        A(ind, edges(edgeNum, 2)-1) = 1 ;
        b(ind) = edges_values(edgeNum)*1 ;
    end % of if
    ind = ind + 1 ;
end % of for

% solve the system of linear equations
x = A\b;

% estimate the delay based on the phases of the x vector values
estmd_delays = angle(x) ;
estmd_delays = full(estmd_delays) ; % convert from a sparse vector to a regular vector
estmd_delays = [0; estmd_delays] ; % add the phase of the first vertex, which is 0

% convert all the phase values to be positive
for ii = 1 : length(estmd_delays)
    if estmd_delays(ii) < 0
        estmd_delays(ii) = estmd_delays(ii) + 2*pi;
    end % of if
end % of for
estmd_delays = N*(estmd_delays/(2*pi)) ; % convert from phase values to delay values

end % of angular_synchronization


% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %


function [edges, edges_values] = convert_delays_to_edges_and_values(delays_between_sigs, N)
% convert_delays_to_edges_and_values converts the "delays_between_sigs"
% matrix into two lists of edges and their values.
% ----------------------------------------------------------------------- %

num_vertices = size(delays_between_sigs, 1) ; % number of vertices
num_edges = (num_vertices * num_vertices - num_vertices) / 2 ; % number of edges
edges = zeros(num_edges, 2) ;
edges_values = zeros(num_edges, 1) ;

% create the edges and caculate thier values
ind = 1 ;
for ii = 1 : num_vertices-1
    for jj = ii + 1 : num_vertices
        delay_between_ii_to_jj = delays_between_sigs(ii, jj) ;
        edges_values(ind) = (2*pi*delay_between_ii_to_jj/N) ;
        edges(ind, 1) = ii ;
        edges(ind, 2) = jj ;
        ind = ind + 1 ;
    end % of for
end % of for
edges_values = exp(1i*edges_values) ;

end % of convert_delays_to_edges_and_values