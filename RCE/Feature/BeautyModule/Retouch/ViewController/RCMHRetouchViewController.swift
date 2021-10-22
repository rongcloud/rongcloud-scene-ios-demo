//
//  RCMHRetouchViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/2.
//

import UIKit

class RCMHRetouchViewController: UIViewController {
    
    private lazy var containerView = UIView()
    private var retouchView: MHBeautyAssembleView = {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 264)
        return MHBeautyAssembleView(frame: frame)
    }()
    
    private let manager: MHBeautyManager
    init(_ manager: MHBeautyManager) {
        self.manager = manager
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .clear
        enableClickingDismiss()
        containerView.backgroundColor = UIColor(byteRed: 3, green: 6, blue: 47)
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-264)
        }
        containerView.addSubview(retouchView)
        retouchView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        retouchView.delegate = self
    }
    
}

extension RCMHRetouchViewController: MHBeautyAssembleViewDelegate {
    func handleBeauty(withType type: Int, level beautyLevel: CGFloat) {
        debugPrint("handleBeauty: \(type) level: \(beautyLevel)")
        guard let type = MHBeautyType(rawValue: type) else { return }
        switch type {
        case .original:
            manager.setRuddiness(0)
            manager.setSkinWhiting(0)
            manager.setBuffing(0)
        case .mopi:
            manager.setBuffing(beautyLevel)
        case .white:
            manager.setSkinWhiting(beautyLevel)
        case .ruddiess:
            manager.setRuddiness(beautyLevel)
        case .brightness:
            manager.setBrightnessLift(Int32(beautyLevel))
        default: ()
        }
    }
    
    func handleFaceBeauty(withType type: Int, sliderValue value: Int) {
        debugPrint("handleFaceBeauty: \(type) level: \(value)")
        manager.isUseFaceBeauty = true
        guard let type = MHBeautyFaceType(rawValue: type) else {
            return
        }
        switch type {
        case .original:
            manager.isUseFaceBeauty = false
            manager.setFaceLift(0)
            manager.setBigEye(0)
            manager.setMouthLift(0)
            manager.setNoseLift(0)
            manager.setChinLift(0)
            manager.setForeheadLift(0)
            manager.setEyeBrownLift(0)
            manager.setEyeAngleLift(0)
            manager.setEyeAlaeLift(0)
            manager.setShaveFaceLift(0)
            manager.setEyeDistanceLift(0)
        case .thinFace:
            manager.setFaceLift(Int32(value))
        case .bigEyes:
            manager.setBigEye(Int32(value))
        case .mouth:
            manager.setMouthLift(Int32(value))
        case .nose:
            manager.setNoseLift(Int32(value))
        case .chin:
            manager.setChinLift(Int32(value))
        case .forehead:
            manager.setForeheadLift(Int32(value))
        case .eyebrow:
            manager.setEyeBrownLift(Int32(value))
        case .canthus:
            manager.setEyeAngleLift(Int32(value))
        case .eyeAlae:
            manager.setEyeAlaeLift(Int32(value))
        case .eyeDistance:
            manager.setEyeDistanceLift(Int32(value))
        case .shaveFace:
            manager.setShaveFaceLift(Int32(value))
        case .longNose:
            manager.setLengthenNoseLift(Int32(value))
        default: ()
        }
    }
    
    func handleQuickBeautyValue(_ model: MHBeautiesModel) {
        debugPrint("handleQuickBeautyValue: \(model)")
        manager.isUseOneKey = model.type > 0
        manager.setFaceLift(Int32(model.face_defaultValue) ?? 0)//37
        manager.setBigEye(Int32(model.bigEye_defaultValue) ?? 0)//28
        manager.setMouthLift(Int32(model.mouth_defaultValue) ?? 0)//58
        manager.setNoseLift(Int32(model.nose_defaultValue) ?? 0)//0
        manager.setChinLift(Int32(model.chin_defaultValue) ?? 0)//27
        manager.setForeheadLift(Int32(model.forehead_defaultValue) ?? 0)//80
        manager.setEyeBrownLift(Int32(model.eyeBrown_defaultValue) ?? 0)//0
        manager.setEyeAngleLift(Int32(model.eyeAngle_defaultValue) ?? 0)//55
        manager.setEyeAlaeLift(Int32(model.eyeAlae_defaultValue) ?? 0)//77
        manager.setShaveFaceLift(Int32(model.shaveFace_defaultValue) ?? 0)//0
        manager.setEyeDistanceLift(Int32(model.eyeDistance_defaultValue) ?? 0)//0
        manager.setRuddiness(model.ruddinessValue.cgfloatValue / 9)//5
        manager.setSkinWhiting(model.whiteValue.cgfloatValue / 9)//2/9
        manager.setBuffing(model.buffingValue.cgfloatValue / 9)//6/9
        manager.setLengthenNoseLift(Int32(model.longnose_defaultValue) ?? 0)//20
    }
    
    func handleQuickBeauty(withSliderValue value: Int, quickBeautyModel model: MHBeautiesModel) {
        debugPrint("handleQuickBeauty: \(value) level: \(model)")
        let value = Int32(value)
        if value >= model.bigEye_minValue.intValue && value <= model.bigEye_maxValue.intValue {
            manager.setBigEye(value)
        }
        if value >= model.face_minValue.intValue && value <= model.face_maxValue.intValue {
            manager.setFaceLift(value)
        }
        if value >= model.mouth_minValue.intValue && value <= model.mouth_maxValue.intValue {
            manager.setMouthLift(value)
        }
        if value >= model.shaveFace_minValue.intValue && value <= model.shaveFace_maxValue.intValue {
            manager.setShaveFaceLift(value)
        }
        if value >= model.eyeAlae_minValue.intValue && value <= model.eyeAlae_maxValue.intValue {
            manager.setEyeAlaeLift(value)
        }
        if value >= model.eyeAngle_minValue.intValue && value <= model.eyeAngle_maxValue.intValue {
            manager.setEyeAngleLift(value)
        }
        if value >= model.eyeBrown_minValue.intValue && value <= model.eyeBrown_maxValue.intValue {
            manager.setEyeBrownLift(value)
        }
        if value >= model.forehead_minValue.intValue && value <= model.forehead_maxValue.intValue {
            manager.setForeheadLift(value)
        }
        if value >= model.chin_minValue.intValue && value <= model.chin_maxValue.intValue {
            manager.setChinLift(value)
        }
        if value >= model.nose_minValue.intValue && value <= model.nose_maxValue.intValue {
            manager.setNoseLift(value)
        }
        if value >= model.eyeDistance_minValue.intValue && value <= model.eyeDistance_maxValue.intValue {
            manager.setEyeDistanceLift(value)
        }
    }
    
    func handleFiltersEffect(withType filter: Int, withFilterName filterName: String) {
        debugPrint("handleFiltersEffect: \(filter) level: \(filterName)")
        let model = MHFilterModel.unzipFiltersFile(filterName)
        manager.setFilterType(filter, newFilterInfo: [
            "kUniformList": model.uniformList,
            "kUniformData": model.uniformData,
            "kUnzipDesPath": model.unzipDesPath,
            "kName": model.name,
            "kFragmentShader": model.fragmentShader,
        ])
    }
}
