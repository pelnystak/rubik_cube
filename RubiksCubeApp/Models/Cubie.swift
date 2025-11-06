//
//  Cubie.swift
//  RubiksCubeApp
//
//  Reprezentuje pojedynczy element (cubelet) kostki Rubika
//

import Foundation
import SceneKit

/// Pozycja cubie w kostce (współrzędne 0, 1, 2)
struct CubePosition: Equatable, Hashable {
    let x: Int // 0 = lewo, 1 = środek, 2 = prawo
    let y: Int // 0 = dół, 1 = środek, 2 = góra
    let z: Int // 0 = tył, 1 = środek, 2 = przód

    /// Sprawdza czy cubie jest na danej ścianie
    func isOnFace(_ face: CubeFace) -> Bool {
        switch face {
        case .top:    return y == 2
        case .bottom: return y == 0
        case .front:  return z == 2
        case .back:   return z == 0
        case .right:  return x == 2
        case .left:   return x == 0
        }
    }

    /// Sprawdza czy cubie jest narożnikiem
    var isCorner: Bool {
        let positions = [x, y, z].filter { $0 == 1 }
        return positions.count == 0
    }

    /// Sprawdza czy cubie jest krawędzią
    var isEdge: Bool {
        let positions = [x, y, z].filter { $0 == 1 }
        return positions.count == 1
    }

    /// Sprawdza czy cubie jest środkiem
    var isCenter: Bool {
        let positions = [x, y, z].filter { $0 == 1 }
        return positions.count == 2
    }
}

/// Pojedynczy element kostki Rubika
class Cubie {
    /// Pozycja w kostce (0-2 dla każdej osi)
    var position: CubePosition

    /// Kolory 6 ścianek cubie (Top, Bottom, Front, Back, Right, Left)
    var colors: [CubeFace: CubeColor]

    /// Węzeł SceneKit reprezentujący ten cubie
    var node: SCNNode?

    /// Identyfikator unikalny
    let id: UUID

    init(position: CubePosition) {
        self.position = position
        self.colors = [:]
        self.id = UUID()

        // Ustaw kolory dla widocznych ścianek
        for face in CubeFace.allCases {
            if position.isOnFace(face) {
                colors[face] = face.defaultColor
            } else {
                colors[face] = .black // Wewnętrzna ścianka (niewidoczna)
            }
        }
    }

    /// Tworzy kopię cubie
    func copy() -> Cubie {
        let newCubie = Cubie(position: position)
        newCubie.colors = colors
        return newCubie
    }

    /// Obraca cubie wokół osi Y (dla ruchów U/D)
    func rotateY(clockwise: Bool) {
        let oldColors = colors
        if clockwise {
            colors[.front] = oldColors[.left] ?? .black
            colors[.right] = oldColors[.front] ?? .black
            colors[.back] = oldColors[.right] ?? .black
            colors[.left] = oldColors[.back] ?? .black
        } else {
            colors[.front] = oldColors[.right] ?? .black
            colors[.left] = oldColors[.front] ?? .black
            colors[.back] = oldColors[.left] ?? .black
            colors[.right] = oldColors[.back] ?? .black
        }
    }

    /// Obraca cubie wokół osi X (dla ruchów R/L)
    func rotateX(clockwise: Bool) {
        let oldColors = colors
        if clockwise {
            colors[.top] = oldColors[.front] ?? .black
            colors[.back] = oldColors[.top] ?? .black
            colors[.bottom] = oldColors[.back] ?? .black
            colors[.front] = oldColors[.bottom] ?? .black
        } else {
            colors[.front] = oldColors[.top] ?? .black
            colors[.top] = oldColors[.back] ?? .black
            colors[.back] = oldColors[.bottom] ?? .black
            colors[.bottom] = oldColors[.front] ?? .black
        }
    }

    /// Obraca cubie wokół osi Z (dla ruchów F/B)
    func rotateZ(clockwise: Bool) {
        let oldColors = colors
        if clockwise {
            colors[.top] = oldColors[.left] ?? .black
            colors[.right] = oldColors[.top] ?? .black
            colors[.bottom] = oldColors[.right] ?? .black
            colors[.left] = oldColors[.bottom] ?? .black
        } else {
            colors[.left] = oldColors[.top] ?? .black
            colors[.top] = oldColors[.right] ?? .black
            colors[.right] = oldColors[.bottom] ?? .black
            colors[.bottom] = oldColors[.left] ?? .black
        }
    }
}
