Screen('Preference', 'SkipSyncTests', 0); % We skip the synctest 

close all; % Clear the workspace
clearvars;
sca;

PsychDefaultSetup(2); % Setup PTB with some default values

Screen('Preference', 'DefaultFontName','NanumGothicCoding');%Default font setting

% Seed the random number generator. Here we use the an older way to be
% compatible with older systems. Newer syntax would be rng('shuffle'). Look
% at the help function of rand "help rand" for more information
rand('seed', sum(100 * clock));

screenNumber = max(Screen('Screens'));

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;
black = BlackIndex(screenNumber);

% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 2);

% Flip to clear
Screen('Flip', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Set the text size
Screen('TextSize', window, 60);

% Query the maximum priority level
topPriorityLevel = MaxPriority(window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set the alpha blending for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% fixation cross
crossLength = 30;
crossColor = white;
crossWidth = 3;
crossLines = [-crossLength, 0; crossLength, 0; 0, -crossLength; 0, crossLength];
crossLines = crossLines';


%----------------------------------------------------------------------
%                       Timing Information
%----------------------------------------------------------------------

% Interstimulus interval time in seconds and frames
isiTimeSecs = 1;
isiTimeFrames = round(isiTimeSecs / ifi);

% Numer of frames to wait before re-drawing
waitframes = 1;


%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------

% Define the keyboard keys that are listened for. We will be using the left
% and right arrow keys as response keys for the task and the escape key as
% a exit/reset key
KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');
SpaceKey = KbName('space');
responseKeys = {'z','m'};
% Bring in stimulus
[f,msg]=fopen('fMRIstim.csv','r+','n','UTF-8');
txt=fscanf(f,'%c');
x=textscan(txt,'%[^,] %[^,] %[^,] %[^,] %[^,] %[^,] %[^,] %s','delimiter',',');
stim = [x{:}];
numTrials = 2;



%----------------------------------------------------------------------
%                     Make a response matrix
%----------------------------------------------------------------------

% The first row will record the word we present,
% the second row the color the word it written in, the third row the key
% they respond with and the final row the time they took to make there response.
respMat = nan(3, numTrials);


%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------

% Animation loop: we loop for the total number of trials

DrawFormattedText(window, double('실험이 시작됩니다. \n\n 준비가 완료되면 아무 키나 눌러주세요.'), 'center', 'center', white);
Screen('Flip', window);
KbStrokeWait;
RestrictKeysForKbCheck([]);
for trial = 1:numTrials

    % Word number
    wordNum = stim(trial+1,3:8);



    % Now we present the isi interval with fixation point minus one frame
    % because we presented the fixation point once already when getting a
    % time stamp
%     for frame = 1:isiTimeFrames - 1
%         % Draw the fixation point
%         Screen('DrawText', window, '+', xCenter, yCenter, white);
%         % Flip to the screen
%         vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
%     end

    % Now present the word in continuous loops until the person presses a
    % key to respond. We take a time stamp before and after to calculate
    % our reaction time. We could do this directly with the vbl time stamps,
    % but for the purposes of this introductory demo we will use GetSecs.
    %
    for i = 1:6
        % Draw the word
        DrawFormattedText(window, double(char(wordNum(i))), 'center', 'center', white);
        % Flip to the screen
        Screen('Flip', window);
        WaitSecs(0.5);
    end
    DrawFormattedText(window, double('Comprehension Question'), 'center', 'center', white);
    flipTime = Screen('Flip', window);
    rt = 0;
    resp = 0;
        while GetSecs - flipTime < 3
            clear keyCode;
            RestrictKeysForKbCheck([90, 77, 27]);
            [keyIsDown,secs,keyCode] = KbCheck;
            respTime = GetSecs;
            pressedKeys = find(keyCode);
            % ESC key quits the experiment
            if keyCode(KbName('ESCAPE')) == 1
                clear all
                close all
                sca
                return
            end
            % Check for response keys
            if ~isempty(pressedKeys)
                for i = 1:length(responseKeys)
                    if KbName(responseKeys{i}) == pressedKeys(1)
                        resp = responseKeys{i};
                        rt = respTime - flipTime;
                    end
                end
            end

            % Exit loop once a response is recorded
            if rt > 0
                break;
            end
        end
    WaitSecs(3);
    if respTime > 3
       DrawFormattedText(window, double('제한시간 초과'), 'center', 'center', white);
       Screen('Flip', window);
       WaitSecs(1);
    end    
    Screen('DrawLines',window, crossLines, crossWidth, crossColor, [xCenter, yCenter]);
    vbl = Screen('Flip', window);
    WaitSecs(1);

    % Record the trial data into out data matrix
    respMat(1, trial) = trial;
    respMat(2, trial) = resp;
    respMat(3, trial) = rt;
	end


RestrictKeysForKbCheck([]);

DrawFormattedText(window, double('실험이 종료되었습니다. \n\n 참여해주셔서 감사합니다.'), 'center', 'center', white);
Screen('Flip', window);
KbStrokeWait;
sca;


