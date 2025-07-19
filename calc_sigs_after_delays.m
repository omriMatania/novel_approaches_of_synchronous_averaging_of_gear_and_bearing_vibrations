function [delayed_sigs_mtrx] = calc_sigs_after_delays(sigs_mtrx, delays)
% calc_sigs_after_delays calculates the signals in "sigs_mtrx" after the
% "delays." Each signal is in a different column, and there is no relationship
% between different columns.
% Inputs:
%   sigs_mtrx - Signals matrix. Each signal is in a different column.
%   delays - Delays to propagate the "sigs_mtrx."
% Outputs:
%   delayed_sigs_mtrx - "sigs_mtrx" after propagation with the delays.
% ----------------------------------------------------------------------- %

N = size(sigs_mtrx, 1); % number of samples
M = size(sigs_mtrx, 2); % number of examples

sigs_mtrx_f = fft(sigs_mtrx); % convert to the frequency domain

% calculating the exponent related to the delays.
delays_mtrx = repmat(delays.', N, 1);
num_mtrx = repmat([0 : 1 : N - 1].' / N, 1, M);
exp_f = exp(2 * pi * 1i * delays_mtrx .* num_mtrx);
if mod(N, 2) == 0
    exp_f = [exp_f(1 : N / 2 + 1, :) ; conj(flipud(exp_f(2 : N / 2, :)))] ;
elseif mod(N, 2) == 1
    exp_f = [exp_f(1 : floor(N / 2) + 1, :) ; conj(flipud(exp_f(2 : floor(N / 2) + 1, :)))] ;
end % of if

% calculating the signals after the delays
delayed_synced_sigs_mtrx_f = sigs_mtrx_f .* exp_f;
delayed_sigs_mtrx = real(ifft(delayed_synced_sigs_mtrx_f)); % convert to the time domain

end % end of calc_sig_after_delays

