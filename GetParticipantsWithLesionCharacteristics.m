%attempts to extract normalized lesion files from .mat and insert into pwd if this
%is set to true
generateLesionFiles = false;

%matFileDirectory starts empty
matFileDirectory = '';

%set mat file directory manually
matFileDirectory = '/Volumes/Expansion 1/BOX_BACKUP_07-01-2021/MASTER_FILES_08_2019';

%if no matFileDirectory specified will prompt user to select location of
%.mat files
if isempty(matFileDirectory)
    matFileDirectory = uigetdir(pwd,'Select directory in which .mat files can be found:');
end

%CD into matFileDirectory and perform all work there
cd(matFileDirectory);
matFiles = dir('*.mat')
matFiles = matFiles(~contains({matFiles.name}, {'._'}))

%specify target atlas
TargetAtlas = 'bro';

%specify areas that must be partially damaged
AreasToInclude = [73];

%specify areas that must have no damage
AreasToExclude = [1:72 74:82];

ListOfMatchingFiles = {};
fldName = ['lesion_' TargetAtlas]
totalNumViable = 0;
% LEFT 44 = 73 *
% LEFT 45 = 75
% LEFT 47 = 79

%Attempts to extract Lesion Files to Directory
if(generateLesionFiles)
    for i = 1:length(matFiles)
         [x y z] = spm_fileparts(matFiles(i).name);
         outputLesionFileName = [pwd '/' y '_Lesion.nii'];
         matFileData = load(matFiles(i).name);
         matFileData.lesion.hdr.fname = outputLesionFileName;
         spm_write_vol(matFileData.lesion.hdr,matFileData.lesion.dat);

    end
end

%Collate viable particiapnts based on areas chosen to include and exclude
%Interrogates lesionLoad == 0, lesionLoad >0 to make these decisions
for i = 1:length(matFiles)
    
     [x y z] = spm_fileparts(matFiles(i).name);
     outputLesionFileName = [pwd '/' y '_Lesion.nii'];
     matFileData = load(matFiles(i).name);
     
     viable = true; %until bad, participant is good
     for inc = 1:length(AreasToInclude)
         if(matFileData.(fldName).mean(AreasToInclude(inc))) == 0
             viable = false;
         end 
     end
     for exc = 1:length(AreasToExclude)
        if(matFileData.(fldName).mean(AreasToExclude(exc))) > 0 
             viable = false;
        end 
     end
     
     if(viable)
        %ListOfMatchingFiles = [ListOfMatchingFiles; matFiles(i).name]
        totalNumViable = totalNumViable +1
        ListOfMatchingFiles{totalNumViable} = matFiles(i).name
     end
     
     %fprintf("Processed %d/%d participant .mat files...%d/%d are viable",i,length(matFiles),length(ListOfMatchingFiles) ,i);
     
end


fprintf("Found %d viable participants, summarized in ListOfMatchingFiles variable shown here: \n",length(ListOfMatchingFiles));
%Output viable participants to text file 
T = cell2table(ListOfMatchingFiles')
writetable(T,'viableFileList.csv')
