#ifndef _CursorTextField_H_  
#define _CursorTextField_H_  
  
#include "cocos2d.h"  
  
USING_NS_CC;  
  
class CursorTextField : public TextFieldTTF, public TextFieldDelegate  
{  
private:  
    // 点击开始位置  
    Point m_beginPos;  
    // 光标精灵  
    Sprite * m_pCursorSprite;  
    // 光标动画  
    Action *m_pCursorAction;  
    // 光标坐标  
    Point m_cursorPos;  
    //输入框长度  
    float inputFrameWidth;  
    //允许输入的最大字符数Unicode  
    float inputMaxLength;  
    int m_Sprite_Posi = 0;  
    // 输入框总内容  
    std::string m_pInputText;  
    std::string inpuText; //当前输入框内容  
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
    // 初始化光标精灵  
    void initCursorSprite(int nHeight);  
    virtual void setPositionX(Node *node , float x);  
  
    // TextFieldDelegate  
    virtual bool onTextFieldAttachWithIME(TextFieldTTF *pSender) override;  
    virtual bool onTextFieldDetachWithIME(TextFieldTTF * pSender) override;  
    virtual bool onTextFieldInsertText(cocos2d::TextFieldTTF*  sender, const char * text, size_t nLen) override;  
    virtual bool onTextFieldDeleteBackward(cocos2d::TextFieldTTF*  sender, const char * delText, size_t nLen) override;  
  
  
  
    virtual void setPosition(const Point& pos);  
    virtual void setPosition(float &x, float &y);  
  
    void setCursorPositionX(float x); // 设置光标x位置  
    // 把光标添加到和输入框一起的层中  
    void AddCursor(Node *node);  
    // Layer Touch  
    bool onTouchBegan(Touch *pTouch, Event *pEvent);  
    void onTouchEnded(Touch *pTouch, Event *pEvent);  
    void onKeyPressed(cocos2d::EventKeyboard::KeyCode, cocos2d::Event*);  
    void onKeyReleased(cocos2d::EventKeyboard::KeyCode, cocos2d::Event*);  
  
    // 判断是否点击在TextField处  
    bool isInTextField(Touch *pTouch);  
    // 得到TextField矩形  
    Rect getRect();  
  
    // 打开输入法  
    void openIME();  
    // 关闭输入法  
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