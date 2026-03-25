import torch
print(torch.cuda.is_available())

import numpy as np
import random

from agent_ddpg import AgentDDPG
import os
import time

import gymnasium as gym
env = gym.make(id = 'Pendulum-v1')
state_dim = env.observation_space.shape[0]  # 标量
action_dim = env.action_space.shape[0]  # 标量

agent = AgentDDPG(state_dim, action_dim)

num_episode = 1000
num_step = 100
epsilon_start = 1.0
epsilon_final = 0.01
epsilon_decay = 50000 #epsilon会在这些步长后衰减至epsilon_final

reward_buffer = np.empty(shape = num_episode)  # 创建未初始化数组

for episode_i in range(num_episode):
    state, others = env.reset()
    episode_reward = 0

    for step_i in range(num_step):

        epsilon = np.interp(x = episode_i * num_step + step_i, xp = [0, epsilon_decay], fp = [epsilon_start, epsilon_final])
        random_sample = random.random()

        if random_sample <= epsilon:
            # action = env.action_space.sample()
            action = np.random.uniform(low = -2, high = 2, size = action_dim)
        else:
            action = agent.get_action(state)

        next_state, reward, terminated, truncated, info = env.step(action)

        # 注意，这里没有将truncated的状态储存为数据
        agent.replay_buffer.add_memo(state, action, reward, next_state, terminated)

        state = next_state
        episode_reward += reward

        agent.update()

        if terminated:
            break

    reward_buffer[episode_i] = episode_reward

    print("Episode: {}, Reward: {}".format(episode_i+1, round(episode_reward, 2)) )

current_path = os.path.dirname(os.path.realpath(__file__))

model = current_path + '/models'
time_stamp = time.strftime("%Y%m%d-%H%M%S")

# 保存训练好了的Agent模型
torch.save(agent.actor.state_dict(), model + '/ddpg_actor_' + time_stamp + '.pth')
torch.save(agent.critic.state_dict(), model + '/ddpg_critic_' + time_stamp + '.pth')

env.close()




