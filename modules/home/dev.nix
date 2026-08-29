# Редакторы, тулчейны, dev-CLI.
{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    withPython3 = true;
    defaultEditor = true;
    # Конфиг лежит не здесь, а в ./config/nvim и подключается модулем dotfiles.
    sideloadInitLua = true;
    extraPackages = with pkgs; [
      yaml-language-server
      bash-language-server
      lua-language-server
      pyright
      vim-language-server
      ruff
    ];
  };

  programs.vscode.enable = true;
  programs.go.enable = true;
  programs.bun.enable = true;

  home.packages = with pkgs; [
    # nix-тулинг
    nil
    nixd
    nixfmt

    # общие тулчейны
    nodejs
    gcc

    # go-обвязка
    go-task
    air
    dbmate
    sqlc

    zed-editor
    teleport

    (jetbrains.goland.override {
      vmopts = ''
        -Xms128m
        -Xmx1024m
        -XX:ReservedCodeCacheSize=512m
        -XX:+IgnoreUnrecognizedVMOptions
        -XX:+UseG1GC
        -XX:SoftRefLRUPolicyMSPerMB=50
        -XX:CICompilerCount=2
        -XX:+HeapDumpOnOutOfMemoryError
        -XX:-OmitStackTraceInFastThrow
        -ea
        -Dsun.io.useCanonCaches=false
        -Djdk.http.auth.tunneling.disabledSchemes=""
        -Djdk.attach.allowAttachSelf=true
        -Djdk.module.illegalAccess.silent=true
        -Dkotlinx.coroutines.debug=off
        -XX:ErrorFile=$HOME/java_error_in_idea_%p.log
        -XX:HeapDumpPath=$HOME/java_error_in_idea.hprof
        -Dawt.toolkit.name=WLToolkit
        -Dide.browser.jcef.enabled=false
      '';
    })
  ];
}
