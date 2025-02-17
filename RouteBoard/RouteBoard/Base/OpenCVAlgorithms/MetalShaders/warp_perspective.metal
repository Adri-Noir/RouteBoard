//
//  warp_perspective.metal
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 06.02.2025..
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexOut warp_vertex(
    uint vertexID [[vertex_id]],
    constant float4x4 &matrix [[buffer(0)]]
) {
    float2 positions[4] = {
        {-1, -1}, {-1, 1}, {1, -1}, {1, 1}
    };
    
    VertexOut out;
    out.position = float4(positions[vertexID], 0, 1);
    out.texCoord = (positions[vertexID] + 1.0) * 0.5;
    return out;
}

fragment float4 warp_fragment(
    VertexOut in [[stage_in]],
    texture2d<float> sourceTexture [[texture(0)]],
    constant float3x3 &homography [[buffer(0)]]
) {
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    
    float3 uv = homography * float3(in.texCoord.x, 1.0 - in.texCoord.y, 1.0);
    uv /= uv.z;
    return sourceTexture.sample(textureSampler, float2(uv.x, 1.0 - uv.y));
}
