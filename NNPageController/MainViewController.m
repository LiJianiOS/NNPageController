//
//  MainViewController.m
//  NNPageController
//
//  Created by public on 15/10/30.
//  Copyright © 2015年 public. All rights reserved.
//

#import "MainViewController.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#define BtnTag 1001
#define ScreenSize  ([UIScreen mainScreen].bounds.size)
@interface MainViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate,UIScrollViewDelegate>
{
    UILabel *theLine;
    UIScrollView *pageScrollView;
    FirstViewController *shopController;
    SecondViewController *sellHotController;
    
    
    
    NSString *currentPage;
    NSString *fundTpyePage;
}

@property(nonatomic,strong) NSMutableArray *viewControllerArray;
@property (nonatomic, strong)UIPageViewController *pageController;
@property (nonatomic, assign)NSInteger currentPageIndex;
@end

@implementation MainViewController

-(void)viewDidLoad
{
    [self initMainController];
    [self setupPageViewController];
}

//初始化导航控制器
-(void)initMainController{
    
    
    NSArray *btnArr = @[@"界面一",@"界面二"];
     for (int i = 0; i < btnArr.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
       CGSize  size = [btnArr[i] sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16]}];

        [btn setTitle:btnArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor yellowColor] forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        btn.frame = CGRectMake((ScreenSize.width - 3*size.width -2*16)/2 + size.width*i+16*i, (64 + 20 - size.height)/2, size.width, size.height);
        btn.tag = BtnTag + i;
        if (i == _currentPageIndex) {
            btn.selected = YES;
            theLine = [[UILabel alloc]initWithFrame:CGRectMake(btn.frame.origin.x, 64 - 2, size.width, 2)];
        }
        [btn addTarget:self action:@selector(changeControllerClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    
    theLine.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:theLine];
    
}

-(void)setupPageViewController{
    _viewControllerArray = [[NSMutableArray alloc]init];
    shopController = [[FirstViewController alloc]init];
    
    sellHotController = [[SecondViewController alloc]init];
    [_viewControllerArray addObjectsFromArray:@[shopController,sellHotController]];
    self.pageController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageController.view.frame = CGRectMake(0, 64, ScreenSize.width, ScreenSize.height - 64);
    self.pageController.delegate = self;
    self.pageController.dataSource = self;
    
    [self.pageController setViewControllers:@[[_viewControllerArray objectAtIndex:_currentPageIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self addChildViewController:self.pageController];
    
    
    
    [self.view addSubview:self.pageController.view];
    [self syncScrollView];
}
-(void)syncScrollView{
    for (UIView *view in _pageController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            pageScrollView = (UIScrollView *)view;
            pageScrollView.delegate = self;
            pageScrollView.scrollsToTop=NO;
        }
    }
}
-(void)changeControllerClick:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger tempIndex = _currentPageIndex;
    __weak typeof (self) weakSelf = self;
    NSInteger nowTemp = btn.tag - BtnTag;
    if (nowTemp > tempIndex) {
        for (int i = (int)tempIndex + 1; i <= nowTemp; i ++) {
            [_pageController setViewControllers:@[[_viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
                if (finished) {
                    [weakSelf updateCurrentPageIndex:i];
                }
            }];
        }
    }else if (nowTemp < tempIndex){
        for (int i = (int)tempIndex ; i >= nowTemp; i--) {
            [_pageController setViewControllers:@[[_viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
                if (finished) {
                    [weakSelf updateCurrentPageIndex:i];
                }
            }];
        }
    }
}

-(void)updateCurrentPageIndex:(NSInteger)newIndex
{
    _currentPageIndex = newIndex;
    
    UIButton *btn = (UIButton *)[self.view viewWithTag:BtnTag+_currentPageIndex];
    for (int i = 0 ; i < 3; i ++) {
        UIButton *otherBtn = (UIButton *)[self.view viewWithTag:BtnTag + i];
        if (btn.tag == otherBtn.tag) {
            otherBtn.selected = YES;
        }else{
            otherBtn.selected = NO;
        }
    }
}
#pragma mark --------Scroll协议-------
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    NSInteger X = _currentPageIndex;
    UIButton *btn = (UIButton *)[self.view viewWithTag:X+BtnTag];
    [UIView animateWithDuration:0.2 animations:^{
        CGRect sizeRect = theLine.frame;
        sizeRect.origin.x = btn.frame.origin.x;
        theLine.frame = sizeRect;
    }];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [self indexOfController:viewController];
    
    if ((index == NSNotFound) || (index == 0)) {
        return nil;
    }
    
    index--;
    return [_viewControllerArray objectAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [self indexOfController:viewController];
    
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    
    if (index == [_viewControllerArray count]) {
        return nil;
    }
    return [_viewControllerArray objectAtIndex:index];
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        _currentPageIndex = [self indexOfController:[pageViewController.viewControllers lastObject]];
        [self updateCurrentPageIndex:_currentPageIndex];
    }
}

-(NSInteger)indexOfController:(UIViewController *)viewController
{
    for (int i = 0; i<[_viewControllerArray count]; i++) {
        if (viewController == [_viewControllerArray objectAtIndex:i])
        {
            return i;
        }
    }
    return NSNotFound;
}

@end
