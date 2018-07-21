//
//  UITableView+NoDataPlaceholder.m
//  StandardMVVM
//
//  Created by 张绪川 on 2018/2/2.
//  Copyright © 2018年 张绪川. All rights reserved.
//

#import "UITableView+NoDataPlaceholder.h"
#import "XCNoDataPlaceholder.h"
#import <objc/runtime.h>

const char * imageDelegateKey_tb = "imageDelegateKey_tb";

BOOL xcPlaceholderNetState  = YES ;

@implementation UITableView (NoDataPlaceholder)

+ (void)load{

    Method old = class_getInstanceMethod(self, @selector(reloadData));
    Method current = class_getInstanceMethod(self, @selector(zxc_reloadData));
    method_exchangeImplementations(old, current);
}


-(void)zxc_reloadData{
    [self zxc_reloadData];
    if (self.firstReload) {
        [self refreshPlaceholderView];
    }
    self.firstReload = YES;
    
}



- (void)refreshPlaceholderView{
    
    //若两个都没有实现，则不继续执行
    if ( !([self.placeholderImageDelegate respondsToSelector:@selector(PlaceholderNoDataImage)] ||
           [self.placeholderImageDelegate respondsToSelector:@selector(PlaceholderNetErrorImage)] )) {
        return;
    }
    
    [self clearBackgroundView];
    
    //判断-有判断工具并且网络不正常
    if ( self.visibleCells.count <= 0 && !xcPlaceholderNetState ) {
        
        [self loadErrorBackgroundView];
        return;
    }
    
    if (self.visibleCells.count <= 0) {

        [self loadNormalBackgroundView];
    }
    
}




#pragma mark -

- (void)loadNormalBackgroundView{
    
    if (![self.placeholderImageDelegate respondsToSelector:@selector(PlaceholderNoDataImage)]  ) {
        return;
    }
    if (![self.placeholderImageDelegate PlaceholderNoDataImage] ) {
        return;
    }
    
    CGSize size = [self defaultPlaceholderSize];
    
    if ([self.placeholderImageDelegate respondsToSelector:@selector(PlaceholderImageSize)]) {
        size  = [self.placeholderImageDelegate PlaceholderImageSize];
    }
    
    UIImageView * normalView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,size.width , size.height)];
    normalView.center = [self makeOffsetWithPoint:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
    normalView.image = [[self.placeholderImageDelegate PlaceholderNoDataImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [self.backgroundView addSubview:normalView];
    [self addRefureshButton];
}

- (void)loadErrorBackgroundView{
    
    if (![self.placeholderImageDelegate respondsToSelector:@selector(PlaceholderNetErrorImage)]  ) {
        return;
    }
    
    UIImage * errNetImg ;
    UIImage * nodataImg ;
    if ([self.placeholderImageDelegate respondsToSelector:@selector(PlaceholderNetErrorImage)]) {
        errNetImg = [self.placeholderImageDelegate PlaceholderNetErrorImage];
    }else if ([self.placeholderImageDelegate respondsToSelector:@selector(PlaceholderNoDataImage)]) {
        nodataImg = [self.placeholderImageDelegate PlaceholderNoDataImage];
    }else {
        return;
    }
    
    UIImage * result = errNetImg != nil ? errNetImg : nodataImg;
    
    if (result == nil){
        return;
    }
    
    CGSize size = [self defaultPlaceholderSize];
    
    if ([self.placeholderImageDelegate respondsToSelector:@selector(PlaceholderImageSize)]) {
        size  = [self.placeholderImageDelegate PlaceholderImageSize];
    }
   
    UIImageView * normalView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0 ,size.width , size.height)];
    normalView.center = [self makeOffsetWithPoint:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
    normalView.image = [result imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [self.backgroundView addSubview:normalView];
    [self addRefureshButton];
}

- (void)addRefureshButton{
    
    if (!( [self.placeholderImageDelegate respondsToSelector:@selector(PlaceholderRefreshButton)] &&
        [self.placeholderImageDelegate PlaceholderRefreshButton] ) ) {
        return;
    }
    
    UIView * placeholderImgView = self.backgroundView.subviews.firstObject;
    
    UIButton * refreshButton = [self.placeholderImageDelegate PlaceholderRefreshButton];
    
    CGFloat y = refreshButton.bounds.size.height/2 + CGRectGetMaxY(placeholderImgView.frame) + 20;
    
    refreshButton.center = CGPointMake(placeholderImgView.center.x, y );
    
    [self.backgroundView addSubview:refreshButton];
    
}

- (void)clearBackgroundView{
    
    
    [self.backgroundView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    if (!self.backgroundView) {
        self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    }
}


#pragma mark -

- (CGSize)defaultPlaceholderSize{
    
    return CGSizeMake(200, 200);
}


- (CGPoint)makeOffsetWithPoint:(CGPoint)point{
    
    if (![self.placeholderImageDelegate respondsToSelector:@selector(PlaceholderOffset)]) return point;
    
    UIOffset offset = [self.placeholderImageDelegate PlaceholderOffset];
    point.x += offset.horizontal;
    point.y += offset.vertical;
    
    return point;
}

#pragma mark -

-(id<XCNoDataPlaceholderProtocol>)placeholderImageDelegate{
    return objc_getAssociatedObject(self, imageDelegateKey_tb);
}

-(void)setPlaceholderImageDelegate:(id<XCNoDataPlaceholderProtocol>)placeholderImageDelegate{
    objc_setAssociatedObject(self, imageDelegateKey_tb, placeholderImageDelegate, OBJC_ASSOCIATION_ASSIGN);
}


- (BOOL)firstReload {
    return [objc_getAssociatedObject(self, @selector(firstReload)) boolValue];
}

- (void)setFirstReload:(BOOL)firstReload {
    objc_setAssociatedObject(self, @selector(firstReload), @(firstReload), OBJC_ASSOCIATION_ASSIGN);
}



@end
