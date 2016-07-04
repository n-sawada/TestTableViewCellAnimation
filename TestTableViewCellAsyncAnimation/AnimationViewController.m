//
//  AnimationViewController.m
//  TestTableViewCellAsyncAnimation
//
//  Created by Naoki_Sawada on 2016/07/03.
//  Copyright © 2016年 nsawada. All rights reserved.
//

#import "AnimationViewController.h"
#import "AnimationTableViewCell.h"

static NSString *ReuseIdentifer = @"AnimationCell";

@interface AnimationViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *animationTableView;

@end

@implementation AnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AnimationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdentifer forIndexPath:indexPath];
    
    [cell configureCell];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    CATransform3D transform = CATransform3DTranslate(CATransform3DIdentity, 0, 30, 0);
//    
//    cell.layer.transform = transform;
//    
//    cell.alpha = 0.2f;
//    
//    [UIView animateWithDuration:3.0f
//                          delay:0
//                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
//                     animations:^{
//                         cell.layer.transform = CATransform3DIdentity;
//                         cell.alpha = 1.0f;
//                     }
//                     completion:nil
//     ];
    
    
    //we create a view that will increase in size from top to bottom, thats why it starts with these frame parameters
    UIView *fillingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, cell.contentView.bounds.size.height)];
    //set the color we want to change to
    fillingView.backgroundColor = [UIColor blueColor];
    //add it to the view we want to change the color
    [cell.contentView addSubview:fillingView];
    
    [UIView animateWithDuration:2.0 animations:^{
        //this will make so the view animates up, since its animating the frame to the target view's size
        fillingView.frame = cell.contentView.bounds;
    } completion:^(BOOL finished) {
        //set the color we want and then disappear with the filling view.
        self.view.backgroundColor = [UIColor blueColor];
//        [fillingView removeFromSuperview];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
