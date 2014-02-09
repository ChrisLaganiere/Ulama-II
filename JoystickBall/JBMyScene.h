//
//  JBMyScene.h
//  JoystickBall
//

//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

// These constans are used to define the physics interactions between physics bodies in the scene.
static const uint32_t starCategory  =  0x1 << 0;
static const uint32_t ballCategory  =  0x1 << 1;
static const uint32_t edgeCategory  =  0x1 << 2;

@interface JBMyScene : SKScene <SKPhysicsContactDelegate>

@end
