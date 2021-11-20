--애드온 이름
local addonName = 'WarehouseManager'
local addonNameUpper = string.upper(addonName)
local addonNameLower = string.lower(addonName)


--제작자 이름
local author = 'Charbon'
local authorUpper = string.upper(author)
local authorLower = string.lower(author)


--버전
local version = '1.1.7'


--전역 변수 설정
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][authorUpper] = _G['ADDONS'][authorUpper] or {}
_G['ADDONS'][authorUpper][addonNameUpper] = _G['ADDONS'][authorUpper][addonNameUpper] or {}
local WarehouseManager = _G['ADDONS'][authorUpper][addonNameUpper]


--라이브러리 변수 설정
local ACUtil = require('acutil')
local CharbonAPI = require('charbonapi')


--다국어
WarehouseManager.LangTable = {
  ['kr'] = {
    Message = {
      CannotLoadSettings = '설정 파일을 불러오지 못했습니다.',
      ConsumeItemCount   = '인벤토리에 남길 개수를 입력해주세요.',
      WarehouseClosed    = '팀 창고가 닫혀 있습니다.',
      SilverDeposited    = '{img silver 20 20} %s 실버를 입금했습니다.',
      SilverWithdrawn    = '{img silver 20 20} %s 실버를 출금했습니다.',
      ItemDeposited      = '{img %s 20 20} %s %s개를 팀 창고에 넣었습니다.',
      ItemWithdrawn      = '{img %s 20 20} %s %s개를 팀 창고에서 꺼냈습니다.'
    },
    System = {
      Close             = '{@st59}닫기{/}',
      Title             = '{@st43}팀 창고 설정{/}',
      DefaultTitle      = '{s16}{ol}기본 설정{/}{/}',
      CommonItemTitle   = '{s16}{ol}정리할 공용 아이템 목록{/}{/}',
      PersonalItemTitle = '{s16}{ol}정리할 개인 아이템 목록{/}{/}',
      Deposit           = '{@st66b}자동 입금{/}',
      Withdraw          = '{@st66b}자동 출금{/}',
      ArrangeItems      = '{@st66b}아이템 자동 정리{/}',
      Silver            = '{@st42b}{img silver 20 20} 실버{/}'
    }
  },
  ['jp'] = {
    Message = {
      CannotLoadSettings = '設定ファイルをロードできません。',
      ConsumeItemCount   = 'インベントリに残す数を入力してください。',
      WarehouseClosed    = 'チーム倉庫が閉じています。',
      SilverDeposited    = '{img silver 20 20} %s シルバーを入金しました。',
      SilverWithdrawn    = '{img silver 20 20} %s シルバーを出金しました。',
      ItemDeposited      = '{img %s 20 20} %s %s個　チーム倉庫に搬入しました。',
      ItemWithdrawn      = '{img %s 20 20} %s %s個　チーム倉庫から搬出しました。'
    },
    System = {
      Close             = '{@st59}閉じる{/}',
      Title             = '{@st43}チーム倉庫設定{/}',
      DefaultTitle      = '{s16}{ol}デフォルト設定{/}{/}',
      CommonItemTitle   = '{s16}{ol}チーム全体のアイテム設定{/}{/}',
      PersonalItemTitle = '{s16}{ol}キャラクタごとのアイテム設定{/}{/}',
      Deposit           = '{@st66b}自動入金{/}',
      Withdraw          = '{@st66b}自動出金{/}',
      ArrangeItems      = '{@st66b}アイテムを自動整頓{/}',
      Silver            = '{@st42b}{img silver 20 20} シルバー{/}'
    }
  },
  ['global'] = {
    Message = {
      CannotLoadSettings = 'Can not load settings.',
      ConsumeItemCount   = 'Enter the number to be left in the inventory.',
      WarehouseClosed    = 'Warehouse is closed.',
      SilverDeposited    = 'Deposited {img silver 20 20} %s silver.',
      SilverWithdrawn    = 'Withdrawn {img silver 20 20} %s silver.',
      ItemDeposited      = 'Put {img %s 20 20} %s x %s in the warehouse.',
      ItemWithdrawn      = 'Taken {img %s 20 20} %s x %s in the warehouse.'
    },
    System = {
      Close             = '{@st59}Close{/}',
      Title             = '{@st43}Warehouse Settings{/}',
      DefaultTitle      = '{s16}{ol}Default Settings{/}{/}',
      CommonItemTitle   = '{s16}{ol}Common Item List to Arrange{/}{/}',
      PersonalItemTitle = '{s16}{ol}Personal Item List to Arrange{/}{/}',
      Deposit           = '{@st66b}Deposit automatically{/}',
      Withdraw          = '{@st66b}Withdraw automatically{/}',
      ArrangeItems      = '{@st66b}Arrange items automatically{/}',
      Silver            = '{@st42b}{img silver 20 20} Silver{/}'
    }
  }
}


--설정 파일 저장 위치
WarehouseManager.SettingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
WarehouseManager.CharSettingsFileLoc = string.format('../addons/%s/%%s.json', addonNameLower)


