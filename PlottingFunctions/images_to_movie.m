function images_to_movie(imagepaths, outpath, imformat)
% combines a series of images into a movie
% movie will play images in order, i.e. frame 1 = imagepaths{1}
%
% images = a cell array of file paths, e.g. 'C:\images\frame1.png'
% outpath = filepath and name of movie, e.g. 'C:\images\movie'
% imformat = file format, e.g. '.eps'
% returns status = 0 (everything is fine) or 1 (there was a problem)

mov = VideoWriter(outpath, 'Motion JPEG AVI') ;
mov.FrameRate = 1 ;
% expects all files to be same extension
if strcmp(imformat, '.eps') 
    
end

open(mov)
for i = 1:length(imagepaths)
    frame = im2frame(imread(imagepaths{i}) ) ;
    writeVideo(mov, frame) ;
end
close(mov);
end