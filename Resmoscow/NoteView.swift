//
//  NoteView.swift
//  Resmoscow
//
//  Created by Egor Galaev on 24/06/17.


import UIKit

fileprivate let tableViewRowHeight: CGFloat = 63.0
fileprivate let leftInsetForTableViewSeparator: CGFloat = 25.0

protocol NoteViewProtocol {
    func cancellNoteAction()
    func addNotesAction()
    func cantChooseAnotherItem()
}

class NoteView: UIView {
    
    var preorderedModis:[ModisItem] = []
    var delegate: NoteViewProtocol?
    var completion: (() -> Void)!
    var product: Product! {
        didSet {
            if let modisSchemeId = product.modisScheme, let modisScheme = Menu.modisSchemeMap?[modisSchemeId] {
                for groupId in modisScheme.groups {
                    if let group = Menu.modisGroupMap?[groupId] {
                        groups.append(group)
                 
                    }
                }
            }
            for groupId in product.modisCommonGroups {
                if let group = Menu.modisGroupMap?[groupId] {
                    groups.append(group)
               
                }
            }
            countsByGroups = Array(repeating: 0, count: groups.count)
        }
    }
    
    fileprivate var groups: [ModisGroup] = []
    
    fileprivate var countsByGroups: [Int] = []
    
    @IBOutlet private weak var noteTitleLabel: UILabel!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var addToOrderButton: UIButton!
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        noteTitleLabel.text = NSLocalizedString("Note", comment: "")
        addToOrderButton.setTitle(NSLocalizedString("Add to order", comment: ""), for: .normal)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: NoteTableViewCell.className, bundle: nil), forCellReuseIdentifier: NoteTableViewCell.className)
        tableView.rowHeight = tableViewRowHeight
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        delegate?.cancellNoteAction()
    }
    
    @IBAction func addToOrderButtonTapped(_ sender: Any) {
        
        product.modisToOrder = preorderedModis
       
        completion()
        
        delegate?.cancellNoteAction()
        
        delegate?.addNotesAction()

    }
}

extension NoteView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups[section].items.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableViewRowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = Bundle.main.loadNibNamed(NoteTableViewHeader.className, owner: nil, options: nil)!.first! as! NoteTableViewHeader
        view.titleLabel.text = groups[section].getName()
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.className) as! NoteTableViewCell
        cell.separatorInset.left = leftInsetForTableViewSeparator
        cell.separatorInset.right = leftInsetForTableViewSeparator
        
        
        let group = groups[indexPath.section]
        if let item = Menu.modisItemMap?[group.items[indexPath.row]] {
            cell.setupModis(modis:item)
            
            cell.handleAddModis = { [unowned self] modisItem in
                self.preorderedModis.append(modisItem)
            }
            
            cell.handleRemoveModis = { [unowned self] modisItem in
                let modisToremove = self.preorderedModis.filter({$0.ident == modisItem.ident})
                if let modis = modisToremove.first {
                    self.preorderedModis.remove(object: modis)
                }
            }
        }
        
        return cell
    }
}

extension Array where Element: AnyObject {
    mutating func remove(object: Element) {
        if let index = index(where: { $0 === object }) {
            remove(at: index)
        }
    }
}

extension NoteView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let group = groups[indexPath.section]
        var canChooseAnotherItem = false
        
        guard let minCount = group.minCount else {
            return
        }
        
        canChooseAnotherItem = minCount > countsByGroups[indexPath.section]
        
        if let cell = tableView.cellForRow(at: indexPath) as? NoteTableViewCell {
            if cell.choosed {
                cell.choosed = false
                cell.imgView.image = nil
                countsByGroups[indexPath.section] -= 1
            } else {
                if canChooseAnotherItem {
                    cell.choosed = true
                    cell.imgView.image = #imageLiteral(resourceName: "Choosed")
                    countsByGroups[indexPath.section] += 1
                } else {
                    if minCount == 1 {
                        cell.choosed = true
                        cell.imgView.image = #imageLiteral(resourceName: "Choosed")
                        for i in 0..<tableView.numberOfRows(inSection: indexPath.section) {
                            if i != indexPath.row {
                                if let anotherCell = tableView.cellForRow(at: IndexPath(row: i, section: indexPath.section)) as? NoteTableViewCell {
                                    anotherCell.choosed = false
                                    anotherCell.imgView.image = nil
                                }
                            }
                        }
                    } else {
                        delegate?.cantChooseAnotherItem()
                    }
                }
            }
        }
    }
}




