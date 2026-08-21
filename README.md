# BlueGate 3x-ui Subscription Theme

تم اختصاصی Subscription برای 3x-ui با زبان طراحی BlueGate / BluePing.

## امکانات

- طراحی responsive و mobile-first مطابق ظاهر BlueGate
- Dark / Light mode
- نمایش Live وضعیت Online/Offline
- مصرف، دانلود، آپلود، حجم باقی‌مانده و تاریخ انقضا
- Polling زنده از `?format=info`
- لینک اصلی Subscription + JSON + Clash/Mihomo
- کپی سریع کانفیگ‌ها
- نمایش اعلان 3x-ui
- اتصال به Support URL تنظیم‌شده در پنل
- بدون وابستگی به CDN یا asset خارجی
- installer، updater و uninstaller
- بکاپ خودکار تم قبلی و دیتابیس قبل از تغییر تنظیمات

## سازگاری

برای نسخه‌های 3x-ui که قابلیت **Custom Subscription Templates / subThemeDir** را دارند.
قالب در مسیر زیر نصب می‌شود:

```text
/etc/3x-ui/sub_templates/bluegate
```

## نصب از Clone

```bash
git clone https://github.com/USERNAME/bluegate-3xui-sub-theme.git
cd bluegate-3xui-sub-theme
sudo bash install.sh
```

## نصب مستقیم از GitHub

`USERNAME` را با نام GitHub خودت جایگزین کن:

```bash
sudo BGT_REPO="USERNAME/bluegate-3xui-sub-theme" \
  bash <(curl -fsSL https://raw.githubusercontent.com/USERNAME/bluegate-3xui-sub-theme/main/install.sh)
```

Installer در نصب SQLite معمول 3x-ui تلاش می‌کند `subThemeDir` را هم خودکار تنظیم کند.
اگر `sqlite3` نصب نباشد یا PostgreSQL/Docker داشته باشی، فقط این مسیر را در پنل وارد کن:

```text
Settings → Subscription → Information → Sub Theme Directory
/etc/3x-ui/sub_templates/bluegate
```

سپس x-ui را restart کن.

## تست

لینک subscription را در مرورگر با HTML mode باز کن:

```text
https://SUB-DOMAIN/sub/SUB-ID?html=1
```

## بروزرسانی

```bash
sudo BGT_REPO="USERNAME/bluegate-3xui-sub-theme" bash update.sh
```

یا دوباره `install.sh` را اجرا کن. قبل از جایگزینی، از تم قبلی backup می‌گیرد.

## حذف

```bash
sudo bash uninstall.sh
```

## تنظیمات اختیاری

مسیر نصب متفاوت:

```bash
sudo BLUEGATE_THEME_DIR="/opt/bluegate-sub-theme" bash install.sh
```

جلوگیری از دست‌کاری خودکار SQLite:

```bash
sudo BGT_AUTO_SET=0 bash install.sh
```

## فایل‌ها

- `theme/index.html` — تم واقعی 3x-ui
- `preview.html` — پیش‌نمایش مستقل با اطلاعات نمونه
- `install.sh` — نصب و تنظیم خودکار در SQLite در صورت امکان
- `update.sh` — بروزرسانی از GitHub
- `uninstall.sh` — غیرفعال‌سازی امن