--기본 설정
WarehouseManager.DefaultSettings = {}
WarehouseManager.DefaultSettings.DepositEnabled = false
WarehouseManager.DefaultSettings.WithdrawEnabled = false
WarehouseManager.DefaultSettings.ArrangeItemsEnabled = false
WarehouseManager.DefaultSettings.Silver = 0
WarehouseManager.DefaultSettings.ItemList = {}
WarehouseManager.DefaultCharSettings = {}
WarehouseManager.DefaultCharSettings.ItemList = {}


--상수 설정
WarehouseManager.TYPE_DEPOSIT         = 0
WarehouseManager.TYPE_WITHDRAW        = 1
WarehouseManager.RET_WAREHOUSE_CLOSED = -1
WarehouseManager.RET_NO_NEED_DEPOSIT  = -2
WarehouseManager.RET_NO_NEED_WITHDRAW = -3
WarehouseManager.RET_SUCCESS          = 0
WarehouseManager.RET_KEEP_DEPOSIT     = 1


--설정되어 있는 다국어 코드 반환
function WarehouseManager.GetLangCode(self)
  local langCode = self.Settings and self.Settings.LangCode

  if not langCode then
    langCode = option.GetCurrentCountry()

    if langCode == 'kr' then
      langCode = 'kr'
    elseif langCode == 'Japanese' then
      langCode = 'jp'
    else
      langCode = 'global'
    end
  end

  return langCode
end


--다국어 텍스트 반환
function WarehouseManager.GetLangText(self, key, ...)
  return CharbonAPI:GetLangText(self.LangTable, self:GetLangCode(), key, ...)
end


--로그 출력
function WarehouseManager.Log(self, mode, key, ...)
  return CharbonAPI:Log(mode, self.LangTable, self:GetLangCode(), key, ...)
end


--설정 파일 관리
function WarehouseManager.LoadSettings(self)
  --애드온 설정 불러오기
  local settings, err = ACUtil.loadJSON(self.SettingsFileLoc)

  --파일 I/O 오류 처리
  if err then
    self:Log('Normal', 'Message.CannotLoadSettings')
  end

  --기본 설정 적용
  if not settings then
    settings = self.DefaultSettings
  end

  if not settings.LangCode then
    settings.LangCode = self:GetLangCode()
  end

  --설정 저장
  self.Settings = settings
end


function WarehouseManager.SaveSettings(self)
  return ACUtil.saveJSON(self.SettingsFileLoc, self.Settings)
end


function WarehouseManager.LoadCharSettings(self, charID)
  if not charID then
    charID = self:GetCharID()
  end

  --애드온 설정 불러오기
  local charSettingsFileLoc = string.format(self.CharSettingsFileLoc, charID)
  local settings, err = ACUtil.loadJSON(charSettingsFileLoc)

  --파일 I/O 오류 처리
  if err then
    self:Log('Normal', 'Message.CannotLoadSettings')
  end

  --기본 설정 적용
  if not settings then
    settings = self.DefaultCharSettings
  end

  --설정 저장
  self.CharSettings = settings
end


function WarehouseManager.SaveCharSettings(self, charID)
  if not charID then
    charID = self:GetCharID()
  end

  local charSettingsFileLoc = string.format(self.CharSettingsFileLoc, charID)
  return ACUtil.saveJSON(charSettingsFileLoc, self.CharSettings)
end


--캐릭터 고유값 반환
function WarehouseManager.GetCharID(self)
  return info.GetCID(session.GetMyHandle())
end


--자동 입금 설정 반환
function WarehouseManager.IsDepositEnabled(self)
  return self.Settings.DepositEnabled
end


--아이템 자동 정리 설정 반환
function WarehouseManager.IsArrangeItemsEnabled(self)
  return self.Settings.ArrangeItemsEnabled
end


--자동 입금 설정 변경
function WarehouseManager.ToggleDeposit(self)
  self.Settings.DepositEnabled = not self.Settings.DepositEnabled
  self:SaveSettings()
end


--자동 출금 설정 반환
function WarehouseManager.IsWithdrawEnabled(self)
  return self.Settings.WithdrawEnabled
end


--팀 창고가 열려있는지 확인
function WarehouseManager.IsWarehouseVisible(self)
  local warehouseFrame = ui.GetFrame('accountwarehouse')
  return warehouseFrame:IsVisible() == 1
end


--자동 출금 설정 변경
function WarehouseManager.ToggleWithdraw(self)
  self.Settings.WithdrawEnabled = not self.Settings.WithdrawEnabled
  self:SaveSettings()
end


function WarehouseManager.ToggleArrangeItems(self)
  self.Settings.ArrangeItemsEnabled = not self.Settings.ArrangeItemsEnabled
  self:SaveSettings()
end


--캐릭터 실버 반환
function WarehouseManager.GetSilver(self)
  return self.Settings.Silver
end


--캐릭터 실버 변경
function WarehouseManager.SetSilver(self, silver)
  self.Settings.Silver = math.max(tonumber(silver), 0)
  self:SaveSettings()
end


