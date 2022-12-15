function ROI_Conglomerator()
   
    %%%leave this line uncommented to choose atlas using the GUI
    [inuptfile, folder] = uigetfile();
    %%%if you use the same atlas many times, leave the following two lines
    %%%uncommented after typing the path to the atlas so you don't have to
    %%%choose it every time you make a new image
    %inputfile = 'aal.nii'
    %folder = 'G:\_Mpaths\NiiStat\roi'
 
    %specify numbers of ROIs from the atlas to put in the new image
    roisToInclude = [74 82];
    
    %%%use usual spm functions to load the image header and matrix
  	atlas_hdr = spm_vol (fullfile(folder, inputfile));
    atlas_dat = spm_read_vols (atlas_hdr);
    
    %%%go through the 3D matrix substituting a 1 for any number in your
    %%%'roisToInclude' and a 0 if not in that set
    for ii = 1:size(atlas_dat,1)
        for jj = 1:size(atlas_dat,2)
            for kk = 1:size(atlas_dat,3)
                if(   ismember (atlas_dat(ii,jj,kk), roisToInclude)            )
                    atlas_dat(ii,jj,kk) = 1;
                else
                    atlas_dat(ii,jj,kk) = 0;
                end
            end
        end
    end
    
    %%%create name for image to be saved
    atlas_hdr.fname =  fullfile(pwd,'newConglomerate.nii')
    
    %%%use SPM's image writing function to write that new image based on
    %%%the filename in the header, and the modified 3d matrix of values
    spm_write_vol(atlas_hdr, atlas_dat);