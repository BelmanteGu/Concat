struct Params { zoom: f32, twirl: f32, blur: f32 }

fn transition(uv: vec2<f32>, progress: f32) -> vec4<f32> {
    // Squared, so the vortex gathers late and lets go early.
    let k = bell(progress) * bell(progress);
    let aspect = frame.size.x / frame.size.y;
    let r = length((uv - vec2<f32>(0.5)) * vec2<f32>(aspect, 1.0));
    // The twist is strongest in the middle and gone by the frame's height
    // away from it; it winds up to the cut and unwinds after.
    let fall = max(1.0 - r, 0.0);
    let twisted = turn_about(uv, vec2<f32>(0.5), radians(params.twirl) * k * fall * fall);
    let z = 1.0 + params.zoom * 0.03 * k;
    let sampled = vec2<f32>(0.5) + (twisted - vec2<f32>(0.5)) / z;
    return camera_blur(sampled, (sampled - vec2<f32>(0.5)) * k * k * params.blur * 0.003, progress);
}
