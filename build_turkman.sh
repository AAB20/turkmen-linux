#!/bin/bash

# ==============================================================================
# سكربت بناء نظام: Turkman Linux (The Ultimate Edition)
# الوصف: يحول Ubuntu 24.04 إلى نظام خارق (AI + 100% EXE + Global Languages)
# ==============================================================================

# منع الأسئلة التفاعلية أثناء التثبيت
export DEBIAN_FRONTEND=noninteractive

echo "======================================================="
echo ">>> بدء بناء إمبراطورية Turkman Linux..."
echo "======================================================="

# 1. التحديث وإعداد المستودعات
echo ">>> [1/9] تحديث النظام وإضافة المفاتيح..."
apt update && apt upgrade -y
apt install software-properties-common wget curl git gpg -y

# ==============================================================================
# 2. دعم تطبيقات ويندوز الاحترافي (نسبة تشغيل قصوى)
# ==============================================================================
echo ">>> [2/9] تفعيل دعم EXE بنسبة 100% (Wine Staging + Libraries)..."

# تفعيل معمارية 32-بت
dpkg --add-architecture i386
mkdir -p /etc/apt/keyrings

# إضافة مستودع WineHQ الرسمي (للحصول على أحدث نسخة Staging)
wget -O - https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key -
wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources
apt update

# تثبيت Wine Staging (أقوى من النسخة العادية)
apt install --install-recommends winehq-staging -y

# تثبيت أدوات مساعدة لفك ضغط ملفات ويندوز
apt install winbind cabextract p7zip-full unrar -y

# تثبيت Winetricks (مدير المكتبات)
wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x winetricks
mv winetricks /usr/local/bin

# تثبيت Bottles و Lutris (لضمان تشغيل البرامج المعقدة والألعاب)
apt install flatpak -y
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.usebottles.bottles -y
apt install lutris steam-installer gamemode -y

# ==============================================================================
# 3. دعم اللغات العالمية (Global Support)
# ==============================================================================
echo ">>> [3/9] تثبيت اللغات والخطوط العالمية..."

# تثبيت خطوط Google Noto (تغطي كل لغات العالم)
apt install fonts-noto fonts-noto-cjk fonts-noto-color-emoji fonts-dejavu fonts-symbola -y

# تثبيت خطوط مايكروسوفت الأصلية
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections
apt install ttf-mscorefonts-installer -y

# توليد إعدادات المنطقة لجميع الدول
apt install locales-all -y

# تثبيت لوحة المفاتيح Fcitx5 (للغات الآسيوية والمعقدة)
apt install fcitx5 fcitx5-all kde-config-fcitx5 im-config -y
im-config -n fcitx5

# ==============================================================================
# 4. الواجهة الرسومية (KDE Plasma - Windows 11 Style)
# ==============================================================================
echo ">>> [4/9] تحويل الواجهة إلى Windows 11..."

# تثبيت واجهة KDE
apt install kubuntu-desktop sddm -y
echo "/usr/sbin/sddm" > /etc/X11/default-display-manager
dpkg-reconfigure -f noninteractive sddm

# تحميل الثيمات والأيقونات
mkdir -p /tmp/theme_build
cd /tmp/theme_build

# أيقونات Win11
git clone https://github.com/yeyushengfan258/Win11-icon-theme.git
cd Win11-icon-theme
./install.sh -a
cd ..

# سمات النوافذ (WhiteSur)
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git
cd WhiteSur-gtk-theme
./install.sh -l -c Dark -t all

# ==============================================================================
# 5. الذكاء الاصطناعي (Offline AI - Ollama)
# ==============================================================================
echo ">>> [5/9] دمج الذكاء الاصطناعي..."

# تثبيت Ollama
curl -fsSL https://ollama.com/install.sh | sh

# تحميل الموديل (Llama 3.2)
echo ">>> جاري تحميل الموديل... (قد يستغرق وقتاً حسب الإنترنت)"
nohup ollama serve > /dev/null 2>&1 &
PID_OLLAMA=$!
sleep 20
ollama pull llama3.2:1b
kill $PID_OLLAMA

# واجهة الشات (Python + Streamlit)
apt install python3-pip -y
pip3 install streamlit --break-system-packages

cat <<EOF > /usr/local/bin/turkman-chat.py
import streamlit as st
import os

st.set_page_config(page_title="Turkman AI", page_icon="🧠")
st.title("🤖 Turkman AI - System Intelligence")
st.success("Secure. Offline. Fast.")

