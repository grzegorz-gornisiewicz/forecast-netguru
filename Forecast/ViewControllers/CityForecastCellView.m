//
//  CityForecastCellView.m
//  Forecast
//
//  Created by Grzegorz Górnisiewicz on 12.01.2017.
//  Copyright © 2017 Long Road. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CityForecastCellView.h"
#import "PureLayout.h"
#import "PINImageView+PINRemoteImage.h"
#import <OpenSans/UIFont+OpenSans.h>

@implementation CityForecastCellView

const NSString *imagesBaseUrl = @"http://openweathermap.org/img/w/";

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSLog(@"Have you been calling me?");
        reuseId = reuseIdentifier;
        if (!_indicator) {
            _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [_indicator setHidesWhenStopped:YES];
            [self addSubview:_indicator];
            [_indicator autoCenterInSuperviewMargins];
        }
        
        if (!_cityNameLabel) {
            _cityNameLabel = [[UILabel alloc] initWithFrame:self.frame];
            _cityNameLabel.layer.cornerRadius = 2.0f;
            _cityNameLabel.layer.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25].CGColor;
            _cityNameLabel.layer.shadowRadius = 5.0f;
            _cityNameLabel.clipsToBounds = YES;
            _cityNameLabel.text = @"-";
            _cityNameLabel.textAlignment = NSTextAlignmentCenter;
            _cityNameLabel.textColor = [UIColor whiteColor];
            _cityNameLabel.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
            _cityNameLabel.font = [UIFont openSansSemiBoldFontOfSize:14.0f];
            [_cityNameLabel sizeToFit];
            CGRect frame = _cityNameLabel.frame;
            frame.size.width = self.frame.size.width;
            _cityNameLabel.frame = frame;
            [self.contentView addSubview:_cityNameLabel];
            [_cityNameLabel autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeBottom];
        }

        [self setBackgroundColor: [UIColor clearColor]];
        [self.contentView setTranslatesAutoresizingMaskIntoConstraints:YES];
    }

    return self;
}

- (void) updateCell:(NSDictionary*) jsonObject {
    if (jsonObject) {
        [_indicator stopAnimating];

        //prepare scroll view
        CGRect frame = self.contentView.frame;
        UIScrollView *scrollView = [self viewWithTag:100];
        scrollView.layer.cornerRadius = 2.0f;
        scrollView.clipsToBounds = YES;
        if (!scrollView) {
            scrollView = [[UIScrollView alloc] init];
            scrollView.tag = 100;
            
            [self.contentView addSubview:scrollView];
            [scrollView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16.0f];
            [scrollView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16.0f];
            [scrollView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:30.0f];
            [scrollView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0f];
            scrollView.showsHorizontalScrollIndicator = NO;
            scrollView.showsVerticalScrollIndicator = NO;
        }
        
        NSString *country = [jsonObject valueForKeyPath:@"city.country"];
        _cityNameLabel.text = [NSString stringWithFormat:@"%@ (%@)", _cityNameLabel.text, country];
        
        NSArray *list = [jsonObject valueForKeyPath:@"list"];
        NSInteger index = 0;
        CGRect tileFrame = CGRectMake(0, 0, 100, self.contentView.frame.size.height - _cityNameLabel.frame.size.height);
        for (id data in list) {
            NSNumber *dt = [data valueForKey:@"dt"];
            NSNumber *temp = [data valueForKeyPath:@"main.temp"];
            NSString *weatherDescription = [[[data valueForKey:@"weather"] firstObject] valueForKey:@"description"];
            NSString *weatherIcon = [[[data valueForKey:@"weather"] firstObject] valueForKey:@"icon"];
            NSString *hour = [NSDateFormatter localizedStringFromDate:[NSDate dateWithTimeIntervalSince1970:dt.integerValue] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];

            tileFrame.origin.x = index * (tileFrame.size.width);
            UIView *tile = [scrollView viewWithTag:1000 + index];
            if (!tile) {
                tile = [[UIView alloc] initWithFrame:tileFrame];
                tile.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.25f];
                tile.tag = 1000 + index;
            }

            UILabel *hourLabel = [tile viewWithTag:2000 + index];
            if (!hourLabel) {
                hourLabel = [[UILabel alloc] initForAutoLayout];
                hourLabel.textAlignment = NSTextAlignmentCenter;
                hourLabel.textColor = [UIColor whiteColor];
                hourLabel.tag = 2000 + index;
                hourLabel.font = [UIFont openSansFontOfSize:10.0f];
                [tile addSubview:hourLabel];
                [hourLabel autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeBottom];
                [hourLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:4.0f];
            }
            
            hourLabel.text = hour;

            UILabel *tempLabel = [tile viewWithTag:3000 + index];
            if (!tempLabel) {
                tempLabel = [[UILabel alloc] initForAutoLayout];
                tempLabel.tag = 3000 + index;
                tempLabel.textAlignment = NSTextAlignmentCenter;
                tempLabel.textColor = [UIColor whiteColor];
                tempLabel.font = [UIFont openSansBoldFontOfSize:20.0f];
                [tile addSubview:tempLabel];
                [tempLabel autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeBottom];
                [tempLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:18.0f];
            }
            
            tempLabel.text = [NSString stringWithFormat:@"%.0f°", [temp floatValue]];

            UIImageView *imageView = [tile viewWithTag:4000 + index];
            if (!imageView) {
                imageView = [[UIImageView alloc] initForAutoLayout];
                imageView.tag = 4000 + index;
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                [tile addSubview:imageView];
                [imageView autoSetDimensionsToSize:CGSizeMake(40, 40)];
                [imageView autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeTop];
                [imageView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:19.0f];
            }

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSString *urlString = [NSString stringWithFormat:@"%@%@.png", imagesBaseUrl, weatherIcon];
                [imageView pin_cancelImageDownload];
                [imageView pin_setImageFromURL:[NSURL URLWithString:urlString]];
            });
            
            UILabel *descLabel = [tile viewWithTag:5000 + index];
            if (!descLabel) {
                descLabel = [[UILabel alloc] initForAutoLayout];
                descLabel.tag = 5000 + index;
                descLabel.textAlignment = NSTextAlignmentCenter;
                descLabel.textColor = [UIColor whiteColor];
                descLabel.font = [UIFont openSansFontOfSize:10.0f];
                [tile addSubview:descLabel];
                [descLabel autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeTop];
                [descLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:14.0f];
            }
            
            descLabel.text = weatherDescription;

            [scrollView addSubview:tile];
            index += 1;
        }

        scrollView.contentSize = CGSizeMake(index * tileFrame.size.width, scrollView.frame.size.height);
    } else {
        [_indicator startAnimating];
    }
}


@end
