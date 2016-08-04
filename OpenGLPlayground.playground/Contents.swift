//: Playground - noun: a place where people can play

import UIKit
import GLKit
import PlaygroundSupport

//This is all GPUImage2 code (re-arranged and modified to work here in a stand-alone way
// https://github.com/BradLarson/GPUImage2

//Position.swift
public struct Position {
    public let x:Float
    public let y:Float
    public let z:Float?
    
    public init (_ x:Float, _ y:Float, _ z:Float? = nil) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    public static let Center = Position(0.5, 0.5)
    public static let Zero = Position(0.0, 0.0)
}

//Matrix.swift
#if !os(Linux)
    import QuartzCore
#endif

public struct Matrix4x4 {
    public let m11:Float, m12:Float, m13:Float, m14:Float
    public let m21:Float, m22:Float, m23:Float, m24:Float
    public let m31:Float, m32:Float, m33:Float, m34:Float
    public let m41:Float, m42:Float, m43:Float, m44:Float
    
    public init(rowMajorValues:[Float]) {
        guard rowMajorValues.count > 15 else { fatalError("Tried to initialize a 4x4 matrix with fewer than 16 values") }
        
        self.m11 = rowMajorValues[0]
        self.m12 = rowMajorValues[1]
        self.m13 = rowMajorValues[2]
        self.m14 = rowMajorValues[3]
        
        self.m21 = rowMajorValues[4]
        self.m22 = rowMajorValues[5]
        self.m23 = rowMajorValues[6]
        self.m24 = rowMajorValues[7]
        
        self.m31 = rowMajorValues[8]
        self.m32 = rowMajorValues[9]
        self.m33 = rowMajorValues[10]
        self.m34 = rowMajorValues[11]
        
        self.m41 = rowMajorValues[12]
        self.m42 = rowMajorValues[13]
        self.m43 = rowMajorValues[14]
        self.m44 = rowMajorValues[15]
    }
    
    public static let Identity = Matrix4x4(rowMajorValues:[1.0, 0.0, 0.0, 0.0,
                                                           0.0, 1.0, 0.0, 0.0,
                                                           0.0, 0.0, 1.0, 0.0,
                                                           0.0, 0.0, 0.0, 1.0])
}

public struct Matrix3x3 {
    public let m11:Float, m12:Float, m13:Float
    public let m21:Float, m22:Float, m23:Float
    public let m31:Float, m32:Float, m33:Float
    
    public init(rowMajorValues:[Float]) {
        guard rowMajorValues.count > 8 else { fatalError("Tried to initialize a 3x3 matrix with fewer than 9 values") }
        
        self.m11 = rowMajorValues[0]
        self.m12 = rowMajorValues[1]
        self.m13 = rowMajorValues[2]
        
        self.m21 = rowMajorValues[3]
        self.m22 = rowMajorValues[4]
        self.m23 = rowMajorValues[5]
        
        self.m31 = rowMajorValues[6]
        self.m32 = rowMajorValues[7]
        self.m33 = rowMajorValues[8]
    }
    
    public static let Identity = Matrix3x3(rowMajorValues:[1.0, 0.0, 0.0,
                                                           0.0, 1.0, 0.0,
                                                           0.0, 0.0, 1.0])
    
    public static let CenterOnly = Matrix3x3(rowMajorValues:[0.0, 0.0, 0.0,
                                                             0.0, 1.0, 0.0,
                                                             0.0, 0.0, 0.0])
}

func orthographicMatrix(left:Float, right:Float, bottom:Float, top:Float, near:Float, far:Float, anchorTopLeft:Bool = false) -> Matrix4x4 {
    let r_l = right - left
    let t_b = top - bottom
    let f_n = far - near
    var tx = -(right + left) / (right - left)
    var ty = -(top + bottom) / (top - bottom)
    let tz = -(far + near) / (far - near)
    
    let scale:Float
    if (anchorTopLeft) {
        scale = 4.0
        tx = -1.0
        ty = -1.0
    } else {
        scale = 2.0
    }
    
    return Matrix4x4(rowMajorValues:[
        scale / r_l, 0.0, 0.0, tx,
        0.0, scale / t_b, 0.0, ty,
        0.0, 0.0, scale / f_n, tz,
        0.0, 0.0, 0.0, 1.0])
}


