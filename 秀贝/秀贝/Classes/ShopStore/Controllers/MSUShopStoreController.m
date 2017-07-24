//
//  MSUShopStoreController.m
//  秀贝
//
//  Created by Zhuge_Su on 2017/5/24.
//  Copyright © 2017年 Zhuge_Su. All rights reserved.
//

#import "MSUShopStoreController.h"
#import "MSUPrefixHeader.pch"
#import "MSUHomeNavView.h"
#import "MSUDanamicTableCell.h"
#import "MSUTimerHandler.h"
#import "MSUStringTools.h"
#import "MSUDanamicHeaderView.h"

/// 视频播放器
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "TestTools.h"

@interface MSUShopStoreController ()<UITableViewDelegate,UITableViewDataSource,AVPlayerViewControllerDelegate>

/// 列表
@property (nonatomic , strong) UITableView *tableView;

// cell高
@property (nonatomic , assign) NSInteger cellHeight;

// 播放视频相关
@property (nonatomic , strong) UIView *playerView;
@property (nonatomic , strong) MSUDanamicTableCell *currentCell;
@property (nonatomic , strong) AVPlayerViewController *avPlayerVC;
@property (nonatomic , strong) AVPlayer *player;
@property (nonatomic , strong) AVPlayerItem *playerItem;
@property (nonatomic , strong) AVPlayerLayer *playerLayer;
@property (nonatomic , strong) NSURL *localUrl;

@end

@implementation MSUShopStoreController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    /// 状态栏字体颜色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;

    // 导航视图
    MSUHomeNavView *nav = [[MSUHomeNavView alloc] initWithFrame:NavRect showNavWithNumber:6];
    [self.view addSubview:nav];
    
    // 列表视图
    [self createTableView];
}

- (void)dealloc{
    NSLog(@" dealloc");
    // AVPlayer版
    [_playerItem removeObserver:self forKeyPath:@"status" context:nil];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
}

#pragma mark - 中部视图
- (void)createTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT-64 -44) style:UITableViewStylePlain];
    _tableView.backgroundColor = SLIVERYCOLOR;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    BOOL isAttention = NO;
    CGFloat height;
    if (isAttention) {
        height = 50 + 20;
    }else{
        height = 50 + 15 + 80 + 70;
    }
    MSUDanamicHeaderView *header = [[MSUDanamicHeaderView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, height) isAttention:isAttention];
    header.backgroundColor = YELLOWCOLOR;
    _tableView.tableHeaderView = header;
}

