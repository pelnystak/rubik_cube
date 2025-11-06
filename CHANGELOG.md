# Changelog

Wszystkie znaczące zmiany w projekcie będą dokumentowane w tym pliku.

Format oparty na [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
projekt używa [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-XX

### Dodane
- 🎮 Pełna implementacja kostki Rubika 3x3x3
- 🎨 Proceduralnie generowana geometria 3D (SceneKit)
- 🖐️ System gestów:
  - Pan - obracanie całej kostki
  - Swipe - obracanie warstw
  - Pinch - zoom kamery
  - Tap - przygotowane do przyszłych funkcji
- 🌟 Realistyczne oświetlenie:
  - Światło główne z cieniami
  - Światło wypełniające
  - Światło tylne
  - Światło ambient
- 🎬 Płynne animacje z ease-in-ease-out
- 📊 Licznik ruchów
- 🔄 Funkcje:
  - Scramble (25 losowych ruchów)
  - Reset (powrót do stanu rozwiązanego)
  - Undo (cofnięcie ostatniego ruchu)
  - Reset widoku (powrót do domyślnego kąta kamery)
- ✅ Detekcja ułożenia kostki
- 📳 Wibracja haptyczna przy ruchach
- 🎨 Standardowe kolory międzynarodowe
- 📐 Notacja Singmaster (U, D, F, B, R, L + prime)
- 🏗️ Architektura MVVM z separacją warstw
- 📱 Obsługa orientacji: Portrait + Landscape
- 🌙 Dark mode jako domyślny
- 📖 Pełna dokumentacja projektu
- 🛠️ Przewodnik konfiguracji Xcode

### Techniczne
- Swift 5.9+
- iOS 17.0+
- SwiftUI dla UI
- SceneKit dla 3D
- Combine dla reaktywności
- UIKit dla gestów
- Physically Based Rendering (PBR)
- Quaterniony dla rotacji bez gimbal lock
- Proceduralna geometria (bez zewnętrznych modeli 3D)

## [Unreleased] - Planowane funkcje

### Do dodania
- 🧩 Solver (algorytm CFOP/Kociemba)
- 📚 Tutorial interaktywny
- 🎵 Efekty dźwiękowe
- ⏱️ Timer i statystyki
- 🌐 Multiplayer
- 🎨 Skórki (skins)
- 🤖 AI opponent
- 📱 Apple Watch app
- 🎓 Pattern library
- 🧪 Unit tests
- 🧪 UI tests
- 📊 Zaawansowane statystyki
- 🏆 Osiągnięcia (achievements)
- 📤 Eksport rozwiązań
- 📥 Import scrambles
- 🎥 Replay rozwiązań
- 🔊 Ustawienia dźwięku
- 📱 Ustawienia haptyki
- 🌍 Lokalizacja (i18n)
- ♿ Accessibility

## Historia wersji

### [0.1.0] - Development
- Inicjalna wersja developmentowa
- Podstawowa struktura projektu

---

**Legenda:**
- 🎮 Gameplay
- 🎨 Wizualizacja
- 🖐️ Interakcja
- 🌟 Grafika
- 🎬 Animacje
- 📊 UI/UX
- 🔄 Funkcje
- ✅ Logika
- 📳 Feedback
- 🏗️ Architektura
- 📱 Platform
- 🌙 Tryby
- 📖 Dokumentacja
- 🛠️ Narzędzia
- 🧩 Algorytmy
- 🎵 Audio
- ⏱️ Pomiary
- 🌐 Network
- 🤖 AI
- 🧪 Testy
- 🏆 Gamification
- 🔊 Ustawienia
- 🌍 Internationalization
- ♿ Accessibility
