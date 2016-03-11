//
//  GameObject.swift
//  glkit-opengles-basics
//
//  Created by Justin Buergi on 3/7/16.
//  Copyright © 2016 dvdkouril. All rights reserved.
//
import GLKit
import Foundation

class gameObject{
    var vertexArray: GLuint = 0
    var vertexBuffer: GLuint = 0
    var indexBuffer: GLuint = 0
    var indices: [GLuint] = [];
    var gCubeVertexData: [GLfloat] = [];
    var gCubeNormalData: [GLfloat] = [];
    var gCubeUVData: [GLfloat] = [];
    

    var VerticesP: [Vertex] = []
    var verticyCount: Int = 0
    func getData(named: NSString){
        print("a")
        let truePath = NSBundle.mainBundle().pathForResource(named as String, ofType: "json")!
        let jsonData: NSData = NSData(contentsOfFile: truePath)!
        do{
            let jsonDict: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments) as! NSDictionary
            for (key, _) in jsonDict {
                print(key)
            }
            gCubeVertexData = jsonDict.valueForKey("vertices") as! [GLfloat]
            gCubeNormalData = jsonDict.valueForKey("normals") as! [GLfloat]
            let x: [[GLfloat]] = jsonDict.valueForKey("uvs") as! [[GLfloat]]
            gCubeUVData = x[0]
            let test1: [UInt] = jsonDict.valueForKey("faces") as! [UInt]
            let test2: [UInt32] = test1.map{UInt32($0)}
            indices = test2 as [GLuint]
            
            print("UV")
            print(gCubeUVData.count)
            print("Normal")
            print(gCubeNormalData.count)
            print("vertex triangles")
            print(gCubeVertexData.count/3)
            print("indicies")
            print(test1.count * 3/11)
            
            var toThree: Int = 1
            var realCountUp: Int = 0
            var normalCountUp: Int = 0
            var UVCountUp: Int = 0
            var RgCubeVertexData: [GLfloat] = [GLfloat](count: gCubeVertexData.count * 3, repeatedValue: GLfloat(0.0))
            
            
            for(var countUp = 0; countUp < gCubeVertexData.count - 1; countUp+=3){
                /*let xds = Vertex(
                    Position: (RgCubeVertexData[realCountUp - 8], RgCubeVertexData[realCountUp - 7], RgCubeVertexData[realCountUp - 6], 1.0),
                    Color: (0.951000,0.245000, 0.245000, 1.0),
                    Normal: (RgCubeVertexData[realCountUp - 5], RgCubeVertexData[realCountUp - 4], RgCubeVertexData[realCountUp - 3]),
                    UV: (gCubeUVData[UVCountUp], gCubeUVData[UVCountUp + 1])
                );*/
                
                let xds1 = Vertex(
                    Position: (gCubeVertexData[realCountUp], gCubeVertexData[realCountUp + 1], gCubeVertexData[realCountUp + 2], 1.0),
                    Color: (0.951000,0.245000, 0.245000, 1.0),
                    Normal: (gCubeNormalData[normalCountUp], gCubeNormalData[normalCountUp + 1], gCubeNormalData[normalCountUp + 2]),
                    UV: (gCubeUVData[UVCountUp], gCubeUVData[UVCountUp + 1])
                );
                realCountUp+=3;
                normalCountUp+=3;
                UVCountUp+=2;
                VerticesP.append(xds1)
            }
            /*for(var countUp = 0; countUp < gCubeVertexData.count - 1; countUp++){
                if(toThree == 1 || toThree == 2 || toThree == 3){
                    RgCubeVertexData[realCountUp] = gCubeVertexData[countUp]
                    if(toThree == 3){
                        toThree = 0
                        realCountUp++
                        normalCountUp++
                        RgCubeVertexData[realCountUp] = gCubeNormalData[normalCountUp]
                        realCountUp++
                        normalCountUp++
                        RgCubeVertexData[realCountUp] = gCubeNormalData[normalCountUp]
                        realCountUp++
                        normalCountUp++
                        RgCubeVertexData[realCountUp] = gCubeNormalData[normalCountUp]
                        
                        if(named == "top"){
                            realCountUp++
                            RgCubeVertexData[realCountUp] = 0.451000
                            realCountUp++
                            RgCubeVertexData[realCountUp] = 0.545000
                            realCountUp++
                            RgCubeVertexData[realCountUp] = 0.635
                        }else{
                            realCountUp++
                            RgCubeVertexData[realCountUp] = 0.951000
                            realCountUp++
                            RgCubeVertexData[realCountUp] = 0.245000
                            realCountUp++
                            RgCubeVertexData[realCountUp] = 0.635
                        }
                        let xds = Vertex(                                                              Position: (RgCubeVertexData[realCountUp - 8], RgCubeVertexData[realCountUp - 7], RgCubeVertexData[realCountUp - 6], 1.0),                                                       Color: (0.951000,0.245000, 0.245000, 1.0),                                    Normal: (RgCubeVertexData[realCountUp - 5],                           RgCubeVertexData[realCountUp - 4], RgCubeVertexData[realCountUp - 3]),           UV: (gCubeUVData[UVCountUp], gCubeUVData[UVCountUp + 1]));
                        verticyCount++;
                        UVCountUp+=2
                        VerticesP.append(xds)
                    }
                }
                toThree++
                realCountUp++
            }*/
            toThree = 1
            realCountUp = 0
            normalCountUp = 0
            var trueCountUp: Int = 0
            var Rindecies: [GLuint] = [GLuint](count: (indices.count * 3)/11, repeatedValue: GLuint(0.0))
            
            for(var countUp = 0; countUp < indices.count * 4/11; countUp++){
                if(toThree == 1){
                }else if(toThree == 2 || toThree == 3 || toThree == 4){
                    Rindecies[trueCountUp] = indices[realCountUp] as GLuint
                    trueCountUp++
                    if(toThree == 4){
                        toThree = 0
                        realCountUp+=7
                        normalCountUp+=7
                    }
                }
                toThree++
                realCountUp++
                
            }
            //Rindecies
            indices = Rindecies
            gCubeVertexData = RgCubeVertexData
            Vertices = VerticesP
            //print(Vertices)
            //print("Indicies")
            //print(indices.count)
            //print("vertex")
            //print(gCubeVertexData.count)
            
            
        }catch _{
            
        }
    }
    
    
    func loadBuffers(){
        glGenVertexArraysOES(1, &vertexArray);
        glBindVertexArrayOES(vertexArray);
        
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(sizeof(GLfloat) * gCubeVertexData.count), &gCubeVertexData, GLenum(GL_STATIC_DRAW))
        
        glGenBuffers(1, &indexBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), GLsizeiptr(sizeof(GLuint) * indices.count), &indices, GLenum(GL_STATIC_DRAW))
        
        
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Position.rawValue))
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Normal.rawValue))
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Color.rawValue))
        
        
      //  glVertexAttribPointer(GLuint(GLKVertexAttrib.Position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(sizeof(GLfloat)) * 9, BUFFER_OFFSET(0)   )
        
       // glVertexAttribPointer(GLuint(GLKVertexAttrib.Normal.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(sizeof(GLfloat)) * 9, BUFFER_OFFSET(12)   )
        
       // glVertexAttribPointer(GLuint(GLKVertexAttrib.Color.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(sizeof(GLfloat)) * 9, BUFFER_OFFSET(24)   )
        
        
        //glBindVertexArrayOES(0)
    }
    
    func render(){
        // print(gCubeVertexData)
        glBindVertexArrayOES(vertexArray);
        //gluniformMatrix4fv(obj.shaderProgram.pMatrixUniform, false, proj);
        
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_INT), nil)
    }
}