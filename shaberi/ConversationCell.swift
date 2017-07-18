//
//  Conversation.swift
//  shaberi
//
//  Created by muu van duy on 2017/02/08.
//  Copyright © 2017 muuvanduy. All rights reserved.
//

import UIKit
import AVFoundation

class ConversationCell: UICollectionViewCell {
    
    var message: Message?
    
    var sourceController: ChatLogController?

    var bubbleViewWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    var player: AVPlayer?
    var playLayer: AVPlayerLayer?
    
    let activitiIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.hidesWhenStopped = true
        aiv.translatesAutoresizingMaskIntoConstraints = false
        
        return aiv
    }()
    
    let profileImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.layer.cornerRadius = 16
        imgView.layer.masksToBounds = true
        imgView.contentMode = .scaleAspectFill
        imgView.image = UIImage(named: "profile_img")
        imgView.translatesAutoresizingMaskIntoConstraints = false
        
        return imgView
    }()
    
    lazy var messageImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.layer.cornerRadius = 16
        imgView.layer.masksToBounds = true
        imgView.contentMode = .scaleAspectFill
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomImage)))
        imgView.isUserInteractionEnabled = true
        
        return imgView
    }()
    
    lazy var playButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "btn_play"), for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(handlePlayButton), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        return btn
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        
        return tv
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.OUTGOING_MESSAGE
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        
        bubbleView.addSubview(messageImageView)
        bubbleView.addSubview(playButton)
        bubbleView.addSubview(activitiIndicatorView)
        
        //set profileImageView constraints
        profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        // set bubbleView constraints
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8)
        bubbleViewRightAnchor?.isActive = true
        
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        bubbleViewLeftAnchor?.isActive = false
        
        bubbleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bubbleViewWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleViewWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        // set textView constraints
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        //set messageImageView constraints
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        // set playButton constraints
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 222).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 125).isActive = true
        
        // set activitiIndicatorView constraints
        activitiIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activitiIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        activitiIndicatorView.widthAnchor.constraint(equalToConstant: 222).isActive = true
        activitiIndicatorView.heightAnchor.constraint(equalToConstant: 125).isActive = true
        
    }
    
    func handleZoomImage(tapGesture: UITapGestureRecognizer) {
        if message?.videoUrl != nil { return }
        guard let imageView = tapGesture.view as? UIImageView else { return }
        sourceController?.handleZoomImage(withImageView: imageView)
    }
    
    func handlePlayButton() {
        if let videoUrlString = message?.videoUrl, let url = URL(string: videoUrlString){
            player = AVPlayer(url: url)
            
            playLayer = AVPlayerLayer(player: player)
            
            playLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playLayer!)
            
            player?.play()
            activitiIndicatorView.startAnimating()
            playButton.isHidden = true
            print("Playing video...")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        playLayer?.removeFromSuperlayer()
        player?.pause()
        activitiIndicatorView.stopAnimating()
    }
}
