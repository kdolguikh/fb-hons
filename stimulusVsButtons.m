function [stims, buttons] = stimulusVsButtons(experiment, subTable)
    
    % comment these two lines out for self-paced exps
    ninesec = subTable(subTable.Condition == 9000, :);
    onesec = subTable(subTable.Condition == 1000, :);

    subjects = unique(subTable.Subject);

    %% first everyone
    meanBySubjectbuttons = [];
    for i = 1:length(subjects)   
        current = subTable.p4button(subTable.Subject == subjects(i));
        meanBySubjectbuttons = [meanBySubjectbuttons; nanmean(current)];
    end

    meanBySubjectfeatures = [];
    for i = 1:length(subjects)
        current = subTable.p4features(subTable.Subject == subjects(i));
        meanBySubjectfeatures = [meanBySubjectfeatures; nanmean(current)];
    end

    stims = meanBySubjectfeatures;
    buttons = meanBySubjectbuttons;
    
    means = [nanmean(stims); nanmean(buttons)];
    stds = [nanstd(meanBySubjectfeatures); nanstd(meanBySubjectbuttons)];
    
    figure()

    bar(means, 0.95);
    hold on
    errorbar([1;2], means, stds, 'r', 'linestyle', 'none');

    axis([0 3 0 3000]);
    % title('Time on stimulus vs feedback signal: one sec condition')
    ylabel('Total time (ms)')
    ylim([0 2000])
    xticks([1 2])
    xticklabels({'Stim', 'FB'})

    hold off
    
    fnPlot = strcat('/Users/16132/Documents/lab/KAT/', experiment, '/plots/stimbuttons.png');
    saveas(gca, char(fnPlot));
    close all
 
    
    %% then one sec (comment out the rest for self-paced)
    subjects = unique(onesec.Subject);
    
    meanBySubjectbuttonsOne = [];
    for i = 1:length(subjects)   
        current = onesec.p4button(onesec.Subject == subjects(i));
        meanBySubjectbuttonsOne = [meanBySubjectbuttonsOne; nanmean(current)];
    end

    meanBySubjectfeaturesOne = [];
    for i = 1:length(subjects)
        current = onesec.p4features(onesec.Subject == subjects(i));
        meanBySubjectfeaturesOne = [meanBySubjectfeaturesOne; nanmean(current)];
    end

    means = [nanmean(meanBySubjectfeaturesOne); nanmean(meanBySubjectbuttonsOne)];
    stds = [nanstd(meanBySubjectfeaturesOne); nanstd(meanBySubjectbuttonsOne)];
    
    figure()

    bar(means, 0.95);
    hold on
    errorbar([1;2], means, stds, 'r', 'linestyle', 'none');

    axis([0 4 0 5500]);
    %title('Time on stimulus vs feedback signal: one sec condition')
    ylabel('Total time (ms)')
    ylim([0 6000])
    xticks([1 2])
    xticklabels({'Stim', 'FB'})

    hold off
    
    fnPlot = strcat('/Users/16132/Documents/lab/KAT/', experiment, '/plots/stimbuttonsonesec.png');
    saveas(gca, char(fnPlot));
    close all
    

    disp('one sec condition')
    [h, p, ci, stats] = ttest(meanBySubjectfeaturesOne, meanBySubjectbuttonsOne)
        
    disp('ratio')
    ratio = nanmean(meanBySubjectbuttonsOne)/nanmean(meanBySubjectfeaturesOne)
    disp('stimulus feature rate')
    stimRate = nanmean(meanBySubjectfeaturesOne)/(nanmean(meanBySubjectfeaturesOne) + nanmean(meanBySubjectbuttonsOne))
    
    
    %% then nine sec
    subjects = unique(ninesec.Subject);
    
    meanBySubjectbuttonsNine = [];
    for i = 1:length(subjects)   
        current = ninesec.p4button(ninesec.Subject == subjects(i));
        meanBySubjectbuttonsNine = [meanBySubjectbuttonsNine; nanmean(current)];
    end

    meanBySubjectfeaturesNine = [];
    for i = 1:length(subjects)
        current = ninesec.p4features(ninesec.Subject == subjects(i));
        meanBySubjectfeaturesNine = [meanBySubjectfeaturesNine; nanmean(current)];
    end

    means = [nanmean(meanBySubjectfeaturesNine); nanmean(meanBySubjectbuttonsNine)];
    stds = [nanstd(meanBySubjectfeaturesNine); nanstd(meanBySubjectbuttonsNine)];
    
    figure()

    bar(means, 0.95);
    hold on
    errorbar([1;2], means, stds, 'r', 'linestyle', 'none');

    axis([0 4 0 5500]);
    %title('Time on stimulus vs feedback signal: nine sec condition')
    ylabel('Total time (ms)')
    ylim([0 6000])
    xticks([1 2])
    xticklabels({'Stim', 'FB'})

    hold off
    
    fnPlot = strcat('/Users/16132/Documents/lab/KAT/', experiment, '/plots/stimbuttonsninesec.png');
    saveas(gca, char(fnPlot));
    close all
    
 
    disp('nine sec condition')
    [h, p, ci, stats] = ttest(meanBySubjectfeaturesNine, meanBySubjectbuttonsNine)
        
    disp('ratio')
    ratio = nanmean(meanBySubjectbuttonsNine)/nanmean(meanBySubjectfeaturesNine)
    disp('stimulus feature rate')
    stimRate = nanmean(meanBySubjectfeaturesNine)/(nanmean(meanBySubjectfeaturesNine) + nanmean(meanBySubjectbuttonsNine))
    
    
    %% compare one sec to nine sec
    disp('comparing time on feedback buttons')
    [h, p, ci, stats] = ttest2(meanBySubjectbuttonsOne, meanBySubjectbuttonsNine)
    
    disp('comparing time on stimulus features')
    [h, p, ci, stats] = ttest2(meanBySubjectfeaturesOne, meanBySubjectfeaturesNine)

end