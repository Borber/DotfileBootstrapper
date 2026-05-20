Daemon mode (recommended). Example Hyprland setup:
  1. Run: wayscriber --daemon
     Optional: wayscriber --daemon --freeze-on-show
  2. Add to Hyprland config:
     exec-once = wayscriber --daemon
     bind = SUPER, D, exec, wayscriber --daemon-toggle
     bind = SUPER SHIFT, D, exec, wayscriber --daemon-toggle --freeze
     bind = SUPER ALT, L, exec, wayscriber --light-toggle
     bind = SUPER ALT, D, exec, wayscriber --light-draw-toggle
     bind = SUPER ALT, F, exec, wayscriber --light-draw-on
     bindr = SUPER ALT, F, exec, wayscriber --light-draw-off
  3. Press your bound shortcut (e.g. Super+D) to toggle overlay on/off

Requirements:
  - Wayland compositor (Hyprland, Sway, etc.)
  - wlr-layer-shell protocol support
