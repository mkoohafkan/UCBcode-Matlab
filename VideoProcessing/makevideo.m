function err = makevideo(videoname, profile, framerate, matchstring)
% function to create a video from a collection of images. Assumes the
% images are named with a numeric sequence.
%
% INPUT ARGUMENTS
% videoname = the filename or path of the output video.
% profile = the profile used by VideoWriter.
% framerate = the framerate of the output video. Default is 2.
% matchstring = the regular expression used to obtain the list of files,
%               e.g. "/mydir/*.tiff".
%
% OUTPUT
% A video of the sequence of images.
%
%
% get videoname
if nargin < 1
    disp('Error: no output specified.')
    err = -1 ;
    return
end
% get profile
if nargin < 2
    disp('Error: no profile specified for output.')
    err = VideoWriter.getProfiles ;
    disp(err)
    return
end
% get framerate
if nargin < 3
    disp('framerate not specified. Assuming 2 frames per second.')
    framerate = 2 ;
elseif isdeployed
    framerate = str2double(framerate) ;
elseif framerate <= 0
    disp('Error: framerate must be a nonzero positive number.')
    err = -1 ;
    return
end
% get matchstring
if nargin < 4
    disp(['Warning: no regular expression provided. ' ...
          'Searching for all tiff files in current folder.'])
    matchstring = '*tiff' ;
end
% get list of files with specified extension
filelist = ls(matchstring) ;
imagenames = strtrim(mat2cell(filelist, ones(size(filelist, 1), 1))) ;
if size(imagenames, 1) < 1
    disp('Error: regular expression did not return any files.')
    err = -1 ;
    return
end
% sort files
imagestrings = regexp([imagenames{:}], '(\d*)', 'match') ;
imagenumbers = str2double(imagestrings) ;
if any(isnan(imagenumbers))
    disp('Error: input images must be named with sequential numbers.')
    err = -1 ;
    return
end
[~,sortidx] = sort(imagenumbers) ;
sortednames = imagenames(sortidx) ;
% create output video file
try
    outvideo = VideoWriter(videoname, profile) ;
    outvideo.FrameRate = framerate ;
catch err
    disp('Error: there was a problem creating the output file.')
    rethrow(err)
end
open(outvideo);
% write read image and write frame to video
try
    for i = 1:length(sortednames)
        img = imread(sortednames{i}) ;
        writeVideo(outvideo, img) ;
    end
catch err
    disp(['Error: There was a problem writing ' sortednames{i} '.'])
    close(outvideo)
    rethrow(err)
end 
disp('Video written successfully.')
close(outvideo) ;
err = 0 ;
%
end