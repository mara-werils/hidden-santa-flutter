# Assignment 4 – Gestures, Dynamic Elements, and Adaptive Theme/Language

**Week:** 4  
**Points:** 15  
**Lecture Covered:** Types and Null Safety  

---

## Objective

Implement gesture-based interactions, dynamic UI updates, and automatic adaptation to the system’s theme and language. Ensure at least one fully functional page demonstrates these features.

---

## Features Implemented

### 1. One Fully Functional Page
- `SettingsScreen` is fully interactive and logically complete.
- Language switching, theme adaptation, and gesture interactions are all implemented here.

### 2. Gestures
- **Long Press:** Changes theme (light/dark).
- **Swipe Gesture:** (Left/Right) also toggles theme.
- Gestures perform real actions like modifying the UI theme in real-time.

### 3. Dynamic UI Updates
- Language switching buttons instantly change app language.
- Widgets update live without needing a restart.

### 4. Theme Switching (System-based)
- `ThemeMode.system` is implemented.
- App adapts light/dark theme automatically based on device settings.

### 5. Language Switching (System-based)
- Supported locales: **English (en)**, **Russian (ru)**, **Kazakh (kk)**
- Uses `localeResolutionCallback` with fallback to `kk` for unsupported locales.

```dart
localeResolutionCallback: (locale, supportedLocales) {
  if (locale == null) return const Locale('kk');
  for (var supportedLocale in supportedLocales) {
    if (supportedLocale.languageCode == locale.languageCode) {
      return supportedLocale;
    }
  }
  return const Locale('kk');
},
```

---

![image](https://github.com/user-attachments/assets/d5361209-b7aa-4fe2-939a-cc81d2916046)
![image](https://github.com/user-attachments/assets/df709e18-4d61-4f0b-a83a-611ef4329fe8)
![image](https://github.com/user-attachments/assets/de1f3fa4-cce0-4064-8131-5834c743b079)
![image](https://github.com/user-attachments/assets/d99833fb-1548-4489-ad66-83e760cad6ad)
![image](https://github.com/user-attachments/assets/b2e02b7c-853b-4b38-84eb-62136de6ec15)
![image](https://github.com/user-attachments/assets/22a69cfc-8779-40c6-b0f0-d5891e49cf6f)
![image](https://github.com/user-attachments/assets/3eb76505-d6f9-4552-b3a1-9b90c0564ad4)
