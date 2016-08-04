import UIKit

//Modifed version of https://github.com/mchoe/SwiftSVG/blob/master/SwiftSVG/SVGParser.swift
//Original license:

//  SVGParser.swift
//  SwiftSVG
//
//  Copyright (c) 2015 Michael Choe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//  http://www.github.com/mchoe
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

struct Stack<T> {
    var items = [T]()
    
    mutating func push(itemToPush: T) {
        self.items.append(itemToPush)
    }
    
    mutating func pop() -> T {
        return self.items.removeLast()
    }
}

extension Stack {
    var count: Int {
        get {
            return self.items.count
        }
    }
    
    var isEmpty: Bool {
        get {
            if self.items.count > 0 {
                return true
            }
            return false
        }
    }
    
    var last: T? {
        get {
            if self.isEmpty == false {
                return self.items.last
            }
            return nil
        }
    }
}


extension NSObject {
    
    //
    // Retrieves an array of property names found on the current object
    // using Objective-C runtime functions for introspection:
    // https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
    //
    func propertyNames() -> [String] {
        var results = [String]();
        
        // retrieve the properties via the class_copyPropertyList function
        var count: UInt32 = 0;
        let myClass: AnyClass = self.classForCoder;
        let properties = class_copyPropertyList(myClass, &count);
        
        // iterate each objc_property_t struct
        for i in 0..<count {
            let property = properties?[Int(i)];
            
            // retrieve the property name by calling property_getName function
            let cname = property_getName(property);
            
            // convert the c string into a Swift string
            let name = String(validatingUTF8: cname!);
            results.append(name!);
        }
        
        // release objc_property_t structs
        free(properties);
        
        return results;
    }
    
    func classNameAsString() -> String {
        
        let thisClass: AnyClass = self.classForCoder
        let classString = NSStringFromClass(thisClass)
        return classString
    }
    
}

public extension String {
    
    func hexToInteger() -> Int {
        return strtol(self, nil, 16)
    }
    
    public subscript(index: Int) -> Character {
        get {
            let index = self.characters.index(self.characters.startIndex, offsetBy: index)
            //            let index = self.startIndex.advancedBy(n: index)
            return self[index]
        }
    }
    
    public subscript(integerRange: CountableClosedRange<Int>) -> String {
        let start = self.characters.index(self.characters.startIndex, offsetBy: integerRange.lowerBound)
        let end = self.characters.index(self.characters.startIndex, offsetBy: integerRange.upperBound)
        //        let start = self.startIndex.advancedBy(n: integerRange.startIndex)
        //        let end = self.startIndex.advancedBy(n: integerRange.endIndex)
        let range = start..<end
        return self[range]
    }
}

public extension UIColor {
    
    convenience init(hexString: String) {
        
        var workingString = hexString
        if workingString.hasPrefix("#") {
            workingString = String(workingString.characters.dropFirst())
        }
        
        var hexRed = "00"
        var hexGreen = "00"
        var hexBlue = "00"
        
        
        if workingString.characters.count == 6 {
            hexRed = workingString[0...1]
            hexGreen = workingString[2...3]
            hexBlue = workingString[4...5]
        } else if workingString.characters.count == 3 {
            let redValue = workingString[0]
            let greenValue = workingString[1]
            let blueValue = workingString[2]
            hexRed = "\(redValue)\(redValue)"
            hexGreen = "\(greenValue)\(greenValue)"
            hexBlue = "\(blueValue)\(blueValue)"
        }
        
        let red = CGFloat(hexRed.hexToInteger())
        let green = CGFloat(hexGreen.hexToInteger())
        let blue = CGFloat(hexBlue.hexToInteger())
        
        self.init(red: CGFloat(red / 255.0), green: CGFloat(green / 255.0), blue: CGFloat(blue / 255.0), alpha: 1.0)
    }
}

private enum PathType {
    case Absolute, Relative
}

private struct NumberStack {
    var characterStack: String = ""
    var asCGFloat: CGFloat? {
        get {
            if self.characterStack.characters.count > 0 {
                return CGFloat(strtod(self.characterStack, nil))
            }
            return nil
        }
    }
    var isEmpty: Bool {
        get {
            if self.characterStack.characters.count > 0 {
                return false
            }
            return true
        }
    }
    
    init() { }
    
    init(startCharacter: Character) {
        self.characterStack = String(startCharacter)
    }
    
    mutating func push(character: Character) {
        self.characterStack += String(character)
    }
    
