/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Shader that gives images a pink tint by zero-ing out the green value.
*/

#include <metal_stdlib>
using namespace metal;

// Compute kernel
kernel void rosyEffect(texture2d<half, access::read>  inputTexture  [[ texture(0) ]],
                       texture2d<half, access::write> outputTexture [[ texture(1) ]],
                       uint2 gid [[thread_position_in_grid]])
{
    // Don't read or write outside of the texture.
    if ((gid.x >= inputTexture.get_width()) || (gid.y >= inputTexture.get_height())) {
        return;
    }
    
    half4 inputColor = inputTexture.read(gid);
    
    // Set the output color to the input color, excluding the green component.
    half4 outputColor = half4(inputColor.r, 0.0, inputColor.b, 1.0);
    
    outputTexture.write(outputColor, gid);
}

kernel void greenEffect(texture2d<half, access::read>  inputTexture  [[ texture(0) ]],
                       texture2d<half, access::write> outputTexture [[ texture(1) ]],
                       uint2 gid [[thread_position_in_grid]])
{
    // Don't read or write outside of the texture.
    if ((gid.x >= inputTexture.get_width()) || (gid.y >= inputTexture.get_height())) {
        return;
    }
    
    half4 inputColor = inputTexture.read(gid);
    
    // Set the output color to the input color, excluding the green component.
    half4 outputColor = half4(0.0, inputColor.g, 0.0, 1.0);
    
    outputTexture.write(outputColor, gid);
}

kernel void fourQuadrantEffect(texture2d<half, access::read>  inputTexture  [[texture(0)]],
                               texture2d<half, access::write> outputTexture [[texture(1)]],
                               uint2 gid [[thread_position_in_grid]])
{
    uint width  = inputTexture.get_width();
    uint height = inputTexture.get_height();

    if (gid.x >= width || gid.y >= height) {
        return;
    }

    uint halfW = width / 2;
    uint halfH = height / 2;

    uint2 src;

    if (gid.x < halfW && gid.y < halfH) {
        src = uint2(gid.x * 2, gid.y * 2);
    } else if (gid.x >= halfW && gid.y < halfH) {
        src = uint2((gid.x - halfW) * 2, gid.y * 2);
    } else if (gid.x < halfW && gid.y >= halfH) {
        src = uint2(gid.x * 2, (gid.y - halfH) * 2);
    } else {
        src = uint2((gid.x - halfW) * 2, (gid.y - halfH) * 2);
    }

    src.x = min(src.x, width  - 1);
    src.y = min(src.y, height - 1);

    half4 color = inputTexture.read(src);
    outputTexture.write(color, gid);
}

