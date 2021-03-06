宏和脚本编写说明
====================================
编写宏最好用支持Lua语法高亮的文本编辑器，推荐Notepad++。vs code 和 EditPlus 添加了插件也可以，这样比较容易发现语法错误。<br>

## 目录
  * [宏](#宏)
    * [Lua基础](#lua基础)
    * [基本概念](#基本概念)
    * [全局函数](#全局函数)
    * [Player对象](#player对象)
    * [NPC对象](#npc对象)
    * [枚举值和常量](#枚举值和常量)
    * [其他常用示例](#其他常用示例)
  * [脚本](#脚本)
    * [基础命令](#基础命令)
    * [移动和交通](#移动和交通)
    * [交互和对话](#交互和对话)
    * [任务](#任务)
    * [物品和商店](#物品和商店)
    * [交易行](#交易行)
    * [战斗和技能](#战斗和技能)
    * [其他命令](#其他命令)
    * [全局变量](#全局变量)
 * [台服版使用说明](#台服版使用说明)

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
全局函数可以在编写宏的时候调用，也可以在脚本中作为表达式的一部分调用。

---
#### s_Output
描述：向控制台输出信息，用于输出宏中需要调试的信息。<br>
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
1个参数：NPC或玩家对象。<br>
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
#### SetTarget
描述：设置自己的当前目标。<br>
2个参数：类型（TARGET.NPC或TARGET.PLAYER）， NPC或者玩家对象ID。<br>
没有返回值。<br>

---
#### IsEnemy
描述：判断两个对象是不是敌对关系<br>
2个参数：NPC或玩家对象ID, NPC或玩家对象ID<br>
1个返回值：是敌对返回true，否则返回false<br>
示例：if IsEnemy(player.dwID, target.dwID) then ... end

---
#### s_util.GetBuffInfo
描述：返回指定对象的buff数据表。<br>
2个参数：Player或者NPC对象， 是否只返回自己造成的buff（可选，缺省false）。<br>
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

--有指定buff，并且层数大于3
if TargetBuff[123] and TargetBuff[123].nStackNum > 3 then
 ...
end

--有指定buff并且剩余时间大于1.5秒
if TargetBuff[123] and TargetBuff[123].nLeftTime > 1.5 then
 ...
end

--返回我对目标造成的buff数据
local TargetBuffByMe = s_util.GetBuffInfo(target, true)
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
2个返回值：NPC对象（没有指定类型NPC，返回nil）， 范围内指定NPC数量。<br>
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
5个返回值： 是否在读条，技能ID，等级，读条百分比，动作类型。<br>
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
#### s_util.UseItem
描述：使用背包物品。<br>
2个参数：id1，id2。<br>
1个返回值：成功true，否则false。（不成功的原因可能是没有该物品或者物品还没冷却）<br>
示例：
```Lua
--
```

---
#### s_util.GetPuppet
描述：获取唐门千机变数据。<br>
没有参数。<br>
2个返回值：千机变模板ID（没有返回nil）， 千机变NPC对象（没有返回nil）。<br>
说明：第一个返回值是千机变的模板ID，作为有没有千机变，千机变是什么形态的依据。第二个返回值是千机变的NPC对象，用于获取更详细的信息（一般用途可能是获取自己到千机变的距离）。第一个返回值成功获取的情况下，第二个返回值还是可能为nil。因为千机变的形态数据（模板ID）比NPC数据更早接收到，大概差几十毫秒，游戏中可以观察到，先显示千机变面板然后才出现千机变。所以不要假设第一个返回值正常就一定有第二个返回值。<br>
示例：
```Lua
local TempID, Puppet = s_util.GetPuppet()

--如果没有机关，自己脚下放千机变
if not TempID then
 s_util.CastSkill(3109, true)
end

--如果是底座，变形毒煞
if TempID == 16174 then
 s_util.CastSkill(3370, false)
end

--如果是连弩
if TempID == 16175 then
  ...
end

--如果是重弩
if TempID == 16176 then
  ...
end

--如果是毒煞
if TempID == 16177 then
  ...
end

--如果有千机变，并且距离小于10尺
if Puppet and s_util.GetDistance(player, Puppet) < 10 then
  ...
end
```

---
#### s_util.GetTeamMember
描述：获取团队中血量百分比最少的玩家和团队血量百分比。<br>
1个参数：距离（缺省20尺）。<br>
3个返回值：队伍或团队中血量百分比最少的玩家对象(没有队伍返回nil)，整个团队的血量百分比， 人数。<br>
说明：查找的队友满足以下条件：没死，不是自己，在范围内，团队血量百分比和人数也是根据符合条件的这部分队友计算。<br>
示例:
```Lua
--获取20尺内血量百分比最少的队友，和整个团队的血量百分比
local target, teamHP = s_util.GetTeamMember()
```

---
#### GetNpcIntensity
描述：获取NPC强度。<br>
1个参数：NPC对象。<br>
1个返回值： 强度。 （1普通, 2精英, 3头目, 4BOSS）。<br>
说明： 如果参数不是NPC对象，返回1。<br>

---
#### s_util.GetNpcHatred
描述： 获取NPC对象对自己的仇恨。<br>
1个参数：NPC对象。<br>
1个返回值：仇恨百分比。获取失败返回nil。<br>
说明：当前目标才能获取仇恨数据。当前没有目标、仇恨数据还没同步到客户端、仇恨列表中没有自己都会获取失败。所以要先判断是否获取到，然后再判断数值。<br>
示例：<br>
```Lua
--如果仇恨大于90%
local hatread = s_util.GetNpcHatred(target)
if hatread and hatread > 0.9 then
 ...
end
```

---
#### s_util.GetShadow
描述：获取长歌影子数据。<br>
没有参数。<br>
1个返回值：影子数量。<br>
说明：本人不玩长歌不知道需要获取哪些数据，当前只返回影子的数量。<br>

---
#### Jump
描述：跳（和按下空格效果相同）。<br>
没有参数。<br>
没有返回值。<br>

---
#### s_util.QuestIsAccept
描述：是否已接受指定任务。<br>
1个参数：任务ID。<br>
1个返回值：true或false。<br>

---
#### s_util.QuestIsFinish
描述：指定任务是否可交。<br>
1个参数：任务ID。<br>
1个返回值：true或false。<br>

---
#### s_util.QuestIsFail
描述：指定任务是否已失败。<br>
1个参数：任务ID。<br>
1个返回值：true或false。<br>

---
#### s_util.QuestCheckKill
描述：检查指定任务杀怪条件是否完成。<br>
2个参数：任务ID，索引。<br>
1个返回值：true或false。<br>

---
#### s_util.QuestCheckItem
描述：检查指定任务需要物品是否完成。<br>
2个参数：任务ID，索引。<br>
1个返回值：true或false。<br>

---
#### s_util.QuestCheckState
描述：检查指定任务状态条件是否完成。<br>
2个参数：任务ID，索引。<br>
1个返回值：true或false。<br>

---
#### s_util.GetMapID
描述：获取当前所在地图ID。<br>
没有参数。<br>
1个返回值：当前地图ID。<br>

---
#### s_util.GetBagSize
描述：获取背包信息。<br>
没有参数。<br>
2个返回值：空闲位置数量，总数量<br>

---
#### s_util.GetItemCount
描述：获取背包指定物品的数量。<br>
2个参数：物品ID1，物品ID2。<br>
1个返回值:数量，没有指定物品返回0。<br>

---
#### s_util.FindItem
描述：查找背包物品。<br>
2个参数：物品ID1，物品ID2。<br>
3个返回值：Item对象（没有指定物品返回nil），背包索引，位置索引。<br>

---
#### s_util.GetItemCD
描述：获取物品冷却时间。<br>
2个参数：背包索引，位置索引。<br>
1个返回值：指定位置物品的冷却剩余时间（单位：秒）。<br>
```Lua
--假设物品的ID为 5, 11111
local item, bag, pos = s_util.FindItem(5, 11111)
--如果有指定物品，并且冷却时间小于0.5秒
if item and s_util.GetItemCD(bag, pos) < 0.5 then
   ...
end
```

---
#### s_util.GetWarnMsg
描述：获取警告信息。<br>
没有参数。<br>
1个返回值：警告信息文本。<br>
说明：获取一次后，在游戏中没有再次出现警告信息的情况下，返回的是空串。<br>
示例：
```Lua
--判断战兽山老一的警告信息
local warnmsg = s_util.GetWarnMsg()
if warnmsg == "报九枫吹奏手中长笛，潜入水下可隔绝笛音！" then
 ...
end
--查找子串，更好些，上面的完全相等，稍微复制错少个标点什么的就不行了
if string.find(warnmsg, "报九枫吹奏手中长笛") then
 ...
end
```

---
#### GetTickCount
描述：获取当前时间（毫秒）。<br>
没有参数。<br>
1个返回值：游戏启动后到当前的毫秒数。<br>

---
#### s_util.SetTimer
描述：设置计时器。<br>
1个参数： 计时器名。<br>
没有返回值。<br>

---
#### s_util.GetTimer
描述：获取计时器。<br>
1个参数：计时器名。<br>
1个返回值： 指定计时器从上次设置到当前时间的间隔（毫秒）。<br>
示例：
```Lua
--比如某些操作至少间隔1秒
if s_util.GetTimer("aaa") > 1000 then
 ...
 s_util.SetTimer("aaa")
end
```

---
### Player对象
自己和其他玩家都是Player对象。以下示例假设变量player是一个Player对象。

| 成员变量 | 描述
| --- | ---
| dwID | 对象ID
| nCurrentLife | 当前气血
| nMaxLife | 最大气血
| nCurrentMana | 当前内力
| nMaxMana | 最大内力
| nCurrentRage | 苍云怒气，霸刀狂意，藏剑剑气，天策战意
| nCurrentEnergy | 霸刀刀魂，唐门神机值
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
| nCamp | 阵营（0中立，1浩气，2恶人）
| bOnHorse | 是否在马上

| 成员函数 | 描述
| --- | ---
| GetPet | 获取五毒宠物NPC对象，没有返回nil。没有参数。

---
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

---
### 其他常用示例
```Lua
--获取自己的玩家对象，没有进入游戏会返回nil
local player = GetClientPlayer()

--没有自己的玩家对象直接返回，没有继续的必要了
if not player then return end

--获取自己的当前目标数据
local target, targetClass = s_util.GetTarget(player)

--获取目标的目标数据
local ttarget, ttargetClass = s_util.GetTarget(target)

--如果目标的目标是自己
if ttarget and ttarget.dwID == player.dwID then
 ...
end

--后跳技能（不是迎风回浪）
s_util.CastSkill(9007, false)

--如果在马上，就下马
if player.bOnHorse then
 RideHorse()
end

```


## 脚本
脚本和宏是不同概念，脚本是一个文本文件，是按行执行的，每次执行一行，每行只能有一条命令，并且也只能有一条命令。一个命令执行完了，才会下一行。所有命令只有参数，没有返回值。

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
#### s_cmd.Next()
描述：下一行命令。<br>
没有参数。<br>
说明：这个命令要配合Lua代码使用，只有在一行代码中没有其他命令的时候才使用。<br>

---
#### s_cmd.CheckExpr
描述：检查表达式的值，如果为真跳转到指定标号，否则执行下一行。<br>
2个参数：Lua表达式，标号（串）。<br>
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
#### s_cmd.LoadScript
描述：载入脚本。<br>
2个参数：脚本文件名(相对路径)，行号或者标号(可选，缺省为1)。<br>
示例:<br>
```
--脚本路径是相对于工具所在目录下的脚本目录。假设脚本目录下有 脚本.txt 这个文件
--加载脚本，从第1行开始执行
s_cmd.LoadScript("脚本.txt")
--加载脚本，从指定行号开始
s_cmd.LoadScript("脚本.txt", 50)
--加载脚本，从指定标号开始
s_cmd.LoadScript("脚本.txt", "标号")
```

---
#### s_cmd.SendMessage
描述：向主控端发送消息。<br>
2个参数：消息串，是否错误（可选，如果为true字体颜色是红色）。<br>

---
#### s_cmd.SelectTarget
描述：选择目标。<br>
2个参数：NPC模板ID， 范围（可选，缺省20尺）<br>

---
### 移动和交通
这些命令用于控制角色移动和实现交通功能。

---
#### s_cmd.MoveTo
描述：移动到指定位置。<br>
3个参数：X坐标，Y坐标，Z坐标。<br>

---
#### s_cmd.SprintTo
描述：冲刺到指定位置。<br>
4个参数：X坐标，Y坐标，Z坐标，是否停止（可选，如果为true，到达目标点不停止冲刺）。<br>

---
#### s_cmd.Ride
描述：上马下马。<br>
1个参数：0下马， 1上马。<br>

---
#### s_cmd.TakeBus
描述：坐马车。<br>
2个参数：出发点ID， 到达点ID。<br>

---
#### s_cmd.ShenXing
描述：神行千里。<br>
2个参数：地图ID，交通点ID。<br>

---
#### s_cmd.ItemTransfer
描述：使用物品传送。<br>
2个参数：类型（1旋返书、2战狂牌）， 地图ID。<br>

---
### 交互和对话

---
#### s_cmd.InteractNpc
描述：交互NPC。<br>
3个参数：NPC模板ID，范围（可选，缺省10尺），等待对话面板打开（可选，false等待，true不等待）<br>

---
#### s_cmd.SelectTalk
描述：选择对话项。<br>
1个参数：索引或者文本。<br>
说明：需要先用 s_cmd.InteractNpc 命令交互NPC。<br>

---
#### s_cmd.CheckDialogText
描述：判断对话面板是否有指定文本。如果有跳转到指定标号。<br>
2个参数：文本，标号。<br>
说明：需要先用 s_cmd.InteractNpc 命令交互NPC。<br>

---
#### s_cmd.InteractDoodad
描述：交互DOODAD。<br>
1个参数：模板ID。<br>
说明：交互6尺内指定模板ID的Doodad一次。

---
#### s_cmd.InteractDoodadEx
描述：交互DOODAD。<br>
4个参数：模板ID， 范围（尺）， 表达式（可选）， 标号（如果有表达式，必须指定，否则不需要）。<br>
说明：交互指定范围内的Doodad，如果距离大于6尺，会向Doodad移动。指定范围内没有指定的Doodad下一条命令。如果表达式为真，跳转到指定标号。<br>

---
### 任务

---
#### s_cmd.AcceptQuest
描述：接受任务。<br>
2个参数：NPC模板ID，任务ID。<br>

---
#### s_cmd.AcceptAllQuest
描述：接受指定NPC所有可接任务。<br>
1个参数：NPC模板ID。<br>

---
#### s_cmd.FinishQuest
描述：完成任务。<br>
4个参数：NPC模板ID， 任务ID， 第一组奖励选择索引（可选）， 第二组奖励选择索引（可选）。<br>

---
#### s_cmd.CancelQuest
描述：放弃任务。<br>
1个参数：任务ID。<br>

---
### 物品和商店

---
#### s_cmd.OpenShop
描述：打开商店。<br>
1个参数：商店名。<br>
说明：这个命令的上一条命令必须是s_cmd.InteractNpc。<br>

---
#### s_cmd.BuyItem
描述：购买物品。<br>
4个参数：物品ID1， 物品ID2， 购买数量， 物品所在的页数（可选，缺省第1页）。<br>
说明：购买数量是买够这种物品的总数量，比如参数是5，这种物品背包已经有2个，只会再买3个。<br>

---
#### s_cmd.SellItem
描述：出售物品。<br>
2个参数：物品ID1， 物品ID2。<br>

---
#### s_cmd.UseItem
描述：使用物品。<br>
4个参数：物品ID1， 物品ID2， 是否使用到没有。<br>

---
#### s_cmd.DestroyItem
描述：删除物品。<br>
2个参数：物品ID1， 物品ID2。<br>

---
#### s_cmd.OpenBox
描述： 打开盒子物品。<br>
2个参数： 物品ID1， 物品ID2。<br>

---
#### s_cmd.GetLevelAward
描述： 领取等级礼包。<br>
1个参数: 索引（1-10)。<br>

---
#### s_cmd.DailySign
描述： 每日签到。<br>
没有参数。<br>

---
#### s_cmd.ReadAllBook
描述： 阅读背包中所有没有读过的书籍。<br>
没有参数。<br>

---
#### s_cmd.ExchangeEquip
描述： 切换装备。<br>
1个参数：索引（1-4）。<br>

---
### 交易行

---
#### s_cmd.AuctionBuy
描述：交易行购买物品。<br>
4个参数：NPC模板ID， 物品ID1， 物品ID2， 单价（单位：铜）<br>
说明：从交易行购买一口价低于指定单价的所有指定物品。<br>

---
#### s_cmd.AuctionSell
描述：交易行寄售物品。<br>
5个参数：NPC模板ID， 物品ID1， 物品ID2， 单价（单位：铜），  保管时间(12,24,48之一)<br>
说明：把背包中的所有指定物品，以比其他人低1银的单价寄售。如果最低单价低于指定的单价不寄售。<br>

---
### 战斗和技能

---
#### s_cmd.Fight
描述： 战斗。<br>
3个参数：<br>

| 参数 | 说明 
| --- | --- 
| 参数1 | 战斗函数索引。缺省1。
| 参数2 | 敌人类型。 0所有， 1NPC， 2玩家， NPC模板ID。缺省0。
| 参数3 | 范围。单位：尺，缺省20。

示例：
```Lua
--下面两行效果完全一样，没有指定的参数，都会使用缺省值。
--用战斗函数表中第1个函数，攻击所有敌人，范围20尺。
s_cmd.Fight(1, 0, 20)
s_cmd.Fight()

--攻击10尺内模板ID为12345的NPC。
--这是个死循环，除非手动停止，脚本不会结束。
s_cmd.Tag("开始")
s_cmd.Fight(1, 12345, 10)
s_cmd.Goto("开始")
```

---
#### s_cmd.FightEx
描述： 战斗。<br>
5个参数：<br>

| 参数 | 说明 
| --- | --- 
| 参数1 | 战斗函数索引。缺省1.
| 参数2 | 敌人类型。 0所有， 1NPC， 2玩家， NPC模板ID。缺省0.
| 参数3 | 范围。单位：尺，缺省20.
| 参数4 | Lua表达式
| 参数5 | 标号

说明：和上一个命令的区别是，攻击到指定范围内没有符合条件的敌人，才下一条命令。表达式为真，跳转到指定标号。

---
#### s_cmd.SelectTalentPoint
描述： 选择奇穴。<br>
2个参数： 奇穴ID， 索引。<br>

---
#### s_cmd.LearnRecipe
描述： 领悟秘籍。<br>
2个参数： 技能ID， 秘籍ID。<br>

---
#### s_cmd.UpdateSkill
描述： 升级所有可升级的技能。<br>
没有参数。<br>

---
#### s_cmd.MountKungfu
描述： 切换内功。<br>
1个参数： 内功ID。<br>

---
#### s_cmd.SitDown
描述： 打坐。<br>
1个参数: 表达式。<br>
说明： 当表达式为真，结束打坐。<br>

---
#### s_cmd.UseSkill
描述：使用技能。<br>
2个参数： 技能ID， 是否等待读条（可选，缺省false）。<br>

---
### 其他命令

---
#### s_cmd.CancelBuff
描述： 取消buff。<br>
1个参数：buffid。<br>

---
#### s_cmd.Fishing
描述： 帮会钓鱼。<br>
没有参数。<br>

---
#### s_cmd.SendChat
描述： 发送聊天信息。<br>
1个参数： 聊天信息文本。<br>
示例:<br>
```
--地图频道喊话
s_cmd.SendChat("/y Hello World!")
```

---
#### s_cmd.SwitchMap
描述：切换地图<br>
1个参数：目标地图名称。<br>
示例:
```Lua
--进入副本
s_cmd.SwitchMap("5人英雄")
--进入地图
s_cmd.SwitchMap("洛道")
```

---
### 全局变量
以下全局变量用于配置脚本的一些选项。<br>

---
#### s_tConfigVar.bRevive
描述：是否回营地复活。缺省值为false。<br>
说明：脚本运行中，如果角色死亡会自动复活。如果当前地图不能原地复活（比如在副本内），直接回营地复活。如果当前地图可原地复活，判断这个变量，如果为false，原地复活，如果为true，回营地复活。如果是回营地复活，复活后会检查脚本中是否有 "复活点" 标号，如果有就跳转到这个标号。<br>
示例：<br>
```Lua
--自绝经脉回营地
s_tConfigVar.bRevive = true s_cmd.Next()  --设置回营地复活
s_cmd.UseSkill(608, true)                 --自绝经脉
s_tConfigVar.bRevive = false s_cmd.Next() --设置原地复活
```

---
## 台服版使用说明
把 X:\你台服版的安装目录\bin\zhtw_hd\ 文件夹下的 gameupdater.exe 改名为 gameupdater2.exe， 把软件目录下的 gameupdater.exe 复制到这个位置，然后启动台服登录游戏的软件，和正常流程一样启动游戏。首次运行会有选择配套软件所在目录的对话框，选择手残党台服版目录下的m.exe。<br>
注意：台服版的宏和脚本， 要保存为不带 BOM 的 UTF-8 编码（不明白自行百度）， 不然会乱码， 脚本还可能不正常（比如打开商店的商店名）。<br>


