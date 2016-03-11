//
//  OpenGLView.swift
//  glkit-opengles-basics
//
//  Created by David Kouřil on 22/04/15.
//  Copyright (c) 2015 dvdkouril. All rights reserved.
//

import GLKit
import Foundation

struct Vertex {
    var Position: (CFloat, CFloat, CFloat, CFloat)
    var Color: (CFloat, CFloat, CFloat, CFloat)
    var Normal: (CFloat, CFloat, CFloat)
    var UV: (CFloat, CFloat)
}
var Vertices = [
    Vertex(Position: (1, -1, 0, 1), Color: (1, 0, 0, 1), Normal: (0.25, 0.36, 0.58), UV: (0.5, 1.0)),
    Vertex(Position: (1, 1, 0, 1), Color: (1, 0, 0, 1), Normal: (0.25, 0.36, 0.58), UV: (0.5, 1.0)),
    Vertex(Position: (-1, 1, 0, 1), Color: (0, 1, 0, 1), Normal: (0.25, 0.36, 0.58), UV: (0.5, 1.0)),
    Vertex(Position: (-1, -1, 0, 1), Color: (0, 1, 0, 1), Normal: (0.25, 0.36, 0.58), UV: (1.0, 0.0)),
    Vertex(Position: (1, -1, -1, 1), Color: (1, 0, 0, 1), Normal: (0.25, 0.36, 0.58), UV: (1.0, 0.0)),
    Vertex(Position: (1, 1, -1, 1), Color: (1, 0, 0, 1), Normal: (0.25, 0.36, 0.58), UV: (1.0, 0.0)),
    Vertex(Position: (-1, 1, -1, 1), Color: (0, 1, 0, 1), Normal: (0.25, 0.36, 0.58), UV: (1.0, 1.0)),
    Vertex(Position: (-1, -1, -1, 1), Color: (0, 1, 0, 1), Normal: (0.25, 0.36, 0.58), UV: (1.0, 1.0))
]
/*
var Indices: [GLubyte] = [
    // Front
    0, 1, 2,
    2, 3, 0,
    // Back
    4, 6, 5,
    4, 7, 6,
    // Left
    2, 7, 3,
    7, 6, 2,
    // Right
    0, 4, 1,
    4, 1, 5,
    // Top
    6, 2, 1,
    1, 6, 5,
    // Bottom
    0, 3, 7,
    0, 7, 4
]*/


class OpenGLView: GLKView {
    
    
    var VAO: GLuint = GLuint()
    var time: Float = 0.0
    var vertexBuffer: GLuint = GLuint()
    var indexBuffer: GLuint = GLuint()
    var positionSlot: GLuint = 1
    var colorSlot: GLuint = 2
    var program: GLuint = GLuint()
    var normalSlot: GLuint = 3
    var uvSlot: GLuint = 4
//    override init!(frame: CGRect, context: EAGLContext!) {
//        super.init(frame: frame, context: context)
//    }
        let TOP: gameObject  = gameObject()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let api : EAGLRenderingAPI = EAGLRenderingAPI.OpenGLES2
        self.context = EAGLContext(API: api)
        self.drawableDepthFormat = GLKViewDrawableDepthFormat.Format24
        
        TOP.getData("top")
       Vertices = TOP.VerticesP
        print(TOP.indices)
        
        
        
        if !EAGLContext.setCurrentContext(self.context) {
            print("Failed to set current OpengGL ES context")
        }
        
        print("view bounds: \(self.bounds.width)x\(self.bounds.height)")
        
