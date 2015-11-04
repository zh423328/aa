
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    --初始化
    self:initLevelIndex(GameData.lv);

    -- 注册帧事件  注册之后一定要 启用 才生效
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) 
        return self:updateMy(dt)
    end);
    self:scheduleUpdate();
end

function MainScene:initLevelIndex(level)

    if self.faileLabel == nil then
        --todo
        self.failLabel = ui.newTTFLabel({text = "Failed!", size = 30, align = ui.TEXT_ALIGN_CENTER,x = display.cx,y = display.cy});
        self:addChild(self.failLabel, 6)
    end
        --失败字--
    self.failLabel:setColor(ccc3(252,129, 131))
    self.failLabel:setScale(0.7)
    self.failLabel:setVisible(false);

    if self.sucessLabel == nil then
        --todo
        self.sucessLabel = ui.newTTFLabel({text = "Successs!", size = 30, align = ui.TEXT_ALIGN_CENTER,x = display.cx,y = display.cy});
        self:addChild(self.sucessLabel, 6);
    end
    self.sucessLabel:setColor(ccc3(0,255, 0));
    self.sucessLabel:setScale(0.7);
    self.sucessLabel:setVisible(false);

    if self.allpass == nil then
        --todo
        self.allpass = ui.newTTFLabel({text = "All Pass!", size = 30, align = ui.TEXT_ALIGN_CENTER,x = display.cx,y = display.cy});
        self:addChild(self.allpass, 6); 
    end

    self.allpass:setColor(ccc3(0,255, 0));
    self.allpass:setScale(0.7);
    self.allpass:setVisible(false);



    --添加一个自定义颜色--
    if self.colorLayer == nil then
        --todo
        self.colorLayer = display.newColorLayer(ccc4(255, 250, 215, 255));
        self:addChild(self.colorLayer);
    end

    if self.contentLayer ~= nil then
        --todo
        self.contentLayer:removeFromParentAndCleanup(true);
    end
    --添加一个圆球转动球--
    self.contentLayer=display.newLayer();
    self.contentLayer:setPosition(ccp(0,100));
    self:addChild(self.contentLayer, 2);

    --再定一个层  这个层放置所有  还没有插入的球  每插入一个  向上移动一点
    if self.contentLayer2 ~= nil then
        --todo
        self.contentLayer2:removeFromParentAndCleanup(true);
    end

    self.contentLayer2 = display.newLayer();
    self.contentLayer2:setPosition(ccp(0,100));
    self:addChild(self.contentLayer2, 2);

    local levellen = #levels;

    if level > levellen then
        --todo
        level = levellen;
    end


    --数据--
    self.peizhiData = levels[level];
    sudu = self.peizhiData.speed1
    sudu2 = self.peizhiData.speed2
    time = self.peizhiData.time;
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
    self:addResources(level);

    --当前Layer的角度
    self.angleDu = 0.0;


    self.gameOver = false;

    self.running =  false;

    self.speedchange = 1;

    --添加触摸事件--
    self.contentLayer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)  --单点触摸
    self.contentLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return self:onTouch(event.name, event.x,event.y)
    end)
    self.contentLayer:setTouchEnabled(true)
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
    if self.numLabel == nil then
        --todo
        self.numLabel = ui.newTTFLabel({text = levelindex, size = 30, align = ui.TEXT_ALIGN_CENTER,
            x = display.cx,y = display.cy+100});
        self:addChild(self.numLabel, 3);
    end
    self.numLabel:setString(levelindex);



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
        if time ~= 0 then
            --todo
            self.jishitime = self.jishitime + dt;

            if self.jishitime >= time then
                --todo
                if self.speedchange == 1 then
                    --todo
                    self.realsudu = sudu2;
                    self.speedchange  = 2;
                else
                    self.realsudu = sudu;
                    self.speedchange  = 1;
                end
                self.jishitime = 0;
            end
        end
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

                local dis = math.sqrt((pos2.x-pos1.x)*(pos2.x-pos1.x) + (pos2.y-pos1.y)*(pos2.y-pos1.y));
                if dis < 2*rLittleBall then
                    --todo--
                    transition.execute(tmpball, CCScaleTo:create(0.1,1.2),{easing = "backout"});
                    self.gameOver = true;
                    self.failLabel:setVisible(true);
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

            GameData.lv = GameData.lv+1;

            if GameData.lv >#levels then
                --todo
                GameData.lv = 1;
                self.allpass:setVisible(true);
            else
                self.sucessLabel:setVisible(true);
                self:initLevelIndex(GameData.lv);
            end
            GameState.save(GameData);
        end
    end
end

return MainScene
