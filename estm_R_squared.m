function [mean_R_squared] = estm_R_squared(sas, sigs_mtrx, num_sigs_for_sa)
% estm_R_squared estimates R squared. For each synchronous avearge in "sas"
% matrix, the funciton estimates the explined noise of the corresponding
% signals in "sigs_mtrx", relative to their calculated synchronous avearge.
% Inputs:
%   sas - Synchronous averages matrix. Each column corresponds to a 
%       different synchronous average.
%   sigs_mtrx - Signals matrix.
%   num_sigs_for_sa - number of signals used to caclulate each synchronous 
%       avearge.
% Outputs:
%   mean_R_squared - mean estimated R_squared.
% ----------------------------------------------------------------------- %

num_sas = size(sas, 2) ; % number of synchronous averages
R_squared_vctr = zeros(num_sas, 1) ;

for ii = 1 : num_sas
    sa_ii = sas(:, ii) ;
    sigs_ii = sigs_mtrx(:, (ii-1)*num_sigs_for_sa+1 : ii*num_sigs_for_sa) ;

    R_squared_vctr_ii = zeros(num_sigs_for_sa, 1) ;
    for jj = 1 : num_sigs_for_sa
        sig_ii_jj = sigs_ii(:, jj) ;
        sig_ii_jj = sync_sigs(sig_ii_jj, sa_ii) ;
        sig_mse = sum((sig_ii_jj).^2) ;
        noise_mse = sum((sig_ii_jj - sa_ii).^2) ;
        R_squared = 1 - (noise_mse / sig_mse) ;
        R_squared_vctr_ii(jj) = R_squared ;
    end % of for

    R_squared_vctr(ii) = mean(R_squared_vctr_ii) ;
end % of for

mean_R_squared = mean(R_squared_vctr) ;

end % of estm_R_square