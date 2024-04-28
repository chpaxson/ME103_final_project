%call to cleaned data files in the folders
freqFolders = dir('../Data/Cleaned Data/');
isub = [freqFolders(:).isdir];
freqNames = {freqFolders(isub).name}';
freqNames(ismember(freqNames,{'.','..', '.ipynb_checkpoints'})) = [];

%grab folder lengths for processing data
number_folders = length(freqNames);
number_columns = ceil(sqrt(number_folders)); 
number_rows = ceil(number_folders / number_columns);

%define preset frequency values
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

% Generate plots for each frequency fodler for the output encoder
for i = 1:number_folders
    w_guess = w_guess_values(i);
    gcf = figure(i);
    FolderName = ['../Data/Cleaned Data/', freqNames{i}];

    % Set up trial data arrays
    x_all = [];
    y_all = [];

    % Look through all the trials in the folder
    for j = 0:4
        trialFileName = fullfile(FolderName, ['trial', num2str(j), '.csv']);
        if isfile(trialFileName)
            data = readtable(trialFileName);
            data(2, :) = [];
            time = (data{:, 'time'}) ./ (1e6); % convert out of microseconds
            output_encoder = data{:, 'output_encoder'};
            
            % accumulate data
            x_all = [x_all; time];
            y_all = [y_all; output_encoder];
        end
    end

    % Sort data by time
    [x_all_sorted, sort_indices] = sort(x_all);
    y_all_sorted = y_all(sort_indices);

    % Perform curve fit
    A_guess = output_enc_amp_guess(i);
    w_guess = w_guess_values(i);
    phi_guess = 0;
    m_guess = input_enc_m_guess(i);
    guess = [A_guess, w_guess, phi_guess, m_guess];

    fittedModel = fit(x_all_sorted, y_all_sorted, model, 'StartPoint', initialGuess);
    hold on
    % Plot original data
    plot(x_all_sorted, y_all_sorted, 'Color', lineColor);
    % Plot the curve fit
    plot(x_all_sorted, fittedModel(x_all_sorted), 'Color', fitColor);

    % Get fit coefficients
    coeffs_output_encoder = coeffvalues(fittedModel);
    
    % Construct equation string for display on subplot 
    eqn_str = sprintf('Fit Equation: y = %.2f*sin(%.2fx + %.2f) + %.2fx', coeffs_output_encoder(1), coeffs_output_encoder(2), coeffs_output_encoder(3), coeffs_output_encoder(4));

    % Display the equation as a title
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

    hold off
    saveas(gcf, strcat('./Individual Curve Fit Plots/', freqNames{i}, '_output_encoder.png'))
end

% Generate plots for each frequency folder for the input encoder
for i = 1:number_folders
    w_guess = w_guess_values(i);
    gcf = figure(i);
    FolderName = ['../Data/Cleaned Data/', freqNames{i}];

    % Set up trial data arrays
    x_all = [];
    y_all = [];

    % Look through all the trials in the folder
    for j = 0:4
        trialFileName = fullfile(FolderName, ['trial', num2str(j), '.csv']);
        if isfile(trialFileName)
            data = readtable(trialFileName);
            data(2, :) = [];
            time = (data{:, 'time'}) ./ (1e6); % convert out of microseconds
            input_encoder = data{:, 'input_encoder'};
            
            % accumulate data
            x_all = [x_all; time];
            y_all = [y_all; input_encoder];
        end
    end

    % Sort data by time
    [x_all_sorted, sort_indices] = sort(x_all);
    y_all_sorted = y_all(sort_indices);

    % Perform curve fit
    A_guess = input_enc_amp_guess(i);
    w_guess = w_guess_values(i);
    phi_guess = 0;
    m_guess = input_enc_m_guess(i);
    guess = [A_guess, w_guess, phi_guess, m_guess];

    fittedModel = fit(x_all_sorted, y_all_sorted, model, 'StartPoint', initialGuess);
    hold on
    % Plot original data
    plot(x_all_sorted, y_all_sorted, 'Color', lineColor);
    % Plot the curve fit
    plot(x_all_sorted, fittedModel(x_all_sorted), 'Color', fitColor);

    % Get fit coefficients
    coeffs_input_encoder = coeffvalues(fittedModel);
    
    % Construct equation string for display on subplot 
    eqn_str = sprintf('Fit Equation: y = %.2f*sin(%.2fx + %.2f) + %.2fx', coeffs_input_encoder(1), coeffs_input_encoder(2), coeffs_input_encoder(3), coeffs_input_encoder(4));

    % Display the equation as a title
    title({freqNames{i}, eqn_str}, 'Interpreter', 'none');
    xlabel('Time (s)');
    ylabel('Input Encoder');
    grid on;

    % Calculate the derivative equation
    product_input_enc = coeffs_input_encoder(1) * coeffs_input_encoder
    product_input_enc_values(i) = product_input_enc;
    phases_input_encoder(i) = coeffs_input_encoder(3);
    derivative_input_encoder_equation = sprintf('%.6f * cos(%.6f * t + %.6f) + %.6f', product_input_enc, coeffs_input_encoder(2), coeffs_input_encoder(3), coeffs_input_encoder(4));
    derivative_input_encoder_equations{i} = derivative_input_encoder_equation;

    fprintf('Derivative of the curve fit equation for %s:\n', freqNames{i});
    fprintf('%s\n\n', derivative_input_encoder_equation);

    hold off
    saveas(gcf, strcat('./Individual Curve Fit Plots/', freqNames{i}, '_input_encoder.png'))