user_input = st.text_input("Ask me anything / اسألني / Bana sor:", "")

if st.button("Generate Answer"):
    if user_input:
        with st.spinner('Processing...'):
            cmd = f'ollama run llama3.2:1b "{user_input}"'
            stream = os.popen(cmd)
            output = stream.read()
            st.markdown(output)
EOF

# أيقونة سطح المكتب للذكاء
cat <<EOF > /usr/share/applications/turkman-ai.desktop
[Desktop Entry]
Name=Turkman AI
Comment=Offline AI Assistant
Exec=streamlit run /usr/local/bin/turkman-chat.py
Icon=utilities-terminal
Terminal=true
Type=Application
Categories=Education;Science;Utility;
EOF

# ==============================================================================
# 6. البرامج والإنتاجية (Office & Performance)
# ==============================================================================
echo ">>> [6/9] تثبيت الأوفيس وتحسين السرعة..."

# LibreOffice العالمي
apt install libreoffice libreoffice-kf5 -y
apt install libreoffice-l10n-ar libreoffice-help-ar \
            libreoffice-l10n-tr libreoffice-help-tr \
            libreoffice-l10n-ru libreoffice-l10n-fr \
            libreoffice-l10n-zh-cn libreoffice-l10n-es -y

# أدوات الوسائط
apt install ubuntu-restricted-extras vlc ffmpeg okular -y

# تحسين الرام والأداء (Preload + ZRAM)
apt install preload zram-tools -y
echo "ALGO=lz4" >> /etc/default/zramswap
echo "PERCENT=50" >> /etc/default/zramswap

# النظام البيئي (ربط الهاتف + استعادة النظام)
apt install kdeconnect timeshift -y

# ==============================================================================
# 7. الهوية البصرية (Branding)
# ==============================================================================
echo ">>> [7/9] تصميم الهوية (Turkman Linux)..."

mkdir -p /usr/share/backgrounds/turkman/

# إنشاء الخلفية بالكود
cat <<EOF > /usr/share/backgrounds/turkman/wallpaper.svg
<svg width="1920" height="1080" xmlns="http://www.w3.org/2000/svg">
    <defs>
        <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" style="stop-color:#003366;stop-opacity:1" />
            <stop offset="100%" style="stop-color:#0088cc;stop-opacity:1" />
        </linearGradient>
    </defs>
    <rect width="1920" height="1080" fill="url(#grad1)" />
    <text x="50%" y="45%" dominant-baseline="middle" text-anchor="middle" font-family="sans-serif" font-size="110" fill="white" font-weight="bold" letter-spacing="5">TURKMAN LINUX</text>
    <text x="50%" y="58%" dominant-baseline="middle" text-anchor="middle" font-family="sans-serif" font-size="35" fill="#cceeff">Ultimate Edition - All Languages - AI Powered</text>
    <path d="M960,200 L1000,300 L920,300 Z" fill="white" transform="rotate(30 960 250)" opacity="0.8"/>
    <circle cx="980" cy="240" r="15" fill="white" opacity="0.9"/>
</svg>
EOF

# إعدادات الخلفية الافتراضية
mkdir -p /etc/skel/.config/plasma-org.kde.plasma.desktop/contents/defaults
cat <<EOF > /etc/skel/.config/plasma-org.kde.plasma.desktop/contents/defaults/Image
[Desktop Entry]
Image=file:///usr/share/backgrounds/turkman/wallpaper.svg
EOF

# تغيير اسم النظام
sed -i 's/NAME="Ubuntu"/NAME="Turkman Linux"/g' /etc/os-release
sed -i 's/PRETTY_NAME="Ubuntu 24.04 LTS"/PRETTY_NAME="Turkman Linux Ultimate"/g' /etc/os-release
echo "Turkman Linux Ultimate \n \l" > /etc/issue

# ==============================================================================
# 8. التنظيف (Cleanup)
# ==============================================================================
echo ">>> [8/9] تنظيف النظام لتقليل حجم ISO..."
rm -rf /tmp/*
apt autoremove -y
apt clean
rm -rf /var/lib/apt/lists/*
rm -rf /root/.cache

echo "======================================================="
echo ">>> [9/9] اكتملت المهمة! Turkman Linux جاهز."
echo ">>> يمكنك الآن الضغط على Next في Cubic."
echo "======================================================="
