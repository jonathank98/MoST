%% Script for Renaming files generated as output of the annotation phase 
%Outputs text files of annotation phase has the name like 
%'annotated_xy@m000a_s0b_m0f_n0c' and video with name like 'm00xym00f'.
%The number indicated with xy are useful to distinguish different execution
%of the same movements.
%However, with this sintax,files cannot be read by VibMotion2 because it 
%require text files with name like 'm000a_s0b_m0f_n0c' and video with 
%name like 'm00xy_s0b_m0f_c01'.   
%This script changes the names of the files to the correct format, saving
%the information relative to the number of isolated movements (field 'xy')
%will be placed in the first 'm' field

% select the interested video/textual file or files
[fileName,PathName,FilterIndex]=uigetfile({'*.txt'; '*.avi'},'MultiSelect','on');
if iscell(fileName)
    nbfiles = length(fileName);
elseif fileName ~= 0
    nbfiles = 1;
else
    nbfiles = 0;
end
fprintf (' number of files open') ;
disp(nbfiles)

% replace one part of the file name with another string with the command
% strrep(path_of_file_and_name,'string old','string desidered')

% distinguish between multiple files and single file
if nbfiles ~= 1
    for i=1:nbfiles
        path=strcat(PathName,fileName{i});
        [a b c] = fileparts(path);
        if strcmp(c,'.txt')
            index=strfind(fileName{i},'@')%find the end of the prefix
            %understand how many 0 are needed in field m
            bolean=(strcmp((fileName{i}(index-2)),'_')) 
             if bolean>0
   %movement number<10 , 3 zeros required to reach the amount of 4 numbers          
            newMovement=strcat('m000',fileName{i}(index-1))
             else
  %movement number>10 , 2 zeros required to reach the amount of 4 numbers
                newMovement=strcat('m00',fileName{i}(index-2:index-1))
             end
            
            % erase prefix replacing 'annotated_2' with blank string
            newlabel = strrep(fileName{i}, fileName{i}(1:index), '') ;
% replace old prefix with different number of movement (first occurrence 
% of field 'm000x' will replace the information previously given by 
%'annotated_x@')
           
            newlabel = strrep(newlabel, 'm0001', newMovement);
            eval(['!rename "',fileName{i},'" ',newlabel]);
        elseif strcmp(c,'.avi')
           
            bolean2=(strcmp((fileName{i}(5)),'m'))
            %understand how many 0 are needed in field m
             if bolean2>0 %movement number<10
            
newlabel=strcat('m00',fileName{i}(3:4),'_s01_m',fileName{i}(7:8),'_c01.avi')
             else 
newlabel=strcat('m00',fileName{i}(4:5),'_s01_m',fileName{i}(8:9),'_c01.avi')
            
             end
             eval(['!rename "',fileName{i},'" ',newlabel])
        end
    end
else
    %one file to modified,same operations previously explained
    path=strcat(PathName,fileName);
    [a b c] = fileparts(path);
    if strcmp(c,'.txt')
        index=strfind(fileName,'@')
            bolean=(strcmp((fileName(index-2)),'_')) 
            %understand how many 0 are needed in field m
             if bolean>0 
                 %movement number<10
            newMovement=strcat('m000',fileName(index-1))
            else
                newMovement=strcat('m00',fileName(index-2:index-1))
             end
            
            % erase prefix replacing 'annotated_2' with blank string
            newlabel = strrep(fileName, fileName(1:index), '') ;
            % replace old prefix with different number of movement (first
 % occurrence of field 'm000x' will replace the information 
 % previously given by 'annotated_x@')           
            newlabel = strrep(newlabel, 'm0001', newMovement);
            eval(['!rename "',fileName,'" ',newlabel]);
    elseif strcmp(c,'.avi')
        bolean2=(strcmp((fileName(5)),'m'))
        if bolean2>0 %movement number<10
            
newlabel = strcat('m00',fileName(3:4),'_s01_m',fileName(7:8),'_c01.avi')
             else 
newlabel = strcat('m00',fileName(4:5),'_s01_m',fileName(8:9),'_c01.avi')
           
             end
        eval(['!rename "',fileName,'" ',newlabel]);
    end
end







