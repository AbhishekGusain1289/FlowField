varying vec2 vUv;
varying float vSize;


uniform vec2 uResolution;
attribute float aSize;


void main()
{
    vec4 viewPosition = viewMatrix * vec4(position, 1.0);


    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    gl_PointSize = 15.0 * aSize;
    gl_PointSize *= (1.0 / -viewPosition).z;


    // Varyings
    vUv = uv;
    vSize = aSize;
}
