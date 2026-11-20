# Ly Display Manager Migration Plan

## Purpose

This document records the intended migration path for using Ly as the display
manager in this dotfiles bootstrapper.

The bootstrapper should keep the same boundary as the rest of the project:
`bootstrap` only orchestrates items, and the Ly-specific system changes should
live in a dedicated `items/ly/item.conf`.

## Scope

The `ly` item manages:

- Ly dependency checks and installation hints.
- Systemd service enablement for Ly.
- Safe migration away from the current display manager.
- Ly configuration file installation from `items/ly/src/config.ini`.

The `ly` item does not manage:

- Hyprland configuration. That belongs to `items/hypr`.
- Display manager logic in the top-level `bootstrap` script.

## Current Local State

Observed on 2026-05-14:

- `ly` is not installed.
- `sddm` is installed.
- `/etc/systemd/system/display-manager.service` points to
  `/usr/lib/systemd/system/sddm.service`.
- `/etc/systemd/system/multi-user.target.wants/ly@tty2.service` exists as a
  symlink, but `/usr/lib/systemd/system/ly@.service` does not exist. Treat this
  as stale service state until the `ly` package is installed.
- Hyprland session files already exist:
  - `/usr/share/wayland-sessions/hyprland.desktop`
  - `/usr/share/wayland-sessions/hyprland-uwsm.desktop`

## Target State

The desired final state is:

- `ly` package is installed.
- `ly-dm` exists in `PATH`.
- `/usr/lib/systemd/system/ly@.service` exists.
- `ly@tty2.service` is enabled.
- `getty@tty2.service` is disabled.
- The previous display manager, currently SDDM, is disabled after Ly has been
  manually verified.
- Hyprland is launched through the existing Wayland session desktop file.

Use `tty2` as the default Ly TTY unless there is a clear machine-specific
reason to choose another TTY.

## Manual Migration Flow

### 1. Preflight

Check the current service and session state:

```bash
pacman -Q ly sddm
command -v ly-dm
systemctl is-enabled display-manager.service
systemctl is-enabled sddm.service
systemctl is-enabled ly@tty2.service
systemctl is-enabled getty@tty2.service
ls /usr/share/wayland-sessions
```

Expected before migration on the current machine:

- `ly` is missing.
- `sddm` is installed.
- Hyprland session files are present.

### 2. Install Ly

On Arch Linux:

```bash
sudo pacman -S --needed ly
```

After installation, verify:

```bash
command -v ly-dm
test -f /usr/lib/systemd/system/ly@.service
```

### 3. Enable Ly Without Removing SDDM Yet

Enable Ly on `tty2` and disable the normal getty on the same TTY:

```bash
sudo systemctl disable getty@tty2.service
sudo systemctl enable ly@tty2.service
```

At this stage, keep SDDM enabled. This gives us a recovery path while Ly is
being tested.

### 4. Verify Ly Login

Reboot or switch TTYs and test Ly:

```bash
sudo reboot
```

After reboot:

- Use `Ctrl+Alt+F2` if Ly is not the visible TTY.
- Log in through Ly.
- Select a Hyprland session if Ly presents a session selector.
- Confirm Hyprland starts correctly.

### 5. Disable SDDM After Verification

Only after Ly login works:

```bash
sudo systemctl disable sddm.service
sudo systemctl disable display-manager.service
```

Then reboot again and confirm Ly is the intended login path.

## GNOME Keyring for Noctalia Clipboard History

On CachyOS, Ly ships PAM hooks for GNOME Keyring in `/etc/pam.d/ly`. With
password login, PAM can create and unlock the `Login` keyring using the system
login password. Noctalia uses the default keyring to store the key for its
encrypted clipboard history.

1. Install GNOME Keyring before setting up Noctalia's clipboard storage.

   ```bash
   sudo pacman -S --needed gnome-keyring
   ```

2. Sign out and sign back in through Ly with your system password. For a new
   setup, do this before clicking **Retry** in Noctalia's clipboard settings.
3. Confirm that the default collection is `/org/freedesktop/secrets/collection/login`
   and that its `Locked` property is `false`.

   ```bash
   busctl --user --auto-start=no call org.freedesktop.secrets \
     /org/freedesktop/secrets org.freedesktop.Secret.Service ReadAlias s default
   busctl --user --auto-start=no get-property org.freedesktop.secrets \
     /org/freedesktop/secrets/collection/login org.freedesktop.Secret.Collection Locked
   ```

