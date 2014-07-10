function clist = comlist()

% Get serial port status
[s, res] = dos('C:\Windows\System32\mode');
% [s, res] = dos('mode');

% parse results, and take out serial ports 1 & 2 
com_list = regexp(res, 'device COM([0-9]*):', 'tokens'); 
com_list = cellfun(@(x) str2num(x{1}),com_list);
%turn the results into numbers for com ports 
com_list = com_list(~ismember(com_list,[1 2])); 
% remove com ports 1 & 2

% turn into cell array of com_ports
clist={};
    for idx = 1:numel(com_list)
       clist{idx} = sprintf('COM%i',com_list(idx))
    end

end
