//
//  JYBlockView.m
//  JYBlockView
//
//  Created by joyann on 15/10/24.
//  Copyright © 2015年 Joyann. All rights reserved.
//

#import "JYBlockView.h"

/*
    增加9个按钮并设置好selected和normal状态 -> 设置手势，将button设置为不可交互 -> 在handlePan方法中判断手指点击的点是否在button上(使用CGRectContainsPoint判断，不必更换坐标系，注意使用的是frame) -> 如果在button上，则将button加到selectedButtons数组中，前提是数组中没有这个对象，这样避免重复选中button -> 在handlePan方法中，手指移动就重新绘制线（先找出原点，绘制出所有选中的按钮之间的连线，每次移动都重新绘制这些线。注意首先要判断是否有选中的按钮，确定有才开始画线。点击按钮也是选中。） -> 绘制完选中按钮之间的线绘制到当前手指位置的线 -> 当手指离开，将选中按钮数组中的按钮的selected设置为NO并且将数组内容清除，重新绘制，此时之前的线和选中的按钮就都恢复原样了。
    另外，此时用的是addSubview方式将blockView加入控制器中，所以blockView并不会有默认背景，这导致每次刷新都会显示出之前绘制的内容，解决方法就是设置JYBlockView的backgroundColor，这样每次绘制就会用背景覆盖上之前绘制的内容，然后绘制新内容。
 */

@interface JYBlockView ()

@property (nonatomic, strong) NSMutableArray *selectedButtons;

@property (nonatomic, assign) CGPoint currentPoint;

@end

@implementation JYBlockView

#pragma mark - Getter Methods

- (NSMutableArray *)selectedButtons
{
    if (!_selectedButtons) {
        _selectedButtons = [NSMutableArray array];
    }
    return _selectedButtons;
}

#pragma mark - Init Methods

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setUp];
}

#pragma mark - Set Up

- (void)setUp
{
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat margin = 20.0;
    CGFloat buttonWH = 74;
    // 添加按钮
    for (int i = 0; i < 9; i++) {
        int column = i % 3;
        int row = i / 3;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"gesture_node_normal"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"gesture_node_highlighted"] forState:UIControlStateSelected];
        CGPoint point = CGPointMake(margin * (column + 1) + column * buttonWH, margin * (row + 1) + row * buttonWH);
        button.frame = CGRectMake(point.x, point.y, buttonWH, buttonWH);
        button.userInteractionEnabled = NO;
        button.tag = i;
        [self addSubview:button];
    }
    // 添加手势
    [self addGesture];
}

#pragma mark - Add Gesture

- (void)addGesture
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:pan];
}

#pragma mark - Touch Began

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    UIButton *button = [self buttonWithRectContainsPoint:point];
    if (button) {
        button.selected = YES;
    }
}

#pragma mark - Handle Pan

- (void)handlePan: (UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan locationInView:self];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        {
            UIButton *button = [self buttonWithRectContainsPoint:point];
            if (button) {
                button.selected = YES;
            }
            self.currentPoint = point;
            [self setNeedsDisplay];
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            NSMutableString *password = [[NSMutableString alloc] init];
            for (int i = 0; i < self.selectedButtons.count; i++) {
                UIButton *button = self.selectedButtons[i];
                if (button.selected) {
                    button.selected = NO;
                    [password appendFormat:@"%ld", button.tag];
                }
            }
            [self.selectedButtons removeAllObjects];
            [self setNeedsDisplay];
            NSLog(@"%@", password);
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Draw Rect

- (void)drawRect:(CGRect)rect
{
    if (self.selectedButtons.count) {
        
        UIBezierPath *linePath = [UIBezierPath bezierPath];
        
        for (int i = 0; i < self.selectedButtons.count; i ++) {
            UIButton *button = self.selectedButtons[i];
            if (i == 0) {
                [linePath moveToPoint: button.center];
            } else {
                [linePath addLineToPoint:button.center];
            }
        }
        
        [linePath addLineToPoint:self.currentPoint];
        
        [[UIColor redColor] setStroke];
        linePath.lineWidth = 10.0;
        linePath.lineJoinStyle = kCGLineJoinRound;
        
        [linePath stroke];
    }
    
}

#pragma mark - Hit Test

- (UIButton *)buttonWithRectContainsPoint: (CGPoint)point
{
    for (UIButton *button in self.subviews) {
        if (CGRectContainsPoint(button.frame, point)) {
            if (![self.selectedButtons containsObject:button]) {
                [self.selectedButtons addObject:button];
            }
            return button;
        }
    }
    return nil;
}

@end
