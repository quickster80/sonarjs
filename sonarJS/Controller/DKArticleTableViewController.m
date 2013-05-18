//
//  DKArticleTableViewController.m
//  echojs
//
//  Created by Damien Klinnert on 01.05.13.
//  Copyright (c) 2013 Damien Klinnert. All rights reserved.
//

#import "DKArticleTableViewController.h"
#import "DKArticleViewController.h"
#import "DKArticleTableViewCell.h"
#import "DKEchoJS.h"
#import "UIApplication+NetworkActivityManager.h"

#define DK_ARTICLE_START_INDEX 0
#define DK_ARTICLE_PAGE_COUNT 30

@interface DKArticleTableViewController ()
@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) DKEchoJS *echoJS;
@end

@implementation DKArticleTableViewController

#pragma mark - Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureCustomUI];
    
    // ios bug: we have to chain the target / action in code
    [self.refreshControl addTarget:self action:@selector(handlePullToRefresh) forControlEvents:UIControlEventValueChanged];
    
    [self loadData];
}



#pragma mark - Getters / Setters

- (void)setData:(NSMutableArray *)data
{
    _data = data;
    [self updateUI];
}

- (DKEchoJS *)echoJS
{
    if (!_echoJS) _echoJS = [[DKEchoJS alloc] init];
    return _echoJS;
}



#pragma mark - UI

- (void)configureCustomUI
{
    [self.tableView setContentInset:UIEdgeInsetsMake(10,0,10,0)];
}

- (void)updateUI
{    
    // complete reload, should be changed later to higher performance
    [self.tableView reloadData];
}



#pragma mark - Event handlers

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(DKArticleTableViewCell *)sender
{
    if ([segue.identifier isEqualToString:@"Show Article"]) {
        if ([segue.destinationViewController isKindOfClass:[DKArticleViewController class]]) {
            DKArticleViewController *destinationController = (DKArticleViewController *)segue.destinationViewController;
            
            NSIndexPath *selectedRowindexPath = [super.tableView indexPathForSelectedRow];
            
            destinationController.articleTitle = [self.data[selectedRowindexPath.row] objectForKey:@"title"];
            destinationController.articleUrl = [self.data[selectedRowindexPath.row] objectForKey:@"url"];
            destinationController.articleId = [[self.data[selectedRowindexPath.row] objectForKey:@"id"] integerValue];
            destinationController.articleComments = [[self.data[selectedRowindexPath.row] objectForKey:@"comments"] integerValue];
        }
    }
}

- (IBAction)handlePullToRefresh
{
    [self loadData];
}



#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Article";
    DKArticleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
    cell.articleTitle = [self.data[indexPath.item] objectForKey:@"title"];
    cell.articleUrl = [self.data[indexPath.item] objectForKey:@"url"];
    cell.articleUpvotes = [[self.data[indexPath.item] objectForKey:@"up"] integerValue];
    cell.articleDownvotes = [[self.data[indexPath.item] objectForKey:@"down"] integerValue];
    cell.articleComments = [[self.data[indexPath.item] objectForKey:@"comments"] integerValue];
    cell.articleCreated = [[self.data[indexPath.item] objectForKey:@"ctime"] integerValue];
    
    return cell;
}



#pragma mark - Helpers

- (IBAction)loadData
{
    [self.refreshControl beginRefreshing];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    
    [self.echoJS retrieveArticlesOrderedBy:DKEchoJSOrderModeTop startingAtIndex:DK_ARTICLE_START_INDEX withCount:DK_ARTICLE_PAGE_COUNT success:^(id articles){
        // this will update the ui, so we need to call it here!!
        self.data = articles;
        
        // all ui kit related code most go here, because it is NOT threadsave
        [self.refreshControl endRefreshing];
        
        [[UIApplication sharedApplication] hideNetworkActivityIndicator];
        
    }];
}

@end