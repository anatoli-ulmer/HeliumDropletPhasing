function obj = startRecon(obj, method, nSteps, nLoops)
    if nargin>1
        obj.reconPlan = {method,nSteps,nLoops};
    end
    planEntries=size(obj.reconPlan,1);
    fprintf('reconstructing with plan:\n')
    for i=1:planEntries
        [method,nSteps,nLoops]=obj.reconPlan{i,:};
        fprintf('\t%d loop(s) with %d step(s) ''%s''\n',...
            nLoops,nSteps,method)
    end
    for i=1:planEntries
        [method,nSteps,nLoops]=obj.reconPlan{i,:};
        for j=1:nLoops
            obj.iterate(nSteps,method);
            obj.plotAll;
        end
    end
end