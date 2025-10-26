# Spec for shellit - uses rpkg macros for git builds

%global debug_package %{nil}
%global version {{{ git_dir_version }}}
%global pkg_summary Shellit - Material 3 inspired shell for Wayland compositors

Name:           shellit
Epoch:          1
Version:        %{version}
Release:        1%{?dist}
Summary:        %{pkg_summary}

License:        GPL-3.0-only
URL:            https://github.com/xix-osano/shellit-dots
VCS:            {{{ git_dir_vcs }}}
Source0:        {{{ git_dir_pack }}}

# shellit CLI from Shellitlinux latest commit
Source1:        https://github.com/AvengeMedia/Shellitlinux/archive/refs/heads/master.tar.gz

BuildRequires:  git-core
BuildRequires:  rpkg
BuildRequires:  gzip
BuildRequires:  golang >= 1.24
BuildRequires:  make
BuildRequires:  wget

# Core requirements
Requires:       (quickshell-git or quickshell)
Requires:       accountsservice
Requires:       shellit-cli
Requires:       dgop
Requires:       fira-code-fonts
Requires:       material-symbols-fonts
Requires:       rsms-inter-fonts

# Core utilities (Highly recommended for shellit functionality)
Recommends:     brightnessctl
Recommends:     cava
Recommends:     cliphist
Recommends:     hyprpicker
Recommends:     matugen
Recommends:     quickshell-git
Recommends:     wl-clipboard

# Recommended system packages
Recommends:     NetworkManager
Recommends:     qt6-qtmultimedia
Suggests:       qt6ct

%description
Shellit is a modern Wayland desktop shell built with Quickshell
and optimized for the niri and hyprland compositors. Features notifications,
app launcher, wallpaper customization, and fully customizable with plugins.

Includes auto-theming for GTK/Qt apps with matugen, 20+ customizable widgets,
process monitoring, notification center, clipboard history, dock, control center,
lock screen, and comprehensive plugin system.

%package -n shellit-cli
Summary:        Shellit CLI tool
License:        GPL-3.0-only
URL:            https://github.com/AvengeMedia/Shellitlinux

%description -n shellit-cli
Command-line interface for Shellit configuration and management.
Provides native DBus bindings, NetworkManager integration, and system utilities.

%package -n dgop
Summary:        Stateless CPU/GPU monitor for Shellit
License:        MIT
URL:            https://github.com/AvengeMedia/dgop
Provides:       dgop

%description -n dgop
DGOP is a stateless system monitoring tool that provides CPU, GPU, memory, and 
network statistics. Designed for integration with Shellit but can be 
used standalone. This package always includes the latest stable dgop release.

%prep
{{{ git_dir_setup_macro }}}

# Extract ShellitLinux source
tar -xzf %{SOURCE1} -C %{_builddir}

# Download and extract DGOP binary for target architecture
case "%{_arch}" in
  x86_64)
    DGOP_ARCH="amd64"
    ;;
  aarch64)
    DGOP_ARCH="arm64"
    ;;
  *)
    echo "Unsupported architecture: %{_arch}"
    exit 1
    ;;
esac

wget -O %{_builddir}/dgop.gz "https://github.com/AvengeMedia/dgop/releases/latest/download/dgop-linux-${DGOP_ARCH}.gz" || {
  echo "Failed to download dgop for architecture %{_arch}"
  exit 1
}
gunzip -c %{_builddir}/dgop.gz > %{_builddir}/dgop
chmod +x %{_builddir}/dgop

%build
# Build shellit CLI from source
cd %{_builddir}/Shellitlinux-master
make dist

%install
# Install shellit-cli binary (built from source) - use architecture-specific path
case "%{_arch}" in
  x86_64)
    shellit_BINARY="shellit-linux-amd64"
    ;;
  aarch64)
    shellit_BINARY="shellit-linux-arm64"
    ;;
  *)
    echo "Unsupported architecture: %{_arch}"
    exit 1
    ;;
esac

install -Dm755 %{_builddir}/Shellitlinux-master/bin/${shellit_BINARY} %{buildroot}%{_bindir}/shellit

# Install dgop binary
install -Dm755 %{_builddir}/dgop %{buildroot}%{_bindir}/dgop

# Install shell files to shared data location
install -dm755 %{buildroot}%{_datadir}/quickshell/shellit
cp -r * %{buildroot}%{_datadir}/quickshell/shellit/

# Remove build files
rm -rf %{buildroot}%{_datadir}/quickshell/shellit/.git*
rm -f %{buildroot}%{_datadir}/quickshell/shellit/.gitignore
rm -rf %{buildroot}%{_datadir}/quickshell/shellit/.github
rm -f %{buildroot}%{_datadir}/quickshell/shellit/*.spec

%posttrans
# Clean up old installation path from previous versions (only if empty)
if [ -d "%{_sysconfdir}/xdg/quickshell/shellit" ]; then
    # Remove directories only if empty (preserves any user-added files)
    rmdir "%{_sysconfdir}/xdg/quickshell/shellit" 2>/dev/null || true
    rmdir "%{_sysconfdir}/xdg/quickshell" 2>/dev/null || true
    rmdir "%{_sysconfdir}/xdg" 2>/dev/null || true
fi

# Restart shellit for active users after upgrade
if [ "$1" -ge 2 ]; then
    # Find all quickshell shellit processes (PID and username)
    while read pid cmd; do
        username=$(ps -o user= -p "$pid" 2>/dev/null)
        
        [ "$username" = "root" ] && continue
        [ -z "$username" ] && continue
        
        # Get user's UID and validate session
        user_uid=$(id -u "$username" 2>/dev/null)
        [ -z "$user_uid" ] && continue
        [ ! -d "/run/user/$user_uid" ] && continue
        
        wayland_display=$(tr '\0' '\n' < /proc/$pid/environ 2>/dev/null | grep '^WAYLAND_DISPLAY=' | cut -d= -f2)
        [ -z "$wayland_display" ] && continue
        
        echo "Restarting shellit for user: $username"
        
        # Run as user with full Wayland session environment
        runuser -u "$username" -- /bin/sh -c "
            export XDG_RUNTIME_DIR=/run/user/$user_uid
            export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$user_uid/bus
            export WAYLAND_DISPLAY=$wayland_display
            export PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:\$PATH
            shellit restart >/dev/null 2>&1
        " 2>/dev/null || true
        
        break
    done < <(pgrep -a -f 'quickshell.*shellit' 2>/dev/null)
fi

%files
%license LICENSE
%doc README.md CONTRIBUTING.md
%{_datadir}/quickshell/shellit/

%files -n shellit-cli
%{_bindir}/shellit

%files -n dgop
%{_bindir}/dgop

%changelog
{{{ git_dir_changelog }}}