function [resamp_t, resamp_vib_sig, RFs] = angular_resampling(t_rps_sig, rps_sig, t, vib_sig)
% DESCRIPTION:
% This function calculates the new time vector, resampled with phase 
% increments instead with time. The phase signal is obtained by
% integration on the measured processed rps signal. This is the preliminary
% calculations before angular resampling of the vibration data.
% =====
% INPUTS:
% * t_rps_sig - The time vector of the processed rps signal.
% * rps_sig - The processed rps signal.
% * dt_vib_sig - The time resolution of the original vibration signal.
% =====
% OUTPUTS:
% * resamp_t - the new time vector, resampled with phase increments.
% * RFs - Sampling rate after angular resampling. RFs is the number of
% samples per one cycle of the respected shaft's speed.
% =====
% IN FUNCTION VARIABLES:
% * phase_sig - The phase signal obtained by integration on the rps sig.
% * phase_sig_resamp - The phase signal, built in such way that there are
% RFs samples in each cycle (for angular resampling).
% =====
% Created by Ph.D. student Lior Bachar, Gears Team, 2021.
% PHM Laboratory, Ben-Gurion University of the Negev, Be'er Sheva, Israel.
% Email: liorbac@post.bgu.ac.il
%%
dt = t(2) - t(1) ;
phase_sig = cumsum(rps_sig)*dt ; % integration on the rps signal in time.
phase_sig = phase_sig - phase_sig(1) ; % set the initial phase to be zero.
RFs = 2^nextpow2(1/dt/min(rps_sig)) ; % sampling rate after angular resampling.
phase_sig_resamp = linspace(0,floor(max(phase_sig)), RFs*floor(max(phase_sig)))' ; % the phase signal in fine resolution.
resamp_t = interp1(phase_sig,t_rps_sig, phase_sig_resamp, 'linear') ; % obtain the new time vector (i.e., the non-normalized cycle vector) by interpolation.
resamp_vib_sig = interp1(t, vib_sig, resamp_t, 'spline') ;

end

