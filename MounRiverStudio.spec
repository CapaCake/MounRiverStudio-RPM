AutoReqProv: no
%define debug_package %{nil}
%define __os_install_post %{nil}

Name:           MounRiverStudio
Version:        220
Release:        1%{?dist}
Summary:        MounRiver Studio IDE for WCH RISC-V MCUs

License:        Proprietary
URL:            https://www.mounriver.com/
Source0:        %{name}_Linux_X64_V%{version}.deb

BuildArch:      x86_64


Requires:       hidapi
Requires:       libjaylink
Requires:       ncurses-compat-libs
Requires:       libusbx

Requires:       gtk3
Requires:       nss
Requires:       alsa-lib
Requires:       libXScrnSaver


%description
MounRiver Studio is an integrated development environment (IDE) based on the
Eclipse platform, tailored for the development of WCH RISC-V microcontrollers.
This package installs the IDE, necessary udev rules for debug probes, and 
required libraries.


%prep
%setup -q -c -T
ar x %{SOURCE0}
tar -xf data.tar.*
LOAD_SH_PATH="usr/share/MRS2/beforeinstall/load.sh"
sed -i '2i export LD_LIBRARY_PATH="/usr/share/MRS2/beforeinstall:$LD_LIBRARY_PATH"' "${LOAD_SH_PATH}"



%build


%install

mkdir -p %{buildroot}/usr/share
cp -r %{_builddir}/%{name}-%{version}/usr/share/* %{buildroot}/usr/share/

mkdir -p %{buildroot}/etc/udev/rules.d/
cp %{_builddir}/%{name}-%{version}/usr/share/MRS2/beforeinstall/50-wch.rules %{buildroot}/etc/udev/rules.d/
cp %{_builddir}/%{name}-%{version}/usr/share/MRS2/beforeinstall/60-openocd.rules %{buildroot}/etc/udev/rules.d/


%post

if command -v update-desktop-database >/dev/null 2>&1; then
    /usr/bin/update-desktop-database /usr/share/applications >/dev/null 2>&1 || :
fi

if command -v update-mime-database >/dev/null 2>&1; then
    /usr/bin/update-mime-database /usr/share/mime >/dev/null 2>&1 || :
fi

ldconfig


udevadm control --reload-rules

chmod -R 777 /usr/share/MRS2/MRS-linux-x64
chown root /usr/share/MRS2/MRS-linux-x64/chrome-sandbox
chmod 4755 /usr/share/MRS2/MRS-linux-x64/chrome-sandbox
chmod -R 777 /usr/share/MRS2/MRS-linux-x64/resources/app

echo "Install OK!"


%postun
if command -v update-desktop-database >/dev/null 2>&1; then
    /usr/bin/update-desktop-database /usr/share/applications >/dev/null 2>&1 || :
fi

if command -v update-mime-database >/dev/null 2>&1; then
    /usr/bin/update-mime-database /usr/share/mime >/dev/null 2>&1 || :
fi


%files
/usr/share/
/etc/udev/rules.d/

%changelog
* Wed Aug 27 2025 CapaCake <exec.cat@foxmail.com>
- 
