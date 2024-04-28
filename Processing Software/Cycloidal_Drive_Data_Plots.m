%call to cleaned data files in the folders
freqFolders = dir('../Data/Cleaned Data/');
isub = [freqFolders(:).isdir];
freqNames = {freqFolders(isub).name}';
freqNames(ismember(freqNames,{'.','..', '.ipynb_checkpoints'})) = [];
%figure;

%grab folder lengths for processing data
number_folders = length(freqNames);
number_columns = ceil(sqrt(number_folders)); 
number_rows = ceil(number_folders / number_columns);

%define preset frequency values
%these values will be called through loop iterations 
frequency_values_hz = [0.1, 0.13, 0.19, 0.26, 0.37, ...
    0.51, 0.71, 1, 1.39, 1.93, 2.68, 3.73, 5.17, 7.19, 10];
%convert frequencies from hertz to rad/s using 2*pi*f
w_guess_values = 2*pi.*frequency_values_hz;

%manual amplitude and linear slope guesses
%these have been added in as an attempt to remedy curve fit errors
%with higher frequencies
output_enc_amp_guess = [57244.31, 41139.93, 30411.92, 22090.69, ...
   15960.23, 11697.67, 8310.19, 5910.56, 4174.33, 3094.66, ...
   180, 160, 100, 46, 155];
input_enc_amp_guess = [572279.83, 411547.32, 304346.98, 220991.5, ...
   159725.42, 117416.05, 83607.86, 59510.31, 42113.41, 31073.21, ...
   1663.35, 1638.66, 1305.16, 1049.28, 1907];
output_enc_m_guess = [-21.84, 433.11, 213.90, 105.36, 101.09, ...
   349.07, 72.47, 227.88, 49.25, 21.02, 0, 0, 0, 0, 1543.55];
input_enc_m_guess = [-229.34, 4304.93, 2113.94, 1026.23, 961.85, ...
    3467.78, 744.34, 2250.87, 511.56, 140.8, 0, 0, 0, 0, 15576.56];

%define the linear + sinusoidal fit 
model = @(A, w, phi, m, x) A*sin(w*x + phi) + m*x;

%generate the figures for encoder and motor input curves
figure_output_encoder = figure;
figure_input_encoder = figure;
figure_input_velo = figure;
figure_input_gyro = figure;
figure_output_gyro = figure;

%data trials -> blue, curve fit -> red
lineColor = 'blue';  
fitColor = 'red';  

%cell arrays store the curve fit equations 
derivative_output_encoder_equations = cell(number_folders, 1);
derivative_input_encoder_equations = cell(number_folders, 1);
derivative_input_velo_equations = cell(number_folders, 1);
integral_input_gyro_equations = cell(number_folders, 1);
integral_output_gyro_equations = cell(number_folders, 1);

%generate arrays for amplitudes and phases for bode plots
product_output_enc_values = zeros(number_folders, 1);
product_input_enc_values = zeros(number_folders, 1);
product_input_velo_values = zeros(number_folders, 1);
product_input_gyro_values = zeros(number_folders, 1);
product_output_gyro_values = zeros(number_folders, 1);

phases_output_encoder = zeros(number_folders, 1);
phases_input_encoder = zeros(number_folders, 1);
phases_input_velo = zeros(number_folders, 1);
phases_input_gyro = zeros(number_folders, 1);
phases_output_gyro = zeros(number_folders, 1);

%subplot layout for encoder and motor input figures 
subplot_rows_output = number_rows;
subplot_columns_output = number_columns;
subplot_rows_input = number_rows;
subplot_columns_input = number_columns;
subplot_rows_input_velo = number_rows;
subplot_columns_input_velo = number_columns;
subplot_rows_input_gyro = number_rows;
subplot_columns_input_gyro = number_columns;
subplot_rows_output_gyro = number_rows;
subplot_columns_output_gyro = number_columns;

