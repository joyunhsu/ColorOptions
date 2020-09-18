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

    var selectedPoint: CGPoint = CGPoint(x: 150, y: 150)

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

    lazy var selectedImage: UIImage = {
        let size = CGSize(width: 50, height: 50)
        let capturedRect = CGRect(x: selectedPoint.x - size.width / 2 , y: selectedPoint.y - size.height / 2, width: size.width, height: size.height)
        let image = imageView.image
        let resizedImage = image?.resize(to: CGSize(width: 300, height: 300), mode: .scaleAspectFill)
        let croppedImage = cropToBounds(image: resizedImage!, width: 50, height: 50, position: CGPoint(x: 150, y: 150))
        return croppedImage
    }()

    func cropToBounds(image: UIImage, width: CGFloat, height: CGFloat, position: CGPoint) -> UIImage {

        var x = position.x - width / 2
        var y = position.y - width / 2
        if x < 0 {
            x = 0
        } else if x >= image.size.width {
            x = image.size.width - 1
        }
        if y < 0 {
            y = 0
        } else if y >= image.size.height {

            y = image.size.height - 1
        }

        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
//        let posX: CGFloat = position.x - width / 2
//        let posY: CGFloat = position.y - width / 2
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)

        // See what size is longer and create the center off of that
//        if contextSize.width > contextSize.height {
//            posX = ((contextSize.width - contextSize.height) / 2)
//            posY = 0
//            cgwidth = contextSize.height
//            cgheight = contextSize.height
//        } else {
//            posX = 0
//            posY = ((contextSize.height - contextSize.width) / 2)
//            cgwidth = contextSize.width
//            cgheight = contextSize.width
//        }

        let rect: CGRect = CGRect(x: x, y: y, width: cgwidth, height: cgheight)

        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!

        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

        return image
    }

    private var colorCursor: ColorCursor

    init(colorCursor: ColorCursor = CircularPreviewCursor()) {
        self.colorCursor = colorCursor
        super.init(frame: .zero)
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
        updateSelectedImage(at: location)
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
        colorCursor.selectedColor = color
    }

    func updateSelectedImage(at point: CGPoint) {
        let image = imageView.image
        let resizedImage = image?.resize(to: CGSize(width: 300, height: 300), mode: .scaleAspectFill)
        let croppedImage = cropToBounds(image: resizedImage!, width: 50, height: 50, position: point)
        colorCursor.selectedImage = croppedImage
    }

    private func updateCursorPosition(at point: CGPoint) {
        colorCursor.frame = CGRect(
            origin: CGPoint(
                x: point.x - CircularPreviewCursor.sideWidth / 2,
                y: point.y - CircularPreviewCursor.sideWidth / 2
            ),
            size: CGSize(
                width: CircularPreviewCursor.sideWidth,
                height: CircularPreviewCursor.sideWidth
            )
        )
    }

    private func setup() {
        addSubview(imageView)
        addSubview(colorCursor)

        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        colorCursor.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(CircularPreviewCursor.sideWidth)
        }

        updateSelectedImage(at: CGPoint(x: 150, y: 150))
        updateSelectedColor(at: CGPoint(x: 150, y: 150))
    }
}

protocol ColorCursor: UIView {

    var selectedImage: UIImage { set get }

    var selectedColor: UIColor { set get }

    func createPreviewPath() -> UIBezierPath
}

class DropletPreviewCursor: UIView, ColorCursor {

    init(selectedColor: UIColor, selectedImage: UIImage) {
        self.selectedImage = selectedImage
        self.selectedColor = selectedColor
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var selectedImage: UIImage

    var selectedColor: UIColor

    private let shapeLayer = CAShapeLayer()

    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }

