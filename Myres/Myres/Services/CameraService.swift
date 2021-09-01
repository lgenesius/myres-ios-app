//
//  CameraService.swift
//  Myres
//
//  Created by Luis Genesius on 01/09/21.
//

import AVFoundation

enum CameraAuthorizationStatus {
    case granted
    case notRequested
    case unauthorized
}

class CameraService {
    static func requestCameraAuthorization(completionHandler: @escaping (CameraAuthorizationStatus) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                guard granted else {
                    completionHandler(.unauthorized)
                    return
                }
                completionHandler(.granted)
            }
        }
    }
    
    static func getCameraAuthorizationStatus() -> CameraAuthorizationStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
            case .authorized:
                return .granted
            case .notDetermined:
                return .notRequested
            default:
                return .unauthorized
        }
    }
}