    mutating func clear() {
        self.characterStack = String()
    }
}

private struct PreviousCommand {
    var commandLetter: String?
    var parameters: [CGFloat]?
}

/////////////////////////////////////////////////////
//
// MARK: Protocols

private protocol Commandable {
    var numberOfRequiredParameters: Int { get }
    func execute(forPath: UIBezierPath, previousCommand: PreviousCommand?)
}

/////////////////////////////////////////////////////
//
// MARK: Base Classes

private class PathCharacter {
    var character: Character?
    
    convenience init(character: Character) {
        self.init()
        self.character = character
    }
}

private class NumberCharacter : PathCharacter {}
private class SeparatorCharacter : PathCharacter {}
private class SignCharacter : NumberCharacter {}

private class PathCommand : PathCharacter, Commandable {
    
    var numberOfRequiredParameters: Int {
        get {
            return 0
        }
    }
    var pathType: PathType = .Absolute
    var parameters: [CGFloat] = Array()
    var path: UIBezierPath = UIBezierPath()
    
    
    override init() {
        super.init()
    }
    
    convenience init(character: Character, pathType: PathType) {
        self.init()
        self.character = character
        self.pathType = pathType
    }
    
    func execute(forPath: UIBezierPath, previousCommand: PreviousCommand? = nil) {
        assert(false, "Subclasses must implement this method")
    }
    
    func canExecute() -> Bool {
        
        if self.numberOfRequiredParameters == 0 {
            return true
        }
        
        if self.parameters.count == 0 {
            return false
        }
        
        if self.parameters.count % self.numberOfRequiredParameters != 0 {
            return false
        }
        
        return true
    }
    
    func pushCoordinateAndExecuteIfPossible(coordinate: CGFloat, previousCommand: PreviousCommand? = nil) -> PreviousCommand? {
        self.parameters.append(coordinate)
        if self.canExecute() {
            self.execute(forPath: self.path, previousCommand: previousCommand)
            let returnParameters = self.parameters
            self.parameters.removeAll(keepingCapacity: false)
            return PreviousCommand(commandLetter: String(self.character!), parameters: returnParameters)
        }
        return nil
    }
    
    func pointForPathType(point: CGPoint) -> CGPoint {
        switch self.pathType {
        case .Absolute:
            return point
        case .Relative:
            return CGPoint(x: point.x + self.path.currentPoint.x, y: point.y + self.path.currentPoint.y)
        }
    }
}

/////////////////////////////////////////////////////
//
// MARK: Command Implementations

private class MoveTo : PathCommand {
    
    override var numberOfRequiredParameters: Int {
        get {
            return 2
        }
    }
    
    override func execute(forPath: UIBezierPath, previousCommand: PreviousCommand? = nil) {
        let point = self.pointForPathType(point: CGPoint(x: self.parameters[0], y: self.parameters[1]))
        forPath.move(to: point)
    }
}

private class ClosePath : PathCommand {
    
    override var numberOfRequiredParameters: Int {
        get {
            return 0
        }
    }
    
    override func execute(forPath: UIBezierPath, previousCommand: PreviousCommand? = nil) {
        forPath.close()
    }
}

private class LineTo : PathCommand {
    
    override var numberOfRequiredParameters: Int {
        get {
            return 2
        }
    }
    
    override func execute(forPath: UIBezierPath, previousCommand: PreviousCommand? = nil) {
        let point = self.pointForPathType(point: CGPoint(x: self.parameters[0], y: self.parameters[1]))
        forPath.addLine(to: point)
    }
}

private class HorizontalLineTo : PathCommand {
    
    override var numberOfRequiredParameters: Int {
        get {
            return 1
        }
    }
    
    override func execute(forPath: UIBezierPath, previousCommand: PreviousCommand? = nil) {
        let x = self.parameters[0]
        let point = (self.pathType == PathType.Absolute ? CGPoint(x: x, y: forPath.currentPoint.y) : CGPoint(x: forPath.currentPoint.x + x, y: forPath.currentPoint.y))
        forPath.addLine(to: point)
    }
}

private class VerticalLineTo : PathCommand {
    
    override var numberOfRequiredParameters: Int {
        get {
            return 1
        }
    }
    
    override func execute(forPath: UIBezierPath, previousCommand: PreviousCommand? = nil) {
        let y = self.parameters[0]
        let point = (self.pathType == PathType.Absolute ? CGPoint(x: forPath.currentPoint.x, y: y) : CGPoint(x: forPath.currentPoint.x, y: forPath.currentPoint.y + y))
        forPath.addLine(to: point)
    }
}

