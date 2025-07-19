function [snr_vctr, R_squared_vctr, num_sgmnts_for_sa_vctr] = calc_snr_and_R_squered_improvement_curves(...
    record_t, N, varargin)
% calc_snr_and_R_squered_improvement_curves calculates the SNR and R^2
% improvemnt curves.
% Inputs:
%   record_t - The record that is divided into signals.
%   N - Number of points in the synchronous average.
%   varargin - Additional input parameters.
% Outputs:
%   snr_vctr - The estimated SNR curve.
%   R_squared_vctr - The estimated R^2 curve.
%   num_sgmnts_for_sa_vctr - X axis of the curves.
% ----------------------------------------------------------------------- %

[technique, batch_size, num_itrtns, max_delay_deviation, num_sas_for_estmtn, num_sgmnts_for_sa_vctr] = ...
    handle_varargin(length(record_t), N, varargin) ;

snr_vctr = zeros(length(num_sgmnts_for_sa_vctr), 1) ;
R_squared_vctr = zeros(length(num_sgmnts_for_sa_vctr), 1) ;
ind = 1 ;
for num_sgmnts_for_sa = num_sgmnts_for_sa_vctr
    sas = zeros(N, num_sas_for_estmtn) ;
    sig_len = N * num_sgmnts_for_sa ;
    first_ind = 1 ; last_ind = sig_len ; step_size = floor(length(record_t)/num_sas_for_estmtn) ;
    for sa_num = 1:num_sas_for_estmtn
        sig = record_t(first_ind:last_ind) ;
        sas(:, sa_num) = calc_synchronous_average(sig, N, 'Technique', technique, ...
            'Batch size', batch_size, 'Number of iterations', num_itrtns, ...
            'Maximal delay deviation', max_delay_deviation);
        first_ind = first_ind + step_size ; last_ind = last_ind + step_size ;
    end % of for
    
    snr_vctr(ind) = estm_snr(sas) ;
    
    sgmnts_mtrx = reshape(record_t(1:N*floor(length(record_t)/N)), N, floor(length(record_t)/N)) ;
    R_squared_vctr(ind) = estm_R_squared(sas(:, 1), sgmnts_mtrx, floor(length(record_t)/N)) ;
    
    ind = ind + 1 ;
end % for

end % of calc_snr_and_R_squered_improvement_curves


% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %


function [technique, batch_size, num_itrtns, max_delay_deviation, num_sas_for_estmtn, num_sgmnts_for_sa_vctr] ...
    = handle_varargin(long_sig_len, N, varargin)
% handle_varargin handles the varargin of calc_snr_and_R_squered_improvement_curves
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
    elseif strcmp(variable_name, 'Number of SAs for Estimation')
        num_sas_for_estmtn = variable_value ;
    elseif strcmp(variable_name, 'Vector of Number of segments for SA')
        num_sgmnts_for_sa_vctr = variable_value ;
    end % of if

    varargin = varargin(3:end) ;
    ind = ind + 1 ;
end % of while

try
    max_num_sgmnts_for_sa = floor(long_sig_len / (N*num_sas_for_estmtn)) ;
catch
end
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
end
if ~ismember('Number of SAs for Estimation', assigned_variables)
    num_sas_for_estmtn = 10 ;
    max_num_sgmnts_for_sa = floor(long_sig_len / (N*num_sas_for_estmtn)) ;
end % of if
if ~ismember('Vector of Number of segments for SA', assigned_variables)
    num_sgmnts_for_sa_vctr = [1:max_num_sgmnts_for_sa] ;
end % of if

if floor(long_sig_len / (N*num_sas_for_estmtn)) < max(num_sgmnts_for_sa_vctr)
    warning(['The maximum number of segments for SA should not exceed ', ...
        num2str(max_num_sgmnts_for_sa),'. Therefore, all values larger than ', ...
        num2str(max_num_sgmnts_for_sa),' were removed from the vector of number of segments for SA.'])
    ind = 1 ;
    while ind <= length(num_sgmnts_for_sa_vctr)
        if num_sgmnts_for_sa_vctr(ind) > max_num_sgmnts_for_sa
            num_sgmnts_for_sa_vctr(ind) = [] ;
        else
            ind = ind + 1 ;
        end % of if
    end % of while
end % of if

end % of handle_varargin