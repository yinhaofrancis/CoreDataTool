//
//  viewExtension.swift
//  image
//
//  Created by YinHao on 16/6/24.
//  Copyright © 2016年 Suzhou Qier Network Technology Co., Ltd. All rights reserved.
//

import UIKit
@IBDesignable
extension UIView{
    @IBInspectable var style:String{
        get{
            return ""
        }
        set{
            self.layer.contentsScale = UIScreen.mainScreen().scale
            self.layer.rasterizationScale = UIScreen.mainScreen().scale
            let array = newValue.componentsSeparatedByString("+")
            for i in array {
                let values = i.componentsSeparatedByString(":")
                let data = convertData(values[1])
                self.layer.setValue(data, forKey: values[0])
            }
        }
    }
}
extension UIColor{
    class func hexColor(color:String)->UIColor{
        let scanr = NSScanner(string: color.substringWithRange(color.startIndex...color.startIndex.advancedBy(1)))
        var r:UInt32 = 0
        scanr.scanHexInt(&r)
        let scang = NSScanner(string: color.substringWithRange(color.startIndex.advancedBy(2)...color.startIndex.advancedBy(3)))
        var g:UInt32 = 0
        scang.scanHexInt(&g)
        let scanb = NSScanner(string: color.substringWithRange(color.startIndex.advancedBy(4)...color.startIndex.advancedBy(5)))
        var b:UInt32 = 0
        scanb.scanHexInt(&b)
        let scana = NSScanner(string: color.substringWithRange(color.startIndex.advancedBy(6)...color.startIndex.advancedBy(7)))
        var a:UInt32 = 0
        scana.scanHexInt(&a)
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
    }
}
func convertData(data:String)->AnyObject{
    if data.hasPrefix("("){
        return NSValue(CGPoint: makePoint(data.substringWithRange(data.startIndex.successor()...data.endIndex.predecessor().predecessor())))
    }else if data.hasPrefix("{"){
        return NSValue(CGRect: makeCGRect(data.substringWithRange(data.startIndex.successor()...data.endIndex.predecessor().predecessor())))
    }else if(data.hasPrefix("[")){
        return NSValue(CGSize: makeSize(data.substringWithRange(data.startIndex.successor()...data.endIndex.predecessor().predecessor())))
    }else if(data.hasPrefix("#")){
        return UIColor.hexColor(data.substringWithRange(data.startIndex.successor()...data.endIndex.predecessor())).CGColor
    }else if(data.hasPrefix("'")){
        return data.substringWithRange(data.startIndex.successor()...data.endIndex.predecessor().predecessor())
    }else if(data.hasPrefix("\"")){
        let name = data.substringWithRange(data.startIndex.successor()...data.endIndex.predecessor().predecessor())
        return UIImage(named: name)!.CGImage!
    }else if data == "true" || data == "false"{
        return makeBool(data)
    }
    else{
        return makeCGFloat(data)
    }
}
func makeBool(value:String)->NSNumber{
    if value == "true"{
        return NSNumber(bool: true)
    }else{
        return NSNumber(bool: false)
    }
    
}
func makeCGFloat(string:String)->CGFloat{
    return CGFloat(NSString(string: string).floatValue)
}
func makeCGRect(string:String)->CGRect{
    let values = string.componentsSeparatedByString(",")
    return CGRect(x: makeCGFloat(values[0]), y: makeCGFloat(values[1]), width: makeCGFloat(values[2]), height: makeCGFloat(values[3]))
}
func makePoint(string:String)->CGPoint{
    let values = string.componentsSeparatedByString(",")
    return CGPoint(x: makeCGFloat(values[0]), y: makeCGFloat(values[1]))
}
func makeSize(string:String)->CGSize{
    let values = string.componentsSeparatedByString(",")
    return CGSize(width:makeCGFloat(values[0]), height: makeCGFloat(values[1]))
}