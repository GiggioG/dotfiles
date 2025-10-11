# CARGO
export PATH="$PATH:$HOME/.cargo/bin"

# BOB
. "/home/gigo/.local/share/bob/env/env.sh"

# CUDA
export PATH=${PATH}:/usr/local/cuda-13.0/bin
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda-13.0/lib64

# NVIDIA NSYS_EASY
export PATH="$PATH:$HOME/.local/share/nsys_easy"

# HOMEBREW
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export NODE_PATH=$(npm root -g)
