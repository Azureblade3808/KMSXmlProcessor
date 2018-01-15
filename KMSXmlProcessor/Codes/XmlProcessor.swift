//
//  XmlProcessor.swift
//  KMSXmlProcessor
//
//  Created by 傅立业 on 21/08/2017.
//  Copyright © 2017 Kirisame Magic Shop. All rights reserved.
//

import Foundation

// MARK: - Main

/// A mutable XML element.
@objc(KMSXmlElement)
public class XmlElement : NSObject, NSCopying {
	/// Tag name of this element.
	@objc
	public var name: String
	
	/// Attributes of this element.
	@objc
	public var attributes: [String : String]
	
	/// Child elements in this element.
	@objc
	public var children: [XmlElement]
	
	/// Inner text of this element.
	@objc
	public var innerText: String
	
	@objc(initWithName:attributes:children:innerText:)
	public init(name: String = "", attributes: [String : String] = [:], children: [XmlElement] = [], innerText: String = "") {
		self.name = name
		self.attributes = attributes
		self.children = children
		self.innerText = innerText
	}
	
	override
	public convenience init() {
		self.init(name: "", attributes: [:], children: [], innerText: "")
	}
	
	@objc(initWithXmlElement:)
	convenience
	public init(other: XmlElement) {
		self.init(
			name: other.name,
			attributes: other.attributes,
			children: other.children.map({ XmlElement(other: $0) }),
			innerText: other.innerText
		)
	}
	
	@objc(childrenWithName:)
	public func children(name: String) -> [XmlElement] {
		return children.filter { $0.name == name }
	}
	
	@objc(firstChildWithName:)
	public func firstChild(name: String) -> XmlElement? {
		return children.first { $0.name == name }
	}
	
	@objc(addChild:)
	public func addChild(_ child: XmlElement) {
		children.append(child)
	}
	
	@objc(removeChild:)
	@discardableResult
	public func removeChild(_ child: XmlElement) -> Bool {
		guard let index = children.index(of: child) else {
			return false
		}
		
		children.remove(at: index)
		
		return true
	}
	
	@objc(attributeForName:)
	public func attribute(name: String) -> String? {
		return attributes[name]
	}
	
	@objc(setAttribute:forName:)
	public func setAttribute(_ attribute: String?, for name: String) {
		attributes[name] = attribute
	}
	
	public func copy(with zone: NSZone? = nil) -> Any {
		return XmlElement(other: self)
	}
}

// MARK: - Parsing

extension XmlElement {
	/// Initializes with a piece of data which represents an XML document.
	/// - parameters:
	/// 	- data: A piece of data which decodes from an XML document using UTF-8 encoding.
	/// - throws: Any error that occured during the parsing.
	@objc(initWithData:errorPointer:)
	convenience
	public init(data: Data) throws {
		self.init()
		
		// Keep a strong reference for the handler, as the parser would not.
		let handler = Handler(owner: self)
		
		let parser = XMLParser(data: data)
		parser.delegate = handler
		parser.parse()
		
		// The handler must live until then.
		_ = handler
		
		if let error = parser.parserError {
			throw error
		}
	}
	
	private class Handler : NSObject, XMLParserDelegate {
		private unowned let owner: XmlElement
		
		private var elementStack: [XmlElement] = []
		
		public init(owner: XmlElement) {
			self.owner = owner
		}
		
		public func parser(_: XMLParser, didStartElement name: String, namespaceURI: String?, qualifiedName: String?, attributes: [String : String] = [:]) {
			if elementStack.isEmpty {
				owner.name = name
				owner.attributes = attributes
				
				elementStack.append(owner)
			}
			else {
				let child = XmlElement(name: name, attributes: attributes)
				
				let parent = elementStack.last!
				parent.children.append(child)
				parent.innerText = ""
				
				elementStack.append(child)
			}
		}
		
		public func parser(_: XMLParser, didEndElement name: String, namespaceURI: String?, qualifiedName: String?) {
			assert(elementStack.last!.name == name)
			
			elementStack.removeLast()
		}
		
		public func parser(_: XMLParser, foundCharacters string: String) {
			let element = elementStack.last!
			if element.children.isEmpty {
				element.innerText.append(string)
			}
		}
	}
}

