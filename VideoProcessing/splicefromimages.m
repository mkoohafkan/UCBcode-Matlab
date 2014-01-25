function nframes = splicefromimages(invideo, matchstring, fps, outvideo, writeprofile)
% custom function to add plots to bottom of a fog camera video
% assumes video resolution is 1280 x 720
% assumes plot resolution is 368 x 1920
% creates video that is 1920 x 1088, MPEG-4

if nargin < 2
   matchstring = '*tiff' ;   
end
if nargin < 3
    fps = 8 ;
end
if nargin < 4
    outvideo = 'outvideo.avi' ;
end
if nargin < 5
   writeprofile = 'MPEG-4' ; 
end
% get sorted list of images (from makevideo.m)
filelist = ls(matchstring) ;
imagenames = strtrim(mat2cell(filelist, ones(size(filelist, 1), 1))) ;
% sort files
imagestrings = regexp([imagenames{:}], '(\d*)', 'match') ;
imagenumbers = str2double(imagestrings) ;
[~,sortidx] = sort(imagenumbers) ;
sortednames = imagenames(sortidx) ;
% load input video
inobj = VideoReader(invideo) ;
nframes = inobj.NumberOfFrames ;
assert(nframes == length(imagenumbers)) ;
% open new video
outobj = VideoWriter(outvideo, writeprofile) ;
outobj.FrameRate = fps ;
open(outobj) ;
for i = 1:nframes
    frame = padarray(read(inobj, i), [0 320]) ;
    try
        img = imread(sortednames{i}) ;
    catch err
        pause(120) ;
        img = imread(sortednames{i}) ;
    end
    % merge the two images
    newframe = vertcat(frame, img) ;
    outobj.writeVideo(newframe) ;
end
close(outobj) ;



end