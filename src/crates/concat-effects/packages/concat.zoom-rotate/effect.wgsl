struct Params { zoom: f32, rotation: f32, overshoot: f32, blur: f32 }

fn transition(uv: vec2<f32>, progress: f32) -> vec4<f32> {
    let peak = 1.0 + params.zoom * 0.04;
    let half_turn = radians(params.rotation) * 0.5;
    // Before the cut the camera speeds in on the outgoing shot and turns
    // half the way; after it, it pulls back out of the incoming one and
    // turns the rest, past its rest and back as far as the overshoot says.
    var c: f32;
    var z: f32;
    if (progress < 0.5) {
        let q = progress * 2.0;
        c = q * q * q;
        z = mix(1.0, peak, c);
    } else {
        let q = progress * 2.0 - 1.0;
        c = mix(ease_out_quint(q), ease_out_back(q, 2.5), params.overshoot * 0.01) - 1.0;
        z = mix(peak, 1.0, c + 1.0);
    }
    let turned = turn_about(uv, vec2<f32>(0.5), half_turn * c);
    let sampled = vec2<f32>(0.5) + (turned - vec2<f32>(0.5)) / max(z, 0.1);
    // Radial blur: each pixel smears along its own line to the middle.
    let speed = bell(progress) * bell(progress);
    return camera_blur(sampled, (sampled - vec2<f32>(0.5)) * speed * params.blur * 0.004, progress);
}