#if !os(Linux)
    public extension Matrix4x4 {
        public init (_ transform3D:CATransform3D) {
            self.m11 = Float(transform3D.m11)
            self.m12 = Float(transform3D.m12)
            self.m13 = Float(transform3D.m13)
            self.m14 = Float(transform3D.m14)
            
            self.m21 = Float(transform3D.m21)
            self.m22 = Float(transform3D.m22)
            self.m23 = Float(transform3D.m23)
            self.m24 = Float(transform3D.m24)
            
            self.m31 = Float(transform3D.m31)
            self.m32 = Float(transform3D.m32)
            self.m33 = Float(transform3D.m33)
            self.m34 = Float(transform3D.m34)
            
            self.m41 = Float(transform3D.m41)
            self.m42 = Float(transform3D.m42)
            self.m43 = Float(transform3D.m43)
            self.m44 = Float(transform3D.m44)
        }
        
        public init (_ transform:CGAffineTransform) {
            self.init(CATransform3DMakeAffineTransform(transform))
        }
    }
#endif

//Color.swift
public struct Color {
    public let red:Float
    public let green:Float
    public let blue:Float
    public let alpha:Float
    
    public init(red:Float, green:Float, blue:Float, alpha:Float = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    public static let Black = Color(red:0.0, green:0.0, blue:0.0, alpha:1.0)
    public static let White = Color(red:1.0, green:1.0, blue:1.0, alpha:1.0)
    public static let Red = Color(red:1.0, green:0.0, blue:0.0, alpha:1.0)
    public static let Green = Color(red:0.0, green:1.0, blue:0.0, alpha:1.0)
    public static let Blue = Color(red:0.0, green:0.0, blue:1.0, alpha:1.0)
    public static let Transparent = Color(red:0.0, green:0.0, blue:0.0, alpha:0.0)
}

//Size.swift
public struct Size {
    public let width:Float
    public let height:Float
    
    public init(width:Float, height:Float) {
        self.width = width
        self.height = height
    }
}

//ShaderUniformSettings.swift
public struct ShaderUniformSettings {
    private var uniformValues = [String:Any]()
    
    public init() {}
    
    public subscript(index:String) -> Float? {
        get { return uniformValues[index] as? Float}
        set(newValue) { uniformValues[index] = newValue }
    }
    
    public subscript(index:String) -> Int? {
        get { return uniformValues[index] as? Int }
        set(newValue) { uniformValues[index] = newValue }
    }
    
    public subscript(index:String) -> Color? {
        get { return uniformValues[index] as? Color }
        set(newValue) { uniformValues[index] = newValue }
    }
    
    public subscript(index:String) -> Position? {
        get { return uniformValues[index] as? Position }
        set(newValue) { uniformValues[index] = newValue }
    }
    
    public subscript(index:String) -> Size? {
        get { return uniformValues[index] as? Size}
        set(newValue) { uniformValues[index] = newValue }
    }
    
    public subscript(index:String) -> Matrix4x4? {
        get { return uniformValues[index] as? Matrix4x4 }
        set(newValue) { uniformValues[index] = newValue }
    }
    
    public subscript(index:String) -> Matrix3x3? {
        get { return uniformValues[index] as? Matrix3x3}
        set(newValue) { uniformValues[index] = newValue }
    }
    
    public func restoreShaderSettings(shader:ShaderProgram) {
        for (uniform, value) in uniformValues {
            switch value {
            case let value as Float: shader.setValue(value: GLfloat(value), forUniform:uniform)
            case let value as Int: shader.setValue(value: GLint(value), forUniform:uniform)
            case let value as Color: shader.setValue(value: value, forUniform:uniform)
            case let value as Position: shader.setValue(value: value.toGLArray(), forUniform:uniform)
            case let value as Size: shader.setValue(value: value.toGLArray(), forUniform:uniform)
            case let value as Matrix4x4: shader.setMatrix(value: value.toRowMajorGLArray(), forUniform:uniform)
            case let value as Matrix3x3: shader.setMatrix(value: value.toRowMajorGLArray(), forUniform:uniform)
            default: fatalError("Somehow tried to restore a shader uniform value of an unsupported type: \(value)")
            }
        }
    }
}

extension Color {
    func toGLArray() -> [GLfloat] {
        return [GLfloat(red), GLfloat(green), GLfloat(blue)]
    }
    
