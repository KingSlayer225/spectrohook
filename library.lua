-- Lua | library.lua | Spectrohook UI library
local Library={Version="2.0.0"}
function Library.CreateWindow(options,colonOptions)
    if options==Library then options=colonOptions end
    options=options or {}
    options.Compatibility=type(options.Build)~='function'
    if options.Compatibility then
        options.Build=function() end
        options.SettingsPage=options.SettingsPage or 'UI Settings'
        options.Pages=options.Pages or {'Main',options.SettingsPage}
    end
    options.Name=options.Name or options.Title
    assert(type(options)=="table" and type(options.Build)=="function","CreateWindow requires a Build function")
    if options.Pages==nil then options.Pages={"Combat","Misc","Visuals","Settings"} end
    do
        local unique,settings={},false
        assert(type(options.Pages)=="table" and #options.Pages>0,"Pages must be a nonempty array")
        for _,name in ipairs(options.Pages) do
            assert(type(name)=="string" and name~="" and not unique[name],"Page names must be unique strings")
            unique[name]=true;if name==(options.SettingsPage or "Settings") then settings=true end
        end
        if not settings then options.Pages[#options.Pages+1]=options.SettingsPage or "Settings" end
    end
    local Players=game:GetService("Players")
    local UIS=game:GetService("UserInputService")
    local TweenService=game:GetService("TweenService")
    local ReplicatedStorage=game:GetService("ReplicatedStorage")
    local player=Players.LocalPlayer
    local playerGui=player:WaitForChild("PlayerGui")
    for _,name in ipairs({"SpectrohookGui","SpectrohookWeatherGui","LucidityGui","LucidityWeatherGui","SableGui"}) do
        local previous=playerGui:FindFirstChild(name)
        if previous then previous:Destroy() end
    end

    local function rgb(r,g,b) return Color3.fromRGB(r,g,b) end
    local uiFont=Enum.Font.ArialBold
    local scriptName=type(options.Name)=="string" and options.Name or "Spectrohook"
    local themePresets={
        White={colors={Accent=rgb(242,242,242),Background=rgb(22,22,22),Section=rgb(33,33,33),Header=rgb(23,23,23),Sidebar=rgb(22,22,22),Navigation=rgb(31,31,31),Inline=rgb(20,20,20),Outline=rgb(66,66,66),Text=rgb(234,234,234),Unselected=rgb(148,148,148),LowContrast=rgb(40,40,40)},
            style={PanelRadius=7,DropdownRadius=9,PopupRadius=10,InputRadius=7,ItemRadius=7,MenuRadius=8,GradientBottom=.95,BackdropBottom=.94,BorderAlpha=.64,BorderAccent=.12,BorderWidth=1,GlowStrength=.085,SheenTransparency=.82}},
        Mint={colors={Accent=rgb(143,209,185),Background=rgb(18,24,23),Section=rgb(26,36,33),Header=rgb(18,26,24),Sidebar=rgb(17,25,23),Navigation=rgb(24,34,31),Inline=rgb(15,23,21),Outline=rgb(48,72,64),Text=rgb(222,239,232),Unselected=rgb(124,153,142),LowContrast=rgb(31,44,39)},
            style={PanelRadius=8,DropdownRadius=10,PopupRadius=11,InputRadius=8,ItemRadius=8,MenuRadius=9,GradientBottom=.93,BackdropBottom=.93,BorderAlpha=.66,BorderAccent=.14,BorderWidth=1,GlowStrength=.075,SheenTransparency=.86}},
        Default={colors={Accent=rgb(148,189,229),Background=rgb(18,23,29),Section=rgb(27,34,43),Header=rgb(20,26,33),Sidebar=rgb(17,22,29),Navigation=rgb(25,32,42),Inline=rgb(15,20,28),Outline=rgb(52,67,86),Text=rgb(225,235,247),Unselected=rgb(128,146,167),LowContrast=rgb(31,41,54)},
            style={PanelRadius=7,DropdownRadius=9,PopupRadius=10,InputRadius=7,ItemRadius=7,MenuRadius=8,GradientBottom=.94,BackdropBottom=.92,BorderAlpha=.62,BorderAccent=.14,BorderWidth=1,GlowStrength=.08,SheenTransparency=.83}},
        Amethyst={colors={Accent=rgb(180,154,222),Background=rgb(22,20,28),Section=rgb(33,29,43),Header=rgb(23,20,31),Sidebar=rgb(20,18,27),Navigation=rgb(31,27,40),Inline=rgb(19,17,26),Outline=rgb(68,59,88),Text=rgb(235,229,246),Unselected=rgb(150,140,169),LowContrast=rgb(39,33,51)},
            style={PanelRadius=8,DropdownRadius=10,PopupRadius=11,InputRadius=8,ItemRadius=8,MenuRadius=9,GradientBottom=.90,BackdropBottom=.89,BorderAlpha=.63,BorderAccent=.16,BorderWidth=1,GlowStrength=.10,SheenTransparency=.78}},
        Rose={colors={Accent=rgb(225,161,183),Background=rgb(26,21,25),Section=rgb(39,31,37),Header=rgb(29,23,28),Sidebar=rgb(23,19,23),Navigation=rgb(36,28,34),Inline=rgb(21,17,21),Outline=rgb(84,64,76),Text=rgb(246,231,237),Unselected=rgb(167,141,152),LowContrast=rgb(47,35,43)},
            style={PanelRadius=9,DropdownRadius=10,PopupRadius=12,InputRadius=8,ItemRadius=8,MenuRadius=10,GradientBottom=.93,BackdropBottom=.94,BorderAlpha=.67,BorderAccent=.13,BorderWidth=1,GlowStrength=.07,SheenTransparency=.86}},
        Yellow={colors={Accent=rgb(234,200,105),Background=rgb(25,23,18),Section=rgb(37,34,25),Header=rgb(27,25,19),Sidebar=rgb(22,21,17),Navigation=rgb(34,31,24),Inline=rgb(20,19,15),Outline=rgb(78,72,48),Text=rgb(244,239,222),Unselected=rgb(161,153,125),LowContrast=rgb(45,40,28)},
            style={PanelRadius=6,DropdownRadius=8,PopupRadius=9,InputRadius=6,ItemRadius=6,MenuRadius=7,GradientBottom=.97,BackdropBottom=.96,BorderAlpha=.62,BorderAccent=.12,BorderWidth=1.05,GlowStrength=.06,SheenTransparency=.88}},
        Graphite={colors={Accent=rgb(152,159,168),Background=rgb(20,21,24),Section=rgb(29,31,35),Header=rgb(22,23,27),Sidebar=rgb(18,20,23),Navigation=rgb(27,29,33),Inline=rgb(17,19,23),Outline=rgb(63,67,75),Text=rgb(223,226,233),Unselected=rgb(139,145,156),LowContrast=rgb(34,37,44)},
            style={PanelRadius=5,DropdownRadius=7,PopupRadius=8,InputRadius=5,ItemRadius=5,MenuRadius=6,GradientBottom=.99,BackdropBottom=.99,BorderAlpha=.58,BorderAccent=.06,BorderWidth=1,GlowStrength=.04,SheenTransparency=.92}},
    }
    local theme,themeStyle={},{}
    for key,value in pairs(themePresets.White.colors) do theme[key]=value end
    for key,value in pairs(themePresets.White.style) do themeStyle[key]=value end
    local alive, connections, themeBindings, controls, values = true, {}, setmetatable({},{__mode="k"}), {}, {}
    local bridge={data={},events={},active={}}
    function bridge.same(a,b)
        if a==b then return true end
        if type(a)~='table' or type(b)~='table' or getmetatable(a) or getmetatable(b) then return false end
        for key,value in pairs(a) do if not bridge.same(value,b[key]) then return false end end
        for key in pairs(b) do if a[key]==nil then return false end end
        return true
    end
    values=setmetatable({}, {
        __index=bridge.data,
        __newindex=function(_,id,value)
            local changed=not bridge.same(bridge.data[id],value)
            bridge.data[id]=value
            if changed then
                for _,fn in ipairs(bridge.events[id] or {}) do
                    local ok,err=pcall(fn,value)
                    if not ok then warn('Spectrohook observer: '..tostring(err)) end
                end
            end
        end,
        __pairs=function() return next,bridge.data,nil end,
    })
    local restoringConfig=false
    local appearanceRefreshers={}
    local function refreshAppearance()
        for _,refresh in ipairs(appearanceRefreshers) do refresh() end
    end
    function appearanceRefreshers.watch(owner,refresh)
        local function run() if owner.Parent then refresh() end end
        appearanceRefreshers[#appearanceRefreshers+1]=run
        owner.Destroying:Once(function()
            for i=#appearanceRefreshers,1,-1 do if appearanceRefreshers[i]==run then table.remove(appearanceRefreshers,i);break end end
        end)
    end
    local windowOrder, popup, capture, activeDrag = 20, nil, nil, nil
    local presentation
    local function connect(signal,fn)
        local c=signal:Connect(fn); connections[#connections+1]=c; return c
    end
    local function connectOwned(owner,signal,fn)
        local c=signal:Connect(fn)
        owner.Destroying:Once(function() c:Disconnect() end)
        return c
    end
    local function new(class,props,parent)
        local obj=Instance.new(class)
        for key,value in pairs(props or {}) do obj[key]=value end
        obj.Parent=parent
        return obj
    end
    local motionReady=false
    local motion={Hover=.12,Control=.16,Tab=.09,Section=.22,SectionOpen=.20,PageOut=.07,Page=.14,Popup=.14,Window=.18,Drag=.07}
    local tweenSlots=setmetatable({},{__mode="k"})
    local tweenOwners=setmetatable({},{__mode="k"})
    local runningTweens={}
    local function stopTween(record)
        if not record or not runningTweens[record] then return end
        runningTweens[record]=nil
        if record.connection then record.connection:Disconnect() end
        local slots=tweenSlots[record.object]
        if slots then for property in pairs(record.goals) do if slots[property]==record then slots[property]=nil end end end
        record.tween:Cancel()
    end
    local function cancelMotion(object)
        local slots=tweenSlots[object]
        if slots then
            local records={};for _,record in pairs(slots) do records[record]=true end
            for record in pairs(records) do stopTween(record) end
            tweenSlots[object]=nil
        end
    end
    local function animate(object,goals,duration,finished,easing,direction)
        if not alive or not object.Parent then return end
        duration=motionReady and (duration or motion.Control) or 0
        local slots=tweenSlots[object] or {};tweenSlots[object]=slots
        local changed,pending=false,false
        for property,value in pairs(goals) do
            local record=slots[property]
            if record and record.goals[property]==value then pending=true
            elseif record or object[property]~=value then changed=true end
        end
        if duration>0 and not changed then
            if finished and pending then

                local waiting,remaining,aborted={},0,false
                for property in pairs(goals) do
                    local record=slots[property]
                    if record and not waiting[record] then waiting[record]=true;remaining=remaining+1 end
                end
                for record in pairs(waiting) do
                    local connection
                    connection=record.tween.Completed:Connect(function(state)
                        connection:Disconnect();remaining=remaining-1
                        if state~=Enum.PlaybackState.Completed then aborted=true end
                        if remaining==0 and not aborted and alive and object.Parent then finished() end
                    end)
                end
            elseif not pending and finished then finished() end
            return
        end

        local previous={}
        for property in pairs(goals) do if slots[property] then previous[slots[property]]=true end end
        for record in pairs(previous) do stopTween(record) end
        if duration<=0 then
            for property,value in pairs(goals) do object[property]=value end
            if finished then finished() end
            return
        end
        if not tweenOwners[object] then
            tweenOwners[object]=true
            object.Destroying:Once(function() cancelMotion(object) end)
        end
        local record={object=object,goals=goals}
        record.tween=TweenService:Create(object,TweenInfo.new(duration,easing or Enum.EasingStyle.Quad,direction or Enum.EasingDirection.Out),goals)
        runningTweens[record]=true
        for property in pairs(goals) do slots[property]=record end
        record.connection=record.tween.Completed:Connect(function(state)
            runningTweens[record]=nil
            for property in pairs(goals) do if slots[property]==record then slots[property]=nil end end
            record.connection:Disconnect()
            if alive and object.Parent and state==Enum.PlaybackState.Completed and finished then finished() end
        end)
        record.tween:Play()
    end
    local function caption(object,value)
        if object.Text==value then return end
        object.Text=value
        if motionReady then
            animate(object,{TextTransparency=.35},0);animate(object,{TextTransparency=0},motion.Hover)
        end
    end
    local function themeColor(key)
        if key=='Text' then return theme.Text:Lerp(Color3.new(),.05) end
        if key=='Unselected' then return theme.Unselected:Lerp(Color3.new(),.06) end
        if key=='IdleText' then return theme.Text:Lerp(theme.Unselected,.10):Lerp(Color3.new(),.02) end
        if key=='SelectedText' then return theme.Text:Lerp(theme.Accent,.12):Lerp(Color3.new(1,1,1),.32) end
        if key=='SelectedAccent' or key=='ToggleOn' then return theme.Accent:Lerp(Color3.new(1,1,1),.06) end
        if key=='ToggleOff' or key=='ThumbOff' then
            local color=key=='ToggleOff' and theme.Inline or theme.Unselected
            local value=(color.R*.2126+color.G*.7152+color.B*.0722)*.78
            return Color3.new(value,value,value)
        end
        if key=='ThumbBorder' then
            local c=theme.Outline;local v=c.R*.2126+c.G*.7152+c.B*.0722
            return Color3.new(v,v,v)
        end
        if key=='ToggleBorderOn' then return theme.Accent:Lerp(theme.Inline,.45) end
        if key=='ToggleBorderOff' then
            local a,b=theme.Outline,theme.Inline
            local v=(a.R*.2126+a.G*.7152+a.B*.0722)*.4+(b.R*.2126+b.G*.7152+b.B*.0722)*.6
            return Color3.new(v,v,v)
        end
        if key=='NavHoverSurface' then return themeColor('NavSurface'):Lerp(themeColor('EffectAccent'),.07) end
        if key=='ThumbOn' then return theme.Inline:Lerp(theme.Accent,.08):Lerp(Color3.new(),.60) end
        if key=='SectionIdle' then return themeColor('PanelSurface'):Lerp(Color3.new(),.16) end
        if key=='SectionSelected' then return themeColor('PanelSurface'):Lerp(Color3.new(1,1,1),.012) end
        if key=="EffectAccent" then return theme.Accent:Lerp(Color3.new(),.78) end
        if key=='SheenAccent' then return theme.Accent:Lerp(Color3.new(),.56) end
        if key=="WeatherTint" then return rgb(220,231,245):Lerp(theme.Accent,.08) end
        if key=="PanelSurface" then return theme.Section:Lerp(Color3.new(),.36):Lerp(theme.Accent,.003):Lerp(Color3.new(1,1,1),.012) end
        if key=="NavigationSurface" then return themeColor("Backdrop") end
        if key=="TitleSurface" then return theme.Sidebar:Lerp(Color3.new(),.22):Lerp(theme.Accent,.004):Lerp(Color3.new(1,1,1),.012) end
        if key=="HeaderSurface" then return themeColor('TitleSurface') end
        if key=="SearchSurface" then return themeColor('TitleSurface'):Lerp(Color3.new(),.12) end
        if key=="MainSurface" then return theme.Background:Lerp(Color3.new(),.10):Lerp(theme.Accent,.003):Lerp(Color3.new(1,1,1),.012) end
        if key=="NavSurface" then return themeColor('PanelSurface'):Lerp(Color3.new(),.27) end
        if key=="SelectedSurface" then return themeColor('PanelSurface'):Lerp(themeColor('EffectAccent'),.08):Lerp(Color3.new(1,1,1),.01) end
        if key=="Backdrop" then return theme.Background:Lerp(Color3.new(),.45):Lerp(theme.Accent,.003):Lerp(Color3.new(1,1,1),.012) end
        if key=="SelectedBorder" then return theme.Outline:Lerp(theme.Accent,.32) end
        if key=="DropdownSurface" then return theme.Inline:Lerp(theme.Section,.06):Lerp(Color3.new(),.10):Lerp(Color3.new(1,1,1),.012) end
        if key=="PopupSurface" then return theme.Background:Lerp(theme.Section,.08):Lerp(Color3.new(),.14):Lerp(Color3.new(1,1,1),.012) end
        if key=="DropdownSelection" then return themeColor('PopupSurface'):Lerp(theme.Accent,.055) end
        if key=="DropdownHover" then return themeColor('PopupSurface'):Lerp(theme.Accent,.022) end
        if key=='Background' or key=='Section' or key=='Header' or key=='Sidebar' or key=='Navigation' or key=='Inline' or key=='LowContrast' then
            return theme[key]:Lerp(Color3.new(1,1,1),.012)
        end
        return theme[key]
    end
    local function bind(obj,property,key,duration)
        if duration then animate(obj,{[property]=themeColor(key)},duration) else obj[property]=themeColor(key) end
        themeBindings[obj]=themeBindings[obj] or {}
        themeBindings[obj][property]=key
    end
    local function applyTheme(live)
        local cache={}
        for obj,properties in pairs(themeBindings) do
            if obj.Parent and not (live and obj:IsA('UIStroke') and obj.Enabled==false) then
                local goals={}
                for property,key in pairs(properties) do
                    local color=cache[key]
                    if not color then color=themeColor(key);cache[key]=color end
                    local pending=tweenSlots[obj] and tweenSlots[obj][property]
                    if obj[property]~=color or pending and pending.goals[property]~=color then goals[property]=color end
                end
                if next(goals) then animate(obj,goals,live and 0 or motion.Control) end
            end
        end
        if not live then refreshAppearance() end
    end
    local themeUpdates={states={},restoreKeys={},shown=true}
    do
        local connection,dirty,needsCommit,elapsed=nil,false,false,0
        local disposed=false
        local function running()
            for _,state in pairs(themeUpdates.states) do if state.enabled and (themeUpdates.shown or not state.themeKey) then return true end end
            return false
        end
        local function stop()
            if connection then connection:Disconnect();connection=nil end
        end
        function themeUpdates.flush(commit)
            if disposed then return end
            if dirty then
                dirty=false
                applyTheme(true)
                if themeUpdates.onSync then themeUpdates.onSync(true) end
                local gui=themeUpdates.gui
                if gui and gui.Parent then gui:SetAttribute('ThemeUpdatePasses',(gui:GetAttribute('ThemeUpdatePasses') or 0)+1) end
            end
            if commit and needsCommit and not restoringConfig then
                needsCommit=false
                if themeUpdates.onCommit then themeUpdates.onCommit() end
            end
            if not running() and not dirty then stop() end
        end
        local function start()
            if connection or disposed or not (running() or dirty and themeUpdates.shown) then return end
            elapsed=0
            connection=game:GetService('RunService').Heartbeat:Connect(function(dt)
                elapsed=elapsed+math.max(0,dt)
                if elapsed<1/30 then return end
                local step=elapsed;elapsed=0
                for _,state in pairs(themeUpdates.states) do
                    if state.enabled and (themeUpdates.shown or not state.themeKey) then
                        state.hue=(state.hue+step*state.speed/12)%1
                        local color=Color3.fromHSV(state.hue,state.sat,state.val)
                        if state.themeKey then
                            theme[state.themeKey]=color;dirty=true;needsCommit=true
                        elseif state.applyColor then state.applyColor(color) end
                    end
                end
                themeUpdates.flush(false)
            end)
        end
        function themeUpdates.add(key,id)
            local state={key=key or id,themeKey=key,id=id,enabled=false,speed=1}
            themeUpdates.states[state.key]=state
            themeUpdates.restoreKeys[id..'Rainbow']=true
            themeUpdates.restoreKeys[id..'RainbowSpeed']=true
            return state
        end
        function themeUpdates.enable(state,enabled,quiet)
            enabled=enabled==true
            if state.enabled==enabled then return end
            state.enabled=enabled;values[state.id..'Rainbow']=enabled
            if enabled then
                local color=state.getColor and state.getColor() or theme[state.themeKey]
                state.hue,state.sat,state.val=color:ToHSV()
                state.sat=math.max(state.sat,state.themeKey and state.themeKey~='Accent' and .12 or .55)
                if state.themeKey then
                    dirty=true;needsCommit=true
                    if not restoringConfig and themeUpdates.onCustom then themeUpdates.onCustom() end
                end
                start()
            else
                if not quiet then themeUpdates.flush(true) end
                if not running() and not dirty then stop() end
            end
            if state.ui and state.ui.owner.Parent then state.ui.paint() end
        end
        function themeUpdates.speed(state,value)
            value=tonumber(value)
            if not value or value~=value or value==math.huge or value==-math.huge then value=state.speed end
            state.speed=math.clamp(math.floor(value*10+.5)/10,.1,3)
            values[state.id..'RainbowSpeed']=state.speed
            if state.ui and state.ui.owner.Parent then state.ui.paint() end
        end
        function themeUpdates.edit(key,color)
            if disposed then return end
            local state=themeUpdates.states[key]
            if state and state.enabled then themeUpdates.enable(state,false,true) end
            if theme[key]==color then return end
            theme[key]=color
            if restoringConfig then return end
            dirty=true;needsCommit=true
            if themeUpdates.onCustom then themeUpdates.onCustom() end
            if themeUpdates.shown then start() else themeUpdates.flush(true) end
        end
        function themeUpdates.reset(themeOnly)
            for _,state in pairs(themeUpdates.states) do
                if not themeOnly or state.themeKey then themeUpdates.enable(state,false,true) end
            end
            dirty=false;needsCommit=false
            if not running() then stop() end
        end
        function themeUpdates.restore(data)
            for _,state in pairs(themeUpdates.states) do
                controls[state.id..'RainbowSpeed'].set(data[state.id..'RainbowSpeed'] or 1,true)
                controls[state.id..'Rainbow'].set(data[state.id..'Rainbow']==true,true)
            end
        end
        function themeUpdates.setVisible(shown)
            shown=shown==true and not (themeUpdates.gui and themeUpdates.gui.Enabled==false)
            themeUpdates.shown=shown
            if not shown then
                themeUpdates.flush(true);stop()
                if running() then start() end
            else
                for _,state in pairs(themeUpdates.states) do
                    if state.enabled and not state.themeKey and state.applyColor then state.applyColor(state.getColor()) end
                end
                if dirty or running() then start() end
            end
        end
        function themeUpdates.destroy()
            disposed=true;stop()
            themeUpdates.onSync=nil;themeUpdates.onCommit=nil;themeUpdates.onCustom=nil
            for _,state in pairs(themeUpdates.states) do state.ui=nil end
        end
    end

    local function round(obj,r) new("UICorner",{CornerRadius=UDim.new(0,r or 2)},obj) end
    local surfaceStyles=setmetatable({},{__mode='k'})
    local selectedBorder
    do
        local targets=setmetatable({},{__mode='k'})
        local pointer
        local ok,position=pcall(function() return UIS:GetMouseLocation() end)
        if ok then pointer=position end
        local function scaleOf(object)
            local scale,node=1,object
            while node do
                for _,child in ipairs(node:GetChildren()) do
                    if child:IsA('UIScale') then scale=scale*child.Scale end
                end
                node=node.Parent
            end
            return math.max(.001,scale)
        end
        local function layout(object,data)
            local scale=scaleOf(object)
            local width,height=object.AbsoluteSize.X/scale,object.AbsoluteSize.Y/scale
            local corner=object:FindFirstChildOfClass('UICorner')
            local radius=corner and math.min(width,height)*corner.CornerRadius.Scale+corner.CornerRadius.Offset or 2
            if data.width==width and data.height==height and data.radius==radius and data.scale==scale then return end
            for _,part in ipairs(data.parts) do part.object:Destroy() end
            data.parts={};data.width=width;data.height=height;data.radius=radius;data.scale=scale
            if width<3/scale or height<3/scale then return end
            local inset=1.05/scale
            local left,top,right,bottom=inset,inset,width-inset,height-inset
            local r=math.clamp(radius-inset,0,math.min(right-left,bottom-top)/2)
            local points={}
            local function point(p)
                local previous=points[#points]
                if previous then
                    local delta=p-previous
                    local steps=math.max(1,math.ceil(delta.Magnitude*scale/1.3))
                    for i=1,steps do points[#points+1]=previous+delta*(i/steps) end
                else points[1]=p end
            end
            for _,arc in ipairs({{right-r,top+r,-math.pi/2},{right-r,bottom-r,0},{left+r,bottom-r,math.pi/2},{left+r,top+r,math.pi}}) do
                local steps=math.max(4,math.ceil(r*scale*math.pi/2/1.3))
                for i=0,steps do
                    local angle=arc[3]+i/steps*math.pi/2
                    point(Vector2.new(arc[1]+math.cos(angle)*r,arc[2]+math.sin(angle)*r))
                end
            end
            point(points[1])
            for i=2,#points do
                local a,b=points[i-1],points[i]
                local delta=b-a
                if delta.Magnitude>.001 then
                    local center=(a+b)/2
                    local part=new('Frame',{Name='BorderSegment',AnchorPoint=Vector2.new(.5,.5),
                        Position=UDim2.fromOffset(center.X,center.Y),Size=UDim2.fromOffset(delta.Magnitude+.45/scale,1/scale),
                        Rotation=math.deg(math.atan2(delta.Y,delta.X)),BackgroundTransparency=1,BorderSizePixel=0,
                        Active=false,Selectable=false,ZIndex=30},data.root)
                    round(part,1/scale);bind(part,'BackgroundColor3','SelectedBorder')
                    data.parts[#data.parts+1]={object=part,point=center}
                end
            end
        end
        local function paint(object,data)
            if not object.Parent then return end
            data.root.Visible=object:GetAttribute('BorderSelected')==true and object:GetAttribute('NoBackplateBorder')~=true
            if not data.root.Visible then return end
            layout(object,data)
            local nearest,farthest=math.huge,0
            if pointer then
                for _,part in ipairs(data.parts) do
                    local distance=(object.AbsolutePosition+part.point*data.scale-pointer).Magnitude
                    part.distance=distance;nearest=math.min(nearest,distance);farthest=math.max(farthest,distance)
                end
            end
            local proximity=pointer and math.clamp(1-nearest/160,0,1) or 0
            local span=math.max(.001,(farthest-nearest)*.84)
            for _,part in ipairs(data.parts) do
                local near=pointer and math.clamp(1-(part.distance-nearest)/span,0,1) or 0
                near=near*near*(3-2*near)
                local alpha=.46*near^1.5*proximity
                local thickness=.65+1.15*near*proximity
                local size=part.object.Size
                part.object.Size=UDim2.fromOffset(size.X.Offset,thickness/data.scale)
                part.object.BackgroundTransparency=1-alpha
            end
        end
        selectedBorder=function(object,selected)
            local stroke=object:FindFirstChild('ControlBorder')
            if not stroke then
                stroke=new('UIStroke',{Name='ControlBorder',Enabled=false,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
                    LineJoinMode=Enum.LineJoinMode.Round,Thickness=1,Transparency=1},object)
                bind(stroke,'Color','SelectedBorder')
            end
            stroke.Enabled=false
            object:SetAttribute('BorderSelected',selected==true)
            local data=targets[object]
            if selected and not object:GetAttribute('NoBackplateBorder') and not data then
                local root=new('Frame',{Name='ProximityBorder',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
                    BorderSizePixel=0,Active=false,Selectable=false,ZIndex=30},object)
                data={root=root,parts={}};targets[object]=data
                connectOwned(root,object:GetPropertyChangedSignal('AbsolutePosition'),function() paint(object,data) end)
                connectOwned(root,object:GetPropertyChangedSignal('AbsoluteSize'),function() paint(object,data) end)
            end
            if data then paint(object,data) end
            return stroke
        end
        connect(UIS.InputChanged,function(input)
            if input.UserInputType==Enum.UserInputType.MouseMovement then
                pointer=Vector2.new(input.Position.X,input.Position.Y)
                for object,data in pairs(targets) do paint(object,data) end
            end
        end)
        connect(UIS.WindowFocusReleased,function()
            pointer=nil
            for object,data in pairs(targets) do paint(object,data) end
        end)
        appearanceRefreshers[#appearanceRefreshers+1]=function()
            for object,data in pairs(targets) do paint(object,data) end
        end
    end

    local function applySurfaceStyle(object,kind)
        if not object.Parent then return end
        local radiusKey=kind=='Dropdown' and 'DropdownRadius' or kind=='Popup' and 'PopupRadius'
            or kind=='Option' and 'ItemRadius' or kind=='Input' and 'InputRadius'
            or (kind=='Window' or kind=='Backdrop') and 'MenuRadius' or 'PanelRadius'
        local radius=themeStyle[radiusKey]
        local corner=object:FindFirstChildOfClass('UICorner')
        if not corner then round(object,radius) else corner.CornerRadius=UDim.new(0,radius) end
        local gradient=object:FindFirstChild('SurfaceGradient') or object:FindFirstChild('TabFade') or object:FindFirstChild('SelectionFade')
        if gradient then
            local bottom=kind=='Backdrop' and themeStyle.BackdropBottom or themeStyle.GradientBottom
            gradient.Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),
                ColorSequenceKeypoint.new(.55,Color3.new((1+bottom)/2,(1+bottom)/2,(1+bottom)/2)),
                ColorSequenceKeypoint.new(1,Color3.new(bottom,bottom,bottom)),
            })
        end
        if kind~='Window' and kind~='Backdrop' then
            selectedBorder(object,kind=='Selected' or object:GetAttribute('BorderSelected')==true)
        end
        local shade=object:FindFirstChild('FunctionShade')
        if shade then shade:FindFirstChildOfClass('UICorner').CornerRadius=UDim.new(0,radius) end
        local sheen=object:FindFirstChild('SelectionSheen')
        if sheen then
            sheen:FindFirstChildOfClass('UICorner').CornerRadius=UDim.new(0,themeStyle.PanelRadius)
            local opacity=(1-math.clamp(themeStyle.SheenTransparency-.06,.5,.9))*(sheen:GetAttribute('Strength') or 1)
            animate(sheen,{BackgroundTransparency=1-opacity},motion.Control)
        end
    end
    local function styleSurface(object,kind)
        surfaceStyles[object]=kind
        object:SetAttribute('SurfaceKind',kind)
        applySurfaceStyle(object,kind)
        return object
    end
    appearanceRefreshers[#appearanceRefreshers+1]=function()
        for object,kind in pairs(surfaceStyles) do applySurfaceStyle(object,kind) end
    end
    local function frame(parent,pos,size,key)
        local f=new("Frame",{Position=pos,Size=size,BorderSizePixel=0},parent)
        if key then bind(f,"BackgroundColor3",key) else f.BackgroundTransparency=1 end
        return f
    end
    local function group(parent,pos,size,key)
        local obj=new("CanvasGroup",{Position=pos,Size=size,BorderSizePixel=0,GroupTransparency=0},parent)
        if key then bind(obj,"BackgroundColor3",key) else obj.BackgroundTransparency=1 end
        return obj
    end
    local function softGlow(parent,name,strength,plain)
        local glow=(plain and frame or group)(parent,UDim2.new(),UDim2.fromScale(1,1))
        glow.Name=name;glow.Active=false;glow.Selectable=false;glow.ClipsDescendants=true
        round(glow,999)

        local layers=16
        local opacity=1-(1-themeStyle.GlowStrength*(name=='SelectionGlow' and 1 or .58))^(1/layers)
        for layer=0,layers-1 do
            local diameter=1-layer/layers
            local disk=frame(glow,UDim2.fromScale(.5,.5),UDim2.fromScale(diameter,diameter),"EffectAccent")
            disk.Name="GlowDisk";disk.AnchorPoint=Vector2.new(.5,.5)
            disk.BackgroundTransparency=1-opacity;disk.Active=false;disk.Selectable=false
            new("UICorner",{CornerRadius=UDim.new(1,0)},disk)
        end
        appearanceRefreshers[#appearanceRefreshers+1]=function()
            if not glow.Parent then return end
            local alpha=1-(1-themeStyle.GlowStrength*(name=='SelectionGlow' and 1 or .58))^(1/layers)
            for _,disk in ipairs(glow:GetChildren()) do
                if disk.Name=='GlowDisk' then animate(disk,{BackgroundTransparency=1-alpha},motion.Control) end
            end
        end
        return glow
    end
    local function tabGlow(plate,selected)
        local glow=softGlow(plate,selected and "SelectionGlow" or "TabHoverGlow",selected and .12 or .07)
        glow.Size=UDim2.new(1,-6,0,20);glow.Position=UDim2.fromScale(.5,.5)
        glow.AnchorPoint=Vector2.new(.5,.5);glow.GroupTransparency=1
    end
    local sheenEffects={shown=false,items={},reach=.6}
    do
        local function eligible(object,state)
            if not sheenEffects.shown or not state.requested or values.GlowEffects==false or not object.Parent then return false end
            local node=object
            while node do
                if node:IsA('GuiObject') and not node.Visible or node:IsA('ScreenGui') and node.Enabled==false then return false end
                node=node.Parent
            end
            return true
        end
        local function sync(object,state)
            local wanted=eligible(object,state)
            state.node.Visible=wanted
            if state.running==wanted then return end
            state.running=wanted;state.revision=state.revision+1
            local revision=state.revision
            cancelMotion(state.gradient)
            if not wanted then return end
            local function pass()
                if not alive or not state.running or revision~=state.revision then return end
                if not eligible(object,state) then sync(object,state);return end
                
                local current=state.gradient.Offset.X
                if math.abs(current-state.target)<.0001 then state.target=-state.target end
                local duration=3.4*math.abs(state.target-current)/(sheenEffects.reach*2)
                animate(state.gradient,{Offset=Vector2.new(state.target,0)},duration,pass,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
            end
            pass()
        end
        function sheenEffects.add(object,requested,strength)
            local sheen=frame(object,UDim2.new(),UDim2.fromScale(1,1),'SheenAccent')
            sheen.Name='SelectionSheen';sheen.ZIndex=0;sheen.Active=false;sheen.Selectable=false;sheen.Visible=false
            strength=math.clamp(tonumber(strength) or 1,0,1);sheen:SetAttribute('Strength',strength)
            sheen.BackgroundTransparency=1-(1-math.clamp(themeStyle.SheenTransparency-.06,.5,.9))*strength;round(sheen,themeStyle.PanelRadius)
            local gradient=new('UIGradient',{Name='Shimmer',Rotation=40,Offset=Vector2.new(-sheenEffects.reach,0),Transparency=NumberSequence.new({
                NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.04,1),
                NumberSequenceKeypoint.new(.26,.55),NumberSequenceKeypoint.new(.50,.18),
                NumberSequenceKeypoint.new(.74,.55),NumberSequenceKeypoint.new(.96,1),NumberSequenceKeypoint.new(1,1),
            })},sheen)
            local state={node=sheen,gradient=gradient,requested=requested==true,running=false,revision=0,target=sheenEffects.reach}
            sheenEffects.items[object]=state
            object.Destroying:Once(function()
                state.running=false;state.revision=state.revision+1
                cancelMotion(gradient);sheenEffects.items[object]=nil
            end)
            sync(object,state)
        end
        function sheenEffects.set(object,requested)
            local state=sheenEffects.items[object]
            if state then state.requested=requested==true;sync(object,state) end
        end
        function sheenEffects.refresh()
            for object,state in pairs(sheenEffects.items) do sync(object,state) end
        end
        function sheenEffects.setVisible(shown)
            sheenEffects.shown=shown==true;sheenEffects.refresh()
        end
    end
    local function navigationPlate(parent,pos,size,name,selected)
        local plate=frame(parent,pos,size,selected and "SelectedSurface" or "NavSurface")
        plate.Name=name;plate.ZIndex=selected and 2 or 1;plate.ClipsDescendants=true;round(plate,6)
        plate.BackgroundTransparency=0
        new("UIGradient",{Name=selected and "SelectionFade" or "TabFade",Rotation=90,Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(.55,Color3.new(.97,.97,.97)),
            ColorSequenceKeypoint.new(1,Color3.new(.94,.94,.94)),
        })},plate)
        tabGlow(plate,selected)
        if selected then sheenEffects.add(plate,true) end
        styleSurface(plate,selected and 'Selected' or 'Panel')
        return plate
    end
    local selectionRevisions=setmetatable({},{__mode="k"})
    local function moveSelection(plate,control,onArrival)
        local position=control.Position+UDim2.fromOffset(.5,0)
        local size=UDim2.fromOffset(control.Size.X.Offset-1,20)
        local moving=motionReady and (plate.Position~=position or plate.Size~=size)
        local revision=(selectionRevisions[plate] or 0)+1
        selectionRevisions[plate]=revision;plate:SetAttribute("Moving",moving)
        animate(plate,{BackgroundColor3=themeColor('SelectedSurface')},0)
        animate(plate,{
            Position=position,
            Size=size,
        },motion.Tab,moving and function()
            if selectionRevisions[plate]~=revision then return end
            plate:SetAttribute("Moving",false)
            if onArrival then onArrival() end
        end or nil)
        return moving
    end
    local function surfaceGradient(obj,bottom)
        bottom=bottom or .97
        if not obj:FindFirstChild("SurfaceGradient") then
            new("UIGradient",{Name="SurfaceGradient",Rotation=90,Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),
                ColorSequenceKeypoint.new(.55,Color3.new((1+bottom)/2,(1+bottom)/2,(1+bottom)/2)),
                ColorSequenceKeypoint.new(1,Color3.new(bottom,bottom,bottom)),
            })},obj)
        end
    end
    local function controlBackplate(obj)
        selectedBorder(obj,obj:GetAttribute('BorderSelected')==true)
    end
    local function text(parent,caption,pos,size,fontSize,key)
        local label=new("TextLabel",{
            BackgroundTransparency=1,Position=pos,Size=size,Text=caption,
            Font=uiFont,TextSize=fontSize or 8,TextXAlignment=Enum.TextXAlignment.Left,
            TextYAlignment=Enum.TextYAlignment.Center,BorderSizePixel=0,
        },parent)
        bind(label,"TextColor3",key or "Text")
        return label
    end
    local function button(parent,caption,pos,size,key)
        local b=new("TextButton",{
            Position=pos,Size=size,Text=caption,Font=uiFont,TextSize=8,
            BorderSizePixel=0,AutoButtonColor=false,
        },parent)
        bind(b,"BackgroundColor3",key or "Inline"); bind(b,"TextColor3","Unselected")
        round(b,2)
        controlBackplate(b)
        connectOwned(b,b.MouseEnter,function()
            if b.Active and not b:GetAttribute("NoHover") then animate(b,{BackgroundColor3=themeColor("LowContrast")},motion.Hover) end
        end)
        connectOwned(b,b.MouseLeave,function()
            if not b:GetAttribute("NoHover") then animate(b,{BackgroundColor3=themeColor(key or "Inline")},motion.Hover) end
        end)
        return b
    end
    local function switchControl(parent,pos,initial,changed,disabled)
        local function neutral(color)
            local brightness=color.R*.2126+color.G*.7152+color.B*.0722
            return Color3.new(brightness,brightness,brightness)
        end
        local trackWidth,trackHeight,thumbSize=19,11,7
        local padding=(trackHeight-thumbSize)/2
        local track=button(parent,"",pos,UDim2.fromOffset(trackWidth,trackHeight),"Inline")
        track.Name="Toggle";track:SetAttribute("NoHover",true);track.Active=not disabled
        track:FindFirstChildOfClass("UICorner").CornerRadius=UDim.new(1,0)
        track.ControlBorder.Thickness=.5;track.ControlBorder.Transparency=.75
        new("UIGradient",{Rotation=90,Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1,Color3.new(.66,.66,.66)),
        })},track)
        local thumb=frame(track,UDim2.new(0,padding+thumbSize/2,.5,0),UDim2.fromOffset(thumbSize,thumbSize))
        thumb.AnchorPoint=Vector2.new(.5,.5)
        thumb.Name="Thumb";thumb.BackgroundTransparency=disabled and .35 or 0
        thumb.Active=false;round(thumb,thumbSize)
        new("UIGradient",{Rotation=90,Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1,Color3.new(.75,.75,.75)),
        })},thumb)
        local edge=new("UIStroke",{Thickness=.5,Transparency=.55},thumb)
        edge.Color=neutral(theme.Outline)
        bind(thumb,'BackgroundColor3',initial and 'ThumbOn' or 'ThumbOff')
        local enabled=false
        local function render(state)
            enabled=state==true;track:SetAttribute("Enabled",enabled)
            track:SetAttribute("BorderSelected",enabled and not disabled);track.ControlBorder.Enabled=enabled and not disabled
            track.BackgroundTransparency=disabled and .65 or 0
            bind(track,'BackgroundColor3',enabled and 'ToggleOn' or 'ToggleOff',motion.Control)
            bind(thumb,'BackgroundColor3',enabled and 'ThumbOn' or 'ThumbOff',motion.Control)
            animate(thumb,{
                Position=UDim2.new(0,enabled and trackWidth-padding-thumbSize/2 or padding+thumbSize/2,.5,0),
            },motion.Control)
            bind(edge,'Color','ThumbBorder',motion.Control)
            bind(track.ControlBorder,'Color',enabled and 'ToggleBorderOn' or 'ToggleBorderOff',motion.Control)
            animate(track.ControlBorder,{Thickness=.5,Transparency=enabled and .75 or 1},motion.Control)
        end
        if not disabled then
            connectOwned(track,track.Activated,function() if changed then changed(not enabled) end end)
        end
        appearanceRefreshers.watch(track,function() render(enabled) end)
        render(initial)
        return track,render
    end

    local gui=new("ScreenGui",{
        Name="SpectrohookGui",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=25,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    },playerGui)
    gui.ScreenInsets=Enum.ScreenInsets.None
    gui:SetAttribute('ClientBuild',142)
    themeUpdates.gui=gui;gui:SetAttribute('ThemeUpdatePasses',0)
    local canvas=frame(gui,UDim2.fromScale(.5,.5),UDim2.fromOffset(1280,720))
    canvas.AnchorPoint=Vector2.new(.5,.5)
    canvas.ClipsDescendants=false
    local uiScale=new("UIScale",{Scale=1},canvas)
    local viewportConnection
    local fitWindows
    local fitNotifications
    local fitPresentation
    local function resizeCanvas()
        local camera=workspace.CurrentCamera
        if camera then uiScale.Scale=math.min(camera.ViewportSize.X/1280,camera.ViewportSize.Y/720) end
        if fitWindows then fitWindows() end
        if fitNotifications then fitNotifications(false) end
        if fitPresentation then fitPresentation() end
    end
    resizeCanvas()
    local function watchCamera()
        if viewportConnection then viewportConnection:Disconnect() end
        if workspace.CurrentCamera then viewportConnection=connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"),resizeCanvas) end
        resizeCanvas()
    end
    connect(workspace:GetPropertyChangedSignal("CurrentCamera"),watchCamera)
    watchCamera()

    local windows={}
    local function viewportBounds()
        local camera=workspace.CurrentCamera
        local viewport=camera and camera.ViewportSize or gui.AbsoluteSize
        local scale=math.max(uiScale.Scale,.001)

        local left=(1280-viewport.X/scale)*.5
        local top=(720-viewport.Y/scale)*.5
        return left,top,left+viewport.X/scale,top+viewport.Y/scale
    end
    local function windowPosition(win,x,y,targetWidth,targetHeight)
        local left,top,right,bottom=viewportBounds()
        local width=targetWidth or win.Size.X.Offset
        local height=targetHeight or win.Size.Y.Offset
        return UDim2.fromOffset(
            math.clamp(x,left,math.max(left,right-width)),
            math.clamp(y,top,math.max(top,bottom-height))
        )
    end
    local function settleWindowSize(win)
        local record=tweenSlots[win] and tweenSlots[win].Size
        if record and record.goals.Size then animate(win,{Size=record.goals.Size},0) end
    end
    fitWindows=function()
        if activeDrag and activeDrag.kind=="window" then activeDrag=nil end
        for _,win in ipairs(windows) do
            if win.Parent then
                settleWindowSize(win)
                animate(win,{Position=windowPosition(win,win.Position.X.Offset,win.Position.Y.Offset)},0)
            end
        end
    end

    local TAB_ICONS={}
    function TAB_ICONS.raster(paths,width,height)
        local pixels,edges={},{}
        for i=1,width*height do pixels[i]=0 end
        for _,path in ipairs(paths) do
            local count=#path
            for i=1,count,2 do
                local j=i+2;if j>count then j=1 end
                local x0,y0=path[i]*width,path[i+1]*height
                local x1,y1=path[j]*width,path[j+1]*height
                if y0~=y1 then edges[#edges+1]={x0,y0,x1,y1} end
            end
        end

        local samples=8
        for y=0,height-1 do for sample=0,samples-1 do
            local scan=y+(sample+.5)/samples
            local hits={}
            for _,edge in ipairs(edges) do
                local y0,y1=edge[2],edge[4]
                if (y0<=scan and y1>scan) or (y1<=scan and y0>scan) then
                    hits[#hits+1]=edge[1]+(scan-y0)*(edge[3]-edge[1])/(y1-y0)
                end
            end
            table.sort(hits)
            for i=1,#hits-1,2 do
                local left,right=math.clamp(hits[i],0,width),math.clamp(hits[i+1],0,width)
                for x=math.floor(left),math.ceil(right)-1 do
                    local ink=math.max(0,math.min(right,x+1)-math.max(left,x))/samples
                    local index=y*width+x+1
                    pixels[index]=pixels[index]+ink
                end
            end
        end end
        return pixels
    end
    function TAB_ICONS.curves(paths,side)
        local contours={}
        local steps=math.max(12,math.ceil(math.sqrt(side)*3))
        for _,path in ipairs(paths) do
            local polygon={path.start[1],path.start[2]}
            local x0,y0=path.start[1],path.start[2]
            for _,curve in ipairs(path.curves) do
                for i=1,steps do
                    local t=i/steps;local u=1-t
                    polygon[#polygon+1]=u^3*x0+3*u*u*t*curve[1]+3*u*t*t*curve[3]+t^3*curve[5]
                    polygon[#polygon+1]=u^3*y0+3*u*u*t*curve[2]+3*u*t*t*curve[4]+t^3*curve[6]
                end
                x0,y0=curve[5],curve[6]
            end
            contours[#contours+1]=polygon
        end
        return contours
    end

    do local icons={
        Combat={source="icons8-crossed-swords-96.png",paths={
            {
                0.05263,0.24342, 0.05263,0.03289, 0.05921,0.02632, 0.28289,0.02647, 0.49342,0.25339, 0.50658,0.25317,
                0.71711,0.02653, 0.94079,0.02632, 0.94737,0.03289, 0.94716,0.25658, 0.70697,0.48026, 0.71066,0.49342,
                0.78289,0.57372, 0.79605,0.57744, 0.83553,0.53805, 0.84868,0.53805, 0.90936,0.59868, 0.90932,0.61184,
                0.81721,0.70395, 0.81726,0.71711, 0.91447,0.81394, 0.95127,0.82237, 0.98549,0.84868, 0.99815,0.875,
                0.99965,0.90132, 0.98547,0.94079, 0.96711,0.95915, 0.94079,0.97179, 0.90132,0.97179, 0.875,0.95911,
                0.84868,0.92452, 0.84034,0.88816, 0.74342,0.7909, 0.73026,0.7909, 0.63816,0.883, 0.625,0.883,
                0.56437,0.82237, 0.56459,0.80921, 0.60376,0.76974, 0.60037,0.75658, 0.06396,0.26974, 0.05282,0.25658,
            },
            {
                0.00032,0.90132, 0.00177,0.875, 0.01974,0.84283, 0.05921,0.8176, 0.08553,0.81414, 0.18301,0.71711,
                0.18701,0.70395, 0.1144,0.625, 0.11515,0.61184, 0.17763,0.54969, 0.21711,0.57137, 0.23026,0.56532,
                0.41453,0.73026, 0.41631,0.74342, 0.39704,0.76974, 0.41831,0.79605, 0.34868,0.86563, 0.26974,0.78878,
                0.25658,0.7909, 0.15966,0.88816, 0.15591,0.91447, 0.1432,0.94079, 0.125,0.95901, 0.09868,0.97175,
                0.05921,0.97183, 0.03289,0.95915, 0.01451,0.94079,
            },
        }},
        Misc={source="icons8-compass-90.png",paths={
            {
                0.00017,0.50694, 0.00306,0.4375, 0.0303,0.32639, 0.07087,0.24306, 0.11806,0.17849, 0.20139,0.09892,
                0.27083,0.05574, 0.36806,0.01684, 0.45139,0.00149, 0.54861,0.00149, 0.63194,0.01689, 0.71528,0.04856,
                0.79861,0.09873, 0.88194,0.17831, 0.92924,0.24306, 0.96949,0.32639, 0.99839,0.45139, 0.99839,0.54861,
                0.98288,0.63194, 0.95786,0.70139, 0.90111,0.79861, 0.83672,0.86806, 0.75694,0.92913, 0.67361,0.96949,
                0.54861,0.99839, 0.45139,0.99839, 0.36806,0.98294, 0.27083,0.94417, 0.21528,0.91148, 0.17852,0.88194,
                0.09877,0.79861, 0.04223,0.70139, 0.01689,0.63194, 0.00306,0.5625,
            },
            {
                0.2208,0.77083, 0.22917,0.77916, 0.24306,0.77372, 0.57639,0.58628, 0.59577,0.5625, 0.77911,0.22917,
                0.77083,0.22089, 0.75694,0.22685, 0.42361,0.41414, 0.40419,0.4375,
            },
            {
                0.45909,0.49306, 0.47917,0.46431, 0.50694,0.45912, 0.53559,0.47917, 0.54084,0.50694, 0.52083,0.53559,
                0.49306,0.54088, 0.46441,0.52083,
            },
        }},
        Visuals={source="icons8-eye-64.png",paths={
            {
                0.00364,0.49038, 0.02259,0.43269, 0.06081,0.375, 0.125,0.30909, 0.20192,0.25104, 0.25962,0.21706,
                0.35577,0.17841, 0.45192,0.15918, 0.50962,0.15707, 0.625,0.17412, 0.68269,0.19281, 0.77885,0.23918,
                0.85577,0.292, 0.93898,0.375, 0.97727,0.43269, 0.99614,0.50962, 0.97713,0.56731, 0.93873,0.625,
                0.85577,0.708, 0.79808,0.74876, 0.74038,0.78246, 0.64423,0.82112, 0.54808,0.84073, 0.49038,0.84286,
                0.375,0.82578, 0.31731,0.80715, 0.25962,0.78266, 0.16346,0.72152, 0.06095,0.625, 0.02266,0.56731,
            },
            {
                0.31119,0.49038, 0.32581,0.56731, 0.35577,0.61827, 0.41346,0.66737, 0.49038,0.68867, 0.56731,0.67409,
                0.61823,0.64423, 0.66707,0.58654, 0.6886,0.50962, 0.67414,0.43269, 0.64423,0.38177, 0.58654,0.33254,
                0.50962,0.31133, 0.47115,0.31331, 0.41346,0.33235, 0.38166,0.35577, 0.33235,0.41346,
            },
            {
                0.43403,0.49038, 0.45368,0.45192, 0.47115,0.4403, 0.50962,0.43428, 0.54808,0.45394, 0.56572,0.49038,
                0.56559,0.50962, 0.54593,0.54808, 0.52885,0.55955, 0.49038,0.56572, 0.45192,0.54606, 0.44034,0.52885,
            },
        }},
        Settings={source="icons8-settings-120.png",paths={
            {
                0.00026,0.50481, 0.00232,0.48558, 0.01442,0.4709, 0.02404,0.46386, 0.0625,0.45677, 0.07526,0.44712,
                0.08392,0.42788, 0.08738,0.39904, 0.08499,0.37981, 0.03958,0.34135, 0.03618,0.32212, 0.04046,0.30288,
                0.05288,0.29043, 0.0625,0.28772, 0.08173,0.28682, 0.11058,0.29241, 0.12981,0.28749, 0.14309,0.27404,
                0.16065,0.24519, 0.16217,0.22596, 0.13747,0.1875, 0.13546,0.17788, 0.13804,0.15865, 0.1444,0.14904,
                0.15865,0.13798, 0.17788,0.13546, 0.1875,0.13747, 0.21756,0.15865, 0.23558,0.16251, 0.27404,0.14309,
                0.28749,0.12981, 0.29247,0.11058, 0.28606,0.07212, 0.29087,0.05288, 0.30288,0.04046, 0.3125,0.03754,
                0.34135,0.03961, 0.37981,0.08503, 0.39904,0.08733, 0.42788,0.08401, 0.45037,0.07212, 0.46072,0.05288,
                0.46386,0.02404, 0.47596,0.00936, 0.49519,0.00026, 0.51442,0.00224, 0.52908,0.01442, 0.53606,0.02404,
                0.54301,0.0625, 0.55288,0.07529, 0.57212,0.08396, 0.60096,0.0873, 0.62019,0.08493, 0.65865,0.03955,
                0.67788,0.03618, 0.69712,0.04054, 0.7095,0.05288, 0.71228,0.0625, 0.71312,0.08173, 0.70733,0.11058,
                0.71243,0.12981, 0.72596,0.14312, 0.75481,0.16075, 0.77404,0.16214, 0.8125,0.13738, 0.82212,0.13538,
                0.84135,0.13798, 0.85096,0.14437, 0.86202,0.15865, 0.86454,0.17788, 0.86248,0.1875, 0.84135,0.21698,
                0.83738,0.23558, 0.85685,0.27404, 0.87019,0.28751, 0.88942,0.29235, 0.92788,0.2861, 0.94712,0.29095,
                0.95946,0.30288, 0.96243,0.3125, 0.9606,0.34135, 0.91494,0.37981, 0.91257,0.39904, 0.91599,0.42788,
                0.92467,0.44712, 0.9375,0.45692, 0.97596,0.46378, 0.98558,0.47064, 0.9976,0.48558, 0.99972,0.49519,
                0.99768,0.51442, 0.98558,0.5293, 0.97596,0.53614, 0.9375,0.54294, 0.92467,0.55288, 0.91613,0.57212,
                0.91262,0.60096, 0.91507,0.62019, 0.9608,0.65865, 0.96386,0.67788, 0.95942,0.69712, 0.94712,0.70938,
                0.9375,0.71223, 0.91827,0.71308, 0.88942,0.7072, 0.87019,0.71241, 0.85691,0.72596, 0.83925,0.75481,
                0.83783,0.77404, 0.86258,0.8125, 0.86457,0.82212, 0.86196,0.84135, 0.8556,0.85096, 0.84135,0.86196,
                0.82212,0.86454, 0.8125,0.86248, 0.78289,0.84135, 0.76442,0.83738, 0.72596,0.85685, 0.71243,0.87019,
                0.70746,0.88942, 0.71386,0.92788, 0.7095,0.94712, 0.69712,0.95942, 0.6875,0.96243, 0.65865,0.96065,
                0.62019,0.91497, 0.60096,0.91262, 0.57212,0.91599, 0.55288,0.92464, 0.54294,0.9375, 0.53614,0.97596,
                0.5293,0.98558, 0.51442,0.99768, 0.50481,0.99972, 0.48558,0.9976, 0.47064,0.98558, 0.46378,0.97596,
                0.45692,0.9375, 0.44712,0.92471, 0.42788,0.91613, 0.39904,0.9127, 0.37981,0.91504, 0.34135,0.96075,
                0.32212,0.96386, 0.30288,0.95946, 0.29108,0.94712, 0.28775,0.9375, 0.28692,0.91827, 0.2926,0.88942,
                0.28751,0.87019, 0.27404,0.85691, 0.24519,0.8393, 0.22596,0.83783, 0.1875,0.86253, 0.17788,0.86457,
                0.15865,0.86202, 0.14904,0.85563, 0.13804,0.84135, 0.13546,0.82212, 0.13747,0.8125, 0.15865,0.78268,
                0.16257,0.76442, 0.14315,0.72596, 0.12981,0.71246, 0.11058,0.70753, 0.07212,0.71382, 0.05288,0.70957,
                0.04054,0.69712, 0.03754,0.6875, 0.03958,0.65865, 0.08499,0.62019, 0.08738,0.60096, 0.08401,0.57212,
                0.07212,0.54956, 0.05288,0.53925, 0.02404,0.53606, 0.00911,0.52404,
            },
            {
                0.38459,0.21635, 0.38559,0.22596, 0.49519,0.41476, 0.50481,0.42342, 0.52404,0.42703, 0.54327,0.43683,
                0.56303,0.45673, 0.57212,0.46154, 0.79327,0.46154, 0.80498,0.45673, 0.78732,0.38942, 0.75805,0.33173,
                0.71897,0.28365, 0.66827,0.24198, 0.61058,0.21235, 0.53365,0.19354, 0.45673,0.19489, 0.40865,0.20575,
            },
            {
                0.19244,0.49519, 0.19354,0.53365, 0.20304,0.58173, 0.22596,0.63938, 0.26424,0.69712, 0.29327,0.72772,
                0.3125,0.74142, 0.32573,0.72596, 0.43133,0.54327, 0.43199,0.53365, 0.42342,0.50481, 0.43139,0.45673,
                0.32582,0.27404, 0.3125,0.25853, 0.29327,0.27218, 0.2641,0.30288, 0.22592,0.36058, 0.20298,0.41827,
                0.1948,0.45673,
            },
            {
                0.38462,0.78365, 0.41827,0.79702, 0.45673,0.80507, 0.52404,0.807, 0.58173,0.79713, 0.64904,0.76894,
                0.70673,0.72822, 0.75795,0.66827, 0.78729,0.61058, 0.80498,0.54327, 0.79327,0.53846, 0.57212,0.53846,
                0.54327,0.5631, 0.52404,0.57285, 0.50481,0.57658, 0.49519,0.5852, 0.46308,0.63942, 0.38559,0.77404,
            },
        }},
    }
    for key,icon in pairs(icons) do TAB_ICONS[key]=icon end
    end

    local embeddedImages={}
    local function rasterIcon(source,side)
        source.rasters=source.rasters or {}
        if source.rasters[side] then return source.rasters[side] end
        local eye=source.source=="icons8-eye-64.png"
        local compass=source.source=="icons8-compass-90.png"
        if (eye or compass) and side<=20 then

            local raster,samples={},12
            local center=(.49*.49-.36*.36)/.72
            local radius=center+.36
            for y=0,side-1 do for x=0,side-1 do
                local ink=0
                for sy=0,samples-1 do for sx=0,samples-1 do
                    local px=(x+(sx+.5)/samples)/side-.5
                    local py=(y+(sy+.5)/samples)/side-.5
                    local d=px*px+py*py
                    local filled
                    if eye then
                        local lens=px*px+(math.abs(py)+center)^2<=radius*radius
                        filled=lens and (d>=.19*.19 or d<=.085*.085)
                    else
                        local u,v=(px-py)/math.sqrt(2),(px+py)/math.sqrt(2)
                        local needle=math.abs(u)/.375+math.abs(v)/.10<=1
                        local hub=math.abs(u)+math.abs(v)<=.065
                        filled=d<=.49*.49 and (not needle or hub)
                    end
                    if filled then ink=ink+1 end
                end end
                raster[y*side+x+1]=math.floor(ink/(samples*samples)*255+.5)
            end end
            source.rasters[side]=raster
            return raster
        end
        local coverage=TAB_ICONS.raster(source.paths,side,side)
        local raster={}
        for i,alpha in ipairs(coverage) do
            raster[i]=math.clamp(math.floor(alpha*255+.5),0,255)
        end
        source.rasters[side]=raster
        return raster
    end

    local function nativeIconContent(source,raster,side)
        if source.nativeDisabled then return nil end
        if not Content or not Content.fromObject or not buffer or not buffer.fromstring then return nil end
        local ok,content=pcall(function()
            if not source.nativeImage or side>source.nativeCapacity then
                local capacity=32
                while capacity<side do capacity=capacity*2 end
                local editable=game:GetService("AssetService"):CreateEditableImage({Size=Vector2.new(capacity,capacity)})
                if not editable then return nil end
                embeddedImages[editable]=true
                local previous=source.nativeImage
                source.nativeImage=editable;source.nativeCapacity=capacity;source.nativeSide=nil
                source.nativeContent=Content.fromObject(editable)
                if previous then embeddedImages[previous]=nil;previous:Destroy() end
            end
            if source.nativeSide~=side then
                local rgba={}
                for _,alpha in ipairs(raster) do rgba[#rgba+1]=string.char(255,255,255,alpha) end
                source.nativeImage:WritePixelsBuffer(Vector2.zero,Vector2.new(side,side),buffer.fromstring(table.concat(rgba)))
                source.nativeSide=side
            end
            return source.nativeContent
        end)
        if not ok or not content then source.nativeDisabled=true;return nil end
        return content
    end

    local function tintSprite(obj,color,duration,role)
        obj:SetAttribute("GlyphColor",color);obj:SetAttribute("GlyphThemeRole",role)
        local native=obj:FindFirstChild("NativeIcon")
        if native then if role then bind(native,"ImageColor3",role,duration or motion.Control) else animate(native,{ImageColor3=color},duration or motion.Control) end end
        for _,pixel in ipairs(obj:GetDescendants()) do
            if pixel:GetAttribute("GlyphPixel") then
                if role then bind(pixel,"BackgroundColor3",role,duration or motion.Control) else animate(pixel,{BackgroundColor3=color},duration or motion.Control) end
            end
        end
    end
    local function embeddedTabIcon(parent,key,pos,size)
        local source=assert(TAB_ICONS[key],"Missing tab icon")
        if not source.ink then
            local reference=rasterIcon(source,96)
            local ink=0
            for _,alpha in ipairs(reference) do ink=ink+alpha end
            source.ink=ink/(255*96*96)
        end
        local holder=frame(parent,pos,size)
        holder.Name=key:lower().."_icon";holder.ZIndex=3
        holder:SetAttribute("EmbeddedIcon",true);holder:SetAttribute("IconSource",source.source)
        holder:SetAttribute("SourceInk",source.ink)
        new("UIAspectRatioConstraint",{AspectRatio=1,DominantAxis=Enum.DominantAxis.Width},holder)
        local plot=frame(holder,UDim2.new(),UDim2.new())
        plot.Name="PixelAlignedGlyph";plot.ZIndex=2
        local side,native=0,nil
        local function align()
            local factor=math.max(holder.AbsoluteSize.X/size.X.Offset,.001)
            local p=holder.AbsolutePosition
            local extent=holder.AbsoluteSize
            local x=math.floor(p.X+(extent.X-side)/2+.5)
            local y=math.floor(p.Y+(extent.Y-side)/2+.5)
            plot.Position=UDim2.fromOffset((x-p.X)/factor,(y-p.Y)/factor)
            plot.Size=UDim2.fromOffset(side/factor,side/factor)
            if native then native.Position=plot.Position;native.Size=plot.Size end
        end
        local function ready()
            if not alive or not holder.Parent then return end
            local loaded=native and native.IsLoaded
            if native then native.Visible=loaded==true end
            plot.Visible=not loaded
            holder:SetAttribute("IconBackend",loaded and "Native" or "Raster")
        end
        local function render()
            local available=math.min(holder.AbsoluteSize.X,holder.AbsoluteSize.Y)
            if available<=0 then return end
            local pixels=math.max(1,math.floor(available+.5))
            if pixels==side then align();return end
            side=pixels
            for _,child in ipairs(plot:GetChildren()) do child:Destroy() end
            local role=holder:GetAttribute("GlyphThemeRole")
            local color=role and themeColor(role) or holder:GetAttribute("GlyphColor") or theme.Unselected
            local raster=rasterIcon(source,side)
            for y=0,side-1 do
                local x=0
                while x<side do
                    local alpha=raster[y*side+x+1];local finish=x+1
                    while finish<side and raster[y*side+finish+1]==alpha do finish=finish+1 end
                    if alpha>0 then
                        local pixel=new("Frame",{
                            Name="GlyphPixel",Position=UDim2.fromScale(x/side,y/side),
                            Size=UDim2.fromScale((finish-x)/side,1/side),BorderSizePixel=0,
                            BackgroundColor3=color,BackgroundTransparency=1-alpha/255,ZIndex=2,
                        },plot)
                        pixel:SetAttribute("GlyphPixel",true);if role then bind(pixel,"BackgroundColor3",role) end
                    end
                    x=finish
                end
            end
            local content=nativeIconContent(source,raster,side)
            if content then
                if not native then
                    local ok,image=pcall(new,"ImageLabel",{
                        Name="NativeIcon",BackgroundTransparency=1,BorderSizePixel=0,
                        ImageContent=content,ImageColor3=color,ScaleType=Enum.ScaleType.Stretch,
                        ResampleMode=Enum.ResamplerMode.Pixelated,Visible=false,ZIndex=3,
                    },holder)
                    if ok then
                        native=image
                        connectOwned(holder,native:GetPropertyChangedSignal("IsLoaded"),ready)
                    end
                else native.ImageContent=content end
                if native then native.ImageRectSize=Vector2.new(side,side);if role then bind(native,"ImageColor3",role) end end
            end
            holder:SetAttribute("RasterSide",side);align();ready()
        end
        connectOwned(holder,holder:GetPropertyChangedSignal("AbsoluteSize"),render)
        connectOwned(holder,holder:GetPropertyChangedSignal("AbsolutePosition"),align)
        render()
        return holder
    end

    local function closePopup()
        if activeDrag and (activeDrag.kind=="color" or popup and activeDrag.popup==popup) then activeDrag=nil end
        themeUpdates.flush(true)
        if not popup then return end
        local closing=popup;popup=nil
        closing:SetAttribute("Closing",true)
        for _,object in ipairs(closing:GetDescendants()) do
            if object:IsA("GuiButton") then object.Active=false end
            if object:IsA("TextBox") and UIS:GetFocusedTextBox()==object then object:ReleaseFocus(false) end
        end
        local panel=closing:FindFirstChild("PopupPanel")
        if panel then
            panel.Active=false
            animate(panel,{GroupTransparency=1},motion.Popup,function() closing:Destroy() end)
        else closing:Destroy() end
    end
    local function popupAt(anchor,width,height)
        closePopup()
        local left,top,right,bottom=viewportBounds()
        popup=frame(canvas,UDim2.fromOffset(left,top),UDim2.fromOffset(right-left,bottom-top))
        popup.Name="Popup";popup.ZIndex=10000
        local shield=button(popup,"",UDim2.fromScale(0,0),UDim2.fromScale(1,1))
        shield.Name="PopupShield";shield.BackgroundTransparency=1;shield.TextTransparency=1;shield:SetAttribute("NoHover",true)
        connectOwned(shield,shield.Activated,closePopup)
        local p=(anchor.AbsolutePosition-canvas.AbsolutePosition)/uiScale.Scale
        local x=math.clamp(p.X,left+4,math.max(left+4,right-width-4))
        local y=p.Y+anchor.AbsoluteSize.Y/uiScale.Scale+2
        if y+height>bottom-4 then y=p.Y-height-2 end
        y=math.clamp(y,top+4,math.max(top+4,bottom-height-4))
        local box=group(popup,UDim2.fromOffset(x-left,y-top),UDim2.fromOffset(width,height),"Section")
        box.Name="PopupPanel";box.ZIndex=2;round(box,2)
        bind(box,"BackgroundColor3","PopupSurface");styleSurface(box,"Popup")
        box.GroupTransparency=motionReady and 1 or 0
        local scale=new("UIScale",{Scale=motionReady and .97 or 1},box)
        animate(box,{GroupTransparency=0},motion.Popup)
        animate(scale,{Scale=1},motion.Popup)
        return box
    end

    local function setWindowVisible(win,shown,quiet)
        shown=shown==true
        if win.Name=="Main" then themeUpdates.setVisible(shown) end
        if presentation and win.Name=="Main" then presentation.cancelIntro(not shown) end
        local revision=win:GetAttribute("VisibilityRevision") or 0
        if win:GetAttribute("VisibleTarget")~=shown then revision=revision+1 end
        win:SetAttribute("VisibilityRevision",revision);win:SetAttribute("VisibleTarget",shown)
        local scale=win:FindFirstChild("WindowScale")
        if shown then
            if not win.Visible then win.GroupTransparency=1;scale.Scale=win.Name=='Main' and 1 or .97 end
            win.Visible=true
        end
        local duration=quiet and 0 or (win.Name=="Main" and math.max(0,tonumber(options.MenuFadeTime) or .28) or motion.Window)
        animate(scale,{Scale=win.Name=='Main' and 1 or shown and 1 or .97},win.Name=='Main' and 0 or duration)
        animate(win,{GroupTransparency=shown and 0 or 1},duration,function()
            if win:GetAttribute("VisibilityRevision")==revision and not shown then win.Visible=false end
        end)
        if presentation and win.Name=="Main" then presentation.setVisible(shown,quiet) end
    end
    local function makeWindow(name,x,y,w,h,title)
        local win=group(canvas,UDim2.fromOffset(x,y),UDim2.fromOffset(w,h),"Background")
        win.Name=name;round(win,3)
        win:SetAttribute("VisibleTarget",true)
        new("UIScale",{Name="WindowScale",Scale=1},win)
        local bar=frame(win,UDim2.fromOffset(0,0),UDim2.new(1,0,0,21),"Header")
        bar.Name="TitleBar"
        surfaceGradient(bar)
        round(bar,3)
        bar.Active=true
        if title then text(bar,title,UDim2.fromOffset(8,0),UDim2.new(1,-16,1,0),8) end
        connectOwned(bar,bar.InputBegan,function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                if not win:GetAttribute("VisibleTarget") then return end
                local headerPages=bar:FindFirstChild("GlobalSearch",true)
                if headerPages and headerPages.Visible then
                    local p,s=headerPages.AbsolutePosition,headerPages.AbsoluteSize
                    if input.Position.X>=p.X and input.Position.X<=p.X+s.X and input.Position.Y>=p.Y and input.Position.Y<=p.Y+s.Y then return end
                end
                windowOrder=windowOrder+1;win.ZIndex=windowOrder;closePopup()
                settleWindowSize(win)
                animate(win.WindowScale,{Scale=1},0)
                animate(win,{Position=win.Position},0)
                activeDrag={kind="window",input=input,object=win,start=Vector2.new(input.Position.X,input.Position.Y),position=win.Position}
            end
        end)
        windows[#windows+1]=win
        return win,bar
    end

    local logoShape={width=564,height=533,paths={
        {start={0.54699,0},curves={
            {0.5239, 0.30521, 0.67241, 0.43338, 0.95035, 0.35929},
            {0.6588, 0.41985, 0.4261, 0.59555, 0.28989, 0.87617},
            {0.42301, 0.57189, 0.27823, 0.48578, 0, 0.49625},
            {0.27459, 0.47127, 0.48794, 0.2888, 0.54699, 0},
        }},
        {start={0.73316,0.5272},curves={
            {0.78227, 0.61666, 0.91107, 0.6125, 1, 0.60882},
            {0.79769, 0.64574, 0.64999, 0.80021, 0.57713, 1},
            {0.60142, 0.89999, 0.62839, 0.76321, 0.49468, 0.7439},
            {0.58317, 0.69281, 0.67, 0.61831, 0.73316, 0.5272},
        }},
    }}
    logoShape.headerWidth=math.ceil(14*logoShape.width/logoShape.height)
    logoShape.textOffset=logoShape.headerWidth+5
    logoShape.introWidth=math.ceil(44*logoShape.width/logoShape.height)

    local headerHeight=28
    local mainWidth=405
    local mainHeight=485
    local defaultMainX=(1280-mainWidth)/2
    local defaultMainY=(720-mainHeight)/2
    local navigationTop=headerHeight+7
    local navigationHeight=20
    local navigationGap=math.max(0,tonumber(options.TabPadding) or 5)
    local contentLeft=8
    local contentTop=navigationTop+navigationHeight+8
    local contentWidth=mainWidth-contentLeft-8
    local columnWidth=(contentWidth-10)/2
    local rightColumnX=columnWidth+10
    local brandTextWidth=math.ceil(game:GetService("TextService"):GetTextSize(scriptName,11,uiFont,Vector2.new(1000,16)).X)+2
    local headerTitleWidth=brandTextWidth+logoShape.textOffset+16
    local pageHeaderLeft=headerTitleWidth
    local main,mainBar=makeWindow("Main",defaultMainX,defaultMainY,mainWidth,mainHeight)
    main.ZIndex=5;mainBar.Size=UDim2.new(1,0,0,headerHeight)
    styleSurface(main,'Window')
    main.ClipsDescendants=true;main.BackgroundTransparency=1
    connectOwned(gui,gui:GetPropertyChangedSignal('Enabled'),function() themeUpdates.setVisible(gui.Enabled~=false and main:GetAttribute('VisibleTarget')==true) end)
    mainBar.BackgroundTransparency=1;mainBar.ZIndex=3
    mainBar.SurfaceGradient:Destroy()
    local navigationSurface=frame(main,UDim2.fromOffset(0,headerHeight),UDim2.new(1,0,0,contentTop-headerHeight-4))
    navigationSurface.Name="NavigationSurface";navigationSurface.ZIndex=1;navigationSurface.BackgroundTransparency=1
    local function shadeNavigation()
        bind(navigationSurface,'BackgroundColor3','NavigationSurface',motion.Control)
    end
    appearanceRefreshers[#appearanceRefreshers+1]=shadeNavigation
    shadeNavigation()
    local titleBackplate=frame(mainBar,UDim2.new(),UDim2.fromOffset(headerTitleWidth,headerHeight),"TitleSurface")
    titleBackplate.Name="ScriptTitleBackplate";titleBackplate.BackgroundTransparency=1;round(titleBackplate,3);styleSurface(titleBackplate,'Header')
    local function shadeTitleSurface()
        animate(titleBackplate,{BackgroundColor3=themeColor('TitleSurface')},motion.Control)
    end
    appearanceRefreshers[#appearanceRefreshers+1]=shadeTitleSurface
    shadeTitleSurface()
    local pageHeader=frame(mainBar,UDim2.fromOffset(pageHeaderLeft,0),UDim2.new(1,-pageHeaderLeft,1,0),"HeaderSurface")
    pageHeader.Name="SearchBackplate";pageHeader.ClipsDescendants=true;pageHeader.BackgroundTransparency=1
    round(pageHeader,3);styleSurface(pageHeader,'Header')
    local function shadeMainSurfaces()
        bind(main,'BackgroundColor3','MainSurface',motion.Control)
        animate(pageHeader,{BackgroundColor3=themeColor('HeaderSurface')},motion.Control)
    end
    appearanceRefreshers[#appearanceRefreshers+1]=shadeMainSurfaces
    shadeMainSurfaces()
    local brandLockup=frame(titleBackplate,UDim2.fromScale(.5,.5),UDim2.fromOffset(headerTitleWidth-16,18))
    brandLockup.Name="BrandLockup";brandLockup.AnchorPoint=Vector2.new(.5,.5)
    local logo=group(brandLockup,UDim2.fromOffset(0,2),UDim2.fromOffset(logoShape.headerWidth,14))
    logo.Name="SpectrohookLogo";logo.Active=false
    local function drawSpectrohookMark(holder,designSize,progress)
        local logoPlot=frame(holder,UDim2.new(),UDim2.new())
        logoPlot.Name='PixelAlignedLogo';logoPlot.Active=false
        holder:SetAttribute('LogoVariant','SpectralSplit08')
        local rasterWidth,rasterHeight=0,0
        local logoPixels,coverage,revealPhase,revealPart={},{},{},{}
        local function paintReveal()
            if not progress then return end
            local stage=math.clamp(progress.Value,0,1)*#logoShape.paths
            for i,pixel in ipairs(logoPixels) do
                
                local cursor=math.clamp(stage-(revealPart[i]-1),0,1)*1.04
                pixel.BackgroundTransparency=1-coverage[i]*math.clamp((cursor-revealPhase[i])/.04,0,1)
            end
        end
        local function renderBrandLogo()
            local origin,extent=holder.AbsolutePosition,holder.AbsoluteSize
            local ratio=logoShape.width/logoShape.height
            local height=math.max(1,math.floor(math.min(extent.Y,extent.X/ratio)+.5))
            local width=math.max(1,math.floor(height*ratio+.5))
            local x=math.floor(origin.X+(extent.X-width)/2+.5)
            local y=math.floor(origin.Y+(extent.Y-height)/2+.5)
            logoPlot.Position=UDim2.fromScale((x-origin.X)/math.max(extent.X,.001),(y-origin.Y)/math.max(extent.Y,.001))
            logoPlot.Size=UDim2.fromScale(width/math.max(extent.X,.001),height/math.max(extent.Y,.001))
            if width==rasterWidth and height==rasterHeight then return end
            rasterWidth,rasterHeight=width,height;logoPixels={};coverage={};revealPhase={};revealPart={}
            for _,child in ipairs(logoPlot:GetChildren()) do themeBindings[child]=nil;child:Destroy() end
            local paths=TAB_ICONS.curves(logoShape.paths,math.max(width,height))
            local function plotPart(partPaths,part)
                local raster=TAB_ICONS.raster(partPaths,width,height)
                local left,right=width,0
                if progress then
                    for _,path in ipairs(partPaths) do for i=1,#path,2 do
                        left=math.min(left,path[i]*width);right=math.max(right,path[i]*width)
                    end end
                end
                for py=0,height-1 do for px=0,width-1 do
                    local alpha=raster[py*width+px+1]
                    if alpha>1/1024 then
                        alpha=math.min(1,alpha*(designSize<=16 and 1.12 or 1))
                        local pixel=frame(logoPlot,UDim2.fromScale(px/width,py/height),UDim2.fromScale(1/width,1/height),'Accent')
                        pixel.BackgroundTransparency=1-alpha;pixel.Active=false
                        logoPixels[#logoPixels+1]=pixel
                        if progress then
                            pixel:SetAttribute('LogoPart',part)
                            coverage[#logoPixels]=alpha;revealPart[#logoPixels]=part
                            revealPhase[#logoPixels]=math.clamp((px+.5-left)/math.max(right-left,1),0,1)
                        end
                    end
                end end
            end
            if progress then
                for part,path in ipairs(paths) do plotPart({path},part) end
            else
                plotPart(paths,0)
            end
            paintReveal()
        end
        if progress then connectOwned(holder,progress:GetPropertyChangedSignal('Value'),paintReveal) end
        connectOwned(holder,holder:GetPropertyChangedSignal('AbsoluteSize'),renderBrandLogo)
        connectOwned(holder,holder:GetPropertyChangedSignal('AbsolutePosition'),renderBrandLogo)
        renderBrandLogo()
        appearanceRefreshers.watch(holder,function()
            for _,pixel in ipairs(logoPixels) do
                if pixel.Parent then bind(pixel,'BackgroundColor3','Accent',motion.Control) end
            end
        end)
    end
    drawSpectrohookMark(logo,14)
    local brand=text(brandLockup,scriptName,UDim2.new(0,logoShape.textOffset,.5,0),UDim2.fromOffset(brandTextWidth,16),11)
    brand.Name="ScriptName";brand.AnchorPoint=Vector2.new(0,.5)
    brand.TextScaled=false;brand.TextWrapped=false;brand.AutomaticSize=Enum.AutomaticSize.X
    brand.TextXAlignment=Enum.TextXAlignment.Left;brand.TextYAlignment=Enum.TextYAlignment.Center
    bind(brand,"TextColor3","Accent")
    do
        local function fitBrand()
            if not alive or not brand.Parent then return end
            local factor=math.max(uiScale.Scale*main.WindowScale.Scale,.001)
            local width=math.max(brandTextWidth,math.ceil(brand.AbsoluteSize.X/factor))
            headerTitleWidth=width+logoShape.textOffset+16;pageHeaderLeft=headerTitleWidth
            brandLockup.Size=UDim2.fromOffset(width+logoShape.textOffset,18)
            titleBackplate.Size=UDim2.fromOffset(headerTitleWidth,headerHeight)
            pageHeader.Position=UDim2.fromOffset(pageHeaderLeft,0)
            pageHeader.Size=UDim2.new(1,-pageHeaderLeft,1,0)
        end
        connectOwned(brand,brand:GetPropertyChangedSignal('AbsoluteSize'),fitBrand)
        fitBrand()
    end
    appearanceRefreshers[#appearanceRefreshers+1]=function()
        animate(brand,{TextColor3=theme.Accent},motion.Control)
    end
    local keybinds,keybindsBar=makeWindow('Keybinds',104,260,164,50)
    keybindsBar.Size=UDim2.new(1,0,0,23);keybinds.ZIndex=10
    bind(keybinds,'BackgroundColor3','Background');round(keybinds,8);surfaceGradient(keybinds,.96);styleSurface(keybinds,'Panel')
    bind(keybindsBar,'BackgroundColor3','HeaderSurface');round(keybindsBar,8);styleSurface(keybindsBar,'Header')
    local bindList=frame(keybinds,UDim2.fromOffset(7,27),UDim2.new(1,-14,1,-34))
    new('UIListLayout',{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder},bindList)
    do
        local heading=text(keybindsBar,'Keybinds',UDim2.fromOffset(9,0),UDim2.new(1,-18,1,0),9,'Accent')
        heading.Name='KeybindListTitle'
        local empty=text(bindList,'',UDim2.new(),UDim2.new(1,0,0,18),8,'Unselected')
        empty.Name='KeybindEmpty';empty.TextXAlignment=Enum.TextXAlignment.Center
    end
    setWindowVisible(keybinds,false,true)

    local noticeWidth,noticeGap=197,6
    local notices=frame(canvas,UDim2.new(),UDim2.new())
    notices.Name="Notifications";notices.ZIndex=20000;notices.ClipsDescendants=false;notices.Active=false
    local noticeEntries={}
    local dismissNotice
    fitNotifications=function(smooth)
        if not alive then return end
        local left,top,right,bottom=viewportBounds()
        local width,height=right-left,bottom-top
        local scale=math.max(uiScale.Scale,.001)
        local position=values.NotificationPosition or "Top Right"
        local offsetX=(tonumber(values.NotificationOffsetX) or 12)/scale
        local offsetY=(tonumber(values.NotificationOffsetY) or 12)/scale
        local watermark=canvas:FindFirstChild('Watermark')
        if position=='Top Right' and watermark and watermark.Visible then
            local p,size=watermark.Position,watermark.Size
            local x,y=right-offsetX-noticeWidth,top+offsetY
            if p.X.Offset<x+noticeWidth and p.X.Offset+size.X.Offset>x and p.Y.Offset<y+28 and p.Y.Offset+size.Y.Offset>y then
                offsetY=math.max(offsetY,p.Y.Offset+size.Y.Offset-top+8)
            end
        end
        local fromBottom=position:find("Bottom",1,true)~=nil
        local total,count=0,0
        for _,entry in ipairs(noticeEntries) do
            if not entry.exiting and entry.slot.Parent then total=total+entry.height;count=count+1 end
        end
        total=total+math.max(0,count-1)*noticeGap
        local x
        if position:find("Left",1,true) then x=offsetX
        elseif position:find("Center",1,true) then x=(width-noticeWidth)/2+offsetX
        else x=width-noticeWidth-offsetX end
        x=math.clamp(x,0,math.max(0,width-noticeWidth))
        local inset=math.clamp(offsetY,0,math.max(0,height-total))
        local cursor=fromBottom and height-inset or inset
        for _,entry in ipairs(noticeEntries) do
            if not entry.exiting and entry.slot.Parent then
                local y=fromBottom and cursor-entry.height or cursor
                animate(entry.slot,{Position=UDim2.fromOffset(left+x,top+y)},smooth~=false and entry.placed and motion.Window or 0)
                entry.placed=true
                cursor=fromBottom and y-noticeGap or y+entry.height+noticeGap
            end
        end
    end
    dismissNotice=function(entry)
        if not alive or entry.exiting or not entry.slot.Parent then return end
        entry.exiting=true
        local direction=values.NotificationExitDirection or "Right"
        entry.card:SetAttribute("ExitDirection",direction)
        local dx,dy=0,0
        if direction=="Up" then dy=-32 elseif direction=="Left" then dx=-32 else dx=32 end
        animate(entry.card,{GroupTransparency=1,Position=UDim2.fromOffset(dx,dy)},motion.Window,function()
            for i=#noticeEntries,1,-1 do if noticeEntries[i]==entry then table.remove(noticeEntries,i);break end end
            entry.slot:Destroy();fitNotifications(true)
        end)
        animate(entry.scale,{Scale=.97},motion.Window)
        fitNotifications(true)
    end
    local function notify(title,description,noBar,customDuration)
        if not alive or values.NotificationsEnabled==false then return end
        local height=description and description~="" and 45 or 29
        local slot=frame(notices,UDim2.new(),UDim2.fromOffset(noticeWidth,height))
        slot.Name="NotificationSlot"
        local card=group(slot,UDim2.new(),UDim2.fromOffset(noticeWidth,height),"Header")
        card.Name="Notification";card.GroupTransparency=motionReady and 1 or 0
        local scale=new("UIScale",{Scale=motionReady and .97 or 1},card)
        local entry={slot=slot,card=card,scale=scale,height=height,placed=false,exiting=false}
        noticeEntries[#noticeEntries+1]=entry
        local position=values.NotificationPosition or "Top Right"
        if motionReady then
            if position:find("Left",1,true) then card.Position=UDim2.fromOffset(-24,0)
            elseif position:find("Right",1,true) then card.Position=UDim2.fromOffset(24,0)
            else card.Position=UDim2.fromOffset(0,position:find("Bottom",1,true) and 16 or -16) end
        end
        round(card,6);card.ClipsDescendants=true
        text(card,title or scriptName,UDim2.fromOffset(7,4),UDim2.new(1,-14,0,12),8)
        if description and description~="" then
            local d=text(card,description,UDim2.fromOffset(7,17),UDim2.new(1,-14,0,18),7,"Unselected")
            d.TextWrapped=true;d.TextYAlignment=Enum.TextYAlignment.Top
        end
        local duration=tonumber(customDuration) or tonumber(values.NotificationDuration) or 3.6
        if not noBar and values.NotificationBar~=false then
            local progress=frame(card,UDim2.new(0,5,1,-5),UDim2.new(1,-10,0,2),"Accent")
            round(progress,1)
            animate(progress,{Size=UDim2.fromOffset(0,2)},duration,nil,Enum.EasingStyle.Linear)
        end
        
        local active=0
        for _,item in ipairs(noticeEntries) do if not item.exiting then active=active+1 end end
        if active>8 then
            for _,item in ipairs(noticeEntries) do if not item.exiting then dismissNotice(item);break end end
        end
        fitNotifications(true)
        animate(card,{GroupTransparency=0,Position=UDim2.new()},motion.Window)
        animate(scale,{Scale=1},motion.Window)
        task.delay(duration,function() dismissNotice(entry) end)
    end
    fitNotifications(false)

    local function pageTransition(collection,shield,origin)
        local revision=0
        return function(name,quiet)
            revision=revision+1
            local token=revision
            local duration=quiet and 0 or motion.Page
            shield.Visible=not quiet
            local function show()
                if not alive or not shield.Parent or token~=revision then return end
                for key,page in pairs(collection) do
                    page.Position=origin
                    if key~=name then
                        animate(page,{GroupTransparency=1},0);page.Visible=false
                    end
                end
                local page=collection[name]
                page.Visible=true
                sheenEffects.refresh()
                local revealTime=presentation and presentation.revealPage(page,quiet) or 0
                animate(page,{GroupTransparency=0},duration,function()
                    task.delay(math.max(0,revealTime-duration),function()
                        if alive and shield.Parent and token==revision then shield.Visible=false end
                    end)
                end)
            end
            if quiet then show();return end
            local fading=false
            for _,page in pairs(collection) do
                if page.Visible and page.GroupTransparency<1 then
                    fading=true
                    animate(page,{GroupTransparency=1},motion.PageOut)
                end
            end

            if fading then task.delay(motion.PageOut,show) else show() end
        end
    end

    local tabs,pages,tabButtons,tabLabels,tabPlates={}, {}, {}, {}, {}
    local currentTab=options.Pages[1]
    local pageSize=UDim2.fromScale(1,1)
    local pageCenter=UDim2.fromScale(.5,.5)
    local contentViewport=frame(main,UDim2.fromOffset(contentLeft,contentTop),UDim2.new(1,-(contentLeft+8),1,-(contentTop+8)))
    contentViewport.Name="ContentViewport";contentViewport.ClipsDescendants=true
    local tabBar=frame(main,UDim2.fromOffset(contentLeft,navigationTop),UDim2.fromOffset(contentWidth,navigationHeight))
    tabBar.Name="TabBar";tabBar.ZIndex=3
    local tabSelection=navigationPlate(tabBar,UDim2.fromOffset(.5,0),UDim2.fromOffset(57,navigationHeight),"TabSelection",true)
    local transitionShield=new("TextButton",{Name="PageTransitionShield",Position=UDim2.new(),Size=UDim2.fromScale(1,1),Text="",BackgroundTransparency=1,AutoButtonColor=false,Visible=false,ZIndex=500},contentViewport)
    local switchMainPages=pageTransition(pages,transitionShield,pageCenter)
    local function paintTabs()
        local chosen=tabButtons[currentTab]
        local moving=false
        if chosen then

            tabSelection:SetAttribute("SelectedTab",currentTab)
            moving=moveSelection(tabSelection,chosen,paintTabs)
        end
        local highlights=values.GlowEffects~=false
        animate(tabSelection.SelectionGlow,{GroupTransparency=highlights and .08 or 1},motion.Hover)
        sheenEffects.set(tabSelection,true)
        for key in pairs(pages) do
            local b=tabButtons[key]
            local selected=not moving and key==currentTab
            local hovered=values.GlowEffects~=false and not moving and key~=currentTab and b:GetAttribute("Hovered")==true
            b.BackgroundTransparency=1
            bind(tabPlates[key],'BackgroundColor3',hovered and 'NavHoverSurface' or 'NavSurface',moving and 0 or motion.Control)
            animate(tabPlates[key].TabHoverGlow,{GroupTransparency=hovered and .35 or 1},moving and 0 or motion.Hover)
            bind(tabLabels[key],'TextColor3',selected and 'SelectedText' or 'Unselected',moving and 0 or motion.Control)
            tintSprite(tabs[key],themeColor(selected and 'SelectedAccent' or 'Unselected'),moving and 0 or motion.Control,selected and 'SelectedAccent' or 'Unselected')
        end
    end
    local function setTab(name)
        if not pages[name] then return end
        closePopup()
        local switching=motionReady and currentTab~=name
        currentTab=name
        switchMainPages(name,not switching)
        paintTabs()
        if options.Compatibility and Library._context and Library._context.fitLayout then task.defer(Library._context.fitLayout) end
    end
    appearanceRefreshers[#appearanceRefreshers+1]=paintTabs
    local tabX=0
    local function addNativeTab(name,i)
        local side=10
        local labelWidth=math.ceil(game:GetService('TextService'):GetTextSize(name,8,uiFont,Vector2.new(1000,navigationHeight)).X)+2
        local tabWidth=math.max(58,labelWidth+side+5+16)
        local b=button(tabBar,"  "..name,UDim2.fromOffset(tabX,0),UDim2.fromOffset(tabWidth,navigationHeight),"Section")
        b.Name="Tab"..name;b.TextTransparency=1;b.BackgroundTransparency=1;b:SetAttribute("NoHover",true)
        b.ZIndex=3;b.LayoutOrder=i
        b:SetAttribute("NoBackplateBorder",true);b.ControlBorder.Enabled=false
        local plate=navigationPlate(tabBar,UDim2.fromOffset(tabX+.5,0),UDim2.fromOffset(tabWidth-1,navigationHeight),"TabBackplate"..name,false)
        local iconX=math.floor((tabWidth-side-5-labelWidth)/2)
        local icon=embeddedTabIcon(b,(options.Icons and options.Icons[name]) or (TAB_ICONS[name] and name or "Misc"),UDim2.fromOffset(iconX,5),UDim2.fromOffset(side,side))
        local caption=text(b,name,UDim2.fromOffset(iconX+side+5,0),UDim2.fromOffset(labelWidth,navigationHeight),8,"Unselected");caption.ZIndex=3
        tabs[name]=icon;tabButtons[name]=b;tabLabels[name]=caption;tabPlates[name]=plate
        local page=group(contentViewport,pageCenter,pageSize)
        page.AnchorPoint=Vector2.new(.5,.5)
        page.Name=name;pages[name]=page
        connectOwned(b,b.Activated,function() if currentTab~=name then setTab(name) end end)
        connectOwned(b,b.MouseEnter,function() b:SetAttribute("Hovered",true);paintTabs() end)
        connectOwned(b,b.MouseLeave,function() b:SetAttribute("Hovered",false);paintTabs() end)
        tabX=tabX+tabWidth+navigationGap
        page.Visible=false
        return page
    end
    for i,name in ipairs(options.Pages) do addNativeTab(name,i) end

    local function column(page,x,width,height)
        local col=new("ScrollingFrame",{
            Name="SectionColumn",BackgroundTransparency=1,
            Position=UDim2.fromOffset(x,0),Size=UDim2.new(0,width,1,height or 0),
            BorderSizePixel=0,CanvasSize=UDim2.new(),
            AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,
            ScrollBarThickness=0,ScrollBarImageTransparency=1,
            ElasticBehavior=Enum.ElasticBehavior.Never,ClipsDescendants=true,
        },page)

        new("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},col)
        return col
    end

    local sectionBodies=setmetatable({},{__mode="k"})
    local sectionControllers=setmetatable({},{__mode="k"})
    local register
    local function searchTag(object,label,id,kind)
        object:SetAttribute("SearchLabel",label)
        object:SetAttribute("SearchId",id or "")
        object:SetAttribute("SearchKind",kind or "Control")
    end
    local function rawRow(parent,height,asGroup)
        local order=(parent:GetAttribute("NextRowOrder") or 0)+1
        parent:SetAttribute("NextRowOrder",order)
        local r=(asGroup and group or frame)(parent,UDim2.new(),UDim2.new(1,0,0,height or 14))
        r.LayoutOrder=order
        return r
    end
    local function row(parent,height)
        return rawRow(sectionBodies[parent] or parent,height)
    end
    local functionShade={samples={}}
    function functionShade.draw(holder,height)
        local pixels=height*math.max(uiScale.Scale*main.WindowScale.Scale,.001)
        local count=32
        while count<pixels and count<512 do count=count*2 end
        if holder:GetAttribute('Rows')==count then return end
        local colors=functionShade.samples[count]
        if not colors then
            colors={}
            for y=0,count-1 do
                local points={}
                for x=0,15 do
                    local t=(x/15+(y+.5)/count)*.5

                    local noise=((math.sin((y+1)*127.1+(x+1)*311.7)*43758.5453)%1-.5)*.16
                    local value=math.clamp(1-t*t*(3-2*t)+noise,0,1)
                    points[#points+1]=ColorSequenceKeypoint.new(x/15,Color3.new(value,value,value))
                end
                colors[y+1]=ColorSequence.new(points)
            end
            functionShade.samples[count]=colors
        end
        for _,child in ipairs(holder:GetChildren()) do if child.Name=='ShadeStrip' then child:Destroy() end end
        for y=0,count-1 do
            local strip=frame(holder,UDim2.fromScale(0,y/count),UDim2.fromScale(1,1/count))
            strip.Name='ShadeStrip';strip.ZIndex=0;strip.Active=false;strip.Selectable=false
            strip.BackgroundColor3=Color3.new(1,1,1);strip.BackgroundTransparency=.975
            new('UIGradient',{Name='ShadeGradient',Rotation=0,Color=colors[y+1]},strip)
        end
        holder:SetAttribute('Rows',count)
    end
    local function sectionTitle(parent,title,featureId,options)
        options=options or {}
        local settings=options.settings==true
        local shell=rawRow(parent,22,true)
        shell.Name="Section"..title:gsub("%W","")
        shell.BackgroundTransparency=0;shell.ClipsDescendants=true;shell.Active=false;shell:SetAttribute("NoBackplateBorder",true)
        bind(shell,"BackgroundColor3","SectionIdle");round(shell,6);surfaceGradient(shell,.94);styleSurface(shell,'Panel')
        shell.SurfaceGradient.Rotation=45
        local shade=frame(shell,UDim2.new(),UDim2.fromScale(1,1))
        shade.Name='FunctionShade';shade.ZIndex=0;shade.Active=false;shade.Selectable=false;shade.Visible=false;shade.ClipsDescendants=true
        round(shade,themeStyle.PanelRadius)
        local backplate=new('TextButton',{Name='SectionBackplate',Size=UDim2.new(1,0,0,22),
            BackgroundTransparency=1,BorderSizePixel=0,Text='',AutoButtonColor=false,Active=true,Selectable=false,ZIndex=1},shell)
        shell:SetAttribute("SectionName",title);shell:SetAttribute("Expanded",false);shell:SetAttribute("Enabled",false)
        local heading=new('TextButton',{Text=title,Position=UDim2.fromOffset(7,3),Size=UDim2.fromOffset(1,16),
            BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,Active=false,Selectable=false,
            Font=uiFont,TextSize=8,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center},shell)
        bind(heading,'TextColor3','Text')
        heading.Name="SectionTitle";heading.ZIndex=2
        local width=game:GetService("TextService"):GetTextSize(title,8,uiFont,Vector2.new(1000,16)).X
        heading.Size=UDim2.fromOffset(math.ceil(width)+4,16)
        local tab,node="Menu",parent
        while node and node~=main do
            for name,page in pairs(pages) do if node==page then tab=name end end
            node=node.Parent
        end
        local id=featureId or ("SectionEnabled_"..tab.."_"..parent.Name.."_"..title:gsub("%W",""))
        shell:SetAttribute("SectionEnabledId",id);searchTag(heading,title,id,"Section")
        local setEnabled
        local headerToggle,paintSwitch=switchControl(shell,UDim2.new(1,-26,0,5.5),false,function(state)
            closePopup();activeDrag=nil;setEnabled(state)
        end)
        headerToggle.Name="SectionToggle";headerToggle.ZIndex=3
        headerToggle.Visible=not settings;headerToggle.Active=not settings;headerToggle.Selectable=not settings
        local body=group(shell,UDim2.fromOffset(7,19),UDim2.new(1,-14,0,0))
        body.Name="SectionContent";body.Visible=false;body.GroupTransparency=1;body.ZIndex=2;body.Active=false
        local shield=new("TextButton",{Name="SectionInputShield",Position=body.Position,Size=body.Size,BackgroundTransparency=1,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=50},shell)
        local enabled,expanded=false,false
        local layout=new("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder},body)
        local function resize(smooth)
            local contentHeight,count=0,0
            for _,child in ipairs(body:GetChildren()) do
                if child:IsA("GuiObject") and child.Visible then contentHeight=contentHeight+child.Size.Y.Offset;count=count+1 end
            end
            contentHeight=contentHeight+math.max(0,count-1)*2
            if expanded then body.Visible=true end
            if enabled and not settings or expanded and settings then functionShade.draw(shade,expanded and contentHeight+26 or 22) end
            local duration=smooth==false and 0 or (expanded and motion.SectionOpen or motion.Section)
            backplate.Size=UDim2.new(1,0,0,expanded and 19 or 22)
            animate(body,{Size=UDim2.new(1,-14,0,expanded and contentHeight or 0),GroupTransparency=expanded and 0 or 1},duration)
            animate(shield,{Size=UDim2.new(1,-14,0,expanded and contentHeight or 0)},duration)
            animate(shell,{Size=UDim2.new(1,0,0,expanded and contentHeight+26 or 22)},duration,function()
                if not expanded then body.Visible=false end
            end)
        end
        local function paintSection()
            local active=enabled and not settings or expanded and settings
            bind(shell,'BackgroundColor3',active and 'SectionSelected' or 'SectionIdle',motion.Control)
            bind(heading,'TextColor3',active and 'SelectedText' or 'IdleText',motion.Hover)
            shade.Visible=active;shell.SurfaceGradient.Enabled=false
            selectedBorder(shell,false)
        end
        local function setExpanded(state,quiet)
            state=state==true
            if not state then
                local focused=UIS:GetFocusedTextBox()
                local ancestor=focused
                while ancestor do
                    if ancestor==body then focused:ReleaseFocus(false);break end
                    ancestor=ancestor.Parent
                end
                local node=capture and capture.key
                while node do
                    if node==body then capture.set(values[capture.id],true);capture=nil;break end
                    node=node.Parent
                end
            end
            expanded=state;shield.Visible=not state;shell:SetAttribute('Expanded',state)
            paintSection();resize(not quiet)
        end
        local function toggleExpanded()
            closePopup();activeDrag=nil;setExpanded(not expanded)
        end
        connectOwned(heading,heading.Activated,toggleExpanded)
        connectOwned(backplate,backplate.Activated,toggleExpanded)
        local function updateEnabled(state)
            enabled=settings or state==true;values[id]=enabled;shell:SetAttribute('Enabled',enabled)
            heading.Active=true;heading.Selectable=true;paintSwitch(enabled)
            paintSection()
            if sectionControllers.syncBinds then sectionControllers.syncBinds(id,enabled) end
        end
        setEnabled=function(state,quiet)
            updateEnabled(state)
            resize(not quiet)
            if options.changed and not quiet and not restoringConfig then options.changed(enabled) end
        end
        register(id,settings or options.initial==true,setEnabled)
        controls[id].derived=settings or options.derived==true
        controls[id].sync=function(state) updateEnabled(state);resize() end
        setEnabled(settings or options.initial==true,true)
        sectionControllers[shell]=function() setExpanded(true);return true end
        connectOwned(shell,layout:GetPropertyChangedSignal("AbsoluteContentSize"),function() resize() end)
        connectOwned(shell,uiScale:GetPropertyChangedSignal('Scale'),function() if enabled then resize(false) end end)
        appearanceRefreshers[#appearanceRefreshers+1]=paintSection
        sectionBodies[parent]=body
        task.defer(function() if alive and shell.Parent then resize(false) end end)
        return body,shell
    end
    register=function(id,initial,setter,getter)
        values[id]=initial
        controls[id]={set=setter,get=getter or function() return values[id] end,initial=initial}
    end
    local function labelRow(parent,label,height)
        local r=row(parent,height or 14)
        return text(r,label,UDim2.new(),UDim2.fromScale(1,1),8),r
    end
    local function toggle(parent,label,id,initial,callback,disabled)
        local r=row(parent,14)
        searchTag(r,label,id,"Toggle")
        r.Name=id.."Row";r:SetAttribute("ControlId",id)
        local set
        local box,paint=switchControl(r,UDim2.fromOffset(0,1.5),initial,function(value) set(value) end,disabled)
        local caption=text(r,label,UDim2.fromOffset(25,0),UDim2.new(1,-25,1,0),8)
        if disabled then caption.TextTransparency=.55 end
        set=function(value,quiet)
            values[id]=value==true
            paint(values[id])
            bind(caption,'TextColor3',values[id] and 'SelectedText' or 'IdleText',motion.Control)
            if callback and not quiet then callback(values[id]) end
        end
        register(id,initial,set);set(initial,true)
        if not disabled then
            local hit=new("TextButton",{Size=UDim2.new(1,-42,1,0),BackgroundTransparency=1,Text="",AutoButtonColor=false},r)
            hit.Name="ToggleHit";hit.ZIndex=2
            connectOwned(hit,hit.Activated,function() set(not values[id]) end)
        end
        return r,set
    end
    local function slider(parent,label,id,initial,min,max,step,suffix,callback,stringValues)
        local r=row(parent,22);r.Name=id.."Row";r:SetAttribute("ControlId",id)
        searchTag(r,label,id,"Slider")
        text(r,label,UDim2.new(),UDim2.new(1,-44,0,12),8)
        local out=new("TextBox",{
            Name=id.."Value",Position=UDim2.new(1,-44,0,0),Size=UDim2.fromOffset(44,12),
            BackgroundTransparency=1,BorderSizePixel=0,Font=uiFont,TextSize=8,
            TextXAlignment=Enum.TextXAlignment.Right,ClearTextOnFocus=false,MultiLine=false,Text="",
        },r)
        bind(out,"TextColor3","Text")
        local track=button(r,"",UDim2.fromOffset(0,15),UDim2.new(1,0,0,4))
        track.Name=id.."Track"
        local fill=frame(track,UDim2.new(),UDim2.fromScale(0,1),"Accent");fill.Name="Fill";round(fill,2)
        local editing,cancelled=false,false
        local function finite(n) return n and n==n and n~=math.huge and n~=-math.huge end
        local function numberText(n) return (string.format("%.4f",n):gsub("0+$",""):gsub("%.$","")) end
        local function display(n)
            return stringValues and stringValues[math.floor((n-min)/step+.5)+1] or numberText(n)..(suffix or "")
        end
        local function set(value,quiet)
            value=tonumber(value)
            if not finite(value) then value=values[id] or initial end
            value=math.clamp(value,min,max)
            value=math.clamp(math.floor((value-min)/step+.5)*step+min,min,max)
            value=math.floor(value*10000+.5)/10000
            values[id]=value
            local duration=activeDrag and activeDrag.kind=="slider" and motion.Drag or motion.Control
            animate(fill,{Size=UDim2.fromScale((value-min)/(max-min),1)},duration)
            if not editing then out.Text=display(value) end
            if callback and not quiet then callback(value) end
        end
        local function parse(raw)
            raw=raw:match("^%s*(.-)%s*$")
            if stringValues then
                for i,v in ipairs(stringValues) do if raw:lower()==v:lower() then return min+(i-1)*step end end
            end
            if suffix and suffix~="" and raw:sub(-#suffix):lower()==suffix:lower() then
                raw=raw:sub(1,-#suffix-1):match("^%s*(.-)%s*$")
            end
            local n=tonumber((raw:gsub(",",".")))
            return finite(n) and n or nil
        end
        register(id,initial,set);set(initial,true)
        connectOwned(out,out.Focused,function()
            closePopup();activeDrag=nil;editing=true;cancelled=false
            bind(out,'TextColor3','SelectedText',motion.Hover)
            out.Text=stringValues and display(values[id]) or numberText(values[id])
            task.defer(function()
                if alive and out.Parent and UIS:GetFocusedTextBox()==out then
                    out.CursorPosition=#out.Text+1;out.SelectionStart=1
                end
            end)
        end)
        connectOwned(out,out.FocusLost,function()
            local n=not cancelled and parse(out.Text) or nil
            editing=false;cancelled=false
            bind(out,'TextColor3','Text',motion.Hover)
            if n then set(n) end
            out.Text=display(values[id])
        end)
        connectOwned(out,out.InputBegan,function(input)
            if input.KeyCode==Enum.KeyCode.Escape then cancelled=true;out:ReleaseFocus(false) end
        end)
        local function at(x)
            if track.AbsoluteSize.X>0 then set(min+math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)*(max-min)) end
        end
        connectOwned(track,track.InputBegan,function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                if UIS:GetFocusedTextBox()==out then out:ReleaseFocus(false) end
                activeDrag={kind="slider",input=input,update=at};at(input.Position.X)
            end
        end)
        return r,set
    end

    local function dropdown(parent,label,id,options,initial,multi,callback)
        local r=row(parent,label~='' and 36 or 22)
        searchTag(r,label,id,'Dropdown');r:SetAttribute('SearchTerms',table.concat(options,' '))
        if label~='' then text(r,label,UDim2.new(),UDim2.new(1,0,0,12),8) end
        local b=button(r,'',UDim2.fromOffset(0,label~='' and 14 or 0),UDim2.new(1,0,0,20),'DropdownSurface')
        b.Name=id..'Dropdown';b:SetAttribute('NoHover',true);styleSurface(b,'Dropdown')
        local shown=text(b,'',UDim2.fromOffset(8,0),UDim2.new(1,-16,1,0),8,'Text')
        shown.Name='DropdownValue';shown.TextTruncate=Enum.TextTruncate.AtEnd
        local hovered=false
        local function paintField()
            local open=b:GetAttribute('DropdownOpen')==true
            local key=(hovered or open) and 'DropdownHover' or 'DropdownSurface'
            themeBindings[b].BackgroundColor3=key
            animate(b,{BackgroundColor3=themeColor(key)},motion.Hover)
            selectedBorder(b,open)
            bind(shown,'TextColor3',open and 'SelectedText' or 'Text',motion.Hover)
        end
        appearanceRefreshers[#appearanceRefreshers+1]=function() if b.Parent then paintField() end end
        connectOwned(b,b.MouseEnter,function() hovered=true;paintField() end)
        connectOwned(b,b.MouseLeave,function() hovered=false;paintField() end)
        local function set(value,quiet)
            if multi then
                local valid={}
                if type(value)=='table' then for _,option in ipairs(options) do if value[option] then valid[option]=true end end end
                values[id]=valid
                local labels={};for _,option in ipairs(options) do if valid[option] then labels[#labels+1]=option end end
                caption(shown,table.concat(labels,', '))
            else
                local valid=options[1]
                for _,option in ipairs(options) do if option==value then valid=option;break end end
                values[id]=valid;caption(shown,valid or '')
            end
            if callback and not quiet then callback(values[id]) end
        end
        register(id,initial,set);set(initial,true);paintField()
        connectOwned(b,b.Activated,function()
            local count=math.min(#options,8)
            local box=popupAt(b,math.max(100,b.AbsoluteSize.X/uiScale.Scale),count*26+20)
            styleSurface(box,'Popup');box.ClipsDescendants=true
            b:SetAttribute('DropdownOpen',true);paintField()
            box.Destroying:Once(function() if b.Parent then b:SetAttribute('DropdownOpen',false);paintField() end end)
            local scroll=new('ScrollingFrame',{
                Position=UDim2.fromOffset(6,8),Size=UDim2.new(1,-12,1,-16),
                BackgroundTransparency=1,BorderSizePixel=0,
                CanvasSize=UDim2.fromOffset(0,#options*26+4),
                ScrollBarThickness=2,ScrollBarImageTransparency=.55,ClipsDescendants=true,
            },box)
            bind(scroll,'ScrollBarImageColor3','Accent')
            for index,opt in ipairs(options) do
                local option=opt
                local item=button(scroll,'  '..option,UDim2.fromOffset(0,2+(index-1)*26),UDim2.new(1,#options>8 and -4 or 0,0,24),'Inline')
                item:SetAttribute('NoHover',true)
                styleSurface(item,'Option')
                item.TextXAlignment=Enum.TextXAlignment.Left;item.TextTransparency=1;item.ClipsDescendants=false
                local optionLabel=text(item,option,UDim2.fromOffset(8,3),UDim2.new(1,-16,1,-6),8,'Text')
                optionLabel.Name='OptionLabel';optionLabel.TextYAlignment=Enum.TextYAlignment.Center
                local over=false
                local function chosen() return multi and values[id][option] or not multi and values[id]==option end
                local function paint()
                    local selected=chosen()
                    selectedBorder(item,selected)
                    local background=selected and 'DropdownSelection' or 'DropdownHover'
                    local foreground=selected and 'SelectedText' or 'IdleText'
                    themeBindings[item].BackgroundColor3=background;themeBindings[item].TextColor3=foreground
                    themeBindings[optionLabel].TextColor3=foreground
                    animate(optionLabel,{TextColor3=themeColor(foreground)},motion.Hover)
                    animate(item,{
                        BackgroundTransparency=(selected or over) and 0 or 1,
                        BackgroundColor3=themeColor(background),TextColor3=themeColor(foreground),
                    },motion.Hover)
                end
                paint()
                connectOwned(item,item.MouseEnter,function() over=true;paint() end)
                connectOwned(item,item.MouseLeave,function() over=false;paint() end)
                connectOwned(item,item.Activated,function()
                    if multi then
                        local nextValue={};for key,value in pairs(values[id]) do nextValue[key]=value end
                        nextValue[option]=not nextValue[option] or nil;set(nextValue);paint()
                    else set(option);closePopup() end
                end)
            end
        end)
        return r,set
    end
    local function colorHex(color)
        return string.format("#%02X%02X%02X",math.floor(color.R*255+.5),math.floor(color.G*255+.5),math.floor(color.B*255+.5))
    end
    local function parseColor(value)
        if type(value)=="string" then
            local raw=value:gsub("#","")
            if raw:match("^%x%x%x%x%x%x$") then return rgb(tonumber(raw:sub(1,2),16),tonumber(raw:sub(3,4),16),tonumber(raw:sub(5,6),16)) end
        elseif typeof(value)=="Color3" then return value end
        return nil
    end
    local function colorPicker(parent,id,initial,pos,callback,options)
        options=options or {}
        local state=themeUpdates.add(options.themeKey,id)
        if state then
            register(id..'Rainbow',false,function(value,quiet) themeUpdates.enable(state,value,quiet) end)
            register(id..'RainbowSpeed',1,function(value) themeUpdates.speed(state,value) end)
        end
        local b=button(parent,'',pos or UDim2.new(1,-10,0,2),UDim2.fromOffset(10,10))
        b.Name=id..'ColorPicker';b:SetAttribute('NoHover',true);b.ZIndex=5
        b:FindFirstChildOfClass('UICorner').CornerRadius=UDim.new(0,3)
        themeBindings[b].BackgroundColor3=nil
        local view
        local function set(value,quiet,live)
            local color=parseColor(value) or initial
            if not quiet and state.enabled then themeUpdates.enable(state,false,true) end
            local hex=colorHex(color);local changed=values[id]~=hex
            values[id]=hex
            local dragging=activeDrag and activeDrag.kind=='color' and activeDrag.owner==b
            if b.BackgroundColor3~=color then animate(b,{BackgroundColor3=color},(live or dragging) and 0 or motion.Control) end
            if view and view.owner.Parent and (not quiet or view.lastColor~=color) then view.paint(color);view.lastColor=color end
            if changed and callback and not quiet then callback(color) end
        end
        register(id,colorHex(initial),set);set(initial,true)
        state.getColor=function() return parseColor(values[id]) or initial end
        state.applyColor=function(color)
            local previous=values[id]
            if themeUpdates.shown then set(color,true,true) else values[id]=colorHex(color) end
            if previous~=values[id] and callback and not state.themeKey then callback(color) end
        end
        appearanceRefreshers.watch(b,function() animate(b,{BackgroundColor3=parseColor(values[id]) or initial},motion.Control) end)
        connectOwned(b,b.Activated,function()
            local box=popupAt(b,176,state and 234 or 176)
            styleSurface(box,'Popup')
            local hue,sat,val=parseColor(values[id]):ToHSV()
            local sv=button(box,'',UDim2.fromOffset(8,8),UDim2.fromOffset(140,140));sv.Name='SaturationValue'
            sv:FindFirstChildOfClass('UICorner').CornerRadius=UDim.new(0,4);sv:SetAttribute('NoHover',true)
            themeBindings[sv].BackgroundColor3=nil
            local white=frame(sv,UDim2.new(),UDim2.fromScale(1,1));white.BackgroundTransparency=0;white.BackgroundColor3=Color3.new(1,1,1)
            round(white,4)
            new('UIGradient',{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)})},white)
            local black=frame(sv,UDim2.new(),UDim2.fromScale(1,1));black.BackgroundTransparency=0;black.BackgroundColor3=Color3.new()
            round(black,4)
            new('UIGradient',{Rotation=90,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)})},black)
            local dot=frame(sv,UDim2.new(),UDim2.fromOffset(4,4));dot.Name='ColorCursor';dot.AnchorPoint=Vector2.new(.5,.5)
            dot.BackgroundTransparency=1;round(dot,5);new('UIStroke',{Thickness=1,Color=Color3.new(1,1,1)},dot)
            local strip=button(box,'',UDim2.fromOffset(154,8),UDim2.fromOffset(14,140));strip.Name='HueStrip'
            strip:FindFirstChildOfClass('UICorner').CornerRadius=UDim.new(0,3);strip:SetAttribute('NoHover',true)
            themeBindings[strip].BackgroundColor3=nil;strip.BackgroundColor3=Color3.new(1,1,1)
            local points={};for i=0,6 do points[#points+1]=ColorSequenceKeypoint.new(i/6,Color3.fromHSV(i/6,1,1)) end
            new('UIGradient',{Rotation=90,Color=ColorSequence.new(points)},strip)
            local hueMark=frame(strip,UDim2.new(),UDim2.new(1,2,0,2));hueMark.Name='HueCursor';hueMark.BackgroundTransparency=0;hueMark.BackgroundColor3=Color3.new(1,1,1)
            local hex=new('TextBox',{Name='ColorHex',Position=UDim2.fromOffset(8,154),Size=UDim2.fromOffset(160,14),
                BorderSizePixel=0,ClearTextOnFocus=false,Font=uiFont,TextSize=8,Text=''},box)
            round(hex,3);controlBackplate(hex);bind(hex,'BackgroundColor3','Inline');bind(hex,'TextColor3','Text')
            local function paint(color)
                if not (activeDrag and activeDrag.kind=='color' and activeDrag.owner==b) then hue,sat,val=color:ToHSV() end
                animate(sv,{BackgroundColor3=Color3.fromHSV(hue,1,1)},0)
                animate(dot,{Position=UDim2.fromScale(sat,1-val)},0)
                animate(hueMark,{Position=UDim2.new(0,-1,hue,0)},0)
                if UIS:GetFocusedTextBox()~=hex then
                    local value=colorHex(color);if hex.Text~=value then hex.Text=value end
                end
            end
            view={owner=box,paint=paint}
            connectOwned(box,box.Destroying,function()
                if view and view.owner==box then view=nil end
                if state and state.ui and state.ui.owner==box then state.ui=nil end
            end)
            local function update(quiet) set(Color3.fromHSV(hue,sat,val),quiet,true) end
            connectOwned(hex,hex.FocusLost,function()
                local color=parseColor(hex.Text)
                if color then
                    if state then
                        themeUpdates.enable(state,false,true)
                        if state.themeKey then themeUpdates.edit(state.themeKey,color) end
                    end
                    hue,sat,val=color:ToHSV();update();themeUpdates.flush(true)
                else hex.Text=values[id] end
            end)
            local function begin(input,move)
                if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
                if state then themeUpdates.enable(state,false,true) end
                activeDrag={kind='color',input=input,owner=b,popup=box.Parent,update=move}
                move(input.Position.X,input.Position.Y)
            end
            connectOwned(sv,sv.InputBegan,function(input)
                begin(input,function(x,y)
                    sat=math.clamp((x-sv.AbsolutePosition.X)/sv.AbsoluteSize.X,0,1)
                    val=1-math.clamp((y-sv.AbsolutePosition.Y)/sv.AbsoluteSize.Y,0,1);update()
                end)
            end)
            connectOwned(strip,strip.InputBegan,function(input)
                begin(input,function(_,y) hue=math.clamp((y-strip.AbsolutePosition.Y)/strip.AbsoluteSize.Y,0,1);update() end)
            end)
            if state then
                local rainbowLabel=text(box,'Rainbow',UDim2.fromOffset(8,177),UDim2.fromOffset(124,16),8)
                local rainbow,paintSwitch=switchControl(box,UDim2.fromOffset(149,180),state.enabled,function(value)
                    controls[id..'Rainbow'].set(value)
                end)
                rainbow.Name=id..'RainbowToggle'
                text(box,'Speed',UDim2.fromOffset(8,199),UDim2.fromOffset(92,16),8)
                local speed=new('TextBox',{Name=id..'RainbowSpeedValue',Position=UDim2.fromOffset(116,199),Size=UDim2.fromOffset(52,16),
                    BackgroundTransparency=1,BorderSizePixel=0,Font=uiFont,TextSize=8,Text='',ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Right},box)
                bind(speed,'TextColor3','Text')
                local speedTrack=button(box,'',UDim2.fromOffset(8,221),UDim2.fromOffset(160,4));speedTrack.Name=id..'RainbowSpeedTrack'
                speedTrack:SetAttribute('NoHover',true)
                local speedFill=frame(speedTrack,UDim2.new(),UDim2.fromScale(0,1),'Accent');round(speedFill,2)
                local function paintSettings()
                    paintSwitch(state.enabled)
                    bind(rainbowLabel,'TextColor3',state.enabled and 'SelectedText' or 'IdleText',motion.Control)
                    if UIS:GetFocusedTextBox()~=speed then speed.Text=string.format('%.1fx',state.speed) end
                    animate(speedFill,{Size=UDim2.fromScale((state.speed-.1)/2.9,1)},0)
                end
                state.ui={owner=box,paint=paintSettings}
                connectOwned(speed,speed.FocusLost,function()
                    local number=tonumber((speed.Text:lower():gsub('x',''):gsub('×',''):gsub(',','.')))
                    controls[id..'RainbowSpeed'].set(number or state.speed);paintSettings()
                end)
                connectOwned(speedTrack,speedTrack.InputBegan,function(input)
                    if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
                    local function move(x)
                        controls[id..'RainbowSpeed'].set(.1+2.9*math.clamp((x-speedTrack.AbsolutePosition.X)/speedTrack.AbsoluteSize.X,0,1))
                    end
                    activeDrag={kind='slider',input=input,popup=box.Parent,owner=speedTrack,update=move};move(input.Position.X)
                end)
                paintSettings()
            end
            update(true)
        end)
        return b,set
    end
    local function colorRow(parent,label,id,color,callback,options)
        local _,r=labelRow(parent,label,15)
        searchTag(r,label,id,'Color')
        return colorPicker(r,id,color,UDim2.new(1,-10,0,2),callback,options)
    end

    local function actionRow(parent,label,fn)
        local r=row(parent,19)
        searchTag(r,label,nil,"Button")
        local b=button(r,label,UDim2.new(),UDim2.fromScale(1,1))
        connectOwned(b,b.Activated,fn or function() notify(scriptName) end)
        return b
    end
    local keybindRecords={}
    function keybindRecords.matches(input,binding)
        if not binding or binding=='Unknown' then return false end
        return input.KeyCode.Name==binding or input.UserInputType.Name==binding
    end
    local bindRows={}
    local function updateBindList()
        local count=0
        local names={MouseButton1='LMB',MouseButton2='RMB',MouseButton3='MMB',RightAlt='RALT'}
        for _,record in ipairs(keybindRecords) do
            local visible=not record.noUI and values[record.id] and values[record.id]~='Unknown'
            local entry=bindRows[record.id]
            if visible and not entry then
                local r=row(bindList,18);r.Name='KeybindEntry';r:SetAttribute('BindId',record.id)
                bind(r,'BackgroundColor3','SectionIdle');round(r,5)
                local label=text(r,record.label,UDim2.fromOffset(7,0),UDim2.new(1,-70,1,0),8,'Text')
                label.Name='BindName';label.TextTruncate=Enum.TextTruncate.AtEnd
                local badge=frame(r,UDim2.new(1,-36,0,3),UDim2.fromOffset(30,12),'Inline')
                badge.Name='BindKeyBackplate';round(badge,4)
                local key=text(badge,'',UDim2.new(),UDim2.fromScale(1,1),7.5,'Unselected')
                key.Name='BindKey';key.TextXAlignment=Enum.TextXAlignment.Center
                entry={row=r,key=key,label=label,badge=badge};bindRows[record.id]=entry
            end
            if entry then entry.row.Visible=visible==true end
            if visible then
                count=count+1
                local key=names[values[record.id]] or values[record.id]:upper()
                caption(entry.key,key)
                local width=math.max(28,math.min(58,math.ceil(game:GetService('TextService'):GetTextSize(key,7.5,uiFont,Vector2.new(1000,12)).X)+10))
                entry.badge.Position=UDim2.new(1,-width-6,0,3);entry.badge.Size=UDim2.fromOffset(width,12)
                entry.label.Size=UDim2.new(1,-width-20,1,0)
                bind(entry.badge,'BackgroundColor3',record.active and 'Accent' or 'Inline',motion.Hover)
                entry.badge.BackgroundTransparency=record.active and .82 or 0
                bind(entry.key,'TextColor3',record.active and 'SelectedText' or 'Unselected',motion.Hover)
                bind(entry.label,'TextColor3',record.active and 'SelectedText' or 'IdleText',motion.Hover)
                if record.key then bind(record.key,'TextColor3',record.active and 'SelectedText' or 'Unselected',motion.Hover) end
            end
        end
        keybinds:SetAttribute('BindCount',count)
        local empty=bindList:FindFirstChild('KeybindEmpty')
        if empty then empty.Visible=count==0 end
        local height=math.max(50,34+count*21)
        animate(keybinds,{Size=UDim2.fromOffset(164,height),Position=windowPosition(keybinds,keybinds.Position.X.Offset,keybinds.Position.Y.Offset,164,height)},motion.Control)
    end
    function keybindRecords.setActive(record,state)
        local previous=record.active
        record.active=state==true
        local control=record.featureId and controls[record.featureId]
        if control and not restoringConfig and values[record.featureId]~=record.active then control.set(record.active) end
        if previous~=record.active and bridge.active[record.id] then bridge.active[record.id](record.active) end
    end
    function keybindRecords.dispatch(input)
        for _,record in ipairs(keybindRecords) do
            if keybindRecords.matches(input,values[record.id]) then
                keybindRecords.setActive(record,record.mode=='Hold' or record.mode=='Always' or not record.active)
            end
        end
        updateBindList()
    end
    function sectionControllers.syncBinds(id,state)
        for _,record in ipairs(keybindRecords) do if record.featureId==id then record.active=state==true end end
        updateBindList()
    end
    function sectionControllers.syncAllBinds()
        for _,record in ipairs(keybindRecords) do if record.featureId then record.active=values[record.featureId]==true end end
        updateBindList()
    end
    appearanceRefreshers[#appearanceRefreshers+1]=updateBindList
    local function keybind(parent,label,id,initial,callback,listed)
        local r=row(parent,15)
        searchTag(r,label,id,"Keybind")
        local b=button(r,"",UDim2.new(),UDim2.fromScale(1,1))
        b.BackgroundTransparency=1
        text(b,label,UDim2.new(),UDim2.new(1,-38,1,0),8)
        local key=text(b,"",UDim2.new(1,-58,0,0),UDim2.fromOffset(58,15),7,"Unselected")
        key.TextXAlignment=Enum.TextXAlignment.Right
        local function set(value,quiet)
            if type(value)~="string" then value=initial end
            local changed=values[id]~=value
            values[id]=value
            caption(key,"["..(value=="RightAlt" and "RIGHT ALT" or value:upper()).."]")
            if listed then
                if changed then
                    for _,record in ipairs(keybindRecords) do
                        if record.id==id and record.mode=='Hold' then keybindRecords.setActive(record,false) end
                    end
                end
                updateBindList()
            end
            if callback and not quiet then callback(value) end
        end
        register(id,initial,set);set(initial,true)
        local record={id=id,label=type(listed)=="string" and listed or label,mode="Toggle",active=false,key=key}
        if listed then
            local feature=id:match('^(.-)Key$')
            if feature and controls[feature..'Enabled'] then record.featureId=feature..'Enabled';record.active=values[record.featureId]==true end
        end
        if listed then keybindRecords[#keybindRecords+1]=record end
        if listed then
        register(id.."Mode","Toggle",function(mode)
            if mode~="Toggle" and mode~="Hold" and mode~="Always" then mode="Toggle" end
            record.mode=mode;values[id.."Mode"]=mode
            keybindRecords.setActive(record,mode=="Always");updateBindList()
        end)
        end
        connectOwned(b,b.Activated,function()
            closePopup()
            if capture then capture.set(values[capture.id],true) end
            capture={id=id,set=set,key=key};caption(key,"[...]")
        end)
        if listed then
        connectOwned(b,b.MouseButton2Click,function()
            local box=popupAt(b,90,60)
            for i,mode in ipairs({"Toggle","Hold","Always"}) do
                local opt=button(box,mode,UDim2.fromOffset(3,3+(i-1)*18),UDim2.new(1,-6,0,18),"Section")
                bind(opt,'TextColor3',record.mode==mode and 'SelectedText' or 'IdleText')
                connectOwned(opt,opt.Activated,function() controls[id.."Mode"].set(mode);closePopup() end)
            end
        end)
        end
        return r
    end

    local function feature(parent,title,id,options)
        local body,shell=sectionTitle(parent,title,id.."Enabled",options)
        shell.Name=id.."Feature"
        return body
    end
    local function featureColumns(page,name)
        local left=column(page,0,columnWidth)
        local right=column(page,rightColumnX,columnWidth)
        left.Name=name.."LeftColumn";right.Name=name.."RightColumn"
        return left,right
    end

    sectionControllers.api={Name=scriptName,Gui=gui,Pages=pages}
    function sectionControllers.api:Columns(name)
        assert(pages[name],"Unknown page: "..tostring(name))
        return featureColumns(pages[name],name)
    end
    function sectionControllers.api:Feature(...) return feature(...) end
    function sectionControllers.api:Slider(...) return slider(...) end
    function sectionControllers.api:ToggleControl(...) return toggle(...) end
    function sectionControllers.api:Toggle(...) return toggle(...) end
    function sectionControllers.api:Dropdown(...) return dropdown(...) end
    function sectionControllers.api:Keybind(...) return keybind(...) end
    function sectionControllers.api:ColorPicker(...) return colorRow(...) end
    function sectionControllers.api:Action(...) return actionRow(...) end
    function sectionControllers.api:Accent() return theme.Accent end
    function sectionControllers.api:Notify(...) return notify(...) end
    function sectionControllers.api:FitNotifications() return fitNotifications(true) end
    function sectionControllers.api:SyncRuntime()
        if sectionControllers.syncRuntime then sectionControllers.syncRuntime() end
    end
    function sectionControllers.api:Get(id)
        local control=controls[id]
        return control and control.get()
    end
    function sectionControllers.api:Set(id,value)
        local control=controls[id]
        if not control then return false end
        control.set(value);return true
    end
    function sectionControllers.api:SelectTab(name)
        if pages[name] then setTab(name);return true end
        return false
    end
    function sectionControllers.api:SetVisible(visible) setWindowVisible(main,visible) end
    function sectionControllers.api:Destroy() gui:Destroy() end
    sectionControllers.example={
        players=Players,main=main,bindFrame=keybinds,
        get=function(id) return controls[id] and controls[id].get() end,
        has=function(id) return controls[id]~=nil end,
        set=function(id,value) assert(controls[id],'Unknown control: '..tostring(id));controls[id].set(value) end,
        observe=function(id,fn) bridge.events[id]=bridge.events[id] or {};table.insert(bridge.events[id],fn) end,
        connect=function(signal,fn) return connectOwned(gui,signal,fn) end,
        destroyed=function(fn) connectOwned(gui,gui.Destroying,fn) end,
        toggle=toggle,slider=slider,dropdown=dropdown,color=colorRow,keybind=keybind,action=actionRow,parseColor=parseColor,
        accent=function() return theme.Accent end,background=function() return theme.Background end,
        addTab=function(name)
            assert(type(name)=='string' and name~='','Tab name is required')
            if not pages[name] then options.Pages[#options.Pages+1]=name;addNativeTab(name,#options.Pages);paintTabs() end
            return pages[name]
        end,
        columns=featureColumns,
        selectTab=setTab,
        group=function(parent,title,id)
            local body,shell=sectionTitle(parent,title,id,{settings=true})
            sectionControllers[shell]();return body,shell
        end,
        showBinds=function(value) setWindowVisible(keybinds,value==true) end,
        toggleMenu=function() setWindowVisible(main,not main:GetAttribute('VisibleTarget')) end,
        setTitle=function(title) brand.Text=title end,
        notify=function(message,duration) notify(scriptName,message,nil,duration) end,
        setWatermark=function(value) if sectionControllers.watermark then sectionControllers.watermark.setText(value) end end,
        findBind=function(id) for _,record in ipairs(keybindRecords) do if record.id==id then return record end end end,
        bindChanged=function(id,fn) bridge.active[id]=fn end,
        setBindActive=keybindRecords.setActive,updateBinds=updateBindList,
    }
    function sectionControllers.example.input(parent,title,id,initial,info)
        local r=row(parent,36)
        text(r,title,UDim2.new(),UDim2.new(1,0,0,12),8)
        local box=new('TextBox',{
            Name=id..'Input',Text=initial,PlaceholderText=info.Placeholder or '',ClearTextOnFocus=false,
            Position=UDim2.fromOffset(0,14),Size=UDim2.new(1,0,0,20),BackgroundColor3=theme.Inline,
            TextColor3=theme.Text,Font=uiFont,TextSize=8,BorderSizePixel=0,TextXAlignment=Enum.TextXAlignment.Left,
        },r)
        round(box,5);styleSurface(box,'Input');bind(box,'BackgroundColor3','Inline');bind(box,'TextColor3','Text')
        searchTag(r,title,id,'Input');new('UIPadding',{PaddingLeft=UDim.new(0,6)},box)
        local updating=false
        local function set(value)
            value=tostring(value or '')
            if info.MaxLength then value=value:sub(1,math.max(0,info.MaxLength)) end
            if info.Numeric and value~='' and not tonumber(value) then value=values[id] or initial end
            values[id]=value
            if box.Text~=value then updating=true;box.Text=value;updating=false end
        end
        register(id,initial,set);set(initial)
        connectOwned(box,box:GetPropertyChangedSignal('Text'),function() if not updating and not info.Finished then set(box.Text) end end)
        connectOwned(box,box.FocusLost,function(enter) if not info.Finished or enter then set(box.Text) else updating=true;box.Text=values[id];updating=false end end)
        return box,r
    end
    function sectionControllers.example.fitLayout()
        if not options.Compatibility or not main.Parent then return end
        if main.Size.X.Offset~=mainWidth or main.Size.Y.Offset~=mainHeight then
            main.Size=UDim2.fromOffset(mainWidth,mainHeight)
            main.Position=windowPosition(main,main.Position.X.Offset,main.Position.Y.Offset)
        end
    end
    sectionControllers.example.columns=function(page,name)
        local left,right=featureColumns(page,name)
        for _,column in ipairs({left,right}) do
            local layout=column:FindFirstChildOfClass('UIListLayout')
            connectOwned(column,layout:GetPropertyChangedSignal('AbsoluteContentSize'),sectionControllers.example.fitLayout)
        end
        task.defer(sectionControllers.example.fitLayout)
        return left,right
    end
    function sectionControllers.example.tooltip(anchor,message)
        local tip,revision=nil,0
        local function hide() revision=revision+1;if tip then tip:Destroy();tip=nil end end
        connectOwned(anchor,anchor.MouseEnter,function()
            revision=revision+1;local token=revision
            task.delay(.35,function()
                if token~=revision or not alive or not anchor.Parent then return end
                local measured=game:GetService('TextService'):GetTextSize(tostring(message),8,uiFont,Vector2.new(190,1000))
                local width,height=math.min(206,measured.X+14),math.max(24,measured.Y+12)
                tip=frame(canvas,UDim2.new(),UDim2.fromOffset(width,height),'DropdownSurface')
                tip.Name='ExampleTooltip';tip.ZIndex=10001;tip.Active=false;round(tip,6)
                local p=anchor.AbsolutePosition-canvas.AbsolutePosition
                tip.Position=windowPosition(tip,p.X/uiScale.Scale,p.Y/uiScale.Scale+anchor.AbsoluteSize.Y/uiScale.Scale+4)
                local label=text(tip,tostring(message),UDim2.fromOffset(7,5),UDim2.new(1,-14,1,-10),8,'Text');label.TextWrapped=true;label.Active=false
            end)
        end)
        connectOwned(anchor,anchor.MouseLeave,hide);connectOwned(anchor,anchor.Destroying,hide)
    end
    function sectionControllers.example.resizeLabel(label,r,wrap)
        local lines=1;for _ in label.Text:gmatch('\n') do lines=lines+1 end
        local height=math.max(14,lines*12)
        if wrap then
            local available=math.max(30,columnWidth-22)
            local measured=game:GetService('TextService'):GetTextSize(label.Text,8,uiFont,Vector2.new(available,10000))
            height=math.max(height,measured.Y+2)
        end
        r.Size=UDim2.new(1,0,0,height);label.Size=UDim2.fromScale(1,1);label.TextWrapped=wrap==true
    end
    function sectionControllers.example.label(parent,value,wrap)
        local label,r=labelRow(parent,value,14)
        sectionControllers.example.resizeLabel(label,r,wrap);return label,r
    end
    function sectionControllers.example.divider(parent)
        local r=row(parent,7);local line=frame(r,UDim2.new(0,0,.5,0),UDim2.new(1,0,0,1),'Outline');line.BackgroundTransparency=.6;return line
    end
    function sectionControllers.example.container(parent)
        local body=row(parent,0)
        local layout=new('UIListLayout',{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder},body)
        local busy=false
        local function fit()
            if busy or not body.Parent then return end
            busy=true
            local height=math.max(0,layout.AbsoluteContentSize.Y/math.max(uiScale.Scale,.001))
            if body.Size.Y.Offset~=height then body.Size=UDim2.new(1,0,0,height) end
            busy=false
        end
        connectOwned(body,layout:GetPropertyChangedSignal('AbsoluteContentSize'),fit)
        connectOwned(body,body.DescendantAdded,function(child)
            if child.Parent==body and child:IsA('GuiObject') then
                connectOwned(child,child:GetPropertyChangedSignal('Visible'),fit)
                connectOwned(child,child:GetPropertyChangedSignal('Size'),fit)
            end
            task.defer(fit)
        end)
        connectOwned(body,body.DescendantRemoving,function() task.defer(fit) end)
        task.defer(fit)
        return body
    end
    function sectionControllers.example.tabbox(parent,methods,decorate,uid)
        local body,shell=sectionTitle(parent,'Tabs',uid(),{settings=true})
        sectionControllers[shell]()
        local header=rawRow(body,20)
        local tabs,selected={},nil
        local box={Tabs=tabs,Holder=shell}
        local function select(name)
            selected=name
            for key,tab in pairs(tabs) do tab._body.Visible=key==name;bind(tab.Button,'TextColor3',key==name and 'SelectedText' or 'Unselected') end
            local chosen=tabs[name]
            if chosen then
                local p,s=chosen.Button.Position,chosen.Button.Size
                animate(box.Selection,{Position=p,Size=s},motion.Tab)
            end
        end
        box.Selection=frame(header,UDim2.new(),UDim2.fromOffset(54,18),'SelectedSurface');round(box.Selection,4)
        function box:AddTab(name)
            assert(not tabs[name],'Duplicate tabbox tab')
            local count=0;for _ in pairs(tabs) do count=count+1 end
            local width=math.max(40,math.ceil(game:GetService('TextService'):GetTextSize(name,8,uiFont,Vector2.new(1000,18)).X)+16)
            local x=0;for _,existing in pairs(tabs) do x=x+existing.Button.Size.X.Offset+4 end
            local b=button(header,name,UDim2.fromOffset(x,0),UDim2.fromOffset(width,18));b.BackgroundTransparency=1;b.ZIndex=2
            local container=sectionControllers.example.container(body);container.Name='Tabbox_'..name
            container:SetAttribute('SearchVariant',name)
            sectionControllers[container]=function() select(name);return true end
            local tab=setmetatable({_body=container,Button=b}, {__index=methods});tabs[name]=tab
            connectOwned(b,b.Activated,function() select(name) end)
            function tab:ShowTab() select(name) end
            select(selected or name);return tab
        end
        return box
    end
    Library:_attach(sectionControllers.api,sectionControllers.example)

    options.Build(sectionControllers.api)


    local defaultSnapshot

    local configRemote
    local configs,selectedConfig={},nil
    local configCol=column(pages[options.SettingsPage or "Settings"],0,columnWidth)
    sectionTitle(configCol,"Profiles",nil,{settings=true})
    local configPanel=row(configCol,114)
    local configList=new("ScrollingFrame",{Name="ConfigList",Position=UDim2.fromOffset(0,0),Size=UDim2.new(1,0,0,44),BackgroundColor3=theme.Inline,BorderSizePixel=0,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2},configPanel)
    bind(configList,'BackgroundColor3','DropdownSurface');bind(configList,'ScrollBarImageColor3','Accent')
    configList.ScrollBarImageTransparency=.55
    new("UIListLayout",{Padding=UDim.new(0,1),SortOrder=Enum.SortOrder.LayoutOrder},configList)
    local configName=new("TextBox",{Name="ConfigName",Position=UDim2.fromOffset(0,49),Size=UDim2.new(1,0,0,18),BackgroundColor3=theme.Inline,TextColor3=theme.Unselected,PlaceholderColor3=theme.Unselected,Font=uiFont,TextSize=7.5,Text="",PlaceholderText="",ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,BorderSizePixel=0},configPanel)
    bind(configName,'BackgroundColor3','Inline');bind(configName,'TextColor3','Unselected');bind(configName,'PlaceholderColor3','Unselected')
    connectOwned(configName,configName.Focused,function() bind(configName,'TextColor3','SelectedText',motion.Hover) end)
    connectOwned(configName,configName.FocusLost,function() bind(configName,'TextColor3','Unselected',motion.Hover) end)
    searchTag(configName,"Config Name","ConfigName","Input")
    local function snapshot()
        themeUpdates.flush(true)
        local data={}
        for id,c in pairs(controls) do
            local value=c.get()
            if type(value)=="table" then local copy={};for k,v in pairs(value) do copy[k]=v end;data[id]=copy else data[id]=value end
        end
        data.Layout={MainX=main.Position.X.Offset,MainY=main.Position.Y.Offset,KeybindX=keybinds.Position.X.Offset,KeybindY=keybinds.Position.Y.Offset,KeybindVisible=keybinds:GetAttribute("VisibleTarget")==true}
        if sectionControllers.watermark then
            data.Layout.WatermarkX,data.Layout.WatermarkY,data.Layout.WatermarkMoved=sectionControllers.watermark.getLayout()
        end
        return data
    end
    local function restore(data)
        if type(data)~="table" then return end
        restoringConfig=true;themeUpdates.reset()
        for id,value in pairs(data) do if controls[id] and not controls[id].derived and id~="ThemePreset" and not themeUpdates.restoreKeys[id] then controls[id].set(value) end end
        if type(data.ThemePreset)=="string" then controls.ThemePreset.set(data.ThemePreset) end
        themeUpdates.restore(data)
        restoringConfig=false
        if sectionControllers.syncRuntime then sectionControllers.syncRuntime() end
        local layout=data.Layout
        if type(layout)=="table" then
            local function n(key,default)
                local value=tonumber(layout[key])
                return value and value==value and value~=math.huge and value~=-math.huge and value or default
            end
            animate(main,{Position=windowPosition(main,n("MainX",defaultMainX),n("MainY",defaultMainY))},motion.Window)
            animate(keybinds,{Position=windowPosition(keybinds,n("KeybindX",104),n("KeybindY",260))},motion.Window)
            if type(layout.KeybindVisible)=="boolean" then setWindowVisible(keybinds,layout.KeybindVisible) end
            if sectionControllers.watermark and type(layout.WatermarkMoved)=='boolean' then
                sectionControllers.watermark.setLayout(n('WatermarkX',0),n('WatermarkY',12),layout.WatermarkMoved)
            end

        end
        applyTheme();updateBindList();setTab(currentTab)
    end
    local function refreshConfigList()
        for _,obj in ipairs(configList:GetChildren()) do if obj:IsA("GuiObject") then obj:Destroy() end end
        local names={};for name in pairs(configs) do names[#names+1]=name end;table.sort(names)
        for _,name in ipairs(names) do
            local b=button(configList,name,UDim2.new(),UDim2.new(1,0,0,16))
            b.TextXAlignment=Enum.TextXAlignment.Left
            b:SetAttribute('NoHover',true)
            local chosen=selectedConfig==name
            local function paint(over)
                bind(b,'BackgroundColor3',chosen and 'DropdownSelection' or over and 'DropdownHover' or 'DropdownSurface',motion.Hover)
                bind(b,'TextColor3',chosen and 'SelectedText' or 'Unselected',motion.Hover)
            end
            paint(false)
            connectOwned(b,b.MouseEnter,function() paint(true) end)
            connectOwned(b,b.MouseLeave,function() paint(false) end)
            if motionReady then b.TextTransparency=.35;animate(b,{TextTransparency=0},motion.Hover) end
            connectOwned(b,b.Activated,function() selectedConfig=name;configName.Text=name;refreshConfigList() end)
        end
    end
    local busy,requestSerial=false,0
    local function configAction(action)
        if busy then return end
        local name=action=="save" and configName.Text:match("^%s*(.-)%s*$") or selectedConfig
        if action~="list" and (not name or name=="") then notify("No profile selected");return end
        if name then
            local length=utf8.len(name)
            if not length or length>40 or name:find("[%z\1-\31]") then notify("Invalid profile name");return end
        end
        local payload=action=="save" and snapshot() or nil
        busy=true
        requestSerial=requestSerial+1
        local serial=requestSerial
        task.delay(12,function()
            if alive and busy and requestSerial==serial then busy=false;requestSerial=requestSerial+1;notify(scriptName,"Request timed out") end
        end)
        task.spawn(function()
            local ok,result=true,nil
            if configRemote then ok,result=pcall(function() return configRemote:InvokeServer(action,name,payload) end)
            elseif Library.SaveManager.Library==Library then ok,result=pcall(function() return Library.SaveManager:_action(action,name,payload) end) end
            if not alive or requestSerial~=serial then return end
            busy=false
            if not ok or (result and (type(result)~="table" or result.ok==false)) then notify(scriptName,type(result)=="table" and result.error or "Config request failed.");return end
            if result and type(result.configs)=="table" then configs=result.configs end
            if action=="save" then configs[name]=result and result.configs and result.configs[name] or payload;selectedConfig=name;notify(result and result.storage=="persistent" and "Saved" or "Saved in session",name)
            elseif action=="load" then if configs[name] then restore(configs[name]);notify("Loaded",name) end
            elseif action=="delete" then configs[name]=nil;selectedConfig=nil;notify("Deleted",name)
            elseif action=="auto" then notify("Auto Load Config",name)
            end
            refreshConfigList()
        end)
    end
    for i,entry in ipairs({{"Save","save"},{"Load","load"},{"Delete","delete"},{"Refresh","list"}}) do
        local b=button(configPanel,entry[1],UDim2.new((i-1)%2*.5,(i-1)%2*2,0,72+math.floor((i-1)/2)*22),UDim2.new(.5,-2,0,18))
        connectOwned(b,b.Activated,function() configAction(entry[2]) end)
    end
    sectionControllers.example.snapshot=snapshot
    sectionControllers.example.restore=restore
    sectionControllers.example.configPanel=configPanel
    sectionControllers.example.configList=function() configAction("list") end
    sectionControllers.example.buildConfig=function(tab)
        configCol.Parent=tab.Right;configCol.Visible=true
        local layout=configCol:FindFirstChildOfClass("UIListLayout")
        local function fit() configCol.Size=UDim2.new(1,0,0,math.max(28,layout.AbsoluteContentSize.Y/math.max(uiScale.Scale,.001)));configCol.CanvasSize=UDim2.new() end
        connectOwned(configCol,layout:GetPropertyChangedSignal("AbsoluteContentSize"),fit);fit()
    end
    if options.Compatibility then
        configCol.Visible=false
        actionRow(configCol,'Set Autoload',function() configAction('auto') end)
        actionRow(configCol,'Load Autoload',function() Library.SaveManager:LoadAutoloadConfig() end)
    end
    local menuCol=column(pages[options.SettingsPage or "Settings"],rightColumnX,columnWidth)
    if options.Compatibility then menuCol.Visible=false end
    sectionTitle(menuCol,"Menu",nil,{settings=true})
    keybind(menuCol,"Menu Bind","MenuBind","Z")
    toggle(menuCol,"Watermark","WatermarkVisible",true,function(shown)
        if sectionControllers.watermark then sectionControllers.watermark.setVisible(shown) end
    end)
    actionRow(menuCol,"Keybind List",function() setWindowVisible(keybinds,not keybinds:GetAttribute("VisibleTarget")) end)
    actionRow(menuCol,"Reset Positions",function()
        animate(main,{Position=windowPosition(main,defaultMainX,defaultMainY)},motion.Window)
        animate(keybinds,{Position=windowPosition(keybinds,104,260)},motion.Window)
        if sectionControllers.watermark then sectionControllers.watermark.reset() end
    end)
    actionRow(menuCol,"Factory Reset",function() if defaultSnapshot then restore(defaultSnapshot);notify(scriptName,"Settings restored.") end end)
    sectionTitle(menuCol,"Theme",nil,{settings=true})
    local themeRows={{"Accent","Accent"},{"Background","Background"},{"Panels","Section"}}
    local function currentPalette()
        local palette={}
        for key,color in pairs(theme) do palette[key]=colorHex(color) end
        palette.Style={};for key,value in pairs(themeStyle) do palette.Style[key]=value end
        return palette
    end
    local function copyThemeStyle(source)
        local result={}
        for key,initial in pairs(themePresets.White.style) do
            local value=type(source)=='table' and tonumber(source[key]) or nil
            if not value or value~=value or value==math.huge or value==-math.huge then value=initial end
            local low,high=0,1
            if key:find('Radius',1,true) then low,high=3,14
            elseif key=='BorderWidth' then low,high=.8,1.25
            elseif key=='GradientBottom' or key=='BackdropBottom' then low,high=.84,1
            elseif key=='GlowStrength' then low,high=.02,.15 end
            result[key]=math.clamp(value,low,high)
        end
        return result
    end
    local initialPalette=currentPalette()
    register("CustomTheme",initialPalette,function(palette)
        local saved={}
        for key,initial in pairs(initialPalette) do
            if key~='Style' then
                local color=type(palette)=="table" and parseColor(palette[key]) or nil
                saved[key]=color and colorHex(color) or initial
            end
        end
        saved.Style=copyThemeStyle(type(palette)=='table' and palette.Style)
        values.CustomTheme=saved
    end)
    controls.CustomTheme.set(initialPalette)
    local function syncThemePickers(live)
        for i,entry in ipairs(themeRows) do
            local control=controls["Theme"..i]
            if control then control.set(theme[entry[2]],true,live) end
        end
    end
    themeUpdates.onSync=syncThemePickers
    themeUpdates.onCustom=function() if controls.ThemePreset and values.ThemePreset~='Custom' then controls.ThemePreset.set('Custom',true) end end
    themeUpdates.onCommit=function() controls.CustomTheme.set(currentPalette()) end
    for i,entry in ipairs(themeRows) do
        local themeKey=entry[2]
        colorRow(menuCol,entry[1],'Theme'..i,theme[themeKey],function(color)
            themeUpdates.edit(themeKey,color)
        end,{themeKey=themeKey})
    end
    dropdown(menuCol,"Themes","ThemePreset",{"White","Mint","Default","Amethyst","Rose","Yellow","Graphite","Custom"},"White",false,function(name)
        themeUpdates.flush(true);themeUpdates.reset(true)
        if name=="Custom" then
            for key,value in pairs(values.CustomTheme) do if key~='Style' then theme[key]=parseColor(value) or theme[key] end end
            for key,value in pairs(copyThemeStyle(values.CustomTheme.Style)) do themeStyle[key]=value end
        elseif themePresets[name] then
            for key,value in pairs(themePresets[name].colors) do theme[key]=value end
            for key,value in pairs(themePresets[name].style) do themeStyle[key]=value end
        end
        syncThemePickers();applyTheme()
    end)
    do
        local effectIds={'IntroAnimation','RevealEffects','HeroHeading','GlowEffects'}
        local saved,changing=nil,false
        local function syncRuntime()
            if changing or restoringConfig then return end
            local any=false
            for _,id in ipairs(effectIds) do if values[id]==true then any=true end end
            if any then
                saved={};for _,id in ipairs(effectIds) do saved[id]=values[id]==true end
            end
            controls.PresentationEnabled.sync(any)
            if controls.BackgroundEnabled then controls.BackgroundEnabled.sync(values.BackgroundEffect~='Off') end
            if values.NotificationsEnabled==false then
                for _,entry in ipairs(noticeEntries) do if entry.slot.Parent then entry.slot:Destroy() end end
                noticeEntries={}
            end
            if sectionControllers.syncAllBinds then sectionControllers.syncAllBinds() end
            paintTabs()
            if presentation and motionReady then presentation.refresh() end
        end
        sectionControllers.syncRuntime=syncRuntime
        sectionTitle(menuCol,'Presentation','PresentationEnabled',{initial=true,derived=true,changed=function(state)
            changing=true
            if not state then
                saved={};for _,id in ipairs(effectIds) do saved[id]=values[id]==true end
                for _,id in ipairs(effectIds) do controls[id].set(false) end
            else
                for _,id in ipairs(effectIds) do controls[id].set(not saved or saved[id]==true) end
            end
            changing=false;syncRuntime()
        end})
        toggle(menuCol,'Intro animation','IntroAnimation',true,syncRuntime)
        toggle(menuCol,'Card transitions','RevealEffects',true,syncRuntime)
        toggle(menuCol,'Title reveal','HeroHeading',true,syncRuntime)
        toggle(menuCol,'Highlights & glow','GlowEffects',true,syncRuntime)
        actionRow(menuCol,'Replay Intro',function() if values.PresentationEnabled and presentation then presentation.playIntro(true) end end)
        sectionTitle(menuCol,'Background','BackgroundEnabled',{derived=true,changed=function(state)
            controls.BackgroundEffect.set(state and 'Snow' or 'Off')
        end})
        dropdown(menuCol,'Effect','BackgroundEffect',{'Off','Snow'},'Off',false,syncRuntime)
    end
    slider(menuCol,"Intensity","WeatherStrength",80,10,100,1,"%",function() if presentation then presentation.refresh() end end)
    slider(menuCol,"Density","WeatherDensity",20,8,40,1,"",function() if presentation then presentation.refresh() end end)
    slider(menuCol,"Speed","WeatherSpeed",1,.25,2,.05,"×",function() if presentation then presentation.refresh() end end)
    actionRow(menuCol,"Restart effect",function() if presentation then presentation.restartBackground() end end)
    local function installGlobalSearch()
        local shell=frame(pageHeader,UDim2.new(1,-8,.5,0),UDim2.fromOffset(164,20),"SearchSurface")
        shell.Name="GlobalSearch";shell.AnchorPoint=Vector2.new(1,.5);round(shell,5);controlBackplate(shell);styleSurface(shell,"Input")
        local function shadeSearch()
            animate(shell,{BackgroundColor3=themeColor('SearchSurface')},motion.Control)
        end
        appearanceRefreshers[#appearanceRefreshers+1]=shadeSearch
        shadeSearch()
        local input=new("TextBox",{
            Name="GlobalSearchInput",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,
            Text="",PlaceholderText="",ClearTextOnFocus=false,MultiLine=false,
            Font=uiFont,TextSize=8,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2,
        },shell)
        bind(input,"TextColor3","Text");bind(input,"PlaceholderColor3","Unselected")
        new("UIPadding",{PaddingLeft=UDim.new(0,21),PaddingRight=UDim.new(0,22)},input)
        local lens=frame(shell,UDim2.fromOffset(7,6),UDim2.fromOffset(6,6))
        lens.ZIndex=3;round(lens,6)
        local lensEdge=new("UIStroke",{Thickness=1,Transparency=.2},lens);bind(lensEdge,"Color","Unselected")
        local handle=frame(shell,UDim2.fromOffset(12,12),UDim2.fromOffset(4,1),"Unselected")
        handle.Rotation=45;handle.ZIndex=3
        local clear=button(shell,"×",UDim2.new(1,-20,0,0),UDim2.fromOffset(20,20))
        clear.Name="GlobalSearchClear";clear.BackgroundTransparency=1;clear.ZIndex=4;clear.Visible=false
        clear:SetAttribute("NoBackplateBorder",true);clear.ControlBorder.Enabled=false
        local entries,results,resultButtons={},{},{}
        local selected,searchPopup,resultPanel,status=1,nil,nil,nil
        local navigationRevision=0
        local aliases={
            ["аим"]="aim",["аимбот"]="aim",["триггер"]="trigger",["сайлент"]="silent",
            ["скелет"]="skeleton",["скелетон"]="skeleton",["уведомления"]="notification",
            ["тема"]="theme",["темы"]="theme",["конфиг"]="config",["настройки"]="settings",
            ["цвет"]="color",["радиус"]="radius",["ползунок"]="slider",["тоггл"]="toggle",
        }
        local function normalized(value)
            value=tostring(value or "")
            local ok,lower=pcall(function()
                local chars={}
                for _,code in utf8.codes(value) do
                    if code>=1040 and code<=1071 then code=code+32 elseif code==1025 then code=1105 end
                    chars[#chars+1]=utf8.char(code)
                end
                return table.concat(chars):lower()
            end)
            return (ok and lower or value:lower()):gsub("%s+"," "):match("^%s*(.-)%s*$")
        end
        local function context(object)
            local tab,section,column,variant
            local node=object
            while node and node~=main do
                if not section and node:GetAttribute("SectionName") then section=node end
                if not column and node:IsA("ScrollingFrame") then column=node end
                if node:GetAttribute("SearchVariant") then variant=node:GetAttribute("SearchVariant") end
                for name,page in pairs(pages) do if node==page then tab=name end end
                node=node.Parent
            end
            return tab,section,column,variant
        end
        local function add(object,label,id,kind,terms)
            local tab,section,column,variant=context(object)
            if not tab or not label or label=="" then return end
            local path=tab
            if section then path=path.." › "..section:GetAttribute("SectionName") end
            if variant then path=path.." › "..variant end
            local entry={target=object,label=label,id=id or "",kind=kind or "Control",tab=tab,section=section,column=column,variant=variant,path=path,order=#entries+1}
            entry.name=normalized(label)
            entry.haystack=normalized(label.." "..entry.id.." "..entry.kind.." "..path.." "..(terms or ""))
            entries[#entries+1]=entry
        end
        local function reindex()
            entries={}
        for _,tab in ipairs(options.Pages) do
            for _,object in ipairs(pages[tab]:GetDescendants()) do
                local label=object:GetAttribute("SearchLabel")
                if label then
                    add(object,label,object:GetAttribute("SearchId"),object:GetAttribute("SearchKind"),object:GetAttribute("SearchTerms"))
                elseif object:IsA("GuiButton") and object.Text~="" then
                    local node,covered=object.Parent,false
                    while node and node~=main do
                        if node:GetAttribute("SearchLabel") then covered=true;break end
                        node=node.Parent
                    end
                    if not covered then add(object,object.Text:match("^%s*(.-)%s*$"),nil,"Button") end
                end
            end
        end
        end
        reindex()
        local function activeResults()
            return searchPopup and popup==searchPopup and searchPopup.Parent and not searchPopup:GetAttribute("Closing")
        end
        local function hideResults()
            if activeResults() then closePopup() end
            searchPopup=nil;resultPanel=nil;status=nil;resultButtons={};results={}
        end
        local function siblingsBefore(object,parent,factor)
            local layout=parent:FindFirstChildOfClass("UIListLayout")
            if not layout then
                local anchor=object.AnchorPoint or Vector2.zero
                return object.Position.Y.Offset+object.Position.Y.Scale*parent.AbsoluteSize.Y/factor-anchor.Y*object.AbsoluteSize.Y/factor
            end
            local children={}
            for order,child in ipairs(parent:GetChildren()) do
                if child:IsA("GuiObject") and child.Visible then children[#children+1]={object=child,order=order} end
            end
            table.sort(children,function(a,b)
                if a.object.LayoutOrder==b.object.LayoutOrder then return a.order<b.order end
                return a.object.LayoutOrder<b.object.LayoutOrder
            end)
            local offset=0
            local padding=layout.Padding.Offset+layout.Padding.Scale*parent.AbsoluteSize.Y/factor
            for _,child in ipairs(children) do
                if child.object==object then break end
                offset=offset+child.object.AbsoluteSize.Y/factor+padding
            end
            return offset
        end
        local function reveal(entry)
            if not entry or not entry.target.Parent then return end
            navigationRevision=navigationRevision+1
            local revision,locateRevision=navigationRevision,0
            input:ReleaseFocus(false);input.Text="";clear.Visible=false;hideResults()
            setTab(entry.tab)
            local function locate(target)
                locateRevision=locateRevision+1
                local request=locateRevision
                task.delay(motion.PageOut+math.max(motion.Page,motion.SectionOpen)+.02,function()
                    if not alive or revision~=navigationRevision or request~=locateRevision or currentTab~=entry.tab or not target.Parent then return end
                    local column=entry.column
                    if column and column.Parent then
                        local factor=math.max(uiScale.Scale*main.WindowScale.Scale,.001)
                        local offset,node=0,target
                        while node and node~=column do
                            local parent=node.Parent
                            if not parent then break end
                            offset=offset+siblingsBefore(node,parent,factor);node=parent
                        end
                        local total,count=0,0
                        for _,child in ipairs(column:GetChildren()) do
                            if child:IsA("GuiObject") and child.Visible then total=total+child.AbsoluteSize.Y/factor;count=count+1 end
                        end
                        local layout=column:FindFirstChildOfClass("UIListLayout")
                        if layout then total=total+math.max(0,count-1)*layout.Padding.Offset end
                        local maximum=math.max(0,total-column.AbsoluteSize.Y/factor)
                        animate(column,{CanvasPosition=Vector2.new(0,math.clamp(offset-5,0,maximum))},motion.SectionOpen)
                    end
                    local surface=entry.section or target
                    local previous=surface:FindFirstChild('SearchHighlight')
                    if previous then previous:Destroy() end
                    local highlight=frame(surface,UDim2.new(),UDim2.fromScale(1,1),'Accent')
                    highlight.Name='SearchHighlight';highlight.Active=false;highlight.Selectable=false;highlight.ZIndex=0
                    highlight.BackgroundTransparency=1
                    local corner=surface:FindFirstChildOfClass('UICorner')
                    new('UICorner',{CornerRadius=corner and corner.CornerRadius or UDim.new(0,6)},highlight)
                    animate(highlight,{BackgroundTransparency=.87},motion.Hover)
                    task.delay(.75,function()
                        if alive and highlight.Parent then animate(highlight,{BackgroundTransparency=1},motion.Section,function() highlight:Destroy() end) end
                    end)
                end)
            end
            local ancestor=entry.target
            while ancestor and ancestor~=main do
                if ancestor~=entry.section and sectionControllers[ancestor] then sectionControllers[ancestor]() end
                ancestor=ancestor.Parent
            end
            local opened=true
            if entry.section and sectionControllers[entry.section] then
                opened=sectionControllers[entry.section](function()
                    if revision==navigationRevision and currentTab==entry.tab then locate(entry.target) end
                end)
            end
            locate(opened and entry.target or entry.section.SectionToggle)
        end
        local function paintResults()
            if resultPanel then resultPanel:SetAttribute("SelectedIndex",selected) end
            for i,control in ipairs(resultButtons) do
                if control.Parent then
                    local chosen=i==selected
                    bind(control,'BackgroundColor3','DropdownHover',motion.Hover)
                    animate(control,{BackgroundTransparency=chosen and 0 or 1},motion.Hover)
                    bind(control.ResultLabel,'TextColor3',chosen and 'SelectedText' or 'IdleText',motion.Hover)
                end
            end
        end
        appearanceRefreshers[#appearanceRefreshers+1]=function() if activeResults() then paintResults() end end
        local function update()
            reindex()
            local query=normalized(input.Text)
            clear.Visible=input.Text~=""
            if query=="" then hideResults();return end
            local tokens={}
            for token in query:gmatch("%S+") do tokens[#tokens+1]=aliases[token] or token end
            local matches={}
            for _,entry in ipairs(entries) do
                local match=true
                for _,token in ipairs(tokens) do if not entry.haystack:find(token,1,true) then match=false;break end end
                if match then
                    local score=entry.name==query and 0 or entry.name:sub(1,#query)==query and 1 or entry.name:find(query,1,true) and 2 or 3
                    matches[#matches+1]={entry=entry,score=score}
                end
            end
            table.sort(matches,function(a,b) if a.score==b.score then return a.entry.order<b.entry.order end;return a.score<b.score end)
            local total=#matches
            local count=math.min(total,8)
            local height=count>0 and count*22+8 or 26
            local width=220
            for i=1,count do
                local entry=matches[i].entry
                entry.fullPath=entry.path..(entry.kind=='Section' and '' or ' › '..entry.label)
                width=math.max(width,game:GetService('TextService'):GetTextSize(entry.fullPath,8,uiFont,Vector2.new(1000,24)).X+28)
            end
            local leftBound,_,rightBound=viewportBounds()
            width=math.min(width,mainWidth-16,rightBound-leftBound-8)
            if not activeResults() then
                resultPanel=popupAt(shell,width,height);searchPopup=resultPanel.Parent;resultPanel.Active=true
                styleSurface(resultPanel,'Popup')
                resultPanel.ClipsDescendants=true;controlBackplate(resultPanel)
                searchPopup.PopupShield.Visible=false;searchPopup.PopupShield.Active=false
                resultPanel:SetAttribute("GlobalSearchResults",true)
                status=text(resultPanel,"",UDim2.fromOffset(8,5),UDim2.new(1,-16,0,13),7.5,"Unselected");status.Name="SearchStatus"
            else
                for _,control in ipairs(resultButtons) do control:Destroy() end
            end
            local left,top,right,bottom=viewportBounds()
            local anchor=(shell.AbsolutePosition-canvas.AbsolutePosition)/uiScale.Scale
            local x=math.clamp(anchor.X,left+4,math.max(left+4,right-width-4))
            local y=anchor.Y+shell.AbsoluteSize.Y/uiScale.Scale+2
            if y+height>bottom-4 then y=anchor.Y-height-2 end
            y=math.clamp(y,top+4,math.max(top+4,bottom-height-4))
            animate(resultPanel,{Position=UDim2.fromOffset(x-left,y-top),Size=UDim2.fromOffset(width,height)},motion.Popup)
            results={};resultButtons={};selected=1
            for i=1,count do
                local entry=matches[i].entry;results[i]=entry
                local control=button(resultPanel,"",UDim2.fromOffset(4,4+(i-1)*22),UDim2.new(1,-8,0,20))
                control.Name="SearchResult"..i;control:SetAttribute("ResultId",entry.id);control:SetAttribute("ResultTab",entry.tab)
                control:SetAttribute('FullPath',entry.fullPath)
                control:SetAttribute("NoHover",true);control:SetAttribute("NoBackplateBorder",true);control.ControlBorder.Enabled=false
                control:FindFirstChildOfClass("UICorner").CornerRadius=UDim.new(0,6)
                local label=text(control,entry.fullPath,UDim2.fromOffset(8,0),UDim2.new(1,-16,1,0),8,"Text")
                label.Name="ResultLabel";label.TextWrapped=false
                resultButtons[i]=control
                connectOwned(control,control.MouseEnter,function() selected=i;paintResults() end)
                connectOwned(control,control.Activated,function() reveal(entry) end)
            end
            status.Visible=false;status.Text="";resultPanel.Visible=count>0
            resultPanel:SetAttribute("ResultCount",total)
            paintResults()
        end
        connectOwned(input,input:GetPropertyChangedSignal("Text"),update)
        connectOwned(input,input.Focused,function() bind(input,'TextColor3','SelectedText',motion.Hover);if input.Text~="" then update() end end)
        connectOwned(input,input.FocusLost,function(enter) bind(input,'TextColor3','Text',motion.Hover);if enter then reveal(results[selected]) end end)
        connectOwned(input,input.InputBegan,function(key)
            if key.KeyCode==Enum.KeyCode.Escape then
                input.Text="";clear.Visible=false;input:ReleaseFocus(false);hideResults()
            elseif (key.KeyCode==Enum.KeyCode.Up or key.KeyCode==Enum.KeyCode.Down) and #results>0 then
                selected=(selected-1+(key.KeyCode==Enum.KeyCode.Down and 1 or -1))%#results+1
                input.CursorPosition=#input.Text+1;input.SelectionStart=-1;paintResults()
            end
        end)
        connectOwned(clear,clear.Activated,function() input.Text="";clear.Visible=false;hideResults();input:CaptureFocus() end)
        connectOwned(shell,UIS.InputBegan,function(key)
            if not activeResults() or (key.UserInputType~=Enum.UserInputType.MouseButton1 and key.UserInputType~=Enum.UserInputType.Touch) then return end
            local function inside(object)
                local p,s=object.AbsolutePosition,object.AbsoluteSize
                return key.Position.X>=p.X and key.Position.X<=p.X+s.X and key.Position.Y>=p.Y and key.Position.Y<=p.Y+s.Y
            end
            if not inside(shell) and not inside(resultPanel) then hideResults() end
        end)
    end

    installGlobalSearch()

    connect(UIS.InputChanged,function(input)
        if not activeDrag then return end
        local t=input.UserInputType
        if t~=Enum.UserInputType.MouseMovement and t~=Enum.UserInputType.Touch then return end
        if t==Enum.UserInputType.Touch and input~=activeDrag.input then return end
        local drag=activeDrag
        if drag.kind=="window" then
            local delta=(Vector2.new(input.Position.X,input.Position.Y)-drag.start)/uiScale.Scale
            animate(drag.object,{Position=windowPosition(drag.object,drag.position.X.Offset+delta.X,drag.position.Y.Offset+delta.Y)},0)
            if drag.object==main and fitPresentation then fitPresentation()
            elseif drag.object.Name=='Watermark' and fitNotifications then fitNotifications(false) end
        else drag.update(input.Position.X,input.Position.Y) end
    end)
    connect(UIS.InputEnded,function(input)
        if activeDrag and (input==activeDrag.input or input.UserInputType==Enum.UserInputType.MouseButton1) then
            local colorDrag=activeDrag.kind=="color";activeDrag=nil
            if colorDrag then themeUpdates.flush(true) end
        end
        for _,record in ipairs(keybindRecords) do
            if record.mode=="Hold" and keybindRecords.matches(input,values[record.id]) then keybindRecords.setActive(record,false);updateBindList() end
        end
    end)
    connect(UIS.WindowFocusReleased,function()
        activeDrag=nil;themeUpdates.flush(true)
        for _,record in ipairs(keybindRecords) do if record.mode=="Hold" then keybindRecords.setActive(record,false) end end
        updateBindList()
    end)
    connect(UIS.InputBegan,function(input,processed)
        if UIS:GetFocusedTextBox() then return end
        if capture then
            if input.UserInputType==Enum.UserInputType.Keyboard then
                capture.set(input.KeyCode==Enum.KeyCode.Escape and "Unknown" or input.KeyCode.Name);capture=nil
            elseif input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.MouseButton2 or input.UserInputType==Enum.UserInputType.MouseButton3 then
                capture.set(input.UserInputType.Name);capture=nil
            end
            return
        end
        if processed then
            if main:GetAttribute('VisibleTarget')~=true then keybindRecords.dispatch(input) end
            return
        end
        if input.KeyCode==Enum.KeyCode.Escape then closePopup() end
        local key=input.KeyCode~=Enum.KeyCode.Unknown and input.KeyCode.Name or input.UserInputType.Name
        local menuId=Library.ToggleKeybind and Library.ToggleKeybind._nativeId or 'MenuBind'
        if key==values[menuId] then setWindowVisible(main,not main:GetAttribute("VisibleTarget"));closePopup() end
        keybindRecords.dispatch(input)
    end)
    for _,input in ipairs(gui:GetDescendants()) do
        if input:IsA("TextBox") and input.BackgroundTransparency<.99 then
            if not input:FindFirstChildOfClass("UICorner") then round(input,2) end
            controlBackplate(input);bind(input,"BackgroundColor3","Inline")
        end
    end
    sectionControllers.watermark=(function()
        local api={moved=false}
        local mark=frame(canvas,UDim2.new(),UDim2.fromOffset(400,24),'HeaderSurface')
        mark.Name='Watermark';mark.Active=true;mark.Selectable=false;mark.ClipsDescendants=true
        mark.ZIndex=9998;round(mark,7);surfaceGradient(mark,.96);styleSurface(mark,'Panel')
        windows[#windows+1]=mark
        local border=new('UIStroke',{Thickness=1,Transparency=.72},mark)
        bind(border,'Color','Outline')
        local logoWidth=math.ceil(12*logoShape.width/logoShape.height)
        local emblem=group(mark,UDim2.fromOffset(7,6),UDim2.fromOffset(logoWidth,12))
        emblem.Name='WatermarkLogo';emblem.Active=false;drawSpectrohookMark(emblem,12)
        local titleWidth=math.ceil(game:GetService('TextService'):GetTextSize(scriptName,9,uiFont,Vector2.new(1000,24)).X)
        local titleX=7+logoWidth+5
        local title=text(mark,scriptName,UDim2.fromOffset(titleX,0),UDim2.fromOffset(titleWidth,24),9,'Accent')
        title.Name='WatermarkTitle';title.Active=false
        local divider=frame(mark,UDim2.fromOffset(titleX+titleWidth+7,8),UDim2.fromOffset(1,8),'Outline')
        divider.BackgroundTransparency=.3;divider.Active=false
        local detailsX=titleX+titleWidth+16
        local details=text(mark,'',UDim2.fromOffset(detailsX,0),UDim2.new(1,-detailsX-8,1,0),8,'Text')
        details.Name='WatermarkDetails';details.TextTruncate=Enum.TextTruncate.AtEnd;details.Active=false
        local executor='Roblox'
        local provider=type(identifyexecutor)=='function' and identifyexecutor or type(getexecutorname)=='function' and getexecutorname
        if provider then
            local ok,name=pcall(provider)
            if ok and type(name)=='string' and name:match('%S') then executor=name:gsub('%c',' '):sub(1,28) end
        end
        local fps,frames,window=nil,0,0
        local function refresh()
            if not alive or not mark.Parent then return end
            local seconds=workspace.DistributedGameTime
            local clock='—'
            if type(seconds)=='number' and seconds==seconds and seconds>=0 and seconds<math.huge then
                seconds=math.floor(seconds)
                clock=string.format('%02d:%02d:%02d',math.floor(seconds/3600),math.floor(seconds/60)%60,seconds%60)
            end
            local message=api.customText or string.format('%s FPS  ·  %s  ·  %s  ·  Server %s',fps and tostring(fps) or '—',player.Name,executor,clock)
            if details.Text~=message then details.Text=message end
            mark:SetAttribute('FPS',fps);mark:SetAttribute('PlayerName',player.Name)
            mark:SetAttribute('Executor',executor);mark:SetAttribute('ServerTime',clock)
            local left,top,right=viewportBounds()
            local measured=game:GetService('TextService'):GetTextSize(message,8,uiFont,Vector2.new(10000,24)).X
            local width=math.min(right-left-24,math.ceil(detailsX+measured+10))
            mark.Size=UDim2.fromOffset(width,24)
            if api.moved then
                mark.Position=windowPosition(mark,mark.Position.X.Offset,mark.Position.Y.Offset)
            else
                mark.Position=UDim2.fromOffset(right-width-12,top+12)
            end
            mark:SetAttribute('Moved',api.moved)
        end
        function api.setText(value) api.customText=value;refresh() end
        function api.getLayout() return mark.Position.X.Offset,mark.Position.Y.Offset,api.moved end
        function api.setLayout(x,y,moved)
            api.moved=moved==true
            if api.moved then mark.Position=windowPosition(mark,x,y) end
            refresh()
        end
        function api.setVisible(shown)
            mark.Visible=shown==true
            mark:SetAttribute('VisibleTarget',mark.Visible)
            if not mark.Visible and activeDrag and activeDrag.object==mark then activeDrag=nil end
            if mark.Visible then refresh() end
            fitNotifications(true)
        end
        function api.reset() api.moved=false;refresh() end
        connectOwned(mark,mark.InputBegan,function(input)
            if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
            closePopup();api.moved=true;mark:SetAttribute('Moved',true)
            activeDrag={kind='window',input=input,object=mark,start=Vector2.new(input.Position.X,input.Position.Y),position=mark.Position}
        end)
        connectOwned(gui,game:GetService('RunService').RenderStepped,function(dt)
            if type(dt)~='number' or dt<=0 then return end
            frames=frames+1;window=window+dt
            if window>=.35 then
                fps=math.max(1,math.floor(frames/window+.5));frames=0;window=0;refresh()
            end
        end)
        appearanceRefreshers.watch(mark,refresh)
        api.setVisible(values.WatermarkVisible~=false)
        return api
    end)()

    presentation=(function()
        local api={}
        local disposed=false
        local intro,introRevision,finishing=nil,0,false
        local pageTokens=setmetatable({},{__mode="k"})
        local visibility=setmetatable({},{__mode="k"})
        local stage=frame(main,UDim2.new(),UDim2.fromScale(1,1))
        stage.Name='PresentationBackdrop';stage.ZIndex=0
        bind(stage,'BackgroundColor3','Backdrop');stage.BackgroundTransparency=1
        stage.Active=false;stage.Selectable=false;stage.Visible=false
        stage.ClipsDescendants=true;round(stage,6);surfaceGradient(stage,.90);styleSurface(stage,'Backdrop')
        local function passive(object) object.Active=false;object.Selectable=false;return object end

        local weatherGui=new('ScreenGui',{
            Name='SpectrohookWeatherGui',ResetOnSpawn=false,IgnoreGuiInset=true,
            DisplayOrder=gui.DisplayOrder-1,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Enabled=false,
        },playerGui)
        weatherGui.ScreenInsets=Enum.ScreenInsets.None
        weatherGui:SetAttribute('ClientBuild',142)
        local backgroundBase=passive(frame(weatherGui,UDim2.new(),UDim2.new(),'Backdrop'))
        backgroundBase.Name='MenuBackgroundBase';backgroundBase.ZIndex=0
        round(backgroundBase,themeStyle.MenuRadius);surfaceGradient(backgroundBase);styleSurface(backgroundBase,'Backdrop')
        local weather=passive(frame(weatherGui,UDim2.new(),UDim2.new()))
        weather.Name='WeatherLayer';weather.ZIndex=1;weather.ClipsDescendants=true;weather.Visible=false
        local weatherMode,weatherTime='Off',0
        local weatherPools,weatherConnection,stopWeather={},nil,nil
        local weatherHasStarted,lastWeatherError=false,nil
        weather:SetAttribute('Driver','Heartbeat')
        weather:SetAttribute('RenderLayer','BehindControls')
        local function syncWeatherLayer()

            local camera=workspace.CurrentCamera
            local viewport=camera and camera.ViewportSize or gui.AbsoluteSize
            local design=Vector2.new(canvas.Size.X.Offset,canvas.Size.Y.Offset)
            local canvasScale=math.max(.001,uiScale.Scale)
            local scale=canvasScale*main.WindowScale.Scale
            local windowSize=Vector2.new(main.Size.X.Scale*design.X+main.Size.X.Offset,main.Size.Y.Scale*design.Y+main.Size.Y.Offset)*scale
            local anchor=main.AnchorPoint or Vector2.zero
            local origin=(viewport-design*canvasScale)/2
            local windowPosition=origin+Vector2.new(main.Position.X.Scale*design.X+main.Position.X.Offset,main.Position.Y.Scale*design.Y+main.Position.Y.Offset)*canvasScale
                -Vector2.new(anchor.X*windowSize.X,anchor.Y*windowSize.Y)
            local position=windowPosition+Vector2.new(contentLeft*scale,contentTop*scale)
            local size=windowSize-Vector2.new((contentLeft+8)*scale,(contentTop+8)*scale)
            weather.Position=UDim2.fromOffset(position.X,position.Y)
            weather.Size=UDim2.fromOffset(math.max(1,size.X),math.max(1,size.Y))
            backgroundBase.Position=UDim2.fromOffset(windowPosition.X,windowPosition.Y)
            backgroundBase.Size=UDim2.fromOffset(windowSize.X,windowSize.Y)
            backgroundBase.BackgroundTransparency=math.clamp(main.GroupTransparency,0,1)
            backgroundBase:FindFirstChildOfClass('UICorner').CornerRadius=UDim.new(0,themeStyle.MenuRadius*scale)
            weatherGui.DisplayOrder=gui.DisplayOrder-1
            weatherGui.Enabled=not disposed and gui.Enabled~=false and main.Visible
        end
        local randomState=79193
        local function weatherRandom(a,b)
            randomState=(randomState*48271)%2147483647
            local value=randomState/2147483647
            return a and a+(b-a)*value or value
        end
        local function crystalLine(parent,a,b,thickness,name,alpha)
            local delta=b-a
            local line=passive(frame(parent,UDim2.fromOffset((a.X+b.X)/2,(a.Y+b.Y)/2),UDim2.fromOffset(delta.Magnitude,thickness),'WeatherTint'))
            line.Name=name;line.AnchorPoint=Vector2.new(.5,.5)
            line.Rotation=math.deg(math.atan2(delta.Y,delta.X));line.BackgroundTransparency=alpha or .12
            round(line,thickness/2)
            return line
        end
        local function drawSnowflake(root,size,variant,pixelScale)
            local center=Vector2.new(size/2,size/2)
            local radius=size*.43
            local thickness=(size*pixelScale>13 and 1.1 or 1)/pixelScale
            local branches=0
            for arm=0,5 do
                local angle=-math.pi/2+arm*math.pi/3
                local direction=Vector2.new(math.cos(angle),math.sin(angle))
                crystalLine(root,center+direction*(radius*.10),center+direction*radius,thickness,'CrystalArm',.06)
                local levels=variant==1 and { .56 } or { .49,.76 }
                for _,level in ipairs(levels) do
                    local origin=center+direction*(radius*level)
                    local length=radius*(level>.65 and .19 or .30)
                    for _,sign in ipairs({-1,1}) do
                        local branch=angle+sign*math.pi/3
                        crystalLine(root,origin,origin+Vector2.new(math.cos(branch),math.sin(branch))*length,thickness*.92,'CrystalBranch',.12)
                        branches=branches+1
                    end
                end
                if variant==3 then
                    local nextAngle=angle+math.pi/3
                    crystalLine(root,center+direction*(radius*.20),center+Vector2.new(math.cos(nextAngle),math.sin(nextAngle))*(radius*.20),thickness*.8,'CrystalCore',.16)
                end
            end
            root:SetAttribute('Arms',6);root:SetAttribute('Branches',branches)
        end
        local function weatherScale()
            return math.clamp(uiScale.Scale*main.WindowScale.Scale,.5,4)
        end
        local function buildWeatherShape(particle,mode,pixelScale)
            local node=particle.node
            for _,part in ipairs(node:GetChildren()) do part:Destroy() end
            local size=(8+particle.depth*6)*pixelScale
            particle.physicalHeight=size;particle.pixelScale=pixelScale
            node.Size=UDim2.fromOffset(size,size)
            drawSnowflake(node,size,particle.variant,1)
            particle.parts={};particle.opacity=nil
            for _,part in ipairs(node:GetChildren()) do
                if part:IsA('GuiObject') then particle.parts[#particle.parts+1]={object=part,alpha=1-part.BackgroundTransparency} end
            end
        end
        local function newWeatherParticle(pool,index,pixelScale)
            local node=passive(frame(pool.root,UDim2.new(),UDim2.new()))
            node.Name='Snowflake';node.AnchorPoint=Vector2.new(.5,.5)
            local particle={node=node,x=weatherRandom(),y=weatherRandom(-.08,1.04),depth=weatherRandom(.15,1),
                phase=weatherRandom(0,math.pi*2),angle=weatherRandom(0,360),spin=weatherRandom(-12,12),variant=index%3+1}
            buildWeatherShape(particle,'Snow',pixelScale);pool.items[#pool.items+1]=particle
            return particle
        end
        local function weatherPool(mode)
            if weatherPools[mode] then return weatherPools[mode] end
            local root=passive(frame(weather,UDim2.new(),UDim2.fromScale(1,1)))
            root.Name='SnowBackground';root.Visible=false
            local pool={root=root,mode=mode,items={},blend=0,from=0,target=0,elapsed=.24}
            weatherPools[mode]=pool
            return pool
        end
        local function drawWeather(dt)
            syncWeatherLayer()
            local speed=tonumber(values.WeatherSpeed) or 1
            weatherTime=weatherTime+dt*speed
            local strength=(tonumber(values.WeatherStrength) or 80)/100
                *math.clamp(1-main.GroupTransparency,0,1)
            local pixelScale=weatherScale()
            local width,height=math.max(1,weather.AbsoluteSize.X),math.max(1,weather.AbsoluteSize.Y)
            local area=width*height/(415*315*pixelScale*pixelScale)
            local live,total=false,0
            for mode,pool in pairs(weatherPools) do
                pool.elapsed=math.min(.24,pool.elapsed+dt)
                local t=pool.elapsed/.24
                local eased=.5-.5*math.cos(math.pi*t)
                pool.blend=pool.from+(pool.target-pool.from)*eased
                if t>=1 then pool.blend=pool.target end
                pool.root.Visible=pool.target>0 or pool.blend>.0001
                pool.root:SetAttribute('Blend',pool.blend)
                if pool.root.Visible then
                    live=true
                    local count=math.clamp(math.floor((tonumber(values.WeatherDensity) or 20)*area+.5),8,64)
                    while #pool.items<count do newWeatherParticle(pool,#pool.items+1,pixelScale) end
                    for index,particle in ipairs(pool.items) do
                        local node=particle.node
                        node.Visible=index<=count
                        if node.Visible then
                            if math.abs(pixelScale/particle.pixelScale-1)>.08 then buildWeatherShape(particle,mode,pixelScale) end
                            local depth=particle.depth
                            particle.y=particle.y+dt*speed*(10+depth*15)/height
                            if particle.y>1.07 then particle.y=-particle.physicalHeight/height-.025;particle.x=weatherRandom() end
                            local x=particle.x+math.sin(weatherTime*.48+particle.phase)*(4+depth*4)/width
                                +math.sin(weatherTime*.21+particle.phase*1.7)*3/width
                            node.Rotation=particle.angle+weatherTime*particle.spin
                            local opacity=(.50+depth*.40)*(.95+.05*math.sin(weatherTime*.65+particle.phase))*.22
                            local fade=math.min(math.clamp((particle.y+.035)/.10,0,1),math.clamp((1.06-particle.y)/.14,0,1))
                            opacity=math.clamp(opacity*strength*fade*pool.blend,0,.95)
                            node.Position=UDim2.fromScale(x,particle.y)
                            if not particle.opacity or math.abs(particle.opacity-opacity)>1/512 or opacity==0 then
                                for _,part in ipairs(particle.parts) do part.object.BackgroundTransparency=1-part.alpha*opacity end
                                particle.opacity=opacity
                            end
                            total=total+1
                        end
                    end
                end
            end
            weather:SetAttribute('Time',weatherTime)
            weather:SetAttribute('Particles',total)
            if not live and weatherMode=='Off' then weather.Visible=false;if stopWeather then stopWeather() end end
            syncWeatherLayer()
        end
        stopWeather=function()
            if weatherConnection then weatherConnection:Disconnect();weatherConnection=nil end
        end
        local function reportWeatherError(message)
            message=tostring(message)
            stopWeather();weather:SetAttribute('Error',message)
            if lastWeatherError~=message then
                lastWeatherError=message
                warn('[Spectrohook background build 142] '..message)
                notify('Background error')
            end
        end
        local function startWeather()
            if weatherConnection then return end
            local ok,result=pcall(function()
                return game:GetService('RunService').Heartbeat:Connect(function(dt)
                    if not alive or disposed or not weather.Parent then stopWeather();return end
                    local rendered,message=pcall(drawWeather,math.clamp(dt,0,.10))
                    if not rendered then reportWeatherError(message) end
                end)
            end)
            if ok then weatherConnection=result else reportWeatherError(result) end
        end
        local function runWeather(shown,instant)
            local wanted=shown and values.BackgroundEffect or 'Off'
            if wanted~='Snow' then wanted='Off' end
            weatherMode=wanted;weather:SetAttribute('Mode',wanted)
            if wanted~='Off' then
                weather.Visible=true;weatherPool(wanted)
                if not weatherHasStarted then instant=true;weatherHasStarted=true end
            end
            for mode,pool in pairs(weatherPools) do
                local target=mode==wanted and 1 or 0
                if instant then pool.from=target;pool.blend=target;pool.target=target;pool.elapsed=.24
                elseif pool.target~=target then pool.from=pool.blend;pool.target=target;pool.elapsed=0 end
            end
            local rendered,message=pcall(drawWeather,0)
            if not rendered then reportWeatherError(message);return end
            if weather.Visible and not lastWeatherError then startWeather() end
        end
        local function runSelection(shown)
            sheenEffects.setVisible(shown)
        end
        appearanceRefreshers[#appearanceRefreshers+1]=function()
            animate(stage,{BackgroundColor3=themeColor('Backdrop')},motion.Control)
            syncWeatherLayer()
        end
        stage.BackgroundColor3=themeColor('Backdrop')
        local function cards(page)
            local list={}
            for _,object in ipairs(page:GetDescendants()) do
                if object:GetAttribute("SectionName") then list[#list+1]=object end
            end
            table.sort(list,function(a,b)
                if a.LayoutOrder==b.LayoutOrder then return a.Parent.Position.X.Offset<b.Parent.Position.X.Offset end
                return a.LayoutOrder<b.LayoutOrder
            end)
            return list
        end
        local function inView(card)
            local column=card.Parent
            local a,b=card.AbsolutePosition,column.AbsolutePosition
            return a.Y+card.AbsoluteSize.Y>b.Y and a.Y<b.Y+column.AbsoluteSize.Y
        end
        local hero=brandLockup
        local heroRevision=0
        local function fitScene()
            stage.Position=UDim2.new();stage.Size=UDim2.fromScale(1,1)
            syncWeatherLayer()
            if intro then
                intro.Position=main.Position;intro.Size=main.Size
                intro.IntroScale.Scale=main.WindowScale.Scale
            end
        end
        fitPresentation=fitScene;fitScene()
        local function syncScene()
            if disposed then return end
            if not main:GetAttribute('VisibleTarget') and not main.Visible then stage.Visible=false end
            syncWeatherLayer()
        end
        connectOwned(main,main:GetPropertyChangedSignal('Visible'),syncScene)
        connectOwned(main,main:GetPropertyChangedSignal('GroupTransparency'),syncWeatherLayer)
        connectOwned(main,gui:GetPropertyChangedSignal('Enabled'),function() syncWeatherLayer();sheenEffects.refresh() end)
        connectOwned(main.WindowScale,main.WindowScale:GetPropertyChangedSignal('Scale'),fitScene)
        local function clearHeading()
            animate(brand,{Position=UDim2.new(0,logoShape.textOffset,.5,0),TextTransparency=0},0)
            animate(logo,{Position=UDim2.fromOffset(0,2),GroupTransparency=0},0)
        end
        local function showHeading(delay)
            heroRevision=heroRevision+1
            local revision=heroRevision
            hero.Visible=true
            if values.HeroHeading==false or not motionReady then clearHeading();return end
            animate(brand,{Position=UDim2.new(0,logoShape.textOffset,.5,9),TextTransparency=1},0)
            animate(logo,{Position=UDim2.fromOffset(0,12),GroupTransparency=1},0)
            task.delay(delay or 0,function()
                if not alive or disposed or revision~=heroRevision or not main:GetAttribute('VisibleTarget') then return end
                animate(logo,{Position=UDim2.fromOffset(0,2),GroupTransparency=0},.32,nil,Enum.EasingStyle.Quart)
                animate(brand,{Position=UDim2.new(0,logoShape.textOffset,.5,0),TextTransparency=0},.38,nil,Enum.EasingStyle.Quart)
            end)
        end
        function api.revealPage(page,quiet)
            pageTokens[page]=(pageTokens[page] or 0)+1
            local revision=pageTokens[page]
            local useMotion=not quiet and values.RevealEffects~=false and motionReady
            local duration=0
            for index,card in ipairs(cards(page)) do
                visibility[card]=inView(card)
                if useMotion and visibility[card] then
                    local delay=(index-1)*.025
                    duration=math.max(duration,delay+.22)
                    animate(card,{GroupTransparency=1},0)
                    animate(card.SectionTitle,{Position=UDim2.fromOffset(7,5),TextTransparency=1},0)
                    animate(card.SectionToggle,{Position=UDim2.new(1,-26,0,7.5)},0)
                    animate(card.SectionContent,{Position=UDim2.fromOffset(7,21)},0)
                    task.delay(delay,function()
                        if alive and not disposed and card.Parent and pageTokens[page]==revision and page.Visible and main:GetAttribute("VisibleTarget") then
                            animate(card,{GroupTransparency=0},.20)
                            animate(card.SectionTitle,{Position=UDim2.fromOffset(7,3),TextTransparency=0},.22,nil,Enum.EasingStyle.Quart)
                            animate(card.SectionToggle,{Position=UDim2.new(1,-26,0,5.5)},.22,nil,Enum.EasingStyle.Quart)
                            animate(card.SectionContent,{Position=UDim2.fromOffset(7,19)},.22,nil,Enum.EasingStyle.Quart)
                        end
                    end)
                else
                    animate(card,{GroupTransparency=0},0)
                    animate(card.SectionTitle,{Position=UDim2.fromOffset(7,3),TextTransparency=0},0)
                    animate(card.SectionToggle,{Position=UDim2.new(1,-26,0,5.5)},0)
                    animate(card.SectionContent,{Position=UDim2.fromOffset(7,19)},0)
                end
            end
            return duration
        end
        function api.cancelIntro(force)
            if finishing and not force then return end
            introRevision=introRevision+1;finishing=false
            local old=intro;intro=nil
            gui:SetAttribute("IntroPlaying",false)
            if old then
                old:Destroy()
                if not disposed then runWeather(main:GetAttribute('VisibleTarget')==true and main.Visible) end
            end
            syncScene()
        end
        function api.setVisible(shown,quiet)
            runWeather(shown and (intro==nil or finishing));runSelection(shown)
            stage.Visible=shown or main.Visible
            hero.Visible=true
            if shown then
                if not quiet then showHeading(0) end
                api.revealPage(pages[currentTab],quiet)
            else
                heroRevision=heroRevision+1;clearHeading()
                for _,page in pairs(pages) do api.revealPage(page,true) end
            end
        end
        function api.playIntro(force)
            if disposed or not alive then return end
            if values.IntroAnimation==false and not force then setWindowVisible(main,true,true);clearHeading();return end
            closePopup();api.cancelIntro(true)
            local revision=introRevision
            main.Visible=true;main:SetAttribute('VisibleTarget',true)
            animate(main,{GroupTransparency=1},0)
            runWeather(false,true);runSelection(true);stage.Visible=true
            intro=frame(canvas,main.Position,main.Size)
            intro.Name='SpectrohookIntro';intro.ZIndex=15000;intro.ClipsDescendants=true
            bind(intro,'BackgroundColor3','Backdrop');intro.BackgroundTransparency=0
            surfaceGradient(intro,.90)
            round(intro,themeStyle.MenuRadius);styleSurface(intro,'Backdrop')
            new('UIScale',{Name='IntroScale',Scale=main.WindowScale.Scale},intro)
            local scene=intro
            gui:SetAttribute('IntroPlaying',true)
            local blocker=new('TextButton',{Name='IntroShield',Size=UDim2.fromScale(1,1),Text='',BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,ZIndex=20},scene)
            local mark=passive(group(scene,UDim2.new(.5,0,.5,-35),UDim2.fromOffset(logoShape.introWidth,44)))
            mark.AnchorPoint=Vector2.new(.5,0)
            mark.Name='IntroMark';mark.ZIndex=3;mark.GroupTransparency=1
            local fill=passive(group(mark,UDim2.new(),UDim2.fromScale(1,1)))
            fill.Name='LogoFill'
            local reveal=new('NumberValue',{Name='DrawProgress',Value=0},mark)
            drawSpectrohookMark(fill,44,reveal)
            local wordWidth=math.max(200,math.ceil(game:GetService('TextService'):GetTextSize(scriptName,34,Enum.Font.Bodoni,Vector2.new(1000,48)).X)+16)
            local titleBox=passive(frame(scene,UDim2.new(.5,0,.5,23),UDim2.fromOffset(wordWidth,48)))
            titleBox.AnchorPoint=Vector2.new(.5,0)
            titleBox.Name='IntroWordmark';titleBox.ZIndex=3
            local word=text(titleBox,scriptName,UDim2.new(),UDim2.fromScale(1,1),34,'Accent')
            word.Name='IntroWord';word.TextTransparency=1
            word.Size=UDim2.fromOffset(wordWidth-16,48);word.Position=UDim2.fromScale(.5,0);word.AnchorPoint=Vector2.new(.5,0)
            word.TextScaled=false;word.TextWrapped=false;word.AutomaticSize=Enum.AutomaticSize.X
            word.Font=Enum.Font.Bodoni
            pcall(function()
                local base=Font.fromEnum(Enum.Font.Bodoni)
                word.FontFace=Font.new(base.Family,Enum.FontWeight.SemiBold,base.Style)
            end)
            word.TextXAlignment=Enum.TextXAlignment.Center
            local function later(delay,fn)
                task.delay(delay,function()
                    if alive and not disposed and not finishing and intro==scene and revision==introRevision and scene.Parent then fn() end
                end)
            end
            later(.06,function() animate(reveal,{Value=1},.60,nil,Enum.EasingStyle.Linear) end)
            later(.02,function()
                animate(mark,{Position=UDim2.new(.5,0,.5,-57),GroupTransparency=0},.48,nil,Enum.EasingStyle.Quart)
            end)
            later(.40,function()
                animate(titleBox,{Position=UDim2.new(.5,0,.5,0)},.60,nil,Enum.EasingStyle.Quart)
                animate(word,{TextTransparency=0},.60)

            end)
            local function finish()
                if disposed or intro~=scene or revision~=introRevision or finishing then return end
                finishing=true
                setWindowVisible(main,true)
                animate(mark,{Position=UDim2.new(.5,0,.5,-65),GroupTransparency=1},.25)
                animate(word,{TextTransparency=1},.25)
                animate(scene,{BackgroundTransparency=1},.36,function() if intro==scene then api.cancelIntro(true) end end)
            end
            connectOwned(blocker,blocker.Activated,finish)
            later(1.42,finish)
        end
        function api.refresh()
            if values.IntroAnimation==false and intro and not finishing then
                api.cancelIntro(true)
                if main:GetAttribute("VisibleTarget") then setWindowVisible(main,true) end
            end
            runWeather(main:GetAttribute("VisibleTarget")==true and (intro==nil or finishing))
            runSelection(main:GetAttribute("VisibleTarget")==true)
            stage.Visible=main.Visible
            if values.HeroHeading==false then heroRevision=heroRevision+1;clearHeading() end
            if values.RevealEffects==false then
                for _,page in pairs(pages) do api.revealPage(page,true) end
            end
        end
        function api.restartBackground()
            if disposed then return end
            stopWeather()
            for _,pool in pairs(weatherPools) do pool.root:Destroy() end
            weatherPools={};weatherTime=0;weatherHasStarted=false
            randomState=(randomState+104729)%2147483647
            lastWeatherError=nil;weather:SetAttribute('Error',nil);weather:SetAttribute('Time',0)
            weather:SetAttribute('Restarts',(weather:GetAttribute('Restarts') or 0)+1)
            controls.BackgroundEffect.set('Snow',true)
            controls.BackgroundEnabled.sync(true)
            runWeather(main:GetAttribute('VisibleTarget')==true and main.Visible and intro==nil,true)
            print(string.format('[Spectrohook background build 142] mode=%s enabled=%s particles=%s viewport=%dx%d xy=%d,%d menuAlpha=%.3f error=%s',
                tostring(weather:GetAttribute('Mode')),tostring(weatherGui.Enabled),tostring(weather:GetAttribute('Particles')),
                math.floor(weather.AbsoluteSize.X),math.floor(weather.AbsoluteSize.Y),
                math.floor(weather.AbsolutePosition.X),math.floor(weather.AbsolutePosition.Y),
                1-main.GroupTransparency,tostring(weather:GetAttribute('Error'))))
            if not lastWeatherError then notify('Background',tostring(values.BackgroundEffect)..' restarted.') end
        end
        for _,page in pairs(pages) do
            for _,column in ipairs(page:GetChildren()) do
                if column:IsA("ScrollingFrame") then
                    local function scrollReveal()
                        if disposed or not alive or not page.Visible or not main:GetAttribute("VisibleTarget") or intro then return end
                        for _,card in ipairs(column:GetChildren()) do
                            if card:GetAttribute("SectionName") then
                                local visible=inView(card)
                                if visible and visibility[card]==false and values.RevealEffects~=false then
                                    animate(card,{GroupTransparency=1},0);animate(card,{GroupTransparency=0},.18)
                                end
                                visibility[card]=visible
                            end
                        end
                    end
                    connectOwned(column,column:GetPropertyChangedSignal("CanvasPosition"),scrollReveal)
                    connectOwned(column,column:GetPropertyChangedSignal("AbsoluteSize"),scrollReveal)
                end
            end
        end
        connectOwned(main,main:GetPropertyChangedSignal("Position"),fitScene)
        connectOwned(main,main:GetPropertyChangedSignal("Size"),fitScene)
        function api.destroy()
            runSelection(false)
            disposed=true;weatherMode='Off';stopWeather()
            heroRevision=heroRevision+1;fitPresentation=nil
            api.cancelIntro(true)
            for _,page in pairs(pages) do pageTokens[page]=(pageTokens[page] or 0)+1 end
            weatherGui:Destroy();stage:Destroy()
        end
        return api
    end)()

    sectionControllers.syncRuntime()
    setTab(currentTab);updateBindList();defaultSnapshot=snapshot()
    motionReady=true
    main.GroupTransparency=1;main.WindowScale.Scale=1
    if options.AutoShow==false then setWindowVisible(main,false,true) else presentation.playIntro(false) end

    task.spawn(function()
        
        local folder=ReplicatedStorage:FindFirstChild("SpectrohookBackend") or ReplicatedStorage:FindFirstChild("LucidityBackend") or ReplicatedStorage:FindFirstChild("SableBackend")
        if folder then
            local config=folder:FindFirstChild("Config")
            if config and config:IsA("RemoteFunction") then configRemote=config end
            if configRemote then
                local ok,result=pcall(function() return configRemote:InvokeServer("list") end)
                if alive and ok and type(result)=="table" and result.ok then
                    configs=result.configs or {};refreshConfigList()
                    if result.auto and configs[result.auto] then restore(configs[result.auto]);selectedConfig=result.auto;refreshConfigList() end
                end
            end
        end
    end)

    connect(gui.Destroying,function()
        themeUpdates.destroy()
        if presentation then presentation.destroy() end
        alive=false;activeDrag=nil;capture=nil
        for record in pairs(runningTweens) do stopTween(record) end
        for _,c in ipairs(connections) do c:Disconnect() end
        for image in pairs(embeddedImages) do image:Destroy() end
    end)

    return sectionControllers.api
end
function Library:_attach(window,c)
    self.CurrentWindow=window;self.Unloaded=false
    self.Toggles={};self.Options={};self._unload={};self._context=c
    local environment=type(getgenv)=='function' and getgenv() or _G
    environment.Toggles=self.Toggles;environment.Options=self.Options;environment.Library=self
    local library=self
    local serial=0
    local function uid() serial=serial+1;return 'Example_'..serial end
    local function safe(fn,...)
        if type(fn)~='function' then return end
        local ok,err=pcall(fn,...)
        if not ok then warn('Spectrohook callback: '..tostring(err)) end
    end
    local function object(id,kind,read,write,info)
        assert(not library.Toggles[id] and not library.Options[id],'Duplicate control: '..tostring(id))
        local item={Type=kind,Index=id,_nativeId=id,_listeners={},Callback=info and info.Callback,_revision=0}
        setmetatable(item,{__index=function(_,key) if key=='Value' then return read() end end})
        function item:OnChanged(fn)
            assert(type(fn)=='function','OnChanged requires a function')
            local link={Connected=true}
            self.Changed=fn
            self._listeners[#self._listeners+1]={fn,link}
            function link:Disconnect() self.Connected=false end
            safe(fn,read())
            return link
        end
        function item:SetValue(value)
            assert(not library.Unloaded,'Spectrohook is unloaded')
            local revision=self._revision
            local result=write(value)
            if self._revision==revision then self:_emit() end
            return result
        end
        function item:_emit()
            if library.Unloaded or self._batch then return end
            self._revision=self._revision+1
            local value=read()
            if self.Callback and not self._skipCallback then safe(self.Callback,value) end
            for _,entry in ipairs(self._listeners) do if entry[2].Connected then safe(entry[1],value) end end
        end
        function item:_sync(value)
            self._skipCallback=true
            local ok,err=pcall(write,value)
            self._skipCallback=false
            if not ok then error(err,0) end
        end
        c.observe(id,function() item:_emit() end)
        if kind=='Toggle' then library.Toggles[id]=item else library.Options[id]=item end
        return item
    end
    local groupMethods={}
    local function decorate(target,parentToggle)
        function target:AddColorPicker(id,info)
            info=info or {};local initial=info.Default or Color3.new(1,1,1)
            c.color(self._body,info.Title or self.Text or 'Color',id,initial)
            local picker=object(id,'ColorPicker',function() return c.parseColor(c.get(id)) end,function(value) c.set(id,value) end,info)
            function picker:SetValueRGB(value,alpha)
                assert(typeof(value)=='Color3','SetValueRGB requires Color3')
                self._batch=true
                c.set(id,value)
                if c.has(id..'Transparency') then c.set(id..'Transparency',alpha or 0) end
                self._batch=false
                self:_emit()
            end
            function picker:SetValue(value,alpha)
                if typeof(value)=='Color3' then return self:SetValueRGB(value,alpha) end
                assert(type(value)=='table','SetValue requires HSV components')
                return self:SetValueRGB(Color3.fromHSV(value[1],value[2],value[3]),alpha)
            end
            if info.Transparency~=nil then
                c.slider(self._body,'Transparency',id..'Transparency',info.Transparency,0,1,.01,'')
                local mt=getmetatable(picker);local old=mt.__index
                mt.__index=function(t,key) if key=='Transparency' then return c.get(id..'Transparency') end;return old(t,key) end
                c.observe(id..'Transparency',function() picker:_emit() end)
            end
            return picker
        end
        function target:AddKeyPicker(id,info)
            info=info or {}
            local aliases={MB1='MouseButton1',MB2='MouseButton2',MB3='MouseButton3',None='Unknown'}
            local reverse={MouseButton1='MB1',MouseButton2='MB2',MouseButton3='MB3',Unknown='None'}
            local function key(value) return aliases[value] or value or 'Unknown' end
            local row=c.keybind(self._body,info.Text or self.Text or 'Bind',id,key(info.Default),nil,info.Text or self.Text or id)
            local record=c.findBind(id);record.noUI=info.NoUI==true
            local infoCopy={}
            local picker=object(id,'KeyPicker',function() local value=c.get(id);return reverse[value] or value end,function(value)
                if type(value)=='table' then
                    c.set(id,key(value[1]));if value[2] then c.set(id..'Mode',value[2]) end
                else c.set(id,key(value)) end
            end,infoCopy)
            picker._clicks={};picker.Row=row
            function picker:GetState() return record.active==true end
            function picker:OnClick(fn) assert(type(fn)=='function');self._clicks[#self._clicks+1]=fn;return self end
            local mt=getmetatable(picker);local old=mt.__index
            mt.__index=function(t,k) if k=='Mode' then return record.mode end;return old(t,k) end
            picker:OnChanged(function()
                if info.ChangedCallback then
                    local current=c.get(id)
                    safe(info.ChangedCallback,current:match('^MouseButton') and Enum.UserInputType[current] or Enum.KeyCode[current])
                end
            end)
            c.bindChanged(id,function(active)
                safe(info.Callback,active)
                if record.mode=='Toggle' then for _,fn in ipairs(picker._clicks) do safe(fn,active) end end
            end)
            if info.SyncToggleState and parentToggle then
                record.featureId=parentToggle._nativeId
                parentToggle:OnChanged(function() c.setBindActive(record,parentToggle.Value) end)
                c.setBindActive(record,parentToggle.Value)
            end
            c.set(id..'Mode',info.Mode or 'Toggle');c.updateBinds()
            return picker
        end
        return target
    end
    function groupMethods:AddToggle(id,info)
        info=info or {};local row=c.toggle(self._body,info.Text or id,id,info.Default==true)
        local item=object(id,'Toggle',function() return c.get(id)==true end,function(value) c.set(id,value==true) end,info)
        item.Row=row;item._body=self._body;item.Text=info.Text or id
        if info.Tooltip then c.tooltip(row,info.Tooltip) end
        return decorate(item,item)
    end
    function groupMethods:AddSlider(id,info)
        info=info or {};local rounding=info.Rounding or 0
        assert(type(info.Min)=='number' and type(info.Max)=='number' and info.Max>info.Min,'Slider requires Min < Max')
        local row=c.slider(self._body,info.Text or id,id,info.Default or info.Min,info.Min,info.Max,10^-rounding,info.Suffix or '')
        local item=object(id,'Slider',function() return c.get(id) end,function(value) c.set(id,value) end,info)
        item.Row=row;if info.Tooltip then c.tooltip(row,info.Tooltip) end;return item
    end
    function groupMethods:AddDropdown(id,info)
        info=info or {};local choices={}
        local function replace(input) for i=#choices,1,-1 do choices[i]=nil end;for _,v in ipairs(input or {}) do choices[#choices+1]=tostring(v) end end
        local function special()
            local result={}
            if info.SpecialType=='Player' then for _,p in ipairs(c.players:GetPlayers()) do result[#result+1]=p.Name end
            elseif info.SpecialType=='Team' then for _,team in ipairs(game:GetService('Teams'):GetTeams()) do result[#result+1]=team.Name end
            else return info.Values or {} end
            table.sort(result);return result
        end
        replace(special())
        local default=type(info.Default)=='number' and choices[info.Default] or info.Default
        if info.Multi then default=type(default)=='table' and default or (default and {[default]=true} or {}) end
        local row=c.dropdown(self._body,info.Text or id,id,choices,default,info.Multi==true)
        local item=object(id,'Dropdown',function() return c.get(id) end,function(value) c.set(id,value) end,info)
        item.Row=row;item.Values=choices;item.Multi=info.Multi==true;item.SpecialType=info.SpecialType
        if info.Tooltip then c.tooltip(row,info.Tooltip) end
        function item:SetValues(input) local previous=c.get(id);replace(input);row:SetAttribute('SearchTerms',table.concat(choices,' '));c.set(id,previous) end
        if info.SpecialType=='Player' then
            local function refresh() item:SetValues(special()) end
            c.connect(c.players.PlayerAdded,refresh);c.connect(c.players.PlayerRemoving,refresh)
        elseif info.SpecialType=='Team' then
            local teams=game:GetService('Teams');c.connect(teams.ChildAdded,function() item:SetValues(special()) end);c.connect(teams.ChildRemoved,function() item:SetValues(special()) end)
        end
        return item
    end
    function groupMethods:AddInput(id,info)
        info=info or {};local box,row=c.input(self._body,info.Text or id,id,tostring(info.Default or ''),info)
        local item=object(id,'Input',function() return c.get(id) end,function(value) c.set(id,tostring(value)) end,info)
        item.Box=box;item.Row=row;if info.Tooltip then c.tooltip(row,info.Tooltip) end;return item
    end
    function groupMethods:AddLabel(value,wrap)
        local label,row=c.label(self._body,tostring(value),wrap)
        local item={Text=tostring(value),Label=label,Row=row,_body=self._body}
        function item:SetText(text) self.Text=tostring(text);label.Text=self.Text;c.resizeLabel(label,row,wrap) end
        return decorate(item)
    end
    function groupMethods:AddDivider() return c.divider(self._body) end
    function groupMethods:AddButton(info,fn)
        if type(info)=='string' then info={Text=info,Func=fn} end
        assert(type(info)=='table' and type(info.Func)=='function','Button requires Func')
        local item={_body=self._body,_buttons={}}
        -- Each sub-button keeps its own handler while sharing the parent row.
        local function append(config)
            local last=-math.huge
            local b=c.action(item._body,config.Text or 'Button',function()
                local now=os.clock()
                if config.DoubleClick and now-last>.4 then last=now;return end
                last=-math.huge;safe(config.Func)
            end)
            if #item._buttons>0 then local empty=b.Parent;b.Parent=item._buttons[1].Parent;empty:Destroy() end
            item._buttons[#item._buttons+1]=b;item.Button=b
            local count=#item._buttons
            for index,part in ipairs(item._buttons) do part.Position=UDim2.new((index-1)/count,(index-1)*2,0,0);part.Size=UDim2.new(1/count,-(count-1)*2,1,0) end
            if config.Tooltip then c.tooltip(b,config.Tooltip) end
            return item
        end
        function item:AddButton(config,callback) if type(config)=='string' then config={Text=config,Func=callback} end;assert(type(config.Func)=='function');return append(config) end
        return append(info)
    end
    function groupMethods:AddDependencyBox()
        local body=c.container(self._body);local box=setmetatable({_body=body,Dependencies={}}, {__index=groupMethods})
        function box:SetupDependencies(dependencies)
            for _,link in ipairs(self._links or {}) do link:Disconnect() end
            self._links={};self.Dependencies=dependencies
            local function refresh()
                local visible=true
                for _,entry in ipairs(dependencies) do if entry[1].Value~=entry[2] then visible=false;break end end
                body.Visible=visible
            end
            for _,entry in ipairs(dependencies) do self._links[#self._links+1]=entry[1]:OnChanged(refresh) end
            refresh();return self
        end
        return box
    end
    local function group(parent,name)
        local body,shell=c.group(parent,name,uid());local g=setmetatable({_body=body,Holder=shell}, {__index=groupMethods})
        return g
    end
    window.Tabs={}
    function window:AddTab(name)
        if self.Tabs[name] then return self.Tabs[name] end
        local page=c.addTab(name);local left,right=c.columns(page,name)
        local tab={Name=name,Page=page,Left=left,Right=right}
        function tab:AddLeftGroupbox(title) return group(left,title) end
        function tab:AddRightGroupbox(title) return group(right,title) end
        function tab:AddLeftTabbox() return c.tabbox(left,groupMethods,decorate,uid) end
        function tab:AddRightTabbox() return c.tabbox(right,groupMethods,decorate,uid) end
        function tab:AddGroupbox(info) return group(info.Side==2 and right or left,info.Name or 'Groupbox') end
        function tab:AddTabbox(info) return c.tabbox(info.Side==2 and right or left,groupMethods,decorate,uid) end
        function tab:ShowTab() c.selectTab(name) end
        self.Tabs[name]=tab;return tab
    end
    function window:SetWindowTitle(title) c.setTitle(tostring(title));self.Name=tostring(title) end
    window.Holder=c.main
    library.KeybindFrame=setmetatable({}, {
        __index=function(_,key) if key=='Visible' then return c.bindFrame:GetAttribute('VisibleTarget')==true end;return c.bindFrame[key] end,
        __newindex=function(_,key,value) if key=='Visible' then c.showBinds(value) else c.bindFrame[key]=value end end,
    })
    c.destroyed(function()
        library.Unloaded=true
        for _,fn in ipairs(library._unload) do safe(fn) end
        library._unload={}
    end)
    return window
end

function Library:OnUnload(fn) assert(type(fn)=='function');self._unload[#self._unload+1]=fn end
function Library:Unload() if self.CurrentWindow and not self.Unloaded then self.CurrentWindow:Destroy() end end
function Library:Toggle() self._context.toggleMenu() end
function Library:SetWatermarkVisibility(value) self._context.set('WatermarkVisible',value==true) end
function Library:SetWatermark(value) self._context.setWatermark(tostring(value)) end
function Library:StartWatermark()
    if self._watermarkDriver then self._watermarkDriver:Disconnect() end
    local name='Unknown'
    local env=type(getgenv)=='function' and getgenv() or _G
    for _,key in ipairs({'identifyexecutor','getexecutorname'}) do
        local provider=env[key] or _G[key]
        if type(provider)=='function' then
            local ok,value=pcall(provider)
            if ok and type(value)=='string' and value:find('%S') then name=value:gsub('%c',' '):sub(1,48);break end
        end
    end
    local elapsed,frames=0,0
    self._watermarkDriver=self:GiveSignal(game:GetService('RunService').RenderStepped:Connect(function(dt)
        elapsed=elapsed+dt;frames=frames+1
        if elapsed<.35 then return end
        local fps=math.floor(frames/elapsed+.5);elapsed=0;frames=0
        local player=game:GetService('Players').LocalPlayer
        local ok,ping=pcall(function() return player:GetNetworkPing()*1000 end)
        self:SetWatermark(('Spectrohook | %s | %s fps | %s ms'):format(name,fps,ok and math.floor(ping) or '—'))
    end))
    return self._watermarkDriver
end
function Library:Notify(text,duration) self._context.notify(tostring(text),duration) end
function Library:GiveSignal(signal) self:OnUnload(function() signal:Disconnect() end);return signal end

Library.SaveManager={Ignore={},Stores={},Folder='Spectrohook/configs'}
function Library.SaveManager:SetLibrary(value) self.Library=value end
function Library.SaveManager:IgnoreThemeSettings() self.IgnoreThemes=true end
function Library.SaveManager:SetIgnoreIndexes(ids) self.Ignore={};for _,id in ipairs(ids) do self.Ignore[id]=true end end
function Library.SaveManager:SetFolder(folder)
    assert(type(folder)=='string' and not folder:find('%.%.') and not folder:match('^[/\\]'),'Invalid config folder')
    self.Folder=folder;self.Stores[folder]=self.Stores[folder] or {configs={}};self.Store=self.Stores[folder]
end
function Library.SaveManager:_action(action,name,payload)
    if not self.Store then self:SetFolder(self.Folder) end
    local store=self.Store
    local filesystem=type(writefile)=='function' and type(readfile)=='function' and type(makefolder)=='function'
    local function json() return game:GetService('HttpService') end
    local function folder()
        local current=''
        for part in self.Folder:gmatch('[^/]+') do current=current=='' and part or current..'/'..part;pcall(makefolder,current) end
    end
    local function path(value) assert(value and value:match('^[%w _.-]+$') and not value:find('%.%.'),'Invalid profile name');return self.Folder..'/'..value..'.json' end
    if action=='save' then
        local filtered={}
        for id,value in pairs(payload or {}) do
            if not self.Ignore[id] and not self.Ignore[id:gsub('Mode$','')] and not (self.IgnoreThemes and (id=='ThemePreset' or id=='CustomTheme' or id:match('^Theme%d') or (Library.ThemeManager.Indexes or {})[id])) then filtered[id]=value end
        end
        if filesystem then folder();writefile(path(name),json():JSONEncode(filtered)) end
        store.configs[name]=filtered
    elseif action=='load' then
        if filesystem then local ok,value=pcall(function() return json():JSONDecode(readfile(path(name))) end);if ok and type(value)=='table' then store.configs[name]=value end end
        assert(store.configs[name],'Profile not found')
    elseif action=='delete' then
        if filesystem and type(delfile)=='function' then pcall(delfile,path(name)) end
        store.configs[name]=nil
    elseif action=='auto' then
        store.auto=name
        if filesystem then folder();writefile(self.Folder..'/autoload.txt',name) end
    elseif action=='list' and filesystem and type(listfiles)=='function' then
        folder()
        for _,file in ipairs(listfiles(self.Folder)) do
            local item=file:gsub('\\','/'):match('/([^/]+)%.json$')
            if item then local ok,value=pcall(function() return json():JSONDecode(readfile(file)) end);if ok and type(value)=='table' then store.configs[item]=value end end
        end
    end
    return {ok=true,configs=store.configs,auto=store.auto,storage=filesystem and 'persistent' or 'session'}
end
function Library.SaveManager:BuildConfigSection(tab) self.Library._context.buildConfig(tab);self.Library._context.configList();return self.Library._context.configPanel end
function Library.SaveManager:LoadAutoloadConfig()
    local store=self.Store
    if not store then self:SetFolder(self.Folder);store=self.Store end
    if type(readfile)=='function' then local ok,value=pcall(readfile,self.Folder..'/autoload.txt');if ok then store.auto=value end end
    if store.auto then local result=self:_action('load',store.auto);self.Library._context.restore(result.configs[store.auto]) end
end
Library.ThemeManager={Folder='Spectrohook/themes',Stores={},Indexes={ExampleTheme=true,ExampleAccent=true,ExampleBackground=true,ExampleThemeName=true}}
function Library.ThemeManager:SetLibrary(value) self.Library=value end
function Library.ThemeManager:SetFolder(folder)
    assert(type(folder)=='string' and not folder:find('%.%.') and not folder:match('^[/\\]'),'Invalid theme folder')
    self.Folder=folder;self.Stores[folder]=self.Stores[folder] or {};self.Store=self.Stores[folder]
end
function Library.ThemeManager:SaveCustomTheme(name)
    assert(type(name)=='string' and name:match('^[%w _.-]+$') and not name:find('%.%.'),'Enter a valid theme name')
    if not self.Store then self:SetFolder(self.Folder) end
    local snapshot=self.Library._context.snapshot()
    local data={CustomTheme=snapshot.CustomTheme,ThemePreset='Custom'}
    if type(writefile)=='function' and type(makefolder)=='function' then
        local current='';for part in self.Folder:gmatch('[^/]+') do current=current=='' and part or current..'/'..part;pcall(makefolder,current) end
        writefile(self.Folder..'/'..name..'.json',game:GetService('HttpService'):JSONEncode(data))
    end
    self.Store[name]=data;return true
end
function Library.ThemeManager:LoadCustomTheme(name)
    assert(type(name)=='string' and name:match('^[%w _.-]+$') and not name:find('%.%.'),'Enter a valid theme name')
    if not self.Store then self:SetFolder(self.Folder) end
    local data=self.Store[name]
    if type(readfile)=='function' then local ok,value=pcall(function() return game:GetService('HttpService'):JSONDecode(readfile(self.Folder..'/'..name..'.json')) end);if ok then data=value end end
    assert(type(data)=='table','Theme not found')
    self.Library._context.restore(data);return true
end
function Library.ThemeManager:ApplyToTab(tab)
    local group=tab:AddLeftGroupbox('Theme')
    return self:ApplyToGroupbox(group)
end
function Library.ThemeManager:ApplyToGroupbox(group)
    local library=self.Library
    local preset=group:AddDropdown('ExampleTheme',{Text='Theme',Values={'White','Mint','Default','Amethyst','Rose','Yellow','Graphite','Custom'},Default='White',Callback=function(value) library._context.set('ThemePreset',value) end})
    local accent=group:AddLabel('Accent'):AddColorPicker('ExampleAccent',{Default=library._context.accent(),Callback=function(value) library._context.set('Theme1',value) end})
    local background=group:AddLabel('Background'):AddColorPicker('ExampleBackground',{Default=library._context.background(),Callback=function(value) library._context.set('Theme2',value) end})
    library._context.observe('ThemePreset',function(value) preset:_sync(value) end)
    library._context.observe('Theme1',function(value) accent:_sync(value) end)
    library._context.observe('Theme2',function(value) background:_sync(value) end)
    group:AddInput('ExampleThemeName',{Text='Custom theme',Default='my-theme',Finished=true})
    group:AddButton({Text='Save theme',Func=function() self:SaveCustomTheme(library.Options.ExampleThemeName.Value);library:Notify('Theme saved') end})
        :AddButton({Text='Load theme',Func=function() self:LoadCustomTheme(library.Options.ExampleThemeName.Value);library:Notify('Theme loaded') end})
    return group
end

return Library