#pragma mark - 代理相关
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"danamicTable";
    MSUDanamicTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[MSUDanamicTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 头像
    [cell.iconBtn setImage:[UIImage imageNamed:@"icon-z"] forState:UIControlStateNormal];
    // 昵称
    cell.nickLab.text = @"叶叶叶叶叶子";
    // 时间
    cell.timeLab.text = @"2017-07-11 19:30";
    // 是否转发
    cell.isTranspod = NO;
    
    if (cell.isTranspod) {
        // 转发评论
        cell.transpodLab.text = @"转发视频";
        CGRect transRect = [MSUStringTools danamicGetHeightFromText:cell.transpodLab.text WithWidth:WIDTH-10 font:[UIFont systemFontOfSize:12]];
        cell.transpodLab.frame = CGRectMake(10, 50 + 10, WIDTH-20, transRect.size.height);
        // 内容正题
        cell.tittleLab.text = @"有一美人兮，见之不忘。一日不见兮，思之如狂。凤飞翱翔兮，四海求凰。无奈佳人兮，不在东墙。将琴代语兮，聊写衷肠。何日见许兮，慰我彷徨。愿言配德兮，携手相将。不得于飞兮，使我沦亡。";
        CGRect textRect = [MSUStringTools danamicGetHeightFromText:cell.tittleLab.text WithWidth:WIDTH-10 font:[UIFont systemFontOfSize:12]];
        cell.tittleBGView.frame = CGRectMake(0, 50 + 10 + transRect.size.height + 5, WIDTH, textRect.size.height);
        cell.tittleLab.frame = CGRectMake(10, 0, WIDTH-20, textRect.size.height);
        cell.videoBGView.frame = CGRectMake(0, CGRectGetMaxY(cell.tittleBGView.frame), WIDTH, 220);
        
        cell.tittleBGView.backgroundColor = [UIColor grayColor];
        cell.videoBGView.backgroundColor = [UIColor grayColor];;

    }else{
        // 内容正题
        cell.tittleLab.text = @"有一美人兮，见之不忘。一日不见兮，思之如狂。凤飞翱翔兮，四海求凰。无奈佳人兮，不在东墙。将琴代语兮，聊写衷肠。何日见许兮，慰我彷徨。愿言配德兮，携手相将。不得于飞兮，使我沦亡。";
        CGRect textRect = [MSUStringTools danamicGetHeightFromText:cell.tittleLab.text WithWidth:WIDTH-10 font:[UIFont systemFontOfSize:12]];
        cell.tittleBGView.frame = CGRectMake(0, 50 + 10 , WIDTH, textRect.size.height);
        cell.tittleLab.frame = CGRectMake(10, 0, WIDTH-20, textRect.size.height);
        cell.videoBGView.frame = CGRectMake(0, CGRectGetMaxY(cell.tittleBGView.frame), WIDTH, 210);
    }

    // 视频页面
    cell.videoImaView.image = [UIImage imageNamed:@"FoSe.jpeg"];
    // 播放按钮
    [cell.playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.playBtn.tag = indexPath.row;
    
    // 是否定位
    cell.isLocation = YES;
    if (cell.isLocation) {
        cell.lineView.frame = CGRectMake(0, CGRectGetMaxY(cell.videoBGView.frame) + 5+ 25+ 5 , WIDTH, 1);
    }else{
        cell.locationBtn.hidden = YES;
        cell.lineView.frame = CGRectMake(0, CGRectGetMaxY(cell.videoBGView.frame) + 5 , WIDTH, 1);
    }
    
    self.cellHeight = CGRectGetMaxY(cell.lineView.frame) + 40 + 20;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

#pragma mark - 按钮点击事件
- (void)playBtnClick:(UIButton *)sender{
    NSLog(@"点击了第%ld个按钮",sender.tag);

    self.currentCell = (MSUDanamicTableCell *)sender.superview.superview;
    // 当有上一个在播放的时候 点击 就先release
    if (self.playerView) {
        [self releasePlayer];
        
        self.playerView = [[UIView alloc] initWithFrame:self.currentCell.videoImaView.bounds];
//        NSLog(@"cell frame ： %@ ，videoBGView frame %@,frame ：%@",NSStringFromCGRect(self.currentCell.frame),NSStringFromCGRect(self.currentCell.videoImaView.frame),NSStringFromCGRect(self.playerView.frame));
    }else{
        self.playerView = [[UIView alloc] initWithFrame:self.currentCell.videoImaView.bounds];
//        NSLog(@"cell frame ： %@ ，videoBGView frame %@,frame ：%@",NSStringFromCGRect(self.currentCell.frame),NSStringFromCGRect(self.currentCell.videoImaView.frame),NSStringFromCGRect(self.playerView.frame));
    }
    
    self.currentCell.playBtn.hidden = YES;
    [self.currentCell.videoImaView addSubview:_playerView];
    [self.currentCell.videoImaView bringSubviewToFront:_playerView];
    [self playByAVPlayer];
    NSLog(@"view2 : %@",self.playerView.superview.superview.superview);

}

- (void)releasePlayer{
    NSLog(@"view1 : %@",self.playerView.superview.superview.superview);
    
    MSUDanamicTableCell *cell = (MSUDanamicTableCell *)self.playerView.superview.superview.superview;
    cell.playBtn.hidden = NO;
    
    [_playerItem removeObserver:self forKeyPath:@"status" context:nil];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    
    [_playerItem cancelPendingSeeks];
    [_playerItem.asset cancelLoading];
    
    [self.playerView removeFromSuperview];
    [self.playerLayer removeFromSuperlayer];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.player = nil;
    self.playerItem = nil;
}

#pragma mark - 视频相关
- (void)playByAVPlayer{
    // 加载本地音乐
    //    NSURL *localMusicUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"蓝莲花" ofType:@"mp3"]];
    
    // 加载本地视频
    //    NSURL *localVideoUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"IMG_1234" ofType:@"MOV"]];
    //    NSURL *localVideoUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"经济技术" ofType:@"mp4"]];
    //    NSURL *localVideoUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"IMG_1233" ofType:@"MOV"]];
    NSURL *localVideoUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"haha" ofType:@"mp4"]];
    
    
    // 加载网络视频
    //    NSURL *netVideoUrl = [NSURL URLWithString:@"http://w2.dwstatic.com/1/5/1525/127352-100-1434554639.mp4"];
    
    
    // AVPlayerIterm
    self.playerItem = [AVPlayerItem playerItemWithURL:localVideoUrl];
    
    // 创建 AVPlayer 播放器
    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    
    
    // 将 AVPlayer 添加到 AVPlayerLayer 上
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];

    // 设置播放页面大小
    _playerLayer.frame = self.playerView.bounds;
    NSLog(@"视频层 %@",NSStringFromCGRect(_playerLayer.frame));
    // 设置画面缩放模式
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //        playerLayer.videoRect = CGRectMake(10, 64, WIDTH - 20, 400);
    
    // 在视图上添加播放器
    [self.playerView.layer addSublayer:_playerLayer];
    
    // 开始播放
    [_player pause];
    
    //获取总帧数与帧率
    //    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    //    AVURLAsset *myAsset = [[AVURLAsset alloc] initWithURL:localVideoUrl options:opts];
    //    CMTimeValue  value = myAsset.duration.value;//总帧数
    //    CMTimeScale  timeScale =   myAsset.duration.timescale; //timescale为帧率  fps
    //    NSLog(@"-------%lld,%d",value,timeScale);
    
    [self AVPlayerParameterWithAVPlayer:_player AVPlayerItem:_playerItem];
    
    //    UIImageView *wolfIma = [[UIImageView alloc] init];
    //    wolfIma.frame = CGRectMake(0, HEIGHT/2, WIDTH, 200);
    //    wolfIma.image = [TestTools thumbnailImageForVideo:localVideoUrl atTime:1000];
    //    [self.view addSubview:wolfIma];
    
}

