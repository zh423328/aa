
local MainScene = class("MainScene", function()
    return display.newScene("MainScene",1)
end)

function MainScene:ctor(levelindex)
	--失败字--
	-- self.failLabel = ui.newBMFontLabel({
 --            text  = "Failed!",
 --            font  = "fnt-lianji.fnt",
 --            x     = display.cx,
 --            y     = display.cy,
 --            align = ui.TEXT_ALIGEN_CENTER,
 --        })
    self.failLabel = ui.newTTFLabel({text = "Failed!", size = 30, align = ui.TEXT_ALIGN_CENTER,x = display.cx,y = display.cy});
    self:addChild(self.failLabel, 6)
    self.failLabel:setColor(ccc3(252,129, 131))
    self.failLabel:setScale(0.7)
    self.failLabel:setOpacity(0)

    self.sucessLabel = ui.newTTFLabel({text = "Successs!", size = 30, align = ui.TEXT_ALIGN_CENTER,x = display.cx,y = display.cy});
    self:addChild(self.sucessLabel, 6)
    self.sucessLabel:setColor(ccc3(0,255, 0))
    self.sucessLabel:setScale(0.7)
    self.sucessLabel:setOpacity(0)

    --显示第几关---
    -- self.titleLabel = ui.newBMFontLabel({
    --         text  = ""..levelIndex,
    --         font  = "fnt-lianji.fnt",
    --         x     = display.cx,
    --         y     = display.top + 50,
    --         align = ui.TEXT_ALIGEN_CENTER,
    --     })
   --  self.titleLabel = ui.newTTFLabel({text = "LEVEL", size = 30, align = ui.TEXT_ALIGN_CENTER,
   --      x = display.cx,y = display.top+70});
   --  self:addChild(self.titleLabel, 6);
   --  self.titleLabel:setVisible(false);

   --  ---做个动画--
   --  self:performWithDelay(
   --  	function()
			-- self.titleLabel:setVisible(true)
			-- local seq = transition.sequence({
			--     CCMoveBy:create(0.1,ccp(0,-120)),
			--     CCMoveBy:create(0.2,ccp(0,20))
			-- })
			-- self.titleLabel:runAction(seq)
   --  	end,1.0)

   	--添加一个自定义颜色--
    display.newColorLayer(ccc4(255, 250, 215, 255)):addTo(self);

    --添加一个圆球转动球--
    self.contentLayer=display.newLayer();
    self.contentLayer:setPosition(ccp(0,100));
    self:addChild(self.contentLayer, 2);

    --再定一个层  这个层放置所有  还没有插入的球  每插入一个  向上移动一点
    self.contentLayer2 = display.newLayer();
    self.contentLayer2:setPosition(ccp(0,100));
    self:addChild(self.contentLayer2, 2);

    --定义一个半透明的层-
    self.bgLayer = display.newColorLayer(ccc4(255, 0, 0, 255)):addTo(self,1);
    self.bgLayer:setVisible(false);



    --数据--
    self.peizhiData = levels[2];
    sudu = self.peizhiData.speed1
    sudu2 = self.peizhiData.speed2
    time = self.peizhiData.time * 60
    startNumberLevel = self.peizhiData.startNumber
    myLevelNumber = self.peizhiData.myNumber

    --角速度
    self.realsudu = sudu;
    --计时间-
    self.jishitime = 0;

    --保存转动的球--
    self.tableArray = {};
    --保存未插入的球--
    self.ballDown = {};

    --添加资源--
    self:addResources(levelindex);

    --当前Layer的角度
    self.angleDu = 0.0;

    --添加触摸事件--
    self.contentLayer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)  --单点触摸
    self.contentLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return self:onTouch(event.name, event.x,event.y)
    end)
    self.contentLayer:setTouchEnabled(true)

    --添加帧事件--
    -- 注册帧事件  注册之后一定要 启用 才生效
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) 
        return self:updateMy(dt)
    end)
    self:scheduleUpdate();

    self.gameOver = false;

    self.running =  false;
end


function MainScene:onEnter()
end

function MainScene:onExit()
end

