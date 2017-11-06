//
//  RecordingHUD.swift
//  AudioRecorder
//
//  Created by heyuze on 2017/11/6.
//  Copyright © 2017年 heyuze. All rights reserved.
//

import UIKit

enum RecordingState {
    
    case recoding
    case cancel
    case ignore
}

class RecordingHUD: UIView {
    
    var state: RecordingState = .ignore
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = UIColor(hex: 0x848484)
        constrainWidth("145", height: "145")
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        addSubview(imageView)
        addSubview(label)
        
        label.alignCenterX(withView: self, predicate: "0")
        label.alignBottomEdge(withView: self, predicate: "-15")
        imageView.alignCenterX(withView: self, predicate: "0")
        imageView.alignCenterY(withView: self, predicate: "-12")
        imageView.constrainWidth(toView: self, predicate: "0")
        imageView.constrainHeight("50")
    }
    
    func show(state: RecordingState) {
        switch state {
        case .recoding:
            backgroundColor = UIColor(hex: 0x848484)
//            imageView.image = UIImage(named: "Voice1")
            label.text = "上滑手指 取消发送"
        case .cancel:
            imageView.image = UIImage(named: "CancelIcon")
            backgroundColor = UIColor(hex: 0xf76082)
            label.text = "上滑手指 取消发送"
        case .ignore:
            backgroundColor = UIColor(hex: 0x848484)
            imageView.image = UIImage(named: "IgnoreIcon")
            label.text = "说话时间太短"
        }
        self.state = state
        isHidden = false
    }
    
    func hide(deley: Double = 0.0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + deley) {
            self.isHidden = true
        }
    }
    
    func setVoice(level: Int) {
        if state != .recoding { return }
        let iconName = String(format: "Voice%d", level)
        imageView.image = UIImage(named: iconName)
    }
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
}

