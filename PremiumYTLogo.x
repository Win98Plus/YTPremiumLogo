#import "Headers/PremiumYTLogo.h"

static NSBundle *PremiumLogoResources(void) {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Frameworks/Module_Framework.framework/Innertube_Resources.bundle"];
        bundle = [NSBundle bundleWithPath:path];
    });
    return bundle;
}

static UIImage *PremiumLogoReplacement(UIImage *image, BOOL enabled) {
    if (!image) return image;

    NSString *description = image.description;
    if (!description) return image;

    NSString *assetName = nil;
    NSInteger pageStyle = 0;

    if (enabled) {
        if ([description containsString:@"Resources: youtube_logo_dark)"]) {
            assetName = @"youtube_premium_logo_white";
            pageStyle = 1;
        } else if ([description containsString:@"Resources: youtube_logo)"]) {
            assetName = @"youtube_premium_logo";
            pageStyle = 0;
        }
    } else {
        if ([description containsString:@"Resources: youtube_premium_logo_white)"]) {
            assetName = @"youtube_logo_dark";
            pageStyle = 1;
        } else if ([description containsString:@"Resources: youtube_premium_logo)"]) {
            assetName = @"youtube_logo";
            pageStyle = 0;
        }
    }

    if (!assetName) return image;

    UIImage *replacement = [UIImage imageNamed:assetName inBundle:PremiumLogoResources() compatibleWithTraitCollection:nil];
    if (!replacement) {
        Class ytuiCls = %c(YTUIResources);
        if (ytuiCls) {
            if (enabled && [ytuiCls respondsToSelector:@selector(youtubePremiumLogoWithPageStyle:)]) {
                replacement = [ytuiCls youtubePremiumLogoWithPageStyle:pageStyle];
            } else if (!enabled && [ytuiCls respondsToSelector:@selector(youtubeLogoWithPageStyle:)]) {
                replacement = [ytuiCls youtubeLogoWithPageStyle:pageStyle];
            }
        }
    }
    return replacement ?: image;
}

static void RefreshViewsRecursively(UIView *view) {
    if (!view) return;
    if ([view isKindOfClass:[UIImageView class]]) {
        UIImageView *iv = (UIImageView *)view;
        if (iv.image) {
            [iv setImage:iv.image];
        }
    }
    for (UIView *sub in view.subviews) {
        RefreshViewsRecursively(sub);
    }
}

static void RefreshAllWindowsLogo(void) {
    for (UIWindow *win in [[UIApplication sharedApplication] windows]) {
        RefreshViewsRecursively(win);
    }
}

@implementation YTPremiumLogoSettingsVC

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"YTPremiumLogoSwitchCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = @"YouTube Premium Logo";
    cell.detailTextLabel.text = @"Display YouTube Premium logo in navbar";

    UISwitch *toggle = [[UISwitch alloc] init];
    [toggle setOn:IsPremiumLogoEnabled() animated:NO];
    [toggle addTarget:self action:@selector(didTogglePremiumLogoSwitch:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = toggle;
    return cell;
}

- (void)didTogglePremiumLogoSwitch:(UISwitch *)sender {
    SetPremiumLogoEnabled(sender.isOn);
    RefreshAllWindowsLogo();
}

@end

%hook UIImageView

- (void)setImage:(UIImage *)image {
    %orig(PremiumLogoReplacement(image, IsPremiumLogoEnabled()));
}

%end

%hook YTAppSettingsPresentationData

+ (NSArray *)settingsCategoryOrder {
    NSArray *orig = %orig;
    if (!orig) return orig;
    NSMutableArray *mutableOrder = [orig mutableCopy];
    NSUInteger idx = [mutableOrder indexOfObject:@(1)];
    if (idx != NSNotFound) {
        [mutableOrder insertObject:@(kYTPremiumLogoSettingsCategory) atIndex:idx + 1];
    } else {
        [mutableOrder insertObject:@(kYTPremiumLogoSettingsCategory) atIndex:0];
    }
    return [mutableOrder copy];
}

%end

%hook YTSettingsGroupData

- (NSArray *)orderedCategories {
    BOOL isMainGroup = ([self type] == 1);
    NSArray *orig = %orig;
    if (isMainGroup && orig) {
        NSMutableArray *mutable = [orig mutableCopy];
        [mutable insertObject:@(kYTPremiumLogoSettingsCategory) atIndex:0];
        return [mutable copy];
    }
    return orig;
}

%end

%hook YTSettingsSectionItemManager

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == kYTPremiumLogoSettingsCategory) {
        id delegate = [self valueForKey:@"_settingsViewControllerDelegate"];
        if (!delegate) return;
        YTIIcon *icon = [%c(YTIIcon) new];
        [icon setIconType:530];
        if ([delegate respondsToSelector:@selector(setSectionItems:forCategory:title:icon:titleDescription:headerHidden:)]) {
            [delegate setSectionItems:nil forCategory:kYTPremiumLogoSettingsCategory title:@"YouTube Premium Logo" icon:icon titleDescription:nil headerHidden:NO];
        } else if ([delegate respondsToSelector:@selector(setSectionItems:forCategory:title:titleDescription:headerHidden:)]) {
            [delegate setSectionItems:nil forCategory:kYTPremiumLogoSettingsCategory title:@"YouTube Premium Logo" titleDescription:nil headerHidden:NO];
        }
        return;
    }
    %orig;
}