end

% Generate plots for each frequency folder for the motor input
for i = 1:number_folders
    w_guess = w_guess_values(i);
    gcf = figure(i);
    FolderName = ['../Data/Cleaned Data/', freqNames{i}];

    % Set up trial data arrays
    x_all = [];
    y_all = [];

    % Look through all the trials in the folder
    for j = 0:4
        trialFileName = fullfile(FolderName, ['trial', num2str(j), '.csv']);
        if isfile(trialFileName)
            data = readtable(trialFileName);
            data(2, :) = [];
            time = (data{:, 'time'}) ./ (1e6); % convert out of microseconds
            input_velocity = data{:, 'input_velocity'};
            
            % accumulate data
            x_all = [x_all; time];
            y_all = [y_all; input_velocity];
        end
    end

    % Sort data by time
    [x_all_sorted, sort_indices] = sort(x_all);
    y_all_sorted = y_all(sort_indices);

    % Perform curve fit
    A_guess = input_enc_amp_guess(i);
    w_guess = w_guess_values(i);
    phi_guess = 0;
    m_guess = input_enc_m_guess(i);
    guess = [A_guess, w_guess, phi_guess, m_guess];

    fittedModel = fit(x_all_sorted, y_all_sorted, model, 'StartPoint', initialGuess);
    hold on
    % Plot original data
    plot(x_all_sorted, y_all_sorted, 'Color', lineColor);
    % Plot the curve fit
    plot(x_all_sorted, fittedModel(x_all_sorted), 'Color', fitColor);

    % Get fit coefficients
    coeffs_input_velocity = coeffvalues(fittedModel);
    
    % Construct equation string for display on subplot 
    eqn_str = sprintf('Fit Equation: y = %.2f*sin(%.2fx + %.2f) + %.2fx', coeffs_input_velocity(1), coeffs_input_velocity(2), coeffs_input_velocity(3), coeffs_input_velocity(4));

    % Display the equation as a title
    title({freqNames{i}, eqn_str}, 'Interpreter', 'none');
    xlabel('Time (s)');
    ylabel('Input Velocity');
    grid on;

    % Calculate the derivative equation
    product_input_velo = coeffs_input_velocity(1) * coeffs_input_velocity(2);
    product_input_velo_values(i) = product_input_velo;
    phases_input_velo(i) = coeffs_input_velocity(3);
    derivative_input_velo_equation = sprintf('%.6f * cos(%.6f * t + %.6f) + %.6f', product_input_velo, coeffs_input_velocity(2), coeffs_input_velocity(3), coeffs_input_velocity(4));

    fprintf('Derivative of the curve fit equation for %s:\n', freqNames{i});
    fprintf('%s\n\n', derivative_input_velo_equation);

    hold off
    saveas(gcf, strcat('./Individual Curve Fit Plots/', freqNames{i}, '_input_velocity.png'))
end

