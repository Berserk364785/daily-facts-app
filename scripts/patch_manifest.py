"""Патчит android/app/src/main/AndroidManifest.xml:
- добавляет нужные разрешения
- регистрирует FactWidgetProvider

Запускается из codemagic.yaml как отдельный шаг сборки, чтобы не
встраивать многострочный Python внутрь YAML (это ломает парсер YAML).
"""
import os

manifest_path = "android/app/src/main/AndroidManifest.xml"

if not os.path.exists(manifest_path):
    raise SystemExit(f"Не найден {manifest_path}")

with open(manifest_path, "r", encoding="utf-8") as f:
    content = f.read()

if "POST_NOTIFICATIONS" not in content:
    permissions = (
        '    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />\n'
        '    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />\n'
        '    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />\n'
        '    <uses-permission android:name="android.permission.INTERNET" />\n'
    )
    content = content.replace("<application", permissions + "\n    <application", 1)

    receiver = (
        '        <receiver android:name=".FactWidgetProvider" android:exported="false">\n'
        '            <intent-filter>\n'
        '                <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />\n'
        '            </intent-filter>\n'
        '            <meta-data\n'
        '                android:name="android.appwidget.provider"\n'
        '                android:resource="@xml/fact_widget_info" />\n'
        '        </receiver>\n'
    )
    content = content.replace("</application>", receiver + "    </application>", 1)

    with open(manifest_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Manifest patched.")
else:
    print("Manifest already patched, skipping.")
