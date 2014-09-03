//
//  ViewController.swift
//  OtamaTune
//
//  Created by Kouki Saito on 2014/08/31.
//  Copyright (c) 2014年 Kouki. All rights reserved.
//

import UIKit


class ViewController: UIViewController, AudioControllerDelegate, PitchDetectorDelegate {
    var autoCorrelator:PitchDetector!
    let table = [ "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#" ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let l = AudioController()
        l.delegate = self
        l.startAudio()
        
        autoCorrelator = PitchDetector(sampleRate: 44100.0,  andDelegate: self)
        
    }
    
    func updatedPitch(frequency: Float) {
        println(frequency)
    }
    
    func receivedAudioSamples(samples: UnsafeMutablePointer<Int16>, length len: Int32) {
        //println(samples)
        
        autoCorrelator.addSamples(samples, inNumberFrames: len)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func freqToTone(freq: Float) -> String{
        let tone = round(log2f(freq / 440.0) * 12.0) % 12

        return table[Int(tone)]
    }


}

