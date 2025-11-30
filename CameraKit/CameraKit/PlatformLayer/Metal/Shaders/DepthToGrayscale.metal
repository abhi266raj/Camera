/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Metal compute shader that translates depth values to grayscale RGB values.
*/

#include <metal_stdlib>
using namespace metal;

struct converterParameters {
    float offset;
    float range;
};

// Compute kernel
kernel void depthToGrayscale(texture2d<float, access::read>  inputTexture      [[ texture(0) ]],
                             texture2d<float, access::write> outputTexture     [[ texture(1) ]],
                             constant converterParameters& converterParameters [[ buffer(0) ]],
                             uint2 gid [[ thread_position_in_grid ]])
{
    // Don't read or write outside of the texture.
    if ((gid.x >= inputTexture.get_width()) || (gid.y >= inputTexture.get_height())) {
        return;
    }
    
    float depth = inputTexture.read(gid).x;
    
    // Normalize the value between 0 and 1.
    depth = (depth - converterParameters.offset) / (converterParameters.range);
    
    float4 outputColor = float4(float3(depth), 1.0);
    
    outputTexture.write(outputColor, gid);
}

kernel void d2(texture2d<float, access::read>  inputTexture      [[ texture(0) ]],
                             texture2d<float, access::write> outputTexture     [[ texture(1) ]],
                             uint2 gid [[ thread_position_in_grid ]])
{
    if (gid.x >= inputTexture.get_width() || gid.y >= inputTexture.get_height()) return;

    float depth = inputTexture.read(gid).x;

    // Hardcoded normalization for iPhone 17 Pro LiDAR
    float offset = 0.2;   // minimum valid depth ~ 20 cm
    float range  = 4.8;   // max depth = 5.0 m → range = 5 - 0.2 = 4.8 m

    // Clamp to avoid negative/overflow
    depth = clamp((depth - offset) / range, 0.0, 1.0);

    float4 outputColor = float4(float3(depth), 1.0);
    outputTexture.write(outputColor, gid);
}
