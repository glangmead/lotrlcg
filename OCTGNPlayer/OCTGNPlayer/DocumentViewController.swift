//
//  DocumentViewController.swift
//  OCTGNPlayer
//
//  Created by Greg Langmead on 2/17/19.
//  Copyright © 2019 Greg Langmead. All rights reserved.
//

import UIKit
import MobileCoreServices
import ZIPFoundation
import SpriteKit

class DocumentViewController: UIViewController, UINavigationBarDelegate, UIDocumentPickerDelegate {
    
    var documentNameLabel: UILabel
    var document: Document
    var skView : SKView
    var tableScene : TableScene? = nil
    var navBar : UINavigationBar
    let scaleSlider : UISlider
    
    init(fileURL url: URL) {
        self.documentNameLabel = UILabel()
        self.document = Document(fileURL: url)
        self.skView = SKView()
        self.skView.translatesAutoresizingMaskIntoConstraints = false
        self.navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        self.scaleSlider = UISlider(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        super.init(nibName: nil, bundle: nil)

        self.navBar.delegate = self
        self.navBar.barStyle = UIBarStyle.default
        self.navBar.translatesAutoresizingMaskIntoConstraints = false
        self.scaleSlider.addTarget(self, action: #selector(changeScale), for: .valueChanged)
        self.scaleSlider.translatesAutoresizingMaskIntoConstraints = false
        self.scaleSlider.minimumValue = 1.0 / 50.0
        self.scaleSlider.maximumValue = 1.0
    }
    
    @objc func changeScale() {
        self.tableScene!.scale = CGFloat(self.scaleSlider.value)
        self.tableScene!.syncFromModel(tableSize: tableScene!.size)
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.orange
        //self.hidesBarsOnTap = true
        let navItem = UINavigationItem(title: "Table")
        navItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissDocumentViewController))
        navItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addResources))
        self.navBar.pushItem(navItem, animated: false)

        self.tableScene = TableScene(table: self.document.getTable(), size: self.view.frame.size, tapAction: {self.toggleTabBarVisibility()})
        // Set the scale mode to scale to fit the window
        self.tableScene!.scaleMode = .resizeFill
        // Present the scene
        self.view.addSubview(self.skView)
        self.view.addSubview(self.navBar)

        self.skView.showsFPS = true
        self.skView.showsNodeCount = true
        self.skView.ignoresSiblingOrder = false
        self.skView.presentScene(self.tableScene)
        
        self.navBar.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.navBar.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.navBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        self.navBar.addSubview(self.scaleSlider)

        self.skView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.skView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.skView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.skView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        let sliderWidth : CGFloat = 250
        self.scaleSlider.value = 0.2
        self.scaleSlider.rightAnchor.constraint(equalTo: self.navBar.rightAnchor, constant: -50).isActive = true
        self.scaleSlider.centerYAnchor.constraint(equalTo: self.navBar.centerYAnchor).isActive = true
        self.scaleSlider.widthAnchor.constraint(equalToConstant: sliderWidth).isActive = true

    }
    
    
    
    func toggleTabBarVisibility() {
        self.navBar.isHidden = !self.navBar.isHidden
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Access the document
        self.document.open(completionHandler: { (success) in
            if success {
                self.tableScene!.table = self.document.table
                self.tableScene!.syncFromModel(tableSize: self.tableScene!.size) // refresh scenekit data from loaded model data
            } else {
                // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // just for breakpoint purposes to see frames
        print("view did appear")
    }
    
    @objc func dismissDocumentViewController() {
        dismiss(animated: true) {
            self.document.save(to: self.document.fileURL, for: .forOverwriting, completionHandler: nil)
            self.document.close(completionHandler: nil)
        }
    }
    
    @objc func addResources() {
        let importMenu = UIDocumentPickerViewController(documentTypes: [kUTTypeItem] as [String], in: .import)
        
        if #available(iOS 11.0, *) {
            importMenu.allowsMultipleSelection = true
        }
        
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        
        present(importMenu, animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print(urls)
        urls.forEach({addFileToTable(url: $0)})
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.tableScene?.syncFromModel(tableSize: size)
    }
    
    func addFileToTable(url : URL) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentsURL = URL(fileURLWithPath: documentsPath)
        
        let fileManager = FileManager.default
        let destURL = documentsURL.appendingPathComponent(url.lastPathComponent)
        if destURL.lastPathComponent.hasSuffix(".o8c") || destURL.lastPathComponent.hasSuffix(".zip") {
            do {
                try fileManager.copyItem(at: url, to: destURL)
                try fileManager.unzipItem(at: destURL, to: documentsURL)
            } catch {
                print("Unzip failure, probably because it exists already")
            }
        }
        if destURL.lastPathComponent.hasSuffix(".o8d") {
            do {
                try fileManager.copyItem(at: url, to: destURL)
            } catch {
                print("Error copying deck, probably because it exists at the destination already")
            }
            let deckFileData = try! Data.init(contentsOf: destURL)
            let deck = Serialization().deckFromOCTGNXML(data: deckFileData)
            self.document.table.addDeck(deck)
            self.tableScene!.syncFromModel(tableSize: tableScene!.size)
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
