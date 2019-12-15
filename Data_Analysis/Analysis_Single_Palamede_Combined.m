function [Params] = Analysis_Single_Palamede_Legend(directory,file,position)
%% Please note that this function is using the Palamedes toolbox
%% The codes and comments were written by Linfeng (Tony) Han.
% Please contact Tony via email (linfenghan98@gmail.com) or Slack / WeChat for any questions
% Please contact Tony if you need to get access to the Palamede Toolbox
% Or you can visit the website via: 
   %%%%%  http://www.palamedestoolbox.org/
% Citation of the Palamedes Toolbox
   %%%%% Prins, N & Kingdom, F. A. A. (2018) Applying the Model-Comparison Approach to Test 
   %Specific Research Hypotheses in Psychophysical Research Using the Palamedes Toolbox. 
   %Frontiers in Psychology, 9:1250. doi: 10.3389/fpsyg.2018.01250

%% Try this sentence for a demo -- type this into the command window
% Analysis_Single_Palamede_Legend('THU_Single','Result_THU_04_Round1_WJJ.mat',1:8)
% directory = 'THU_Single';
% file = 'Result_THU_04_Round1_WJJ.mat';
% position = 1:8;
%% Beginning of the function
PF = @PAL_Logistic; %Fitting Approach: Logistic
searchGrid.alpha = -10:.01:10; 
%Parameter 1: Alpha. In the demo, it is searched from 0~1. However, it
%would be best to have a much larger range here so that the function can
%deal with some extreme values.
searchGrid.beta = logspace(0,3,1000);
%Parameter 2: Beta. Provide a much larger range here too.
searchGrid.gamma = 0; 
%Paramter 3: Gamma. Generally just set it as 0.
searchGrid.lambda = 0;  
%Paramter 4: Lambda. Generally just set it as 0.
paramsFree = [1,1,0,0]; %Free parameters
%In a 2-parameter fitting, set alpha and beta free.

OutOfNum = 24*ones(1,9); 
%This is the baseline, which is a critical variable in the fitting function
%(total number, 24 trials per each condition)

%For analyzing the 1728-trial spatial heterogeneity experiments here 
%In the following parts of this script, "for SH" means that the codes
%CANNOT be generalized to other psychometric fitting, but serve uniquely
%for the spatial heterogeneity experiments 
Labels = {'1','2','3','4','5','6','7','8'};
%% This script is to analyze the psychometric data with the palamedes toolbox
filedoc = [directory,'/',file]; 
load(filedoc); %Loading the target file
ALL = sortrows(ALL',1)'; 
%ALL is the data recorded in the experiment, 1st row: locations; 2nd row: morph values; 3rd row: accuracy; 4th row: actual response
%ALL(2,:) = ALL(2,:) * 5 - 25;
ALL(4,:) = ALL(4,:) - 1; %for SH, make the actual response binary 
Cond = 0:216:1728; %for SH, for organizing the data 
ntrial = 24; %for SH

figure('name','Maximum Likelihood Psychometric Function Fitting');

for iteL = position %for SH %8 positions in the experiment, "position" should often be 1:8
    Color_Specific = [rand(1)/1.1,rand(1)/1.1,rand(1)/1.1]; %Generating a random color for each line
    Loc{iteL} = (Cond(iteL)+1) : (Cond(iteL+1));    
    Data_Loc{iteL} = ALL(:,Loc{iteL}); %for SH
    [StimLevel, RespRatio] = psymetric_single2multi(Data_Loc{iteL}(2,:),Data_Loc{iteL}(4,:),ntrial);
    %above: for SH. psymetric_single2multi.m is another function written by
    %Linfeng, which aims at organizing the data 
    StimLevel_Loc{iteL} = StimLevel; 
    %This is an important variable, refering to the stimulus level 
    %It is best that this variable is in the format of A:I:B (I use 1:1:9 in
    %the SH experiment).
    RespRatio_Loc{iteL} = RespRatio;
    %This is the other important variable, refering to the subject's response
    %This variable should strictly be constructed by 0 & 1.
    %Perform fit
    disp('Fitting function.....');
    %Just to note that this program is running...

%% This is the fitting function (PAL_PFML_Fit.m)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The 3rd input variable is the "baseline" (the number of trials in total in each condition
    [paramsValues, ~, ~] = PAL_PFML_Fit(StimLevel_Loc{iteL},RespRatio_Loc{iteL}, ...
    ntrial*ones(1,9),searchGrid,paramsFree,PF);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generating the output 
    Params{iteL} = paramsValues;

%% Creating psychometric plots
    ProportionCorrectObserved = RespRatio./OutOfNum; 
    StimLevelsFineGrain = [min(StimLevel):max(StimLevel)./1000:max(StimLevel)];
    ProportionCorrectModel = PF(paramsValues,StimLevelsFineGrain);
    hold on
    LP{iteL} = plot(StimLevelsFineGrain,ProportionCorrectModel,'-','color',Color_Specific,'linewidth',2,'DisplayName',num2str(iteL));
    %legend(AX,num2str(iteL));
%plotting out the line
%The iteL/10 is just ensuring that each plot will have a unique color
    plot(StimLevel,ProportionCorrectObserved,'k.','markersize',15,'color',Color_Specific);
%plotting out the dots (response proportion)
    set(gca, 'fontsize',16);
    set(gca, 'Xtick', StimLevel);
    axis([min(StimLevel),max(StimLevel),0,1]);
    %xticklabels({'-50','-37.5','-25','-12.5','0','12.5','25','37.5','50'});
    xlabel('Stimulus Intensity'); %Different levels of stimuli
    ylabel('Female Proportion'); %It depends on your own response variable 
end

AX = LP{8};
% legend(AX,{'0','45','90','135','180','225','270',' 315'});
legend([LP{1},LP{2},LP{3},LP{4},LP{5},LP{6},LP{7},LP{8}],{'0','45','90','135','180','225','270',' 315'});

%% Two remaining steps to do with the function
% 1. Store the parameter data of subjects into a new directory so they can be
% accessed easily.
% 2. To write a function which is the inverse function of the psychometric
% curve so that JND could be calculated.
end