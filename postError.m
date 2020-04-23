                
function [first, second, third] = postError(experiment, subTable, phase, cps)

%     % load data
      load(strcat('Users/16132/Documents/lab/KAT/', experiment, '/explvl.mat'));
      load(strcat('Users/16132/Documents/lab/KAT/', experiment, '/triallvl.mat'));

      
    % filter out people we are not interested in i.e. gaze droppers and
    % non-learners
    gd = explvl.GazeDropper == 1;
    nl = explvl.Learner == 0;
    cut = gd | nl;
 
    badSubs = explvl.Subject(cut);

    for i = 1:length(badSubs) % rip this has gotta be inefficient, oh well...
         cutMe = badSubs(i);
         triallvl(triallvl.Subject == cutMe, :) = [];
    end

    
    subjects = unique(subTable.Subject);

    if strcmp(phase, "p4")
        
        %% these two measures get uncommented for self-paced exps.
%         correctrt = [];
%         errorrt = [];
        
        correctirrel = [];
        errorirrel = [];
        
        % comment the rest of these initialized variables out for
        % self-paced.
        correctOne = [];
        errorOne = [];
        
        correctNine = [];
        errorNine = [];
        
        for i = 1:length(subjects)
            cp = cps(i);
            
            current = subTable(subTable.Subject == subjects(i), :);
            
            % only learning trials pls
            current = current(current.Trial < cp, :);
            correctTrials = current(current.Accuracy == 1, :);
            errorTrials = current(current.Accuracy == 0, :);
            
            %% same as above, reintroduce for self-paced
%             correctrt = [correctrt; nanmean(correctTrials.rt4)];
%             errorrt = [errorrt; nanmean(errorTrials.rt4)];
            
            correctirrel = [correctirrel; nanmean(correctTrials.irrelp4)];
            errorirrel = [errorirrel; nanmean(errorTrials.irrelp4)];
            
            % comment out this next line and the entire if/else for
            % self-paced.
            cond = subTable.Condition(subTable.Subject == subjects(i));
            if cond(1) == 9000
                correctNine = [correctNine; nanmean(correctTrials.irrelp4)];
                errorNine = [errorNine; nanmean(errorTrials.irrelp4)];
            else
                correctOne = [correctOne; nanmean(correctTrials.irrelp4)];
                errorOne = [errorOne; nanmean(errorTrials.irrelp4)];
            end
        end
        
        %% reintroduced in self-paced
