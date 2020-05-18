%% fix this to accommodate self=paced v fixed-time

function [first, second, third] = postError(experiment, subTable, phase, cps, fixed)

 %  Author: Kat 
    %  Date Created: 
    %  Last Edit: 
     
    %  Cognitive Science Lab, Simon Fraser University 
    %  Originally Created For: feedback
      
    %  Reviewed: 
    %  Verified: 

    
    %  PURPOSE: investigate how errors change attention. two versions of
    %  analysis here: p2 and p4. 
        % p2: compares attention on the error trial to three kinds of
        % 'next' trials: the trial immediately following, the next trial of
        % the same category, the next trial of the same stimulus
        % p4: compares attention during the feedback phase on all error
        % trials to all non-error trials
 
    
    %  INPUT: 
    
%         experiment: experiment name

%         subTable: binned data table (loaded from directory in master.m)

%         phase: phase of interest (p2 or p4)

%         cps: vector of CP for each subject in the curren experiment

%         fixed: 1 if experiment is fixed time (feedback2, feedback3), 0 if
%         self-paced (asset, sato, sshrcif)

    
    %  OUTPUT: up to three t-tests comparing error to non-error trials.

    
    %  Additional Scripts Used: 
    
    %  Additional Comments: this is the quarantine version aka I had to
    %  load .mat versions of data tables.. normally we would call
    %  from SQL directly. likely will change back to this once we can
    %  get back in the lab.
    

     % load data (normally would use SQL directly for this.)
     load(strcat('Users/16132/Documents/lab/KAT/', experiment, '/explvl.mat'));
     load(strcat('Users/16132/Documents/lab/KAT/', experiment, '/triallvl.mat'));

      
    % filter out people we are not interested in i.e. gaze droppers and
    % non-learners
    gd = explvl.GazeDropper == 1;
    nl = explvl.Learner == 0;
    cut = gd | nl;
 
    badSubs = explvl.Subject(cut);

    for i = 1:length(badSubs) % inefficient, I know -.-
         cutMe = badSubs(i);
         triallvl(triallvl.Subject == cutMe, :) = [];
    end

    
    subjects = unique(subTable.Subject);
    

    %% first, the p4 version of the analysis
    if strcmp(phase, "p4")
        
        correctirrel = [];
        errorirrel = [];
        
        if fixed
            % for fb2, fb3 we want condition-specific measures 
            correctOne = [];
            errorOne = [];

            correctNine = [];
            errorNine = [];
        else
            % for self-paced experiments, we also want feedback phase
            % duration. this is constant in fixed-time exp.s, so we don't
            % bother with it
            correctrt = [];
            errorrt = [];
        end

        for i = 1:length(subjects)
            cp = cps(i);
            
            current = subTable(subTable.Subject == subjects(i), :);
            
            % since there are very few error trials later on in the
            % experiment, we limit this analysis to early errors and early
            % correct responses. we call these learning trials as they
            % occur before CP is reached. this will hopefully limit any
            % effect of time in the experiment
            current = current(current.Trial < cp, :);
            correctTrials = current(current.Accuracy == 1, :);
            errorTrials = current(current.Accuracy == 0, :);
            
            
            % we are looking at time on irrelevant features during
            % feedback. for fb2, fb3 this is divided by condition. for
            % other experiments it is not.
            if fixed
                cond = subTable.Condition(subTable.Subject == subjects(i));
                if cond(1) == 9000
                    correctNine = [correctNine; nanmean(correctTrials.irrelp4)];
                    errorNine = [errorNine; nanmean(errorTrials.irrelp4)];
                else
                    correctOne = [correctOne; nanmean(correctTrials.irrelp4)];
                    errorOne = [errorOne; nanmean(errorTrials.irrelp4)];
                end
            else
                correctirrel = [correctirrel; nanmean(correctTrials.irrelp4)];
                errorirrel = [errorirrel; nanmean(errorTrials.irrelp4)];
            end


        end
        


        % for all exps, compare time on irrelevant features on correct and
        % error trials
        first = [];
        disp('everyone')
        [h, p, ci, stats] = ttest(correctirrel, errorirrel)
        second = [h, p];
        
        third = [];
        
        % now, by condition
        if fixed
        
            % one sec
            disp('one sec')
            [h, p, ci, stats] = ttest(correctOne, errorOne)

            % nine sec
            disp('nine sec')
            [h, p, ci, stats] = ttest(correctNine, errorNine)
        else
            % in self-paced, compare feedback phase duration on correct and error trials
            [h, p , ci, stats] = ttest(correctrt, errorrt)
            first = [h, p];
        end
        
        
    %% now p2 version of analysis    
    else        
               
        % error suffix: the error trial
        % trial suffix: following trial
        % cat suffix: next same category
        % stim suffix: next same stimulus
        
        rt2error = [];
        rt2trial = [];
        rt2cat = [];
        rt2stim = [];
        
        if fixed    % in fixed-time feedback, divide by condition
            errorNine = [];
            trialNine = [];
            catNine = [];
            stimNine = [];

            errorOne = [];
            trialOne = [];
            catOne = [];
            stimOne = [];
        else
            % for self-paced experiments, we also look at fb duration on
            % error trials
            rt4error = [];
        end
        
        
        for i = 1:length(subjects)

            % find error trials
            current = subjects(i);
            errorTrials = subTable(subTable.Subject == current & subTable.Accuracy == 0, :);
            errors = errorTrials.Trial;
            
            cond = subTable.Condition(subTable.Subject == current);
            
            % for each trial, identify the next ones. if there is NO next
            % one (of the furthest possible i.e. next same STIM), cut this
            % error trial. at the end we will have all error trials that
            % have all 3 kinds of next trial.
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
                
                if fixed
                    % for fixed-time experiments, divide by condition
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
                                    
            end
            index = errorTrials.Subject == current;

            rt2error = [rt2error; errorTrials.rt2(index)];
            
            if fixed
                if cond(1) == 9000
                    errorNine = [errorNine; errorTrials.rt2(index)];
                else
                    errorOne = [errorOne; errorTrials.rt2(index)];
                end
            else
                rt4error = [rt4error; errorTrials.rt4(index)];
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
        
        
        % for fixed time experiments, look by condition and across
        % conditions as well
        if fixed
            
            % one sec
            disp('NOW ONE SEC ONLY')
            disp('next trial following error')
            [h, p, ci, stats] = ttest(trialOne, errorOne, 'Tail', 'right')

            disp('next trial with same category')
            [h, p, ci, stats] = ttest(catOne, errorOne, 'Tail', 'right')

            disp('next trial with same stimulus')
            [h, p, ci, stats] = ttest(stimOne, errorOne, 'Tail', 'right')


            % nine sec
            disp('NOW NINE SEC ONLY')
            disp('next trial following error')
            [h, p, ci, stats] = ttest(trialNine, errorNine, 'Tail', 'right')

            disp('next trial with same category')
            [h, p, ci, stats] = ttest(catNine, errorNine, 'Tail', 'right')

            disp('next trial with same stimulus')
            [h, p, ci, stats] = ttest(stimNine, errorNine, 'Tail', 'right')


            % across conditions
            disp('COMPARING CONDITIONS')

            % to compare across conditions, we take the difference between
            % error trial values and next trial values for each error
            % trial. we then compare the distributions of these difference
            % values using independent samples t-tests.
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

end

