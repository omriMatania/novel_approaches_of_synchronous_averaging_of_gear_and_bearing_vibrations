function [sa, estmd_delays, syncd_sgmnts_mtrx] = calc_synchronous_average(sig, N, varargin)
% calc_synchronous_average calculates the synchronous average of the signal "sig".
% Inputs:
%   sig - Signal, should be a column vector.
%   N - Number of points in the synchronous average.
%   varargin - Additional input parameters. These can include 'Technique',
%       'Batch size', 'Number of iterations', and 'Maximal delay deviation'. 'Technique'
%       is the synchronous averaging technique to use (the default 
%       technique is 'Simple'). 'Batch size', represnts the batch size for 
%       batch synchronous averaging'Number of iterations' represents the 
%       number of iterations to use in the 'Mean - Sync Iterations' 
%       technique (the default value is 10). 'Maximal delay deviation' 
%       denotes the maximum allowable delay between the signals within each
%       pair in the 'Angular Synchronization' technique. It should be a 
%       number between 0 and 1 (The default value is 0.01). The deviation 
%       itself can be positive or negative.
% Outputs:
%   sa - Calculated synchronous average.
%   estmd_delays - Estimated delays between the segments of the signal.
%   syncd_sgmnts_mtrx - The synchronized segments of the signal.
% ----------------------------------------------------------------------- %

[technique, batch_size, num_itrtns, max_delay_deviation] = handle_varargin(varargin) ;

num_sgmnts = floor(length(sig) / N); % number of segments
sig = sig(1:num_sgmnts * N);
sgmnts_mtrx = reshape(sig, N, num_sgmnts); % segments matrix

if strcmp(technique, 'Simple')
    sa = mean(sgmnts_mtrx, 2);
    estmd_delays = zeros(num_sgmnts, 1);
    syncd_sgmnts_mtrx = sgmnts_mtrx;
elseif strcmp(technique, 'Batch')
    % calculate synchronous average using batches
    if num_sgmnts > batch_size
        residual_num_sgmnts = num_sgmnts - batch_size*floor(num_sgmnts / batch_size) ;
    else
        residual_num_sgmnts = 0 ;
    end % of if
    sa_left = mean(sgmnts_mtrx(:, 1:num_sgmnts-residual_num_sgmnts), 2);
    sa_right = mean(sgmnts_mtrx(:, residual_num_sgmnts+1:num_sgmnts), 2);
    sa = (sa_left + sa_right)/2 ;
    estmd_delays = zeros(num_sgmnts, 1);
    syncd_sgmnts_mtrx = sgmnts_mtrx;
elseif strcmp(technique, 'Sync to Ref Segment')
    % calculate synchronous average by synchronizing all the segments to
    % the first reference segment.
    ref_sgmnt = sgmnts_mtrx(:, 1);
    ref_sgmnt_mtrx = repmat(ref_sgmnt, 1, size(sgmnts_mtrx, 2));
    [syncd_sgmnts_mtrx, estmd_delays] = sync_sigs(sgmnts_mtrx, ref_sgmnt_mtrx);
    sa = mean(syncd_sgmnts_mtrx, 2);
elseif strcmp(technique, 'Mean - Sync Iterations')
    % calculate the synchronous average by mean - synchronizing iterations
    % and 'Sync to Ref Segment' as a first step.
    [sa, estmd_delays] = calc_synchronous_average(sig, N, 'Technique', 'Sync to Ref Segment');
    syncd_sgmnts_mtrx = sgmnts_mtrx;
    for itrtn_num = 1 : num_itrtns
        sa_mtrx = repmat(sa, 1, size(sgmnts_mtrx, 2));
        [syncd_sgmnts_mtrx, current_estmd_delays] = sync_sigs(syncd_sgmnts_mtrx, sa_mtrx);
        estmd_delays = mod(estmd_delays + current_estmd_delays, N);
        sa = mean(syncd_sgmnts_mtrx, 2);
    end
elseif strcmp(technique, 'Angular Synchronization')
    % calculate the synchronous average by angular synchronization and
    % 'Mean - Sync Iterations' and 'Sync to Ref Segment' as first steps.
    [~, estmd_delays, syncd_sgmnts_mtrx] = calc_synchronous_average(sig, N, ...
        'Technique', 'Mean - Sync Iterations', 'Number of iterations', num_itrtns);

    delays_between_sgmnts = estm_delays_of_all_pairs(syncd_sgmnts_mtrx, max_delay_deviation) ;
    current_estmd_delays = angular_synchronization(delays_between_sgmnts, N) ;
    estmd_delays = mod(estmd_delays + current_estmd_delays, N) ;
    syncd_sgmnts_mtrx = calc_sigs_after_delays(syncd_sgmnts_mtrx, current_estmd_delays) ;

    sa = mean(syncd_sgmnts_mtrx, 2);
end % of if

end % of calc_synchronous_average


% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %


function [technique, batch_size, num_itrtns, max_delay_deviation] = handle_varargin(varargin)
% handle_varargin handles the varargin of calc_synchronous_average
% funciton.
% ----------------------------------------------------------------------- %

varargin = varargin{1} ;

% assign the variable values using varargin
assigned_variables = {} ;
ind = 1 ;
while ~isempty(varargin)
    variable_name = varargin{1} ;
    variable_value = varargin{2} ;

    assigned_variables{ind} = variable_name ;

    if strcmp(variable_name, 'Technique')
        technique = variable_value ;
    elseif strcmp(variable_name, 'Batch size')
        batch_size = variable_value ;
    elseif strcmp(variable_name, 'Number of iterations')
        num_itrtns = variable_value ;
    elseif strcmp(variable_name, 'Maximal delay deviation')
        max_delay_deviation = variable_value ;
    end % of if

    varargin = varargin(3:end) ;
    ind = ind + 1 ;
end % of while

% set default values to unassigned variables
if ~ismember('Technique', assigned_variables)
    technique = 'Simple' ;
end % of if
if ~ismember('Batch size', assigned_variables)
    batch_size = inf ;
end % of if
if ~ismember('Number of iterations', assigned_variables)
    num_itrtns = 10 ;
end % of if
if ~ismember('Maximal delay deviation', assigned_variables)
    max_delay_deviation = 0.01 ;
end % of if

end % of handle_varargin
