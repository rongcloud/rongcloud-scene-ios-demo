//
//  MHBeautyManager+Extension.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/18.
//

import Foundation

extension MHBeautyManager {
    func setupDefault() {
        isUseOneKey = true
        setFaceLift(37)
        setBigEye(28)
        setMouthLift(58)
        setNoseLift(0)
        setChinLift(27)
        setForeheadLift(80)
        setEyeBrownLift(0)
        setEyeAngleLift(55)
        setEyeAlaeLift(77)
        setShaveFaceLift(0)
        setEyeDistanceLift(0)
        setRuddiness(5.0 / 9)
        setSkinWhiting(2.0 / 9)
        setBuffing(6.0 / 9)
        setLengthenNoseLift(20)
    }
}
