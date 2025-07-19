function estmd_delays = estm_delays_by_cross_correlation(sigs_mtrx_to_sync, ...
    ref_sigs_mtrx, max_delay_deviation)
% estm_delays_by_cross_correlation estimates the delays between the signals
% in "sigs_mtrx_to_sync" and the reference signals in "ref_sigs_mtrx" by 
% minimizing the mean square error, which is actually cross-correlation. 
% Each delay is estimated between the columns in "sigs_mtrx_to_sync" and 
% their corresponding columns in "ref_sigs_mtrx." There is no relation 
% between different columns.
% Inputs:
%   sigs_mtrx_to_sync - Signals for which their delays with the signals in 
%       "ref_sigs_mtrx" should be estimated. Each signal is in a different
%       column.
%   ref_sigs_mtrx - Reference signals to which the delays of the signals in
%       "sigs_mtrx_to_sync" are estimated.
%   max_delay_deviation - Maximum allowable delay between the signals 
%       within each pair. It should be a number between 0 and 1. The 
%       deviation itself can be positive or negative.
% Outputs:
%   estmd_delays - Estimated delays between "sigs_mtrx_to_sync" and
%   "ref_sigs_mtrx."
% ----------------------------------------------------------------------- %

N = size(sigs_mtrx_to_sync, 1) ; % number of samples
num_sigs = size(sigs_mtrx_to_sync, 2) ; % number of signals
max_delay_deviation = round(N*max_delay_deviation) ; % convert to an integer.

sigs_mtrx_to_sync_f = fft(sigs_mtrx_to_sync); % convert to the frequency domain
ref_sigs_mtrx_f = fft(ref_sigs_mtrx); % convert to the frequency domain

% calculate the mean square error as a function of the delays
mse_as_function_of_delays = -real(ifft(sigs_mtrx_to_sync_f .* conj(ref_sigs_mtrx_f)));

% positive and negative indices inside the deviation region. Negative 
% delays are actually represented in the vector using their positive value 
% equal to mod(delay, N). So, for example, -1 is represented by N.
% positive_inds = repmat([1:min([max_delay_deviation+1, ceil(N/2)])].', 1, num_sigs) ;
% negative_inds = repmat([max([N-max_delay_deviation+1, ceil(N/2)+1]):N].', 1, num_sigs) ;
% inds_inside_deviation_range = [positive_inds; negative_inds] ;
positive_inds = [1:min([max_delay_deviation+1, ceil(N/2)])].' ;
negative_inds = [max([N-max_delay_deviation+1, ceil(N/2)+1]):N].' ;
inds_inside_deviation_range = [positive_inds; negative_inds] ;
mse_as_function_of_delays = mse_as_function_of_delays(inds_inside_deviation_range, :) ;

% estimate the delays based on the minimal mean square error
[~, estmd_delays] = min(mse_as_function_of_delays);
estmd_delays = (estmd_delays - 1).';

% correct the delay to its rela value if it is negative
for sig_num = 1 : num_sigs
    if estmd_delays(sig_num) > max(positive_inds-1)
        estmd_delays(sig_num) = estmd_delays(sig_num) + ...
            min(negative_inds) - max(positive_inds) - 1 ;
    end % of if
end % of for

end % of estm_delays_by_cross_correlation