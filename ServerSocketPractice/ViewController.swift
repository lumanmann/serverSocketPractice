//
//  ViewController.swift
//  ServerSocketPractice
//
//  Created by WY NG on 20/10/2018.
//  Copyright © 2018 lumanman. All rights reserved.
//

import UIKit
import  CocoaAsyncSocket


class ViewController: UIViewController {
    
    var severSocket : GCDAsyncSocket?
    var clientSocket : GCDAsyncSocket?
    
    var clientArray = [GCDAsyncSocket]()
    
    let hostIP = "192.168.1.21"
    let severPort : UInt16 = 9999
 
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. 建立Socket
        severSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        
        // 2. 建立監聽
        do {
            try severSocket?.accept(onPort: severPort)
        } catch  {
            print("error")
        }
        
    }
    
    @IBAction func sendClicked(_ sender: UIButton) {
        
        guard let inputText = inputTextField.text else {
            return
        }
        
        var currentext = messageTextView.text
        currentext = currentext ?? "" + "\nMe : \(inputText)"
        messageTextView.text = currentext
        let data = inputTextField.text?.data(using: String.Encoding.utf8)
        
        for client in clientArray {
            // 發送訊息
            client.write(data ?? Data(), withTimeout: -1, tag: 0)
        }
    }

}


extension ViewController: GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        print("收到新的連線")
        print(newSocket.connectedHost ?? "")
        
        clientArray.append(newSocket)
        //clientSocket = newSocket
        newSocket.readData(withTimeout: -1, tag: 0)
    }
    
    // 接收到資料
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print(sock.connectedHost as Any) //sock：連到的client
        
        let message = String(data: data, encoding: String.Encoding.utf8)
        var currentText = messageTextView.text!
  
        print(message as Any)
        currentText = currentText + "\nFrom : \(String(describing: sock.connectedHost)) : \(message!))"
        messageTextView.text = currentText

        // 繼續讀資料 （因爲它只會讀一次）
        sock.readData(withTimeout: -1, tag: 0)
    }
}
