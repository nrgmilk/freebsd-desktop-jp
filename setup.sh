#!/bin/sh

export ASSUME_ALWAYS_YES=yes
export FORCE_PKG_REGISTER=1
LINUX=1

### Functions

selectDesktop () {
	DESKTOP=`dialog  --stdout --no-tags --nocancel --checklist \
							"Select desktop environment. " 20 76 8 \
							mate MATE on  \
							xfce Xfce off \
							lxde LXDE off \
							kde KDE off \
							gnome GNOME off \
							fluxbox Fluxbox off \
							awesome awesome off \
							openbox openbox off \
							windowmaker "Window Maker" off \
							i3 i3 off \
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
									kde ja-kde-l10n "
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
									i3 i3status "
					;;
				'openbox')
					PACKAGE_DESKTOP="$PACKAGE_DESKTOP\
									openbox "
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

			case $IM_ENGINE in
				'mozc-jp')
					PACKAGE_IM="ja-ibus-mozc "
					;;
				'anthy')
					PACKAGE_IM="ja-ibus-anthy "
					;;
				'skk')
					PACKAGE_IM="ja-ibus-skk "
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
						sed -i -e \
							"s@<language>.*</language>@<language>ja</language>@" \
							/usr/local/share/ibus/component/mozc.xml
						sed -i -e \
							"s@<rank>.*</rank>@<rank>99</rank>@" \
							/usr/local/share/ibus/component/mozc.xml
						sed -i -e \
							"s@<layout>.*</layout>@<layout>us</layout>@" \
							/usr/local/share/ibus/component/mozc.xml
						;;
					'anthy')
						sed -i -e \
							"s@<layout>.*</layout>@<layout>us</layout>@" \
							/usr/local/share/ibus/component/anthy.xml
						;;
					'skk')
						sed -i -e \
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
						sed -i -e \
							"s@<language>.*</language>@<language>ja</language>@" \
							/usr/local/share/ibus/component/mozc.xml
						sed -i -e \
							"s@<rank>.*</rank>@<rank>99</rank>@" \
							/usr/local/share/ibus/component/mozc.xml
						sed -i -e \
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
\$XIM_PROGRAM \$XIM_ARGS
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
export XIM_ARGS=""
\$XIM_PROGRAM \$XIM_ARGS &
EOF
				;;
	esac

}

selectExtra () {
	EXTRA=`dialog  --stdout --no-tags --nocancel --checklist \
					"Select extra packages. " 14 76 14 \
					firefox "Firefox" off  \
					chromium "Chrome" off \
					thunderbird "Thunderbird" off \
					flash "Adobe Flash Player" off \
					libreoffice "LibreOffice" off \
					vlc "VLC media player" off \
					smplayer "SMPlayer" off \
					geany "Geany" off \
					vim "Vim" off \
					emacs24 "Emacs" off \
					openjdk8 "OpenJDK 8" off \
					wine "WINE" off \
					py27-mcomix "MComix" off \
					gimp "GIMP" off \
					zsh "ZSH" off \
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
					LINUX=1
					;;
				'libreoffice')
					PACKAGE_EXTRA="$PACKAGE_EXTRA\
								  libreoffice ja-libreoffice "
					;;
				'firefox')
					PACKAGE_EXTRA="$PACKAGE_EXTRA\
						          firefox firefox-i18n "
					;;
				'thunderbird')
					PACKAGE_EXTRA="$PACKAGE_EXTRA\
						          thunderbird thunderbird-i18n "
					;;
				'wine')
					if [ $ARCH == "amd64" ]
					then
						PACKAGE_EXTRA="$PACKAGE_EXTRA\
							          i386-wine-devel "
					else
						PACKAGE_EXTRA="$PACKAGE_EXTRA\
							          wine-devel "
					fi
					;;
				*)
					PACKAGE_EXTRA=$PACKAGE_EXTRA"$i ";;
			esac
	done
	unset i
}

portsUpdate () {
	if [ ! -f /var/db/portsnap/INDEX ]
	then
		portsnap --interactive fetch extract > /dev/null 2>&1 &
	else
		portsnap --interactive fetch update > /dev/null 2>&1 &
	fi
}

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

checkRoot () {
	if [ "$(id -u)" != "0" ];
	then
	   echo "This script must be run as root" 1>&2
	   exit 1
	fi
}

echoMessage () {
	dialog --msgbox "$1" 6 76
}

