#include "PixelCollision.h"

//static const auto kVertexShader = "Shaders/SolidColorShader.vsh";
//static const auto kFragmentShader = "Shaders/SolidColorShader.fsh";
static const auto kShaderRedUniform = "u_color_red";
static const auto kShaderBlueUniform = "u_color_blue";
static const auto kOpacityThreshold = 50;

const GLchar* const kVertexShader = "attribute vec4 a_position; \n \
				attribute vec2 a_texCoord;				\n \
				attribute vec4 a_color;				\n \
				#ifdef GL_ES					\n \
				varying lowp vec4 v_fragmentColor;		\n \
				varying mediump vec2 v_texCoord;			\n \
				#else				\n \
				varying vec4 v_fragmentColor;				\n \
				varying vec2 v_texCoord;				\n \
				#endif					\n \
				void main()				\n \
				{				\n \
					gl_Position = CC_PMatrix * a_position;		\n \
					v_fragmentColor = a_color;					\n \
					v_texCoord = a_texCoord;					\n \
				}";

const GLchar* const kFragmentShader = "#ifdef GL_ES     \n \
				precision lowp float;				\n \
				#endif				\n \
				varying vec2 v_texCoord;			\n \
				uniform int u_color_red;			\n \
				uniform int u_color_blue;			\n \
				void main()				\n \
				{			\n \
					vec4 color = texture2D(CC_Texture0, v_texCoord);		\n \
					gl_FragColor = vec4(u_color_red, 0, u_color_blue, color.a);		\n \
				}";

PixelCollision* PixelCollision::s_instance = nullptr;

