%this script will flip .nii files LR
%this is handy if you , say, do a motor cortex functional localizer with 
%Roch from Brainsight and you ppc the data and it shows right hemisphere
%activation when the task was Right Hand movement andyou are like
%what the heck and Roch is like what the heck, and then you feel like a 
%dumbass...
immy = 'C:\Users\Magic\Desktop\PVROI\RHPV.nii'
%immy = spm_select();
hdr = spm_vol (immy)
img = spm_read_vols (hdr);

hdr1 = hdr;
hdr1.fname = strcat(immy);

img1 = img;
img1 = flip (img, 1);

pathlength = size(immy,2);
addon = '_FLIPPED.nii';
addonL = size(addon,2);
immy(pathlength-3:pathlength+addonL-4) = addon;
hdr1.fname = immy;

spm_write_vol (hdr1, img1);