//
// TTWKActivityIndicator
// Copyright (c) 2015, TouchTribe B.V. All rights reserved.
//
// This source code is available under the MIT license. See the LICENSE file for more info.
//

#import <UIKit/UIKit.h>
#import <WatchKit/WatchKit.h>

/** 
 * Simplifies creating of AppleWatch-style activity animations at run time.
 *
 * It's not the actual control, but a helper that is used to prerender a sequence of images 
 * (as a single 'animated' instance of UIImage) which then is fed to WKInterfaceImage.
 *
 * It can also be used in regular iOS apps within drawRect:, in which case the initial 'fade in'
 * sequence can be also animated. (It cannot be used on AppleWatch yet, because there is no way 
 * to loop the animation from a non-first frame.)
 *
 * To use it with WatchKit you'll need to add a WKInterfaceImage into your storyboard and then 
 * set its image into something returned by one of the -animatedImage* methods, for example:
 *
 * \begincode
 *     [self.activityIndicatorImage
 *         setImage:[TTWKActivityIndicator
 *             animatedImageWithColor:[UIColor colorWithRed:0.8588 green:0.0196 blue:0.0706 alpha:1.0]
 *         ]
 * 	   ];
 *     [self.activityIndicatorImage startAnimating];
 * \endcode
 *
 * Or better use shortcuts in TTWKActivityIndicator category of WKInterfaceImage, that already
 * use device's image cache:
 *
 * \begincode
 *     [self.activityIndicatorImage 
 *         setActivityIndicatorImageWithColor:[UIColor colorWithRed:0.8588 green:0.0196 blue:0.0706 alpha:1.0]
 *     ];
 * \endcode
 */
@interface TTWKActivityIndicator : NSObject

/** Returns a looped animated image of the AppleWatch-style activity indicator of the given color 
 * and specific radius of a single bubble (if 0, then 4 points is used by default). */
+ (UIImage *)animatedImageWithColor:(UIColor *)color bubbleRadius:(CGFloat)bubbleRadius;

/** Returns a looped animated image of the AppleWatch-style activity indicator of the default size 
 * and the given color. */
+ (UIImage *)animatedImageWithColor:(UIColor *)color;

@end

/** 
 * Shortcuts for setting up activity animation over existing instances of WKInterfaceImage.
 * These shortcuts use device's image cache, so it might be better to use them instead of
 * TTWKActivityIndicator directly.
 */
@interface WKInterfaceImage (TTWKActivityIndicator)

/** 
 * Generates AppleWatch-style activity indicator animation of given color and size 
 * as 'animated' UIImage, sets it to the receiver, and then starts the animation.
 *
 * Tries to cache the generated image in the device's image cache and reuse it later 
 * (if called with the same parameters of course).
 */
- (void)setActivityIndicatorImageWithColor:(UIColor *)color bubbleRadius:(CGFloat)bubbleRadius;

/** A shortcut for [self setActivityIndicatorImageWithColor:color bubbleRadius:0]. */
- (void)setActivityIndicatorImageWithColor:(UIColor *)color;

@end

/** 
 * WKInterfaceGroup should have the same shortcuts as the WKInterfaceImage.
 */
@interface WKInterfaceGroup (TTWKActivityIndicator)

- (void)setActivityIndicatorImageWithColor:(UIColor *)color bubbleRadius:(CGFloat)bubbleRadius;

- (void)setActivityIndicatorImageWithColor:(UIColor *)color;

@end

/** 
 * The stuff that is not interested for normal use cases.
 */
@interface TTWKActivityIndicator (Subclasses)

/** 
 * Initializes with the color of the bubble and the radius of a single bubble 
 * (set it to 0 to use the default one).
 */
- (id)initWithColor:(UIColor *)color bubbleRadius:(CGFloat)bubbleRadius;

/** 
 * Draws a single frame of the animation corresponding to the provided time.
 *
 * It will do this in the center of the rectangle with its origin at (0, 0) and size returned by -size method below.
 *
 * Note that the animation starts with its initial sequence when the bubbles fade in (at the timestamp 0),
 * you can use -loopStartTime to skip past this part.
 */
- (void)drawForTime:(NSTimeInterval)time;

/** 
 * Time the looped part of the animation begins.
 *
 * Together with -loopDuration this is handy when you want to skip the fade in sequence 
 * and capture only the looped part, like -animatedImage* methods do.
 */
- (NSTimeInterval)loopStartTime;

/** How long is a single looped part of the animation. */
- (NSTimeInterval)loopDuration;

/** The size of a minimal rect safely enclosing the whole animation. */
- (CGSize)size;

/** An animated image corresponding to the looped part of the animation. */
- (UIImage *)animatedImage;

/** The key that can be used used to store a generated animation in the AppleWatch image cache. */
+ (NSString *)cacheKeyForColor:(UIColor *)color bubbleRadius:(CGFloat)bubbleRadius;

@end
