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
      startn = "dbus-run-session niri &> ~/niri.log";
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
    loginShellInit = ''
      if test -z "$WAYLAND_DISPLAY"; and test "$XDG_VTNR" -eq 1
          dbus-run-session niri &> ~/niri.log
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
      startn = "dbus-run-session niri &> ~/niri.log";
    };
    initExtra = ''
      export PS1="\[\e[38;5;75m\]\u@\h \[\e[38;5;113m\]\w \[\e[38;5;189m\]\$ \[\e[0m\]"
      if [ -z "''${WAYLAND_DISPLAY}" ] && [ "''${XDG_VTNR}" -eq 1 ]; then
        dbus-run-session niri &> ~/niri.log
      fi
    '';
  };

  home.packages = with pkgs; [
    ripgrep
    xq
  ];
}
