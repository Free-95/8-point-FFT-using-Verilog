function binary_str = fp16_encoder(decimal_num)
% FP16_ENCODER 
%   Converts the input DECIMAL_NUM (a decimal floating-point number) 
%   into its 16-character binary string representation following the 
%   IEEE 754 half-precision (binary16) format.
%
%   Input:
%     decimal_num - The decimal number to convert.
%
%   Output:
%     binary_str - A 16-character string of '0's and '1's representing
%                  the 16-bit floating-point binary number.
%
%   Example:
%     fp16_encoder(1.0) returns '0011110000000000'
%     fp16_encoder(-1.0) returns '1011110000000000'
%     fp16_encoder(0.0) returns '0000000000000000'
%     fp16_encoder(Inf) returns '0111110000000000'
%     fp16_encoder(NaN) returns '0111110000000001' (example NaN)

% Define IEEE 754 half-precision parameters
exponent_bits = 5;
mantissa_bits = 10;
exponent_bias = 2^(exponent_bits - 1) - 1; % For 5-bit exponent, bias is 15
max_exponent_val = 2^exponent_bits - 1;    % Max exponent value (31)

% Initialize binary string components
sign_bit = '0';
exponent_binary = '';
mantissa_binary = '';

% Handle special values
if isnan(decimal_num)
    sign_bit = '0'; % Sign can be anything for NaN, typically 0
    exponent_binary = dec2bin(max_exponent_val, exponent_bits); % All ones
    mantissa_binary = dec2bin(1, mantissa_bits); % Non-zero mantissa (e.g., 1)
    binary_str = [sign_bit, exponent_binary, mantissa_binary];
    return;
elseif isinf(decimal_num)
    if decimal_num < 0
        sign_bit = '1';
    else
        sign_bit = '0';
    end
    exponent_binary = dec2bin(max_exponent_val, exponent_bits); % All ones
    mantissa_binary = dec2bin(0, mantissa_bits); % All zeros
    binary_str = [sign_bit, exponent_binary, mantissa_binary];
    return;
elseif decimal_num == 0
    if decimal_num < 0 % Handle negative zero if input supports it (-0.0)
        sign_bit = '1';
    else
        sign_bit = '0';
    end
    exponent_binary = dec2bin(0, exponent_bits); % All zeros
    mantissa_binary = dec2bin(0, mantissa_bits); % All zeros
    binary_str = [sign_bit, exponent_binary, mantissa_binary];
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
    % Find the exponent (E) such that 2^E <= decimal_num < 2^(E+1)
    % Or, find E such that decimal_num = M * 2^E where 1 <= M < 2
    E = floor(log2(decimal_num));

    % Normalized number (1 <= M < 2)
    % M = decimal_num / 2^E
    % Fractional part of mantissa comes from M - 1
    if E >= -exponent_bias + 1 % Check if it can be represented as a normalized number
        % Normalized form: (1.fraction) * 2^E
        % exponent_actual = E
        exponent_val_raw = E + exponent_bias;

        % Check for overflow (exponent too large for normalized form)
        if exponent_val_raw >= max_exponent_val
            % Set to infinity if positive, or negative infinity if original was negative
            if sign_bit == '0'
                binary_str = '0111110000000000'; % Positive Inf
            else
                binary_str = '1111110000000000'; % Negative Inf
            end
            return;
        end

        mantissa_fraction = decimal_num / (2^E) - 1;
        mantissa_val = round(mantissa_fraction * (2^mantissa_bits)); % Convert fractional part to integer

        % Ensure mantissa_val does not overflow if rounding pushes it
        % If mantissa_val becomes 2^mantissa_bits due to rounding,
        % it means the number rounded up to the next power of 2,
        % so increment exponent and set mantissa to 0.
        if mantissa_val == 2^mantissa_bits
            mantissa_val = 0;
            exponent_val_raw = exponent_val_raw + 1;
        end
        
        % Final check for overflow after mantissa rounding adjustment
        if exponent_val_raw >= max_exponent_val
            if sign_bit == '0'
                binary_str = '0111110000000000'; % Positive Inf
            else
                binary_str = '1111110000000000'; % Negative Inf
            end
            return;
        end

        exponent_binary = dec2bin(exponent_val_raw, exponent_bits);
        mantissa_binary = dec2bin(mantissa_val, mantissa_bits);

    else % Denormalized number
        % Exponent is all zeros (raw value 0), actual exponent is 1 - bias
        % decimal_num = (0.fraction) * 2^(1 - bias)
        % fraction = decimal_num / 2^(1 - bias)
        % This also needs to be limited by precision, so we multiply by 2^mantissa_bits
        exponent_val_raw = 0; % All zeros
        
        denormal_power = 2^(1 - exponent_bias);
        mantissa_val = round((decimal_num / denormal_power) * (2^mantissa_bits));

        % Check for underflow (denormalized value too small)
        if mantissa_val == 0
            % Round down to zero
            if sign_bit == '0'
                binary_str = '0000000000000000'; % Positive zero
            else
                binary_str = '1000000000000000'; % Negative zero
            end
            return;
        end

        exponent_binary = dec2bin(exponent_val_raw, exponent_bits);
        mantissa_binary = dec2bin(mantissa_val, mantissa_bits);
    end
end

% Assemble the 16-bit binary string
binary_str = [sign_bit, exponent_binary, mantissa_binary];

end
