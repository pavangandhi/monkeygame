//
//  MyScene.h
//  iosGame
//

//  Copyright (c) 2014 iPPLE. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Item.h"
#import "TreeBranch.h"
#import "GameController.h"
#import <CoreMotion/CoreMotion.h>
#import "Monkey.h"

@interface MyScene : SKScene {
    Monkey *monkey;
    GameController *gc;
}

@property (nonatomic) int sizeBlock;
@property (nonatomic) TreeBranch *treeBranch;
@property (nonatomic) NSMutableArray *wave;

@end