--등록되어 있는 아이템 목록 반환
function WarehouseManager.GetCommonItemList(self)
  return self.Settings.ItemList
end


function WarehouseManager.GetPersonalItemList(self)
  return self.CharSettings.ItemList
end


--아이템 등록
function WarehouseManager.InsertItem(self, itemList, itemType, count)
  count = tonumber(count) or 0

  --중복 검사
  for i = 1, #itemList do
    local itemSetting = itemList[i]
    if itemType == itemSetting.ItemType then
      return false
    end
  end

  table.insert(itemList, {
    ItemType = itemType,
    Count    = count
  })

  return true
end


function WarehouseManager.InsertCommonItem(self, itemType, count)
  local result = self:InsertItem(self.Settings.ItemList, itemType, count)

  self:SaveSettings()

  return result
end


function WarehouseManager.InsertPersonalItem(self, itemType, count)
  local result = self:InsertItem(self.CharSettings.ItemList, itemType, count)

  self:SaveCharSettings()

  return result
end


--아이템 삭제
function WarehouseManager.DeleteItem(self, itemList, itemType)
  for i = #itemList, 1, -1 do
    local itemSetting = itemList[i]
    if itemType == itemSetting.ItemType then
      table.remove(itemList, i)
    end
  end
end


function WarehouseManager.DeleteCommonItem(self, itemType)
  local result = self:DeleteItem(self.Settings.ItemList, itemType)

  self:SaveSettings()

  return result
end


function WarehouseManager.DeletePersonalItem(self, itemType)
  local result = self:DeleteItem(self.CharSettings.ItemList, itemType)

  self:SaveCharSettings()

  return result
end


--캐릭터 실버 오브젝트 반환
function WarehouseManager.GetInvVisItem(self)
  local visItem = session.GetInvItemByName(MONEY_NAME)
  local charSilver = visItem and tonumber(visItem:GetAmountStr()) or 0

  return visItem, charSilver
end


--팀 창고 실버 오브젝트 반환
function WarehouseManager.GetWarehouseVisItem(self)
  local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
  local cnt, visItemList = GET_INV_ITEM_COUNT_BY_PROPERTY({{
      Name = 'ClassName',
      Value = MONEY_NAME
    }},
    false,
    itemList)

  local visItem = visItemList[1]
  local warehouseSilver = visItem and tonumber(visItem:GetAmountStr()) or 0

  return visItem, warehouseSilver
end


--넣을 아이템 중 첫 번째 아이템 반환
function WarehouseManager.DequeueDepositItemList(self)
  return self.DepositItemList and table.remove(self.DepositItemList, 1)
end


--꺼낼 아이템 반환
function WarehouseManager.GetWithdrawItemList(self)
  return self.WithdrawItemList
end


--넣을 아이템 설정
function WarehouseManager.SetDepositItemList(self, itemList)
  self.DepositItemList = itemList
end


--꺼낼 아이템 설정
function WarehouseManager.SetWithdrawItemList(self, itemList)
  self.WithdrawItemList = itemList
end


--넣을 아이템이 있는지 확인
function WarehouseManager.IsExistDepositItemList(self)
  return not not self.DepositItemList
end


--꺼낼 아이템이 있는지 확인
function WarehouseManager.IsExistWithdrawItemList(self)
  return not not self.WithdrawItemList
end


--넣을 아이템이 남아있는지 확인
function WarehouseManager.IsRemainDepositItemList(self)
  return self:IsExistDepositItemList() and #self.DepositItemList > 0
end


--캐릭터 실버 입금
function WarehouseManager.DepositSilver(self)
  local visItem, charSilver = self:GetInvVisItem()
  local depositSilver = charSilver - self:GetSilver()

  if depositSilver < 1 then
    return 0
  end

  local warehouseFrame = ui.GetFrame('accountwarehouse')
  local handle = warehouseFrame:GetUserIValue('HANDLE')

  item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, visItem:GetIESID(), tostring(depositSilver), handle)

  return depositSilver
end


--팀 창고 실버 출금
function WarehouseManager.WithdrawSilver(self)
  local invVisItem, charSilver = self:GetInvVisItem()
  local warehouseVisItem, warehouseSilver = self:GetWarehouseVisItem()

  if not warehouseVisItem then
    return 0
  end

  local withdrawSilver = self:GetSilver() - charSilver

  if withdrawSilver < 1 then
    return 0
  end

  local warehouseFrame = ui.GetFrame('accountwarehouse')
  local handle = warehouseFrame:GetUserIValue('HANDLE')

  session.ResetItemList()
  session.AddItemIDWithAmount(warehouseVisItem:GetIESID(), tostring(withdrawSilver))
  item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), handle)

  return withdrawSilver
end


