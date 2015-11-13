//
//  GameScene.swift
//  metronome
//
//  Created by TsukamotoYoshihiko on 2015/04/17.
//  Copyright (c) 2015年 TsukamotoYoshihiko. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    //---------- グローバルと定数

    let userDefaults = NSUserDefaults.standardUserDefaults()
    var recTime:[Double]=[]
    var maxRec:Int = 0
    var recStartFrom:Int = 0
    var recStartTime:Double = 0.0
    var gScreenLock:Bool = false
    var playFrom:Int = -1
    var playTo:Int = -1
    var gPlayMode = 0
    var gPlayModeMeasureCount = -1
    
    var gScrollMode:Int = 0
    var gVoiceMode:Int = 0
    var gDC = -999
    
    private var forceRewrite:Bool = false
    private var 現在の拍数:Int = 0
    private var 拍数:Int = 4
    
    private var isMoving:Bool = false//現在動いてるか？初期値は止まってる
    private var isStarting:Bool = false//動作するように指示されているか？初期値は停止するように指示されている
    private var isGoingToRight:Bool = true//現在動いてる方向
    private var lastClickTime:Double = 0.0//最後にクリックした時間を保持するワークのため初期値なし
    private var isSoundON:Bool = true
    
    //
    let base_p = SKSpriteNode(imageNamed: "base-p")//振り子本体
    let base_w = SKSpriteNode(imageNamed: "base-w")//錘
    let dial = SKSpriteNode(imageNamed: "dial")//速度ダイヤル
    let click_s0 = SKAction.playSoundFileNamed("bell.wav", waitForCompletion: true)
    let click_s1 = SKAction.playSoundFileNamed("4bunonpu.wav", waitForCompletion: true)
    let click_s2 = SKAction.playSoundFileNamed("8bunonpu.wav", waitForCompletion: true)
    let voice1 = SKAction.playSoundFileNamed("v1.wav", waitForCompletion: true)
    let voice2 = SKAction.playSoundFileNamed("v2.wav", waitForCompletion: true)
    let voice3 = SKAction.playSoundFileNamed("v3.wav", waitForCompletion: true)
    let voice4 = SKAction.playSoundFileNamed("v4.wav", waitForCompletion: true)
    let voice5 = SKAction.playSoundFileNamed("v5.wav", waitForCompletion: true)
    let voice6 = SKAction.playSoundFileNamed("v6.wav", waitForCompletion: true)
    
    //ダイヤル関係の変数
    let dialX = 100.0//位置
    let dialY = 700.0//位置
    var dialRotate = 0.0//回転
    var dialRotateOld = 0.01//以前の位置
    let dialNum = SKLabelNode(fontNamed:"Arial-BoldMT")//テンポを表す数字
    var isNoteSelected:Bool = false
    var SelectedNoteNumber:Int = 0
    var prevNotsButton = 0
    //拍数ボタン
    let n0ON = SKSpriteNode(imageNamed: "n0ON")
    let n2ON = SKSpriteNode(imageNamed: "n2ON")
    let n3ON = SKSpriteNode(imageNamed: "n3ON")
    let n4ON = SKSpriteNode(imageNamed: "n4ON")
    let n5ON = SKSpriteNode(imageNamed: "n5ON")
    let n6ON = SKSpriteNode(imageNamed: "n6ON")
    let n0OFF = SKSpriteNode(imageNamed: "n0OFF")
    let n2OFF = SKSpriteNode(imageNamed: "n2OFF")
    let n3OFF = SKSpriteNode(imageNamed: "n3OFF")
    let n4OFF = SKSpriteNode(imageNamed: "n4OFF")
    let n5OFF = SKSpriteNode(imageNamed: "n5OFF")
    let n6OFF = SKSpriteNode(imageNamed: "n6OFF")
    let b1ON = SKSpriteNode(imageNamed: "b1ON")
    let b2ON = SKSpriteNode(imageNamed: "b2ON")
    let b3ON = SKSpriteNode(imageNamed: "b3ON")
    let b1OFF = SKSpriteNode(imageNamed: "b1OFF")
    let b2OFF = SKSpriteNode(imageNamed: "b2OFF")
    let b3OFF = SKSpriteNode(imageNamed: "b3OFF")

    let swOFF = SKSpriteNode(imageNamed: "swOFF")
    let swON = SKSpriteNode(imageNamed: "swON")

    override func didMoveToView(view: SKView) {
        UIApplication.sharedApplication().idleTimerDisabled = true

        //土台の読み込み、土台は２個ある上下になってる
        let base_X_position:CGFloat = 576/2 //土台の横方向の位置
        let base_m1 = SKSpriteNode(imageNamed: "base-m1")//上半分
        let base_m2 = SKSpriteNode(imageNamed: "base-m2")//下半分
        base_m1.position = CGPointMake(base_X_position, 510.0)
        base_m2.position = CGPointMake(base_X_position+8, 135.0)
        base_m1.zPosition = 0
        base_m2.zPosition = 5
        self.addChild(base_m1)
        self.addChild(base_m2)
        base_p.anchorPoint = CGPointMake(0.5, 0)
        base_p.position = CGPointMake(base_X_position, 190.0)
        base_w.anchorPoint=CGPointMake(0.47, 0.5)
        base_w.position = CGPointMake(0, 150)
        base_p.zPosition = 3
        base_w.zPosition = 4
        self.addChild(base_p)
        base_p.addChild(base_w)
        //速度ダイヤル
        dial.position = CGPointMake(CGFloat(dialX) ,CGFloat(dialY))
        dial.zPosition = 2.0
        self.addChild(dial)
        dialNum.text = String(0)
        dialNum.fontSize = 70
        dialNum.position = CGPointMake(130,480)
        dialNum.zPosition = 3.0
        self.addChild(dialNum)
        //
        b1ON.zPosition = 6
        b1ON.hidden = true
        b1ON.position = CGPointMake(576/2-105,140)
        self.addChild(b1ON)
        b2ON.zPosition = 6
        b2ON.hidden = true
        b2ON.position = CGPointMake(576/2,140)
        self.addChild(b2ON)
        b3ON.zPosition = 6
        b3ON.hidden = true
        b3ON.position = CGPointMake(576/2+105,140)
        self.addChild(b3ON)
        b1OFF.zPosition = 5
        b1OFF.position = CGPointMake(576/2-105,140)
        self.addChild(b1OFF)
        b2OFF.zPosition = 5
        b2OFF.position = CGPointMake(576/2,140)
        self.addChild(b2OFF)
        b3OFF.zPosition = 5
        b3OFF.position = CGPointMake(576/2+105,140)
        self.addChild(b3OFF)
        //
        n0ON.zPosition = 1
        n0ON.hidden = true
        n0ON.position = CGPointMake(465,310)
        self.addChild(n0ON)
        n2ON.zPosition = 1
        n2ON.hidden = true
        n2ON.position = CGPointMake(465,310+80)
        self.addChild(n2ON)
        n3ON.zPosition = 1
        n3ON.hidden = true
        n3ON.position = CGPointMake(465,310+160)
        self.addChild(n3ON)
        n4ON.zPosition = 1
        n4ON.hidden = true
        n4ON.position = CGPointMake(465,310+240)
        self.addChild(n4ON)
        n5ON.zPosition = 1
        n5ON.hidden = true
        n5ON.position = CGPointMake(465,310+320)
        self.addChild(n5ON)
        n6ON.zPosition = 1
        n6ON.hidden = true
        n6ON.position = CGPointMake(465,310+400)
        self.addChild(n6ON)
        n0OFF.zPosition = 0
        n0OFF.position = CGPointMake(465,310)
        self.addChild(n0OFF)
        n2OFF.zPosition = 0
        n2OFF.position = CGPointMake(465,310+80)
        self.addChild(n2OFF)
        n3OFF.zPosition = 0
        n3OFF.position = CGPointMake(465,310+160)
        self.addChild(n3OFF)
        n4OFF.zPosition = 0
        n4OFF.position = CGPointMake(465,310+240)
        self.addChild(n4OFF)
        n5OFF.zPosition = 0
        n5OFF.position = CGPointMake(465,310+320)
        self.addChild(n5OFF)
        n6OFF.zPosition = 0
        n6OFF.position = CGPointMake(465,310+400)
        self.addChild(n6OFF)
        //
        swON.zPosition = 1
        swON.hidden = true
        swON.position = CGPointMake(125,410)
        self.addChild(swON)
        swOFF.zPosition = 0
        swOFF.position = CGPointMake(125,410)
        self.addChild(swOFF)
        /*
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker,error:nil)
        }*/
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in (touches ) {
            let location = touch.locationInNode(self)
            
            if 範囲(location,cx:465,cy:310,r:40) {
                拍数 = 0
                return
            }
            if 範囲(location,cx:465,cy:310+80,r:40) {
                拍数 = 2
                return
            }
            if 範囲(location,cx:465,cy:310+160,r:40) {
                拍数 = 3
                return
            }
            if 範囲(location,cx:465,cy:310+240,r:40) {
                拍数 = 4
                return
            }
            if 範囲(location,cx:465,cy:310+320,r:40) {
                拍数 = 5
                return
            }
            if 範囲(location,cx:465,cy:310+400,r:40) {
                拍数 = 6
                return
            }
            
            if 範囲(location,cx:576/2-105,cy:140,r:50) {
                subbeatCount = 0
                return
            }
            if 範囲(location,cx:576/2,cy:140,r:50) {
                subbeatCount = 2
                return
            }
            if 範囲(location,cx:576/2+105,cy:140,r:50) {
                subbeatCount = 3
                return
            }

            if 範囲(location,cx:125,cy:410,r:40) {
                if gVoiceMode==1 {
                    gVoiceMode = 0
                }else{
                    gVoiceMode = 1
                }
                return
            }
            
            if (location.x < CGFloat(dialX + 130.0))  && (location.y > CGFloat(dialY - 130.0)){
                return
            }//ダイアルにタッチしてる

            
            if(isStarting){
                isStarting=false
            }else{
                isStarting = true
            }
        }
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?){
        
        for touch: AnyObject in touches {
            let t: UITouch = touch as! UITouch
            let cpoint = t.locationInNode(self)
            let ppoint = t.previousLocationInNode(self)

            if !gScreenLock && (cpoint.x < CGFloat(dialX + 130.0))  && (cpoint.y > CGFloat(dialY - 130.0)) {
                //ダイアル操作が行われている
                let cdx = Double(cpoint.x) - dialX
                let cdy = Double(cpoint.y) - dialY
                let pdx = Double(ppoint.x) - dialX
                let pdy = Double(ppoint.y) - dialY
                dialRotate += atan2(pdx,pdy)-atan2(cdx,cdy)
            }
        }
    }
    var subbeatCount:Int = 0
    var subbeat:Int = 0
    func 音の種類を決める(pos:Double)->Int{
        if pos == 0 {
            subbeat = 0
            return 1
        }
        if isFirstHalf {return 0}
        switch subbeatCount{
        case 2:
            if subbeat == 0 && pos >= 0.5 {
                subbeat = 1
                return 2
            }
            break
        case 3:
            if subbeat == 0 && pos >= 0.333333 {
                subbeat = 1
                return 2
            }
            if subbeat == 1 && pos >= 0.666667 {
                subbeat = 2
                return 2
            }
            break
        default:
            break
        }
        return 0
    }
    func 錘(tempo:Int){
        //40-206
        let convTable:[Int] = [
            0,  2,  3,  5,  6,  8,  9,  11, 12, 14,
            15, 17, 19, 21, 23, 25, 27, 29, 32, 34,
            36, 38, 40, 42, 44, 46, 48, 50, 52, 54,
            56, 58, 60, 62, 64, 66, 68, 70, 72, 74,
            76, 78, 80, 82, 84, 86, 88, 90, 92, 94,
            96, 98, 100,102,104,106,108,110,112,114,
            116,118,120,122,124,126,128,130,132,134,
            136,138,140,142,144,145,147,150,152,154,
            156,158,160,162,164,166,168,170,172,174,
            176,178,180,182,184,186,188,190,192,194,
            196,198,200,202,203,206,208,210,212,214,
            216,219,222,224,227,229,232,234,237,239,
            241,243,245,247,249,251,253,255,257,259,
            261,263,265,267,269,271,274,276,278,280,
            282,284,286,288,290,292,294,296,298,300,
            302,304,306,308,310,312,314,316,318,320,
            322,324,326,328,330,332,334,336,99999]
        var tmp = tempo - 40
        if tmp < 0 { tmp = 0 }
        if tmp > 165 { tmp = 165 }
        
        base_w.position = CGPointMake(0.0, CGFloat(431.0 - Double(convTable[tmp])))
        
    }
    
    func 範囲(p:CGPoint,cx:Double,cy:Double,r:Double=0.0,dx:Double=0.0,dy:Double=0.0)->Bool{
        let xx = Double(p.x)
        let yy = Double(p.y)
        var ddx = r
        var ddy = r
        if dx > ddx {  ddx = dx }
        if dy > ddy {  ddy = dy }
        if(xx > cx - ddx)&&(xx < cx + ddx)&&(yy > cy - ddy)&&(yy < cy + ddy){
            return true
        }
        return false
    }

    var tempo:Double = 80.0
    private var prevPosition:Double = 0.0
    private var currentTime2:Double = 0.0
    private var isFirstHalf:Bool = false
    private var pPosition:Double = 0.0 //現在の位置情報を0.0-1.0の範囲で保持する。

    override func update(currentTime: CFTimeInterval) {
        currentTime2 = currentTime
        dialNum.text = String(Int(tempo))
        錘(Int(tempo))
        switch subbeatCount{
        case 2:
            b1ON.hidden = true
            b2ON.hidden = false
            b3ON.hidden = true
            break
        case 3:
            b1ON.hidden = true
            b2ON.hidden = true
            b3ON.hidden = false
            break
        default:
            b1ON.hidden = false
            b2ON.hidden = true
            b3ON.hidden = true
        }
        if gVoiceMode == 1{
            swON.hidden = false
        }else{
            swON.hidden = true
        }
        n0ON.hidden = true
        n2ON.hidden = true
        n3ON.hidden = true
        n4ON.hidden = true
        n5ON.hidden = true
        n6ON.hidden = true

        switch 拍数 {
        case 2:
            n2ON.hidden = false
            break
        case 3:
            n3ON.hidden = false
            break
        case 4:
            n4ON.hidden = false
            break
        case 5:
            n5ON.hidden = false
            break
        case 6:
            n6ON.hidden = false
            break
        default:
            n0ON.hidden = false
        }

        var 現在の角度:Double//現在の角度を計算するためのワーク
        if isMoving==false && isStarting==true{ //これから動き出す
            現在の拍数 = 0//小節の最初から
            lastClickTime = currentTime - (30.0/tempo) //半分動いてきたことにする
            isMoving = true //動いていることにする
            prevPosition = 0.500001
            isFirstHalf = true
        }
        //動作中
        if isMoving {//動作中の処理
            pPosition = (currentTime-lastClickTime)/(60.0/tempo) //0.0-1.0が範囲
            現在の角度 = (pPosition - 0.5)*1.3//角度を計算する（画面を見ながら適当に倍率を掛けてる）
            if(isGoingToRight) {//右行きならマイナスの数値になるように調整
                現在の角度 = 0.0 - 現在の角度
            }
            base_p.zRotation = CGFloat(現在の角度)//振り子を動かす
            //振り子の向きを調整する
            if(pPosition>=1.0){//拍位置にきたので逆向きに動かす
                if(isGoingToRight){
                    isGoingToRight=false
                }else{
                    isGoingToRight=true
                }
                lastClickTime = currentTime//逆向きに動き出した時間を保持
                prevPosition = -0.1
                pPosition = 0.0;
                現在の拍数+=1
                if 現在の拍数 > 拍数 { 現在の拍数 = 1 }
            }
            
            //音を出す位置かどうかを判断する。音の種類はnnの値によりきまる
            let 音の種類 = 音の種類を決める(pPosition)
            if 音の種類 != 0 {
                
                isFirstHalf = false
                    switch gVoiceMode {
                    case 1:
                        if 音の種類 == 1 {
                            if isSoundON {
                                switch 現在の拍数 {
                                case 1:
                                    runAction(voice1)
                                case 2:
                                    runAction(voice2)
                                case 3:
                                    runAction(voice3)
                                case 4:
                                    runAction(voice4)
                                case 5:
                                    runAction(voice5)
                                case 6:
                                    runAction(voice6)
                                default:
                                    runAction(voice1)
                                }
                            }
                        } else {
                            if isSoundON {runAction(click_s2)}
                        }
                    default:
                        if 音の種類 == 1 {
                            if(現在の拍数==1){
                                if isSoundON {runAction(click_s0)}
                            }else{
                                if isSoundON {runAction(click_s1)}
                            }
                        }else{
                            if isSoundON {runAction(click_s2)}
                        }
                    }

            }
            //振り子を止める
            if(!isStarting){
                if(pPosition<0.51){
                    if(pPosition>0.47){
                        isMoving = false
                        base_p.zRotation = 0.0
                    }
                }
            }
        }
        //ダイヤルが回された場合の処理
        if dialRotate != dialRotateOld {
            dial.zRotation = CGFloat(dialRotate)
            if (dialRotate - dialRotateOld) > -2.0 && (dialRotate - dialRotateOld) < 2.0{
                tempo += (dialRotate - dialRotateOld)*5
                if tempo < 20.0 {tempo = 20.0}
                if tempo > 200.0 {tempo = 200.0}
                
            }
        }
        dialRotateOld = dialRotate
        
        //次の呼び出しへの準備
        prevPosition = pPosition
    }
}
