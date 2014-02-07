//
//  JBMyScene.m
//  JoystickBall
//
//  Created by Christopher Laganiere on 2/6/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "JBMyScene.h"

#define STICK_CENTER_TARGET_POS_LEN 20.0f

@interface JBMyScene()

@property SKSpriteNode *joystickBase;
@property SKSpriteNode *joystickControl;
@property SKSpriteNode *ball;
@property bool touching;
@property CGVector forceVector;

@end

@implementation JBMyScene



-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor grayColor];
        self.anchorPoint = CGPointMake (0.5,0.5);
        
        
        
        // 1 Create a physics body that borders the screen
        CGRect myFrame = CGRectMake(2*self.frame.origin.x,2*self.frame.origin.y, self.frame.size.width, self.frame.size.height); //adjusting for anchorpoint
        SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:myFrame];
        // 2 Set physicsBody of scene to borderBody
        self.physicsBody = borderBody;
        // 3 Set the friction of that physicsBody to 0
        self.physicsBody.friction = 0.0f;
         
        
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        
        SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"ball80"];
        ball.position = self.anchorPoint;
        ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.frame.size.width/2];
        ball.physicsBody.mass = 2.0f;
        ball.physicsBody.friction = 0.4f;
        ball.physicsBody.restitution = 1.0f; //bounciness
        ball.physicsBody.dynamic = YES;
        [self addChild:ball];
        self.ball = ball;
        
        

    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        [self initStick:location];
    }
    self.touching = true;
    [self touchEvent:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchEvent:touches];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.joystickBase) {
        self.joystickBase.alpha = 0.0;
    }
    self.touching = false;
}

- (void)touchEvent:(NSSet *)touches
{
    
    if([touches count] != 1)
        return ;
    
    UITouch *touch = [touches anyObject];
    UIView *view = [touch view];
    if(view != self.view)
        return ;
    
    CGPoint touchPoint = [touch locationInNode:self.joystickBase];
    CGPoint dtarget, dir;
    dir.x = touchPoint.x;
    dir.y = touchPoint.y;
    double len = sqrt(dir.x * dir.x + dir.y * dir.y);
    
    if(len < 10.0 && len > -10.0)
    {
        // center pos
        dtarget.x = 0.0;
        dtarget.y = 0.0;
        dir.x = 0;
        dir.y = 0;
    }
    else
    {
        double len_inv = (1.0 / len);
        dir.x *= len_inv;
        dir.y *= len_inv;
        dtarget.x = dir.x * STICK_CENTER_TARGET_POS_LEN;
        dtarget.y = dir.y * STICK_CENTER_TARGET_POS_LEN;
    }
    
    //[self.ball.physicsBody applyImpulse:CGVectorMake(10.0f, -10.0f)];
    self.forceVector = CGVectorMake(50*dtarget.x, 50*dtarget.y);
    [self applyForce];
    
    self.joystickControl.position = dtarget;
    
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (self.touching) {
        [self applyForce];
    }
}

#pragma mark joystick

-(void) initStick:(CGPoint)location
{
    
    if (!self.joystickControl) {
        SKSpriteNode *joystickBase = [SKSpriteNode spriteNodeWithImageNamed:@"joystickBase"];
        joystickBase.anchorPoint = CGPointMake(0.5, 0.5);
        [self addChild:joystickBase];
        self.joystickBase = joystickBase;
        
        SKSpriteNode *joystickControl = [SKSpriteNode spriteNodeWithImageNamed:@"joystick_normal"];
        joystickControl.anchorPoint = CGPointMake(0.5, 0.5);
        joystickControl.position = CGPointMake(0, 0);
        [joystickBase addChild:joystickControl];
        self.joystickControl = joystickControl;
    }
    
    self.joystickBase.alpha = 1.0;
    self.joystickBase.position = location;
}

#pragma mark ball action

-(void)applyForce
{
    [self.ball.physicsBody applyForce:self.forceVector];
}

@end