addRcConf () {
	EXSIST=`egrep -c "^$1" /etc/rc.conf`
	if [ $EXSIST -ne 0 ]
	then
		sed -i -e "s/^$1/#$1/" /etc/rc.conf
	fi
	echo $1"=\"$2\"" >> /etc/rc.conf
	unset $EXSIST
}

addFstab () {
	EXSIST=`egrep -c "^$1" /etc/fstab`
	if [ $EXSIST -eq 0 ]
	then
		echo "$2" >> /etc/fstab
	fi
	unset $EXSIST
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
	CONFIRM_PACKAGE=''
	for i in $PACKAGE_DESKTOP
	do
		CONFIRM_PACKAGE=$CONFIRM_PACKAGE"$i\n"
	done
	unset i
	for i in $PACKAGE_IM
	do
		CONFIRM_PACKAGE=$CONFIRM_PACKAGE"$i\n"
	done
	unset i
	for i in $PACKAGE_EXTRA
	do
		CONFIRM_PACKAGE=$CONFIRM_PACKAGE"$i\n"
	done
	unset i
	CONFIRM=1
	dialog  --defaultno --yesno \
							"These packages are installed. \
							\n\n$CONFIRM_PACKAGE" 20 76
						
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
	if [ "$LINUX" != "" ] 
	then
		kldload linux
		addRcConf linux_enable "YES"
		addFstab proc "proc /proc procfs rw 0 0"
		addFstab linprocfs "linprocfs /compat/linux/proc linprocfs rw 0 0"
		addFstab linsysfs "linprocfs /compat/linux/sys linsysfs rw 0 0"
	fi
	
	pkg install -y 	xorg-minimal \
					hal \
					dbus \
					setxkbmap \
					xterm \
					ja-font-migu \
					urwfonts-ttf \
					droid-fonts-ttf \
					slim \
					linux_base-c6
	pkg install -y $PACKAGE_DESKTOP
	pkg install -y $PACKAGE_IM
	pkg install -y $PACKAGE_EXTRA

	if [ "$PORTS_EXTRA" != "" ]
	then
		for i in $PORTS_EXTRA
		do
			make BATCH=yes -C /usr/ports/$i install clean
		done
		unset i
	fi

	sed -i -e "s/^#sessiondir/sessiondir/" /usr/local/etc/slim.conf
	sed -i -e "s/^login_cmd/#login_cmd/" /usr/local/etc/slim.conf
	echo "login_cmd exec /bin/sh - /usr/local/etc/X11/xinit/xinitrc %session" \
			>> /usr/local/etc/slim.conf

	addRcConf devd_enable "YES"
	addRcConf devfs_enable "YES"
	addRcConf devfs_system_ruleset "devfsrules_common"
	addRcConf hald_enable "YES"
	addRcConf dbus_enable "YES"
	addRcConf slim_enable "YES"
	addFstab fdesc "fdesc /dev/fd fdescfs rw 0 0"
	
	mv /etc/devfs.rules /etc/devfs.rules.`date +%s`	 > /dev/null 2>&1
	
	cat >> /etc/devfs.rules << EOF
[devfsrules_common=7]
add path 'ad[0-9]*' mode 666
add path 'da[0-9]*' mode 666
add path 'acd[0-9]*' mode 666
add path 'cd[0-9]*' mode 666
add path 'cuaU[0-9]*' mode 666
add path 'cuad[0-9]*' mode 666
add path 'bpf[0-9]*' mode 666
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
EOF

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

	settingIm

	cat >> /usr/local/etc/X11/xinit/xinitrc << EOF
if [ ! -f \$HOME/.nspluginwrapper_setup -a -f /usr/local/bin/nspluginwrapper ]
then
        nspluginwrapper -a -i
        touch \$HOME/.nspluginwrapper_setup
fi

if [ ! -f \$HOME/.dconf_setup -a \$1 == "gnome-session" ]
then
		#gsettings set org.gnome.settings-daemon.plugins.keyboard active false
        dconf write /org/gnome/desktop/interface/gtk-im-module "'ibus'"
        dconf write /org/gnome/desktop/input-sources/sources "[('ibus', '$IM_ENGINE')]"
        touch \$HOME/.dconf_setup
fi

exec \$1
EOF

}

### Execute

checkRoot
checkArch
portsUpdate
while [ "$CONFIRM" == "" ]
do
	selectPackages
	confirm
done
install
mount -a
service devd restart
service devfs restart
service hald start
service dbus start
service slim start
