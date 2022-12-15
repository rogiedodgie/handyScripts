function measure_roi_volume(atlas, fnms)
%for each parcel of an atlas, provide sum intensity for image(s)
% atlas : image where each region has a unique number (e.g. brodmann areas)
% fnms  : images where brightness corresponds to amount of tissue (gray matter, white matter)
%Examples
% measure_roi_volume('Lobules-SUIT.nii', 'wc1T1.nii');
% measure_roi_volume() %use graphical interface

if ~exist('atlas','var')
	atlas = spm_select(1,'image','Select atlas image'); 
end
if ~exist('fnms','var')
	fnms = spm_select(inf,'image','Select image[s] quantification'); 
end


for i=1:size(fnms,1)
    fnm = deblank(fnms(i,:));
    measureSub(atlas, fnm)
end
%end measure_atlas_volume() 

function measureSub(atlasName, subjName)
%First, load in our atlas
atlasHDR = spm_vol(atlasName);
atlasIMG = spm_read_vols(atlasHDR);
%Next, load in our ptx image (assuming they are in the same space)
subjHDR = spm_vol(subjName);
subjIMG = spm_read_vols(subjHDR);
subjIMG(isnan(subjIMG)) = 0; %SPM can use NaN for out of brain
%make sure our images match each other (check with fslhd):
[~, subjIMG] = nii_reslice_target(subjHDR, subjIMG, atlasHDR, true);
n_rois = unique(atlasIMG(atlasIMG ~= 0)); %get a list of all ROIs (ignoring empty space (0's))
%For loop for each ROI
[~,n]  = spm_fileparts(atlasHDR.fname);
fileID = fopen([n,'.txt'],'a');
fprintf('Subject: %s\n',subjName);
[~,n] = spm_fileparts(subjHDR.fname);
fprintf(fileID, 'Subject: %s\t',n);
for i = 1:length(n_rois) %For each ROI
    roinum = n_rois(i);
    voxsum = sum(subjIMG(atlasIMG == roinum));
    fprintf('%f\n', voxsum); %The data printed in the txt file
    fprintf(fileID, '%f\t', voxsum); %The data printed in the txt file

end
fprintf(fileID, '\n');
fclose(fileID);
%end()
