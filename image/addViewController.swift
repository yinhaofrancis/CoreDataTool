//
//  addViewController.swift
//  image
//
//  Created by YinHao on 16/6/24.
//  Copyright © 2016年 Suzhou Qier Network Technology Co., Ltd. All rights reserved.
//

import UIKit
import CoreData
class addViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        top.constant = -selectView.frame.height
        CoreDataProvide.shareInstace().query("User", condition: nil) { (data) in
            print(data)
        }
        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var top: NSLayoutConstraint!

    @IBOutlet weak var selectView: UIView!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: [.CurveEaseOut], animations: { 
            self.top.constant = 64
            self.selectView.layoutIfNeeded()
            }, completion: nil)
    }
    override func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: [.CurveEaseOut], animations: {
            self.top.constant =  -self.selectView.frame.height
            self.selectView.layoutIfNeeded()
            }, completion: {_ in
                super.dismissViewControllerAnimated(false, completion: nil)
        })
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
}
