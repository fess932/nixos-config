default: rebuild
rebuild:
	git add .
	nixos-rebuild switch --sudo --flake ~/nixos-config#nixos

update:
	git add .
	nix flake update
	nixos-rebuild switch --sudo --upgrade --flake /home/fess932/nixos-config#nixos --show-trace --verbose

config-not-nix:
	./link_config.sh
