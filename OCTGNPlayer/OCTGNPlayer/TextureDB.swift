//
//  TextureDB.swift
//  OCTGNPlayer
//
//  Created by Greg Langmead on 2/17/19.
//  Copyright © 2019 Greg Langmead. All rights reserved.
//

import Foundation
import SpriteKit
import FileBrowser

// Card has id and type
//   id should lead directly to URL for the front, and sometimes a URL for the back
//     if no back is found, we ask the user to help us grow a map from type to URL
//       we keep this type -> URL mapping in a config dictionary we save with the table

class TextureDB {
    var idToFront : [String: SKTexture]
    var idOrTypeToBack : [String: SKTexture]
    var tableConfig : [String:String]

    init() {
        self.idToFront = [:]
        self.idOrTypeToBack = [:]
        self.tableConfig = [:]
    }
    
    func urlToImage(url : URL) -> UIImage? {
        var image: UIImage? = nil
        do {
            let imageData = try Data(contentsOf: url)
            image = UIImage(data: imageData)
        } catch {
            print("Error loading image: \(error)")
        }
        return image
    }
    
    func findPathsStartingWith(id : String) -> [URL] {
        let idPlusDot = id + "."
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let url = URL(fileURLWithPath: documentsPath)
        
        let fileManager = FileManager.default
        let enumerator: FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: url.path)!
        var results : [URL] = []
        while let filePath = enumerator.nextObject() as? String {
            let fileURL = URL(fileURLWithPath: filePath, relativeTo: url)
            if fileURL.lastPathComponent.hasPrefix(idPlusDot) {
                results.append(fileURL)
            }
        }
        return results
    }
    
    func get(card: Card) -> (SKTexture, SKTexture) {
        var frontTexture : SKTexture? = nil
        var backTexture : SKTexture? = nil
        
        // check if the front is already mapped to a texture
        if let tex = self.idToFront[card.id] {
            frontTexture = tex
        // card id needs to be searched -- might turn up 0, 1 or 2 paths
        } else {
            let urls = findPathsStartingWith(id: card.id)
            if urls.count >= 1 {
                frontTexture = SKTexture(image: urlToImage(url: urls[0])!)
                self.idToFront[card.id] = frontTexture
            } else {
                if urls.count == 2 {
                    backTexture = SKTexture(image: urlToImage(url: urls[1])!)
                    self.idOrTypeToBack[card.id] = backTexture
                }
            }
        }
        
        // if backTexture is still unassigned, we must use its type
        if backTexture == nil {
            let key = card.type
            if let urlStr = tableConfig[key] {
                backTexture = SKTexture(image: urlToImage(url: URL(fileURLWithPath: urlStr))!)
                self.idOrTypeToBack[key] = backTexture
            // no one has mapped the type to an image URL, prompt the user
            }
//            else {
//                let fileBrowser = FileBrowser()
//                var vc = UIApplication.shared.keyWindow?.rootViewController
//                while (vc?.presentedViewController != nil) {
//                    vc = vc?.presentedViewController
//                }
//                vc?.present(fileBrowser, animated: true, completion: {
//                    
//                })
//            }
        }
        if backTexture == nil {
            backTexture = frontTexture
        }
        return (frontTexture!, backTexture!)
    }
}
