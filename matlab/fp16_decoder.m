function decimal_num = fp16_decoder(binary_str)
% FP16_DECODER 
%   Converts the input BINARY_STR (a 16-character string representing a 
%   16-bit binary number in IEEE 754 half-precision format) into its 
%   equivalent decimal floating-point number.
%
%   Input:
%     binary_str - A 16-character string of '0's and '1's.
%
%   Output:
%     decimal_num - The decimal equivalent of the binary string.
%
%   Example:
%     fp16_decoder('0011110000000000') returns 1.0 (positive 1)
%     fp16_decoder('1011110000000000') returns -1.0 (negative 1)
%     fp16_decoder('0000000000000000') returns 0.0 (positive zero)
%     fp16_decoder('0111110000000000') returns Inf (positive infinity)
%     fp16_decoder('0111110000000001') returns NaN (Not a Number)

% Input validation
if ~ischar(binary_str) || length(binary_str) ~= 16 || ~all(ismember(binary_str, '01'))
    error('Input must be a 16-character binary string (e.g., ''0111101000000000'').');
end

% Define IEEE 754 half-precision parameters
exponent_bits = 5;
mantissa_bits = 10;
exponent_bias = 2^(exponent_bits - 1) - 1; % For 5-bit exponent, bias is 2^(5-1) - 1 = 15

% Parse the bits
sign_bit_str = binary_str(1);
exponent_str = binary_str(2 : 1 + exponent_bits);
mantissa_str = binary_str(2 + exponent_bits : end);

% Convert binary strings to decimal integers
sign_val = bin2dec(sign_bit_str); % 0 or 1
exponent_val_raw = bin2dec(exponent_str);
mantissa_val = bin2dec(mantissa_str);

% Determine the sign
sign_multiplier = (-1)^sign_val;

% Handle special values
if exponent_val_raw == 2^exponent_bits - 1 % All ones in exponent (31 for 5-bit)
    if mantissa_val == 0
        % Infinity (positive or negative)
        decimal_num = sign_multiplier * inf;
    else
        % NaN (Not a Number)
        decimal_num = NaN;
    end
elseif exponent_val_raw == 0 % All zeros in exponent
    if mantissa_val == 0
        % Zero (positive or negative)
        decimal_num = sign_multiplier * 0.0;
    else
        % Denormalized number
        % The implicit leading '1' is '0' for denormalized numbers
        % Formula: (-1)^sign * 2^(1 - bias) * (0 + fractional_mantissa)
        fractional_mantissa = mantissa_val / (2^mantissa_bits);
        decimal_num = sign_multiplier * (2^(1 - exponent_bias)) * fractional_mantissa;
    end
else
    % Normalized number
    % Formula: (-1)^sign * 2^(exponent_val - bias) * (1 + fractional_mantissa)
    exponent_actual = exponent_val_raw - exponent_bias;
    fractional_mantissa = mantissa_val / (2^mantissa_bits);
    decimal_num = sign_multiplier * (2^exponent_actual) * (1 + fractional_mantissa);
end

end
