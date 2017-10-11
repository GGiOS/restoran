//
//  CollapsableMenuSection.swift
//  Resmoscow
//
//  Created by Egor Galaev on 20/04/17.


#import "CollapsableMenuSection.h"

@implementation CollapsableMenuSection

@synthesize ident = _ident;
@synthesize pictureUrl = _pictureUrl;
@synthesize logoUrl = _logoUrl;
@synthesize title = _title;
@synthesize isVisible = _isVisible;
@synthesize parent = _parent;
@synthesize categories = _categories;
@synthesize products = _products;
@synthesize topSeparatorVisible = _topSeparatorVisible;
@synthesize bottomSeparatorVisible = _bottomSeparatorVisible;

-(instancetype)initWithTitle:(NSString *)title
                       ident:(NSNumber *)ident
                  pictureUrl:(NSString *)pictureUrl
                     logoUrl:(NSString *)logoUrl
               optionVisible:(NSNumber *)isVisible
                      parent:(NSObject *)parent
                  categories:(NSArray *)categories
                    products:(NSArray *)products
         topSeparatorVisible:(NSNumber *)topSeparatorVisible
      bottomSeparatorVisible:(NSNumber *)bottomSeparatorVisible {
    self = [super init];
    if (self) {
        _ident = ident;
        _pictureUrl = pictureUrl;
        _logoUrl = logoUrl;
        _title = title;
        _isVisible = isVisible;
        _parent = parent;
        _categories = categories;
        _products = products;
        _topSeparatorVisible = topSeparatorVisible;
        _bottomSeparatorVisible = bottomSeparatorVisible;
    }
    return self;
}

@end
