
require("config")
require("framework.init")
levels = require("levels")

--数据保存
GameData = {};
GameState=require(cc.PACKAGE_NAME .. ".api.GameState");

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
	--initState--
	GameState.init(
		function(param)
			-- body
			local returnValue = nil;
			if param.errorCode then
				CCLuaLog("error");
			else
				--crypto
				if param.name == "save" then
					--todo
					local str = json.encode(param.values);
					str = crypto.encryptXXTEA(str, "abcd");
					returnValue = {data = str;};
				elseif param.name == "load" then
					local str = crypto.decryptXXTEA(param.values.data, "abcd");
					returnValue = json.decode(str);
				end
			end
			return returnValue;
		end
		,"data.txt","1234"
		);
	GameData = GameState.load();
	if  not GameData then
		--todo
		GameData = {lv=1};
	end
    MyApp.super.ctor(self)
end

function MyApp:run()
    CCFileUtils:sharedFileUtils():addSearchPath("res/")
    self:enterScene("MainScene");
end

return MyApp
