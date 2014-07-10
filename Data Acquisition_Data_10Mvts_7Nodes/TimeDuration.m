
for i = 1 : 13
    Time_Duration2(i) = (cursor_info2(1,2*i-1).Position(1)- cursor_info2(1,2*i).Position(1))/50;
end

for i = 1 : 11
    Time_Duration3(i) = (cursor_info3(1,2*i-1).Position(1)- cursor_info3(1,2*i).Position(1))/50;
end

for i = 1 : 7
    Time_Duration4(i) = (cursor_info4(1,2*i-1).Position(1)- cursor_info4(1,2*i).Position(1))/50;
end