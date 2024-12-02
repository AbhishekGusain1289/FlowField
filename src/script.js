import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import GUI from 'lil-gui'
import testVertexShader from './shaders/test/vertex.glsl'
import testFragmentShader from './shaders/test/fragment.glsl'

/**
 * Base
 */
// Debug
const gui = new GUI()

// Canvas
const canvas = document.querySelector('canvas.webgl')

// Scene
const scene = new THREE.Scene()

/**
 * Test mesh
 */
// Geometry
const geometry = new THREE.PlaneGeometry(1, 1, 64, 64)




// Material
const material = new THREE.ShaderMaterial({
    vertexShader: testVertexShader,
    fragmentShader: testFragmentShader,
    side: THREE.DoubleSide,
    uniforms: {
        uTime: new THREE.Uniform(0),
        uNoiseSpeed: new THREE.Uniform(0.1),
        uNoiseFrequency: new THREE.Uniform(1.7),
        uNoiseOffset: new THREE.Uniform(0.7),
        uOffset: new THREE.Uniform(0.1)
    },
    transparent: true,
    
})


const sizeArray = new Float32Array(geometry.attributes.position.count)
for(let i = 0; i < sizeArray.length; i++){
    sizeArray[i] = Math.random() + material.uniforms.uOffset.value
}
geometry.setAttribute('aSize', new THREE.BufferAttribute(sizeArray, 1))



const plane = new THREE.Mesh(geometry, material)
plane.position.x = 1
scene.add(plane)



// Mesh
const mesh = new THREE.Points(geometry, material)
scene.add(mesh)


const times = [];
let fps;

function refreshLoop() {
  window.requestAnimationFrame(() => {
    const now = performance.now();
    while (times.length > 0 && times[0] <= now - 1000) {
      times.shift();
    }
    times.push(now);
    fps = times.length;
    console.log(fps)
    refreshLoop();
  });
}

refreshLoop();



gui.add(material.uniforms.uNoiseSpeed, 'value').min(0).max(10).step(0.001).name('noise speed').onChange(() => {
    material.needsUpdate = true
})
gui.add(material.uniforms.uNoiseFrequency, 'value').min(0).max(10).step(0.001).name('noise frequency').onChange(() => {
    material.needsUpdate = true
})
// gui.add(material.uniforms.uNoiseOffset, 'value').min(0).max(1).step(0.001).name('noise offset').onChange(() => {
//     material.needsUpdate = true
// })
gui.add(material.uniforms.uOffset, 'value').min(0).max(1).step(0.001).name('offset').onChange(() => {
    for(let i = 0; i < sizeArray.length; i++){
        sizeArray[i] = Math.random() + material.uniforms.uOffset.value
    }
    geometry.setAttribute('aSize', new THREE.BufferAttribute(sizeArray, 1))
    
    material.needsUpdate = true
})


/**
 * Sizes
 */
const sizes = {
    width: window.innerWidth,
    height: window.innerHeight
}

window.addEventListener('resize', () =>
{
    // Update sizes
    sizes.width = window.innerWidth
    sizes.height = window.innerHeight

    // Update camera
    camera.aspect = sizes.width / sizes.height
    camera.updateProjectionMatrix()

    // Update renderer
    renderer.setSize(sizes.width, sizes.height)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
})

/**
 * Camera
 */
// Base camera
const camera = new THREE.PerspectiveCamera(75, sizes.width / sizes.height)
camera.position.set(0, 0, 0.5)
scene.add(camera)

// Controls
const controls = new OrbitControls(camera, canvas)
controls.enableDamping = true

/**
 * Renderer
 */
const renderer = new THREE.WebGLRenderer({
    canvas: canvas
})
renderer.setSize(sizes.width, sizes.height)
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))

/**
 * Animate
 */
const clock = new THREE.Clock()

const tick = () =>
{
    const elapsedTime = clock.getElapsedTime()
    // Update controls
    controls.update()
    material.uniforms.uTime.value = elapsedTime

    // Render
    renderer.render(scene, camera)

    // Call tick again on the next frame
    window.requestAnimationFrame(tick)
}

tick()