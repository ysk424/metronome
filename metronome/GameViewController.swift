//
//  GameViewController.swift
//  metronome
//
//  Created by TsukamotoYoshihiko on 2015/04/17.
//  Copyright (c) 2015年 TsukamotoYoshihiko. All rights reserved.
//

import UIKit
import SpriteKit
import GoogleMobileAds

extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            let sceneData = try! NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController ,GADBannerViewDelegate {
    var adBannerView: GADBannerView!
    let ud = NSUserDefaults.standardUserDefaults()
    var adDisplayed:Bool = false
    
    private let IAPCODE:String = "TTJMET"


    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }
        //広告を表示する
        
        if ud.integerForKey(IAPCODE) != 1 {
            if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                adBannerView = GADBannerView(frame: CGRectMake(0, self.view.frame.size.height - 50, 320, 50))
            }else{
                adBannerView = GADBannerView(frame: CGRectMake(0, self.view.frame.size.height - 90, 728, 90))
            }
            adBannerView.delegate = self
            adBannerView.rootViewController = self
            adBannerView.adUnitID = "ca-app-pub-4638874782962623/4183833395"
            
            let reqAd = GADRequest()
            //reqAd.testDevices = [GAD_SIMULATOR_ID] // If you want test ad's
            adBannerView.loadRequest(reqAd)
           self.view.addSubview(adBannerView)
            adDisplayed = true
        }

    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.AllButUpsideDown
        } else {
            return UIInterfaceOrientationMask.All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
