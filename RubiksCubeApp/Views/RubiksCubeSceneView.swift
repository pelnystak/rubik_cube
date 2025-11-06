//
//  RubiksCubeSceneView.swift
//  RubiksCubeApp
//
//  UIViewRepresentable dla SceneKit view
//

import SwiftUI
import SceneKit

struct RubiksCubeSceneView: UIViewRepresentable {
    @ObservedObject var sceneController: CubeSceneController

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()

        // Konfiguracja widoku
        scnView.scene = sceneController.scene
        scnView.allowsCameraControl = false // Wyłączamy domyślną kontrolę kamery
        scnView.autoenablesDefaultLighting = false // Używamy własnego oświetlenia
        scnView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)

        // Antyaliasing dla lepszej jakości
        scnView.antialiasingMode = .multisampling4X

        // Włącz HDR
        scnView.technique = createHDRTechnique()

        // Dodaj gesty
        setupGestures(for: scnView, context: context)

        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        // Aktualizacja widoku gdy zmieni się stan
        scnView.scene = sceneController.scene
    }

    private func setupGestures(for view: SCNView, context: Context) {
        let gestureHandler = context.coordinator.gestureHandler

        // Pan gesture dla obracania kostki
        let panGesture = UIPanGestureRecognizer(target: gestureHandler, action: #selector(GestureHandler.handlePan(_:)))
        view.addGestureRecognizer(panGesture)

        // Swipe gestures dla obracania warstw
        let swipeDirections: [UISwipeGestureRecognizer.Direction] = [.right, .left, .up, .down]
        for direction in swipeDirections {
            let swipeGesture = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleSwipe(_:)))
            swipeGesture.direction = direction
            view.addGestureRecognizer(swipeGesture)
        }

        // Pinch gesture dla zoom
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
        view.addGestureRecognizer(pinchGesture)

        // Tap gesture
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)

        // Zapisz referencję do view w coordinatorze
        context.coordinator.scnView = view
    }

    private func createHDRTechnique() -> SCNTechnique? {
        // Opcjonalnie: dodaj HDR post-processing
        // Na razie zwracamy nil dla prostoty
        return nil
    }

    // MARK: - Coordinator

    func makeCoordinator() -> Coordinator {
        Coordinator(sceneController: sceneController)
    }

    class Coordinator: NSObject {
        let gestureHandler: GestureHandler
        weak var scnView: SCNView?

        init(sceneController: CubeSceneController) {
            self.gestureHandler = GestureHandler(sceneController: sceneController)
        }

        @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
            guard let scnView = scnView else { return }
            gestureHandler.handleSwipe(gesture, scnView: scnView)
        }

        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard let scnView = scnView else { return }
            gestureHandler.handlePinch(gesture, scnView: scnView)
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let scnView = scnView else { return }
            gestureHandler.handleTap(gesture, scnView: scnView)
        }
    }
}
