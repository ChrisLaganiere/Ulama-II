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
#define difficultyTime 500
#define forceVar 25
#define initialMaxStars 2

#define scoreFontSize (isIpad ? 45 : 30)

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
@property int score;
@property SKLabelNode *scoreReport;
@property SKLabelNode *highscore;
@property SKLabelNode *scoreLabel;

@end

@implementation JBMyScene


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [UIColor colorWithRed:
                                0.390625 green:0.83203125 blue:
                                0.390625 alpha:1.0];
        self.anchorPoint = CGPointMake (0.5,0.5);
        
        CGRect myFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height); //adjusting for anchorpoint
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:myFrame];
        self.physicsBody.categoryBitMask = edgeCategory;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.contactTestBitMask = 0;
        self.physicsWorld.gravity = CGVectorMake(3,3);
        self.physicsWorld.contactDelegate = self;
        
        self.starTimer = arc4random() % starTimerMax;
        self.maxStars = initialMaxStars;
        self.difficultyTimer = difficultyTime;
        self.ballScale = 1.0;
        
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
        
        self.score = 0;
        SKLabelNode *scoreReport = [SKLabelNode labelNodeWithFontNamed:@"Imagine Font"];
        scoreReport.fontSize = scoreFontSize;
        scoreReport.fontColor = [UIColor whiteColor];
        scoreReport.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
        scoreReport.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        scoreReport.position = CGPointMake(self.frame.size.width/2-scoreFontSize,self.frame.size.height/2-45);
        scoreReport.text = [NSString stringWithFormat:@"%i",self.score];
        [self addChild:scoreReport];
        self.scoreReport = scoreReport;
        
        if (![[NSUserDefaults standardUserDefaults] integerForKey:@"highscore"]) {
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"highscore"];
        }
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
        self.starTimer = arc4random() % (starTimerMax-MIN(_maxStars, 100));
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
        ((secondBody.categoryBitMask & ballCategory) != 0) && ([firstBody.node.userData valueForKey:@"killed"] == [NSNumber numberWithBool:FALSE]))
    {
        self.starCounter--;
        self.score++;
        self.scoreReport.text = [NSString stringWithFormat:@"%i",self.score];
        [firstBody.node removeAllActions];
        [firstBody.node runAction:[SKAction fadeAlphaBy:-1.0 duration:1] completion:^{
            [firstBody.node removeFromParent];
        }];
        [firstBody.node.userData setValue:[NSNumber numberWithBool:TRUE] forKey:@"killed"];
    }
}

#pragma mark extras

-(void)addStar
{
    if (self.starCounter >= self.maxStars) return;
    
    SKSpriteNode *newStar = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(50, 50)];
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
    
    newStar.userData = [NSMutableDictionary dictionary];
    
    [newStar.userData setValue:[NSNumber numberWithBool:FALSE] forKey:@"killed"];
    
    [self addChild:newStar];
    
    SKAction *starAct = [SKAction group:@[[SKAction colorizeWithColor:[UIColor redColor] colorBlendFactor:0.5 duration:10], [SKAction scaleBy:0.3 duration:10]]];
    SKAction *starDeath = [SKAction sequence:@[[SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:1.0 duration:0],
                                               [SKAction scaleBy:6.0 duration:0],
                                               [SKAction fadeAlphaBy:-1.0 duration:.5],
                                               [SKAction waitForDuration:2.5]]];
    
    [newStar runAction:starAct completion:^{
        //no more collisions
        newStar.physicsBody.collisionBitMask = edgeCategory;
        newStar.physicsBody.contactTestBitMask = edgeCategory;
        //don't place any more stars
        self.starTimer = 10000;
        //kill other stars
        [self enumerateChildNodesWithName:@"star" usingBlock:^(SKNode *node, BOOL *stop) {
            if (node != newStar) {
                [node removeFromParent];
                self.starCounter--;
            }
        }];
        [self preEndGame];
        [self runAction:[SKAction waitForDuration:3.0] completion:^{
            [self endGame];
        }];

        [newStar runAction:starDeath completion:^{
            //kill other stars
        }];
    }];
    
    self.starCounter++;
}

-(void)preEndGame
{
    if (self.highscore) {
        [self.highscore removeFromParent];
        self.highscore = nil;
    }
    if (self.scoreLabel) {
        [self.scoreLabel removeFromParent];
        self.scoreLabel = nil;
    }
    if (self.score > [[NSUserDefaults standardUserDefaults] integerForKey:@"highscore"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:self.score forKey:@"highscore"];
    }
    
    SKLabelNode *highscore = [SKLabelNode labelNodeWithFontNamed:@"Imagine Font"];
    
    highscore.text = [NSString stringWithFormat:@"Score: %i\n", self.score];
    highscore.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    highscore.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    highscore.fontSize = scoreFontSize;
    highscore.position = CGPointMake(-self.frame.size.width/2+scoreFontSize, self.frame.size.height/2-45);
    [highscore runAction:[SKAction sequence:@[
                                              [SKAction waitForDuration:3.0],
                                              [SKAction fadeAlphaBy:-1.0 duration:2.0]
                                              ]] completion:^{
        [highscore removeFromParent];
    }];
    [self addChild:highscore];
    self.highscore = highscore;
    
    SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Imagine Font"];
    
    scoreLabel.text = [NSString stringWithFormat:@"High: %li\n", (long)[[NSUserDefaults standardUserDefaults] integerForKey:@"highscore"]];
    scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    scoreLabel.fontSize = scoreFontSize;
    CGFloat labelPosDiff = isIpad ? 100 : 80;
    scoreLabel.position = CGPointMake(-self.frame.size.width/2+scoreFontSize, self.frame.size.height/2-labelPosDiff);
    [scoreLabel runAction:[SKAction sequence:@[
                                              [SKAction waitForDuration:3.0],
                                              [SKAction fadeAlphaBy:-1.0 duration:2.0]
                                              ]] completion:^{
        [scoreLabel removeFromParent];
    }];
    [self addChild:scoreLabel];
    self.scoreLabel = scoreLabel;
    
    
}

-(void)endGame
{
    //kill last star
    [self enumerateChildNodesWithName:@"star" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
        self.starCounter--;
    }];
    
    CGFloat hue = ( arc4random() % 256 / 256.0 ); // 0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / (128/0.2) ) + 0.8; // 0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    self.backgroundColor = color;
    
    self.score = 0;
    self.scoreReport.text = [NSString stringWithFormat:@"%i",self.score];
    self.starTimer = arc4random() % starTimerMax;
    self.maxStars = initialMaxStars;
}

@end
