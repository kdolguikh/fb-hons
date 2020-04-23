
    
function [hr, pr, cir, statsr] = attnChange(experiment, subTable, targetTrial, binSize, limits, cutSubs) 

    % get optimization p2 and p4 

    P2 = subjTableHack(experiment, 'opt');
    P4 = subjTableHack(experiment, 'opt4');
    cps = subjTableHack(experiment, 'cp'); 
    
    % cut non-learners and gaze droppers (RIP)
    for i = 1:length(cutSubs)
        cutMe = cutSubs(i);
        
        x = cps(:, 1) == cutMe;
        cps(x, :) = [];
        
        y = P2(:, 1) == cutMe;
        P2(y, :) = [];
        
        z = P4(:, 1) == cutMe;
        P4(z, :) = [];
    end


    % subjects represents the number of subjects in the current experiment.
    subjects = cps(:, 1);
    expMax = max(subTable.Trial);

    gazeChange = [];
    
    % comment these out for self-paced:
    gazeOne = [];
    gazeNine = [];
    
    targetNine = [];
    targetOne = [];

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

        optDiff = abs(p2Subject - p4Subject);       % for plot, we don't want absolute value, so get rid of it
        

        %% uncomment this next part for individual plots of attention change (eg. fig. 10 in paper). also need to get rid of abs() above in this case.
        % create a scatter plot for each subject (what we are looking for are the points at 0)
%         figure()
%         scatter(1:length(p2Subject), optDiff);
%         ylim([-2 2])
%         hold on
%         y = ylim;
%         plot([cp cp],[y(1) y(2)])
% 
% 
%         fnPlot = strcat('\Users\16132\Documents\lab\KAT\optChange\', experiment, '\', num2str(current));
% 
%         saveas(gca, char(strcat(fnPlot, '.png')));
% 
%         close all

        % at the end of this loop, gazeChange will be a #subjects * expMax
        % array of optChange values for each subject on each trial 

        gazeChange = [gazeChange, optDiff];
        
        % comment this chunk out for seld-paced
        cond = subTable.Condition(subTable.Subject == current);
        if cond(1) == 1000
           gazeOne = [gazeOne, optDiff];
           targetOne = [targetOne; targetTrial(i)];
        else
           gazeNine = [gazeNine, optDiff];
           targetNine = [targetNine; targetTrial(i)];
        end


    end

    % t- tests...I want to find the block containing at LEAST half the CP
    % trials aka the block containing trial CP + 11. 
    
    firstBin = [];
    cpBin = [];

    
    for i = 1:length(targetTrial)
        % this is the same process as in basics.m

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
    
    [hr, pr, cir, statsr] = ttest(cpBin, firstBin, 'Tail', 'left');
    
    %% fb 2/3 stuff follows below. comment out the rest for self-paced.
    
    % now one sec
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
    
    % compare one sec to nine sec (independent samples)
    disp('comparing first block')
    [h, p, ci, stats] = ttest2(firstOne, firstNine)
    
    disp('comparing cp block')
    [h, p, ci, stats] = ttest2(cpOne, cpNine)
    

end