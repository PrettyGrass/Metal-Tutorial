//
//  ViewController.swift
//  MetalTriangle
//
//  Created by Kirinzer on 2019/7/22.
//  Copyright © 2019 kirinzer. All rights reserved.
//

import UIKit
import Metal

class ViewController: UIViewController {
    var device: MTLDevice!
    var metalLayer: CAMetalLayer!  // 画布
    let vertextData: [Float] = [
        0.0, 1.0, 0.0,
        -1.0, -1.0, 0.0,
        1.0, -1.0, 0.0
    ]   // 这个顶点集合会作为 vertex shader 的输入
    var vertextBuffer: MTLBuffer!
    
    // 创建渲染管线
    // 现在要用一种新的对象（render pipeline）来连接上面创建的顶点着色器和片段着色器
    var pipelineState: MTLRenderPipelineState!
    
    // 创建命令队列
    var commandQueue: MTLCommandQueue!
    
    var timer: CADisplayLink!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: - set up metal
        device = MTLCreateSystemDefaultDevice()
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
        let dataSize = vertextData.count * MemoryLayout.size(ofValue: vertextData[0])
        // 需要获取 vertex data 的字节大小，通过获取数组第一个元素大小，然后乘以数组元素数量
        vertextBuffer = device.makeBuffer(bytes: vertextData, length: dataSize, options: [])
        // 调用 MTLDevice 的这个方法可以创建一个新的 buffer 在 GPU
        
        let defaultLibrary = device.makeDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
        let vertextProgram = defaultLibrary.makeFunction(name: "basic_vertex")
        // 配置顶点着色器，片段着色器，以及像素格式
        let piplelineStateDescriptor = MTLRenderPipelineDescriptor()
        piplelineStateDescriptor.vertexFunction = vertextProgram
        piplelineStateDescriptor.fragmentFunction = fragmentProgram
        piplelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        // 最终 descripter 对象会编译进管线状态
        pipelineState = try! device.makeRenderPipelineState(descriptor: piplelineStateDescriptor)
        
        // 创建命令队列
        commandQueue = device.makeCommandQueue();
        
        //MARK: - rendering
        timer = CADisplayLink(target: self, selector: #selector(gameloop))
        timer.add(to: RunLoop.main, forMode: .default)
        // 设置完成后，每次屏幕刷新时就会调用 gameloop
    }
    
    func render() {
        guard let drawable = metalLayer?.nextDrawable() else { // nextDrawable 会返回需要绘制的纹理
            return
        }
        // 这个对象决定哪些纹理需要被渲染，哪些是空白
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture // 配置需要绘制的纹理
        renderPassDescriptor.colorAttachments[0].loadAction = .clear // 在做绘制前，设置纹理为 clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 104.0/255/0, 55.0/255.0, 1.0) // 设置 clear color 为绿色
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        // 创建渲染指令编码器
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setVertexBuffer(vertextBuffer, offset: 0, index: 0)
        
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        // 这里通知到 GPU 去画三角形，这里只画一次
        renderEncoder?.endEncoding()
        
        commandBuffer.present(drawable) //确认当前纹理将要绘制完成
        commandBuffer.commit()  //提交以发送到 GPU
    }
    
    @objc func gameloop() {
        autoreleasepool {
            self.render()
        }
    }
    
}


