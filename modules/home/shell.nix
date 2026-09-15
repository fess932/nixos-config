# Оболочка и всё вокруг неё: fish, bash, история, git.
{ pkgs, ... }:

{
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings.user = {
      name = "fess932";
      email = "fess932@gmail.com";
    };
  };

  # общая история между сессиями/машинами
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fish = {
    enable = true;

    shellAliases = {
      startn = "niri-session -l";
      vim = "nvim";
    };

    functions = {
      tl = {
        description = "tsh login на рабочий teleport-прокси";
        wraps = "tsh login";
        body = "tsh login --proxy tp-cloud.wb.ru --auth=passwordless $argv";
      };
    };

    # Выполняется только при логине на первой TTY — автостарт niri.
    # niri-session запускает niri.service в systemd --user: общая сессионная
    # шина с gnome-keyring и порталами, поднимается graphical-session.target,
    # логи в journalctl --user -u niri. Флаг -l обязателен: без него
    # niri-session перезапускает себя через `fish -l`, а тот снова попадает сюда.
    loginShellInit = ''
      if test -z "$WAYLAND_DISPLAY"; and test "$XDG_VTNR" -eq 1
          niri-session -l
      end
    '';

    interactiveShellInit = ''
      set fish_greeting ""
      if status --is-interactive; and type -q microfetch
        microfetch
      end

      function auto_source_uv --on-variable PWD
        if test -d .venv
            source .venv/bin/activate.fish
        else
          if set -q VIRTUAL_ENV
              deactivate
          end
        end
      end

      function fish_prompt
              # Хост (голубой)
              set_color '#5f87d7'
              echo -n (hostname)"@"

              # Пользователь (зелёный)
              set_color '#87d787'
              echo -n (whoami)

              # Текущая директория
              set_color '#afafff'
              echo -n "/"(prompt_pwd)" "

              # Разделитель (фиолетовый)
              set_color '#d7afd7'
              echo -n "❯ "

              # Сброс цвета
              set_color normal
          end
    '';
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      startn = "niri-session -l";
    };
    initExtra = ''
      export PS1="\[\e[38;5;75m\]\u@\h \[\e[38;5;113m\]\w \[\e[38;5;189m\]\$ \[\e[0m\]"
      if [ -z "''${WAYLAND_DISPLAY}" ] && [ "''${XDG_VTNR}" -eq 1 ]; then
        niri-session -l
      fi
    '';
  };

  home.packages = with pkgs; [
    ripgrep
    xq
  ];
}
