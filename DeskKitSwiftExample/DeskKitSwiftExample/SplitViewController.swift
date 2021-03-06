//
//  SplitViewController.swift
//  DeskKitSwiftExample
//
//  Created by Desk.com on 6/27/16.
//  Copyright (c) 2016, Salesforce.com, Inc.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided
//  that the following conditions are met:
//
//     Redistributions of source code must retain the above copyright notice, this list of conditions and the
//     following disclaimer.
//
//     Redistributions in binary form must reproduce the above copyright notice, this list of conditions and
//     the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//     Neither the name of salesforce.com, Inc. nor the names of its contributors may be used to endorse or
//     promote products derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
//  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
//  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//

import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate, DKTopicsViewControllerDelegate, DKArticlesViewControllerDelegate, DKContactUsViewControllerDelegate {
    private var topicsViewController: DKTopicsViewController?
    private var contactUsButtonIndex: Int = 0
    private var selectedArticle: DSAPIArticle?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        setupAppearances()
        topicsViewController = newTopicsViewController()
        masterNavigationController?.viewControllers = [topicsViewController!]
        
        masterNavigationController?.setToolbarHidden(false, animated: false)
        detailNavigationController?.setToolbarHidden(false, animated: false)
        
        showMasterViewControllerIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var title: String? {
        get {
            return super.title
        }
        set {
            super.title = newValue
            topicsViewController?.title = newValue
        }
    }
    
    private func setupAppearances() {
        let tintColor = UIColor(colorLiteralRed: 16.0/255, green: 122.0/255, blue: 135.0/255, alpha: 1.0)
        let barTintColor = UIColor(colorLiteralRed: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1.0)
        let topNavTitleTextAttributes = [NSForegroundColorAttributeName: tintColor]
        
        UINavigationBar.appearance().titleTextAttributes = topNavTitleTextAttributes
        UINavigationBar.appearance().barTintColor = barTintColor
        UINavigationBar.appearance().tintColor = tintColor
        
        UIToolbar.appearance().barTintColor = barTintColor
        UIToolbar.appearance().tintColor = tintColor
    }
    
    private var masterNavigationController: UINavigationController? {
        return viewControllers.first as? UINavigationController
    }
    
    private var detailNavigationController: UINavigationController? {
        return viewControllers.last as? UINavigationController
    }
    
    private func showMasterViewControllerIfNeeded() {
        preferredDisplayMode = .allVisible
    }
    
    // MARK: ViewController Constructors
    
    private func newTopicsViewController() -> DKTopicsViewController {
        let controller = DKSession.newTopicsViewController()
        
        controller.delegate = self
        controller.title = NSLocalizedString("Topics", comment: "Topics")
        controller.toolbarItems = contactUsToolbarItems
        
        return controller
    }
    
    private func newArticlesViewController() -> DKArticlesViewController {
        let controller = DKSession.newArticlesViewController()
        controller.toolbarItems = contactUsToolbarItems
        return controller
    }
    
    private func newArticleDetailViewController() -> DKArticleDetailViewController {
        let controller = DKSession.newArticleDetailViewController()
        controller.toolbarItems = contactUsToolbarItems
        return controller
    }
    
    private var contactUsToolbarItems: [UIBarButtonItem] {
        let spacer1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let spacer2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let contactUsButton = UIBarButtonItem(title: NSLocalizedString("Contact Us", comment: "Contact Us"), style: .plain, target: self, action: #selector(contactUsButtonTapped(sender:)))
        contactUsButtonIndex = 1
        
        return [spacer1, contactUsButton, spacer2]
    }
    
    private func newEmptyViewController() -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DKEmptyViewController")
    }
    
    // MARK: Action Sheet
    
    func contactUsButtonTapped(sender: NSObjectProtocol) {
        openActionSheet()
    }
    
    private func openActionSheet() {
        guard let toolbarItems = masterNavigationController?.topViewController?.toolbarItems, contactUsButtonIndex < toolbarItems.count else { return }
        
        let contactUsSheet = DKSession.newContactUsAlertController(callHandler: { (callAction) in
            guard let phoneURL = DKSession.sharedInstance().contactUsPhoneNumberURL else { return }
            
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
            }) { (emailAction) in
                self.alertControllerDidTapEmailUs()
        }
        
        let contactUsButton = toolbarItems[contactUsButtonIndex]
        contactUsSheet.popoverPresentationController?.barButtonItem = contactUsButton
        present(contactUsSheet, animated: true, completion: nil)
    }
    
    private func alertControllerDidTapEmailUs() {
        let contactUsVC = DKSession.sharedInstance().newContactUsViewController()
        contactUsVC.delegate = self
        
        /*
        // Example of adding custom fields
        // 1. Grab initial custom fields populated from DeskKitSettings.plist
        let customFields = NSMutableDictionary(dictionary:contactUsVC.customFields)
        // 2. Add your own dynamic custom fields.
        customFields.addEntries(from: dynamicCustomFields)
        // 3. Assign back to property.
        contactUsVC.customFields = customFields as [NSObject : AnyObject];
        */
        
        // Configure additional properties of DKContactUsViewController here
        
        
        let navVC = UINavigationController(rootViewController: contactUsVC)
        navVC.modalPresentationStyle = .pageSheet
        present(navVC, animated: true, completion: nil)
    }
    
    // MARK: Custom Field Example
    
    var dynamicCustomFields: [String: Any] {
        return [
            "my_case_boolean_custom_field" : true,
            "my_case_date_custom_field" : NSDate().stringWithISO8601Format(),
            "my_case_list_custom_field" : "C",
            "my_case_number_custom_field" : 45, // Integer
            "my_case_text_custom_field" : "value1"
        ]
    }
    
    // MARK: DKContactUsViewControllerDelegate
    
    func contactUsViewControllerDidSendMessage(_ viewController: DKContactUsViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func contactUsViewControllerDidCancel(_ viewController: DKContactUsViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: DKTopicsViewControllerDelegate
    
    func topicsViewController(_ topicsViewController: DKTopicsViewController, didSelect topic: DSAPITopic?, articlesTopicViewModel: DKArticlesTopicViewModel?) {
        guard let topic = topic, let articlesTopicViewModel = articlesTopicViewModel else { return }
        
        let controller = newArticlesViewController()
        
        controller.delegate = self
        controller.setViewModel(articlesTopicViewModel, topic: topic)
        
        masterNavigationController?.pushViewController(controller, animated: true)
    }
    
    func topicsViewController(_ topicsViewController: DKTopicsViewController, didSelectSearchedArticle article: DSAPIArticle?) {
        guard let article = article else { return }
        
        showArticle(article: article)
    }
    
    // MARK: DKArticlesViewControllerDelegate
    
    func articlesViewController(_ articlesViewController: DKArticlesViewController, didSelectSearchedArticle article: DSAPIArticle?) {
        guard let article = article else { return }
        
        showArticle(article: article)
    }
    
    func articlesViewController(_ articlesViewController: DKArticlesViewController, didSelect article: DSAPIArticle?) {
        guard let article = article else { return }
        
        showArticle(article: article)
    }
    
    private func showArticle(article: DSAPIArticle) {
        selectedArticle = article
        
        let controller = newArticleDetailViewController()
        controller.article = article
        
        if viewControllers.count == 2 {
            controller.navigationItem.leftBarButtonItem = displayModeButtonItem
            detailNavigationController?.viewControllers = [controller]
        } else {
            detailNavigationController?.pushViewController(controller, animated: true)
        }
    }
    
    // MARK: UISplitViewControllerDelegate
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        guard let _ = selectedArticle else {
            // YES: Tells UIKit not to do anything, ignoring empty view.
            return true
        }
        
        guard
            let secondaryNavigationController = secondaryViewController as? UINavigationController,
            let topVC = secondaryNavigationController.topViewController else {
            // NO: Tells UIKit performs default behavior which is collapsing secondary onto primary.
            return false
        }
        
        guard let detailVC = topVC as? DKArticleDetailViewController else {
            // YES: Tells UIKit not to do anything, ignoring empty view.
            return true
        }
        
        guard let primaryNavigationController = primaryViewController as? UINavigationController else {
            // YES: Tells UIKit not to do anything, ignoring detail view.
            return true
        }
        
        detailVC.navigationItem.leftBarButtonItem = nil
        primaryNavigationController.pushViewController(detailVC, animated: false)
        return true
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        guard let selectedArticle = selectedArticle else {
            return UINavigationController(rootViewController: newEmptyViewController())
        }
        guard let primaryNavigationController = primaryViewController as? UINavigationController else {
            return nil
        }
        
        var detailVC: DKArticleDetailViewController
        if let vc = primaryNavigationController.topViewController as? DKArticleDetailViewController {
            detailVC = vc
            primaryNavigationController.popViewController(animated: false)
        } else {
            detailVC = newArticleDetailViewController()
            detailVC.article = selectedArticle
        }
        
        detailVC.navigationItem.leftBarButtonItem = displayModeButtonItem
        let secondaryNavigationController = UINavigationController(rootViewController: detailVC)
        return secondaryNavigationController
    }
}
