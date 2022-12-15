 

%sum all lesion maps
data = dir('wr*SW.nii');
%data = dir('LR*')
L = [];
R = [];
A = [];
P = [];
S = [];
I = [];


for i = 1:size(data,1)
    L(i) = 0;
    R(i) = 0;
    A(i) = 0;
    P(i) = 0;
    S(i) = 0;
    I(i) = 0;
    
    in_hdr = spm_vol (data(i).name);
    in_dat = spm_read_vols (in_hdr);
    lr_differentiator = size(in_dat,1)/2
    ap_differentiator = size(in_dat,2)/2
    si_differentiator = size(in_dat,3)/2
       
       for ii = 1:in_hdr.dim(1)
        for jj = 1:in_hdr.dim(2)
            for kk = 1:in_hdr.dim(3)
                if (in_dat(ii,jj,kk) > 0)
                   if (ii < lr_differentiator)
                     L(i) = L(i) +1;
                   end
                   if(ii > lr_differentiator)
                     R(i) = R(i) +1;
                   end
                   
                   if (jj < ap_differentiator)
                     P(i) = P(i) +1;
                   end
                   if(jj > ap_differentiator)
                     A(i) = A(i) +1;
                   end
                   
                   if (kk < si_differentiator)
                     I(i) = I(i) +1;
                   end
                   if(kk > si_differentiator)
                     S(i) = S(i) +1;
                   end
                   
                   
                   
                   
                   
                end
            end
         end
       end
    
end

res = [L' R' A' P' I' S']
L
R
