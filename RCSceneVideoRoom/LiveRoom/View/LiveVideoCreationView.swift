//
//  LiveVideoCreationView.swift
//  RCE
//
//  Created by 叶孤城 on 2021/9/3.
//

import UIKit
import PhotosUI
import Rswift
import Kingfisher

protocol CreateLiveVideoHeaderProtocol: AnyObject {
    func roomDidSelect(thumb image: UIImage)
    func roomDidEndEditing(name: String)
    func roomDidClick(type isPrivate: Bool)
}

class LiveVideoCreationView: UIView {
    weak var delegate: CreateLiveVideoHeaderProtocol?
    
    private lazy var editThumbButton: UIButton = {
        let instance = UIButton()
        instance.layer.cornerRadius = 12
        instance.clipsToBounds = true
        instance.imageView?.contentMode = .scaleAspectFill
        instance.addTarget(self, action: #selector(handleThumbDidClick), for: .touchUpInside)
        return instance
    }()
    private lazy var editIconImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = R.image.video_thumb_edit_icon()
        return instance
    }()
    private lazy var textField: UITextField = {
        let instance = UITextField()
        instance.backgroundColor = .clear
        instance.layer.borderWidth = 1.0
        instance.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        instance.layer.cornerRadius = 20
        instance.font = .systemFont(ofSize: 14)
        instance.returnKeyType = .done
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 40))
        instance.leftView = leftView
        instance.leftViewMode = .always
        instance.addTarget(self, action: #selector(handleTextEndEditing(_:)), for: .editingDidEndOnExit)
        instance.addTarget(self, action: #selector(handleTextFieldEditing(textField:)), for: .editingChanged)
        instance.attributedPlaceholder = NSAttributedString(string: "设置房间标题", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.6)])
        return instance
    }()
    private lazy var privateButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 14)
        instance.setTitle("私密", for: .normal)
        instance.setImage(R.image.video_type_unselected(), for: .normal)
        instance.addTarget(self, action: #selector(handlePrivateDidClick), for: .touchUpInside)
        instance.setInsets(forContentPadding: UIEdgeInsets.zero, imageTitlePadding: 10)
        return instance
    }()
    private lazy var publicButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 14)
        instance.setTitle("公开", for: .normal)
        instance.setImage(R.image.video_type_unselected(), for: .normal)
        instance.addTarget(self, action: #selector(handlePublicDidClick), for: .touchUpInside)
        instance.setInsets(forContentPadding: UIEdgeInsets.zero, imageTitlePadding: 10)
        return instance
    }()
    private lazy var stackView: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [privateButton, publicButton])
        instance.axis = .horizontal
        instance.alignment = .center
        instance.distribution = .equalSpacing
        instance.spacing = 23
        return instance
    }()
    
    private lazy var imagePicker: UIImagePickerController = {
        let instance = UIImagePickerController()
        instance.sourceType = .photoLibrary
        instance.delegate = self
        instance.allowsEditing = true
        return instance
    }()
    
    init(_ delegate: CreateLiveVideoHeaderProtocol) {
        self.delegate = delegate
        super.init(frame: .zero)
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildLayout() {
        backgroundColor = UIColor(hexString: "03062F").withAlphaComponent(0.2)
        addSubview(editThumbButton)
        addSubview(textField)
        addSubview(stackView)
        editThumbButton.addSubview(editIconImageView)
        
        editThumbButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 72.resize, height: 72.resize))
            make.bottom.equalToSuperview().inset(24.resize)
            make.left.equalToSuperview().offset(24.resize)
        }
        
        editIconImageView.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
        }
        
        textField.snp.makeConstraints { make in
            make.left.equalTo(editThumbButton.snp.right).offset(24.resize)
            make.right.equalToSuperview().inset(24.resize)
            make.top.equalTo(editThumbButton)
            make.height.equalTo(40)
        }
        
        stackView.snp.makeConstraints { make in
            make.bottom.equalTo(editThumbButton)
            make.left.equalTo(textField).offset(8)
        }
        
        /// 默认随机一直图标
        let imageName = roomThumbNames.randomElement() ?? "room_background_image1"
        if let image = UIImage(named: imageName) {
            editThumbButton.setBackgroundImage(image, for: .normal)
            delegate?.roomDidSelect(thumb: image)
        }
        
        /// 默认私密房间
        handlePrivateDidClick()
    }
    
    @objc private func handleTextEndEditing(_ textField: UITextField) {
        endEditing(true)
        delegate?.roomDidEndEditing(name: textField.text ?? "")
    }
    
    @objc private func handleTextFieldEditing(textField: UITextField) {
        guard let text = textField.text else {  return }
        guard textField.markedTextRange == nil else { return }
        if text.count > 10 {
            let startIndex = text.startIndex
            let endIndex = text.index(startIndex, offsetBy: 10)
            textField.text = String(text[startIndex..<endIndex])
        }
        delegate?.roomDidEndEditing(name: textField.text ?? "")
    }
    
    @objc func handlePrivateDidClick() {
        textField.resignFirstResponder()
        privateButton.setImage(R.image.video_type_selected(), for: .normal)
        publicButton.setImage(R.image.video_type_unselected(), for: .normal)
        delegate?.roomDidClick(type: true)
    }
    
    @objc func handlePublicDidClick() {
        textField.resignFirstResponder()
        privateButton.setImage(R.image.video_type_unselected(), for: .normal)
        publicButton.setImage(R.image.video_type_selected(), for: .normal)
        delegate?.roomDidClick(type: false)
    }
    
    @objc func handleThumbDidClick() {
        controller?.present(imagePicker, animated: true)
    }
}

extension LiveVideoCreationView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = decodeImage(info) else {
            return
        }
        delegate?.roomDidSelect(thumb: image)
        editThumbButton.setBackgroundImage(image, for: .normal)
    }
    
    func decodeImage(_ info: [UIImagePickerController.InfoKey : Any]) -> UIImage? {
        if let image = info[.editedImage] as? UIImage {
            return image
        }
        guard
            let refUrl = info[.referenceURL] as? URL,
            let asset = PHAsset.fetchAssets(withALAssetURLs: [refUrl], options: nil).firstObject
        else {
            return nil
        }
        
        if !refUrl.absoluteString.contains("GIF") {
            return nil
        }
        
        var image: UIImage?
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        let semaphore = DispatchSemaphore(value: 0)
        PHImageManager.default().requestImageData(for: asset, options: options) { data, path, orientation, info in
            if let data = data, let imageSource = CGImageSourceCreateWithData(data as CFData, nil) {
                let imageCount = CGImageSourceGetCount(imageSource)
                if imageCount > 0, let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) {
                    image = UIImage(cgImage: cgImage).kf.resize(to: CGSize(width: 72, height: 72))
                }
            }
            semaphore.signal()
        }
        let result = semaphore.wait(timeout: DispatchTime.now() + 8)
        
        switch result {
        case .success: return image
        case .timedOut: return nil
        }
    }
}
