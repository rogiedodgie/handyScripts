function nii_lesionpercents(indir)
%Load each M*.mat file from indir

if ~exist('indir','var')
   indir = pwd;
   indir = '/Volumes/Expansion 1/BOX_BACKUP_07-01-2021/MASTER_FILES_08_2019';
end
atlas = 'lesion_bro'; %lesion_AICHA
AreasToInclude = [1:82];

nOK = 0;
fnms = dir(fullfile(indir,'M*.mat'));
fid = fopen('exp.tab','w');
for i = 1:numel(fnms)
   fnm = fullfile(indir, fnms(i).name);
   m = load(fnm);
   if ~isfield(m,atlas), continue; end;
   frac = m.(atlas).mean(AreasToInclude);
   if (sum(frac) <= 0.0), continue; end;
   nOK = nOK + 1;
   if (nOK == 1)
     fprintf(fid,'ID');
     for j = 1 : numel(AreasToInclude)
        fprintf(fid,'\t%s', strtrim(m.(atlas).label(AreasToInclude(j),:)));
     end
     fprintf(fid,'\n');
   end

   [~,ID] = fileparts(fnms(i).name);
   fprintf(fid, '%s', ID);
   for j = 1 : numel(AreasToInclude)
    fprintf(fid, '\t%g', m.(atlas).mean(AreasToInclude(j)));
   end
   fprintf(fid, '\n');
end
fclose(fid);