function ABCHarvestAndZipMultipleModalitiesPerParticipant (modalitiesToInclude)
%example 
%ABCHarvestAndZipMultipleModalitiesPerParticipant({'T1','fMRI_f','fMRI_p','fme1','fme2','fmp','Rest','ASL','ASLrev',})
%harvest T1s from Master_DB
%T1,SWI,FLAIR,ASL,ASLrev,Rest,
%ABCHarvestAndZipMultipleModalitiesPerParticipantRawData({'w_RMS.ni','FLAIR.ni','dwi'})

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
    filesToZip = {};
    fileFoundCtr = 0;
    
    for m = 1:length(modalitiesToInclude)
       % if(modalitiesToInclude{m} ~= 'DTI')
            cd(char(fullfile(inputdir,nameFolds(i))))
            %666cd('ABC')
            searchTarget = [ '*' modalitiesToInclude{m} '*' ]
            %targ = rdir('FLAIR*.nii')
            targ = rdir(searchTarget)
            
            x = modalitiesToInclude{m}
            xx = 'DTI'
            
            if(strcmpi(modalitiesToInclude{m} , 'dwi'))
                for j = 1:length(targ)
                    if(~isempty(targ))
                        fileFoundCtr = fileFoundCtr+1;
                        warg = targ{j}
                        namedFile = warg(length(searchTarget)+2:length(warg))
                        filesToZip{fileFoundCtr} = namedFile;
                    end
                end
            else
                if(~isempty(targ))
                    fileFoundCtr = fileFoundCtr+1;
                    warg = targ{1}
                    namedFile = warg(length(searchTarget)+2:length(warg))
                    filesToZip{fileFoundCtr} = namedFile;
                end
            end
            
            
        %end
%         if(modalitiesToInclude{m} == 'DTI')
%             
%             cd(char(fullfile(inputdir,nameFolds(i))))
%             cd('ABC')
%             searchTarget = [modalitiesToInclude{m} '*.nii' ]
%         end
        
    end
    
    if(length(filesToZip) ~= 0)
        zip([char(nameFolds(i))],filesToZip);
        fullZippath = fullfile(inputdir,char(nameFolds(i)), [char(nameFolds(i)) '.zip']);
        finalpath =   fullfile(outputdir,[char(nameFolds(i)) '.zip']);
        movefile(fullZippath,  finalpath);
        delete(fullZippath);  %remove extra copy
    end
    
    
end

