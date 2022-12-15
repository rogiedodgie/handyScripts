function nii_suit_vol(fnms)
%process T1 images with suit http://www.diedrichsenlab.org/imaging/suit_function.htm
%   fnms: (optional) filenames of T1 scans to process
%Examples
%   nii_suit() %use gui
%   nii_suit('t.nii.gz') %use gui
%   nii_suit('strvcat('t.nii.gz', 'T1.nii'));

%where to save results from volume query
results_File_Directory = '/Users/rogiedodgie/Desktop/SUIT_ABC';
%point to your SUIT_atlas.nii file
suitAtlasPath = '/Users/rogiedodgie/Desktop/SUIT_ABC/SUIT_atlas.nii,1';
%warnings are just annoying...
warning('off','all')

if isempty(which('spm'))
    error('please install SPM12'); 
end
if ~exist(fullfile(spm('Dir'),'toolbox','suit'), 'dir')
    error('please put suit in your SPM toolbox folder. http://www.diedrichsenlab.org/imaging/suit_download.htm'); 
end
if ~exist('fnms','var')
	fnms = spm_select(inf,'image','Select T1 image[s] for suit'); 
end
if isempty(spm_figure('FindWin','Graphics')), 
    spm fmri; %suit requires SPM is running
end
homeDir = pwd;
useDartel = true;
for i=1:size(fnms,1)
    tic
    fnm = deblank(fnms(i,:));
    [p,n,x] = spm_fileparts(fnm);
    if isempty(p)
       p = homeDir; 
    end
    if startsWith(x,'.gz')
        error('Please provide uncompressed .nii files, not .nii.gz');
    end
    fnm = fullfile(p,[n,x]);
    if ~exist(fnm, 'file')
        error('unable to find %s', fnm);
    end
    tmpDir = fullfile(p,[n, 'Temp']);
    tmpFnm = fullfile(tmpDir, [n,x]);
    mkdir(tmpDir);
    copyfile(fnm, tmpFnm);
    cd(tmpDir);
    [fnm, gmfnm, wmfnm] = suitSub(tmpFnm, useDartel);
    if ~exist(fnm,'file') || ~exist(gmfnm,'file') || ~exist(wmfnm,'file')
        error('Expected files %s %s %s', fnm, gmfnm, wmfnm);
    end
    
    outnmA = fullfile(p,['w',n,x]);
    copyfile(fnm, outnmA);
    outnmB = fullfile(p,['wc1',n,x]);
    copyfile(gmfnm, outnmB);
    outnmC = fullfile(p,['wc2',n,x]);
    copyfile(wmfnm, outnmC);
    cd(homeDir);
    %rmdir(tmpDir, 's');
    
    
    %use SUIT atlas to mask wc, wcc1 and wcc2 images 
    args = {suitAtlasPath;[p '/' n 'Temp/' 'wc' n x ',1' ]};
    matlabbatch{1}.spm.util.imcalc.input = args;
    matlabbatch{1}.spm.util.imcalc.output = ['masked_' 'wc' n x ];
    matlabbatch{1}.spm.util.imcalc.outdir = {tmpDir};
    matlabbatch{1}.spm.util.imcalc.expression = 'i2.*(i1>0)';
    matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{1}.spm.util.imcalc.options.mask = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp = 1;
    matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
        spm_jobman('run',matlabbatch);
    args = {suitAtlasPath;[p '/' n 'Temp/' 'wcc1' n x ',1' ]};
    matlabbatch{1}.spm.util.imcalc.input = args;
    matlabbatch{1}.spm.util.imcalc.output = ['masked_' 'wcc1' n x ];
    matlabbatch{1}.spm.util.imcalc.outdir = {tmpDir};
    matlabbatch{1}.spm.util.imcalc.expression = 'i2.*(i1>0)';
    matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{1}.spm.util.imcalc.options.mask = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp = 1;
    matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
        spm_jobman('run',matlabbatch);
    args = {suitAtlasPath;[p '/' n 'Temp/' 'wcc2' n x ',1' ]};
    matlabbatch{1}.spm.util.imcalc.input = args;
    matlabbatch{1}.spm.util.imcalc.output = ['masked_' 'wcc2' n x ];
    matlabbatch{1}.spm.util.imcalc.outdir = {tmpDir};
    matlabbatch{1}.spm.util.imcalc.expression = 'i2.*(i1>0)';
    matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{1}.spm.util.imcalc.options.mask = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp = 1;
    matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
        spm_jobman('run',matlabbatch);

    %reverse normalize masked images into participant space
    job.Affine = {[p '/' n 'Temp/' 'Affine_c1' n '.mat' ]};
    job.flowfield = {[p '/' n 'Temp/' 'u_a_c1' n '.nii' ]};
    job.resample = {[p '/' n 'Temp/' 'masked_wc' n '.nii' ]};
    job.ref = {[p '/' n 'Temp/' n '.nii' ]};
        suit_reslice_dartel_inv(job) %appends iw to the final file...  
    job.Affine = {[p '/' n 'Temp/' 'Affine_c1' n '.mat' ]};
    job.flowfield = {[p '/' n 'Temp/' 'u_a_c1' n '.nii' ]};
    job.resample = {[p '/' n 'Temp/' 'masked_wcc1' n '.nii' ]};
    job.ref = {[p '/' n 'Temp/' n '.nii' ]};
        suit_reslice_dartel_inv(job) %appends iw to the final file... 
    job.Affine = {[p '/' n 'Temp/' 'Affine_c1' n '.mat' ]};
    job.flowfield = {[p '/' n 'Temp/' 'u_a_c1' n '.nii' ]};
    job.resample = {[p '/' n 'Temp/' 'masked_wcc2' n '.nii' ]};
    job.ref = {[p '/' n 'Temp/' n '.nii' ]};
        suit_reslice_dartel_inv(job) %appends iw to the final file...
    
     %GET total_vol, GM_vol and WM_vol and write to text file
     wc_hdr = spm_vol ([p '/' n 'Temp/' 'iw_masked_wc' n '_u_a_c1' n '.nii' ]);
     wc_dat = spm_read_vols (wc_hdr);
     total_vol = 0;
         %loop through image and get values
         for ii = 1:wc_hdr.dim(1)
             for jj = 1:wc_hdr.dim(2)
                 for kk = 1:wc_hdr.dim(3)
                     if~isnan(wc_dat(ii,jj,kk))
                         if(wc_dat(ii,jj,kk) > 0)
                             total_vol =  total_vol+1;
                         end
                     end
                 end
             end
         end
     wcc1_hdr = spm_vol ([p '/' n 'Temp/' 'iw_masked_wcc1' n '_u_a_c1' n '.nii' ]);
     wcc1_dat = spm_read_vols (wcc1_hdr);
         GM_vol = 0;
         %loop through image and get values
         for ii = 1:wcc1_hdr.dim(1)
             for jj = 1:wcc1_hdr.dim(2)
                 for kk = 1:wcc1_hdr.dim(3)
                     if~isnan(wcc1_dat(ii,jj,kk))
                         if(wcc1_dat(ii,jj,kk) > 0)
                             GM_vol =  GM_vol+1;
                         end
                     end
                 end
             end
         end 
     wcc2_hdr = spm_vol ([p '/' n 'Temp/' 'iw_masked_wcc2' n '_u_a_c1' n '.nii' ]);
     wcc2_dat = spm_read_vols (wcc2_hdr);
         WM_vol = 0;
         %loop through image and get values
         for ii = 1:wcc2_hdr.dim(1)
             for jj = 1:wcc2_hdr.dim(2)
                 for kk = 1:wcc2_hdr.dim(3)
                     if~isnan(wcc2_dat(ii,jj,kk))
                         if(wcc2_dat(ii,jj,kk) > 0)
                             WM_vol =  WM_vol+1;
                         end
                     end
                 end
             end
         end
         
    outputFile = [results_File_Directory '/volInfo.txt'];     
    fid = fopen(outputFile,'a+');
    fprintf(fid, '%s\t%d\t%d\t%d\n',n,total_vol,GM_vol, WM_vol);
    fclose(fid);
    
    toc
    
end
%end nii_suit()

function [fnm, gmfnm, wmfnm] = suitSub(fnm, useDartel)
[p,n,x] = spm_fileparts(fnm);
aIsolateSub(fnm);
gmfnm = fullfile(p,['c1',n, x]); %gray
wmfnm = fullfile(p,['c2',n, x]); %white
%in theory this should work, but suit_isolate_seg cropping fails with oblique scans
if false
    cfnm = fullfile(p,['c_', n, x]); %cropped
    pfnm = fullfile(p,['c_', n, '_pcereb', x]); %percent
else
    cfnm = fnm;
    pfnm = makeSumSub({gmfnm; wmfnm});
end
if useDartel
    bNormEstDartelSub(gmfnm, wmfnm, pfnm);
else
    bNormEstSub(cfnm, pfnm);
end
[~, pn] = fileparts(cfnm);
matnm = fullfile(p,['m',pn, '_snc.mat']); %white '/home/chris/Desktop/suit/mT1_snc.mat'};
if useDartel
  cNormWriteDartelSub(fnm);   
  fnm = fullfile(p,['wc', pn, x]); %percent