        program = self.compileShaders()
        self.setupVBOs()
    }
    

    override func drawRect(rect: CGRect) {
        time += 0.1
        glClearColor(0.1, 0.1, 0.1, 1.0)
        glClearDepthf(1.0)
        glClear(GLenum(GL_COLOR_BUFFER_BIT) | GLenum(GL_DEPTH_BUFFER_BIT))
        
        //println("\(time)")
        updateUniforms()
        
        glBindVertexArrayOES(VAO)
        //glViewport(0, 0, GLint(self.frame.size.width), GLint(self.frame.size.height))
        //print(TOP.indices)
        //print(TOP.indices.count)
        //print(Vertices.count)
        //glDrawElements(GLenum(GL_TRIANGLES), GLsizei(TOP.indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(TOP.indices.count), GLenum(GL_UNSIGNED_INT), nil)
        
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER)) // probably doesn't need to be here
        
        glBindVertexArrayOES(0)
    }
    
    func updateUniforms() {
        let timeUniform = glGetUniformLocation(program, "u_time")
        glUniform1f(timeUniform, self.time)
        
        let projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), Float(self.frame.width / self.frame.height), 0.1, 100.0)
        let pj: GLKMatrix4? = GLKMatrix4(m: (2.4142136573791504, 0.0, 0.0, 0.0, 0.0, 2.4142136573791504, 0.0, 0.0, 0.0, 0.0, -1.0202020406723022, -1.0, 0.0, 0.0, -0.20202019810676575, 0.0))
        
        let pDiddy: [GLfloat] = [2.4142136573791504, 0.0, 0.0, 0.0, 0.0, 2.4142136573791504, 0.0, 0.0, 0.0, 0.0, -1.0202020406723022, -1.0, 0.0, 0.0, -0.20202019810676575, 0.0]

        
        
        let projectionUniform = glGetUniformLocation(program, "Projection")
        let myMatrix: Array<GLfloat> = [
            projectionMatrix.m00, projectionMatrix.m01, projectionMatrix.m02, projectionMatrix.m03,
            projectionMatrix.m10, projectionMatrix.m11, projectionMatrix.m12, projectionMatrix.m13,
            projectionMatrix.m20, projectionMatrix.m21, projectionMatrix.m22, projectionMatrix.m23,
            projectionMatrix.m30, projectionMatrix.m31, projectionMatrix.m32, projectionMatrix.m33, ]
        
        //glUniformMatrix4fv(projectionUniform, GLsizei(1), GLboolean(0), pDiddy)
        glUniformMatrix4fv(glGetUniformLocation(program, "Projection"), GLsizei(1), GLboolean(GL_FALSE), pDiddy)
      
        
        var modelViewMatrix = GLKMatrix4MakeTranslation(0/*sin(time)*/, 0, -7)
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, time, 0, 0, 1)
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, time, 1, 0, 0)
        
        let modelViewUniform = glGetUniformLocation(program, "ModelView")
        let myModelViewMatrix: Array<GLfloat> = [
            modelViewMatrix.m00, modelViewMatrix.m01, modelViewMatrix.m02, modelViewMatrix.m03,
            modelViewMatrix.m10, modelViewMatrix.m11, modelViewMatrix.m12, modelViewMatrix.m13,
            modelViewMatrix.m20, modelViewMatrix.m21, modelViewMatrix.m22, modelViewMatrix.m23,
            modelViewMatrix.m30, modelViewMatrix.m31, modelViewMatrix.m32, modelViewMatrix.m33, ]
        
        glUniformMatrix4fv(modelViewUniform, GLsizei(1), GLboolean(0), myModelViewMatrix)
        
        
        let WCtoLCitUniform = glGetUniformLocation(program, "WCtoLCit")
        let wctolcitMatrix = GLKMatrix4InvertAndTranspose(modelViewMatrix, nil);
        let wcModelViewMatrix: Array<GLfloat> = [
            wctolcitMatrix.m00, wctolcitMatrix.m01, wctolcitMatrix.m02, wctolcitMatrix.m03,
            wctolcitMatrix.m10, wctolcitMatrix.m11, wctolcitMatrix.m12, wctolcitMatrix.m13,
            wctolcitMatrix.m20, wctolcitMatrix.m21, wctolcitMatrix.m22, wctolcitMatrix.m23,
            wctolcitMatrix.m30, wctolcitMatrix.m31, wctolcitMatrix.m32, wctolcitMatrix.m33, ]
        
        glUniformMatrix4fv(WCtoLCitUniform, GLsizei(1), GLboolean(0), wcModelViewMatrix)
        
        //var normalMatrix: GLKMatrix3 = GLKMatrix3(myModelViewMatrix.m)
        
        
        
        let normalUniform = glGetUniformLocation(program, "NormalMatrix")
        let wnormMatrix: GLKMatrix3 = GLKMatrix3(m: (
            wctolcitMatrix.m00, wctolcitMatrix.m01, wctolcitMatrix.m02,
            wctolcitMatrix.m10, wctolcitMatrix.m11, wctolcitMatrix.m12,
            wctolcitMatrix.m20, wctolcitMatrix.m21, wctolcitMatrix.m22 ))
        //print(wnormMatrix.m)
        let wNormal27: GLKMatrix3 = GLKMatrix3InvertAndTranspose(wnormMatrix, nil);

        let wcNormalViewMatrix: Array<GLfloat> = [
            wNormal27.m00, wNormal27.m01, wNormal27.m02,
            wNormal27.m10, wNormal27.m11, wNormal27.m12,
            wNormal27.m20, wNormal27.m21, wNormal27.m22,
        ]
        
        glUniformMatrix4fv(normalUniform, GLsizei(1), GLboolean(0), wcNormalViewMatrix)
        
        
        
    }
    
    func compileShader(shaderName: String?, shaderType: GLenum) -> GLuint {
        
        let shaderPath = NSBundle.mainBundle().pathForResource(shaderName!, ofType: "glsl")
        var error: NSError? = nil
        //var shaderString = String(contentsOfFile: shaderPath!, encoding: NSUTF8StringEncoding, error: &error)
        var shaderString: NSString?
        do {
            shaderString = try NSString(contentsOfFile: shaderPath!, encoding: NSUTF8StringEncoding)
        } catch let error1 as NSError {
            error = error1
            shaderString = nil
        }
        var shaderS = shaderString! as String
        shaderS += "\n"
        shaderString = shaderS as NSString
        
        if shaderString == nil {
            print("Failed to set contents shader of shader file!")
        }
        
        let shaderHandle: GLuint = glCreateShader(shaderType)
        
        //var shaderStringUTF8 = shaderString!.utf8
        var shaderStringUTF8 = shaderString!.UTF8String
        //var shaderStringLength: GLint = GLint() // LOL
        var shaderStringLength: GLint = GLint(shaderString!.length)
        glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength)
        
        glCompileShader(shaderHandle)
        
        var compileSuccess: GLint = GLint()
        
        glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &compileSuccess)
        
        if compileSuccess == GL_FALSE {
            print("Failed to compile shader \(shaderName!)!")
            var value: GLint = 0
            glGetShaderiv(shaderHandle, GLenum(GL_INFO_LOG_LENGTH), &value)
            var infoLog: [GLchar] = [GLchar](count: Int(value), repeatedValue: 0)
            var infoLogLength: GLsizei = 0
            glGetShaderInfoLog(shaderHandle, value, &infoLogLength, &infoLog)
            let s = NSString(bytes: infoLog, length: Int(infoLogLength), encoding: NSASCIIStringEncoding)
            print(s)
            
            exit(1)
        }
        
        
        return shaderHandle
        
    }
    
    // function compiles vertex and fragment shaders into program. Returns program handle
    func compileShaders() -> GLuint {
        
        let vertexShader: GLuint = self.compileShader("SimpleVertexUber", shaderType: GLenum(GL_VERTEX_SHADER))
        let fragmentShader: GLuint = self.compileShader("SimpleFragmentUber", shaderType: GLenum(GL_FRAGMENT_SHADER))
        
        let programHandle: GLuint = glCreateProgram()
        glAttachShader(programHandle, vertexShader)
        glAttachShader(programHandle, fragmentShader)
        
        
        glBindAttribLocation(programHandle, self.colorSlot, "SourceColor")
        glBindAttribLocation(programHandle, self.positionSlot, "Position")
        glBindAttribLocation(programHandle, self.normalSlot, "aVertexNormal")
        glBindAttribLocation(programHandle, self.uvSlot, "aVertexUV")
        glLinkProgram(programHandle)
        
        var linkSuccess: GLint = GLint()
        glGetProgramiv(programHandle, GLenum(GL_LINK_STATUS), &linkSuccess)
        if linkSuccess == GL_FALSE {
            print("Failed to create shader program!")
            
            var value: GLint = 0
            glGetProgramiv(programHandle, GLenum(GL_INFO_LOG_LENGTH), &value)
            var infoLog: [GLchar] = [GLchar](count: Int(value), repeatedValue: 0)
            var infoLogLength: GLsizei = 0
            glGetProgramInfoLog(programHandle, value, &infoLogLength, &infoLog)
            let s = NSString(bytes: infoLog, length: Int(infoLogLength), encoding: NSASCIIStringEncoding)
            print(s)
            
            //GLchar messages[1024]
            //glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
            exit(1)
        }
        
        glUseProgram(programHandle)

        glEnableVertexAttribArray(self.positionSlot)
        glEnableVertexAttribArray(self.colorSlot)
        glEnableVertexAttribArray(self.normalSlot)
        glEnableVertexAttribArray(self.uvSlot)
        
        
        return programHandle
    }

    
    func setupVBOs() {
        glGenVertexArraysOES(1, &VAO)
        glBindVertexArrayOES(VAO)
        
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        print("Vertices.count: \(Vertices.count)")
        glBufferData(GLenum(GL_ARRAY_BUFFER), Vertices.count * sizeof(Vertex), Vertices, GLenum(GL_STATIC_DRAW))
        
        //let positionSlotFirstComponent = UnsafePointer<Int>(0)
        let positionSlotFirstComponent = UnsafePointer<Int>(bitPattern: 0)
        glEnableVertexAttribArray(positionSlot)
        glVertexAttribPointer(positionSlot, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(sizeof(Vertex)), positionSlotFirstComponent)
        
        glEnableVertexAttribArray(colorSlot)
        let colorSlotFirstComponent = UnsafePointer<Int>(bitPattern: sizeof(CFloat) * 4)
        glVertexAttribPointer(colorSlot, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(sizeof(Vertex)), colorSlotFirstComponent)
        
        
        glEnableVertexAttribArray(normalSlot)
        let normalSlotFirstComponent = UnsafePointer<Int>(bitPattern: sizeof(CFloat) * 8)
        glVertexAttribPointer(normalSlot, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(sizeof(Vertex)), normalSlotFirstComponent)
        
        glEnableVertexAttribArray(uvSlot)
        let uvSlotFirstComponent = UnsafePointer<Int>(bitPattern: sizeof(CFloat) * 10)
        glVertexAttribPointer(uvSlot, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(sizeof(Vertex)), uvSlotFirstComponent)
        
        
        glGenBuffers(1, &indexBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), TOP.indices.count * sizeof(GLuint), TOP.indices, GLenum(GL_STATIC_DRAW))
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArrayOES(0)
        
    }

    
}
