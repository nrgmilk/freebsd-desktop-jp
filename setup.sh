#!/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

export ASSUME_ALWAYS_YES=yes
export FORCE_PKG_REGISTER=1

### Functions

checkArch () {
	ARCH=`sysctl -n hw.machine_arch`
	case $ARCH in
		'amd64')
			;;
		'i386')
			;;
		*)
			echo "$ARCH is not supported."
			exit 1
			;;
	esac
}

checkVersion () {
	VERSION=`freebsd-version -k | awk '{print substr($0, 0, 2)}'`
}

checkRoot () {
	if [ "$(id -u)" != "0" ];
	then
	   echo "This script must be run as root" 1>&2
	   exit 1
	fi
}

checkVirtual () {
	SYSTEM=`kenv -q smbios.system.product`
	case $SYSTEM in
		'VirtualBox')
			VBOXGUEST=1
			;;
		'VMware Virtual Platform')
			VMWAREGUEST=1
			;;
		*)
			;;
	esac
}

echoMessage () {
	dialog --msgbox "$1" 6 76
}

addConf () {
	EXSIST=`egrep -c "^$1" $3`
	if [ $EXSIST -ne 0 ]
	then
		sed -i "" -e "s/^$1/#$1/" $3
	fi
	echo $1"=\"$2\"" >> $3
	unset EXSIST
}

addComment () {
	echo "\n#"$1 >> $2
}


addFstab () {
	EXSIST=`egrep -c "^$1" /etc/fstab`
	if [ $EXSIST -eq 0 ]
	then
		echo "$2" >> /etc/fstab
	fi
	unset EXSIST
}

portsUpdate () {
	if [ ! -f /var/db/portsnap/INDEX ]
	then
		portsnap --interactive fetch extract > /dev/null 2>&1 &
	else
		portsnap --interactive fetch update > /dev/null 2>&1 &
	fi
}

selectDesktop () {
	DESKTOP=`dialog  --stdout --no-tags --nocancel --checklist \
						"Select desktop environment. " 20 76 11 \
						mate MATE on  \
						xfce Xfce off \
						kde KDE off \
						gnome GNOME3 off \
						lxde LXDE off \
						cinnamon Cinnamon off \
						lumina Lumina off \
						fluxbox Fluxbox off \
						awesome awesome off \
						openbox openbox off \
						windowmaker "Window Maker" off \
						`
}

packageDesktop () {
	PACKAGE_DESKTOP=''
	for i in $DESKTOP;
		do
			case $i in
				'mate')
					PACKAGE_DESKTOP="$PACKAGE_DESKTOP\
									mate "
					;;
				'kde')
					PACKAGE_DESKTOP="$PACKAGE_DESKTOP\
									kde ja-kde-l10n \
									gtk-qt-engine \
									gtk-oxygen-engine \
									gtk3-oxygen-engine "
					KDE=1
					;;
				'gnome')
					PACKAGE_DESKTOP="$PACKAGE_DESKTOP\
									gnome3 "
					GNOME=1
					;;
				'xfce')
					PACKAGE_DESKTOP="$PACKAGE_DESKTOP\
									xfce "
					;;
				'lxde')
					PACKAGE_DESKTOP="$PACKAGE_DESKTOP\
									lxde-meta "
					;;
				'lumina')
					PACKAGE_DESKTOP="$PACKAGE_DESKTOP\
									lumina "
					;;
				'fluxbox')
					PACKAGE_DESKTOP="$PACKAGE_DESKTOP\
									fluxbox "
					;;
				'windowmaker')
					PACKAGE_DESKTOP="$PACKAGE_DESKTOP\
									windowmaker "
					;;
				'awesome')
					PACKAGE_DESKTOP="$PACKAGE_DESKTOP\
									awesome "
					;;
				'i3')
					PACKAGE_DESKTOP="$PACKAGE_DESKTOP\
									i3 i3status i3lock "
					;;
				'openbox')
					PACKAGE_DESKTOP="$PACKAGE_DESKTOP\
									openbox "
					;;
				'cinnamon')
					PACKAGE_DESKTOP="$PACKAGE_DESKTOP\
									cinnamon mate "
					;;
				'enlightenment')
					PACKAGE_DESKTOP="$PACKAGE_DESKTOP\
									enlightenment "
					;;

			esac
	done
	unset i
}