--인벤토리 아이템 넣기
function WarehouseManager.DepositItems(self)
  --팀 창고가 열려 있지 않은 경우
  if not self:IsWarehouseVisible() then
    return self.RET_WAREHOUSE_CLOSED
  end

  --넣을 아이템이 없을 경우
  if not self:IsExistDepositItemList() then
    return self.RET_NO_NEED_DEPOSIT
  end

  --아이템을 모두 넣었을 경우
  if not self:IsRemainDepositItemList() then
    self:SetDepositItemList(nil)
    return self.RET_SUCCESS
  end

  --인벤토리 아이템 넣기
  local depositItem = self:DequeueDepositItemList()
  local warehouseFrame = ui.GetFrame('accountwarehouse')
  local handle = warehouseFrame:GetUserIValue('HANDLE')

  item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, depositItem.ItemGuid, depositItem.Count, handle, depositItem.Index)

  return self.RET_KEEP_DEPOSIT, depositItem
end


--팀 창고 아이템 꺼내기
function WarehouseManager.WithdrawItems(self)
  local warehouseFrame = ui.GetFrame('accountwarehouse')
  local handle = warehouseFrame:GetUserIValue('HANDLE')

  --꺼낼 아이템이 없을 경우
  if not self:IsExistWithdrawItemList() then
    return self.RET_NO_NEED_WITHDRAW
  end

  local withdrawItemList = self:GetWithdrawItemList()

  --팀 창고 아이템 꺼내기
  self:SetWithdrawItemList(nil)
  session.ResetItemList()

  for i, withdrawItem in ipairs(withdrawItemList) do
    session.AddItemID(withdrawItem.ItemGuid, withdrawItem.Count)
  end

  item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), handle)

  return self.RET_SUCCESS
end


--정리할 아이템 반환
function WarehouseManager.GetArrangeItemList(self)
  local itemList = {}
  local arrangeItemList = {}
  local depositItemList = {}
  local withdrawItemList = {}

  for _, itemSetting in ipairs(self:GetCommonItemList()) do
    table.insert(itemList, {
      ItemType = itemSetting.ItemType,
      Count    = itemSetting.Count
    })
  end

  for _, itemSetting in ipairs(self:GetPersonalItemList()) do
    for i = #itemList, 1, -1 do
      local oldItemSetting = itemList[i]
      if oldItemSetting.ItemType == itemSetting.ItemType then
        table.remove(itemList, i)
      end
    end

    table.insert(itemList, {
      ItemType = itemSetting.ItemType,
      Count    = itemSetting.Count
    })
  end

  --인벤토리 아이템 확인
  local invItemList = session.GetInvItemList()

  FOR_EACH_INVENTORY(invItemList, function(
    invItemList,
    invItem)

      local itemCls = GetClassByType('Item', invItem.type)
      local enableTeamTrade = TryGetProp(itemCls, 'TeamTrade', 'YES') ~= 'NO'

      for _, itemSetting in ipairs(itemList) do
        if itemSetting.ItemType == invItem.type then
          local depositCount = math.max(invItem.count - itemSetting.Count, 0)
          local withdrawCount = math.max(itemSetting.Count - invItem.count, 0)

          --팀 창고로 아이템을 넣어야 할 경우
          if depositCount > 0 and enableTeamTrade and not invItem.isLockState then
            table.insert(arrangeItemList, {
              Type     = self.TYPE_DEPOSIT,
              ItemType = itemSetting.ItemType,
              ItemGuid = invItem:GetIESID(),
              Count    = depositCount
            })

          --팀 창고에서 아이템을 빼야 할 경우
          elseif withdrawCount > 0 then
            table.insert(arrangeItemList, {
              Type     = self.TYPE_WITHDRAW,
              ItemType = itemSetting.ItemType,
              Count    = withdrawCount
            })
          end

          break
        end
      end
    end,
    false)

  --인벤토리에 없는 아이템 확인
  for _, itemSetting in ipairs(itemList) do
    local invItemOpt = {
      ItemExist = false
    }

    FOR_EACH_INVENTORY(invItemList, function(
      invItemList,
      invItem,
      invItemOpt)

        if itemSetting.ItemType == invItem.type then
          invItemOpt.ItemExist = true
        end
      end,
      false,
      invItemOpt)

    if not invItemOpt.ItemExist then
      table.insert(arrangeItemList, {
        Type     = self.TYPE_WITHDRAW,
        ItemType = itemSetting.ItemType,
        Count    = itemSetting.Count
      })
    end
  end

  --팀 창고 아이템 확인
  local warehouseItemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)

  FOR_EACH_INVENTORY(warehouseItemList, function(
    warehouseItemList,
    warehouseItem)

      local warehouseItemObj = GetIES(warehouseItem:GetObject())
      local maxStack = TryGetProp(warehouseItemObj, 'MaxStack', 1)

      for _, arrangeItem in ipairs(arrangeItemList) do
        if arrangeItem.ItemType == warehouseItem.type then

          --넣을 아이템 확인
          if arrangeItem.Type == self.TYPE_DEPOSIT and maxStack > 1 then
            arrangeItem.Index = warehouseItem.invIndex

          --꺼낼 아이템 확인
          elseif arrangeItem.Type == self.TYPE_WITHDRAW then
            arrangeItem.ItemGuid = warehouseItem:GetIESID()
            arrangeItem.Count = math.min(arrangeItem.Count, warehouseItem.count)
          end

          break
        end
      end
    end,
    false)

  --넣을 아이템과 꺼낼 아이템 분리
  for _, arrangeItem in ipairs(arrangeItemList) do
    if arrangeItem.ItemGuid and arrangeItem.Count > 0 then

      --넣을 아이템 추가
      if arrangeItem.Type == self.TYPE_DEPOSIT then
        table.insert(depositItemList, {
          ItemType = arrangeItem.ItemType,
          ItemGuid = arrangeItem.ItemGuid,
          Index    = arrangeItem.Index,
          Count    = arrangeItem.Count
        })

      --꺼낼 아이템 추가
      elseif arrangeItem.Type == self.TYPE_WITHDRAW then
        table.insert(withdrawItemList, {
          ItemType = arrangeItem.ItemType,
          ItemGuid = arrangeItem.ItemGuid,
          Count    = arrangeItem.Count
        })
      end
    end
  end

  return depositItemList, withdrawItemList
