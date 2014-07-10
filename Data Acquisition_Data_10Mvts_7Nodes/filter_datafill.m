% Fills in missing data in sensor data stream. Data must be from a single
%   sensor node
% data_out = filter_datafill(data_in, col_packet_num, interpolation)
%   data_in: a two-dimensional array. columns represent individual sensor
%     streams. One column is the packet number. Packet numbers are assumed
%     to be strictly increasing
%   col_packet_num: the column containing the packet numbers
%   interpolation: type of interpolation. Defaults to 'nearest'. Can have
%     any value listed in 'interp1' documentation 
%   data_out: the same thing with missing values filled in
function data_out = filter_datafill(data_in, col_packet_num, interpolation)

if(nargin<3)
    interpolation='nearest';
end

% Check to make sure data is non-increasing
if(sum( ~(data_in(1:end-1, col_packet_num) < data_in(2:end,col_packet_num)) ) > 0)
    % This isn't non-increasing
    disp('Error: filter_datafill: Data is not strictly increasing!');
    data_out=data_in;
    return
end

% figure out missing values
missing_packets = 1:data_in(end,col_packet_num)-data_in(1,col_packet_num)+1;
missing_packets(data_in(:,col_packet_num)-data_in(1,col_packet_num)+1)=0;
missing_packets=missing_packets(missing_packets ~= 0)+data_in(1,col_packet_num)-1;
if(numel(missing_packets)==0)
    data_out=data_in;
    return;
end

% interpolate
yi=interp1(data_in(:,col_packet_num), data_in, missing_packets,interpolation);
yi(:,col_packet_num) = missing_packets;

% Combine interpolated and regular data
data_out = sortrows([data_in;yi], col_packet_num);

end
