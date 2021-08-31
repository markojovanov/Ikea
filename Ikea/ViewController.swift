//
//  ViewController.swift
//  Ikea
//
//  Created by Marko Jovanov on 31.8.21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    let itemsArray = ["cup","vase","boxing","table"]
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    var selectedItem: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.debugOptions = [.showFeaturePoints]
        itemsCollectionView.delegate = self
        itemsCollectionView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsArray.count
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTest = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            if !hitTest.isEmpty {
                if let hitTestResult = hitTest.first {
                    addItem(hitTestResult: hitTestResult)
                }
            }
        }
    }
    func addItem(hitTestResult: ARHitTestResult) {
        if let selectedItemResult = selectedItem {
            print("\(selectedItemResult) -> u sceneItem")
            let sceneItem = SCNScene(named: "\(selectedItemResult).scn")
            if let nodeItem = sceneItem?.rootNode.childNode(withName: selectedItemResult, recursively: false) {
                let transform = hitTestResult.worldTransform.columns.3
                nodeItem.position = SCNVector3(transform.x,
                                                transform.y,
                                                transform.z)
                sceneView.scene.rootNode.addChildNode(nodeItem)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! itemCell
        cell.itemLabel.text = itemsArray[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        selectedItem = itemsArray[indexPath.item]
        print(itemsArray[indexPath.item])
        cell?.backgroundColor = UIColor.green
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.orange
    }
}
