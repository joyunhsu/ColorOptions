//
//  ColorInfoCollectionViewCell.swift
//  ColorOptionsExplore
//
//  Created by Jo Hsu on 2020/9/2.
//  Copyright © 2020 Jo Hsu. All rights reserved.
//

import UIKit
import SnapKit
import ColorPicker

class ColorInfoCollectionViewCell: UICollectionViewCell {

    static let identifier = "ColorInfoCollectionViewCell"
    private let colorPreview = UIView()
    private lazy var colorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }()

    var color: UIColor? {
        didSet {
            guard let color = color else { return }
            colorPreview.backgroundColor = color
            colorLabel.text = color.hexString
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .white
        colorPreview.backgroundColor = .gray
        colorLabel.text = "#FFFFFF"
        addSubview(colorPreview)
        addSubview(colorLabel)

        colorPreview.snp.makeConstraints { (make) in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(120)
        }

        colorLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-30)
            make.width.height.greaterThanOrEqualTo(0)
        }
    }
}
