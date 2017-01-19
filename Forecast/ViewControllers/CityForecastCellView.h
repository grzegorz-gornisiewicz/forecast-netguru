//
//  CityForecastCellView.h
//  Forecast
//
//  Created by Grzegorz Górnisiewicz on 12.01.2017.
//  Copyright © 2017 Long Road. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityForecastCellView : UITableViewCell {
    NSString *reuseId;
}

@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UILabel *cityNameLabel;

- (void) updateCell:(NSDictionary*)jsonObject;

@end
