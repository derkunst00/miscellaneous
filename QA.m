% matlab

clear all
subjects={'badguy','goodguy1','goodguy2','goodguy3','auditorz'};


for s=1:length(subjects)

  % read the image into the matrix X
  fprintf('Stability of subject %s ... ', subjects{s});
  P =spm_vol([subjects{s} '.nii']);
  X=spm_read_vols(P);

  % do something with the matrix X
  cs=10;
  for i=1:size(X,4)
  vox_corner=reshape(X(1:cs,1:cs,:,i),cs*cs*size(X,3),1);
  mean_corner(s,i)=mean(vox_corner);
  std_corner(s,i)=std(vox_corner);
  end

  RR=std(mean_corner(s,1:size(X,4)));
  RR2=std(std_corner(s,1:size(X,4)));
  fprintf('%1.2f %1.2f',RR,RR2);
  if RR<0.6 && RR2<0.6
    fprintf(', okay\n');
  else
    fprintf(', ---> FAIL\n');
  end

end

figure
hold on
title('mean signal');
xlabel('time');
ylabel('noise signal');
for s=1:length(subjects)
   plot(mean_corner(s,:))
end

figure
hold on
title('std');
xlabel('time');
ylabel('noise signal');
for s=1:length(subjects)
   plot(std_corner(s,:))
end

