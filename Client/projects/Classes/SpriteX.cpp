#include "SpriteX.h"

const GLchar* const szEffectFragSource =
		"#ifdef GL_ES													  \n \
		precision mediump float;										  \n \
		#endif															  \n \
		varying vec2 v_texCoord;										  \n \
		varying vec4 v_fragmentColor;									  \n \
		uniform mat4 matrixEffect;										  \n \
		void main(void)													  \n \
		{																  \n \
			gl_FragColor = texture2D(CC_Texture0, v_texCoord)*matrixEffect*v_fragmentColor; \n \
		}";

const GLchar* const szVShaderFilename =
		"attribute vec4 a_position;	\n \
		attribute vec2 a_texCoord;	\n \
		attribute vec4 a_color;		\n \
		varying vec2 v_texCoord;	\n \
		void main()					\n \
		{                           \n \
			gl_Position = CC_PMatrix * a_position;  \n \
			v_texCoord = a_texCoord;           \n \
		}";

const GLchar* const szFShaderFilename =
		"varying vec2 v_texCoord;	\n \
		uniform mat3 u_hue;			\n \
		uniform float u_alpha;		\n \
		void main()					\n \
		{                           \n \
			vec4 pixColor = texture2D(CC_Texture0, v_texCoord);  \n \
			vec3 rgbColor ;  \n \
			rgbColor = u_hue * pixColor.rgb;  \n \
			gl_FragColor = vec4(rgbColor.r,rgbColor.g,rgbColor.b, pixColor.a * u_alpha);  \n \
		}";

const GLchar* const szStrokeSource =
"varying vec4 v_fragmentColor; \n \
		varying vec2 v_texCoord; // 纹理坐标  \n \
		uniform float outlineSize; // 描边宽度，以像素为单位  \n \
		uniform vec3 outlineColor; // 描边颜色  \n \
		uniform vec2 textureSize; // 纹理大小（宽和高），为了计算周围各点的纹理坐标，必须传入它，因为纹理坐标范围是0~1  \n \
		uniform vec3 foregroundColor; // 主要用于字体，可传可不传，不传默认为白色  \n \
		// 判断在这个角度上距离为outlineSize那一点是不是透明  \n \
		int getIsStrokeWithAngel(float angel)  \n \
		{  \n \
			int stroke = 0;  \n \
			float rad = angel * 0.01745329252;   \n \
			//float a = texture2D(CC_Texture0, vec2(v_texCoord.x + outlineSize * cos(rad) / textureSize.x, v_texCoord.y + outlineSize * sin(rad) / textureSize.y)).a; // 这句比较难懂，outlineSize * cos(rad)可以理解为在x轴上投影，除以textureSize.x是因为texture2D接收的是一个0~1的纹理坐标，而不是像素坐标  \n \
			vec4 c =  texture2D(CC_Texture0, vec2(v_texCoord.x + outlineSize * cos(rad) / textureSize.x, v_texCoord.y + outlineSize * sin(rad) / textureSize.y)); \n \
			if (c.a >= 0.5 && !(c.r >= 0 && c.r <= 24.0f/255.0f && c.g >= 0 && c.g <= 24.0f/255.0f && c.b <= 24.0f/255.0f && c.b >= 0))// 我把alpha值大于0.5都视为不透明，小于0.5都视为透明  \n \
			{  \n \
				stroke = 1;  \n \
			}  \n \
			return stroke;  \n \
		}  \n \
		void main()  \n \
		{  \n \
			vec4 myC = texture2D(CC_Texture0, vec2(v_texCoord.x, v_texCoord.y)); // 正在处理的这个像素点的颜色  \n \
			myC.rgb *= foregroundColor;  \n \
			if (myC.a >= 0.5) // 不透明，不管，直接返回  \n \
			{  \n \
				gl_FragColor = v_fragmentColor * myC;  \n \
				return;  \n \
			}  \n \
			// 这里肯定有朋友会问，一个for循环就搞定啦，怎么这么麻烦！其实我一开始也是用for的，但后来在安卓某些机型（如小米4）会直接崩溃，查找资料发现OpenGL es并不是很支持循环，while和for都不要用  \n \
			int strokeCount = 0;  \n \
			strokeCount += getIsStrokeWithAngel(0.0);  \n \
			strokeCount += getIsStrokeWithAngel(30.0);  \n \
			strokeCount += getIsStrokeWithAngel(60.0);  \n \
			strokeCount += getIsStrokeWithAngel(90.0);  \n \
			strokeCount += getIsStrokeWithAngel(120.0);  \n \
			strokeCount += getIsStrokeWithAngel(150.0);  \n \
			strokeCount += getIsStrokeWithAngel(180.0);  \n \
			strokeCount += getIsStrokeWithAngel(210.0);  \n \
			strokeCount += getIsStrokeWithAngel(240.0);  \n \
			strokeCount += getIsStrokeWithAngel(270.0);  \n \
			strokeCount += getIsStrokeWithAngel(300.0);  \n \
			strokeCount += getIsStrokeWithAngel(330.0);  \n \
			if (strokeCount > 0) // 四周围至少有一个点是不透明的，这个点要设成描边颜色 \n \
			{				\n \
				myC.rgb = outlineColor;  \n \
				myC.a = 1.0;  \n \
			}			\n \
			gl_FragColor = v_fragmentColor * myC;  \n \
		}";

