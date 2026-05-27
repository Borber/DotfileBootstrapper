~/git
❯ paru -S --needed --noconfirm meson gcc just wayland wayland-protocols libglvnd freetype2 fontconfig cairo pango
  │ harfbuzz libxkbcommon glib2 sdbus-cpp libpipewire polkit pam curl libwebp librsvg ninja pkgconf jemalloc
[sudo] password for x:
warning: gcc-16.1.1+r12+g301eb08fa2c5-2 is up to date -- skipping
warning: wayland-1.25.0-1.1 is up to date -- skipping
warning: wayland-protocols-1.48-1 is up to date -- skipping
warning: libglvnd-1.7.0-3.1 is up to date -- skipping
warning: freetype2-2.14.3-1.2 is up to date -- skipping
warning: fontconfig-2:2.17.1-1.1 is up to date -- skipping
warning: cairo-1.18.4-1.1 is up to date -- skipping
warning: pango-1:1.57.1-1.1 is up to date -- skipping
resolving dependencies...
looking for conflicting packages...

Package (4)             New Version  Net Change  Download Size

cachyos-extra-v3/ninja  1.13.2-3.1     0.46 MiB       0.19 MiB
extra/python-tqdm       4.67.3-1       0.62 MiB       0.13 MiB
cachyos-extra-v3/just   1.51.0-1.1     4.39 MiB       1.51 MiB
extra/meson             1.11.1-3      16.42 MiB       2.46 MiB

Total Download Size:    4.28 MiB
Total Installed Size:  21.89 MiB

:: Proceed with installation? [Y/n]
:: Retrieving packages...
 python-tqdm-4.67.3-1-any                      130.5 KiB   652 KiB/s 00:00 [------------------------------------------] 100%
 ninja-1.13.2-3.1-x86_64_v3                    192.7 KiB   786 KiB/s 00:00 [------------------------------------------] 100%
 meson-1.11.1-3-any                              2.5 MiB  5.04 MiB/s 00:00 [------------------------------------------] 100%
 just-1.51.0-1.1-x86_64_v3                    1543.3 KiB  2.82 MiB/s 00:01 [------------------------------------------] 100%
 Total (4/4)                                     4.3 MiB  7.35 MiB/s 00:01 [------------------------------------------] 100%
(4/4) checking keys in keyring                                             [------------------------------------------] 100%
(4/4) checking package integrity                                           [------------------------------------------] 100%
(4/4) loading package files                                                [------------------------------------------] 100%
(4/4) checking for file conflicts                                          [------------------------------------------] 100%
:: Running pre-transaction hooks...
(1/2) Performing snapper pre snapshots for the following configurations...
==> root: 217
(2/2) Waiting for limine-snapper-sync to finish...
:: Processing package changes...
(1/4) installing ninja                                                     [------------------------------------------] 100%
(2/4) installing python-tqdm                                               [------------------------------------------] 100%
Optional dependencies for python-tqdm
    python-requests: telegram
(3/4) installing meson                                                     [------------------------------------------] 100%
(4/4) installing just                                                      [------------------------------------------] 100%
:: Running post-transaction hooks...
(1/2) Arming ConditionNeedsUpdate...
(2/2) Performing snapper post snapshots for the following configurations...
==> root: 218
fish: Unknown command: │
fish:
│ harfbuzz libxkbcommon glib2 sdbus-cpp libpipewire polkit pam curl libwebp librsvg ninja pkgconf jemalloc
^

~/git took 7s
❯ paru -S --needed --noconfirm meson gcc just wayland wayland-protocols libglvnd freetype2 fontconfig cairo pango harfbuzz libxkbcommon glib2 sdbus-cpp libpipewire polkit pam curl libwebp librsvg ninja pkgconf jemalloc
warning: meson-1.11.1-3 is up to date -- skipping
warning: gcc-16.1.1+r12+g301eb08fa2c5-2 is up to date -- skipping
warning: just-1.51.0-1.1 is up to date -- skipping
warning: wayland-1.25.0-1.1 is up to date -- skipping
warning: wayland-protocols-1.48-1 is up to date -- skipping
warning: libglvnd-1.7.0-3.1 is up to date -- skipping
warning: freetype2-2.14.3-1.2 is up to date -- skipping
warning: fontconfig-2:2.17.1-1.1 is up to date -- skipping
warning: cairo-1.18.4-1.1 is up to date -- skipping
warning: pango-1:1.57.1-1.1 is up to date -- skipping
warning: harfbuzz-14.2.0-1.1 is up to date -- skipping
warning: libxkbcommon-1.13.1-1.1 is up to date -- skipping
warning: glib2-2.88.1-1.1 is up to date -- skipping
warning: sdbus-cpp-2.3.1-1.1 is up to date -- skipping
warning: libpipewire-1:1.6.6-1.1 is up to date -- skipping
warning: polkit-127-3.1 is up to date -- skipping
warning: pam-1.7.2-2.1 is up to date -- skipping
warning: curl-8.20.0-7.1 is up to date -- skipping
warning: libwebp-1.6.0-2.1 is up to date -- skipping
warning: librsvg-2:2.62.2-1.1 is up to date -- skipping
warning: ninja-1.13.2-3.1 is up to date -- skipping
warning: pkgconf-2.5.1-1.1 is up to date -- skipping
warning: jemalloc-1:5.3.1-2.1 is up to date -- skipping
 there is nothing to do

~/git
❯
