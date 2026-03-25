import torch
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(device)

import gymnasium as gym
import numpy as np
env = gym.make(id = 'Pendulum-v1', render_mode = 'rgb_array')

state_dim = env.observation_space.shape[0]
action_dim = env.action_space.shape[0]

import os
current_path = os.path.dirname(os.path.realpath(__file__))
model = current_path + '/models'
actor_path = model + '/ddpg_actor_20260320-175820.pth'

from agent_ddpg import Actor
actor = Actor(state_dim, action_dim).to(device)
actor.load_state_dict(torch.load(actor_path))

# import pygame
#
# pygame.init()
# width, height = 800, 600
# screen = pygame.display.set_mode((width, height))
# clock = pygame.time.Clock()

# def process_frame(frame):
#     frame = np.transpose(frame, [1, 0, 2])
#     frame = pygame.surfarray.make_surface(frame)
#     return pygame.transform.rotate(frame, 180)

num_episode = 500
num_step = 1000

for episode_i in range(num_episode):
    state, others = env.reset()
    episode_reward = 0

    for step_i in range(num_step):
        action = actor(torch.tensor(state).unsqueeze(0).to(device)).detach().cpu().numpy()[0]
        next_state, reward, terminated, truncated, _ = env.step(action)
        state = next_state
        episode_reward += reward

        print(f"step: {step_i}, reward: {episode_reward}, truncated: {truncated}")

        # frame = env.render()
        # frame = process_frame(frame)
        # screen.blit(frame, (0, 0))
        # pygame.display.flip()
        # clock.tick(10)

    print(f"Episode: {episode_i}, Reward: {episode_reward}")

# pygame.quit()
env.close()


