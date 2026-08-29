HOST  ?= nixos
FLAKE ?= $(HOME)/nixos-config

default: switch

# Nix видит только файлы, которые отслеживает git. Новый .nix без `git add`
# для флейка просто не существует — поэтому add идёт перед каждой сборкой.
stage:
	@git add -A

## применить конфиг
switch: stage
	nixos-rebuild switch --sudo --flake $(FLAKE)\#$(HOST)

## собрать, но не применять — безопасная проверка перед switch
build: stage
	nixos-rebuild build --flake $(FLAKE)\#$(HOST)

## что изменится по сравнению с текущей системой
diff: build
	nix store diff-closures /run/current-system ./result

## применить на следующую загрузку (для смены ядра/драйверов)
boot: stage
	nixos-rebuild boot --sudo --flake $(FLAKE)\#$(HOST)

## обновить все инпуты и применить
update: stage
	nix flake update
	@git add -A
	nixos-rebuild switch --sudo --flake $(FLAKE)\#$(HOST)

## обновить один инпут: make update-input INPUT=claude-code
update-input: stage
	nix flake update $(INPUT)
	@git add -A

## откатиться на предыдущее поколение
rollback:
	sudo nixos-rebuild switch --rollback

## отформатировать все .nix
fmt:
	nixfmt $$(git ls-files '*.nix')

## проверить форматирование, ничего не меняя
fmt-check:
	nixfmt --check $$(git ls-files '*.nix')

## почистить старые поколения
gc:
	sudo nix-collect-garbage --delete-older-than 7d
	nix-collect-garbage --delete-older-than 7d

## список поколений системы
generations:
	nixos-rebuild list-generations

help:
	@grep -B1 -E '^[a-z-]+:' Makefile | grep -A1 '^##' | sed 's/^## /  /;s/:.*//' | paste - - | column -t

.PHONY: default stage switch build diff boot update update-input rollback fmt fmt-check gc generations help
