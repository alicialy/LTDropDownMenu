//
//  DemoTableHeaderView.m
//  LTDropDownMenuExample
//
//  Created by alicia on 2019/1/5.
//  Copyright © 2019 LeafTeam. All rights reserved.
//

#import "DemoTableHeaderView.h"
#import "LTDropDownMenu.h"

@interface DemoTableHeaderView () <LTDropDownMenuDelegate, LTDropDownMenuDataSource>

@property (nonatomic, strong) LTDropDownMenu *menu;
@property (nonatomic, strong) NSArray *colArray;
@property (nonatomic, strong) NSArray *foodArray;
@property (nonatomic, strong) NSArray *movieArray;
@property (nonatomic, strong) NSArray *hotelArray;
@property (nonatomic, strong) NSArray *areaArray;
@property (nonatomic, strong) NSArray *sortArray;

@end

@implementation DemoTableHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        [self addControls];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addControls];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutControls];
}

#pragma mark - Controls
- (void)addControls {
    CGSize size = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 28);
    LTDropDownMenu *menu = [LTDropDownMenu menuWithSize:size];
    [menu setMenuTitles:@[@"全部",@"附近",@"智能排序"]];
    menu.delegate = self;
    menu.dataSource = self;
    menu.selectedLineColor = [UIColor redColor];
  
    [self addSubview:menu];
    self.colArray = @[@"美食",@"今日新单",@"电影",@"酒店"];
    self.foodArray = @[@"自助餐",@"快餐",@"火锅",@"日韩料理",@"西餐",@"烧烤小吃"];
    self.movieArray = @[@"内地剧",@"港台剧",@"英美剧"];
    self.hotelArray = @[@"经济酒店",@"商务酒店",@"连锁酒店",@"度假酒店",@"公寓酒店"];
    self.areaArray = @[@"附近",@"芙蓉区",@"雨花区",@"天心区",@"开福区",@"岳麓区"];
    self.sortArray = @[@"默认排序",@"离我最近",@"好评优先",@"人气优先",@"最新发布"];
    
    
    self.menu = menu;
}

- (void)layoutControls {
    CGFloat offsetX = 0;
    CGFloat viewWidth = self.bounds.size.width;
    CGFloat viewHeight = self.bounds.size.height;
    
    self.menu.frame = CGRectMake(offsetX, 0, viewWidth, viewHeight);
}

#pragma mark - Public Mehtod
- (void)setScrollTop:(CGFloat)scrollTop {
    _scrollTop = scrollTop;
  
    [self.menu setMaskOffsetY:scrollTop];
}

#pragma mark - LTDropDownMenuDelegate

- (void)menuDidSelected {
     [self.delegate scrollToTop];
}

- (void)menu:(LTDropDownMenu *)menu didSelectRow:(NSInteger)row {
    [self.delegate scrollToTop];
}

- (void)menu:(LTDropDownMenu *)menu didSelectLefRow:(NSInteger)leftRow rightRow:(NSInteger)rightRow {
    
}

#pragma mark - LTDropDownMenuDataSource
- (NSInteger)num {
    return 3;
}

- (NSString *)menu:(LTDropDownMenu *)menu titleForCol:(NSInteger)col row:(NSInteger)row {
    if (col == 0) {
        return self.colArray[row];
    } else if (col == 1) {
        return self.areaArray[row];
    } else if (col == 2) {
        return self.sortArray[row];
    }
    return nil;
}

- (NSString *)menu:(LTDropDownMenu *)menu titleForCol:(NSInteger)col leftRow:(NSInteger)leftRow rightRow:(NSInteger)rightRow {
    if (col == 0) {
        if (leftRow == 0) {
            return self.foodArray[rightRow];
        } else if (leftRow == 2) {
            return self.movieArray[rightRow];
        } else if (leftRow == 3) {
            return self.hotelArray[rightRow];
        }
    }
    return nil;
    
}
- (NSInteger)menu:(LTDropDownMenu *)menu numberOfRowsInCol:(NSInteger)col {
    if (col == 0) {
        return [self.colArray count];
    } else if (col == 1) {
        return [self.areaArray count];
    } else if (col == 2){
        return [self.sortArray count];
    } else {
        return 0;
    }
}

- (NSInteger)menu:(LTDropDownMenu *)menu numberOfRightRowsInCol:(NSInteger)col leftRow:(NSInteger)leftRow {
    if (col == 0) {
        if (leftRow == 0) {
            return [self.foodArray count];
        } else if (leftRow == 2) {
            return [self.movieArray count];
        } else if (leftRow == 3) {
            return [self.hotelArray count];
        }
    }
    return 0;
}
- (BOOL)menu:(LTDropDownMenu *)menu hasRightRowsInCol:(NSInteger)col {
    if (col == 0) {
        return YES;
    } else {
        return NO;
    }
}

@end
