//
//  CustomViewController.m
//  Example
//
//  Created by Jonathan Tribouharet.
//

#import "CustomViewController.h"

@interface CustomViewController (){
    NSMutableDictionary *_eventsByDate;
    NSDate *_minDate;
    NSDate *_maxDate;
    NSDate *dateSelected;
    NSDate *_todayDate;
    
    
    NSMutableArray *datesSelected;
    NSMutableArray *weeksView;
    JTCalendarWeekView *superWeekView;
}

@end

@implementation CustomViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(!self){
        return nil;
    }
    
    self.title = @"Custom";
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    weeksView = [NSMutableArray new];
    datesSelected = [NSMutableArray new];
    
    _todayDate = [NSDate date];
    _calendarManager = [[JTCalendarManager alloc] init];
    _calendarManager.delegate = self;
    [self createMinAndMaxDate];
   
    self.isWeek = true;
    
    _calendarMenuView.contentRatio = .75;
    _calendarManager.settings.weekDayFormat = JTCalendarWeekDayFormatCustom;
    _calendarManager.dateHelper.calendar.firstWeekday = 2;
    [_calendarManager.settings.weekDays setArray:@[@"yi",@"er",@"san",@"si",@"wu",@"liu",@"ri"]];
    
    [_calendarManager setMenuView:_calendarMenuView];
    [_calendarManager setContentView:_calendarContentView];
    [_calendarManager setDate:_todayDate];
    [_calendarManager reload];
    
}

- (void)createMinAndMaxDate
{
    // Min date will be 2 month before today
    _minDate = [_calendarManager.dateHelper addToDate:_todayDate months:-24];
    
    // Max date will be 2 month after today
    _maxDate = [_calendarManager.dateHelper addToDate:_todayDate months:24];
}

#pragma mark - CalendarManager delegate

// Exemple of implementation of prepareDayView method
// Used to customize the appearance of dayView
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{
    if ([_calendarManager.dateHelper date:[NSDate new] isTheSameDayThan:dayView.date]) {
        dayView.circleView.hidden = NO;
        dayView.circleView.layer.borderWidth = 1;
        dayView.circleView.layer.borderColor = [UIColor colorWithRed:235/255.0 green:157.0/255.0 blue:91.0/255.0 alpha:1.0].CGColor;
        dayView.circleView.backgroundColor = [UIColor whiteColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor darkTextColor];
    }
    // Other month
    else if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor lightGrayColor];
    }
    // Another day of the current month
    else{
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor blackColor];
    }
    
    // Selected date
    if(dateSelected && [_calendarManager.dateHelper date:dateSelected isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:91.0/255.0 blue:235.0/255.0 alpha:1.0];
        dayView.circleView.layer.borderColor = [UIColor colorWithRed:128.0/255.0 green:91.0/255.0 blue:235.0/255.0 alpha:1.0].CGColor;
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    
    if (_isWeek) {
        if (superWeekView == nil && datesSelected.count == 0 && [_calendarManager.dateHelper date:[NSDate new] isTheSameDayThan:dayView.date]) {
            superWeekView = (JTCalendarWeekView *)dayView.fatherView;
            superWeekView.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:91.0/255.0 blue:235.0/255.0 alpha:1.0];
            NSLog(@"读取日期");
            for (JTCalendarDayView *dView in [superWeekView getArrays]) {
                NSLog(@"dateSelectInsert:%@",dView.date);
                if(dView.date){
                    [datesSelected addObject:dView.date];
                }else{
//                    NSLog(@"error:%@",dView);
//                    superWeekView = nil;
                    [datesSelected removeAllObjects];
                }
            }
            [calendar reload];
        }
        
        if (datesSelected.firstObject && [_calendarManager.dateHelper date:datesSelected.firstObject isTheSameDayThan:dayView.date]) {
            superWeekView = (JTCalendarWeekView *)dayView.fatherView;
//            NSLog(@"%@,%@",superWeekView,dayView.date);
        }
       
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyy-MM-dd";
        if([self isInDatesSelected:dayView.date]){
            dayView.circleView.hidden = NO;
            dayView.circleView.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:91.0/255.0 blue:235.0/255.0 alpha:1.0];
            dayView.circleView.layer.borderColor = [UIColor colorWithRed:128.0/255.0 green:91.0/255.0 blue:235.0/255.0 alpha:1.0].CGColor;
            dayView.dotView.backgroundColor = [UIColor whiteColor];
            dayView.textLabel.textColor = [UIColor whiteColor];
            if ([superWeekView isEqual:dayView.fatherView]) {
                superWeekView.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:91.0/255.0 blue:235.0/255.0 alpha:1.0];
            }
        }else{
            dayView.fatherView.backgroundColor = [UIColor whiteColor];
        }
       
    }
    
}

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView
{
    dateSelected = dayView.date;
    
    // Animation for the circleView
    dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView transitionWithView:dayView
                      duration:.3
                       options:0
                    animations:^{
        dayView.circleView.transform = CGAffineTransformIdentity;
        [self->_calendarManager reload];
    } completion:nil];
    if(_calendarManager.settings.weekModeEnabled){
        return;
    }
    // Load the previous or next page if touch a day from another month
    
    if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        if([_calendarContentView.date compare:dayView.date] == NSOrderedAscending){
            [_calendarContentView loadNextPageWithAnimation];
        }
        else{
            [_calendarContentView loadPreviousPageWithAnimation];
        }
    }
    
    
    if (_isWeek) {
        for (JTCalendarWeekView *objc in weeksView) {
            if ([objc isEqual:dayView.fatherView]) {
                objc.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:91.0/255.0 blue:235.0/255.0 alpha:1.0];
                [datesSelected removeAllObjects];
                for (JTCalendarDayView *dView in [objc getArrays]) {
                    [datesSelected addObject:dView.date];
                }
                superWeekView = objc;
            }else{
                objc.backgroundColor = [UIColor whiteColor];
            }
        }
        [calendar reload];
    }
    
    
}

