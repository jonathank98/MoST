% Turns an unsigend value to a signed value
% data_out = filter_unsigned2signed(data_in)
%   data_in: a two-dimensional array whose values are to be converted from
%     unsigned to signed
%   fields: fields apply the filter to
%   bits: defaults to 16
%   data_out: the converted output
function data_out = filter_unsigned2signed(data_in, fields, bits)
    if(nargin < 3)
        bits = 16;
    end
    max_num = 2^(bits-1);
    
    data_out = data_in;
    idx = data_out >= max_num;
    idx2 = data_in;
    idx2(:) = false;
    idx2(:, fields) = true;
    idx = idx & idx2;
%     data_out(idx) = max_num*2 - data_out(idx);
    data_out(idx) = data_out(idx) - 2^bits;
end