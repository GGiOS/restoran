//
//  PriceListTableViewCellProtocol.swift
//  Resmoscow
//
//  Created by Egor Galaev on 22/04/17.


@objc protocol PriceListTableViewCellProtocol {
    @objc optional func cellDidOpen(cell: PriceListTableViewCell)
    @objc optional func cellDidClose(cell: PriceListTableViewCell)
    
    @objc optional func cellRemoveAction(cell: PriceListTableViewCell)
    
    func cellChangedOrderCount(cell: PriceListTableViewCell, completion: (() -> Void)?)
}
