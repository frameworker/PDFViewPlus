//  DraggableScrollView.h

#import "DraggableScrollView.h"

@implementation DraggableScrollView

#pragma mark PRIVATE CLASS METHODS

//	dragCursor -- Return a cursor which hints that the user can drag.
//	FIXME: A hand would be better than this pointing finger.
+ (NSCursor *) dragCursor
{
    static NSCursor	*openHandCursor = nil;

    if (openHandCursor == nil)
    {
        NSImage		*image;

        image = [NSImage imageNamed: @"fingerCursor"];
        openHandCursor = [[NSCursor alloc] initWithImage: image
            hotSpot: NSMakePoint (8, 8)]; // guess that the center is good
    }

    return openHandCursor;
}

#pragma mark PRIVATE INSTANCE METHODS

//	canScroll -- Return YES if the user could scroll.
- (BOOL) canScroll
{
    if ([[self documentView] frame].size.height > [self documentVisibleRect].size.height)
        return YES;
    if ([[self documentView] frame].size.width > [self documentVisibleRect].size.width)
        return YES;

    return NO;
}


#pragma mark PUBLIC INSTANCE METHODS -- OVERRIDES FROM NSScrolLView

//	tile -- Override to update the document cursor.
- (void) tile
{
    [super tile];

    //	If the user can scroll right now, make our document cursor reflect that.
	if ([self canScroll])
        [self setDocumentCursor: [[self class] dragCursor]];
    else
        [self setDocumentCursor: [NSCursor arrowCursor]];
}

#pragma mark PUBLIC INSTANCE METHODS

//	dragDocumentWithMouseDown: -- Given a mousedown event, which should be in
//	our document view, track the mouse to let the user drag the document.
- (BOOL) dragDocumentWithMouseDown: (NSEvent *) theEvent // RETURN: YES => user dragged (not clicked)
{
	NSPoint 		initialLocation;
    NSRect			visibleRect;
    BOOL			keepGoing;
    BOOL			result = NO;

	initialLocation = [theEvent locationInWindow];
    visibleRect = [[self documentView] visibleRect];
    keepGoing = YES;

    while (keepGoing)
    {
        theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask];
        switch ([theEvent type])
        {
            case NSLeftMouseDragged:
            {
                NSPoint	newLocation;
                NSRect	newVisibleRect;
                float	xDelta, yDelta;

                newLocation = [theEvent locationInWindow];
                xDelta = initialLocation.x - newLocation.x;
                yDelta = initialLocation.y - newLocation.y;

                //	This was an amusing bug: without checking for flipped,
                //	you could drag up, and the document would sometimes move down!
                if ([[self documentView] isFlipped])
                    yDelta = -yDelta;

                //	If they drag MORE than one pixel, consider it a drag
                if ( (abs (xDelta) > 1) || (abs (yDelta) > 1) )
                    result = YES;

                newVisibleRect = NSOffsetRect (visibleRect, xDelta, yDelta);
                [[self documentView] scrollRectToVisible: newVisibleRect];
            }
            break;

            case NSLeftMouseUp:
                keepGoing = NO;
                break;

            default:
                /* Ignore any other kind of event. */
                break;
        }								// end of switch (event type)
    }									// end of mouse-tracking loop

    return result;
}

@end
