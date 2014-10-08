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
    
    var cent=0.0;

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
        
        
        toneLabel.text = "\(tone)"
        
        
        self.cent = self.cent + 1
        let angle = self.cent * M_PI / 180.0;
        println(barView.bounds.height)
        barView.transform = CGAffineTransformMakeRotation(CGFloat(angle));


        if pitch == 0{
            toneLabel.text = ""
        }

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
        return "A"
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
