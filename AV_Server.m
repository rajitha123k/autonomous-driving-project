close all
clc
clear

%Steer = imread('Steering1.jpg');
% read the input video file
videoReader = VideoReader('Clockwise.mp4');
writerObj = VideoWriter('sign_lane_hmi_combined.avi');
writerObj.FrameRate = 10;
videoPlayer = vision.VideoPlayer;
% initiate TCP/IP connection
t = tcpip('0.0.0.0', 30000, 'NetworkRole', 'server');
fopen(t);

SchoolCount = 0;
SchoolFlag = 0;
StopCount = 0;
StopFlag = 0;
ShoolorStop = 0;	
StopBox=0;
SchoolBox=0;
Speed = 10;

% append relevant text and image in to video
text_str = cell(3,1);
%conf_val = [85.212 98.76 78.342]; 
%for ii=1:3
%   text_str{ii} = ['Confidence: ' num2str(conf_val(ii),'%0.2f') '%'];
%end

text_str{1} = ['Odometer: ' num2str(8240) ' mi'];

text_stop = 'STOP';
text_school1 = 'School A Head';
%text_school2 = '       Go Slow   ';
text_school2 = 'Go Slow';

position = [50 957;50 857;1600 957]; 
position_school1 = [700 557];
position_school2 = [800 683];
position_stop = [850 683];
position_PRND = [1840 955 40 78];
box_color = {'cyan','green','cyan'};

Framepos = 0;
open(writerObj);
% Display the final appended video
while hasFrame(videoReader)

%while Framepos > 326
    
Framepos = Framepos + 1 
  
  %frame=read(videoReader,Framepos);
frame = readFrame(videoReader);

   %[lane_Leftposition,lane_Rightposition,lane_position] = lanerecognitionsub( frame );
img1 =  frame; 
shape = size(img1);
gray_pic = rgb2gray(img1);
sig = 1;
gaussF = fspecial('gaussian',[5,5],sig);
gray_pic_g = imfilter(gray_pic,gaussF,'replicate');
edge_pic = edge(gray_pic_g,'canny',[0.055,0.126]);

%specify row coordinates of polygon
a=[shape(2)*0.3, shape(2)*0.7, shape(2)*0.9, shape(2)*0];
%specify column coordinates of polygon
b=[shape(1)*0.54, shape(1)*0.54, shape(1),shape(1)];
bw=roipoly(img1,a,b);
BW=(edge_pic(:,:,1)&bw);

[H,T,R] = hough(BW);
P=houghpeaks(H,3);
lines = houghlines(BW,T,R,P,'FillGap',10,'MinLength',5);

anglethres=0.01; %separate left/right by orientation threshold
leftlines=[]; rightlines=[]; %Two group of lines
draw_y=[shape(1)*0.6,shape(1)];
for k = 1:length(lines)
    x1=lines(k).point1(1);
    y1=lines(k).point1(2);
    x2=lines(k).point2(1);
    y2=lines(k).point2(2);
    if (x2>=shape(2)/2) && ((y2-y1)/(x2-x1)>anglethres)
        rightlines=[rightlines;x1,y1;x2,y2];
        PR=polyfit(rightlines(:,2),rightlines(:,1),1);
        draw_rx=polyval(PR,draw_y);
    elseif (x2<=shape(2)/2) && ((y2-y1)/(x2-x1)<(-1*anglethres))
        leftlines=[leftlines;x1,y1;x2,y2];
        PL=polyfit(leftlines(:,2),leftlines(:,1),1);
        draw_lx=polyval(PL,draw_y);
    end
