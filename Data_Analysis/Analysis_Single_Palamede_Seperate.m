function [Params] = Analysis_Single_Palamede_Seperate(directory,file,position)
%% Please note that this function is using the palamede toolbox
%% The codes and comments were written by Linfeng (Tony) Han.
% Please contact Tony via email (linfenghan98@gmail.com) or Slack / WeChat for any questions
PF = @PAL_Logistic; %Fitting Approach: Logistic
searchGrid.alpha = -10:.01:10; 
%Parameter 1: Alpha. In the demo, it is searched from 0~1. However, it
%would be best to have a much larger range here.
searchGrid.beta = logspace(0,3,1000);
%Parameter 2: Beta. Provide a much larger range here too.
searchGrid.gamma = 0; 
%Paramter 3: Gamma. Generally just set it as 0.
searchGrid.lambda = 0;  
%Paramter 4: Lambda. Generally just set it as 0.
paramsFree = [1,1,0,0]; %Free parameters
%In a 2-parameter fitting, set alpha and beta free.

OutOfNum = 24*ones(1,9);
%For analyzing the 1728-trial spatial heterogeneity experiments here 
%In the following parts of this script, "for SH" means that the codes
%CANNOT be generalized to other psychometric fitting, but serve uniquely
%for the spatial heterogeneity experiments 

%% This script is to analyze with the palamedes toolbox
filedoc = [directory,'/',file]; 
load(filedoc); %Loading the target file 
ALL = sortrows(ALL',1)'; %
%ALL(2,:) = ALL(2,:) * 5 - 25;
ALL(4,:) = ALL(4,:) - 1; %for SH
Cond = 0:216:1728; %for SH
ntrial = 24; %for SH



for iteL = position %for SH %8 positions in the experiment
    figure('name','Maximum Likelihood Psychometric Function Fitting');
Loc{iteL} = (Cond(iteL)+1) : (Cond(iteL+1));
Data_Loc{iteL} = ALL(:,Loc{iteL}); %for SH
[StimLevel, RespRatio] = psymetric_single2multi(Data_Loc{iteL}(2,:),Data_Loc{iteL}(4,:),ntrial);
%above: for SH. psymetric_single2multi.m is another function written by Linfeng
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
% The 3rd input variable is the "baseline" (the number of trials in total in each condition
[paramsValues, ~, ~] = PAL_PFML_Fit(StimLevel_Loc{iteL},RespRatio_Loc{iteL}, ...
    ntrial*ones(1,9),searchGrid,paramsFree,PF);

%% Generating the output 
Params{iteL} = paramsValues;

%% Creating psychometric plots
ProportionCorrectObserved = RespRatio./OutOfNum; 
StimLevelsFineGrain = [min(StimLevel):max(StimLevel)./1000:max(StimLevel)];
ProportionCorrectModel = PF(paramsValues,StimLevelsFineGrain);
%axes;
hold on
plot(StimLevelsFineGrain,ProportionCorrectModel,'-','color',[iteL/10,iteL/10, iteL/10],'linewidth',4);
%plotting out the line
%The iteL/10 is just ensuring that each plot will have a unique color
%hold on
plot(StimLevel,ProportionCorrectObserved,'k.','markersize',40);
%plotting out the dots (response proportion)
set(gca, 'fontsize',16);
set(gca, 'Xtick', StimLevel);
axis([min(StimLevel),max(StimLevel),0,1]);
xlabel('Stimulus Intensity'); %Different levels of stimuli
ylabel('Female Proportion'); %It depends on your own response variable 
end