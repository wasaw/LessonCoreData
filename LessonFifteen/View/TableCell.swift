//
//  TableCell.swift
//  LessonFifteen
//
//  Created by Александр Меренков on 29.11.2022.
//

import UIKit

class TableCell: UITableViewCell {
    static let identifire = "tableCell"
    
//    MARK: - Properties
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 21)
        label.textColor = .lightGray
        return label
    }()
    
     let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 45 / 2
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        imageView.layer.shadowOpacity = 0.5
        imageView.layer.shadowRadius = 5
        imageView.layer.masksToBounds = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.widthAnchor.constraint(equalToConstant: 45).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19)
        label.lineBreakMode = .byCharWrapping
        label.numberOfLines = 2
        label.textColor = .black
        return label
    }()
    
     let workImageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
//    MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    MARK: - Helpers
    
    private func configureUI() {
        let stack = UIStackView(arrangedSubviews: [numberLabel, avatarImageView, userNameLabel])
        stack.axis = .horizontal
        stack.spacing = 12

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.leftAnchor.constraint(equalTo: leftAnchor, constant: 25).isActive = true
        stack.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        stack.rightAnchor.constraint(equalTo: rightAnchor, constant: -25).isActive = true
    }
    
    func setInformation(cellNumber: Int, profile: Profile) {
        numberLabel.text = String(cellNumber)
        userNameLabel.text = profile.userName
        avatarImageView.image = profile.profileImage
        if cellNumber % 2 == 0 {
            backgroundColor = .background
        } else {
            backgroundColor = .white
        }
        
        workImageView.image = profile.workImage
    }
    
    func addPhoto() {
        if workImageView.isHidden {
            workImageView.isHidden = false
        } else {
            addSubview(workImageView)
            workImageView.translatesAutoresizingMaskIntoConstraints = false
            workImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            workImageView.topAnchor.constraint(equalTo: topAnchor, constant: 75).isActive = true
            workImageView.widthAnchor.constraint(equalToConstant: bounds.width).isActive = true
            workImageView.heightAnchor.constraint(equalToConstant: bounds.width).isActive = true
        }
    }
    
    func hide() {
        workImageView.isHidden = true
    }
}
