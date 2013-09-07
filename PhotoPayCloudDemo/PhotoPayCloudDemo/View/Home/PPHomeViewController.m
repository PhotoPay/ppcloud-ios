//
//  PPHomeViewController.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPHomeViewController.h"
#import "PPDocumentsDataSource.h"

@interface PPHomeViewController () <UITableViewDelegate>

@property (nonatomic, strong) PPDocumentsDataSource* documentsDataSource;

- (void)reloadTableWithDocuments:(NSArray*)documents;

@end

@implementation PPHomeViewController

@synthesize documentsDataSource;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:_(@"PhotoPayHomeTitle")];
    
    documentsDataSource = [[PPDocumentsDataSource alloc] init];
    
    [[self billsTable] setDataSource:[self documentsDataSource]];
    [[self billsTable] setDelegate:self];
}

- (void)viewDidUnload {
    [self setDocumentsDataSource:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //To clear any selection in the table view before it’s displayed,
    // implement the viewWillAppear: method to clear the selected row
    // (if any) by calling deselectRowAtIndexPath:animated:.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    PPDocument *doc1 = [[PPDocument alloc] init];
    PPDocument *doc2 = [[PPDocument alloc] init];
    PPDocument *doc3 = [[PPDocument alloc] init];
    PPDocument *doc4 = [[PPDocument alloc] init];
    PPDocument *doc5 = [[PPDocument alloc] init];
    
    NSArray* documents = [[NSArray alloc] initWithObjects:doc1, doc2, doc3, doc4, doc5, nil];
    
    [self reloadTableWithDocuments:documents];
    
    // flash the scroll view’s scroll indicators
    [[self billsTable] flashScrollIndicators];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadTableWithDocuments:(NSArray*)documents {
    [[self documentsDataSource] setDocuments:documents];
    [[self billsTable] reloadData];
}

+ (NSString*)defaultXibName {
    if (IS_IPAD) {
        return @"PPHomeViewController_iPad";
    } else {
        return @"PPHomeViewController_iPhone";
    }
}

- (IBAction)cameraButtonPressed:(id)sender {
    DDLogInfo(@"Camera pressed!");
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogInfo(@"Selected cell %d", [indexPath row]);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
