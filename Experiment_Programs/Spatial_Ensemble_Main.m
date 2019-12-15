%% This is the main function for the ensemble program
clear all
close all
KbName('UnifyKeyNames');

%% This is the main function of the spatial heterogeneity program (ensemble experiments)
% FOR ANY QUESTIONS, PLEASE CONTACT TONY (LINFENG HAN), RESEARCH ASSISTANT
% IN THE WHITNEY LAB
% linfenghan98@gmail.com (email & skype)

%% Subject information
num_lines = 1;
Info = {'Number','Initials','Gender [1=Male, 2=Female, 3=Other, 4=Decline to State]','Age','Handedness [1=Right,2=Left,,3=Other]'};
dlg_title = 'Participant Information';
subject_info = inputdlg(Info,dlg_title,num_lines);
filename = ['Result_',subject_info{1},'_',subject_info{2}];

%% Initializing parameters
ntrial = 48; %Number of trials in each condition, corresponding to 1 data
%point in the psychometric curve fitting
[FemaleRect,MaleRect] = Parameters_Input(); %Calling the input function
%%%%%% Experimenters will manually input the number of faces in the
%%%%%% ensemble trials. Group 1 -- Female-biased locations; Group 2 --
%%%%%% Male-biased locations

Cross_Delay = 0.5; %Duration of Fixation Cross
Duration = 0.150; %Duration of Stimuli Display
Duration = Duration - 0.0167; %ignore this
Waiting_Time = 0.3; %blank screen duration after the display / response
black = [0,0,0]; %rgb value for black
white = [255,255,255]; %rgb value for white
red = [255,0,0]; %rgb value for red
grey = [127,127,127]; %rgb value for grey
F_Sc = []; %Full Screen
P_Sc = [0,0,900,650]; %Partial Screen
size_img_angle = 2.25; %The size of the displayed image
radius_angle = 3.35; %The spatial jitter (radius of the circle)
Morph_Range = 1;
%Range = 16:385;
%For image correction, please ignore it, for questions contact Tony
%This is no longer necessary with the new stimuli set
rest_trial = 96; %For every n trials participants will have rest
nprac = 3;
%% This is the equation for converting visual angle into actual pixel amount
% Please don't change ANYTHING in this part
% This is only applicable on Whitney Lab's computers, if monitors are
% changed, please contact Tony to change these equations
length_size_img = tan((size_img_angle/ 2) * (pi / 180)) * 57;
size_img = ((1920 / (20*2.54)) * length_size_img * 2);
length_radius = tan((radius_angle/2) * (pi / 180)) * 57;%76 pixels, corresponding to approximately 2.35º visual angle
radius = ((1920 / (20*2.54)) * length_radius * 2); %100 pixels, corresponding to approximately 3º visual angle