else
    cNormWriteSub(matnm, {gmfnm; wmfnm});
fnm = fullfile(p,['wm', pn, x]); %percent
end
gmfnm = fullfile(p,['wcc1',n, x]); %gray
wmfnm = fullfile(p,['wcc2',n, x]); %white

%end nii_suit

function sumfnm = makeSumSub(fnms)
hdr = spm_vol(fnms{1});
img = spm_read_vols(hdr);
for i = 2:numel(fnms)
    hdr = spm_vol(fnms{i});
    img = img + spm_read_vols(hdr);
end
[p,n,x] = spm_fileparts(fnms{1});
sumfnm = fullfile(p, ['sum_',num2str(numel(fnms)), '_', n, x]);
hdr.fname = sumfnm;
spm_write_vol(hdr,img);
%end makeSumSub()

function aIsolateSub(fnm)
%isolate the cerebellum and segment into gray and white matter
if ~isempty(which('nii_setOrigin12'))
    nii_setOrigin12(fnm)
elseif ~isempty(which('nii_setOrigin12x'))
    nii_setOrigin12x(fnm)
else
    error('please install nii_setOrigin12x https://github.com/rordenlab/spmScripts'); 
end
matlabbatch{1}.spm.tools.suit.isolate_seg.source = {{fnm}};
matlabbatch{1}.spm.tools.suit.isolate_seg.bb = [-76 76; -108 -6; -70 11];
matlabbatch{1}.spm.tools.suit.isolate_seg.maskp = 0.1;
matlabbatch{1}.spm.tools.suit.isolate_seg.keeptempfiles = 1;
spm_jobman('run',matlabbatch);
%end aIsolateSub()


