%close all
%clc
%clear
load('rcnn.mat')
cam=VideoReader('Clockwise.mp4');
%while hasFrame(cam)
%videoFrame = readFrame(cam);
t = tcpip('localhost', 30000, 'NetworkRole', 'client');
fopen(t);
flag = 1;

while flag == 1
while t.BytesAvailable == 0
      pause(1)
end
dat = fread(t, t.BytesAvailable);
data="";
for i=1:length(dat)
    data=strcat(data,char(dat(i)));
end
    frameNumber=str2num(data)
videoFrame=read(cam,frameNumber);
%imtool(videoFrame);
[bboxes,score,label] = detect(rcnn,videoFrame,'MiniBatchSize',128);
[score, idx] = max(score);

bbox = bboxes(idx, :);
annotation = sprintf('%s: (Confidence = %f)', label(idx), score);

outputImage = insertObjectAnnotation(videoFrame, 'rectangle', bbox, annotation);

if(score >= 0.9)
    if(label(idx)=='school')
        box(1)=2;
        box(2:5)=bbox;
        fwrite(t,box,'double');
    elseif(label(idx)=='stop')
            box(1)=1;
        box(2:5)=bbox;
        fwrite(t,box,'double');
    end
 else
         box(1)=0;
        box(2:5)=[0 0 0 0];
        fwrite(t,box,'double');
 end
%imtool(outputImage)
box
end

%fclose(t);
%delete(t); 
%clear t ;
%end