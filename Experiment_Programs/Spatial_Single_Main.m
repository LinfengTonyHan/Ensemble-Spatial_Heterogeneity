
%% This script is the main function of the pilot experiment

% Phase 1 -- Correction to 85% accuracy, the last 50 trials will be taken into account
% Phase 2 -- Testing spatial heterogeneity
% Phase 1 has unlimited trials, should be a WHILE loop
% Phase 2 will have 1728 trials

%% Cleaning variables
clear all;
close all;
clc;
KbName('UnifyKeyNames');
commandwindow;
%% Initializing the variables
%rng('shuffle'); %This doesn't work on R2010
Cross_Delay = 0.5; %Duration of Fixation Cross
Duration = 0.15; %Duration of Stimuli Display
Duration = Duration - 0.0167; %ignore this sentence please
ntrial = 24;%number of trials in each condition
ntrial = 8*9*ntrial; %converting the ntrial/condition into total number of trials
Waiting_Time = 0.3;
black = [0,0,0];
white = [255,255,255];
red = [255,0,0];
grey = [127,127,127];
F_Sc = []; %Full Screen
P_Sc = [0,0,900,650]; %Partial Screen
size_img_angle = 2.25; %The size of the displayed image
radius_angle = 3.35; %The spatial jitter (radius of the circle)
nprac = 3; %Number of practice blocks in familiarization phase
Morph_Range = 64;
nprac = nprac * Morph_Range;
%Range = 16:385; %Ignore this line -- the images have black surrounding pixels, I am cutting them off
%% This is the equation for converting visual angle into actual pixel amount
% Please don't change ANYTHING in this part
% This is only applicable on Whitney Lab's computers, if monitors are
% changed, please contact Tony to change these equations
length_size_img = tan((size_img_angle/ 2) * (pi / 180)) * 57;
size_img = ((1920 / (20*2.54)) * length_size_img * 2);
length_radius = tan((radius_angle/2) * (pi / 180)) * 57;
radius = ((1920 / (20*2.54)) * length_radius * 2);

%% Subject information
Info = {'Number','Initials','Gender [1=Male, 2=Female, 3=Other, 4=Decline to State]','Age','Handedness [1=Right,2=Left,,3=Other]'};
dlg_title = 'Participant Information';
num_lines = 1;
subject_info = inputdlg(Info,dlg_title,num_lines);
filename = ['Result_',subject_info{1},'_',subject_info{2}];
%% Open the window
%ListenChar(-1); %This doens't work on R2010
Screen('Preference','SkipSyncTests',1);
[window,rect]=Screen('OpenWindow',0,grey,F_Sc); %opening a grey screen, change "grey" into "black" or "white" if you need to
Screen('BlendFunction',window,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

HideCursor();
win_width = rect(3)-rect(1);
win_height = rect(4)-rect(2);
x_center = win_width/2;
y_center = win_height/2;

num_pts = 8;
theta = linspace(360/num_pts, 360, num_pts); %angles equally spaced
theta = theta - 360 / num_pts;
x_circle = x_center + (cosd(theta) * radius);
y_circle = y_center + (sind(theta) * radius);

RECT = [x_circle - size_img/2; y_circle - size_img/2;  ...
    x_circle + size_img/2; y_circle + size_img/2];
RECT_CENTER = [x_center - size_img/2; y_center - size_img/2;  ...
    x_center + size_img/2; y_center + size_img/2];
%% Loading the images
cd Selected_9
for img_ite = 1:9
    img = imread([num2str(img_ite),'.bmp']);
    %img = img(Range,Range,:); No longer necessary with the new stimulus set
    img(img == 0) = 127; %changing the background the image into grey
    %this should be kept consistent with the screen color,
    %change 127 into 0 /255 if you want to make it black / white
    stimuli(img_ite) = Screen('MakeTexture',window,img);
end

cd ..

cd All_Range
R_poi = 1; %This is a pointer and will increase 1 in every loop
for img_pointer = [8:39,41:72]
    img = imread([num2str(img_pointer),'.bmp']);
    %img = img(Range,Range,:); No longer necessary with the new stimulus set
    img(img == 0) = 127; %changing the background the image into grey
    %this should be kept consistent with the screen color,
    %change 127 into 0 /255 if you want to make it black / white
    stimuli_prac(R_poi) = Screen('MakeTexture',window,img);
    R_poi = R_poi + 1;
end

cd ..
%% Phase 1: Familiarization phase
IB_Phase1;
% This is the familiarization phase, it is not the
% same as Arash's experiment now (because we are now running RAs who are
% familiar with the set), but it will be replicating Arash's procedure when
% running RPP students
%% Interval
DrawFormattedText(window,'Press Space to Start Testing','center','center');
Screen('Flip',window);
while 1
    [~,~,kC] = KbCheck();
    if kC(KbName('space'))
        break;
    end
end

%% Phase 2: Testing
LOC = repmat(1:8, 1, ntrial / 8);
MOR = repmat(1:9, 1, ntrial / 9);
ALL = [LOC;MOR];
ALL = ALL(:, randperm(size(ALL, 2)));

for ite = 1:ntrial
    
    recta = RECT(:,ALL(1,ite));
    stimulus = stimuli(ALL(2,ite));
    Screen('TextColor',window,red);
    DrawFormattedText(window,'+','center','center');
    Screen('Flip',window);
    WaitSecs(Cross_Delay);
    Screen('DrawTexture',window,stimulus,[],recta);
    Screen('Flip',window);
    WaitSecs(Duration);
    Screen('TextColor',window,black);
    DrawFormattedText(window,'Male',x_center + 200, y_center + 150,white);
    DrawFormattedText(window,'Female',x_center - 250, y_center + 150,white);
    Screen('Flip',window);
    while 1
        [~,~,kC] = KbCheck();
        if kC(KbName('p'))
            J = 1;
            break
        elseif kC(KbName('q'))
            J = 2;
            break
        end
    end
    
    ALL(4,ite) = J;
    if ALL(2,ite) == 5
        
    elseif ALL(2,ite) >=  6
        ALL(3,ite) = J - 1;
    elseif ALL(2,ite) <= 4
        ALL(3,ite) = mod(J,2);
    end
    
    Screen('Flip',window);
    WaitSecs(Waiting_Time);
    cd DATA
    save(filename);
    cd ..
    
    if mod(ite,96) == 0
        DrawFormattedText(window,[num2str(ite),' out of 1728 trials finished and Press SPACE to continue'],'center','center');
        Screen('Flip',window);
        while 1
            [~,~,KC] = KbCheck();
            if KC(KbName('space'))
                break
            end
        end
    end
end

sca;
%ListenChar(1);