end


--팀 창고에 설정 버튼 추가
function WarehouseManager.CreateOpenButtonCtrl(self)
  --팀 창고 공간 확보
  self:AdjustOpenButtonCtrlPosition()

  --설정 버튼 추가
  local logGbox = self:GetWarehouseLogGBox()
  local openButton = AUTO_CAST(logGbox:CreateOrGetControl('button', 'WarehouseManagerOpenButton', 0, 0, 33, 33))

  openButton:SetEventScript(ui.LBUTTONUP, 'WAREHOUSEMANAGER_OPEN')
  openButton:SetImage('inven_setup_btn')
  openButton:SetOverSound('button_over')
  openButton:SetClickSound('button_click_big')
  openButton:SetGravity(ui.RIGHT, ui.TOP)
  openButton:SetMargin(0, 5, 10, 0)
  openButton:EnableHitTest(1)
  openButton:ShowWindow(1)

  return openButton
end


--팀 창고에 설정 버튼 공간 확보
function WarehouseManager.AdjustOpenButtonCtrlPosition(self)
  local silverGbox = self:GetWarehouseSilverGbox()
  silverGbox:Resize(400 - 28, 35)

  local silverCtrl = self:GetWarehouseSilverCtrl()
  silverCtrl:Resize(300 - 28, 26)

  local depositButtonCtrl = self:GetWarehouseDepositButtonCtrl()
  depositButtonCtrl:SetMargin(0, 0, 110 + 43, 0)

  local withdrawButtonCtrl = self:GetWarehouseWithdrawButtonCtrl()
  withdrawButtonCtrl:SetMargin(0, 0, 10 + 43, 0)
end


--UI 오브젝트 반환
function WarehouseManager.GetWarehouseLogGBox(self)
  return AUTO_CAST(ui.GetFrame('accountwarehouse'):GetChild('logBox'))
end


function WarehouseManager.GetWarehouseSilverGbox(self)
  return AUTO_CAST(self:GetWarehouseLogGBox():GetChild('DepositSkin'))
end


function WarehouseManager.GetWarehouseSilverCtrl(self)
  return AUTO_CAST(self:GetWarehouseSilverGbox():GetChild('moneyInput'))
end


function WarehouseManager.GetWarehouseDepositButtonCtrl(self)
  return AUTO_CAST(self:GetWarehouseLogGBox():GetChild('Deposit'))
end


function WarehouseManager.GetWarehouseWithdrawButtonCtrl(self)
  return AUTO_CAST(self:GetWarehouseLogGBox():GetChild('Withdraw'))
end


function WarehouseManager.GetTopGBox(self)
  return AUTO_CAST(self.Frame:GetChild('topGbox'))
end


function WarehouseManager.GetTitleCtrl(self)
  return AUTO_CAST(self:GetTopGBox():GetChild('title'))
end


function WarehouseManager.GetCloseButtonCtrl(self)
  return AUTO_CAST(self:GetTopGBox():GetChild('closeButton'))
end


function WarehouseManager.GetDefaultTitleBackground(self)
  return AUTO_CAST(self.Frame:GetChild('defaultTitleBg'))
end


function WarehouseManager.GetDefaultTitleCtrl(self)
  return AUTO_CAST(self:GetDefaultTitleBackground():GetChild('defaultTitle'))
end


function WarehouseManager.GetDefaultGbox(self)
  return AUTO_CAST(self.Frame:GetChild('defaultGbox'))
end


function WarehouseManager.GetDepositCtrl(self)
  return AUTO_CAST(self:GetDefaultGbox():GetChild('deposit'))
end


function WarehouseManager.GetWithdrawCtrl(self)
  return AUTO_CAST(self:GetDefaultGbox():GetChild('withdraw'))
end


function WarehouseManager.GetArrangeItemsCtrl(self)
  return AUTO_CAST(self:GetDefaultGbox():GetChild('arrangeItems'))
end


function WarehouseManager.GetSilverTitleCtrl(self)
  return AUTO_CAST(self:GetDefaultGbox():GetChild('silverTitle'))
end


