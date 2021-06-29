//
//  File.swift
//  
//
//  Created by Chris Eidhof on 29.06.21.
//

import Foundation
import HtmlToMarkdownLib

let dir = "/Users/chris/Development/chriseidhofnl/content/post"
let out = URL(fileURLWithPath: "/Users/chris/objc.io/chriseidhofnl/site/posts")

let fm = FileManager.default

let contents = try fm.contentsOfDirectory(atPath: dir)
for file in contents {
    if file.hasPrefix(".") { continue }
    let path = URL(fileURLWithPath: dir).appendingPathComponent(file)
    let out = out.appendingPathComponent(file).deletingPathExtension().appendingPathExtension("md")
    switch path.pathExtension {
    case "html":
        let contents = try! String(contentsOf: path)
        var (yaml, str) = try contents.markdown()
        if let y = yaml {
            str = "---\(y)---\n\n" + str
        }
        try str.write(to: out, atomically: true, encoding: .utf8)
    case "md":
        try fm.copyItem(at: path, to: out)
    default:
        fatalError("\(path)")
    }
    
}
