clear all
files = dir('L*.nii')
results = [];
baddycount = [];

for i = 1:length(files)

    numbadvox = 0;
    %load up activity map (i.e. the contast image)
    Map_hdr = spm_vol (files(i).name);
    Map_dat = spm_read_vols (Map_hdr);
   vectorDat = Map_dat(:); 
    maxvalue(i) = max(vectorDat);
    name(i) = {files(i).name};
    
    %fix high values by bringing down to 1
    for ii = 1:Map_hdr.dim(1)
        for j = 1:Map_hdr.dim(2)
            for k = 1:Map_hdr.dim(3)
                if (Map_dat(ii,j,k) > 1)
                    %fprintf('Nonzero Voxel found at %d , %d , %d and badvoxel = %d\n',ii,j,k,Map_dat(ii,j,k));
                    Map_dat(ii,j,k) = 1;
                    numbadvox = numbadvox+1;
                end
            end
        end
    end
    fprintf('Found %d bad voxels (above 1)!\n',numbadvox);
    baddycount(i) = numbadvox;
    
   %make ones zeros and zeros ones, aka invert it so lesions = zero which
   %is what Cat12 likes!
   for ii = 1:Map_hdr.dim(1)
        for j = 1:Map_hdr.dim(2)
            for k = 1:Map_hdr.dim(3)
                if (Map_dat(ii,j,k) == 1)
                    Map_dat(ii,j,k) = 0;
                elseif (Map_dat(ii,j,k) == 0)
                    Map_dat(ii,j,k) = 1;
                else
                    %do nothing
                end
            end
        end
    end
    
    Map_hdr.fname = ['f' Map_hdr.fname];
    spm_write_vol(Map_hdr, Map_dat);
  
end

%cell2csv('output.csv',transpose(name),',')