function MainScene:addResources(levelindex)
    --添加圆--
    self.circle = display.newSprite("MB_QIU.png");
    self.circle:setPosition(ccp(display.cx,display.cy));
    self.contentLayer:addChild(self.circle, 2)

    --显示还有多少个球没有插入进去--
    self.numLabel = ui.newTTFLabel({text = levelindex, size = 30, align = ui.TEXT_ALIGN_CENTER,
        x = display.cx,y = display.cy+100});
    self:addChild(self.numLabel, 3);


    --放置预先准备好的球--
    --小球半径--
    local r = 40;
    local rLittleBall = 7;
    for i = 1,startNumberLevel do 
        local xx = math.sin(math.rad((i-1)*360/startNumberLevel))*r;
        local yy = math.cos(math.rad((i-1)*360/startNumberLevel))*r;

        --设置棍子--
        local sp0 = display.newSprite("MB_ZHENG.png");
        sp0:setPosition(ccp(display.cx+xx,display.cy + yy));

        --设置旋转角度
        sp0:setRotation((i-1)*360/startNumberLevel);
        self.contentLayer:addChild(sp0, 1);

        --小球
        local ball1 = display.newSprite("MB_MINIQIU.png")
        ball1:setPosition(ccp(display.cx + xx * 2,display.cy + yy * 2))
        self.contentLayer:addChild(ball1,2)
         
        --把它们 全放入table
        self.tableArray[#self.tableArray + 1] = ball1
    end

    --在下面依次排列所有的未插入的小球--
    for i=1,myLevelNumber do
        local balldd = display.newSprite("MB_MINIQIU.png")
        balldd:setPosition(ccp(display.cx,display.cy - r * 2 - (myLevelNumber + 1 - i) * rLittleBall * 3.0))
        self.contentLayer2:addChild(balldd,3)
        balldd.number = i

        --小球的数字
        local setLabel = ui.newTTFLabel({text = i, size = 30, align = ui.TEXT_ALIGN_CENTER,
            x = balldd:getContentSize().width/2,y = balldd:getContentSize().height/2});
        setLabel:setScale(0.36)
        balldd:addChild(setLabel, 2)

        --保存所有未插入的小球
        self.ballDown[#self.ballDown + 1] = balldd;
    end


end

--1/60
function MainScene:updateMy(dt)
    --body--
   --旋转--
    if self.gameOver ~= true then
        --todo
        self.angleDu = self.angleDu + dt*self.realsudu;
        if self.contentLayer ~= nil then
            --todo
            self.contentLayer:setRotation(self.angleDu);
        end
    end
end

function MainScene:onTouch(name,x,y)
    -- body
    if name == "began" then  
        print("layer began") 
        self:BallUp();
    elseif name == "moved" then  
        print("layer moved")  
    elseif name == "ended" then  
        print("layer ended")
    elseif name == "cancelled" then
          --todo 
        print("layer cancelled") 
    end  
end

--弹射小球
function MainScene:BallUp()
    -- body-
    if  self.gameOver == false and self.running == false and #self.ballDown ~= 0 then
        --todo
        local len = #self.ballDown;
        local ball = self.ballDown[len];
        self.ballDown[len] = nil;
        if ball ~= nil then
            --发射-
            self.running = true;

            --ball:setParent(nil);
            --执行动作
            local  rLittleBall = 7;
            local len = rLittleBall * 3.0;
            transition.execute(ball, CCMoveBy:create(0.1, ccp(0,len)), {  
            onComplete = function()  
                self:callback(ball)
            end,  
             })  

            for i=1,#self.ballDown do
                local  tmpball = self.ballDown[i];
                if tmpball ~= nil then
                    --todo
                    len = rLittleBall * 3.0;
                    transition.execute(tmpball, CCMoveBy:create(0.1, ccp(0,len)));
                end
            end
        end
    end
end

--回调函数--
function MainScene:callback(ball)
    -- body
    local r = 40;
    local rLittleBall = 7;

    if ball ~= nil then
        --进行区域判断--
        self.running = false;
        print("havetable len:"..#self.tableArray);
        for i=1,#self.tableArray do
            local tmpball = self.tableArray[i];
            if tmpball ~= nil then
                --todo
                local x1, y1= ball:getPosition()
                local x2, y2= tmpball:getPosition()
                local pos1 = self.contentLayer2:convertToWorldSpace(ccp(x1,y1));
                local pos2 = self.contentLayer:convertToWorldSpace(ccp(x2,y2));
                print(pos1.x,pos1.y);
                print(pos2.x,pos2.y);

                local dis = math.sqrt((pos2.x-pos1.x)*(pos2.x-pos1.x) + (pos2.y-pos1.y)*(pos2.y-pos1.y));
                print(dis);
                if dis < 2*rLittleBall then
                    --todo--
                    transition.execute(tmpball, CCScaleTo:create(0.1,1.2),{easing = "backout"});
                    self.gameOver = true;
                    self.failLabel:setOpacity(255);
                    --失败--
                    return;
                end
            end
        end

        local number = ball.number;
        ball:removeFromParentAndCleanup(true);
        ball = nil;


        local xx = math.sin(math.rad(180-self.angleDu))*r;
        local yy = math.cos(math.rad(180-self.angleDu))*r;

            --设置棍子--
        local sp0 = display.newSprite("MB_ZHENG.png");
        sp0:setPosition(ccp(display.cx+xx,display.cy + yy));

            --设置旋转角度
        sp0:setRotation(180-self.angleDu);
        self.contentLayer:addChild(sp0, 1);

            --小球
        local balldd = display.newSprite("MB_MINIQIU.png")
        balldd.number = number;

        --小球的数字
        local setLabel = ui.newTTFLabel({text = number, size = 30, align = ui.TEXT_ALIGN_CENTER,
            x = balldd:getContentSize().width/2,y = balldd:getContentSize().height/2});
        setLabel:setScale(0.36)
        balldd:addChild(setLabel, 2)

        balldd:setPosition(ccp(display.cx + xx * 2,display.cy + yy * 2))
        self.contentLayer:addChild(balldd,2)
             
            --把它们 全放入table
        self.tableArray[#self.tableArray + 1] = balldd;

        if #self.ballDown == 0 then
            --todo
            self.gameOver = true;
            self.sucessLabel:setOpacity(255);
        end
    end
end

return MainScene