/*
void xRotateMat(float mat[3][3], float rs, float rc);
void yRotateMat(float mat[3][3], float rs, float rc);
void zRotateMat(float mat[3][3], float rs, float rc);
void matrixMult(float a[3][3], float b[3][3], float c[3][3]);
void hueMatrix(GLfloat mat[3][3], float angle);
void premultiplyAlpha(GLfloat mat[3][3], float alpha);
*/
SpriteX::SpriteX(void)
{
	m_pShader = 0;
}

SpriteX::~SpriteX(void)
{
	for(auto iter=m_stateAniMap.begin();iter!=m_stateAniMap.end();++iter)
	{
		CC_SAFE_RELEASE(iter->second);
	}

	m_stateAniMap.clear();
}

bool SpriteX::init()
{
	//this->setupDefaultSettings();
    //this->initShader();
	//

	return true;
}

void SpriteX::setShaderEnable(bool enable)
{
	if (enable)
	{
		if (m_pShader == NULL)
		{
			m_pShader = RemindShader::create();
			m_pShader->retain();

			if (this->getParent() != NULL)
			{
				this->getParent()->addChild(m_pShader, this->getLocalZOrder()-1);
			}
		}
	}
	else
	{
		if (m_pShader)
		{
			this->removeChild(m_pShader, true);
			m_pShader->release();
			m_pShader = 0;
		}
	}
}

SpriteX* SpriteX::create()
{
	SpriteX *sprite = new (std::nothrow) SpriteX();
    if (sprite)
    {
		sprite->init();
        sprite->autorelease();

        return sprite;
    }
    CC_SAFE_DELETE(sprite);
    return nullptr;
}

 SpriteX* SpriteX::create(const std::string& filename)
 {
	SpriteX *sprite = new (std::nothrow) SpriteX();
    if (sprite && sprite->initWithFile(filename))
    {
		sprite->init();
        sprite->autorelease();
        return sprite;
    }
    CC_SAFE_DELETE(sprite);

    return nullptr;
 }

SpriteX* SpriteX::create(const std::string& filename, const Rect& rect)
{
	SpriteX *sprite = new (std::nothrow) SpriteX();
    if (sprite && sprite->initWithFile(filename, rect))
    {
		sprite->init();
        sprite->autorelease();
        return sprite;
    }
    CC_SAFE_DELETE(sprite);
    return nullptr;
}

