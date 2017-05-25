
#include "cocos2d.h"
#include <vector>
#include <map>
#include "RemindShader.h"

USING_NS_CC;
using namespace std;

//定点着色器
#define EFFECT_MATRIX_NAME "matrixEffect"
#define EFFECT_STROKE_NAME "ShjyShader_Stroke"

enum EffectSelect
{
	ES_NONE              = 0,  //没有特效
	ES_BLACK_AND_WHITE   = 1,  //黑白化
	ES_OLD_PHOTOS        = 2,  //老照片
	ES_INVERT            = 3,  //反相
	ES_BURNS			 = 4,  //灼伤（偏红）
	ES_POISONING		 = 5,  //中毒（偏绿）
	ES_COLD			     = 6,  //寒冷（偏蓝)
	ES_WHITE			 = 7,  //白化

	ES_USER_DEFINED //自定义的特效矩阵序号从这里开始
};

class SpriteX : public Sprite
{
public:
	~SpriteX(void);
	

	static SpriteX* create();
	
    static SpriteX* create(const std::string& filename);

    static SpriteX* create(const std::string& filename, const Rect& rect);

    static SpriteX* createWithTexture(Texture2D *texture);

    static SpriteX* createWithTexture(Texture2D *texture, const Rect& rect, bool rotated=false);

    static SpriteX* createWithSpriteFrame(SpriteFrame *spriteFrame);

	static SpriteX* createWithSpriteFrameWithRetain(SpriteFrame *spriteFrame);

    static SpriteX* createWithSpriteFrameName(const std::string& spriteFrameName);
	
	void		release();
	bool		init();
	bool		setEffect(int effectid);
	bool		setEdging(float outlineSize, 
					Color3B outlineColor, 
					Size textureSize, 
					Color3B foregroundColor=Color3B::WHITE);
	//virtual void setHue(GLfloat _hue);
    
	//void runAction(callFu);
	//void runActions();
	void		stopAllActions();
	bool        isPlayingAction();
	void        merge(SpriteX* sprite);
	bool		runStateAni(const char* aniName);
	void		addStateAni(const char* aniName, Animate* animate);
	void        delStateAni(const char* aniName);
	Animate*    getAnimateFromName(const char* aniName);
	Animate*    getAnimateFromIndex(int index);
	int         getAinmateCount();
	void        setShaderEnable(bool enable);
	void		draw(Renderer *renderer, const Mat4 &transform, uint32_t flags);

    CC_SYNTHESIZE_READONLY(GLfloat, m_hue, Hue);

protected://method
    /*
    virtual void setupDefaultSettings();
    
    virtual void getUniformLocations();
    
    virtual void updateColorMatrix();
    
    virtual void updateAlpha();
    
    virtual GLfloat alpha();
    
    virtual void updateColor();
    
    //virtual bool initWithTexture(Texture2D *texture, const Rect& rect, bool rotated);
    
    virtual void initShader();*/

private:
	SpriteX(void);

	//GLint m_hueLocation;
    //GLint m_alphaLocation;
	map<string, Animate*>  m_stateAniMap;
	string                 m_stateStr;

	RemindShader*          m_pShader;
};

class VertexEffect : public Ref
{
public:
	~VertexEffect();

	GLProgramState* getStrokeProgramState(float outlineSize, Color3B outlineColor, Size textureSize, Color3B foregroundColor/* = cocos2d::Color3B::WHITE*/ );  
	int addEffectMatrix(const cocos2d::Mat4& matrix);

	static VertexEffect* getInstance();

	static void destroy();

	bool initEffect();
	bool setEffectForSprite(Sprite* sprite, int effectid);

private:
	std::vector<cocos2d::Mat4>  m_matrices;

	VertexEffect();

	static VertexEffect* m_pInstance;
};

inline int VertexEffect::addEffectMatrix(const cocos2d::Mat4& matrix) 
{
	m_matrices.push_back(matrix);
	return m_matrices.size()-1;
}