function hex_str = fp16_encoder(decimal_num)
% FP16_ENCODER 
%   Converts the input DECIMAL_NUM (a decimal floating-point number) 
%   into its 4-character hexadecimal string representation following the 
%   IEEE 754 half-precision (binary16) format.
%
%   Input:
%     decimal_num - The decimal number to convert.
%
%   Output:
%     hex_str - A 4-character hex string representing
%               the 16-bit floating-point number.

% Define IEEE 754 half-precision parameters
exponent_bits = 5;
mantissa_bits = 10;
exponent_bias = 2^(exponent_bits - 1) - 1; % For 5-bit exponent, bias is 15
max_exponent_val = 2^exponent_bits - 1;    % Max exponent value (31)

% Helper function to convert 16-character binary string to 4-character hex
bin2hex = @(b) dec2hex(bin2dec(b), 4);

% Initialize binary string components
sign_bit = '0';
exponent_binary = '';
mantissa_binary = '';

% Handle special values
if isnan(decimal_num)
    sign_bit = '0'; % Sign can be anything for NaN, typically 0
    exponent_binary = dec2bin(max_exponent_val, exponent_bits); % All ones
    mantissa_binary = dec2bin(1, mantissa_bits); % Non-zero mantissa (e.g., 1)
    hex_str = bin2hex([sign_bit, exponent_binary, mantissa_binary]);
    return;
elseif isinf(decimal_num)
    if decimal_num < 0
        sign_bit = '1';
    else
        sign_bit = '0';
    end
    exponent_binary = dec2bin(max_exponent_val, exponent_bits); % All ones
    mantissa_binary = dec2bin(0, mantissa_bits); % All zeros
    hex_str = bin2hex([sign_bit, exponent_binary, mantissa_binary]);
    return;
elseif decimal_num == 0
    if decimal_num < 0 % Handle negative zero if input supports it (-0.0)
        sign_bit = '1';
    else
        sign_bit = '0';
    end
    exponent_binary = dec2bin(0, exponent_bits); % All zeros
    mantissa_binary = dec2bin(0, mantissa_bits); % All zeros
    hex_str = bin2hex([sign_bit, exponent_binary, mantissa_binary]);
    return;
end

% Determine sign bit
if decimal_num < 0
    sign_bit = '1';
    decimal_num = -decimal_num; % Work with absolute value for magnitude calculation
else
    sign_bit = '0';
end

% Calculate exponent and mantissa for normalized/denormalized numbers
if decimal_num > 0
    E = floor(log2(decimal_num));

    if E >= -exponent_bias + 1 
        exponent_val_raw = E + exponent_bias;

        if exponent_val_raw >= max_exponent_val
            if sign_bit == '0'
                hex_str = bin2hex('0111110000000000'); % Positive Inf
            else
                hex_str = bin2hex('1111110000000000'); % Negative Inf
            end
            return;
        end

        mantissa_fraction = decimal_num / (2^E) - 1;
        mantissa_val = round(mantissa_fraction * (2^mantissa_bits)); 

        if mantissa_val == 2^mantissa_bits
            mantissa_val = 0;
            exponent_val_raw = exponent_val_raw + 1;
        end
        
        if exponent_val_raw >= max_exponent_val
            if sign_bit == '0'
                hex_str = bin2hex('0111110000000000'); % Positive Inf
            else
                hex_str = bin2hex('1111110000000000'); % Negative Inf
            end
            return;
        end

        exponent_binary = dec2bin(exponent_val_raw, exponent_bits);
        mantissa_binary = dec2bin(mantissa_val, mantissa_bits);

    else % Denormalized number
        exponent_val_raw = 0; % All zeros
        
        denormal_power = 2^(1 - exponent_bias);
        mantissa_val = round((decimal_num / denormal_power) * (2^mantissa_bits));

        if mantissa_val == 0
            if sign_bit == '0'
                hex_str = bin2hex('0000000000000000'); % Positive zero
            else
                hex_str = bin2hex('1000000000000000'); % Negative zero
            end
            return;
        end

        exponent_binary = dec2bin(exponent_val_raw, exponent_bits);
        mantissa_binary = dec2bin(mantissa_val, mantissa_bits);
    end
end

% Assemble the 16-bit binary string and convert to hex
hex_str = bin2hex([sign_bit, exponent_binary, mantissa_binary]);

end