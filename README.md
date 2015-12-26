# freebsd-desktop-jp

This script is automatic setting for desktop environment and Japanese input for FreeBSD.

## 目標
* 完全自動設定
* FreeBSDデスクトップ利用の利便性を高める。

## 利用する対象
* FreeBSDでのデスクトップ環境の構築がわからない
* いろんなデスクトップ環境をサクッと試してみたい
* パッケージをインストールしてみたものの設定が良くわからない
* そもそもviやeeの操作方法が難解で詰んだ

## 動作環境
* FreeBSD 10.2 (amd64/i386)
* FreeBSD 11-CURRENT (amd64/i386)
* 9以下は現状動きません
* インターネットに接続できること
* 正しいキーボードの設定が設定済みであること(日本語なら/etc/rc.confのkeymapがjPになっているか)

## 使い方
* fetch http://git.io/vE0oh -o setup.sh
* rootになってsh setup.shで起動

## 設定内容

### パッケージの選択

#### デスクトップ環境(WMも同義とする) 
* MATE
* Xfce
* KDE
* GNOME3
* LXDE
* Cinnamon
* Lumina
* Fluxbox
* awesome
* openbox
* Window Maker

#### 日本語入力 (いずれかの組み合わせ1つ)
* iBus (mozc/anthy/skk)
* fcitx (mozc/anthy/skk)
* uim (mozc/anthy)

#### ご一緒にいかが？
* Adobe Flash Player
* Firefox (Web browser)
* Chrome (Web browser)
* Thunderbird (Mail client)
* Sylpheed (Mail client)
* LibreOffice (Office suite)
* LyX (Document Processor)
* Filezilla (FTP and SFTP client)
* XChat (IRC client)
* Transmission (BitTorrent client)
* qBittorrent (BitTorrent client)
* VLC (Media player)
* SMPlayer (Media player)
* Audacious (Audio player)
* GIMP (Image Manipulation)
* RawTherapee (RAW image processing)
* Darktable (Photo workflow software)
* Shotwell (Photo manager)
* Blender (3D graphics and animation software)
* Imagemagick (Image manipulation software)
* Inkscape (vector graphics editor)
* MyPaint (painting/scribbling program)
* Scribus (Comprehensive desktop publishing program)
* Synfig Studio (Vector-based 2D animation software)
* FontForge (Font editor)
* Agave (Color scheme builder)
* SANE (Scanner API tool)
* FFmpeg (Audio/video encoder/converter)
* OpenShot Video Editor (Non-linear video editor)
* Pitivi (Non-linear video editor)
* Kdenlive (Non-linear video editor)
* DVDStyler (DVD recoding and authoring programs)
* Subtitle Editor (Subtitle editor)
* Audacity (Audio Editor and Recorder)
* ardour (Multichannel digital audio workstation)
* Hydrogen (drum machine)
* LMMS (All-in-one sequencer)
* MuseScore (music composition & notation software)
* SooperLooper (Live audio looping sampler)
* JACK (JACK Audio Connection Kit)
* XfBurn (CD/DVD Burning)
* K3B (CD/DVD Burning)
* Brasero (CD/DVD Burning)
* epdfview (PDF viewer)
* MComix (Comic viewer)
* calibre (E-book viewer)
* Geany (Develop environment)
* Vim (Develop environment)
* Emacs (Develop environment)
* Meld (Visual diff and merge tool)
* OpenJDK 8 (Java development kit)
* VirtualBox (Virtual machine)
* Wine (Windows compatibility environment)
* ADB (Android debug bridge)
* ClamAV (Antivirus)
* TOR (Anonymizing overlay network for TCP)
* Wifimgr (WiFi Networks Manager)
* ZSH (Shell)
* Minecraft (Game)

### パッケージインストール

### インストールしたパッケージの設定及びデスクトップ利用に最適な設定の追加

### サービスの開始

### デスクトップログイン画面の起動


## おことわり
FreeBSDに限らずOSS環境はコロコロ仕様が変わります。
ある日突然パッケージの仕様が変わって動かなくなることもあります。
ご了承ください。
