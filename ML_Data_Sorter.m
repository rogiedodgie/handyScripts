%Sorts Data from received format into nii_preprocessing format
%loops through all directories
%rogiedodgie@gmail.com, Roger Newman-Norlund, September 15 2020
clc


args1 = ' -f "%z_%s_%i_%p "';
args2 =  ' -i y -p y -x y -z n ';
base = '/media/polar/Rainbowy/ML_Data_Raw/mri';
x = dir([ base '/*']);
isub = [x(:).isdir];
folds = {x(isub).name};
folds(ismember(folds,{'.','..'})) = []


for i =1:length(folds)

    dcmpath =  '/home/polar/Neuro/mricrogl_lx/dcm2niix ';
    args1 = ' -f "%z_%s_%i_%p "';
    args2 =  ' -i y -p y -x y -z n ';
    folds = {x(isub).name};
    folds(ismember(folds,{'.','..'})) = [];
    cd(fullfile(base,folds{i}))
    inputdir = fullfile(base,folds{i})
    inputdirstring = [' "' inputdir '" ']
    
   delete (fullfile(pwd,'*.nii'))
     delete (fullfile(pwd,'*.bvec'))
      delete (fullfile(pwd,'*.bval'))
    %dcm2niix
    cmd = [ dcmpath args1 args2 inputdirstring]
    system(cmd);

    
   
    
    try
        
    try
    %move jsons
    movefile([pwd '/*.json'],fullfile(pwd,'/jsons'));
    %identify and reassign scans
    catch
    end
    
    try
    sortScan(pwd, '/*Crop*.nii', 'T1_scan.nii')
    catch
    end
    try
    sortScan(pwd, '/*RESTING*.nii', 'Rest_scan.nii')
    catch
    end
    try
    sortScan(pwd, '/*DTI_6*AP*nii', 'DTI_AP_scan.nii')
    sortScan(pwd, '/*DTI_6*AP*bval', 'DTI__AP_scan.bval')
    sortScan(pwd, '/*DTI_6*AP*bvec','DTI_AP_scan.bvec')
    sortScan(pwd, '/*DTI_b0*AP*nii', 'DTI_AP_extraB0.nii')
    catch
    end
    try
    sortScan(pwd, '/*DTI_6*PA*nii', 'DTIrev_PA_scan.nii')
    sortScan(pwd, '/*DTI_6*PA*bval', 'DTIrev__PA_scan.bval')
    sortScan(pwd, '/*DTI_6*PA*bvec','DTIrev_PA_scan.bvec')
    sortScan(pwd, '/*DTI_b0*PA*nii', 'DTIrev_PA_extraB0.nii')
    catch
    end
    try
    sortScan(pwd, '/*MOVIE*nii', 'fMRI_movie.nii')
    catch
    end
    try
    sortScan(pwd, '/*BACK*nii', 'fMRI_NBACK_NNN.nii')
    catch
    end
    try
    deprefixScanAt(pwd, '/*Breathing*nii', 'Breathing')
    catch
    end
    try
    movefile([pwd '/_*'],fullfile(pwd,'/extraScans'));
    catch
    end
    try
    movefile([pwd '/epfid*'],fullfile(pwd,'/extraScans'));
    catch
    end
    try
    movefile([pwd '/*extraB0*'],fullfile(pwd,'/extraDTIb0s'));
    catch
    end

    catch
         fprintf('something went wrong with %s\n',inputdir)
    end

end

function [x] = sortScan(currdir, matchstring, scanname)
 currdir = pwd;
x = dir([currdir matchstring])
for j = 1:length(x)
    xpath = fullfile(x(j).folder, x(j).name)
    copyfile(xpath,fullfile(currdir,strrep(scanname,'_NNN', ['_' num2str(j)]   )       )    )
    delete(xpath)
end
end

function [x] = deprefixScanAt(currdir, matchstring, keepAfter)
x = dir([currdir matchstring])
for j = 1:length(x)
    xpath = fullfile(x(j).folder, x(j).name)
    sp = strsplit(x(j).name, 'Breathing')
    copyfile(xpath,fullfile(pwd, ['Breathing' sp{2}] ) )
    delete(xpath)
end
end
