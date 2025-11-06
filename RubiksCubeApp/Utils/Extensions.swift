//
//  Extensions.swift
//  RubiksCubeApp
//
//  Pomocnicze rozszerzenia
//

import Foundation
import SceneKit

// MARK: - SCNVector3 Extensions

extension SCNVector3 {
    /// Długość wektora
    var length: Float {
        return sqrt(x * x + y * y + z * z)
    }

    /// Znormalizowany wektor
    func normalized() -> SCNVector3 {
        let len = length
        return len > 0 ? SCNVector3(x / len, y / len, z / len) : self
    }

    /// Dodawanie wektorów
    static func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
    }

    /// Odejmowanie wektorów
    static func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x - right.x, left.y - right.y, left.z - right.z)
    }

    /// Mnożenie przez skalar
    static func * (vector: SCNVector3, scalar: Float) -> SCNVector3 {
        return SCNVector3(vector.x * scalar, vector.y * scalar, vector.z * scalar)
    }

    /// Iloczyn skalarny (dot product)
    func dot(_ other: SCNVector3) -> Float {
        return x * other.x + y * other.y + z * other.z
    }

    /// Iloczyn wektorowy (cross product)
    func cross(_ other: SCNVector3) -> SCNVector3 {
        return SCNVector3(
            y * other.z - z * other.y,
            z * other.x - x * other.z,
            x * other.y - y * other.x
        )
    }
}

// MARK: - SCNQuaternion Definition

struct SCNQuaternion {
    var x: Float
    var y: Float
    var z: Float
    var w: Float

    init(x: Float, y: Float, z: Float, w: Float) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }

    /// Tworzy quaternion z axis-angle
    init(axis: SCNVector3, angle: Float) {
        let halfAngle = angle / 2
        let sinHalf = sin(halfAngle)
        let normalizedAxis = axis.normalized()

        self.x = normalizedAxis.x * sinHalf
        self.y = normalizedAxis.y * sinHalf
        self.z = normalizedAxis.z * sinHalf
        self.w = cos(halfAngle)
    }

    /// Konwertuje quaternion do axis-angle
    func toAxisAngle() -> (axis: SCNVector3, angle: Float) {
        let angle = 2 * acos(w)
        let s = sqrt(1 - w * w)

        let axis: SCNVector3
        if s < 0.001 {
            axis = SCNVector3(x, y, z)
        } else {
            axis = SCNVector3(x / s, y / s, z / s)
        }

        return (axis, angle)
    }

    /// Mnożenie quaternionów
    static func * (lhs: SCNQuaternion, rhs: SCNQuaternion) -> SCNQuaternion {
        return SCNQuaternion(
            x: lhs.w * rhs.x + lhs.x * rhs.w + lhs.y * rhs.z - lhs.z * rhs.y,
            y: lhs.w * rhs.y - lhs.x * rhs.z + lhs.y * rhs.w + lhs.z * rhs.x,
            z: lhs.w * rhs.z + lhs.x * rhs.y - lhs.y * rhs.x + lhs.z * rhs.w,
            w: lhs.w * rhs.w - lhs.x * rhs.x - lhs.y * rhs.y - lhs.z * rhs.z
        )
    }

    /// Normalizacja quaterniona
    func normalized() -> SCNQuaternion {
        let length = sqrt(x * x + y * y + z * z + w * w)
        return length > 0 ? SCNQuaternion(x: x / length, y: y / length, z: z / length, w: w / length) : self
    }
}

// MARK: - Color Extensions

extension UIColor {
    /// Tworzy UIColor z SCNVector4
    convenience init(scnVector4: SCNVector4) {
        self.init(
            red: CGFloat(scnVector4.x),
            green: CGFloat(scnVector4.y),
            blue: CGFloat(scnVector4.z),
            alpha: CGFloat(scnVector4.w)
        )
    }
}

// MARK: - Animation Helpers

extension SCNNode {
    /// Animuje rotację węzła
    func animateRotation(to rotation: SCNVector4, duration: TimeInterval, completion: (() -> Void)? = nil) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = duration
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        SCNTransaction.completionBlock = completion

        self.rotation = rotation

        SCNTransaction.commit()
    }

    /// Animuje pozycję węzła
    func animatePosition(to position: SCNVector3, duration: TimeInterval, completion: (() -> Void)? = nil) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = duration
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        SCNTransaction.completionBlock = completion

        self.position = position

        SCNTransaction.commit()
    }
}

// MARK: - Random Helpers

extension Array {
    /// Zwraca losowy element lub nil jeśli tablica jest pusta
    func randomElement() -> Element? {
        guard !isEmpty else { return nil }
        let randomIndex = Int.random(in: 0..<count)
        return self[randomIndex]
    }
}
