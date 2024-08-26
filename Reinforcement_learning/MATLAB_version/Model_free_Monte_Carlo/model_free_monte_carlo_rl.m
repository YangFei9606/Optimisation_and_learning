
clear
close all

%% Initialize environment parameters
% agent_state = [1, 1];
% final_state = [6, 6];
% obstacle_state = [1, 2; 2, 2; 3, 2; 2, 4; 3, 4; 4, 4; 5, 4];
% x_length = 6;
% y_length = 6;
% gamma = 0.8;

%%
agent_state = [1, 1];
final_state = [3, 3];
obstacle_state = [1, 3; 2, 1; 1, 2];
x_length = 3;
y_length = 4;
gamma = 0.8;

%% Vector-shape state space
state_space = x_length * y_length;
state=1:state_space;
state_value=ones(state_space,1);

%% Reward set-up
reward_forbidden = -10;
reward_target = 100;
reward_step = -1;

%% Define actions: up, right, down, left, stay
number_of_action=5;
actions = {[0, -1], [1, 0], [0, 1], [-1, 0], [0, 0]};

%% Initialize a cell array to store the action space for each state
action_space = cell(state_space, 1);

% Populate the action space
for i = 1:state_space
    action_space{i} = actions;
end

policy=zeros(state_space, number_of_action); % policy can be deterministic or stochastic, shown as follows:

%% Initialize the policy with random numbers
for i=1:state_space
    policy(i,:)=.2;
end

% Initialize the episode
episode_length = 1000;

state_history = zeros(episode_length, 2);
reward_history = zeros(episode_length, 1);

% Set the initial state
state_history(1, :) = agent_state;

policy_update_threshold = 10^-5;
current_policy_diff = 10^5;
recursive_step = 100;

v_pi_all = zeros(state_space, recursive_step);

sample_num = 40;
sample_step = 40;

%% Start training
for epoch = 1 : episode_length
    
    fprintf("Running Epoch "+num2str(epoch)+"\n");
    % Use the latest policy
    policy_new = policy;

    % Check all possible states
    for state_temp = 1 : state_space
        action_state = action_space{state_temp, :};
        state_now = [state_temp - (ceil(state_temp/x_length) - 1) * x_length, ceil(state_temp/x_length)];
        action_q_value = zeros(length(action_state), 1);

        % Check all possible actions for the current state
        for act_temp = 1 : length(action_state)
            action_now = action_state{:, act_temp};
            action_q_value(act_temp) = action_value_mc(sample_num, sample_step, state_now, ...
                x_length, y_length, policy_new, action_now, action_space, final_state, obstacle_state, ...
                reward_forbidden, reward_target, reward_step, gamma);
        end

        % Find the index for optimal actions
        optimal_action_index = find(action_q_value == max(action_q_value));

        % Update the policy
        policy_new(state_temp,:) = 0;
        for j = 1 : length(optimal_action_index)
            policy_new(state_temp, optimal_action_index(j)) = 1/length(optimal_action_index);
        end

        % Update the state values
        v_pi_all(state_temp, epoch) = policy_new(state_temp,:) * action_q_value;

    end


    % If the difference is small enough, stop the process
    if epoch > 1
        policy_diff = policy - policy_new;
        value_diff = v_pi_all(:, epoch) - v_pi_all(:, epoch-1);

        if norm(policy_diff) + norm(value_diff) < 10^-3
            break;
        end

    end

    policy = policy_new;
end

%%

step_num = 0;

state_history = [agent_state];

while step_num <= 100

    state_index = agent_state(1) + (agent_state(2) - 1) * x_length;
    policy_state = policy(state_index,:);
    action_state = action_space{state_index, :};

    for policy_index = 1 : length(policy_state)
        if policy_index == 1
            action_now = action_state{:, policy_index};
            action_prob = policy_state(policy_index);
        elseif policy_state(policy_index) > action_prob
            action_now = action_state{:, policy_index};
            action_prob = policy_state(policy_index);
        end
    end
    
    [state_next, reward_now] = next_state_and_reward(agent_state, action_now, ...
                x_length, y_length, final_state, obstacle_state, reward_forbidden, reward_target, reward_step);

    state_history = [state_history; state_next];
    agent_state = state_next;

    step_num = step_num + 1;

    if norm(agent_state - final_state) == 0
        break;
    end

end


%%

figure_plot(x_length, y_length, agent_state, final_state, obstacle_state, v_pi_all(:, epoch), state, step_num, state_history, policy, actions);


%%
