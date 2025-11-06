# 🛠️ Przewodnik konfiguracji projektu Xcode

Ten dokument zawiera szczegółowe instrukcje tworzenia projektu Xcode dla aplikacji Rubik's Cube 3D.

## 📋 Metoda 1: Automatyczne tworzenie projektu

### Krok 1: Utwórz nowy projekt w Xcode

1. Otwórz Xcode
2. Wybierz **File → New → Project** (lub `Cmd + Shift + N`)
3. W oknie szablonów:
   - Platforma: **iOS**
   - Szablon: **App**
   - Kliknij **Next**

### Krok 2: Skonfiguruj projekt

Wypełnij następujące pola:

- **Product Name**: `RubiksCubeApp`
- **Team**: Wybierz swój Apple Developer Team (lub zostaw None dla developmentu lokalnego)
- **Organization Identifier**: `com.yourname` (dowolny reverse-domain identifier)
- **Bundle Identifier**: automatycznie wygenerowany (np. `com.yourname.RubiksCubeApp`)
- **Interface**: **SwiftUI** ⚠️ WAŻNE!
- **Language**: **Swift** ⚠️ WAŻNE!
- **Storage**: Core Data - **NIE zaznaczaj** (nie używamy)
- **Include Tests**: Możesz zaznaczyć jeśli chcesz pisać testy

Kliknij **Next** i wybierz lokalizację zapisu projektu.

### Krok 3: Zastąp domyślne pliki

1. **Usuń domyślne pliki:**
   - Usuń plik `ContentView.swift` (zostanie zastąpiony)
   - Zachowaj plik `RubiksCubeAppApp.swift` (lub jak się nazywa)

2. **Dodaj pliki z repozytorium:**

   W Xcode, przeciągnij folder `RubiksCubeApp/` do projektu lub:

   a. Kliknij prawym na projekt → **Add Files to "RubiksCubeApp"**

   b. Wybierz wszystkie foldery:
      - `App/`
      - `Models/`
      - `Views/`
      - `SceneKit/`
      - `Gestures/`
      - `Utils/`

   c. Zaznacz:
      - ✅ **Copy items if needed**
      - ✅ **Create groups** (nie "Create folder references")
      - ✅ **Add to target: RubiksCubeApp**

### Krok 4: Skonfiguruj strukturę projektu

Twoja struktura w Xcode powinna wyglądać tak:

```
RubiksCubeApp/
├── App/
│   └── RubiksCubeApp.swift
├── Models/
│   ├── CubeColor.swift
│   ├── Move.swift
│   ├── Cubie.swift
│   └── RubiksCube.swift
├── Views/
│   ├── ContentView.swift
│   └── RubiksCubeSceneView.swift
├── SceneKit/
│   ├── CubeRenderer.swift
│   └── CubeSceneController.swift
├── Gestures/
│   └── GestureHandler.swift
├── Utils/
│   └── Extensions.swift
├── Info.plist
└── Assets.xcassets/
```

### Krok 5: Zastąp Info.plist

1. W navigatorze projektu, kliknij na `Info.plist`
2. Zastąp zawartość plikiem `Info.plist` z repozytorium, lub:
3. Dodaj ręcznie kluczowe ustawienia:

```xml
<key>UIApplicationSceneManifest</key>
<dict>
    <key>UIApplicationSupportsMultipleScenes</key>
    <false/>
</dict>
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
</array>
```

### Krok 6: Konfiguracja Build Settings

1. Wybierz projekt w navigatorze (niebieski plik na górze)
2. Wybierz target `RubiksCubeApp`
3. Zakładka **General**:
   - **Minimum Deployments**: iOS 17.0 (lub wyższy)
   - **Supported Destinations**: iPhone
   - **Device Orientation**:
     - ✅ Portrait
     - ✅ Landscape Left
     - ✅ Landscape Right
     - ❌ Upside Down (opcjonalnie)

4. Zakładka **Build Settings**:
   - **Swift Language Version**: Swift 5 (domyślne)
   - **Enable Bitcode**: No (domyślne dla iOS 17+)

### Krok 7: Weryfikacja importów

Upewnij się, że wszystkie pliki mają poprawne importy:

