function nframes = clipvideo(videoname, nleading, ntrailing)
% clips a video by dropping the first nleading frames and last ntrailing
% frames of a video

invideo = VideoReader(videoname) ;
nframes = invideo.NumberOfFrames ;
startframe = nleading + 1 ;
endframe = nframes - ntrailing ;

outvideo = VideoWriter([videoname '_clip.avi']) ;
outvideo.FrameRate = invideo.FrameRate ;
open(outvideo) ;
for i = startframe:endframe
        writeVideo(outvideo, read(invideo, i)) ;
end
close(outvideo)

end