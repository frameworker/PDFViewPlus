# PDFViewPlus
Objective-C sample to highlight drawing problem in Catalina and above.

Notice that the fancy drawInRect in PDFImageView.m screws up in 10.15 and greater but works okay in 10.14 and lower.

        // Draws image in 10.15+ but without opacity parameter/
        [rep drawInRect: onePageBounds];
        
        // Draws image up to Mohave with opacity parameter
        // In Catalina and above only draws the same page repeatedly

        [(NSImageRep *)rep drawInRect:onePageBounds
                             fromRect:NSZeroRect
                            operation:NSCompositingOperationSourceOver // NSCompositeSourceOver
                             fraction:[self backgroundOpacity] // 0.0 < x < 1.0
                       respectFlipped:NO
                                hints:NULL];
                                
