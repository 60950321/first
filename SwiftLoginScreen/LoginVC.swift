//
//  ViewController.swift
//  First Meter
//
//  Created by Pirashanth Pulendran on 13/10/2016.
//  Copyright © 2016 Contrasoft. All rights reserved.
//


import UIKit

class LoginVC: UIViewController,UITextFieldDelegate {
    
    
    @IBOutlet var txtUsername : UITextField!
    @IBOutlet var txtPassword : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // #pragma mark - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func signinTapped(_ sender : UIButton) {
        let username:NSString = txtUsername.text! as NSString
        let password:NSString = txtPassword.text! as NSString
        
        if ( username.isEqual(to: "") || password.isEqual(to: "") ) {
            
            let alert = UIAlertController(title: "Fejl!", message:"Indtast venligst adgangskode", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
            self.present(alert, animated: true){}
        
        } else {
            
            do {
            let post:NSString = "username=\(username)&password=\(password)" as NSString
            
            NSLog("PostData: %@",post);
            
            let url:URL = URL(string:"https://drivepanel.dk/jsonlogin2.php")!
            
            let postData:Data = post.data(using: String.Encoding.ascii.rawValue)!
            
            let postLength:NSString = String( postData.count ) as NSString
            
            let request:NSMutableURLRequest = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = postData
            request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            
            var reponseError: NSError?
            var response: URLResponse?
            
            var urlData: Data?
            do {
                urlData = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning:&response)
            } catch let error as NSError {
                reponseError = error
                urlData = nil
            }
            
            if ( urlData != nil ) {
                let res = response as! HTTPURLResponse!;
                
                //pelle NSLog("Response code: %ld", res?.statusCode);
                
                if ((res?.statusCode)! >= 200 && (res?.statusCode)! < 300)
                {
                    let responseData:NSString  = NSString(data:urlData!, encoding:String.Encoding.utf8.rawValue)!
                    
                    NSLog("Response ==> %@", responseData);
                    
                    //var error: NSError?
                    
                    let jsonData:NSDictionary = try JSONSerialization.jsonObject(with: urlData!, options:JSONSerialization.ReadingOptions.mutableContainers ) as! NSDictionary
                    
                    
                    let success:NSInteger = jsonData.value(forKey: "success") as! NSInteger
                    
                    //[jsonData[@"success"] integerValue];
                    
                    NSLog("Success: %ld", success);
                    
                    if(success == 1)
                    {
                        NSLog("Login SUCCESS");
                        
                        let prefs:UserDefaults = UserDefaults.standard
                        prefs.set(username, forKey: "USERNAME")
                        prefs.set(1, forKey: "ISLOGGEDIN")
                        prefs.synchronize()
                        
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        var error_msg:NSString
                        
                        if jsonData["error_message"] as? NSString != nil {
                            error_msg = jsonData["error_message"] as! NSString
                        } else {
                            error_msg = "Unknown Error"
                        }
                       
                        
                        let alert = UIAlertController(title: "Fejl!", message:error_msg as String, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                        self.present(alert, animated: true){}
                  
                    }
                    
                } else {
                    
                    let alert = UIAlertController(title: "Fejl!", message:"login fejl" as String, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                    self.present(alert, animated: true){}
                }
            } else {
                
                
                let alert = UIAlertController(title: "Fejl!", message:"Server fejl" as String, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                self.present(alert, animated: true){}

                
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Sign in Failed!"
                alertView.message = "Connection Failure"
                if let error = reponseError {
                    alertView.message = (error.localizedDescription)
                }
                alertView.delegate = self
                alertView.addButton(withTitle: "OK")
                alertView.show()
            }
            } catch {
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Sign in Failed!"
                alertView.message = "Server Error"
                alertView.delegate = self
                alertView.addButton(withTitle: "OK")
                alertView.show()
            }
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
}
