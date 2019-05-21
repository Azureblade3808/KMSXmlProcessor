//
//  XmlElementTests.swift
//  KMSXmlProcessor
//
//  Created by 傅立业 on 11/08/2017.
//  Copyright © 2017 Kirisame Magic Shop. All rights reserved.
//

import XCTest

@testable
import KMSXmlProcessor

internal class XmlElementTests : XCTestCase {
	func testClosedEmptyXmlElement() {
		let element = try! XmlElement(data: "<a />".data(using: .utf8)!)
		XCTAssertEqual(element.name, "a")
		XCTAssert(element.attributes.isEmpty)
		XCTAssert(element.children.isEmpty)
		XCTAssert(element.innerText.isEmpty)
		
		let string = element.stringifyMinimized()
		XCTAssertEqual(string, "<a />")
	}
	
	func testOpenEmptyXmlElement() {
		let element = try! XmlElement(data: "<a></a>".data(using: .utf8)!)
		XCTAssertEqual(element.name, "a")
		XCTAssert(element.attributes.isEmpty)
		XCTAssert(element.children.isEmpty)
		XCTAssert(element.innerText.isEmpty)
		
		let string = element.stringifyMinimized()
		XCTAssertEqual(string, "<a />")
	}
	
	func testElementWithAttributes() {
		let element = try! XmlElement(data: "<a c=\"2\" b=\"1\" />".data(using: .utf8)!)
		XCTAssertEqual(element.name, "a")
		XCTAssert(element.attributes == ["b": "1", "c": "2"])
		XCTAssert(element.children.isEmpty)
		XCTAssert(element.innerText.isEmpty)
		
		let string = element.stringifyMinimized()
		XCTAssertEqual(string, "<a b=\"1\" c=\"2\" />")
	}
	
	func testElementWithChildElements() {
		let element = try! XmlElement(data: "<a><b /></a>".data(using: .utf8)!)
		XCTAssertEqual(element.name, "a")
		XCTAssert(element.attributes.isEmpty)
		XCTAssert(element.innerText.isEmpty)
		
		let child = element.children.first!
		XCTAssertEqual(child.name, "b")
		XCTAssert(child.attributes.isEmpty)
		XCTAssert(child.children.isEmpty)
		XCTAssert(child.innerText.isEmpty)
		
		let string = element.stringifyMinimized()
		XCTAssertEqual(string, "<a><b /></a>")
	}
	
	func testElementWithInnerText() {
		let element = try! XmlElement(data: "<a>b</a>".data(using: .utf8)!)
		XCTAssertEqual(element.name, "a")
		XCTAssert(element.attributes.isEmpty)
		XCTAssert(element.children.isEmpty)
		XCTAssertEqual(element.innerText, "b")
		
		let string = element.stringifyMinimized()
		XCTAssertEqual(string, "<a>b</a>")
	}
}
