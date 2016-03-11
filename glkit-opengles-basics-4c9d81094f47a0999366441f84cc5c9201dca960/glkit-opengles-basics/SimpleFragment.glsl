varying lowp vec4 DestinationColor;
/*
uniform lowp float u_time;
//uniform lowp float u_resolution;

void main(void) {
    gl_FragColor = vec4(DestinationColor.x, DestinationColor.y, DestinationColor.z, DestinationColor.a);
}*/
precision mediump float;

varying vec2 vUV;
varying vec3 vNormal;
varying vec3 HV;
varying vec3 VP;
varying float d;

uniform sampler2D colorMap;

const vec3 ambient = vec3(.1, 0.1, 0.1);
const vec3 diffuse = vec3(0.7, 0.7, 0.9);
const vec3 specular = vec3(0.7, 0.7, 0.7);
const float constantAttenuation = 1.0;
const float linearAttenuation = 0.0;
const float quadraticAttenuation = 0.0;
const float shininess = 50.0; //can be as high as 128 - bigger number = more concentrated bright spot
float spotCutoff = cos(radians(20.0)); //cosine of angle for spot cone
const vec3 LightDirection = vec3(0.0, 0.0, -1.0);
const float spotExponent = 1.0;

void main(void){
    float pf=0.0; //power factor
    float attenuation = 0.1;
    float spotAttenuation = 0.1; //final spotlight attenuation factor
    float nDotVP = 0.0;
    float nDotHV = 0.0;
    //normals may have been denormalized by linear interpolation, so we'll normalize *again*
    vec3 n = normalize(vNormal);
    vec3 c = ambient;
    nDotVP = max(dot(n,normalize(-VP)),0.0);
    if (nDotVP > 0.){
        //see if point on surface is inside cone of illumination
        float spotDot = dot(VP, normalize(LightDirection));
        if (spotDot > spotCutoff){
            spotAttenuation = pow(spotDot, spotExponent);
            //compute attenuation
            attenuation = spotAttenuation / (constantAttenuation +
                                            linearAttenuation * d +
                                             quadraticAttenuation * d * d);
            
            c += attenuation * (diffuse * nDotVP);
            
            nDotHV = max(0.0, dot(n, HV));
            
            c += attenuation * specular * pow(nDotHV, shininess);
        }
    }
    
   // gl_FragColor = texture2D(colorMap, vUV)  * vec4(c, 1.0);
    gl_FragColor = vec4(nDotVP,nDotVP,nDotVP,1.);
}