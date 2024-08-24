
clear
close all

%% Initialize environment parameters
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
reward_forbidden = -1;
reward_target = 1;
reward_step = 0;

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

[v_pi_now, train_reu] = state_value_cal(state_space, recursive_step, 10^-5, action_space, ...
    x_length, y_length, policy, final_state, obstacle_state, reward_forbidden, reward_target, reward_step, gamma);

v_pi_all = zeros(state_space, recursive_step);

%% Start training
for step = 1 : episode_length

    v_pi_all(:, step) = v_pi_now;
    % Step 1: Policy update
    policy_new = policy;

    for state_temp = 1 : state_space
        action_state = action_space{state_temp, :};
        state_now = [state_temp - (ceil(state_temp/x_length) - 1) * x_length, ceil(state_temp/x_length)];

        for act_temp = 1 : length(action_state)

            action_now = action_state{:, act_temp};
            [state_next, reward_now] = next_state_and_reward(state_now, action_now, ...
                x_length, y_length, final_state, obstacle_state, reward_forbidden, reward_target, reward_step);

            reward_temp = reward_now + gamma * v_pi_now(state_next(1) + (state_next(2) - 1) * x_length );

            if act_temp == 1
                opt_act = 1;
                opt_reward = reward_temp;
            else
                if reward_temp > opt_reward
                    opt_act = act_temp;
                    opt_reward = reward_temp;
                elseif reward_temp == opt_reward
                    opt_act = [opt_act, act_temp];
                end
            end

        end

        % Store the new policy
        policy_new(state_temp,:) = 0;
        for j = 1 : length(opt_act)
            policy_new(state_temp, opt_act(j)) = 1/length(opt_act);
        end

    end

    % Step 2: Update state value
    v_pi_tem = state_value_cal(state_space, recursive_step, 10^-5, action_space, ...
        x_length, y_length, policy_new, final_state, obstacle_state, reward_forbidden, reward_target, reward_step, gamma);

    v_pi_now = v_pi_tem;

    % If the difference is small enough, stop the process
    if step > 1
        policy_diff = policy - policy_new;
        value_diff = v_pi_all(:, step) - v_pi_all(:, step-1);

        if norm(policy_diff) + norm(value_diff) < 10^-3
            break;
        end

    end

    policy = policy_new;
end

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

figure_plot(x_length, y_length, agent_state, final_state, obstacle_state, v_pi_now, state, step_num, state_history, policy, actions);


%%
