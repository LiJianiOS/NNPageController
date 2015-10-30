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
#import "ThreeViewController.h"
#define BtnTag 1001
#define ScreenSize  ([UIScreen mainScreen].bounds.size)
@interface MainViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate,UIScrollViewDelegate>

@property (nonatomic, strong)  NSArray *btnArr;
@property(nonatomic,strong) NSMutableArray *viewControllerArray;
@property (nonatomic, strong)UIPageViewController *pageController;
@property (nonatomic, assign)NSInteger currentPageIndex;
@end

@implementation MainViewController
/**
 *  只需要修改的第一处
 */
- (NSArray *)btnArr{
    if (!_btnArr) {
        _btnArr =  @[@"iOS",@"交流群",@"390438081"];
    }
    return _btnArr;
}

/**
 *  只需要修改的第二处
 */
- (NSMutableArray *)viewControllerArray{
    if (!_viewControllerArray) {
        _viewControllerArray =
        _viewControllerArray = [[NSMutableArray alloc]init];
        FirstViewController *FController = [[FirstViewController alloc]init];
        SecondViewController *SController = [[SecondViewController alloc]init];
        ThreeViewController *TController = [[ThreeViewController alloc]init];
        [_viewControllerArray addObjectsFromArray:@[FController,SController,TController]];
    }
    return _viewControllerArray;
}

-(void)viewDidLoad
{
    [self initMainController];
    [self setupPageViewController];
}

- (UIPageViewController *)pageController{
    if (!_pageController) {
       _pageController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
       _pageController.view.frame = CGRectMake(0, 64, ScreenSize.width, ScreenSize.height - 64);
      _pageController.delegate = self;
        _pageController.dataSource = self;
        
        [_pageController setViewControllers:@[[self.viewControllerArray objectAtIndex:_currentPageIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];

    }
    return _pageController;
}
//初始化导航控制器
-(void)initMainController{
    
    UILabel *theLine = [[UILabel alloc]init];
     for (int i = 0; i < self.btnArr.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
       CGSize  size = [self.btnArr[2] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]}];

        [btn setTitle:self.btnArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        btn.frame = CGRectMake((ScreenSize.width - 3*size.width)/2 + size.width*i+16*i, 40, size.width, size.height);
        btn.tag = BtnTag + i;
        if (i == _currentPageIndex) {
            btn.selected = YES;
            theLine .frame = CGRectMake(btn.frame.origin.x, 64 - 2, btn.frame.size.width, 2);
            theLine.tag = 2000;
        }
        [btn addTarget:self action:@selector(changeControllerClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    
    theLine.backgroundColor = [UIColor blackColor];
    [self.view addSubview:theLine];
    
}

-(void)setupPageViewController{
    [self addChildViewController:self.pageController];
    [self.view addSubview:self.pageController.view];
    [self syncScrollView];
}
-(void)syncScrollView{
    for (UIView *view in self.pageController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *pageScrollView = (UIScrollView *)view;
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
            [_pageController setViewControllers:@[[self.viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
                if (finished) {
                    [weakSelf updateCurrentPageIndex:i];
                }
            }];
        }
    }else if (nowTemp < tempIndex){
        for (int i = (int)tempIndex ; i >= nowTemp; i--) {
            [_pageController setViewControllers:@[[self.viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
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
    for (int i = 0 ; i < self.btnArr.count; i ++) {
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
        UIView *line = (UIView *)[self.view viewWithTag:2000];
        CGRect sizeRect = line.frame;
        sizeRect.origin.x = btn.frame.origin.x;
        line.frame = CGRectMake(btn.frame.origin.x, 64 - 2, btn.frame.size.width, 2);
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
        NSLog(@"当前界面是界面=== %ld",_currentPageIndex);
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