%         [h, p , ci, stats] = ttest(correctrt, errorrt)
%         first = [h, p];

        first = [];
        disp('everyone')
        [h, p, ci, stats] = ttest(correctirrel, errorirrel)
        second = [h, p];
        
        third = [];
        
        %% now by condition... comment these two tests out for self paced)
        
        % one sec
        disp('one sec')
        [h, p, ci, stats] = ttest(correctOne, errorOne)
        
        % nine sec
        disp('nine sec')
        [h, p, ci, stats] = ttest(correctNine, errorNine)
        
        
        
    else        % now p2 things 
                
        rt2error = [];
        rt2trial = [];
        rt2cat = [];
        rt2stim = [];
        
        % comment these next two chunks out for self paced
        errorNine = [];
        trialNine = [];
        catNine = [];
        stimNine = [];
        
        errorOne = [];
        trialOne = [];
        catOne = [];
        stimOne = []; 
                
        %rt4error = [];     % include this line in self-paced
        
        for i = 1:length(subjects)

            % find error trials
            current = subjects(i);
            errorTrials = subTable(subTable.Subject == current & subTable.Accuracy == 0, :);
            errors = errorTrials.Trial;
            
            cond = subTable.Condition(subTable.Subject == current);
            
            % for each trial, identify the next ones. if there is NO next
            % one (of the furthest possible i.w next same STIM), cut this
            % error trial. 
            for j = 1:length(errors)
                currentTrial = errors(j);

                %% first, next trial same stimulus.
                f1 = triallvl.Feature1Value(triallvl.Subject == current & triallvl.TrialID == currentTrial);             
                f2 = triallvl.Feature2Value(triallvl.Subject == current & triallvl.TrialID == currentTrial);
                f3 = triallvl.Feature3Value(triallvl.Subject == current & triallvl.TrialID == currentTrial);
                
                % this is all future trials with the same stimulus.
                sameStim = triallvl(triallvl.Subject == current & triallvl.TrialID > currentTrial & triallvl.Feature1Value == f1 & triallvl.Feature2Value == f2 & triallvl.Feature3Value == f3, :);
                
                if isempty(sameStim)        % no next trial, so cut this error trial.
                    errorTrials(errorTrials.Trial == currentTrial, :) = [];
                    continue
                end
                
                % otherwise, go ahead and add this error trial to the mix.
                nextSameStim = sameStim.Phase2RT(1);
                rt2stim = [rt2stim; nextSameStim];
                
                
                %% now, do next trial same category.
                category = triallvl.CorrectResponse(triallvl.Subject == current & triallvl.TrialID == currentTrial);
                
                % this is all future trials with the same category
                sameCategory = triallvl(triallvl.Subject == current & triallvl.TrialID > currentTrial & strcmp(triallvl.CorrectResponse, category), :);
                
                nextSameCat = sameCategory.Phase2RT(1);
                rt2cat = [rt2cat; nextSameCat];
                
                   
                %% finally, next trial
                nextTrial = subTable.rt2(subTable.Subject == current & subTable.Trial == currentTrial + 1);
                rt2trial = [rt2trial; nextTrial];
                
                % remove this if/else in self-paced
                if cond(1) == 9000
                    trialNine = [trialNine; nextTrial];
                    catNine = [catNine; nextSameCat];
                    stimNine = [stimNine; nextSameStim];
                else
                    trialOne = [trialOne; nextTrial];
                    catOne = [catOne; nextSameCat];
                    stimOne = [stimOne; nextSameStim];
                end
                                    
            end
            index = errorTrials.Subject == current;
            
            %% add rt4 back in for self-paced
            %rt4error = [rt4error; errorTrials.rt4(index)];
            rt2error = [rt2error; errorTrials.rt2(index)];
            
            % comment this if/else for self-paced
            if cond(1) == 9000
                errorNine = [errorNine; errorTrials.rt2(index)];
            else
                errorOne = [errorOne; errorTrials.rt2(index)];
            end

        end
    
        % paired sample t-tests:
        disp('next trial following error')
        [h, p, ci, stats] = ttest(rt2trial, rt2error, 'Tail', 'right')
        first = [h, p];
        
        disp('next trial with same category')
        [h, p, ci, stats] = ttest(rt2cat, rt2error, 'Tail', 'right')
        second = [h, p];
        
        disp('next trial with same stimulus')
        [h, p, ci, stats] = ttest(rt2stim, rt2error, 'Tail', 'right')
        third = [h, p];
        
        
        % for fb2, fb3 (comment for self-paced)
        disp('NOW ONE SEC ONLY')
        disp('next trial following error')
        [h, p, ci, stats] = ttest(trialOne, errorOne, 'Tail', 'right')
        
        disp('next trial with same category')
        [h, p, ci, stats] = ttest(catOne, errorOne, 'Tail', 'right')
        
        disp('next trial with same stimulus')
        [h, p, ci, stats] = ttest(stimOne, errorOne, 'Tail', 'right')
        
        
        
        disp('NOW NINE SEC ONLY')
        disp('next trial following error')
        [h, p, ci, stats] = ttest(trialNine, errorNine, 'Tail', 'right')
        
        disp('next trial with same category')
        [h, p, ci, stats] = ttest(catNine, errorNine, 'Tail', 'right')
        
        disp('next trial with same stimulus')
        [h, p, ci, stats] = ttest(stimNine, errorNine, 'Tail', 'right')
        
        
        disp('COMPARING CONDITIONS')
        
        trialDiffOne = trialOne - errorOne;
        trialDiffNine = trialNine - errorNine;
        disp('next trial following error')
        [h, p, ci, stats] = ttest2(trialDiffOne, trialDiffNine)
        
        catDiffOne = catOne - errorOne;
        catDiffNine = catNine - errorNine;
        disp('next trial with same category')
        [h, p, ci, stats] = ttest2(catDiffOne, catDiffNine)
        
        stimDiffOne = stimOne - errorOne;
        stimDiffNine = stimNine - errorNine;
        disp('next trial with same stimulus')
        [h, p, ci, stats] = ttest2(stimDiffOne, stimDiffNine)
                   
    end

end