private class CurveTo : PathCommand {
    
    override var numberOfRequiredParameters: Int {
        get {
            return 6
        }
    }
    
    override func execute(forPath: UIBezierPath, previousCommand: PreviousCommand? = nil) {
        let startControl = self.pointForPathType(point: CGPoint(x: self.parameters[0], y: self.parameters[1]))
        let endControl = self.pointForPathType(point: CGPoint(x: self.parameters[2], y: self.parameters[3]))
        let point = self.pointForPathType(point: CGPoint(x: self.parameters[4], y: self.parameters[5]))
        forPath.addCurve(to: point, controlPoint1: startControl, controlPoint2: endControl)
    }
}

private class SmoothCurveTo : PathCommand {
    
    override var numberOfRequiredParameters: Int {
        get {
            return 4
        }
    }
    
    override func execute(forPath: UIBezierPath, previousCommand: PreviousCommand? = nil) {
        
        if let previousParams = previousCommand?.parameters {
            
            let point = self.pointForPathType(point: CGPoint(x: self.parameters[2], y: self.parameters[3]))
            let controlEnd = self.pointForPathType(point: CGPoint(x: self.parameters[0], y: self.parameters[1]))
            
            let currentPoint = forPath.currentPoint
            
            var controlStartX = currentPoint.x
            var controlStartY = currentPoint.y
            
            if let previousChar = previousCommand?.commandLetter {
                
                switch previousChar {
                case "C":
                    controlStartX = (2.0 * currentPoint.x) - previousParams[2]
                    controlStartY = (2.0 * currentPoint.y) - previousParams[3]
                case "c":
                    let oldCurrentPoint = CGPoint(x: currentPoint.x - previousParams[4], y: currentPoint.y - previousParams[5])
                    controlStartX = (2.0 * currentPoint.x) - (previousParams[2] + oldCurrentPoint.x)
                    controlStartY = (2.0 * currentPoint.y) - (previousParams[3] + oldCurrentPoint.y)
                case "S":
                    controlStartX = (2.0 * currentPoint.x) - previousParams[0]
                    controlStartY = (2.0 * currentPoint.y) - previousParams[1]
                case "s":
                    let oldCurrentPoint = CGPoint(x: currentPoint.x - previousParams[2], y: currentPoint.y - previousParams[3])
                    controlStartX = (2.0 * currentPoint.x) - (previousParams[0] + oldCurrentPoint.x)
                    controlStartY = (2.0 * currentPoint.y) - (previousParams[1] + oldCurrentPoint.y)
                default:
                    break
                }
                
            } else {
                assert(false, "Must supply previous command for SmoothCurveTo")
            }
            
            forPath.addCurve(to: point, controlPoint1: CGPoint(x: controlStartX, y: controlStartY), controlPoint2: controlEnd)
            
        } else {
            assert(false, "Must supply previous parameters for SmoothCurveTo")
        }
    }
}

private class QuadraticCurveTo : PathCommand {
    
    override var numberOfRequiredParameters: Int {
        get {
            return 4
        }
    }
    
    override func execute(forPath: UIBezierPath, previousCommand: PreviousCommand? = nil) {
        let controlPoint = self.pointForPathType(point: CGPoint(x: self.parameters[0], y: self.parameters[1]))
        let point = self.pointForPathType(point: CGPoint(x: self.parameters[2], y: self.parameters[3]))
        forPath.addQuadCurve(to: point, controlPoint: controlPoint)
    }
}

private class SmoothQuadraticCurveTo : PathCommand {
    
    override var numberOfRequiredParameters: Int {
        get {
            return 2
        }
    }
    
    override func execute(forPath: UIBezierPath, previousCommand: PreviousCommand? = nil) {
        
        if let previousParams = previousCommand?.parameters {
            
            let point = self.pointForPathType(point: CGPoint(x: self.parameters[0], y: self.parameters[1]))
            var controlPoint = forPath.currentPoint
            
            if let previousChar = previousCommand?.commandLetter {
                
                let currentPoint = forPath.currentPoint
                
                switch previousChar {
                case "Q":
                    controlPoint = CGPoint(x: (2.0 * currentPoint.x) - previousParams[0], y: (2.0 * currentPoint.y) - previousParams[1])
                case "q":
                    let oldCurrentPoint = CGPoint(x: currentPoint.x - previousParams[2], y: currentPoint.y - previousParams[3])
                    controlPoint = CGPoint(x: (2.0 * currentPoint.x) - (previousParams[0] + oldCurrentPoint.x), y: (2.0 * currentPoint.y) - (previousParams[1] + oldCurrentPoint.y))
                default:
                    break
                }
                
            } else {
                assert(false, "Must supply previous command for SmoothQuadraticCurveTo")
            }
            
            forPath.addQuadCurve(to: point, controlPoint: controlPoint)
            
        } else {
            assert(false, "Must supply previous parameters for SmoothQuadraticCurveTo")
        }
    }
}


