%%%% when we get towards the end of the experiment and people only make 1
%%%% 2, or 3 fixations during feedback, what do they look at??

function relevance = shortFB(experiment, summaryTable, fixlvl)      
 
    shortTrials = summaryTable(summaryTable.fc4 < 4, :);   
    subjects = unique(shortTrials.Subject);
    
    fixations = [];
    for i = 1:length(subjects)
        
        % this gives us trial ID of all trials with a short enough fb
        % phase, for the current subject
        trials = shortTrials.Trial(shortTrials.Subject == subjects(i));
        
        subjectFixations = fixlvl(fixlvl.Subject == subjects(i), :);
        
        % this gives us all p4 fixations for the current subject
        subjectp4 = subjectFixations(subjectFixations.TrialPhase == 4, :);
        
        % and this goes through all the short trials and picks fixations
        % from there
        for j = 1:length(trials)
            short = subjectp4.funcRelevance(subjectp4.TrialID == trials(j));
            fixations = [fixations; short];
        end       
    
    end
    
    % funcRelevance = 1, 2: relevant features; 3: irrelevant feature; > 3:
    % feedback button; 0: something else aka useless
    relevant = sum(fixations == 1 | fixations == 2);
    irrelevant = sum(fixations == 3);
    button = sum(fixations > 3);
   
    
    relevance = [relevant, irrelevant, button];
    
    
    figure()
    bar(relevance, 0.95);
    
    % title('location of fixations in very short feedback phases')
    ylabel('number of fixations')
    ylim([0 8500])
    xticks([1 2 3])
    xticklabels({'Rel. feature', 'Irrel. feature', 'FB'})
    
    fnPlot = strcat('/Users/16132/Documents/lab/KAT/', experiment, '/plots/short.png');
    saveas(gca, char(fnPlot));
    close all

end


