//
//  ViewController.swift
//  TinyServer
//
//  Created by Luigi Pizzolito on 7/11/2017.
//  Copyright © 2017 Luigi Pizzolito. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    
    @IBOutlet var PortField: NSTextField!
    @IBOutlet var RootField: NSTextField!
    @IBOutlet var RootInd: NSButton!
    @IBOutlet var LogField: NSTextView!
    @IBOutlet var RunStopButtons: NSButton!
    dynamic var isRunning = false
    var outputPipe:Pipe!
    var buildTask:Process!
    
    @IBAction func RunStopButton(_ sender: Any) {
        var rootPath:String = RootField.stringValue;
        var portNum:String = PortField.stringValue;
        guard let javaServer = Bundle.main.path(forResource: "WebServerLite",ofType:"jar") else {
            print("Unable to locate WebServerLite.jar")
            return
        }
        if RunStopButtons.title == "Stop" {
            //stop running
            buildTask.terminate();
            print("Stopping Web Server...");
            
        } else if RunStopButtons.title == "Run" {
            //start running!
            if PortField.stringValue == "" {PortField.stringValue = "80"; portNum = "80";}
            if RootField.stringValue == "" {RootField.stringValue = "/"; rootPath = "/";}
            LogField.string = ""
            self.RootTyped(sender: Any?.self);
            RunStopButtons.title = "Stop";
            PortField.isEnabled = false;
            RootField.isEnabled = false;
            RootInd.isEnabled = false;
            //debug
//            print("rootPath is \(rootPath)");
//            print("portNum is \(portNum)");
//            print("javaServer is at \(javaServer)");
            var arguments:[String] = []
            arguments.append(portNum)
            arguments.append(rootPath)
            arguments.append(javaServer)
                
            runScript(arguments)
                
            
            
            //LogField.textStorage?.replaceCharacters(in: NSMakeRange(0,(LogField.textStorage?.length)!), with: "Starting server on 127.0.0.1:"+portNum+" with root at "+rootPath);
        }
        if isRunning {isRunning = false} else if !isRunning {isRunning = true;}
    }
    
    func runScript(_ arguments:[String]) {
        isRunning = true
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        
        taskQueue.async {
            
            guard let path = Bundle.main.path(forResource: "RunServer",ofType:"command") else {
                print("Unable to locate RunServer.command")
                return
            }
            
            self.buildTask = Process()
            self.buildTask.launchPath = path
            self.buildTask.arguments = arguments
            
            self.buildTask.terminationHandler = {
                
                task in
                DispatchQueue.main.async(execute: {
                    self.isRunning = false
                    self.RunStopButtons.title = "Run";
                    self.PortField.isEnabled = true;
                    self.RootField.isEnabled = true;
                    self.RootInd.isEnabled = true;
                    //LogField.string = "Choose a root address and a port. Then press run to start the web server.";
                    print("Web Server Stopped");
                })
                
            }
            
            self.captureStandardOutputAndRouteToTextView(self.buildTask)
            
            //4.
            self.buildTask.launch()
            
            //5.
            self.buildTask.waitUntilExit()
            
        }
        
    }
    
    
    func captureStandardOutputAndRouteToTextView(_ task:Process) {
        
        //1.
        outputPipe = Pipe()
        task.standardOutput = outputPipe
        
        //2.
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        //3.
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading , queue: nil) {
            notification in
            
            //4.
            let output = self.outputPipe.fileHandleForReading.availableData
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
            
            //5.
            DispatchQueue.main.async(execute: {
                let previousOutput = self.LogField.string ?? ""
                let nextOutput = previousOutput + "\n" + outputString
                self.LogField.string = nextOutput
                
                let range = NSRange(location:nextOutput.characters.count,length:0)
                self.LogField.scrollRangeToVisible(range)
                
            })
            
            //6.
            self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            
            
        }
        
    }

    
    @IBAction func RootTyped(_ sender: Any) {
        //check root path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: RootField.stringValue) {
            //file exists
            RootInd.title = "...";
            RootField.textColor = NSColor(red: 0, green: 0, blue: 0, alpha: 255);
        } else {
            //file does not exist
            RootInd.title = "...";
            RootField.textColor = NSColor(red: 0.8, green: 0, blue: 0, alpha: 255);
        }
    }
    
    @IBAction func rootPanel(_ sender: Any) {
        if !isRunning {
            let openPanel = NSOpenPanel();
            openPanel.title = "Select a directory:"
            openPanel.message = "This will be the root directory for the web server."
            openPanel.prompt = "Select";
            openPanel.canCreateDirectories = true;
            openPanel.showsHiddenFiles = true;
            openPanel.showsResizeIndicator=true;
            openPanel.canChooseDirectories = true;
            openPanel.canChooseFiles = false;
            openPanel.allowsMultipleSelection = false;
            openPanel.isExtensionHidden = false;
            openPanel.treatsFilePackagesAsDirectories = true;
            openPanel.delegate = self as? NSOpenSavePanelDelegate;
            openPanel.begin { (result) -> Void in
                if(result == NSFileHandlingPanelOKButton){
                    let pth = openPanel.url!.path
                    self.RootField.stringValue = pth;
                    self.RootTyped(sender: Any?.self);
                }
            }
        }
    }
    
    

    
    
}

