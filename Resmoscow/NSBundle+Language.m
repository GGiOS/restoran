//
//  NSBundle+Language.m
//  Resmoscow
//
//  Created by Egor Galaev on 17/04/17.


#import "NSBundle+Language.h"
#import <objc/runtime.h>

static const char _bundle = 0;
static NSString * const kLanguageKey = @"Language";
static Language const kDefLanguage = Russian;

NSString * const Language_toString[] = {
    [Russian] = @"RU",
    [English] = @"EN"
};
NSString * const kChangeLanguageNotification = @"ChangeLanguageNotification";

@interface BundleEx : NSBundle

@end

@implementation BundleEx

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    NSBundle * bundle = objc_getAssociatedObject(self, &_bundle);
    return bundle ? [bundle localizedStringForKey:key value:value table:tableName] : [super localizedStringForKey:key value:value table:tableName];
}

@end

@implementation NSBundle (Language)

+ (void)setLanguage {
    [self setLanguage:[self.langCode isEqualToString:Language_toString[Russian]] ? Russian : English];
}

+ (void)setLanguage:(Language)language {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object_setClass([NSBundle mainBundle], [BundleEx class]);
    });
    
    // use <language>.lproj folder
    objc_setAssociatedObject([NSBundle mainBundle], &_bundle, [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:Language_toString[language].lowercaseString ofType:@"lproj"]], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // save lang
    [[NSUserDefaults standardUserDefaults] setValue:Language_toString[language] forKey:kLanguageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeLanguageNotification object:nil];
}

+ (NSString *)switchLanguageToAnotherByLangCode:(NSString *)langCode {
    Language currentLanguage = [langCode isEqualToString:Language_toString[Russian]] ? English : Russian;
    Language newLanguage = currentLanguage == Russian ? English : Russian;
    [self setLanguage:newLanguage];
    return Language_toString[currentLanguage];
}

+ (Language)language {
    return [self.langCode isEqualToString:Language_toString[Russian]] ? Russian : English;
}

+ (NSString *)langCode {
    NSString * langCode = [[NSUserDefaults standardUserDefaults] valueForKey:kLanguageKey];
    return langCode ?: Language_toString[kDefLanguage];
}

+ (NSString *)inverseLangCode {
    NSString * inverseLangCode = [self.langCode isEqualToString:Language_toString[Russian]] ? Language_toString[English] : Language_toString[Russian];
    return inverseLangCode;
}

@end




