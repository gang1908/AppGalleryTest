//
//  LoadingIndicator.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 17.02.26.
//

import UIKit

class LoadingIndicator: UIActivityIndicatorView {
    
    override init(style: UIActivityIndicatorView.Style) {
        super.init(style: style)
        setupUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        hidesWhenStopped = true
        color = .systemBlue
        transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
    }
    
    func show(in view: UIView) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            view.addSubview(self)
            self.center = view.center
            self.startAnimating()
        }
    }
    
    func hide() {
        DispatchQueue.main.async { [weak self] in
            self?.stopAnimating()
            self?.removeFromSuperview()
        }
    }
}
