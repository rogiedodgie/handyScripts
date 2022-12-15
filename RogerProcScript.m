%This script calls nii_preprocess using the command line for all folders inside a master folder
%containing the POLAR participant scans
%Each participant should be in a separate folder, and contain a folder
%called 'POLAR' in which all of the images for a single session are placed.
%RNN, 10/4/2017

isRest = true;  %if true will get Rest*.nii and put into nii_preprocess
isDTI = false;  %if true will get DTI_*.nii and DTIrev*.nii and put into nii_preprocess
isfMRI = false; %if true will get fMRI*.nii and put into nii_preprocess
isASL = false;  %if true will get ASL*.nii and put into nii_preprocess

%gather directories to process from current directory
dirInfo = dir(pwd);
isDir = [dirInfo.isdir];
dirNames = {dirInfo(isDir).name} %gets all dir names in directorym, modify to exclude '.' and '..' ???
subjDirs = dirNames;

%last minute additions to run
subjDirs = {'M10243'};%,'M10262','M10292','M10311'};

%loop through subjects, set up processing path and launch nii_preprocess
for j = 1:length(subjDirs)
    if (size(subjDirs{j},2) > 3) %only executes if directory name is greater than three characters (so no '.' or '..')
        filesDir = fullfile('/media/research/NEW2TBDRIVE/POLAR_MASTER_DB',subjDirs{j},'POLAR');
        outputDir = fullfile('/media/research/NEW2TBDRIVE/_POLAR_MASTER_IN',subjDirs{j});
        mkdir(outputDir);
        cd (filesDir);

        %get appropriate files from file directory
        filesAndFolders = dir(filesDir);
        stringToBeFound = 'T1';
        numOfFIles = length(filesAndFolders);
        %find file you want for this modality
        for i = 1:length(filesAndFolders)
              filename = filesAndFolders(i).name;
              x = stringToBeFound;
              if(strfind(filesAndFolders(i).name, stringToBeFound))
                 name = filesAndFolders(i).name;
              end;
        end
        imgs.T1 = name

        stringToBeFound = 'T2';
        numOfFIles = length(filesAndFolders);
        %find file you want for this modality
        for i = 1:length(filesAndFolders)
              filename = filesAndFolders(i).name;
              x = stringToBeFound;
              if(strfind(filesAndFolders(i).name, stringToBeFound))
                 name = filesAndFolders(i).name;
              end;
        end
        imgs.T2 = name

        if (isRest)
            stringToBeFound = 'Rest';
            numOfFIles = length(filesAndFolders);
            %find file you want for this modality
            for i = 1:length(filesAndFolders)
                  filename = filesAndFolders(i).name;
                  x = stringToBeFound;
                  if(strfind(filesAndFolders(i).name, stringToBeFound))
                     name = filesAndFolders(i).name;
                  end;
            end
            imgs.Rest = name
        end;

        if (isfMRI)
            stringToBeFound = 'fMRI';
            numOfFIles = length(filesAndFolders);
            %find file you want for this modality
            for i = 1:length(filesAndFolders)
                  filename = filesAndFolders(i).name;
                  x = stringToBeFound;
                  if(strfind(filesAndFolders(i).name, stringToBeFound))
                     name = filesAndFolders(i).name;
                  end;
            end
            imgs.fMRI = name
        end;

        if (isDTI)
            stringToBeFound = 'DTIrev';
            numOfFIles = length(filesAndFolders);
            %find file you want for this modality
            for i = 1:length(filesAndFolders)
                  filename = filesAndFolders(i).name;
                  x = stringToBeFound;
                  if(strfind(filesAndFolders(i).name, stringToBeFound))
                     name = filesAndFolders(i).name;
                  end;
            end
            imgs.DTIrev = name
        end;
        if (isDTI)
            stringToBeFound = 'DTI_';
            numOfFIles = length(filesAndFolders);
            %find file you want for this modality
            for i = 1:length(filesAndFolders)
                  filename = filesAndFolders(i).name;
                  x = stringToBeFound;
                  if(strfind(filesAndFolders(i).name, stringToBeFound))
                     name = filesAndFolders(i).name;
                  end;
            end
            imgs.DTI = name
        end;
        
%         stringToBeFound = 'ASL';
%         numOfFIles = length(filesAndFolders);
%         %find file you want for this modality
%         for i = 1:length(filesAndFolders)
%               filename = filesAndFolders(i).name;
%               x = stringToBeFound;
%               if(strfind(filesAndFolders(i).name, stringToBeFound))
%                  name = filesAndFolders(i).name;
%               end;
%         end;
%         imgs.ASL = name

        stringToBeFound = 'LESION';
        numOfFIles = length(filesAndFolders);
        %find file you want for this modality
        for i = 1:length(filesAndFolders)
              filename = filesAndFolders(i).name;
              x = stringToBeFound;
              if(strfind(filesAndFolders(i).name, stringToBeFound))
                 name = filesAndFolders(i).name;
              end;
        end;
        imgs.LESION = name

        %all files loaded inton imgs, run that person and generate their
        %files in their own directory
        nii_preprocess(imgs,subjDirs{j},false, true);
       
    
    end;
    
    %clear variables in preparation for next loop iteration
    clearvars imgs;
end;
