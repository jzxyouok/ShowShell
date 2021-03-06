//
//  MSUVideoDetailController.m
//  秀贝
//
//  Created by Zhuge_Su on 2017/8/2.
//  Copyright © 2017年 Zhuge_Su. All rights reserved.
//

#import "MSUVideoDetailController.h"
#import "MSUHomeNavView.h"
#import "MSUPrefixHeader.pch"
#import "MSUVideoDetailView.h"
#import "MSUVideoDetailBottomView.h"
#import "MSUShopDetailController.h"
#import "MSUVideoDetailCommentView.h"
#import "MSUVideoCommentTableCell.h"
#import "MSUShopSelectView.h"
#import "MSUShopSelectTableCell.h"

// 工具类
#import "MSUStringTools.h"
#import "MSUPathTools.h"

@interface MSUVideoDetailController ()<UITableViewDelegate,UITableViewDataSource> {
    BOOL isUnfolds[500];
}

/// 滚动视图
@property (nonatomic , strong) UIScrollView *bgScrollView;

/// 商品选择页
@property (nonatomic , strong) MSUShopSelectView *seleView;
@property (nonatomic , strong) UIView *shadowView;

/// 视频高度
@property (nonatomic , assign) CGFloat videoHeight;
/// 内容正文
@property (nonatomic , strong) NSString *textStr;
/// 内容正文宽高
@property (nonatomic , assign) CGRect textRect;
/// 转发内容
@property (nonatomic , strong) NSString *transText;
/// 转发内容正文宽高
@property (nonatomic , assign) CGRect transRect;
/// 转发判断
@property (nonatomic , assign) BOOL isTrans;

@property (nonatomic , assign) BOOL isUnfold;

@end

@implementation MSUVideoDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.isUnfold = NO;
    self.textStr = @"有一美人兮，见之不忘。一日不见兮，思之如狂。凤飞翱翔兮，四海求凰。无奈佳人兮，不在东墙。将琴代语兮，聊写衷肠。何日见许兮，慰我彷徨。愿言配德兮，携手相将。不得于飞兮，使我沦亡。";
    self.textRect = [MSUStringTools danamicGetHeightFromText:_textStr WithWidth:WIDTH-10 font:16];
    self.transText = @"转发视频";
    self.transRect = [MSUStringTools danamicGetHeightFromText:_transText WithWidth:WIDTH-10 font:16];
    
    self.isTrans = NO;
    if (_isTrans) {
        self.videoHeight = 50 + 10 + _transRect.size.height + 5 + _textRect.size.height + 220 + 40;
    } else {
        self.videoHeight = 50 + 10 + _textRect.size.height + 5 + 210 + 30;
    }

    // 导航视图
    MSUHomeNavView *nav = [[MSUHomeNavView alloc] initWithFrame:NavRect showNavWithNumber:11];
    [self.view addSubview:nav];
    
    // 视频视图
    [self createVideoView];
    // 商品视图
    [self createShopViewWithCount:4];
    
    // 评论视图
    [self createCommentView];
    
    // 底部视图
    MSUVideoDetailBottomView *bottom = [[MSUVideoDetailBottomView alloc] initWithFrame:CGRectMake(0, HEIGHT-50, WIDTH, 50)];
    [self.view addSubview:bottom];
    [bottom.buyBtn addTarget:self action:@selector(buyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)createVideoView{
    self.bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT)];
    _bgScrollView.backgroundColor = BGLINECOLOR;
    _bgScrollView.scrollEnabled = YES;
    _bgScrollView.contentSize = CGSizeMake(0, 5+self.videoHeight+5+130+200+(39+_textRect.size.height+50)*2);
    _bgScrollView.showsHorizontalScrollIndicator = NO;
    _bgScrollView.showsVerticalScrollIndicator = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:_bgScrollView];

    MSUVideoDetailView *video = [[MSUVideoDetailView alloc] initWithFrame:CGRectMake(0, 5, WIDTH, self.videoHeight)];
    video.backgroundColor = [UIColor whiteColor];
    [_bgScrollView addSubview:video];
    // 头像
    [video.iconBtn setImage:[UIImage imageNamed:@"icon-z"] forState:UIControlStateNormal];
    // 昵称
    video.nickLab.text = @"何何何何太太";
    // 时间
    video.timeLab.text = @"2017-07-11 19:30";
    // 是否转发
    video.isTranspod = _isTrans;
    
    if (video.isTranspod) {
        // 转发评论
        video.transpodLab.text = self.transText;
        video.transpodLab.frame = CGRectMake(10, 50 + 10, WIDTH-20, _transRect.size.height);
        // 内容正题
        video.tittleLab.text = self.textStr;
        video.tittleBGView.frame = CGRectMake(0, 50 + 10 + _transRect.size.height + 5, WIDTH, _textRect.size.height+5);
        video.tittleLab.frame = CGRectMake(10, 5, WIDTH-20, _textRect.size.height);
        video.videoBGView.frame = CGRectMake(0, CGRectGetMaxY(video.tittleBGView.frame), WIDTH, 220);
        
        video.tittleBGView.backgroundColor = SLIVERYCOLOR;
        video.videoBGView.backgroundColor = SLIVERYCOLOR;
        
    }else{
        // 内容正题
        video.tittleLab.text = _textStr;
        video.tittleBGView.frame = CGRectMake(0, 50 + 10 , WIDTH, _textRect.size.height);
        video.tittleLab.frame = CGRectMake(10, 0, WIDTH-20, _textRect.size.height);
        video.videoBGView.frame = CGRectMake(0, CGRectGetMaxY(video.tittleBGView.frame), WIDTH, 210);
    }
    
    // 视频页面
    video.videoImaView.image = [MSUPathTools showImageWithContentOfFileByName:@"FoSe.jpeg"];
    // 播放按钮
