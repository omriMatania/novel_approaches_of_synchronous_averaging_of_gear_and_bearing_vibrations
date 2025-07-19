clear all; close all;

records_path = ['D:\data\papers\synchronous_average_for_bearing_vibrations\MFPT_dataset\'] ;

y_lim_range = [-5.5, 7.1] ;

num_sgmnts_for_sa = 90 ;
num_sas = 2 ;

axis_name_size = 20 ;
title_size = 25 ;
font_axis_size = 12 ;
lgnd_size = 14 ;

files = dir(fullfile(records_path, '*.mat'));
num_records = numel(files);
snr_simple = zeros(num_records, 1) ;
snr_sync_to_ref = zeros(num_records, 1) ;
snr_mean_sync_itrtns = zeros(num_records, 1) ;
snr_angulr_sync = zeros(num_records, 1) ;
R_squared_simple = zeros(num_records, 1) ;
R_squared_sync_to_ref = zeros(num_records, 1) ;
R_squared_mean_sync_itrtns = zeros(num_records, 1) ;
R_squared_angulr_sync = zeros(num_records, 1) ;

tic()
ind = 1 ;
figure
figure_ind = 1 ;
for record_num = 1:num_records

    disp(['record_num:', num2str(record_num), '/', num2str(num_records), ...
        ', t:', num2str(round(toc()))])
    
    load([records_path,'record_num_', num2str(record_num), '.mat'])
    record_t = data.sig_t ;
    sampling_rate = data.sampling_rate ;
    brng_spcftns = data.bearing_specifications ;
    
    [~, ~, bpfo, ~] = calc_bearing_tones(data.shaft_speed, brng_spcftns.number_rolling_elements, ...
        brng_spcftns.ball_diameter, brng_spcftns.pitch_diameter, brng_spcftns.bearing_contact_angle) ;
    rps = bpfo * ones(size(record_t)) ;
    dt = 1 / sampling_rate ;
    t = [0 : dt : (length(record_t)-1)*dt].' ;
    [~, record_cyc, N] = angular_resampling(t, rps, t, record_t) ;
    
    sas_simple = zeros(N, num_sas) ; sas_sync_to_ref = zeros(N, num_sas) ;
    sas_mean_sync_itrtns = zeros(N, num_sas) ; sas_angulr_sync = zeros(N, num_sas) ;
    for sa_num = 1:num_sas
        sig_len = N * num_sgmnts_for_sa ;
        sig = record_cyc((sa_num-1)*sig_len+1:sa_num*sig_len) ;

        sas_simple(:, sa_num) = calc_synchronous_average(sig, N) ;
        sas_sync_to_ref(:, sa_num) = calc_synchronous_average(sig, N, ...
            'Technique', 'Sync to Ref Segment') ;
        sas_mean_sync_itrtns(:, sa_num) = calc_synchronous_average(sig, N, ...
            'Technique', 'Mean - Sync Iterations') ;
        sas_angulr_sync(:, sa_num) = calc_synchronous_average(sig, N, ...
            'Technique', 'Angular Synchronization', 'Maximal delay deviation', 0.01) ;
    end % of for

    snr_simple(record_num) = estm_snr(sas_simple) ;
    snr_sync_to_ref(record_num) = estm_snr(sas_sync_to_ref) ;
    snr_mean_sync_itrtns(record_num) = estm_snr(sas_mean_sync_itrtns) ;
    [snr_angulr_sync(record_num), sas_angulr_sync] = estm_snr(sas_angulr_sync) ;

    sgmnts_mtrx = reshape(record_cyc(1:sig_len*num_sas), N, sig_len*num_sas/N) ;
    R_squared_simple(record_num) = estm_R_squared(sas_simple, sgmnts_mtrx, num_sgmnts_for_sa) ;
    R_squared_sync_to_ref(record_num) = estm_R_squared(sas_sync_to_ref, sgmnts_mtrx, num_sgmnts_for_sa) ;
    R_squared_mean_sync_itrtns(record_num) = estm_R_squared(sas_mean_sync_itrtns, sgmnts_mtrx, num_sgmnts_for_sa) ;
    R_squared_angulr_sync(record_num) = estm_R_squared(sas_angulr_sync, sgmnts_mtrx, num_sgmnts_for_sa) ;

    dcyc = 1 / N ;
    cyc = [0:dcyc:(N-1)*dcyc].';
    subplot(2,2,ind)
    plot(cyc, sas_angulr_sync(:, 1), 'LineWidth', 2)
    hold on
    plot(cyc, sas_angulr_sync(:, 2), 'LineWidth', 1)
    hold off
    ylim(y_lim_range)
    ax = gca;
    ax.FontSize = font_axis_size; % font size.
    title(['Record number ', num2str(record_num)], ...
        'FontName', 'Times New Roman', 'FontSize', title_size)
    xlabel('Cycle', 'FontName', 'Times New Roman', 'FontSize', axis_name_size)
    ylabel('Acceleration [g]', 'FontName', 'Times New Roman', 'FontSize', axis_name_size)
    legend('SA 1', 'SA 2', 'FontName', 'Times New Roman', 'FontSize', lgnd_size, 'Location', 'northwest');

    ind = ind + 1 ;
    if ind == 5 || record_num == num_records
        ind = 1 ;
        figure
        figure_ind = figure_ind + 1 ;
    end

end % of for


plot(snr_simple, 'LineWidth', 3);
hold on;
plot(snr_sync_to_ref, 'LineWidth', 3);
plot(snr_mean_sync_itrtns, 'LineWidth', 3);
plot(snr_angulr_sync, 'LineWidth', 3);
xlabel('Record number', 'FontName', 'Times New Roman', 'FontSize', 25);
ylabel('SNR', 'FontName', 'Times New Roman', 'FontSize', 25);
legend('Simple', 'Sync to Ref Segment', 'Mean - Sync Iterations', 'Angular Synchronization', 'FontName', 'Times New Roman', 'FontSize', 15);
title('SNR of different synchronous averaging techniques', 'FontName', 'Times New Roman', 'FontSize', 25);
hold off;

figure;
plot(R_squared_simple, 'LineWidth', 3);
hold on;
plot(R_squared_sync_to_ref, 'LineWidth', 3);
plot(R_squared_mean_sync_itrtns, 'LineWidth', 3);
plot(R_squared_angulr_sync, 'LineWidth', 3);
xlabel('Record number', 'FontName', 'Times New Roman', 'FontSize', 25);
ylabel('R^2', 'FontName', 'Times New Roman', 'FontSize', 25);
legend('Simple', 'Sync to Ref Segment', 'Mean - Sync Iterations', 'Angular Synchronization', 'FontName', 'Times New Roman', 'FontSize', 15);
title('R^2 of different synchronous averaging techniques', 'FontName', 'Times New Roman', 'FontSize', 25);
hold off;