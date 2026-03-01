function decimal_num = fp16cpx_decoder(hex_str)
% FP16CPX_DECODER
%   Converts an 8-character hex string of a complex number with 
%   the first 4 characters as real and the last 4 characters as 
%   the imaginary part into the corresponding complex number in base 10.
    
    % Input validation
    if ~ischar(hex_str) || length(hex_str) ~= 8 || ~all(isstrprop(hex_str, 'xdigit'))
        error('Input must be an 8-character hex string (e.g., ''3c003c00'').');
    end

    % Conversion of real part
    real_part = fp16_decoder(hex_str(1:4));
    % Conversion of imaginary part
    imag_part = fp16_decoder(hex_str(5:8));
    
    % Complex result assignment
    decimal_num = real_part + imag_part * 1j;
end