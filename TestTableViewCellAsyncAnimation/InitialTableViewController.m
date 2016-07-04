//
//  InitialTableViewController.m
//  TestTableViewCellAsyncAnimation
//
//  Created by Naoki_Sawada on 2016/07/02.
//  Copyright © 2016年 nsawada. All rights reserved.
//

#import "InitialTableViewController.h"

typedef NS_ENUM(NSInteger, SomeCells) {
    
    AsyncCell = 0,
    AnimationCell,
    LazyBlurCell
};

@interface InitialTableViewController ()

@end

@implementation InitialTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SomeCells someCells = indexPath.row;
    
    UITableViewCell *cell;
    
    switch (someCells) {
        case AsyncCell: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"AsyncCell"];
            cell.textLabel.text = @"AsyncCell";
            break;
        }
        case AnimationCell: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"AnimationCell"];
            cell.textLabel.text = @"AnimationCell";
            break;
        }
        case LazyBlurCell: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"LazyBlurCell"];
            cell.textLabel.text = @"LazyBlurCell";
            break;
        }
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
