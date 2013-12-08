function nframes = get_timestamps(videoname)


% timestamp is 705px to 720px, across width of frame

% create folder to house exported frames
outfolder = [videoname '_timestamps'] ;
mkdir(outfolder) ;
% read the video file
inobj = VideoReader(videoname) ;
nframes = inobj.NumberOfFrames ;
for i = 1:nframes
    % extract a frame
    img = read(inobj, i);
    % write frame to a file
    imwrite(img(705:720, :, :), [outfolder '\' videoname '_timestamps' sprintf('_%d.',i) imgformat]) ;
end


end