/*
 MIT License

 Copyright (c) 2017-2019 MessageKit

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation
import UIKit

/// A subclass of `MessageCollectionViewCell` used to display text, media, and location messages.
open class MessageContentCell: MessageCollectionViewCell {

    /// The image view displaying the avatar.
    open var avatarView = AvatarView()

    /// The container used for styling and holding the message's content view.
    open var messageContainerView: MessageContainerView = {
        let containerView = MessageContainerView()
        containerView.clipsToBounds = true
        containerView.layer.masksToBounds = true
        return containerView
    }()
    
    public var _reactionView: UIView = {
        let reactionView = UIView()
        reactionView.backgroundColor = .lightGray
        reactionView.clipsToBounds = true
        reactionView.layer.masksToBounds = true
        reactionView.layer.cornerRadius = 10
        return reactionView
    }()
    
    open var reactionLabel: InsetLabel = {
        let label = InsetLabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    open var cellContainerView: CellContainerView = {
        let containerView = CellContainerView()
        containerView.clipsToBounds = true
        containerView.layer.masksToBounds = true
//        containerView.style = .bubble
//        containerView.backgroundColor = .red
        return containerView
    }()

    /// The top label of the cell.
    open var cellTopLabel: InsetLabel = {
        let label = InsetLabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    /// The bottom label of the cell.
    open var cellBottomLabel: InsetLabel = {
        let label = InsetLabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    /// The top label of the messageBubble.
    open var messageTopLabel: InsetLabel = {
        let label = InsetLabel()
        label.numberOfLines = 0
        return label
    }()

    /// The bottom label of the messageBubble.
    open var messageBottomLabel: MessageLabel = {
        let label = MessageLabel()
        label.numberOfLines = 0
        return label
    }()
    
    open var messageCellBorderWidth: CGFloat = 1

    /// The time label of the messageBubble.
    open var messageTimestampLabel: InsetLabel = InsetLabel()

    // Should only add customized subviews - don't change accessoryView itself.
    open var accessoryView: UIView = UIView()

    /// The `MessageCellDelegate` for the cell.
    open weak var delegate: MessageCellDelegate?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupSubviews()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupSubviews()
    }

    open func setupSubviews() {
        contentView.addSubview(cellContainerView)
        contentView.addSubview(accessoryView)
        contentView.addSubview(cellTopLabel)
        contentView.addSubview(messageTopLabel)
        contentView.addSubview(messageBottomLabel)
        contentView.addSubview(cellBottomLabel)
        contentView.addSubview(messageContainerView)
        contentView.addSubview(avatarView)
        contentView.addSubview(messageTimestampLabel)
        contentView.addSubview(_reactionView)
//        _reactionView.addSubview(reactionLabel)
//        reactionLabel.centerInSuperview()
        contentView.addSubview(reactionLabel)
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        cellTopLabel.text = nil
        cellBottomLabel.text = nil
        messageTopLabel.text = nil
        messageBottomLabel.text = nil
        messageTimestampLabel.attributedText = nil
    }

    // MARK: - Configuration

    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes else { return }
        // Call this before other laying out other subviews
        layoutMessageContainerView(with: attributes)
        layoutMessageBottomLabel(with: attributes)
        layoutCellBottomLabel(with: attributes)
        layoutCellTopLabel(with: attributes)
        layoutMessageTopLabel(with: attributes)
        layoutAvatarView(with: attributes)
        layoutAccessoryView(with: attributes)
        layoutTimeLabelView(with: attributes)
        layoutCellContainerView(with: attributes)
        layoutReactionView(with: attributes)
    }

    /// Used to configure the cell.
    ///
    /// - Parameters:
    ///   - message: The `MessageType` this cell displays.
    ///   - indexPath: The `IndexPath` for this cell.
    ///   - messagesCollectionView: The `MessagesCollectionView` in which this cell is contained.
    open func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        guard let dataSource = messagesCollectionView.messagesDataSource else {
            fatalError(MessageKitError.nilMessagesDataSource)
        }
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }

        delegate = messagesCollectionView.messageCellDelegate

        let messageColor = displayDelegate.backgroundColor(for: message, at: indexPath, in: messagesCollectionView)
        let messageStyle = displayDelegate.messageStyle(for: message, at: indexPath, in: messagesCollectionView)

        let cellStyle = displayDelegate.cellStyle(for: message, at: indexPath, in: messagesCollectionView)
        displayDelegate.configureAvatarView(avatarView, for: message, at: indexPath, in: messagesCollectionView)

        displayDelegate.configureAccessoryView(accessoryView, for: message, at: indexPath, in: messagesCollectionView)

        messageContainerView.backgroundColor = messageColor
        messageContainerView.style = messageStyle
        cellContainerView.style = cellStyle
        let topCellLabelText = dataSource.cellTopLabelAttributedText(for: message, at: indexPath)
        let bottomCellLabelText = dataSource.cellBottomLabelAttributedText(for: message, at: indexPath)
        let topMessageLabelText = dataSource.messageTopLabelAttributedText(for: message, at: indexPath)
        let bottomMessageLabelText = dataSource.messageBottomLabelAttributedText(for: message, at: indexPath)
        let reactionLabelText = dataSource.messageReactionLabelText(for: message, at: indexPath)
        let messageTimestampLabelText = dataSource.messageTimestampLabelAttributedText(for: message, at: indexPath)
        cellTopLabel.attributedText = topCellLabelText
        cellBottomLabel.attributedText = bottomCellLabelText
        messageTopLabel.attributedText = topMessageLabelText
        messageBottomLabel.attributedText = bottomMessageLabelText
        messageTimestampLabel.attributedText = messageTimestampLabelText
        messageTimestampLabel.isHidden = !messagesCollectionView.showMessageTimestampOnSwipeLeft
        reactionLabel.text = "" // reactionLabelText
        _reactionView.backgroundColor =  displayDelegate.reactionBackgroundColor(for: message, at: indexPath, in: messagesCollectionView)
        reactionLabel.textColor = displayDelegate.textColor(for: message, at: indexPath, in: messagesCollectionView)
        let animateReactionIfAny = displayDelegate.animateReactionIfAny(for: message, at: indexPath, in: messagesCollectionView)
        
        if animateReactionIfAny == nil {
            reactionLabel.text = reactionLabelText
            reactionLabel.font = .systemFont(ofSize: 12)
        } else {
            reactionLabel.font = .systemFont(ofSize: 36)
            _reactionView.isHidden = true
            self.reactionLabel.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.reactionLabel.text = animateReactionIfAny
                self._reactionView.isHidden = false
                UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
                    self.reactionLabel.transform = CGAffineTransform(scaleX: 1, y: 1).concatenating(CGAffineTransform(translationX: 0, y: -50))
                }, completion: { _ in
                    UIView.animate(withDuration: 0.25, delay: 0.5, options: .curveEaseIn, animations: {
                        self.reactionLabel.transform = .identity.concatenating(CGAffineTransform(scaleX: 0.4, y: 0.4))
                    }, completion: { _ in
                        self.reactionLabel.font = .systemFont(ofSize: 12)
                        self.reactionLabel.transform = .identity
                        self.reactionLabel.text = reactionLabelText
                    })
                })
            }
        }
    }

    /// Handle tap gesture on contentView and its subviews.
    open override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: self)

        switch true {
        case _reactionView.frame.contains(touchLocation):
            delegate?.didTapReaction(in: self)
        case messageContainerView.frame.contains(touchLocation) && !cellContentView(canHandle: convert(touchLocation, to: messageContainerView)):
            delegate?.didTapMessage(in: self)
        case avatarView.frame.contains(touchLocation):
            delegate?.didTapAvatar(in: self)
        case cellTopLabel.frame.contains(touchLocation):
            delegate?.didTapCellTopLabel(in: self)
        case cellBottomLabel.frame.contains(touchLocation):
            delegate?.didTapCellBottomLabel(in: self)
        case messageTopLabel.frame.contains(touchLocation):
            delegate?.didTapMessageTopLabel(in: self)
        case messageBottomLabel.frame.contains(touchLocation):
            delegate?.didTapMessageBottomLabel(in: self)
        case accessoryView.frame.contains(touchLocation):
            delegate?.didTapAccessoryView(in: self)
        default:
            delegate?.didTapBackground(in: self)
        }
    }

    /// Handle long press gesture, return true when gestureRecognizer's touch point in `messageContainerView`'s frame
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let touchPoint = gestureRecognizer.location(in: self)
        guard gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) else { return false }
        return messageContainerView.frame.contains(touchPoint)
    }

    /// Handle `ContentView`'s tap gesture, return false when `ContentView` doesn't needs to handle gesture
    open func cellContentView(canHandle touchPoint: CGPoint) -> Bool {
        return false
    }

    // MARK: - Origin Calculations

    /// Positions the cell's `AvatarView`.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutAvatarView(with attributes: MessagesCollectionViewLayoutAttributes) {
        var origin: CGPoint = .zero
        let padding = attributes.avatarLeadingTrailingPadding

        switch attributes.avatarPosition.horizontal {
        case .cellLeading:
            origin.x = padding
        case .cellTrailing:
            origin.x = attributes.frame.width - attributes.avatarSize.width - padding
        case .natural:
            fatalError(MessageKitError.avatarPositionUnresolved)
        }

        switch attributes.avatarPosition.vertical {
        case .messageLabelTop:
            origin.y = messageTopLabel.frame.minY
        case .messageTop: // Needs messageContainerView frame to be set
            origin.y = messageContainerView.frame.minY
        case .messageBottom: // Needs messageContainerView frame to be set
            origin.y = messageContainerView.frame.maxY - attributes.avatarSize.height
        case .messageCenter: // Needs messageContainerView frame to be set
            origin.y = messageContainerView.frame.midY - (attributes.avatarSize.height/2)
        case .cellBottom:
            origin.y = attributes.frame.height - attributes.avatarSize.height
        default:
            break
        }

        avatarView.frame = CGRect(origin: origin, size: attributes.avatarSize)
    }

    /// Positions the cell's `MessageContainerView`.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutMessageContainerView(with attributes: MessagesCollectionViewLayoutAttributes) {
        var origin: CGPoint = .zero

        switch attributes.avatarPosition.vertical {
        case .messageBottom:
            origin.y = attributes.size.height - attributes.messageContainerPadding.bottom - attributes.cellBottomLabelSize.height - attributes.messageBottomLabelSize.height - attributes.messageContainerSize.height - attributes.messageContainerPadding.top
        case .messageCenter:
            if attributes.avatarSize.height > attributes.messageContainerSize.height {
                let messageHeight = attributes.messageContainerSize.height + attributes.messageContainerPadding.vertical
                origin.y = (attributes.size.height / 2) - (messageHeight / 2)
            } else {
                fallthrough
            }
        default:
            if attributes.accessoryViewSize.height > attributes.messageContainerSize.height {
                let messageHeight = attributes.messageContainerSize.height + attributes.messageContainerPadding.vertical
                origin.y = (attributes.size.height / 2) - (messageHeight / 2)
            } else {
                origin.y = attributes.cellTopLabelSize.height + attributes.messageTopLabelSize.height + attributes.messageContainerPadding.top
            }
        }

        let avatarPadding = attributes.avatarLeadingTrailingPadding
        switch attributes.avatarPosition.horizontal {
        case .cellLeading:
            origin.x = attributes.avatarSize.width + attributes.messageContainerPadding.left + avatarPadding
        case .cellTrailing:
            origin.x = attributes.frame.width - attributes.avatarSize.width - attributes.messageContainerSize.width - attributes.messageContainerPadding.right - avatarPadding
        case .natural:
            fatalError(MessageKitError.avatarPositionUnresolved)
        }

        messageContainerView.frame = CGRect(origin: origin, size: attributes.messageContainerSize)
    }

    /// Positions the cell's top label.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutCellTopLabel(with attributes: MessagesCollectionViewLayoutAttributes) {
        cellTopLabel.textAlignment = attributes.cellTopLabelAlignment.textAlignment
        cellTopLabel.textInsets = attributes.cellTopLabelAlignment.textInsets

        cellTopLabel.frame = CGRect(origin: .zero, size: attributes.cellTopLabelSize)
    }
    
    /// Positions the cell's bottom label.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutCellBottomLabel(with attributes: MessagesCollectionViewLayoutAttributes) {
        cellBottomLabel.textAlignment = attributes.cellBottomLabelAlignment.textAlignment
        cellBottomLabel.textInsets = attributes.cellBottomLabelAlignment.textInsets
        
        let y = messageBottomLabel.frame.maxY
        let origin = CGPoint(x: 0, y: y)
        
        cellBottomLabel.frame = CGRect(origin: origin, size: attributes.cellBottomLabelSize)
    }
    
    /// Positions the message bubble's top label.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutMessageTopLabel(with attributes: MessagesCollectionViewLayoutAttributes) {
        messageTopLabel.textAlignment = attributes.messageTopLabelAlignment.textAlignment
        messageTopLabel.textInsets = attributes.messageTopLabelAlignment.textInsets

        let y = messageContainerView.frame.minY - attributes.messageContainerPadding.top - attributes.messageTopLabelSize.height
        let origin = CGPoint(x: messageContainerView.frame.origin.x, y: y)
        messageTopLabel.frame = CGRect(origin: origin, size: CGSize(width: messageContainerView.frame.width, height: attributes.messageTopLabelSize.height))
    }

    /// Positions the message bubble's bottom label.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutMessageBottomLabel(with attributes: MessagesCollectionViewLayoutAttributes) {
        messageBottomLabel.textAlignment = attributes.messageBottomLabelAlignment.textAlignment
        messageBottomLabel.textInsets = attributes.messageBottomLabelAlignment.textInsets

        let y = messageContainerView.frame.maxY + attributes.messageContainerPadding.bottom
        let origin = CGPoint(x: messageContainerView.frame.origin.x, y: y)
        messageBottomLabel.frame = CGRect(origin: origin, size: CGSize(width: messageContainerView.frame.width, height: attributes.messageBottomLabelSize.height))
    }

    /// Positions the cell's accessory view.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutAccessoryView(with attributes: MessagesCollectionViewLayoutAttributes) {
        
        var origin: CGPoint = .zero
        
        // Accessory view is set at the side space of the messageContainerView
        switch attributes.accessoryViewPosition {
        case .messageLabelTop:
            origin.y = messageTopLabel.frame.minY
        case .messageTop:
            origin.y = messageContainerView.frame.minY
        case .messageBottom:
            origin.y = messageContainerView.frame.maxY - attributes.accessoryViewSize.height
        case .messageCenter:
            origin.y = messageContainerView.frame.midY - (attributes.accessoryViewSize.height / 2)
        case .cellBottom:
            origin.y = attributes.frame.height - attributes.accessoryViewSize.height
        default:
            break
        }

        // Accessory view is always on the opposite side of avatar
        switch attributes.avatarPosition.horizontal {
        case .cellLeading:
            origin.x = messageContainerView.frame.maxX + attributes.accessoryViewPadding.left
        case .cellTrailing:
            origin.x = messageContainerView.frame.minX - attributes.accessoryViewPadding.right - attributes.accessoryViewSize.width
        case .natural:
            fatalError(MessageKitError.avatarPositionUnresolved)
        }

        accessoryView.frame = CGRect(origin: origin, size: attributes.accessoryViewSize)
    }

    ///  Positions the message bubble's time label.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutTimeLabelView(with attributes: MessagesCollectionViewLayoutAttributes) {
        let paddingLeft: CGFloat = 10
        let origin = CGPoint(x: contentView.frame.size.width + paddingLeft, y: contentView.frame.size.height * 0.5)
        let size = CGSize(width: attributes.messageTimeLabelSize.width, height: attributes.messageTimeLabelSize.height)
        messageTimestampLabel.frame = CGRect(origin: origin, size: size)
    }
    
    ///  Positions the message bubble's time label.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutCellContainerView(with attributes: MessagesCollectionViewLayoutAttributes) {
        let origin = CGPoint(x: messageContainerView.frame.origin.x - messageCellBorderWidth, y: messageTopLabel.frame.origin.y - messageCellBorderWidth)
        cellContainerView.frame = CGRect(origin: origin, size:
                                            CGSize(width: messageContainerView.frame.size.width + 2 * messageCellBorderWidth, height: messageTopLabel.frame.size.height + messageContainerView.frame.size.height + messageBottomLabel.frame.size.height)
                                            )

    }
    
    open func layoutReactionView(with attributes: MessagesCollectionViewLayoutAttributes) {
    let width = attributes.reactionViewSize.width
    _reactionView.frame = CGRect(origin: CGPoint(x: messageContainerView.frame.origin.x + messageContainerView.frame.width - width, y: cellBottomLabel.frame.origin.y - 10), size: attributes.reactionViewSize)
    reactionLabel.frame = CGRect(origin: CGPoint(x: _reactionView.frame.origin.x - 10, y: _reactionView.frame.origin.y), size: CGSize(width: attributes.reactionViewSize.width + 20, height: attributes.reactionViewSize.height))
    }
}

open class CellContainerView: UIImageView {

    // MARK: - Properties

    private let imageMask = UIImageView()
    
    open var style: MessageStyle = .none {
        didSet {
            applyMessageStyle()
        }
    }

    open override var frame: CGRect {
        didSet {
            sizeMaskToView()
        }
    }
    
    // MARK: - Methods

    private func sizeMaskToView() {
        switch style {
        case .none, .custom, .customCell:
            break
        case .bubble, .bubbleTail, .bubbleOutline, .bubbleTailOutline:
            imageMask.frame = bounds
        }
    }

    private func applyMessageStyle() {
        switch style {
        case .bubble, .bubbleTail:
            imageMask.image = style.image
            sizeMaskToView()
            mask = imageMask
            image = nil
        case .bubbleOutline(let color):
            let bubbleStyle: MessageStyle = .bubble
            imageMask.image = bubbleStyle.image
            sizeMaskToView()
            mask = imageMask
            image = style.image?.withRenderingMode(.alwaysTemplate)
            tintColor = color
        case .bubbleTailOutline(let color, let tail, let corner):
            let bubbleStyle: MessageStyle = .bubbleTail(tail, corner)
            imageMask.image = bubbleStyle.image
            sizeMaskToView()
            mask = imageMask
            image = style.image?.withRenderingMode(.alwaysTemplate)
            tintColor = color
        case .none, .custom:
            mask = nil
            image = nil
            tintColor = nil
        case .customCell(let configurationClosure):
            mask = nil
            image = nil
            tintColor = nil
            configurationClosure(self)
        }
    }
}