selectIm () {
	IM=`dialog  --stdout --no-tags --nocancel --radiolist \
			"Select input method. " 20 76 3 \
			ibus ibus on  \
			fcitx fcitx off \
			uim uim off
			`
			
	case $IM in
		'ibus')
			IM_ENGINE=`dialog  --stdout --no-tags --nocancel --radiolist \
				"Select IM engine. " 20 76 3 \
				mozc-jp mozc on  \
				anthy anthy off \
				skk skk off
				`
			PACKAGE_IM="dconf "
			case $IM_ENGINE in
				'mozc-jp')
					PACKAGE_IM=$PACKAGE_IM"ja-ibus-mozc "
					;;
				'anthy')
					PACKAGE_IM=$PACKAGE_IM"ja-ibus-anthy "
					;;
				'skk')
					PACKAGE_IM=$PACKAGE_IM"ja-ibus-skk "
					;;
			esac

			;;
		'fcitx')
			IM_ENGINE=`dialog  --stdout --no-tags --nocancel --radiolist \
				"Select IM engine. " 20 76 3 \
				mozc-jp mozc on  \
				anthy anthy off \
				skk skk off
				`
			PACKAGE_IM="zh-fcitx-configtool "
			case $IM_ENGINE in
				'mozc-jp')
					PACKAGE_IM=$PACKAGE_IM"ja-fcitx-mozc "
					if [ "$GNOME" != "" ]
					then
						PACKAGE_IM=$PACKAGE_IM"ja-ibus-mozc "
					fi
					;;
				'anthy')
					PACKAGE_IM=$PACKAGE_IM"ja-fcitx-anthy "
					if [ "$GNOME" != "" ]
					then
						PACKAGE_IM=$PACKAGE_IM"ja-ibus-anthy "
					fi
					;;
				'skk')
					PACKAGE_IM=$PACKAGE_IM"ja-fcitx-skk "
					if [ "$GNOME" != "" ]
					then
						PACKAGE_IM=$PACKAGE_IM"ja-ibus-skk "
					fi
					;;
			esac

			;;
		'uim')
			IM_ENGINE=`dialog  --stdout --no-tags --nocancel --radiolist \
				"Select IM engine. " 20 76 2 \
				mozc-jp mozc on  \
				anthy anthy off \
				`
			PACKAGE_IM="uim-gtk uim-gtk3 uim-qt4 "
			case $IM_ENGINE in
				'mozc-jp')
					PACKAGE_IM=$PACKAGE_IM"ja-uim-mozc "
					if [ "$GNOME" != "" ]
					then
						PACKAGE_IM=$PACKAGE_IM"ja-ibus-mozc "
					fi
					;;
				'anthy')
					PACKAGE_IM=$PACKAGE_IM"ja-uim-anthy "
					if [ "$GNOME" != "" ]
					then
						PACKAGE_IM=$PACKAGE_IM"ja-ibus-anthy "
					fi
					;;
			esac

			;;
	esac
}


settingIm () {
			
	KEYMAP_JP=`egrep -c "^keymap=\"jp(.*)?\"" /etc/rc.conf`
	if [ $KEYMAP_JP -eq 0 ]
	then
		# US配列ユーザー向け設定
		echo "setxkbmap us" >> /usr/local/etc/X11/xinit/xinitrc
		case $IM in
			'ibus')
				case $IM_ENGINE in
					'mozc-jp')
						sed -i "" -e \
							"s@<language>.*</language>@<language>ja</language>@" \
							/usr/local/share/ibus/component/mozc.xml
						sed -i "" -e \
							"s@<rank>.*</rank>@<rank>99</rank>@" \
							/usr/local/share/ibus/component/mozc.xml
						sed -i "" -e \
							"s@<layout>.*</layout>@<layout>us</layout>@" \
							/usr/local/share/ibus/component/mozc.xml
						;;
					'anthy')
						sed -i "" -e \
							"s@<layout>.*</layout>@<layout>us</layout>@" \
							/usr/local/share/ibus/component/anthy.xml
						;;
					'skk')
						sed -i "" -e \
							"s@<layout>.*</layout>@<layout>us</layout>@" \
							/usr/local/share/ibus/component/skk.xml
						;;
				esac
				;;
			*)
				;;
		esac
	else
		# JIS配列ユーザー向け設定
		echo "setxkbmap jp" >> /usr/local/etc/X11/xinit/xinitrc
		case $IM in
			'ibus')
				case $IM_ENGINE in
					'mozc-jp')
						sed -i "" -e \
							"s@<language>.*</language>@<language>ja</language>@" \
							/usr/local/share/ibus/component/mozc.xml
						sed -i "" -e \
							"s@<rank>.*</rank>@<rank>99</rank>@" \
							/usr/local/share/ibus/component/mozc.xml
						sed -i "" -e \
							"s@<layout>.*</layout>@<layout>jp</layout>@" \
							/usr/local/share/ibus/component/mozc.xml
						;;
					*)
						;;
				esac
				;;
			*)
				;;
		esac
	fi
	unset $KEYMAP_JP

	case $IM in
		'ibus')
			cat >> /usr/local/etc/X11/xinit/xinitrc << EOF
export XMODIFIERS=@im=ibus
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XIM=ibus
export XIM_PROGRAM="ibus-daemon"
export XIM_ARGS="-r -d -x"
if [ ! -f \$HOME/.ibus_firsttime ]
then
	dconf write /desktop/ibus/general/engines-order "['$IM_ENGINE', 'xkb:jp::jpn']"
	dconf write /desktop/ibus/general/preload-engines "['$IM_ENGINE', 'xkb:jp::jpn']"
	touch \$HOME/.ibus_firsttime
fi
case \$1 in
    'wmaker')
       \$XIM_PROGRAM \$XIM_ARGS
        ;;
    'awesome')
       \$XIM_PROGRAM \$XIM_ARGS
        ;;
    'fluxbox')
       \$XIM_PROGRAM \$XIM_ARGS
        ;;
    *)
        ;;