SpriteX* SpriteX::createWithTexture(Texture2D *texture)
{
	SpriteX *sprite = new (std::nothrow) SpriteX();
	if (sprite && sprite->initWithTexture(texture))
    {
		sprite->init();
        sprite->autorelease();
        return sprite;
    }
    CC_SAFE_DELETE(sprite);
    return nullptr;
}

SpriteX* SpriteX::createWithTexture(Texture2D *texture, const Rect& rect, bool rotated)
{
	SpriteX *sprite = new (std::nothrow) SpriteX();
	if (sprite && sprite->initWithTexture(texture, rect, rotated))
    {
		sprite->init();
        sprite->autorelease();
        return sprite;
    }
    CC_SAFE_DELETE(sprite);
    return nullptr;
}

SpriteX* SpriteX::createWithSpriteFrame(SpriteFrame *spriteFrame)
{
	SpriteX *sprite = new (std::nothrow) SpriteX();
	if (sprite && sprite->initWithSpriteFrame(spriteFrame))
    {
		sprite->init();
        sprite->autorelease();
        return sprite;
    }
    CC_SAFE_DELETE(sprite);
    return nullptr;
}

SpriteX* SpriteX::createWithSpriteFrameWithRetain(SpriteFrame *spriteFrame)
{
	SpriteX *sprite = new (std::nothrow) SpriteX();
	if (sprite && sprite->initWithSpriteFrame(spriteFrame))
    {
		sprite->init();
        return sprite;
    }
    CC_SAFE_DELETE(sprite);
    return nullptr;
}

SpriteX* SpriteX::createWithSpriteFrameName(const std::string& spriteFrameName)
{
	SpriteX *sprite = new (std::nothrow) SpriteX();
	if (sprite && sprite->initWithSpriteFrameName(spriteFrameName))
    {
		sprite->init();
        sprite->autorelease();
        return sprite;
    }
    CC_SAFE_DELETE(sprite);
    return nullptr;
}

bool SpriteX::setEffect(int effectid)
{
	VertexEffect::getInstance()->setEffectForSprite(this, effectid);

	return true;
}

bool SpriteX::setEdging(float outlineSize, Color3B outlineColor, Size textureSize, Color3B foregroundColor)
{
	auto programState = VertexEffect::getInstance()->getStrokeProgramState(outlineSize, outlineColor, textureSize, foregroundColor);
	this->setGLProgramState(programState);

	return true;
}

void SpriteX::merge(SpriteX* sprite)
{
	for(auto iter=sprite->m_stateAniMap.begin();iter!=sprite->m_stateAniMap.end();++iter)
	{
		addStateAni(iter->first.c_str(), iter->second);
	}

	sprite->release();
}

void SpriteX::stopAllActions()
{
	Sprite::stopAllActions();
}

bool SpriteX::isPlayingAction()
{
	auto num = this->getNumberOfRunningActions();
	return num > 0 ? true : false;
}

bool SpriteX::runStateAni(const char* aniName)
{
	if (m_stateAniMap.find(aniName) == m_stateAniMap.end())
		return false;

	/*
	if (aniName == m_stateStr && this->isRunning())
		return false;
	*/
	if (this->isRunning())
		stopAction(m_stateAniMap[m_stateStr]);

	auto animate = m_stateAniMap[aniName];
	runAction(animate);

	m_stateStr = aniName;

	return true;
}

void SpriteX::addStateAni(const char* aniName, Animate* animate)
{
	if (m_stateAniMap.find(aniName) != m_stateAniMap.end())
		m_stateAniMap[aniName]->release();

	if (animate == NULL)
		return;

	animate->retain();
	m_stateAniMap[aniName] = animate;

	/*
	if (getTexture() == 0)
	{
		Vector<AnimationFrame*> frames = animate->getAnimation()->getFrames();
		AnimationFrame* animationFrame = frames.at(0);
		SpriteFrame* spriteFrame = animationFrame->getSpriteFrame();
	}*/
}

