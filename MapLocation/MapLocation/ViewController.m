//
//  ViewController.m
//  MapLocation
//
//  Created by Zzc on 15/7/28.
//  Copyright (c) 2015年 Zzc. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
@interface ViewController ()<MAMapViewDelegate,AMapSearchDelegate>
{
     MAMapView *_mapView;
    AMapSearchAPI *_search;
    NSInteger ii;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ii=0;
    NSLog(@"%@",[NSBundle mainBundle].bundleIdentifier);
    [MAMapServices sharedServices].apiKey = @"4a59ccc85e2177da01c97fc14442dd52";
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;    //YES 为打开定位，NO为关闭定位
    [_mapView setUserTrackingMode: MAUserTrackingModeFollowWithHeading animated:YES]; //地图跟着位置移动

    [self.view addSubview:_mapView];
    
        // Do any additional setup after loading the view, typically from a nib.
}
- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response
{
    if(response.pois.count == 0)
    {
        NSLog(@"失败！！！！");
        return;
    }
    
    //通过AMapPlaceSearchResponse对象处理搜索结果
    NSString *strSuggestion = [NSString stringWithFormat:@"Suggestion: %@", response.suggestion];
    NSLog(@"%@",strSuggestion);
    for (AMapPOI *p in response.pois)
    {
        NSLog(@"%@",p.location);
        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
        pointAnnotation.coordinate = CLLocationCoordinate2DMake(p.location.latitude, p.location.longitude);
        pointAnnotation.title = p.name;
        pointAnnotation.subtitle = p.address;
        
        [_mapView addAnnotation:pointAnnotation];
    }

}
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    if (ii==0) {
        //初始化检索对象
        _search = [[AMapSearchAPI alloc]initWithSearchKey:@"4a59ccc85e2177da01c97fc14442dd52" Delegate:self];
        //构造AMapPlaceSearchRequest对象，配置关键字搜索参数
        AMapPlaceSearchRequest *poiRequest = [[AMapPlaceSearchRequest alloc] init];
        poiRequest.searchType = AMapSearchType_PlaceAround;
        poiRequest.location = [AMapGeoPoint locationWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
        poiRequest.keywords = @"网吧";
        // types属性表示限定搜索POI的类别，默认为：餐饮服务、商务住宅、生活服务
        // POI的类型共分为20种大类别，分别为：
        // 汽车服务、汽车销售、汽车维修、摩托车服务、餐饮服务、购物服务、生活服务、体育休闲服务、
        // 医疗保健服务、住宿服务、风景名胜、商务住宅、政府机构及社会团体、科教文化服务、
        // 交通设施服务、金融保险服务、公司企业、道路附属设施、地名地址信息、公共设施
        poiRequest.types = @[@"网吧"];
        poiRequest.city = @[@"beijing"];
        poiRequest.requireExtension = YES;
        poiRequest.radius = 1000;
        //发起POI搜索
        [_search AMapPlaceSearch: poiRequest];
        ii = 1;
    }
    
    
    

}
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorRed;
        return annotationView;
    }
    return nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