// MARK: - Serializing

extension XmlElement {
	/// Translates into an XML snippet with given format.
	/// - parameters:
	/// 	- indent: The string used as an indent. Default is "\t".
	/// 	- lineEnd: The string used as a line end. Default is "\n".
	/// 	- indentLevel: How many indents should be placed in the front. Default is 0.
	/// - returns: A formatted XML snippet representing this element.
	@objc(stringifyWithIndent:lineEnd:indentLevel:)
	public func stringify(indent: String = "\t", lineEnd: String = "\n", indentLevel: Int = 0) -> String {
		precondition(!name.isEmpty, "The name of an element should not be empty when it gets stringized.")
		
		var string = ""
		
		for _ in stride(from: 0, to: indentLevel, by: 1) {
			string += indent
		}
		string += "<\(name)"
		
		for (attributeName, attributeValue) in attributes.sorted(by: <=) {
			string += " \(attributeName)=\"\(encodeValue(attributeValue))\""
		}
		
		if children.isEmpty {
			if innerText.isEmpty {
				string += " />\(lineEnd)"
			}
			else {
				string += ">\(encodeText(innerText))</\(name)>\(lineEnd)"
			}
		}
		else {
			string += ">\(lineEnd)"
			
			for child in children {
				string += child.stringify(indent: indent, lineEnd: lineEnd, indentLevel: indentLevel + 1)
			}
			
			for _ in stride(from: 0, to: indentLevel, by: 1) {
				string += indent
			}
			string += "</\(name)>\(lineEnd)"
		}
		
		return string
	}
	
	/// Translates into an XML document with given format.
	/// - parameters:
	/// 	- indent: The string used as an indent. Default is "\t".
	/// 	- lineEnd: The string used as a line end. Default is "\n".
	/// - returns: A formatted XML snippet representing this element.
	@objc(stringifyAsDocumentWithIndent:lineEnd:)
	public func stringifyAsDocument(indent: String = "\t", lineEnd: String = "\n") -> String {
		var string = ""
		
		string += "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
		
		string += stringify(indent: indent, lineEnd: lineEnd)
		
		return string
	}
	
	/// Translates into an minimized XML document.
	/// - note: Identical as calling:
	/// ````
	/// self.stringify(
	///     indent: "",
	///     lineEnd: "",
	///     indentLevel: 0
	/// )
	/// ````
	@objc(stringifyMinimized)
	public func stringifyMinimized() -> String {
		return self.stringify(indent: "", lineEnd: "", indentLevel: 0)
	}
	
	private func encodeValue(_ value: String) -> String {
		let encodedValue = value
			.replacingOccurrences(of: "&", with: "&amp;")
			.replacingOccurrences(of: "<", with: "&lt;")
			.replacingOccurrences(of: ">", with: "&gt;")
			.replacingOccurrences(of: "\'", with: "&apos;")
			.replacingOccurrences(of: "\"", with: "&quot;")
			.replacingOccurrences(of: "\n", with: "&#x0D")
			.replacingOccurrences(of: "\r", with: "&#x0A")
		
		return encodedValue
	}
	
	private func encodeText(_ text: String) -> String {
		let encodedText = text
			.replacingOccurrences(of: "&", with: "&amp;")
			.replacingOccurrences(of: "<", with: "&lt;")
			.replacingOccurrences(of: ">", with: "&gt;")
		
		return encodedText
	}
}

// MARK: Objective-C Supporting.

extension XmlElement {
	@objc(initWithName:)
	public convenience init(name: String) {
		self.init(name: name, attributes: [:], children: [], innerText: "")
	}
	
	@objc(initWithName:innerText:)
	public convenience init(name: String, innerText: String) {
		self.init(name: name, attributes: [:], children: [], innerText: innerText)
	}
	
	@objc(stringify)
	public func stringify() -> String {
		return stringify(indent: "\t", lineEnd: "\n", indentLevel: 0)
	}
	
	@objc(stringifyAsDocument)
	public func stringifyAsDocument() -> String {
		return stringifyAsDocument(indent: "\t", lineEnd: "\n")
	}
}
