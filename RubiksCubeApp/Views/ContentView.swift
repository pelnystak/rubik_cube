//
//  ContentView.swift
//  RubiksCubeApp
//
//  Główny widok aplikacji z interfejsem użytkownika
//

import SwiftUI

struct ContentView: View {
    @StateObject private var rubiksCube = RubiksCube()
    @StateObject private var sceneController: CubeSceneController

    @State private var showingSolvedAlert = false
    @State private var moveCount = 0
    @State private var isScrambling = false

    init() {
        let cube = RubiksCube()
        _rubiksCube = StateObject(wrappedValue: cube)
        _sceneController = StateObject(wrappedValue: CubeSceneController(rubiksCube: cube))
    }

    var body: some View {
        ZStack {
            // Tło
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.1),
                    Color(red: 0.1, green: 0.1, blue: 0.15)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Nagłówek
                headerView
                    .padding(.top, 50)
                    .padding(.bottom, 20)

                // Scena 3D
                RubiksCubeSceneView(sceneController: sceneController)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)

                // Panel kontrolny
                controlPanel
                    .padding(.vertical, 30)
                    .padding(.horizontal, 20)
            }
        }
        .statusBar(hidden: false)
        .preferredColorScheme(.dark)
        .alert("Gratulacje!", isPresented: $showingSolvedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Ułożyłeś kostkę Rubika w \(moveCount) ruchach!")
        }
        .onChange(of: rubiksCube.moveHistory.count) { newValue in
            moveCount = newValue
            if rubiksCube.isSolved && moveCount > 0 {
                showingSolvedAlert = true
            }
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Rubik's Cube 3D")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            HStack(spacing: 20) {
                // Licznik ruchów
                HStack(spacing: 6) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 14))
                    Text("\(moveCount)")
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                }
                .foregroundColor(.white.opacity(0.8))

                // Status
                HStack(spacing: 6) {
                    Circle()
                        .fill(rubiksCube.isSolved ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                    Text(rubiksCube.isSolved ? "Ułożona" : "Pomieszana")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.8))
            }
        }
    }

    // MARK: - Control Panel

    private var controlPanel: some View {
        VStack(spacing: 16) {
            // Przyciski główne
            HStack(spacing: 16) {
                // Przycisk Scramble
                Button(action: scrambleCube) {
                    HStack(spacing: 8) {
                        Image(systemName: "shuffle")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Pomieszaj")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(sceneController.isAnimating || isScrambling)

                // Przycisk Reset
                Button(action: resetCube) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Reset")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(sceneController.isAnimating || isScrambling)
            }

            // Dodatkowe przyciski
            HStack(spacing: 16) {
                // Cofnij ruch
                Button(action: undoMove) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 14))
                        Text("Cofnij")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.white.opacity(0.1))
                    .foregroundColor(.white.opacity(0.9))
                    .cornerRadius(12)
                }
                .disabled(rubiksCube.moveHistory.isEmpty || sceneController.isAnimating)

                // Reset widoku
                Button(action: resetView) {
                    HStack(spacing: 6) {
                        Image(systemName: "camera.rotate")
                            .font(.system(size: 14))
                        Text("Reset widoku")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.white.opacity(0.1))
                    .foregroundColor(.white.opacity(0.9))
                    .cornerRadius(12)
                }
            }

            // Instrukcja
            Text("Przeciągnij palcem by obracać kostkę\nPrzesuń (swipe) na kostce by obracać warstwy")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
    }

    // MARK: - Actions

    private func scrambleCube() {
        isScrambling = true

        // Animacja mieszania
        DispatchQueue.main.async {
            var delay: Double = 0
            let moves = 25

            for _ in 0..<moves {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    let randomMove = MoveType.allCases.randomElement()!
                    sceneController.animateMove(randomMove) { }
                }
                delay += 0.15 // Krótszy czas dla szybkiego mieszania
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.5) {
                isScrambling = false
            }
        }
    }

    private func resetCube() {
        rubiksCube.reset()
        sceneController.rebuildCube()
        sceneController.resetCubeRotation(animated: true)
        moveCount = 0
    }

    private func undoMove() {
        guard let lastMove = rubiksCube.moveHistory.last else { return }
        sceneController.animateMove(lastMove.type.inverse) {
            rubiksCube.moveHistory.removeLast()
        }
    }

    private func resetView() {
        sceneController.resetCubeRotation(animated: true)
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