esac
EOF
				;;
		'fcitx')
			cat >> /usr/local/etc/X11/xinit/xinitrc << EOF
export XMODIFIERS=@im=fcitx
export GTK_IM_MODULE="fcitx"
export QT_IM_MODULE="fcitx"
export XIM=fcitx
export XIM_PROGRAM="fcitx"
export XIM_ARGS="-r -d"
\$XIM_PROGRAM \$XIM_ARGS
EOF
				;;
		'uim')
			cat >> /usr/local/etc/X11/xinit/xinitrc << EOF
export XMODIFIERS=@im=uim
export GTK_IM_MODULE="uim"
export QT_IM_MODULE="uim"
export XIM=uim
export XIM_PROGRAM="uim-xim"
export XIM_ARGS="&"
\$XIM_PROGRAM \$XIM_ARGS &
EOF
				;;
	esac

}

selectExtra () {
	EXTRA=`dialog  --stdout --no-tags --nocancel --checklist \
            "Select extra packages. " 20 76 58 \
            flash "Adobe Flash Player" off \
            firefox "Firefox (Web browser)" off  \
            chromium "Chrome (Web browser)" off \
            thunderbird "Thunderbird (Mail client)" off \
            sylpheed "Sylpheed (Mail client)" off \
            libreoffice "LibreOffice (Office suite)" off \
            lyx "LyX (Document Processor)" off \
            filezilla "Filezilla (FTP and SFTP client)" off \
            xchat "XChat (IRC client)" off \
            transmission "Transmission (BitTorrent client)" off \
            qbittorrent "qBittorrent (BitTorrent client)" off \
            vlc "VLC (Media player)" off \
            smplayer "SMPlayer (Media player)" off \
            audacious "Audacious (Audio player)" off \
            gimp "GIMP (Image Manipulation)" off \
            rawtherapee "RawTherapee (RAW image processing)" off \
            darktable "Darktable (Photo workflow software)" off \
            shotwell "Shotwell (Photo manager)" off \
            blender "Blender (3D graphics and animation software)" off \
            Imagemagick "Imagemagick (Image manipulation software)" off \
            Inkscape "Inkscape (vector graphics editor)" off \
            mypaint "MyPaint (painting/scribbling program)" off \
            scribus "Scribus (Comprehensive desktop publishing program)" off \
            synfigstudio "Synfig Studio (Vector-based 2D animation software)" off \
            fontforge "FontForge (Font editor)" off \
            agave "Agave (Color scheme builder)" off \
            xsane "SANE (Scanner API tool)" off \
            ffmpeg "FFmpeg (Audio/video encoder/converter)" off \
            openshot "OpenShot Video Editor (Non-linear video editor)" off \
            pitivi "Pitivi (Non-linear video editor)" off \
            kdenlive "Kdenlive (Non-linear video editor)" off \
            dvdstyler "DVDStyler (DVD recoding and authoring programs)" off \
            subtitleeditor "Subtitle Editor (Subtitle editor)" off \
            AudioProduction "Audio Production Softwares (Meta package)" off \
            xfburn "XfBurn (CD/DVD Burning)" off \
            k3b "K3B (CD/DVD Burning)" off \
            brasero "Brasero (CD/DVD Burning)" off \
            epdfview "epdfview (PDF viewer)" off \
            py27-mcomix "MComix (Comic viewer)" off \
            calibre "calibre (E-book viewer)" off \
            geany "Geany (Develop environment)" off \
            vim "Vim (Develop environment)" off \
            emacs24 "Emacs (Develop environment)" off \
            eclipse "Eclipse (Develop environment)" off \
            meld "Meld (Visual diff and merge tool)" off \
            openjdk8 "OpenJDK 8 (Java development kit)" off \
            virtualbox "VirtualBox (Virtual machine)" off \
            wine "Wine (Windows compatibility environment)" off \
            android-tools-adb "ADB (Android debug bridge)" off \
            clamav "ClamAV (Antivirus)" off \
            tor "TOR (Anonymizing overlay network for TCP)" off \
            wifimgr "Wifimgr (WiFi Networks Manager)" off \
            zsh "ZSH (Shell)" off \
            minecraft-client "Minecraft (Game)" off \
            `
}

