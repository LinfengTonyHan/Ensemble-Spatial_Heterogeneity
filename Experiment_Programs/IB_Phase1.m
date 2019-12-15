%% IB_Phase1

%This is the script for the familiarization
%Face images are presented for 600ms and participants give their
%responses. Feedback will be given
%The number of practice trials are controlled by nprac

DrawFormattedText(window,'Press Space to Start','center','center',white);
Screen('Flip',window);
while 1
    [~,~,kM] = KbCheck();
    if kM(KbName('space'))
        break
    end
end

Screen('Flip',window);
WaitSecs(Waiting_Time);
Order_Prac = [randperm(Morph_Range),randperm(Morph_Range),randperm(Morph_Range)];

for prac = 1:nprac
    Face_Test = Order_Prac(prac);
    Screen('TextColor',window,red);
    DrawFormattedText(window,'+','center','center');
    Screen('Flip',window);
    WaitSecs(Cross_Delay);
    Screen('DrawTexture',window,stimuli_prac(Face_Test),[],RECT_CENTER);
    Screen('Flip',window);
    WaitSecs(0.6);
    Screen('TextColor',window,black);
    DrawFormattedText(window,'Male',x_center + 200, y_center + 150,white);
    DrawFormattedText(window,'Female',x_center - 250, y_center + 150,white);
    Screen('Flip',window);
    while 1
        [~,~,kC] = KbCheck();
        if kC(KbName('p'))
            % J = 1;
            break
        elseif kC(KbName('q'))
            % J = 2;
            break
        end
    end
    
    %if Face_Test == 5
    %    DrawFormattedText(window,'Neutral!','center','center')
    %    Screen('Flip',window);
    %    WaitSecs(0.6);
    if Face_Test >=  21
        DrawFormattedText(window,'Female!','center','center')
        Screen('Flip',window);
        WaitSecs(0.6);
    elseif Face_Test <= 20
        DrawFormattedText(window,'Male!','center','center')
        Screen('Flip',window);
        WaitSecs(0.6);
    end
    
    Screen('Flip',window);
    WaitSecs(Waiting_Time);
end