//
//  SettingViewController.swift
//  Myres
//
//  Created by Luis Genesius on 01/09/21.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var musicSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.bool(forKey: "Mute On") {
            musicSwitch.isOn = false
        } else {
            musicSwitch.isOn = true
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func musicSwitchChanged(_ sender: Any) {
        
        if (sender as! UISwitch).isOn {
            AudioService.instance.resumeMusic()
            UserDefaults.standard.set(false, forKey: "Mute On")
        } else {
            AudioService.instance.pauseMusic()
            UserDefaults.standard.set(true, forKey: "Mute On")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
