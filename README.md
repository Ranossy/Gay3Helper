宏和脚本编写说明
====================================

## 目录
  * 宏
    * Lua基础
    * 基本概念
    * 全局函数
    * Player对象
    * NPC对象
    * 常量
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
没有参数。<br>
1一个返回值：自己控制的Player对象。如果尚未进入游戏返回nil。<br>
示例： local player = GetClientPlayer()<br>


### Player对象

### NPC对象

### 常量

---
#### TARGET

| NO_TARGET | 没有目标 |
| NPC | NPC |
| PLAYER | 玩家 |
| DOODAD | DOODAD |



## 脚本
    
