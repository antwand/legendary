#include "MirFileLoader.h"
#include "WZLReader.h"
#include "WILReader.h"
#include "FileCache.h"
#include "CCLuaEngine.h"
#include <fstream>

vector<AniAction> MirAniAction::HumAction;
vector<AniAction> MirAniAction::MonsterAction;
vector<AniAction> MirAniAction::GodMonAction;
vector<AniAction> MirAniAction::NPCAction;
vector<vector<AniAction>> MirAniAction::actionList;
bool MirAniAction::__init = MirAniAction::init();

bool MirAniAction::init() 
{
	HumAction.push_back(AniAction(0, 4, 4, 0.20f, true));     //站立 1
	HumAction.push_back(AniAction(64, 6, 2, 0.09f, true));    //走  2
	HumAction.push_back(AniAction(128, 6, 2, 0.12f, true));   //跑   3
	HumAction.push_back(AniAction(192, 1, 0, 0.020f, true));     //警戒 4
	HumAction.push_back(AniAction(200, 6, 2, 0.085f, false));	  //普攻  5
	HumAction.push_back(AniAction(264, 6, 2, 0.090f, false));	  //被重击后停滞的画面  6
	HumAction.push_back(AniAction(328, 8, 0, 0.070f, false));     //重击击中动画  7
	HumAction.push_back(AniAction(392, 6, 2, 0.060f, false));     //施法  8 
	HumAction.push_back(AniAction(456, 2, 0, 0.30f, false));      //坐下  9
	HumAction.push_back(AniAction(472, 3, 5, 0.070f, false));     //被攻击  10
	HumAction.push_back(AniAction(536, 4, 4, 0.120f, false));     //死亡  11
	/*
	1 ActStand: (start: 0; frame: 4; skip: 4; ftime: 200; usetick: 0); //0-63  站立  
    2 ActWalk: (start: 64; frame: 6; skip: 2; ftime: 90; usetick: 2);  //64-127   行走  
    3 ActRun: (start: 128; frame: 6; skip: 2; ftime: 120; usetick: 3);  //128- 191    跑步  
    4 ActRushLeft: (start: 128; frame: 3; skip: 5; ftime: 120; usetick: 3);//野蛮冲撞的貌似  
    5 ActRushRight: (start: 131; frame: 3; skip: 5; ftime: 120; usetick: 3);  //  
    6 ActWarMode: (start: 192; frame: 1; skip: 0; ftime: 200; usetick: 0); //攻击后停滞的画面  
    7 ActHit: (start: 200; frame: 6; skip: 2; ftime: 85; usetick: 0);  
    8 ActHeavyHit: (start: 264; frame: 6; skip: 2; ftime: 90; usetick: 0);  
    9 ActBigHit: (start: 328; frame: 8; skip: 0; ftime: 70; usetick: 0);  
    10 ActFireHitReady: (start: 192; frame: 6; skip: 4; ftime: 70; usetick: 0);  
    11 ActSpell: (start: 392; frame: 6; skip: 2; ftime: 60; usetick: 0);  
    12 ActSitdown: (start: 456; frame: 2; skip: 0; ftime: 300; usetick: 0);  12*8=96
    13 ActStruck: (start: 472; frame: 3; skip: 5; ftime: 70; usetick: 0);  
    14 ActDie: (start: 536; frame: 4; skip: 4; ftime: 120; usetick: 0);  */

	//startOffset+0, 4, 6, 0.2, -1
	//
	MonsterAction.push_back(AniAction(0, 4, 6, 0.20f, true));   //stand
	MonsterAction.push_back(AniAction(80, 6, 4, 0.20f, true));  //walk
	MonsterAction.push_back(AniAction(160, 6, 4, 0.085f, false));//attack
	MonsterAction.push_back(AniAction(240, 2, 0, 0.10f, false));//hurt
	MonsterAction.push_back(AniAction(260, 10, 0, 0.20f, false));//die

	//GodMonAction
	GodMonAction.push_back(AniAction(0, 10, 0, 0.10f, false)); //appear  1
	GodMonAction.push_back(AniAction(80, 4, 6, 0.20f, true)); //climb alert  2
	GodMonAction.push_back(AniAction(160, 6, 4, 0.20f, true)); //climb walk  3
	GodMonAction.push_back(AniAction(240, 2, 0, 0.20f, false)); //climb hurt  4
	GodMonAction.push_back(AniAction(260, 10, 0, 0.20f, false));//climb die   5
	GodMonAction.push_back(AniAction(350, 10, 0, 0.10f, false)); //climb to stand  6
	GodMonAction.push_back(AniAction(430, 4, 6, 0.20f, true)); //stand alert  7
	GodMonAction.push_back(AniAction(510, 6, 4, 0.20f, true));//stand walk  8
	GodMonAction.push_back(AniAction(590, 6, 4, 0.085f, false));//stand attack  9
	GodMonAction.push_back(AniAction(670, 2, 0, 0.20f, false));//stand hurt  10
	GodMonAction.push_back(AniAction(690, 10, 0, 0.20f, false));//stand die  11

	//npc
	NPCAction.push_back(AniAction(0, 4, 6, 0.40f, true, 3));  //stand
	NPCAction.push_back(AniAction(30, 10, 0, 0.20f, true, 3)); //action

	actionList.push_back(HumAction);
	actionList.push_back(MonsterAction);
	actionList.push_back(GodMonAction);
	actionList.push_back(NPCAction);
	
	return true;
}

