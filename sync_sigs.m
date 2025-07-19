function [syncd_sigs_mtrx, estmd_delays] = sync_sigs(sigs_mtrx_to_sync, ...
    ref_sigs_mtrx, max_delay_deviation)
% sync_sigs synchronizes the signals in "sigs_mtrx_to_sync" to the reference
% signals in "ref_sigs_mtrx" by minimizing the mean square error. Each
% column in "sigs_mtrx_to_sync" is synchronized to its corresponding
% columns in "ref_sigs_mtrx". There is no relation between different
% columns.
% Inputs:
%   sigs_mtrx_to_sync - Signals to be synchronized with the signals in 
%       "ref_sigs_mtrx". Each signal is in a different column.
%   ref_sigs_mtrx - Reference signals to which the signals in
%       "sigs_mtrx_to_sync" are synchronized.
%   max_delay_deviation - Maximum allowable delay between the signals 
%       within each pair. It should be a number between 0 and 1. The 
%       deviation itself can be positive or negative.
% Outputs:
%   syncd_sigs_mtrx - Synchronized signals matrix of "sigs_mtrx_to_sync".
%   estmd_delays - Estimated delays between "sigs_mtrx_to_sync" and
%   "ref_sigs_mtrx".
% ----------------------------------------------------------------------- %

if nargin < 3
    max_delay_deviation = 1 ;
end % of if

estmd_delays = estm_delays_by_cross_correlation(sigs_mtrx_to_sync, ...
    ref_sigs_mtrx, max_delay_deviation) ;

syncd_sigs_mtrx = calc_sigs_after_delays(sigs_mtrx_to_sync, estmd_delays);

end % of sync_sigs
