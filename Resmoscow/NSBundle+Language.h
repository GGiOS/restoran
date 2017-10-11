//
//  NSBundle+Language.h
//  Resmoscow
//
//  Created by Egor Galaev on 17/04/17.


@import Foundation;

typedef enum : NSInteger {
    Russian,
    English
} Language;

extern NSString * const Language_toString[];
extern NSString * const kChangeLanguageNotification;

@interface NSBundle (Language)

+ (void)setLanguage;
+ (NSString *)switchLanguageToAnotherByLangCode:(NSString *)langCode;

+ (Language)language;
+ (NSString *)inverseLangCode;

@end
