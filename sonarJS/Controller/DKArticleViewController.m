//
//  DKArticleViewController.m
//  echojs
//
//  Created by Damien Klinnert on 01.05.13.
//  Copyright (c) 2013 Damien Klinnert. All rights reserved.
//

#import "DKArticleViewController.h"
#import "DKCommentsTableViewController.h"
#import "UIApplication+NetworkActivityManager.h"
#import "TUSafariActivity.h"
#import "ARChromeActivity.h"
#import "UIBarButtonItem+FlatUI.h"

#define DK_DEFAULTS_ARTICLE_ENABLED @"articleEnabled"

@interface DKArticleViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *commentsButton;
@property (weak, nonatomic) IBOutlet UIWebView *articleWebView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *articleBackButton;
@end

@implementation DKArticleViewController

#pragma mark - Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.articleWebView.delegate = self;
    
    // disable back button per default
    self.articleBackButton.enabled = NO;
    
    [self updateUI];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // remove loading animation if webview still loads
    if ([self isMovingFromParentViewController] && self.articleWebView.isLoading) {
        [[UIApplication sharedApplication] hideNetworkActivityIndicator];
        [self.articleWebView stopLoading];
    }
}



#pragma mark - Getters / Setters

- (void)setArticleTitle:(NSString *)articleTitle
{
    _articleTitle = articleTitle;
    [self updateUI];
}

- (void)setArticleUrl:(NSString *)articleUrl
{
    _articleUrl = articleUrl;
    [self updateUI];
}

- (void)setArticleId:(NSInteger)articleId
{
    _articleId = articleId;
    [self updateUI];
}

- (void)setArticleComments:(NSInteger)articleComments
{
    _articleComments = articleComments;
    [self updateUI];
}



#pragma mark - UI

- (void)updateUI
{
    NSURL *url = [NSURL URLWithString:self.articleUrl];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.articleWebView loadRequest:requestObj];
}



#pragma mark - Event handlers

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Comments"]) {
        if ([segue.destinationViewController isKindOfClass:[DKCommentsTableViewController class]]) {
            DKCommentsTableViewController *destinationController = (DKCommentsTableViewController *)segue.destinationViewController;
            
            destinationController.articleId = self.articleId;
        }
    }
}

- (IBAction)handleBackButton:(id)sender
{
    [self.articleWebView goBack];
    self.articleBackButton.enabled = self.articleWebView.canGoBack;
}

- (IBAction)handleActionButton:(id)sender {
    NSString *content = [NSString stringWithFormat:@"%@ via @sonarJS", self.articleTitle];
    NSArray *postItems = @[content, [NSURL URLWithString:self.articleUrl]];
    NSArray *activities = @[[[TUSafariActivity alloc] init], [[ARChromeActivity alloc] init]];

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:postItems applicationActivities:activities];
    [self presentViewController:activityVC animated:YES completion:nil];
}



#pragma mark - webview delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [self.spinner startAnimating];
    self.articleBackButton.enabled = self.articleWebView.canGoBack;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] hideNetworkActivityIndicator];
    [self.spinner stopAnimating];
    self.articleBackButton.enabled = self.articleWebView.canGoBack;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[UIApplication sharedApplication] hideNetworkActivityIndicator];
    [self.spinner stopAnimating];
    self.articleBackButton.enabled = self.articleWebView.canGoBack;
}

@end
