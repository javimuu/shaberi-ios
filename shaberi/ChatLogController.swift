//
//  ChatLogController.swift
//  shaberi
//
//  Created by muu van duy on 2017/02/07.
//  Copyright © 2017 muuvanduy. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let cellId: String = "cellId"
    
    lazy var inputContainerView: InputContainerView = {
        let view = InputContainerView()
        view.sourceController = self
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        
        return view
    }()
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    var messages = [Message]()
    var inputContainerViewBottomAnchor: NSLayoutConstraint?
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupKeyboardObservers()
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ConversationCell
        let message = messages[indexPath.item]
        
        cell.sourceController = self
        cell.message = message
        cell.textView.text = message.text
        
        setupConversation(for: cell, message: message)
        
        if let messageText = message.text {
            cell.bubbleViewWidthAnchor?.constant = estimateFrame(for: messageText).width + 32
            cell.textView.isHidden = false
        } else if message.imageUrl != nil {
            cell.bubbleViewWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        cell.playButton.isHidden = message.videoUrl == nil
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        inputContainerView.inputTextField.endEditing(true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        
        if let text = message.text {
            height = estimateFrame(for: text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            height = CGFloat((imageHeight * 200) / imageWidth)
        }
        
        let width = UIScreen.main.bounds.width
        
        return CGSize(width: width, height: height)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL{
            self.handleVideoSelected(for: videoUrl)
        } else {
            self.handleImageSelected(for: info)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func handleKeyboardDidShow() {
        if self.messages.count > 0 {
            let indexPath = IndexPath(item: collectionView!.numberOfItems(inSection: 0) - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    func handleSendMessage() {
        guard let messageText = inputContainerView.inputTextField.text else { return }
        
        let properties = ["text": messageText] as [String : Any]
        
        sendMessage(withProperties: properties)
    }
    
    func handleUploadImage() {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func handleZoomImage(withImageView imageView: UIImageView) {
        self.startingImageView = imageView
        self.startingImageView?.isHidden = true
        self.startingFrame = imageView.superview?.convert(imageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.image = imageView.image
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        zoomingImageView.isUserInteractionEnabled = true
        
        guard let keyWindow = UIApplication.shared.keyWindow  else { return }
        
        self.blackBackgroundView = UIView(frame: keyWindow.frame)
        
        self.blackBackgroundView?.backgroundColor = .black
        self.blackBackgroundView?.alpha = 0
        
        keyWindow.addSubview(self.blackBackgroundView!)
        keyWindow.addSubview(zoomingImageView)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
            self.blackBackgroundView?.alpha = 1
            self.inputAccessoryView?.alpha = 0
            
            let height = CGFloat((self.startingFrame!.height / self.startingFrame!.width) * keyWindow.frame.width)
            
            zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
            zoomingImageView.center = keyWindow.center
        }) { (completed) in
            //
        }
    }
    
    func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        guard let zoomOutImageView = tapGesture.view else { return }
        
        zoomOutImageView.layer.cornerRadius = 16
        zoomOutImageView.clipsToBounds = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            zoomOutImageView.frame = self.startingFrame!
            self.blackBackgroundView?.alpha = 0
            self.inputAccessoryView?.alpha = 1
        }) { (completed) in
            zoomOutImageView.removeFromSuperview()
            self.startingImageView?.isHidden = false
//            self.blackBackgroundView?.removeFromSuperview()
        }
    }
    
    func observeMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid,
            let toId = user?.id
        else { return }
        
        let userMessagesRef = FIRDatabase.database().reference().child(Models.user_messages).child(uid).child(toId)
        
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child(Models.messages).child(messageId)
            
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                let message = Message(dictionary: dictionary)
                
                self.messages.append(message)
                
                DispatchQueue.main.async {
                    
                    if self.messages.count > 0 {
                        self.collectionView?.reloadData()
                        let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                        self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                    }
                }
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    func setupCollectionView(){
        let contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.contentInset = contentInset
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView?.register(ConversationCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
    }
    
    private func estimateFrame(for text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    private func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
    
    private func handleImageSelected(for info: [String: Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"]  as? UIImage {
            selectedImageFromPicker = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
//            uploadToFirebaseStorage(use: selectedImage)
            uploadToFirebaseStorage(use: selectedImage, completion: { (imageUrl) in
                self.sendMessage(withImgUrl: imageUrl, image: selectedImage)
            })
        }
    }
    
    private func handleVideoSelected(for url: URL) {
        let fileName = NSUUID().uuidString
        let ref = FIRStorage.storage().reference().child(Models.message_videos).child("\(fileName).mp4")
        
        let uploadTask = ref.putFile(url, metadata: nil, completion: { (metadata, error) in
            
            if error != nil {
                print("Failed to upload video: ", error!)
                return
            }
            
            if let storageUrl = metadata?.downloadURL()?.absoluteString {
                
                if let thumbnailImage = self.getThumbnailImage(forUrl: url) {
                    
                    self.uploadToFirebaseStorage(use: thumbnailImage, completion: { (imageUrl) in
                        let properties = ["imageUrl": imageUrl, "imageWidth": thumbnailImage.size.width, "imageHeight": thumbnailImage.size.height, "videoUrl": storageUrl] as [String : Any]
                        self.sendMessage(withProperties: properties)
                    })
                }
            }
        })
        
        uploadTask.observe(.progress) { (snapshot) in
            if let compltedUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(compltedUnitCount)
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }
    }
    
    private func sendMessage(withImgUrl url: String, image: UIImage) {
        let properties = ["imageUrl": url, "imageWidth": image.size.width, "imageHeight": image.size.height] as [String : Any]
        
        sendMessage(withProperties: properties)
    }
    
    private func sendMessage(withProperties properties: [String: Any]) {
        guard let toId = user?.id,
            let fromId = FIRAuth.auth()?.currentUser?.uid
            else { return }
        
        let timestamp: NSNumber = NSNumber(value: NSDate().timeIntervalSince1970)
        
        var values = ["toId": toId, "fromId": fromId, "timestamp": timestamp] as [String : Any]

        let ref = FIRDatabase.database().reference().child(Models.messages)
        let childRef = ref.childByAutoId()
        
        // key $0, value $1
        properties.forEach({ values[$0] = $1 })
        
        childRef.updateChildValues(values) { (error, reference) in
            
            if error != nil {
                print(error!)
                return
            }
            
            self.inputContainerView.inputTextField.text = nil
            
            let userMessagesRef = FIRDatabase.database().reference().child(Models.user_messages).child(fromId).child(toId)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = FIRDatabase.database().reference().child(Models.user_messages).child(toId).child(fromId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
    }
    
    private func setupConversation(for cell: ConversationCell, message: Message) {
        if let profileImgUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageUsingCache(withUrl: profileImgUrl)
        }
        
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            // outgoing message
            cell.bubbleView.backgroundColor = Colors.OUTGOING_MESSAGE
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
        } else {
            // in commning message
            cell.bubbleView.backgroundColor = Colors.INCOMMING_MESSAGE
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCache(withUrl: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = .clear
        } else {
            cell.messageImageView.isHidden = true
        }
    }
    
    private func uploadToFirebaseStorage(use image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        let imageName = NSUUID().uuidString
        let ref = FIRStorage.storage().reference().child(Models.message_images).child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("Failed to upload image: ", error!)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    completion(imageUrl)
                }
            })
        }
    }
}
