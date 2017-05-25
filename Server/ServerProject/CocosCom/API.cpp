#include "API.h"

#include "cocos2d.h"
#include "AppDelegate.h"
#include "scripting/lua-bindings/manual/CCLuaEngine.h"
#include "ConfigParser.h"
#include "scripting/lua-bindings/manual/lua_module_register.h"
//#include "lua_cocos2dx_extratools_auto.hpp"
#include "LogSystem.h"

static char buff[1024] = "12swadwadwas";

extern "C"
{
	AppDelegate app;

	DLLEXPORT void Debug()
	{
		AllocConsole();
		freopen("CONIN$", "r", stdin);
		freopen("CONOUT$", "w", stdout);
		freopen("CONOUT$", "w", stderr);
	}
	
	DLLEXPORT bool Initialize()
	{
		memset(buff, 0, 1024);

		CCFileUtils::getInstance()->addSearchPath("res");
		CCFileUtils::getInstance()->addSearchPath("code");
		CCFileUtils::getInstance()->addSearchPath("../res");
		CCFileUtils::getInstance()->addSearchPath("../code");
		CCFileUtils::getInstance()->addSearchPath("system");
		//HANDLE hCon = GetStdHandle(STD_OUTPUT_HANDLE);      //��ȡ����̨������  
		//INT hCrt = _open_osfhandle((INT)hCon, _O_TEXT);     //ת��ΪC�ļ�������  
		//FILE * hf = _fdopen(hCrt, "w");           //ת��ΪC�ļ���  
		//setvbuf(hf, NULL, _IONBF, 0);              //�޻���  
		//*stdout = *hf;

		// initialize director
		auto director = Director::getInstance();

		#if (COCOS2D_DEBUG>0)
				//initRuntime();
		#endif

		if (!ConfigParser::getInstance()->isInit()) {
			ConfigParser::getInstance()->readConfig();
		}

		// set FPS. the default value is 1.0/60 if you don't call this
		//director->setAnimationInterval(1.0 / 60);
		GLContextAttrs glContextAttrs = { 8, 8, 8, 8, 24, 8 };
		GLView::setGLContextAttrs(glContextAttrs);
		//_app->initGLContextAttrs();

		const Rect frameRect = Rect(0, 0, 100, 100);
		//auto glview = GLViewImpl::createWithRect("", frameRect, 1);
		//director->setOpenGLView(glview);

		auto engine = LuaEngine::getInstance();
		ScriptEngineManager::getInstance()->setScriptEngine(engine);
		lua_State* L = engine->getLuaStack()->getLuaState();
		// register lua module
		lua_module_register(L);
		
		LuaStack* stack = engine->getLuaStack();
		stack->setXXTEAKeyAndSign("2dxLua", strlen("2dxLua"), "XXTEA", strlen("XXTEA"));

		if (engine->executeScriptFile("code/main.lua"))
		{
			return false;
		}

		return true;
	}

	DLLEXPORT bool Start()
	{
		auto engine = LuaEngine::getInstance();
		auto success = engine->executeGlobalFunction("start");

		return true;
	}

	DLLEXPORT void MainLoop()
	{
		auto director = cocos2d::Director::getInstance();
		director->mainLoop();
		//director->getOpenGLView()->pollEvents();		
	}

	DLLEXPORT void Destory()
	{
		LuaEngine::getInstance()->executeString("Close");

		auto director = cocos2d::Director::getInstance();
		director->end();
		//director->mainLoop();
	}

	DLLEXPORT void ExcStr(char* str)
	{
		auto engine = LuaEngine::getInstance();
		engine->executeString(str);
	}

	DLLEXPORT const char* getLogMessage(int type)
	{
		string str = LogSystem::getInstance()->getLog(type);
		strcpy(buff, str.c_str());

		return buff;// buff;
	}

	DLLEXPORT const char* getLuaVariable(char* variable)
	{
		LuaStack * L = LuaEngine::getInstance()->getLuaStack();
		lua_State* tolua_s = L->getLuaState();

		lua_getglobal(tolua_s, variable);
		string strTemp = lua_tostring(tolua_s, -1);
		strcpy(buff, strTemp.c_str());

		return buff;
	}

	DLLEXPORT const char* getLuaTable(char* table, char* field)
	{
		LuaStack* L = LuaEngine::getInstance()->getLuaStack();
		lua_State* tolua_s = L->getLuaState();

		lua_getglobal(tolua_s, table);
		lua_getfield(tolua_s, -1, field);
		string strName = lua_tostring(tolua_s, -1);
		strcpy(buff, strName.c_str());

		return buff;
	}

	DLLEXPORT const char* getLuaFunction(char* func, char* param)
	{
		LuaStack* L = LuaEngine::getInstance()->getLuaStack();
		lua_State* tolua_s = L->getLuaState();

		lua_getglobal(tolua_s, func);    // ��ȡ������ѹ��ջ��  
		lua_pushstring(tolua_s, param);       // ѹ���һ������  

		int iRet = lua_pcall(tolua_s, 1, 1, 0);// ���ú�������������Ժ󣬻Ὣ����ֵѹ��ջ�У�2��ʾ����������1��ʾ���ؽ��������  
		if (iRet)                       // ���ó���  
		{
			const char *pErrorMsg = lua_tostring(tolua_s, -1);
			CCLOG("����-------%s", pErrorMsg);
			return 0;
		}

		string str = lua_tostring(tolua_s, -1);     //��ȡ�ڶ�������ֵ 
		strcpy(buff, str.c_str());
		
		return buff;
	}
}