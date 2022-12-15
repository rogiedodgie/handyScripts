function DilationfMRICalculator()
    % This file assumes your present working directory is a folder with all of the files in it and Matlab is in that directory! 
    % This also only gets the mean value of 'positive' values in the fMRI
    % activation file, you can change this in the code if you want!
    % XX files that start with 'fMRI'
    % XX files that start with 'M' and have 'lesion' in the name, which
    % correspond to the fMRI files
    % lesion dilation files created based on each lesion file noted above,
    % make sure you fill out the first few lines properly to ensure you
    % capture the right files for the analysis!!! -->

    fMRIfiles = dir('fMRI*');          % get the fMRI files with the activity in them
    LESIONfiles = dir('M*lesion*');    % get the matching lesion files 
    lesionDilations = {'3', '5', '7'}; % enter in the lesion dilations YOU used to create YOUR d* dilation files
    
    %number of particiapnts
    numPart = length(fMRIfiles);
    
   
   
    %loop through the files and for each one, 
 	for i = 1:numPart
    
    %load up activity map (i.e. the contast image)
    activityMap = fullfile(fMRIfiles(i).folder,fMRIfiles(i).name)
    [xact yact zact] = fileparts(activityMap);
    activityMap_hdr = spm_vol (activityMap);
    activityMap_dat = spm_read_vols (activityMap_hdr);
    
    %load up the original lesion file
    lesionFile = fullfile(LESIONfiles(i).folder,LESIONfiles(i).name)
    [xles yles zles] = fileparts(lesionFile);
    lesion_hdr = spm_vol (lesionFile);
    lesion_dat = spm_read_vols (lesion_hdr);
    
    %since lesion file and fmri activity file don't have same resolution,
    %need to reslice: let's reslice the fMRI file to be the same resolution as the
    %lesionDilation files
    nii_reslice_target(activityMap_hdr, activityMap_dat, lesion_hdr)    
    
    %now let's reload that activity map (now resliced to match the
    %resolution of the lesion file)
    [xact yact zact] = fileparts(activityMap);
    activityMap_hdr = spm_vol ([xact filesep 'r' yact zact]);
    activityMap_dat = spm_read_vols (activityMap_hdr);
    activityMap_dat(isnan(activityMap_dat)) = 0; %need to make NaN = 0, so can multiply this image by lesionDilation image later
    
        %for each dilation map, calculate the mean value of the activityMap at
        %voxels where the lesionmap == 1, and the value is positive
        for j = 1:length(lesionDilations-1)

            CurrentDilation = [xles filesep 'd' lesionDilations{j} '_' lesionDilations{j+1} yles zles];
            CurrentDilation_hdr = spm_vol (CurrentDilation);
            CurrentDilation_dat = spm_read_vols (CurrentDilation_hdr);

            finalOutput_dat = CurrentDilation_dat.*activityMap_dat; %perform element-by-element multiplication of the images
            finalOutput_dat_as_vector = finalOutput_dat(:);        %still has positive and negative values!!
            %finalOutput_dat_as_vector = finalOutput_dat_as_vector (finalOutput_dat_as_vector>=0)  %this will ensure all positive values
            meanValue{i,j} = mean(nonzeros(finalOutput_dat_as_vector)); 
            participantNames(i)=LESIONfiles(i).name;
        end
    
    end
    
%write a table with the resulting values
%Each column is a particiapnt, starting with the first
%Each row is for one dilation distance, starting with the first
filename = 'test_output.csv';    %must end in csv


writetable( cell2table(meanValue), filename, 'writevariablenames', false, 'quotestrings', true)


%rowlabeled_filename = ['rownames_' filename];
%table2write = cell2table(meanValue);
%table2write.Properties.RowNames = {fMRIfiles.name};
%writetable( table2write, filename, 'writerownames', true, 'quotestrings', true);