// Private Constructor being called from within the GetInstance handle
PixelCollision::PixelCollision(void) :
	_glProgram(nullptr),
	_rt(nullptr),
	_pixelReader(nullptr) {
	_glProgram = GLProgram::createWithByteArrays(kVertexShader, kFragmentShader);//GLProgram::createWithFilenames(kVertexShader, kFragmentShader);	
	_glProgram->addAttribute(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
	_glProgram->addAttribute(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORD);
	_glProgram->addAttribute(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);

	const Size &size = Director::sharedDirector()->getWinSize();
	_rt = RenderTexture::create(size.width, size.height, kCCTexture2DPixelFormat_RGBA8888);
	_pixelReader = PixelReaderNode::create(Point::ZERO);

	_glProgram->retain();
	_rt->retain();
	_pixelReader->retain();
}

PixelCollision::~PixelCollision(void) {
	_glProgram->release();
	_rt->release();
	_pixelReader->release();
}

PixelCollision* PixelCollision::getInstance(void) {
	if (!s_instance) {
		s_instance = new PixelCollision();
	}
	return s_instance;
}

void PixelCollision::destroyInstance(void) {
	delete s_instance;
	s_instance = nullptr;
}

bool PixelCollision::collidesWithSprite(Sprite *sprite1, Sprite *sprite2) {
	return this->collidesWithSprite(sprite1, sprite2, true);
}

bool PixelCollision::collidesWithSprite(Sprite *sprite1, Sprite *sprite2, bool pp) {
	Rect r1 = sprite1->getBoundingBox();
	Rect r2 = sprite2->getBoundingBox();

	if (r1.intersectsRect(r2)) {
		if (!pp) {
			return true;
		}

		Rect intersection = this->getIntersection(r1, r2);
		unsigned int numPixels = intersection.size.width * intersection.size.height;

		_rt->beginWithClear(0, 0, 0, 0);

		CustomCommand sprite1Command;
		CustomCommand sprite2Command;
		auto oldPosition1 = this->renderSprite(sprite1, sprite1Command, true);
		auto oldPosition2 = this->renderSprite(sprite2, sprite2Command, false);

		_pixelReader->setReadPoint(intersection.origin);
		_pixelReader->setReadSize(intersection.size);
		_pixelReader->reset();
		_pixelReader->visit();

		auto buffer = _pixelReader->getBuffer();
		_rt->end();
		Director::getInstance()->getRenderer()->render();

		this->resetSprite(sprite1, oldPosition1);
		this->resetSprite(sprite2, oldPosition2);

		unsigned int maxIndex = numPixels * 4;
		for (unsigned int i = 0; i < maxIndex; i += 4) {
			if (buffer[i] > 0 && buffer[i + 2] > 0 && buffer[i + 3] > kOpacityThreshold) { // red and blue
				return true;
			}
		}
	}
	return false;
}

bool PixelCollision::collidesWithPoint(Sprite *sprite, const Point &point) {
	_rt->beginWithClear(0, 0, 0, 0);
	glColorMask(1, 0, 0, 1);

	Point oldPosition = sprite->getPosition();
	sprite->setPosition(sprite->getParent()->convertToWorldSpace(oldPosition));
	sprite->visit();

	auto readPoint = sprite->getParent()->convertToWorldSpace(point) * CC_CONTENT_SCALE_FACTOR();
	_pixelReader->setReadPoint(readPoint);
	_pixelReader->setReadSize(Size(1, 1));
	_pixelReader->visit();

	auto color = _pixelReader->getBuffer();
	_rt->end();
	Director::getInstance()->getRenderer()->render();
	glColorMask(1, 1, 1, 1);
	sprite->setPosition(oldPosition);

	return color[0] > 0;
}

// Private methods
PixelCollision::PixelReaderNode *PixelCollision::PixelReaderNode::create(const Point &readPoint) {
	auto pixelReader = new PixelReaderNode(readPoint);
	if (pixelReader && pixelReader->init()) {
		pixelReader->autorelease();
		return pixelReader;
	}
	CC_SAFE_DELETE(pixelReader);
	return nullptr;
}

PixelCollision::PixelReaderNode::PixelReaderNode(const Point &readPoint) :
	_readPoint(readPoint),
	_readSize(Size::ZERO),
	_buffer(nullptr) {
	this->setReadSize(Size(1, 1));
}

PixelCollision::PixelReaderNode::~PixelReaderNode(void) {
	free(_buffer);
}

void PixelCollision::PixelReaderNode::draw(Renderer *renderer, const Mat4& transform, uint32_t flags) {
	_readPixelCommand.init(_globalZOrder);
	_readPixelCommand.func = CC_CALLBACK_0(PixelCollision::PixelReaderNode::onDraw, this);
	renderer->addCommand(&_readPixelCommand);
}

void PixelCollision::PixelReaderNode::onDraw(void) {
	glReadPixels(_readPoint.x, _readPoint.y, _readSize.width, _readSize.height,
		GL_RGBA, GL_UNSIGNED_BYTE, _buffer);
}

Rect PixelCollision::getIntersection(const Rect &r1, const Rect &r2) const {
	float tempX;
	float tempY;
	float tempWidth;
	float tempHeight;

	if (r1.getMaxX() > r2.getMinX()) {
		tempX = r2.getMinX();
		tempWidth = r1.getMaxX() - r2.getMinX();
	}
	else {
		tempX = r1.getMinX();
		tempWidth = r2.getMaxX() - r1.getMinX();
	}
	if (r2.getMaxY() < r1.getMaxY()) {
		tempY = r1.getMinY();
		tempHeight = r2.getMaxY() - r1.getMinY();
	}
	else {
		tempY = r2.getMinY();
		tempHeight = r1.getMaxY() - r2.getMinY();
	}

	return Rect(tempX * CC_CONTENT_SCALE_FACTOR(), tempY * CC_CONTENT_SCALE_FACTOR(),
		tempWidth * CC_CONTENT_SCALE_FACTOR(), tempHeight * CC_CONTENT_SCALE_FACTOR());
}

Point PixelCollision::renderSprite(Sprite *sprite, CustomCommand &command, bool red) {
	command.init(sprite->getGlobalZOrder());
	command.func = [=]() {
		sprite->getGLProgramState()->setUniformInt(kShaderRedUniform, red ? 255 : 0);
		sprite->getGLProgramState()->setUniformInt(kShaderBlueUniform, red ? 0 : 255);
	};
	Director::getInstance()->getRenderer()->addCommand(&command);

	sprite->setGLProgram(_glProgram);
	sprite->setBlendFunc(BlendFunc::ADDITIVE);
	Point oldPosition = sprite->getPosition();
	sprite->setPosition(sprite->getParent()->convertToWorldSpace(oldPosition));
	sprite->visit();

	return oldPosition;
}

void PixelCollision::resetSprite(Sprite *sprite, const Point &oldPosition) {
	auto program = ShaderCache::sharedShaderCache()->programForKey(
		GLProgram::SHADER_NAME_POSITION_TEXTURE_COLOR_NO_MVP);
	sprite->setGLProgram(program);
	sprite->setBlendFunc(BlendFunc::ALPHA_PREMULTIPLIED);
	sprite->setPosition(oldPosition);
}