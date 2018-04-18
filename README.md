宏和脚本编写说明
====================================

## 目录
  * 宏
    * Lua基础
    * 基本概念
    * 全局函数
    * Player对象
    * NPC对象
    * 枚举值和常量
  * 脚本
    * 移动
    * 交互
    * 任务
    * 战斗
    * 物品
    * 商店
    * 拍卖行
    * 帮会

## 宏
宏是一个lua脚本，所以要编写宏，需要了解Lua编程语言的基础知识。宏载入（绑定）后会编译为一个Lua函数，每次按下快捷键就会执行一次这个函数。

### Lua基础
参考[Lua教程](http://www.runoob.com/lua/lua-tutorial.html)，重点看数据类型、变量、流程控制、运算符、表等内容，后面的不用看了。<br>
其他参考资料：Lua程序设计（第2版）前六章。注：必须是第2版，这一版是参照Lua5.1，和软件使用的版本一致，其他版本语法等方面有细微差异。<br>
Lua代码是区分大小写的，例如 abc 和 Abc 是两个不同的标识符。

### 基本概念
游戏中有三类对象。<br>
Player：自己和其他玩家。<br>
Doodad：可采集的矿、草、任务物品等等。<br>
NPC：除玩家和Doodad外都是NPC。包括BOSS和玩家释放技能之后的效果，比如地刺之类的。一部分NPC没有名字。<br>
编写宏重点关注的是Player和NPC对象。


### 全局函数

---
#### GetClientPlayer
描述：获取自己控制的Player对象。<br>
没有参数。<br>
1个返回值：Player对象。如果尚未进入游戏返回nil。<br>
示例： local player = GetClientPlayer()<br>

---
#### s_util.GetTarget
描述：获取对象的当前目标。<br>
1个参数：对象。<br>
2个返回值：没有目标返回nil。否则返回目标对象，目标对象类型（[TARGET](#TARGET) 类型的枚举值）。<br>
示例：local target, targetClass = s_util.GetTarget(player)<br>

---
#### IsEnemy
描述：判断两个对象是不是敌对关系<br>
2个参数：NPC或玩家对象ID, NPC或玩家对象ID<br>
1个返回值：是敌对返回true，否则返回false<br>

---
#### s_util.GetBuffInfo
描述：返回指定对象的buff数据表。<br>
1个参数：Player或者NPC对象。<br>
1个返回值：buff数据表。键是buffid，值是指定id的buff数据。<br>
buff数据是如下结构的表：<br>

| 键 | 值
| --- | ---
| dwID | buffid
| nLevel | buff等级
| bCanCancel | 是否能取消
| nLeftTime | 剩余时间(秒)
| nStackNum | 层数
| dwSkillSrcID | 造成这个buff的对象ID

示例：假设要判断的buffid为123，目标对象为target，我的对象为player<br>
```Lua
--获取目标的buff表
local TargetBuff = s_util.GetBuffInfo(target)

--如果有指定buff
if TargetBuff[123] then
 ...
end

--如果没有指定buff
if not TargetBuff[123] then
 ...
end

--没有指定buff或者不是我造成的
if not TargetBuff[123] or TargetBuff[123].dwSkillSrcID ~= player.dwID then
 ...
end

--有指定buff，并且层数大于3
if TargetBuff[123] and TargetBuff[123].nStackNum > 3 then
 ...
end

--有指定buff并且剩余时间大于1.5秒
if TargetBuff[123] and TargetBuff[123].nLeftTime > 1.5 then
 ...
end

--没有指定buff，或者剩余时间小于等于0.5秒，或者不是我造成的
if not TargetBuff[123] or TargetBuff[123].nLeftTime <= 0.5 or TargetBuff[123].dwSkillSrcID ~= player.dwID then
 ...
end
```
`注意：判断buff数据的其他信息之前必须先判断有没有这个buff，否则Lua会报错试图索引一个nil值。`

---
#### s_util.GetDistance
描述：返回两个对象之间的距离。
2个参数：对象1，对象2。<br>
1个返回值：距离（尺）。
示例：local distance = s_util.GetDistance(player, target)


### Player对象

### NPC对象

### 枚举值和常量

---
#### TARGET
 * NO_TARGET : 没有目标
 * NPC : 目标是NPC
 * PLAYER : 目标是玩家
 * DOODAD : 目标是DOODAD




## 脚本
    
