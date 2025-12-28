# CARGO
if [ -d $HOME/.cargo/bin ]; then
	export PATH="$PATH:$HOME/.cargo/bin"
fi

# BOB
if [ -f $HOME/.local/share/bob/env/env.sh ]; then
	. "/home/gigo/.local/share/bob/env/env.sh"
fi

# CUDA
if [ -d /usr/local/cuda ]; then
	export PATH=${PATH}:/usr/local/cuda/bin
	export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda/lib64
fi

# NVIDIA NSYS_EASY
if [ -d $HOME/.local/share/nsys_easy ]; then
	export PATH="$PATH:$HOME/.local/share/nsys_easy"
fi

# HOMEBREW
if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# NVM
if [ -d $HOME/.nvm ]; then
	export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
	export NODE_PATH=$(npm root -g)
fi
