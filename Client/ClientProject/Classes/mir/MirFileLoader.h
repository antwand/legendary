#include "SpriteX.h"
#include <queue>

#define HUMDIR 8

using namespace std;

struct AniAction
{
	int start;				 // ��ʼ֡
	int frame;				 // ֡��
	int skip;				 // ������֡��
	float ftime;            // ÿ֡���ӳ�ʱ��(����)
	bool isLoops;
	int dir;   //����

	AniAction(int _start, int _frame, int _skip, float _ftime, bool _isLoops, int _dir=8)
	{
		start = _start;
		frame = _frame;
		skip = _skip;
		ftime =  _ftime;
		isLoops = _isLoops;
		dir = _dir;
	}
};

struct AsyncLoadingCommand
{
	int			type;   //1:imageinfo load complete 2:all imageInfo load complete
	string		filename;
	int			atype;
	int			offset;
	void*		imageInfo;  
	AniAction*	aniAction;

	~AsyncLoadingCommand()
	{
	}

	AsyncLoadingCommand()
	{
		imageInfo = 0;
		aniAction = 0;
		offset = 0;
		atype = 0;
		type = 0;
		filename = "";
	}
};

class MirAniAction
{
public:
	static vector<AniAction> HumAction;
	static vector<AniAction> MonsterAction;
	static vector<AniAction> GodMonAction;
	static vector<AniAction> NPCAction;
	static vector<vector<AniAction>> actionList;

private:
	static bool __init;
	static bool init();
};

class MirFileLoader: public Node
{
	enum ActionType
	{
		HUMAN = 1,
		MONSTER,
		GODMON,
		NPC
	};

public:
	~MirFileLoader(void);

	static MirFileLoader*			getInstance();

	Animation*						readMirAnimation(const char* imageName,
										int start,				// ��ʼ֡
										int frame,				// ֡��
										int skip,				// ������֡��
										float ftime,            // ÿ֡���ӳ�ʱ��(����)
										bool isLoop = true);	// �Ƿ�ѭ��

	Animation*						readMirAnimation(const char* imageName, AniAction* action);			
	Animate*						readMirAnimate(const char* imageName,
										int start,				// ��ʼ֡
										int frame,				// ֡��
										int skip,				// ������֡��
										float ftime,            // ÿ֡���ӳ�ʱ��(����)
										bool isLoops);			// (����δ֪)

	Texture2D*						readMirTexture(int index, void* image, void* conf, void* &_info);
	SpriteFrame*                    readMirSpriteFrame(int index, const char* imageName, const char* confName);
	SpriteX*						readMirActionSprite(const char* filename, int atype, int offset);
	SpriteX*						asyncReadMirActionSprite(const char* filename, int atype, int offset);
	void                            insertActionSetting(int idx, int _start, int _frame, int _skip, float _ftime, bool _isLoops, int _dir = 8);

	void                            setClearNearBlackColor(bool clear);
	void                            launchSchedule();
	void                            stopSchedule();
	void							release();
	void							update(float delta);
	void                            parseCommand(AsyncLoadingCommand* command);

private:
	//load image thread function
	void							loadingResThread();
	void                            readMirActionSpriteThread(const char* filename, int atype, int offset);
	void							readMirAnimationThread(const char* imageName,
										int start,				// ��ʼ֡
										int frame,				// ֡��
										int skip,				// ������֡��
										float ftime,            // ÿ֡���ӳ�ʱ��(����)
										bool isLoops);
	void							readMirSpriteFrameThread(int index, const char* imageName, const char* confName);
	SpriteX*						realReadMirActionSpriteForThread(const char* filename, int atype, int offset);
	void                            sendActionSpriteCreateSuccessEvent(SpriteX* sprite);

	Texture2D*						createTexture2D(void* info, const char* filename);
	SpriteFrame*					createSpriteFrame(Texture2D*, const char* filename);
	SpriteX*						readMirActionSprite(const char* filename, vector<AniAction> actions, int offset);
	string							convertImageFilenameToConfFilename(string imageFilename);
	string                          formatName(const char* filename, int index);
	vector<AniAction>				getAniActionConfFromType(int type);

private:
	MirFileLoader(void);
	static MirFileLoader*			m_pInstance;

	void							retainImage(int type, const char* name, Ref* node);
	Ref*                            getImage(int index, const char* name);

	//cache
	map<string, SpriteFrame*>       m_spriteFrameMap;
	map<string, Texture2D*>			m_texture2DMap;
	map<string, Animation*>			m_animationMap;
	map<string, int>				m_isSpriteLoadedMap;

	//async res list
	queue<AsyncLoadingCommand*>     m_waitLoadingCommand; //�ȴ����̶߳�ȡ��Դ�б�
	queue<AsyncLoadingCommand*>     m_LoadedCommand;      //�ȴ����̼߳��������б�
	queue<AsyncLoadingCommand*>		m_parsingCommand;     //��ǰ���ڴ���ļ��������б�
	map<string, int>				m_loadedRes;		  //����Ѿ����ص���Դ

	std::mutex						m_mutex;//�̻߳������  
	
private:
	bool							m_isLoadingRes;
};

string IntToString(int number);
