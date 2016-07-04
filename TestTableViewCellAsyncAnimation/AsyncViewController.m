//
//  AsyncViewController.m
//  TestTableViewCellAsyncAnimation
//
//  Created by Naoki_Sawada on 2016/07/02.
//  Copyright © 2016年 nsawada. All rights reserved.
//

#import "AsyncViewController.h"
#import "AppRecord.h"
#import "IconDownloader.h"
#import "ParseOperation.h"
#import "AsyncCell.h"

#define kCustomRowCount 7

static NSString *CellIdentifier = @"AsyncCell";
static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";

static NSString *const TopPaidAppsFeed =
@"http://phobos.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/toppaidapplications/limit=75/xml";


@interface AsyncViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

// the set of IconDownloader objects for each app
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

// the queue to run our "ParseOperation"
@property (nonatomic, strong) NSOperationQueue *queue;

// the NSOperation driving the parsing of the RSS feed
@property (nonatomic, strong) ParseOperation *parser;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AsyncViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:TopPaidAppsFeed]];
    
    // create an session data task to obtain and the XML feed
    NSURLSessionDataTask *sessionTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                            // in case we want to know the response status code
                                                                            //NSInteger HTTPStatusCode = [(NSHTTPURLResponse *)response statusCode];
                                                                            
                                                                            
                                                                            if (error != nil)
                                                                            {
                                                                                [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
                                                                                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                                                    
                                                                                    if ([error code] == NSURLErrorAppTransportSecurityRequiresSecureConnection)
                                                                                    {
                                                                                        // if you get error NSURLErrorAppTransportSecurityRequiresSecureConnection (-1022),
                                                                                        // then your Info.plist has not been properly configured to match the target server.
                                                                                        //
                                                                                        abort();
                                                                                    }
                                                                                    else
                                                                                    {
                                                                                        [self handleError:error];
                                                                                    }
                                                                                }];
                                                                            }
                                                                            else
                                                                            {
                                                                                // create the queue to run our ParseOperation
                                                                                self.queue = [NSOperationQueue new];
                                                                                
                                                                                // create an ParseOperation (NSOperation subclass) to parse the RSS feed data so that the UI is not blocked
                                                                                _parser = [[ParseOperation alloc] initWithData:data];
                                                                                
                                                                                __weak typeof(self)weakSelf = self;
                                                                                
                                                                                self.parser.errorHandler = ^(NSError *parseError) {
                                                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                                                        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                                                        [weakSelf handleError:parseError];
                                                                                    });
                                                                                };
                                                                                
                                                                                // referencing parser from within its completionBlock would create a retain cycle
                                                                                
                                                                                [self.queue addOperation:self.parser]; // this will start the "ParseOperation"
                                                                                
                                                                                __weak typeof(ParseOperation)*weakParser = self.parser;
                                                                                
                                                                                self.parser.completionBlock = ^(void) {
                                                                                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                                                    if (weakParser.appRecordList != nil)
                                                                                    {
                                                                                        // The completion block may execute on any thread.  Because operations
                                                                                        // involving the UI are about to be performed, make sure they execute on the main thread.
                                                                                        //
                                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                                                            
                                                                                            weakSelf.entries = weakParser.appRecordList;
                                                                                            
                                                                                            // tell our table view to reload its data, now that parsing has completed
                                                                                            [weakSelf.tableView reloadData];
                                                                                        });
                                                                                    }
                                                                                    
                                                                                    // we are finished with the queue and our ParseOperation
                                                                                    weakSelf.queue = nil;
                                                                                };
                                                                                
                                                                            }
                                                                        }];
    
    [sessionTask resume];
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    _imageDownloadsInProgress = [NSMutableDictionary dictionary];
}

// -------------------------------------------------------------------------------
//	terminateAllDownloads
// -------------------------------------------------------------------------------
- (void)terminateAllDownloads
{
    // terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    [self.imageDownloadsInProgress removeAllObjects];
}

// -------------------------------------------------------------------------------
//	dealloc
//  If this view controller is going away, we need to cancel all outstanding downloads.
// -------------------------------------------------------------------------------
- (void)dealloc
{
    // terminate all pending download connections
    [self terminateAllDownloads];
}

// -------------------------------------------------------------------------------
//	didReceiveMemoryWarning
// -------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // terminate all pending download connections
    [self terminateAllDownloads];
}


#pragma mark - UITableViewDataSource

// -------------------------------------------------------------------------------
//	tableView:numberOfRowsInSection:
//  Customize the number of rows in the table view.
// -------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count = self.entries.count;
    return count == 0 ? kCustomRowCount : count;
}

// -------------------------------------------------------------------------------
//	tableView:cellForRowAtIndexPath:
// -------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    NSUInteger nodeCount = self.entries.count;
    
    if (nodeCount == 0 && indexPath.row == 0)
    {
        // add a placeholder cell while waiting on table data
        cell = [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier forIndexPath:indexPath];
        return cell;
    }
    else
    {
        AsyncCell *asyncCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        // Leave cells empty if there's no data yet
        if (nodeCount > 0)
        {
            // Set up the cell representing the app
            AppRecord *appRecord = self.entries[indexPath.row];
            
            [asyncCell configureCell:appRecord ConfigureCompetion:^{
                
                if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
                {
                    [self startIconDownload:appRecord forIndexPath:indexPath];
                }
                // if a download is deferred or in progress, return a placeholder image
                asyncCell.asyncImageView.image = [UIImage imageNamed:@"Placeholder.png"];

            }];
        }
        
        return asyncCell;
    }
    
    return cell;
}


#pragma mark - Table cell image support

// -------------------------------------------------------------------------------
//	startIconDownload:forIndexPath:
// -------------------------------------------------------------------------------
- (void)startIconDownload:(AppRecord *)appRecord forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = (self.imageDownloadsInProgress)[indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.appRecord = appRecord;
        (self.imageDownloadsInProgress)[indexPath] = iconDownloader;
        [iconDownloader startDownload];
        
        iconDownloader.completionHandler = ^{
            
            AsyncCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            // Display the newly loaded image
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.asyncImageView.image = appRecord.appIcon;
            });
            
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
            
        };
        
    }
}

// -------------------------------------------------------------------------------
//	loadImagesForOnscreenRows
//  This method is used in case the user scrolled into a set of cells that don't
//  have their app icons yet.
// -------------------------------------------------------------------------------
- (void)loadImagesForOnscreenRows
{
    if (self.entries.count > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            AppRecord *appRecord = self.entries[indexPath.row];
            
            if (!appRecord.appIcon)
                // Avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:appRecord forIndexPath:indexPath];
            }
        }
    }
}


#pragma mark - UIScrollViewDelegate

// -------------------------------------------------------------------------------
//	scrollViewDidEndDragging:willDecelerate:
//  Load images for all onscreen rows when scrolling is finished.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self loadImagesForOnscreenRows];
    }
}

// -------------------------------------------------------------------------------
//	scrollViewDidEndDecelerating:scrollView
//  When scrolling stops, proceed to load the app icons that are on screen.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}


- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    
    // alert user that our current record was deleted, and then we leave this view controller
    //
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Show Top Paid Apps"
                                                                   message:errorMessage
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         // dissmissal of alert completed
                                                     }];
    
    [alert addAction:OKAction];
    [self presentViewController:alert animated:YES completion:nil];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
