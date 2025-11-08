//
//  CubeSceneController.swift
//  RubiksCubeApp
//
//  Kontroler zarządzający sceną 3D kostki Rubika
//

import Foundation
import SceneKit
import Combine

class CubeSceneController: NSObject, ObservableObject, SCNSceneRendererDelegate {
    /// Scena SceneKit
    let scene: SCNScene

    /// Renderer kostki
    let renderer: CubeRenderer

    /// Model kostki
    var rubiksCube: RubiksCube

    /// Główny węzeł kostki
    var cubeRootNode: SCNNode?

    /// Węzeł kamery
    var cameraNode: SCNNode?

    /// Czy trwa animacja ruchu
    @Published var isAnimating = false

    /// Kąt rotacji całej kostki (dla interakcji użytkownika)
    var currentRotation: SCNVector4 = SCNVector4(0, 1, 0, 0)

    /// Subscriptions
    private var cancellables = Set<AnyCancellable>()

    init(rubiksCube: RubiksCube) {
        self.rubiksCube = rubiksCube
        self.scene = SCNScene()
        self.renderer = CubeRenderer()

        super.init()

        setupScene()
        observeCubeChanges()
    }

    /// Konfiguruje scenę
    private func setupScene() {
        // Dodaj oświetlenie
        renderer.setupLighting(scene: scene)

        // Dodaj kamerę
        cameraNode = renderer.setupCamera(scene: scene)

        // Dodaj podłoże
        renderer.createFloor(scene: scene)

        // Utwórz kostkę
        rebuildCube()

        // Ustaw tło
        scene.background.contents = UIColor(white: 0.1, alpha: 1.0)
    }

    /// Przebudowuje wizualizację kostki
    func rebuildCube() {
        // Usuń stary węzeł
        cubeRootNode?.removeFromParentNode()

        // Utwórz nowy węzeł z aktualnym stanem kostki
        cubeRootNode = renderer.createCubeScene(rubiksCube: rubiksCube)

        // Zastosuj aktualną rotację
        cubeRootNode?.rotation = currentRotation

        // Dodaj do sceny
        scene.rootNode.addChildNode(cubeRootNode!)
    }

    /// Obserwuje zmiany w modelu kostki
    private func observeCubeChanges() {
        rubiksCube.$cubies
            .sink { [weak self] _ in
                // Aktualizuj kolory cubies bez przebudowy
                self?.updateCubieColors()
            }
            .store(in: &cancellables)
    }

    /// Aktualizuje kolory cubies bez przebudowy sceny
    private func updateCubieColors() {
        for cubie in rubiksCube.cubies {
            if let node = cubie.node {
                renderer.updateCubieColors(node: node, cubie: cubie)
            }
        }
    }

    // MARK: - Animations

    /// Wykonuje animowany ruch na kostce
    func animateMove(_ moveType: MoveType, completion: @escaping () -> Void) {
        guard !isAnimating else {
            completion()
            return
        }

        isAnimating = true

        // Pobierz cubies do animacji
        let affectedCubies = rubiksCube.cubies.filter { $0.position.isOnFace(moveType.face) }
        let affectedNodes = affectedCubies.compactMap { $0.node }

        // Utwórz węzeł pivot dla rotacji
        let pivotNode = SCNNode()
        pivotNode.position = SCNVector3(0, 0, 0)

        // Przenieś węzły do pivot node
        for node in affectedNodes {
            let worldPosition = node.worldPosition
            node.removeFromParentNode()
            pivotNode.addChildNode(node)
            node.position = scene.rootNode.convertPosition(worldPosition, to: pivotNode)
        }

        cubeRootNode?.addChildNode(pivotNode)

        // Animuj rotację
        let rotation = SCNAction.rotate(
            by: CGFloat(moveType.angle),
            around: moveType.axis,
            duration: 0.3
        )

        rotation.timingMode = .easeInEaseOut

        pivotNode.runAction(rotation) { [weak self] in
            guard let self = self else { return }

            // Przenieś węzły z powrotem do głównego węzła
            for node in affectedNodes {
                let worldPosition = node.worldPosition
                node.removeFromParentNode()
                self.cubeRootNode?.addChildNode(node)
                node.position = self.scene.rootNode.convertPosition(worldPosition, to: self.cubeRootNode)
            }

            pivotNode.removeFromParentNode()

            // Wykonaj logiczny ruch
            self.rubiksCube.performMove(moveType, animated: false)

            // Przebuduj węzły z nowymi pozycjami
            self.rebuildCube()

            self.isAnimating = false
            completion()
        }
    }

    /// Obraca całą kostkę (dla gestów)
    func rotateCube(by rotation: SCNVector4) {
        currentRotation = rotation
        cubeRootNode?.rotation = rotation
    }

    /// Dodaje rotację do aktualnej rotacji kostki
    func addRotation(angle: Float, axis: SCNVector3) {
        guard let cubeNode = cubeRootNode else { return }

        // Konwertuj aktualną rotację na quaternion
        let currentQuat = SCNQuaternion(
            x: cubeNode.rotation.x * cubeNode.rotation.w,
            y: cubeNode.rotation.y * cubeNode.rotation.w,
            z: cubeNode.rotation.z * cubeNode.rotation.w,
            w: cubeNode.rotation.w
        )

        // Utwórz quaternion dla nowej rotacji
        let halfAngle = angle / 2
        let sinHalf = sin(halfAngle)
        let newQuat = SCNQuaternion(
            x: axis.x * sinHalf,
            y: axis.y * sinHalf,
            z: axis.z * sinHalf,
            w: cos(halfAngle)
        )

        // Pomnóż quaterniony
        let resultQuat = multiplyQuaternions(currentQuat, newQuat)

        // Konwertuj z powrotem na axis-angle
        let angle = 2 * acos(resultQuat.w)
        let s = sqrt(1 - resultQuat.w * resultQuat.w)

        var x: Float, y: Float, z: Float
        if s < 0.001 {
            x = resultQuat.x
            y = resultQuat.y
            z = resultQuat.z
        } else {
            x = resultQuat.x / s
            y = resultQuat.y / s
            z = resultQuat.z / s
        }

        currentRotation = SCNVector4(x, y, z, angle)
        cubeNode.rotation = currentRotation
    }

    /// Mnoży dwa quaterniony
    private func multiplyQuaternions(_ q1: SCNQuaternion, _ q2: SCNQuaternion) -> SCNQuaternion {
        return SCNQuaternion(
            x: q1.w * q2.x + q1.x * q2.w + q1.y * q2.z - q1.z * q2.y,
            y: q1.w * q2.y - q1.x * q2.z + q1.y * q2.w + q1.z * q2.x,
            z: q1.w * q2.z + q1.x * q2.y - q1.y * q2.x + q1.z * q2.w,
            w: q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z
        )
    }

    /// Reset rotacji kostki do domyślnego widoku
    func resetCubeRotation(animated: Bool = true) {
        let defaultRotation = SCNVector4(0, 1, 0, 0)

        if animated {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            cubeRootNode?.rotation = defaultRotation
            SCNTransaction.commit()
        } else {
            cubeRootNode?.rotation = defaultRotation
        }

        currentRotation = defaultRotation
    }
}

// MARK: - Extensions

extension SCNVector3 {
    func normalized() -> SCNVector3 {
        let length = sqrt(x * x + y * y + z * z)
        return length > 0 ? SCNVector3(x / length, y / length, z / length) : self
    }
}
