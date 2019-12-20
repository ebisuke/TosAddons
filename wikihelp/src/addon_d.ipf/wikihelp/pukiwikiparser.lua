

local P={}
local function till_br(def,str)
    --return str:sub(1,str:find("\r\n"))
    return str
end
local function till_parentasis(def,str)
    return str:sub(1,str:find(");"))
end
local function till_same(def,str)
    return str:sub(1,str:find(def.begin[1]))
end
function string.split(str, ts)
    -- 引数がないときは空tableを返す
    if ts == nil then return {} end
  
    local t = {} ; 
    i=1
    for s in string.gmatch(str, "([^"..ts.."]+)") do
      t[i] = s
      i = i + 1
    end
  
    return t
  end
function string.starts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end
function P.findancestor(node,name)
    while node.parent do
        
        if(node.name==name)then
            return node
        end
        node=node.parent
    end
    return nil
end

local tags={
    {
        name="text",
        isdiv=true,
    },
    {
        name="font",
        begin={"&color","&size"},
        till_fn=till_parentasis,
        attrib_fn=function(def,begin,str)

        end,
    },
    {
        name="br",
        begin={"&br;"},
        attrib_fn=function(def,begin,str)
        end,
    },
    {
        name="header",
        begin={"*"},
        isdiv=true,
        till_fn=till_br,
    },
    {
        name="hl",
        begin={"----","#BR"},
        till_fn=till_br,
    },
    {
        name="image",
        begin={"&attachref"},
        till_fn=till_parentasis,
        attrib_fn=function(def,begin,str)

        end,
    },
    {
        name="comment",
        begin={"#","//"},
        till_fn=till_br,
    },
    {
        name="td",
        begin={"|"},
        isdiv=true,
        till_fn=till_same,
        generate="table",
        attrib_fn=function(def,begin,str)
        end,
    },
    {
        name="table",
        isdiv=true,
        hold_fn=function (def,str)
            return str:find("|")
        end,
    },
    {
        name="li",
        begin={"-","--","---"},
        isdiv=true,
        till_fn=till_br,
        attrib_fn=function(def,begin,str)
        end,
    },
    {
        name="ln",
        begin={"+"},
        isdiv=true,
        till_fn=till_br,
        attrib_fn=function(def,begin,str)

        end,
    },
    {
        name="a",
        begin={"[["},
        till_fn=function(def,str)
            return str:sub(3,str:find("]]")-1)
        end,
        isdiv=true,
        attrib_fn=function(def,str)

        end,
    },
    {
        name="quote",
        begin={">"},
        till_fn=till_br,
        isdiv=true,
    },
    {
        name="title",
        begin={"TITLE:"},
        till_fn=till_br,
    },

}
function P.findtag(name)
    for _,v in ipairs(tags) do
        if(v.name==name)then
            return v
        end
    end
    return nil
