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
    let itemsArray = ["table","cup","vase","boxing"]
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    var selectedItem: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        itemsCollectionView.delegate = self
        itemsCollectionView.dataSource = self
        sceneView.autoenablesDefaultLighting = true
        registerGestureRecognizers()
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
    
    func addItem(hitTestResult: ARHitTestResult) {
        if let selectedItemResult = selectedItem {
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
    
    //MARK: - CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! itemCell
        cell.itemLabel.text = itemsArray[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        selectedItem = itemsArray[indexPath.item]
        cell?.backgroundColor = UIColor.green
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.orange
    }
    
    //MARK: - GestureRecongizers
    
    func registerGestureRecognizers() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self,
                                                              action: #selector(pinch))
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self,
                                                                      action: #selector(rotate))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        longPressGestureRecognizer.minimumPressDuration = 0.1
        sceneView.addGestureRecognizer(pinchGestureRecognizer)
        sceneView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func tapped(sender: UITapGestureRecognizer) {
        let sceneViewTapped = sender.view as! ARSCNView
        let tapLocation = sender.location(in: sceneViewTapped)
        let hitTest = sceneViewTapped.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        if !hitTest.isEmpty {
            self.addItem(hitTestResult: hitTest.first!)
        }
    }
    
    @objc func pinch(sender: UIPinchGestureRecognizer) {
        let sceneViewPinch = sender.view as! ARSCNView
        let pinchLocation = sender.location(in: sceneViewPinch)
        let hitTest = sceneViewPinch.hitTest(pinchLocation)
        if !hitTest.isEmpty {
            let node = hitTest.first?.node
            let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
            node?.runAction(pinchAction)
            sender.scale = 1.0
        }
    }
    @objc func rotate(sender: UILongPressGestureRecognizer) {
        let sceneViewRotate = sender.view as! ARSCNView
        let holdLocation = sender.location(in: sceneViewRotate)
        let hitTest = sceneViewRotate.hitTest(holdLocation)
        if !hitTest.isEmpty {
            let node = hitTest.first?.node
            if sender.state == .began {
                let action = SCNAction.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 1)
                let foreverAction = SCNAction.repeatForever(action)
                node?.runAction(foreverAction)
            } else if sender.state == .ended {
                node?.removeAllActions()
            }
        }
    }
}
