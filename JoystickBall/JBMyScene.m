//
//  JBMyScene.m
//  JoystickBall
//
//  Created by Christopher Laganiere on 2/6/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "JBMyScene.h"

#define STICK_CENTER_TARGET_POS_LEN 80.0f
#define starTimerMax 150
#define difficultyTime 1500
#define forceVar 25

@interface JBMyScene()

@property SKSpriteNode *joystickBase;
@property SKSpriteNode *joystickControl;
@property SKSpriteNode *ball;
@property bool touching;
@property CGVector forceVector;
@property int starCounter;
@property int starTimer;
@property int maxStars;
@property int difficultyTimer;
@property double ballScale;

@end

@implementation JBMyScene



-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor grayColor];
        self.anchorPoint = CGPointMake (0.5,0.5);
        
        CGRect myFrame = CGRectMake(2*self.frame.origin.x,2*self.frame.origin.y, self.frame.size.width, self.frame.size.height); //adjusting for anchorpoint
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:myFrame];
        self.physicsBody.categoryBitMask = edgeCategory;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.contactTestBitMask = 0;
        self.physicsWorld.gravity = CGVectorMake(3,3);
        self.physicsWorld.contactDelegate = self;
        
        self.starTimer = arc4random() % starTimerMax;
        self.maxStars = 2;
        self.difficultyTimer = difficultyTime;
        self.ballScale = 1.0;
        
        // Create a physics body that borders the screen
        
         
        
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        
        SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"ball80"];
        ball.position = self.anchorPoint;
        ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.frame.size.width/2];
        ball.physicsBody.mass = 2.0f;
        ball.physicsBody.friction = 0.4f;
        ball.physicsBody.restitution = 0.3f; //bounciness
        ball.physicsBody.dynamic = YES;
        
        ball.physicsBody.categoryBitMask = ballCategory;
        ball.physicsBody.collisionBitMask = edgeCategory;
        ball.physicsBody.contactTestBitMask = starCategory;
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
    
    else if (len >= STICK_CENTER_TARGET_POS_LEN || len <= -STICK_CENTER_TARGET_POS_LEN)
    {
        //double len_inv = (1.0 / len);
        //dir.x *= len_inv;
        //dir.y *= len_inv;
        dir.x = (1.0/len) * dir.x * STICK_CENTER_TARGET_POS_LEN;
        dir.y = (1.0/len) * dir.y * STICK_CENTER_TARGET_POS_LEN;
    }
    
    
    self.forceVector = CGVectorMake(forceVar*dir.x, forceVar*dir.y);
    [self applyForce];
    
    self.joystickControl.position = dir;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (self.touching) {
        [self applyForce];
    }
    
    if (self.difficultyTimer <= 0) {
        //increase number of objects to hit
        self.maxStars++;
        self.difficultyTimer = difficultyTime;
    } else {
        self.difficultyTimer--;
    }
    
    if (self.starTimer < 1) {
        [self addStar];
        self.starTimer = arc4random() % starTimerMax;
    } else {
        self.starTimer--;
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

#pragma mark physics

-(void)applyForce //on ball
{
    [self.ball.physicsBody applyForce:self.forceVector];
}
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // Handle contacts between two physics bodies.
    SKPhysicsBody *firstBody;
    SKPhysicsBody *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    // Asteroids that hit planets are destroyed.
    if (((firstBody.categoryBitMask & starCategory) != 0) &&
        ((secondBody.categoryBitMask & ballCategory) != 0))
    {
        self.starCounter--;
        //[firstBody.node removeFromParent];
        [firstBody.node runAction:[SKAction fadeAlphaBy:-.5 duration:1] completion:^{
            [firstBody.node removeFromParent];
        }];
    }
}

#pragma mark extras

-(void)addStar
{
    if (self.starCounter >= self.maxStars) return;
    
    SKSpriteNode *newStar = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(50, 50)];
    int realX = self.size.width/2;
    int realY = self.size.height/2;
    int randomX = arc4random() % realX;
    int randomY = arc4random() % realY;
    
    if (arc4random() % 2) randomX *= -1;
    if (arc4random() % 2) randomY *= -1;
    
    CGPoint starPos = CGPointMake(randomX, randomY);
    newStar.position = starPos;
    newStar.name = @"star";
    newStar.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:newStar.size];
    newStar.physicsBody.categoryBitMask = starCategory;
    newStar.physicsBody.collisionBitMask = ballCategory | edgeCategory;
    newStar.physicsBody.contactTestBitMask = 0;
    
    [self addChild:newStar];
    
    SKAction *starAct = [SKAction group:@[[SKAction colorizeWithColor:[UIColor redColor] colorBlendFactor:0.5 duration:10], [SKAction scaleBy:0.3 duration:10]]];
    
    [newStar runAction:starAct completion:^{
        [self endGame];
    }];
    
    self.starCounter++;
}

-(void)endGame
{
    NSLog(@"game over");
    [self enumerateChildNodesWithName:@"star" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
        self.starCounter--;
    }];
}

@end
