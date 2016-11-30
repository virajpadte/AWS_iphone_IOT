//
//  ViewController.m
//  IotApp
//
//  Created by Viraj & Mayank  on 14/11/16.
//  Copyright © 2016 Bit2labz. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (weak, nonatomic) IBOutlet UILabel *xAxis;
@property (weak, nonatomic) IBOutlet UILabel *yAxis;
@property (weak, nonatomic) IBOutlet UILabel *zAxis;
@property (weak, nonatomic) IBOutlet UITextField *intervalText;
@property (weak, nonatomic) IBOutlet UITextView *displayLogText;

@end

@implementation ViewController
NSString *UDID;
float updateInterval = 0;
int UploadInterval = 3;
- (IBAction)updateIntervalTime:(id)sender {
    UploadInterval = [[_intervalText text] intValue];
    _displayLogText.text = [NSString stringWithFormat:@"%@\nNew Upload Interval:%i",_displayLogText.text,UploadInterval];
    [self scrollToBottom];
    [_intervalText resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.xAxis.text = @"";
    UDID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    self.motionManager = [[CMMotionManager alloc] init];
    
    self.motionManager.accelerometerUpdateInterval = 0.1;
    if ([self.motionManager isAccelerometerAvailable])// & [self.motionManager isAccelerometerActive])
    {
        NSLog(@"Accelerometer is active and available");
        _displayLogText.text = [NSString stringWithFormat:@"%@\nAccelerometer is active",_displayLogText.text];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [self.motionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error)
         
         {
             /*NSLog(@"X = %0.4f, Y = %.04f, Z = %.04f",
                   accelerometerData.acceleration.x,
                   accelerometerData.acceleration.y,
                   accelerometerData.acceleration.z);*/
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.xAxis.text = [NSString stringWithFormat:@"%.4f",accelerometerData.acceleration.x];
                 self.yAxis.text = [NSString stringWithFormat:@"%.4f",accelerometerData.acceleration.y];
                 self.zAxis.text = [NSString stringWithFormat:@"%.4f",accelerometerData.acceleration.z];
                 if(updateInterval>UploadInterval){
                     [self sendDataToServer:accelerometerData.acceleration.x :accelerometerData.acceleration.y :accelerometerData.acceleration.z];
                     updateInterval = 0;
                 }
                 else{
                     updateInterval=updateInterval+0.1;
                     
                 }
                 
             });
         }];
    }
    else{
        
        NSLog(@"not active");
        _displayLogText.text = [NSString stringWithFormat:@"%@\nAccelerometer is NOT active",_displayLogText.text];
    }
    
}

- (void)sendDataToServer:(float)xdata :(float)ydata :(float)zdata {
    
    NSURL *url = nil;
    NSMutableURLRequest *request = nil;
    NSString *getURL = [NSString stringWithFormat:@"%@?uid='%@'&xaxis=%.4f&yaxis=%.4f&zaxis=%.4f", @"http://<ChnagetoServerIP/domainname>/postdata.php",UDID, xdata, ydata, zdata ];
    url = [NSURL URLWithString: getURL];
    request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"GET"];
    [request addValue: @"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if( connection )
    {
        NSLog(@"Data Sent!");
        _displayLogText.text = [NSString stringWithFormat:@"%@\nData Sent %.4f,%.4f,%.4f",_displayLogText.text,xdata,ydata,zdata];
        [self scrollToBottom];
        mutableData = [NSMutableData new];
        
    }else{
        
        
        
    }
    
}
NSMutableData *mutableData;
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) connection:(NSURLConnection *) connection didReceiveResponse:(NSURLResponse *)response
{
    [mutableData setLength:0];
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [mutableData appendData:data];
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error in connection : %@",error);
    _displayLogText.text = [NSString stringWithFormat:@"%@\nConnection ERROR:%@",_displayLogText.text,error];
    [self scrollToBottom];
    return;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *responseStringWithEncoded = [[NSString alloc] initWithData: mutableData encoding:NSUTF8StringEncoding];
    NSLog(@"Response from Server : %@", responseStringWithEncoded);
    _displayLogText.text = [NSString stringWithFormat:@"%@\nResponse:%@",_displayLogText.text,responseStringWithEncoded];
    [self scrollToBottom];
}

-(void)scrollToBottom{
    NSRange range = NSMakeRange(_displayLogText.text.length - 1, 1);
    [_displayLogText scrollRangeToVisible:range];
}
@end
