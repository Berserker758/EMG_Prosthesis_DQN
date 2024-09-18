function plotAgents(agents_directory, episodes, step)

iterations = fix(episodes / step);
fig = figure('Visible', 'off');
hold on;

text_positions = zeros(iterations, 2);

for i = 1:iterations
    agent_file = strcat(agents_directory, "\Agent", num2str(step * i), ".mat"); 
    agent = load(agent_file);  
    agent_result = agent.savedAgentResult.AverageReward;
    if i == 1
        init = 1;
    else 
        init = step * (i - 1) + 1;
    end
    agent_result = agent_result(init:end);
    x = 1:length(agent_result);
    plot(x, agent_result(), 'DisplayName', sprintf('Agent %d', step * i));

    text_positions(i, :) = [step * i, agent_result(end)];
end

xlabel('Episode');  
ylabel('Average Reward'); 
title('Average Reward per Episode');
legend('Location', 'northeastoutside'); 

for i = 1:iterations
    reward_text = sprintf('Agent %d: %.2f', step * i, text_positions(i, 2));
    text(1.05, 0.5 - (i * 0.1), reward_text, 'Units', 'normalized', ...
        'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');
end

grid on; 
hold off;

filename = strcat(agents_directory, '\agents.png');
saveas(fig, filename);  
close(fig);
