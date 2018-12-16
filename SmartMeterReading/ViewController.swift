//
//  ViewController.swift
//  SmartMeterReading
//
//  Created by Prajakta Kulkarni on 09/12/2018.
//  Copyright © 2018 Prajakta Kulkarni. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var IPAdreessTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var readingLabel: UILabel!
    @IBOutlet weak var readingView: UIView!
    @IBOutlet weak var getReadingButton: UIButton!
    var readingArray = Array<Float>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func GetMeterReading(_ sender: Any) {
        getReadingButton.isEnabled = false
        let historyPeriod:Date = Date.init(timeIntervalSinceNow: -30)
        let urlString = String("http://\(IPAdreessTextField.text ?? " "):8123/api/history/period/\(historyPeriod)?filter_entity_id=sensor.gas_consumption")//?filter_entity_id=sensor.gas_consumption
        print(urlString)
        let rOriginal = urlString.range(of: " ")
        let newString = urlString.replacingCharacters(in: rOriginal!, with: "T")
        let newUrlString = newString.replacingOccurrences(of: " ", with: "", options: .literal, range:nil)
        let url = URL(string: newUrlString)
        print ("URL",url ?? " default")
        let urlRequest : NSMutableURLRequest = NSMutableURLRequest()
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("\(PasswordTextField.text ?? " ")", forHTTPHeaderField: "X-HA-Access")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.url = url
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let dataTask = session.dataTask(with: urlRequest as URLRequest) { (data, response, error) in
            if error != nil{
                print("\(String(describing: error))")
            }
            else {
                    do {
                        print("Response :",response!)
                        let responseData = try JSONSerialization.jsonObject(with: data!, options: []) as! [[[String:Any]]]
                        print("API Data:",responseData )
                        self.showReading(responseData: responseData);
                }catch{
                    print("couldn't convert json data")
                }
            }
        }
        dataTask.resume()
        
        Timer.scheduledTimer(withTimeInterval: 30, repeats: false) { (timer) in
            self.GetMeterReading(sender)
        }
        
        
    }
    
    func showReading(responseData:[[[String:Any]]]) ->Void {
        let gasConsumptionData:Dictionary = responseData[0][0]
        DispatchQueue.main.async {
            self.PasswordTextField.resignFirstResponder()
            self.IPAdreessTextField.resignFirstResponder()
            self.readingLabel.text = gasConsumptionData["state"] as? String
            self.readingArray.append((self.readingLabel.text! as NSString).floatValue)
            self.readingView.isHidden =  false
            self.blinkAnimation()
        }
        print("reading:",readingArray )
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        getReadingButton.isEnabled = true
    }
    func blinkAnimation() -> Void {
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
            
            self.readingLabel.alpha = 0.0
            
        }, completion: nil)
        UIView.animate(withDuration: 0.5, delay:0.5, options: .curveEaseOut, animations: {
            
            self.readingLabel.alpha = 1.0
            
        }, completion: nil)
    }
 
}