packageExtra () {
	PACKAGE_EXTRA=''
	PORTS_EXTRA=''
	for i in $EXTRA;
		do
			case $i in
				'flash')
					PACKAGE_EXTRA="$PACKAGE_EXTRA\
								   nspluginwrapper \
								   gmake \
								   python \
								   perl5 \
								   pcre \
								   libiconv \
								   glib \
								   gettext "
					PORTS_EXTRA="$PORTS_EXTRA\
								www/linux-c6-flashplugin11 "
					;;
				'libreoffice')
					PACKAGE_EXTRA="$PACKAGE_EXTRA\
								  libreoffice ja-libreoffice "
					;;
				'firefox')
					PACKAGE_EXTRA="$PACKAGE_EXTRA\
						          firefox firefox-i18n "
                    PACKAGE_FIREFOX=1
					;;
				'thunderbird')
					PACKAGE_EXTRA="$PACKAGE_EXTRA\
						          thunderbird thunderbird-i18n "
                    PACKAGE_THUNDERBIRD=1
					;;
				'wine')
					if [ $ARCH == "amd64" ]
					then
						PACKAGE_EXTRA="$PACKAGE_EXTRA\
							          i386-wine-staging "
					else
						PACKAGE_EXTRA="$PACKAGE_EXTRA\
							          wine-staging "
					fi
					;;
				'vlc')
					if [ $KDE != "" ]
					then
						PACKAGE_EXTRA="$PACKAGE_EXTRA\
							          vlc-qt4 "
					else
						PACKAGE_EXTRA="$PACKAGE_EXTRA\
							          vlc "
					fi
					;;
				'virtualbox')
                    if [ $VERSION == 10 ]
                    then
                        PACKAGE_EXTRA="$PACKAGE_EXTRA\
                                      virtualbox-ose \
                                      virtualbox-ose-kmod "
                        PACKAGE_VBOX=1
                    else
                        echoMessage "$i package not found on FreeBSD $VERSION"
                    fi
					;;
				'tor')
					PACKAGE_EXTRA="$PACKAGE_EXTRA\
						          tor "
					PACKAGE_TOR=1
					;;
				'clamav')
					PACKAGE_EXTRA="$PACKAGE_EXTRA\
						          clamav \
						          clamtk "
					PACKAGE_CLAMAV=1
					;;
				'eclipse')
					PACKAGE_EXTRA="$PACKAGE_EXTRA\
						          eclipse "
					PACKAGE_ECLIPSE=1
					;;
				'audacious')
					PACKAGE_EXTRA="$PACKAGE_EXTRA\
                                    audacious \
                                    audacious-skins \
                                    audacious-plugins "
					;;
				'AudioProduction')
                    PACKAGE_EXTRA="$PACKAGE_EXTRA\
                                    audacity \
                                    ardour \
                                    hydrogen \
                                    lmms \
                                    musescore \
                                    sooperlooper \
                                    idjc \
                                    rsynth qsynth whysynth \
                                    xsynth-dssi fluidsynth-dssi \
                                    spiralsynth spiralsynthmodular \
                                    qjackctl \
                                    jackit \
                                    jack-keyboard \
                                    jack-rack \
                                    jack-smf-utils \
                                    jack_ghero \
                                    jack_mixer \
                                    jack_umidi "
                    PACKAGE_AUDIO_PRODUCTION=1
                    ;;
				*)
					PACKAGE_EXTRA=$PACKAGE_EXTRA"$i ";;
			esac
	done
	unset i

	if [ "$VBOXGUEST" != "" ] 
	then
		PACKAGE_EXTRA="$PACKAGE_EXTRA\
			virtualbox-ose-additions "
	fi

	if [ "$VMWAREGUEST" != "" ] 
	then
		PACKAGE_EXTRA="$PACKAGE_EXTRA\
			open-vm-tools \
			xf86-video-vmware "
	fi

}

selectPackages () {
	# デスクトップ環境
	while [ "$DESKTOP" == "" ]
	do
		selectDesktop
		if [ "$DESKTOP" == ""  ] 
		then
				echoMessage "Please select least one."
		fi
	done
	packageDesktop

	# 日本語入力
	while [ "$PACKAGE_IM" == "" ]
	do
		selectIm
		if [ "$PACKAGE_IM" == ""  ] 
		then
				echoMessage "Please select least one."
		fi
	done

	# 追加パッケージ
	selectExtra
	packageExtra
}

confirm () {
	CONFIRM_MESSAGE="[Desktop environment]\n
$DESKTOP\n
\n
[Input method]\n
$IM $IM_ENGINE\n
\n
[Extra packages]\n
$EXTRA
"

	CONFIRM=1
	dialog  --defaultno --yesno \
							"Please confirm. \
							\n\n$CONFIRM_MESSAGE" 20 76
						
	if [ $? -ne 0 ]
	then
		unset CONFIRM
		unset DESKTOP
		unset PACKAGE_IM
		unset EXTRA
		unset PACKAGE_EXTRA
	fi
}

install () {

	kldload linux
    
    sed -i "" -e 's@url: "pkg+http://pkg.FreeBSD.org/\${ABI}/.*"@url: "pkg+http://pkg.FreeBSD.org/\${ABI}/latest"@' \
        /etc/pkg/FreeBSD.conf

	pkg install -y 	xorg-minimal \
					xorg-drivers \
					xrandr \
					hal dbus \
					setxkbmap \
					xterm gksu octopkg \
					zip p7zip rar lha \
					ja-font-migu \
					ja-font-ipamjm \
					urwfonts-ttf \
					droid-fonts-ttf \
					liberation-fonts-ttf \
					slim slim-themes \
					uhidd volman \
					swapexd webcamd \
					fusefs-ext4fuse \
					fusefs-ntfs \
					e2fsprogs ntfsprogs \
					cuse4bsd-kmod \
					panicmail \
					cups avahi \
					gmake ffmpegthumbnailer \
					linux_base-c6 \
					$PACKAGE_DESKTOP \
					$PACKAGE_IM \
					$PACKAGE_EXTRA

    if [ $? -ne 0 ]
    then
        echoMessage "Pakage install failed."
        exit 1
    fi

	if [ "$PORTS_EXTRA" != "" ]
	then
		for i in $PORTS_EXTRA
		do
			make BATCH=yes -C /usr/ports/$i install clean
            if [ $? -ne 0 ]
            then
                echoMessage "Ports install failed."
                exit 1
            fi
		done
		unset i
	fi

}

