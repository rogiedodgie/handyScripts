%harvest T1s from Master_DB
inputdir = uigetdir('/Volumes','Pick INPUT dir')
%outputdir = uigetdir('/Volumes','Pick OUTPUT dir')


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
    if strfind(cpth,'LIME')
        nameFolds(i) = {'.'}; %disallow anything with a point later on, so if has a '2133' just say it is a .
    end
    if strfind(cpth,'M.')
        nameFolds(i) = {'.'}; %disallow anything with a point later on, so if has a '2133' just say it is a .
    end
end

%this has a list of 
nameFolds(ismember(nameFolds,{'.','..'})) = [];


for i = 1:length(nameFolds)
	
    %for each folder first change directory into that folder
    cd(char(fullfile(inputdir,nameFolds(i))))
    
       delete .DS_Store;
   delete ._.DS_Store;

   
end;

