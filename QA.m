% matlab

clear all
subjects={'badguy','goodguy1','goodguy2','goodguy3'};


for s=1:length(subjects)

  % read the image into the matrix X
  fprintf('Stability of subject %s ... ', subjects{s});
  P =spm_vol([subjects{s} '.nii']);
  X=spm_read_vols(P);

  % do something with the matrix X
  cs=10;
  for i=1:size(X,4)
  vox_corner=reshape(X(1:cs,1:cs,:,i),cs*cs*size(X,3),1);
  mean_corner1(s,i)=mean(vox_corner);
  std_corner1(s,i)=std(vox_corner);
  end

  RR=std(mean_corner1(s,1:size(X,4)));
  RR2=std(std_corner1(s,1:size(X,4)));
  fprintf('first corner %1.2f %1.2f',RR,RR2);
  if RR<0.6 && RR2<0.66
    for i=1:size(X,4) %looking for other corners
    vox_corner2=reshape(X(size(X,1)-cs+1:size(X,1),1:cs,:,i),cs*cs*size(X,3),1);
    mean_corner2(s,i)=mean(vox_corner2);
    std_corner2(s,i)=std(vox_corner2);
    end
    
    RR3=std(mean_corner2(s,1:size(X,4)));
    RR4=std(std_corner2(s,1:size(X,4)));
    fprintf(' second corner %1.2f %1.2f',RR3,RR4);
    if RR3<0.6 && RR4<0.66
        for i=1:size(X,4) %looking for other corners
        vox_corner3=reshape(X(size(X,1)-cs+1:size(X,1),size(X,1)-cs+1:size(X,1),:,i),cs*cs*size(X,3),1);
        mean_corner3(s,i)=mean(vox_corner3);
        std_corner3(s,i)=std(vox_corner3);
        end
    
        RR5=std(mean_corner3(s,1:size(X,4)));
        RR6=std(std_corner3(s,1:size(X,4)));
        fprintf(' third corner %1.2f %1.2f',RR5,RR6);
        if RR5<0.6 && RR6<0.66
            for i=1:size(X,4) %looking for the last corners
            vox_corner4=reshape(X(1:cs,size(X,1)-cs+1:size(X,1),:,i),cs*cs*size(X,3),1);
            mean_corner4(s,i)=mean(vox_corner4);
            std_corner4(s,i)=std(vox_corner4);
            end
    
            RR7=std(mean_corner4(s,1:size(X,4)));
            RR8=std(std_corner4(s,1:size(X,4)));
            fprintf(' fourth corner %1.2f %1.2f',RR7,RR8);
            if RR7<0.6 && RR8<0.66
                fprintf(', okay\n');
            else
            fprintf(', ---> FAIL\n');
            end  
            fprintf(', okay\n');
        else
        fprintf(', ---> FAIL\n');
        end
        fprintf(', okay\n');
    else
    fprintf(', ---> FAIL\n');
    end
  else
  fprintf(', ---> FAIL\n');
  end

end

figure
hold on
title('mean signal corner1');
xlabel('time');
ylabel('noise signal');
for s=1:length(subjects)
   plot(mean_corner1(s,:))
end

figure
hold on
title('mean signal corner2');
xlabel('time');
ylabel('noise signal');
for s=1:length(subjects)
   plot(mean_corner2(s,:))
end

figure
hold on
title('mean signal corner3');
xlabel('time');
ylabel('noise signal');
for s=1:length(subjects)
   plot(mean_corner3(s,:))
end

figure
hold on
title('mean signal corner4');
xlabel('time');
ylabel('noise signal');
for s=1:length(subjects)
   plot(mean_corner4(s,:))
end

figure
hold on
title('std');
xlabel('time');
ylabel('noise signal corner1');
for s=1:length(subjects)
   plot(std_corner1(s,:))
end

figure
hold on
title('std');
xlabel('time');
ylabel('noise signal corner2');
for s=1:length(subjects)
   plot(std_corner2(s,:))
end

figure
hold on
title('std');
xlabel('time');
ylabel('noise signal corner3');
for s=1:length(subjects)
   plot(std_corner3(s,:))
end

figure
hold on
title('std');
xlabel('time');
ylabel('noise signal corner4');
for s=1:length(subjects)
   plot(std_corner4(s,:))
end




