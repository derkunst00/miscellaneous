%-----------------------------------------------------------------------
% Job saved on 24-Apr-2017 12:22:55 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6906)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
spm fmri
spm_jobman('initcfg')

dir_base='/home/raid/cheon/corr/';

TR=7;
numvols=84;



    disp(['extracting'])

    %specify normalized and smoothed structural images and the destination files for WM and CSF masks
    
   
    clear swc1file 
    clear swc2file 
    clear smwc2file
    clear swc3file 
    clear smwc3file
   
    mask1file  = ([dir_base '/rc1wmsM00223_002.nii']);
    mask2file  = ([dir_base '/rc2wmsM00223_002.nii']);
    mask3file  = ([dir_base '/rc3wmsM00223_002.nii']);


% read the image into the matrix X --- GM
Pc1 =spm_vol(mask1file); 
Xc1 =spm_read_vols(Pc1);

% read the image into the matrix X --- WM 
Pc2 =spm_vol(mask2file); 
Xc2 =spm_read_vols(Pc2);
Mask2 = zeros(size(Xc2));
if size(Xc2) ~= size(Xc1) 
  error('different dimensions');
end

% read the image into the matrix X --- CSF
Pc3 =spm_vol(mask3file); 
Xc3 =spm_read_vols(Pc3);
Mask3 = zeros(size(Xc3));
if size(Xc3) ~= size(Xc1) 
  error('different dimensions');
end

% prepare mask for WM (selecting only the central regions)
nn2=0;
for j=10:size(Xc1,1)-10
   for k=10:size(Xc1,2)-10
      for l=20:size(Xc1,3)-10
          if Xc1(j,k,l)<0.01
             if Xc2(j,k,l)>0.3
	        nn2=nn2+1;
                Mask2(j,k,l)=1;
             end
          end
       end
   end
end

% prepare mask for CSF (selecting only the central regions)
nn3=0;
for j=20:size(Xc1,1)-20
   for k=20:size(Xc1,2)-20
      for l=20:size(Xc1,3)-20
          if Xc1(j,k,l)<0.01  
             if Xc3(j,k,l)>0.3
	         nn3=nn3+1;
                 Mask3(j,k,l)=1;
	     end  
          end
       end
   end
end

%mask size
if nn2<10
  fprintf(1,'WARNING: less than 10 Voxels in WM mask\n');  
end
if nn3<10
  fprintf(1,'WARNING: less than 10 Voxels in CSF mask\n');  
end

%save masks
Pmc2 = spm_vol(mask2file); 
Pmc2 = spm_write_vol(Pmc2,Mask2); 
Pmc3 = spm_vol(mask3file); 
Pmc3 = spm_write_vol(Pmc3,Mask3); 

disp(['mask creation done'])



%create mean value
% read the image into the matrix X 

swaudata = ([dir_base 'spm_raw.nii,']);

for i=1:numvols

   sum2=0;
   sum3=0;
   P =spm_vol([swaudata num2str(i) ]); 
   X =spm_read_vols(P); 
   if size(X) ~= size(Xc1) 
     error('different dimensions');
   end

   for j=1:size(X,1)
      for k=1:size(X,2)
         for l=1:size(X,3)        
             if Mask2(j,k,l)>0
                sum2 = sum2 + X(j,k,l);
             end
             if Mask3(j,k,l)>0
                sum3 = sum3 + X(j,k,l);
             end
         end
      end
   end
   sum2x(i)=sum2/nn2;
   sum3x(i)=sum3/nn3;
end
   
cd([dir_base]);
fid = fopen('globalWMandCSFvalues_regression.txt','w+');
for i=1:numvols 
    fprintf(fid,'%d     %f    %f\n',i, sum2x(i),sum3x(i));
end
fclose(fid);
		
fprintf(1,'%s Masksize: %d %d\n',nn2,nn3);
disp(['completed'])



