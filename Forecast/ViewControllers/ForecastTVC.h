//
//  ForecastTVC.h
//  Forecast
//
//  Created by Grzegorz Górnisiewicz on 12.01.2017.
//  Copyright © 2017 Long Road. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForecastTVC : UITableViewController {
    NSMutableArray *citiesToLoad;
    NSMutableDictionary *citiesLoaded;
    NSMutableDictionary *tasks;
}

@end
