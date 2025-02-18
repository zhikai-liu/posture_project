function plot_normalized_hist(filename)
    S=load(filename);
    time_normalized=S.results.time_normalized;
    mean_ECG=S.results.mean_ECG;
    total_event=S.results.normalized_events;
    count_cycle=S.results.count_cycle;
    figure;
    yyaxis left;
    hold on;
    plot(time_normalized, mean_ECG, 'k', 'LineWidth', 2);
    xlabel('Normalized Time');
    ylabel('Normalized ECG');
    title('Normalized Mean ECG ');
    %xlim([-1 1]);
    AxisFormat();
    hold off;
    
    % Plot normalized event histogram
    yyaxis right;
    hold on;
    [normalized_histcount, normalized_edges] = histcounts(total_event, linspace(-2,2,80));
    histogram('BinCounts', normalized_histcount/count_cycle , 'BinEdges', normalized_edges,'FaceColor', [0.7, 0.7, 0.7]);
    xlabel('Normalized Time');
    ylabel('Event Counts');
    title(['Event Histogram - ' filename],'interpreter','none');
    xlim([-2 2]);
    AxisFormat();
    ylim([0 3]);
    hold off;
    export_svg_jpg(['hist_' filename])
    
end