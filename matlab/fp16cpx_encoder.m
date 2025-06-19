function binary_str = fp16cpx_encoder(decimal_num)
% FP16CPX_ENCODER
%   Converts a base 10 complex number into corresponding 
%   32-bit binary string with first 16 bits as real and last 16 bits as 
%   imaginary part using FP16_ENCODER function.

    % Conversion of real part
    binary_str(1:16) = fp16_encoder(real(decimal_num));
    % Conversion of imaginary part
    binary_str(17:32) = fp16_encoder(imag(decimal_num));
    
end