end
function P.parse(current,str,context)
    current=current or {}
    context=context or {}
    local spr
    if(current.tag)then
        if(current.tag.till_fn)then
            spr={current.tag.till_fn(current.tag,str)}
        else
            spr={str}
        end
    else
        spr=str:split("\r\n")
    end
    local dominant=false
    local count=0
    for _,s in ipairs(spr) do
        
        for _,tag in ipairs(tags) do
            if(tag.begin)then
                for _,b in ipairs(tag.begin) do
                    if(s:starts(b))then
                        --make tag
                        local tillfn=tag.till_fn or function(def,str) return str end
                        local cursor=current
                        if(tag.generate)then
                            if(not P.findancestor(cursor,tag.generate))then
                                local gtag=P.findtag(tag.generate)
                                cursor.child=cursor.child or {}
                                cursor.child[#cursor.child+1]={
                                    tag=gtag,
                                    name=gtag.name,
                                    content=tillfn(tag,s):sub(#b+1),
                                    parent=cursor
                                }
                                local alter=cursor.child[#cursor.child]
                                context.wrapbase=current
                                context.hold=gtag
                                current=alter
                                cursor=alter
                            end
                        end
                        cursor.child=cursor.child or {}
                        cursor.child[#cursor.child+1]={
                            tag=tag,
                            name=tag.name,
                            content=tillfn(tag,s):sub(#b+1),
                            parent=cursor
                        }
                        local child=cursor.child[#cursor.child];
                        if(tag.isdiv)then
                            P.parse(child,child.content,context)
                            if(context.leave)then
                                current=context.wrapbase
                                context.wrapbase=nil
                                context.leave=nil
                                context.hold=nil
                            end
                        end
                        if(tag.attrib_fn)then
                            child.attrib=tag:attrib_fn(b,str) or {}
                        end
                        dominant=true
                        break
                    end
                end
            end
        end
        if(not dominant)then
            local tag=tags[1]
            current.child=current.child or {}
            current.child[#current.child+1]={
                tag=tag,
                name=tag.name,
                content=s,
                parent=current
            }
        end
        --必ずbrを生成
        local tag=tags[3]
        current.child=current.child or {}
        current.child[#current.child+1]={
            tag=tag,
            name=tag.name,
            parent=current
        }
        if context.hold then
            if context.hold:hold_fn(s) then
                --pass
            else
                --leave
                current=context.wrapbase
                context.leave=true
                return current
            end
        end
        count=count+#s
    end
    return current
end

--EOF
WIKIHELP_PUKIWIKI_PARSER=P

tester=P.parse({},
[==[TITLE:ソードマン
>&attachref(クラス/ソードマン/0.png,nolink,60%,ソードマン);
千年以上の長きにわたり、ソードマンは王国軍の基本兵科であり、新たな冒険者に選ばれています。
多くの戦士がソードマンから始め、経験を積むことで王国の歴史に名を刻んでいます。
その長きにわたり行われてきた武器と戦術により、魔法の発展に劣らずソードマンの威容を誇ります。
ソードマン系統は全ての系統の中で最も高いHPと防御力を持ち、敵陣では安定して戦うことができます。
&attachref(Class/ソードマン/swordsman_m0.gif,nolink,ソードマン);　&attachref(Class/ソードマン/swordsman_f0.gif,nolink,ソードマン);

#include(ReBuild/ソードマン,notitle)
----
#contents

*概要 [#g9493590]
ソードマン系列の一番下地となる攻撃型クラス。
-マスターの場所
--ソードマンマスター　[[クラベダ>Map/街/クラペダ]]
--ソードマンサブマスター　[[オルシャ>Map/街/オルシャ]]
~

・ステータス成長比率
|~力|~体力|~知能|~精神|~敏捷|
|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|C
|37.5%|37.5%|0%|0%|25%|
#BR
・ダッシュ性能（ソードマン系共通）
　ダッシュ中に攻撃を受けても中断されない
　騎乗状態でダッシュ可能
*クラス特性 [#nee121bf]
|~条件|~特性|~MaxLv|~効果|~特性費用&br;(0→Max)|
|CENTER:|LEFT:|CENTER:|LEFT:|CENTER:|C
|~ |プロヴォック|10|敵を攻撃する時に得るヘイト値が特性レベル1につき150%アップ|825P|
|~Lv100|片手剣マスタリ:&br;戦闘準備|1|[盾]と一緒に[片手剣]装備時、&br;武器の攻撃力の20%を物理防御力に転換&br;[盾]ではない補助武器と[片手剣]装備時、攻撃速度アップ|30P|

-ktos
--5/23 プロボ効果上昇
*スキル一覧 [#g994d8a0]
&size(4){アイコンにカーソルを合わせるとスキル名が表示されます。&br;クリックすればそのスキル欄まで飛びます。&br;黄枠はOHスキルです。};
|~クラスLv|>|>|>|>|>|~スキル|
|CENTER:|CENTER:50|CENTER:50|CENTER:50|CENTER:50|CENTER:50|CENTER:50|c
|~1-15|BGCOLOR(#ffff00):[[&attachref(Class/ソードマン/icon_warri_thrust.png,50%,スラスト);>#w8f88c04]]|BGCOLOR(#ffff00):[[&attachref(Class/ソードマン/icon_warri_bash.png,50%,バッシュ);>#d30c1985]]|[[&attachref(Class/ソードマン/icon_warri_gungho.png,50%,デアデビル);>#ye187d50]]|[[&attachref(./icon_warri_bear.png,50%,ベアー);>#qc461afc]]|[[&attachref(Class/ソードマン/icon_warri_painbarrier.png,50%,ペインバリア);>#y7a97c7a]]|[[&attachref(./icon_warri_liberate.png,50%,リベレート);>#mff1829d]]|

-ktos
--6/13 新スキル『リバーレート』追加
*クラスLv1－15 [#ff6c7d6c]
**&attachref(Class/ソードマン/icon_warri_thrust.png,nolink,50%,スラスト);&sizex(5){''スラスト''}; [#w8f88c04]
>&color(Red){''物理－突属性&br;搭乗互換''};
敵を武器の先で強く突き後ろに押し出します。
#youtube(OTyGyBryamw,300,200)

+スキル性能
|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|c
|~クラスLv|~Lv|~スキル係数|~基本消費SP|~CD|~備考|
|~1-15|~1|277%|52|10秒|OH5回&br;AOE+10|
|~|~2|286%|~|~|~|
|~|~3|295%|~|~|~|
|~|~4|304%|~|~|~|
|~|~5|313%|~|~|~|
+スキル特性
|~条件|~特性|~MaxLv|~効果|~影響|~T|
|CENTER:|CENTER:|CENTER:|LEFT:|CENTER:|CENTER:|c
|~SLv1|強化|100|[スラスト]のスキル係数が特性レベル1につき0.5%アップ&br;最高レベルになるとさらに10%アップ|-|P|
+スキル使用感
-武器を突き出して攻撃する。
-射程は武器から出るエフェクトの先まで、幅は左右1キャラ程度。
-完全硬直は突き出す直前まで。
-スキルの打撃タイミングが約2倍速くなった。
-ktos
--6/13 モーション短縮？
**&attachref(Class/ソードマン/icon_warri_bash.png,nolink,50%,バッシュ);&sizex(5){''バッシュ''}; [#d30c1985]
>&color(Red){''物理－斬属性&br;搭乗互換''};
強い攻撃で敵にダメージを与えます。
#youtube(pxZKt7udSpU,300,200)

+スキル性能
|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|c
|~クラスLv|~Lv|~スキル係数|~基本消費SP|~CD|~備考|
|~1-15|~1|197%|54|10秒|OH5回&br;AOE+10|
|~|~2|203%|~|~|~|
|~|~3|210%|~|~|~|
|~|~4|216%|~|~|~|
|~|~5|223%|~|~|~|
+スキル特性
|~条件|~特性|~MaxLv|~効果|~影響|~T|
|CENTER:|CENTER:|CENTER:|LEFT:|CENTER:|CENTER:|C
|~SLv1|強化|100|[バッシュ]のスキル係数が特性レベル1につき0.5%アップ&br;最高レベルになるとさらに10%アップ|-|P|
|~SLv3|ノックダウン|1|[バッシュ]を受けた敵をノックダウン|SP+30%|A|
+スキル使用感
-射程はエフェクトの先まで、幅は左右2キャラ程度。
-硬直は振り下ろすまで。
-スキルの打撃タイミングが約2倍速くなった。
-ktos
--6/13 モーション短縮？
**&attachref(Class/ソードマン/icon_warri_gungho.png,nolink,50%,デアデビル);&sizex(5){''デアデビル''}; [#ye187d50]
>&color(Red){''搭乗互換''};
覚悟を決めて一時的に自分の物理攻撃のダメージをアップさせます。
#youtube(MxXA9Gj8u6Y,300,200)

+スキル性能
|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|c
|~クラスLv|~Lv|~物理攻撃力増加|~持続時間|~基本消費SP|~CD|~備考|
|~1-15|~1|2%|30分|186|60秒||
|~|~2|4%|~|~|~|~|
|~|~3|6%|~|~|~|~|
|~|~4|8%|~|~|~|~|
|~|~5|10%|~|~|~|~|
+スキル特性
|~条件|~特性|~MaxLv|~効果|~影響|~T|
|CENTER:|LEFT:|CENTER:|LEFT:|CENTER:|CENTER:|C
|~SLv1|強化|100|特性レベル1につき[デアデビル]の物理攻撃ダメージ増加効果が0.5%増加&br;最高レベルになるとさらに10%アップ|-|P|
+スキル使用感
-デメリットのない火力増加バフ。
-%%ベアーを使うと自動で解除される。%%
-%%辛いときは無理せずベアーに切り替えよう。%%
--ベアーと同時併用可能に。
**&attachref(./icon_warri_bear.png,nolink,50%,ベアー);&sizex(5){''ベアー''}; [#qc461afc]
>&color(Red){''搭乗互換''};
覚悟を決めて一時的に自分が受ける物理攻撃のダメージをダウンさせます。
#youtube(2IkOJ1jC-Hk,300,200)

+スキル性能
|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|c
|~クラスLv|~Lv|~受けるダメージダウン|~持続時間|~基本消費SP|~CD|~備考|
|~1-15|~1|2%|30分|186|60秒||
|~|~2|4%|~|~|~|~|
|~|~3|6%|~|~|~|~|
|~|~4|8%|~|~|~|~|
|~|~5|10%|~|~|~|~|
+スキル特性
|~条件|~特性|~MaxLv|~効果|~影響|~T|
|CENTER:|CENTER:|CENTER:|LEFT:|CENTER:|CENTER:|C
|~SLv1|強化|100|特性レベル1につき[ベアー]の物理ダメージ減少効果が0.5%増加&br;最高レベルになるとさらに10%アップ|-|P|
+スキル使用感
-デメリットのない物理被ダメ減少バフ。
-デアデビルを使うと自動で解除される。
-ktos
--6/13 効果変更、デアデビルと併用可？
**&attachref(Class/ソードマン/icon_warri_painbarrier.png,nolink,50%,ペインバリア);&sizex(5){''ペインバリア''}; [#y7a97c7a]
>&color(Red){''ALL　搭乗互換''};
一定時間体が硬直せず、押されたり倒れなくなります。
使用直後に一時的にすべての状態異常にかからなくなり、ペインバリアの持続時間中は状態異常に対する効果抵抗の確率がアップします。
#youtube(Y0kFl7qXLb8,300,200)

+スキル性能
|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|c
|~クラスLv|~Lv|~持続時間|~状態異常免疫時間|~基本消費SP|~CD|~備考|
|~1-15|~1|10秒|3秒|147|30秒|状態異常に対する効果抵抗確率上昇|
|~|~2|15秒|~|~|~|~|
|~|~3|20秒|~|~|~|~|
|~|~4|25秒|~|~|~|~|
|~|~5|30秒|~|~|~|~|
//+スキル特性
//|~条件|~特性|~MaxLv|~効果|~影響|~T|
//|CENTER:|CENTER:|CENTER:|LEFT:|CENTER:|CENTER:|C
//|~スキルレベル|名前|数値|説明|-|P|
+スキル使用感
-ノックバック・ノックダウン耐性バフだが、被ダメージ時の硬直は防げない模様。（バグ？）
-pvpでは持続時間が半減する。
**&attachref(./icon_warri_liberate.png,nolink,50%,リベレート);&sizex(5){''リベレート''}; [#mff1829d]
>&color(Red){''搭乗互換''};
一時的に力を開放して周辺の敵の目に付くようになります。
バフ持続時間中は自分の攻撃でモンスターに適用されるヘイト値がアップします。
#youtube(ZgBwpQR8D2g,300,200)

+スキル性能
|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|c
|~クラスLv|~Lv|~持続時間|~基本消費SP|~CD|~備考|
|~1-15|~1|30秒|180|60秒|ヘイト値500%アップ|
+スキル特性
|~条件|~特性|~MaxLv|~効果|~影響|~T|
|CENTER:|CENTER:|CENTER:|LEFT:|CENTER:|CENTER:|C
|~SLv1|リベレート:覚醒|1|[リベレート]の持続時間が6秒に減る代わり、敵に与えるダメージが50％アップします。|-|A|
|~SLv1|リベレート:忍耐|1|[リベレート]の持続時間が6秒に減る代わり、敵から受けるダメージが50％減少します。|-|A|
+スキル使用感
-

//*スキル増強装備 [#g8e981ae]
//|~装備Lv|~種別|~装備名|~スキル関連効果|~入手方法|
//|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|C
//|～|～|～|～|～|
*コメント [#zc95958f]
''&color(red){19/2/27以前のコメントはRe:build以前のコメントとなります。日時に注意して閲覧してください。};''
//[[過去ログ>Class/ソードマン/コメント]]
#zcomment(t=tosWIKIBBS%2F4&h=200&size=10&style=wikiwiki)
]==]
)