- (BOOL)calendar:(JTCalendarManager *)calendar canDisplayPageWithDate:(NSDate *)date{
    return [_calendarManager.dateHelper date:date isEqualOrAfter:_minDate andEqualOrBefore:_maxDate];
}

- (void)calendarDidLoadNextPage:(JTCalendarManager *)calendar{
    _todayDate = calendar.date;
}
-(void)calendarDidLoadPreviousPage:(JTCalendarManager *)calendar{
    _todayDate = calendar.date;
}


#pragma mark - Views customization

- (UIView *)calendarBuildMenuItemView:(JTCalendarManager *)calendar
{
    UILabel *label = [UILabel new];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Avenir-Medium" size:30];
    
    return label;
}

- (void)calendar:(JTCalendarManager *)calendar prepareMenuItemView:(UILabel *)menuItemView date:(NSDate *)date
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"MMMM yyyy";
        
        dateFormatter.locale = _calendarManager.dateHelper.calendar.locale;
        dateFormatter.timeZone = _calendarManager.dateHelper.calendar.timeZone;
    }
    
    menuItemView.text = [dateFormatter stringFromDate:date];
}

- (UIView<JTCalendarWeekDay> *)calendarBuildWeekDayView:(JTCalendarManager *)calendar
{
    JTCalendarWeekDayView *view = [JTCalendarWeekDayView new];
    for(UILabel *label in view.dayViews){
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:15];
    }
    return view;
}

//- (UIView<JTCalendarDay> *)calendarBuildDayView:(JTCalendarManager *)calendar
//{
//    JTCalendarDayView *view = [JTCalendarDayView new];
//
//    view.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:13];
//
//    return view;
//}


- (UIView<JTCalendarWeek> *)calendarBuildWeekView:(JTCalendarManager *)calendar{
    JTCalendarWeekView *view = [JTCalendarWeekView new];
    view.backgroundColor = [UIColor whiteColor];//[UIColor colorWithRed:128.0/255.0 green:91.0/255.0 blue:235.0/255.0 alpha:1.0];
    [weeksView addObject:view];
    view.layer.cornerRadius = 15.0;
    return view;
}

//MARK: - 新增
- (BOOL)isInDatesSelected:(NSDate *)date
{
//    NSDateFormatter *formatter = [NSDateFormatter new];
//    formatter.dateFormat = @"yyyy-MM-dd";
//    NSMutableString *tmpStr = [NSMutableString new];
    for(NSDate *dateSelected in datesSelected){
//        NSLog(@"isInDatesSelected:%@",date);
//        [tmpStr appendString:@","];
//        [tmpStr appendString:[formatter stringFromDate:dateSelected]];
        if([_calendarManager.dateHelper date:dateSelected isTheSameDayThan:date]){
//            NSLog(@"%@",tmpStr);
            return YES;
        }
    }
//    NSLog(@"not match %@",[formatter stringFromDate:date]);
    return NO;
}

@end
