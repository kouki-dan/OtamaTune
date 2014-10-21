//
//  TuningViewController.swift
//  OtamaTune
//
//  Created by Kouki Saito on 2014/10/08.
//  Copyright (c) 2014年 Kouki. All rights reserved.
//

import UIKit


class TuningViewController: PitchDetectBaseViewController{
    
    @IBOutlet weak var toneLabel: UILabel!
    @IBOutlet weak var barView: UIView!

    var silenceCount = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //TODO:confirm that it works correctly
    }

    
    func randomTone() -> String{
        let pos = random() % self.table.count
        return self.table[pos];
    }
    
    
    override func updatedPitch(frequency: Float) {
        let cent = freqToCent(frequency)
        let octave = freqToOctave(frequency)
        let tone = freqToTone(frequency)
        let pitch = Double(Int((cent - round(cent))))
        
        if frequency == 0{
            silenceCount += 1
            if silenceCount >= 5{
                toneLabel.text = ""
                barView.hidden = true
            }
            else{
            }
            return
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