/////////////////////////////////////////////////////
//
// MARK: Character Dictionary

private let characterDictionary: [Character: PathCharacter] = [
    "M": MoveTo(character: "M", pathType: PathType.Absolute),
    "m": MoveTo(character: "m", pathType: PathType.Relative),
    "C": CurveTo(character: "C", pathType: PathType.Absolute),
    "c": CurveTo(character: "c", pathType: PathType.Relative),
    "S": SmoothCurveTo(character: "S", pathType: PathType.Absolute),
    "s": SmoothCurveTo(character: "s", pathType: PathType.Relative),
    "L": LineTo(character: "L", pathType: PathType.Absolute),
    "l": LineTo(character: "l", pathType: PathType.Relative),
    "H": HorizontalLineTo(character: "H", pathType: PathType.Absolute),
    "h": HorizontalLineTo(character: "h", pathType: PathType.Relative),
    "V": VerticalLineTo(character: "V", pathType: PathType.Absolute),
    "v": VerticalLineTo(character: "v", pathType: PathType.Relative),
    "Q": QuadraticCurveTo(character: "Q", pathType: PathType.Absolute),
    "q": QuadraticCurveTo(character: "q", pathType: PathType.Relative),
    "T": SmoothQuadraticCurveTo(character: "T", pathType: PathType.Absolute),
    "t": SmoothQuadraticCurveTo(character: "t", pathType: PathType.Relative),
    "Z": ClosePath(character: "Z", pathType: PathType.Absolute),
    "z": ClosePath(character: "z", pathType: PathType.Relative),
    "-": SignCharacter(character: "-"),
    ".": NumberCharacter(character: "."),
    "0": NumberCharacter(character: "0"),
    "1": NumberCharacter(character: "1"),
    "2": NumberCharacter(character: "2"),
    "3": NumberCharacter(character: "3"),
    "4": NumberCharacter(character: "4"),
    "5": NumberCharacter(character: "5"),
    "6": NumberCharacter(character: "6"),
    "7": NumberCharacter(character: "7"),
    "8": NumberCharacter(character: "8"),
    "9": NumberCharacter(character: "9"),
    " ": SeparatorCharacter(character: " "),
    ",": SeparatorCharacter(character: ",")
]


/////////////////////////////////////////////////////
//
// MARK: Parse "d" path


/////////////////////////////////////////////////////
//
// This String extension is provided as a convenience for the
// parseSVGPath function. You can use either the extension or the
// global function. I just wanted to provide


public extension String {
    internal func pathFromSVGString() -> UIBezierPath {
        return parseSVGPath(pathString: self)
    }
}

public func parseSVGPath(pathString: String, forPath: UIBezierPath? = nil) -> UIBezierPath {
    
    assert(pathString.hasPrefix("M") || pathString.hasPrefix("m"), "Path d attribute must begin with MoveTo Command (\"M\")")
    
    let workingString = (pathString.hasSuffix("Z") == false && pathString.hasSuffix("z") == false ? pathString + "z" : pathString)
    
    var returnPath = UIBezierPath()
    
    if let suppliedPath = forPath {
        returnPath = suppliedPath
    }
    
    autoreleasepool { () -> () in
        
        var currentPathCommand: PathCommand = PathCommand(character: "M")
        var currentNumberStack: NumberStack = NumberStack()
        var previousParameters: PreviousCommand? = nil
        
        let pushCoordinateAndClear: () -> Void = {
            if currentNumberStack.isEmpty == false {
                if let newCoordinate = currentNumberStack.asCGFloat {
                    if let returnParameters = currentPathCommand.pushCoordinateAndExecuteIfPossible(coordinate: newCoordinate, previousCommand: previousParameters) {
                        previousParameters = returnParameters
                    }
                }
                currentNumberStack.clear()
            }
        }
        
        for thisCharacter in workingString.characters {
            if let pathCharacter = characterDictionary[thisCharacter] {
                
                if pathCharacter is PathCommand {
                    
                    pushCoordinateAndClear()
                    
                    currentPathCommand = pathCharacter as! PathCommand
                    currentPathCommand.path = returnPath
                    
                    if currentPathCommand.character == "Z" || currentPathCommand.character == "z" {
                        currentPathCommand.execute(forPath: returnPath, previousCommand: previousParameters)
                    }
                    
                } else if pathCharacter is SeparatorCharacter {
                    
                    pushCoordinateAndClear()
                    
                } else if pathCharacter is SignCharacter {
                    
                    pushCoordinateAndClear()
                    currentNumberStack = NumberStack(startCharacter: thisCharacter)
                    
                } else {
                    
                    if currentNumberStack.isEmpty == false {
                        currentNumberStack.push(character: thisCharacter)
                    } else {
                        currentNumberStack = NumberStack(startCharacter: thisCharacter)
                    }
                    
                }
                
            } else {
                assert(false, "Invalid character \"\(thisCharacter)\" found")
            }
        }
    }
    return returnPath
}

