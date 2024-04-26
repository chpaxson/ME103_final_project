% Get a list of all frequency folders within 'data_cleaned'
freqFolders = dir('./data_cleaned');
isub = [freqFolders(:).isdir];
freqNames = {freqFolders(isub).name}';
freqNames = freqNames(~ismember(freqNames, {'.', '..', '.ipynb_checkpoints'}));
figure;

% Calculate the number of subplot rows and columns based on the number of folders
number_folders = length(freqNames);
number_columns = ceil(sqrt(number_folders));
number_rows = ceil(number_folders / number_columns);

% Loop through each frequency folder
for i = 1:number_folders
    FolderName = ['../data_cleaned/', freqNames{i}];
    subplot(number_rows, number_columns, i);
    hold on;
    
    % Loop through each trial
    for j = 0:4
        trial_Name = fullfile(FolderName, ['trial', num2str(j), '.csv']);
        if isfile(trialFileName)
            data = readtable(trialFileName);
            
          
            if i == 6 || i > 7
                t = data{6:end, 'time'};
                output_encoder = data{6:end, 'output_encoder'};
            else
                t = data{:, 'time'};
                output_encoder = data{:, 'output_encoder'};
            end
            
            if length(t) == length(output_encoder)
                plot(t, output_encoder);
            else
                disp(['Skipping plot for ', trialFileName, ' due to mismatched data lengths.']);
            end
        end
    end
    
    % Labeling the plot
    title(freqNames{i}, 'Interpreter', 'none');
    xlabel('Time (s)');
    ylabel('Output Encoder');
    grid on;
    hold off;
end

% Adjust the layout and size of the figure window if necessary
set(gcf, 'Position', get(0, 'Screensize'));
