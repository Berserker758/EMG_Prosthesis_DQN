function plot_episode(this)
    % plot_episode() plots at the end of the episode.
    % This function graphs the glove signals and the position of the motors,
    % with their respective actions and rewards.

    %% Check if plotting should occur
    if this.episodeCounter > 0 
        % Path to store the graphics
        saveDir = '.\graficos2\test1';
        if ~exist(saveDir, 'dir')
            mkdir(saveDir);
        end
        
        f = figure('Visible', 'off');
        set(f, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

        % Get the necessary variables
        aux_1 = this.encoderAdjustedLog(1:this.c);
        aux_2 = this.flexConvertedLog(1:this.c);
        aux_actions = this.actionLog(1:this.c, :);
        aux_actions2 = this.actionSatLog(1:this.c, :);
        aux_rewards_individual = this.rewardIndividualLog(1:this.c, :);

        prosthesis_position = cat(1, aux_1{:});
        glove_position = cat(1, aux_2{:});

        % Interpolation of the prosthesis position signal to match the glove position size
        n_glove = size(glove_position, 1);
        n_prosthesis = size(prosthesis_position, 1);

        if n_prosthesis ~= n_glove
            x_prosthesis = linspace(1, n_glove, n_prosthesis);
            x_glove = 1:n_glove;
            prosthesis_position_interp = interp1(x_prosthesis, prosthesis_position, x_glove);
        else
            prosthesis_position_interp = prosthesis_position;
        end

        % Scaling stock indices to match interpolated indices
        action_indices = linspace(1, n_glove, size(aux_actions, 1));
        
        % Determine global axis limits
        all_positions = [prosthesis_position_interp; glove_position];
        global_xlim = [1, n_glove];
        global_ylim = [min(all_positions(:)), max(all_positions(:))];

        for i = 1:4
            % Create the first subplot
            ax1 = subplot(4, 2, 2*i-1, 'Parent', f);
            cla(ax1);
            hold(ax1, 'on');

            % Plot prosthesis and glove data with names for the legend
            h1 = plot(ax1, prosthesis_position_interp(:, i), '-', 'Color', 'b', 'DisplayName', 'Prosthesis');
            h2 = plot(ax1, glove_position(:, i), 'Color', [1 0.5 0], 'DisplayName', 'Glove');

            % Plot action points
            for j = 1:length(action_indices)
                action_value = aux_actions(j, i);
                if ~isnan(action_value)
                    plot(ax1, action_indices(j), prosthesis_position_interp(round(action_indices(j)), i), 'r.'); % Red points for actions
                    text(ax1, action_indices(j), prosthesis_position_interp(round(action_indices(j)), i), sprintf('%d', action_value), ...
                        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 11);
                end
            end

            % Add legend and set axis limits to the first subplot
            legend(ax1, [h1, h2], 'Location', 'best');
            xlim(ax1, global_xlim);
            ylim(ax1, global_ylim);

            % Create the second subplot
            ax2 = subplot(4, 2, 2*i, 'Parent', f);
            cla(ax2);
            hold(ax2, 'on');

            % Plot prosthesis and glove data with names for the legend
            h3 = plot(ax2, prosthesis_position_interp(:, i), '-', 'Color', 'b', 'DisplayName', 'Prosthesis');
            h4 = plot(ax2, glove_position(:, i), 'Color', [1 0.5 0], 'DisplayName', 'Glove');

            % Plot action points and rewards
            for j = 1:length(action_indices)
                action_sat_value = aux_actions2(j, i);
                if ~isnan(action_sat_value)
                    plot(ax2, action_indices(j), prosthesis_position_interp(round(action_indices(j)), i), 'rx', 'MarkerSize', 6); % Red x for saturated actions
                    text(ax2, action_indices(j), prosthesis_position_interp(round(action_indices(j)), i), sprintf('%d', action_sat_value), ...
                        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'Color', 'black', 'FontSize', 11);
                end
                reward_value = aux_rewards_individual{j}(i);
                if ~isnan(reward_value)
                    text(ax2, action_indices(j), prosthesis_position_interp(round(action_indices(j)), i), sprintf('%.2f', reward_value), ...
                        'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'Color', 'black', 'FontSize', 6);
                end
            end

            % Add legend and set axis limits to the second subplot
            legend(ax2, [h3, h4], 'Location', 'best');
            xlim(ax2, global_xlim);
            ylim(ax2, global_ylim);

            % Additional subplot formatting
            if i == 1
                title(ax1, sprintf('Episode %d', this.episodeCounter - 1));
                title(ax2, sprintf('Episode %d', this.episodeCounter - 1));
            elseif i == 4
                xlabel(ax1, 'Step in episode');
                xlabel(ax2, 'Step in episode');
            end
        end
        drawnow
        
        % Save the figure
        filename = fullfile(saveDir, sprintf('episode_%d.png', this.episodeCounter - 1));
        saveas(f, filename);
        fprintf('Saved %s\n', filename);
        close(f);
    end
end
