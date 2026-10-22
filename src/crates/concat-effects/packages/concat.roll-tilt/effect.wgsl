struct Params { axis: f32, angle: f32, depth: f32, blur: f32 }

// The point of the picture seen at `uv` while it is tipped `a` radians
// about its middle line, the eye `d` frame-heights in front of it: the
// inverse of the perspective projection. `z` is 0 where the line of sight
// passes over the picture's horizon and sees nothing of it.
fn tipped(uv: vec2<f32>, a: f32, d: f32) -> vec3<f32> {
    let aspect = frame.size.x / frame.size.y;
    var p = (uv - vec2<f32>(0.5)) * vec2<f32>(aspect, 1.0);
    let roll = params.axis > 0.5;
    if (roll) {
        p = p.yx;
    }
    let below = d * cos(a) - p.y * sin(a);
    let v = p.y * d / max(below, 0.0001);
    var q = vec2<f32>(p.x * (d + v * sin(a)) / d, v);
    if (roll) {
        q = q.yx;
    }
    return vec3<f32>(q / vec2<f32>(aspect, 1.0) + vec2<f32>(0.5), step(0.0001, below));
}

fn transition(uv: vec2<f32>, progress: f32) -> vec4<f32> {
    // The outgoing shot tips away to the full angle by the cut, and the
    // incoming one tips back in from the full angle the other way.
    let swing = ease_in_out_cubic(progress) - step(0.5, progress);
    let a = radians(params.angle) * swing * 2.0;
    let d = 1.5 + params.depth * 0.03;
    let spread = radians(params.angle) * bell(progress) * bell(progress) * params.blur * 0.005;
    var sum = vec4<f32>(0.0);
    for (var i: i32 = 0; i < 5; i++) {
        // Never past edge-on: a tap beyond it would see the picture's back.
        let tap = clamp(a + spread * (f32(i) / 4.0 - 0.5), -1.48, 1.48);
        let seen = tipped(uv, tap, d);
        sum += mix(vec4<f32>(0.0, 0.0, 0.0, 1.0), camera_at(seen.xy, progress), seen.z);
    }
    return sum / 5.0;
}
