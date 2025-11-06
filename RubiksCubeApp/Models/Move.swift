//
//  Move.swift
//  RubiksCubeApp
//
//  Definiuje możliwe ruchy na kostce Rubika
//

import Foundation

/// Typ ruchu - zgodny z notacją Singmaster
enum MoveType: String, CaseIterable {
    // Podstawowe ruchy
    case U  // Góra zgodnie z ruchem wskazówek zegara
    case Up // Góra przeciwnie do ruchu wskazówek (U')
    case D  // Dół zgodnie z ruchem wskazówek
    case Dp // Dół przeciwnie (D')
    case F  // Przód zgodnie z ruchem wskazówek
    case Fp // Przód przeciwnie (F')
    case B  // Tył zgodnie z ruchem wskazówek
    case Bp // Tył przeciwnie (B')
    case R  // Prawo zgodnie z ruchem wskazówek
    case Rp // Prawo przeciwnie (R')
    case L  // Lewo zgodnie z ruchem wskazówek
    case Lp // Lewo przeciwnie (L')

    /// Oś rotacji dla danego ruchu
    var axis: SCNVector3 {
        switch self {
        case .U, .Up:  return SCNVector3(0, 1, 0)
        case .D, .Dp:  return SCNVector3(0, -1, 0)
        case .F, .Fp:  return SCNVector3(0, 0, 1)
        case .B, .Bp:  return SCNVector3(0, 0, -1)
        case .R, .Rp:  return SCNVector3(1, 0, 0)
        case .L, .Lp:  return SCNVector3(-1, 0, 0)
        }
    }

    /// Kąt rotacji w radianach (90° lub -90°)
    var angle: Float {
        switch self {
        case .U, .D, .F, .B, .R, .L:
            return .pi / 2  // 90° zgodnie z ruchem wskazówek
        case .Up, .Dp, .Fp, .Bp, .Rp, .Lp:
            return -.pi / 2 // 90° przeciwnie
        }
    }

    /// Ściana, która się obraca
    var face: CubeFace {
        switch self {
        case .U, .Up:  return .top
        case .D, .Dp:  return .bottom
        case .F, .Fp:  return .front
        case .B, .Bp:  return .back
        case .R, .Rp:  return .right
        case .L, .Lp:  return .left
        }
    }

    /// Ruch odwrotny
    var inverse: MoveType {
        switch self {
        case .U: return .Up
        case .Up: return .U
        case .D: return .Dp
        case .Dp: return .D
        case .F: return .Fp
        case .Fp: return .F
        case .B: return .Bp
        case .Bp: return .B
        case .R: return .Rp
        case .Rp: return .R
        case .L: return .Lp
        case .Lp: return .L
        }
    }
}

/// Reprezentuje pojedynczy ruch na kostce
struct Move {
    let type: MoveType
    let timestamp: Date

    init(type: MoveType) {
        self.type = type
        self.timestamp = Date()
    }
}
