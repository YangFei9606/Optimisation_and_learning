import gymnasium as gym
import sys
import numpy as np
import torch
import torch.nn as nn

env = gym.make(id = 'Pendulum-v1')

# print(env.observation_space)
# print(env.action_space)
#
# print(env.observation_space.shape)
# print(env.action_space.shape)

state, others = env.reset()
print(state)
print(sys.getsizeof(state))
print(torch.FloatTensor(state).shape)
print(torch.FloatTensor(state).unsqueeze(0).shape)





# a = [1,2,3]
# print(np.array(a).shape)
# print(torch.FloatTensor(a).unsqueeze(1).shape)

