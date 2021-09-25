//
//  UIImage+Extension.swift
//  RCVoiceRoomMessage
//
//  Created by shaoshuai on 2021/8/10.
//

import UIKit

extension UIImage {
    
    static func creatorImage() -> UIImage? {
        let bundle = Bundle(for: RCVRMView.self)
        guard let path = bundle.path(forResource: "creator", ofType: "png") else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
    
    static func managerImage() -> UIImage? {
        let bundle = Bundle(for: RCVRMView.self)
        guard let path = bundle.path(forResource: "manager", ofType: "png") else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
    
    static func audio1Image() -> UIImage? {
        let bundle = Bundle(for: RCVRMView.self)
        guard let path = bundle.path(forResource: "audio_icon_1", ofType: "png") else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
    
    static func audio2Image() -> UIImage? {
        let bundle = Bundle(for: RCVRMView.self)
        guard let path = bundle.path(forResource: "audio_icon_2", ofType: "png") else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
    
    static func audio3Image() -> UIImage? {
        let bundle = Bundle(for: RCVRMView.self)
        guard let path = bundle.path(forResource: "audio_icon_3", ofType: "png") else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
    
}
