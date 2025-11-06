{ host, ...}:
{

  wayland.windowManager.hyprland = 
{
  enable = true;
  settings = {
    general = {
      "$modifier" = "SUPER";
    }; 

    exec-once = [
      "waybar"
      "rofy"
    ]; 

    bind = [
       "$modifier,Return,exec,wezterm"
       "$modifier,K,exec,list-keybinds"
       "$modifier,Space,exec,rofi -show drun"
    ]; 

  }; 

};
}
