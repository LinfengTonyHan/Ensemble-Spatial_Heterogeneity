function [StimLevel, RespRatio] = psymetric_single2multi(Stimval, Response, ntrial)
%% [StimLevel, RespRatio] = psymetric_single2multi(Stimval, Response, ntrial)
Data = [Stimval;Response];
Data = sortrows(Data',1)';
Stimval = Data(1,:);
Response = Data(2,:);

size_vec = size(Data,2);
Level = size_vec / ntrial;
StimLevel = zeros(1,Level);
RespRatio = zeros(1,Level);
for s = 1:Level 
    StimLevel(s) = Stimval((s-1)*ntrial+1);
    RespRatio(s) = sum(Response((s*ntrial-ntrial+1):s*ntrial));
end 
    