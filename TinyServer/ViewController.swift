//
//  ViewController.swift
//  TinyServer
//
//  Created by Luigi Pizzolito on 7/11/2017.
//  Copyright © 2017 Luigi Pizzolito. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSWindowDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewDidAppear() {
        self.view.window?.delegate = self
    }
    
    func windowShouldClose(_ sender: Any) -> Bool {
        if RunStopButtons.title == "Stop" {buildTask.terminate()}
        self.showNotification(title: "Tiny Web Server Shutting Down", subtitle: "Your web server will be terminated", infotext: "Until the next time...", image: self.byeIcon)
        NSApplication.shared().terminate(self)
        return true
    }
    
    
    @IBOutlet var PortField: NSTextField!
    @IBOutlet var RootField: NSTextField!
    @IBOutlet var RootInd: NSButton!
    @IBOutlet var LogField: NSTextView!
    @IBOutlet var RunStopButtons: NSButton!
    dynamic var isRunning = false
    var crashFlag:Bool = false;
    var outputPipe:Pipe!
    var buildTask:Process!
    let appIcon:NSImage = NSWorkspace.shared().icon(forFile: Bundle.main.bundlePath)
    let crashIcon:NSImage = NSImage(contentsOfFile: Bundle.main.path(forResource: "iconCrash",ofType:"png")!)!
    let byeIcon:NSImage = NSImage(contentsOfFile: Bundle.main.path(forResource: "iconBye",ofType:"png")!)!
    let stopIcon:NSImage = NSImage(contentsOfFile: Bundle.main.path(forResource: "iconStop",ofType:"png")!)!
    let startIcon:NSImage = NSImage(contentsOfFile: Bundle.main.path(forResource: "iconStart",ofType:"png")!)!
    
    
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
            crashFlag = false;
            //print("Stopping Web Server...");
            
        } else if RunStopButtons.title == "Run" {
            //start running!
            if PortField.stringValue == "" {PortField.stringValue = "8888"; portNum = "8888";}
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
        }
        if isRunning {isRunning = false} else if !isRunning {isRunning = true;}
    }
    
    func runScript(_ arguments:[String]) {
        isRunning = true
        crashFlag = true;
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
                    if self.crashFlag {
                        //print("Web Server Crashed");
                        self.showNotification(title: "Tiny Web Server Crashed", subtitle: "Your web server has crashed...", infotext: self.RootField.stringValue, image: self.crashIcon)
                    } else if !self.crashFlag {
                        //print("Web Server Stopped");
                        self.showNotification(title: "Tiny Web Server Stopped", subtitle: "Your web server has stopped running...", infotext: self.RootField.stringValue, image: self.stopIcon)
                    }

                })
                
            }
            
            self.captureStandardOutputAndRouteToTextView(self.buildTask)
            
            //4.
            self.buildTask.launch()
            self.showNotification(title: "Tiny Web Server Started", subtitle: "Your web server has started running...", infotext: self.RootField.stringValue, image: self.startIcon)
            //5.
            self.buildTask.waitUntilExit()
            
        }
        
    }
    
    func showNotification(title:String, subtitle:String, infotext:String, image:NSImage) -> Void {
        let notification = NSUserNotification()
        notification.identifier = self.randomString(length: 8)
        notification.title = title
        notification.subtitle = subtitle
        notification.informativeText = infotext
        //notification.soundName = NSUserNotificationDefaultSoundName
        notification.contentImage = image
        // Manually display the notification
        let notificationCenter = NSUserNotificationCenter.default
        notificationCenter.deliver(notification)
    }
    func randomString(length:Int) -> String {
        let charSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var c = charSet.characters.map { String($0) }
        var s:String = ""
        for _ in (1...length) {
            s.append(c[Int(arc4random()) % c.count])
        }
        return s
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

    @IBAction func showHelp(_ sender: Any) {
        NSWorkspace.shared().open(NSURL(string: "http://www.jibble.org/jibblewebserver.php")! as URL)
    }
    
    @IBAction func savelog(_ sender: Any) {
        let savePanel = NSSavePanel();
        savePanel.title = "Select where to save the log:"
        savePanel.message = "The log is saved as a .log"
        savePanel.prompt = "Save Log";
        savePanel.canCreateDirectories = true;
        savePanel.showsHiddenFiles = true;
        savePanel.showsTagField = true;
        savePanel.tagNames = ["TinyServer"];
        savePanel.isExtensionHidden = false;
        savePanel.canSelectHiddenExtension = true;
        savePanel.treatsFilePackagesAsDirectories = true;
        savePanel.allowedFileTypes = ["log"];
        savePanel.allowsOtherFileTypes = false;
        savePanel.delegate = self as? NSOpenSavePanelDelegate;
        savePanel.begin { (result) -> Void in
            if(result == NSFileHandlingPanelOKButton){
                let lpth = savePanel.url!.path
                let lpath = NSURL(fileURLWithPath: lpth) as URL
                do {
                    let text = self.LogField.string;
                    try text?.write(to: lpath as URL, atomically: false, encoding: String.Encoding.utf8)
                } catch {
                    self.showNotification(title: "Tiny Web Server Error", subtitle: "Could not save your log", infotext: "Please try again...", image: self.crashIcon)
                }
                
            }
        }
    }
    
    @IBAction func quit(_ sender: Any) {
        if RunStopButtons.title == "Stop" {buildTask.terminate()}
        self.showNotification(title: "Tiny Web Server Shutting Down", subtitle: "Your web server will be terminated", infotext: "Until the next time...", image: self.byeIcon)
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func runMenu(_ sender: Any) {
        if RunStopButtons.title == "Run" {
            var rootPath:String = RootField.stringValue;
            var portNum:String = PortField.stringValue;
            guard let javaServer = Bundle.main.path(forResource: "WebServerLite",ofType:"jar") else {
                print("Unable to locate WebServerLite.jar")
                return
            }
            //start running!
            if PortField.stringValue == "" {PortField.stringValue = "8888"; portNum = "8888";}
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
            if isRunning {isRunning = false} else if !isRunning {isRunning = true;}
        }
    }
    
    @IBAction func stopMenu(_ sender: Any) {
        if RunStopButtons.title == "Stop" {
            //stop running
            buildTask.terminate();
            crashFlag = false;
            //print("Stopping Web Server...");
            if isRunning {isRunning = false} else if !isRunning {isRunning = true;}
        }
    }
    @IBAction func viewSource(_ sender: Any) {
        NSWorkspace.shared().open(NSURL(string: "http://github.com/Gangster45671/TinyServer")! as URL)
    }
    @IBAction func viewAbout(_ sender: Any) {
        NSWorkspace.shared().open(NSURL(string: "http://github.com/Gangster45671/TinyServer/blob/master/README.md")! as URL)
    }
    @IBAction func touchRun(_ sender: Any) {
        runMenu(sender: Any?.self)
    }
    @IBAction func touchStop(_ sender: Any) {
        stopMenu(sender: Any?.self)
    }
    @IBAction func touchOpen(_ sender: Any) {
        rootPanel(sender: Any?.self)
    }
    @IBAction func touchLog(_ sender: Any) {
        savelog(sender: Any?.self)
    }
    
}

