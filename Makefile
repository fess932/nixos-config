default: rebuild
rebuild:
	git add .
	sudo nixos-rebuild switch --flake ~/nixos-config#nixos

update:
	git add .
	sudo nix flake update