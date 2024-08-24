function [v_pi_now, v_pi_all] = state_value_cal(state_space, number_of_run, error_thres, action_space, ...
    x_length, y_length, policy, final_state, obstacle_state, reward_forbidden, reward_target, reward_step, gamma)

%% Calculate the current state values

% Calculate immediate reward for all states
v_pi_now = zeros(state_space, 1);
v_pi_next = v_pi_now;
v_pi_all = zeros(state_space, number_of_run);
v_pi_all(:, 1) = v_pi_now;

for recur_step = 1 : number_of_run

    v_pi_all(:,recur_step) = v_pi_now;

    for state_temp = 1 : state_space
        action_state = action_space{state_temp, :};
        state_now = [state_temp - (ceil(state_temp/x_length) - 1) * x_length, ceil(state_temp/x_length)];

        for act_temp = 1 : length(action_state)
            % Traverse all the actions
            action_now = action_state{:, act_temp};

            [state_next, reward_now] = next_state_and_reward(state_now, action_now, ...
                x_length, y_length, final_state, obstacle_state, reward_forbidden, reward_target, reward_step);

            v_pi_next(state_temp) = policy(state_temp, act_temp) * (reward_now + ...
                gamma * v_pi_now(x_length * (state_next(2)-1) + state_next(1))) + v_pi_next(state_temp);
        end

    end

    if norm(v_pi_next - v_pi_now) <= error_thres
        break;
    end

    v_pi_now = v_pi_next;
    v_pi_next = zeros(state_space, 1);

end


end

