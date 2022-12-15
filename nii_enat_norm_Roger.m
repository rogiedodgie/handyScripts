clear all;

d = dir('LESION*nii');

nni = 1;

for i = 1: length(d)
    
    lesion_name = d(i).name;
    [x y z] = fileparts(lesion_name);
    t1_name = ['T1' char(extractBetween(y,7,length(y))) '.nii' ];
    t2_name = ['T2' char(extractBetween(y,7,length(y))) '.nii'];

    if(isfile(t1_name) & isfile(t2_name) & isfile(lesion_name))
        nii_enat_norm(t1_name,lesion_name,t2_name); 
        fprintf('Running participant %s ',t1_name);
    else
        notnormal{nni} = t1_name;
        nni=nni+1;
        fprintf('Skipping participant %s because not all images present.',t1_name);
    end
    
    
    %nii_enat_norm('LESION_M2002.nii','T1_M2002.nii','T1_M2002.nii')
 
    delete wT1*
    delete wsrLES*
    delete wbT1*
    delete bT1*
    delete y_eT1*
    delete rc*
    delete c*
    delete iy*
    delete *seg*
    delete sr*
    delete rLES*
    delete rT2*
    delete spm*
    delete *.mat
    
end

