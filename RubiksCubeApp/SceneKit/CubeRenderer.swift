//
//  CubeRenderer.swift
//  RubiksCubeApp
//
//  Renderer odpowiedzialny za tworzenie wizualizacji 3D kostki
//

import Foundation
import SceneKit

class CubeRenderer {
    /// Rozmiar pojedynczego cubie
    private let cubieSize: CGFloat = 1.0

    /// Odstęp między cubies (dla efektu szczelin)
    private let gap: CGFloat = 0.05

    /// Zaokrąglenie krawędzi cubies
    private let chamferRadius: CGFloat = 0.1

    /// Tworzy geometrię dla pojedynczego cubie
    func createCubieGeometry() -> SCNGeometry {
        let box = SCNBox(
            width: cubieSize - gap,
            height: cubieSize - gap,
            length: cubieSize - gap,
            chamferRadius: chamferRadius
        )

        // Utwórz osobny materiał dla każdej ścianki
        let materials = (0..<6).map { _ -> SCNMaterial in
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.black
            material.specular.contents = UIColor.white
            material.shininess = 0.3
            material.lightingModel = .physicallyBased
            material.roughness.contents = 0.4
            material.metalness.contents = 0.1
            return material
        }

        box.materials = materials
        return box
    }

    /// Tworzy węzeł dla pojedynczego cubie
    func createCubieNode(for cubie: Cubie) -> SCNNode {
        let node = SCNNode(geometry: createCubieGeometry())

        // Ustaw pozycję w przestrzeni 3D (przesunięcie o -1 aby wyśrodkować)
        let x = Float(cubie.position.x) - 1.0
        let y = Float(cubie.position.y) - 1.0
        let z = Float(cubie.position.z) - 1.0

        node.position = SCNVector3(
            x * Float(cubieSize),
            y * Float(cubieSize),
            z * Float(cubieSize)
        )

        // Przypisz kolory do materiałów (kolejność: Right, Left, Top, Bottom, Front, Back)
        updateCubieColors(node: node, cubie: cubie)

        // Dodaj cienie
        node.castsShadow = true

        // Zapisz referencję
        cubie.node = node

        return node
    }

    /// Aktualizuje kolory materiałów węzła na podstawie cubie
    func updateCubieColors(node: SCNNode, cubie: Cubie) {
        guard let geometry = node.geometry else { return }

        // Kolejność materiałów w SCNBox: Right(0), Left(1), Top(2), Bottom(3), Front(4), Back(5)
        let materialOrder: [CubeFace] = [.right, .left, .top, .bottom, .front, .back]

        for (index, face) in materialOrder.enumerated() {
            if let color = cubie.colors[face] {
                let material = geometry.materials[index]

                // Ustaw kolor podstawowy
                material.diffuse.contents = UIColor(
                    red: CGFloat(color.sceneColor.x),
                    green: CGFloat(color.sceneColor.y),
                    blue: CGFloat(color.sceneColor.z),
                    alpha: CGFloat(color.sceneColor.w)
                )

                // Dodaj subtelne odbicia
                if color != .black {
                    material.specular.contents = UIColor.white
                    material.shininess = 0.5
                }
            }
        }
    }

    /// Tworzy węzeł zawierający całą kostkę
    func createCubeScene(rubiksCube: RubiksCube) -> SCNNode {
        let rootNode = SCNNode()

        // Utwórz węzły dla wszystkich cubies
        for cubie in rubiksCube.cubies {
            let cubieNode = createCubieNode(for: cubie)
            rootNode.addChildNode(cubieNode)
        }

        return rootNode
    }

    /// Tworzy oświetlenie sceny
    func setupLighting(scene: SCNScene) {
        // Główne światło - symuluje słońce
        let mainLight = SCNLight()
        mainLight.type = .directional
        mainLight.color = UIColor.white
        mainLight.intensity = 1000
        mainLight.castsShadow = true
        mainLight.shadowMode = .deferred
        mainLight.shadowRadius = 3.0
        mainLight.shadowSampleCount = 16

        let mainLightNode = SCNNode()
        mainLightNode.light = mainLight
        mainLightNode.position = SCNVector3(5, 10, 10)
        mainLightNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(mainLightNode)

        // Światło wypełniające (fill light)
        let fillLight = SCNLight()
        fillLight.type = .omni
        fillLight.color = UIColor.white
        fillLight.intensity = 300

        let fillLightNode = SCNNode()
        fillLightNode.light = fillLight
        fillLightNode.position = SCNVector3(-5, 5, -5)
        scene.rootNode.addChildNode(fillLightNode)

        // Światło tylne (rim light)
        let rimLight = SCNLight()
        rimLight.type = .omni
        rimLight.color = UIColor(white: 0.8, alpha: 1.0)
        rimLight.intensity = 200

        let rimLightNode = SCNNode()
        rimLightNode.light = rimLight
        rimLightNode.position = SCNVector3(0, -3, -8)
        scene.rootNode.addChildNode(rimLightNode)

        // Światło ambient dla ogólnego rozjaśnienia
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor(white: 0.3, alpha: 1.0)
        ambientLight.intensity = 100

        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        scene.rootNode.addChildNode(ambientLightNode)
    }

    /// Tworzy kamerę dla sceny
    func setupCamera(scene: SCNScene) -> SCNNode {
        let camera = SCNCamera()
        camera.fieldOfView = 50
        camera.zNear = 0.1
        camera.zFar = 100

        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 8)
        cameraNode.look(at: SCNVector3(0, 0, 0))

        scene.rootNode.addChildNode(cameraNode)
        return cameraNode
    }

    /// Tworzy podłoże z cieniem
    func createFloor(scene: SCNScene) {
        let floor = SCNFloor()
        floor.reflectivity = 0.05

        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = UIColor(white: 0.15, alpha: 1.0)
        floorMaterial.lightingModel = .physicallyBased
        floor.materials = [floorMaterial]

        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(0, -2.5, 0)

        scene.rootNode.addChildNode(floorNode)
    }
}
