//
//  ViewController.swift
//  FlashBack
//
//  Created by Vishnu V Ram on 3/20/18.
//  Copyright © 2018 Shannthini. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class ViewController: UIViewController, AVAudioRecorderDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var recordingSession:AVAudioSession!
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    
    //login
    var isAuthenticated = false
    var didReturnFromBackground = false
    
    var numberOfRecords:Int = 0
    var settings = [String : Int]()

    @IBOutlet weak var startStoplabel: UIButton!
    @IBAction func record(_ sender: Any) {
        
        startRecordingAudio()
    }
    @IBOutlet weak var homeTableView: UITableView!
    
    @IBAction func viewSavedRecording(_ sender: Any) {
        performSegue(withIdentifier: "listTable", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? RecordDisplayTableViewController {
            //destination.numberOfRecordsToBeDisplayed = 10
            destination.numberOfRecordsToBeDisplayed = numberOfRecords
            destination.pathDir = getDirectory()
        }
    }
    
    //Function to start recording
    
    func startRecordingAudio() {
       
        //check if a recording session is in process
        if audioRecorder == nil
        {
            numberOfRecords += 1
            let filename = getDirectory().appendingPathComponent("\(numberOfRecords).m4a")
            
            // Audio Settings
            settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            //Start audio recording
            do {
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                
                startStoplabel.setTitle("Stop", for: .normal)
            } catch {
                finishRecording(success: false)
            }
        }
        else
        {
            finishRecording(success: true)
        }
        
    }
    @IBAction func logoutAction(_ sender: Any) {
        isAuthenticated = false
        performSegue(withIdentifier: "loginView", sender: self)
    }
    
   // Function that will stop recording
    
    func finishRecording(success:Bool) {
        //Stopping the recording session in process
        audioRecorder.stop()
        audioRecorder = nil
        
        UserDefaults.standard.set(numberOfRecords , forKey: "lastRecordNumber")
        homeTableView.reloadData()
        
        if success {
            startStoplabel.setTitle("Start", for: .normal)
        }
        else {
            displayAlert(title: "Oops", message: "Recording failed")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Starting of a session
        startStoplabel.layer.cornerRadius = 40.0
        recordingSession = AVAudioSession.sharedInstance()
        if let number:Int = UserDefaults.standard.object(forKey: "lastRecordNumber") as? Int {
            numberOfRecords = number
        }
        
        
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission {
                print("Thank you for the permission")
            }
            else {
                print("Permission not given")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        showLoginView()
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        isAuthenticated = true
        view.alpha = 1.0
    }
    func showLoginView() {
        if !isAuthenticated {
            performSegue(withIdentifier: "loginView", sender: self)
        }
    }
    @objc func appWillResignActive(_ notification : Notification) {
        view.alpha = 0
        isAuthenticated = false
        didReturnFromBackground = true
    }
    @objc func appDidBecomeActive(_ notification : Notification) {
        if didReturnFromBackground {
            showLoginView()
            view.alpha = 1
        }
    }
    
    
   // function to get the path to the Url to save the audio recording
    func getDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    
    //function to display an alert
    
    func displayAlert (title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //Setting up the table view for the home page
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRecords
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath)
        cell.textLabel?.text = String (indexPath.row + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let path = getDirectory().appendingPathComponent("\(indexPath.row + 1).m4a")
        do
        {
            audioPlayer = try AVAudioPlayer (contentsOf: path)
            audioPlayer.play()
        
        }
        catch
        {
            print("Playback error")
        }
        
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func fileManager(_ fileManager: FileManager,
                              shouldRemoveItemAt URL: URL) -> Bool{
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            print("Deleted")
            
            let path = getDirectory().appendingPathComponent("\(indexPath.row + 1).m4a")
            let fileManager = FileManager.default
            do {
            try fileManager.removeItem(at: path)
            }
            catch {
                print("Could not clear record")
            }
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            
        }
    }
}

