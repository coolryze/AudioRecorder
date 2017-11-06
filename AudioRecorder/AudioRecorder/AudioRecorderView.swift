//
//  AudioRecorderView.swift
//  AudioRecorder
//
//  Created by heyuze on 2017/11/6.
//  Copyright © 2017年 heyuze. All rights reserved.
//

import UIKit
import AVFoundation
import FLKAutoLayout

private let baseURL = try! FileManager.default.url(for: .documentDirectory,
                                           in: .userDomainMask,
                                           appropriateFor: nil,
                                           create: true)
let fileURL = baseURL.appendingPathComponent("test.aac")

class AudioRecorderView: UIView {
    
    private weak var button: UIButton!
    private weak var effectiveAreaView: UIView!
    private weak var superView: UIView!
    
    private var hud = RecordingHUD()
    private var time: Float = 0.0
    private var timer: Timer?
    private var isStart: Bool = false {
        didSet {
            if isStart {
                button.isSelected = true
                timerStart()
            } else {
                button.isSelected = false
                timerStop()
            }
        }
    }
    
    init(superView: UIView, button: UIButton, effectiveAreaView: UIView) {
        self.superView = superView
        self.button = button
        self.effectiveAreaView = effectiveAreaView
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        backgroundColor = .clear
        superView.insertSubview(self, at: 0)
        align(toView: superView)
        
        superView.insertSubview(hud, at: superView.subviews.count)
        hud.alignCenter(withView: superView)
        hud.isHidden = true
        
        setupTimer()
    }
    
    // MARK: - Timer
    
    private func setupTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(run), userInfo: nil, repeats: true)
        timerStop()
    }
    
    private func timerStart() {
        time = 0.0
        timer?.fireDate = Date.distantPast
    }
    
    private func timerStop() {
        timer?.fireDate = Date.distantFuture
    }
    
    @objc private func run() {
        time += 0.01
        if isStart && time > 0.19 && time <= 0.2 {
            hud.show(state: .recoding)
            startRecord()
        } else if time > 0.2 {
            recorder.updateMeters()
            let decibels = recorder.peakPower(forChannel: 0)
            print(decibels)
            let level = getVoiceLevel(decibels: decibels)
            hud.setVoice(level: level)
        }
    }
    
    // MARK: - Recorder
    
    private func startRecord() {
        DispatchQueue.global().async {
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(AVAudioSessionCategoryRecord)
                try session.setActive(true)
                self.recorder.record()
            } catch {
                print("session setActive error")
            }
        }
    }
    
    private func stopRecord() {
        DispatchQueue.global().async {
            let session = AVAudioSession.sharedInstance()
            self.recorder.stop()
            do {
                try session.setActive(false)
            } catch {
                print("session setActive error")
            }
        }
    }
    
    private func getVoiceLevel(decibels: Float) -> Int {
        var level: Int = 1 // 1~7, max:7, min:1
        let minDecibels: Float = -30.0
        if decibels < minDecibels {
            level = 1
        } else if decibels >= 0.0 {
            level = 7
        } else {
            let value = Int(-decibels)
            level = (7 - 2) - (value / 6) + 1
        }
        return level
    }
    
    private lazy var recorder: AVAudioRecorder = {
        do {
            let recorder = try AVAudioRecorder.init(url: fileURL, settings: [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: NSNumber.init(value: 16_000.0),
                AVNumberOfChannelsKey: NSNumber.init(value: 1),
                ])
            recorder.isMeteringEnabled = true
            return recorder
        } catch let error as NSError {
            print("\(error)")
        }
        
        fatalError("should not be here")
    }()
}

// MARK: - Touch
extension AudioRecorderView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchedBegan")
        if let point = touches.first?.location(in: self), button.frame.contains(point) {
            isStart = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first!.location(in: self)
        print("Move (\(point.x), \(point.y))")
        if !isStart || time <= 0.2 { return }
        
        if let point = touches.first?.location(in: self), effectiveAreaView.frame.contains(point) {
            hud.show(state: .recoding)
        } else {
            hud.show(state: .cancel)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesEnded \(time)")
        if !isStart { return }
        
        isStart = false
        if time > 0.2 && time <= 1 {
            // 0.2 ~ 1: ignore
            hud.show(state: .ignore)
            hud.hide(deley: 0.5)
            stopRecord()
        } else if time > 1 {
            // > 1: send
            hud.hide()
            stopRecord()
        } else {
            // < 0.2: ignore
            print("< 0.2")
            hud.hide()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesCancelled")
    }
}
