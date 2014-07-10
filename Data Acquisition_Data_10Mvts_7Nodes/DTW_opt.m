clear;
experiment=29;
subject=1;
Template_subject=1;
movements=[1 2 3 4 5 6 7 8 9 10];
Template_movement=3;
Template_sample=5;
bit_res_ps=12-[4];%[2 3 4 5 6 7 8 9 10 11 12];
down_samples=[27];%[30 25 20 16 12 9 6 5 4 3 2 1];
Motes=[1];    % 1: Waist 2: Right Wrist 3: Left Wrist 4: Right Arm 5: Left Thigh 6: Right Ankle 10: Left Ankle
Threshold_th=[10];
Sampling_freq=72;%Hz
for down_sample=down_samples    
    
    for bit_res_p=bit_res_ps     
        clear result s1 s Sample split_data;
        bit_res=2^bit_res_p;
        bit_res_T=bit_res;
        down_sample_T=down_sample;
        %down_sample=15;           %Use one sample out of this nuber of samples
        %down_sample_T=15;         %Use one data out of template data

        %bit_res=256;            %devide sample data by this number and round it
        %bit_res_T=256;          %devide template data by this number and round it
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Make Template 
        annotations_name = sprintf('annotations/m%04d_s%02d_m%02d.txt',experiment,Template_subject,Template_movement);
        annotations_data=textread(annotations_name,'%n');
        for split_i=Motes
            split_name=sprintf('split\\m%04d_s%02d_m%02d_n%02d.txt',experiment,Template_subject,Template_movement,split_i);
            temp=textread(split_name,'%n');
            if (split_i==Motes(1)) 
                split_data(split_i,:)=temp; 
            elseif size(temp)>size(split_data,2)
                split_data(split_i,:)=temp(1:size(split_data,2));
            else%
                split_data(split_i,1:size(temp))=temp;
            end
        end
        s={};
        for i=1:size(annotations_data)/4
            sample_length(i)=annotations_data(4*i-1)-annotations_data(4*i-3);
            
            s{i}=[];
            for split_i=Motes
                s1=[];
                for j=annotations_data(4*i-3):annotations_data(4*i-1)
                    s1=cat(1,s1,split_data(split_i,(j-1)*23+15:(j-1)*23+17));%23:length of split data feild .  15:accerlometer.x  19:gyro.y ******17=just acc
                end
            s{i}=cat(2,s{i},s1);    
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Compare Template to samples of same movements as templates
        %Make Threshold
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        Template=floor(s{Template_sample}/bit_res_T)';
        Template=Template(:,1:down_sample_T:size(Template,2));
        for i=1:size(s,2)
            Sample=floor(s{i}/bit_res)';
            Sample=Sample(:,1:down_sample:size(Sample,2));
            result(Template_movement,i)=DTW_core(Sample,Template);
            %[result(Template_movement,i),path(Template_movement,:,:,i)]=DTW_path(Sample,Template);
            accum=0;
            for j=1:size(Template,1)
                accum=accum+xcorr((Template(j,:)-mean(Template(j,:)))/norm(Template(j,:)-mean(Template(j,:))),(Sample(j,:)-mean(Sample(j,:)))/norm(Sample(j,:)-mean(Sample(j,:))));
            end
            corr_result(Template_movement,i)=max(accum);
        end
        Temp=sort(result(Template_movement,:),'descend');
        DTW_threshold=Temp(2);
        Temp=sort(corr_result(Template_movement,:));
        CC_threshold=Temp(2);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        FP_DTW(down_sample,bit_res_p+1)=0;
        FP_CC(down_sample,bit_res_p+1)=0;
        for movement=movements
            clear split_data s1 s Sample
            annotations_name = sprintf('annotations/m%04d_s%02d_m%02d.txt',experiment,subject,movement);
            annotations_data=textread(annotations_name,'%n');
            for split_i=Motes
                split_name=sprintf('split\\m%04d_s%02d_m%02d_n%02d.txt',experiment,subject,movement,split_i);
                temp=textread(split_name,'%n');
                if (split_i==Motes(1))
                    split_data(split_i,:)=temp;
                elseif size(temp)>size(split_data,2)
                    split_data(split_i,:)=temp(1:size(split_data,2));
                else
                    split_data(split_i,1:size(temp))=temp;
                end
            end
            
