宏和脚本编写说明
====================================
配套软件下载 https://pan.baidu.com/s/18cC8pGu64OkRCpwdxlsxyA<br>
扣扣群：511064247<br>
编写宏最好用支持Lua语法高亮的文本编辑器，推荐Notepad++。vs code 和 EditPlus 添加了插件也可以，这样比较容易发现语法错误。<br>

## 目录
  * [宏](#宏)
    * [Lua基础](#lua基础)
    * [基本概念](#基本概念)
    * [全局函数](#全局函数)
    * [Player对象](#player对象)
    * [NPC对象](#npc对象)
    * [枚举值和常量](#枚举值和常量)
  * [脚本](#脚本)
    * [基础命令](#基础命令)
    * [移动命令](#移动命令)
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
#### s_Output
描述：向控制台输出信息<br>
参数：任意。<br>
没有返回值。<br>
示例：
```Lua
--向控制台输出我的名字和等级
local player = GetClientPlayer()
if not player then return end

s_Output(player.szName, player.nLevel)
```

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
2个返回值：没有目标返回nil。否则返回目标对象，目标对象类型（[TARGET](#target) 类型的枚举值）。<br>
示例：
```Lua
--有目标并且目标是玩家
local target, targetClass = s_util.GetTarget(player)
if target and targetClass == TARGET.PLAYER then
 ...
end
```
---
#### IsEnemy
描述：判断两个对象是不是敌对关系<br>
2个参数：NPC或玩家对象ID, NPC或玩家对象ID<br>
1个返回值：是敌对返回true，否则返回false<br>
示例：if IsEnemy(player.dwID, target.dwID) then ... end

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
描述：返回两个对象之间的距离。<br>
2个参数：对象1，对象2。<br>
1个返回值：距离（尺）。<br>
示例：local distance = s_util.GetDistance(player, target)

---
#### s_util.GetNpc
描述：获取一个指定类型的NPC。<br>
2个参数：NPC模板ID， 范围（单位：尺，缺省值20）。<br>
1个返回值：NPC对象。没有指定类型NPC，返回nil。<br>
示例：<br>
```
--获取扬州接秘境任务那个牌子的NPC对象
local npc_mjrw = s_util.GetNpc(869)
```

---
#### s_util.OutputTip
描述：输出提示信息<br>
2个参数：文本串，颜色（1黄色 2红色 缺省为1）<br>
没有返回值。<br>
示例：s_util.OutputTip("基友们，大家好。")<br>

---
#### s_util.GetSkillCN
描述：获取充能技能可使用次数和冷却剩余时间<br>
1个参数：技能ID<br>
2个返回值：可使用次数，冷却剩余时间（单位：秒）<br>
示例：
```Lua
--如果盾击可使用次数大于0
if s_util.GetSkillCN(13047) > 0 then ... end
```
---
#### s_util.GetSkillOD
描述：获取透支技能可使用次数。<br>
1个参数：技能ID。<br>
1个返回值：剩余透支次数。<br>
示例：
```Lua
--如果雷走风切剩余透支次数大于1
if s_util.GetSkillOD(16629) > 1 then
 ...
end
```
---
#### s_util.GetSkillCD
描述：获取技能冷却剩余时间。<br>
1个参数：技能ID。<br>
1个返回值：冷却剩余时间（单位：秒）。<br>
示例：
```Lua
--如果闹须弥已经冷却
if s_util.GetSkillCD(17057) <= 0 then
 ...
end
```
---
#### s_util.CastSkill
描述：施放技能。<br>
3个参数：技能ID，是否对自己施放，是否不判断读条（可选，如果为true和fcast效果一样，缺省为false）<br>
1个返回值：释放成功返回true，否则返回false。<br>
示例：
```Lua
--
```
说明：第二个参数对于不同类型的技能含义不同。对于需要选择一个位置施放的技能（比如唐门的天绝地灭，纯阳的气场等），如果为true是在自己的位置施放，如果为false是在目标位置施放。对于需要选择一个目标的增益技能（比如奶妈的加血技能），如果为true是对自己施放，如果为false是对目标释放。其他的普通攻击技能这个参数都应该为false.

---
#### GetSkillOTActionState
描述：获取对象读条数据。<br>
1个参数：Player或NPC对象。<br>
5个返回值：是否在读条，技能ID，等级，剩余时间(秒)，动作类型<br>
示例：
```Lua
--获取目标的读条数据
local bPrepare, dwSkillId, dwLevel, nLeftTime, nActionState =  GetSkillOTActionState(target)
```

---
#### s_util.StopSkill
描述：打断技能读条。<br>
没有参数。<br>
没有返回值。<br>
示例：
```Lua
--获取自己读条数据
local bPrepare, dwSkillId, dwLevel, nLeftTime, nActionState =  GetSkillOTActionState(player)
--如果在读条打断读条
if bPrepare then
 s_util.StopSkill()
end
```

---
### s_util.UseItem
描述：使用背包物品。<br>
2个参数：id1，id2。<br>
1个返回值：成功true，否则false。（不成功的原因可能是没有该物品或者物品还没冷却）<br>
示例：
```Lua
--
```

---
#### s_util.GetPuppet
描述：获取唐门千机变的模板ID。<br>
没有参数。<br>
1个返回值：千机变模板ID。没有千机变返回nil。<br>
示例：
```Lua
local puppet = s_util.GetPuppet()
```

---
#### Jump
描述：跳（和按下空格效果相同）。<br>
没有参数。<br>
没有返回值。<br>

### Player对象
自己和其他玩家都是Player对象。以下示例假设变量player是一个Player对象。

| 成员变量 | 描述
| --- | ---
| dwID | 对象ID
| nCurrentLife | 当前气血
| nMaxLife | 最大气血
| nCurrentMana | 当前内力
| nMaxMana | 最大内力
| nCurrentRage | 苍云怒气，霸刀狂意
| nCurrentEnergy | 霸刀刀魂
| nAccumulateValue | 少林禅那，纯阳气点，七秀剑舞层数
| nCurrentSunEnergy | 日灵（是看到的100倍），霸刀气劲
| nCurrentMoonEnergy | 月灵（是看到的100倍）
| nSunPowerValue | 满日（大于0满，否则不满）
| nMoonPowerValue | 满月（大于0满，否则不满）
| nPoseState | 姿态（[POSE_TYPE](#pose_type)枚举值）
| nMoveState | 移动状态（[MOVE_STATE](#move_state)枚举值）
| dwForceID | 门派ID（[FORCE_TYPE](#force_type)枚举值）
| bFightState | 是否战斗状态
| szName | 名字
| nLevel | 等级
| nX | x坐标
| nY | y坐标
| nZ | z坐标
| nCurrentStamina | 精力
| nCurrentThew | 体力

### NPC对象
| 成员变量 | 描述
| --- | ---
| dwID | 对象ID
| dwTemplateID | 模板ID
| nCurrentLife | 当前气血
| nMaxLife | 最大气血
| nCurrentMana | 当前内力
| nMaxMana | 最大内力
| nLevel | 等级
| bFightState | 是否战斗状态
| szName | 名字
| nIntensity | 强度
| nMoveState | 移动状态（[MOVE_STATE](#move_state)枚举值）
| nX | x坐标
| nY | y坐标
| nZ | z坐标


### 枚举值和常量

---
#### TARGET
| 成员 | 描述
| --- | ---
| NO_TARGET | 没有目标
| NPC | 目标是NPC
| PLAYER | 目标是玩家
| DOODAD | 目标是DOODAD

---
#### MOVE_STATE
| 成员 | 描述
| --- | ---
| INVALID | 未知状态
| ON_STAND | 站着不动
| ON_WALK | 走路
| ON_RUN | 跑步
| ON_JUMP | 跳跃
| ON_SWIM_JUMP | 水中跳跃
| ON_SWIM | 游泳
| ON_FLOAT | 水中漂浮
| ON_SIT | 坐下
| ON_KNOCKED_DOWN | 被击倒
| ON_KNOCKED_BACK | 被击退
| ON_KNOCKED_OFF | 被击飞
| ON_HALT | 眩晕
| ON_FREEZE | 定身
| ON_ENTRAP | 锁足
| ON_AUTO_FLY | 乘坐交通工具
| ON_DEATH | 重伤
| ON_DASH | 冲刺
| ON_PULL | 被抓
| ON_REPULSED | 滑行
| ON_RISE | 爬起
| ON_SKID | 滑行
| ON_SPRINT_BREAK | 使用轻功
| ON_SPRINT_DASH | 使用轻功
| ON_SPRINT_KICK | 使用轻功
| ON_SPRINT_FLASH | 使用轻功
| ON_SKILL_MOVE_SRC | 攻击位移状态
| ON_SKILL_MOVE_DST | 被攻击位移状态
| ON_SKILL_MOVE_TAIL | 技能收招状态
| ON_SKILL_MOVE_DEATH | 
| ON_START_AUTO_FLY | 正在开始乘坐交通工具
| ON_FLY | 飞行
| ON_FLY_FLOAT | 未确认
| ON_FLY_JUMP | 未确认
| ON_DASH_TO_POSITION | 未确认

---
#### FORCE_TYPE
| 成员 | 描述
| --- | ---
| JIANG_HU | 大侠
| SHAO_LIN | 少林
| WAN_HUA | 万花
| TIAN_CE | 天策
| CHUN_YANG | 纯阳
| QI_XIU | 七秀
| WU_DU | 五毒
| TANG_MEN | 唐门
| CANG_JIAN | 藏剑
| GAI_BANG | 丐帮
| MING_JIAO | 明教
| CANG_YUN | 苍云
| CHANG_GE | 长歌
| BA_DAO | 霸刀

---
#### POSE_TYPE
| 成员 | 描述
| --- | ---
| SWORD | 苍云 擎刀
| SHIELD | 苍云 擎盾
| GAOSHANLIUSHUI | 长歌 高山流水
| YANGCUNBAIXUE | 长歌 阳春白雪
| PINGSHALUOYAN | 长歌 平沙落雁
| MEIHUASHANNONG | 长歌 梅花三弄
| BROADSWORD | 霸刀 秀明尘身
| SHEATH_KNIFE | 霸刀 雪絮金屏
| DOUBLE_BLADE | 霸刀 松烟竹雾



## 脚本
脚本和宏是不同概念，脚本是一个文本文件，是按行执行的，每次执行一行，每行只能有一条命令。一个命令执行完了，才会下一行。所有命令只有参数，没有返回值。

---
### 基础命令
这些命令用于脚本的流程控制。

---
#### s_cmd.Tag
描述：定义一个标号。<br>
1个参数：标号（串）。<br>

---
#### s_cmd.Goto
描述：跳转到指定标号。<br>
1个参数：标号（串）。<br>
说明：这个命令和上个命令配合组成循环结构。<br>
示例：
```Lua
--这是一个死循环，永远不会退出，除非停止脚本
s_cmd.Tag("开始")
s_cmd.SendMessage("正在循环")
s_cmd.Goto("开始")
```

---
#### s_cmd.CheckExpr
描述：检查表达式的值，如果为真跳转到指定标号，否则执行下一行。<br>
2个参数：Lua表达式，标号（串）。
说明：这个命令和s_cmd.Tag配合组成分支结构或者退出循环。表达式中可以用所有的全局函数和变量。<br>

#### s_cmd.Wait
描述：等待指定时间。<br>
1个参数：等待的时间（数字，单位：毫秒）。<br>
示例：
```lua
--等待1秒
s_cmd.Wait(1000)
```

---
#### s_cmd.WaitFor
描述：等待到指定的表达式为真或超时。<br>
2个参数：超时时间（单位：毫秒，-1表示无限等待），表达式（可选参数）。<br>
说明：如果第2个参数的表达式为真，或者已经过去了第1个参数指定的时间，那么结束等待。<br>
示例：
```Lua
--这是个反面的例子，这个等待永远不会结束。
--因为没有第2个参数，所有它永远不会为真。并且第1个参数指定为无限等待。
s_cmd.WaitFor(-1)
--这样使用和s_cmd.Wait是同样效果，没有指定第2个参数。只有超时了才会结束等待。
s_cmd.WaitFor(1000)
```

---
#### s_cmd.SendMessage
描述：向主控端发送消息。<br>
2个参数：消息串，是否错误（可选，如果为true字体颜色是红色）。<br>

---
### 移动命令
这些命令用于控制角色移动。

---
#### s_cmd.MoveTo
描述：移动到指定位置。<br>
3个参数：X坐标，Y坐标，Z坐标。<br>

---
#### s_cmd.SprintTo
描述：冲刺到指定位置。<br>
3个参数：X坐标，Y坐标，Z坐标。<br>






