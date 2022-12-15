[files, paths, indices] =uigetfile('*','Select the INPUT DATA FILE(s)','MultiSelect','on');

for i = 1: length(files)
    V = spm_vol(files{1});
    Y = spm_read_vols(V);
    
    for x = 1:size(Y,1)
        for y = 1:size(Y,2)
            for z = 1:size(Y,3)
                if(x >=0)
                    Y(x,y,z) = 0;
                end
                
            end
        end
    end
    
    V.fname = ['LH-only_RH-deleted' V.fname];
    spm_write_vol(V,Y); 
    
end

