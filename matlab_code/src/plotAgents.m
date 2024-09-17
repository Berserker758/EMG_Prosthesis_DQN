function plotAgents(agents_directory, episodes, step)

iterations = fix(episodes/step);
fig = figure('Visible', 'off');
hold on;

for i=1:iterations
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
    plot(x, agent_result(), 'DisplayName', sprintf('Agente %d', step * i));
end

xlabel('Episodio');  
ylabel('Recompensa Promedio'); 
title('Recompensa Promedio por Episodio');
legend; 
grid on; 
hold off;

filename = strcat(agents_directory, '\agentes.png');
saveas(fig, filename);  
close(fig);