%             for i=1:size(annotations_data)/4-1
%                 sample_length(i)=annotations_data(4*i-1)-annotations_data(4*i-3);
%                 s=[];
%                 clear s1;
%                 for split_i=Motes
%                     for j=annotations_data(4*i-3):annotations_data(4*i-1)
%                         s1(i,:,j-annotations_data(4*i-3)+1)=split_data(split_i,(j-1)*23+15:(j-1)*23+19);%23:length of split data feild .  15:accerlometer.x  19:gyro.y
%                     end
%                     s=cat(2,s,s1);
%                 end
%             end
%             
%             
        for i=1:size(annotations_data)/4
            sample_length(i)=annotations_data(4*i-1)-annotations_data(4*i-3);
            s{i}=[];
            for split_i=Motes
                s1=[];
                for j=annotations_data(4*i-3):annotations_data(4*i-1)
                    s1=cat(1,s1,split_data(split_i,(j-1)*23+15:(j-1)*23+17));%23:length of split data feild .  15:accerlometer.x  19:gyro.y 
                end
            s{i}=cat(2,s{i},s1);    
            end
        end
            
            
            for i=1:size(s,2)
                
                Sample=floor(s{i}'/bit_res);
                Sample=Sample(:,1:down_sample:size(Sample,2));
                %result(movement,i)=DTW_core(Sample,Template);
                %[result(movement,i),path(:,:,i)]=DTW_path(Sample,Template);
                if (movement==1)&&(i==3)[result(movement,i),domain1]=DTW_domain(Sample,Template);
                elseif (movement==3)&&(i==3)[result(movement,i),domain2]=DTW_domain(Sample,Template);
                else result(movement,i)=DTW_core(Sample,Template);end
                accum=0;
                for j=1:size(Template,1)
                    accum=accum+xcorr((Template(j,:)-mean(Template(j,:)))/norm(Template(j,:)-mean(Template(j,:))),(Sample(j,:)-mean(Sample(j,:)))/norm(Sample(j,:)-mean(Sample(j,:))));
                end
                corr_result(movement,i)=max(accum);
                if (movement~=Template_movement)
                    if (result(movement,i)<DTW_threshold)
                        FP_DTW(down_sample,bit_res_p+1)=FP_DTW(down_sample,bit_res_p+1)+1;
                    end
                    if ~(corr_result(movement,i)<CC_threshold)
                        FP_CC(down_sample,bit_res_p+1)=FP_CC(down_sample,bit_res_p+1)+1;
                    end                    
                end
            end
        end
        %find minimum threshold between sit to stand and other movements
%         min_gap(down_sample,bit_res_p+1)=(min([result(2,:),result(3,1:10),result(4,1:10),result(5,:)])-max(result(1,:)))/mean(mean(result));
%         max_template(down_sample,bit_res_p+1)=max(result(1,:));
%         min_sample(down_sample,bit_res_p+1)=min([result(2,:),result(3,1:10),result(4,1:10),result(5,:)]);
%         %find mean for sit to stand and other movements
%         mean_gap(down_sample,bit_res_p+1)=(mean([result(2,:),result(3,1:10),result(4,1:10),result(5,:)])-mean(result(1,:)))/mean(mean(result));
%         mean_template(down_sample,bit_res_p+1)=mean(result(1,:));
%         mean_sample(down_sample,bit_res_p+1)=mean([result(2,:),result(3,1:10),result(4,1:10),result(5,:)]);
%         sort_result=sort(-result(1,:));
%         threshold=-sort_result(2);
%         TN(down_sample,bit_res_p+1)=sum([result(2,:),result(3,1:10),result(4,1:10),result(5,:)]<threshold);

    
    margin(down_sample,bit_res_p+1)=(min([min(min(result(1:Template_movement-1,:)),min(min(result(Template_movement+1:end,:))))])-max(result(Template_movement,:)))/(min([min(min(result(1:Template_movement-1,:)),min(min(result(Template_movement+1:end,:))))])+max(result(Template_movement,:)));
    
    end
end

figure(55);
hold on;
plot(result(1,:),'c--');
plot(result(2,:),'g');
plot(result(3,:),'k--');
plot(result(4,:),'r.-');
plot(result(5,:),'y');
plot(result(6,:),'b');
plot(result(7,:),'m');
plot(result(8,:),'k.');
plot(result(9,:),'y.-');
plot(result(10,:),'y');
h=legend('Pick up from ground','Sit to lie','Sit to stand','Kneeling','Turn right','Look behind','Step forward','Step leftward','Grasp from shelf','Jump up',10);
set(h,'Interpreter','none');
figure(16);
hold on;
plot(corr_result(1,:),'c--');
plot(corr_result(2,:),'g');
plot(corr_result(3,:),'k-.');
plot(corr_result(4,:),'r.-');
plot(corr_result(5,:),'y');
h=legend('Pick up from ground','Sit to lie','Sit to stand','Kneeling','Turn right','Look behind','Step forward','Step leftward','Grasp from shelf','Jump up',10);
set(h,'Interpreter','none');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%result=corr_result;
%DTW range for different movements
mean_result=[mean(result(3,:)),mean(result(2,:)),mean(result(1,:)),mean(result(4,:)),mean(result(5,:)),mean(result(6,:)),mean(result(7,:)),mean(result(8,:)),mean(result(9,:)),mean(result(10,:))];
min_result=[min(result(3,:)),min(result(2,:)),min(result(1,:)),min(result(4,:)),min(result(5,:)),min(result(6,:)),min(result(7,:)),min(result(8,:)),min(result(9,:)),min(result(10,:))];
max_result=[max(result(3,:)),max(result(2,:)),max(result(1,:)),max(result(4,:)),max(result(5,:)),max(result(6,:)),max(result(7,:)),max(result(8,:)),max(result(9,:)),max(result(10,:))];
figure(1);
errorbar([1 2 3 4 5 6 7 8 9 10],mean_result,mean_result-min_result,max_result-mean_result,'.','LineWidth',2,'MarkerSize',15);
set(gca,'XTick',[1:10]);
%set(gca,'XTickLabel',{'Sit to stand','Sit to lie','Pick up from ground','Kneeling','Turn right','Look behind','Step forward','Step leftward','Grasp from shelf','Jump up'},'FontSize',7);
set(gca,'XTickLabel',{'1','2','3','4','5','6','7','8','9','10'},'FontSize',14);
%set(gca,'YTickLabel',,'FontSize',14);
%%%ylabel('Cross-Correlation Range','FontSize',12);
ylabel('Distance Measure','FontSize',14);
xlabel('Action','FontSize',14);
xlim([0.5,10.5]);
figure(2);
imshow(domain1);
figure(3);
imshow(domain2);
figure(4);
surf(margin((down_samples),(bit_res_ps+1)));
set(gca,'XTick',[1:11]);
set(gca,'YTick',[1:12]);
set(gca,'YTickLabel',Sampling_freq./(down_samples));
set(gca,'XTickLabel',sort(bit_res_ps)+2);
ylabel('Sampling Frequency(Hz)');
xlabel('Bit Resolution');
zlabel('Safe Margin');
figure(7);
surf(FP_DTW);
set(gca,'XTickLabel',[2:12]);
set(gca,'YTickLabel',{'14','13','12','11','10','9','8','7'})
xlabel('Bit Resolution');
ylabel('Template Size');
zlabel('False Positive Wake Up');
figure(8);
surf(FP_CC);%surf(min_gap);

figure(9);
surf(max_template);
figure(10);
surf(min_sample);
figure(11);
surf(mean_template);
figure(12);
surf(mean_sample);
figure(13);
surf(TN);