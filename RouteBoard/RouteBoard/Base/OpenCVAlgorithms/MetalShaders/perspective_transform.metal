//
//  perspective_transform.metal
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 06.02.2025..
//

#include <metal_stdlib>
using namespace metal;

kernel void perspective_transform(
    device float2 *points [[buffer(0)]],
    constant float3x3 &matrix [[buffer(1)]],
    device float2 *result [[buffer(2)]],
    uint id [[thread_position_in_grid]])
{
    float2 point = points[id];
    float3 vec = float3(point.x, point.y, 1.0);
    float3 transformed = matrix * vec;
    result[id] = transformed.xy / transformed.z;
}