% Loop through each frequency folder for output_encoder
for i = 1:number_folders

    %call the angular frequency array from earlier
    w_guess = w_guess_values(i); 

    %updates the subplot
    figure(figure_output_encoder);
    subplot(subplot_rows_output, subplot_columns_output, i);
    hold on;

    %call the data folder name
    FolderName = ['../Data/Cleaned Data/', freqNames{i}]; 
    
    %set up trial data arrays
    x_all = [];
    y_all = [];

    %loop through all the trials 
    for j = 0:4
        trialFileName = fullfile(FolderName, ['trial', num2str(j), '.csv']);
        if isfile(trialFileName)
            data = readtable(trialFileName);
            data(2, :) = [];
            time = (data{:, 'time'}) ./ (1e6); %convert out of microseconds
            output_encoder = data{:, 'output_encoder'};
            
            %accumulate data
            x_all = [x_all; time];
            y_all = [y_all; output_encoder];
        end
    end
    
    %sort data based on time
    [x_all_sorted, sort_indices] = sort(x_all);
    y_all_sorted = y_all(sort_indices);
    
    %generate curve fit
    %develop guesses for parameters [A, w, phi, m]
    %note these are manually input, see report for original algorithm
    A_guess = output_enc_amp_guess(i);  % Amplitude
    w_guess = w_guess_values(i);              % Angular frequency
    phi_guess = 0;                            % Phase 
    m_guess = input_enc_m_guess(i); % Slope 
    initialGuess = [A_guess, w_guess, phi_guess, m_guess];
    
    %fit the model
    fittedModel = fit(x_all_sorted, y_all_sorted, model, 'StartPoint', initialGuess);
    
    %plot original data
    plot(x_all_sorted, y_all_sorted, 'Color', lineColor);
    
    %plot the curve fit
    plot(x_all_sorted, fittedModel(x_all_sorted), 'Color', fitColor);

    %grab coeffs
    coeffs_output_encoder = coeffvalues(fittedModel);
    
    %construct equation string for display on subplot 
    eqn_str = sprintf('Fit Equation: y = %.2f*sin(%.2fx + %.2f) + %.2fx', coeffs_output_encoder(1), coeffs_output_encoder(2), coeffs_output_encoder(3), coeffs_output_encoder(4));
    
    %display the equation as a title
    title({freqNames{i}, eqn_str}, 'Interpreter', 'none');
    xlabel('Time (s)');
    ylabel('Output Encoder');
    grid on;

    % Calculate the derivative equation
    product_output_enc = coeffs_output_encoder(1) * coeffs_output_encoder(2);
    product_output_enc_values(i) = product_output_enc;
    phases_output_encoder(i) = coeffs_output_encoder(3);
    derivative_output_encoder_equation = sprintf('%.6f * cos(%.6f * t + %.6f) + %.6f', product_output_enc, coeffs_output_encoder(2), coeffs_output_encoder(3), coeffs_output_encoder(4));
    derivative_output_encoder_equations{i} = derivative_output_encoder_equation;
    
    fprintf('Derivative of the curve fit equation for %s:\n', freqNames{i});
    fprintf('%s\n\n', derivative_output_encoder_equation);

    hold off;
end

