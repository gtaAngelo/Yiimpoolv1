# Changelog

All notable changes to YiimPool are documented here.

---

## [v2.7.1] — 2026-03-14

### Bug Fixes

- **`yiimp_upgrade/utils/functions.sh` — wrong GCC version in `upgrade_stratum()`** — Compiler was being set to `gcc-9` / `g++-9` before the stratum build. Changed to `gcc-10` / `g++-10` to match the version required by the current yiimp stratum source.
- **`yiimp_upgrade/utils/functions.sh` — wrong stratum build order in `upgrade_stratum()`** — `secp256k1` was compiled before `algos`, `sha3`, and `iniparser`. Corrected build order: `algos` → `sha3` → `iniparser` → `secp256k1` → `make buildonly`, matching the order required by the updated yiimp stratum Makefile.
- **`yiimp_upgrade/utils/functions.sh` — wrong final make target in `upgrade_stratum()`** — Final stratum build used `make -j$(nproc+1)` instead of `make buildonly`. Fixed.
- **`yiimp_upgrade/utils/functions.sh` — `-j$(nproc+1)` removed from sub-library builds** — `make -C algos`, `make -C sha3`, and `make -C iniparser` were all using parallel job flags incompatible with the updated stratum Makefiles. Changed to plain `make -C <dir>`.
- **`yiimp_upgrade/utils/update_stratum_conf.sh` — `log_message: command not found`** — Script is called via `bash` subshell which does not inherit the parent shell's functions. `log_message` is defined only in `upgrade/utils/functions.sh`, not in `/etc/functions.sh`. Fixed by defining `log_message` locally inside the script.

### New Features

- **`yiimp_upgrade/utils/update_stratum_conf.sh`** — New standalone script that applies pool credentials to every `*.conf` file in the live stratum config directory (`$STORAGE_ROOT/yiimp/site/stratum/config`). Applies the same six `sed` substitutions as `yiimp_single/stratum.sh`: blocknotify password, stratum server URL, database host (WireGuard-aware), database name, database username, and database password. Includes guards for missing config directory and zero conf files. Restores `www-data` ownership and `750` permissions after patching. Called automatically by `upgrade_stratum()` after every backup restore.

### Improvements

- **`upgrade_stratum()` — G++ now explicitly set** — `update-alternatives --set g++` is now called alongside `gcc` at both the pre-build and post-build steps to ensure the compiler pair is always consistent.
- **`upgrade_stratum()` — config credential update integrated** — After restoring the stratum config backup, `upgrade_stratum()` now automatically calls `update_stratum_conf.sh` to re-apply pool credentials. A fallback message is shown if no backup is found (fresh `config.sample` scenario) before credentials are applied.

---

## [v2.6.8] — 2026-03-13

### Bug Fixes

- **`yiimp_single/remote_system_stratum_server.sh`** — Fixed single-quoted `'$STORAGE_ROOT/yiimp/'` in `-e` test (always evaluated to false); directory check now uses double quotes so the variable expands correctly.
- **`yiimp_single/remote_stratum.sh`** — Fixed missing `install` subcommand in `apt-get -y libmysqlclient-dev` (package was silently never installed).
- **`yiimp_upgrade/up_web.sh`** — Fixed single-quoted `'$STORAGE_ROOT/...'` preventing variable expansion in `-e` test, and fixed inverted `!` condition that removed the directory only when it didn't exist.

### Improvements

