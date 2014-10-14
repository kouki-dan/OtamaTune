//
//  TuningViewController.swift
//  OtamaTune
//
//  Created by Kouki Saito on 2014/10/08.
//  Copyright (c) 2014年 Kouki. All rights reserved.
//

import UIKit


class TuningViewController: UIViewController, AudioControllerDelegate, PitchDetectorDelegate{
    var autoCorrelator:PitchDetector!
    let table = [ "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#" ]
    
    @IBOutlet weak var toneLabel: UILabel!
    @IBOutlet weak var barView: UIView!

    var silenceCount = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let l = AudioController()
        l.delegate = self
        l.startAudio()
        
        autoCorrelator = PitchDetector(sampleRate: 44100.0,  andDelegate: self)

        // Do any additional setup after loading the view.
    }

    
    func updatedPitch(frequency: Float) {
        let cent = freqToCent(frequency)
        let octave = freqToOctave(frequency)
        let tone = freqToTone(frequency)
        let pitch = Double(Int((cent - round(cent)) * 100))
        
        if pitch == 0{
            silenceCount += 1
            if silenceCount >= 5{
                toneLabel.text = ""
                barView.hidden = true
            }
            else{
                return
            }
        }
        silenceCount = 0
        
        toneLabel.text = "\(tone)"
        
        let diff = Double((cent - round(cent)) * 100)
        let angle = diff * M_PI / 200.0
        barView.hidden = false
        barView.transform = CGAffineTransformMakeRotation(CGFloat(angle))


        /*
        pitchLabel.text = "\(pitch) cent"
        freqLabel.text = "\(frequency) f"
        */
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
