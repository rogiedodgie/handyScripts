clear
clc
wd = '/Volumes/ABC_EXPRESS/ASL_ALL_IN_DATA' 
cd(wd)
files = dir('*/*/*/*/perfusion_calib.nii')
outputDir = '/Users/rorden/Desktop/finaloutput'


for i = 1:length(files)
    
    try
        %only go into standard space folder to get calibrated images
        if(   contains(files(i).folder,'std_space') )
            %split into folders
            stuff=regexp(files(i).folder,'/','split');
            %use 6th folder which is subject ID in this CASE ONLY!!
            finalName = fullfile(outputDir, [stuff{6} '.mat']);
            %convert the .nii file you found, as cbf, to the final name in
            %output folder
            nii_nii2mat(fullfile(files(i).folder,files(i).name),'cbf',finalName);
            fprintf('Created new matfile with name = : %s', finalName);
        end
    catch
        fprintf('WARNING - Failed to create mat for %s', files(i).folder);
    end
    
    
end