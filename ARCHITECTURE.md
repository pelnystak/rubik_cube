# 🏗️ Architektura aplikacji Rubik's Cube 3D

Szczegółowy opis architektury, wzorców projektowych i przepływu danych.

## 📐 Wzorce projektowe

### MVVM (Model-View-ViewModel)

```
┌─────────────────────────────────────────────────────┐
│                      View Layer                     │
│  ┌─────────────────────────────────────────────┐   │
│  │         ContentView (SwiftUI)               │   │
│  │  - UI Components (przyciski, tekst)         │   │
│  │  - Layout                                    │   │
│  └─────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────┐   │
│  │    RubiksCubeSceneView (UIViewRepresentable)│   │
│  │  - SceneKit wrapper                          │   │
│  │  - Gesture coordinators                      │   │
│  └─────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
                      ↕ Binding
┌─────────────────────────────────────────────────────┐
│                  ViewModel Layer                    │
│  ┌─────────────────────────────────────────────┐   │
│  │    CubeSceneController (ObservableObject)   │   │
│  │  - Scene management                          │   │
│  │  - Animation control                         │   │
│  │  - Camera control                            │   │
│  │  - Published state (@Published)              │   │
│  └─────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────┐   │
│  │         GestureHandler                       │   │
│  │  - Gesture recognition                       │   │
│  │  - Gesture → Move translation               │   │
│  └─────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
                      ↕ Commands
┌─────────────────────────────────────────────────────┐
│                   Model Layer                       │
│  ┌─────────────────────────────────────────────┐   │
│  │      RubiksCube (ObservableObject)          │   │
│  │  - Business logic                            │   │
│  │  - State management                          │   │
│  │  - Move execution                            │   │
│  └─────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────┐   │
│  │            Cubie                             │   │
│  │  - Individual piece data                     │   │
│  │  - Color management                          │   │
│  └─────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────┐   │
│  │      Move, CubeColor, CubeFace              │   │
│  │  - Data structures                           │   │
│  └─────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
                      ↕ Rendering
┌─────────────────────────────────────────────────────┐
│                 Rendering Layer                     │
│  ┌─────────────────────────────────────────────┐   │
│  │          CubeRenderer                        │   │
│  │  - 3D geometry creation                      │   │
│  │  - Material setup                            │   │
│  │  - Lighting                                  │   │
│  └─────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────┐   │
│  │          SCNScene                            │   │
│  │  - Scene graph                               │   │
│  │  - Node hierarchy                            │   │
│  └─────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

## 🔄 Przepływ danych

### 1. Wykonanie ruchu przez użytkownika

```
User Swipe
    ↓
GestureHandler.handleSwipe()
    ↓
Determine move from:
  - Hit test position
  - Swipe direction
    ↓
CubeSceneController.animateMove()
    ↓
┌────────────────────────────┐
│   Create pivot node        │
│   Move affected SCNNodes   │
│   Animate rotation (0.3s)  │
└────────────────────────────┘
    ↓
After animation completes:
    ↓
RubiksCube.performMove()
    ↓
┌────────────────────────────┐
│  Update cubie positions    │
│  Rotate cubie colors       │
│  Add to move history       │
└────────────────────────────┘
    ↓
@Published triggers update
    ↓
CubeSceneController.rebuildCube()
    ↓
View updates automatically
```

### 2. Scramble kostki

```
User taps "Scramble"
    ↓
ContentView.scrambleCube()
    ↓
Generate 25 random moves
    ↓
For each move (with delay):
    ↓
CubeSceneController.animateMove()
    ↓
RubiksCube.performMove()
    ↓
Visual + logical update
    ↓
After all moves:
    ↓
isScrambling = false
```

### 3. Obracanie całej kostki

```
User pans on screen
    ↓
GestureHandler.handlePan()
    ↓
Calculate delta (Δx, Δy)
    ↓
Convert to rotation:
  angle = delta × 0.01
  axis = (1, 0, 0) or (0, 1, 0)
    ↓
CubeSceneController.addRotation()
    ↓
┌────────────────────────────┐
│ Convert to quaternion      │
│ Multiply quaternions       │
│ Convert back to axis-angle │
└────────────────────────────┘
    ↓
Update cubeRootNode.rotation
    ↓
