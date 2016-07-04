//
//  AsyncCell.h
//  TestTableViewCellAsyncAnimation
//
//  Created by Naoki_Sawada on 2016/07/02.
//  Copyright © 2016年 nsawada. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ConfigureCompletionBlock)();

@class AppRecord;

@interface AsyncCell : UITableViewCell
//@property (weak, nonatomic) IBOutlet UIView *asyncImageView;
@property (weak, nonatomic) IBOutlet UIImageView *asyncImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
//@property (copy, nonatomic) ConfigureCompletionBlock configureCompletion;

- (void)configureCell:(AppRecord *)appRecord ConfigureCompetion:(ConfigureCompletionBlock)configureCompletion;

@end
