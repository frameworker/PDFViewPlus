//  PDFImageView.h
//
//	PDFImageView displays a multi-page PDF (Portable Document Format) file
//	in a single view (NSImageView would display only the first page), and
//	also handles printing.

#import <Cocoa/Cocoa.h>

@interface PDFImageView : NSImageView
{
	NSInteger   pages;
	NSSize      pageSize;
	NSSize      clipViewSize;
}

- (NSInteger) pages;
- (void) setPages:(NSInteger)newPages;

- (NSSize) pageSize;
- (void) setPageSize:(NSSize)newPageSize;

#pragma mark PUBLIC INSTANCE METHODS

//	loadFromPath: -- Load the PDF at the specified path into the view.
//	This automatically resizes the view to fit all pages of the document.
- (void) loadFromPath: (NSString *) path;

- (NSRect) roundedRect:(NSRect)rectToRound;

- (void) doZoom: (double) theScaleFactor;

@end
