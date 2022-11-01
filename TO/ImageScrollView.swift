//
//  ImageScrollView.swift
//  TO
//
//  Created by Константин Козлов on 14.05.2022.
//

import UIKit

class ImageScrollView: UIScrollView, UIScrollViewDelegate {
    
    private var image: Images!
    private var imageZoomView: UIImageView!
    
    lazy var zoomingTap: UITapGestureRecognizer = {
        let zoomingTap = UITapGestureRecognizer(target: self, action: #selector(handleZoomingTap))
        zoomingTap.numberOfTapsRequired = 2
        return zoomingTap
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.delegate = self
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.decelerationRate = UIScrollView.DecelerationRate.fast
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func set(image: UIImage){
        
        imageZoomView?.removeFromSuperview()
        imageZoomView = nil
        
        imageZoomView = UIImageView(image: image)
        self.addSubview(imageZoomView)
        
        confugurateFor(imageSize: image.size)
    }
    
    
    private func confugurateFor(imageSize: CGSize){
        self.contentSize = imageSize
        
        setCurrentMaxandMinScale()
        self.zoomScale = self.minimumZoomScale
        
        self.imageZoomView.addGestureRecognizer(self.zoomingTap)
        self.imageZoomView.isUserInteractionEnabled = true
    }
    
    
    override func layoutSubviews() {
        self.centerImage()
    }
    
    
    private func setCurrentMaxandMinScale(){
        let bounsSize = self.bounds.size
        
        let imageSize = imageZoomView.bounds.size
        
        let xScale = bounsSize.width / imageSize.width
        let yScale = bounsSize.height / imageSize.height
        let minScale = min(xScale, yScale)
        
        var maxScale: CGFloat = 1.0
        if minScale < 0.1{
            maxScale = 0.3
        }
        
        if minScale >= 0.1 && minScale < 0.5{
            maxScale = 0.7
        }
        
        if minScale >= 0.5 {
            maxScale = max(1.0, minScale)
        }
        
        self.minimumZoomScale = minScale
        self.maximumZoomScale = maxScale
    }
    
    
    private func centerImage(){
        let bounsSize = self.bounds.size
        var frameToCenter = imageZoomView.frame
        
        if frameToCenter.size.width < bounsSize.width{
            frameToCenter.origin.x = (bounsSize.width - frameToCenter.size.width) / 2
        }else{
            frameToCenter.origin.x = 0
        }
        
        if frameToCenter.size.height < bounsSize.height{
            frameToCenter.origin.y = (bounsSize.height - frameToCenter.size.height) / 2
        }else{
            frameToCenter.origin.y = 0
        }
        
        imageZoomView.frame = frameToCenter
    }
    
    
    @objc func handleZoomingTap(sender: UITapGestureRecognizer){
        let location = sender.location(in: sender.view)
        self.zoom(to: location, animated: true)
    }
    
    
    private func zoom(to rect: CGPoint, animated: Bool) {
        let currentScale = self.zoomScale
        let minScale = self.minimumZoomScale
        let maxScale = self.maximumZoomScale
        
        if(minScale == maxScale && minScale > 1){
            return
        }
        
        let toScale = maxScale
        let finalScale = (currentScale == minScale) ? toScale : minScale
        let point = CGPoint()
        let zoomRect = self.zoomRect(scale: finalScale, center: point)
        self.zoom(to: zoomRect, animated: animated)
        
    }
    
    
    private func zoomRect(scale: CGFloat, center: CGPoint) -> CGRect{
        var zoomRect = CGRect.zero
        let bounds = self.bounds
        
        zoomRect.size.width = bounds.size.width / scale
        zoomRect.size.height = bounds.size.height / scale
        
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2)
        return zoomRect
    }
    
    
    //MARK: - UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageZoomView
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.centerImage()
    }
}
