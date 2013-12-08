function nframes = extractframeset(videoname, startframe, endframe, framestep, imgformat)

% modification of splitvideo.m
% extracts the specified range of frames as [statframe:framestep:endframe]
if nargs < 2
    startframe = 1 ;
end
if nargs < 4
    framestep = 1 ;
end
if nargs < 5
    imgformat = 'tiff' ;
end
% prep output folder
outfolder = [videoname '_frames'] ;
mkdir(outfolder) ;
% read the video file
inobj = VideoReader(videoname) ;
nframes = inobj.NumberOfFrames ;
if nargs < 3
    endframe = nframes ;
end
% write frames to files
for i = startframe:framestep:endframe
    % extract a frame
    img = read(inobj,i);
    % write frame to a file
    imwrite(img, [outfolder '\' videoname sprintf('_%d.', i) imgformat]) ;
end

end