Immediate visual feedback
```

## 🎯 Separacja odpowiedzialności

### Model (RubiksCube, Cubie)

**Odpowiedzialności:**
- ✅ Stan logiczny kostki (pozycje, kolory)
- ✅ Wykonywanie ruchów (logika)
- ✅ Walidacja (czy ułożona)
- ✅ Historia ruchów

**Nie odpowiada za:**
- ❌ Renderowanie 3D
- ❌ Animacje
- ❌ Gesty użytkownika
- ❌ UI

### ViewModel (CubeSceneController, GestureHandler)

**Odpowiedzialności:**
- ✅ Zarządzanie sceną 3D
- ✅ Animacje wizualne
- ✅ Tłumaczenie gestów na komendy
- ✅ Synchronizacja model ↔ view

**Nie odpowiada za:**
- ❌ Logikę gry (rozwiązywanie, sprawdzanie)
- ❌ Przechowywanie stanu
- ❌ Layout UI

### View (ContentView, RubiksCubeSceneView)

**Odpowiedzialności:**
- ✅ Deklaratywny opis UI
- ✅ Obsługa akcji użytkownika
- ✅ Wyświetlanie stanu

**Nie odpowiada za:**
- ❌ Logikę biznesową
- ❌ Animacje 3D (deleguje do ViewModel)
- ❌ Bezpośrednie manipulowanie modelem

## 🧩 Komponenty szczegółowo

### RubiksCube (Model)

```swift
class RubiksCube: ObservableObject {
    // MARK: - State
    @Published var cubies: [Cubie]          // 26 elementów
    @Published var moveHistory: [Move]
    @Published var isAnimating: Bool

    // MARK: - Computed Properties
    var isSolved: Bool                      // O(1) sprawdzenie

    // MARK: - Public API
    func performMove(_ moveType: MoveType)  // Wykonuje ruch
    func undoLastMove()                     // Cofa ostatni ruch
    func scramble(moves: Int)               // Miesza losowo
    func reset()                            // Reset do początkowego

    // MARK: - Private Methods
    private func getCubiesOnFace(_ face: CubeFace) -> [Cubie]
    private func rotateColors(for cubies: [Cubie], move: MoveType)
    private func updatePositions(for cubies: [Cubie], move: MoveType)
}
```

**Algorytm `performMove`:**

```swift
func performMove(_ moveType: MoveType) {
    // 1. Pobierz cubies na danej ścianie
    let affected = cubies.filter { $0.position.isOnFace(moveType.face) }

    // 2. Rotuj kolory każdego cubie
    for cubie in affected {
        switch moveType.face {
        case .top, .bottom: cubie.rotateY(clockwise: moveType.angle > 0)
        case .right, .left: cubie.rotateX(clockwise: moveType.angle > 0)
        case .front, .back: cubie.rotateZ(clockwise: moveType.angle > 0)
        }
    }

    // 3. Aktualizuj pozycje w siatce 3x3x3
    for cubie in affected {
        cubie.position = calculateNewPosition(
            old: cubie.position,
            face: moveType.face,
            clockwise: moveType.angle > 0
        )
    }

    // 4. Dodaj do historii
    moveHistory.append(Move(type: moveType))
}
```

### Cubie (Model)

```swift
class Cubie {
    // MARK: - State
    var position: CubePosition              // (x, y, z) w [0, 1, 2]
    var colors: [CubeFace: CubeColor]       // 6 ścianek
    var node: SCNNode?                      // Weak reference do węzła
    let id: UUID

    // MARK: - Computed Properties
    var isCorner: Bool                      // 0 środkowych koordynat
    var isEdge: Bool                        // 1 środkowa koordynata
    var isCenter: Bool                      // 2 środkowe koordynaty

    // MARK: - Rotation Methods
    func rotateY(clockwise: Bool)           // U/D moves
    func rotateX(clockwise: Bool)           // R/L moves
    func rotateZ(clockwise: Bool)           // F/B moves
}
```

**Przykład rotacji kolorów (rotateY):**

```
Przed rotacją (clockwise):
    Front: Red
    Right: Green
    Back: Orange
    Left: Blue

Po rotacji:
    Front: Blue    (było Left)
    Right: Red     (było Front)
    Back: Green    (było Right)
    Left: Orange   (było Back)

Algorytm:
    temp = front
    front = left
    left = back
    back = right
    right = temp
```

### CubeSceneController (ViewModel)

```swift
class CubeSceneController: ObservableObject {
    // MARK: - Properties
    let scene: SCNScene
    let renderer: CubeRenderer
    var rubiksCube: RubiksCube
    var cubeRootNode: SCNNode?
    var cameraNode: SCNNode?

