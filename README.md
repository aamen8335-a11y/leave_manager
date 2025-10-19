# مدير الإجازات (Flutter)
- واجهة عربية بالكامل
- تبويب طلبات/موافقات/لوحة تحكم/إعدادات
- يدعم Firebase لاحقًا عند إضافة `google-services.json`

## البناء على Codemagic
- فعّل YAML workflow
- الملف `codemagic.yaml` ينشئ مجلد android تلقائيًا (`flutter create .`)
- يبني APK: `build/app/outputs/flutter-apk/app-release.apk`
