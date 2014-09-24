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

    @IBOutlet weak var freqLabel: UILabel!
    @IBOutlet weak var toneLabel: UILabel!
    @IBOutlet weak var pitchLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let l = AudioController()
        l.delegate = self
        l.startAudio()
        
        autoCorrelator = PitchDetector(sampleRate: 44100.0,  andDelegate: self)
        
    }
    
    func updatedPitch(frequency: Float) {
        let cent = freqToCent(frequency)
        let octave = freqToOctave(frequency)
        let tone = freqToTone(frequency)
        let pitch = Double(Int((cent - round(cent)) * 100))
        toneLabel.text = "\(octave)\(tone)"
        pitchLabel.text = "\(pitch) cent"
        freqLabel.text = "\(frequency) f"
        
    }
    
    func receivedAudioSamples(samples: UnsafeMutablePointer<Int16>, length len: Int32) {
        //println(samples)
        autoCorrelator.addSamples(samples, inNumberFrames: len)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func freqToCent(freq: Float) -> Float{
        return log2f(freq / 440) * 12
    }
    
    func freqToOctave(freq: Float) -> Float{
        return round((freqToCent(freq) + 3) / 12) + 4
    }
    
    
    func freqToTone(freq: Float) -> String{
        let tone = (round(log2f(freq / 440.0) * 12.0)+120) % 12
        

        return table[Int(tone)]
    }


}