end
Leftposition = [draw_lx(1,1) draw_y(1,1) draw_lx(1,2) draw_y(1,2)]; 
Rightposition = [draw_rx(1,1) draw_y(1,1) draw_rx(1,2) draw_y(1,2)]; 
lane_Leftposition = Leftposition;
lane_Rightposition = Rightposition;

   
   % this will show left lane line
   RGB = insertShape(frame,'line',lane_Leftposition,'LineWidth',20, 'Color','white');
   % this will show right lane line
   RGB = insertShape(RGB,'line',lane_Rightposition,'LineWidth',20, 'Color','white');
   % this will show filled rectangle or trapezoidal
   %laneimg = insertShape(laneimg,'FilledPolygon',position,'LineWidth',10, 'Color','Yellow');
   
   [phi, Dir] = controller(lane_Leftposition,lane_Rightposition);
   
   text_steer = [num2str(abs(phi)) ' deg'];
   % steering
    RGB = insertShape(RGB,'circle',[917 957 70],'LineWidth',15, 'Color','Yellow');
    RGB = insertShape(RGB,'line',[847 957 987 957],'LineWidth',10, 'Color','Yellow');
    RGB = insertShape(RGB,'line',[917 957 917 1027],'LineWidth',10, 'Color','Yellow');
    
    if Dir == 2
    RGB = insertShape(RGB,'line',[847 850 987 850],'LineWidth',10, 'Color','Yellow');
    RGB = insertShape(RGB,'FilledPolygon',[847 820 847 880 824 850],'LineWidth',15,'Color','Yellow' );
    RGB = insertText(RGB,[660 900],text_steer,'FontSize',40,'BoxColor',...
    'yellow','BoxOpacity',0.4,'TextColor','white'); 
    end
    if Dir == 1
    RGB = insertShape(RGB,'line',[847 850 987 850],'LineWidth',10, 'Color','Yellow');
    RGB = insertShape(RGB,'FilledPolygon',[987 820 987 880 1010 850],'LineWidth',15,'Color','Yellow' );
    RGB = insertText(RGB,[1030 900],text_steer,'FontSize',40,'BoxColor',...
    'yellow','BoxOpacity',0.4,'TextColor','white'); 
    end
    if Dir == 0
     % dont show anything
    end
   
  if (Framepos >= 328 && Framepos <= 357) && (ShoolorStop ~= 2)
   fwrite(t, num2str(Framepos));
   while t.BytesAvailable == 0
      pause(1)
   end
   dat = fread(t, t.BytesAvailable,'double');
   ShoolorStop = dat(1);
   bbox=dat(2:5);
   bbox=bbox.';
   end
   
   if (Framepos >= 1023 && Framepos <= 1052) && (ShoolorStop ~= 2)
   fwrite(t, num2str(Framepos));
   while t.BytesAvailable == 0
      pause(1)
   end
   dat = fread(t, t.BytesAvailable,'double');
   ShoolorStop = dat(1);
   bbox=dat(2:5);
   bbox=bbox.';
   end
   
   if (Framepos >= 1 && Framepos <= 20) && (ShoolorStop ~= 1)
   fwrite(t, num2str(Framepos));
   while t.BytesAvailable == 0
      pause(1)
   end
   dat = fread(t, t.BytesAvailable,'double');
   ShoolorStop = dat(1);
   bbox=dat(2:5);
   bbox=bbox.';
   end
   
   if (Framepos >= 700 && Framepos <= 729) && (ShoolorStop ~= 1)
   fwrite(t, num2str(Framepos));
   while t.BytesAvailable == 0
      pause(1)
   end
   dat = fread(t, t.BytesAvailable,'double');
   ShoolorStop = dat(1);
   bbox=dat(2:5);
   bbox=bbox.';
   end
   
   if (Framepos >= 1355 && Framepos <= 1369) && (ShoolorStop ~= 1)
   fwrite(t, num2str(Framepos));
   while t.BytesAvailable == 0
      pause(1)
   end
   dat = fread(t, t.BytesAvailable,'double');
   ShoolorStop = dat(1);
   bbox=dat(2:5);
   bbox=bbox.';
   end
   
   %if Framepos >= 290 && Framepos <= 390
   %if Framepos >= 1000 && Framepos <= 1100
   
   if ShoolorStop == 2 || SchoolFlag == 1
       SchoolFlag = 1;
       annotation = sprintf('%s:', "school");
       if SchoolBox~=0
       RGB = insertObjectAnnotation(RGB, 'rectangle', bbox, annotation);
       end
       if SchoolBox>=1
           SchoolBox=0;
       end
       RGB = insertText(RGB,position_school1,text_school1,'FontSize',70,'BoxColor',...
    'red','BoxOpacity',0.6,'TextColor','white'); 
       RGB = insertText(RGB,position_school2,text_school2,'FontSize',70,'BoxColor',...
    'red','BoxOpacity',0.6,'TextColor','white');
    if SchoolCount >= 30
        SchoolFlag = 0;
        SchoolCount = 0;
        ShoolorStop = 0;
    end
    SchoolCount = SchoolCount + 1;
    SchoolBox=SchoolBox + 1;
   end
   
  % if Framepos >= 680 && Framepos <= 760 
  % if Framepos >= 1340 && Framepos <= 1410
  if ShoolorStop == 1 || StopFlag == 1
      StopFlag = 1;
       annotation = sprintf('%s:', "stop");
        if StopBox~=0
       RGB = insertObjectAnnotation(RGB, 'rectangle', bbox, annotation);
       end
       if StopBox>=1
           StopBox=0;
       end
       RGB = insertText(RGB,position_stop,text_stop,'FontSize',70,'BoxColor',...
    'red','BoxOpacity',0.6,'TextColor','white'); 
    if StopCount >= 30
        StopFlag = 0;
        StopCount = 0;
        ShoolorStop = 0;
    end
    StopCount = StopCount + 1;
    StopBox=StopBox+1;
  end
  
   
   % making the speed and PRND dynamic update 
  
   if (Framepos >= 1) && (Framepos <= 20) 
        Speed = 0;
        position_PRND = [1720 955 40 78];
   elseif (Framepos >= 329) && (Framepos <= 400) 
       Speed = 5;
       position_PRND = [1840 955 40 78];
   elseif (Framepos >= 734) && (Framepos <= 753) 
       Speed = 0;
       position_PRND = [1720 955 40 78];
   elseif (Framepos >= 1050) && (Framepos <= 1089) 
       Speed = 5;
       position_PRND = [1840 955 40 78];
   elseif (Framepos >= 1405)
       Speed = 0;
       position_PRND = [1720 955 40 78];
   else
       Speed = 10;
       position_PRND = [1840 955 40 78];
   end
   
   
  
   text_str{2} = ['Speed: ' num2str(Speed) ' mph'];
   text_str{3} = ['Gear: ' 'P R N D'];
   
 
   %RGB = insertShape(frame,'FilledRectangle',[1720 955 40 78],'LineWidth',10, 'Opacity',1,'Color','red');
   RGB = insertShape(RGB,'FilledRectangle',position_PRND,'LineWidth',10, 'Opacity',1,'Color','red');
   RGB = insertText(RGB,position,text_str,'FontSize',40,'BoxColor',...
    box_color,'BoxOpacity',0.6,'TextColor','white'); 
  
   
   %RGB = insertShape(RGB,'rectangle', [100 200]);
   %out = imtile({RGB, Steer} , 'GridSize', [2 NaN]);
   %imshow(out);
   
   %{
   RGB = insertText(RGB,[50 50],num2str(Framepos),'FontSize',70,'BoxColor',...
    'red','BoxOpacity',0.6,'TextColor','white'); 
    left = ['Leftlane: ' num2str(lane_Leftposition)];
    right = ['rightlane: ' num2str(lane_Rightposition)];
    RGB = insertText(RGB,[50 250],left,'FontSize',30,'BoxColor',...
    'red','BoxOpacity',0.6,'TextColor','white'); 
    RGB = insertText(RGB,[50 450],right,'FontSize',30,'BoxColor',...
    'red','BoxOpacity',0.6,'TextColor','white'); 
   %}
   writeVideo(writerObj, RGB);
   
   %step(videoPlayer,RGB);
end
%close(videoReader);
close(writerObj);
fclose(t);
delete(t); 
clear t; 