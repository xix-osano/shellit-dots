# Spec for DMS - uses rpkg macros for git builds

%global debug_package %{nil}
%global version {{{ git_dir_version }}}
%global pkg_summary ShellitMaterialShell - Material 3 inspired shell for Wayland compositors

Name:           dms
Epoch:          1
Version:        %{version}
Release:        1%{?dist}
Summary:        %{pkg_summary}

License:        GPL-3.0-only
URL:            https://github.com/AvengeMedia/ShellitMaterialShell
VCS:            {{{ git_dir_vcs }}}
Source0:        {{{ git_dir_pack }}}

# DMS CLI from Shellitlinux latest commit
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
Requires:       dms-cli
Requires:       dgop
Requires:       fira-code-fonts
Requires:       material-symbols-fonts
Requires:       rsms-inter-fonts

# Core utilities (Highly recommended for DMS functionality)
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
ShellitMaterialShell (DMS) is a modern Wayland desktop shell built with Quickshell
and optimized for the niri and hyprland compositors. Features notifications,
app launcher, wallpaper customization, and fully customizable with plugins.

Includes auto-theming for GTK/Qt apps with matugen, 20+ customizable widgets,
process monitoring, notification center, clipboard history, dock, control center,
lock screen, and comprehensive plugin system.

%package -n dms-cli
Summary:        ShellitMaterialShell CLI tool
License:        GPL-3.0-only
URL:            https://github.com/AvengeMedia/Shellitlinux

%description -n dms-cli
Command-line interface for ShellitMaterialShell configuration and management.
Provides native DBus bindings, NetworkManager integration, and system utilities.

%package -n dgop
Summary:        Stateless CPU/GPU monitor for ShellitMaterialShell
License:        MIT
URL:            https://github.com/AvengeMedia/dgop
Provides:       dgop

%description -n dgop
DGOP is a stateless system monitoring tool that provides CPU, GPU, memory, and 
network statistics. Designed for integration with ShellitMaterialShell but can be 
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
# Build DMS CLI from source
cd %{_builddir}/Shellitlinux-master
make dist

%install
# Install dms-cli binary (built from source) - use architecture-specific path
case "%{_arch}" in
  x86_64)
    DMS_BINARY="dms-linux-amd64"
    ;;
  aarch64)
    DMS_BINARY="dms-linux-arm64"
    ;;
  *)
    echo "Unsupported architecture: %{_arch}"
    exit 1
    ;;
esac

install -Dm755 %{_builddir}/Shellitlinux-master/bin/${DMS_BINARY} %{buildroot}%{_bindir}/dms

# Install dgop binary
install -Dm755 %{_builddir}/dgop %{buildroot}%{_bindir}/dgop

# Install shell files to shared data location
install -dm755 %{buildroot}%{_datadir}/quickshell/dms
cp -r * %{buildroot}%{_datadir}/quickshell/dms/

# Remove build files
rm -rf %{buildroot}%{_datadir}/quickshell/dms/.git*
rm -f %{buildroot}%{_datadir}/quickshell/dms/.gitignore
rm -rf %{buildroot}%{_datadir}/quickshell/dms/.github
rm -f %{buildroot}%{_datadir}/quickshell/dms/*.spec

%posttrans
# Clean up old installation path from previous versions (only if empty)
if [ -d "%{_sysconfdir}/xdg/quickshell/dms" ]; then
    # Remove directories only if empty (preserves any user-added files)
    rmdir "%{_sysconfdir}/xdg/quickshell/dms" 2>/dev/null || true
    rmdir "%{_sysconfdir}/xdg/quickshell" 2>/dev/null || true
    rmdir "%{_sysconfdir}/xdg" 2>/dev/null || true
fi

# Restart DMS for active users after upgrade
if [ "$1" -ge 2 ]; then
    # Find all quickshell DMS processes (PID and username)
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
        
        echo "Restarting DMS for user: $username"
        
        # Run as user with full Wayland session environment
        runuser -u "$username" -- /bin/sh -c "
            export XDG_RUNTIME_DIR=/run/user/$user_uid
            export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$user_uid/bus
            export WAYLAND_DISPLAY=$wayland_display
            export PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:\$PATH
            dms restart >/dev/null 2>&1
        " 2>/dev/null || true
        
        break
    done < <(pgrep -a -f 'quickshell.*dms' 2>/dev/null)
fi

%files
%license LICENSE
%doc README.md CONTRIBUTING.md
%{_datadir}/quickshell/dms/

%files -n dms-cli
%{_bindir}/dms

%files -n dgop
%{_bindir}/dgop

%changelog
{{{ git_dir_changelog }}}