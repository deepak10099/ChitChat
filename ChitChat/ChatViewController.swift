//
//  ChatViewController.swift
//  ChitChat
//
//  Created by Deepak on 06/09/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {

    //    var messagess = [JSQMessage]()
    var messages:[JSQMessage] = []
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incommingBubbleImageView: JSQMessagesBubbleImage!

    let rootRef = FIRDatabase.database().reference()
    var messageRef: FIRDatabaseReference!
    var userIsTypingRef: FIRDatabaseReference!
    var usersTypingQuery: FIRDatabaseQuery!
//    private var localTyping = false
//    var isTyping: Bool{
//        get{
//            return localTyping
//        }
//        set{
//            localTyping = newValue
//            userIsTypingRef.setValue(newValue)
//        }
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "chitchat"
        self.setupBubble()
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        messageRef = rootRef.child("messages")
    }

        override func viewDidAppear(animated: Bool) {
            super.viewDidAppear(animated)
            observeMessages()
//            observeTyping()
        }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    func setupBubble() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incommingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incommingBubbleImageView
        }
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]

        if message.senderId == senderId {
            cell.textView.textColor = UIColor.whiteColor()
        } else {
            cell.textView.textColor = UIColor.blackColor()
        }

        return cell
    }

    func addMessage(id:String, text:String) {
        let message = JSQMessage(senderId: id, displayName: "", text: text)
        messages.append(message)
    }

    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let itemRef = messageRef.childByAutoId()
        let messageItem = [
            "text": text,
            "sender id": senderId
        ]
        itemRef.setValue(messageItem)

        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
//        isTyping = false
    }

    private func observeMessages() {
        let messagesQuery = messageRef.queryLimitedToLast(25)

        messagesQuery.observeEventType(.ChildAdded, withBlock: { snapshot in
            let id = snapshot.value!["sender id"] as! String
            let text = snapshot.value!["text"] as! String
            self.addMessage(id, text: text)
            self.finishReceivingMessage()
        })
    }

//    override func textViewDidChange(textView: UITextView) {
////        isTyping = textView.text != ""
//    }
//
//    private func observeTyping() {
//        let typingIndicatorRef = rootRef.child("typingIndicator")
//        userIsTypingRef = typingIndicatorRef.child(senderId)
//        userIsTypingRef.onDisconnectRemoveValue()
//    }
}
