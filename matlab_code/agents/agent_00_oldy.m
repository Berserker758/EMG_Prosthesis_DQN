function agent = agent_00_oldy(observationInfo, actionInfo)
%agent_00_oldy() creates the agent trained in prosthesis v1.
%
%

%{
Laboratorio de Inteligencia y Visión Artificial
ESCUELA POLITÉCNICA NACIONAL
Quito - Ecuador

autor: Jonathan Zea
jonathan.a.zea@ieee.org

"I find that I don't understand things unless I try to program them."
-Donald E. Knuth

03 January 2024
%}


%%
%numHiddenUnits = 14;
hL = @reluLayer;

%% newtork
criticNetwork = [
    featureInputLayer(44, "Name", "observation")
    fullyConnectedLayer(64, "Name", "fc_1")
    hL("Name", "hL1")
    fullyConnectedLayer(128, "Name", "fc_2")
    hL("Name", "hL2")
    fullyConnectedLayer(64, "Name", "fc_3")
    hL("Name", "hL3")
    fullyConnectedLayer(81, "Name", "output")];



opt = rlRepresentationOptions( ...
    'LearnRate', 1e-4, ... % default 0.01
    'L2RegularizationFactor', 1e-4... % default 1e-4
    , 'Optimizer', 'sgdm' ... % default adam
    ,'UseDevice','cpu');

% for adam
% opt.OptimizerParameters.GradientDecayFactor = 0.99; % Default 0.9
% for sgdm
opt.OptimizerParameters.Momentum = 0.95; % default 0.9

critic = rlQValueRepresentation(criticNetwork, observationInfo, ...
    actionInfo, 'Observation', {'observation'}, opt);

%% agent options  DQN
% agentOptions = rlDQNAgentOptions(...
%     'UseDoubleDQN', true, ... % default
%     'SequenceLength', 1, ... % default, Maximum batch-training trajectory length when using a recurrent neural network for the critic, specified as a positive integer. This value must be greater than 1 when using a recurrent neural network for the critic and 1 otherwise.
%     'TargetSmoothFactor',1e-4, ... % Smoothing factor for target critic updates, specified as a positive scalar less than or equal to 1.
%     'TargetUpdateFrequency', 4, ... %def
%     'ResetExperienceBufferBeforeTraining', false,...
%     'SaveExperienceBufferWithAgent', true, ... % not default
%     'MiniBatchSize', 64, ...% updated from 32 to 64
%     'NumStepsToLookAhead', 1, ...
%     'ExperienceBufferLength', 5000, ... % default
%     'DiscountFactor', 0.99);% default
% 
% agentOptions.EpsilonGreedyExploration.EpsilonDecay = 1e-4;
% agentOptions.EpsilonGreedyExploration.Epsilon = 1; % default
% agentOptions.EpsilonGreedyExploration.EpsilonMin = 0.1; % default
% 
% agent = rlDQNAgent(critic, agentOptions);
%% Exploration strategy
exploration = rl.option.EpsilonGreedyExploration(...
    'Epsilon', 1, ...
    'EpsilonDecay', 1e-4, ...
    'EpsilonMin', 0.1);

%% SARSA Agent options
agentOptions = rlSARSAAgentOptions(...
    'EpsilonGreedyExploration', exploration, ...
    'DiscountFactor', 0.9);

%% Create the SARSA agent
agent = rlSARSAAgent(critic, agentOptions);
