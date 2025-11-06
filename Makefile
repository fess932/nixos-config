rebuild:
	git add .
	sudo nixos-rebuild switch --flake ~/nixos-config#nixos
