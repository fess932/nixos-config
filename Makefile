default: rebuild
rebuild:
	git add .
	nixos-rebuild switch --sudo --flake ~/nixos-config#nixos

update:
	git add .
	nixos-rebuild switch --sudo --upgrade --flake ~/nixos-config#nixos

config-not-nix:
	./link_config.sh
