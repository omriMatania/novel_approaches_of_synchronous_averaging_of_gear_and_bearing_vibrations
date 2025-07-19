function [snr, syncd_sas] = estm_snr(sas)
% estm_snr estimates the signal-to-noise ratio (SNR) between the synchronous
% averages. Each column in the "sas" matrix corresponds to a different
% synchronous average.
% Inputs:
%   sas - Synchronous averages matrix. Each column corresponds to a 
%       different synchronous average.
% Outputs:
%   snr - Estimated SNR.
%   syncd_sas - Synchronized synchronous averages.
% ----------------------------------------------------------------------- %

num_sas = size(sas, 2) ; % number of synchronous averages

% synchronize the synchronous averages to the first synchronous average,
% helps to plot the synchronous averages with the smae phase.
syncd_sas = sync_sigs(sas, repmat(sas(:, 1), 1, num_sas)) ;

mean_rms = mean(sum(sas.^2, 1)) ; % mean RMS

mse = zeros((num_sas*num_sas-num_sas)/2, 1) ; % pre-allocation
ind = 1 ;
for ii = 1 : 1 : num_sas
    for jj = ii+1 : 1 : num_sas
        mse(ind) = calc_mse_between_sigs(sas(:, ii), sas(:, jj), 'Synchronize Signals') ;
        ind = ind + 1 ;
    end % of for
end % of for
mean_mse = mean(mse) ;

% Signal-to-noise ratio. The division by 2 is to reduce the estimated MSE
% by a factor of 2 because it is estimated between the two signals (thus, 
% before the division the noise is considered twice) and not relative to 
% the mean.
snr = sqrt(mean_rms / (mean_mse/2)) ;

end % of estm_snr