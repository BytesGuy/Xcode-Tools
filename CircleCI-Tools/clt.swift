//
//  clt.swift
//  CircleCI-Tools
//
//  Created by Adam on 14/08/2020.
//

import Foundation

class CLT: NSObject, ObservableObject {
    private var idmsa: IDMSAClient?
    private var DownloadURL: String?
    private var Version: String?
    
    lazy var session: URLSession = {
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.httpCookieAcceptPolicy = .always
        sessionConfiguration.httpShouldSetCookies = true
        sessionConfiguration.httpCookieStorage = .shared
        return URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
    }()
    
    init(DownloadURL: String?, Version: String?) {
        self.idmsa = IDMSAClient()
        self.DownloadURL = DownloadURL
        self.Version = Version
    }
    
    func downloadCLT() {
        print("Downloading Command Line Tools Installer...")
        idmsa!.login(username: username!, password: password!) { (success, error) in
            // TODO: Add this as an argument
            let url = URL(string: "https://developer.apple.com/devcenter/download.action?path=/Developer_Tools/Command_Line_Tools_for_Xcode_12_beta_4/Command_Line_Tools_for_Xcode_12_beta_4.dmg")!
            
            self.session.downloadTask(with: url).resume()
        }
    }
    
    func installCLT() {
        // TODO: Tidy up this mess if possible
        print("Installing Command Line Tools...")
        let taskMount = Process()
        taskMount.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
        taskMount.arguments = ["attach", "-noverify", "/tmp/CLT.dmg"]
        
        let taskInstall = Process()
        taskInstall.executableURL = URL(fileURLWithPath: "/bin/bash")
        taskInstall.arguments = ["-c", "/usr/sbin/installer -verbose -pkg /Volumes/Command*/*.pkg -target /"]
        
        taskMount.terminationHandler = { (process) in
            print("Mounting Complete!")
            taskInstall.terminationHandler = { (process) in
                print("Install Complete!")
                self.cleanUp()
            }
            do {
                print("Running Install...")
                try taskInstall.run()
            } catch {
                print(error.localizedDescription)
                return
            }
        }
        
        do {
            print("Mounting DMG...")
            try taskMount.run()
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    
    func listCLT() {
        // TODO
    }
    
    func cleanUp() {
        print("Cleaning up...")
        let taskUmount = Process()
        taskUmount.executableURL = URL(fileURLWithPath: "/bin/bash")
        taskUmount.arguments = ["-c", "/sbin/umount /Volumes/Command*"]
        
        taskUmount.terminationHandler = { (process) in
            do {
                try FileManager.default.removeItem(at: URL(string: "file:///tmp/CLT.dmg")!)
                print("Cleanup complete!")
            } catch {
                print(error.localizedDescription)
                return
            }
        }
        
        do {
            try taskUmount.run()
        } catch {
            print(error.localizedDescription)
            return
        }
    }
}

extension CLT: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
          print(error.localizedDescription)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        let dest = "file:///tmp/CLT.dmg"
        do {
            if FileManager.default.fileExists(atPath: "/tmp/CLT.dmg") {
                try FileManager.default.removeItem(at: URL(string: dest)!)
            }
            try FileManager.default.copyItem(at: location, to: URL(string: dest)!)
        } catch {
            print(error)
        }
        
        print("Download Complete!")
        installCLT()
    }
}