setup (){
    
    addFstab proc "proc /proc procfs rw 0 0"
    addFstab linprocfs "linprocfs /compat/linux/proc linprocfs rw 0 0"
    addFstab linsysfs "linprocfs /compat/linux/sys linsysfs rw 0 0"
	addFstab fdesc "fdesc /dev/fd fdescfs rw 0 0"
    mkdir /tmpfs > /dev/null 2>&1
    echo "tmpfs /tmpfs tmpfs rw,mode=01777 0 0" >> /etc/fstab

	sed -i "" -e "s/^#sessiondir/sessiondir/" /usr/local/etc/slim.conf
	sed -i "" -e "s/^login_cmd/#login_cmd/" /usr/local/etc/slim.conf
	echo "login_cmd exec /bin/sh - /usr/local/etc/X11/xinit/xinitrc %session" \
			>> /usr/local/etc/slim.conf
	sed -i "" -e "s/^current_theme/#current_theme/" /usr/local/etc/slim.conf
	echo "current_theme      fbsd" \
			>> /usr/local/etc/slim.conf
	sed -i "" -e "s/^session_msg/#session_msg/" /usr/local/etc/slim.conf
	echo "session_msg         [F1]Session:" \
			>> /usr/local/etc/slim.conf

    addConf legal.intel_iwi.license_ack 1 /boot/loader.conf
    addConf legal.intel_ipw.license_ack 1 /boot/loader.conf
    addConf legal.realtek.license_ack 1 /boot/loader.conf
    
    addConf kern.ipc.shmseg 1024 /boot/loader.conf
    addConf kern.ipc.shmmni 1024 /boot/loader.conf
    addConf kern.maxproc 10000 /boot/loader.conf
    addConf kern.cam.scsi_delay 500 /boot/loader.conf
    addConf kern.hz 100 /boot/loader.conf
    addConf hint.acpi_throttle.0.disabled 1 /boot/loader.conf
    addConf machdep.disable_mtrrs 1 /boot/loader.conf
    addConf hw.memtest.tests 0 /boot/loader.conf
    addConf hw.pci.do_power_nodriver 3 /boot/loader.conf
    addConf net.graph.maxdata 65536 /boot/loader.conf
    addConf ums_load "YES" /boot/loader.conf
    addConf aesni_load "YES" /boot/loader.conf
    addConf linux_load "YES" /boot/loader.conf

    addConf kern.coredump 0 /etc/sysctl.conf
    sysctl kern.coredump=0
    addConf kern.maxfiles 49312 /etc/sysctl.conf
    sysctl kern.maxfiles=49312
    addConf kern.sched.preempt_thresh 224 /etc/sysctl.conf
    sysctl kern.sched.preempt_thresh=224
    addConf kern.shutdown.poweroff_delay 500 /etc/sysctl.conf
    sysctl kern.shutdown.poweroff_delay=500

    SHMMAX=`sysctl -n hw.physmem`
    addConf kern.ipc.shmmax $SHMMAX /etc/sysctl.conf
    sysctl kern.ipc.shmmax=$SHMMAX
    
    SHMALL=`expr $SHMMAX / 4096`    
    addConf kern.ipc.shmall $SHMALL /etc/sysctl.conf
    sysctl kern.ipc.shmall=$SHMALL
    
    addConf kern.ipc.shm_allow_removed 1 /etc/sysctl.conf
    sysctl kern.ipc.shm_allow_removed=1
    addConf vfs.usermount 1 /etc/sysctl.conf
    sysctl vfs.usermount=1
    addConf hw.usb.no_shutdown_wait 1 /etc/sysctl.conf
    sysctl hw.usb.no_shutdown_wait=1
    addConf hw.syscons.bell 0 /etc/sysctl.conf
    sysctl hw.syscons.bell=0

    addConf kld_list "libiconv libmchain msdosfs_iconv cuse4bsd sem fdescfs \
linsysfs ext2fs acpi_video fuse" /etc/rc.conf				
    addConf kldxref_enable "YES" /etc/rc.conf
    addConf kldxref_clobber "YES" /etc/rc.conf
    addConf linux_enable "YES" /etc/rc.conf
    addConf clear_tmp_enable "YES" /etc/rc.conf
    addConf clean_tmp_X "YES" /etc/rc.conf
    addConf fsck_y_enable "YES" /etc/rc.conf
    addConf dumpdev "AUTO" /etc/rc.conf
    addConf panicmail_enable "YES" /etc/rc.conf
    addConf panicmail_autosubmit "YES" /etc/rc.conf
    addConf autofs_enable "YES" /etc/rc.conf
    addConf swapexd_enable "YES" /etc/rc.conf
    addConf powerd_enable "YES" /etc/rc.conf
    addConf powerd_flags "-a hiadaptive -b adaptive" /etc/rc.conf
    addConf performance_cx_lowest "Cmax" /etc/rc.conf
    addConf economy_cx_lowest "Cmax" /etc/rc.conf
    addConf moused_enable "YES" /etc/rc.conf
    addConf uhidd_enable "YES" /etc/rc.conf
    addConf volmand_enable "YES" /etc/rc.conf
    addConf webcamd_enable "YES" /etc/rc.conf
    addConf cupsd_enable "YES" /etc/rc.conf
    addConf avahi_daemon_enable "YES" /etc/rc.conf
    addConf devd_enable "YES" /etc/rc.conf
    addConf devfs_enable "YES" /etc/rc.conf
    addConf devfs_system_ruleset "devfsrules_common" /etc/rc.conf
    addConf hald_enable "YES" /etc/rc.conf
    addConf dbus_enable "YES" /etc/rc.conf
    addConf slim_enable "YES" /etc/rc.conf

	if [ "$PACKAGE_FIREFOX" != "" ]
	then
        cat > /usr/local/lib/firefox/defaults/pref/local-settings.js << EOF
pref("general.config.obscure_value", 0);
pref("general.config.filename", "localize.js");
EOF
        cat > /usr/local/lib/firefox/localize.js << EOF
pref("extensions.bootstrappedAddons", "{"langpack-ja@firefox.mozilla.org":{"type":"locale","descriptor":"/usr/local/lib/firefox/browser/extensions/langpack-ja@firefox.mozilla.org","multiprocessCompatible":false}}");
pref("extensions.autoDisableScopes", 0);
pref("general.useragent.locale", "ja-JP");
pref("font.language.group", "ja");
pref("intl.accept_languages", "ja-JP, ja, en-US, en");
pref("font.name.monospace.ja", "Migu 1M");
pref("font.name.sans-serif.ja", "Migu 1C");
pref("font.name.serif.ja", "IPAmjMincho");
pref("startup.homepage_welcome_url", "");
pref("startup.homepage_welcome_url.additional", "");
EOF
	fi

	if [ "$PACKAGE_THUNDERBIRD" != "" ]
	then
        cat > /usr/local/lib/thunderbird/defaults/pref/local-settings.js << EOF
pref("general.config.obscure_value", 0);
pref("general.config.filename", "localize.js");
EOF
        cat > /usr/local/lib/thunderbird/localize.js << EOF
pref("extensions.bootstrappedAddons", "{"langpack-ja@thunderbird.mozilla.org":{"type":"locale","descriptor":"/usr/local/lib/thunderbird/extensions/langpack-ja@thunderbird.mozilla.org","multiprocessCompatible":false}}");
pref("extensions.autoDisableScopes", 0);
pref("general.useragent.locale", "ja-JP");
pref("font.language.group", "ja");
pref("intl.accept_languages", "ja-JP, ja, en-US, en");
pref("font.name.monospace.ja", "Migu 1M");
pref("font.name.sans-serif.ja", "Migu 1C");
pref("font.name.serif.ja", "IPAmjMincho");
pref("startup.homepage_welcome_url", "");
pref("startup.homepage_welcome_url.additional", "");
EOF
	fi

	if [ "$PACKAGE_VBOX" != "" ]
	then
		addConf vboxnet_enable "YES" /etc/rc.conf
		addConf vboxwatchdog_enable "YES" /etc/rc.conf
		addConf vboxwatchdog_user "root" /etc/rc.conf
		chmod +x /usr/local/lib/virtualbox/VirtualBox
	fi

	if [ "$VBOXGUEST" != "" ]
	then
		addConf vboxguest_enable "YES" /etc/rc.conf
		addConf vboxservice_enable "YES" /etc/rc.conf
	fi

	if [ "$VMWAREGUEST" != "" ]
	then
		addConf vmware_guest_vmblock_enable "YES" /etc/rc.conf
		addConf vmware_guest_vmhgfs_enable "YES" /etc/rc.conf
		addConf vmware_guest_vmmemctl_enable "YES" /etc/rc.conf
		addConf vmware_guest_vmxnet_enable "YES" /etc/rc.conf
		addConf vmware_guestd_enable "YES" /etc/rc.conf
	fi

	if [ "$PACKAGE_TOR" != "" ]
	then
		addConf tor_enable "YES" /etc/rc.conf
		addConf net.inet.ip.random_id "1" /boot/loader.conf
		sysctl net.inet.ip.random_id=1
		rm -r /var/db/tor /var/run/tor > /dev/null 2>&1
		mkdir -p /var/db/tor/data /var/run/tor
		touch /var/log/tor
		chown -R _tor:_tor /var/db/tor /var/log/tor /var/run/tor
		chmod -R 700 /var/db/tor
	fi

	if [ "$PACKAGE_CLAMAV" != "" ]
	then
		sed -i "" -e "s/^User/#User/" /usr/local/etc/clamd.conf
		echo "User root" \
			>> /usr/local/etc/clamd.conf
		#addConf clamav_clamd_enable "YES" /etc/rc.conf
		addConf clamav_freshclam_enable "YES" /etc/rc.conf
		/usr/local/bin/freshclam
	fi

	if [ "$PACKAGE_ECLIPSE" != "" ]
	then
        fetch http://www.eclipse.org/ecd/img/eclipse256.png -o /usr/local/share/eclipse
        cd /tmp
        fetch http://svn.sourceforge.jp/svnroot/mergedoc/trunk/Pleiades/build/pleiades.zip
        tar xvzf pleiades.zip
        cp -a plugins/* /usr/local/lib/eclipse/plugins/
        cp -a features/* /usr/local/lib/eclipse/features/
        sed -i "" -e "s@^-Xms.*m@-Xms1024m@" \
            /usr/local/lib/eclipse/eclipse.ini 1>&2
        sed -i "" -e "s@^-Xmx.*m@-Xmx1024m@" \
            /usr/local/lib/eclipse/eclipse.ini 1>&2
        cd -
        cat > /usr/local/share/applications/eclipse.desktop << EOF
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Name=Eclipse
Comment=Eclipse Development Environment
Exec=eclipse -vmargs -Xverify:none -javaagent:/usr/local/lib/eclipse/plugins/jp.sourceforge.mergedoc.pleiades/pleiades.jar -Xms1024m -Xmx1024m %F
Terminal=false
Type=Application
Icon=/usr/local/share/eclipse/eclipse256.png
Categories=Development;
MimeType=text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/xml;text/html;text/css;text/x-sql;text/x-diff;
EOF
        cat > /usr/local/share/applications/eclipse-clean.desktop << EOF
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Name=Eclipse (clean)
Comment=Eclipse Development Environment
Exec=eclipse -clean
Terminal=false
Type=Application
Icon=/usr/local/share/eclipse/eclipse256.png
Categories=Development;
MimeType=text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/xml;text/html;text/css;text/x-sql;text/x-diff;
EOF
	fi

    sed -i "" -e "s/^Categories.*/Categories=Settings;/" \
        /usr/local/share/applications/flash-player-properties.desktop 2>&1
        
    sed -i "" -e "s/^Categories.*/Categories=Network;/" \
        /usr/local/share/applications/bssh.desktop 2>&1
    sed -i "" -e "s/^Categories.*/Categories=Network;/" \
        /usr/local/share/applications/bvnc.desktop 2>&1
        
    sed -i "" -e "s/^Categories.*/Categories=AudioVideo;Audio;/" \
        /usr/local/share/applications/jack-rack.desktop 2>&1
    sed -i "" -e "s/^Categories.*/Categories=AudioVideo;Audio;/" \
        /usr/local/share/applications/jack_mixer.desktop 2>&1
    sed -i "" -e "s/^Categories.*/Categories=AudioVideo;Audio;/" \
        /usr/local/share/applications/hydrogen.desktop 2>&1
    sed -i "" -e "s/^Categories.*/Categories=AudioVideo;Audio;/" \
        /usr/local/share/applications/lmms.desktop 2>&1
    sed -i "" -e "s/^Categories.*/Categories=AudioVideo;Audio;/" \
        /usr/local/share/applications/mscore.desktop 2>&1
    sed -i "" -e "s/^Categories.*/Categories=AudioVideo;Audio;/" \
        /usr/local/share/applications/qjackctl.desktop 2>&1
    sed -i "" -e "s/^Categories.*/Categories=AudioVideo;Audio;/" \
        /usr/local/share/applications/qsynth.desktop 2>&1

    sed -i "" -e "s/^Categories.*/Categories=Utility;/" \
        /usr/local/share/applications/gucharmap.desktop 2>&1

    sed -i "" -e "s@^Icon=.*@Icon=/usr/local/share/hydrogen/data/img/gray/icon.svg@" \
        /usr/local/share/applications/hydrogen.desktop 2>&1

    echo "Name[ja]=OctoPkg パッケージマネージャー" \
        >> /usr/local/share/applications/octopkg.desktop

    echo "GenericName[ja]=パッケージマネージャー" \
        >> /usr/local/share/applications/octopkg.desktop

    echo "Comment[ja]=パッケージの追加と削除" \
        >> /usr/local/share/applications/octopkg.desktop


	if [ "$PACKAGE_AUDIO_PRODUCTION" != "" ]
	then
        cat > /usr/local/share/applications/ardour.desktop << EOF
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Name=Ardour Digital Audio Workstation
Comment=Record, mix and master multi-track audio
Exec=ardour2 %U
Terminal=false
Type=Application
Icon=/usr/local/share/ardour2/icons/ardour_icon_48px.png
Categories=AudioVideo;Audio;
MimeType=application/x-ardour;
EOF
	fi

	mv /etc/X11/xorg.conf /etc/X11/xorg.conf.`date +%s`	 > /dev/null 2>&1
    
    echo "link /tmpfs shm" >> /etc/devfs.conf
    
	mv /etc/devfs.rules /etc/devfs.rules.`date +%s`	 > /dev/null 2>&1
	
	cat >> /etc/devfs.rules << EOF
[devfsrules_common=7]
add path 'devstat' mode 444
add path 'ad[0-9]*' mode 666
add path 'da[0-9]*' mode 666
add path 'acd[0-9]*' mode 666
add path 'cd[0-9]*' mode 666
add path 'cuaU[0-9]*' mode 666
add path 'cuad[0-9]*' mode 666
add path 'bpf[0-9]*' mode 666
add path 'bpf' mode 666
add path 'fuse' mode 666
add path 'mmcsd[0-9]*' mode 666
add path 'pass[0-9]*' mode 666
add path 'xpt[0-9]*'    mode 666
add path 'ugen[0-9]*' mode 666
add path 'usbctl' mode 666
add path 'usb/*' mode 666
add path 'lpt[0-9]*' mode 666
add path 'ulpt[0-9]*' mode 666
add path 'unlpt[0-9]*' mode 666
add path 'fd[0-9]*' mode 666
add path 'uscan[0-9]*' mode 666
add path 'video[0-9]*' mode 666
add path 'ukbd[0-9]*' mode 666
add path 'dvb/*' mode 666
add path 'vmm/*' mode 66
add path 'msdosfs/*' mode 666
add path 'dri/*' mode 666
add path 'mdctl' mode 666 
add path 'md[0-9]' mode 666
add path 'uhid[0-9]' mode 666
add path 'uvhid[0-9]' mode 666
add path 'vkbd[0-9]' mode 666
add path 'vkbdctl[0-9]' mode 666
EOF

	if [ ! -d /usr/local/share/xsessions ]
	then
		mkdir -p /usr/local/share/xsessions
	fi

	for i in $DESKTOP;
		do
			case $i in
				'kde')
			cat > /usr/local/share/xsessions/kde.desktop << EOF
