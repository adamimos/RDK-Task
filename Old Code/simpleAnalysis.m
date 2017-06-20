nTrials = response.nCorrect + response.nWrong;
trialType = params.trialSide(1:nTrials);
rrr = response.res(1:nTrials);

fprintf('percent correct close = %f\n',100*sum(rrr(trialType == 1)./length(rrr(trialType==1))));
fprintf('percent correct far = %f\n',100*sum(rrr(trialType == 3)./length(rrr(trialType==3))));


responseTimes = response.trialRespondTime(1:nTrials) - response.centerPokeTime(1:nTrials);
sRT = sort(responseTimes);
minRT = sRT(1);
maxRT = sRT(ceil(0.995.*length(sRT)));

subplot(1,3,1)
plot(linspace(minRT,maxRT,40),histc(responseTimes,linspace(minRT,maxRT,40)));
subplot(1,3,2)
plot(linspace(minRT,maxRT,40),histc(responseTimes(trialType == 1),linspace(minRT,maxRT,40)));
hold on
subplot(1,3,2)
plot(linspace(minRT,maxRT,40),histc(responseTimes(trialType == 3),linspace(minRT,maxRT,40)));
subplot(1,3,3)
plot(linspace(minRT,maxRT,40),histc(responseTimes(rrr == 1),linspace(minRT,maxRT,40)));
hold on
subplot(1,3,3)
plot(linspace(minRT,maxRT,40),histc(responseTimes(rrr == 0),linspace(minRT,maxRT,40)));




