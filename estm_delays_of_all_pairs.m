function delays_between_sigs = estm_delays_of_all_pairs(sigs_mtrx, max_delay_deviation)
% estm_delays_of_all_pairs estimates the delays of all pairs in "sigs_mtrx"
% using cross-correlation. The function constrains the maximum delay within
% each pair using max_delay_deviation.
% Inputs:
%   sigs_mtrx - Signals matrix. Each column represents a different signal.
%   max_delay_deviation - Maximum allowable delay between the signals 
%       within each pair. It should be a number between 0 and 1. The 
%       deviation itself can be positive or negative.
% Outputs:
%   delays_between_sigs - A matrix of delays between the signals. Each cell
%       (ii, jj) corresponds to the delays between signal ii and
%       signal jj.
% ----------------------------------------------------------------------- %

if nargin < 2
    max_delay_deviation = 1 ;
end % of if

num_sigs = size(sigs_mtrx, 2) ; % number of signals
delays_between_sigs = zeros(num_sigs, num_sigs) ;

for ii = 1 : num_sigs
    sig_ii = sigs_mtrx(:, ii) ;
    sig_ii_mtrx = repmat(sig_ii, 1, num_sigs-ii) ;
    estmd_delays_ii = estm_delays_by_cross_correlation(sigs_mtrx(:, ii+1:end), ...
        sig_ii_mtrx, max_delay_deviation) ;

    delays_between_sigs(ii, ii+1:end) = estmd_delays_ii ;
    delays_between_sigs(ii+1:end, ii) = estmd_delays_ii ;
end % of for

end % of estm_delays_of_all_pairs