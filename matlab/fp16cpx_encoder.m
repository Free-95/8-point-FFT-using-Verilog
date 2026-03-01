function hex_str = fp16cpx_encoder(decimal_num)
% FP16CPX_ENCODER
%   Converts a base 10 complex number into the corresponding 
%   8-character hex string with the first 4 characters as real and the 
%   last 4 characters as the imaginary part.

    % Conversion of real part
    real_hex = fp16_encoder(real(decimal_num));
    % Conversion of imaginary part
    imag_hex = fp16_encoder(imag(decimal_num));
    
    % Complex string concatenation
    hex_str = [real_hex, imag_hex];
end