MirFileLoader* MirFileLoader::m_pInstance = 0;

MirFileLoader::MirFileLoader(void)
{
	m_isLoadingRes = false;
}


MirFileLoader::~MirFileLoader(void)
{
}

void MirFileLoader::insertActionSetting(int idx, int _start, int _frame, 
	int _skip, float _ftime, bool _isLoops, int _dir)
{
	if (MirAniAction::actionList.size() <= idx)
	{
		vector<AniAction> action;
		action.push_back(AniAction(_start, _frame, _skip, _ftime, _isLoops, _dir));

		MirAniAction::actionList.push_back(action);

		return;
	}

	MirAniAction::actionList[idx].push_back(AniAction(_start, _frame, _skip, _ftime, _isLoops, _dir));
}

MirFileLoader* MirFileLoader::getInstance()
{
	if (m_pInstance == 0)
		m_pInstance = new MirFileLoader();

	return m_pInstance;
}

Texture2D*	MirFileLoader::readMirTexture(int index, void* image, void* conf, void*& _info)
{
	MirImageInfo* info = NULL;
	if (((RandomAccessFile*)image)->getFilename().find(".wzl") != string::npos)
		info = WZLReader::getInstance()->readMirImageInfo(index, (RandomAccessFile*)image, (RandomAccessFile*)conf);
	else if (((RandomAccessFile*)image)->getFilename().find(".wil") != string::npos)
		info = WILReader::getInstance()->readMirImageInfo(index, (RandomAccessFile*)image, (RandomAccessFile*)conf);
	else
		return NULL;
	Texture2D* text = 0;

	if (info != 0 && info->getData() != 0)
	{
		string textName = formatName(((RandomAccessFile*)image)->getFilename().c_str(), index);

		if (info->getWidth()<=0 || info->getHeight()<=0 || info->getDataSize() <= 0)
		{
			log("readMirTexture %s no found", textName.c_str());
			return NULL;
		}

		text = createTexture2D(info, textName.c_str());
		text->setAliasTexParameters();
		//createSpriteFrame(text, textName.c_str());
		_info = info;
	}

	return text;
}

Animation* MirFileLoader::readMirAnimation(const char* imageName,
			int start,						// 开始帧
			int frame,						// 帧数
			int skip,						// 跳过的帧数  
			float ftime,					// 每帧的延迟时间(毫秒)  
			bool isLoop)					// (意义未知)  
{
	string imageFilename = imageName;
	string confFilename = "";
	string filename = imageFilename.substr(0, imageFilename.length()-4);
	string aniName = formatName(imageFilename.c_str(), start);

	Animation* animation = (Animation*)getImage(3, aniName.c_str());
	if (animation != NULL)
		return animation;
	
	if (imageFilename.find(".wil") != string::npos)
		confFilename = filename + ".wix";
	else if (imageFilename.find(".wzl") != string::npos)
		confFilename = filename + ".wzx";
	else
		return 0;
	
	animation = Animation::create();
	animation->setDelayPerUnit(ftime);
	animation->setRestoreOriginalFrame(false);

	if (isLoop) 
		animation->setLoops(-1);
	else
		animation->setLoops(1);

	for (int i=start; i	< start+frame;)
	{
		SpriteFrame* spriteFrame = readMirSpriteFrame(i, imageFilename.c_str(), confFilename.c_str());

		if (spriteFrame != 0)
			animation->addSpriteFrame(spriteFrame);
		else
			log("no found spriteframe %d, %s, %s", i, imageFilename.c_str(), confFilename.c_str());

		i += skip;
	}

	retainImage(3, aniName.c_str(), animation);

	return animation;
}