[Desktop Entry]
Version=1.0
Name=KDE
Comment=Use this session to run KDE as your desktop environment
Exec=startkde
Icon=
Type=Application
EOF
					;;
				'fluxbox')
			cat > /usr/local/share/xsessions/fluxbox.desktop << EOF
[Desktop Entry]
Version=1.0
Name=fluxbox
Comment=Use this session to run fluxbox as your desktop environment
Exec=fluxbox
Icon=
Type=Application
EOF
					;;
				'windowmaker')
			cat > /usr/local/share/xsessions/wmaker.desktop << EOF
[Desktop Entry]
Version=1.0
Name=Window Maker
Comment=Use this session to run WindowMaker as your desktop environment
Exec=wmaker
Icon=
Type=Application
EOF
					;;
				'cinnamon')
					SOUND=`sysctl -n hw.snd.default_unit`
			cat >> /usr/local/etc/pulse/default.pa << EOF
set-default-sink $SOUND
set-default-source $SOUND
EOF
					;;
				*)
					;;
			esac
	done
	unset i

	mv /usr/local/etc/X11/xinit/xinitrc	\
		/usr/local/etc/X11/xinit/xinitrc.`date +%s` 1>&2

	cat >> /usr/local/etc/X11/xinit/xinitrc << EOF
