function action_q = action_value_mc(sample_num, sample_step, state_now, x_length, ...
    y_length, policy, action_now, action_space, final_state, obstacle_state, ...
    reward_forbidden, reward_target, reward_step, gamma)

action_q = 0;

for sample_temp = 1 : sample_num

    sample_reward = 0;
    for sample_step_temp = 1 : sample_step

        % Step 1.1 Choose an action
        if sample_step_temp == 1
            % If this is the first step, the action is already settled
            sample_action_temp = action_now;
            sample_state_now = state_now;
        else
            % If it is not the first step, there might be
            % multiple possible actions, we need to choose one
            sample_state_now = sample_state_next;
            state_index_temp = sample_state_now(1) + (sample_state_now(2) - 1) * x_length;
            sample_state_policy = policy(state_index_temp, :);
            sample_action_set = action_space{state_index_temp, :};
            sample_policy_index = find(sample_state_policy == max(sample_state_policy));

            if max(sample_state_policy) == 1
                % If there is only one possible action
                sample_action_temp = sample_action_set{:, sample_policy_index};
            else
                % If there are multiple possible actions, use
                % random seed to choose one
                rand_seed = length(sample_policy_index) * rand();
                sample_action_temp = sample_action_set{:, ceil(rand_seed)};
            end
        end

        % Step 1.2: Roll the dice with the current action
        [sample_state_next, sample_reward_now] = next_state_and_reward(sample_state_now, sample_action_temp, ...
            x_length, y_length, final_state, obstacle_state, reward_forbidden, reward_target, reward_step);

        sample_reward = sample_reward + sample_reward_now * gamma^(sample_step_temp - 1);
        
    end

    action_q = action_q + sample_reward/sample_temp;

end



end