    func toGLArrayWithAlpha() -> [GLfloat] {
        return [GLfloat(red), GLfloat(green), GLfloat(blue), GLfloat(alpha)]
    }
}

extension Position {
    func toGLArray() -> [GLfloat] {
        if let z = self.z {
            return [GLfloat(x), GLfloat(y), GLfloat(z)]
        } else {
            return [GLfloat(x), GLfloat(y)]
        }
    }
}

extension Size {
    func toGLArray() -> [GLfloat] {
        return [GLfloat(width), GLfloat(height)]
    }
}

extension Matrix4x4 {
    func toRowMajorGLArray() -> [GLfloat] {
        return [m11, m12, m13, m14,
                m21, m22, m23, m24,
                m31, m32, m33, m34,
                m41, m42, m43, m44]
    }
}

public extension Matrix3x3 {
    func toRowMajorGLArray() -> [GLfloat] {
        return [m11, m12, m13,
                m21, m22, m23,
                m31, m32, m33]
    }
}

//ShaderProgram.swift
struct ShaderCompileError:ErrorProtocol {
    let compileLog:String
}

enum ShaderType {
    case VertexShader
    case FragmentShader
}

public class ShaderProgram {
    public var colorUniformsUseFourComponents = false
    let program:GLuint
    var vertexShader:GLuint! // At some point, the Swift compiler will be able to deal with the early throw and we can convert these to lets
    var fragmentShader:GLuint!
    var initialized:Bool = false
    private var attributeAddresses = [String:GLuint]()
    private var uniformAddresses = [String:GLint]()
    private var currentUniformIntValues = [String:GLint]()
    private var currentUniformFloatValues = [String:GLfloat]()
    private var currentUniformFloatArrayValues = [String:[GLfloat]]()
    
    // MARK: -
    // MARK: Initialization and teardown
    
    public init(vertexShader:String, fragmentShader:String) throws {
        program = glCreateProgram()
        
        self.vertexShader = try compileShader(shaderString: vertexShader, type:.VertexShader)
        self.fragmentShader = try compileShader(shaderString: fragmentShader, type:.FragmentShader)
        
        glAttachShader(program, self.vertexShader)
        glAttachShader(program, self.fragmentShader)
        
        try link()
    }
    
    public convenience init(vertexShader:String, fragmentShaderFile:NSURL) throws {
        try self.init(vertexShader:vertexShader, fragmentShader:try shaderFromFile(file: fragmentShaderFile))
    }
    
    public convenience init(vertexShaderFile:NSURL, fragmentShaderFile:NSURL) throws {
        try self.init(vertexShader:try shaderFromFile(file: vertexShaderFile), fragmentShader:try shaderFromFile(file: fragmentShaderFile))
    }
    
    deinit {
        debugPrint("Shader deallocated")
        
        if (vertexShader != nil) {
            glDeleteShader(vertexShader)
        }
        if (fragmentShader != nil) {
            glDeleteShader(fragmentShader)
        }
        glDeleteProgram(program)
    }
    
    // MARK: -
    // MARK: Attributes and uniforms
    
    public func attributeIndex(attribute:String) -> GLuint? {
        if let attributeAddress = attributeAddresses[attribute] {
            return attributeAddress
        } else {
            var attributeAddress:GLint = -1
            attribute.withGLChar{glString in
                attributeAddress = glGetAttribLocation(self.program, glString)
            }
            
            if (attributeAddress < 0) {
                return nil
            } else {
                glEnableVertexAttribArray(GLuint(attributeAddress))
                attributeAddresses[attribute] = GLuint(attributeAddress)
                return GLuint(attributeAddress)
            }
        }
    }
    
    public func uniformIndex(uniform:String) -> GLint? {
        if let uniformAddress = uniformAddresses[uniform] {
            return uniformAddress
        } else {
            var uniformAddress:GLint = -1
            uniform.withGLChar{glString in
                uniformAddress = glGetUniformLocation(self.program, glString)
            }
            
            if (uniformAddress < 0) {
                return nil
            } else {
                uniformAddresses[uniform] = uniformAddress
                return uniformAddress
            }
        }
    }
    
    // MARK: -
    // MARK: Uniform accessors
    
    public func setValue(value:GLfloat, forUniform:String) {
        guard let uniformAddress = uniformIndex(uniform: forUniform) else {
            debugPrint("Warning: Tried to set a uniform (\(forUniform)) that was missing or optimized out by the compiler")
            return
        }
        if (currentUniformFloatValues[forUniform] != value) {
            glUniform1f(GLint(uniformAddress), value)
            currentUniformFloatValues[forUniform] = value
        }
    }
    