//    [video.playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    // 是否定位
    video.isLocation = YES;
    if (video.isLocation) {
        
    }else{
        video.locationBtn.hidden = YES;
        video.dictanceBtn.hidden = YES;
    }
}

- (void)createShopViewWithCount:(NSInteger)count{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 5 + self.videoHeight + 5, WIDTH, 130)];
    bgView.backgroundColor = [UIColor whiteColor];
    [_bgScrollView addSubview:bgView];
    
    for (NSInteger i = 0; i < count; i++) {
        CGFloat btnWidth = (WIDTH-20-3*10)/4;
        UIButton *shopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        shopBtn.layer.cornerRadius = 5;
        shopBtn.layer.shouldRasterize = YES;
        shopBtn.layer.rasterizationScale = [UIScreen mainScreen].scale;
        shopBtn.layer.borderWidth = 1;
        shopBtn.layer.borderColor = [UIColor redColor].CGColor;
        shopBtn.frame = CGRectMake(10+(btnWidth+10)*i, 10, btnWidth, 110);
        shopBtn.backgroundColor = [UIColor colorWithRed:247/255.0 green:215/255.0 blue:33/255.0 alpha:1];
        [bgView addSubview:shopBtn];
        [shopBtn addTarget:self action:@selector(shopBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)createCommentView{
    MSUVideoDetailCommentView *comment = [[MSUVideoDetailCommentView alloc] initWithFrame:CGRectMake(0, 5 + self.videoHeight + 5 + 130 + 5, WIDTH, (39+_textRect.size.height+50)*2) tableViewHeight:(39+_textRect.size.height+50)*2];
    comment.backgroundColor = BGLINECOLOR;
    [_bgScrollView addSubview:comment];
    
    comment.titLab.text = [NSString stringWithFormat:@"评论%@",@"（62）"];
//    comment.comeLab.hidden = NO;
//    comment.tableView.hidden = YES;
    comment.tableView.delegate = self;
    comment.tableView.dataSource = self;
    comment.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}


#pragma mark - 点击事件
- (void)shopBtnClick:(UIButton *)sender{
    self.hidesBottomBarWhenPushed = YES;
    MSUShopDetailController *shop = [[MSUShopDetailController alloc] init];
    [self.navigationController pushViewController:shop animated:YES];
}

- (void)buyBtnClick:(UIButton *)sender{
    self.shadowView.hidden = NO;
    self.seleView.hidden = NO;
}

- (void)cancelBtnClick:(UIButton *)sender{
    self.shadowView.hidden = YES;
}

- (void)foldBtnClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    NSLog(@"选择状态%d",sender.selected);
    if (sender.selected) {
        self.isUnfold = YES;
        //** sqz---注释/添加
        isUnfolds[sender.tag] =YES;
        // */
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [_seleView.seleTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        NSLog(@"展开了 ，选择状态是%d",sender.selected);

    }else{
        self.isUnfold = NO;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [_seleView.seleTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        NSLog(@"合并");
    }
}

#pragma mark - 代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _seleView.seleTableView) {
        return 3;
    } else {
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _seleView.seleTableView) {
        //** sqz---注释/添加
//        if (!self.isUnfold) {
//            return 100;
//        } else {
//            return 190;
//        }
        if (isUnfolds[indexPath.row]) {
            return 190;
        } else {
            return 100;
        }
        // */

    } else {
        return 28+_textRect.size.height+10+1 +50;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _seleView.seleTableView) {
        MSUShopSelectTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectShopCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.shopNameLab.text = @"天青色等烟雨，而我在等你；炊烟袅袅升起，隔江千万里!";
        CGRect hotRect = [MSUStringTools danamicGetHeightFromText:cell.shopNameLab.text WithWidth:(WIDTH-30) font:16];
        cell.shopNameLab.frame = CGRectMake(5+80+10, 3, WIDTH-30-25-(5+80+10), hotRect.size.height);
        cell.priceLab.text = [NSString stringWithFormat:@"¥%@",@"88.80"];

        //** sqz---注释/添加
//        if (self.isUnfold) {
//            cell.bottomBGView.hidden = NO;
//        }else{
//            cell.bottomBGView.hidden = YES;
//        }
        cell.foldBtn.tag =indexPath.row;
        if (isUnfolds[indexPath.row]) {
            cell.bottomBGView.hidden = NO;
        } else {
            cell.bottomBGView.hidden = YES;
        }
        
//        NSLog(@"展开合并状态%d",self.isUnfold);
//        
//        __weak __typeof(self) weakSelf= self;
        // */
        cell.unfoldBtnClickBlock = ^(UIButton *unfoldBtn) {
            //** sqz---注释/添加
//            weakSelf.isUnfold = !weakSelf.isUnfold;
            isUnfolds[indexPath.row] =! isUnfolds[unfoldBtn.tag];
            //*/
            
            NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            NSLog(@"第几行%ld",indexPath.row);
            [_seleView.seleTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath1, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        };
        
//        [cell.foldBtn addTarget:self action:@selector(foldBtnClick:) forControlEvents:UIControlEventTouchUpInside];

        return cell;
    } else{
        MSUVideoCommentTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentVideoShopCell"];
        
        //    [cell configCellWithModel:model indexPath:indexPath];
        
        [cell.iconBtn setImage:[UIImage imageNamed:@"icon-z"] forState:UIControlStateNormal];
        cell.nickLab.text = @"叶叶叶叶叶子";
        cell.commentLab.text = _textStr;
        cell.commentLab.frame = CGRectMake(70, 28, WIDTH-70-10, _textRect.size.height);
        cell.lineView.frame = CGRectMake(70, CGRectGetMaxY(cell.commentLab.frame)+40+10, WIDTH-70-10, 1);
        
        return cell;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - 初始化
- (UIView *)shadowView{
    if (!_shadowView) {
        self.shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        _shadowView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        [self.view addSubview:_shadowView];
    }
    return _shadowView;
}

- (MSUShopSelectView *)seleView{
    if (!_seleView) {
        self.seleView = [[MSUShopSelectView alloc] initWithFrame:CGRectMake(0, HEIGHT*0.5, WIDTH, HEIGHT*0.5)];
        [self.shadowView addSubview:_seleView];
        _seleView.hidden = YES;
        _seleView.seleTableView.delegate = self;
        _seleView.seleTableView.dataSource = self;
        [_seleView.cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _seleView;
}

@end
