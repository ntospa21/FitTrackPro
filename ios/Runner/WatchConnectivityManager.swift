//
//  WatchConnectivityManager.swift
//  Runner
//
//  Created by user on 24/12/25.
//

import Foundation
import WatchConnectivity
import Flutter

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    private var wcSession: WCSession?
    private var methodChannel: FlutterMethodChannel?
    
    override init() {
        super.init()
        setupWatchConnectivity()
    }
    
    func setupMethodChannel(binaryMessenger: FlutterBinaryMessenger) {
        methodChannel = FlutterMethodChannel(name: "com.fittrackpro/watch", binaryMessenger: binaryMessenger)
        
        methodChannel?.setMethodCallHandler { [weak self] call, result in
            switch call.method {
            case "startWorkout":
                self?.sendCommandToWatch(command: "startWorkout")
                result(nil)
            case "stopWorkout":
                self?.sendCommandToWatch(command: "stopWorkout")
                result(nil)
            case "isWatchConnected":
                let isReachable = self?.wcSession?.isReachable ?? false
                let isPaired = self?.wcSession?.isPaired ?? false
                print("Watch isPaired: \(isPaired), isReachable: \(isReachable)")
                result(isReachable)
            case "refreshConnection":
                self?.refreshConnection()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
            print("WCSession setup initiated")
        } else {
            print("WCSession is not supported on this device")
        }
    }
    
    func refreshConnection() {
        if let session = wcSession {
            print("Refreshing connection - isPaired: \(session.isPaired), isReachable: \(session.isReachable)")
            sendConnectionStatusToFlutter()
        }
    }
    
    func sendCommandToWatch(command: String) {
        guard let wcSession = wcSession else {
            print("WCSession is nil")
            return
        }
        
        guard wcSession.isReachable else {
            print("Watch is not reachable")
            return
        }
        
        wcSession.sendMessage(["command": command], replyHandler: nil) { error in
            print("Error sending command to watch: \(error.localizedDescription)")
        }
    }
    
    private func sendDataToFlutter(_ data: [String: Any]) {
        DispatchQueue.main.async {
            self.methodChannel?.invokeMethod("onWatchData", arguments: data)
        }
    }
    
    private func sendConnectionStatusToFlutter() {
        DispatchQueue.main.async {
            let isConnected = self.wcSession?.isReachable ?? false
            self.methodChannel?.invokeMethod("onWatchConnectionChanged", arguments: isConnected)
        }
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                print("WCSession activation failed: \(error.localizedDescription)")
            } else {
                print("WCSession activated with state: \(activationState.rawValue)")
                print("isPaired: \(session.isPaired), isReachable: \(session.isReachable)")
                self.sendConnectionStatusToFlutter()
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("WCSession deactivated")
        wcSession?.activate()
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("Watch reachability changed: \(session.isReachable)")
        sendConnectionStatusToFlutter()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Received message from watch: \(message)")
        DispatchQueue.main.async {
            if let type = message["type"] as? String {
                switch type {
                case "liveData", "workoutComplete":
                    self.sendDataToFlutter(message)
                case "watchReady":
                    self.sendConnectionStatusToFlutter()
                default:
                    break
                }
            }
        }
    }
}