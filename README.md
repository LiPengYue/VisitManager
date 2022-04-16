# iOS-关于浏览、搜索等历史记录本地存储的思路

## 前言

在APP需求开发中，经常会有一些本地存储一些信息的功能，对于本地保存的浏览历史记录，大多需要根据几个维度进行约束：时间、数量、增删改查的时间复杂度、用户浏览顺序等

例如：在简书APP推荐列表中，对用户浏览过的文章进行了置灰。

抽象成需求：在商品列表中，对用户浏览过的商品卡片进行置灰

需求的要求：

1、 用户浏览的顺序需要记录，如果用户浏览的是同一个商品，则需要更新商品的浏览时间为用户最后一次浏览时间

2、超时的历史记录进行删除：对于浏览时间落后当前时间X天的历史数据，则需要删除

3、历史记录需要存到磁盘

## 工具类VisitManager结构

对比数组、字典存储，我们选择了字典存储链表来进行存储。并把链表设计成双向链表结构

为了避免删除的Node需要手动释放内存，我们可以让Node的Next指针指向下一个Node在字典中的唯一标识Key，prev指针指向上一个Node在字典中的唯一标识Key

于是我们最终方案的结构如下：
  ![VisitManager结构](https://tva1.sinaimg.cn/large/e6c9d24ely1h1bw7ost2bj216x0u0whf.jpg)

### 一、Node：

Node中储存了单个的房源浏览历史

| 名称 | 类型 | 含义 |
| --- | --- | --- |
| prevNodeKey | NSString | 上一次浏览的房源的Node的CurrentNodeKey |
| data | id | 用于储存数据的扩展字段 |
| timeInterval | NSTimeInterval（double） | 加入到 NodeDic中的时间戳 |
| currentNodeKey | NSString | 当前节点在NodeDic中所在的key |
| nextNodeKey | NSString | 下一次浏览的房源的Node的CurrentNodeKey |

### 二、 VisitManager

VisitManager是一个单利类，里面储存了一些关键信息：

| 名称 | 类型 | 含义 |
| --- | --- | --- |
| NodeDic | 字典 | 储存了所有的node数据 |
| HeadNode | Node | 链表头, （prevNodeKey指向的nil） |
| EndNode | Node | 链表尾 （nextNodeKey指向的nil） |
| NodeDicMaxCount | Int | 链表储存的最大长度 |

## VisitManager数据操作流程

### 一、插入数据

在进入到房源详情页时、会尝试生成一条该房源的唯一标识Key，根据这个Key来尝试插入一条node

![插入数据](https://tva1.sinaimg.cn/large/e6c9d24ely1h1bw628rqxj21gs0k8q4f.jpg)

1、 查看浏览的房源A生成的Key，在NodeDic中是否有Node存在，如果存在，则说明之前浏览过房源

1.1、如果存在，则把之前的NodeA从链表中删除（下面详细叙述）

1.2、如果不存在，则创建NodeA，并查看NodeDIc.count 是否大于 NodeDicMaxCount-1， 超出了则删除 headNode

1.3、插入NodeA到链表末尾，并赋值NodeA的TimeInterval的值为当前的手机时间

1.4、赋值 manager的 endNode

### 二、 删除链表中的Node

![删除链表中的Node](https://tva1.sinaimg.cn/large/e6c9d24ely1h1bw4hlr2cj21aq0u0q60.jpg)

#### 1、 删除链表中的NodeB

1.1、 根据NodeB.prevNodeKey 从manager 的NodeDic中获取 NodeB的左节点，NodeA

1.2、 根据NodeB.nextNodeKey 从manager 的NodeDic中获取 NodeB的左节点，NodeC

1.3、 NodeA.nextNodeKey = NodeC.currentNodeKey

1.4、NodeC.prevNodeKey = NodeA.currentNodeKey

15、NodeB.nextNodeKey = nil， NodeB.prevNodeKey = nil

#### 2、 真正的删除内存中的NodeB

把manager 的NodeDic字典中的NodeB删除:

NodeDic[NodB.currentNodeKey?:@""] = nil;

### 三、校验与存储到磁盘

在用户浏览房源卡片列表时，创建visitManager，并且解档NodeDic、headeNode

当APP 退出后台，或者杀死APP时，会把manager中的NodeDic、headeNode、EndNode归档到沙河中


## 思考过程

### 一、 读取的时间复杂度

面对这样一个需求，首要考虑的是读取数据的时间复杂度。

数组储存： 每个列表卡片都需要循环数组才能知道这个商品用户是否已经浏览。而列表因为有上拉加载功能，卡片是无限的，这无疑造成了资源的浪费。而且如果用户点击的是同一个商品卡片，则需要先移除数组中的历史记录，再添加到数组的末尾，这又是一比消耗

字典存储：读取速度是O(1)， 而且每个商品的唯一标识我们肯定是知道的，那么我们使用商品的唯一标识作为Key，把一些必要数据包装成Mode为字典的Value。所以字典存储是可行的。而且如果用户点击的是同一个商品卡片，不需要做删除与插入操作

### 二、 存储的最大长度

在产品迭代中，肯定会新增一些信息一起存储到用户浏览记录里，如果个数不加以限制，则会造成空间浪费

还是两种存储方式：

数组存储： 数组有序，从而知道用户的浏览顺序，所以对于如果用户浏览超出了最大长度的限制，则只需要删除数组前部分数据即可（时间复杂度O(n)）

字典储存：字典无需，但是我们可以把字典变得有序，比如我们在字典中储存的是一个链表（以下把Mode称为Node）。并记录链表的head与end，这样我们就可以实现快速的删除操作（时间复杂度O(1)）。

### 三、超时的历史记录进行删除

删除超时的历史记录，就是查找超时历史记录的范围

数组存储： 因为数组在浏览时间上是有序的，所以我们可以使用二分查找来查找最后一个过期的历史记录（查找的时间复杂度O(log2n)，删除的时间复杂度为O(n)）

字典储存： 我们可以从链表的heade来逐个查找（查找时间复杂度为O(n)，删除的时间复杂度为O(1)）

由于对于超时历史记录的删除，对于实时性并没那么敏感，所以或许我们可以在APP启动、或者第一次使用到历史记录数据的时候进行查找删除

### 四、储存到磁盘

储存到磁盘的操作是非常耗时的，所以应该尽量减少存储次数。

好在iOS在APP退出、切换到后台时都会发出通知：`UIApplicationDidEnterBackgroundNotification`，所以我们可以接收到通知时进行存储

## demo
demo地址： [https://github.com/LiPengYue/VisitManager.git](https://github.com/LiPengYue/VisitManager.git)

最大缓存数为：5个

最大超时时间为20秒


