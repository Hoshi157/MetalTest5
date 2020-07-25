//
//  Shader.metal
//  MetalTest5
//
//  Created by 福山帆士 on 2020/07/25.
//  Copyright © 2020 福山帆士. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

// 構造体
struct ColorInOut
{
    float4 position [[ position ]]; // float4型
};

// vertex関数(ColorOut型)
vertex ColorInOut vertexShader(const device float4 *positions[[ buffer(0)]],
                               uint               vid        [[ vertex_id]])
{
    ColorInOut out; // ColorInOut.positionにアクセス
    out.position = positions[vid]; // *positins にvid引数を利用して取得
    return out;
}

// fragment関数
fragment float4 fragmentShader(ColorInOut in [[ stage_in ]])
{
    return float4(0, 0, 1, 1); // 色の設定
}


