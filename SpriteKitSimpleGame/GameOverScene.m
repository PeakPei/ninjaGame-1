//
//  GameOverScene.m
//  SpriteKitSimpleGame
//
//  Created by Cassandra Sandquist on 2/8/2014.
//  Copyright (c) 2014 Cassandra Sandquist. All rights reserved.
//

#import "GameOverScene.h"
#import "MyScene.h"

@implementation GameOverScene

-(id)initWithSize:(CGSize)size won:(BOOL)won
{
    if (self = [super initWithSize:size])
    {
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        NSString *message;
        
        message = (won)?@"You win!": @"You lose :[";

        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label.text = message;
        label.fontSize = 40;
        label.fontColor = [SKColor blackColor];
        label.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:label];
        
        [self runAction:[SKAction sequence:@[
            [SKAction waitForDuration:3.0],
            [SKAction runBlock:^(){
                SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
                SKScene *myScene = [[MyScene alloc] initWithSize:self.size];
                [self.view presentScene:myScene transition:reveal];
        }]]]];
    }
    return self;
}

@end