function WarehouseManager.GetSilverCtrl(self)
  return AUTO_CAST(self:GetDefaultGbox():GetChild('silver'))
end


function WarehouseManager.GetCommonItemTitleBackground(self)
  return AUTO_CAST(self.Frame:GetChild('commonItemTitleBg'))
end


function WarehouseManager.GetCommonItemTitleCtrl(self)
  return AUTO_CAST(self:GetCommonItemTitleBackground():GetChild('commonItemTitle'))
end


function WarehouseManager.GetCommonItemGbox(self)
  return AUTO_CAST(self.Frame:GetChild('commonItemGbox'))
end


function WarehouseManager.GetCommonSlotSetCtrl(self)
  return AUTO_CAST(self:GetCommonItemGbox():GetChild('commonSlotSet'))
end


function WarehouseManager.GetPersonalItemTitleBackground(self)
  return AUTO_CAST(self.Frame:GetChild('personalItemTitleBg'))
end


function WarehouseManager.GetPersonalItemTitleCtrl(self)
  return AUTO_CAST(self:GetPersonalItemTitleBackground():GetChild('personalItemTitle'))
end


function WarehouseManager.GetPersonalItemGbox(self)
  return AUTO_CAST(self.Frame:GetChild('personalItemGbox'))
end


function WarehouseManager.GetPersonalSlotSetCtrl(self)
  return AUTO_CAST(self:GetPersonalItemGbox():GetChild('personalSlotSet'))
end


--UI 업데이트
function WarehouseManager.UpdateFrame(self)
  self:UpdateFrameLanguage()
  self:UpdateDefaultSettings()
  self:UpdateItemList(self:GetCommonSlotSetCtrl(), self:GetCommonItemList())
  self:UpdateItemList(self:GetPersonalSlotSetCtrl(), self:GetPersonalItemList())
end


--다국어 적용
function WarehouseManager.UpdateFrameLanguage(self)
  local titleCtrl = self:GetTitleCtrl()
  local titleLang = self:GetLangText('System.Title')
  titleCtrl:SetText(titleLang)

  local closeButtonCtrl = self:GetCloseButtonCtrl()
  local closeButtonLang = self:GetLangText('System.Close')
  closeButtonCtrl:SetTextTooltip(closeButtonLang)

  local defaultTitleCtrl = self:GetDefaultTitleCtrl()
  local defaultTitleLang = self:GetLangText('System.DefaultTitle')
  defaultTitleCtrl:SetText(defaultTitleLang)

  local depositCtrl = self:GetDepositCtrl()
  local depositLang = self:GetLangText('System.Deposit')
  depositCtrl:SetText(depositLang)

  local withdrawCtrl = self:GetWithdrawCtrl()
  local withdrawLang = self:GetLangText('System.Withdraw')
  withdrawCtrl:SetText(withdrawLang)

  local arrangeItemsCtrl = self:GetArrangeItemsCtrl()
  local arrangeItemsLang = self:GetLangText('System.ArrangeItems')
  arrangeItemsCtrl:SetText(arrangeItemsLang)

  local silverTitleCtrl = self:GetSilverTitleCtrl()
  local silverTitleLang = self:GetLangText('System.Silver')
  silverTitleCtrl:SetText(silverTitleLang)

  local commonItemTitleCtrl = self:GetCommonItemTitleCtrl()
  local commonItemTitleLang = self:GetLangText('System.CommonItemTitle')
  commonItemTitleCtrl:SetText(commonItemTitleLang)

  local personalItemTitleCtrl = self:GetPersonalItemTitleCtrl()
  local personalItemTitleLang = self:GetLangText('System.PersonalItemTitle')
  personalItemTitleCtrl:SetText(personalItemTitleLang)
end


--기본 설정 업데이트
function WarehouseManager.UpdateDefaultSettings(self)
  local depositCtrl = self:GetDepositCtrl()
  depositCtrl:SetCheck(self:IsDepositEnabled() and 1 or 0)

  local withdrawCtrl = self:GetWithdrawCtrl()
  withdrawCtrl:SetCheck(self:IsWithdrawEnabled() and 1 or 0)

  local arrangeItemsCtrl = self:GetArrangeItemsCtrl()
  arrangeItemsCtrl:SetCheck(self:IsArrangeItemsEnabled() and 1 or 0)

  local silverCtrl = self:GetSilverCtrl()
  silverCtrl:SetText(GET_COMMAED_STRING(self:GetSilver()))
end