export LC_ALL=ja_JP.UTF-8
export LANGUAGE=ja_JP.UTF-8
export LANG=ja_JP.UTF-8
EOF

	/compat/linux/usr/bin/localedef -i ja_JP -f UTF-8 ja_JP.UTF-8

	settingIm

	cat >> /usr/local/etc/X11/xinit/xinitrc << EOF
if [ ! -f \$HOME/.nspluginwrapper_setup -a -f /usr/local/bin/nspluginwrapper ]
then
        nspluginwrapper -a -i
        touch \$HOME/.nspluginwrapper_setup
fi

case \$1 in
    'gnome-session')
        if [ ! -f \$HOME/.dconf_gnome_setup ]
        then
                #gsettings set org.gnome.settings-daemon.plugins.keyboard active false
                dconf write /org/gnome/desktop/interface/gtk-im-module "'ibus'"
                dconf write /org/gnome/desktop/input-sources/sources "[('ibus', '$IM_ENGINE')]"
                touch \$HOME/.dconf_gnome_setup
        fi
        ;;
    'mate-session')
        if [ ! -f \$HOME/.dconf_mate_setup ]
        then
                dconf write /org/mate/marco/general/theme "'Menta'"
                dconf write /org/mate/desktop/interface/icon-theme "'matefaenza'"
                dconf write /org/mate/desktop/peripherals/mouse/cursor-theme "'mate'"
                dconf write /org/mate/notification-daemon/theme "'slider'"
                touch \$HOME/.dconf_mate_setup
        fi
        ;;
    'cinnamon-session-cinnamon')
        if [ ! -f \$HOME/.dconf_cinnamon_setup ]
        then
                dconf write /org/cinnamon/desktop/interface/icon-theme "'matefaenza'"
                dconf write /org/cinnamon/desktop/interface/cursor-theme "'mate'"
                dconf write /org/cinnamon/desktop/interface/gtk-theme "'Menta'"
                dconf write /org/cinnamon/desktop/wm/preferences/theme "'Menta'"
                dconf write /org/cinnamon/theme/name "'cinnamon'"
                touch \$HOME/.dconf_cinnamon_setup
        fi
        ;;
    *)
        ;;
esac

exec \$1
EOF

}

### Execute

checkRoot
checkArch
checkVersion
checkVirtual
portsUpdate
while [ "$CONFIRM" == "" ]
do
	selectPackages
	confirm
done
install
setup
mount -a
service kld start
service devfs restart
service -R
