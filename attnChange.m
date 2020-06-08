
function [hr, pr, cir, statsr] = attnChange(experiment, subTable, targetTrial, binSize, limits, cutSubs, fixed) 


    %  Author: Kat 
    %  Date Created: 
    %  Last Edit: 
     
    %  Cognitive Science Lab, Simon Fraser University 
    %  Originally Created For: feedback
      
    %  Reviewed: 
    %  Verified: 

    
    %  PURPOSE: analyse attention change in eye tracking experiments. the
    %  idea for the attention change measure comes from 
    % Leong, Y. C., Radulescu, A., Daniel, R., DeWoskin, V., & Niv, Y. (2017). Dynamic interaction between reinforcement learning and attention in multidimensional environments. Neuron, 93(2), 451-463.
    % they found that 'attention at choice' (stimulus presentation aka p2)
    % becomes more similar to 'attention at learning' (feedback phase aka
    % p4) as participants learn. here we use gaze optimization to
    % operationalize attention. we compare optimization during p2 to
    % optimization during p4. 
 
    
    %  INPUT: 
    
%         experiment: experiment name

%         subTable: binned data table (loaded from directory in master.m)

%         targetTrial: a vector of trial (CP + 11) for all subjects in the
%         current experiment. this is calculated in master.m (because it is
%         used in a number of measures, so I wanted to avoid recalculating
%         it a million times). I use CP + 11 to ensure (at least) around
%         half of the subject's CP trials are included in the learned bin.
%         CP is 24 correct trials in a row. the value listed as a subject's
%         CP is the FIRST of these 24 trials. so a subject with CP 35 (for
%         example) will have correctly categorized trials 35-58. target
%         trial for this subject would be 46.

%         binSize: varies by experiment. this value is calculated in
%         master.m and represents the number of trials in each bin.

%         limits: the upper trial in each bin (again, calculated in master.m to avoid redoing it in every script.)

%         cutSubs: subject numbers of individuals to exclude (either for bad gaze or because they are nonlearners. calculated in master.m)

