function ABCHarvestAndZipMultipleModalitiesPerParticipant (modalitiesToInclude)
%example 
%ABCHarvestAndZipMultipleModalitiesPerParticipant({'T1','fMRI_f','fMRI_p','fme1','fme2','fmp','Rest','ASL','ASLrev',})
%harvest T1s from Master_DB
%T1,SWI,FLAIR,ASL,ASLrev,Rest,
%ABCHarvestAndZipMultipleModalitiesPerParticipant({'w_RMS.nii','FLAIR.nii','DTI'})

inputdir = uigetdir('','Pick INPUT dir')
outputdirFA = uigetdir('','Pick FA OUTPUT dir')
outputdirMD = uigetdir('','Pick MD OUTPUT dir')

d = dir(inputdir);
isub = [d(:).isdir]; %# returns logical vector
nameFolds = {d(isub).name}';

for i = 1:length(nameFolds)
    cpth = char(deblank(nameFolds(i)));
    if cpth(1) == '.'
        nameFolds(i) = {'.'}; %disallow anything starting with a .
    end
    if strfind(cpth,'.')
        nameFolds(i) = {'.'}; 
    end
end
nameFolds(ismember(nameFolds,{'.','..'})) = [];

for i = 1:length(nameFolds)

    cd(char(fullfile(inputdir,nameFolds(i))))
    if ~isempty(dir('wDTI*FA.nii'))
        FAmap = dir('wDTI*FA.nii'); 0
        FAfile = [FAmap(1).folder '\' FAmap(1).name];
        MDmap = dir('wDTI*MD.nii');   
        MDfile = [MDmap(1).folder '\' MDmap(1).name];     

        copyfile(FAfile, [outputdirFA '\' nameFolds{i} '_FA.nii'])
        copyfile(MDfile, [outputdirMD '\' nameFolds{i} '_MD.nii'])
    end
    
       
end

