//
//  ViewController.swift
//  AudioRecorder
//
//  Created by heyuze on 2017/11/6.
//  Copyright © 2017年 heyuze. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    private var currentPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(effectiveAreaView)
        view.addSubview(button)
        
        button.alignBottom("-50", trailing: "-30", toView: view)
        button.constrainWidth("90", height: "40")
        effectiveAreaView.alignCenter(withView: button)
        effectiveAreaView.constrainWidth(toView: button, predicate: "*2")
        effectiveAreaView.constrainHeight(toView: button, predicate: "*3")
        
        let playButton = UIButton()
        playButton.setTitle("Play", for: .normal)
        playButton.setTitleColor(.black, for: .normal)
        playButton.titleLabel?.font = .systemFont(ofSize: 15)
        playButton.addTarget(self, action: #selector(self.playButtonHandler), for: .touchUpInside)
        view.addSubview(playButton)
        playButton.alignCenter(withView: view)
        playButton.constrainWidth("50", height: "30")
        
        let audioRecorderView = AudioRecorderView(superView: view, button: button, effectiveAreaView: effectiveAreaView)
        audioRecorderView.setup()
     }

    @objc private func playButtonHandler() {
        guard let player = try? AVAudioPlayer.init(contentsOf: fileURL) else {
            print("play audio error")
            return
        }
        
        player.prepareToPlay()
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
            try session.setActive(true)
        } catch {
            print("player config session error")
        }
        
        player.play()
        self.currentPlayer = player
    }

    // MARK: - UI
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("按住 配音", for: .normal)
        button.setTitle("松开 结束", for: .selected)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIImage(color: UIColor(hex: 0x39c6d2)), for: .normal)
        button.setBackgroundImage(UIImage(color: UIColor(hex: 0xbebebe)), for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.isUserInteractionEnabled = false
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var effectiveAreaView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }()
}