- **`mysql` → `mariadb`** — Replaced all `sudo mysql` calls with `sudo mariadb` across `yiimp_single/db.sh`, `install/add_stratum_db.sh`, `yiimp_upgrade/db.sh`, and `yiimp_upgrade/health_check.sh` to eliminate the deprecation warning on MariaDB 11.x.
- **`chmod 777` → `chmod 755`** — Replaced all 114 world-writable `chmod 777` calls in `daemon_builder/utils/source.sh` and `daemon_builder/utils/upgrade.sh` (build temp dirs); removes unnecessary write permission for group/other.
- **`tempfile` → `mktemp`** — Replaced all 10 `TMP=$(tempfile)` calls in `daemon_builder/utils/upgrade.sh`; `tempfile` was removed in Ubuntu 22.04+.
- **Shebang fixes** — Corrected `#!/bin/env bash` → `#!/usr/bin/env bash` in 25 scripts across `daemon_builder/`, `install/`, `yiimp_single/`, and `yiimp_upgrade/`.
- **`apt_install` removal** — Removed the `apt_install` wrapper from `install/functions.sh` and replaced all usages with `hide_output sudo apt install -y` across 10 scripts.
- **Add-stratum workflow** — Quoted unquoted `$STORAGE_ROOT` / `$HOME` / `$DEFAULT_*` variables throughout `install/questions_add_stratum.sh`, `add_stratum_db.sh`, `setsid_stratum_server.sh`, `start_add_stratum.sh`; replaced all backtick subshells with `$()`; simplified redundant if/else copy to a single `sudo cp`.
- **`yiimp_single/stratum.sh` + `remote_stratum.sh`** — Quoted all `$STORAGE_ROOT` paths in `tee`, `chmod`, `cd`, and `setfacl` calls; fixed unquoted sources.
- **`yiimp_single/create_user_remote.sh`** — Replaced backtick `whoami` with `$()`; fixed deprecated `$[...]` arithmetic to `$((...))`.
- **`daemon_builder/utils/addport.sh` + `addport_stratum_server.sh`** — Fixed unquoted `$tempfile` in `trap`; replaced backtick `cat $tempfile` and `base64` calls with `$()`.
- **`yiimp_single/db.sh`** — Fixed debconf pre-seed package name typo (`maria-db-11.8` → `mariadb-server-11.8`); replaced fragile config append with `printf ... | sudo tee -a`; added source guards.
- **`yiimp_single/yiimp_confs/yiimpserverconfig.sh`** — Rewrote to eliminate duplicate heredoc blocks; added source guards; resolved DB/stratum values per wireguard mode before a single `tee` heredoc.
- **Version** — Bumped `TAG` to `v2.6.8` in `ver.sh`, `install.sh`, and `yiimp_single/create_user_remote.sh`.

---

## [v2.6.3] — 2026-03-07

### Bug Fixes

