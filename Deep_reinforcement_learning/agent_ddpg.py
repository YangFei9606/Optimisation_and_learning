from collections import deque

import torch
import torch.nn as nn
import torch.optim as optim
import numpy as np

import random

# 设置计算的设备
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print("Device type: ", device)

##### 超参数
lr_actor = 1e-4
lr_critic = 1e-3
gamma = 0.99
memory_size = 100000
batch_size = 64
tau = 5e-3

class Actor(nn.Module):
    def __init__(self, state_dim, action_dim):
        # 子类与父类之间的问题
        super(Actor, self).__init__()
        self.fc1 = nn.Linear(state_dim, 128)
        self.fc2 = nn.Linear(128, 128)
        self.fc3 = nn.Linear(128, action_dim)

    def forward(self, state):
        x_1 = torch.relu(self.fc1(state))
        x_2 = torch.relu(self.fc2(x_1))
        x_3 = torch.tanh(self.fc3(x_2)) * 2
        return x_3

class Critic(nn.Module):
    def __init__(self, state_dim, action_dim, output_dim = 1):
        super(Critic, self).__init__()
        self.fc1 = nn.Linear(state_dim + action_dim, 128)
        self.fc2 = nn.Linear(128, 128)
        self.fc3 = nn.Linear(128, output_dim)

    def forward(self, state, action):
        # torch.cat 用来拼接张量, dim=0时为沿着行拼接（也就是拼接后列数不变），dim=1时为沿着列拼接
        x = torch.cat([state, action], 1)
        x_1 = torch.relu(self.fc1(x))
        x_2 = torch.relu(self.fc2(x_1))
        x_3 = self.fc3(x_2)
        return x_3

class ReplayMemory(object):
    def __init__(self, capacity: int):
        self.buffer = deque(maxlen=capacity)

    def add_memo(self, state, action, reward, next_state, terminated):
        # 将状态尺寸扩充至张量
        state = np.expand_dims(state, 0)
        next_state = np.expand_dims(next_state, 0)
        self.buffer.append((state, action, reward, next_state, terminated))

    def sample(self, sample_size):
        state, action, reward, next_state, terminated = zip(*random.sample(self.buffer, sample_size))
        return np.concatenate(state), action, reward, np.concatenate(next_state), terminated


    def __len__(self):
        return len(self.buffer)


class AgentDDPG(object):
    def __init__(self, state_dim, action_dim):
        self.actor = Actor(state_dim, action_dim).to(device)
        self.actor_target = Actor(state_dim, action_dim).to(device)
        self.actor_target.load_state_dict(self.actor.state_dict())
        self.actor_optimizer = optim.Adam(self.actor.parameters(), lr=lr_actor)

        self.critic = Critic(state_dim, action_dim).to(device)
        self.critic_target = Critic(state_dim, action_dim).to(device)
        self.critic_target.load_state_dict(self.critic.state_dict())
        self.critic_optimizer = optim.Adam(self.critic.parameters(), lr=lr_critic)

        self.replay_buffer = ReplayMemory(memory_size)

    def get_action(self, state):
        # 将 NumPy 数组 state 转换为 PyTorch 的张量（Tensor），下面语句可以让张量与数组公用一块内存，从而节省数据

        state = torch.FloatTensor(state).unsqueeze(0).to(device)

        # state = torch.from_numpy(state).float().to(device)
        action = self.actor(state)

        # 输出时，还是将数据格式转回数组
        return action.detach().cpu().numpy()[0]

    def update(self):

        # 首先，获取训练所需的mini batch
        if len(self.replay_buffer) < batch_size:
            # 如果长度不够就先不更新
            return

        states, actions, rewards, next_states, terminals = self.replay_buffer.sample(batch_size)

        states = torch.FloatTensor(states).to(device)
        actions = torch.FloatTensor(np.vstack(actions)).to(device)
        rewards = torch.FloatTensor(rewards).unsqueeze(1).to(device)
        next_states = torch.FloatTensor(next_states).to(device)
        terminals = torch.FloatTensor(terminals).unsqueeze(1).to(device)

        # 更新Critic网络
        # 1 预测下一步的动作
        next_actions = self.actor_target(next_states)
        # 2 用Target网络计算下一时刻的动作价值
        target_q = self.critic_target(next_states, next_actions.detach())  # 使用detach函数标明对应向量不再需要梯度计算
        # 3 计算TD target
        td_target = rewards + gamma * target_q * (1 - terminals)
        # 4 计算当前动作价值
        current_q = self.critic(states, actions)
        # 5 TD error 计算
        critic_loss = nn.MSELoss()(current_q, td_target)
        # 6 基于loss进行Critic网络更新
        self.critic_optimizer.zero_grad()  #先把上一步的梯度清理掉
        critic_loss.backward()  # 计算Critic网络基于loss的梯度
        self.critic_optimizer.step() # 更新Critic网络的参数
        # 7 更新Actor网络
        actor_loss = -self.critic(states, self.actor(states)).mean()    ## ?????????
        self.actor_optimizer.zero_grad()
        actor_loss.backward()
        self.actor_optimizer.step()
        # 8 更新两个Target网络，因为有很多层的参数，所以用了
        for target_param, param, in zip(self.critic_target.parameters(), self.critic.parameters()):
            target_param.data.copy_(tau * param.data + (1 - tau) * target_param.data)

        for target_param, param, in zip(self.actor_target.parameters(), self.actor.parameters()):
            target_param.data.copy_(tau * param.data + (1 - tau) * target_param.data)










