%% initialize
close all ;
clear all ;
%% get file list
imgfolder = 'img' ;
imgfiles = struct2cell(dir(imgfolder)) ;
numimages = length(imgfiles) ;
imgnames = cell(numimages, 1) ;
for i =1:numimages
    imgnames{i, 1} = imgfiles{1, i} ;
end
imgnames = imgnames(4:end, 1) ;
realareas = zeros(length(imgnames), 1) ;

%% get leaf areas
for n = 1:length(imgnames)
    realareas(n, 1) = getleafarea(imgfolder, imgnames{n, 1}, true) ;
end
% convert to cm
realareas = 6.4516*realareas ;

%% save results to file
TempTime=clock;
ts = [date '_' num2str(TempTime(4),'%02.0f') num2str(TempTime(5),'%02.0f')];
%# write line-by-line
fid = fopen(['leafareas' ts '.csv'], 'w+');
fprintf(fid, '%s,%s,%s\n', 'imagename', 'trialname', 'area_cm2') ;
for i=1:size(realareas,1)
    fprintf(fid, '%s,%s,%01.4f\n', imgnames{i, 1}, imgnames{i, 1}(1:end-4), realareas(i, 1)) ;
end
fclose(fid);