%input encoder
for i = 1:number_folders

    w_guess = w_guess_values(i); 

    figure(figure_input_encoder); 
    subplot(subplot_rows_input, subplot_columns_input, i);
    hold on;

    FolderName = ['../Data/Cleaned Data/', freqNames{i}]; 
    
    x_all = [];
    y_all = [];

    for j = 0:4
        trialFileName = fullfile(FolderName, ['trial', num2str(j), '.csv']);
        if isfile(trialFileName)
            data = readtable(trialFileName);
            data(2, :) = [];
            time = (data{:, 'time'}) ./ (1e6); 
            input_encoder = data{:, 'input_encoder'};
            
            x_all = [x_all; time];
            y_all = [y_all; input_encoder];
        end
    end
    
    [x_all_sorted, sort_indices] = sort(x_all);
    y_all_sorted = y_all(sort_indices);
    
    A_guess = input_enc_amp_guess(i); 
    w_guess = w_guess_values(i);              
    phi_guess = 0;                           
    m_guess = output_enc_m_guess(i);
    initialGuess = [A_guess, w_guess, phi_guess, m_guess];
    
    fittedModel = fit(x_all_sorted, y_all_sorted, model, 'StartPoint', initialGuess);
    
    plot(x_all_sorted, y_all_sorted, 'Color', lineColor);
    
    plot(x_all_sorted, fittedModel(x_all_sorted), 'Color', fitColor);

    coeffs_input_encoder = coeffvalues(fittedModel);
    
    eqn_str = sprintf('Fit Equation: y = %.2f*sin(%.2fx + %.2f) + %.2fx', coeffs_input_encoder(1), coeffs_input_encoder(2), coeffs_input_encoder(3), coeffs_input_encoder(4));
    
    title({freqNames{i}, eqn_str}, 'Interpreter', 'none');
    xlabel('Time (s)');
    ylabel('Input Encoder');
    grid on;

    product_input_enc = coeffs_input_encoder(1) * coeffs_input_encoder(2);
    product_input_enc_values(i) = product_input_enc;
    phases_input_encoder(i) = coeffs_input_encoder(3);
    derivative_input_encoder_equation = sprintf('%.6f * cos(%.6f * t + %.6f) + %.6f', product_input_enc, coeffs_input_encoder(2), coeffs_input_encoder(3), coeffs_input_encoder(4));
    derivative_input_encoder_equations{i} = derivative_input_encoder_equation;

    fprintf('Derivative of the curve fit equation for %s:\n', freqNames{i});
    fprintf('%s\n\n', derivative_input_encoder_equation);

    hold off;
end

% Loop through each frequency folder for motor input
for i = 1:number_folders

    w_guess = w_guess_values(i);

    figure(figure_input_velo);  
    subplot(subplot_rows_input_velo, subplot_columns_input_velo, i);
    hold on;
 
    FolderName = ['../Data/Cleaned Data/', freqNames{i}]; 
    
    x_all = [];
    y_all = [];

    for j = 0:4
        trialFileName = fullfile(FolderName, ['trial', num2str(j), '.csv']);
        if isfile(trialFileName)
            data = readtable(trialFileName);
            data(2, :) = [];
            time = (data{:, 'time'}) ./ (1e6); 
            input_velo = data{:, 'velocity_in'};
            
            x_all = [x_all; time];
            y_all = [y_all; input_velo];
        end
    end
    
    [x_all_sorted, sort_indices] = sort(x_all);
    y_all_sorted = y_all(sort_indices);
    
    A_guess = 100; %we know the amplitude will be 100
    w_guess = w_guess_values(i);              
    phi_guess = 1.57; %we know the phase shift will be 90 deg                           
    m_guess = (y_all_sorted(end) - y_all_sorted(1)) ./ (x_all_sorted(end) - x_all_sorted(1)); % Slope guess
    initialGuess = [A_guess, w_guess, phi_guess, m_guess];
    
    fittedModel = fit(x_all_sorted, y_all_sorted, model, 'StartPoint', initialGuess);
    
    plot(x_all_sorted, y_all_sorted, 'Color', lineColor);
    
    plot(x_all_sorted, fittedModel(x_all_sorted), 'Color', fitColor);

    coeffs_input_velo = coeffvalues(fittedModel);
    
    eqn_str = sprintf('Fit Equation: y = %.2f*sin(%.2fx + %.2f) + %.2fx', coeffs_input_velo(1), coeffs_input_velo(2), coeffs_input_velo(3), coeffs_input_velo(4));
    
    title({freqNames{i}, eqn_str}, 'Interpreter', 'none');
    xlabel('Time (s)');
    ylabel('Motor Input');
    grid on;

    hold off;
end

