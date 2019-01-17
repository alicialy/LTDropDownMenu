//
//  ChildTableViewController.m
//  LTViewPager
//
//  Created by Alicia on 16/10/9.
//  Copyright © 2016年 leafteam. All rights reserved.
//

#import "ChildTableViewController.h"


static  NSString * const kChildReuseId = @"ChildCell";

@interface ChildTableViewController ()

@end

@implementation ChildTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kChildReuseId];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"in View Will Apperear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kChildReuseId forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %ld", self.title, indexPath.row];
    return cell;
}

@end