void SpriteX::delStateAni(const char* aniName)
{
	if (m_stateAniMap.find(aniName) == m_stateAniMap.end())
		return;

	auto iter = m_stateAniMap.find(aniName);

	m_stateAniMap.erase(iter);
}

Animate* SpriteX::getAnimateFromName(const char* aniName)
{
	if (m_stateAniMap.find(aniName) != m_stateAniMap.end())
		return m_stateAniMap[aniName];

	return NULL;
}

Animate* SpriteX::getAnimateFromIndex(int index)
{
	int aniCount = 0;
	for(auto iter=m_stateAniMap.begin();iter!=m_stateAniMap.end();++iter)
	{
		if (aniCount == index)
		{
			return iter->second;
		}

		aniCount++;
	}

	return NULL;
}

int SpriteX::getAinmateCount()
{
	int aniCount = 0;
	for(auto iter=m_stateAniMap.begin();iter!=m_stateAniMap.end();++iter)
	{
		aniCount++;
	}

	return aniCount;
}

void SpriteX::draw(Renderer *renderer, const Mat4 &transform, uint32_t flags)
{
	if (m_pShader != NULL && m_pShader->getParent() != NULL)
		m_pShader->push2Draw(this);

	Sprite::draw(renderer, transform, flags);
}

void SpriteX::release()
{
	if (m_pShader)
	{
		this->removeChild(m_pShader, true);
		m_pShader->release();
		m_pShader = 0;
	}

	Sprite::release();
}

VertexEffect* VertexEffect::m_pInstance = 0;

VertexEffect::VertexEffect()
{
}

VertexEffect::~VertexEffect()
{

}

VertexEffect* VertexEffect::getInstance()
{
	if (m_pInstance == 0)
	{
		m_pInstance = new VertexEffect();
		m_pInstance->initEffect();
	}

	return m_pInstance;
}

bool VertexEffect::initEffect()
{
	float f0[] = {
		1.0f, 0.0f, 0.0f, 0.0f,
		0.0f, 1.0f, 0.0f, 0.0f,
		0.0f, 0.0f, 1.0f, 0.0f,
		0.0f, 0.0f, 0.0f, 1.0f
	};
	m_matrices.push_back(Mat4(f0));

	//黑白化
	float f1[] = {
		0.299f, 0.587f, 0.184f, 0.0f,
		0.299f, 0.587f, 0.184f, 0.0f,
		0.299f, 0.587f, 0.184f, 0.0f,
		0.0f,   0.0f,   0.0f,   1.0f
	};
	m_matrices.push_back(Mat4(f1));

	//老照片
	float f2[] = {
		0.299f, 0.587f, 0.184f, 0.3137f,
		0.299f, 0.587f, 0.184f, 0.1686f,
		0.299f, 0.587f, 0.184f,-0.0901f,
		0.0f,   0.0f,   0.0f,   1.0f
	};
	m_matrices.push_back(Mat4(f2));

	//反相
	float f3[] = {
	   -1.0f, 0.0f, 0.0f, 1.0f,
		0.0f,-1.0f, 0.0f, 1.0f,
		0.0f, 0.0f,-1.0f, 1.0f,
		0.0f, 0.0f, 0.0f, 1.0f
	};
	m_matrices.push_back(Mat4(f3));

	//灼伤（偏红）
	float f4[] = {
		1.0f,  0.0f, 0.0f, 0.0f,
		0.0f,  0.6f, 0.0f, 0.0f,
		0.0f,  0.0f, 0.6f, 0.0f,
		1.0f,  0.0f, 0.0f, 1.0f
	};
	m_matrices.push_back(Mat4(f4));

	//中毒（偏绿）
	float f5[] = {
		0.6f,  0.0f, 0.0f, 0.0f,
		0.0f,  1.0f, 0.0f, 0.0f,
		0.0f,  0.0f, 0.6f, 0.0f,
		0.0f,  1.0f, 0.0f, 1.0f
	};
	m_matrices.push_back(Mat4(f5));

	//寒冷（偏蓝）
	float f6[] = {
		0.6f,  0.0f, 0.0f, 0.0f,
		0.0f,  0.6f, 0.0f, 0.0f,
		0.0f,  0.0f, 1.0f, 0.0f,
		0.0f,  0.0f, 1.0f, 1.0f
	};
	m_matrices.push_back(Mat4(f6));

	float f7[] = {
		0.58f,  0.50f, 0.32f, 1.0f,
		0.5f,  1.5f, 1.0f, 1.0f,
		1.0f,  1.0f, 1.5f, 1.0f,
		0.5f,  0.5f, 0.5f, 0.5f,
	};
	m_matrices.push_back(Mat4(f7));

	return true;
}