% Generate plots for each frequency folder for the input gyro
for i = 1:number_folders
    w_guess = w_guess_values(i);
    gcf = figure(i);
    FolderName = ['../Data/Cleaned Data/', freqNames{i}];

    % Set up trial data arrays
    x_all = [];
    y_all = [];

    % Look through all the trials in the folder
    for j = 0:4
        trialFileName = fullfile(FolderName, ['trial', num2str(j), '.csv']);
        if isfile(trialFileName)
            data = readtable(trialFileName);
            data(2, :) = [];
            time = (data{:, 'time'}) ./ (1e6); % convert out of microseconds
            input_gyro = data{:, 'input_gyro'};
            
            % accumulate data
            x_all = [x_all; time];
            y_all = [y_all; input_gyro];
        end
    end

    % Sort data by time
    [x_all_sorted, sort_indices] = sort(x_all);
    y_all_sorted = y_all(sort_indices);

    % Perform curve fit
    A_guess = input_enc_amp_guess(i);
    w_guess = w_guess_values(i);
    phi_guess = 0;
    m_guess = input_enc_m_guess(i);
    guess = [A_guess, w_guess, phi_guess, m_guess];

    fittedModel = fit(x_all_sorted, y_all_sorted, model, 'StartPoint', initialGuess);
    hold on
    % Plot original data
    plot(x_all_sorted, y_all_sorted, 'Color', lineColor);
    % Plot the curve fit
    plot(x_all_sorted, fittedModel(x_all_sorted), 'Color', fitColor);

    % Get fit coefficients
    coeffs_input_gyro = coeffvalues(fittedModel);
    
    % Construct equation string for display on subplot
    eqn_str = sprintf('Fit Equation: y = %.2f*sin(%.2fx + %.2f) + %.2fx', coeffs_input_gyro(1), coeffs_input_gyro(2), coeffs_input_gyro(3), coeffs_input_gyro(4));

    % Display the equation as a title
    title({freqNames{i}, eqn_str}, 'Interpreter', 'none');
    xlabel('Time (s)');
    ylabel('Input Gyro');
    grid on;

    % Calculate the integral equation
    product_input_gyro = coeffs_input_gyro(1) * coeffs_input_gyro(2);
    product_input_gyro_values(i) = product_input_gyro;
    phases_input_gyro(i) = coeffs_input_gyro(3);
    integral_input_gyro_equation = sprintf('%.6f * sin(%.6f * t + %.6f) + %.6f', product_input_gyro, coeffs_input_gyro(2), coeffs_input_gyro(3), coeffs_input_gyro(4));

    fprintf('Integral of the curve fit equation for %s:\n', freqNames{i});
    fprintf('%s\n\n', integral_input_gyro_equation);

    hold off
    saveas(gcf, strcat('./Individual Curve Fit Plots/', freqNames{i}, '_input_gyro.png'))
end

% Generate plots for each frequency folder for the output gyro
for i = 1:number_folders
    w_guess = w_guess_values(i);
    gcf = figure(i);
    FolderName = ['../Data/Cleaned Data/', freqNames{i}];

    % Set up trial data arrays
    x_all = [];
    y_all = [];

    % Look through all the trials in the folder
    for j = 0:4
        trialFileName = fullfile(FolderName, ['trial', num2str(j), '.csv']);
        if isfile(trialFileName)
            data = readtable(trialFileName);
            data(2, :) = [];
            time = (data{:, 'time'}) ./ (1e6); % convert out of microseconds
            output_gyro = data{:, 'output_gyro'};
            
            % accumulate data
            x_all = [x_all; time];
            y_all = [y_all; output_gyro];
        end
    end

    % Sort data by time
    [x_all_sorted, sort_indices] = sort(x_all);
    y_all_sorted = y_all(sort_indices);

    % Perform curve fit
    A_guess = output_enc_amp_guess(i);
    w_guess = w_guess_values(i);
    phi_guess = 0;
    m_guess = input_enc_m_guess(i);
    guess = [A_guess, w_guess, phi_guess, m_guess];

    fittedModel = fit(x_all_sorted, y_all_sorted, model, 'StartPoint', initialGuess);
    hold on
    % Plot original data
    plot(x_all_sorted, y_all_sorted, 'Color', lineColor);
    % Plot the curve fit
    plot(x_all_sorted, fittedModel(x_all_sorted), 'Color', fitColor);

    % Get fit coefficients
    coeffs_output_gyro = coeffvalues(fittedModel);
    
    % Construct equation string for display on subplot
    eqn_str = sprintf('Fit Equation: y = %.2f*sin(%.2fx + %.2f) + %.2fx', coeffs_output_gyro(1), coeffs_output_gyro(2), coeffs_output_gyro(3), coeffs_output_gyro(4));

    % Display the equation as a title
    title({freqNames{i}, eqn_str}, 'Interpreter', 'none');
    xlabel('Time (s)');
    ylabel('Output Gyro');
    grid on;

    % Calculate the integral equation
    product_output_gyro = coeffs_output_gyro(1) * coeffs_output_gyro(2);
    product_output_gyro_values(i) = product_output_gyro;
    phases_output_gyro(i) = coeffs_output_gyro(3);
    integral_output_gyro_equation = sprintf('%.6f * sin(%.6f * t + %.6f) + %.6f', product_output_gyro, coeffs_output_gyro(2), coeffs_output_gyro(3), coeffs_output_gyro(4));
    
    fprintf('Integral of the curve fit equation for %s:\n', freqNames{i});
    fprintf('%s\n\n', integral_output_gyro_equation);

    hold off
    saveas(gcf, strcat('./Individual Curve Fit Plots/', freqNames{i}, '_output_gyro.png'))
end

