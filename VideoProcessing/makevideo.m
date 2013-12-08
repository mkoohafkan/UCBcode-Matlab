function vid = makevideo(matchstring, videoname, fps)
if nargs < 1
    matchstring = '*tiff' ;
end
if nargs < 2
    videoname = 'outvideo.avi' ;
end
if nargs < 3
    fps = 2 ;
end
% get list of files with specified extension
filelist = ls(matchstring) ;
imagenames = strtrim(mat2cell(filelist, ones(size(filelist, 1), 1))) ;
% sort files
imagestrings = regexp([imagenames{:}], '(\d*)', 'match') ;
imagenumbers = str2double(imagestrings) ;
[~,sortidx] = sort(imagenumbers) ;
sortednames = imagenames(sortidx) ;
% create video file
outvideo = VideoWriter(videoname, 'Uncompressed AVI') ;
outvideo.FrameRate = fps;
open(outvideo);
% write cell array to video, frame by frame
for i = 1:length(sortednames)
    img = imread(sortednames{i}) ;
    writeVideo(outvideo, img) ;
end
% 
close(outvideo) ;
vid = 0 ;
end