bool VertexEffect::setEffectForSprite(Sprite* sprite, int effectid)
{
	GLProgram* program = GLProgram::createWithByteArrays(ccPositionTextureColor_noMVP_vert,szEffectFragSource);
	sprite->setGLProgram(program);
	sprite->setGLProgramState(GLProgramState::create(program));
	sprite->getGLProgramState()->setUniformMat4(EFFECT_MATRIX_NAME,m_matrices[ES_NONE]);
	sprite->getGLProgramState()->setUniformMat4(EFFECT_MATRIX_NAME,m_matrices[effectid]);
	//->getGLProgramState()->setUniformMat4(EFFECT_MATRIX_NAME,m_matrices[sel]);

	return true;
}

GLProgramState* VertexEffect::getStrokeProgramState(float outlineSize, Color3B outlineColor, Size textureSize, Color3B foregroundColor/* = cocos2d::Color3B::WHITE*/ )
{
	auto glprogram = GLProgramCache::getInstance()->getGLProgram(EFFECT_STROKE_NAME);
    if (!glprogram)
    {
        //std::string fragmentSource = szStrokeSource;//FileUtils::getInstance()->getStringFromFile(FileUtils::getInstance()->fullPathForFilename("shaders/stroke.fsh"));
        glprogram = GLProgram::createWithByteArrays(ccPositionTextureColor_noMVP_vert, szStrokeSource);
        GLProgramCache::getInstance()->addGLProgram(glprogram, EFFECT_STROKE_NAME);
    }

    auto glprogramState = GLProgramState::getOrCreateWithGLProgram(glprogram);

    glprogramState->setUniformFloat("outlineSize", outlineSize);
    glprogramState->setUniformVec3("outlineColor", Vec3(outlineColor.r / 255.0f, outlineColor.g / 255.0f, outlineColor.b / 255.0f));
    glprogramState->setUniformVec2("textureSize", Vec2(textureSize.width, textureSize.height));
    glprogramState->setUniformVec3("foregroundColor", Vec3(foregroundColor.r / 255.0f, foregroundColor.g / 255.0f, foregroundColor.b / 255.0f));

    return glprogramState;
}

void VertexEffect::destroy()
{
	if (m_pInstance != 0)
		delete m_pInstance;
}

