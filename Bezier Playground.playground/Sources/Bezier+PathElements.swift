import UIKit


public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}


public enum PathElement {
    case MoveToPoint(CGPoint)
    case AddLineToPoint(CGPoint)
    case AddQuadCurveToPoint(CGPoint, CGPoint)
    case AddCurveToPoint(CGPoint, CGPoint, CGPoint)
    case CloseSubpath
    
    init(element: CGPathElement) {
        switch element.type {
        case .moveToPoint:
            self = .MoveToPoint(element.points[0])
        case .addLineToPoint:
            self = .AddLineToPoint(element.points[0])
        case .addQuadCurveToPoint:
            self = .AddQuadCurveToPoint(element.points[0], element.points[1])
        case .addCurveToPoint:
            self = .AddCurveToPoint(element.points[0], element.points[1], element.points[2])
        case .closeSubpath:
            self = .CloseSubpath
        }
    }
    
    mutating func adjustPoints(first : CGPoint, second : CGPoint, third : CGPoint) {
        switch self {
        case let .MoveToPoint(point):
            self = .MoveToPoint(point + first)
        case let .AddLineToPoint(point):
            self = .AddLineToPoint(point + first)
        case let .AddQuadCurveToPoint(pointOne, pointTwo):
            self = .AddQuadCurveToPoint(pointOne + first, pointTwo + second)
        case let .AddCurveToPoint(pointOne, pointTwo, pointThree):
            self = .AddCurveToPoint(pointOne + first, pointTwo + second, pointThree + third)
        case .CloseSubpath:
            self = .CloseSubpath
        }
    }
}

extension PathElement : CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .MoveToPoint(point):
            return "\(point.x) \(point.y) moveto"
        case let .AddLineToPoint(point):
            return "\(point.x) \(point.y) lineto"
        case let .AddQuadCurveToPoint(point1, point2):
            return "\(point1.x) \(point1.y) \(point2.x) \(point2.y) quadcurveto"
        case let .AddCurveToPoint(point1, point2, point3):
            return "\(point1.x) \(point1.y) \(point2.x) \(point2.y) \(point3.x) \(point3.y) curveto"
        case .CloseSubpath:
            return "closepath"
        }
    }
}

extension PathElement : Equatable { }

public func ==(lhs: PathElement, rhs: PathElement) -> Bool {
    switch(lhs, rhs) {
    case let (.MoveToPoint(l), .MoveToPoint(r)):
        return l == r
    case let (.AddLineToPoint(l), .AddLineToPoint(r)):
        return l == r
    case let (.AddQuadCurveToPoint(l1, l2), .AddQuadCurveToPoint(r1, r2)):
        return l1 == r1 && l2 == r2
    case let (.AddCurveToPoint(l1, l2, l3), .AddCurveToPoint(r1, r2, r3)):
        return l1 == r1 && l2 == r2 && l3 == r3
    case (.CloseSubpath, .CloseSubpath):
        return true
    case (_, _):
        return false
    }
}

extension UIBezierPath {
    public var elements: [PathElement] {
        var pathElements = [PathElement]()
        withUnsafeMutablePointer(&pathElements) { elementsPointer in
            cgPath.apply(info: elementsPointer) { (userInfo, nextElementPointer) in
                let nextElement = PathElement(element: nextElementPointer.pointee)
                let elementsPointer = UnsafeMutablePointer<[PathElement]>(userInfo)
                elementsPointer?.pointee.append(nextElement)
            }
        }
        return pathElements
    }
}

extension UIBezierPath {
    public convenience init(elements : [PathElement]) {
        self.init()
        addElements(elements: elements)
    }
    
    func addElements(elements : [PathElement]) {
        for element in elements {
            switch element {
            case .MoveToPoint(let point):
                move(to: point)
            case .AddLineToPoint(let point):
                addLine(to: point)
            case .AddQuadCurveToPoint(let pointOne, let pointTwo):
                addQuadCurve(to: pointOne, controlPoint: pointTwo)
            case .AddCurveToPoint(let pointOne, let pointTwo, let pointThree):
                addCurve(to: pointOne, controlPoint1:pointTwo, controlPoint2:pointThree)
            case .CloseSubpath:
                close()
//            default:
//                print("wrong element type")
            }
        }
    }
}
