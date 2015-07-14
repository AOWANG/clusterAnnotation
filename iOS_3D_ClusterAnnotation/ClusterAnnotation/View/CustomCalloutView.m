//
//  CustomCalloutView.m
//  iOS_3D_ClusterAnnotation
//
//  Created by PC on 15/7/9.
//  Copyright (c) 2015年 FENGSHENG. All rights reserved.
//

#import "CustomCalloutView.h"
#import "ClusterTableViewCell.h"


const NSInteger kArrorHeight = 10;

const CGFloat kAnnotationCircleRaduis = 13.5;

const NSInteger kWidth = 260;
const NSInteger kMaxHeight = 200;

const NSInteger kTableViewHoriMargin = 5;
const NSInteger kTableViewBottomMargin = 12;

const NSInteger kCellHeight = 44;


@interface CustomCalloutView()

@property (nonatomic, strong) UITableView *tableview;

@end

@implementation CustomCalloutView

- (void)setPoiArray:(NSArray *)poiArrayy
{
    _poiArray = [NSArray arrayWithArray:poiArrayy];
    
    CGFloat height = kCellHeight*self.poiArray.count + kTableViewBottomMargin > kMaxHeight ? kMaxHeight : kCellHeight*self.poiArray.count + kTableViewBottomMargin;

    self.frame = CGRectMake(-kWidth/2+kAnnotationCircleRaduis, -height, kWidth, height);
    
    self.tableview.frame = CGRectMake(kTableViewHoriMargin, 0, self.bounds.size.width-kTableViewHoriMargin*2, self.bounds.size.height-kArrorHeight);
    [self.tableview reloadData];
}

- (void)dismissCalloutView
{
    [self removeFromSuperview];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.poiArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ClusterCell";
    ClusterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell  == nil)
    {
        cell = [[ClusterTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                           reuseIdentifier:identifier];
    }

    AMapPOI *poi = [self.poiArray objectAtIndex:indexPath.row];
    cell.textLabel.text = poi.name;
    cell.detailTextLabel.text = poi.address;
    
    [cell.tapBtn addTarget:self action:@selector(detailBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    cell.tapBtn.tag = indexPath.row;
    
    return cell;
}

#pragma mark - TapGesture

- (void)detailBtnTap:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(didDetailButtonTapped:)])
    {
        [self.delegate didDetailButtonTapped:button.tag];
    }
}

#pragma mark - draw rect

- (void)drawRect:(CGRect)rect
{
    [self drawInContext:UIGraphicsGetCurrentContext()];
    
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
}

- (void)drawInContext:(CGContextRef)context
{
    CGContextSetLineWidth(context, 3.0);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:1 green:1 blue:1 alpha:1].CGColor);
    
    [self getDrawPath:context];
    CGContextFillPath(context);
}

- (void)getDrawPath:(CGContextRef)context
{
    CGRect rrect = self.bounds;
    CGFloat radius = 6.0;
    CGFloat minx = CGRectGetMinX(rrect),
    midx = CGRectGetMidX(rrect),
    maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect),
    maxy = CGRectGetMaxY(rrect)-kArrorHeight;
    
    CGContextMoveToPoint(context, midx+kArrorHeight, maxy);
    CGContextAddLineToPoint(context,midx, maxy+kArrorHeight);
    CGContextAddLineToPoint(context,midx-kArrorHeight, maxy);

    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx+kArrorHeight, maxy, radius);
    CGContextClosePath(context);
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];

        self.tableview = [[UITableView alloc] init];
        self.tableview.delegate = self;
        self.tableview.dataSource = self;
        
        [self addSubview:self.tableview];
    }
    return self;
}



@end
