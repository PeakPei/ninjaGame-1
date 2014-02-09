//
//  MyScene.m
//  SpriteKitSimpleGame
//
//  Created by Cassandra Sandquist on 2/6/2014.
//  Copyright (c) 2014 Cassandra Sandquist. All rights reserved.
//

#import "MyScene.h"
#import "GameOverScene.h"

@interface MyScene ()

@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) int monstersDestroyed;

@end

static inline CGPoint addVector(CGPoint a, CGPoint b)
{
    return CGPointMake(a.x + b.x,a.y + b.y);
}
static inline CGPoint subtractVector(CGPoint a, CGPoint b)
{
    return CGPointMake(a.x - b.x,a.y - b.y);
}
static inline CGPoint vectorMultiply(CGPoint a, float b)
{
    //scale?
    return CGPointMake(a.x * b,a.y * b);
}
static inline float magnitudeOfVector(CGPoint a)
{
    //magnitude of a vector = sqrt(x^2 + y^2)
    return sqrtf(a.x * a.x+ a.y * a.y);
}
static inline CGPoint normalizeVector(CGPoint a)
{
    //A vector with magnitude 1 is called a Unit Vector.
    // Makes a vector have a length of 1?
    //Convert into a unit vector (of length 1)
    float length = magnitudeOfVector(a);
    return CGPointMake(a.x / length, a.y / length);
}

static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;

@implementation MyScene

-(id)initWithSize:(CGSize)size
{
    if(self = [super initWithSize:size])
    {
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"player"];
        self.player.position = CGPointMake(self.player.size.width/2, self.frame.size.height/2);
        [self addChild:self.player];
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
    }
    return self;
}
-(void)addMonster
{
    SKSpriteNode *monster = [SKSpriteNode spriteNodeWithImageNamed:@"monster"];
    
    //setup collision detection
    monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster.size];
    monster.physicsBody.dynamic = YES;
    monster.physicsBody.categoryBitMask = monsterCategory;
    monster.physicsBody.contactTestBitMask = projectileCategory;
    monster.physicsBody.collisionBitMask = 0;
    
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

    SKAction * loseAction = [SKAction runBlock:^{
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:NO];
        [self.view presentScene:gameOverScene transition: reveal];
    }];
    [monster runAction:[SKAction sequence:@[actionMove, loseAction, actionMoveDone]]];
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
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self runAction:[SKAction playSoundFileNamed:@"pew-pew-lei.caf" waitForCompletion:NO]];
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKSpriteNode *projectile = [SKSpriteNode spriteNodeWithImageNamed:@"projectile"];
    
    //setup collision detection
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.collisionBitMask = monsterCategory;
    projectile.physicsBody.contactTestBitMask = 0;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    
    
    //start at the player, so that you can calculate vector
    projectile.position = self.player.position;
    CGPoint offset = subtractVector(location, projectile.position);
    
    if (offset.x > 0)
    {
        [self addChild:projectile];
        CGPoint direction = normalizeVector(offset);
        //1000 because that should be enough time to travel of screen
        CGPoint shootAmount = vectorMultiply(direction, 1000);
        CGPoint finalDestination = addVector(shootAmount, projectile.position);
        
        float velocity = 480.0/1.0;
        float finalDuration = self.size.width /velocity;
        
        SKAction *actionMove = [SKAction moveTo:finalDestination duration:finalDuration];
        SKAction *actionMoveDone = [SKAction removeFromParent];
        
        [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    }
}
- (void)projectile:(SKSpriteNode *)projectile didCollideWithMonster:(SKSpriteNode *)monster
{
    NSLog(@"Hit");
    [projectile removeFromParent];
    [monster removeFromParent];
    self.monstersDestroyed++;
    if (self.monstersDestroyed > 30) {
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:YES];
        [self.view presentScene:gameOverScene transition: reveal];
    }
}
-(void)didBeginContact:(SKPhysicsContact *)contact
{
    //not convinced all of this is needed
    SKPhysicsBody *firstBody = (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)? contact.bodyA : contact.bodyB;
    SKPhysicsBody *secondBody = (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)? contact.bodyB : contact.bodyA;

    if ((firstBody.categoryBitMask & projectileCategory) != 0 && (secondBody.categoryBitMask & monsterCategory) !=0)
    {
        [self projectile:(SKSpriteNode *)firstBody.node didCollideWithMonster:(SKSpriteNode *)secondBody.node];
    }
}
@end
