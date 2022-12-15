eT1dir = '/Volumes/Rainbowy/EVPS_T1s_minmaxNormed/'
EVPSdir  = '/Volumes/Rainbowy/deleteme/'
templateMask = fullfile(maindir,'/','avg152T1_white.nii');
templateMask =  '/Volumes/Rainbowy/deleteme/MNI152_T1_1mm_brain.nii'
data = dir([EVPSdir 'out*.nii'])
thresh = 50; %seems to be a good threshold for avg152T1_white.nii (range = 0:250)

for i = 1:length(data)

    try
    fnmEVPS = fullfile(data(i).folder, data(i).name);
    fnmeT1 =  [eT1dir strrep(data(i).name, 'out_rx','x')];

    
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = { [fnmeT1 ',1']};
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample =  { [fnmEVPS ',1']};
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.tpm = {'/Users/roger/Documents/neuro/spm12/tpm/TPM.nii'};
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.samp = 3;
    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.bb = [-78 -112 -70
                                                                 78 76 85];
    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.vox = [2 2 2];
    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.interp = 4;
    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.prefix = 'w';

    
     spm_jobman('run',matlabbatch);
       
     normedoutput = strrep(fnm,'out_rx','wout_rx')
     % mask with WMH probability map.....
     nii_reslice_target(templateMask,'',normedoutput,false);
     reslicedTemplate = strrep(templateMask,'MNI','rMNI')
     nii_mask(normedoutput,reslicedTemplate,thresh, 0.0);%also get from manual inspection, need to autom
    
    
         fprintf('succeeded on %s\n', fnmEVPS);
         clear matlabbatch
    catch
        clear matlabbatch
        fprintf('failed on %s\n', fnmEVPS);
    end
    
    
end

%also mask with WM, since PVS really only in the WM that I want



