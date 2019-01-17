//
//  DemoTableViewController.m
//  LTViewPager
//
//  Created by Alicia on 16/10/9.
//  Copyright © 2016年 leafteam. All rights reserved.
//

#import "DemoTableViewController.h"
#import "DemoTableHeaderView.h"

static NSString * const kDemoReuseId            = @"DemoCell";
static NSString * const kDemoHeaderReuseId      = @"DemoHeader";
static NSString * const kDemoHeaderMenuReuseId  = @"DemoHeaderMenu";
static NSInteger const kDemoTableCountMultiple  = 5;

@interface DemoTableViewController () <DemoTableHeaderDelegate>

@property (nonatomic, strong) NSArray *viewsArray;

@end

@implementation DemoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Demo";
    
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kDemoReuseId];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kDemoHeaderReuseId];
    [self.tableView registerClass:[DemoTableHeaderView class] forHeaderFooterViewReuseIdentifier:kDemoHeaderMenuReuseId];
    
    self.viewsArray = @[@"ViewControllerViewPager",
                        @"ViewControllerUnderLine",
                        @"ViewControllerEnlarge"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [self.viewsArray count];
    if (section == 0) {
        return count;
    } else {
        return count * kDemoTableCountMultiple;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row % [self.viewsArray count];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDemoReuseId forIndexPath:indexPath];

    cell.textLabel.text = self.viewsArray[row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kDemoHeaderReuseId];
        [headerView.textLabel setText:@"Normal Header"];
        return headerView;
    } else {
        DemoTableHeaderView *headerView = (DemoTableHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:kDemoHeaderMenuReuseId];
        headerView.delegate = self;
        headerView.scrollTop = 28;
        return headerView;
    }
}

#pragma mark - DemoTableHeaderDelegate
- (void)scrollToTop {
    NSIndexPath *minIndexPath = [[self.tableView indexPathsForVisibleRows] firstObject];
    if (minIndexPath.section == 1) {
        return;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

@end
