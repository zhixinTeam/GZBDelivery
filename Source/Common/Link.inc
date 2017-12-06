//----------------------------------- 通用 -------------------------------------
{.$DEFINE DEBUG}
//调试模式

{.$DEFINE TrialVersion}
//试用版本

{$DEFINE UseReport}
//报表支持

{.$DEFINE RandomID}
//使用随机编号

{$DEFINE cxLibrary42}
//Ver4.2编译环境

{.$DEFINE EnableBackupDB}
//备用数据库支持
{.$DEFINE EnableDoubleDB}
//双数据库支持

//---------------------------------- 中间件 ------------------------------------
{.$DEFINE ClientMon}
//进程守护客户端

{$DEFINE HardMon}
//编译硬件守护

{.$DEFINE GenRODL}
//生成RODL资源

{$DEFINE COM_MIT}
//定义系统模式

//通用中间件
{$IFDEF COM_MIT}
  {$DEFINE DBPool}
  //启用数据库支持
  {$DEFINE ChannelPool}
  //启用通道支持
  {.$DEFINE AutoChannel}
  //启用通道平衡
  {.$DEFINE SAP}
  //启用SAP支持
  {.$DEFINE ClientMon}
  //支持守护服务
{$ENDIF}

//--------------------------------- 特定系统 -----------------------------------
{.$DEFINE COMMON}
//通用版本

{$DEFINE GZBJM}
//特定系统

//葛洲坝松滋
{$IFDEF GZBSZ}
  {$DEFINE COMMON}
  //使用常规
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE SyncRemote}
  //远程同步
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE MicroMsg}
  //微信支持
  {$DEFINE CODEAREA}
  //喷码打印销售区域
  {.$DEFINE ERROPENONEDOOR}
  //过磅失败倒车下磅
  {$DEFINE MultiOrderOfTruck}
  //允许车辆办理多张采购单
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
{$ENDIF}

//葛洲坝荆门
{$IFDEF GZBJM}
  {$DEFINE COMMON}
  //使用常规
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE SyncRemote}
  //远程同步
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE MicroMsg}
  //微信支持
  {$DEFINE CODECOMMON}
  //通用喷码
  {.$DEFINE USECONTRACT}
  //采购使用合同
  {$DEFINE MITTruckProber}
  //服务器操作车检
  {$DEFINE EnableWebMall}
  //使用网上商城
  {.$DEFINE JMSecurityCode}
  //荆门专用防违流喷码
  {$DEFINE MultiOrderOfTruck}
  //允许车辆办理多张采购单
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
{$ENDIF}

//葛洲坝钟祥
{$IFDEF GZBZX}
  {$DEFINE COMMON}
  //使用常规
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE SyncRemote}
  //远程同步
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE CODEBATCODE}
  //喷码打印批次号
  {$DEFINE MITTruckProber}
  //服务器操作车检
  {$DEFINE MultiReplay}
  //JSQ应答模式
  {$DEFINE BATAFTERLINE}
  //刷卡获取批次
  {$DEFINE TruckInLoop}
  //车辆循环进厂
  {$DEFINE USECONTRACT}
  //采购使用合同
  {$DEFINE EnableWebMall}
  //使用网上商城
  {.$DEFINE NoSecurityCodeQuery}
  //关闭防违流查询
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
{$ENDIF}

