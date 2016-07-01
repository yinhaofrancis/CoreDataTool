//
//  articleViewController.swift
//  image
//
//  Created by YinHao on 16/6/24.
//  Copyright © 2016年 Suzhou Qier Network Technology Co., Ltd. All rights reserved.
//

import UIKit

class articleViewController: UITableViewController {
    
    @IBAction func add(sender: AnyObject) {
        let pre = NSPredicate(format: "own.userid == %@", user!.userid!)
        
        let data = UIImagePNGRepresentation(UIImage(named: "bu")!)
        for _ in 0...1 {
            CoreDataProvide.shareInstace().insert(["title":"\(rand())","picture":data!,"own":user!], type: "Article") { (object) in
                self.user?.articles = self.user?.articles?.setByAddingObject(object)
            }
            if user?.articles == nil{
                user?.articles = []
            }
        }
        
        
        CoreDataProvide.shareInstace().query("Article", condition:pre, result: { (data) in
            self.data = data as! [Article]
            asyncMainRun({ 
                self.tableView.reloadData()
                
            })
        })
    }
    var data:[Article] = []
    var user:User?
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = data[indexPath.row].title
        return cell
    }
    @IBAction func i(sender: UIRefreshControl) {
        sender.endRefreshing()
        let pre = NSPredicate(format: "own.userid == %@", user!.userid!)
        CoreDataProvide.shareInstace().query("Article", condition: pre, result: { (data) in
            self.data = data as! [Article]
            dispatch_async(dispatch_get_main_queue(), { 
                self.tableView.reloadData()
            })
        })
    }
    
}