/* 视频播放相关参数 */
- (void)AVPlayerParameterWithAVPlayer:(AVPlayer *)avPlayer AVPlayerItem:(AVPlayerItem *)avPlayerItem{
    // 设置播放速率 （默认为 1.0 (normal speed)，设为 0.0 时暂停播放。设置后立即开始播放，可放在开始播放后设置）
    avPlayer.rate = 1.0;
    
    // 开始播放
    //    [avPlayer play];
    
    // 暂停播放
    // [avPlayer pause];
    
    // 设置音量 （范围 0 - 1，默认为 1）
    // avPlayer.volume = 0;
    
    // 跳转到指定位置 （10 / 1 = 10，跳转到第 10 秒的位置处）
    // [avPlayerItem seekToTime:CMTimeMake(10, 1)];
    
    // 获取视频总长度 （转换成秒，或用 duration.value / duration.timescale; 计算）
    // CMTime duration = avPlayerItem.duration;
    // float totalSecond = CMTimeGetSeconds(duration);
    
    // 获取当前播放进度 （或用 avPlayerItem.currentTime.value/avPlayerItem.currentTime.timescale;）
    // CMTime currentTime = avPlayerItem.currentTime;
    // float currentSecond = CMTimeGetSeconds(currentTime);
    
    // 监听播放进度 （NULL 在主线程中执行，每个一秒执行一次该 Block）
    [avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        
    }];
    
    // 添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(itemDidPlayToEndTime:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:avPlayerItem];
    
    // 获取视频缓冲进度
    NSArray<NSValue *> *loadedTimeRanges = avPlayerItem.loadedTimeRanges;
    
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];  // 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    
    float loadedSecond = startSeconds + durationSeconds;                      // 计算缓冲总进度
    NSLog(@"%f",loadedSecond);
    
    // 监听缓冲进度属性
    [avPlayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    // 监听准备播放状态属性
    // AVPlayerItemStatus status = avPlayerItem.status;                         //获取播放属性
    [avPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - 系统通知
/* 系统自带监听方法 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    /// 监听缓冲进度
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
    }
    
    /// 监听播放状态
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[@"new"] integerValue];
        switch (status) {
            case AVPlayerItemStatusUnknown: {
                NSLog(@"未知状态");
                break;
            }
            case AVPlayerItemStatusReadyToPlay: {
                //                NSLog(@"视频的总时长%f", CMTimeGetSeconds(player.currentItem.duration));
                
                break;
            }
            case AVPlayerItemStatusFailed: {
                NSLog(@"加载失败");
                break;
            }
        }
    }
    
}

- (void)itemDidPlayToEndTime:(NSNotification *)noti{
    NSLog(@"播放结束");
    //    [player seekToTime:kCMTimeZero];
    [self releasePlayer];
}


@end
