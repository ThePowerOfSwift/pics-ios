//
//  ProfilePopover.swift
//  pics-ios
//
//  Created by Michael Skogberg on 27/01/2018.
//  Copyright © 2018 Michael Skogberg. All rights reserved.
//

import Foundation
import UIKit

protocol ProfileDelegate {
    func onPublic()
    func onPrivate()
    func onLogout()
}

class ProfilePopover: UITableViewController, UIPopoverPresentationControllerDelegate {
    let popoverCellIdentifier = "PopoverCell"
    
    let user: String?
    let isPrivate: Bool
    let delegate: ProfileDelegate
    
    init(user: String?, isPrivate: Bool, delegate: ProfileDelegate) {
        self.user = user
        self.isPrivate = isPrivate
        self.delegate = delegate
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Select gallery"
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ProfilePopover.dismissSelf(_:)))
        ]
//        navigationController?.isNavigationBarHidden = false
        tableView.cellLayoutMarginsFollowReadableWidth = false
        // Removes separators when there are no more rows
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: popoverCellIdentifier)
        tableView.layoutIfNeeded()
        preferredContentSize = tableView.contentSize
        tableView.cellLayoutMarginsFollowReadableWidth = false
    }
    
    @objc func dismissSelf(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: popoverCellIdentifier, for: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Public gallery"
            cell.accessoryType = isPrivate ? .none : .checkmark
            break
        case 1:
            cell.textLabel?.text = user ?? "Log in"
            cell.accessoryType = isPrivate ? .checkmark : .none
            if user == nil {
                cell.textLabel?.textColor = PicsColors.blueish
            }
            break
        default:
            cell.textLabel?.text = "Log out"
            cell.textLabel?.textColor = .red
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
        switch indexPath.row {
        case 0:
            delegate.onPublic()
            break
        case 1:
            delegate.onPrivate()
            break
        default:
            delegate.onLogout()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user == nil ? 2 : 3
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
