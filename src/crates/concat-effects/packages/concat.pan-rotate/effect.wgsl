struct Params { direction: f32, rotation: f32, blur: f32 }

// The way the pictures travel: the outgoing one leaves this way and the
// incoming one arrives from the opposite side.
fn heading() -> vec2<f32> {
    let d = i32(params.direction + 0.5);
    if (d == 1) {
        return vec2<f32>(-1.0, 0.0);
    }
    if (d == 2) {
        return vec2<f32>(0.0, 1.0);
    }
    if (d == 3) {
        return vec2<f32>(0.0, -1.0);
    }
    return vec2<f32>(1.0, 0.0);
}

fn transition(uv: vec2<f32>, progress: f32) -> vec4<f32> {
    // One frame of travel and one sweep of the turn, eased across the cut:
    // the outgoing picture covers the first half, the incoming the second.
    let s = ease_in_out_cubic(progress) - step(0.5, progress);
    let turned = turn_about(uv, vec2<f32>(0.5), radians(params.rotation) * s);
    // The cubic's speed peaks at 3 on the cut.
    let speed = 3.0 * bell(progress) * bell(progress);
    let motion = heading() * speed * params.blur * 0.0015;
    return camera_blur(turned + heading() * s, motion, progress);
}
