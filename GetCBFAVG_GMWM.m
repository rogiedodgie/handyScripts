clc
clear
format short 

%some key variables
WMCertainty = 0.9; %probability of WM must be above this number to count as WM
GMCertainty = 0.9; %probability of GM must be above this number to count as WM

GM = [];
WM = [];

%sum all lesion maps
ABCdata = dir('ABC*.nii');
CNABCdata =  dir('CNABC*.nii');

DATA = [ 'COVID/' ABCdata];

GMtemplate = 'MNI152_T1_1mm_Brain_FAST_pve_1_GM.nii';
WMtemplate = 'MNI152_T1_1mm_Brain_FAST_pve_2_WM.nii';
AICHAtemplate = 'AICHA.nii'; %if you want to use AICHA for some reason??
%load atlases
GM_hdr = spm_vol (GMtemplate)
GM_dat = spm_read_vols(GM_hdr);
WM_hdr = spm_vol (WMtemplate)
WM_dat = spm_read_vols(WM_hdr);
AICHA_hdr = spm_vol (AICHAtemplate)
AICHA_dat = spm_read_vols(AICHA_hdr);

for i = 1:length(DATA)
 
 %Load Raw CBF file
 RAW_cbfFile_hdr = spm_vol (DATA(i).name);
 RAW_cbfFile_dat = spm_read_vols (RAW_cbfFile_hdr);
 %reslice CBF to MNI templates (GM and WM are the same) resolution of 182x218x182
 nii_reslice_target(RAW_cbfFile_hdr, RAW_cbfFile_dat, WM_hdr)
 %Load up CBF file in same resolution as GM WM maps for conjunction mean
 cbfFile_hdr = spm_vol (['r' DATA(i).name]);
 cbfFile_dat = spm_read_vols (cbfFile_hdr);
 
 total = 0;
 CBFcum = 0;
 %loop through image and get values
 for ii = 1:cbfFile_hdr.dim(1)
     for jj = 1:cbfFile_hdr.dim(2)
         for kk = 1:cbfFile_hdr.dim(3)
             if(  (cbfFile_dat(ii,jj,kk) < 100) && (cbfFile_dat(ii,jj,kk) > 35) && (GM_dat(ii,jj,kk) > GMCertainty))
            % if(  (cbfFile_dat(ii,jj,kk) >36 )&&(cbfFile_dat(ii,jj,kk) <100 )&& (AICHA_dat(ii,jj,kk) > 0))
                CBFcum = CBFcum+cbfFile_dat(ii,jj,kk);
                total = total+1;
                %fprintf('CBFscore=%d\n',cbfFile_dat(ii,jj,kk));
             end
         end
     end
 end
 
 GM(i) = CBFcum/total;
 fprintf('Average GM intensity = %d\n', GM(i));
 
 total = 0;
 CBFcum = 0;
 %loop through image and get values
 for ii = 1:cbfFile_hdr.dim(1)
     for jj = 1:cbfFile_hdr.dim(2)
         for kk = 1:cbfFile_hdr.dim(3)
             if( (cbfFile_dat(ii,jj,kk) >15) && (cbfFile_dat(ii,jj,kk) <45) && (WM_dat(ii,jj,kk) > WMCertainty))
            %  if((cbfFile_dat(ii,jj,kk) < 45)  && (cbfFile_dat(ii,jj,kk) >15)  && (AICHA_dat(ii,jj,kk) == 0))
                CBFcum = CBFcum+cbfFile_dat(ii,jj,kk);
                total = total+1;
                %fprintf('CBFscore=%d\n',cbfFile_dat(ii,jj,kk));
             end
         end
     end
 end
 
 WM(i) = CBFcum/total;
 fprintf('Average WM intensity = %d\n',  WM(i));
 
 
 
 
 
end


for i = 1:size(DATA,1)
      [x y z] = fileparts(DATA(i).name)
      name{i} = y;
      name = transpose(name)
end
GM = transpose(GM)
WM = transpose(WM)
ALL = [GM WM]
format short;

T = table(ALL,'RowNames',name)
writetable(T,'ALL_results.txt','WriteRowNames',true);








