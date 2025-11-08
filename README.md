# 🎮 Rubik's Cube 3D - Aplikacja iOS

Kompletna aplikacja iOS symulująca realistyczną kostkę Rubika 3x3x3 w 3D z pełną interaktywnością.

![Platform](https://img.shields.io/badge/platform-iOS%2017%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## 📱 Funkcje

- ✨ **Realistyczna wizualizacja 3D** - proceduralnie generowana kostka z użyciem SceneKit
- 🎨 **Prawdziwe kolory** - standardowe kolory kostki Rubika (biały, żółty, czerwony, pomarańczowy, zielony, niebieski)
- 🖐️ **Intuicyjne gesty**:
  - Pan (przeciąganie) - obraca całą kostką
  - Swipe (przesunięcie) - obraca warstwy
  - Pinch - zoom kamery
- 🌟 **Zaawansowane oświetlenie**:
  - Światło główne (directional) z cieniami
  - Światło wypełniające (fill light)
  - Światło tylne (rim light)
  - Światło ambient
  - Physically Based Rendering (PBR)
- 🎬 **Płynne animacje** - naturalne przejścia z ease-in/ease-out
- 📊 **Licznik ruchów** - śledzi liczbę wykonanych ruchów
- 🔄 **Funkcje użytkowe**:
  - Scramble - losowe pomieszanie kostki (25 ruchów)
  - Reset - powrót do stanu rozwiązanego
  - Undo - cofnięcie ostatniego ruchu
  - Reset widoku - powrót do domyślnego kąta kamery
- ✅ **Detekcja ułożenia** - automatyczne wykrywanie rozwiązanej kostki
- 📳 **Wibracja haptyczna** - subtelne potwierdzenie każdego ruchu

## 🏗️ Architektura

Projekt został zaprojektowany z wykorzystaniem wzorca **MVVM** (Model-View-ViewModel) z wyraźnym rozdziałem warstw:

```
RubiksCubeApp/
├── App/
│   └── RubiksCubeApp.swift          # Punkt wejścia aplikacji
├── Models/                           # Warstwa logiki biznesowej
│   ├── CubeColor.swift              # Definicje kolorów i ścian
│   ├── Move.swift                   # Typy ruchów (notacja Singmaster)
│   ├── Cubie.swift                  # Pojedynczy element kostki (27 sztuk)
│   └── RubiksCube.swift             # Główny model kostki 3x3x3
├── Views/                            # Warstwa prezentacji
│   ├── ContentView.swift            # Główny widok SwiftUI + UI
│   └── RubiksCubeSceneView.swift    # Wrapper dla SceneKit
├── SceneKit/                         # Warstwa wizualizacji 3D
│   ├── CubeRenderer.swift           # Rendering kostki (geometria, materiały)
│   └── CubeSceneController.swift    # Kontroler sceny + animacje
├── Gestures/                         # Warstwa interakcji
│   └── GestureHandler.swift         # Obsługa gestów dotykowych
└── Utils/                            # Narzędzia pomocnicze
    └── Extensions.swift             # Rozszerzenia (SCNVector3, quaterniony)
```

## 🎯 Kluczowe komponenty

### 1. **RubiksCube** - Model logiczny

Główna klasa zarządzająca stanem kostki:

```swift
class RubiksCube: ObservableObject {
    @Published var cubies: [Cubie]        // 27 elementów (3x3x3, bez środka)
    @Published var moveHistory: [Move]     // Historia ruchów
    @Published var isAnimating: Bool       // Status animacji

    func performMove(_ moveType: MoveType) // Wykonuje ruch
    func scramble(moves: Int = 25)         // Miesza kostkę
    func reset()                           // Resetuje do stanu początkowego
    var isSolved: Bool                     // Sprawdza czy ułożona
}
```

**Odpowiedzialności:**
- Przechowuje stan 27 cubies
- Wykonuje logikę ruchów (rotacja kolorów + aktualizacja pozycji)
- Śledzi historię ruchów
- Wykrywa czy kostka jest ułożona

### 2. **Cubie** - Pojedynczy element

Reprezentuje jeden z 27 elementów kostki:

```swift
class Cubie {
    var position: CubePosition            // Pozycja w siatce 3x3x3
    var colors: [CubeFace: CubeColor]     // 6 kolorów ścianek
    var node: SCNNode?                    // Węzeł SceneKit

    func rotateY(clockwise: Bool)         // Rotacja wokół osi Y
    func rotateX(clockwise: Bool)         // Rotacja wokół osi X
    func rotateZ(clockwise: Bool)         // Rotacja wokół osi Z
}
```

**Typy cubies:**
- **Corner** (narożniki) - 8 sztuk, 3 widoczne ścianki
- **Edge** (krawędzie) - 12 sztuk, 2 widoczne ścianki
- **Center** (środki) - 6 sztuk, 1 widoczna ścianka
- Środkowy cubie jest pomijany (niewidoczny)

### 3. **CubeRenderer** - Wizualizacja 3D

Odpowiada za rendering geometrii kostki:

```swift
class CubeRenderer {
    func createCubieGeometry() -> SCNGeometry
    func createCubieNode(for cubie: Cubie) -> SCNNode
    func createCubeScene(rubiksCube: RubiksCube) -> SCNNode
    func setupLighting(scene: SCNScene)
    func setupCamera(scene: SCNScene) -> SCNNode
}
```

**Funkcje:**
- Tworzy geometrię SCNBox z zaokrąglonymi krawędziami (chamfer)
- Generuje materiały PBR dla realistycznego wyglądu
- Konfiguruje wieloźródłowe oświetlenie z cieniami
- Ustawia kamerę perspektywiczną

**Parametry rendering:**
- Rozmiar cubie: 1.0 jednostki
- Odstęp (gap): 0.05 jednostki
- Zaokrąglenie: 0.1 jednostki
- Materiały: Physically Based Rendering
  - Roughness: 0.4
  - Metalness: 0.1
  - Specular highlights: 0.3-0.5

### 4. **CubeSceneController** - Kontroler sceny

Zarządza sceną SceneKit i animacjami:

```swift
class CubeSceneController: ObservableObject {
    let scene: SCNScene
    var cubeRootNode: SCNNode?
    var cameraNode: SCNNode?

    func animateMove(_ moveType: MoveType, completion: @escaping () -> Void)
    func rotateCube(by rotation: SCNVector4)
    func addRotation(angle: Float, axis: SCNVector3)
    func rebuildCube()
}
```

**Algorytm animacji ruchu:**
1. Tworzy tymczasowy węzeł pivot
2. Przenosi dotknięte cubies do pivot node
3. Animuje rotację pivot node (0.3s, ease-in-ease-out)
4. Po animacji przenosi cubies z powrotem
5. Wykonuje logiczny ruch w modelu
6. Przebudowuje scenę z nowymi pozycjami

### 5. **GestureHandler** - Obsługa gestów

Zarządza interakcjami dotykowymi:

```swift
class GestureHandler {
    func handlePan(_ gesture: UIPanGestureRecognizer)
    func handleSwipe(_ gesture: UISwipeGestureRecognizer, scnView: SCNView)
    func handlePinch(_ gesture: UIPinchGestureRecognizer, scnView: SCNView)
    func handleTap(_ gesture: UITapGestureRecognizer, scnView: SCNView)
}
```

**Obsługiwane gesty:**
- **Pan** - obraca całą kostką używając quaternionów
- **Swipe** (4 kierunki) - wykrywa hit test i określa ruch warstwy
- **Pinch** - zmienia zoom kamery (zakres 5.0-15.0)
- **Tap** - zarezerwowane na przyszłość (highlight)

### 6. **Move & MoveType** - System ruchów

Implementuje notację Singmaster:

```swift
enum MoveType: String {
    case U, Up   // Góra (Up): zgodnie/przeciwnie do ruchu wskazówek
    case D, Dp   // Dół (Down)
    case F, Fp   // Przód (Front)
    case B, Bp   // Tył (Back)
    case R, Rp   // Prawo (Right)
    case L, Lp   // Lewo (Left)

    var axis: SCNVector3      // Oś rotacji
    var angle: Float          // Kąt (±90°)
    var face: CubeFace        // Dotknięta ściana
    var inverse: MoveType     // Ruch odwrotny
}
```

## 🎨 System kolorów

Standardowe kolory kostki Rubika (międzynarodowe):

```swift
enum CubeColor {
    case white   // Góra (U)
    case yellow  // Dół (D)
    case red     // Przód (F)
    case orange  // Tył (B)
    case green   // Prawo (R)
    case blue    // Lewo (L)
}
```

**Kolory SceneKit (SCNVector4):**
- White:  `(0.95, 0.95, 0.95, 1.0)` - lekko przyciemniony dla realizmu
- Yellow: `(1.0, 0.85, 0.0, 1.0)` - ciepły żółty
- Red:    `(0.9, 0.1, 0.1, 1.0)` - intensywny czerwony
- Orange: `(1.0, 0.5, 0.0, 1.0)` - jasny pomarańczowy
- Green:  `(0.0, 0.7, 0.2, 1.0)` - żywy zielony
- Blue:   `(0.0, 0.3, 0.8, 1.0)` - głęboki niebieski

## 🎬 System animacji

### Animacja ruchów warstw

```swift
func animateMove(_ moveType: MoveType, completion: @escaping () -> Void) {
    // 1. Pobierz dotknięte cubies
    let affectedCubies = rubiksCube.cubies.filter { $0.position.isOnFace(moveType.face) }

    // 2. Utwórz pivot node
    let pivotNode = SCNNode()

    // 3. Przenieś węzły do pivot
    for node in affectedNodes {
        let worldPosition = node.worldPosition
        node.removeFromParentNode()
        pivotNode.addChildNode(node)
        node.position = convertPosition(worldPosition, to: pivotNode)
    }

    // 4. Animuj rotację
    let rotation = SCNAction.rotate(by: moveType.angle, around: moveType.axis, duration: 0.3)
    rotation.timingMode = .easeInEaseOut

    // 5. Po animacji: przenieś węzły z powrotem i zaktualizuj model
    pivotNode.runAction(rotation) {
        // Przywróć węzły
        // Wykonaj logiczny ruch
        // Przebuduj scenę
    }
}
```

### Rotacja całej kostki

Używa **quaternionów** dla płynnej rotacji bez gimbal lock:

```swift
func addRotation(angle: Float, axis: SCNVector3) {
    // 1. Konwertuj aktualną rotację na quaternion
    let currentQuat = SCNQuaternion(from: currentRotation)

    // 2. Utwórz quaternion dla nowej rotacji
    let newQuat = SCNQuaternion(axis: axis, angle: angle)

    // 3. Pomnóż quaterniony
    let resultQuat = currentQuat * newQuat

    // 4. Konwertuj z powrotem na axis-angle
    currentRotation = resultQuat.toAxisAngle()
}
```

## 📐 Matematyka rotacji

### Rotacja pozycji cubies

Dla każdego typu ruchu, pozycje cubies są przekształcane:

**Ruch U (góra, zgodnie z ruchem wskazówek):**
```swift
// Dla Y = 2
(x, z) → (2 - z, x)

Przykład:
(0, 0) → (2, 0)  // Lewy-Tył → Prawy-Tył
(0, 2) → (0, 0)  // Lewy-Przód → Lewy-Tył
(2, 2) → (0, 2)  // Prawy-Przód → Lewy-Przód
(2, 0) → (2, 2)  // Prawy-Tył → Prawy-Przód
```

### Rotacja kolorów

Przy ruchu Y (góra/dół):
```swift
func rotateY(clockwise: Bool) {
    if clockwise {
        colors[.front] = oldColors[.left]
        colors[.right] = oldColors[.front]
        colors[.back]  = oldColors[.right]
        colors[.left]  = oldColors[.back]
    }
}
```

## 🚀 Jak uruchomić

### Wymagania

- **Xcode 15.0+**
- **iOS 17.0+**
- **Swift 5.9+**
- iPhone lub iPad (symulator również obsługiwany)

### Kroki instalacji

1. **Sklonuj repozytorium:**
   ```bash
   git clone https://github.com/yourusername/rubiks-cube-3d.git
   cd rubiks-cube-3d
   ```

2. **Otwórz w Xcode:**
   ```bash
   open RubiksCubeApp.xcodeproj
   ```

3. **Wybierz target:**
   - Wybierz urządzenie lub symulator z listy
   - Zalecane: iPhone 15 Pro (symulator) lub fizyczny iPhone

4. **Uruchom:**
   - Kliknij ▶️ lub naciśnij `Cmd + R`

### Budowanie projektu ręcznie

Jeśli nie masz pliku `.xcodeproj`, możesz go stworzyć:

1. **Utwórz nowy projekt w Xcode:**
   - File → New → Project
   - iOS → App
   - Product Name: `RubiksCubeApp`
   - Interface: SwiftUI
   - Language: Swift

2. **Dodaj pliki:**
   - Przeciągnij wszystkie pliki `.swift` do projektu
   - Zachowaj strukturę folderów używając grup

3. **Dodaj Info.plist:**
   - Zastąp domyślny plik Info.plist

4. **Skonfiguruj uprawnienia:**
   - Brak specjalnych uprawnień wymaganych

## 🎮 Jak grać

### Sterowanie

- **Obracanie kostki:**
  - Przeciągnij palcem w dowolnym miejscu by obrócić całą kostkę
  - Możesz oglądać kostkę ze wszystkich stron

- **Obracanie warstw:**
  - Wykonaj swipe (szybkie przesunięcie) na konkretnej ściance
  - Kierunek swipe określa kierunek rotacji warstwy

- **Zoom:**
  - Użyj gestu pinch (ściśnięcie/rozciągnięcie dwoma palcami)
  - Zakres: 5-15 jednostek od kamery

### Przyciski

- **🔀 Pomieszaj** - losowo miesza kostkę (25 ruchów)
- **🔄 Reset** - przywraca kostkę do stanu rozwiązanego
- **↩️ Cofnij** - cofa ostatni ruch
- **📷 Reset widoku** - przywraca domyślny kąt kamery

### Wskaźniki

- **Licznik ruchów** - pokazuje ile ruchów wykonałeś
- **Status** - zielony = ułożona, pomarańczowy = pomieszana

## 🔧 Konfiguracja i dostosowanie

### Zmiana parametrów kostki

W `CubeRenderer.swift`:

```swift
private let cubieSize: CGFloat = 1.0        // Rozmiar cubie
private let gap: CGFloat = 0.05             // Odstęp między cubies
private let chamferRadius: CGFloat = 0.1     // Zaokrąglenie krawędzi
```

### Zmiana prędkości animacji

W `CubeSceneController.swift`:

```swift
let rotation = SCNAction.rotate(
    by: CGFloat(moveType.angle),
    around: moveType.axis,
    duration: 0.3  // ← Zmień czas animacji (sekundy)
)
```

### Zmiana kolorów

W `CubeColor.swift`:

```swift
case .white: return SCNVector4(0.95, 0.95, 0.95, 1.0)  // ← Dostosuj RGBA
```

### Zmiana oświetlenia

W `CubeRenderer.swift` → `setupLighting()`:

```swift
mainLight.intensity = 1000  // ← Jasność głównego światła
fillLight.intensity = 300   // ← Jasność światła wypełniającego
```

## 🎯 Przyszłe rozszerzenia

### 🧩 Solver (algorytm rozwiązujący)

Implementacja algorytmu CFOP lub Kociemba:

```swift
class RubiksSolver {
    func solve(cube: RubiksCube) -> [MoveType] {
        // 1. White Cross
        // 2. First Two Layers (F2L)
        // 3. Orient Last Layer (OLL)
        // 4. Permute Last Layer (PLL)
    }
}
```

**Korzyści:**
- Automatyczne rozwiązywanie kostki
- Nauka algorytmów speedcubing
- Optymalizacja liczby ruchów

### 📚 Tutorial interaktywny

System nauki krok po kroku:

```swift
struct Tutorial {
    var steps: [TutorialStep]
    var currentStep: Int

    struct TutorialStep {
        let title: String
        let description: String
        let moves: [MoveType]
        let highlightedCubies: [Cubie]
    }
}
```

**Funkcje:**
- Podświetlanie konkretnych cubies
- Prowadzenie przez algorytmy
- Ćwiczenia z rozpoznawaniem wzorów

### 🎵 Dźwięki

Dodanie efektów dźwiękowych:

```swift
import AVFoundation

class SoundManager {
    func playMoveSound()      // Dźwięk ruchu warstwy
    func playScrambleSound()  // Dźwięk mieszania
    func playSolvedSound()    // Dźwięk gratulacji
}
```

**Wykorzystanie:**
- Subtelny "klik" przy każdym ruchu
- Dźwięk sukcesu przy ułożeniu
- Opcjonalne włączenie/wyłączenie

### ⏱️ Timer i statystyki

System pomiaru czasu i śledzenia wyników:

```swift
class StatsTracker: ObservableObject {
    @Published var currentTime: TimeInterval
    @Published var bestTime: TimeInterval
    @Published var averageOf5: TimeInterval
    @Published var solves: [Solve]

    struct Solve {
        let time: TimeInterval
        let moves: Int
        let scramble: [MoveType]
        let date: Date
    }
}
```

**Funkcje:**
- Timer z precyzją milisekund
- Historia rozwiązań
- Wykresy postępów
- Eksport do CSV

### 🌐 Multiplayer

Rywalizacja online:

```swift
class MultiplayerManager {
    func createRoom(name: String)
    func joinRoom(code: String)
    func syncCubeState()
    func sendMove(_ move: MoveType)
}
```

**Tryby:**
- Race - kto pierwszy ułoży
- Collaborative - wspólne układanie
- Ranking globalny

### 🎨 Skórki (skins)

Personalizacja wyglądu:

```swift
struct CubeSkin {
    let name: String
    let colors: [CubeFace: CubeColor]
    let material: MaterialStyle

    enum MaterialStyle {
        case matte, glossy, metallic, neon
    }
}
```

**Przykłady:**
- Klasyczna (standardowa)
- Stickerless (czarne plastikowe ścianki z kolorowymi blokami)
- Pastelowa
- Neonowa
- Metaliczna

### 🤖 AI Opponent

Przeciwnik AI do ćwiczeń:

```swift
class AIPlayer {
    func calculateNextMove(cube: RubiksCube) -> MoveType
    var difficulty: Difficulty

    enum Difficulty {
        case beginner   // Losowe ruchy
        case intermediate  // Podstawowe algorytmy
        case expert     // Zaawansowane strategie
    }
}
```

### 📱 Watch App

Aplikacja towarzysząca na Apple Watch:

- Mini-widok kostki
- Timer
- Statystyki
- Powiadomienia o nowych rekordach

### 🎓 Pattern library

Biblioteka wzorów i algorytmów:

```swift
struct Pattern {
    let name: String           // "Checkerboard", "Cube in Cube"
    let moves: [MoveType]      // Sekwencja ruchów
    let category: Category     // OLL, PLL, F2L, etc.
    let thumbnail: UIImage
}
```

## 📊 Optymalizacja wydajności

### Aktualne optymalizacje

1. **Reużycie węzłów** - węzły SceneKit nie są tworzone od nowa przy każdym ruchu
2. **Lazy rebuild** - przebudowa sceny tylko gdy konieczne
3. **Animacje sprzętowe** - wykorzystanie GPU przez SceneKit
4. **Materiały współdzielone** - jeden materiał na wiele instancji

### Możliwe dalsze optymalizacje

1. **Instancjonowanie geometrii:**
   ```swift
   let sharedGeometry = createCubieGeometry()
   for cubie in cubies {
       let node = SCNNode(geometry: sharedGeometry)
       // ...
   }
   ```

2. **Level of Detail (LOD):**
   - Zmniejszenie szczegółowości gdy kostka daleko od kamery

3. **Culling:**
   - Nie renderuj niewidocznych ścianek wewnętrznych

## 🧪 Testowanie

### Unit testy (do dodania)

```swift
import XCTest

class RubiksCubeTests: XCTestCase {
    func testInitialState() {
        let cube = RubiksCube()
        XCTAssertTrue(cube.isSolved)
        XCTAssertEqual(cube.cubies.count, 26)
    }

    func testMoveExecution() {
        let cube = RubiksCube()
        cube.performMove(.U)
        XCTAssertEqual(cube.moveHistory.count, 1)
    }

    func testInverseMove() {
        let cube = RubiksCube()
        cube.performMove(.U)
        cube.performMove(.Up)
        XCTAssertTrue(cube.isSolved)
    }
}
```

### UI testy (do dodania)

```swift
class RubiksCubeUITests: XCTestCase {
    func testScrambleButton() {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Pomieszaj"].tap()
        // Sprawdź czy kostka została pomieszana
    }
}
```

## 📖 Dokumentacja API

### RubiksCube

```swift
/// Główny model kostki Rubika 3x3x3
class RubiksCube: ObservableObject {
    /// Tablica 27 cubies (faktycznie 26 - środkowy pomijany)
    @Published var cubies: [Cubie]

    /// Historia wykonanych ruchów
    @Published var moveHistory: [Move]

    /// Czy trwa animacja
    @Published var isAnimating: Bool

    /// Sprawdza czy kostka jest ułożona
    var isSolved: Bool { get }

    /// Wykonuje ruch na kostce
    /// - Parameters:
    ///   - moveType: Typ ruchu (U, D, F, B, R, L + prime)
    ///   - animated: Czy animować ruch
    func performMove(_ moveType: MoveType, animated: Bool = true)

    /// Cofa ostatni ruch
    func undoLastMove()

    /// Miesza kostkę losowymi ruchami
    /// - Parameter moves: Liczba ruchów (domyślnie 25)
    func scramble(moves: Int = 25)

    /// Resetuje kostkę do stanu rozwiązanego
    func reset()
}
```

## 🐛 Znane problemy

1. **Wykrywanie ruchów swipe** - wymaga dopracowania algorytmu określania ruchu na podstawie pozycji cubie i kierunku gestu
2. **Fizyka rotacji** - przy bardzo szybkim obracaniu kostki może wystąpić gimbal lock (rozwiązane częściowo przez quaterniony)
3. **Wydajność na starszych urządzeniach** - iPhone 12 i starsze mogą mieć lekkie spadki FPS przy animacjach

## 🤝 Wkład w projekt

Jeśli chcesz dodać nowe funkcje:

1. Fork repozytorium
2. Stwórz branch (`git checkout -b feature/AmazingFeature`)
3. Commit zmian (`git commit -m 'Add some AmazingFeature'`)
4. Push do brancha (`git push origin feature/AmazingFeature`)
5. Otwórz Pull Request

## 📄 Licencja

MIT License - pełna swoboda użycia, modyfikacji i dystrybucji.

## 👨‍💻 Autor

Stworzone z ❤️ przez AI (Claude) dla społeczności cuberów.

## 🙏 Podziękowania

- **SceneKit** - za potężny framework 3D
- **SwiftUI** - za nowoczesny UI framework
- **Społeczność speedcubing** - za inspirację i notację Singmaster

## 📞 Kontakt

Masz pytania lub sugestie? Otwórz issue na GitHubie!

---

**Miłego układania! 🎲✨**