%end

%hook YTCollectionViewController

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self respondsToSelector:@selector(sectionControllers)]) {
        NSArray *sections = [self sectionControllers];
        if (sections && indexPath.section < (NSInteger)sections.count) {
            id secCtrl = sections[indexPath.section];
            if ([secCtrl respondsToSelector:@selector(items)]) {
                NSArray *items = [secCtrl valueForKey:@"items"];
                if (items && indexPath.row < (NSInteger)items.count) {
                    id item = items[indexPath.row];
                    if ([item respondsToSelector:@selector(categoryId)]) {
                        NSInteger catId = [[item valueForKey:@"categoryId"] integerValue];
                        if (catId == kYTPremiumLogoSettingsCategory) {
                            YTPremiumLogoSettingsVC *vc = [[YTPremiumLogoSettingsVC alloc] initWithStyle:UITableViewStyleInsetGrouped];
                            vc.title = @"YouTube Premium Logo";
                            if ([self respondsToSelector:@selector(pageStyle)]) {
                                vc.overrideUserInterfaceStyle = ([self pageStyle] == 1) ? UIUserInterfaceStyleDark : UIUserInterfaceStyleLight;
                            }

                            UIViewController *parentVC = self.parentViewController;
                            id grandParentVC = parentVC.parentViewController;
                            if ([grandParentVC respondsToSelector:@selector(secondViewController)] && [grandParentVC valueForKey:@"secondViewController"] != nil) {
                                Class splitCls = %c(YTWrapperSplitViewController);
                                id wrapper = [[splitCls alloc] initWithParentResponder:parentVC];
                                [wrapper setTitle:@"YouTube Premium Logo"];
                                [wrapper setContent:vc];
                                [grandParentVC setValue:wrapper forKey:@"secondViewController"];
                            } else {
                                Class flatCls = %c(YTWrapperFlatViewController);
                                if (flatCls) {
                                    id wrapper = [[flatCls alloc] initWithParentResponder:parentVC];
                                    [wrapper setTitle:@"YouTube Premium Logo"];
                                    [wrapper setContent:vc];
                                    [[wrapper headerViewController] updateHeaderWithButtonsToDisplay:@(NO)];
                                    [self.navigationController pushViewController:wrapper animated:YES];
                                } else {
                                    [self.navigationController pushViewController:vc animated:YES];
                                }
                            }
                            return;
                        }
                    }
                }
            }
        }
    }
    %orig;
}

%end

%hook YTQTMButton

- (void)layoutSubviews {
    %orig;
    if ([self.accessibilityIdentifier isEqualToString:@"id.ui.browse.back.button"]) {
        [self setTintColor:[UIColor labelColor]];
        if ([self respondsToSelector:@selector(setEnablePageStyling:)]) {
            [self setEnablePageStyling:NO];
        }
    }
}

%end
