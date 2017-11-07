//
//  ViewController.swift
//  TinyServer
//
//  Created by Luigi Pizzolito on 7/11/2017.
//  Copyright © 2017 Luigi Pizzolito. All rights reserved.
//

import Cocoa
import AppKit

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
    @IBOutlet var RunStopButton: NSButton!
    var isRunning:Bool = false;
    
    @IBAction func RunStopButton(_ sender: Any) {
        var rootPath:String = RootField.stringValue;
        var portNum:String = PortField.stringValue;
        guard let javaServer = Bundle.main.path(forResource: "WebServerLite",ofType:"jar") else {
            print("error javaServer");
            return
        }
        
        if isRunning {
            //stop running
            isRunning = false;
            RunStopButton.title = "Run";
            PortField.isEnabled = true;
            RootField.isEnabled = true;
            RootInd.isEnabled = true;
            LogField.textStorage?.replaceCharacters(in: NSMakeRange(0,(LogField.textStorage?.length)!), with: "Choose a root address and a port. Then press run to start the web server.");
            
        } else if !isRunning {
            //start running!
            isRunning = true;
            if PortField.stringValue == "" {PortField.stringValue = "80"; portNum = "80";}
            if RootField.stringValue == "" {RootField.stringValue = "/"; rootPath = "/";}
            self.RootTyped(sender: Any?.self);
            RunStopButton.title = "Stop";
            PortField.isEnabled = false;
            RootField.isEnabled = false;
            RootInd.isEnabled = false;
            //debug
            print("rootPath is \(rootPath)");
            print("portNum is \(portNum)");
            print("javaServer is at \(javaServer)");
            //run
            LogField.textStorage?.replaceCharacters(in: NSMakeRange(0,(LogField.textStorage?.length)!), with: "Starting server on 127.0.0.1:"+portNum+" with root at "+rootPath);
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

