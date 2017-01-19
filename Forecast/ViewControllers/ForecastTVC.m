//
//  ForecastTVC.m
//  Forecast
//
//  Created by Grzegorz Górnisiewicz on 12.01.2017.
//  Copyright © 2017 Long Road. All rights reserved.
//

#import "ForecastTVC.h"
#import "CityForecastCellView.h"

@interface ForecastTVC ()

@end

@implementation ForecastTVC

const NSString *baseUrl = @"http://api.openweathermap.org/data/2.5/";
const NSString *forecast = @"forecast";
const NSString *paramCity = @"q";
const NSString *paramUnits = @"units";
const NSString *paramAppid = @"appid";
const NSString *metricUnits = @"metric";
const NSString *appid = @"aa8e99639498784452c941728c28910f";

static NSString *reuseIdentifier = @"CityForecastCellView";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    citiesToLoad = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"citiesToLoad"].mutableCopy;
    
    if (!citiesToLoad) {
        citiesToLoad = @[@"Helsinki", @"Moscow", @"Cracow", @"London", @"Belfast", @"Paris", @"Madrid", @"Cork", @"Glasgow", @"Poznań", @"Kiev"].mutableCopy;
    }
    
    citiesLoaded = @{}.mutableCopy;
    
    tasks = @{}.mutableCopy;
    
    [self.tableView registerClass:[CityForecastCellView class] forCellReuseIdentifier:reuseIdentifier];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.25 green:0.45 blue:0.65 alpha:1.0];
    
    for (NSInteger i = 0; i < citiesToLoad.count; i++) {
        [self prepareTask:[NSIndexPath indexPathForRow:i inSection:0]];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (NSString*) prepareURL:(NSDictionary *)params {
    NSString *url = @"";

    NSCharacterSet *expectedCharacterSet = [NSCharacterSet URLQueryAllowedCharacterSet];

    url = [url stringByAppendingString:[params objectForKey:@"baseUrl"]];
    url = [url stringByAppendingString:[params objectForKey:@"function"]];

    url = [url stringByAppendingString:@"?units="];
    url = [url stringByAppendingString:[params objectForKey:@"units"]];

    url = [url stringByAppendingString:@"&q="];
    url = [url stringByAppendingString:[params objectForKey:@"city"]];

    url = [url stringByAppendingString:@"&lang="];
    NSLog(@"localeIdentifier: %@", [[NSLocale currentLocale] languageCode]);
    url = [url stringByAppendingString:[[NSLocale currentLocale] languageCode].lowercaseString];

    url = [url stringByAppendingString:@"&appid="];
    url = [url stringByAppendingString:[params objectForKey:@"appid"]];

    return [url stringByAddingPercentEncodingWithAllowedCharacters:expectedCharacterSet];
}

- (void) parseData:(NSData*) data {

    //NSLog(@"object:%@", object);

}

- (void) prepareTask:(NSIndexPath *)indexPath {
    NSURLSessionDataTask *dataTask;
    
    NSString *city = [citiesToLoad objectAtIndex:indexPath.row];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    NSURL *url = [NSURL URLWithString:
                    [self prepareURL:
                        @{
                          @"baseUrl":baseUrl
                          , @"function":forecast
                          , @"units": metricUnits
                          , @"city": city
                          , @"appid":appid
                          }
                     ]
                  ];

    dataTask = (NSURLSessionDataTask*)[tasks valueForKey:city];

    if (dataTask) {
        [dataTask cancel];
    }

    dataTask = [session
                    dataTaskWithURL:url
                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
                        {
                            if (error) {
                                NSLog(@"error: %@", [error localizedDescription]);
                            } else if (response && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                NSError *error;
                                id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                                [citiesLoaded setValue:object forKey:city];
                                if (!error) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self.tableView beginUpdates];
                                        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                        [self.tableView endUpdates];
                                    });
                                }
                            }
                        }
                ];

    [tasks setValue:dataTask forKey:city];

    [dataTask resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [citiesToLoad count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CityForecastCellView *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.cityNameLabel.text = [citiesToLoad objectAtIndex:indexPath.row];
    [cell updateCell:[citiesLoaded valueForKey: [citiesToLoad objectAtIndex:indexPath.row]]];

    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
