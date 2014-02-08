//
//  MyScene.m
//  SpriteKitSimpleGame
//
//  Created by Cassandra Sandquist on 2/6/2014.
//  Copyright (c) 2014 Cassandra Sandquist. All rights reserved.
//

#import "MyScene.h"

@interface MyScene ()

@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

@end

static inline CGPoint addVector(CGPoint a, CGPoint b)
{
    return CGPointMake(
                       a.x + b.x,
                       a.y + b.y
                       );
}

static inline CGPoint subtractVector(CGPoint a, CGPoint b)
{
    return CGPointMake(
                       a.x - b.x,
                       a.y - b.y
                       );
}

static inline CGPoint vectorMultiply(CGPoint a, float b)
{
    return CGPointMake(
                       a.x * b,
                       a.y * b
                       );
}

static inline float rwLength(CGPoint a)
{
    //magnitude of a vector
    //sqrt(x^2 + y^2)
    return sqrtf(a.x * a.x+ a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a)
{
    //A vector with magnitude 1 is called a Unit Vector.
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}
@implementation MyScene

-(id)initWithSize:(CGSize)size
{
    if(self = [super initWithSize:size])
    {
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"player"];
        self.player.position = CGPointMake(self.player.size.width/2, self.frame.size.height/2); //CGPointMake(100, 100);
        [self addChild:self.player];
    }
    return self;
}
-(void)addMonster
{
    SKSpriteNode *monster = [SKSpriteNode spriteNodeWithImageNamed:@"monster"];
    
    int rangeMonsterCouldBeOnY = (self.frame.size.height - monster.size.height/2) - (monster.size.height/2);
    int actualY = (arc4random() % rangeMonsterCouldBeOnY);
    
    monster.position = CGPointMake(self.frame.size.width+monster.size.width/2, actualY + monster.size.height/2);
    
    [self addChild:monster];
    
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    
    int actualDuration = (arc4random() %rangeDuration) + minDuration;
    
    SKAction *actionMove = [SKAction moveTo:CGPointMake(-monster.size.width/2, actualY) duration:actualDuration];
    SKAction *actionMoveDone = [SKAction removeFromParent];
    
    [monster runAction:actionMove completion:^(){
        [monster runAction:actionMoveDone];
    }];
    
    //[monster runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
}
-(void)update:(NSTimeInterval)currentTime
{
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1)
    {
        timeSinceLast = 1.0/60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}
-(void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast
{
    self.lastSpawnTimeInterval += timeSinceLast;
    
    if (self.lastSpawnTimeInterval >1) {
        self.lastSpawnTimeInterval = 0;
        [self addMonster];
    }
}
@end
