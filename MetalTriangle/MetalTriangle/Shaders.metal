//
//  shaders.metal
//  MetalImage
//
//  Created by Kirinzer on 2019/7/22.
//  Copyright © 2019 zerocat. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

// 创建顶点着色器
vertex float4 basic_vertex (   //1
                            const device packed_float3* vertex_array [[ buffer(0) ]], //2
                            unsigned int vid [[ vertex_id ]]) { //3
  return float4(vertex_array[vid], 1.0);  //4
}

//1. 所有顶点着色器必须以关键字 vertex 开始，方法必须返回最终的顶点位置。你在这里表明了类型 float4 （一种 4 浮点顶点），
//然后你给这个顶点着色器命名，在后面用到这个着色器的时候会用到这个名字。
//2. 第一个参数是一个数组指针 packed_float3 类型
//使用 [[...]] 语法去声明属性，可以添加详细的附加信息，例如资源位置，着色器输入，内建的变量。
//[[ buffer(0) ]] 这个参数指示了，从你的 Metal 代码发送给你的顶点着色器的数据的第一个 buffer， 将会占据这个参数位置。
//3. 顶点着色器也能使用 vertex_id 属性获取到一些特殊的参数。这意味着 Metal 能够使用在顶点数组里指定的顶点去填充它。
//4. 在这里，你根据 vertex id 查找顶点数组内的位置并返回该位置。
//你还要将向量转换为 float4，其中最终值为 1.0 ，这是 3D 数学所要求的。


// 创建片段着色器 （会混合不同顶点的颜色）
// 片段着色器的入参是通过获取到顶点着色器的输出并插入

fragment half4 basic_fragment() { //1
  return half4(1.0);  //2
}
//1. 所有顶点着色器必须以关键字 fragment 开头，该方法会返回片段的最终颜色。
//并且指明了类型，这种类型会比 float4 有更高的内存效率，因为会运行在更小的 GPU 内存上。
//2. 现在返回 （1, 1, 1, 1） 这个是白色
