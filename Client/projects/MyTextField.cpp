#include "MyTextField.h"

MyTextField::MyTextField()
{

}

MyTextField::~MyTextField()
{

}

//New textfield ui
MyTextField* MyTextField::create(Node * node, const char *placeholder, const char *fontName, float fontSize)
{
	auto text = new MyTextField();
	if (text && text->init(placeholder, fontName, fontSize))
	{
		//text->setAlignment(TextHAlignment::LEFT, TextVAlignment::TOP);
		text->setColor(Color3B(100, 100, 100));
		text->setContentSize(Size(402.0000, 17.0000));
		node->addChild(text);
		return text;
	}

	return 0;
}

void MyTextField::setTextName(const char* name)
{
	this->setName(name);
}

void MyTextField::setText(const char* str)
{
	m_pText->setString(str);
}

void MyTextField::setTextPosition(float x, float y)
{
	this->setPosition(x, y);
}

bool MyTextField::init(const char *placeholder, const char *fontName, float fontSize)
{
	m_pText = new CCTextFieldTTF();
	m_pText->initWithPlaceHolder(placeholder, fontName, fontSize);
	m_pText->setHorizontalAlignment(TextHAlignment::LEFT);
	m_pText->setAnchorPoint(Vec2(0,0));
	this->addChild(m_pText);

	return true;
}

void MyTextField::onEnter()
{
	/*
	Layer::onEnter();
	listener = EventListenerTouchOneByOne::create();
	listener->setSwallowTouches(true);
	listener->onTouchBegan = CC_CALLBACK_2(MyTextField::onTouchBegan, this);
	listener->onTouchEnded = CC_CALLBACK_2(MyTextField::onTouchEnded, this);
	Director::getInstance()->getEventDispatcher()->addEventListenerWithSceneGraphPriority(listener, this);
	//KeyInsert::getinstence()->addKeyBordClick(this);
	m_pText->setDelegate(this);*/
}

void MyTextField::onExit()
{
	//TextFieldTTF::onExit();
	//Layer::onExit();
	//Director::getInstance()->getEventDispatcher()->removeEventListener(listener);
	//KeyInsert::getinstence()->destoryinstence();
}

bool MyTextField::onTouchBegan(cocos2d::Touch *pTouch, cocos2d::Event *pEvent)
{
	//m_beginPos = pTouch->getLocation();
	return true;
}

void MyTextField::onTouchEnded(Touch *pTouch, Event *pEvent)
{
	//CCPoint pos = pTouch->getLocation();
	Vec2 pos = this->convertTouchToNodeSpace(pTouch);

	float x = m_pText->getPositionX() - m_pText->getContentSize().width / 2;
	float y = m_pText->getPositionY() - m_pText->getContentSize().height / 2;
	float width = m_pText->getContentSize().width;
	float height = m_pText->getContentSize().height;
	CCRect rect = CCRectMake(x, y, width, height);

	//ÅÐ¶Ï´¥µãÊÇ·ñ´¥Ãþµ½±à¼­¿òÄÚ²¿
	if (rect.containsPoint(pos)) {
		CCLOG("attachWithIME");
		m_pText->attachWithIME(); //¿ªÆôÐéÄâ¼üÅÌ
	}
	else {
		CCLOG("detachWithIME");
		m_pText->detachWithIME(); //¹Ø±ÕÐéÄâ¼üÅÌ
	}
}


bool MyTextField::onTextFieldInsertText(cocos2d::TextFieldTTF* sender, const char * text, size_t nLen)
{
	bool ret = CCTextFieldDelegate::onTextFieldInsertText(sender, text, nLen);

	return ret;
}

bool MyTextField::onTextFieldDeleteBackward(cocos2d::TextFieldTTF* sender, const char * delText, size_t nLen)
{
	bool ret = CCTextFieldDelegate::onTextFieldDeleteBackward(sender, delText, nLen);

	updatePosition();

	return ret;
}

void MyTextField::updatePosition()
{
	Size size = m_pText->getContentSize();
}
