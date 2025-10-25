// ===== wp_portal.frag =====
#version 450

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 1) uniform sampler2D source1;  // Current wallpaper (shrinks away)
layout(binding = 2) uniform sampler2D source2;  // Next wallpaper (underneath)

layout(std140, binding = 0) uniform buf {
    mat4  qt_Matrix;
    float qt_Opacity;
    float progress;      // 0..1
    float centerX;       // 0..1
    float centerY;       // 0..1
    float smoothness;    // 0..1 (edge softness)
    float aspectRatio;   // width / height

    float fillMode;      // 0=stretch, 1=fit, 2=crop, 3=tile, 4=tileV, 5=tileH, 6=pad
    float imageWidth1;
    float imageHeight1;
    float imageWidth2;
    float imageHeight2;
    float screenWidth;
    float screenHeight;
    vec4  fillColor;
} ubuf;

vec2 calculateUV(vec2 uv, float imgWidth, float imgHeight) {
    vec2 transformedUV = uv;

    if (ubuf.fillMode < 0.5) {
        transformedUV = uv;
    }
    else if (ubuf.fillMode < 1.5) {
        float scale = min(ubuf.screenWidth / imgWidth, ubuf.screenHeight / imgHeight);
        vec2 scaledImageSize = vec2(imgWidth, imgHeight) * scale;
        vec2 offset = (vec2(ubuf.screenWidth, ubuf.screenHeight) - scaledImageSize) * 0.5;
        vec2 screenPixel = uv * vec2(ubuf.screenWidth, ubuf.screenHeight);
        vec2 imagePixel = (screenPixel - offset) / scale;
        transformedUV = imagePixel / vec2(imgWidth, imgHeight);
    }
    else if (ubuf.fillMode < 2.5) {
        float scale = max(ubuf.screenWidth / imgWidth, ubuf.screenHeight / imgHeight);
        vec2 scaledImageSize = vec2(imgWidth, imgHeight) * scale;
        vec2 offset = (scaledImageSize - vec2(ubuf.screenWidth, ubuf.screenHeight)) / scaledImageSize;
        transformedUV = uv * (vec2(1.0) - offset) + offset * 0.5;
    }
    else if (ubuf.fillMode < 3.5) {
        transformedUV = fract(uv * vec2(ubuf.screenWidth, ubuf.screenHeight) / vec2(imgWidth, imgHeight));
    }
    else if (ubuf.fillMode < 4.5) {
        vec2 tileUV = uv * vec2(ubuf.screenWidth, ubuf.screenHeight) / vec2(imgWidth, imgHeight);
        transformedUV = vec2(uv.x, fract(tileUV.y));
    }
    else if (ubuf.fillMode < 5.5) {
        vec2 tileUV = uv * vec2(ubuf.screenWidth, ubuf.screenHeight) / vec2(imgWidth, imgHeight);
        transformedUV = vec2(fract(tileUV.x), uv.y);
    }
    else {
        vec2 screenPixel = uv * vec2(ubuf.screenWidth, ubuf.screenHeight);
        vec2 imageOffset = (vec2(ubuf.screenWidth, ubuf.screenHeight) - vec2(imgWidth, imgHeight)) * 0.5;
        vec2 imagePixel = screenPixel - imageOffset;
        transformedUV = imagePixel / vec2(imgWidth, imgHeight);
    }

    return transformedUV;
}

vec4 sampleWithFillMode(sampler2D tex, vec2 uv, float imgWidth, float imgHeight) {
    vec2 transformedUV = calculateUV(uv, imgWidth, imgHeight);

    if (ubuf.fillMode >= 2.5 && ubuf.fillMode <= 5.5) {
        return texture(tex, transformedUV);
    }

    if (transformedUV.x < 0.0 || transformedUV.x > 1.0 ||
        transformedUV.y < 0.0 || transformedUV.y > 1.0) {
        return ubuf.fillColor;
    }

    return texture(tex, transformedUV);
}

void main() {
    vec2 uv = qt_TexCoord0;

    vec4 oldCol = sampleWithFillMode(source1, uv, ubuf.imageWidth1, ubuf.imageHeight1);
    vec4 newCol = sampleWithFillMode(source2, uv, ubuf.imageWidth2, ubuf.imageHeight2);

    // Edge softness
    float edgeSoft = mix(0.001, 0.45, ubuf.smoothness * ubuf.smoothness);

    // Aspect-corrected distance from center (keep circle round)
    vec2 center   = vec2(ubuf.centerX, ubuf.centerY);
    vec2 acUv     = vec2(uv.x * ubuf.aspectRatio, uv.y);
    vec2 acCenter = vec2(center.x * ubuf.aspectRatio, center.y);
    float dist    = length(acUv - acCenter);

    // Max radius from center to cover screen
    float maxDistX = max(center.x * ubuf.aspectRatio, (1.0 - center.x) * ubuf.aspectRatio);
    float maxDistY = max(center.y, 1.0 - center.y);
    float maxDist  = length(vec2(maxDistX, maxDistY));

    // Smooth easing for a friendly feel
    float p = ubuf.progress;
    p = p * p * (3.0 - 2.0 * p);

    // Portal radius shrinks from full to zero (bias by edgeSoft so it vanishes cleanly)
    float radius = (1.0 - p) * (maxDist + edgeSoft) - edgeSoft;

    // Inside circle = old wallpaper; outside = new wallpaper
    float t = smoothstep(radius - edgeSoft, radius + edgeSoft, dist);
    // When radius is large: t ~ 0 inside (old), ~1 outside (new)
    // As radius shrinks, old area collapses to center.

    vec4 col = mix(oldCol, newCol, t);

    // Snaps
    if (ubuf.progress <= 0.0) col = oldCol; // full old at start
    if (ubuf.progress >= 1.0) col = newCol; // full new at end

    fragColor = col * ubuf.qt_Opacity;
}
