function standardlize_synthesis()
filename = uigetfile('*.txt', 'Find diary text file');

import java.util.LinkedList
fid = fopen(filename);
q = LinkedList();
stop=0;
q1=LinkedList();

open(filename);

%start processing
start =0;
while ~start %find starting point of your diary
    tline = fgets(fid);
    token = strtok(tline);
    start = strcmp(token, 'START');
end

%keep first line of synthesize
fLine=tline;

while ~stop %until find STOP
    tline = fgets(fid);
    token = strtok(tline);
    if strcmp(sprintf('\r\n'), tline) %skip emply line
        continue;
    elseif strcmp(token, 'STOP!')  % if stop, break
        lLine=tline;
        break;
    else
        q.addLast(tline);
    end
end;

%disp(q);
%count loop
loops=0;
for n=0:q.size()-1
    temp=q.get(n);
    if temp(1)=='['
        loops=loops+1;
    end;
end;


countBracket=0;
while (loops ~=0)
   for i=0:q.size()-1
       temp1=q.get(i);
       if temp1(1)=='['
           countBracket=countBracket+1;
           if countBracket==1 
                fIndex=i;
                iter=temp1(2);
           end
       elseif temp1(1)==']'
           countBracket=countBracket-1;
           if countBracket==0
               lIndex=i;
               break;
           end;
       end;
   end;
   
   for m=0:fIndex-1
       q1.addLast(q.get(m));
   end;
  
   %disp(q1);
   for j=1:str2num(iter)
       for k=fIndex+1:lIndex-1;
           q1.addLast(q.get(k));
       end;
   end;
   
   for j=lIndex+1:q.size()-1
       q1.addLast(q.get(j));
   end;
   
   %disp(q1);
   q.clear();
   q=q1.clone();
   q1.clear();
   loops=0;
   b=q.size();
   t=q;
   %disp(q);
    for n=0:q.size()-1
        temp=q.get(n);
        if temp(1)=='['
        loops=loops+1;
        end;
    end;  
   
end

fid1 = fopen('standard_synthesis.txt', 'w');
fprintf(fid1,'%s',fLine);
while q.size()>0
    fprintf(fid1,'%s',q.getFirst());
    q.removeFirst();
end;
fprintf(fid1,'%s',lLine);
fclose(fid1);

%disp(q);