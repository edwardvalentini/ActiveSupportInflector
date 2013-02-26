//
//  Inflector.m
//  ActiveSupportInflector
//

#import "ActiveSupportInflector.h"

@interface ActiveSupportInflectorRule : NSObject
@property (nonatomic, copy) NSString *rule, *replacement;
@property (nonatomic, strong, readonly) NSRegularExpression *regex;
+ (ActiveSupportInflectorRule*)rule:(NSString*)rule
                        replacement:(NSString*)replacement;
@end

@implementation ActiveSupportInflectorRule
- (void)setRule:(NSString *)newRule
{
    NSParameterAssert(newRule != nil);
    if((_rule = [newRule copy]) != nil)
    {
        NSError *error = nil;
        if((_regex = [[NSRegularExpression alloc] initWithPattern:_rule options:0 error:&error]) == NULL)
        {
            NSLog(@"<%@:%p %@>: Unable to create a regular expression using the rule '%@': Error: %@, userInfo: %@", NSStringFromClass([self class]), self, NSStringFromSelector(_cmd), _rule, error, [error userInfo]);
        }
    }
    NSParameterAssert((_rule != nil) && (_regex != nil));
}

+ (ActiveSupportInflectorRule*) rule:(NSString*)rule replacement:(NSString*)replacement
{
    NSParameterAssert((rule != nil) && (replacement != nil));
    ActiveSupportInflectorRule* result = nil;
    
    if((result = [[self alloc] init]))
    {
        [result setRule:rule];
        [result setReplacement:replacement];
    }
    return (result);
}
@end


@interface ActiveSupportInflector(PrivateMethods)
- (NSString*)_applyInflectorRules:(NSArray*)rules toString:(NSString*)string;
@end

@implementation ActiveSupportInflector

static id _activeSupportInflectorBundlePlist = nil;

+ (id)activeSupportInflectorBundlePlist
{
    _AtomicallyInitObjCPointer(&_activeSupportInflectorBundlePlist, [NSDictionary dictionaryWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"ActiveSupportInflector" ofType:@"plist"]], NULL);
    return(_activeSupportInflectorBundlePlist);
}

- (ActiveSupportInflector*)init
{
    if ((self = [super init]))
    {
        _uncountableWords = [[NSMutableSet   alloc] init];
        _pluralRules      = [[NSMutableArray alloc] init];
        _singularRules    = [[NSMutableArray alloc] init];
        [self addInflectionsFromDictionary:[[self class] activeSupportInflectorBundlePlist]];
    }
    return self;
}

- (void)addInflectionsFromFile:(NSString*)path
{
    [self addInflectionsFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
}

- (void)addInflectionsFromDictionary:(NSDictionary*)dictionary
{
    for (NSArray* pluralRule in [dictionary objectForKey:@"pluralRules"])
    {
        [self addPluralRuleFor:[pluralRule objectAtIndex:0] replacement:[pluralRule objectAtIndex:1]];
    }
    
    for (NSArray* singularRule in [dictionary objectForKey:@"singularRules"])
    {
        [self addSingularRuleFor:[singularRule objectAtIndex:0] replacement:[singularRule objectAtIndex:1]];
    }
    
    for (NSArray* irregularRule in [dictionary objectForKey:@"irregularRules"])
    {
        [self addIrregularRuleForSingular:[irregularRule objectAtIndex:0] plural:[irregularRule objectAtIndex:1]];
    }
    
    for (NSString* uncountableWord in [dictionary objectForKey:@"uncountableWords"])
    {
        [self addUncountableWord:uncountableWord];
    }
}

- (void)addUncountableWord:(NSString*)string
{
    [_uncountableWords addObject:string];
}

- (void)addIrregularRuleForSingular:(NSString*)singular plural:(NSString*)plural
{
    NSString* singularRule = [NSString stringWithFormat:@"%@$", plural];
    [self addSingularRuleFor:singularRule replacement:singular];
    
    NSString* pluralRule = [NSString stringWithFormat:@"%@$", singular];
    [self addPluralRuleFor:pluralRule replacement:plural];
}

- (void)addPluralRuleFor:(NSString*)rule replacement:(NSString*)replacement
{
    [_pluralRules insertObject:[ActiveSupportInflectorRule rule:rule replacement: replacement] atIndex:0];
}

- (void)addSingularRuleFor:(NSString*)rule replacement:(NSString*)replacement
{
    [_singularRules insertObject:[ActiveSupportInflectorRule rule:rule replacement: replacement] atIndex:0];
}

- (NSString*)pluralize:(NSString*)singular
{
    return [self _applyInflectorRules:_pluralRules toString:singular];
}

- (NSString*)singularize:(NSString*)plural
{
    return [self _applyInflectorRules:_singularRules toString:plural];
}

- (NSString*)_applyInflectorRules:(NSArray*)rules toString:(NSString*)string
{
    if([_uncountableWords containsObject:string])
    {
        return(string);
    }
    NSRange range = NSMakeRange(0UL, [string length]);
    for(ActiveSupportInflectorRule *rule in rules)
    {
        if([rule.regex firstMatchInString:string options:0 range:range])
        {
            return([rule.regex stringByReplacingMatchesInString:string options:0 range:range withTemplate:rule.replacement]);
        }
    }
    return(string);
}

@end
