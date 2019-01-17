//
//  DemoTableHeaderView.h
//  LTDropDownMenuExample
//
//  Created by alicia on 2019/1/5.
//  Copyright © 2019 LeafTeam. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol DemoTableHeaderDelegate <NSObject>

- (void)scrollToTop;

@end

NS_ASSUME_NONNULL_BEGIN

@interface DemoTableHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) id <DemoTableHeaderDelegate> delegate;
@property (assign, nonatomic) CGFloat scrollTop;

@end

NS_ASSUME_NONNULL_END
