//
//  ViewController.swift
//  RSPageControl
//
//  Created by yuxiit on 2019/3/12.
//  Copyright © 2019 yuxiit. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let imagesURLStrings = [
        "https://cdn.pixabay.com/photo/2015/06/24/13/32/dog-820014__480.jpg",
        "https://cdn.pixabay.com/photo/2019/03/08/20/13/safari-4043090__480.jpg",
        "https://cdn.pixabay.com/photo/2019/03/10/22/06/cat-4047348__480.jpg",
        "https://cdn.pixabay.com/photo/2019/03/09/08/49/chihuahua-4043838__480.jpg",
        ];
    
    var banner = RSCycleScrollView(frame: CGRect(x: 0, y: 40, width: UIScreen.main.bounds.width, height: 200));
    var bannerSystem = RSCycleScrollView(frame: CGRect(x: 0, y: 280, width: UIScreen.main.bounds.width, height: 200));

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        banner.imagePaths = imagesURLStrings
        banner.customPageControlStyle = .snake
        banner.customPageControlTintColor = UIColor.red
        banner.delegate = self
        self.view.addSubview(banner)
        
        bannerSystem.imagePaths = imagesURLStrings
        self.view.addSubview(bannerSystem)
        
        
    }


}

extension ViewController: RSCycleScrollViewDelegate {
    func cycleScrollView(_ cycleScrollView: RSCycleScrollView, didSelectItemIndex index: NSInteger) {
        print(index)
    }
    
    
}

