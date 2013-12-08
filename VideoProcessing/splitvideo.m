function nframes = splitvideo(videoname, imgformat)

if nargs < 2
   imgformat = 'tiff' ;
end
% create folder to house exported frames
outfolder = [videoname '_frames'] ;
mkdir(outfolder) ;
% read the video file
inobj = VideoReader(videoname) ;
nframes = inobj.NumberOfFrames ;
for i = 1:nframes
    % extract a frame
    img = read(inobj,i);
    % write frame to a file
    imwrite(img, [outfolder '\' videoname sprintf('_%d.',i) imgformat]) ;
end

end