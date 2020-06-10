function [] = featureRelevanceTime(experiment, phase)

    addpath 'C:\Users\16132\Documents\lab\feedback\fb-hons'

    dir = strcat('C:/Users/16132/Documents/lab/feedback/KAT/', experiment); 
    load(strcat(dir, '/explvl.mat'));
    load(strcat(dir, '/fixlvl.mat'));
    
    cps = subjTableHack(experiment, 'cp');
    
    gd = explvl.GazeDropper == 1;
    nl = explvl.Learner == 0;
    
    % 9 sec only
    one = explvl.FeedbackDuration == 1000;
    cut = gd | nl | one;
    
    % 1 sec only
%     nine = explvl.FeedbackDuration == 9000;
%     cut = gd | nl | nine;
    
    badSubs = explvl.Subject(cut);

    for j = 1:length(badSubs) 
         cutMe = badSubs(j);
         x = cps(:, 1) == cutMe;
         cps(x, :) = [];
         
         fixlvl(fixlvl.Subject == j, :) = [];
    end
    
    
    
    fixlvl = fixlvl(fixlvl.TrialPhase == phase, :);

    subjects = cps(:, 1);
    
    pre = [];
    post = [];
    farPost = [];
    
    for i = 1:length(subjects)
        cp = cps(i, 2);
        
        % pre-CP
        precp = fixlvl(fixlvl.Subject == subjects(i) & fixlvl.TrialID < cp, :);
        rel = precp.Duration(precp.funcRelevance == 1 | precp.funcRelevance == 2);
        irrel = precp.Duration(precp.funcRelevance == 3);
        
        current = [nanmean(rel), nanmean(irrel)];
        pre = [pre; current];
        
        % one block post-CP 48 trials
        postCPOne = fixlvl(fixlvl.Subject == subjects(i) & fixlvl.TrialID >= cp & fixlvl.TrialID < cp + 48, :);
        rel = postCPOne.Duration(postCPOne.funcRelevance == 1 | postCPOne.funcRelevance == 2);
        irrel = postCPOne.Duration(postCPOne.funcRelevance == 3);
        
        current = [nanmean(rel), nanmean(irrel)];
        post = [post; current];
        
        % second block post-CP 48 trials
        postCPTwo = fixlvl(fixlvl.Subject == subjects(i) & fixlvl.TrialID >= cp + 48 & fixlvl.TrialID < cp + 96, :);
        rel = postCPTwo.Duration(postCPTwo.funcRelevance == 1 | postCPTwo.funcRelevance == 2);
        irrel = postCPTwo.Duration(postCPTwo.funcRelevance == 3);
        
        current = [nanmean(rel), nanmean(irrel)];
        farPost = [farPost; current];
        
        
    end
    
    relevant = [pre(:, 1), post(:, 1), farPost(:, 1)];
    irrelevant = [pre(:, 2), post(:, 2), farPost(:, 2)];
    
    [p,tbl,stats] = anova1(relevant);
    [p2,tbl2,stats2] = anova1(irrelevant);
    
    errorrel = [nanstd(pre(:, 1))/sqrt(length(pre(:, 1))), nanstd(post(:, 1))/sqrt(length(post(:, 1))), nanstd(farPost(:, 1))/sqrt(length(farPost(:, 1)))];   
    errorirrel = [nanstd(pre(:, 2))/sqrt(length(pre(:, 2))), nanstd(post(:, 2))/sqrt(length(post(:, 2))), nanstd(farPost(:, 2))/sqrt(length(farPost(:, 2)))];

    
    bar(nanmean(relevant), 'edgecolor', 'w', 'facecolor', 'w');
    hold on
    bar(nanmean(irrelevant), 'edgecolor', 'w', 'facecolor', 'w');
    hold on
    p3 = plot([1, 2, 3], nanmean(relevant), '-xr', [1, 2, 3], nanmean(irrelevant), '-xb');
    
    errorbar(nanmean(relevant), errorrel, '.k');
    errorbar(nanmean(irrelevant), errorirrel, '.k');
    
    legend([p3], {'relevant', 'irrelevant'});
    xticklabels({'pre-CP', 'post-CP 1', 'post-CP 2'});
    ylim([0 500]);


end