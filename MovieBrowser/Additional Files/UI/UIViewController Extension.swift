//
//  UIViewController Extension.swift
//  FlatunDemo
//
//  Created by Евгений on 25.11.2018.
//  Copyright © 2018 Евгений. All rights reserved.
//

import UIKit

extension UIViewController {
    func sizeClass() -> (UIUserInterfaceSizeClass, UIUserInterfaceSizeClass) {
        return (self.traitCollection.horizontalSizeClass, self.traitCollection.verticalSizeClass)
    }

    var widthSizeClassIsRegular: Bool{
        return self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.regular
    }
}
