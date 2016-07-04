//
//  AsyncCell.m
//  TestTableViewCellAsyncAnimation
//
//  Created by Naoki_Sawada on 2016/07/02.
//  Copyright © 2016年 nsawada. All rights reserved.
//

#import "AsyncCell.h"
#import "AppRecord.h"

@implementation AsyncCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCell:(AppRecord *)appRecord ConfigureCompetion:(ConfigureCompletionBlock)configureCompletion {
    
    _titleLabel.text = appRecord.appName;
    
    if (appRecord.appIcon != nil) {
        _asyncImageView.image = appRecord.appIcon;
    } else {
        configureCompletion();
    }
}

@end
