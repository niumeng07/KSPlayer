//
//  File.swift
//  KSPlayer
//
//  Created by kintan on 2018/3/9.
//
#if canImport(UIKit)
import UIKit

public class KSSlider: UXSlider {
    private var tapGesture: UITapGestureRecognizer!
    private var panGesture: UIPanGestureRecognizer!
    weak var delegate: KSSliderDelegate?
    public var trackHeigt = CGFloat(4)
    /// Visible thumb diameter; kept in sync with thumb image size in VideoPlayerView.
    public var thumbDiameter = CGFloat(12)
    public var isPlayable = false
    override public init(frame: CGRect) {
        super.init(frame: frame)
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionTapGesture(sender:)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(actionPanGesture(sender:)))
        addGestureRecognizer(tapGesture)
        addGestureRecognizer(panGesture)
        addTarget(self, action: #selector(progressSliderTouchBegan(_:)), for: .touchDown)
        addTarget(self, action: #selector(progressSliderValueChanged(_:)), for: .valueChanged)
        addTarget(self, action: #selector(progressSliderTouchEnded(_:)), for: [.touchUpInside, .touchCancel, .touchUpOutside, .primaryActionTriggered])
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func trackRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.trackRect(forBounds: bounds)
        rect.origin.y = (bounds.height - trackHeigt) / 2
        rect.size.height = trackHeigt
        return rect
    }

    override open func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let rect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        let size = thumbDiameter
        return CGRect(
            x: rect.midX - size / 2,
            y: rect.midY - size / 2,
            width: size,
            height: size
        )
    }

    private func sliderValue(forTouchAt point: CGPoint) -> Float {
        let track = trackRect(forBounds: bounds)
        guard track.width > 0 else { return value }
        let x = point.x - track.minX
        let ratio = max(0, min(1, x / track.width))
        return minimumValue + (maximumValue - minimumValue) * Float(ratio)
    }

    // MARK: - handle UI slider actions

    @objc private func progressSliderTouchBegan(_ sender: KSSlider) {
        guard isPlayable else { return }
        tapGesture.isEnabled = false
        panGesture.isEnabled = false
        value = value
        delegate?.slider(value: Double(sender.value), event: .touchDown)
    }

    @objc private func progressSliderValueChanged(_ sender: KSSlider) {
        guard isPlayable else { return }
        delegate?.slider(value: Double(sender.value), event: .valueChanged)
    }

    @objc private func progressSliderTouchEnded(_ sender: KSSlider) {
        guard isPlayable else { return }
        tapGesture.isEnabled = true
        panGesture.isEnabled = true
        delegate?.slider(value: Double(sender.value), event: .touchUpInside)
    }

    @objc private func actionTapGesture(sender: UITapGestureRecognizer) {
        //        guard isPlayable else {
        //            return
        //        }
        let touchPoint = sender.location(in: self)
        let newValue = sliderValue(forTouchAt: touchPoint)
        self.value = newValue
        delegate?.slider(value: Double(newValue), event: .valueChanged)
        delegate?.slider(value: Double(newValue), event: .touchUpInside)
    }

    @objc private func actionPanGesture(sender: UIPanGestureRecognizer) {
        //        guard isPlayable else {
        //            return
        //        }
        let touchPoint = sender.location(in: self)
        let newValue = sliderValue(forTouchAt: touchPoint)
        self.value = newValue
        if sender.state == .began {
            delegate?.slider(value: Double(newValue), event: .touchDown)
        } else if sender.state == .ended {
            delegate?.slider(value: Double(newValue), event: .touchUpInside)
        } else {
            delegate?.slider(value: Double(newValue), event: .valueChanged)
        }
    }
}

#if os(tvOS)
public class UXSlider: UIProgressView {
    @IBInspectable public var value: Float {
        get {
            progress * maximumValue
        }
        set {
            progress = newValue / maximumValue
        }
    }

    @IBInspectable public var maximumValue: Float = 1 {
        didSet {
            refresh()
        }
    }

    @IBInspectable public var minimumValue: Float = 0 {
        didSet {
            refresh()
        }
    }

    open var minimumTrackTintColor: UIColor? {
        get {
            progressTintColor
        }
        set {
            progressTintColor = newValue
        }
    }

    open var maximumTrackTintColor: UIColor? {
        get {
            trackTintColor
        }
        set {
            trackTintColor = newValue
        }
    }

    open func setThumbImage(_: UIImage?, for _: UIControl.State) {}
    open func addTarget(_: Any?, action _: Selector, for _: UIControl.Event) {}

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - private functions

    private func setup() {
        refresh()
    }

    private func refresh() {}
    open func trackRect(forBounds bounds: CGRect) -> CGRect {
        bounds
    }

    open func thumbRect(forBounds bounds: CGRect, trackRect _: CGRect, value _: Float) -> CGRect {
        bounds
    }
}
#else
public typealias UXSlider = UISlider
#endif

public typealias UIViewContentMode = UIView.ContentMode
extension UIButton {
    func fillImage() {
        contentMode = .scaleAspectFill
        contentHorizontalAlignment = .fill
        contentVerticalAlignment = .fill
    }

    var titleFont: UIFont? {
        get {
            titleLabel?.font
        }
        set {
            titleLabel?.font = newValue
        }
    }

    var title: String? {
        get {
            titleLabel?.text
        }
        set {
            titleLabel?.text = newValue
        }
    }
}

extension UIView {
    func image() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }

    public func centerRotate(byDegrees: Double) {
        transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * byDegrees / 180.0))
    }
}
#endif
