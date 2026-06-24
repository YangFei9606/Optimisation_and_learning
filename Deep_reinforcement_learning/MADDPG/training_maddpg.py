from mpe2._mpe_utils.core import Agent
# 对于多智能体学习框架，需要安装pettingzoo中的MPE组件
# 这里需要注意的是，运行之后一般会有一些warning，意思为开发者正在尝试将MPE独立为MPE2这个模块，但是当前实际上还没有开始执行，可以忽略对应的warnings

from pettingzoo.mpe import simple_adversary_v3

import numpy as np
import torch
import torch.nn as nn
import os
import time

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print("Current device:", device)

def multi_obs_to_state(multi_obs):
    state = np.array([])
    obs = torch.from_numpy(obs).float().to(device)

# 1. 初始化所有的智能体
env = simple_adversary_v3.parallel_env(N=2, max_cycles=100, continuous_actions = True)
multi_obs, _ = env.reset()
num_agent = env.num_agents
agent_name_list = env.agents

# 1.1 获得状态观测信息（这里不能用传统的env.observation_space.shape）
obs_dim = []
for agent_obs in multi_obs.values():
    obs_dim.append(agent_obs.shape[0])
state_dim = sum(obs_dim)

# 1.2 获取动作空间信息
action_dim = []
for agent_name in agent_name_list:
    action_dim.append(env.action_space(agent_name).sample().shape[0])

# 1.3 逐步定义各个agent
agents = []
for agent_i in range(num_agent):
    agent = Agent(state_dim, action_dim, device=device)  # TODO
    agents.append(agent)

# 2. Main training loop
episode_num = 10000
step_num = 200
epsilon_start = 1.0
epsilon_final = 0.05
epsilon_decay_step = episode_num * step_num * 0.6

reward_all = []

for episode_i in range(episode_num):

    multi_obs, _ = env.reset()
    episode_reward = 0
    multi_done = {agent_name: False for agent_name in agent_name_list}

    for step_i in range(step_num):

        multi_actions = {}

        # 2.1 先根据当前各agent的策略获得所有agent目前的动作
        for agent_i, agent_name in enumerate(agent_name_list): # 在遍历列表时，成对返回元素的索引值与其自身值
            # 从装有agent的列表中找到我们所说的对应的agent对象
            agent = agents[agent_i]
            # 从获得的系统整体状态观测获得对应agent的观测
            single_obs = multi_obs[agent_name]
            # 利用对应agent的观测求出当前的最佳策略
            single_action = agent.get_action(single_obs)
            # 将agent的动作收入整体动作合集（以字典形式存储）
            multi_actions[agent_name] = single_action

        # 2.2 执行动作
        multi_next_obs, rewards, multi_done, multi_truncations, _ = env.step(multi_actions)
        state = multi_obs_to_state(multi_obs)
        next_state = multi_obs_to_state(multi_next_obs)







    reward_all.append(episode_reward)

# 3. 更新环境


# 4. 保存环境


# observations, infos = env.reset()
#
# while env.agents:
#
#     actions = {agent: env.action_space(agent).sample() for agent in env.agents }
#
#     observations, rewards, terminations, truncations, _ = env.step(actions)


env.close()

