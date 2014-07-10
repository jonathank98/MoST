experiment=3;
subjects=[24];
movements=[1:7];
% trials=[1:10];
cams=[1,2];

for s=subjects
    for m=movements
%         for t=trials
            for c=cams
                fname1=sprintf('video%sNew_m%03d_s%02d_m%02d_c%02d.avi',filesep,experiment,s,m,c);
                fname2=sprintf('video%sm%04d_s%02d_m%02d_c%02d.avi',filesep,experiment,s,m,c);
                fid = fopen(fname1);
                if (fid ~= -1)
                    fclose(fid);
                    disp(sprintf('copying %s to %s',fname1,fname2));
                    copyfile(fname1,fname2);
                else
                    disp(sprintf('warning: %s not found',fname1));
                end
            end
%         end
    end
end

% experiment=3;
% subjects=[15,16,17,19,20];
% movements=[1:7];
% % trials=[1:10];
% % cams=[1,2];
% 
% for s=subjects
%     for m=movements
% %         for t=trials
% %             for c=cams
%                 fname1=sprintf('raw%sm%03d_s%02d_m%02d.txt',filesep,experiment,s,m);
%                 fname2=sprintf('raw%sm%04d_s%02d_m%02d.txt',filesep,experiment,s,m);
%                 fid = fopen(fname1);
%                 if (fid ~= -1)
%                     fclose(fid);
%                     disp(sprintf('copying %s to %s',fname1,fname2));
%                     copyfile(fname1,fname2);
%                 else
%                     disp(sprintf('warning: %s not found',fname1));
%                 end
% %             end
% %         end
%     end
% end
% 
