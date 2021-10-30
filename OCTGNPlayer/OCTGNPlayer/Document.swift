//
//  Document.swift
//  OCTGNPlayer
//
//  Created by Greg Langmead on 2/17/19.
//  Copyright © 2019 Greg Langmead. All rights reserved.
//

import UIKit

class Document: UIDocument {
    var table : Table
    
    override init(fileURL url: URL) {
        self.table = Table()
        super.init(fileURL: url)
    }
    
    func getTable() -> Table {
        return table
    }
    
    override func contents(forType typeName: String) throws -> Any {
        return table.toJson().data(using: .utf8)!
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        let json = try? JSONSerialization.jsonObject(with: contents as! Data, options: [])
        self.table = Table(json: json as! [String:Any])!
    }
}

