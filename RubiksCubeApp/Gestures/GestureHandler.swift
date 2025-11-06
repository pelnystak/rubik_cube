//
//  GestureHandler.swift
//  RubiksCubeApp
//
//  Obsługuje gesty dotykowe dla rotacji kostki i warstw
//

import Foundation
import UIKit
import SceneKit

class GestureHandler: NSObject {
    /// Kontroler sceny
    weak var sceneController: CubeSceneController?

    /// Ostatnia pozycja gestu pan
    private var lastPanLocation: CGPoint = .zero

    /// Czy gest jest w trakcie
    private var isGesturing = false

    /// Threshold dla wykrycia swipe na warstwie
    private let swipeThreshold: CGFloat = 30.0

    /// Punkt początkowy swipe
    private var swipeStartPoint: CGPoint = .zero

    /// Węzeł aktualnie dotykany
    private var touchedNode: SCNNode?

    init(sceneController: CubeSceneController) {
        self.sceneController = sceneController
    }

    // MARK: - Pan Gesture (obracanie całej kostki)

    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let sceneController = sceneController,
              !sceneController.isAnimating else { return }

        let location = gesture.location(in: gesture.view)

        switch gesture.state {
        case .began:
            lastPanLocation = location
            isGesturing = true

        case .changed:
            let deltaX = Float(location.x - lastPanLocation.x)
            let deltaY = Float(location.y - lastPanLocation.y)

            // Oblicz kąt rotacji na podstawie przesunięcia
            let angleX = deltaY * 0.01 // Rotacja wokół osi X (góra-dół)
            let angleY = deltaX * 0.01 // Rotacja wokół osi Y (lewo-prawo)

            // Zastosuj rotację
            if abs(deltaX) > abs(deltaY) {
                sceneController.addRotation(angle: angleY, axis: SCNVector3(0, 1, 0))
            } else {
                sceneController.addRotation(angle: angleX, axis: SCNVector3(1, 0, 0))
            }

            lastPanLocation = location

        case .ended, .cancelled:
            isGesturing = false

        default:
            break
        }
    }

    // MARK: - Swipe Gesture (obracanie warstw)

    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer, scnView: SCNView) {
        guard let sceneController = sceneController,
              !sceneController.isAnimating else { return }

        let location = gesture.location(in: scnView)

        // Wykryj dotknięty węzeł
        let hitResults = scnView.hitTest(location, options: [:])

        guard let hitResult = hitResults.first,
              let cubie = findCubie(for: hitResult.node) else {
            return
        }

        // Określ kierunek swipe
        let direction = gesture.direction

        // Określ ruch na podstawie pozycji cubie i kierunku swipe
        if let move = determineMove(for: cubie, direction: direction, scnView: scnView, location: location) {
            sceneController.animateMove(move) {
                // Opcjonalnie: dodaj wibrację lub dźwięk
                self.triggerHapticFeedback()
            }
        }
    }

    // MARK: - Tap Gesture (szybkie obrócenie warstwy)

    @objc func handleTap(_ gesture: UITapGestureRecognizer, scnView: SCNView) {
        guard let sceneController = sceneController,
              !sceneController.isAnimating else { return }

        let location = gesture.location(in: scnView)
        let hitResults = scnView.hitTest(location, options: [:])

        guard let hitResult = hitResults.first else { return }

        // Możesz dodać logikę dla tap (np. highlight wybranego cubie)
        // Na razie pozostawiam puste dla prostoty
    }

    // MARK: - Helper Methods

    /// Znajduje cubie dla danego węzła
    private func findCubie(for node: SCNNode) -> Cubie? {
        guard let sceneController = sceneController else { return nil }

        // Przejdź przez wszystkie cubies i znajdź ten z pasującym węzłem
        for cubie in sceneController.rubiksCube.cubies {
            if cubie.node == node || cubie.node?.childNodes.contains(node) == true {
                return cubie
            }
        }

        // Sprawdź parent nodes
        var currentNode: SCNNode? = node
        while let parent = currentNode?.parent {
            for cubie in sceneController.rubiksCube.cubies {
                if cubie.node == parent {
                    return cubie
                }
            }
            currentNode = parent
        }

        return nil
    }

    /// Określa ruch na podstawie pozycji cubie i kierunku swipe
    private func determineMove(for cubie: Cubie, direction: UISwipeGestureRecognizer.Direction,
                                scnView: SCNView, location: CGPoint) -> MoveType? {
        let pos = cubie.position

        // Logika wykrywania ruchu na podstawie pozycji i kierunku
        // To jest uproszczona wersja - można ją rozbudować

        switch direction {
        case .right:
            if pos.y == 2 { return .U }
            if pos.y == 0 { return .Dp }
            if pos.z == 2 { return .F }
            if pos.z == 0 { return .Bp }

        case .left:
            if pos.y == 2 { return .Up }
            if pos.y == 0 { return .D }
            if pos.z == 2 { return .Fp }
            if pos.z == 0 { return .B }

        case .up:
            if pos.x == 2 { return .Rp }
            if pos.x == 0 { return .L }
            if pos.z == 2 { return .F }
            if pos.z == 0 { return .Bp }

        case .down:
            if pos.x == 2 { return .R }
            if pos.x == 0 { return .Lp }
            if pos.z == 2 { return .Fp }
            if pos.z == 0 { return .B }

        default:
            break
        }

        return nil
    }

    /// Wywołuje wibrację haptyczną
    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    // MARK: - Rotation Gesture (pinch for zoom - opcjonalne)

    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer, scnView: SCNView) {
        guard let cameraNode = sceneController?.cameraNode else { return }

        switch gesture.state {
        case .changed:
            let pinchScale = Float(gesture.scale)
            let currentZ = cameraNode.position.z

            // Ogranicz zoom
            let newZ = max(5.0, min(15.0, currentZ / pinchScale))
            cameraNode.position.z = newZ

            gesture.scale = 1.0

        default:
            break
        }
    }
}
