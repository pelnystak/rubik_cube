//
//  RubiksCube.swift
//  RubiksCubeApp
//
//  Główny model logiczny kostki Rubika 3x3x3
//

import Foundation
import Combine

/// Główna klasa zarządzająca stanem kostki Rubika
class RubiksCube: ObservableObject {
    /// Tablica 27 cubies (3x3x3)
    @Published var cubies: [Cubie] = []

    /// Historia wykonanych ruchów
    @Published var moveHistory: [Move] = []

    /// Czy kostka jest w trakcie animacji
    @Published var isAnimating: Bool = false

    /// Czy kostka jest ułożona
    var isSolved: Bool {
        // Sprawdź czy każda ściana ma jednolity kolor
        for face in CubeFace.allCases {
            let faceColors = getCubiesOnFace(face).compactMap { $0.colors[face] }
            guard let firstColor = faceColors.first else { continue }
            if !faceColors.allSatisfy({ $0 == firstColor }) {
                return false
            }
        }
        return true
    }

    init() {
        initializeCube()
    }

    /// Inicjalizuje kostkę w stanie rozwiązanym
    func initializeCube() {
        cubies.removeAll()

        for x in 0...2 {
            for y in 0...2 {
                for z in 0...2 {
                    // Pomijamy środkowy cubie (niewidoczny)
                    if x == 1 && y == 1 && z == 1 {
                        continue
                    }

                    let position = CubePosition(x: x, y: y, z: z)
                    let cubie = Cubie(position: position)
                    cubies.append(cubie)
                }
            }
        }
    }

    /// Resetuje kostkę do stanu rozwiązanego
    func reset() {
        initializeCube()
        moveHistory.removeAll()
    }

    /// Wykonuje ruch na kostce
    func performMove(_ moveType: MoveType, animated: Bool = true) {
        let move = Move(type: moveType)
        moveHistory.append(move)

        // Pobierz cubies na danej ścianie
        let affectedCubies = getCubiesOnFace(moveType.face)

        // Wykonaj rotację kolorów
        rotateColors(for: affectedCubies, move: moveType)

        // Zaktualizuj pozycje cubies
        updatePositions(for: affectedCubies, move: moveType)
    }

    /// Cofa ostatni ruch
    func undoLastMove() {
        guard let lastMove = moveHistory.popLast() else { return }
        performMove(lastMove.type.inverse, animated: true)
        // Usuń ruch inverse z historii
        moveHistory.removeLast()
    }

    /// Miesza kostkę losowymi ruchami
    func scramble(moves: Int = 25) {
        moveHistory.removeAll()
        var previousMove: MoveType?

        for _ in 0..<moves {
            var randomMove: MoveType
            repeat {
                randomMove = MoveType.allCases.randomElement()!
            } while randomMove == previousMove || randomMove.inverse == previousMove

            performMove(randomMove, animated: false)
            previousMove = randomMove
        }
    }

    // MARK: - Private Methods

    /// Zwraca cubies na danej ścianie
    private func getCubiesOnFace(_ face: CubeFace) -> [Cubie] {
        return cubies.filter { $0.position.isOnFace(face) }
    }

    /// Rotuje kolory cubies zgodnie z ruchem
    private func rotateColors(for cubies: [Cubie], move: MoveType) {
        let clockwise = move.angle > 0

        for cubie in cubies {
            switch move.face {
            case .top, .bottom:
                cubie.rotateY(clockwise: clockwise)
            case .right, .left:
                cubie.rotateX(clockwise: clockwise)
            case .front, .back:
                cubie.rotateZ(clockwise: clockwise)
            }
        }
    }

    /// Aktualizuje pozycje cubies po ruchu
    private func updatePositions(for cubies: [Cubie], move: MoveType) {
        let clockwise = move.angle > 0

        for cubie in cubies {
            let pos = cubie.position
            var newX = pos.x
            var newY = pos.y
            var newZ = pos.z

            switch move.face {
            case .top: // Y = 2
                if clockwise {
                    (newX, newZ) = (2 - pos.z, pos.x)
                } else {
                    (newX, newZ) = (pos.z, 2 - pos.x)
                }
            case .bottom: // Y = 0
                if clockwise {
                    (newX, newZ) = (pos.z, 2 - pos.x)
                } else {
                    (newX, newZ) = (2 - pos.z, pos.x)
                }
            case .right: // X = 2
                if clockwise {
                    (newY, newZ) = (pos.z, 2 - pos.y)
                } else {
                    (newY, newZ) = (2 - pos.z, pos.y)
                }
            case .left: // X = 0
                if clockwise {
                    (newY, newZ) = (2 - pos.z, pos.y)
                } else {
                    (newY, newZ) = (pos.z, 2 - pos.y)
                }
            case .front: // Z = 2
                if clockwise {
                    (newX, newY) = (pos.y, 2 - pos.x)
                } else {
                    (newX, newY) = (2 - pos.y, pos.x)
                }
            case .back: // Z = 0
                if clockwise {
                    (newX, newY) = (2 - pos.y, pos.x)
                } else {
                    (newX, newY) = (pos.y, 2 - pos.x)
                }
            }

            cubie.position = CubePosition(x: newX, y: newY, z: newZ)
        }
    }

    /// Tworzy kopię kostki (do undo/redo)
    func createSnapshot() -> [Cubie] {
        return cubies.map { $0.copy() }
    }

    /// Przywraca stan z kopii
    func restoreSnapshot(_ snapshot: [Cubie]) {
        cubies = snapshot.map { $0.copy() }
    }
}
