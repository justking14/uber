attribute vec4 Position;
attribute vec4 SourceColor;
attribute vec3 aVertexNormal;
attribute vec2 aVertexUV;

varying vec4 DestinationColor;


uniform mat4 ModelView;
//uniform mat4 ViewMatrix;
uniform mat4 Projection;
uniform mat4 WCtoLCit;
//uniform mat3 NormalMatrix;


varying vec3 LCpos;                // Vertex position in light coordinates
varying vec3 LCnorm;               // Normal in light coordinates
varying vec3 LCcamera;             // Camera position in light coordinates

void main( void ){
    
    DestinationColor = vec4(0.65, 0.25, 0.25, 1.0);
    mat3 NormalMatrix = mat3(ModelView);
    //NormalMatrix = transpose(inverse(NormalMatrix));
    
    vec3 wcNorm = NormalMatrix * aVertexNormal;
    wcNorm = normalize( wcNorm );
    vec4 wcPos = ( Projection * ModelView) * Position;
    gl_Position = wcPos;
    
    // TODO: Don't hard-code this...
    vec4 ViewPosition = vec4( 0.0, 2.0, 4.0, 1.0 );
    mat4 WCtoLC = ModelView;//view
    
    // Compute light coordinate system camera position,
    // vertex position and normal
    LCcamera = ( WCtoLC * ViewPosition ).xyz;
    LCpos = ( WCtoLC * wcPos ).xyz;
    LCnorm = ( WCtoLCit * vec4( wcNorm, 0.0 ) ).xyz;
    
    //v_tex = aVertexUV;
}


