```Lua
--奇穴：[虎踞][滄雪][疏狂][化蛟][含風][逐鹿][斬紛][星火][楚歌][絕期][冷川][心鏡]
--秘籍：项王击鼎回狂，刀啸风吟回气劲是必须的
--作者：还珠楼主
--最后修改日期：2018/4/21


--初始化
if not g_MacroVars.State_16027 then
	g_MacroVars.State_16027 = 0				--刀啸风吟3次标志
	g_MacroVars.State_11334 = 0				--含风buff标志
end


--获取自己的Player对象，没有的话说明还没进入游戏，直接返回
local player = GetClientPlayer()
if not player then return end

--如果当前门派不是霸刀，输出错误信息
if player.dwForceID ~= FORCE_TYPE.BA_DAO then
	s_util.OutputTip("当前门派不是霸刀，这个宏无法正确运行。", 1)
	return
end

--当前血量比值
local hpRatio = player.nCurrentLife / player.nMaxLife

--获取当前目标，没有目标或者目标不是敌人，直接返回
local target, targetClass = s_util.GetTarget()							--返回 目标对象和目标类型(玩家或者NPC)
if not target or not IsEnemy(player.dwID, target.dwID) then return end

--如果目标死亡，直接返回
if target.nMoveState == MOVE_STATE.ON_DEATH then return end

--获取自己的buff表
local MyBuff = s_util.GetBuffInfo(player)

--获取目标的buff表
local TargetBuff = s_util.GetBuffInfo(target)

--获取自己和目标的距离
local distance = s_util.GetDistance(player, target)


--给目标挂上闹须弥
if (not TargetBuff[11447] or TargetBuff[11447].dwSkillSrcID ~= player.dwID) and s_util.GetSkillCD(17057) <= 0 then		--如果目标没有闹须弥buff或者不是我的，闹须弥冷却
	if player.nPoseState ~= POSE_TYPE.DOUBLE_BLADE then		--如果不是松烟竹雾姿态
		s_util.CastSkill(16166, false)						--施放松烟竹雾
		return
	end
	s_util.CastSkill(17057,false)							--释放 闹须弥
	return
end


--如果是松烟竹雾切姿态
if player.nPoseState == POSE_TYPE.DOUBLE_BLADE then
	--如果有疏狂就切雪絮金屏，否则切秀明尘身
	if MyBuff[11456]  then 
		s_util.CastSkill(16169, false)						--施放雪絮金屏
		g_MacroVars.State_16027 = 0							--切姿态后设置刀x3标志为0
	else
		s_util.CastSkill(16168, false)						--施放秀明尘身
	end
	return
end


--如果是秀明尘身姿态
if player.nPoseState == POSE_TYPE.BROADSWORD then
	--优先放坚壁清野
	if s_util.GetSkillCD(16621) <= 0 and player.nCurrentSunEnergy >= 10 then					--如果坚壁清野冷却了，气劲大于等于10
		--西楚悲歌
		if s_util.CastSkill(16454, false) then return end

		--切换到雪絮金屏姿态
		s_util.CastSkill(16169, false)
		g_MacroVars.State_16027 = 0
		return
	end

	--雷走风切
	if s_util.CastSkill(16629, false) then return end

	--破釜沉舟
	if s_util.CastSkill(16602, false) then return end

	--上将军印 有僵直
	--if s_util.CastSkill(16627, false) then return end

	--项王击鼎321段
	if s_util.CastSkill(17079, false) then return end
	if s_util.CastSkill(17078, false) then return end
	if s_util.CastSkill(16601, false) then return end
end


--如果是雪絮金屏姿态  坚壁 + 醉 + 刀x3 + 醉
if player.nPoseState == POSE_TYPE.SHEATH_KNIFE then
	--处理雪絮金屏姿态气劲用完的情况，一般这个条件不会达到，但是还是要考虑各种特殊情况
	if player.nCurrentSunEnergy < 5 then				--如果气劲小于5点
		s_util.CastSkill(16168, false)					--施放秀明尘身
		return
	end

	--坚壁清野
	if s_util.CastSkill(16621, false) then return end

	--处理第三次刀啸读条结束，buff还没同步的问题
	local bPrepare, dwSkillId, dwLevel, nLeftTime, nActionState =  GetSkillOTActionState(player)		--获取我的读条数据
	if dwSkillId == 16027 and nLeftTime < 0.5 and MyBuff[11334] and MyBuff[11334].nStackNum == 2 then			--如果在读条刀啸，并且剩余时间小于0.5秒, 并且有2层含风
		g_MacroVars.State_11334 = 1				--设置含风buff标志为1，就当作已经有3层含风了
	end

	--设置放过三次刀啸标志
	if MyBuff[11334] and MyBuff[11334].nStackNum > 2 then		--如果有含风，并且含风层数大于2
		g_MacroVars.State_16027 = 1							--技能状态设置为1，表示已经用过三次刀啸
	end

	--醉斩白蛇
	if g_MacroVars.State_11334 == 1 or not MyBuff[11334] or MyBuff[11334].nStackNum > 2 then  	--放过3次刀啸，或者没有含风，或者含风层数大于2
		if s_util.CastSkill(16085, false) then				--施放醉斩白蛇
			g_MacroVars.State_11334 = 0
			return
		end
	end

	--切到秀明尘身
	if s_util.GetSkillCD(16085) > 0 and g_MacroVars.State_16027 == 1 then		--如果醉斩白蛇有CD，并且用过三次刀啸
		s_util.CastSkill(16168, false)					--施放秀明尘身
		return
	end

	--刀啸风吟
	if not MyBuff[11334] or MyBuff[11334].nStackNum < 3 then		--没有含风buff，或者含风层数小于3
		s_util.CastSkill(16027,false)								--施放刀啸风吟
	end
end
```