% Loop through each frequency folder for input gyro (accelerometer)
for i = 1:number_folders

    w_guess = w_guess_values(i);

    figure(figure_input_gyro);  
    subplot(subplot_rows_input_gyro, subplot_columns_input_gyro, i);
    hold on;
 
    FolderName = ['../Data/Cleaned Data/', freqNames{i}]; 
    
    x_all = [];
    y_all = [];

    for j = 0:4
        trialFileName = fullfile(FolderName, ['trial', num2str(j), '.csv']);
        if isfile(trialFileName)
            data = readtable(trialFileName);
            data(2, :) = [];
            time = (data{:, 'time'}) ./ (1e6); 
            input_gyro = data{:, 'input_gyro'}; % Fix here
            
            x_all = [x_all; time];
            y_all = [y_all; input_gyro];
        end
    end
    
    [x_all_sorted, sort_indices] = sort(x_all);
    y_all_sorted = y_all(sort_indices);
    
    A_guess = (max(y_all_sorted) - min(y_all_sorted)) / 2; 
    w_guess = w_guess_values(i);              
    phi_guess = 0;                            
    m_guess = (y_all_sorted(end) - y_all_sorted(1)) / (x_all_sorted(end) - x_all_sorted(1)); 
    initialGuess = [A_guess, w_guess, phi_guess, m_guess];
    
    fittedModel = fit(x_all_sorted, y_all_sorted, model, 'StartPoint', initialGuess);
    
    plot(x_all_sorted, y_all_sorted, 'Color', lineColor);
    
    plot(x_all_sorted, fittedModel(x_all_sorted), 'Color', fitColor);

    coeffs_input_gyro = coeffvalues(fittedModel);
    
    % Calculate the integral equation
    integral_input_gyro_equation = sprintf('(%.6f/%.6f) * (cos(%.6f * t) - cos(%.6f * %.6f))', coeffs_input_gyro(1), coeffs_input_gyro(2), coeffs_input_gyro(2), coeffs_input_gyro(2), x_all_sorted(1));
    integral_input_gyro_equations{i} = integral_input_gyro_equation; % Store the equation in the cell array

    % Display the equation as a title 
    % Construct the equation string
    eqn_str = sprintf('Fit Equation: y = %.2f*sin(%.2fx + %.2f) + %.2fx', coeffs_input_gyro(1), coeffs_input_gyro(2), coeffs_input_gyro(3), coeffs_input_gyro(4));
    
    % Display the equation as a title
    title({freqNames{i}, eqn_str}, 'Interpreter', 'none');
    xlabel('Time (s)');
    ylabel('Input Accelerometer');
    grid on;

    % Display the equation as a title
    fprintf('Integral of the curve fit equation for %s:\n', freqNames{i});
    fprintf('%s\n\n', integral_input_gyro_equation);

    hold off;
end

% Loop through each frequency folder for output gyro (accelerometer)
for i = 1:number_folders

    w_guess = w_guess_values(i);

    figure(figure_output_gyro);  
    subplot(subplot_rows_output_gyro, subplot_columns_output_gyro, i);
    hold on;
 
    FolderName = ['../Data/Cleaned Data/', freqNames{i}]; 
    
    x_all = [];
    y_all = [];

    for j = 0
        trialFileName = fullfile(FolderName, ['trial', num2str(j), '.csv']);
        if isfile(trialFileName)
            data = readtable(trialFileName);
            data(2, :) = [];
            time = (data{:, 'time'}) ./ (1e6); 
            output_gyro = data{:, 'output_gyro'};
            
            x_all = [x_all; time];
            y_all = [y_all; output_gyro];
        end
    end
    
    [x_all_sorted, sort_indices] = sort(x_all);
    y_all_sorted = y_all(sort_indices);
    
    A_guess = (max(y_all_sorted) - min(y_all_sorted)) / 2; 
    w_guess = w_guess_values(i);              
    phi_guess = 0;                            
    m_guess = (y_all_sorted(end) - y_all_sorted(1)) / (x_all_sorted(end) - x_all_sorted(1)); 
    initialGuess = [A_guess, w_guess, phi_guess, m_guess];
    
    fittedModel = fit(x_all_sorted, y_all_sorted, model, 'StartPoint', initialGuess);
    
    plot(x_all_sorted, y_all_sorted, 'Color', lineColor);
    
    plot(x_all_sorted, fittedModel(x_all_sorted), 'Color', fitColor);

    coeffs_output_gyro = coeffvalues(fittedModel);
    
    % Calculate the integral equation
    integral_output_gyro_equation = sprintf('(%.6f/%.6f) * (cos(%.6f * t) - cos(%.6f * %.6f))', coeffs_output_gyro(1), coeffs_output_gyro(2), coeffs_output_gyro(2), coeffs_output_gyro(2), x_all_sorted(1));
    integral_output_gyro_equations{i} = integral_output_gyro_equation; % Store the equation in the cell array

    % Construct the equation string
    eqn_str = sprintf('Fit Equation: y = %.2f*sin(%.2fx + %.2f) + %.2fx', coeffs_output_gyro(1), coeffs_output_gyro(2), coeffs_output_gyro(3), coeffs_output_gyro(4));
    
    % Display the equation as a title
    title({freqNames{i}, eqn_str}, 'Interpreter', 'none');
    xlabel('Time (s)');
    ylabel('Output Accelerometer');
    grid on;

    fprintf('Integral of the curve fit equation for %s:\n', freqNames{i});
    fprintf('%s\n\n', integral_output_gyro_equation);

    hold off;
