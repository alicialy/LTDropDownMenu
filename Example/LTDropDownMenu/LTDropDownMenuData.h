//
//  LTDropDownMenuData.h
//  LTDropDownMenu
//
//  Created by alicia on 2019/01/04.
//  Copyright © 2019 LeafTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LTDropDownMenuData : NSObject

@property (nonatomic, copy) NSString * title;
@property (nonatomic, assign) BOOL isSelectedItem;

@property (nonatomic, strong) NSArray *rightTableData;  // For Two Col

@end
