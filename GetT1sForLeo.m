ChrisArcDirLittle = '/Volumes/Expansion/nat';
outputDir = '/Users/rorden/Desktop/LeoAgeProject/results'
images_data = importdata('/Users/rorden/Desktop/LeoAgeProject/images.csv');

for i = 1: size(images_data.data,1)

    %get path to output file and name appropriately
    folName = images_data.textdata(i);
     spl = strsplit(folName{1},{'a','c','b'})
     extraYears = str2num(spl{2})/365           %convert days after stroke to years
     baseYears = images_data.data(i,1)
     ageActual = baseYears+extraYears;
         ageActual = round(ageActual*100)/100   %round to nearest 100th
     gender = images_data.data(i,2)
     
     T1Name = fullfile(outputDir,[spl{1} num2str(gender) '_' num2str(ageActual) '.nii']);
 
     %get path to target T1
     %if folder exists and T1_.nii (aka not dummy) exists then gaty
     x = fullfile(ChrisArcDirLittle,folName)
     if isdir(fullfile(ChrisArcDirLittle,folName)) && exist([x{1} '/T1_.nii'])
         targetT1 = [x{1} '/T1_.nii'];
         copyfile(targetT1,T1Name);
         fprintf("Copied %s to results folder",targetT1);
     end

end


T1s =dir ('*/*/T1*.nii')
RESTs =dir ('*/*/*/Rest*.nii')
DTIs =dir ('*/*/*/DTI*')
for i = 1:length(DTIs)
    s1 =strsplit(DTIs(i).folder,'.')
    %copyfile(fullfile(T1s(i).folder, T1s(i).name), ['/Volumes/SpeedRacer/T1/rxM00' s1{2} '.nii' ] );
    %copyfile(fullfile(RESTs(i).folder, RESTs(i).name), ['/Volumes/SpeedRacer/REST/Rest_scan' s2{2} '.nii' ] );
    [x y z] = fileparts(fullfile(DTIs(i).folder, DTIs(i).name))
    copyfile(fullfile(DTIs(i).folder, DTIs(i).name), ['/Volumes/SpeedRacer/DTI/' y '_' s1{2} z ] );

end