function bNormEstDartelSub(gmfnm, wmfnm, pfnm)
%normalize cerebellum to standard space using Dartel
matlabbatch{1}.spm.tools.suit.normalise_dartel.subjND.gray = {gmfnm};
matlabbatch{1}.spm.tools.suit.normalise_dartel.subjND.white = {wmfnm};
matlabbatch{1}.spm.tools.suit.normalise_dartel.subjND.isolation = {pfnm};
spm_jobman('run',matlabbatch);
%end bNormEstSub()

function bNormEstSub(fnm, pfnm)
%normalize cerebellum to standard space
matlabbatch{1}.spm.tools.suit.normalise.subjN.source = {fnm};
matlabbatch{1}.spm.tools.suit.normalise.subjN.mask = {pfnm};
matlabbatch{1}.spm.tools.suit.normalise.subjN.lesion_mask = '';
matlabbatch{1}.spm.tools.suit.normalise.prefix = 'w';
template = fullfile(spm('Dir'),'toolbox','suit', 'templates', 'SUIT.nii');
matlabbatch{1}.spm.tools.suit.normalise.template = {template};
wt = fullfile(spm('Dir'),'toolbox','suit', 'templates', 'SUIT_weight.nii');
matlabbatch{1}.spm.tools.suit.normalise.template_weight = {wt};
matlabbatch{1}.spm.tools.suit.normalise.param_postfix = '_snc';
matlabbatch{1}.spm.tools.suit.normalise.smooth_mask = 2;
matlabbatch{1}.spm.tools.suit.normalise.estimate.smosrc = 2;
matlabbatch{1}.spm.tools.suit.normalise.estimate.smoref = 0;
matlabbatch{1}.spm.tools.suit.normalise.estimate.regtype = 'subj';
matlabbatch{1}.spm.tools.suit.normalise.estimate.cutoff = 10;
matlabbatch{1}.spm.tools.suit.normalise.estimate.nits = 30;
matlabbatch{1}.spm.tools.suit.normalise.estimate.reg = 1;
matlabbatch{1}.spm.tools.suit.normalise.write.preserve = 1;
matlabbatch{1}.spm.tools.suit.normalise.write.bb = [-70 -100 -75; 70 -6 11];
matlabbatch{1}.spm.tools.suit.normalise.write.vox = [1 1 1];
matlabbatch{1}.spm.tools.suit.normalise.write.interp = 1;
matlabbatch{1}.spm.tools.suit.normalise.write.wrap = [0 0 0];
spm_jobman('run',matlabbatch);
%end bNormEstSub()

