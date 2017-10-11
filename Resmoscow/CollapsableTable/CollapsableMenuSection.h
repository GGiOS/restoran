//
//  CollapsableMenuSection.swift
//  Resmoscow
//
//  Created by Egor Galaev on 20/04/17.


#import "CollapsableTable.h"

@interface CollapsableMenuSection : NSObject<RRNCollapsableTableViewSectionModelProtocol>

-(instancetype)initWithTitle:(NSString *)title
                       ident:(NSNumber *)ident
                  pictureUrl:(NSString *)pictureUrl
                     logoUrl:(NSString *)logoUrl
               optionVisible:(NSNumber *)isVisible
                      parent:(NSObject *)parent
                  categories:(NSArray *)categories
                    products:(NSArray *)products
         topSeparatorVisible:(NSNumber *)topSeparatorVisible
      bottomSeparatorVisible:(NSNumber *)bottomSeparatorVisible;

@end
