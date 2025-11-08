# 🚀 Quick Start - Rubik's Cube 3D

## ⚡ Szybkie uruchomienie (5 minut)

### 1️⃣ Otwórz Xcode

```bash
# Wymagania: Xcode 15+ na macOS
open -a Xcode
```

### 2️⃣ Utwórz nowy projekt

1. **File → New → Project** (`Cmd + Shift + N`)
2. Wybierz:
   - Platform: **iOS**
   - Template: **App**
3. Wypełnij:
   - Product Name: `RubiksCubeApp`
   - Interface: **SwiftUI** ⚠️
   - Language: **Swift** ⚠️
4. **Next** → Wybierz lokalizację → **Create**

### 3️⃣ Dodaj pliki

Przeciągnij całą folder `RubiksCubeApp/` do projektu w Xcode:

- ✅ Copy items if needed
- ✅ Create groups
- ✅ Add to target: RubiksCubeApp

### 4️⃣ Ustaw minimum deployment

W ustawieniach projektu:
- **General → Minimum Deployments**: `iOS 17.0`

### 5️⃣ Build & Run

- Wybierz symulator: **iPhone 15 Pro**
- Kliknij ▶️ lub `Cmd + R`

## 🎮 Jak grać

### Gesty:

| Gest | Akcja |
|------|-------|
| 👆 **Przeciągnij** | Obraca całą kostkę |
| ⬆️ **Swipe** | Obraca warstwę |
| 🤏 **Pinch** | Zoom kamery |

### Przyciski:

- 🔀 **Pomieszaj** - losowe 25 ruchów
- 🔄 **Reset** - powrót do ułożenia
- ↩️ **Cofnij** - undo ostatniego ruchu
- 📷 **Reset widoku** - domyślny kąt

## 📁 Struktura projektu

```
RubiksCubeApp/
├── 📱 App/             # Główny plik aplikacji
├── 🧩 Models/          # Logika kostki
├── 🎨 Views/           # Interfejs użytkownika
├── 🎬 SceneKit/        # Rendering 3D
├── 👆 Gestures/        # Obsługa gestów
└── 🛠️ Utils/           # Narzędzia pomocnicze
```

## 🐛 Rozwiązywanie problemów

### Nie kompiluje się?

```bash
# Wyczyść build folder
Cmd + Shift + K
# Rebuild
Cmd + B
```

### Czarny ekran?

- Sprawdź czy `RubiksCubeApp.swift` ma `@main`
- Sprawdź czy `ContentView()` jest w `WindowGroup`

### Gesty nie działają?

- Użyj fizycznego urządzenia dla pełnej funkcjonalności
- W symulatorze: używaj myszy, nie trackpada

## 📚 Więcej informacji

- 📖 **README.md** - pełna dokumentacja
- 🏗️ **ARCHITECTURE.md** - architektura systemu
- 🛠️ **SETUP_GUIDE.md** - szczegółowa konfiguracja
- 📋 **PROJECT_SUMMARY.md** - podsumowanie

## ✅ Checklist

- [ ] Xcode 15+ zainstalowane
- [ ] Projekt utworzony (SwiftUI + Swift)
- [ ] Pliki dodane do projektu
- [ ] Minimum deployment: iOS 17.0
- [ ] Build sukces (Cmd + B)
- [ ] Aplikacja uruchomiona (Cmd + R)
- [ ] Kostka się obraca! 🎉

---

**Gotowe w 5 minut! Miłego grania! 🎲✨**
