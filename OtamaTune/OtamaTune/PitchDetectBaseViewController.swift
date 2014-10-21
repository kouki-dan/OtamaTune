//
//  PitchDetectBaseViewController.swift
//  OtamaTune
//
//  Created by Kouki Saito on 2014/10/14.
//  Copyright (c) 2014年 Kouki. All rights reserved.
//

import UIKit

class PitchDetectBaseViewController: UIViewController, AudioControllerDelegate, PitchDetectorDelegate {
    var autoCorrelator:PitchDetector!
    let table = [ "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#" ]
    let freqTable = [
        "A":0,
        "A#":1,
        "B":2,
        "C":3,
        "C#":4,
        "D":5,
        "D#":6,
        "E":7,
        "F":8,
        "F#":9,
        "G":10,
        "G#":11,
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let l = AudioController()
        l.delegate = self
        l.startAudio()
        
        autoCorrelator = PitchDetector(sampleRate: 44100.0,  andDelegate: self)
    }
    func updatedPitch(frequency: Float) {
        //Fill in this in subclasses.
        //
        
    }
    func receivedAudioSamples(samples: UnsafeMutablePointer<Int16>, length len: Int32) {
        //println(samples)
        autoCorrelator.addSamples(samples, inNumberFrames: len)
    }

    func freqToCent(freq: Float) -> Float{
        return log2f(freq / 440) * 12 * 100
    }
    
    func freqToOctave(freq: Float) -> Float{
        return round((freqToCent(freq) / 100 + 3) / 12) + 4
    }
    
    func freqToTone(freq: Float) -> String{
        let tone = (round(log2f(freq / 440.0) * 12.0)+120) % 12
        return table[Int(tone)]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
