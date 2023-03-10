% Function to get voxel counts in Basal Ganglia and Centrum SemiOvale given 
% input maps generated by ShivaPVS github code
% use unthresholded results and choose to threshold them yourself using
% the variables listed below


maindir = '/Users/roger/Desktop/ABCCNABCPVS';
templateMask = fullfile(maindir,'/','avg152T1_white.nii');
cd (maindir);
survival_threshold = 0.7; %this is for PVS images (range = 0:1), only above this value counted
zSplit = 45;  %Above Ventricles Only *get frommanual inspection, could automate
xSplit = 39;  %RH only*from manualinspection, could automate
thresh = 50; %seems to be a good threshold for avg152T1_white.nii (range = 0:250)

%gather wout from SHIVA
data = dir('*w*.nii');

%also mask with WM, since PVS really only in the WM that I want
fslWMmask = templateMask;

for i = 1:length(data)

    fnm = fullfile(data(i).folder, data(i).name);

    [x y z] = fileparts(fnm);
    q = strsplit(y,'_');
    name = q{2};

    %Mask PVS so that only WM comes through, all else set to 0
    nii_mask(fnm,fslWMmask,thresh, 0.0); %also get from manual inspection, need to automate
    newFNM = strrep(fnm,'wout','mwout');

    %Threshold image at 0.5 to get PVS with 50 percent of more prob
    %nii_thresh(fnmMod,false,inf,inf,0.5, 0); %darker than .5 set to zero
    %newFNM = strrep(fnm,'wout','xmwout'); 

    %Read in final image that has been masked and binarized
    imghdr = spm_vol(newFNM);
    imgdata = spm_read_vols(imghdr);

    %count surviving voxels, use splits to cordon off unwanted areas
    ctrCSO = length(imgdata(imgdata(xSplit:end,:,zSplit:end)>survival_threshold));
    ctrBG = length(imgdata(imgdata(xSplit:end,:,1:(zSplit))>survival_threshold));

    %write results to an easy to read CSV file
    fileID = fopen(['results_' num2str(survival_threshold) '.txt'],'a');
    fprintf(fileID,'ID,%s,CSO,%f,BG,%f\n',name,ctrCSO,ctrBG);
    fclose(fileID);
    delete('x*.nii');
    delete('m*.nii');

end
