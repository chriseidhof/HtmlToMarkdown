import Foundation
import CommonMark

extension XMLNode {
    func parseBlock() -> Block {
        guard let n = self as? XMLElement else {
            fatalError("\(self.kind.rawValue) \(self)")
        }
        var inline: [Inline] {
            children?.parseInline() ?? []
        }
        var block: [Block] {
            children?.parseBlock() ?? []
        }
        switch n.name {
        case "p":
            return .paragraph(text: inline)
        case "pre":
            guard children!.count == 1, let c = children![0] as? XMLElement else {
                fatalError()
            }
            assert(c.name == "code")
            return .codeBlock(text: c.stringValue!, language: nil)
        case "h1":
            return .heading(text: inline, level: 1)
        case "h2":
            return .heading(text: inline, level: 2)
        case "h3":
            return .heading(text: inline, level: 3)
        case "blockquote":
            return .blockQuote(items: block)
        case "ol", "ul":
            return .list(items: children!.map { $0.parseListItem() }, type: name == "ul" ? .unordered : .ordered)
        case "hr":
            return .thematicBreak
        default:
            fatalError("Unrecognized tag \(n.name)")
        }
    }
    
    func parseListItem() -> [Block] {
        guard let e = self as? XMLElement, name == "li" else { fatalError() }
        let firstChild = children!.first
        if (firstChild as? XMLElement)?.name == "p" {
            return children!.parseBlock()
        } else {
            return [.paragraph(text: children!.parseInline())]
        }
    }
    
    func parseInline() -> Inline {
        if kind == .text {
            return .text(text: self.stringValue!)
        }
        guard let n = self as? XMLElement else {
            fatalError("\(self.kind)")
        }
        var parsedChildren: [Inline] {
            children?.parseInline() ?? []
        }
        switch n.name {
        case "a":
            let href = n.attribute(forName: "href")!.stringValue!
            let title = n.attribute(forName: "title")?.stringValue
            assert(n.attributes!.count < 3, "Unexpected attributes \(n.attributes)")
            return .link(children: parsedChildren, title: title, url: href)
        case "strong":
            return .strong(children: parsedChildren)
        case "em":
            return .emphasis(children: parsedChildren)
        case "img":
            let src = n.attribute(forName: "src")!.stringValue!
            let alt = n.attribute(forName: "alt")?.stringValue
            assert(n.attributes!.count <= 2, "Unexpected attributes \(n.attributes)")
            return .image(children: [], title: alt, url: src)

        case "code":
            return .code(text: stringValue!)
        case "span":
            assert(parsedChildren.count == 1)
            return parsedChildren[0]
        case "br":
            return .lineBreak
        default:
            fatalError("Unrecognized tag \(n.name) (\(n))")
        }
    }
}

extension Array where Element == XMLNode {
    func parseInline() -> [Inline] {
        map { $0.parseInline() }

    }
    func parseBlock() -> [Block] {
        map { $0.parseBlock() }
    }
}

extension XMLNode {
    func renderToMarkdown() -> String {
        let html = self as! XMLElement
        assert(html.name == "html")
        let body = html.children![1] as! XMLElement
        assert(body.name == "body")
        return CommonMark.Node(blocks: body.children!.parseBlock()).commonMark()
    }
}

extension String {
    public func markdown() throws -> (yaml: String?, markdown: String)  {
        let (yaml, html) = try parseMarkdownWithFrontMatter()
        let x = try XMLDocument(xmlString: html, options: [.documentTidyHTML])
        return (yaml, x.rootElement()!.renderToMarkdown())
    }
}
