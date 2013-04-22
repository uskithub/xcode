//
//  ViewController.m
//  MyReachability
//
//  Created by 斉藤 祐輔 on 13/04/22.
//  Copyright (c) 2013年 斉藤 祐輔. All rights reserved.
//

#import "ViewController.h"
#import "Reachability.h"

@interface ViewController ()

@end

@implementation ViewController
{
    Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;
    
    IBOutlet UILabel* summaryLabel;
    
    IBOutlet UITextField* remoteHostLabel;
    IBOutlet UIImageView* remoteHostIcon;
    IBOutlet UITextField* remoteHostStatusField;
    
    IBOutlet UIImageView* internetConnectionIcon;
    IBOutlet UITextField* internetConnectionStatusField;
    
    IBOutlet UIImageView* localWiFiConnectionIcon;
    IBOutlet UITextField* localWiFiConnectionStatusField;
}

- (void) configureTextField: (UITextField*) textField imageView: (UIImageView*) imageView reachability: (Reachability*) curReach
{
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    BOOL connectionRequired= [curReach connectionRequired];
    NSString* statusString= @"";
    switch (netStatus)
    {
        case NotReachable:
        {
            statusString = @"Access Not Available";
            imageView.image = [UIImage imageNamed: @"stop-32.png"] ;
            //Minor interface detail- connectionRequired may return yes, even when the host is unreachable.  We cover that up here...
            connectionRequired= NO;
            break;
        }
            
        case ReachableViaWWAN:
        {
            statusString = @"Reachable WWAN";
            imageView.image = [UIImage imageNamed: @"WWAN5.png"];
            break;
        }
        case ReachableViaWiFi:
        {
            statusString= @"Reachable WiFi";
            imageView.image = [UIImage imageNamed: @"Airport.png"];
            break;
        }
    }
    if(connectionRequired)
    {
        statusString= [NSString stringWithFormat: @"%@, Connection Required", statusString];
    }
    textField.text= statusString;
}

- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    if(curReach == hostReach)
	{
		[self configureTextField: remoteHostStatusField imageView: remoteHostIcon reachability: curReach];
        NetworkStatus netStatus = [curReach currentReachabilityStatus];
        BOOL connectionRequired= [curReach connectionRequired];
        
        summaryLabel.hidden = (netStatus != ReachableViaWWAN);
        NSString* baseLabel=  @"";
        if(connectionRequired)
        {
            baseLabel=  @"Cellular data network is available.\n  Internet traffic will be routed through it after a connection is established.";
        }
        else
        {
            baseLabel=  @"Cellular data network is active.\n  Internet traffic will be routed through it.";
        }
        summaryLabel.text= baseLabel;
    }
	if(curReach == internetReach)
	{
		[self configureTextField: internetConnectionStatusField imageView: internetConnectionIcon reachability: curReach];
	}
	if(curReach == wifiReach)
	{
		[self configureTextField: localWiFiConnectionStatusField imageView: localWiFiConnectionIcon reachability: curReach];
	}
	
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateInterfaceWithReachability: curReach];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    summaryLabel.hidden = YES;
    
    // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
    // method "reachabilityChanged" will be called.
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    //Change the host name here to change the server your monitoring
    remoteHostLabel.text = [NSString stringWithFormat: @"Remote Host: %@", @"www.apple.com"];
    
    hostReach = [Reachability reachabilityWithHostName: @"www.apple.com"];
    
	[hostReach startNotifier];
    
    [self updateInterfaceWithReachability: hostReach];
	
    
    
    internetReach = [Reachability reachabilityForInternetConnection];
	[internetReach startNotifier];
	[self updateInterfaceWithReachability: internetReach];
    

    wifiReach = [Reachability reachabilityForLocalWiFi];
	[wifiReach startNotifier];
	[self updateInterfaceWithReachability: wifiReach];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
