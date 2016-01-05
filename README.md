# freebsd-desktop-jp

This script is automatic setting for desktop environment and Japanese input for FreeBSD.

## 目標
* 完全自動設定
* FreeBSDデスクトップ利用の利便性を高める。

## 利用する対象
* FreeBSDでのデスクトップ環境の構築がわからない方
* いろんなデスクトップ環境をサクッと試してみたい方
* 環境構築に無駄な時間を費やしたくない方
* パッケージをインストールしてみたものの設定が良くわからない方
* そもそもviやeeの操作方法が難解で詰んだけど使ってみたい方

## 動作環境
* FreeBSD 10.2-RELEASE (amd64/i386)
* FreeBSD 11-CURRENT (amd64/i386)
* 9以下は動きません
* インターネットに接続できること
* 正しいキーボードの設定が設定済みであること(日本語なら/etc/rc.confのkeymapがjpになっているか)

## 使い方
* fetch https://git.io/vEo3o -o setup.sh
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
##### インターネット系
* Adobe Flash Player
* Firefox (Web browser)
* Chrome (Web browser)
* Thunderbird (Mail client)
* Sylpheed (Mail client)
* Filezilla (FTP and SFTP client)
* XChat (IRC client)
* Transmission (BitTorrent client)
* qBittorrent (BitTorrent client)
* TOR (Anonymizing overlay network for TCP)

##### メディアプレイヤー・ビューアー
* VLC (Media player)
* SMPlayer (Media player)
* Audacious (Audio player)
* epdfview (PDF viewer)
* MComix (Comic viewer)
* calibre (E-book viewer)

##### CD/DVD
* XfBurn (CD/DVD Burning)
* K3B (CD/DVD Burning)
* Brasero (CD/DVD Burning)

##### オフィス・文章作成
* LibreOffice (Office suite)
* LyX (Document Processor)

##### 画像編集・作成系
* GIMP (Image Manipulation)
* RawTherapee (RAW image processing)
* Darktable (Photo workflow software)
* Shotwell (Photo manager)
* Imagemagick (Image manipulation software)
* Inkscape (vector graphics editor)
* MyPaint (painting/scribbling program)
* Scribus (Comprehensive desktop publishing program)
* Synfig Studio (Vector-based 2D animation software)
* FontForge (Font editor)
* Agave (Color scheme builder)
* SANE (Scanner API tool)

##### 3D系
* Blender (3D graphics and animation software)

##### 動画編集・作成系
* FFmpeg (Audio/video encoder/converter)
* OpenShot Video Editor (Non-linear video editor)
* Pitivi (Non-linear video editor)
* Kdenlive (Non-linear video editor)
* DVDStyler (DVD recoding and authoring programs)
* Subtitle Editor (Subtitle editor)

##### 音楽編集・作成系
* Audacity (Audio Editor and Recorder)
* ardour (Multichannel digital audio workstation)
* Hydrogen (drum machine)
* LMMS (All-in-one sequencer)
* MuseScore (music composition & notation software)
* SooperLooper (Live audio looping sampler)
* JACK (JACK Audio Connection Kit)

##### 開発環境
* Geany (Develop environment)
* Vim (Develop environment)
* Emacs (Develop environment)
* Eclipse (Develop environment)
* Meld (Visual diff and merge tool)
* OpenJDK 8 (Java development kit)
* VirtualBox (Virtual machine)
* Wine (Windows compatibility environment)
* ADB (Android debug bridge)

##### その他
* ClamAV (Antivirus)
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