private var tagMapping: [String: String] = [
    "path": "SVGPath",
    "svg": "SVGElement"
]

@objc(SVGGroup) private class SVGGroup: NSObject { }

@objc(SVGPath) public class SVGPath: NSObject {
    
    var path: UIBezierPath = UIBezierPath()
    var shapeLayer: CAShapeLayer = CAShapeLayer()
    
    var d: String? {
        didSet {
            if let pathStringToParse = d {
                self.path = pathStringToParse.pathFromSVGString()
                self.shapeLayer.path = self.path.cgPath
            }
        }
    }
    
    var fill: String? {
        didSet {
            if let hexFill = fill {
                self.shapeLayer.fillColor = UIColor(hexString: hexFill).cgColor
            }
        }
    }
}

@objc(SVGElement) private class SVGElement: NSObject { }

public class SVGParser : NSObject, XMLParserDelegate {
    
    private var elementStack = Stack<NSObject>()
    
    public var containerLayer: CALayer?
    public var shouldParseSinglePathOnly = false
    public var paths = [UIBezierPath]()
    
    public convenience init(SVGURL: URL, containerLayer: CALayer? = nil, shouldParseSinglePathOnly: Bool = false) {
        
        self.init()
        
        if let layer = containerLayer {
            self.containerLayer = layer
        }
        
        if let xmlParser = XMLParser(contentsOf: SVGURL) {
            xmlParser.delegate = self
            xmlParser.parse()
        } else {
            assert(false, "Couldn't initialize parser. Check your resource and make sure the supplied URL is correct")
        }
    }
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if let newElement = tagMapping[elementName] {
            
            let className = NSClassFromString(newElement) as! NSObject.Type
            let newInstance = className.init()
            
            let allPropertyNames = newInstance.propertyNames()
            for thisKeyName in allPropertyNames {
                if let attributeValue: AnyObject = attributeDict[thisKeyName] {
                    newInstance.setValue(attributeValue, forKey: thisKeyName)
                }
            }
            
            if newInstance is SVGPath {
                let thisPath = newInstance as! SVGPath
                if self.containerLayer != nil {
                    self.containerLayer!.addSublayer(thisPath.shapeLayer)
                }
                self.paths.append(thisPath.path)
                
                if self.shouldParseSinglePathOnly == true {
                    parser.abortParsing()
                }
            }
            
            self.elementStack.push(itemToPush: newInstance)
        }
    }
    
    public func allKeysForValue<K, V: Equatable>(dict: [K: V], valueToMatch: V) -> [K]? {
        
        let possibleValues = dict.filter ({ (key, value) -> Bool in
            return value == valueToMatch
        }).map { (key, value) -> K in
            return key
        }
        if possibleValues.count > 0 {
            return possibleValues
        }
        return nil
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let lastItem = self.elementStack.last {
            if let keyForValue = allKeysForValue(dict: tagMapping,valueToMatch: lastItem.classNameAsString())?.first {
                if elementName == keyForValue {
                    self.elementStack.pop()
                }
            }
        }
    }
}

extension UIBezierPath {
    
    public convenience init(pathString: String) {
        self.init()
        parseSVGPath(pathString: pathString, forPath: self)
    }
    
    public class func pathWithSVGURL(SVGURL: URL) -> UIBezierPath? {
        let parser = SVGParser(SVGURL: SVGURL, containerLayer: nil, shouldParseSinglePathOnly: true)
        return parser.paths.first
    }
}
