-- { ctrl : { class : {num : item_name }} }
local arts_dic = {}
arts_dic['Warrior'] = {}
arts_dic['Wizard'] = {}
arts_dic['Archer'] = {}
arts_dic['Cleric'] = {}
arts_dic['Scout'] = {}

-- { engname : ctrl }
local job_engName = {}

local job_list = {}
job_list['Warrior'] = {}
job_list['Wizard'] = {}
job_list['Archer'] = {}
job_list['Cleric'] = {}
job_list['Scout'] = {}

local high_ability = {}

local function _StringSplit(str, delimStr)  
  local _tempStr = str;
  local _result = { };
  local _index = 1;

  if dic ~= nil and type(dic) == "table" then
      _tempStr = dic.getTranslatedStr(str);
  end

  local try_count = 1

  for try_count = 1, 1000 do 
      if _tempStr == nil then
          break
      end

      local _temp = string.find(_tempStr, delimStr);
      if _temp == nil then
          _result[_index] = _tempStr;
          break;
      else
          _result[_index] = string.sub(_tempStr, 0, _temp - 1);
      end

      _tempStr = string.sub(_tempStr, string.len(_result[_index]) + string.len(delimStr) + 1, string.len(_tempStr));
      _index = _index + 1;

      if string.len(_tempStr) <= 0 then
          break;
      end
  end

  if try_count >= 1000 then
      local ret = {}
      if str == nil then
          ret[1] = ''
      else
          ret[1] = str
      end
      return ret
  end 

  return _result;
end

function RUN_PARSE_HIDDEN_ABILITY_ITEM()
  local list, cnt = GetClassList("Job")
  for i = 0, cnt - 1 do
      local cls  = GetClassByIndexFromList(list, i)
      local EngName = TryGetProp(cls, 'EngName', 'None')        
      if EngName ~= 'None' and EngName ~= 'GM' then
          local ctrl = TryGetProp(cls, 'CtrlType', 'None')
          if ctrl ~= 'None' and TryGetProp(cls, 'EnableJob', 'None') == 'YES' then
              job_engName[EngName] = ctrl

              table.insert(job_list[ctrl], EngName)                
          end
      end
  end

  local idx = 2040001
  for idx = 2040001, 2040559 do
      local cls = GetClassByType('Item', idx)
      if cls ~= nil then
          local job = TryGetProp(cls, 'AbilityIdspace', 'None')
          local token = _StringSplit(job, '_')
          local cls_name = token[2]
          local ctrl = job_engName[cls_name]
          
          if arts_dic[ctrl][cls_name] == nil then
              arts_dic[ctrl][cls_name] = {}
          end
          local item_name = TryGetProp(cls, 'ClassName', 'None')
          if item_name ~= 'None' and TryGetProp(cls, 'EnableItem', 'None') == 'YES' then
              table.insert(arts_dic[ctrl][cls_name], item_name)              
          end
      end
  end

  list, cnt = GetClassList("HiddenAbility_Reinforce")
  for i = 0, cnt - 1 do
      local cls  = GetClassByIndexFromList(list, i)
      local name = TryGetProp(cls, 'HiddenReinforceAbil', 'None')        
      if name ~= 'None' then
          high_ability['HiddenAbility_' .. name] = 1
      end
  end
end

RUN_PARSE_HIDDEN_ABILITY_ITEM()

-- 계열의 직업 리스트를 가져온다.
function GET_JOB_CLASS_LIST(ctrl)
  return job_list[ctrl]
end

-- 해당 계열, 직업의 아츠 리스트를 가져온다.
function GET_HIDDEN_ABILITY_LIST(ctrl, clazz)
  return arts_dic[ctrl][clazz]
end

-- 분해 가능한 신비한 서(낱장) 인가
function IS_HIDDENABILITY_DECOMPOSE_MATERIAL(itemObj)
    if TryGetProp(itemObj, 'ClassName', 'None') == "HiddenAbility_Piece" then
		  return true;
    end
    
    return false;
end

-- 분해 가능한 신비한 서 인가
function IS_HIDDENABILITY_DECOMPOSE_BOOK_MATERIAL(itemObj)
    local ClassName = TryGetProp(itemObj, 'ClassName', 'None')
    local StringArg = TryGetProp(itemObj, 'StringArg', 'None')

    if StringArg == 'HiddenAbility_MasterPiece' then
      return false
    end

    if StringArg == 'Event_HiddenAbility_MasterPiece' then
      return false
    end

    if StringArg == "HiddenAbility_MasterPiece_Novice" then
      return false;
    end
    
    if string.find(ClassName, 'HiddenAbility_') ~= nil  then
        local cls = GetClass('Item', ClassName)
        if cls ~= nil then
            return true
        end
    end
    
    return false
