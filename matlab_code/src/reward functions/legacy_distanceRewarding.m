function [reward, rewardVector, action] = legacy_distanceRewarding(this, action)

    persistent previousPosFlex

    % Initialize persistent variable if it's empty
    if isempty(previousPosFlex)
        previousPosFlex = zeros(size(action));
    end

    % Reward configuration
    opts.k = 2; % Scaling factor for distance penalty
    rewards = struct(...
        'dirInverse', -10, ... % Penalty for moving in the opposite direction
        'wrongStop', -5, ...  % Penalty for stopping inappropriately
        'goodMove', 10, ...    % Reward for correct movement
        'goodMove2', 5, ...   % Reward for appropriate stopping
        'inactivityPenalty', -2, ... % Penalty for inactivity
        'moveIncentive', 3 ... % Incentive for any movement
    );

    % Initialize reward vector
    rewardVector = zeros(1, length(action));

    % Retrieve and process current position data
    if this.c == 1
        flexConv = this.flexJoined_scaler(reduceFlexDimension(this.flexData));
    else
        flexConv = this.flexConvertedLog{this.c - 1};
    end
    pos = this.motorData(end, :);
    posFlex = this.flexJoined_scaler(encoder2Flex(pos));


    % Calculate rewards based on actions
    for i = 1:length(action)
        % Determine the correct action based on position change
        if previousPosFlex(i) < posFlex(i)
            correctAction = 1; % Forward movement
        elseif previousPosFlex(i) > posFlex(i)
            correctAction = -1; % Backward movement
        else
            correctAction = 0; % No movement
        end
        
        % Assign rewards based on action correctness
        if action(i) == correctAction
            if action(i) ~= 0
                rewardVector(i) = rewards.goodMove;
            else
                rewardVector(i) = rewards.goodMove2;
            end
        else
            if action(i) == 0
                rewardVector(i) = rewards.wrongStop;
            else
                rewardVector(i) = rewards.dirInverse;
            end
        end
    end

    % Update previous position
    previousPosFlex = posFlex;

    % Add movement incentive if any action is taken
    if any(action ~= 0)
        rewardVector = rewardVector + rewards.moveIncentive;
    end

    % Apply distance-based penalty
    distance = abs(posFlex - flexConv(end, :));
    penaltyDistance = distance * opts.k;
    rewardVector = rewardVector - penaltyDistance;

    % Calculate average reward
    reward = mean(rewardVector);

end
