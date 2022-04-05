% Data from spreadsheet

Epoch1 = 60*[1.0667, 1.0667, 1.1000]';
      
Epoch2 = 60*[1.1835, 1.2060, 1.2043]';

      
figure(1); set(gcf, 'Color', 'w');
    boxplot([Epoch1, Epoch2], 'labels', {'Epoch 1', 'Epoch 2'});
    ylabel('Heart Rate (bpm)'); 
    set(gca,'LineWidth', 2, 'FontWeight', 'b', 'FontSize', 14);
    
[h, p, ci, stats] = ttest(Epoch1, Epoch2)    