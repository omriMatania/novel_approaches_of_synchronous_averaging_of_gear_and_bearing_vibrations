function [ftf, bsf, bpfo, bpfi] = calc_bearing_tones(shaft_speed, number_rolling_elements, ...
    rolling_element_diameter, pitch_diameter, bearing_contact_angle)
% calc_bearing_tones calculates the bearing tones, namely the fundamental train frequency (FTF, also know as cage speed), 
% ball-spin frequency (BSF), ball-pass frequency outer (BPFO) and the ball-pass frequency inner (BPFI), 
% corresponding to the optional cage fault, rolling element spall, outer race spall and inner race spall. 
% Inputs:
%   shaft_speed - Bearing shaft speed.
%   number_rolling_elements - Number of rlling elements of the bearing.
%   rolling_element_diameter - Rolling element diameter.
%   pitch_diameter - Pitch diameter.
%   bearing_contact_angle - Bearing contact angle.
% Outputs:
%   ftf - Fundamental train frequency.
%   bsf - Ball-spin frequency.
%   bpfo - ball-pass frequency outer race.
%   bpfi - Ball-pass frequency inner race.
% ----------------------------------------------------------------------- %

coeff_1 = (shaft_speed / 2) ;
coeff_2 = (rolling_element_diameter / pitch_diameter) * cos(bearing_contact_angle) ;

ftf = coeff_1 * (1 - coeff_2) ;
bsf = (pitch_diameter / rolling_element_diameter) * coeff_1 * (1 - coeff_2^2) ;
bpfo = number_rolling_elements * coeff_1 * (1 - coeff_2) ;
bpfi = number_rolling_elements * coeff_1 * (1 + coeff_2) ;

end % of calc_bearing_tones

