//
//  idmsaclient.swift
//  CircleCI-Tools
//
//  Created by Adam on 13/08/2020.
//

import Foundation

class IDMSAClient {
    private var widgetKey: String?
    private var session: URLSession
    
    init() {
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.httpCookieAcceptPolicy = .always
        sessionConfiguration.httpShouldSetCookies = true
        sessionConfiguration.httpCookieStorage = .shared
        self.session = URLSession(configuration: sessionConfiguration)
    }
    
    func login(username: String, password: String, success: @escaping ((Bool, String?) -> Void)) {
        //self.getWidgetKey()
        
        print("Logging in to Apple...")
        
        let portal_url = URL(string: "https://idmsa.apple.com/appleauth/auth/signin")!
        var request = URLRequest(url: portal_url)
        
        let request_data: [String: Any] = [
            "accountName": username,
            "password": password,
            "rememberMe": true
        ]
        let request_data_json = try? JSONSerialization.data(withJSONObject: request_data)
        
        request.httpMethod = "POST"
        request.httpBody = request_data_json
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        // TODO: Grab widget key dynamically
        request.setValue("", forHTTPHeaderField: "X-Apple-Widget-Key")
        request.setValue("application/json, text/javascript", forHTTPHeaderField: "Accept")
        
        session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    success(false, error.localizedDescription)
                }
            }
            
            if let httpCode = response as? HTTPURLResponse,
                  httpCode.statusCode != 200 {
                DispatchQueue.main.async {
                    success(false, "Received a non-200 HTTP response!")
                }
            }
                        
            if let jsonResponse = try? JSONSerialization.jsonObject(with: data!, options: []) {
                if let response = jsonResponse as? [String: Any] {
                    if response["authType"] as? String == "sa" {
                        self.checkSession()
                        DispatchQueue.main.async {
                            print("Login successful!")
                            success(true, nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            success(false, "Something was wrong with the login")
                        }
                    }
                }
            }
        }.resume()
    }
    
    private func getWidgetKey() {
        let url = URL(string: "https://appstoreconnect.apple.com/olympus/v1/app/config?hostname=itunesconnect.apple.com")!
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Uh oh: \(error)")
                return
            }
        }
        task.resume()
    }
    
    private func checkSession() {
        let url = URL(string: "https://appstoreconnect.apple.com/olympus/v1/session")!
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Uh oh: \(error)")
                return
            }
            
            if let result = String(data: data!, encoding: .utf8) {
                //print(result)
            }
        }
        task.resume()
    }
}
