//
//  AnnotationClusterViewController.m
//  officialDemo2D
//
//  Created by yi chen on 14-5-15.
//  Copyright (c) 2014年 AutoNavi. All rights reserved.
//

#import "AnnotationClusterViewController.h"
#import "PoiDetailViewController.h"
#import "CoordinateQuadTree.h"
#import "ClusterAnnotation.h"
#import "ClusterAnnotationView.h"
#import "MAMapSMCalloutView.h"
#include "ClusterTableViewCell.h"

#define kCalloutViewMargin -8

@interface AnnotationClusterViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) CoordinateQuadTree* coordinateQuadTree;

@property (nonatomic, strong) MAMapSMCalloutView *customCalloutView;

@property (nonatomic, strong) NSMutableArray *selectedPoiArray;

@end

@implementation AnnotationClusterViewController

#pragma mark - update Annotation

/* 更新annotation. */
- (void)updateMapViewAnnotationsWithAnnotations:(NSArray *)annotations
{
    /* 用户滑动时，保留仍然可用的标注，去除屏幕外标注，添加新增区域的标注 */
    NSMutableSet *before = [NSMutableSet setWithArray:self.mapView.annotations];
    [before removeObject:[self.mapView userLocation]];
    NSSet *after = [NSSet setWithArray:annotations];
    
    /* 保留仍然位于屏幕内的annotation. */
    NSMutableSet *toKeep = [NSMutableSet setWithSet:before];
    [toKeep intersectSet:after];
    
    /* 需要添加的annotation. */
    NSMutableSet *toAdd = [NSMutableSet setWithSet:after];
    [toAdd minusSet:toKeep];
    
    /* 删除位于屏幕外的annotation. */
    NSMutableSet *toRemove = [NSMutableSet setWithSet:before];
    [toRemove minusSet:after];
    
    /* 更新. */
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView addAnnotations:[toAdd allObjects]];
        [self.mapView removeAnnotations:[toRemove allObjects]];
    });
}

- (void)addAnnotationsToMapView:(MAMapView *)mapView
{
    NSLog(@"calculate annotations.");
    if (self.coordinateQuadTree.root == nil)
    {
        NSLog(@"tree is not ready.");
        return;
    }

    /* 根据当前zoomLevel和zoomScale 进行annotation聚合. */
    double zoomScale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;

    NSArray *annotations = [self.coordinateQuadTree clusteredAnnotationsWithinMapRect:mapView.visibleMapRect
                                                                        withZoomScale:zoomScale
                                                                         andZoomLevel:mapView.zoomLevel];
    /* 更新annotation. */
    [self updateMapViewAnnotationsWithAnnotations:annotations];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.selectedPoiArray count];
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

    AMapPOI *poi = [self.selectedPoiArray objectAtIndex:indexPath.row];
    cell.textLabel.text = poi.name;
    cell.detailTextLabel.text = poi.address;

    [cell.tapBtn addTarget:self action:@selector(detailBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    cell.tapBtn.tag = indexPath.row;
    
    return cell;
}

#pragma mark - TapGesture

- (void)detailBtnTap:(UIButton *)button
{
    PoiDetailViewController *detail = [[PoiDetailViewController alloc] init];
    detail.poi = self.selectedPoiArray[button.tag];

    /* 进入POI详情页面. */
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view
{
    [self.customCalloutView dismissCalloutAnimated:YES];
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    ClusterAnnotation *annotation = (ClusterAnnotation *)view.annotation;
    [self.selectedPoiArray removeAllObjects];
    for (AMapPOI *poi in annotation.pois)
    {
        [self.selectedPoiArray addObject:poi];
    }

    [self.mapView setCenterCoordinate:view.annotation.coordinate animated:YES];
    
    self.customCalloutView = [[MAMapSMCalloutView alloc] init];

    /* 设置弹出AnnotationView */
    CGFloat height = 44*self.selectedPoiArray.count + 20 > 200 ? 200 : 44*self.selectedPoiArray.count + 20;
    self.customCalloutView.calloutHeight = height;
    
    UITableView *poiListView    = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 260, height-20)
                                                               style:UITableViewStylePlain];
    
    poiListView.separatorColor  = [UIColor colorWithRed:105.0/255.0 green:105.0/255.0 blue:105.0/255.0 alpha:1.0];
    poiListView.delegate        = self;
    poiListView.dataSource      = self;
    poiListView.backgroundColor = [UIColor clearColor];
    _customCalloutView.rightAccessoryView = poiListView;
    _customCalloutView.subviewClass       = [UITableView class];
    
    _customCalloutView.backgroundImage    = [UIImage imageNamed:@"map_bubble"];
    
    [_customCalloutView presentCalloutFromRect:CGRectMake(view.bounds.origin.x, view.bounds.origin.y,
                                                          view.bounds.size.width, 100)
                                        inView:view
                             constrainedToView:self.view
                      permittedArrowDirections:MAMapSMCalloutArrowDirectionDown
                                      animated:YES];
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    /* mapView区域变化时重算annotation. */
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self addAnnotationsToMapView:self.mapView];
    });

}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[ClusterAnnotation class]])
    {
        /* dequeue重用annotationView. */
        static NSString *const AnnotatioViewReuseID = @"AnnotatioViewReuseID";
        
        ClusterAnnotationView *annotationView = (ClusterAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotatioViewReuseID];
        
        if (!annotationView)
        {
            annotationView = [[ClusterAnnotationView alloc] initWithAnnotation:annotation
                                                               reuseIdentifier:AnnotatioViewReuseID];
        }
        
        /* 设置annotationView的属性. */
        annotationView.annotation = annotation;
        annotationView.count = [(ClusterAnnotation *)annotation count];
        
        /* 不弹出原生annotation */
        annotationView.canShowCallout = NO;
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    /* 为新添的annotationView添加弹出动画. */
    for (UIView *view in views)
    {
        ClusterAnnotationView *annotationView = (ClusterAnnotationView*)view;
        [annotationView addBounceAnnimation];
    }
}

#pragma mark - SearchPOI

/* 搜索POI. */
- (void)searchPoiWithKeyword:(NSString *)keyword
{
    AMapPlaceSearchRequest *request = [[AMapPlaceSearchRequest alloc] init];
    
    request.searchType          = AMapSearchType_PlaceKeyword;
    request.keywords            = keyword;
    request.city                = @[@"010"];
    request.requireExtension    = YES;
    
    [self.search AMapPlaceSearch:request];
}

/* POI 搜索回调. */
- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)respons
{
    if (respons.pois.count == 0)
    {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        /* 建立四叉树. */
        [self.coordinateQuadTree buildTreeWithPOIs:respons.pois];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            /* 建树完成，计算当前mapView区域内需要显示的annotation. */
            NSLog(@"First time calculate annotations.");
            [self addAnnotationsToMapView:self.mapView];

        });
    });
    
    /* 如果只有一个结果，设置其为中心点. */
    if (respons.pois.count == 1)
    {
        self.mapView.centerCoordinate = [respons.pois[0] coordinate];
    }
    /* 如果有多个结果, 设置地图使所有的annotation都可见. */
    else
    {
        [self.mapView showAnnotations:self.mapView.annotations animated:NO];
    }
}

#pragma mark - Life Cycle

- (id)init
{
    if (self = [super init])
    {
        self.coordinateQuadTree = [[CoordinateQuadTree alloc] init];
        
        self.selectedPoiArray = [[NSMutableArray alloc] init];
        
        [self setTitle:@"Cluster Annotations"];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self searchPoiWithKeyword:@"Apple"];
}

- (void)dealloc
{
    [self.coordinateQuadTree clean];
}

@end
