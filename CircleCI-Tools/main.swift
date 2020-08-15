//
//  main.swift
//  CircleCI-Tools
//
//  Created by Adam on 13/08/2020.
//

import Foundation

// Check we are running as root
let id = Process()
id.executableURL = URL(fileURLWithPath: "/usr/bin/id")
id.arguments = ["-u"]
var pipe = Pipe()
id.standardOutput = pipe
do {
    try id.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    if let output = String(data: data, encoding: String.Encoding.utf8)?.dropLast() {
        if Int(output) != 0 {
            print("Not running as root!")
            print("Exiting...")
            exit(1)
        }
      }
} catch {
    
}

// TODO: Grab from user interactively
var username: String? = ""
var password: String?  = ""

if ProcessInfo.processInfo.environment["XCODE_INSTALL_USER"] != nil && username == nil {
    username = ProcessInfo.processInfo.environment["XCODE_INSTALL_USER"]!
}

if ProcessInfo.processInfo.environment["XCODE_INSTALL_PASSWORD"] != nil && password == nil {
    password = ProcessInfo.processInfo.environment["XCODE_INSTALL_PASSWORD"]!
}

if username == nil || password == nil {
    print("No Username and/or Password defined!")
}

// TODO: Grab from user interactively
var CLT_client = CLT(DownloadURL: nil, Version: nil)
CLT_client.downloadCLT()

RunLoop.main.run()