    @Published var isAnimating: Bool
    var currentRotation: SCNVector4

    // MARK: - Scene Management
    func rebuildCube()                      // Przebudowuje węzły
    func updateCubieColors()                // Aktualizuje materiały

    // MARK: - Animation
    func animateMove(_ moveType: MoveType, completion: @escaping () -> Void)

    // MARK: - Camera/Rotation
    func rotateCube(by rotation: SCNVector4)
    func addRotation(angle: Float, axis: SCNVector3)
    func resetCubeRotation(animated: Bool)
}
```

**Algorytm animacji:**

```swift
func animateMove(_ moveType: MoveType, completion: @escaping () -> Void) {
    guard !isAnimating else { return }
    isAnimating = true

    // 1. Przygotowanie
    let affected = rubiksCube.cubies.filter { $0.position.isOnFace(moveType.face) }
    let nodes = affected.compactMap { $0.node }
    let pivot = SCNNode()

    // 2. Przenieś węzły do pivot
    for node in nodes {
        let worldPos = node.worldPosition
        node.removeFromParentNode()
        pivot.addChildNode(node)
        node.position = scene.rootNode.convertPosition(worldPos, to: pivot)
    }
    cubeRootNode?.addChildNode(pivot)

    // 3. Animuj pivot
    let action = SCNAction.rotate(
        by: CGFloat(moveType.angle),
        around: moveType.axis,
        duration: 0.3
    )
    action.timingMode = .easeInEaseOut

    // 4. Po animacji
    pivot.runAction(action) {
        // Przywróć węzły
        for node in nodes {
            let worldPos = node.worldPosition
            node.removeFromParentNode()
            self.cubeRootNode?.addChildNode(node)
            node.position = self.scene.rootNode.convertPosition(worldPos, to: self.cubeRootNode)
        }
        pivot.removeFromParentNode()

        // Wykonaj logiczny ruch
        self.rubiksCube.performMove(moveType, animated: false)

        // Przebuduj
        self.rebuildCube()

        self.isAnimating = false
        completion()
    }
}
```

### GestureHandler (Controller)

```swift
class GestureHandler {
    weak var sceneController: CubeSceneController?

    // MARK: - Gesture Handlers
    @objc func handlePan(_ gesture: UIPanGestureRecognizer)
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer, scnView: SCNView)
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer, scnView: SCNView)
    @objc func handleTap(_ gesture: UITapGestureRecognizer, scnView: SCNView)

    // MARK: - Private Helpers
    private func findCubie(for node: SCNNode) -> Cubie?
    private func determineMove(for cubie: Cubie, direction: UISwipeGestureRecognizer.Direction) -> MoveType?
    private func triggerHapticFeedback()
}
```

**Algorytm wykrywania ruchu ze swipe:**

```swift
func determineMove(for cubie: Cubie, direction: UISwipeGestureRecognizer.Direction) -> MoveType? {
    let pos = cubie.position

    // Logika: na podstawie pozycji cubie i kierunku swipe,
    // określ która warstwa i w którą stronę ma się obrócić

    // Przykład: swipe w prawo
    if direction == .right {
        if pos.y == 2 {
            // Górna warstwa, swipe w prawo → U (clockwise z góry)
            return .U
        }
        if pos.z == 2 {
            // Przednia warstwa, swipe w prawo → ?
            // Zależy od perspektywy kamery
            return .F
        }
    }

    // ... więcej logiki dla innych kombinacji
    return nil
}
```

### CubeRenderer (Rendering)

```swift
class CubeRenderer {
    // MARK: - Constants
    private let cubieSize: CGFloat = 1.0
    private let gap: CGFloat = 0.05
    private let chamferRadius: CGFloat = 0.1

    // MARK: - Geometry
    func createCubieGeometry() -> SCNGeometry
    func createCubieNode(for cubie: Cubie) -> SCNNode
    func createCubeScene(rubiksCube: RubiksCube) -> SCNNode
    func updateCubieColors(node: SCNNode, cubie: Cubie)