Animation* MirFileLoader::readMirAnimation(const char* imageName, AniAction* action)
{
	return readMirAnimation(imageName, action->start, action->frame, 1, action->ftime, action->isLoops);
}

Animate* MirFileLoader::readMirAnimate(const char* imageName,
			int start,				// 开始帧
			int frame,				// 帧数
			int skip,				// 跳过的帧数
			float ftime,            // 每帧的延迟时间(毫秒)
			bool isLoops)			// (意义未知)
{
	auto animation = readMirAnimation(imageName, start, frame, 1, ftime, isLoops);

	if (animation == NULL)
		log("animation %d no found", imageName);

	auto animate = Animate::create(animation);

	return animate;
}

SpriteFrame* MirFileLoader::readMirSpriteFrame(int _index, const char* imageName, const char* confName)
{
	int index = (int)_index;
	string resName = formatName(imageName, index);
	//auto spriteFrame = SpriteFrameCache::getInstance()->getSpriteFrameByName(resName);
	auto spriteFrame = (SpriteFrame*)getImage(1, resName.c_str());

	if (spriteFrame == 0)
	{
		void* info = NULL;
		RandomAccessFile* imageFile = FileCache::getInstance()->getFile(imageName);
		RandomAccessFile* confFile = FileCache::getInstance()->getFile(confName);

		if (imageFile == NULL || confFile == NULL)
			return 0;

		Texture2D* pTexture = (Texture2D*)getImage(2, resName.c_str());
		if (pTexture == 0)
		{
			pTexture = readMirTexture(index, imageFile, confFile, info);
			if (pTexture == 0)
			{
				if (info)
					delete info;
				return 0;
			}

			retainImage(2, resName.c_str(), pTexture);
		}
	
		Rect rect(0, 0, pTexture->getContentSize().width, pTexture->getContentSize().height);
		spriteFrame = SpriteFrame::createWithTexture(pTexture, rect);
		retainImage(1, resName.c_str(), spriteFrame);
		
		//Vec2 vec2(info->getOffsetX() + xDeviation/2, -info->getOffsetY()-sourceSize.height+TILE_HEIGHT);
		Size size = pTexture->getContentSize();//spriteFrame->getOriginalSize();
		MirImageInfo *imageInfo = (MirImageInfo*)info;
		//spriteFrame->setOffset(Vec2(imageInfo->getOffsetX(), imageInfo->getOffsetY() + size.height));
		spriteFrame->setOffset(Vec2(imageInfo->getOffsetX(),-imageInfo->getOffsetY()-size.height+TILE_HEIGHT));

		delete info;
	}

	return spriteFrame;
}


SpriteX* MirFileLoader::readMirActionSprite(const char* filename, int atype, int offset)
{
	vector<AniAction> actions = getAniActionConfFromType(atype);

	assert(actions.size() > 0);

	return readMirActionSprite(filename, actions, offset);
}

SpriteX* MirFileLoader::readMirActionSprite(const char* filename, vector<AniAction> actions, int offset)
{
	SpriteX* sprite = 0;//SpriteX::create();

	for (int i=0; i < actions.size(); ++i)
	{
		actions[i].start += offset;

		for (int dir=1; dir<actions[i].dir+1; ++dir)
		{
			int startOffset = actions[i].start + (dir-1)*(actions[i].skip+actions[i].frame);
			auto animate = readMirAnimate(filename, startOffset, actions[i].frame, actions[i].skip, actions[i].ftime, actions[i].isLoops);
			//auto animate = Animate::create(animation);

			int aniName = i * actions[i].dir + dir;
			string aniNameStr = IntToString(aniName);

			if (sprite == 0)
			{
				Vector<AnimationFrame*> frames = animate->getAnimation()->getFrames();
				AnimationFrame* animationFrame = frames.at(0);
				SpriteFrame* spriteFrame = animationFrame->getSpriteFrame();

				sprite = SpriteX::createWithSpriteFrameWithRetain(spriteFrame);
			}

			sprite->addStateAni(aniNameStr.c_str(), animate);
		}
	}

	//CallFunc* func = CallFunc::cr;
	sprite->setAnchorPoint(Vec2(0, 0));

	return sprite;
}