    public func setValue(value:GLint, forUniform:String) {
        guard let uniformAddress = uniformIndex(uniform: forUniform) else {
            debugPrint("Warning: Tried to set a uniform (\(forUniform)) that was missing or optimized out by the compiler")
            return
        }
        if (currentUniformIntValues[forUniform] != value) {
            glUniform1i(GLint(uniformAddress), value)
            currentUniformIntValues[forUniform] = value
        }
    }
    
    public func setValue(value:Color, forUniform:String) {
        if colorUniformsUseFourComponents {
            self.setValue(value: value.toGLArrayWithAlpha(), forUniform:forUniform)
        } else {
            self.setValue(value: value.toGLArray(), forUniform:forUniform)
        }
    }
    
    public func setValue(value:[GLfloat], forUniform:String) {
        guard let uniformAddress = uniformIndex(uniform: forUniform) else {
            debugPrint("Warning: Tried to set a uniform (\(forUniform)) that was missing or optimized out by the compiler")
            return
        }
        if let previousValue = currentUniformFloatArrayValues[forUniform] where previousValue == value{
        } else {
            if (value.count == 2) {
                glUniform2fv(uniformAddress, 1, value)
            } else if (value.count == 3) {
                glUniform3fv(uniformAddress, 1, value)
            } else if (value.count == 4) {
                glUniform4fv(uniformAddress, 1, value)
            } else {
                fatalError("Tried to set a float array uniform outside of the range of values")
            }
            currentUniformFloatArrayValues[forUniform] = value
        }
    }
    
    public func setMatrix(value:[GLfloat], forUniform:String) {
        guard let uniformAddress = uniformIndex(uniform: forUniform) else {
            debugPrint("Warning: Tried to set a uniform (\(forUniform)) that was missing or optimized out by the compiler")
            return
        }
        if let previousValue = currentUniformFloatArrayValues[forUniform] where previousValue == value{
        } else {
            if (value.count == 9) {
                glUniformMatrix3fv(uniformAddress, 1, GLboolean(GL_FALSE), value)
            } else if (value.count == 16) {
                glUniformMatrix4fv(uniformAddress, 1, GLboolean(GL_FALSE), value)
            } else {
                fatalError("Tried to set a matrix uniform outside of the range of supported sizes (3x3, 4x4)")
            }
            currentUniformFloatArrayValues[forUniform] = value
        }
    }
    
    // MARK: -
    // MARK: Usage
    
    func link() throws {
        glLinkProgram(program)
        
        var linkStatus:GLint = 0
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &linkStatus)
        if (linkStatus == 0) {
            var logLength:GLint = 0
            glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &logLength)
            if (logLength > 0) {
                var compileLog = [CChar](repeating: 0, count:Int(logLength))
                
                glGetProgramInfoLog(program, logLength, &logLength, &compileLog)
                print("Link log: \(String(validatingUTF8: compileLog))")
            }
            
            throw ShaderCompileError(compileLog:"Link error")
        }
        initialized = true
    }
    
    public func use() {
        glUseProgram(program)
    }
}

func compileShader(shaderString:String, type:ShaderType) throws -> GLuint {
    let shaderHandle:GLuint
    switch type {
    case .VertexShader: shaderHandle = glCreateShader(GLenum(GL_VERTEX_SHADER))
    case .FragmentShader: shaderHandle = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
    }
    
    shaderString.withGLChar{glString in
        var tempString = glString
        
        glShaderSource(shaderHandle, 1, &tempString, nil)
        glCompileShader(shaderHandle)
    }
    
    var compileStatus:GLint = 1
    glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &compileStatus)
    if (compileStatus != 1) {
        var logLength:GLint = 0
        glGetShaderiv(shaderHandle, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        if (logLength > 0) {
            var compileLog = [CChar](repeating:0, count:Int(logLength))
            glGetShaderInfoLog(shaderHandle, logLength, &logLength, &compileLog)
            print("Compile log: \(String(validatingUTF8: compileLog))")
            // let compileLogString = String(bytes:compileLog.map{UInt8($0)}, encoding:NSASCIIStringEncoding)
            
            switch type {
            case .VertexShader: throw ShaderCompileError(compileLog:"Vertex shader compile error:")
            case .FragmentShader: throw ShaderCompileError(compileLog:"Fragment shader compile error:")
            }
        }
    }
    
    return shaderHandle
}

public func crashOnShaderCompileFailure<T>(shaderName:String, _ operation:() throws -> T) -> T {
    do {
        return try operation()
    } catch {
        print("ERROR: \(shaderName) compilation failed with error: \(error)")
        fatalError("Aborting execution.")
    }
}

