//
//  AnimationTableViewCell.h
//  TestTableViewCellAsyncAnimation
//
//  Created by Naoki_Sawada on 2016/07/03.
//  Copyright © 2016年 nsawada. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnimationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *animationView;

- (void)configureCell;

@end
