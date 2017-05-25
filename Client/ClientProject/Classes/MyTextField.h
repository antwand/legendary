#ifndef _MyTextField_H_  
#define _MyTextField_H_  

#include "cocos2d.h"
#include "ui\UITextField.h"

USING_NS_CC;
using namespace ui;

class MyTextField : public Layer, TextFieldDelegate//UICCTextField
{
public:
	MyTextField();
	~MyTextField();

	static MyTextField* create(Node * node, const char *placeholder, const char *fontName, float fontSize);

	std::string getInputText();
	bool init(const char *placeholder, const char *fontName, float fontSize);
	void onEnter(); //initWithPlaceHolder(placeholder, fontName, fontSize)
	void onExit();
	bool onTouchBegan(Touch *pTouch, Event *pEvent);
	void onTouchEnded(Touch *pTouch, Event *pEvent);
	void setTextName(const char* name);
	void setText(const char* str);
	void setTextPosition(float x, float y);
	void setMaxLineWidth(int width);
	void setColor(int red, int green, int blue);
	bool getIsTttachIME();
	virtual bool onTextFieldInsertText(cocos2d::TextFieldTTF*  sender, const char * text, size_t nLen) override;
	virtual bool onTextFieldDeleteBackward(cocos2d::TextFieldTTF*  sender, const char * delText, size_t nLen) override;

private:
	void updatePosition();

	EventListenerTouchOneByOne* listener;
	CCTextFieldTTF* m_pText;
	bool m_isAttachIME;
};

#endif