end

-- 상급 강화인가?
function IS_HIGH_HIDDENABILITY(class_name)
    if high_ability[class_name] == 1 then
      return true
    else
      return false
    end
end

-- 시작의 신비한 서 인가
function IS_HIDDENABILITY_MASTERPIECE_NOVICE(itemObj)
  if itemObj.StringArg == "HiddenAbility_MasterPiece_Novice" then
		return true;
  end
  
  return false;
end

-- 시작의 미식별 신비한 서로 획득 가능한 전집인가 (각 직업 1, 2, 3권)
function IS_HIDDENABILITY_MASTERPIECE_NOVICE_SELECTABLE(resultitemClassName)
  local SelectableItemList = {
    'HiddenAbility_SwordmanPackage',
    'HiddenAbility_WizardPackage',
    'HiddenAbility_ArcherPackage',
    'HiddenAbility_ClericPackage',
    'HiddenAbility_ScoutPackage'
  }

  for key, selectableItem in pairs(SelectableItemList) do
    for index = 1, 3 do
      if resultitemClassName == selectableItem..index then
        return true
      end
    end
  end

  return false
end

-- 시작의 미식별 신비한 서로 만들 수 있는 각 직업 별 전집 1~3 calssname list 반환
function IS_HIDDENABILITY_MASTERPIECE_NOVICE_LIST(ctrlType)
  local totalList = {};
  local mainClassName = "HiddenAbility_";
  if ctrlType == "Warrior" then
    mainClassName = mainClassName .. "SwordmanPackage";
  elseif ctrlType == "Wizard" then
    mainClassName = mainClassName .. "WizardPackage";
  elseif ctrlType == "Archer" then
    mainClassName = mainClassName .. "ArcherPackage";
  elseif ctrlType == "Cleric" then
    mainClassName = mainClassName .. "ClericPackage";
  elseif ctrlType == "Scout" then
    mainClassName = mainClassName .. "ScoutPackage";
  end

  for index = 1, 3 do
    totalList[#totalList + 1] = mainClassName..index;
  end

  return totalList;
end

-- 미식별 신비한 서 아이템인지 확인
function IS_HIDDENABILITY_MATERIAL_MASTER_PIECE(itemObj)
  if itemObj.StringArg == "HiddenAbility_MasterPiece" then
		return true;
  end

  if itemObj.StringArg == "HiddenAbility_MasterPiece_Novice" then
		return true;
  end

  return false;
end

-- 신비한 서 제작에 필요한 미식별 신비한 서 수량
function HIDDENABILITY_MAKE_NEED_MASTER_PIECE_COUNT()
  return 1;
end

-- 미식별 신비한 서 갯 수 반환 함수
-- isNovice = 0 or 1, 1일 경우 시작의 미식별 신비한 서 사용
function GET_TOTAL_HIDDENABILITY_MASTER_PIECE_COUNT(pc, isNovice)
  local totalCnt = 0;
  if IsServerObj(pc) == 1 then
    local invItemList = GetInvItemList(pc);
    for i = 1, #invItemList do
      local invItem = invItemList[i];
      local check = (isNovice == 1 and IS_HIDDENABILITY_MASTERPIECE_NOVICE(invItem) == true) or (isNovice == 0 and IS_HIDDENABILITY_MASTERPIECE_NOVICE(invItem) == false)
      if check == true and IsFixedItem(invItem) ~= 1 and IS_HIDDENABILITY_MATERIAL_MASTER_PIECE(invItem) == true then
        local curCnt = GetInvItemCount(pc, invItem.ClassName);
        totalCnt = totalCnt + curCnt;
      end
    end

    return totalCnt;
  else
    local itemList = session.GetInvItemList();
    local guidList = itemList:GetGuidList();

    for i = 0, guidList:Count() - 1 do
      local guid = guidList:Get(i);
      local invItem = itemList:GetItemByGuid(guid);
      if invItem ~= nil and invItem:GetObject() ~= nil and invItem.isLockState == false then
        local itemObj = GetIES(invItem:GetObject());
        local check = (isNovice == 1 and IS_HIDDENABILITY_MASTERPIECE_NOVICE(itemObj) == true) or (isNovice == 0 and IS_HIDDENABILITY_MASTERPIECE_NOVICE(itemObj) == false)
        if check == true and IS_HIDDENABILITY_MATERIAL_MASTER_PIECE(itemObj) == true then
          if itemObj.MaxStack > 1 then
            totalCnt = totalCnt + invItem.count;
          else -- 비스택형 아이템
            totalCnt = totalCnt + 1;
          end
        end
      end
    end
    return totalCnt;
  end

  return 0;
end