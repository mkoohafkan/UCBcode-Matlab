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
imgnames = imgnames(3:end, 1) ;
realareas = zeros(length(imgnames), 1) ;

%% get leaf areas
for n = 1:length(imgnames)
    realareas(n, 1) = getleafarea(imgfolder, imgnames{n, 1}) ;
end
% convert to cm
realareas = 6.4516*realareas ;

%% save results to file
%# write line-by-line
fid = fopen('leafareas.csv', 'wt');
fprintf(fid, '%s, %s\n', 'imagename', 'area (cm2)') ;
for i=1:size(realareas,1)
    fprintf(fid, '%s,%d\n', imgnames{i, 1}, realareas(i, 1)) ;
end
fclose(fid);

