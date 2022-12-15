function ABCHarvestAndZipMultipleModalitiesPerParticipant (modalitiesToInclude)
%example 
%ABCHarvestAndZipMultipleModalitiesPerParticipant({'T1','fMRI_f','fMRI_p','fme1','fme2','fmp','Rest','ASL','ASLrev',})
%harvest T1s from Master_DB
%T1,SWI,FLAIR,ASL,ASLrev,Rest,
%ABCHarvestAndZipMultipleModalitiesPerParticipant({'w_RMS.nii','FLAIR.nii','DTI'})

inputdir = uigetdir('','Pick INPUT dir')
outputdir = uigetdir('','Pick OUTPUT dir')


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
    
         
        
    zip(['Data' char(nameFolds(i))],filesToZip);
    fullZippath = fullfile(inputdir,char(nameFolds(i)), 'ABC', ['Data' char(nameFolds(i)) '.zip']);
    finalpath =   fullfile(outputdir,['Data' char(nameFolds(i)) '.zip']);
    movefile(fullZippath,  finalpath);
    %delete(fullZippath);  %remove extra copy
    
end