- **`install/add_stratum_db.sh`** — Fixed critical bug where `${PanelUserDBPassword}` (the panel user's password) was incorrectly written to the stratum database credentials file instead of `${StratumUserDBPassword}`. This prevented the remote stratum server from authenticating to the database.
- **`install/questions_add_stratum.sh`** — Fixed three bare shell commands (`user hit ESC/cancel`) that were missing the `#` comment prefix, causing bash to attempt to execute `user` as a binary on every ESC/cancel path.
- **`install/questions_add_stratum.sh`** — Fixed weak default stratum password (`'password'` literal) replaced with a cryptographically random value generated by `openssl rand`.
- **`install/options.sh`** — Fixed "Add New Stratum Server" option that showed "not yet available" despite a complete implementation flow existing. The option now correctly calls `start_add_stratum.sh`.
- **`daemon_builder/utils/dbtoolmenu.sh`** — Fixed `show_menu` call in the `*` wildcard case that referenced an undefined function, causing an error on invalid input. Changed to `exit 0`.
- **`daemon_builder/utils/menu3.sh`** — Fixed undefined variable `${daemonname}` used in a dialog menu item. Replaced with the hardcoded string `daemonbuilder`.
- **`daemon_builder/utils/menu1.sh`** — Fixed unquoted `9 exit` dialog item that rendered as lowercase "exit" with no description. Changed to `9 "Exit DaemonBuilder"`.
- **`yiimp_single/menu.sh`** — Fixed undefined `$VERSION` variable in menu title by adding the missing `source /etc/yiimpoolversion.conf`.
- **`yiimp_single/create_user_remote.sh`** — Fixed outdated version tag `v2.5.1` updated to `v2.6.3`.
- **`yiimp_single/create_user_remote.sh`** — Fixed memory check inconsistency: the hard-exit threshold checked for less than 2 GB but the warning message said "less than 4 GB". Thresholds are now consistent.

### Improvements

#### Implement Add New Stratum Server

- **`install/start_add_stratum.sh`** — Added proper script header (author, date). Added `source /etc/yiimpoolversion.conf`. Replaced plain `echo` success message with `print_success` / `print_info`.
- **`install/questions_add_stratum.sh`** — Fixed "Wireguard" → "WireGuard" casing. Replaced hardcoded `/home/crypto-data/...` path with `$STORAGE_ROOT` variable. Standardized paste instructions across all input boxes. Fixed typo "randonly" → "randomly". Fixed misleading comment about which config file is being sourced. Changed `DEFAULT_blckntifypass` from the literal string `blocknotifypassword` to an empty string, prompting the user to enter the actual value.
- **`install/add_stratum_db.sh`** — Complete rewrite: added script header. Replaced all raw `echo` calls with `print_status`, `print_success`, and `print_info`. Fixed misleading completion message that said `.my.cnf` when the actual file is `.my.$generate.cnf`.
- **`install/setsid_stratum_server.sh`** — Complete rewrite: added script header. Removed dead `yiimpoolversionconf` variable (defined but never used). Removed six debug `echo` lines that printed SSH credentials (`NewStratumUser`, `NewStratumPass`) in plaintext to the terminal. Added `print_status` messages before each SSH copy and execute operation. Added `print_success` / `print_info` completion summary.
- **`yiimp_single/create_user_remote.sh`** — Updated OS support message to correctly list Ubuntu 20.04. Replaced raw colored `echo` calls with proper `print_*` functions. Improved user-facing memory warning messages for clarity.
- **`yiimp_single/remote_stratum.sh`** — Major update to bring compilation steps to parity with the primary `stratum.sh`. Added GCC 9/10 installation and `update-alternatives` setup, `apt_dist_upgrade`, `software-properties-common`, DISTRO-aware PPA handling, multi-line secp256k1 build sequence, WireGuard status messages, installation summary, and final GCC version reset. Replaced all raw `echo` calls with `print_*` functions.
- **`yiimp_single/remote_system_stratum_server.sh`** — Replaced all raw `echo -e "$COLOR ..."` calls with `print_header`, `print_status`, `print_success`, and `print_info`. Removed redundant `echo` spacing. Added missing completion message at end of script.

#### Menu System

- **`install/menu.sh`** — Updated date to 2026-03-06. Changed section header style to `═══` divider lines. Renamed "Options" → "Manage & Upgrade Options". Fixed "Yiimp" → "YiiMP" casing throughout.
- **`install/options.sh`** — Updated title to "YiimPool Options $VERSION". Renamed item 2 "Add Stratum" → "Add New Stratum Server". Fixed exit message. Removed "Not completed yet, sorry." placeholder messages.
- **`daemon_builder/utils/menu.sh`** — Updated date. Added `═══` section separator. Updated item description for "Update Coin Daemon From Source Code".
- **`daemon_builder/utils/menu1.sh`** — Fixed `BULD.sh` → `BUILD.sh` typo in item labels. Added colored exit handler.
- **`daemon_builder/utils/menu2.sh`** — Fixed `BULD.sh` → `BUILD.sh` typo. Added section separators and colored exit handler.
- **`daemon_builder/utils/menu3.sh`** — Fixed `Scrypt` → `Script` typo. Improved grammar in item descriptions.
- **`yiimp_single/menu.sh`** — Added `source /etc/yiimpoolversion.conf`. Changed Yes/No dialog labels to descriptive text. Added `═══` section separator. Updated date.
- **`yiimp_upgrade/dbtoolmenu.sh`** — Removed premature `print_status` call before dialog display. Added `$VERSION` to menu title. Reduced dialog dimensions for better fit. Fixed broken `show_menu` call in `*` wildcard case.

#### Questions / Input Dialogs

- **`yiimp_single/questions.sh`** — Fixed "Yiimpool" → "YiimPool" in message box titles. Changed "subdomain names" → "subdomains". Fixed "Using Sub-Domain" → "Using Subdomain". Fixed duplicate word "from from" in Public IP input box. Changed "for YiiMP panel" → "for the YiiMP panel". Improved blocknotify password description to clearly explain its purpose. Cleaned up trailing spaces on blank continuation lines.
- **`install/questions_add_stratum.sh`** — See Add New Stratum Server section above.

#### Daemon Builder — `source.sh` Overhaul

- **`daemon_builder/utils/source.sh`** — Replaced all uses of the deprecated `tempfile` command (removed in debianutils 4.9 / Ubuntu 22.04+) with `mktemp`. Affected the algorithm-selection dialog, which would silently fail on modern systems.
- **`daemon_builder/utils/source.sh`** — Added `PIPESTATUS` checks after every critical piped compile step: `./autogen.sh | ./configure` (step 5.3), `make` via `makefile.unix` (step 6.2), four separate CMake build steps, and the `makefile.unix` fallback. Previously a failed compile would not stop the build.
- **`daemon_builder/utils/source.sh`** — Removed a dead duplicate summary block that printed stale, hardcoded values instead of the real build results.
- **`daemon_builder/utils/source.sh`** — Fixed `print_divider` called without required argument, causing a blank/broken divider line in output.
- **`daemon_builder/utils/source.sh`** — Fixed stray unquoted `$` character that caused a syntax warning.
- **`daemon_builder/utils/source.sh`** — Fixed wrong step labels that displayed out-of-order step numbers in status output.
- **`daemon_builder/utils/source.sh`** — Fixed `COINUTILFIND` typo (was `COINUTILFND`) and removed a duplicate assignment of the same variable.
- **`daemon_builder/utils/source.sh`** — Added `@reboot` crontab entry for the coin daemon inside the `YIIMPCONF == "true"` block. Previously the daemon was started once at end of script but never registered to restart on reboot. Entry includes a 30-second boot delay, deduplication of existing entries, and redirects output to `/var/log/<coin>-daemon-boot.log`.
- **`daemon_builder/utils/source.sh`** — Updated the final summary section to display autostart status and boot log path when stratum was configured.

#### Daemon Builder — Stratum Autostart Fixes

- **`daemon_builder/utils/addport.sh`** — Replaced deprecated `tempfile` with `mktemp` in the algorithm-selection dialog.
- **`daemon_builder/utils/addport.sh`** — Fixed the `@reboot` crontab entry: added deduplication (`grep -v` before inserting), changed from bare `bash stratum.X` to full path `/usr/bin/stratum.X`, increased boot delay from 10 s to 30 s, and redirected output to `/var/log/stratum-<coin>-boot.log`. Without a full path, `@reboot` entries silently fail because `PATH` is not set at boot time.
- **`daemon_builder/utils/addport.sh`** — Fixed immediate stratum launch at end of script: changed bare `bash stratum.X` to `/usr/bin/stratum.X` for consistency.
- **`daemon_builder/utils/addport_stratum_server.sh`** — Applied identical `tempfile → mktemp`, crontab, and stratum launch path fixes as `addport.sh`. Fixed two separate occurrences of the bare `bash stratum.` call (local branch and remote-server branch).

#### `install/create_user.sh` — SSH Key Login Overhaul

- **Bug fix** — `chmod 644` on `authorized_keys` changed to `chmod 600`. OpenSSH's `StrictModes yes` (the default) refuses to use key files with group/world read permission, causing every key-based login attempt to fall through to password prompting.
- **Bug fix** — Operation order corrected: `authorized_keys` is now written first, then `chown`/`chmod` applied to the final content. Previously permissions were set before the key was written, creating a race window.
- **Bug fix** — Added `chmod 755 /home/${yiimpadmin}` before `.ssh` creation. `StrictModes` also rejects group/world-writable home directories.
- **Bug fix** — Added full `sshd_config` configuration for key-only authentication. The root cause of "still prompts for password after reboot": sshd was never told to disable `KbdInteractiveAuthentication` or `PasswordAuthentication`. On modern systems (Ubuntu 20.04+), a drop-in file `/etc/ssh/sshd_config.d/10-yiimpool.conf` is written with `PubkeyAuthentication yes`, `KbdInteractiveAuthentication no`, `ChallengeResponseAuthentication no`, and `PasswordAuthentication no`. The cloud-init override file `50-cloud-init.conf` is patched if present to prevent it overriding `PasswordAuthentication`.
- **Bug fix** — Added `_sshd_set` helper function for older systems (no `sshd_config.d`). The previous four bare `sed -i 's/^#*DIRECTIVE.*/...'` calls silently did nothing when a directive was absent from `sshd_config` (e.g. Ubuntu 16.04/18.04 using compiled-in defaults). `_sshd_set` checks with `grep -qE` first and appends the directive via `tee -a` if not found.
- **Bug fix** — Added `systemctl restart ssh` (with fallbacks to `sshd` and `service ssh`) so the new sshd config takes effect without a reboot. Previously the settings were never applied until the next system restart.
- **Bug fix** — Removed dead broken `passwd` call in the SSH key path. `$RootPassword` was never set (the `openssl rand` line was commented out), so two empty strings were piped to `passwd`, potentially setting a blank password. The account correctly uses `--disabled-password` for SSH key-only login.
- **Bug fix** — Fixed `sudo rm -r $HOME/yiimpool` (wrong directory name) to `sudo rm -r "$HOME/Yiimpoolv1"`. The SSH path copied `~/Yiimpoolv1` to the new user's home then attempted to delete `~/yiimpool`, leaving the original root copy behind.
- **Bug fix** — Fixed broken `passwd` quoting in the password path: `echo -e ""${RootPassword}"\n"${RootPassword}""` word-splits on passwords containing spaces. Replaced with `printf '%s\n%s\n' "${RootPassword}" "${RootPassword}" | passwd`.
- **Bug fix** — Fixed `yiimpool.conf` being written with 4-space leading indentation on all lines (except the first) due to the heredoc being indented inside a `case` block. Replaced with an unindented `tee` heredoc producing a clean conf file.
- **Improvement** — `yiimpool` command script now includes a proper `#!/usr/bin/env bash` shebang and is written without spurious leading whitespace.
- **Improvement** — Sudoers entry rewritten with `printf` — removes leading-space formatting artifacts from the previous heredoc-in-`echo` approach.
- **Improvement** — SSH path setup summary now displays `PRIVATE_IP` (previously omitted; password path already showed it).
- **Typo fixes** — `Creaete` → `Create`, `continu` → `continue` (×2), `Unfortunatley` → `Unfortunately`, `"your new  username"` double-space removed.
- **Code quality** — All unquoted `${DEFAULT_*}` variables and path strings throughout the file now properly quoted. `bash $(basename $0)` → `bash "$(basename "$0")"`. Stray `$RED` before `$NC` with no text between them removed.

#### `yiimp_upgrade/health_check.sh` — Overhaul

- **Bug fix** — `check_cpu`: replaced fragile `top -bn1 | grep "Cpu(s)" | awk '{print $8}'` (field position not stable across distros/locales) with `awk -F',' '{... if($i ~ /id/) ...}'` which identifies the idle field by its label. Added a `/proc/stat` fallback if `top` parsing still fails.
- **Bug fix** — `check_critical_services`: `php8.1-fpm` was hardcoded. Now dynamically detects the active PHP-FPM service via `systemctl list-units`; falls back to probing versions 8.3 → 7.4.
- **Bug fix** — `check_critical_services`: was checking only `mysql` service. Now checks for `mariadb.service` first and falls back to `mysql`, matching whichever is installed.
- **Bug fix** — `check_database`: `mysqladmin ping` with no credentials fails when `~/.my.cnf` is absent. Now uses `DB_USER`/`DB_PASS` from the sourced `.yiimp.conf` when available.
- **Bug fix** — `check_database`: unguarded empty rows from the `while read db size` loop produced stray color output. Added `[ -z "$db" ] && continue` guard.
- **Bug fix** — `check_ssl`: only checked `ssl_certificate.pem`. Now searches five candidate paths in priority order: `$STORAGE_ROOT/ssl/ssl_certificate.pem`, `$STORAGE_ROOT/ssl/fullchain.pem`, Let's Encrypt `fullchain.pem`, `cert.pem`, and `ssl_certificate.pem`.
- **Bug fix** — `check_ssl`: negative `days_left` (already-expired certificate) fell into the `< 7` branch, printing "expires in -5 days". Added an explicit `< 0` branch: `"SSL Certificate EXPIRED N days ago"`.
- **New** — `check_swap()`: reports swap total, used, and percent with color thresholds (red > 80 %, yellow > 50 %); prints an informational message if no swap is configured.
- **New** — `check_load()`: reads `/proc/loadavg` and displays 1/5/15-minute load averages color-coded against the number of CPU cores; also shows uptime and core count.
- **New** — `check_stratum()`: lists all active `screen` sessions (stratum processes) and their states; warns if none are found.
- **New** — `check_critical_services` now also checks **cron** (`cron`/`crond` auto-detected), **supervisor** (yiimp workers), and **fail2ban` — each only if the service is installed.
- **Improvement** — `main()` header upgraded to box-drawing style displaying version, hostname, and ISO-format timestamp.
- **Improvement** — Database size query results sorted by size descending so the largest databases appear first.
- **Improvement** — `free` local variable renamed to `free_mem` to avoid confusing name collision with the `free` command.
- **Improvement** — Added `MAGENTA` color variable. All output lines consistently indented 2 spaces for cleaner terminal output.

### Version

- **`ver.sh`** — Bumped `TAG` from `v2.6.2` to `v2.6.3`.

---

## [v2.6.2] — Previous Release

Initial tracked release. Established base installer flow for single-server YiiMP deployments with DaemonBuilder integration.

---

*For support, open an issue on [GitHub](https://github.com/afiniel/Yiimpoolv1/issues) or join [Discord](https://discord.gg/vV3JvN5JFm).*
