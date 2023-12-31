/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Pass-through shader (used for preview).
*/

#include <metal_stdlib>
using namespace metal;

// Vertex input/output structure for passing results from vertex shader to fragment shader
struct VertexIO
{
    float4 position [[position]];
    float2 textureCoord [[user(texturecoord)]];
};

// Vertex shader for a textured quad
vertex VertexIO vertexPassThrough(const device packed_float4 *pPosition  [[ buffer(0) ]],
                                  const device packed_float2 *pTexCoords [[ buffer(1) ]],
                                  uint                  vid        [[ vertex_id ]])
{
    VertexIO outVertex;
    
    outVertex.position = pPosition[vid];
    outVertex.textureCoord = pTexCoords[vid];
    
    return outVertex;
}

// Fragment shader for a textured quad
fragment half4 fragmentPassThrough(VertexIO         inputFragment [[ stage_in ]],
                                   texture2d<half> inputTexture  [[ texture(0) ]],
                                   sampler         samplr        [[ sampler(0) ]])
{
    //return half4(0, 0, 1.0, 1.0);
    
//    const half4 colorSample = inputTexture.sample(samplr, inputFragment.textureCoord);
//        half4 premultiplied = colorSample * colorSample.w;
//        premultiplied.w = colorSample.w;
//        return premultiplied;
    return inputTexture.sample(samplr, inputFragment.textureCoord);
  // return half4(inputTexture.sample(samplr, inputFragment.textureCoord).r,
    //           inputTexture.sample(samplr, inputFragment.textureCoord).g ,
     //          inputTexture.sample(samplr, inputFragment.textureCoord).b);
}
