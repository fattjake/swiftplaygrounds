import UIKit

extension CGPoint{
    func deltaTo(a: CGPoint) -> CGPoint {
        return CGPoint(x: self.x - a.x, y: self.y - a.y)
    }
    
    func length() -> CGFloat {
        return CGFloat(sqrt(CDouble(
            self.x*self.x + self.y*self.y
            )))
    }
    
    func multiplyBy(value:CGFloat) -> CGPoint{
        return CGPoint(x: self.x * value, y: self.y * value)
    }
    
    func addTo(a: CGPoint) -> CGPoint {
        return CGPoint(x: self.x + a.x, y: self.y + a.y)
    }
}

public extension UIBezierPath {
    public convenience init?(catmullRomPoints: [CGPoint], closed: Bool, alpha: CGFloat) {
        self.init()
        
        if catmullRomPoints.count < 4 {
            return nil
        }
        
        let startIndex = 1
        let endIndex = catmullRomPoints.count - 2
        
        for i in startIndex ..< endIndex {
            let p0 = catmullRomPoints[i-1 < 0 ? catmullRomPoints.count - 1 : i - 1]
            let p1 = catmullRomPoints[i]
            let p2 = catmullRomPoints[(i+1)%catmullRomPoints.count]
            let p3 = catmullRomPoints[(i+1)%catmullRomPoints.count + 1]
            
            let d1 = p1.deltaTo(a: p0).length()
            let d2 = p2.deltaTo(a: p1).length()
            let d3 = p3.deltaTo(a: p2).length()
            
            var b1 = p2.multiplyBy(value: pow(d1, 2 * alpha))
            b1 = b1.deltaTo(a: p0.multiplyBy(value: pow(d2, 2 * alpha)))
            b1 = b1.addTo(a: p1.multiplyBy(value: 2 * pow(d1, 2 * alpha) + 3 * pow(d1, alpha) * pow(d2, alpha) + pow(d2, 2 * alpha)))
            b1 = b1.multiplyBy(value: 1.0 / (3 * pow(d1, alpha) * (pow(d1, alpha) + pow(d2, alpha))))
            
            var b2 = p1.multiplyBy(value: pow(d3, 2 * alpha))
            b2 = b2.deltaTo(a: p3.multiplyBy(value: pow(d2, 2 * alpha)))
            b2 = b2.addTo(a: p2.multiplyBy(value: 2 * pow(d3, 2 * alpha) + 3 * pow(d3, alpha) * pow(d2, alpha) + pow(d2, 2 * alpha)))
            b2 = b2.multiplyBy(value: 1.0 / (3 * pow(d3, alpha) * (pow(d3, alpha) + pow(d2, alpha))))
            
            if i == startIndex {
                move(to: p1)
            }
            
            addCurve(to: p2, controlPoint1: b1, controlPoint2: b2)
        }
        
        if closed {
            close()
        }
    }
}
