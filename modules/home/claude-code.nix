# Claude Code.
#
# Пакет приходит из flake-инпута `claude-code` (github:sadjow/claude-code-nix)
# через оверлей в flake.nix — он обновляется заметно быстрее, чем nixpkgs.
# Обвязку (settings.json, свои агенты/команды/скиллы) описывает нативный
# модуль home-manager, поэтому папка ~/.claude остаётся живой и записываемой:
# HM владеет только теми файлами, которые перечислены ниже.
{ ... }:

{
  programs.claude-code = {
    enable = true;

    # ~/.claude/settings.json. Пока пусто — HM файл не создаёт вовсе
    # и не мешает Claude Code писать туда самому.
    # Как только что-то тут появится, файл станет read-only симлинком в store.
    settings = {
      # includeCoAuthoredBy = false;
      # permissions.allow = [ "Bash(git diff:*)" ];
    };

    # Общий CLAUDE.md на все проекты: строка или путь до файла.
    # context = ./claude/CLAUDE.md;

    # Свои команды/агенты/скиллы — файлами в репе:
    # commands.review = ./claude/commands/review.md;
    # agents.golang = ./claude/agents/golang.md;
  };
}