4. After a reboot, verify that Ly logs `gkr-pam: unlocked login keyring` and
   that Noctalia loads the existing encrypted clipboard history.

   ```bash
   journalctl -b --no-pager -g 'gkr-pam: unlocked login keyring'
   journalctl --user -b -u noctalia.service --no-pager -g 'loaded encrypted clipboard history'
   ```

If Noctalia first starts encrypted storage in an existing session before PAM
initializes `Login`, a separate default keyring can be created. To keep the
existing clipboard history, copy and verify the `Noctalia encrypted storage key`
entry in `Login` before setting `Login` as the default. Keep keyring files and
clipboard history on the local machine.

Verified on CachyOS on 2026-11-21 with Ly 1.4.1 and GNOME Keyring 51.1. After a
reboot, Ly unlocked `Login` without a keyring prompt, and Noctalia loaded the
saved encrypted clipboard history.

## Item Design

Implemented path:

```text
items/ly/
|-- item.conf
`-- src/
    |-- black-hole.dur
    `-- config.ini
```

### `check_dep()`

Should return `0` only when all required dependencies are present:

- `systemctl`
- `ly-dm`
- `/usr/lib/systemd/system/ly@.service`
- at least one usable session file, preferably:
  - `/usr/share/wayland-sessions/hyprland.desktop`
  - or `/usr/share/wayland-sessions/hyprland-uwsm.desktop`

### `install_dep()`

On Arch Linux, run:

```bash
run sudo pacman -S --needed --noconfirm ly
```

For unsupported package managers, print a clear manual installation message and
return failure.

### `check()`

Should represent the intended final item state.

Minimum checks:

- `ly@tty2.service` is enabled.
- `getty@tty2.service` is disabled.
- `ly-dm` exists.
- `/usr/lib/systemd/system/ly@.service` exists.
- `/etc/ly/black-hole.dur` matches `items/ly/src/black-hole.dur`.
- `/etc/ly/config.ini` matches `items/ly/src/config.ini`.

Optional final-state checks:

- `sddm.service` is disabled when SDDM is installed.
- `display-manager.service` is disabled or not present.

### `install()`

Must explicitly handle dry-run because it will call `systemctl` and may copy
files:

```bash
if [[ "${dry_run:-0}" == 1 ]]; then
  echo "Would install items/ly/src/black-hole.dur to /etc/ly/black-hole.dur"
  echo "Would install items/ly/src/config.ini to /etc/ly/config.ini"
  echo "Would disable getty@tty2.service"
  echo "Would enable ly@tty2.service"
  echo "Would leave the current display manager enabled until Ly is verified"
  return 0
fi
```

The implementation is conservative by default:

```bash
run sudo systemctl disable getty@tty2.service
run sudo systemctl enable ly@tty2.service
```

Do not automatically disable SDDM unless the explicit item variable is set:

```bash
LY_DISABLE_EXISTING_DM=1
```

This avoids locking the user out if Ly has not been tested yet.

### `uninstall()`

Should disable Ly:

```bash
run sudo systemctl disable ly@tty2.service
```

It should not automatically re-enable SDDM. Restoring another display manager is
a machine-level policy decision and should be explicit.

## Ly Config Handling

The item installs these managed files:

```text
items/ly/src/black-hole.dur -> /etc/ly/black-hole.dur
items/ly/src/config.ini -> /etc/ly/config.ini
```

Before replacing an existing regular file, back it up to a `.bak` path such as:

```text
/etc/ly/config.ini.bak
```

This repository is allowed to carry the user's Ly config. The current config
uses a bundled `.dur` animation:

```ini
animation = dur_file
dur_file_path = /etc/ly/black-hole.dur
blank_box = true
lang = en
```

Keep `lang = en` for Ly on the kernel TTY. The TTY usually does not have a CJK
font, so `lang = zh_CN` can make the login UI unreadable.

## Recovery Commands

If Ly does not work and SDDM is still installed:

```bash
sudo systemctl disable ly@tty2.service
sudo systemctl enable getty@tty2.service
sudo systemctl enable sddm.service
sudo systemctl enable display-manager.service
sudo reboot
```

If graphical login is unavailable, switch to another TTY with `Ctrl+Alt+F3` or
`Ctrl+Alt+F4`, log in, and run the recovery commands from the shell.

## References

- Arch Linux package files for `ly`:
  <https://archlinux.org/packages/extra/x86_64/ly/files/>
- Ly upstream repository:
  <https://github.com/fairyglade/ly>
