#ifndef _CursorTextField_H_  
#define _CursorTextField_H_  
  
#include "cocos2d.h"  
  
USING_NS_CC;  
  
class CursorTextField : public TextFieldTTF, public TextFieldDelegate  
{  
private:  
    // �����ʼλ��  
    Point m_beginPos;  
    // ��꾫��  
    Sprite * m_pCursorSprite;  
    // ��궯��  
    Action *m_pCursorAction;  
    // �������  
    Point m_cursorPos;  
    //����򳤶�  
    float inputFrameWidth;  
    //�������������ַ���Unicode  
    float inputMaxLength;  
    int m_Sprite_Posi = 0;  
    // �����������  
    std::string m_pInputText;  
    std::string inpuText; //��ǰ���������  
    int fontsize = 0;  
    std::string fontName;  
    int nowtextlenght = 0;  
    void setTextPosi(std::string , bool is_add = true);  
public:  
    CursorTextField();  
    ~CursorTextField();  
    static CursorTextField * getinstance();  
    // static  
    static CursorTextField * textFieldWithPlaceHolder(cocos2d::Node * node , const char *placeholder, const char *fontName, float fontSize);  
    // Layer  
    void onEnter();  
    void onExit();  
    bool init();  
    // ��ʼ����꾫��  
    void initCursorSprite(int nHeight);  
    virtual void setPositionX(Node *node , float x);  
  
    // TextFieldDelegate  
    virtual bool onTextFieldAttachWithIME(TextFieldTTF *pSender) override;  
    virtual bool onTextFieldDetachWithIME(TextFieldTTF * pSender) override;  
    virtual bool onTextFieldInsertText(cocos2d::TextFieldTTF*  sender, const char * text, size_t nLen) override;  
    virtual bool onTextFieldDeleteBackward(cocos2d::TextFieldTTF*  sender, const char * delText, size_t nLen) override;  
  
  
  
    virtual void setPosition(const Point& pos);  
    virtual void setPosition(float &x, float &y);  
  
    void setCursorPositionX(float x); // ���ù��xλ��  
    // �ѹ����ӵ��������һ��Ĳ���  
    void AddCursor(Node *node);  
    // Layer Touch  
    bool onTouchBegan(Touch *pTouch, Event *pEvent);  
    void onTouchEnded(Touch *pTouch, Event *pEvent);  
    void onKeyPressed(cocos2d::EventKeyboard::KeyCode, cocos2d::Event*);  
    void onKeyReleased(cocos2d::EventKeyboard::KeyCode, cocos2d::Event*);  
  
    // �ж��Ƿ�����TextField��  
    bool isInTextField(Touch *pTouch);  
    // �õ�TextField����  
    Rect getRect();  
  
    // �����뷨  
    void openIME();  
    // �ر����뷨  
    void closeIME();  
  
    std::string split_text(std::string name, int len , int start);  
  
    const char* getInputText();  
    void setInpuntText(char* text);  
    void setInputWidth(float width);  
    void setInputMaxLength(float length);  
	void setChildName(const char* name);
  
    cocos2d::Node * parentNode;  
  
  
    void BlickSpriteLeft();  
  
    void BlickSpriteRight();  
    void KeyDelete();  
    float getLabelWidth(std::string str , std::string fontName, float fontsize);  
    int getPosifromText(std::string str, int posi);  
    int getPosiformPosi(std::string str, float posi);  
  
    void MyRemoveFromParent();  
protected:  
    EventListenerTouchOneByOne * listener;  
};  

#endif