function cNormWriteSub(matnm, fnms)
%warp tissue maps to standard space cerebellum to standard space
matlabbatch{1}.spm.tools.suit.reslice.subj.paramfile = {matnm};
matlabbatch{1}.spm.tools.suit.reslice.subj.resample = fnms;
matlabbatch{1}.spm.tools.suit.reslice.subj.mask = {};
matlabbatch{1}.spm.tools.suit.reslice.smooth_mask = 2;
matlabbatch{1}.spm.tools.suit.reslice.preserve = 1;
matlabbatch{1}.spm.tools.suit.reslice.bb = [NaN NaN NaN; NaN NaN NaN];
matlabbatch{1}.spm.tools.suit.reslice.vox = [1 1 1];
matlabbatch{1}.spm.tools.suit.reslice.interp = 1;
matlabbatch{1}.spm.tools.suit.reslice.prefix = 'wc';
spm_jobman('run',matlabbatch);
%end cNormWriteSub()

function cNormWriteDartelSub(fnm)
[p,n,x] = fileparts(fnm);
nm = fullfile(p,['Affine_c1',n,'.mat']);
matlabbatch{1}.spm.tools.suit.reslice_dartel.subj.affineTr = {nm};
nm = fullfile(p,['u_a_c1',n,x,',1']);
matlabbatch{1}.spm.tools.suit.reslice_dartel.subj.flowfield = {nm};
gmfnm = fullfile(p,['c1',n,x,',1']);
wmfnm = fullfile(p,['c2',n,x,',1']);
matlabbatch{1}.spm.tools.suit.reslice_dartel.subj.resample = {fnm; gmfnm; wmfnm};
msk = fullfile(p,['sum_2_c1',n,x,',1']);
matlabbatch{1}.spm.tools.suit.reslice_dartel.subj.mask = {msk};
matlabbatch{1}.spm.tools.suit.reslice_dartel.jactransf = 1;
matlabbatch{1}.spm.tools.suit.reslice_dartel.K = 6;
matlabbatch{1}.spm.tools.suit.reslice_dartel.bb = [-70 -100 -75; 70 -6 11];
matlabbatch{1}.spm.tools.suit.reslice_dartel.vox = [1 1 1];
matlabbatch{1}.spm.tools.suit.reslice_dartel.interp = 1;
matlabbatch{1}.spm.tools.suit.reslice_dartel.prefix = 'wc';
spm_jobman('run',matlabbatch);
%end cNormWriteDartelSub()