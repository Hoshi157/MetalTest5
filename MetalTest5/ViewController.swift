//
//  ViewController.swift
//  MetalTest5
//
//  Created by 福山帆士 on 2020/07/25.
//  Copyright © 2020 福山帆士. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController {
    
    private let device = MTLCreateSystemDefaultDevice()! // GPU
    
    private var commandQuere: MTLCommandQueue!
    
    private var pipeline: MTLRenderPipelineState! // パイプライン
    
    private var passDescriptor = MTLRenderPassDescriptor() // エンコードに使用するdescriptor
    
    private let vertexData: [Float] = [ // vertexデータ
        -1, -1 , 0, 1,
        1, -1, 0, 1,
        -1, 1, 0, 1,
        1, 1, 0, 1
    ]
    
    private var vertexBuffer: MTLBuffer!
    
    lazy var myMTKView: MTKView = {
        let mtkView = MTKView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), device: device)
        return mtkView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.addSubview(myMTKView)
        
        setUp()
        
        shaderDataBuffer()
        
        createPipeLine()
        
        
        
        myMTKView.enableSetNeedsDisplay = true
        
        myMTKView.setNeedsDisplay()
        
    }
    
    // delegate, コマンド作成
    func setUp() {
        myMTKView.delegate = self
        commandQuere = device.makeCommandQueue()!
    }
    
    // vertexデータをMTLBuffer型へ
    func shaderDataBuffer() {
        let size = vertexData.count * MemoryLayout<Float>.size
        
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: size)
    }
    
    // パイプラインの作成
    func createPipeLine() {
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        guard let library = device.makeDefaultLibrary() else { fatalError() }
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
        
        pipeline = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor) // パイプラインはrenderPipelineDescriotorが必要(deviceから生成)
    }


}

extension ViewController: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func draw(in view: MTKView) {
        
        guard let draable = view.currentDrawable else { fatalError() }
        
        guard let commandBuffer = commandQuere.makeCommandBuffer() else { fatalError() }
        
        passDescriptor.colorAttachments[0].texture = draable.texture // passDescriptorにtexttureを渡す
        
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)!// エンコード
        
        guard let pipeline = pipeline else { fatalError() }
        
        encoder.setRenderPipelineState(pipeline)
        
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        encoder.drawPrimitives(type: .triangleStrip,
                                vertexStart: 0,
                                vertexCount: 4)
        
        encoder.endEncoding()
        
        commandBuffer.present(draable)
        
        commandBuffer.commit()
        
        commandBuffer.waitUntilCompleted()
        
    }
    
    
}

