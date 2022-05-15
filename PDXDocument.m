//  PDFDocument.m

#import "PDXDocument.h"
#import "NSString+CocoaDevUsersAdditions.h"
#import "PDFImageView.h"

@implementation PDXDocument

- (double) scaleFactor
{
	return scaleFactor;
}

- (void)setScaleFactor:(double) newScaleFactor
{
	scaleFactor = newScaleFactor;
}

- (NSString *) pdfPath
{
	return pdfPath;
}

- (void)setPdfPath:(NSString *)newPdfPath
{
	[newPdfPath retain];
	[pdfPath release];
	pdfPath = newPdfPath;
}

- (NSImage *) pdfImage
{
	return pdfImage;
}

- (void)setPdfImage:(NSImage *)newPdfImage
{
	[newPdfImage retain];
	[pdfImage release];
	pdfImage = newPdfImage;
}

- (NSString *) pdfFileContents 
{
	return pdfFileContents;
}

- (void)setPdfFileContents:(NSString *)newPdfFileContents 
{
	[newPdfFileContents retain];
	[pdfFileContents release];
	pdfFileContents = newPdfFileContents;
}

- (id)init
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		[self setScaleFactor:1];
    }
    return self;
}

- (NSData *)dataRepresentationOfType:(NSString *)aType
{
    // Insert code here to write your document from the given data.  You can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
    
    // For applications targeted for Tiger or later systems, you should use the new Tiger API -dataOfType:error:.  In this case you can also choose to override -writeToURL:ofType:error:, -fileWrapperOfType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    return nil;
}

// Read your document from the given data.  You can also choose to override -loadFileWrapperRepresentation:ofType: or -readFromFile:ofType: instead.
// For applications targeted for Tiger or later systems, you should use the new Tiger API readFromData:ofType:error:.  In this case you can also choose to override -readFromURL:ofType:error: or -readFromFileWrapper:ofType:error: instead.

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
    NSString * thePdfPath = [[self fileURL] path];

    [self setPdfPath:thePdfPath];
	
	// Read the data
	
	NSData *pdfData = [NSData dataWithContentsOfFile:pdfPath];

	NSString *thePdfFileContents = [self readFileContents:pdfData];
	[self setPdfFileContents:thePdfFileContents];

    return YES;
}

- (NSString *) readFileContents:(NSData *)theData
{
    NSString *theFileContents = [[NSString alloc] initWithData:theData encoding:NSASCIIStringEncoding]; // NSUTF8StringEncoding
    return theFileContents;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"PDXDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.

	if ([self pdfPath] != nil)
	{
		[pdfView loadFromPath: pdfPath];
	}
    
    NSRect aFrame = NSMakeRect(0, 0, 100, 100);
    NSTextField * newTextField = [[NSTextField alloc] initWithFrame:aFrame];
    [pdfView addSubview:newTextField];
}

- (void) zoomIn: (id) sender
{
	double newScaleFactor = [self scaleFactor]* sqrt(sqrt(2.0));
	[self setScaleFactor:newScaleFactor];
	[pdfView doZoom:newScaleFactor];
	
///	[self resizeWindow];
}

- (void) zoomOut: (id) sender
{
	double newScaleFactor = [self scaleFactor]/sqrt(sqrt(2.0));
	[self setScaleFactor:newScaleFactor];
	[pdfView doZoom:newScaleFactor];

///	[self resizeWindow];
}

- (BOOL) validateMenuItem: (NSMenuItem *) menuItem
{
	BOOL enable = NO;

	double kMaxScaleFactor = 2.0;
	double kMinScaleFactor = 1.0;
	
	if ([menuItem action] == @selector(zoomIn:))
	{
		if ([self scaleFactor] < (kMaxScaleFactor - 0.01))
		{
			enable = YES;
		}
	}
	else if ([menuItem action] == @selector(zoomOut:))
	{
		if ([self scaleFactor] > (kMinScaleFactor + 0.01))
		{
			enable = YES;
		}
	}
	else
	{
		NSLog(@"menuItem: %@", menuItem);
		enable = [super validateMenuItem:menuItem];
	}
	
	return enable;
}

- (void)printShowingPrintPanel:(BOOL)flag
{
	NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];
	
	[printInfo setLeftMargin:   0];
	[printInfo setBottomMargin: 0];
	[printInfo setRightMargin:  0];
	[printInfo setTopMargin:    0];

//	[printInfo isHorizontallyCentered] defaults to YES
//	[printInfo isVerticallyCentered]   defaults to YES

	[printInfo setHorizontallyCentered: NO]; // default was YES
	[printInfo setVerticallyCentered:   NO]; // default was YES

	// verticalPaginationMode   defaults to NSAutoPagination
	// horizontalPaginationMode defaults to NSClipPagination
	NSData* pdfRepData = [pdfView dataWithPDFInsideRect:[pdfView frame]];

    NSPDFImageRep * pdfRepCopy = [[NSPDFImageRep alloc] initWithData: pdfRepData];
	
	PDFImageView * printView = [[PDFImageView alloc] initWithFrame: [pdfView frame]];

	NSImage * imageToPrint = [[[NSImage alloc] init] autorelease];
	
	[imageToPrint addRepresentation: pdfRepCopy];

	[printView setImage: imageToPrint];

	// UNSCALE IF SCALED!
	double inverseScaleFactor = 1.0/[self scaleFactor];
	[printView doZoom:inverseScaleFactor]; // THIS WORKS BUT HAS A BLANK PAGE AT END OF DOC.

	NSPrintOperation * printOp;
	printOp = [NSPrintOperation printOperationWithView:printView 
											 printInfo:printInfo];
	[printOp setShowPanels: YES]; // WAS flag
   
	[printOp runOperation];
}

@end









