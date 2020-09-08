//
//  ViewController.swift
//  ColorOptionsExplore
//
//  Created by Jo Hsu on 2020/9/2.
//  Copyright © 2020 Jo Hsu. All rights reserved.
//

import UIKit
import SnapKit
import ColorPicker

class PixelPickerControl: UIControl {

    let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "sample"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    lazy var selectedColor: UIColor = {
        let image = imageView.image
        let resizedImage = image?.resize(to: CGSize(width: 300, height: 300), mode: .scaleAspectFill)
        let color = resizedImage?.getPixelColor(at: CGPoint(x: 150, y: 150))
        return color ?? .white
    }()

    private let cursor = UIImageView(image: UIImage(named: "img_oval"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        updateSelectedColor(at: location)
        updateCursorPosition(at: location)
        super.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        updateSelectedColor(at: location)
        updateCursorPosition(at: location)
        super.touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        updateSelectedColor(at: location)
        updateCursorPosition(at: location)
        super.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        updateSelectedColor(at: location)
        updateCursorPosition(at: location)
        super.touchesEnded(touches, with: event)
    }

    func updateSelectedColor(at point: CGPoint) {
        let image = imageView.image
        let resizedImage = image?.resize(to: CGSize(width: 300, height: 300), mode: .scaleAspectFill)
        guard let color = resizedImage?.getPixelColor(at: point) else { return }
        selectedColor = color
        sendActions(for: .valueChanged)
    }

    private func updateCursorPosition(at point: CGPoint) {
        cursor.frame = CGRect(origin: CGPoint(x: point.x - 15, y: point.y - 15), size: CGSize(width: 30, height: 30))
    }

    private func setup() {
        addSubview(imageView)
        addSubview(cursor)

        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        cursor.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
    }
}

class ViewController: UIViewController {

    private let containerView = UIView()
    private let pixelControl = PixelPickerControl()
    private let toolPanel = UIView()
    private let eyeDropperButton = UIButton()
    private var colorShade: ColorShade = .original
    private var colorMode: ColorMode = .solid {
        didSet {
            gradientView.isHidden = colorMode == .gradient ? false : true
        }
    }

    private var selectedColor: UIColor {
        return pixelControl.selectedColor
    }
    private var firstColor: UIColor = .white {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var secondaryColor: UIColor {
        let selectedHSLColor = HSLColor(color: selectedColor)
        return HSLColor(
            hue: selectedHSLColor.h - 0.05,
            saturation: selectedHSLColor.s + 0.15,
            lightness: selectedHSLColor.l - 0.15)
            .toUIColor()
    }

    private var adjustedFirstColor: UIColor {
        selectedColor.applyColorShade(colorShade)
    }

    private var adjustedSecondColor: UIColor {
        secondaryColor.applyColorShade(colorShade)
    }

    private var displayColorArray: [UIColor] {
        [adjustedFirstColor, adjustedSecondColor]
    }

    private lazy var flowLayout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 56)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor(hexString: "#F3F3F3")
        collectionView.register(ColorInfoCollectionViewCell.self, forCellWithReuseIdentifier: ColorInfoCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()

    private lazy var swapPhotoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "btn_swap_photo"), for: .normal)
        button.addTarget(self, action: #selector(handleSwapButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var gradientView: ColorGradientView = {
        let gradientView = ColorGradientView()
        gradientView.gradientColors = displayColorArray.map({ color in
            color.cgColor
        })
        gradientView.isHidden = colorMode == .gradient ? false : true
        return gradientView
    }()

    private lazy var colorModeButton: UIButton = {
        let button = UIButton()
        button.setTitle(colorMode.title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .black
        button.addTarget(self, action: #selector(tapColorModeButton), for: .touchUpInside)
        return button
    }()

    private lazy var colorShadeButton: UIButton = {
        let button = UIButton()
        button.setTitle(colorShade.title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = UIColor(hexString: "#F3F3F3")
        button.addTarget(self, action: #selector(tapColorShadeButton), for: .touchUpInside)
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let underlineAttributedString = NSAttributedString(string: colorShade.title, attributes: underlineAttribute)
        button.titleLabel?.attributedText = underlineAttributedString
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        containerView.backgroundColor = selectedColor
        pixelControl.addTarget(self, action: #selector(handleColorChanged), for: .valueChanged)
        pixelControl.addShadowWithOffset()

        view.addSubview(containerView)
        view.addSubview(toolPanel)
        containerView.addSubview(gradientView)
        containerView.addSubview(pixelControl)
        containerView.addSubview(colorModeButton)
        pixelControl.addSubview(swapPhotoButton)
        toolPanel.addSubview(colorShadeButton)
        toolPanel.addSubview(collectionView)

        toolPanel.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(260)
        }

        colorShadeButton.snp.makeConstraints { (make) in
            make.height.equalTo(68)
            make.top.left.right.equalToSuperview()
        }

        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(colorShadeButton.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        containerView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(toolPanel.snp.top)
        }

        gradientView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        pixelControl.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(300)
        }

        swapPhotoButton.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview().offset(-16)
            make.width.height.greaterThanOrEqualTo(0)
        }

        colorModeButton.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.width.equalTo(180)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-28)
        }

        colorModeButton.layer.cornerRadius = 25
        colorModeButton.addShadowWithOffset()
    }

    @objc
    private func tapColorModeButton() {
        let colorModes = ColorMode.allCases
        guard let index = colorModes.firstIndex(of: colorMode) else { return }
        colorMode = colorModes[(index + 1) % colorModes.count]
        colorModeButton.setTitle(colorMode.title, for: .normal)
        collectionView.reloadData()
    }

    @objc
    private func tapColorShadeButton() {
        let colorShades = ColorShade.allCases
        guard let index = colorShades.firstIndex(of: colorShade) else { return }
        colorShade = colorShades[(index + 1) % colorShades.count]
        colorShadeButton.setTitle(colorShade.title, for: .normal)
        handleColorChanged()
    }

    @objc
    private func handleColorChanged() {
        containerView.backgroundColor = adjustedFirstColor
        gradientView.gradientColors = displayColorArray.map({ color in
            color.cgColor
        })
        collectionView.reloadData()
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorMode.numberOfColors
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorInfoCollectionViewCell.identifier, for: indexPath)
        guard let colorCell = cell as? ColorInfoCollectionViewCell else { return cell }
        colorCell.color = displayColorArray[indexPath.item]
        return colorCell
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc
    private func handleSwapButtonTapped() {
        let controller = UIImagePickerController()
        controller.sourceType = .photoLibrary
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        pixelControl.imageView.image = image
        picker.dismiss(animated: true) {
            self.pixelControl.updateSelectedColor(at: CGPoint(x: 150, y: 150))
        }
    }
}
