//
//  ViewController.swift
//  SER
//
//  Created by Dongkyu Lee on 2017. 6. 8..
//  Copyright © 2017년 Dongkyu Lee. All rights reserved.
//

import UIKit
import AVFoundation
//import Alamofire

class ViewController: UIViewController,AVAudioPlayerDelegate,AVAudioRecorderDelegate {
    
    
    @IBOutlet weak var helpLabel: UILabel!
    @IBOutlet weak var serButton: UIButton!
    @IBOutlet weak var filelistButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    public static let shared = ViewController()
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var prob : [Double]!
    var date = Date()
    let formatter = DateFormatter()
    var result : String = ""
    // var flag = 0
    @IBOutlet weak var back: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // d Do any additional setup after loading the view, typically from a nib.
        formatter.dateFormat = "yyyy-MM-dd.HH.mm.ss"
        self.recordButton.layer.cornerRadius = 10
        self.playButton.layer.cornerRadius = 10
        self.filelistButton.layer.cornerRadius = 10
        self.serButton.layer.cornerRadius = 10
        self.helpLabel.layer.cornerRadius = 125
        recordingSession = AVAudioSession.sharedInstance()
        try! recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! recordingSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in          // 마이크 승인여부
                DispatchQueue.main.async {
                    if allowed {    // 허용되어있으면 loadUI실행
                        self.loadRecordingUI()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func play(_ sender:UIButton){
        if ViewController.shared.result != ""{
            if sender.titleLabel?.text == "재생"{
                recordButton.isEnabled = false
                sender.setTitle("중단", for: .normal)
                preparePlayer()
                audioPlayer.play()
            }
            else{
                audioPlayer.stop()
                self.audioPlayerDidFinishPlaying(audioPlayer, successfully: true)
            }
        }
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.isEnabled = true
        playButton.setTitle("재생", for: .normal)
    }
    func preparePlayer(){   //재생할 파일의 url과 볼륨등을 설정할 수 있음
        let audioFilename = getDocumentsDirectory().appendingPathComponent(ViewController.shared.result)
        
        do{audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)}
        catch{
            print("prepare playing failed")
        }
        
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
        
        audioPlayer.volume = 1.0
    }
    
    
    func startRecording() {
        ViewController.shared.result = formatter.string(from: date) + ".wav"
        print(ViewController.shared.result)
        let audioFilename = getDocumentsDirectory().appendingPathComponent(ViewController.shared.result)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            recordButton.setTitle("중단", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(ViewController.shared.result)
        audioRecorder.stop()
        audioRecorder = nil
        print(audioFilename)
        
        if success {
            recordButton.setTitle("녹음", for: .normal)
        } else {
            recordButton.setTitle("녹음", for: .normal)
            // recording failed :(
        }
    }
    func recordTapped() {
        if audioRecorder == nil {
            date = Date()
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func loadRecordingUI() {
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        view.addSubview(recordButton)
    }
    @IBAction func ser(_ sender:UIButton){
        if ViewController.shared.result != ""{
            serButton.setTitle("...", for: .normal)
            self.upload()
        }
    }
    func upload() {
        
        // get the date time String from the date object
        /*var audioFilename = getDocumentsDirectory().appendingPathComponent(ViewController.shared.result)
        Alamofire.request("http://163.239.169.54:5005/uploads").responseString { response in
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            if ((response.response!.statusCode) >= 200 && (response.response!.statusCode) < 300){
                print("Success")
            }
            
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
        }
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(audioFilename, withName: "file")
        },
            to: "http://163.239.169.54:5005/uploads",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        //print(response["Result"])
                        //print(response.result)
                        let data = response.result.value
                        let jsondata = data as! NSDictionary
                        //print(jsondata)
                        //self.resultLabel.text = "(\(jsondata["classification"] as! Int))\(self.answer[jsondata["classification"] as! Int])"
                        // print(resultLabel.text)
                        //print(jsondata["classification"]!)
                        // print(jsondata["classification"] as! Int)
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let serViewController = storyBoard.instantiateViewController(withIdentifier: "serViewController") as! SerViewController
                        self.present(serViewController, animated: true, completion: nil)
                        /* [Happy , Sad, Angry, Frustrated, Excited, Neutral] */
                        
                        // self.resultLabel.text = "(\(jsondata["classification"] as! Int))\(self.answer[jsondata["classification"] as! Int])"
                        
                        //UIView.transition(with: self.back, duration: 5, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {self.back.image = UIImage(named: "l\(jsondata["classification"] as! Int)")}, completion: nil)
                        //self.back.image = nil
                        /*UIView.transition(with: self.back, duration: 3, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {self.back.backgroundColor = self.UIColorFromHex(rgbValue: UInt32(self.corlor_set[jsondata["classification"] as! Int]))})
                         */
                        //self.back.image=UIImage(named: "\(jsondata["classification"] as! Int)")
                        
                        //self.prob = jsondata["prob"] as! [Double]
                        //debugPrint(self.prob)
                        /*
                         self.setChart(dataPoints: self.category, values: self.prob)
                         
                         self.barChartView.animate(xAxisDuration: 0.0, yAxisDuration: 3.0)
                         */
                        
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
        )*/
        
        
        
        
        serButton.setTitle("감정 인식", for: .normal)
    }
    
    
}