vector<AniAction> MirFileLoader::getAniActionConfFromType(int type)
{
	vector<AniAction> actions = MirAniAction::actionList[type-1];
	/*
	switch(type)
	{
		case HUMAN:
			actions =  MirAniAction::HumAction;
			break;
		case MONSTER:
			actions =  MirAniAction::MonsterAction;
			break;
		case GODMON:
			actions = MirAniAction::GodMonAction;
			break;
		case NPC:
			actions = MirAniAction::NPCAction;
			break;
	}
	*/
	return actions;
}

void MirFileLoader::setClearNearBlackColor(bool clear)
{
	WZLReader::getInstance()->setClearNearBlackColor(clear);
}

void MirFileLoader::launchSchedule()
{
	if (m_isLoadingRes == false)
	{
		//schedule(schedule_selector(MirFileLoader::updateRes), 0.2f);
		//scheduleUpdate();
		Director::getInstance()->getScheduler()->scheduleUpdate(this, 1, false);

		m_isLoadingRes = true;

		thread t1(&MirFileLoader::loadingResThread, this);
		t1.detach();
	}
}

void MirFileLoader::stopSchedule()
{
	if (m_isLoadingRes == true)
	{
		Director::getInstance()->getScheduler()->unscheduleUpdate(this);
		//unscheduleUpdate();
		//unschedule(schedule_selector(MirFileLoader::updateRes));

		m_isLoadingRes = false;
	}
}

void MirFileLoader::update(float delta)
{
	m_mutex.lock();
	int commandCount = m_LoadedCommand.size() > 50 ? 50:m_LoadedCommand.size();
	
	for(int i=0;i<commandCount;++i)
	{
		if (!m_LoadedCommand.empty())
		{
			m_parsingCommand.push(m_LoadedCommand.front());
			m_LoadedCommand.pop();
		}
	}
	m_mutex.unlock();

	for (int i=0;i<m_parsingCommand.size();++i)
	{
		parseCommand(m_parsingCommand.front());
		m_parsingCommand.pop();
	}

	FileCache::getInstance()->updateFile();
}

void MirFileLoader::parseCommand(AsyncLoadingCommand* command)
{
	MirImageInfo* info = NULL;
	Texture2D* text = NULL;
	SpriteFrame* frame = NULL;
	SpriteX* sprite = NULL;
	Animation* animaiton = NULL;

	switch(command->type)
	{
	case 1:  //load frame
		info = (MirImageInfo*)command->imageInfo;

		assert(info->getData());

		text = createTexture2D(info, formatName(command->filename.c_str(), info->getIndex()).c_str());
		frame = createSpriteFrame(text, formatName(command->filename.c_str(), info->getIndex()).c_str());

		if (info->getOffsetX() != 0 || info->getOffsetY() != 0)
		{
			auto destSize = text->getContentSize();
			Size sourceSize(Vec2(info->getWidth(), info->getHeight()));
			auto xDeviation = destSize.width - sourceSize.width;
	
			Vec2 vec2(info->getOffsetX() + xDeviation/2, -info->getOffsetY()-sourceSize.height+TILE_HEIGHT);
			frame->setOffset(vec2);
		}
			
		assert(frame);

		break;
	case 2:  //load actionSprite
		sprite = realReadMirActionSpriteForThread(command->filename.c_str(), command->atype, command->offset);

		assert(sprite);

		//sigal sprite create
		m_isSpriteLoadedMap[formatName(command->filename.c_str(), command->offset)] = 1;

		sendActionSpriteCreateSuccessEvent(sprite);

		break;
	case 3:
		animaiton = readMirAnimation(command->filename.c_str(), command->aniAction);

		assert(animaiton);
		break;
	}

	//delete
	CC_SAFE_RELEASE(((MirImageInfo*)(command->imageInfo)));
	CC_SAFE_DELETE(command->aniAction);
	CC_SAFE_DELETE(command);
}

void MirFileLoader::sendActionSpriteCreateSuccessEvent(SpriteX* sprite)
{
	auto engine = cocos2d::LuaEngine::getInstance();

	cocos2d::BasicScriptData    scriptdata(this, sprite);
	cocos2d::ScriptEvent    eve(cocos2d::ScriptEventType::kCallFuncEvent, &scriptdata);
	engine->sendEvent(&eve);
	//sprite->delStateAni("");
}

Texture2D* MirFileLoader::createTexture2D(void* _info, const char* filename)
{
	void* pTexture2D = getImage(2, filename);
	if (pTexture2D != NULL)
		return (Texture2D*)pTexture2D;

	MirImageInfo* info = (MirImageInfo*)_info;

	Texture2D* text = new Texture2D();
	bool ret = text->initWithData(info->getData(), info->getDataSize(), Texture2D::PixelFormat::RGBA8888, 
		info->getWidth(), info->getHeight(), Size(info->getWidth(), info->getHeight()));

	if (text != 0)
		retainImage(2, filename, text);

	return text;
}