--등록된 아이템 업데이트
function WarehouseManager.UpdateItemList(self, slotSet, itemList)
  local slotCount = slotSet:GetSlotCount()

  slotSet:ClearIconAll()

  while #itemList > slotCount - 1 do
    slotSet:ExpandRow()
    slotCount = slotSet:GetSlotCount()
  end

  for i = 0, slotCount - 1 do
    local slot = slotSet:GetSlotByIndex(i)

    if i < #itemList + 1 then
      slot:ShowWindow(1)
    else
      slot:ShowWindow(0)
    end
  end

  for i = 0, #itemList - 1 do
    local slot = slotSet:GetSlotByIndex(i)
    local icon = CreateIcon(slot)
    local itemSetting = itemList[i + 1]
    local itemCls = GetClassByType('Item', itemSetting.ItemType)
    local iconImg = GET_ITEM_ICON_IMAGE(itemCls, 'Icon')

    icon:Set(iconImg, 'Item', itemSetting.ItemType)

    --아이템 툴팁 설정
    icon:SetTooltipType('wholeitem')
    icon:SetTooltipArg('inven', itemSetting.ItemType)

    --아이템 개수 설정
    if itemSetting.Count > 0 then
      SET_SLOT_COUNT_TEXT(slot, itemSetting.Count, '{s14}{ol}{b}')
    end
  end
end


--팀 창고 UI 생성 이벤트
function WAREHOUSEMANAGER_CREATE_UI()
  WarehouseManager:CreateOpenButtonCtrl()
end


--애드온 UI 열기
function WAREHOUSEMANAGER_OPEN()
  WarehouseManager:UpdateFrame()
  WarehouseManager.Frame:ShowWindow(1)
end


--애드온 UI 닫기
function WAREHOUSEMANAGER_CLOSE()
  WarehouseManager.Frame:ShowWindow(0)
end


--자동 입금 설정 이벤트
function WAREHOUSEMANAGER_TOGGLE_DEPOSIT()
  WarehouseManager:ToggleDeposit()
end


--자동 출금 설정 이벤트
function WAREHOUSEMANAGER_TOGGLE_WITHDRAW()
  WarehouseManager:ToggleWithdraw()
end


--아이템 자동 정리 설정 이벤트
function WAREHOUSEMANAGER_TOGGLE_ARRANGE_ITEMS()
  WarehouseManager:ToggleArrangeItems()
end


--캐릭터 실버 설정 이벤트
function WAREHOUSEMANAGER_CHANGE_SILVER()
  local silverCtrl = WarehouseManager:GetSilverCtrl()
  local silver = GET_NOT_COMMAED_NUMBER(silverCtrl:GetText())

  --100억 실버 제한
  silver = math.min(silver, 10000000000)

  local silverText = GET_COMMAED_STRING(silver)

  WarehouseManager:SetSilver(silver)
  silverCtrl:SetText(silverText)
end


--아이템 등록 이벤트
function WAREHOUSEMANAGER_DROP_COMMON_ITEM(parent, ctrl)
  local liftIcon = ui.GetLiftIcon()
  local iconInfo = liftIcon:GetInfo()
  local itemType = iconInfo.type
  local invItem = session.GetInvItemByGuid(iconInfo:GetIESID())
  local itemObj = invItem and GetIES(invItem:GetObject())

  if itemObj then
    local maxStack = TryGetProp(itemObj, 'MaxStack', 1)

    --소비 아이템은 인벤토리에 남길 개수 설정
    if maxStack > 1 then
      INPUT_NUMBER_BOX(
        WarehouseManager.Frame,
        WarehouseManager:GetLangText('Message.ConsumeItemCount'),
        'WAREHOUSEMANAGER_INSERT_COMMON_CONSUME_ITEM',
        0,
        0,
        maxStack,
        itemType)

    --이외의 아이템은 0개로 설정
    else
      WarehouseManager:InsertCommonItem(itemType, 0)
      WarehouseManager:UpdateFrame()
    end
  end
end


function WAREHOUSEMANAGER_DROP_PERSONAL_ITEM(parent, ctrl)
  local liftIcon = ui.GetLiftIcon()
  local iconInfo = liftIcon:GetInfo()
  local itemType = iconInfo.type
  local invItem = session.GetInvItemByGuid(iconInfo:GetIESID())
  local itemObj = invItem and GetIES(invItem:GetObject())

  if itemObj then
    local maxStack = TryGetProp(itemObj, 'MaxStack', 1)

    --소비 아이템은 인벤토리에 남길 개수 설정
    if maxStack > 1 then
      INPUT_NUMBER_BOX(
        WarehouseManager.Frame,
        WarehouseManager:GetLangText('Message.ConsumeItemCount'),
        'WAREHOUSEMANAGER_INSERT_PERSONAL_CONSUME_ITEM',
        0,
        0,
        maxStack,
        itemType)

    --이외의 아이템은 0개로 설정
    else
      WarehouseManager:InsertPersonalItem(itemType, 0)
      WarehouseManager:UpdateFrame()
    end
  end
end


function WAREHOUSEMANAGER_INSERT_COMMON_CONSUME_ITEM(frame, count, inputFrame)
  local itemType = inputFrame:GetValue()

  inputFrame:ShowWindow(0)
  WarehouseManager:InsertCommonItem(itemType, count)
  WarehouseManager:UpdateFrame()
end


function WAREHOUSEMANAGER_INSERT_PERSONAL_CONSUME_ITEM(frame, count, inputFrame)
  local itemType = inputFrame:GetValue()

  inputFrame:ShowWindow(0)
  WarehouseManager:InsertPersonalItem(itemType, count)
  WarehouseManager:UpdateFrame()
end


