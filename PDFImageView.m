//  PDFImageView.m

#import "PDFImageView.h"

@implementation PDFImageView

- (NSInteger) pages
{
	return pages;
}

- (void) setPages:(NSInteger)newPages
{
	pages = newPages;
}

- (NSSize) pageSize
{
	return pageSize;
}

- (void) setPageSize:(NSSize)newPageSize
{
	pageSize = newPageSize;
}

#pragma mark PRIVATE INSTANCE METHODS

//	pdfRep -- Return the image-representation used for PDFs. This
//	representation can tell us things like the PDF's page count.
- (NSPDFImageRep *) pdfRep
{
    //	Assume our sole representation is the PDF representation.
    return (NSPDFImageRep *)[[[self image] representations] lastObject];
}

- (void) awakeFromNib
{
	NSClipView *clipView = [[self enclosingScrollView] contentView];
	NSParameterAssert(nil != clipView);
	clipViewSize = [clipView frame].size;
	[clipView setPostsFrameChangedNotifications: YES];
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(clipViewFrameDidChange:)
												 name: NSViewFrameDidChangeNotification
											   object: clipView];
}

- (void) clipViewFrameDidChange:(NSNotification *) notification
{
     NSSize newClipViewSize = [[notification object] frame].size;

     NSPoint scrollPosition = [[notification object] bounds].origin;
     scrollPosition.y = (scrollPosition.y + (clipViewSize.height - newClipViewSize.height));
     [self scrollPoint: scrollPosition];

     clipViewSize = newClipViewSize;
}

#pragma mark PUBLIC INSTANCE METHODS

//	loadFromPath: -- Load the PDF at the specified path into the view.
//	This automatically resizes the view to fit all pages of the document.
- (void) loadFromPath: (NSString *) path
{
    NSPDFImageRep	*pdfRep;
    NSImage			*pdfImage;
    NSRect			frame;

    //	Load the file into an image-representation,
    //	then create an image and add the representation to it.
    pdfRep = (NSPDFImageRep *)[NSPDFImageRep imageRepWithContentsOfFile: path];
    pdfImage = [[[NSImage alloc] init] autorelease];
    [pdfImage addRepresentation: pdfRep];

    //	Figure our frame by getting the bounds, which is really the size
    //	of one page, and multiplying the height by the page count.
    frame = [pdfRep bounds];
	[self setPages:[pdfRep pageCount]];
	[self setPageSize:frame.size];

    frame.size.height *= [pdfRep pageCount];

    //	Install the image (remember, we're an NSImageView subclass)
    [self setImage: pdfImage];

    //	Set our frame to match the PDF's full height (all pages)
    //	(don't involve our override of -setFrame:, or things won't work right)
    [super setFrame: frame];

    //	Always scroll to show the top of the image
    if ([self isFlipped])
        [self scrollPoint: NSMakePoint (0, 0)];
    else
        [self scrollPoint: NSMakePoint (0, frame.size.height)];
}

#pragma mark PUBLIC INSTANCE METHODS -- NSView OVERRIDES

- (void) drawRect: (NSRect) rect
{
    NSPDFImageRep    *rep;
    NSInteger       pageCount;
    NSInteger       pageNumber;
    NSRect            onePageBounds;
    
    //    Apparently, a PDF doesn't always draw its margins, so make them white
    //    by drawing our entire background as white.
    [[NSColor whiteColor] set];
    NSRectFill (rect);
    
    //    Get the information from the PDF image representation:
    //    how many pages, and how large is each one?
    rep = [self pdfRep];
    pageCount = [rep pageCount];
    
    //    Iterate through all pages
    for (pageNumber = 0; pageNumber < pageCount; pageNumber++)
    {
        //    Use the printing code (which uses one-based numbering) to find where
        //    this page appears.
        onePageBounds = [self rectForPage: (1+pageNumber)];
        
        //    Draw this page only if some of its bounds overlap the drawing area
        if (! NSIntersectsRect (rect, onePageBounds))
            continue;
        
        [rep setCurrentPage: pageNumber];
        
        // Draws image in 10.15+ but without opacity parameter/
        [rep drawInRect: onePageBounds];
        
        // Draws image up to Mohave with opacity parameter
        // In Catalina and above only draws the same page repeatedly depending on pageNumber
/*
        [(NSImageRep *)rep drawInRect:onePageBounds
                             fromRect:NSZeroRect
                            operation:NSCompositingOperationSourceOver // NSCompositeSourceOver
         //    fraction:[self backgroundOpacity] // 0.0 < x < 1.0
                             fraction:0.6
                       respectFlipped:NO
                                hints:NULL];
*/
    }
}


// Round the height and width only.
- (NSRect) roundedRect:(NSRect)rectToRound
{
	float height  = rectToRound.size.height;
	rectToRound.size.height = roundf(height);
	
	float width   = rectToRound.size.width;
	rectToRound.size.width = roundf(width);
	
	return rectToRound;
}

- (void) doZoom: (double) theScaleFactor
{	
    NSPDFImageRep	*pdfRep = [self pdfRep];

	NSSize size   = [pdfRep size];
	float width   = size.width;
	float height  = size.height;
	
	NSInteger pageCount = [pdfRep pageCount];
    
	NSRect zoomedRect = NSMakeRect(0, 0, width*theScaleFactor, height*theScaleFactor*pageCount);
	
	NSRect boundsRect = NSMakeRect(0, 0, width, height*pageCount);
	
	zoomedRect = [self roundedRect:zoomedRect];
	
	[self setFrame:zoomedRect];
  
	[self setBounds:boundsRect];

	[self setNeedsDisplay:YES];
}

#pragma mark PUBLIC INSTANCE METHODS -- NSView OVERRIDES FOR PRINTING

- (BOOL) knowsPageRange: (NSRangePointer) range
{
    range->location = 1; // page numbers are one-based
	
	range->length = [[self pdfRep] pageCount];

	NSRect theBounds  = [[self pdfRep] bounds];
	range->length = theBounds.size.height/pageSize.height;

    return NO; // NO WORKS !!! WHY IS THAT???
}

- (NSRect) rectForPage: (NSInteger) pageNumber // INPUT: ONE-based page number
{
    NSPDFImageRep	*rep;
	NSInteger       pageCount;
    NSRect			result;

    rep = [self pdfRep];
	pageCount = [rep pageCount];

    //	Start at the first page
	result = [rep bounds];

    if (! [self isFlipped])
        result = NSOffsetRect (result, 0.0, (pageCount-1)*result.size.height);

    //	Move to the N'th page
    if ([self isFlipped])
        result = NSOffsetRect (result, 0.0, (pageNumber-1) * result.size.height);
    else
        result = NSOffsetRect (result, 0.0, - (pageNumber-1) * result.size.height);

    return result;
}

@end
