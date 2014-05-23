//
//  Climber.m
//  BaoMonkey
//
//  Created by iPPLE on 09/05/2014.
//  Copyright (c) 2014 BaoMonkey. All rights reserved.
//

#import "Climber.h"
#import "Define.h"

@interface Climber ()
@property (nonatomic, assign) NSInteger climbPositionX;
@end

@implementation Climber

-(id)initWithDirection:(EnemyDirection)_direction {
    self = [super init];
    
    if (self) {
        CGPoint position;
        self.direction = _direction;
        self.type = EnemyTypeClimber;
        self.node.zPosition = 1;
        
        if (self.direction == LEFT)
        {
            node = [SKSpriteNode spriteNodeWithImageNamed:@"hunter-right"];
            position.x = 0;
            _climbPositionX = ([UIScreen mainScreen].bounds.size.width / 2) - 40;
        }
        else
        {
            node = [SKSpriteNode spriteNodeWithImageNamed:@"hunter-left"];
            position.x = [UIScreen mainScreen].bounds.size.width + (node.size.width / 2);
            _climbPositionX = ([UIScreen mainScreen].bounds.size.width / 2) + 40;
        }
        
        node.name = ENEMY_NODE_NAME;
        position.y = node.size.height / 2;
        [node setPosition:position];
        _isClimb = NO;
        _isOnPlateform = NO;
    }
    return (self);
}

- (void) actionClimber:(NSInteger)positionclimb {
    if (_isClimb == YES)
        return ;
    _isClimb = YES;
    SKAction *moveToTrunk = [SKAction moveToX:_climbPositionX
                                     duration:1.5];
    SKAction *waitClimb = [SKAction waitForDuration:0.25];
    SKAction *climb = [SKAction moveToY:positionclimb
                               duration:4.5];

    SKAction *act = [SKAction sequence:@[waitClimb, moveToTrunk, waitClimb, climb]];
    
    [self.node runAction:act completion:^{
        _isOnPlateform = YES;
        node.name = SHOOT_NODE_NAME;
    }];
}

-(void)loadBadMonkeyWalkingSprites {
    
}

-(void)loadSpecialForceWalkingSprites {
    
}

-(void)loadBadMonkeyClumbingSprites {
    
}

-(void)loadSpecialForceClumbingSprites {
    
}

@end
