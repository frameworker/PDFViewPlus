// NSString+CocoaDevUsersAdditions.m

#import "NSString+CocoaDevUsersAdditions.h"

@implementation NSString (CocoaDevUsersAdditions)

- (NSString *) changeSuffix:(NSString *)from to:(NSString *)newSuffix
{
    NSString * newString = @"";
    
    if ([self hasSuffix:from])
    {
        NSScanner * scanner = [NSScanner scannerWithString:self];
        
        [scanner scanUpToString:from intoString:&newString];
        
        newString = [newString stringByAppendingString:newSuffix];
    }
    return newString;
}


/*
+ (NSString *)stringWithPascalString:(Str255)aString encoding:(CFStringEncoding)encoding {
  return [[[self alloc] initWithPascalString:aString encoding:encoding] autorelease];
}

- (id)initWithPascalString:(Str255)aString encoding:(CFStringEncoding)encoding {
  id string = nil;
  CFStringRef cfstring = CFStringCreateWithPascalString (NULL, aString, encoding);
  if (cfstring) {
    string = [self initWithString:(NSString*)cfstring];
    CFRelease (cfstring); // Calls "abort" if null.
  }
  return string;
}

// Returns size of string, including length byte (i.e. conversion to "hi" returns 3), or 0 if failed.
- (int)convertToPascalStringInBuffer:(StringPtr)strBuffer
       size:(int)bufSize encoding:(CFStringEncoding)encoding {
  Boolean success = CFStringGetPascalString ((CFStringRef)self, strBuffer, bufSize, encoding);
  return (success ? (*((const unsigned char*) strBuffer) + 1) : 0);
}

-(int)occurencesOfSubstring:(NSString *)substr {
//consider that for this, it may be(though I'm not sure) faster to use the less-robust outlined below.
  return [self occurencesOfSubstring:substr options:NSCaseInsensitiveSearch];
}

-(int)occurencesOfSubstring:(NSString *)substr options:(int)opt {
// if one wanted to make a much shorter(is it faster?), but rather less robust implementation, one would do:
// return [[self componentsSeparatedByString:substr] count] - 1;
  int strlen = [self length];
  int position = 0;
  NSRange currentRange;
  BOOL flag = YES;
  int count = 0;
  do {
    currentRange = [self rangeOfString:substr
                         options:opt
                         range:NSMakeRange(position,
                                           strlen-position)];
    if (currentRange.location == NSNotFound) {
      flag = NO;
    } else {
      count++;
      position = currentRange.location + currentRange.length;
    }
  } while (flag == YES);

  return count;
}

- (NSArray *)tokensSeparatedByCharactersFromSet:(NSCharacterSet *)separatorSet
{
  NSScanner      *scanner      = [NSScanner scannerWithString:self];
  NSCharacterSet *tokenSet     = [separatorSet invertedSet];
  NSMutableArray *tokens       = [NSMutableArray array];

  [scanner setCharactersToBeSkipped:separatorSet];

  while (![scanner isAtEnd])
  {
    NSString  *destination = [NSString string];

    if ([scanner scanCharactersFromSet:tokenSet intoString:&destination])
    {
      [tokens addObject:[NSString stringWithString:destination]];
    }
  }

  return [NSArray arrayWithArray:tokens];
}

- (NSArray *)objCTokens
{
  NSMutableCharacterSet *tokensSet = [NSMutableCharacterSet alphanumericCharacterSet];
  [tokensSet addCharactersInString:@"_:"];
  return [self tokensSeparatedByCharactersFromSet:[tokensSet invertedSet]];
}

//be careful if you're using SenTe's SenFoundation.  It implements -words as well, 
//and you may become confused in seeking bugs.

//NSTextStorage implements a -words method as well (in 10.3, at least). You may be able to use that instead.
- (NSArray *)words
{
  NSMutableCharacterSet *tokenSet = [NSMutableCharacterSet letterCharacterSet];
  [tokenSet addCharactersInString:@"-"];
  return [self tokensSeparatedByCharactersFromSet:[tokenSet invertedSet]];
}

// Useful for checking for illegal characters.
- (BOOL) containsCharacterFromSet:(NSCharacterSet *)set
{
  return ([self rangeOfCharacterFromSet:set].location != NSNotFound);
}

// Useful for replacing illegal characters with "?" or something.
- (NSString *)stringWithSubstitute:(NSString *)subs forCharactersFromSet:(NSCharacterSet *)set
{
  NSRange r = [self rangeOfCharacterFromSet:set];
  if (r.location == NSNotFound) return self;
  NSMutableString *newString = [self mutableCopy];
  do
  {
    [newString replaceCharactersInRange:r withString:subs];
    r = [newString rangeOfCharacterFromSet:set];
  }
  while (r.location != NSNotFound);
  return [newString autorelease];
}

-(NSArray *)linesSortedByLength {
  return [[self componentsSeparatedByString:@"\n"] sortedArrayUsingSelector:@selector(compareLength:)];
}

-(NSComparisonResult)compareLength:(NSString *)otherString {
  if([self length] < [otherString length])      { return NSOrderedAscending; }
  else if([self length] > [otherString length]) { return NSOrderedDescending; }
  //if same length, use alphabetical ordering.
  else                                          { return [self compare:otherString]; } 
}


- (BOOL)smartWriteToFile:(NSString *)path atomically:(BOOL)atomically
{
  if([self isEqualToString:[NSString stringWithContentsOfFile:path]]) { return YES; }
  return [self writeToFile:path atomically:atomically];
}


- (unsigned)lineCount
{
    unsigned count = 0;
    NSUInteger location = 0;

/// unsigned location = 0;

    while (location < [self length])
    {
        // get next line start and set current location to it
        [self getLineStart:nil end:&location contentsEnd:nil forRange:NSMakeRange(location,1)];
        count += 1;
    }

    return count;
}

- (BOOL) containsSubstring:(NSString *)substring 
{
    BOOL substringFound = NO;
    NSRange range = [self rangeOfString:substring];

    if (range.location != NSNotFound)
    {
        substringFound = YES;
    }
    return substringFound;
}

- (BOOL)containsString:(NSString *)aString
{
    return [self containsString:aString ignoringCase:NO];
}

- (BOOL)containsString:(NSString *)aString ignoringCase:(BOOL)flag
{
    unsigned mask = (flag ? NSCaseInsensitiveSearch : 0);
    NSRange range = [self rangeOfString:aString options:mask];
    return (range.length > 0);
}

-(NSArray *) splitToSize:(unsigned)size
{
    NSMutableArray *splitStrings = [NSMutableArray array];

    int count = 0;
    int i = 0;
    unsigned loc = 0;
    NSString *tempString;

    count = [self length] / size;


    for (i=0; i < count; i++)
      {
        loc = size * i;

        tempString = [self substringWithRange:NSMakeRange(loc,size)];
        [splitStrings addObject: [tempString copy]];
      }

    loc = size * count;

    tempString = [self substringFromIndex:loc];

    [splitStrings addObject: [tempString copy]];

    return splitStrings;
}

-(NSString *)removeTabsAndReturns
{
    NSMutableString *outputString = [NSMutableString string];
    NSCharacterSet *charSet;
    NSString *temp;

    NSScanner *scanner = [NSScanner scannerWithString:self];

    charSet = [NSCharacterSet characterSetWithCharactersInString:@"\n\r\t"];

    while ([scanner scanUpToCharactersFromSet:charSet intoString:&temp])
	{
		[outputString appendString:temp];
	}
    return [[outputString copy] autorelease];
}

-(NSString *)removeSquareBrackets
{
    NSMutableString *outputString = [NSMutableString string];
    NSCharacterSet *charSet;
    NSString *temp;

    NSScanner *scanner = [NSScanner scannerWithString:self];

    charSet = [NSCharacterSet characterSetWithCharactersInString:@"[]"];

    while ([scanner scanUpToCharactersFromSet:charSet intoString:&temp])
	{
		[outputString appendString:temp];
	}
    return [[outputString copy] autorelease];
}

-(NSString*)newlineToCR
{
    NSMutableString *str = [NSMutableString string];
    [str setString: self];

    [str replaceOccurrencesOfString:@"\n" withString:@"\r" 
							options:NSLiteralSearch 
							  range:NSMakeRange (0, [str length])];
    return [[str copy] autorelease];
}

-(NSString *)safeFilePath
{
int numberWithName = 1;
BOOL isDir;
NSString *safePath = [[NSString alloc] initWithString:self];

if ([[NSFileManager defaultManager] fileExistsAtPath:safePath
                                         isDirectory:&isDir])
{
while ([[NSFileManager defaultManager] fileExistsAtPath:safePath
                                            isDirectory:&isDir])
    {
        [safePath release];
        safePath = [[NSString alloc] initWithFormat:@"%@ %d.%@",
            [self       stringByDeletingPathExtension],
            numberWithName,[self pathExtension]];

        numberWithName++;
    }
}

return safePath;
}

-(NSRange)whitespaceRangeForRange:(NSRange)characterRange
{
    NSString *string = [[self copy] autorelease];
    NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    unsigned int areamax = NSMaxRange(characterRange);
    unsigned int length = [string length];
    
    NSRange start = [string rangeOfCharacterFromSet:whitespaceSet
					    options:NSBackwardsSearch
					      range:NSMakeRange(0, characterRange.location)];
    
    if (start.location == NSNotFound)
    {
        start.location = 0;
    }  
    else 
    {
        start.location = NSMaxRange(start);
    }
    
    NSRange end = [string rangeOfCharacterFromSet:whitespaceSet
					  options:0
					    range:NSMakeRange(areamax, length - areamax)];
    
    if (end.location == NSNotFound)
        end.location = length;
    
    NSRange searchRange = NSMakeRange(start.location, end.location - start.location); 
    //last whitespace to next whitespace
    return searchRange;
}

// Useful for parsing strings, in conjunction with rangeOf... methods.
- (NSString *)substringBeforeRange:(NSRange)range
{
  return [self substringToIndex:range.location];
}

- (NSString *)substringAfterRange:(NSRange)range
{
  return [self substringFromIndex:NSMaxRange (range)];
}

#include <regex.h>


 * - (NSArray *) findRegularExpression:(NSString *)re ignoreCase:(BOOL)ignoreCase;
 *
 * Apply the given regular expression (see re_format(7)) to the string and return an array of
 * substrings corresponding to any matched parenthesized subexpressions.  Note that the first
 * element of the returned array is the substring matched by the entire regular expression,
 * element 1 is the match for the first subexpression, and so on.  [NSNull null] is returned
 * for elements that are not matched.
 *
 * Sample usage:
 *
 * NSString *testStr = [NSString stringWithString:@"<?xml version=\"1.0\" encoding=\"UTF-16\"?>"];
 * NSArray *matches = [testStr findRegularExpression:@"version=\"([^\"]+)+.*encoding=\"([^\"]+)+" ignoreCase:YES];
 * NSLog(@"matches: %@", matches);
 *
 * Result:
 *
 * matches: <CFArray 0x134d540 [0xa01900e0]>{type = mutable-small, count = 3, values = (
 *      0 : <CFString 0x134d910 [0xa01900e0]>{contents = "version="1.0" encoding="UTF-16"}
 *      1 : <CFString 0x134d940 [0xa01900e0]>{contents = "1.0"}
 *      2 : <CFString 0x134d950 [0xa01900e0]>{contents = "UTF-16"}
 * )}


static void raise_reg_error_exception(const char* name, int errorcode, regex_t* regex)
{
    NSMutableData*  errorString = [NSMutableData data];
    
    [errorString setLength:regerror(errorcode, regex, NULL, 0)];

    size_t errorSize = regerror(errorcode, regex, [errorString mutableBytes], [errorString length]);

    regfree(regex);

    NSCAssert2(errorSize == [errorString length],
               @"Unexpected size in raise_reg_error_exception: %zu, %zu",
               errorSize, [errorString length]);

///NSCAssert2(errorSize == [errorString length],
///@"Unexpected size in raise_reg_error_exception: %d, %d",
///errorSize, [errorString length]);
 
    [NSException raise: NSInvalidArgumentException
                format: @"%s: %s", name, [errorString bytes]];
}

- (NSArray *) findRegularExpression:(NSString *)re ignoreCase:(BOOL)ignoreCase;
{
    regex_t regex;
    int regCompFlags = REG_EXTENDED;
    int regExecFlags = 0;
    int err = 0;

    //NSLog(@"@\"%@\": findRegularExpression:@\"%@\" ignoreCase:%s", self, re, (ignoreCase ? "YES" : "NO"));

    if (ignoreCase)
    {
        regCompFlags |= REG_ICASE;
    }

    // Compile the regular expression
    if ((err = regcomp(&regex, [re UTF8String], regCompFlags)) != 0)
    {
        // Failed to compile the RE, issue a diagnostic message
        raise_reg_error_exception("regcomp", err, &regex);
        return nil;
    }

    //NSLog(@"match count: %d", 1 + regex.re_nsub);

    NSMutableData*  matchData = [NSMutableData dataWithCapacity: (1 + regex.re_nsub) * sizeof (regmatch_t)];
    regmatch_t*     matches   = [matchData mutableBytes];

    // Execute the compiled regular expression
    if ((err = regexec(&regex, [self UTF8String], 1 + regex.re_nsub, matches, regExecFlags)) != 0)
    {
        if (err != REG_NOMATCH)
        {
            raise_reg_error_exception("regexec", err, &regex);
        }

        // The "nil" return indicates there was no match.  No need for a diagnostic.
        regfree(&regex);
        return nil;
    }

    // Place the matches in an array and return them
    NSMutableArray *matchArray = [NSMutableArray arrayWithCapacity: 1 + regex.re_nsub];
    int m;

    for (m = 0; m <= regex.re_nsub; m++)
    {
        if (matches[m].rm_so == -1)
        {
            [matchArray addObject: [NSNull null]];
        }
        else
        {
            NSRange matchRange = NSMakeRange(matches[m].rm_so, (matches[m].rm_eo - matches[m].rm_so));
            
            [matchArray addObject:[self substringWithRange:matchRange]];
        }
    }

    regfree(&regex);

    return matchArray;
}

-(BOOL)isValidURL
{
    return ([NSURL URLWithString:self] != nil);
}

// Replaces all XML/HTML reserved chars with entities.
- (NSString *)stringSafeForXML
{
  NSMutableString *str = [NSMutableString stringWithString:self];
  NSRange all = NSMakeRange (0, [str length]);
  [str replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:all];
  [str replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:all];
  [str replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch range:all];
  [str replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:all];
  [str replaceOccurrencesOfString:@"'" withString:@"&apos;" options:NSLiteralSearch range:all];
  return str;
}

- (BOOL)isIntegerString
{
    NSScanner *scanner = [NSScanner scannerWithString: self];
    return ([scanner scanInt: nil] && [scanner isAtEnd]);
}

- (BOOL)isAlphanumericString
{
    NSScanner *scanner = [NSScanner scannerWithString: self];
    return ([scanner scanCharactersFromSet: [NSCharacterSet alphanumericCharacterSet] intoString: nil] && [scanner isAtEnd]);
}

- (BOOL)isDecimalNumberString
{
	NSScanner *scanner = [NSScanner scannerWithString: self];
	return ([scanner scanDecimal: nil] && [scanner isAtEnd]);
}

- (BOOL)initialCaps
{
    return [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[self characterAtIndex:0]];
}

- (BOOL)isCellRef
{
    return ([self initialCaps] && [self isAlphanumericString]);
}

- (BOOL)isCapitalizedString
{
    return [self isEqualToString:[self capitalizedString]];
}
*/
@end