///////////////////////////////////
/*
void SpriteX::setupDefaultSettings()
{
    this->m_hue = 0.0;
}

void SpriteX::initShader()
{
    GLProgram * p = new GLProgram();
    this->setGLProgram(p);
    p->release();
    p->initWithFilenames(szVShaderFilename, szFShaderFilename);
    p->link();
    p->updateUniforms();
    this->getUniformLocations();
    this->updateColor();
}

void SpriteX::getUniformLocations()
{
    m_hueLocation = glGetUniformLocation(this->getGLProgram()->getProgram(), "u_hue");
    m_alphaLocation = glGetUniformLocation(this->getGLProgram()->getProgram(), "u_alpha");
}

void SpriteX::updateColorMatrix()
{
    this->getGLProgram()->use();
    GLfloat mat[3][3];
    memset(mat, 0, sizeof(GLfloat)*9);
    hueMatrix(mat, m_hue);
    premultiplyAlpha(mat, this->alpha());
    glUniformMatrix3fv(m_hueLocation, 1, GL_FALSE, (GLfloat *)&mat);
}

void SpriteX::updateAlpha()
{
    this->getGLProgram()->use();
    glUniform1f(m_alphaLocation, this->alpha());
}

GLfloat SpriteX::alpha()
{
    return _displayedOpacity / 255.0f;
}

void SpriteX::setHue(GLfloat _hue)
{
    m_hue = _hue;
    this->updateColorMatrix();
}

void SpriteX::updateColor()
{
    Sprite::updateColor();
    this->updateColorMatrix();
    this->updateAlpha();
}


#pragma mark -

void xRotateMat(float mat[3][3], float rs, float rc)
{
    mat[0][0] = 1.0;
    mat[0][1] = 0.0;
    mat[0][2] = 0.0;

    mat[1][0] = 0.0;
    mat[1][1] = rc;
    mat[1][2] = rs;

    mat[2][0] = 0.0;
    mat[2][1] = -rs;
    mat[2][2] = rc;
}

void yRotateMat(float mat[3][3], float rs, float rc)
{
    mat[0][0] = rc;
    mat[0][1] = 0.0;
    mat[0][2] = -rs;

    mat[1][0] = 0.0;
    mat[1][1] = 1.0;
    mat[1][2] = 0.0;

    mat[2][0] = rs;
    mat[2][1] = 0.0;
    mat[2][2] = rc;
}


void zRotateMat(float mat[3][3], float rs, float rc)
{
    mat[0][0] = rc;
    mat[0][1] = rs;
    mat[0][2] = 0.0;

    mat[1][0] = -rs;
    mat[1][1] = rc;
    mat[1][2] = 0.0;

    mat[2][0] = 0.0;
    mat[2][1] = 0.0;
    mat[2][2] = 1.0;
}

void matrixMult(float a[3][3], float b[3][3], float c[3][3])
{
    int x, y;
    float temp[3][3];

    for(y=0; y<3; y++) {
        for(x=0; x<3; x++) {
            temp[y][x] = b[y][0] * a[0][x] + b[y][1] * a[1][x] + b[y][2] * a[2][x];
        }
    }
    for(y=0; y<3; y++) {
        for(x=0; x<3; x++) {
            c[y][x] = temp[y][x];
        }
    }
}

void hueMatrix(GLfloat mat[3][3], float angle)
{
#define SQRT_2      sqrt(2.0)
#define SQRT_3      sqrt(3.0)

    float mag, rot[3][3];
    float xrs, xrc;
    float yrs, yrc;
    float zrs, zrc;

    // Rotate the grey vector into positive Z
    mag = SQRT_2;
    xrs = 1.0/mag;
    xrc = 1.0/mag;
    xRotateMat(mat, xrs, xrc);
    mag = SQRT_3;
    yrs = -1.0/mag;
    yrc = SQRT_2/mag;
    yRotateMat(rot, yrs, yrc);
    matrixMult(rot, mat, mat);

    // Rotate the hue
    zrs = sin(angle);
    zrc = cos(angle);
    zRotateMat(rot, zrs, zrc);
    matrixMult(rot, mat, mat);

    // Rotate the grey vector back into place
    yRotateMat(rot, -yrs, yrc);
    matrixMult(rot,  mat, mat);
    xRotateMat(rot, -xrs, xrc);
    matrixMult(rot,  mat, mat);
}

void premultiplyAlpha(GLfloat mat[3][3], float alpha)
{
    for (int i = 0; i < 3; ++i) {
        for (int j = 0; j < 3; ++j) {
            mat[i][j] *= alpha;
        }
    }
}
*/
////////////////////////////////////////////
