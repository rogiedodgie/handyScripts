%-----------------------------------------------------------------------
% Preprocessing steps to take sequential ABC input (T1s, FLAIRs and WMH manual drawing
% masks
%1) Coregisters T1 and FLAIR, bringing WMH drawing on Flair along for the
%ride
%2) Normalizes the T1, and uses those warps to bring the WMH drawing into
%standard SPM_152 space
%3) Uses nii_nii2mat to create .mat files containing the normalized lesions
%that can be used like usual in NiiStat/NiiStatGUI
% Roger Newman-Norlund (rogiedodgie@gmail.com) - 04/20/2021

%this is what changes between particiant file names, so easiest to manually
%put it in since numbering is not quite standard
names = ['1001',
        '1002',
        '1003',
        '1004',
        '1005',
        '1006',
        '1007',
        '1008',
        '1009',
        '1010',
        '1011',
        '1012',
        '1013',
        '1014',
        '1015',
        '1016',
        '1017',
        '1018',
        '1019',
        '1020',
        '1021',
        '1022',
        '1023',
        '1024',
        '1025',
        '1026',
        '1027',
        '1028',
        '1029',
        '1030',
        '1031',
        '1032',
        '1033',
        '1034',
        '1035',
        '1036',
        '1037',
        '1038',
        '1039',
        '1040',
        '1041',
        '1042',
        '1043',
        '1044',
        '1045',
        '1046',
        '1047',
        '1048',
        '1049',
        '1050',
        '1051',
        '1052',
        '1053',
        '1054',
        '1055',
        '1056',
        '1057',
        '1058',
        '1059',
        '1060',
        '1061',
        '1062',
        '1063',
        '1064',
        '1065',
        '1066',
        '1067',
        '1068',
        '1069'];
        
    
    
%COREGSTEP
%loop through names
for i = 1:size(names, 1)

name = names(i,:)

if exist( ['ABC' name '.nii'],'file')

    ref = {fullfile('C:\Users\Magic\Desktop\RawABCAndSarah', ['ABC' name '.nii,1'])}            %construct path to T1
    source = {fullfile('C:\Users\Magic\Desktop\RawABCAndSarah', ['ABC' name '_FLAIR.nii,1'])}   %construct path to FLAIR
    other = {fullfile('C:\Users\Magic\Desktop\RawABCAndSarah', ['ABC' name '_WMH_SW.nii,1'])}   %construct path to WMH drawing

    matlabbatch{1}.spm.spatial.coreg.estwrite.ref = ref;%{'C:\Users\Magic\Desktop\RawABCAndSarah\ABC1001.nii,1'};
    matlabbatch{1}.spm.spatial.coreg.estwrite.source = source;%{'C:\Users\Magic\Desktop\RawABCAndSarah\ABC1001_FLAIR.nii,1'};
    matlabbatch{1}.spm.spatial.coreg.estwrite.other = other;%{'C:\Users\Magic\Desktop\RawABCAndSarah\ABC1001_WMH_SW.nii,1'};
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
    
    spm_jobman('run',matlabbatch);
    clear matlabbatch;
end


end

%normstep
for i = 1:size(names, 1)

name = names(i,:)

    if exist( ['ABC' name '.nii'],'file')
        vol = {fullfile('C:\Users\Magic\Desktop\RawABCAndSarah', ['ABC' name '.nii,1'])}                    %construct path to T1
        resample = { fullfile('C:\Users\Magic\Desktop\RawABCAndSarah', ['r' 'ABC' name '_WMH_SW.nii,1'])    %construct path to realigned WMH from prior loop
            fullfile('C:\Users\Magic\Desktop\RawABCAndSarah', ['r' 'ABC' name '_FLAIR.nii,1'])              %construct path to realigned FLAIR from prior loop
        }

        matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = vol
        matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = resample
        matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
        matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
        matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.tpm = {'G:\_MPaths\spm12\tpm\TPM.nii'};
        matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
        matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];
        matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
        matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.samp = 3;
        matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.bb = [-78 -112 -70
                                                                    78 76 85];
        matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.vox = [1 1 1];
        matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.interp = 4;
        matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.prefix = 'w';

       spm_jobman('run',matlabbatch);
       
       %After normalizing WMH map, make sure image is binary by setting all
       %voxels > 0 to equal 1
       in_hdr = spm_vol (fullfile('C:\Users\Magic\Desktop\RawABCAndSarah', ['wr' 'ABC' name '_WMH_SW.nii']));
       in_dat = spm_read_vols (in_hdr);
       
       for ii = 1:in_hdr.dim(1)
        for jj = 1:in_hdr.dim(2)
            for kk = 1:in_hdr.dim(3)
                if (in_dat(ii,jj,kk) > 1)
                    in_dat(ii,jj,kk) = 1;
                end
            end
         end
       end
       spm_write_vol(in_hdr, in_dat);
       
       
       
       clear matlabbatch;
    end
end

%ConvertToMatFileStep
%use nii_nii2mat to convert normalized WMH drawings to .mat files
%** As a final sanity check, just make sure to overlay normalized FLAIR, and normalized WMH on template to
%ensure all went well
for i = 1:size(names, 1)

    name = names(i,:)
    
    if exist( ['ABC' name '.nii'],'file')
        niiFile = {fullfile('C:\Users\Magic\Desktop\RawABCAndSarah', ['wrABC' name '_WMH_SW.nii'])}
        nii_nii2mat(char(niiFile),1,['ABC' name '_WMH.mat']);
    end

end
 

