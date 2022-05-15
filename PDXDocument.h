//  PDXDocument.h

#import <Cocoa/Cocoa.h>
@class PDFImageView;
@class NSWindow;

@interface PDXDocument : NSDocument
{
	IBOutlet PDFImageView	*pdfView;
	IBOutlet NSWindow		*window;
			 double			scaleFactor;
			 
			 NSString		*pdfPath;
			 NSImage		*pdfImage;
			 NSString		*pdfFileContents;
}

- (double) scaleFactor;
- (void)setScaleFactor:(double) newScaleFactor;

- (NSString *) pdfPath;
- (void) setPdfPath:(NSString *) newPdfPath;

- (NSImage *) pdfImage;
- (void) setPdfImage:(NSImage *) newPdfImage;

- (NSString *) pdfFileContents;

- (void)setPdfFileContents:(NSString *)newPdfFileContents;

- (id)init;

- (NSData *) dataRepresentationOfType:(NSString *)aType;

- (BOOL) loadDataRepresentation:(NSData *)data ofType:(NSString *)aType;

- (NSString *) readFileContents:(NSData *)theData;

// MENU COMMANDS

- (IBAction) zoomIn: (id) sender;

- (IBAction) zoomOut: (id) sender;

// - (BOOL) validateMenuItem: (NSMenuItem *) menuItem;

// - (void)printShowingPrintPanel:(BOOL)flag;

@end