```swift
// Pliki modeli
import Foundation
import SceneKit  // tylko gdzie potrzebne (CubeColor, Move)
import Combine   // tylko gdzie potrzebne (RubiksCube)

// Pliki SceneKit
import Foundation
import SceneKit
import Combine

// Pliki gestów
import Foundation
import UIKit
import SceneKit

// Pliki widoków
import SwiftUI
import SceneKit
```

### Krok 8: Build i uruchomienie

1. Wybierz urządzenie docelowe:
   - **Symulator**: iPhone 15 Pro (zalecane)
   - **Fizyczne urządzenie**: dowolny iPhone z iOS 17+

2. Kliknij **Product → Build** (`Cmd + B`)
   - Sprawdź czy nie ma błędów kompilacji

3. Jeśli build się udał, kliknij **Run** (`Cmd + R`)

## 📋 Metoda 2: Użycie Swift Package (zaawansowane)

Jeśli chcesz użyć projektu jako Swift Package:

### Krok 1: Utwórz Package.swift

Stwórz plik `Package.swift` w głównym katalogu:

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "RubiksCubeCore",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "RubiksCubeCore",
            targets: ["RubiksCubeCore"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "RubiksCubeCore",
            dependencies: [],
            path: "RubiksCubeApp",
            exclude: ["App", "Info.plist"],
            sources: ["Models", "SceneKit", "Gestures", "Utils"]
        ),
        .testTarget(
            name: "RubiksCubeCoreTests",
            dependencies: ["RubiksCubeCore"]
        ),
    ]
)
```

### Krok 2: Integracja w projekcie

1. W Xcode, wybierz **File → Add Packages...**
2. Wklej ścieżkę do lokalnego repozytorium
3. Dodaj `RubiksCubeCore` do target dependencies

## 🔧 Rozwiązywanie problemów

### Problem: "Cannot find type 'RubiksCube' in scope"

**Rozwiązanie:**
- Sprawdź czy wszystkie pliki są dodane do target membership
- W Xcode, wybierz plik → File Inspector (⌥⌘1) → Target Membership → zaznacz RubiksCubeApp

### Problem: "Use of undeclared type 'SCNVector3'"

**Rozwiązanie:**
- Dodaj import: `import SceneKit` na górze pliku

### Problem: Build fails z błędami "Circular reference"

**Rozwiązanie:**
- Usuń cykl importów
- Sprawdź czy żaden plik nie importuje sam siebie pośrednio

### Problem: Symulator pokazuje czarny ekran

**Rozwiązanie:**
- Sprawdź czy `RubiksCubeApp.swift` ma poprawną strukturę:
```swift
@main
struct RubiksCubeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Problem: Gesty nie działają w symulatorze

**Rozwiązanie:**
- Swipe: Używaj myszy, nie trackpada
- Pan: Przeciągnij z przytrzymaniem
- Pinch: Trzymaj Option i przeciągaj dla pinch

### Problem: Słaba wydajność w symulatorze

**Rozwiązanie:**
- Użyj fizycznego urządzenia dla pełnej wydajności
- Zmniejsz szczegółowość cieni: `mainLight.shadowSampleCount = 4`
- Zmniejsz antyaliasing: `scnView.antialiasingMode = .multisampling2X`

## 📱 Deployment na urządzenie fizyczne

### Wymagania

1. **Apple Developer Account** (darmowy do testowania)
2. **Urządzenie podłączone przez USB lub WiFi**

### Kroki

1. Podłącz iPhone do Mac przez USB
2. Odblokuj iPhone i zaufaj komputerowi
3. W Xcode:
   - Wybierz swoje urządzenie z listy
   - Zakładka **Signing & Capabilities**
   - Team: wybierz swój Apple ID
   - Signing Certificate: automatycznie

4. Kliknij **Run** (`Cmd + R`)

5. **Na iPhone:**
   - Otwórz **Settings → General → Device Management**
   - Zaufaj swojemu certyfikatowi developera

## 🎨 Dodatkowa konfiguracja

### Ikona aplikacji (App Icon)

1. W `Assets.xcassets`, kliknij `AppIcon`
2. Przeciągnij obrazki w rozmiarach:
   - 1024x1024 (App Store)
   - 180x180 (@3x iPhone)
   - 120x120 (@2x iPhone)
   - 167x167 (@2x iPad)
   itd.

**Wskazówka:** Użyj narzędzia online do wygenerowania wszystkich rozmiarów z jednego obrazka 1024x1024.

### Launch Screen