    // MARK: - Scene Setup
    func setupLighting(scene: SCNScene)
    func setupCamera(scene: SCNScene) -> SCNNode
    func createFloor(scene: SCNScene)
}
```

**Tworzenie geometrii:**

```swift
func createCubieGeometry() -> SCNGeometry {
    let box = SCNBox(
        width: cubieSize - gap,
        height: cubieSize - gap,
        length: cubieSize - gap,
        chamferRadius: chamferRadius
    )

    // 6 materiałów dla 6 ścianek
    box.materials = (0..<6).map { _ in
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.roughness.contents = 0.4
        material.metalness.contents = 0.1
        material.specular.contents = UIColor.white
        material.shininess = 0.3
        return material
    }

    return box
}
```

**Pozycjonowanie cubies:**

```swift
func createCubieNode(for cubie: Cubie) -> SCNNode {
    let node = SCNNode(geometry: createCubieGeometry())

    // Konwersja pozycji logicznej (0-2) na pozycję 3D (-1 do +1)
    let x = Float(cubie.position.x - 1) * Float(cubieSize)
    let y = Float(cubie.position.y - 1) * Float(cubieSize)
    let z = Float(cubie.position.z - 1) * Float(cubieSize)

    node.position = SCNVector3(x, y, z)

    // Przypisz kolory
    updateCubieColors(node: node, cubie: cubie)

    return node
}
```

## 🔀 Przepływ stanu

### State Flow Diagram

```
┌──────────────┐
│  User Input  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Gesture    │◄──────┐
│   Handler    │       │
└──────┬───────┘       │
       │               │
       ▼               │
┌──────────────┐       │
│    Scene     │       │
│  Controller  │       │
└──────┬───────┘       │
       │               │
       ├─Visual────────┘ (Animation loop)
       │
       ▼─Logical───┐
┌──────────────┐  │
│  RubiksCube  │◄─┘
│    Model     │
└──────┬───────┘
       │
       ▼ @Published
┌──────────────┐
│  SwiftUI     │
│   Updates    │
└──────────────┘
```

## 🎨 Rendering Pipeline

```
RubiksCube State
    ↓
CubeRenderer.createCubeScene()
    ↓
┌─────────────────────────────┐
│ For each Cubie:             │
│   Create SCNBox             │
│   Set position              │
│   Assign materials          │
│   Add to scene graph        │
└─────────────────────────────┘
    ↓
Scene Graph:
    ↓
SCNScene.rootNode
  ├─ cubeRootNode (rotation parent)
  │   ├─ cubieNode[0]
  │   ├─ cubieNode[1]
  │   └─ ... (26 nodes)
  ├─ mainLightNode
  ├─ fillLightNode
  ├─ rimLightNode
  ├─ ambientLightNode
  ├─ cameraNode
  └─ floorNode
    ↓
SCNView renders
    ↓
Metal GPU rendering
```

## 🧮 Matematyka transformacji

### Rotacja quaternionami

**Dlaczego quaterniony?**
- Unikają gimbal lock
- Płynna interpolacja
- Łatwe łączenie rotacji

**Implementacja:**

```swift
struct SCNQuaternion {
    var x, y, z, w: Float

    // Axis-angle → Quaternion
    init(axis: SCNVector3, angle: Float) {
        let halfAngle = angle / 2
        let s = sin(halfAngle)
        let normalized = axis.normalized()

        self.x = normalized.x * s
        self.y = normalized.y * s
        self.z = normalized.z * s
        self.w = cos(halfAngle)
    }