SpriteFrame* MirFileLoader::createSpriteFrame(Texture2D* text, const char* filename)
{
	void* _spriteFrame = getImage(1, filename);
	if (_spriteFrame != NULL)
		return (SpriteFrame*)_spriteFrame;

	Rect rect(0, 0, text->getContentSize().width, text->getContentSize().height);
	auto spriteFrame = SpriteFrame::createWithTexture(text, rect);

	if (spriteFrame != 0)
		retainImage(1, filename, spriteFrame);

	return spriteFrame;
}

SpriteX* MirFileLoader::asyncReadMirActionSprite(const char* filename, int atype, int offset)
{
	string spriteName = formatName(filename, offset);

	if (m_loadedRes.find(spriteName) != m_loadedRes.end())
	{
		AsyncLoadingCommand* res = new AsyncLoadingCommand();
		res->filename = filename;
		res->atype  = atype;
		res->offset = offset;
		res->type   = 2;

		m_mutex.lock();
		m_waitLoadingCommand.push(res);
		m_mutex.unlock();

		return NULL;
	}
	else if (m_isSpriteLoadedMap.find(spriteName) == m_isSpriteLoadedMap.end())
	{
		AsyncLoadingCommand* res = new AsyncLoadingCommand();
		res->filename = filename;
		res->atype    = atype;
		res->offset   = offset;
		res->type     = 1;

		//printf("read %s\n", spriteName.c_str());
		m_mutex.lock();
		m_waitLoadingCommand.push(res);
		m_mutex.unlock();

		m_loadedRes[spriteName] = 1;

		return NULL;
	}
	else
	{
		AsyncLoadingCommand* command = new AsyncLoadingCommand();
		command->type = 2;
		command->filename = filename;
		command->atype = atype;
		command->offset = offset;

		m_mutex.lock();
		m_LoadedCommand.push(command);
		m_mutex.unlock();
		
		return NULL;
	}
}

void MirFileLoader::loadingResThread()
{
	while(m_isLoadingRes)
	{
		if (!m_waitLoadingCommand.empty())
		{
			AsyncLoadingCommand* res = m_waitLoadingCommand.front();
			//res->sprite = readMirActionSprite(res->filename.c_str(), res->atype, res->offset);
			//thread load image info 
			if (res->type == 1)
			{
				readMirActionSpriteThread(res->filename.c_str(), res->atype, res->offset);
			}
			//m_waitLoadingRes.pop();
			
			//load info complete 
			res->type = 2;

			m_mutex.lock();
			m_LoadedCommand.push(res);
			m_mutex.unlock();

			m_waitLoadingCommand.pop();
		}
		else
		{
			Sleep(10);
		}
	}
}

void MirFileLoader::readMirActionSpriteThread(const char* filename, int atype, int offset)
{
	vector<AniAction> actions = getAniActionConfFromType(atype);

	for (int i=0; i < actions.size(); ++i)
	{
		actions[i].start += offset;

		for (int dir=1; dir<9; ++dir)
		{
			int startOffset = actions[i].start + (dir-1)*(actions[i].skip+actions[i].frame);
			readMirAnimationThread(filename, startOffset, actions[i].frame, 1, 
				actions[i].ftime, actions[i].isLoops);
		}
	}
}

void MirFileLoader::readMirAnimationThread(const char* imageName,
		int start,				// 开始帧
		int frame,				// 帧数
		int skip,				// 跳过的帧数
		float ftime,            // 每帧的延迟时间(毫秒)
		bool isLoops)
{
	string imageFilename = imageName;
	string confFilename = convertImageFilenameToConfFilename(imageFilename);
	string filename = imageFilename.substr(0, imageFilename.length()-4);
	string aniName = formatName(imageFilename.c_str(), start);
	
	Animation* animation = (Animation*)getImage(3, aniName.c_str());
	if (animation != NULL)
		return ;
	
	for (int i=start; i	< start+frame; )
	{
		readMirSpriteFrameThread(i, imageFilename.c_str(), confFilename.c_str());
		i += skip;
	}

	//all frame info load complete, so this time got to send a animation create command
	AsyncLoadingCommand* command = new AsyncLoadingCommand();
	command->type = 3;
	command->filename = imageName;

	AniAction *action = new AniAction(start, frame, skip, ftime, isLoops);
	command->aniAction = action;

	m_mutex.lock();
	m_LoadedCommand.push(command);
	m_mutex.unlock();
}

