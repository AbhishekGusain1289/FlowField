#define PI 3.141592653

varying vec2 vUv;
varying float vSize;


uniform float uTime;
uniform float uNoiseSpeed;
uniform float uNoiseFrequency;
uniform float uNoiseOffset;


vec4 permute(vec4 x){
    return mod(((x*34.0)+1.0)*x, 289.0);
}

//	Classic Perlin 2D Noise 
//	by Stefan Gustavson (https://github.com/stegu/webgl-noise)
//
vec2 fade(vec2 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}

float cnoise(vec2 P){
    vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
    vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
    Pi = mod(Pi, 289.0); // To avoid truncation effects in permutation
    vec4 ix = Pi.xzxz;
    vec4 iy = Pi.yyww;
    vec4 fx = Pf.xzxz;
    vec4 fy = Pf.yyww;
    vec4 i = permute(permute(ix) + iy);
    vec4 gx = 2.0 * fract(i * 0.0243902439) - 1.0; // 1/41 = 0.024...
    vec4 gy = abs(gx) - 0.5;
    vec4 tx = floor(gx + 0.5);
    gx = gx - tx;
    vec2 g00 = vec2(gx.x,gy.x);
    vec2 g10 = vec2(gx.y,gy.y);
    vec2 g01 = vec2(gx.z,gy.z);
    vec2 g11 = vec2(gx.w,gy.w);
    vec4 norm = 1.79284291400159 - 0.85373472095314 * 
    vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11));
    g00 *= norm.x;
    g01 *= norm.y;
    g10 *= norm.z;
    g11 *= norm.w;
    float n00 = dot(g00, vec2(fx.x, fy.x));
    float n10 = dot(g10, vec2(fx.y, fy.y));
    float n01 = dot(g01, vec2(fx.z, fy.z));
    float n11 = dot(g11, vec2(fx.w, fy.w));
    vec2 fade_xy = fade(Pf.xy);
    vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
    float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
    return 2.3 * n_xy;
}

float random (vec2 st) {
    return fract(sin(dot(st.xy,vec2(12.9898,78.233)))* 43758.5453123);
}

vec2 rotate(vec2 uv, float rotation, vec2 mid){
    return vec2(
        cos(rotation) * (uv.x - mid.x) + sin(rotation) * (uv.y - mid.y) + mid.x,
        cos(rotation) * (uv.y - mid.y) - sin(rotation) * (uv.x - mid.x) + mid.y
    );

}



void main()
{
    


    // float noise = (sin(0.3 * cnoise(vUv * uNoiseFrequency + uTime * uNoiseSpeed * 0.2)) + uNoiseOffset);
    float noise = (sin(cnoise(vUv + uTime * uNoiseSpeed)));
    // noise = min(noise, 0.9);
    // float strength = cnoise(vUv * 10.0) * 20.0;

    // noise = smoothstep(0.0, 0.5, noise);


    vec2 newUv = gl_PointCoord;

    vec2 rotatedUv = rotate(newUv, 2.0 * PI * noise, vec2(0.5));



    // Straight Lines
    // float strength = step(0.45, gl_PointCoord.y);
    // strength *= step(0.5, 1.0 - gl_PointCoord.y);
    // strength *= step(vSize, gl_PointCoord.x);


    // Flow Fields
    float strength = step(0.45, rotatedUv.y);
    strength *= step(0.5, 1.0 - rotatedUv.y);
    // strength *= step(vSize, rotatedUv.x);

    if(strength < 1.0){
        discard;
    }




    // gl_FragColor = vec4(vec3(strength), noise - 0.5);
    gl_FragColor = vec4(vec3(strength), noise + 0.7);
    // gl_FragColor = vec4(vec3(strength), 1.0);
    // gl_FragColor = vec4(rotatedUv, 1.0, 1.0);
}