--아이템 삭제 이벤트
function WAREHOUSEMANAGER_POP_COMMON_ITEM(parent, ctrl)
  local liftIcon = ui.GetLiftIcon()
  local iconInfo = liftIcon:GetInfo()
  local itemType = iconInfo.type

  WarehouseManager:DeleteCommonItem(itemType)
  WarehouseManager:UpdateFrame()
end


function WAREHOUSEMANAGER_POP_PERSONAL_ITEM(parent, ctrl)
  local liftIcon = ui.GetLiftIcon()
  local iconInfo = liftIcon:GetInfo()
  local itemType = iconInfo.type

  WarehouseManager:DeletePersonalItem(itemType)
  WarehouseManager:UpdateFrame()
end


--캐릭터 아이템 정리
function WAREHOUSEMANAGER_START_ARRANGE_ITEMS()
  ReserveScript('WAREHOUSEMANAGER_ARRANGE_SILVER()', 0.5)
  ReserveScript('WAREHOUSEMANAGER_ARRANGE_ITEMS()', 1.0)
end


--실버 정리
function WAREHOUSEMANAGER_ARRANGE_SILVER()
  --실버 자동 출금
  if WarehouseManager:IsWithdrawEnabled() then
    local withdrawSilver = WarehouseManager:WithdrawSilver()
    if withdrawSilver > 0 then
      WarehouseManager:Log('Normal', 'Message.SilverWithdrawn', GET_COMMAED_STRING(withdrawSilver))
    end
  end

  --실버 자동 입금
  if WarehouseManager:IsDepositEnabled() then
    local depositSilver = WarehouseManager:DepositSilver()
    if depositSilver > 0 then
      WarehouseManager:Log('Normal', 'Message.SilverDeposited', GET_COMMAED_STRING(depositSilver))
    end
  end
end


function WAREHOUSEMANAGER_ARRANGE_ITEMS()
  if WarehouseManager:IsArrangeItemsEnabled() then
    local depositItemList, withdrawItemList = WarehouseManager:GetArrangeItemList()

    --아이템 저장
    WarehouseManager:SetDepositItemList(depositItemList)
    WarehouseManager:SetWithdrawItemList(withdrawItemList)

    --아이템 정리
    WAREHOUSEMANAGER_ON_ARRANGE_ITEM()
  end
end


function WAREHOUSEMANAGER_ON_ARRANGE_ITEM()
  --인벤토리 아이템 넣기
  local retMsg, depositItem = WarehouseManager:DepositItems()

  --팀 창고가 닫혀 있는 경우
  if retMsg == WarehouseManager.RET_WAREHOUSE_CLOSED then
    WarehouseManager:Log('Normal', 'Message.WarehouseClosed')
    return

  --아이템을 넣었을 경우
  elseif retMsg == WarehouseManager.RET_KEEP_DEPOSIT then
    local itemCls = GetClassByType('Item', depositItem.ItemType)
    local iconImg = GET_ITEM_ICON_IMAGE(itemCls, 'Icon')
    WarehouseManager:Log('Normal', 'Message.ItemDeposited', iconImg, itemCls.Name, GET_COMMAED_STRING(depositItem.Count))
    return

  --아이템을 모두 넣었을 경우
  elseif retMsg == WarehouseManager.RET_SUCCESS then
    local withdrawItemList = WarehouseManager:GetWithdrawItemList()

    --팀 창고 아이템 꺼내기
    WarehouseManager:WithdrawItems()

    for _, withdrawItem in ipairs(withdrawItemList) do
      local itemCls = GetClassByType('Item', withdrawItem.ItemType)
      local iconImg = GET_ITEM_ICON_IMAGE(itemCls, 'Icon')
      WarehouseManager:Log('Normal', 'Message.ItemWithdrawn', iconImg, itemCls.Name, GET_COMMAED_STRING(withdrawItem.Count))
    end
  end
end


--애드온 초기화 이벤트
function WAREHOUSEMANAGER_ON_INIT(addon, frame)
  WarehouseManager.Addon = addon
  WarehouseManager.Frame = frame

  --설정 파일 처리
  if not WarehouseManager.Loaded then
    WarehouseManager:LoadSettings()
    WarehouseManager:SaveSettings()
    WarehouseManager.Loaded = true
  end

  --개인 설정 파일 처리
  WarehouseManager:LoadCharSettings()
  WarehouseManager:SaveCharSettings()

  --이벤트 등록
  addon:RegisterMsg('OPEN_DLG_ACCOUNTWAREHOUSE', 'WAREHOUSEMANAGER_CREATE_UI')
  addon:RegisterMsg('OPEN_DLG_ACCOUNTWAREHOUSE', 'WAREHOUSEMANAGER_START_ARRANGE_ITEMS')
  addon:RegisterMsg('ACCOUNT_WAREHOUSE_ITEM_IN', 'WAREHOUSEMANAGER_ON_ARRANGE_ITEM')
  --ACUtil.setupEvent(addon, 'ACCOUNTWAREHOUSE_CLOSE', 'WAREHOUSEMANAGER_CLOSE')
end
