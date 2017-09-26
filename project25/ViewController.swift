//
//  ViewController.swift
//  project25
//
//  Created by Amber Spadafora on 9/24/17.
//  Copyright © 2017 Amber Spadafora. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import CoreData

class ViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var images: [UIImage] = [] {
        didSet {
            self.collectionView?.reloadData()
        }
    }
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    var managedContext: NSManagedObjectContext!
    let appD = UIApplication.shared.delegate as! AppDelegate
    var dataSource: SharedPicsCollectionViewDataSource!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar()
        
        appD.coreDataStack.fetchImages(callback: { (pictures) in
            guard let safePics = pictures else { return }
            for pic in safePics {
                let image = pic.uiImage()
                self.images.insert(image, at: 0)
            }
            self.dataSource = SharedPicsCollectionViewDataSource(images: self.images, cellIdentifier: "ImageView")
            self.collectionView?.dataSource = self.dataSource
            self.collectionView?.reloadData()
        })
        
        
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        
        mcSession.delegate = self
    }
    
    // displaying an alert controller
    @objc func importPhotos() {
        let ac = UIAlertController(title: "Select an image source", message: "", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Take a picture", style: .default, handler: openCamera))
        ac.addAction(UIAlertAction(title: "Choose from library", style: .default, handler: displayImagePicker))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func openCamera(action: UIAlertAction){
        // add camera functionality
    }
    
    // displays an image picker controller
    @objc func displayImagePicker(action: UIAlertAction) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    // displays an alert controller
    @objc func showConnectionPrompt() {
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        dismiss(animated: true)
        
        if let imageData = UIImagePNGRepresentation(image) {
            appD.coreDataStack.addPhoto(image: imageData)
            appD.coreDataStack.fetchImages(callback: { (pictures) in
                guard let safePics = pictures else { return }
                for pic in safePics {
                    self.images.removeAll()
                    let image = pic.uiImage()
                    self.images.insert(image, at: 0)
                }
            })
            
            if mcSession.connectedPeers.count > 0 {
                do {
                    try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)
                }
                catch {
                    let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    present(ac, animated: true)
                }
            }
        }
        
    }
    
    func startHosting(action: UIAlertAction) {
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "hws-project25", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant.start()
    }
    
    func joinSession(action: UIAlertAction) {
        let mcBrowser = MCBrowserViewController(serviceType: "hws-project25", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }

    func setUpNavBar(){
        self.title = "Selfie Share"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPhotos))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showConnectionPrompt))
    }
}

extension ViewController: MCSessionDelegate {
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        self.appD.coreDataStack.addPhoto(image: data)
        if let image = UIImage(data: data) {
            DispatchQueue.main.async {
                [unowned self] in
                self.images.insert(image, at: 0)
                self.collectionView?.reloadData()
            }
        }
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            print("Not connected: \(peerID.displayName)")
        case .connected:
            print("Connected: \(peerID.displayName)")
        case .connecting:
            print("Connecting: \(peerID.displayName)")
        }
    }
    
    @available(iOS 7.0, *)
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
}

extension ViewController: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
}