1. W projekcie, dodaj `LaunchScreen.storyboard` lub
2. Użyj `Info.plist` z kluczem `UILaunchScreen`

### Dark Mode

Aplikacja już obsługuje dark mode dzięki:
```swift
.preferredColorScheme(.dark)
```

Aby dodać obsługę light mode:
```swift
.preferredColorScheme(.none) // auto
```

## 📊 Monitoring wydajności

### Instruments

1. **Product → Profile** (`Cmd + I`)
2. Wybierz szablon:
   - **Time Profiler** - CPU usage
   - **SceneKit** - rendering performance
   - **Allocations** - memory usage

### FPS Counter

Dodaj w `RubiksCubeSceneView.swift`:
```swift
scnView.showsStatistics = true
```

To pokaże:
- FPS (frames per second)
- Draw calls
- Liczba poligonów

## 🧪 Testy

### Dodanie testów jednostkowych

1. **File → New → Target**
2. Wybierz **Unit Testing Bundle**
3. Stwórz `RubiksCubeTests.swift`:

```swift
import XCTest
@testable import RubiksCubeApp

final class RubiksCubeTests: XCTestCase {
    var cube: RubiksCube!

    override func setUp() {
        super.setUp()
        cube = RubiksCube()
    }

    func testInitialState() {
        XCTAssertTrue(cube.isSolved)
        XCTAssertEqual(cube.cubies.count, 26)
        XCTAssertTrue(cube.moveHistory.isEmpty)
    }

    func testMove() {
        cube.performMove(.U)
        XCTAssertEqual(cube.moveHistory.count, 1)
        XCTAssertFalse(cube.isSolved)
    }

    func testInverseMove() {
        cube.performMove(.U)
        cube.performMove(.Up)
        XCTAssertTrue(cube.isSolved)
    }

    func testScramble() {
        cube.scramble(moves: 25)
        XCTAssertEqual(cube.moveHistory.count, 25)
    }

    func testReset() {
        cube.scramble(moves: 10)
        cube.reset()
        XCTAssertTrue(cube.isSolved)
        XCTAssertTrue(cube.moveHistory.isEmpty)
    }
}
```

### Uruchomienie testów

- **Product → Test** (`Cmd + U`)
- Lub kliknij diamond obok funkcji testowej

## 🎓 Wskazówki dla początkujących

### Struktura projektu iOS/SwiftUI

```
Projekt iOS
├── App (@main)              # Punkt wejścia
├── Views                    # Warstwa UI (SwiftUI)
├── Models                   # Logika biznesowa
├── Controllers              # Kontrolery (SceneKit, etc.)
└── Resources                # Assets, pliki
```

### SwiftUI basics

- `View` - protokół dla komponentów UI
- `@State` - lokalna zmienna stanu
- `@StateObject` - obiekt stanu (ObservableObject)
- `@Published` - automatyczne powiadomienia o zmianach
- `body` - deklaratywny opis UI

### SceneKit basics

- `SCNScene` - kontener dla całej sceny 3D
- `SCNNode` - obiekt w scenie (kostka, światło, kamera)
- `SCNGeometry` - kształt 3D (box, sphere, etc.)
- `SCNMaterial` - materiał (kolor, tekstura)
- `SCNAction` - animacja

## 📚 Dodatkowe zasoby

### Dokumentacja Apple

- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [SceneKit Documentation](https://developer.apple.com/documentation/scenekit)
- [UIKit Gesture Recognizers](https://developer.apple.com/documentation/uikit/touches_presses_and_gestures)

### Społeczność

- [Swift Forums](https://forums.swift.org)
- [Stack Overflow - Swift](https://stackoverflow.com/questions/tagged/swift)
- [Reddit - r/swift](https://reddit.com/r/swift)

## ✅ Checklist konfiguracji

Przed uruchomieniem, sprawdź:

- [ ] Xcode 15.0+ zainstalowane
- [ ] Wszystkie pliki dodane do projektu
- [ ] Target membership ustawione dla wszystkich plików
- [ ] Minimum Deployment Target: iOS 17.0+
- [ ] Info.plist poprawnie skonfigurowany
- [ ] Brak błędów kompilacji
- [ ] Symulator lub urządzenie wybrane
- [ ] Build sukces
- [ ] Aplikacja uruchamia się bez crashów

---

**Gotowe! Miłego kodowania! 🚀**
