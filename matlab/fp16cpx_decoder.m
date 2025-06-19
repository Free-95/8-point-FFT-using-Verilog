function decimal_num = fp16cpx_decoder(binary_str)
% FP16CPX_DECODER
%   Converts a 32-bit binary string of complex number with 
%   first 16 bits as real and last 16 bits as imaginary part 
%   into corresponding complex number in base 10.
    
    % Input validation
    if ~ischar(binary_str) || length(binary_str) ~= 32 || ~all(ismember(binary_str, '01'))
        error('Input must be a 32-character binary string (e.g., ''01111010000000000111101000000000'').');
    end

    % Conversion of real part
    real = fp16_decoder(binary_str(1:16));
    % Conversion of imaginary part
    imag = fp16_decoder(binary_str(17:32));
    
    % Complex result assignment
    decimal_num = real + imag*1j;
end