void MirFileLoader::readMirSpriteFrameThread(int index, const char* imageName, const char* confName)
{
	string resName = formatName(imageName, index);
	//auto spriteFrame = SpriteFrameCache::getInstance()->getSpriteFrameByName(resName);
	auto spriteFrame = (SpriteFrame*)getImage(1, resName.c_str());

	if (spriteFrame == 0)
	{
		RandomAccessFile* imageFile = FileCache::getInstance()->getFile(imageName);
		RandomAccessFile* confFile = FileCache::getInstance()->getFile(confName);
		MirImageInfo* info = NULL;

		if (resName.find(".wil") != string::npos)
			info = WILReader::getInstance()->readMirImageInfo(index, imageFile, confFile);
		else if (resName.find(".wzl") != string::npos)
			info = WZLReader::getInstance()->readMirImageInfo(index, imageFile, confFile);

		if (info)
		{
			AsyncLoadingCommand* command = new AsyncLoadingCommand();
			command->type = 1;
			command->imageInfo = info;
			command->filename = imageName;

			m_mutex.lock();
			//printf("m_LoadedCommand count:%d\n", m_LoadedCommand.size());
			m_LoadedCommand.push(command);
			m_mutex.unlock();
		}
		//Size size = spriteFrame->getOriginalSize();
		//spriteFrame->setOffset(Vec2(info->getOffsetX(),-info->getOffsetY()-size.height));
	}

	Sleep(4);
}

SpriteX* MirFileLoader::realReadMirActionSpriteForThread(const char* filename, int atype, int offset)
{
	return readMirActionSprite(filename, atype, offset);
}

string MirFileLoader::convertImageFilenameToConfFilename(string imageFilename)
{
	string confFilename = "";
	string filename = imageFilename.substr(0, imageFilename.length()-4);

	if (imageFilename.find(".wil") != string::npos)
		confFilename = filename + ".wix";
	else if (imageFilename.find(".wzl") != string::npos)
		confFilename = filename + ".wzx";

	return confFilename;
}

string MirFileLoader::formatName(const char* filename, int index)
{
	string str = filename;
	str += "_";
	str += IntToString(index);

	return str;
}

void MirFileLoader::retainImage(int type, const char* name, Ref* node)
{
	if (node == NULL)
		return;

	switch (type)
	{
	case 1:
		//TextureCache::getInstance()->
		m_spriteFrameMap[name] = (SpriteFrame*)node;
		//SpriteFrameCache::getInstance()->addSpriteFrame((SpriteFrame*)node, name);
		node->retain();
		break;
	case 2:
		m_texture2DMap[name] = (Texture2D*)node;
		node->retain();
		break;
	case 3:
		m_animationMap[name] = (Animation*)node;
		node->retain();
		//AnimationCache::getInstance()->addAnimation((Animation*)node, name);
		break;
	}
}

Ref* MirFileLoader::getImage(int type, const char* name)
{
	Ref* ptr = NULL;

	switch (type)
	{
	case 1:
		if (m_spriteFrameMap.find(name) != m_spriteFrameMap.end())
			return m_spriteFrameMap[name];
		break;
	case 2:
		if (m_texture2DMap.find(name) != m_texture2DMap.end())
			return m_texture2DMap[name];
		break;
	case 3:
		if (m_animationMap.find(name) != m_animationMap.end())
			return m_animationMap[name];
		break;
	}

	return 0;
}

void MirFileLoader::release()
{
	for(map<string, SpriteFrame*>::iterator iter=m_spriteFrameMap.begin();iter != m_spriteFrameMap.end(); ++iter)
	{
		iter->second->release();
	}

	for(map<string, Texture2D*>	::iterator iter=m_texture2DMap.begin();iter != m_texture2DMap.end(); ++iter)
	{
		iter->second->release();
	}

	for(map<string, Animation*>::iterator iter=m_animationMap.begin();iter != m_animationMap.end(); ++iter)
	{
		iter->second->release();
	}

	m_spriteFrameMap.clear();
	m_texture2DMap.clear();
	m_animationMap.clear();

	stopSchedule();
	//release file cache
	FileCache::getInstance()->release();

	Node::release();
}

string IntToString(int number)
{
	char buff[10];
	sprintf(buff, "%d", number);

	string buffStr = buff;

	return buffStr;
}