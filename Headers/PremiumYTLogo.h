#ifndef PREMIUM_YT_LOGO_STANDALONE_H
#define PREMIUM_YT_LOGO_STANDALONE_H

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *const kYTPremiumLogoEnabledKey = @"com.standalone.premiumytlogo.enabled";
static const NSInteger kYTPremiumLogoSettingsCategory = 790;

static inline BOOL IsPremiumLogoEnabled(void) {
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    if ([defs objectForKey:kYTPremiumLogoEnabledKey] == nil) {
        return YES;
    }
    return [defs boolForKey:kYTPremiumLogoEnabledKey];
}

static inline void SetPremiumLogoEnabled(BOOL enabled) {
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs setBool:enabled forKey:kYTPremiumLogoEnabledKey];
    [defs synchronize];
}

@interface YTIIcon : NSObject
- (void)setIconType:(NSUInteger)iconType;
@end

@interface YTUIResources : NSObject
+ (UIImage *)youtubePremiumLogoWithPageStyle:(NSInteger)style;
+ (UIImage *)youtubeLogoWithPageStyle:(NSInteger)style;
@end

@interface YTSettingsGroupData : NSObject
- (NSInteger)type;
- (NSArray *)orderedCategories;
@end

@interface YTAppSettingsPresentationData : NSObject
+ (NSArray *)settingsCategoryOrder;
@end

@interface YTSettingsViewController : UIViewController
- (void)setSectionItems:(NSArray *)items forCategory:(NSInteger)category title:(NSString *)title icon:(YTIIcon *)icon titleDescription:(NSString *)titleDescription headerHidden:(BOOL)headerHidden;
- (void)setSectionItems:(NSArray *)items forCategory:(NSInteger)category title:(NSString *)title titleDescription:(NSString *)titleDescription headerHidden:(BOOL)headerHidden;
@end

@interface YTSettingsSectionItemManager : NSObject
- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry;
@end

@interface YTWrapperSplitViewController : UIViewController
- (instancetype)initWithParentResponder:(id)parentResponder;
- (void)setTitle:(NSString *)title;
- (void)setContent:(UIViewController *)content;
@end

@interface YTHeaderViewController : UIViewController
- (void)updateHeaderWithButtonsToDisplay:(NSNumber *)buttons;
@end

@interface YTWrapperFlatViewController : UIViewController
- (instancetype)initWithParentResponder:(id)parentResponder;
- (void)setTitle:(NSString *)title;
- (void)setContent:(UIViewController *)content;
- (YTHeaderViewController *)headerViewController;
@end

@interface YTCollectionViewController : UIViewController
- (NSArray *)sectionControllers;
- (NSInteger)pageStyle;
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface YTQTMButton : UIButton
- (void)setEnablePageStyling:(BOOL)enable;
@end

@interface YTPremiumLogoSettingsVC : UITableViewController
@end

#endif
