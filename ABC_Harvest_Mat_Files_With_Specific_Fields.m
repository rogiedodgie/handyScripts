function ABC_Harvest_Mat_Files_With_Specific_Fields(fieldsToInclude)
%example to keep only certain fields!
% CHOICES to include in string array: {'VBM','fa','md','rest','dti','i3mT1','alf','palf','basil','fmri','dax','drad','mk', 'kax','krad','kfa','T1'}
% example = ABC_Harvest_Mat_Files_With_Specific_Fields({'T1','rest'})
fieldsToRemoveIdxTotal = []

inputdir = uigetdir('','Pick INPUT dir')
outputdir = uigetdir('','Pick OUTPUT dir')
nameOfsubFolderToSearch = 'ABC';

d = dir(inputdir);
isub = [d(:).isdir]; %# returns logical vector
nameFolds = {d(isub).name}';

for i = 1:length(nameFolds)
    cpth = char(deblank(nameFolds(i)));
    if strfind(cpth,'_')
        nameFolds(i) = {'.'}; %disallow anything with a point later on, so if has a '_' just say it is a .
    end
    if strfind(cpth,'.')
        nameFolds(i) = {'.'}; 
    end
end
nameFolds(ismember(nameFolds,{'.','..'})) = [];

for i = 1:length(nameFolds)
    
    cd(char(fullfile(inputdir,nameFolds(i))))
    searchTarget = ['*lime.mat' ]
    targ = rdir(searchTarget)
    targ = targ{1}
    targetFile = targ(length(searchTarget)+2:length(targ))
    targetFileLoadedAsMat = load(targetFile); 
    fn = fieldnames(targetFileLoadedAsMat);
    fieldsToRemoveIdxTotal = transpose(zeros(1,length(fn)));
    
    for r = 1:length(fieldsToInclude)
        prefix = fieldsToInclude{r} %remove fields starting with this
        fieldsToRemoveIdx = strncmp(fn, prefix, length(prefix)); %just a vector of 1's and zeros
        fieldsToRemoveIdxTotal = fieldsToRemoveIdxTotal+fieldsToRemoveIdx;
    end
    
    croppedStruct = rmfield(targetFileLoadedAsMat,fn(~fieldsToRemoveIdxTotal)) %newly generated file with specific fields
    newMatFileName = fullfile(outputdir,[char(nameFolds(i)) '.mat']);
    save(newMatFileName, '-struct','croppedStruct'); % need -struct argument to make sure not saved under croppedStruct in matfile
 
end