%         fixed: 1 if experiment is fixed time (feedback2, feedback3), 0 if
%         self-paced (asset, sato, sshrcif)


    
    %  OUTPUT: t-test results for 1st block attention change vs CP block
    %  attention change

    
    %  Additional Scripts Used: subjTableHack and/or Gnarly (to get data)
    
    
    %  Additional Comments: this is the quarantine version aka I had to
    %  rework the parts that would normally use Gnarly. Because of this,
    %  for now ignore any lines of code that get data (aka treat them like
    %  a magic black box). when the lab is open again, I will revert these
    %  to Gnarly, and then we can verify those parts. 
    
    
    
    % get optimization p2 and p4 

    % WILL BE PUT BACK TO GNARLY ONCE WE ARE BACK IN THE LAB.
    % the output of these calls is a Yx2 matrix where the first column is
    % subject numbers and second is the data we are interested in. for CP,
    % this gives on value per subject; for optimization, it gives one value
    % per trial.
    P2 = subjTableHack(experiment, 'opt');
    P4 = subjTableHack(experiment, 'opt4');
    cps = subjTableHack(experiment, 'cp'); 
    
    
    % cut non-learners and gaze droppers 
    for i = 1:length(cutSubs)   %cutSubs is an input arg
        cutMe = cutSubs(i);
        
        % cut the same people in each vector of data
        x = cps(:, 1) == cutMe;
        cps(x, :) = [];
        
        y = P2(:, 1) == cutMe;
        P2(y, :) = [];
        
        z = P4(:, 1) == cutMe;
        P4(z, :) = [];
    end


    % subjects represents the number of subjects in the current experiment.
    subjects = cps(:, 1);
    
    % gives us the maximum possible trial in the experiment (this varies by
    % experiment)
    expMax = max(subTable.Trial);

    
    gazeChange = [];
    
    if fixed
        gazeOne = [];
        gazeNine = [];

        targetNine = [];
        targetOne = [];
    end

    for i = 1:length(subjects)

        % this gets us to the correct vector for the current subject
        current = subjects(i);
        index = P2(:, 1) == current;

        % and this gets the criterion point for the subject of interest
        cp = cps(i, 2);

        p2Subject = P2(index, 2);
        p4Subject = P4(index, 2);

        p2Subject(end+1:expMax) = NaN;
        p4Subject(end+1:expMax) = NaN;

        optDiff = abs(p2Subject - p4Subject);       
        
        
        subAccuracy = subTable.Accuracy(subTable.Subject == current);
        subAccuracy(end+1:expMax) = NaN;

        %% uncomment this next part for individual plots of attention change (eg. fig. 10 in paper). 
       
        % create a scatter plot for each subject (what we are looking for are the points at 0)
        
        % for the plot, we don't want absolute value
        rawDiff = p2Subject - p4Subject;

        c = subAccuracy;

        
        figure()
        caxis([0.2 0.8]);
        colormap jet
        
        scatter(1:length(p2Subject), rawDiff, [], c);
        ylim([-2 2])
        hold on
        y = ylim;
        plot([cp cp],[y(1) y(2)])


        fnPlot = strcat('\Users\16132\Documents\lab\KAT\', experiment, '\attnChange\', num2str(current));

        saveas(gca, char(strcat(fnPlot, '.png')));

        close all



%         % at the end of this loop, gazeChange will be a #subjects * expMax
%         % array of optChange values for each subject on each trial 
% 
%         gazeChange = [gazeChange, optDiff];
%         
%         % for fb2 and fb3, get into each condition specifically
%         if fixed
%             cond = subTable.Condition(subTable.Subject == current);
%             if cond(1) == 1000  % one sec people
%                gazeOne = [gazeOne, optDiff];
%                targetOne = [targetOne; targetTrial(i)];
%             else    % nine sec people
%                gazeNine = [gazeNine, optDiff];
%                targetNine = [targetNine; targetTrial(i)];
%             end
%         end

    end
    
    firstBin = [];
    cpBin = [];

    
    for i = 1:length(targetTrial)
        % this is the same process as in basics.m for finding each
        % subject's learned bin. this is the bin containing most of their
        % 24 in a row correct trials. we used learned bin to compare to
        % first bin to check for differences with learning.

        target = targetTrial(i);
        ind = find(limits > target);
        if isempty(ind)
            relevantBin = 15;
        else
            relevantBin = ind(1);
        end
        binEnd = limits(relevantBin);
        
        gaze = gazeChange(:, i);
        first = gaze(1:binSize);
        targ = gaze((binEnd-binSize+1):binEnd);
        
        firstBin = [firstBin; nanmean(first)];
        cpBin = [cpBin; nanmean(targ)];
        
    end
    
    % here is the t-test we return. we are doing a one-tailed paired
    % samples ttest. the null hypothesis is that attention change in the
    % learned bin is greater than or equal to attention change in the
    % first bin.
    [hr, pr, cir, statsr] = ttest(cpBin, firstBin, 'Tail', 'left');
    
    
    if fixed
    
        % one sec condition only
        firstOne = [];
        cpOne = [];

        % this is exactly the same as above, just filtered for the people in
        % the condition of interest.
        for i = 1:length(targetOne)

            target = targetOne(i);
            ind = find(limits > target);
            if isempty(ind)
                relevantBin = 15;
            else

                relevantBin = ind(1);
            end
            binEnd = limits(relevantBin);

            gaze = gazeOne(:, i);
            first = gaze(1:binSize);
            targ = gaze((binEnd-binSize+1):binEnd);

            firstOne = [firstOne; nanmean(first)];
            cpOne = [cpOne; nanmean(targ)];

        end

        % same t-test as before, just with only one sec people
        disp('one sec condition')
        [h, p, ci, stats] = ttest(cpOne, firstOne, 'Tail', 'left')

        
        % now nine sec
        firstNine = [];
        cpNine = [];

        % same as one sec.
        for i = 1:length(targetNine)

            target = targetNine(i);
            ind = find(limits > target);
            if isempty(ind)
                relevantBin = 15;
            else
                relevantBin = ind(1);
            end
            binEnd = limits(relevantBin);

            gaze = gazeNine(:, i);
            first = gaze(1:binSize);
            targ = gaze((binEnd-binSize+1):binEnd);

            firstNine = [firstNine; nanmean(first)];
            cpNine = [cpNine; nanmean(targ)];

        end

        disp('nine sec condition')
        [h, p, ci, stats] = ttest(cpNine, firstNine, 'Tail', 'left')

        %% compare across conditions. this is independent samples instead of paired samples
        disp('comparing first block')
        [h, p, ci, stats] = ttest2(firstOne, firstNine)

        disp('comparing cp block')
        [h, p, ci, stats] = ttest2(cpOne, cpNine)
    end
    

end