%% Open the window
ListenChar(-1);
Screen('Preference','SkipSyncTests',1);
[window,rect]=Screen('OpenWindow',0,grey,F_Sc); %Note that the screen is grey
% According to Dr. Arash Afraz's suggestion
% If you want to change the screen into black / white, then change "grey"
% into "black" / "white" in the line above
Screen('BlendFunction',window,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

HideCursor();
win_width = rect(3)-rect(1);
win_height = rect(4)-rect(2);
x_center = win_width/2;
y_center = win_height/2;

num_pts = 8; %8 locations in total
theta = linspace(360/num_pts, 360, num_pts); %angles equally spaced
theta = theta - 360 / num_pts;
x_circle = x_center + (cosd(theta) * radius);
y_circle = y_center + (sind(theta) * radius);

RECT = [x_circle - size_img/2; y_circle - size_img/2;  ...
    x_circle + size_img/2; y_circle + size_img/2]; %Rect for the 8 locations
RECT_CENTER = [x_center - size_img/2; y_center - size_img/2;  ...
    x_center + size_img/2; y_center + size_img/2]; %Rect for the image in the center
numF = size(FemaleRect,2);
numM = size(MaleRect,2);

%% Loading the practice stimuli
cd All_Range
R_poi = 1; %This is a pointer and will increase 1 in every loop
for img_pointer = [8:39,41:72]
    img = imread([num2str(img_pointer),'.bmp']);
    %img = img(Range,Range,:); %This is no longer necessary with the new stimuli set
    img(img == 0) = 127; %changing the background the image into grey
    %this should be kept consistent with the screen color,
    %change 127 into 0 /255 if you want to make it black / white
    stimuli_prac(R_poi) = Screen('MakeTexture',window,img);
    R_poi = R_poi + 1;
end
cd ..

%% Practice Phase
IB_Phase1;

%% Interval
DrawFormattedText(window,'Press Space to Start Testing','center','center');
Screen('Flip',window);
while 1
    [~,~,kC] = KbCheck();
    if kC(KbName('space'))
        break;
    end
end
%% Loading the stimuli
cd Selected_9
for img_ite = 1:9
    img = imread([num2str(img_ite),'.bmp']);
    %img = img(Range,Range,:); %This is no longer necessary with the new stimuli set
    img(img == 0) = 127; %Change the black part of the image into grey
    %If you want to change it to black / white background, make it 0 / 255
    stimuli(img_ite) = Screen('MakeTexture',window,img);
end

cd ..
Trial_Order = repmat([1,2],1,ntrial*9);
Mean_Order = repmat(1:9,1,ntrial*2);
ALL = [Trial_Order;Mean_Order];
ALL = ALL(:, randperm(size(ALL, 2)));
%1st row: Which Location, 1 = Female, 2 = Male
%2nd row: Which mean of morphed faces
F_RC = RECT(:,FemaleRect);
M_RC = RECT(:,MaleRect);

%% Experimental Phase
%number of trials = 2(groups of locations) * 9(morphing values) * 48
%(number of trials per each condition)
for ite = 1:2*9*ntrial
    
    if ALL(1,ite) == 1
        Mean_Morph = 100; %Selecting an impossible value to get into the while loop
        while Mean_Morph ~= ALL(2,ite)
            pic_num = randsample(1:9,numF,1); %randsample WITH REPLACEMENT
            Mean_Morph = mean(pic_num);
            Std_Morph = std(pic_num); %Here we record the variance in the picture set
        end
        
        Screen('TextColor',window,red);
        DrawFormattedText(window,'+','center','center');
        Screen('Flip',window);
        WaitSecs(Cross_Delay); %It should be 500ms
        Screen('DrawTextures',window,stimuli(pic_num),[],F_RC);
        Screen('Flip',window);
        WaitSecs(Duration);
        Screen('TextColor',window,grey);
        DrawFormattedText(window,'Male',x_center + 200, y_center + 150,white);
        DrawFormattedText(window,'Female',x_center - 250, y_center + 150,white);
        Screen('Flip',window);
        while 1
            [~,~,kC] = KbCheck();
            if kC(KbName('p'))  %right key = male response
                J = 1;
                break
            elseif kC(KbName('q')) %left key = female response
                J = 2;
                break
            end
        end
        
        ALL(3,ite) = J;
        
    elseif ALL(1,ite) == 2
        Mean_Morph = 100; %Selecting an impossible value to get into the while loop
        while Mean_Morph ~= ALL(2,ite)
            pic_num = randsample(1:9,numM,1); %randsample WITH REPLACEMENT
            Mean_Morph = mean(pic_num);
            Std_Morph = std(pic_num); %Here we record the variance in the picture set
        end
        
        Screen('TextColor',window,red);
        DrawFormattedText(window,'+','center','center');
        Screen('Flip',window);
        WaitSecs(Cross_Delay);
        Screen('DrawTextures',window,stimuli(pic_num),[],M_RC);
        Screen('Flip',window);
        WaitSecs(Duration);
        Screen('TextColor',window,grey);
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
        
        ALL(3,ite) = J;
        
    end
    
    Screen('Flip',window);
    WaitSecs(Waiting_Time);
    
    if mod(ite,rest_trial) == 0 %% For every a few trials participants will have rest
        DrawFormattedText(window,[num2str(ite),' out of ', num2str(2*9*ntrial), 'trials finished and Press SPACE to continue'],'center','center');
        Screen('Flip',window);
        while 1
            [~,~,KC] = KbCheck();
            if KC(KbName('space'))
                break
            end
        end
    end
    %% Increasing robustness!
    STD_ALL(ite) = Std_Morph;
    PIC_ALL{ite} = pic_num;
    
    cd Ensemble_Data
    save(filename); %The data is saved in every loop so that crashing is fine:)
    cd ..
end

Screen('CloseAll');
%ListenChar(1);
ShowCursor();

%[ALL,RECT] = spatial_ensemble(ntrial,FemaleRect,MaleRect); %Forget about this

cd Ensemble_Data
save(filename);
cd ..


