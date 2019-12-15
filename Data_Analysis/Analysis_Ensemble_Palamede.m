function [Params] = Analysis_Ensemble_Palamede(directory,file,position)
%% Please note that this function is using the palamede toolbox
ntrial = 48;
PF = @PAL_Logistic;
searchGrid.alpha = -10:.01:10;
searchGrid.beta = logspace(0,3,1000);
searchGrid.gamma = 0;  %scalar here (since fixed) but may be vector
searchGrid.lambda = 0;  %ditto
paramsFree = [1,1,0,0];
OutOfNum = ntrial*ones(1,9);
%% This script is to analyze with the palamedes toolbox
filedoc = [directory,'/',file];
load(filedoc);
ALL = sortrows(ALL',1)';
%ALL(2,:) = ALL(2,:) * 5 - 25;
ALL(3,:) = ALL(3,:) - 1;
Cond = 0:432:864;

for iteL = position
Loc{iteL} = (Cond(iteL)+1) : (Cond(iteL+1));
Data_Loc{iteL} = ALL(:,Loc{iteL});
[StimLevel, RespRatio] = psymetric_single2multi(Data_Loc{iteL}(2,:),Data_Loc{iteL}(3,:),ntrial);
StimLevel_Loc{iteL} = StimLevel;
RespRatio_Loc{iteL} = RespRatio;
%Perform fit
disp('Fitting function.....');
[paramsValues, ~, ~] = PAL_PFML_Fit(StimLevel_Loc{iteL},RespRatio_Loc{iteL}, ...
    ntrial * ones(1,9),searchGrid,paramsFree,PF);
Params{iteL} = paramsValues;

%% Create simple plots
ProportionCorrectObserved = RespRatio./OutOfNum; 
StimLevelsFineGrain=[min(StimLevel):max(StimLevel)./1000:max(StimLevel)];

ProportionCorrectModel = PF(paramsValues,StimLevelsFineGrain);
figure('name','Maximum Likelihood Psychometric Function Fitting');
axes
hold on
plot(StimLevelsFineGrain,ProportionCorrectModel,'-','color',[iteL/10,iteL/10, iteL/10],'linewidth',4);
plot(StimLevel,ProportionCorrectObserved,'k.','markersize',40);
set(gca, 'fontsize',16);
set(gca, 'Xtick', StimLevel);
axis([min(StimLevel),max(StimLevel),0,1]);
xlabel('Stimulus Intensity');
ylabel('Female Proportion');
end