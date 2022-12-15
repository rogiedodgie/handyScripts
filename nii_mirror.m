function nii_mirror(fnms)
%Given image with left and right hemisphere (LR), create LL and RR images
% fnm: filename of NIfTI image
%Examples
% nii_mirror('eT1.nii')
% nii_mirror({'eT1_M1000.nii', 'eT1_M1001.nii'})

if ~exist('fnms','var'), 
    fnms = spm_select(1,'image','Select image(s)');
end;
if ischar(fnms)
    fnms = {fnms};
end
for i = 1 : numel(fnms)
    fnm = fnms{i};
    fprintf('processing %s\n', fnm);
    mirrorSub(fnm);
end
%end nii_mirror

function mirrorSub (anatImg)
%given LR and RL images, create LL and RR images
% anatImg   : filename of anatomical scan
%returns name of new image with two 'intact' hemispheres
if (exist(anatImg,'file') == 0)
    error('%s unable to find image %s',mfilename, anatImg);
end
%create flipped image 
hdr = spm_vol(anatImg); 
img = spm_read_vols(hdr);
[pth, nam, ext] = spm_fileparts(hdr.fname);
fname_flip = fullfile(pth, ['flip', nam, ext]);
hdr_flip = hdr;
hdr_flip.fname = fname_flip;
hdr_flip.mat = [-1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1] * hdr_flip.mat;
spm_write_vol(hdr_flip,img); 
%coregister data
hdr_flip = spm_vol(fname_flip); 
x  = spm_coreg(hdr_flip,hdr); 
%apply half of transform to find midline
x  = (x/2); 
M = spm_matrix(x);
MM = spm_get_space(fname_flip);
spm_get_space(fname_flip, M*MM); %reorient flip
M  = inv(spm_matrix(x)); 
MM = spm_get_space(hdr.fname);
spm_get_space(hdr.fname, M*MM); %#ok<MINV> %reorient original so midline is X=0
%reslice half way
P            = char(hdr.fname,fname_flip);
flags.mask   = 1;
flags.mean   = 0;
flags.interp = 4;
flags.which  = 1;
flags.wrap   = [0 0 0];
flags.prefix = 'r';
spm_reslice(P, flags);
delete(fname_flip); %remove flipped file
fname_flip = fullfile(pth,['rflip' nam ext]);%resliced flip file
hdr_flip = spm_vol(fname_flip); 
imgFlip = spm_read_vols(hdr_flip);
isLR = zeros(size(img));
j = 1;
for z = 1 : size(img, 3)
   for y = 1 : size(img, 2)
    for x = 1 : size(img, 1)
        vox = [x,y,z];
        mm=vox*hdr_flip.mat(1:3, 1:3)'+hdr_flip.mat(1:3, 4)';
        if (mm(1) > 0)
            isLR(j) = 1.0;
        end
        j = j + 1;
    end
   end
end
%optional:
% delete(fname_flip); %remove resliced flipped file
rdata = (img(:) .* (1.0-isLR(:)))+ (imgFlip(:) .* isLR(:));
rdata = reshape(rdata, size(img));
hdr_flip.fname = fullfile(pth,['LL' nam ext]);%image with lesion filled with intact hemisphere
spm_write_vol(hdr_flip,rdata);
%only right
rdata = (imgFlip(:) .* (1.0-isLR(:)))+ (img(:) .* isLR(:));
rdata = reshape(rdata, size(img));
hdr_flip.fname = fullfile(pth,['RR' nam ext]);%image with lesion filled with intact hemisphere
spm_write_vol(hdr_flip,rdata);
%end entiamorphicSub()

function nam = prefixSub (pre, nam)
[p, n, x] = spm_fileparts(nam);
nam = fullfile(p, [pre, n, x]);
%end prefixSub()