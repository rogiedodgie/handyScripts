%harvest T1s from Master_DB
inputdir =  uigetdir('','Pick INPUT dir');
outputdir = uigetdir('','Pick OUTPUT dir');
nameOfsubFolderToSearch = 'CNABC';
modality = 'T1';

d = dir(inputdir);
isub = [d(:).isdir]; %# returns logical vector
nameFolds = {d(isub).name}';

for i = 1:length(nameFolds)
    cpth = char(deblank(nameFolds(i)));
    if strfind(cpth,'_')
        nameFolds(i) = {'.'}; %disallow anything with a point later on, so if has a '_' just say it is a .
    end
    if strfind(cpth,'2133')
        nameFolds(i) = {'.'}; %disallow anything with a point later on, so if has a '2133' just say it is a .
    end
    if strfind(cpth,'.')
        nameFolds(i) = {'.'}; 
    end
end
nameFolds(ismember(nameFolds,{'.','..'})) = [];

for i = 1:length(nameFolds)
    
    
    cd(inputdir);
    
    cd(char(fullfile(inputdir,nameFolds(i))));
    
    cd('ABC');
    
    searchTarget = [modality '*.nii'];
    targ = dir(searchTarget);
       
    if(size(targ,1)==0)
       fprintf('Did not find %s',nameFolds{i});
       continue;
    end
    
    targ = dir(searchTarget);
    
    fullpath = fullfile(pwd,targ.name);
    partpath = targ(1).name;  
    finalfilename = [modality nameFolds{i} '.nii' ];
        
    finalpath = char(fullfile(outputdir,finalfilename));
   
    

    %mkdir (fullfile (outputdir,nameFolds(i)));
    %copyfile (fullpath,  fullfile (outputdir,nameFolds(i)) );
    copyfile (fullpath,  finalpath);
    
    
end;

