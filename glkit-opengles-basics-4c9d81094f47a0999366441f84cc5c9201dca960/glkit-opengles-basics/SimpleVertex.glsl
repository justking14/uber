attribute vec4 Position;
attribute vec4 SourceColor;
attribute vec3 aVertexNormal;
attribute vec2 aVertexUV;
varying vec4 DestinationColor;

uniform mat4 Projection;
uniform mat4 ModelView;
uniform float u_time;

varying vec2 vUV;
varying vec3 vNormal;
varying float d;
varying vec3 HV;
varying vec3 VP;

const vec3 LightPosition = vec3(0.0, 0.0, 8.0);

void main(void) {
    DestinationColor = vec4(aVertexNormal, 1.0);
    vec3 ecPos = (Projection * ModelView * Position).xyz;
    vec3 eye = -normalize(ecPos);
    
    //vector for surface to light position
    VP = vec3(LightPosition - ecPos);
    //distance from light to surface
    d = length(VP);
    VP = normalize(VP);
    HV = normalize(VP + eye);
    
    gl_Position = Projection * ModelView * Position;
    vUV = aVertexUV;
    vNormal = (Projection * ModelView * vec4(aVertexNormal, 1.0)).xyz;
}


 