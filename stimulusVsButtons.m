function [stims, buttons] = stimulusVsButtons(experiment, subTable, fixed)

    %  Author: Kat 
    %  Date Created: 
    %  Last Edit: 
     
    %  Cognitive Science Lab, Simon Fraser University 
    %  Originally Created For: feedback
      
    %  Reviewed: 
    %  Verified: 

    
    %  PURPOSE: examine time spent looking at stimulus features and time
    %  spent looking at feedback buttons during feedback phase.
 
    
    %  INPUT: 
    
%         experiment: experiment name

%         subTable: binned data table (loaded from directory in master.m)

%         fixed: 1 if experiment is fixed time (feedback2, feedback3), 0 if
%         self-paced (asset, sato, sshrcif)

   
    %  OUTPUT: time spent on stimulus features and on feedback buttons
    %  during experiment feedback phase
    
    %  Additional Scripts Used: 
    
    
    %  Additional Comments: 
    

    subjects = unique(subTable.Subject);

    %% first everyone
    
    % we are looking for a mean time on stimulus features and a mean time
    % on feedback buttons for each subject. then we will compare these two
    % distributions of means.
    
    % buttons
    meanBySubjectbuttons = [];
    for i = 1:length(subjects)   
        current = subTable.p4button(subTable.Subject == subjects(i));
        meanBySubjectbuttons = [meanBySubjectbuttons; nanmean(current)];
    end

    % features
    meanBySubjectfeatures = [];
    for i = 1:length(subjects)
        current = subTable.p4features(subTable.Subject == subjects(i));
        meanBySubjectfeatures = [meanBySubjectfeatures; nanmean(current)];
    end

    stims = meanBySubjectfeatures;
    buttons = meanBySubjectbuttons;
    
    means = [nanmean(stims); nanmean(buttons)];
    stds = [nanstd(meanBySubjectfeatures); nanstd(meanBySubjectbuttons)];
    
    % plot differences 
    figure()

    bar(means, 0.95);
    hold on
    errorbar([1;2], means, stds, 'r', 'linestyle', 'none');

    axis([0 3 0 3000]);
    % title commented out for final figures
    % title('Time on stimulus vs feedback signal: one sec condition')
    ylabel('Total time (ms)')
    ylim([0 2000])
    xticks([1 2])
    xticklabels({'Stim', 'FB'})

    hold off
    
    % save plot
    fnPlot = strcat('/Users/16132/Documents/lab/KAT/', experiment, '/plots/stimbuttons.png');
    saveas(gca, char(fnPlot));
    close all
 
    
    % for feedback2 and feedback3, we also want to look by condition and
    % compare across conditions
    if fixed
        
        ninesec = subTable(subTable.Condition == 9000, :);
        onesec = subTable(subTable.Condition == 1000, :);

        
        %%  one sec people (exact same process as above)
        subjects = unique(onesec.Subject);

        % buttons
        meanBySubjectbuttonsOne = [];
        for i = 1:length(subjects)   
            current = onesec.p4button(onesec.Subject == subjects(i));
            meanBySubjectbuttonsOne = [meanBySubjectbuttonsOne; nanmean(current)];
        end

        % features
        meanBySubjectfeaturesOne = [];
        for i = 1:length(subjects)
            current = onesec.p4features(onesec.Subject == subjects(i));
            meanBySubjectfeaturesOne = [meanBySubjectfeaturesOne; nanmean(current)];
        end

        means = [nanmean(meanBySubjectfeaturesOne); nanmean(meanBySubjectbuttonsOne)];
        stds = [nanstd(meanBySubjectfeaturesOne); nanstd(meanBySubjectbuttonsOne)];


        % and plot the difference
        figure()

        bar(means, 0.95);
        hold on
        errorbar([1;2], means, stds, 'r', 'linestyle', 'none');

        axis([0 4 0 5500]);

        % title commented out for final figure used in my paper
        %title('Time on stimulus vs feedback signal: one sec condition')
        ylabel('Total time (ms)')
        ylim([0 6000])
        xticks([1 2])
        xticklabels({'Stim', 'FB'})

        hold off

        % save plot
        fnPlot = strcat('/Users/16132/Documents/lab/KAT/', experiment, '/plots/stimbuttonsonesec.png');
        saveas(gca, char(fnPlot));
        close all

        % t-test, ratio, stim rate for one sec people (for analysis including everyone,
        % this portion is done in master.m)
        disp('one sec condition')
        [h, p, ci, stats] = ttest(meanBySubjectfeaturesOne, meanBySubjectbuttonsOne)

        disp('ratio')
        ratio = nanmean(meanBySubjectbuttonsOne)/nanmean(meanBySubjectfeaturesOne)
        disp('stimulus feature rate')
        stimRate = nanmean(meanBySubjectfeaturesOne)/(nanmean(meanBySubjectfeaturesOne) + nanmean(meanBySubjectbuttonsOne))


        %% then nine sec (also same as above)
        subjects = unique(ninesec.Subject);

        % buttons
        meanBySubjectbuttonsNine = [];
        for i = 1:length(subjects)   
            current = ninesec.p4button(ninesec.Subject == subjects(i));
            meanBySubjectbuttonsNine = [meanBySubjectbuttonsNine; nanmean(current)];
        end

        % features
        meanBySubjectfeaturesNine = [];
        for i = 1:length(subjects)
            current = ninesec.p4features(ninesec.Subject == subjects(i));
            meanBySubjectfeaturesNine = [meanBySubjectfeaturesNine; nanmean(current)];
        end

        means = [nanmean(meanBySubjectfeaturesNine); nanmean(meanBySubjectbuttonsNine)];
        stds = [nanstd(meanBySubjectfeaturesNine); nanstd(meanBySubjectbuttonsNine)];

        % plot it
        figure()

        bar(means, 0.95);
        hold on
        errorbar([1;2], means, stds, 'r', 'linestyle', 'none');

        axis([0 4 0 5500]);
        % title commented out for final figures
        %title('Time on stimulus vs feedback signal: nine sec condition')
        ylabel('Total time (ms)')
        ylim([0 6000])
        xticks([1 2])
        xticklabels({'Stim', 'FB'})

        hold off

        % save plot
        fnPlot = strcat('/Users/16132/Documents/lab/KAT/', experiment, '/plots/stimbuttonsninesec.png');
        saveas(gca, char(fnPlot));
        close all

        % t-test, ratio, and stim rate
        disp('nine sec condition')
        [h, p, ci, stats] = ttest(meanBySubjectfeaturesNine, meanBySubjectbuttonsNine)

        disp('ratio')
        ratio = nanmean(meanBySubjectbuttonsNine)/nanmean(meanBySubjectfeaturesNine)
        disp('stimulus feature rate')
        stimRate = nanmean(meanBySubjectfeaturesNine)/(nanmean(meanBySubjectfeaturesNine) + nanmean(meanBySubjectbuttonsNine))


        %% finally, compare across conditions
        disp('comparing time on feedback buttons')
        [h, p, ci, stats] = ttest2(meanBySubjectbuttonsOne, meanBySubjectbuttonsNine)

        disp('comparing time on stimulus features')
        [h, p, ci, stats] = ttest2(meanBySubjectfeaturesOne, meanBySubjectfeaturesNine)
    
    end

end