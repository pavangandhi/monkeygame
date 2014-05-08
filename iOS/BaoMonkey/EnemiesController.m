//
//  EnemiesController.m
//  BaoMonkey
//
//  Created by Rémi Hillairet on 07/05/2014.
//  Copyright (c) 2014 BaoMonkey. All rights reserved.
//

#import "EnemiesController.h"
#import "LamberJack.h"
#import "Hunter.h"
#import "GameData.h"

@implementation EnemiesController

@synthesize enemies;

-(id)initWithScene:(SKScene*)_scene {
    self = [super init];
    if (self) {
        enemies = [[NSMutableArray alloc] init];
        scene = _scene;
        timeForAddLamberJack = 0;
        numberOfFloors = 0;
        [self initChoppingSlots];
    }
    return self;
}

-(void)initChoppingSlots {
    choppingSlots = [[NSMutableArray alloc] init];
    CGFloat spaceDistance;
    
    SKSpriteNode *Lamber = [SKSpriteNode spriteNodeWithImageNamed:@"lamberjack-left"];
    spaceDistance = Lamber.size.width / 2 - 2;
    for (int i = 0; i < 3 ; i++) {
        NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"FREE", @"LEFT", @"FREE", @"RIGHT", [NSString stringWithFormat:@"%f", (spaceDistance + (spaceDistance * i))], @"posX", nil];
        [choppingSlots addObject:tmp];
    }
}

#pragma mark - Enemy Controller

-(EnemyDirection)chooseDirection {
    NSUInteger numberLeft = 0;
    NSUInteger numberRight = 0;
    
    for (Enemy *enemy in enemies) {
        if (enemy.type == EnemyTypeLamberJack) {
            if (enemy.direction == LEFT)
                numberLeft++;
            else if (enemy.direction == RIGHT)
                numberRight++;
        }
    }
    if (numberRight < numberLeft)
        return RIGHT;
    return LEFT;
}

-(void)addLamberJack {
    LamberJack *newLamberJack;
    
    newLamberJack = [[LamberJack alloc] initWithDirection:[self chooseDirection]];

    [enemies addObject:newLamberJack];
    [scene addChild:newLamberJack.node];
}

-(void)addHunter {
    Hunter *newLamberJack;
    int positionHunterInSlot = 0;
    for (int currentSlot = 0; currentSlot < self->numberOfFloors; currentSlot++) {
        if (((positionHunterInSlot = [self checkPositionFloorSlot:currentSlot])) != -1)
            break;
    }
    if (positionHunterInSlot == -1)
        return ;
    
    newLamberJack = [[Hunter alloc] initWithFloor:numberOfFloors
                                             slot:positionHunterInSlot];
    
    [enemies addObject:newLamberJack];
    [scene addChild:newLamberJack.node];
    NSLog(@"APPERCU TAB FLOOOR = %d", self->slotFloor[0]);
}

-(NSUInteger)countOfEnemyType:(EnemyType)_type
{
    NSUInteger count = 0;
    
    for (Enemy *enemy in enemies) {
        if (enemy.type == _type)
            count++;
    }
    return count;
}

-(void)updateEnemies:(CFTimeInterval)currentTime {
    
    if ([self countOfEnemyType:EnemyTypeLamberJack] < MAX_LUMBERJACK && ((timeForAddLamberJack <= currentTime) || (timeForAddLamberJack == 0))){
        float randomFloat = (MIN_NEXT_ENEMY + ((float)arc4random() / (0x100000000 / (MAX_NEXT_ENEMY - MIN_NEXT_ENEMY))));
        [self addLamberJack];
        timeForAddLamberJack = currentTime + randomFloat;
    }
    
    if ([GameData getScore] >= 0)
    {
        if (numberOfFloors == 0)
            [self addFloor];
        
        if ([self countOfEnemyType:EnemyTypeHunter] < MAX_HUNTER && ((timeForAddHunter <= currentTime) || (timeForAddHunter == 0))){
            float randomFloat = (MIN_NEXT_ENEMY + ((float)arc4random() / (0x100000000 / (MAX_NEXT_ENEMY - MIN_NEXT_ENEMY))));
            [self addHunter];
            timeForAddHunter = currentTime + randomFloat;
        }
    }
    
    for (Enemy *enemy in enemies) {
        if (enemy.type == EnemyTypeLamberJack)
            [(LamberJack*)enemy updatePosition:choppingSlots];
    }
}

-(void)deleteEnemy:(Enemy*)enemy {
    SKAction *fadeIn = [SKAction fadeAlphaTo:0.0 duration:0.25];
    SKAction *sound = [SKAction playSoundFileNamed:@"coconut.mp3" waitForCompletion:NO];
    [enemy.node runAction:sound completion:^(void){
        [enemy.node runAction:fadeIn completion:^{
            [enemy.node removeFromParent];
        }];
    }];
    
    if (enemy.type == EnemyTypeLamberJack) {
        LamberJack *lamber;
        lamber = (LamberJack*)enemy;
        [lamber freeTheSlot:choppingSlots];
        [GameData addPointToScore:10];
    }
    else if (enemy.type == EnemyTypeHunter) {
        Hunter *hunter = (Hunter *)enemy;
        self->slotFloor[hunter.floor - 1] -= 1 << hunter.slot;
        [GameData addPointToScore:20];
    }
    [enemies removeObject:enemy];
}

#pragma mark - Floor Controller

-(void)addFloor {
    CGRect screen = [UIScreen mainScreen].bounds;
    numberOfFloors++;
    SKSpriteNode *floor = [SKSpriteNode spriteNodeWithColor:[SKColor brownColor] size:CGSizeMake(screen.size.width / 2 - 20, 10)];
    floor.position = CGPointMake(-screen.size.width / 2, screen.size.height / MAX_FLOOR);
    [scene addChild:floor];
    SKAction *slide = [SKAction moveToX:(floor.size.width / 2) duration:0.5];
    [floor runAction:slide];
}

#pragma mark - Floor Slot management

-(void)initFloorSlot {
    for (int index = 0; index < MAX_FLOOR; index++) {
        self->slotFloor[index] = 0;
    }
}

-(int)checkPositionFloorSlot:(NSInteger)floor {
    for (int mask = 3; mask >= 0; mask--) {
        if ((self->slotFloor[floor] >> mask & 0x1) == 0) {
            self->slotFloor[floor] += 1 << mask;
            return (mask + 1);
        }
    }
    return (-1);
}

@end
