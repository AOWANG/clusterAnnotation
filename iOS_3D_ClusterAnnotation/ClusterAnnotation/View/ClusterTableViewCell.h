//
//  ClusterTableViewCell.h
//  iOS_3D_ClusterAnnotation
//
//  Created by PC on 15/7/7.
//  Copyright (c) 2015年 FENGSHENG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClusterTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitle;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;

@end
