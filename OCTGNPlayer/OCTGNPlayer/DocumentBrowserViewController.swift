//
//  DocumentBrowserViewController.swift
//  OCTGNPlayer
//
//  Created by Greg Langmead on 2/17/19.
//  Copyright © 2019 Greg Langmead. All rights reserved.
//

import UIKit


class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        allowsDocumentCreation = true
        allowsPickingMultipleItems = false
        
        // Update the style of the UIDocumentBrowserViewController
        // browserUserInterfaceStyle = .dark
        // view.tintColor = .white
        
        // Specify the allowed content types of your application via the Info.plist.
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    
    func uniqueTempFolderURL() -> URL
    {
        return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let newDocumentURL: URL = uniqueTempFolderURL().appendingPathComponent("table.json")
        let newDoc = Document(fileURL: newDocumentURL)
        
        // Create a new document in a temporary location
        newDoc.save(to: newDocumentURL, for: .forCreating) { (saveSuccess) in
            
            // Make sure the document saved successfully
            guard saveSuccess else {
                // Cancel document creation
                importHandler(nil, .none)
                return
            }
            
            // Close the document.
            newDoc.close(completionHandler: { (closeSuccess) in
                
                // Make sure the document closed successfully
                guard closeSuccess else {
                    // Cancel document creation
                    importHandler(nil, .none)
                    return
                }
                
                // Pass the document's temporary URL to the import handler.
                importHandler(newDocumentURL, .move)
            })
        }
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }
    
    // MARK: Document Presentation
    
    func presentDocument(at documentURL: URL) {
        let documentViewController = DocumentViewController(fileURL: documentURL)
        present(documentViewController, animated: true, completion: nil)
    }
}