public func shaderFromFile(file:NSURL) throws -> String {
    // Note: this is a hack until Foundation's String initializers are fully functional
    //        let fragmentShaderString = String(contentsOfURL:fragmentShaderFile, encoding:NSASCIIStringEncoding)
    guard (FileManager.default.fileExists(atPath: file.path!)) else { throw ShaderCompileError(compileLog:"Shader file \(file) missing")}
    let fragmentShaderString = try NSString(contentsOfFile:file.path!, encoding:String.Encoding.ascii.rawValue)
    
    return String(fragmentShaderString)
}

extension String {
    public func withNonZeroSuffix(suffix:Int) -> String {
        if suffix == 0 {
            return self
        } else {
            return "\(self)\(suffix + 1)"
        }
    }
    
    func withGLChar(operation:(UnsafePointer<GLchar>?) -> ()) {
        if self.cString(using: String.Encoding.utf8) != nil {
            operation(UnsafeMutablePointer<GLchar>(self.cString(using: String.Encoding.utf8)))
        } else {
            fatalError("Could not convert this string to UTF8: \(self)")
        }
    }
}


//End GPUImage2 code

//Playground start here

let vertices:[GLfloat] = [-1.0, -1.0, 1.0, -1.0, -1.0, 1.0, 1.0, 1.0]
let textureCoordinates:[GLfloat] =  [0.0, 1.0, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0]

// public let OneInputVertexShader = "attribute vec4 position;\n attribute vec4 inputTextureCoordinate;\n varying vec2 textureCoordinate;\n void main() {\n    gl_Position = position;\n    textureCoordinate = inputTextureCoordinate.xy;\n }"
public let OneInputVertexShader = "attribute vec4 position;\n void main() {\n    gl_Position = position;\n }"
//public let BrightnessFragmentShader = "varying highp vec2 textureCoordinate;\n uniform sampler2D inputImageTexture;\n uniform lowp float brightness;\n void main() {\n    lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);\n    gl_FragColor = vec4((textureColor.rgb + vec3(brightness)), textureColor.w); }"
public let BrightnessFragmentShader = "void main() {\n gl_FragColor = vec4(1.0, 0.0, 1.0, 1.0);\n }"
class RGViewController : GLKViewController {
    var shader : ShaderProgram?
    var uniformSettings = ShaderUniformSettings()
    
    var brightness:Float = 0.0 {
        didSet {
            uniformSettings["brightness"] = brightness
        }
    }
    
    var textureInfo : GLKTextureInfo?
    
    override func viewDidLoad() {
        let glkView = GLKView(frame: CGRect(x:0, y:0, width:400, height:300), context: EAGLContext(api: .openGLES2))
        view = glkView
        EAGLContext.setCurrent(glkView.context)
        
        do {
        shader = try ShaderProgram(vertexShader: OneInputVertexShader, fragmentShader: BrightnessFragmentShader)
        } catch let error {
            print("Error compiling shader \(error)")
        }
        
        do {
            //let url = Bundle.main.url(forResource: "image", withExtension: "png")
            let url = Bundle.main.urlForResource("image", withExtension: "png")
            textureInfo = try GLKTextureLoader.texture(withContentsOf: url!, options: nil)
        } catch let error {
            print("Error converting texture \(error)")
        }
        brightness = -0.05
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        EAGLContext.setCurrent(view.context)
        
        shader?.use()
        
        uniformSettings.restoreShaderSettings(shader: shader!)
        
        var b = brightness
        b = b + 0.01
        if (b > 1.0) {
            b = b - 2.0
        }
        
        brightness = b
        
        glClearColor(0.0, 0.0, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        
        guard let positionAttribute = shader?.attributeIndex(attribute: "position") else { fatalError("A position attribute was missing from the shader program during rendering.") }
        glVertexAttribPointer(positionAttribute, 2, GLenum(GL_FLOAT), 0, 0, vertices)
        
        let textureCoordinateAttribute = shader?.attributeIndex(attribute: "inputTextureCoordinate".withNonZeroSuffix(suffix: 0))
        glVertexAttribPointer(textureCoordinateAttribute!, 2, GLenum(GL_FLOAT), 0, 0, textureCoordinates)
        
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), (textureInfo?.name)!)
        
        shader?.setValue(value: GLint(0), forUniform:"inputImageTexture".withNonZeroSuffix(suffix: 0))
        
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
    }
}

let viewController = RGViewController()

PlaygroundPage.current.liveView = viewController.view

viewController.textureInfo
