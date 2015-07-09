//
//  CustomCalloutView.h
//  iOS_3D_ClusterAnnotation
//
//  Created by PC on 15/7/9.
//  Copyright (c) 2015年 FENGSHENG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapSearchKit/AMapCommonObj.h>

@protocol CustomCalloutViewTapDelegate <NSObject>

- (void)detailButtonTap:(NSInteger)index;

@end



@interface CustomCalloutView : UIView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *poiArray;

@property (nonatomic, weak) id<CustomCalloutViewTapDelegate> delegate;

- (void)dismissCalloutView;

- (void)setPoiArray:(NSArray *)poiArray;

@end
