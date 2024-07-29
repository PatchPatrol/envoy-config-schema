# makefiles/zsh.mk

.PHONY: devshell-zsh zsh-install zsh-configure zsh-plugins zsh-theme zsh-utils

devshell-zsh: zsh-install zsh-configure zsh-plugins zsh-theme zsh-utils
	@echo "Zsh environment setup complete. Run 'zsh' to start using it or restart your shell."

zsh-install:
	@echo "Installing Zsh and dependencies..."
	@sudo dnf install -y zsh git curl

zsh-configure:
	@echo "Configuring Zsh..."
	@sh -c "$$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
	@echo 'export PATH=$$PATH:$$HOME/.local/bin' >> $$HOME/.zshrc

zsh-plugins:
	@echo "Installing Zsh plugins..."
	@git clone https://github.com/zsh-users/zsh-autosuggestions $${ZSH_CUSTOM:-$$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	@git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $${ZSH_CUSTOM:-$$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
	@echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> $$HOME/.zshrc

zsh-theme:
	@echo "Setting up Powerlevel10k theme..."
	@git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $${ZSH_CUSTOM:-$$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
	@echo 'source $${ZSH_CUSTOM:-$$HOME/.oh-my-zsh/custom}/themes/powerlevel10k/powerlevel10k.zsh-theme' >> $$HOME/.zshrc
	@echo '[[ ! -f $$HOME/.p10k.zsh ]] || source $$HOME/.p10k.zsh' >> $$HOME/.zshrc

zsh-utils:
	@echo "Installing and configuring additional utilities..."
	@curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
	@echo "source $$(zoxide init zsh)" >> $$HOME/.zshrc
	@curl -o $$HOME/.dir_colors https://raw.githubusercontent.com/seebi/dircolors-solarized/master/dircolors.ansi-dark
	@echo 'eval $$(dircolors $$HOME/.dir_colors)' >> $$HOME/.zshrc

.PHONY: zsh-help
zsh-help:
	@echo "Zsh module commands:"
	@echo "  devshell-zsh  - Set up a full Zsh environment"
	@echo "  zsh-install   - Install Zsh and dependencies"
	@echo "  zsh-configure - Configure Zsh basics"
	@echo "  zsh-plugins   - Install Zsh plugins"
	@echo "  zsh-theme     - Set up Powerlevel10k theme"
	@echo "  zsh-utils     - Install and configure additional utilities"