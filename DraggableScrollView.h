//  DraggableScrollView.h

#import <Cocoa/Cocoa.h>

@interface DraggableScrollView : NSScrollView

//	dragDocumentWithMouseDown: -- Given a mousedown event, which should be in
//	our document view, track the mouse to let the user drag the document.
- (BOOL) dragDocumentWithMouseDown:	// RETURN: YES => user dragged (not clicked)
    (NSEvent *) theEvent;

@end
