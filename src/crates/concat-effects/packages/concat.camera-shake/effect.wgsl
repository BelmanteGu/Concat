struct Params { amplitude: f32, frequency: f32, rotation: f32, seed: f32, blur: f32 }

// Smooth noise in -1..1 along `t`: hashed whole steps eased into each
// other, one independent lane per axis.
fn wobble(t: f32, lane: f32) -> f32 {
    let i = floor(t);
    let f = fract(t);
    let a = hash(vec2<f32>(i, lane), params.seed);
    let b = hash(vec2<f32>(i + 1.0, lane), params.seed);
    return mix(a, b, f * f * (3.0 - 2.0 * f)) * 2.0 - 1.0;
}

// Where the shake holds the camera at `p`: a shift in uv and a turn in
// radians, both swelling to the cut and dying away after it.
fn shake(p: f32) -> vec3<f32> {
    let t = p * params.frequency;
    let e = bell(p);
    let reach = params.amplitude * 0.002 * e;
    let turn = radians(params.rotation) * e;
    return vec3<f32>(wobble(t, 1.0) * reach, wobble(t, 2.0) * reach, wobble(t, 3.0) * turn);
}

fn transition(uv: vec2<f32>, progress: f32) -> vec4<f32> {
    let now = shake(progress);
    let before = shake(progress - 0.03);
    let held = turn_about(uv, vec2<f32>(0.5), now.z) + now.xy;
    return camera_blur(held, (now.xy - before.xy) * params.blur * 0.02, progress);
}
