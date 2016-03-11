precision mediump float;

varying vec3 LCpos;                // Vertex position in light coordinates
varying vec3 LCnorm;               // Normal in light coordinates
varying vec3 LCcamera;             // Camera position in light coordinates
varying vec4 DestinationColor;


// Light parameters
 vec3 LightColor;
 vec3 LightWeights;

// Surface parameters
 vec3 SurfaceWeights;
 float SurfaceRoughness;
 bool AmbientClamping;

// Super ellipse shaping parameters
 bool BarnShaping;
 float SeWidth;
 float SeHeight;
 float SeWidthEdge;
 float SeHeightEdge;
 float SeRoundness;

// Distance shaping parameters
 float DsNear;
 float DsFar;
 float DsNearEdge;
 float DsFarEdge;

float superEllipseShape(vec3 pos){
    if (!BarnShaping){
        return 1.0;
    }else{
        
        // Project the point onto the z = 1.0 plane
        vec2 ppos = pos.xy / pos.z;
        vec2 abspos = abs(ppos);
        
        float w = SeWidth;
        float W = SeWidth + SeWidthEdge;
        float h = SeHeight;
        float H = SeHeight + SeHeightEdge;
        
        float exp1 = 2.0 / SeRoundness;
        float exp2 = -SeRoundness / 2.0;
        
        float inner = w * h * pow(pow(h * abspos.x, exp1) + pow(w * abspos.y, exp1), exp2);
        float outer = W * H * pow(pow(H * abspos.x, exp1) + pow(W * abspos.y, exp1), exp2);
        
        return 1.0 - smoothstep(inner, outer, 1.0);
    }
}

float distanceShape(vec3 pos){
    float depth;
    
    depth = abs(pos.z);
    
    float dist = smoothstep(DsNear - DsNearEdge, DsNear, depth) * (1.0 - smoothstep(DsFar, DsFar + DsFarEdge, depth));
    return dist;
}

void main(){
    SeWidth =  0.85;//3.0;
    SeHeight = 0.85;//3.0;
    SurfaceWeights = vec3(1.0, 1.0, 1.0);
    LightWeights = vec3(1.0, 1.0, 1.0);
    DsFar = 1500.0;
    DsNear = 1.0;
     
    
    LightColor =  vec3(DestinationColor.x, DestinationColor.y, DestinationColor.z);//  vec3(0.75, 0.05, 0.05);
    
    BarnShaping = true;
    
    AmbientClamping = false;
    
    SurfaceRoughness = 15.0;
    SeRoundness = 20.0;
    
    DsNearEdge = 25.0;
    DsFarEdge = 25.0;
    
    SeWidthEdge = 25.0;
    SeHeightEdge = 25.0;
    
    vec3 tmpLightColor = LightColor;
    
    vec3 N = normalize(LCnorm);
    vec3 L = -normalize(LCpos);
    vec3 V = normalize(LCcamera-LCpos);
    vec3 H = normalize(L + V);
    
    vec3 tmpColor = tmpLightColor;
    
    float attenuation = 6.5;
    attenuation *= superEllipseShape(LCpos);
    attenuation *= distanceShape(LCpos);
    
    float ndotl = dot(N, L);
    float ndoth = dot(N, H);
    
    vec3 litResult;
    
    litResult[0] = AmbientClamping ? max(ndotl, 0.0) : 1.0;
    litResult[1] = max(ndotl, 0.0);
    litResult[2] = litResult[1] * max(ndoth, 0.0) * SurfaceRoughness;
    litResult *= SurfaceWeights * LightWeights;
    
    vec3 texColor = vec3(DestinationColor.x, DestinationColor.y, DestinationColor.z );//texture( s_tex, v_tex ).xyz;
    
    vec3 ambient = tmpLightColor * texColor * litResult[0];
    vec3 diffuse = tmpColor * texColor * litResult[1];
    vec3 specular = tmpColor * litResult[2];
    gl_FragColor = vec4(attenuation * (ambient + diffuse + specular), 1.0);
    //FragColor = vec4( 1.0, 0.0, 0.0, 1.0 );
}