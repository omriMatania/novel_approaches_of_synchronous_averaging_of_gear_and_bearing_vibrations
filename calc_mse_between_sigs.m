function [mse] = calc_mse_between_sigs(sig_1, sig_2, sync_signal)
% calc_mse_between_sigs calculates the mean squared error (MSE) between the
% signals "sig_1" and "sig_2". When sync_signal is set to 'Synchronize
% Signals', the signals are synchronized before the MSE is calculated.
% Inputs:
%   sig_1 - Signal 1.
%   sig_2 - Signal 2.
%   sync_signal - Synchronize the signals before MSE calculation.
% Outputs:
%   mse - The calculated MSE.
% ----------------------------------------------------------------------- %

if nargin < 3
    sync_signal = '' ;
end % of if

if strcmp(sync_signal, 'Synchronize Signals')
    sig_1 = sync_sigs(sig_1, sig_2) ;
end % of if

mse = sum((sig_1-sig_2).^2) ;

end % of calc_mse_between_sigs