//
//  NSString+ActiveSupportInflector.m
//  ActiveSupportInflector
//

#import "ActiveSupportInflector.h"

@implementation NSString (ActiveSupportInflector)

static ActiveSupportInflector* _inflector = NULL;

- (ActiveSupportInflector *)inflector
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _inflector = [[ActiveSupportInflector alloc] init];
    });
    return _inflector;
}

- (NSString *)pluralizeString
{
    return([[self inflector] pluralize:self]);
}

- (NSString *)singularizeString
{
    return([[self inflector] singularize:self]);
}

@end