    func createPreviewPath() -> UIBezierPath {
        let dropletPath = UIBezierPath()
        let rect: CGRect = CGRect(x: 0, y: 0, width: 80, height: 80)
        dropletPath.move(to: CGPoint(x: rect.minX + 40, y: rect.minY + 78))
        dropletPath.addCurve(to: CGPoint(x: rect.minX + 61.88, y: rect.minY + 60.08), controlPoint1: CGPoint(x: rect.minX + 49.04, y: rect.minY + 73.12), controlPoint2: CGPoint(x: rect.minX + 56.34, y: rect.minY + 67.15))
        dropletPath.addCurve(to: CGPoint(x: rect.minX + 72, y: rect.minY + 34.85), controlPoint1: CGPoint(x: rect.minX + 67.26, y: rect.minY + 53.22), controlPoint2: CGPoint(x: rect.minX + 72, y: rect.minY + 44.01))
        dropletPath.addCurve(to: CGPoint(x: rect.minX + 40, y: rect.minY + 3), controlPoint1: CGPoint(x: rect.minX + 72, y: rect.minY + 17.26), controlPoint2: CGPoint(x: rect.minX + 57.67, y: rect.minY + 3))
        dropletPath.addCurve(to: CGPoint(x: rect.minX + 8, y: rect.minY + 34.85), controlPoint1: CGPoint(x: rect.minX + 22.33, y: rect.minY + 3), controlPoint2: CGPoint(x: rect.minX + 8, y: rect.minY + 17.26))
        dropletPath.addCurve(to: CGPoint(x: rect.minX + 17.98, y: rect.minY + 60.08), controlPoint1: CGPoint(x: rect.minX + 8, y: rect.minY + 43.95), controlPoint2: CGPoint(x: rect.minX + 11.04, y: rect.minY + 51.34))
        dropletPath.addCurve(to: CGPoint(x: rect.minX + 40, y: rect.minY + 78), controlPoint1: CGPoint(x: rect.minX + 22.61, y: rect.minY + 65.91), controlPoint2: CGPoint(x: rect.minX + 29.95, y: rect.minY + 71.88))
        dropletPath.close()
        dropletPath.usesEvenOddFillRule = true
        return dropletPath
    }
}

class CircularPreviewCursor: UIView, ColorCursor {

    var selectedColor: UIColor {
        didSet {
            setNeedsLayout()
        }
    }

    var selectedImage: UIImage {
        didSet {
            setNeedsLayout()
        }
    }

    private let cross = UIImageView(image: UIImage(named: "cursor_cross"))
    static let sideWidth: CGFloat = 130
    private let edgeInset: CGFloat = 3
    static var layerCenter: CGPoint {
        CGPoint(x: sideWidth / 2, y: sideWidth / 2)
    }

    let shapeLayer = CAShapeLayer()
    var colorOvalPath = UIBezierPath()
    let magnifyingView = UIImageView()

    init(selectedColor: UIColor = .white, selectedImage: UIImage = UIImage(named: "sample")!) {
        self.selectedColor = selectedColor
        self.selectedImage = selectedImage
        super.init(frame: .zero)
        setup()
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        colorOvalPath = createPreviewPath()
        shapeLayer.path = colorOvalPath.cgPath
        shapeLayer.fillColor = UIColor.white.cgColor

        let outerCircleSize = CGRect(x: rect.minX, y: rect.minY, width: CircularPreviewCursor.sideWidth, height: CircularPreviewCursor.sideWidth)
        let outerCirclePath = UIBezierPath(ovalIn: outerCircleSize)
        UIColor.black.setFill()
        outerCirclePath.fill()
    }

    private func setup() {
        magnifyingView.layer.cornerRadius = 100 / 2
        magnifyingView.image = selectedImage
        magnifyingView.clipsToBounds = true
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        layer.addSublayer(shapeLayer)

        addSubview(magnifyingView)
        magnifyingView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(100)
        }

        addSubview(cross)
        cross.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(12)
        }
    }

    func createPreviewPath() -> UIBezierPath {
        let frame = CGRect(
            x: bounds.minX,
            y: bounds.minY,
            width: CircularPreviewCursor.sideWidth,
            height: CircularPreviewCursor.sideWidth)
            .insetBy(dx: edgeInset, dy: edgeInset)
        let path = UIBezierPath(ovalIn: frame)
        return path
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.fillColor = selectedColor.cgColor
        magnifyingView.image = selectedImage
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
            self.pixelControl.updateSelectedImage(at: CGPoint(x: 150, y: 150))
        }
    }
}