end

% Generate bode plots 
%find amplitude differences
transfer_function_output_input = product_output_enc_values - product_input_enc_values;
transfer_function_output_velo = product_output_enc_values - 100;
transfer_function_input_velo = product_input_enc_values - 100;

%find phase differences (in radians)
phase_difference_output_input = phases_output_encoder - phases_input_encoder;
phase_difference_output_velo = phases_output_encoder - 1.57;
phase_difference_input_velo = phases_input_encoder - 1.57;

%convert radians to degrees
phase_difference_output_input_deg = rad2deg(phase_difference_output_input);
phase_difference_output_velo_deg = rad2deg(phase_difference_output_velo);
phase_difference_input_velo_deg = rad2deg(phase_difference_input_velo);

% Plot transfer functions
figure;
subplot(3, 1, 1);
semilogx(frequency_values_hz, 20*log10(abs(transfer_function_output_input))); % Changed frequencies to frequency_values_hz
title('Magnitude: Output Encoder - Input Encoder');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
grid on;

subplot(3, 1, 2);
semilogx(frequency_values_hz, 20*log10(abs(transfer_function_output_velo))); % Changed frequencies to frequency_values_hz
title('Magnitude: Output Encoder - Motor Input');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
grid on;

subplot(3, 1, 3);
semilogx(frequency_values_hz, 20*log10(abs(transfer_function_input_velo))); % Changed frequencies to frequency_values_hz
title('Magnitude: Input Encoder - Motor Input');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
grid on;

% Plot phase differences
figure;
subplot(3, 1, 1);
semilogx(frequency_values_hz, phase_difference_output_input_deg);
title('Phase: Output Encoder - Input Encoder');
xlabel('Frequency (Hz)');
ylabel('Phase Difference (degrees)');
grid on;

subplot(3, 1, 2);
semilogx(frequency_values_hz, phase_difference_output_velo_deg);
title('Phase: Output Encoder - Motor Input');
xlabel('Frequency (Hz)');
ylabel('Phase Difference (degrees)');
grid on;

subplot(3, 1, 3);
semilogx(frequency_values_hz, phase_difference_input_velo_deg);
title('Phase: Input Encoder - Motor Input');
xlabel('Frequency (Hz)');
ylabel('Phase Difference (degrees)');
grid on;

%expand plots for encoders and motor input to best display
set(figure_output_encoder, 'Position', get(0, 'Screensize'));
set(figure_input_encoder, 'Position', get(0, 'Screensize'));
set(figure_input_velo, 'Position', get(0, 'Screensize'));
set(figure_input_gyro, 'Position', get(0, 'Screensize'));
set(figure_output_gyro, 'Position', get(0, 'Screensize'));

% Define error arrays
amp_errors_output = zeros(number_folders, 1);
amp_errors_input = zeros(number_folders, 1);
phase_errors_output = zeros(number_folders, 1);
phase_errors_input = zeros(number_folders, 1);