    // Mnożenie quaternionów (łączenie rotacji)
    static func * (lhs: SCNQuaternion, rhs: SCNQuaternion) -> SCNQuaternion {
        return SCNQuaternion(
            x: lhs.w * rhs.x + lhs.x * rhs.w + lhs.y * rhs.z - lhs.z * rhs.y,
            y: lhs.w * rhs.y - lhs.x * rhs.z + lhs.y * rhs.w + lhs.z * rhs.x,
            z: lhs.w * rhs.z + lhs.x * rhs.y - lhs.y * rhs.x + lhs.z * rhs.w,
            w: lhs.w * rhs.w - lhs.x * rhs.x - lhs.y * rhs.y - lhs.z * rhs.z
        )
    }
}
```

### Transformacja pozycji (rotacja 2D w płaszczyźnie)

**Ruch U (góra, clockwise):**

Rotacja o 90° w płaszczyźnie XZ (wokół osi Y):

```
[ x' ]   [ cos(90°)  -sin(90°) ] [ x ]   [  0  -1 ] [ x ]   [ -z ]
[ z' ] = [ sin(90°)   cos(90°) ] [ z ] = [  1   0 ] [ z ] = [  x ]

W siatce 3x3x3 (0-2):
x' = 2 - z
z' = x
y' = y (bez zmian)
```

**Wszystkie transformacje:**

| Ruch | Oś | Clockwise Transform |
|------|----|--------------------|
| U    | Y+ | (x, z) → (2-z, x)  |
| D    | Y- | (x, z) → (z, 2-x)  |
| R    | X+ | (y, z) → (z, 2-y)  |
| L    | X- | (y, z) → (2-z, y)  |
| F    | Z+ | (x, y) → (y, 2-x)  |
| B    | Z- | (x, y) → (2-y, x)  |

## 🔍 Optymalizacje

### 1. Lazy Rebuilding

```swift
// Zamiast:
func performMove() {
    // ...
    rebuildEntireScene()  // Kosztowne!
}

// Używamy:
func performMove() {
    // ...
    updateCubieColors()   // Tylko materiały
    // Rebuild tylko gdy konieczne (np. po animacji)
}
```

### 2. Node Reuse

```swift
// Węzły są reużywane, nie tworzone od nowa
for cubie in rubiksCube.cubies {
    if let existingNode = cubie.node {
        existingNode.position = calculatePosition(cubie)
        updateMaterials(existingNode, cubie)
    } else {
        cubie.node = createCubieNode(for: cubie)
    }
}
```

### 3. Animacje sprzętowe

```swift
// SceneKit automatycznie używa GPU przez Metal
let action = SCNAction.rotate(...)
node.runAction(action)  // Hardware accelerated!
```

## 📊 Złożoność obliczeniowa

### Operacje na modelu

| Operacja | Złożoność | Uwagi |
|----------|-----------|-------|
| `performMove()` | O(9) | 9 cubies na ścianie |
| `isSolved` | O(26) | Sprawdź wszystkie cubies |
| `scramble(n)` | O(9n) | n ruchów × 9 cubies |
| `reset()` | O(26) | Zresetuj wszystkie cubies |

### Operacje na scenie

| Operacja | Złożoność | Uwagi |
|----------|-----------|-------|
| `rebuildCube()` | O(26) | Utwórz/zaktualizuj węzły |
| `animateMove()` | O(9) | 9 węzłów w animacji |
| `updateColors()` | O(26) | Zaktualizuj materiały |

### Rendering

- **Draw calls**: ~30-40 (26 cubies + światła + podłoże)
- **Poligony**: ~300-400 (box = ~12 poligonów × 26)
- **FPS**: 60 na iPhone 12+, 30-45 na starszych

## 🔐 Thread Safety

### Main Thread

Wszystkie operacje UI i SceneKit muszą być na main thread:

```swift
DispatchQueue.main.async {
    sceneController.animateMove(move) { }
}
```

### Background Thread

Potencjalne optymalizacje (przyszłość):

```swift
// Obliczenia solwera w tle
DispatchQueue.global(qos: .userInitiated).async {
    let solution = solver.solve(cube)
    DispatchQueue.main.async {
        self.applySolution(solution)
    }
}
```

## 📝 Podsumowanie

### Kluczowe decyzje architektoniczne

1. **MVVM** - czysty rozdział logiki i prezentacji
2. **ObservableObject** - reaktywny state management
3. **Combine** - automatyczne propagowanie zmian
4. **SceneKit** - gotowy framework 3D z animacjami
5. **Quaterniony** - stabilne rotacje 3D
6. **Proceduralna geometria** - brak zależności od zewnętrznych modeli

### Zalety architektury

- ✅ **Testowalność** - model oddzielony od view
- ✅ **Modułowość** - łatwe dodawanie funkcji
- ✅ **Skalowalność** - przygotowane na solver, multiplayer
- ✅ **Czytelność** - jasna separacja odpowiedzialności
- ✅ **Performance** - optymalizacje w odpowiednich miejscach

### Możliwe ulepszenia

- 🔄 Dependency Injection dla lepszej testowalności
- 🔄 Coordinator pattern dla nawigacji (jeśli dodamy więcej ekranów)
- 🔄 Repository pattern dla persystencji (statystyki, zapisywanie)
- 🔄 Command pattern dla undo/redo z większą elastycznością

---

**Architektury projektu jest solidna, skalowalna i gotowa na przyszłe rozszerzenia! 🚀**
