//
//  ClusterTableViewCell.m
//  iOS_3D_ClusterAnnotation
//
//  Created by PC on 15/7/7.
//  Copyright (c) 2015年 FENGSHENG. All rights reserved.
//

#import "ClusterTableViewCell.h"

@implementation ClusterTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.tapBtn = [[UIButton alloc] initWithFrame:self.bounds];
        self.tapBtn.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.tapBtn];
    }
    
    return self;
}

@end
