clear all ; close all ;

records_path = 'D:\data\papers\synchronous_average_for_bearing_vibrations\gear\' ;

files = dir(fullfile(records_path, '*.mat'));
num_records = numel(files);
M_max = 100 ;

for record_num = 1:num_records

    disp(['record_num:', num2str(record_num), '/', num2str(num_records), ...
        ', t:', num2str(round(toc()))])
    
    load([records_path,'record_num_', num2str(record_num), '.mat'])
    record_t = data.sig_t ;
    sampling_rate = data.sampling_rate ;
    gear_rps = data.gear_rps ;
    pinion_rps = data.pinion_rps ;
    zg = data.zg ;
    zp = data.zp ;
    
    dt = 1 / sampling_rate ;
    t = [0 : dt : (length(record_t)-1)*dt].' ;
    [~, gear_cyc, N_gear] = angular_resampling(t, gear_rps, t, record_t) ;
    [snr_vctr_gear, R_squared_vctr_gear, num_sgmnts_for_sa_vctr_gear] = calc_snr_and_R_squered_improvement_curves(...
        gear_cyc, N_gear, 'Vector of Number of segments for SA', [1:1:M_max]) ;
    [snr_vctr_batch_gear, R_squared_vctr_batch_gear, num_sgmnts_for_sa_vctr_batch_gear] = calc_snr_and_R_squered_improvement_curves(...
        gear_cyc, N_gear, 'Vector of Number of segments for SA', [1:1:M_max], 'Technique', 'Batch', ...
        'Batch size', zp) ;

    [~, pinion_cyc, N_pinion] = angular_resampling(t, pinion_rps, t, record_t) ;
    [snr_vctr_pinion, R_squared_vctr_pinion, num_sgmnts_for_sa_vctr_pinion] = calc_snr_and_R_squered_improvement_curves(...
        pinion_cyc, N_pinion, 'Vector of Number of segments for SA', [1:1:M_max]) ;
    [snr_vctr_batch_pinion, R_squared_vctr_batch_pinion, num_sgmnts_for_sa_vctr_batch_pinion] = calc_snr_and_R_squered_improvement_curves(...
        pinion_cyc, N_pinion, 'Vector of Number of segments for SA', [1:1:M_max], 'Technique', 'Batch', ...
        'Batch size', zg) ;

    figure
    subplot(2,2,1)
    xValues = [18, 36, 54, 72, 90];
    line([xValues; xValues], (max(snr_vctr_batch_gear)+2)*ylim, 'Color', [0.5 0.5 0.5], 'LineStyle', '--');
    hold on
    plot(num_sgmnts_for_sa_vctr_gear, snr_vctr_gear, 'LineWidth', 3)
    plot(num_sgmnts_for_sa_vctr_batch_gear, snr_vctr_batch_gear, 'LineWidth', 3)
    hold off
    ylim([0 max(snr_vctr_batch_gear)+2])
    xlim([1 M_max])
    ax = gca;
    ax.FontSize = 15; % font size.
    title(['(a) SNR improvement curve, fault ',num2str(ceil(record_num/2)),', gear'], 'FontName', ...
        'Times New Roman', 'FontSize', 21)
    xlabel('Number of averaged segments', 'FontName', 'Times New Roman', 'FontSize', 20)
    ylabel('SNR', 'FontName', 'Times New Roman', 'FontSize', 20)
    subplot(2,2,2)
    plot(num_sgmnts_for_sa_vctr_gear, R_squared_vctr_gear, 'LineWidth', 3)
    hold on
    plot(num_sgmnts_for_sa_vctr_batch_gear, R_squared_vctr_batch_gear, 'LineWidth', 3)
    ax = gca;
    ax.FontSize = 15; % font size.
    title(['(b) R^2 improvement curve, fault ',num2str(ceil(record_num/2)),', gear'], 'FontName', 'Times New Roman', 'FontSize', 22)
    xlabel('Number of averaged segments', 'FontName', 'Times New Roman', 'FontSize', 20)
    ylabel('R^2', 'FontName', 'Times New Roman', 'FontSize', 20)
    legend('Simale', 'Batch', 'FontName', 'Times New Roman', 'FontSize', 15, 'Location', 'southeast');
    xlim([1 M_max])
    ylim([min(R_squared_vctr_batch_gear)-0.1 max(R_squared_vctr_batch_gear)+0.1])
    
    subplot(2,2,3)
    xValues = [35, 70];
    line([xValues; xValues], (max(snr_vctr_batch_pinion)+2)*ylim, 'Color', [0.5 0.5 0.5], 'LineStyle', '--');
    hold on
    plot(num_sgmnts_for_sa_vctr_pinion, snr_vctr_pinion, 'LineWidth', 3)
    plot(num_sgmnts_for_sa_vctr_batch_pinion, snr_vctr_batch_pinion, 'LineWidth', 3)
    hold off
    ylim([0 max(snr_vctr_batch_pinion)+2])
    xlim([1 M_max])
    ax = gca;
    ax.FontSize = 15; % font size.
    title(['(c) SNR improvement curve, fault ',num2str(ceil(record_num/2)),', pinion'], 'FontName', ...
        'Times New Roman', 'FontSize', 21)
    xlabel('Number of averaged segments', 'FontName', 'Times New Roman', 'FontSize', 20)
    ylabel('SNR', 'FontName', 'Times New Roman', 'FontSize', 20)
    subplot(2,2,4)
    plot(num_sgmnts_for_sa_vctr_gear, R_squared_vctr_pinion, 'LineWidth', 3)
    hold on
    plot(num_sgmnts_for_sa_vctr_batch_gear, R_squared_vctr_batch_pinion, 'LineWidth', 3)
    ax = gca;
    ax.FontSize = 15; % font size.
    title(['(d) R^2 improvement curve, fault ',num2str(ceil(record_num/2)),', pinion'], 'FontName', 'Times New Roman', 'FontSize', 22)
    xlabel('Number of averaged segments', 'FontName', 'Times New Roman', 'FontSize', 20)
    ylabel('R^2', 'FontName', 'Times New Roman', 'FontSize', 20)
    legend('Simale', 'Batch', 'FontName', 'Times New Roman', 'FontSize', 15, 'Location', 'southeast');
    xlim([1 M_max])
    ylim([min(R_squared_vctr_batch_pinion)-0.1 max(R_squared_vctr_batch_pinion)+0.1])

end % of for