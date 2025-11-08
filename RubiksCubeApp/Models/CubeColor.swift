//
//  CubeColor.swift
//  RubiksCubeApp
//
//  Definiuje kolory kostki Rubika zgodne ze standardem
//

import Foundation
import SceneKit

/// Kolory ścianek kostki Rubika (standard międzynarodowy)
enum CubeColor: Int, CaseIterable {
    case white = 0   // Góra (U - Up)
    case yellow = 1  // Dół (D - Down)
    case red = 2     // Przód (F - Front)
    case orange = 3  // Tył (B - Back)
    case green = 4   // Prawo (R - Right)
    case blue = 5    // Lewo (L - Left)
    case black = 6   // Kolor wewnętrzny/pusty

    /// Zwraca kolor SceneKit dla danej ścianki
    var sceneColor: SCNVector4 {
        switch self {
        case .white:  return SCNVector4(0.95, 0.95, 0.95, 1.0)
        case .yellow: return SCNVector4(1.0, 0.85, 0.0, 1.0)
        case .red:    return SCNVector4(0.9, 0.1, 0.1, 1.0)
        case .orange: return SCNVector4(1.0, 0.5, 0.0, 1.0)
        case .green:  return SCNVector4(0.0, 0.7, 0.2, 1.0)
        case .blue:   return SCNVector4(0.0, 0.3, 0.8, 1.0)
        case .black:  return SCNVector4(0.1, 0.1, 0.1, 1.0)
        }
    }

    /// Nazwa koloru dla debugowania
    var name: String {
        switch self {
        case .white: return "White"
        case .yellow: return "Yellow"
        case .red: return "Red"
        case .orange: return "Orange"
        case .green: return "Green"
        case .blue: return "Blue"
        case .black: return "Black"
        }
    }
}

/// Reprezentuje jedną z 6 ścian kostki
enum CubeFace: Int, CaseIterable {
    case top = 0    // U (Up) - biała
    case bottom = 1 // D (Down) - żółta
    case front = 2  // F (Front) - czerwona
    case back = 3   // B (Back) - pomarańczowa
    case right = 4  // R (Right) - zielona
    case left = 5   // L (Left) - niebieska

    /// Domyślny kolor dla danej ściany
    var defaultColor: CubeColor {
        switch self {
        case .top: return .white
        case .bottom: return .yellow
        case .front: return .red
        case .back: return .orange
        case .right: return .green
        case .left: return .blue
        }
    }

    /// Wektor normalny ściany w przestrzeni 3D
    var normalVector: SCNVector3 {
        switch self {
        case .top:    return SCNVector3(0, 1, 0)
        case .bottom: return SCNVector3(0, -1, 0)
        case .front:  return SCNVector3(0, 0, 1)
        case .back:   return SCNVector3(0, 0, -1)
        case .right:  return SCNVector3(1, 0, 0)
        case .left:   return SCNVector3(-1, 0, 0)
        }
    }
}
