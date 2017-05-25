#include "CursorTextField.h"  
  
#include "MyCharSet.h"  
#include "MyKeyInsert.h"  
  
const static float DELTA = 0.5f;  
  
using namespace cocos2d;  
using namespace std;  
static CursorTextField * _CursorTextField;  
CursorTextField::CursorTextField()  
{  
    TextFieldTTF();  
  
    m_pCursorSprite = NULL;  
    m_Sprite_Posi = 0;  
}  
  
CursorTextField::~CursorTextField()  
{  
}  
  
CursorTextField * CursorTextField::getinstance()  
{  
    return _CursorTextField;  
}  
  
void CursorTextField::onEnter()  
{  
    TextFieldTTF::onEnter();  
    listener = EventListenerTouchOneByOne::create();  
    //listener->setSwallowTouches(true);  
    listener->onTouchBegan = CC_CALLBACK_2(CursorTextField::onTouchBegan, this);  
    listener->onTouchEnded = CC_CALLBACK_2(CursorTextField::onTouchEnded, this);  
    Director::getInstance()->getEventDispatcher()->addEventListenerWithSceneGraphPriority(listener, this);  
    KeyInsert::getinstence()->addKeyBordClick(this);  
    this->setDelegate(this);  
}  
  
CursorTextField * CursorTextField::textFieldWithPlaceHolder(Node * node , const char *placeholder, const char *fontName, float fontSize)  
{  
    _CursorTextField = new (std::nothrow)CursorTextField();  
	node->addChild(_CursorTextField);
    _CursorTextField->parentNode = node;  
    if (_CursorTextField && ((TextFieldTTF*)_CursorTextField)->initWithPlaceHolder(placeholder, fontName, fontSize))  
    {  
        _CursorTextField->fontsize = fontSize;  
        _CursorTextField->fontName = fontName;  
        _CursorTextField->autorelease();  
        if (placeholder)  
        {  
            _CursorTextField->setPlaceHolder(placeholder);  
        }  
        _CursorTextField->init();  
        _CursorTextField->initCursorSprite(fontSize);  
        _CursorTextField->setHorizontalAlignment(kCCTextAlignmentLeft);
		_CursorTextField->setAnchorPoint(Vec2(0, 0));
        return _CursorTextField;  
    }  
    CC_SAFE_DELETE(_CursorTextField);  
    return NULL;  
}  
  
bool CursorTextField::init(){  
    this->inputFrameWidth = 400;  
    this->inputMaxLength = 16;  
    inpuText = "";  
    return true;  
}  
void CursorTextField::initCursorSprite(const int mHeight)  
{  
    int column = 1;  
    int nHeight = 20;  
    int pixels[50][2];  
    for (int i = 0; i < nHeight; ++i)  
    {  
        for (int j = 0; j < column; ++j)  
        {  
            pixels[i][j] = 0xffffffff;  
        }  
    }  
    Texture2D* texture = new Texture2D();  
    texture->initWithData(pixels, 20, Texture2D::PixelFormat::RGB888, 4, mHeight, CCSizeMake(column, nHeight));  
    m_pCursorSprite = Sprite::createWithTexture(texture);  
    texture->autorelease();  
    if (m_pCursorSprite == nullptr)  
    {  
        CCLOG("NULL");  
    }  
    //m_pCursorSprite->setColor(Color3B(255, 0, 0));  
    Size winSize = getContentSize();  
    m_pCursorSprite->setVisible(false);  
    parentNode->addChild(m_pCursorSprite);  
    m_pCursorAction = RepeatForever::create(Sequence::create(FadeOut::create(0.25f), FadeIn::create(0.25f), NULL));  
    m_pCursorSprite->runAction(m_pCursorAction);  
    //m_pInputText = new std::string();  
}  
  
void CursorTextField::setPositionX(Node * node, float x)  
{  
    int i = 0;  
    int count = 0;  
    float width = 0.0;  
    std::string str;  
    if (m_Sprite_Posi <= 0)  
    {  
        width = 0.0;  
        m_Sprite_Posi = 0;  
    }  
    else  
    {  
        std::string ss;  
        for (i = 0; i < inpuText.size();)  
        {  
            ss = split_text(inpuText, 1, i);  
            i += ss.length();  
            str.append(ss);  
            count++;  
            if (count == m_Sprite_Posi)  
            {  
                break;  
            }  
        }  
        width = getLabelWidth(str, _CursorTextField->fontName, _CursorTextField->fontsize);  
    }  
    width += x;  
    node->setPositionX(width);  
}  
  
void CursorTextField::setPosition(float &x, float &y)  
{  
    Point posi(x, y);  
    setPosition(posi);  
}  
  
void CursorTextField::setPosition(const Point& pos)  
{  
    TextFieldTTF::setPosition(pos);  
    // ���ù��λ��  
    if (NULL != m_pCursorSprite)  
    {  
        Size winSize = getContentSize();  
        m_cursorPos = ccp(0, 0/*winSize.height / 2*/);  
        m_cursorPos = m_cursorPos + pos;  
        m_pCursorSprite->setPosition(m_cursorPos.x + m_pCursorSprite->getContentSize().width , m_cursorPos.y + m_pCursorSprite->getContentSize().height / 2.0);  
    }  
}  
  
void CursorTextField::setCursorPositionX(float x) // ���ù��xλ��  
{  
    Point pt = getPosition(); // ��ȡ�����λ��  
    x += pt.x;  
    setPositionX(m_pCursorSprite , x);  
}  
// �ѹ����ӵ��������һ��Ĳ���  
void CursorTextField::AddCursor(Node *node)  
{  
    if (NULL != node && NULL != m_pCursorSprite)  
    {  
        node->addChild(m_pCursorSprite);  
        m_pCursorSprite->setPositionY(getContentSize().height / 2.0);  
        m_pCursorSprite->runAction(m_pCursorAction);  
    }  
}  
  
bool CursorTextField::onTouchBegan(cocos2d::Touch *pTouch, cocos2d::Event *pEvent)  
{  
    m_beginPos = pTouch->getLocation();  
    return true;  
}  
  
Rect CursorTextField::getRect()  
{  
    Size check;  
    check.width = fontsize;  
    Size size = getContentSize() + check;  
    return  CCRectMake(0, 0, inputFrameWidth, size.height);//CCRectMake(0, -size.height / 2, inputFrameWidth, size.height);  
}  
  
//��ȡ���������  
const char* CursorTextField::getInputText(){  
    const char* text = m_pInputText.c_str();  
    return text;  
}  
  
//�������������  
void CursorTextField::setInpuntText(char* text){  
    m_pInputText = "";  
    setString(text);  
    setPositionX(m_pCursorSprite, this->getPosition().x);  
    inpuText = "";  
}  
  
//����������� һ���ַ�����ȳ���������� �ַ������Զ���������  
void CursorTextField::setInputWidth(float width){  
    this->inputFrameWidth = width;  
}  
  
//�����������ʾ������ַ�����Unicode  
void CursorTextField::setInputMaxLength(float length){  
    this->inputMaxLength = length;  
}  

void CursorTextField::setChildName(const char* name)
{
	this->setName(name);
}
  
//�жϵ���¼����Ƿ���Ӧ�������Χ��  
bool CursorTextField::isInTextField(cocos2d::Touch *pTouch)  
{  
    return getRect().containsPoint(convertTouchToNodeSpaceAR(pTouch));  
}  
  
void CursorTextField::onTouchEnded(cocos2d::Touch *pTouch, cocos2d::Event *pEvent)  
{  
    Point endPos = pTouch->getLocation();  
    // �ж��Ƿ�Ϊ����¼�  
    if (::abs(endPos.x - m_beginPos.x) > DELTA ||  
        ::abs(endPos.y - m_beginPos.y))  
    {  
        // ���ǵ���¼�  
        m_beginPos.x = m_beginPos.y = -1;  
        return;  
    }  
    // �ж��Ǵ����뷨���ǹر����뷨  
    isInTextField(pTouch) ? openIME() : closeIME();  
    if (m_pCursorSprite->isVisible())  
    {  
        //��ʼ�����ֽ�  
        int len = getPosiformPosi(inpuText, m_pCursorSprite->getPositionX());  
        //�������ڵ��ֽ�  
        int endlen = getPosiformPosi(inpuText, endPos.x);  
        m_pCursorSprite->setPositionX(this->getPositionX() + getLabelWidth(inpuText.substr(0, endlen), fontName, fontsize));  
  
        int i = 0;  
        int count = 0;  
        //����ǰ��,mposi��ȥ�ַ�  
        if (len > endlen)  
        {  
            count = 0;  
            for (i = endlen; i < len;)  
            {  
                std::string temp = split_text(inpuText, 1, i);  
                count++;  
                i += temp.length();  
            }  
            m_Sprite_Posi -= count;  
        }  
        //ԭ��λ��  
        else if (len == endlen)  
        {  
        }  
        //���˺���,mposi�����ַ�  
        else  
        {  
            count = 0;  
            for (i = len; i < endlen;)  
            {  
                std::string temp = split_text(inpuText, 1, i);  
                count++;  
                i += temp.length();  
            }  
            m_Sprite_Posi += count;  
        }  
    }  
}  
  
  
//�����ֻ�����ʱ��Ӧ�¼�  
bool CursorTextField::onTextFieldAttachWithIME(cocos2d::TextFieldTTF *pSender)  
{  
    if (m_pInputText.empty()) {  
        return false;  
    }  
    //setPositionX(m_pCursorSprite , this->getPosition().x);  
    return false;  
}  
  
//�����������ʱ��Ӧ  
//@param pSender �����¼�����  
//@param text ��������  
//@param  �����ֽڳ���  
  
  
bool CursorTextField::onTextFieldInsertText(cocos2d::TextFieldTTF* sender, const char * text, size_t nLen)  
{  
    //log("OUT   ====   %s =Length= %d", text , nLen);  
    int j = 0 ;  
    std::string mytext = text;  
    for (j = 0; j < mytext.size();)  
    {  
        std::string sText = m_pInputText.c_str();  
        wchar_t* wText = new wchar_t[200];  
        char t[200];  
        memset(t, 0, sizeof(t));  
        strcpy(t, sText.c_str());  
        int unisize = 0;  
        int codenum = MyCharSet::getinstence()->utf8_to_unicode((uint8_t*)t, (uint16_t **)wText, &unisize);  
        //���ַ����������涨ֵ ��������  
        if (codenum >= inputMaxLength && inputMaxLength != 0)  
        {  
            codenum = inputMaxLength;  
            CC_SAFE_DELETE_ARRAY(wText);  
            return true;  
        }  
        nowtextlenght++;  
        std::string ss = split_text(mytext, 1, j);  
        j += ss.length();  
        //���λس�����  
        if (ss == "\n")  
        {  
            CC_SAFE_DELETE_ARRAY(wText);  
            continue;  
        }  
        std::string mmss = "";  
        std::string mystr;  
        int i = 0;  
        //�����ַ�λ�ò���  
        if (m_Sprite_Posi != 0)  
        {  
              
            int count = 0;  
            for (i = 0; i < m_pInputText.size();)  
            {  
                mmss = split_text(m_pInputText, 1, i);  
                i += mmss.length();  
                mystr.append(mmss);  
                count++;  
                if (count == m_Sprite_Posi)  
                {  
                    break;  
                }  
            }  
        }  
        //�ַ�λ�����  
        m_Sprite_Posi++;  
        mystr.append(ss);  
        mystr.append(m_pInputText.substr(i));  
        //����������ݾ����������  
        m_pInputText.clear();  
        //inpuText.clear();  
        m_pInputText.append(mystr);  
        //inpuText.append(mystr);  
        //�����ǰ�ַ������  
        //inpuText.append(ss);  
        setTextPosi(ss, true);  
        CC_SAFE_DELETE_ARRAY(wText);  
        //AndroidShowtext(mychar, 1);  
    }  
    return true;  
}  
  
  
//�����������ʱ��Ӧ  
//@param pSender �����¼�����  
//@param text ɾ������  
//@param  �����ֽڳ���  
  
bool CursorTextField::onTextFieldDeleteBackward(cocos2d::TextFieldTTF* sender, const char * delText, size_t nLen)  
{  
    std::string ss;  
    if (m_Sprite_Posi != 0)  
    {  
        int i = 0;  
        int count = 0;  
        for (i = 0; i < m_pInputText.size();)  
        {  
            ss = split_text(m_pInputText, 1, i);  
            i += ss.length();  
            count++;  
            if (count == m_Sprite_Posi)  
            {  
                m_pInputText.erase(i - ss.length(), ss.length());  
                //inpuText.erase(i - ss.length(), ss.length());  
                break;  
            }  
        }  
    }  
    //�ַ�λ�ü�1  
    m_Sprite_Posi--;  
    //m_pInputText.resize(m_pInputText.size() - nLen);  
    if (m_pInputText.size() <= 0)  
    {  
        m_Sprite_Posi = 0;  
    }  
    if (m_Sprite_Posi < 0)  
    {  
        m_Sprite_Posi = 0;  
    }  
    setTextPosi(ss , false);  
      
    return true;  
}  
  
void CursorTextField::setTextPosi(std::string ss , bool is_add)  
{  
    if (inputFrameWidth <= 0)  
    {  
        inputFrameWidth = _CursorTextField->inputFrameWidth;  
    }  
    if (!is_add)  
    {  
        if (m_pInputText.empty())  
        {  
            m_Sprite_Posi = 0;  
            m_pCursorSprite->setPositionX(m_pCursorSprite->getPositionX() - getLabelWidth(ss, fontName, fontsize));  
            setString("");  
            inpuText.clear();  
            return;  
        }  
        std::string localText = inpuText;  
        int i = getPosifromText(m_pInputText, m_Sprite_Posi);  
        int inlength = getPosiformPosi(inpuText, m_pCursorSprite->getPositionX());     
        if (inlength == 0)  
        {  
            return;  
        }  
        std::string mystr;  
        std::string instr;  
        if (i >= inlength)  
        {  
            int reposi = i - inlength;  
            for (i = 0; i < m_pInputText.length();)  
            {  
                std::string temp = split_text(m_pInputText, 1, i);  
                if (i <= reposi && reposi < temp.length() + i)  
                {  
                    break;  
                }  
                else  
                {  
                    i += temp.length();  
                }  
            }  
            mystr = m_pInputText.substr(i, 1);  
            if (!mystr.empty())  
            {  
                if (mystr[0] < 0)  
                {  
                    mystr = m_pInputText.substr(i, 3);  
                }  
                else  
                {  
                    mystr = m_pInputText.substr(i, 1);  
                }  
            }  
        }  
          
        //��ǰ������޳�  
        std::string deletestr;  
        if (inlength - 3 >= 0)  
        {  
            int reposi = inlength;  
            for (i = 0; i < inpuText.length();)  
            {  
                std::string temp = split_text(inpuText, 1, i);  
                if (i <= reposi && reposi <= temp.length() + i)  
                {  
                    break;  
                }  
                else  
                {  
                    i += temp.length();  
                }  
            }  
            deletestr = inpuText.substr(i, 3);  
            if (deletestr[0] < 0)  
            {  
                inpuText.erase(inlength - 3, 3);  
            }  
            else if (!deletestr.empty())  
            {  
                deletestr = inpuText.substr(inlength - 1, 1);  
                inpuText.erase(inlength - 1, 1);  
            }  
            //log("%s   %s", inpuText.c_str(), deletestr.c_str());  
        }  
        else  
        {  
            deletestr = inpuText.substr(0, 3);  
            if (deletestr[0] < 0)  
            {  
                inpuText.erase(inlength - 3, 3);  
            }  
            else if (!deletestr.empty())  
            {  
                deletestr = inpuText.substr(inlength - 1, 1);  
                inpuText.erase(inlength - 1, 1);  
            }  
        }  
        if (mystr.empty())  
        {  
            instr = m_pInputText.substr(inpuText.length() , 1);  
            if (!instr.empty())  
            {  
                if (instr[0] < 0)  
                {  
                    instr = m_pInputText.substr(inpuText.length(), 3);  
                }  
                else  
                {  
                    //instr.erase(1, 2);  
                    instr = m_pInputText.substr(inpuText.length(), 1);  
                }  
            }  
            inpuText.append(instr);  
        }  
        std::string lastins = mystr;  
        mystr.append(inpuText);  
        inpuText = mystr;  
        if (lastins.empty())  
        {  
            m_pCursorSprite->setPositionX(m_pCursorSprite->getPositionX() - getLabelWidth(deletestr, fontName, fontsize));  
        }  
        else if (!instr.empty())  
        {  
            float reposi = getLabelWidth(deletestr, fontName, fontsize) - getLabelWidth(instr, fontName, fontsize);  
            m_pCursorSprite->setPositionX(m_pCursorSprite->getPositionX() + reposi);  
        }  
        else if (!lastins.empty())  
        {  
            float reposi = getLabelWidth(lastins, fontName, fontsize) - getLabelWidth(deletestr, fontName, fontsize);  
            m_pCursorSprite->setPositionX(m_pCursorSprite->getPositionX() + reposi);  
        }  
        setString(inpuText);  
    }  
    else  
    {  
        std::string localText = m_pInputText;  
        setString(m_pInputText);  
        //������ַ����ĳ��ȴ���ָ�����  
        if (getLabelWidth(m_pInputText , fontName , fontsize) > inputFrameWidth){  
            int inlength = getPosiformPosi(inpuText, m_pCursorSprite->getPositionX());  
            //�����0��,��Ҫ��ȡ����ǰ��������һ���ַ�,  
            if (inlength == 0)  
            {  
                std::string mystr = ss;  
                mystr.append(inpuText);  
                inpuText = mystr;  
                std::string str = inpuText.substr(inpuText.length() - 1);  
                if (str[0] < 0)  
                {  
                    inpuText.resize(inpuText.length() - 3);  
                }  
                else  
                {  
                    inpuText.resize(inpuText.length() - 1);  
                }  
                setString(inpuText);  
                m_pCursorSprite->setPositionX(m_pCursorSprite->getPositionX() + getLabelWidth(ss, fontName, fontsize));  
                return;  
            }  
            //�����ĩβ,��Ҫ��ȡ��һ���ַ�  
            else if (inlength == inpuText.length())  
            {  
                inpuText.append(ss);  
                std::string str = inpuText.substr(0, 3);  
                if (str[0] < 0)  
                {  
                    inpuText.erase(0, 3);  
                }  
                else  
                {  
                    str.erase(1, 2);  
                    inpuText.erase(0, 1);  
                }  
                setString(inpuText);  
                float x = getLabelWidth(str, fontName, fontsize) - getLabelWidth(ss, fontName, fontsize);  
                m_pCursorSprite->setPositionX(m_pCursorSprite->getPositionX() - x);  
                return;  
            }  
            //���ַ������и�  
            std::string last = inpuText.substr(0 , inlength);  
            std::string next = inpuText.substr(inlength);  
            //�ַ�����  
            inpuText = last;  
            inpuText.append(ss);  
            inpuText.append(next);  
            std::string temp = inpuText.substr(0, 3);  
            if (temp[0] < 0 )  
            {  
                inpuText.erase(0, 3);  
            }  
            else  
            {  
                inpuText.erase(0, 1);  
                temp = inpuText.substr(0, 1);  
            }  
            float reposi = getLabelWidth(ss, fontName, fontsize) - getLabelWidth(temp, fontName, fontsize);  
            m_pCursorSprite->setPositionX(m_pCursorSprite->getPositionX() + reposi);  
            setString(inpuText);  
  
        }  
        else{  
            //С�ڣ�ֱ��������ʾ���ַ���  
            int startCur = 0;  
            setString(m_pInputText);  
            inpuText = m_pInputText;  
            std::string showinput;  
            for (int j = 0; j < m_pInputText.size();)  
            {  
                std::string nowstr = split_text(m_pInputText , 1 ,j);  
                showinput.append(nowstr);  
                j += nowstr.length();  
                startCur++;  
                if (startCur == m_Sprite_Posi)  
                {  
                    break;  
                }  
            }  
            startCur = 0;  
            m_pCursorSprite->setPositionX(this->getPosition().x + getLabelWidth(showinput, fontName, fontsize));  
        }  
        //���ù��λ��  
        //setPositionX(m_pCursorSprite, this->getPosition().x);  
    }  
}  
  
bool CursorTextField::onTextFieldDetachWithIME(cocos2d::TextFieldTTF *pSender)  
{  
    return false;  
}  
  
void CursorTextField::openIME()  
{  
    m_pCursorSprite->setVisible(true);  
#if ( CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)  
    setString(m_pInputText);  
#endif  
    ((TextFieldTTF *)this)->attachWithIME();  
}  
  
void CursorTextField::closeIME()  
{  
    m_pCursorSprite->setVisible(false);  
    //auto pTextField = (TextFieldTTF *)pRet;  
    ((TextFieldTTF *)this)->detachWithIME();  
}  
  
void CursorTextField::onExit()  
{  
    TextFieldTTF::onExit();  
    Director::getInstance()->getEventDispatcher()->removeEventListener(listener);  
    KeyInsert::getinstence()->destoryinstence();  
}  
//����λ�÷ָ��ַ����������ַ�  
std::string CursorTextField::split_text(std::string name, int len , int start)  
{  
    int i = start;  
    std::string str;  
    if (name[i] < 0)  
    {  
        i++;  
    }  
    if (start == i)  
    {  
        str = name.substr(start, 1);  
    }  
    else  
    {  
        str = name.substr(start, 3);  
    }  
    //log("mysubstr   %s", str.c_str());  
    return str;  
}  
//������  
void CursorTextField::BlickSpriteLeft()  
{  
    if (!_CursorTextField->m_pCursorSprite->isVisible())  
    {  
        return;  
    }  
    float posix = _CursorTextField->m_pCursorSprite->getPosition().x;  
    float contextsizeposi = _CursorTextField->m_pCursorSprite->getContentSize().width / 2;  
    float parentposi = _CursorTextField->getPosition().x;  
    std::string str;  
    //�����������������  
    if (posix - parentposi <= contextsizeposi)  
    {  
        if (_CursorTextField->m_pInputText == _CursorTextField->inpuText || _CursorTextField->m_Sprite_Posi == 0)  
        {  
            return;  
        }  
        int mlength = _CursorTextField->getPosifromText(_CursorTextField->m_pInputText, _CursorTextField->m_Sprite_Posi);  
        //����������ַ��������  
        if (mlength <= 0)  
        {  
            return;  
        }  
        //ѡȡ���ǰһ���ַ�  
        str = _CursorTextField->m_pInputText.substr(mlength - 1, 1);  
        if (str[0] < 0)  
        {  
            str = _CursorTextField->m_pInputText.substr(mlength - 3, 3);  
        }  
        std::string mystr = _CursorTextField->inpuText.substr(_CursorTextField->inpuText.length() - 1, 1);  
        //�޳����һ���ַ�  
        if (mystr[0] < 0)  
        {  
            _CursorTextField->inpuText.resize(_CursorTextField->inpuText.length() - 3);  
        }  
        else  
        {  
            _CursorTextField->inpuText.resize(_CursorTextField->inpuText.length() - 1);  
        }  
        //�ַ����  
        str.append(_CursorTextField->inpuText);  
        _CursorTextField->inpuText = str;  
        _CursorTextField->setString(_CursorTextField->inpuText);  
    }  
    else  
    {  
        //ֻ���ƶ�  
        int nlength = _CursorTextField->getPosiformPosi(_CursorTextField->inpuText, _CursorTextField->m_pCursorSprite->getPositionX());  
        str = _CursorTextField->inpuText.substr(nlength - 1, 1);  
        if (str[0] < 0)  
        {  
            str = _CursorTextField->inpuText.substr(nlength - 3, 3);  
        }  
        float nowposi = _CursorTextField->getLabelWidth(str, _CursorTextField->fontName, _CursorTextField->fontsize);  
        _CursorTextField->m_pCursorSprite->setPositionX(_CursorTextField->m_pCursorSprite->getPositionX() - nowposi);  
  
    }  
    //������������ַ��м�һ  
    _CursorTextField->m_Sprite_Posi--;  
    if (_CursorTextField->m_Sprite_Posi < 0)  
    {  
        _CursorTextField->m_Sprite_Posi = 0;  
    }  
      
}  
//������������  
void CursorTextField::BlickSpriteRight()  
{  
    if (!_CursorTextField->m_pCursorSprite->isVisible())  
    {  
        return;  
    }  
    float posix = _CursorTextField->m_pCursorSprite->getPosition().x;  
    float contextsizeposi = _CursorTextField->m_pCursorSprite->getContentSize().width / 2;  
    float parentposi = _CursorTextField->getPosition().x + _CursorTextField->getLabelWidth(_CursorTextField->inpuText , _CursorTextField->fontName , _CursorTextField->fontsize);  
    std::string str;  
    if (posix + contextsizeposi >= parentposi)  
    {  
        if (_CursorTextField->m_pInputText == _CursorTextField->inpuText || _CursorTextField->m_Sprite_Posi >= _CursorTextField->nowtextlenght)  
        {  
            return;  
        }  
        int mlength = _CursorTextField->getPosifromText(_CursorTextField->m_pInputText, _CursorTextField->m_Sprite_Posi);  
        if (mlength == _CursorTextField->m_pInputText.length())  
        {  
            return;  
        }  
        str = _CursorTextField->m_pInputText.substr(mlength, 1);  
        if (str[0] < 0)  
        {  
            str = _CursorTextField->m_pInputText.substr(mlength, 3);  
        }  
        std::string mystr = _CursorTextField->inpuText.substr(0, 1);  
        if (mystr[0] < 0)  
        {  
            mystr = _CursorTextField->inpuText.substr(0, 3);  
            _CursorTextField->inpuText.erase(0, 3);  
        }  
        else  
        {  
            _CursorTextField->inpuText.erase(0, 1);  
        }  
        _CursorTextField->inpuText.append(str);  
        //λ�Ʋ�  
        float posix = getLabelWidth(str, _CursorTextField->fontName, _CursorTextField->fontsize) - getLabelWidth(mystr , _CursorTextField->fontName ,_CursorTextField->fontsize);  
        _CursorTextField->m_pCursorSprite->setPositionX(_CursorTextField->m_pCursorSprite->getPositionX() + posix);  
        _CursorTextField->setString(_CursorTextField->inpuText);  
    }  
    else  
    {  
        int nlength = _CursorTextField->getPosiformPosi(_CursorTextField->inpuText, _CursorTextField->m_pCursorSprite->getPositionX());  
        str = _CursorTextField->inpuText.substr(nlength, 1);  
        if (str[0] < 0)  
        {  
            str = _CursorTextField->inpuText.substr(nlength, 3);  
        }  
        float nowposi = _CursorTextField->getLabelWidth(str, _CursorTextField->fontName, _CursorTextField->fontsize);  
        _CursorTextField->m_pCursorSprite->setPositionX(_CursorTextField->m_pCursorSprite->getPositionX() + nowposi);  
  
    }  
    _CursorTextField->m_Sprite_Posi++;  
  
  
}  
  
void CursorTextField::KeyDelete()  
{  
    if (!_CursorTextField->m_pCursorSprite->isVisible())  
    {  
        return;  
    }  
    int nlength = _CursorTextField->getPosiformPosi(_CursorTextField->inpuText, _CursorTextField->m_pCursorSprite->getPositionX());  
    int mlength = _CursorTextField->getPosifromText(_CursorTextField->m_pInputText, _CursorTextField->m_Sprite_Posi);  
    std::string inlast;  
    std::string innext;  
    std::string insMNext;  
    std::string insMLast;  
    if (mlength == _CursorTextField->m_pInputText.length())  
    {  
        return;  
    }  
    std::string in_str = _CursorTextField->inpuText.substr(nlength, 3);  
    std::string im_str = _CursorTextField->m_pInputText.substr(mlength, 3);  
    if (in_str[0] < 0)  
    {  
        _CursorTextField->inpuText.erase(nlength, 3);  
    }  
    else  
    {  
        _CursorTextField->inpuText.erase(nlength, 1);  
    }  
    if (im_str[0] < 0)  
    {  
        _CursorTextField->m_pInputText.erase(mlength, 3);  
    }  
    else  
    {  
        _CursorTextField->m_pInputText.erase(mlength, 1);  
    }  
    insMNext = _CursorTextField->m_pInputText.substr(mlength + _CursorTextField->inpuText.length() - nlength, 1);  
    if (insMNext[0] >= 0)  
    {  
        insMNext = _CursorTextField->m_pInputText.substr(mlength + _CursorTextField->inpuText.length() - nlength, 1);  
    }  
    else  
    {  
        insMNext = _CursorTextField->m_pInputText.substr(mlength + _CursorTextField->inpuText.length() - nlength, 3);  
    }  
    if (insMNext.empty() && mlength != nlength)  
    {  
        if (mlength - nlength - 3 < 0)  
        {  
            insMLast = _CursorTextField->m_pInputText.substr(mlength - nlength - 1, 1);  
        }  
        else  
        {  
            int lenposi = mlength - nlength;  
            int i;  
            for (i = 0; i < _CursorTextField->m_pInputText.length();)  
            {  
                std::string temp = _CursorTextField->split_text(_CursorTextField->m_pInputText, 1, i);  
                if (i <= lenposi && lenposi < i + temp.length())  
                {  
                    break;  
                }  
                i += temp.length();  
            }  
            lenposi = i;  
            insMLast = _CursorTextField->m_pInputText.substr(lenposi - 3, 3);  
            if (insMLast[2] >= 0)  
            {  
                insMLast = _CursorTextField->m_pInputText.substr(lenposi - 1, 1);  
            }  
        }  
    }  
    std::string myallstr;  
    myallstr.append(insMLast);  
    myallstr.append(_CursorTextField->inpuText);  
    myallstr.append(insMNext);  
    _CursorTextField->inpuText = myallstr;  
    _CursorTextField->setString(_CursorTextField->inpuText);  
    if (!insMLast.empty())  
    {  
        _CursorTextField->m_pCursorSprite->setPositionX(_CursorTextField->m_pCursorSprite->getPositionX() + _CursorTextField->getLabelWidth(insMLast, _CursorTextField->fontName, _CursorTextField->fontsize));  
    }  
}  
//����string��ȡ�ַ����  
float CursorTextField::getLabelWidth(std::string str, std::string fontName, float fontsize)  
{  
    if (str.empty())  
    {  
        return 0;  
    }  
    LabelTTF * label = LabelTTF::create(str, fontName, fontsize);  
    float nowposi = label->getContentSize().width;  
    return nowposi;  
}  
  
//�����ַ�λ�÷����ֽ�λ��  
int CursorTextField::getPosifromText(std::string str, int posi)  
{  
    int count = 0;  
    int i;  
    for (i = 0; i < str.length();)  
    {  
        std::string mystr = split_text(str, 1, i);  
        i += mystr.length();  
        count++;  
        if (count == posi)  
        {  
            return i;  
        }  
    }  
    return 0;  
}  
//��������λ�÷����ֽ�λ��  
int CursorTextField::getPosiformPosi(std::string str, float posi)  
{  
    std::string mystr;  
    std::string temp;  
    float parentPosi = this->getPositionX();  
    float reposi = posi - parentPosi;  
    if (parentPosi + getLabelWidth(str , fontName ,fontsize) <= posi)  
    {  
        return str.length();  
    }  
    if (reposi <= 0)  
    {  
        return 0;  
    }  
    int i = 0;  
    float last, next;  
    for (i = 0; i < str.length();)  
    {  
         temp = split_text(str, 1, i);  
         last = getLabelWidth(mystr, fontName, fontsize);  
         next = getLabelWidth(mystr.append(temp), fontName, fontsize);  
         if (last <= reposi && next > reposi)  
         {  
             return i;  
         }  
         else if (next == reposi)  
         {  
             return i + temp.length();  
         }  
         i += temp.length();  
    }  
    return 0;  
}  
  
void CursorTextField::MyRemoveFromParent()  
{  
    if (_CursorTextField)  
    {  
        m_pCursorSprite->stopAllActions();  
        parentNode->removeChild(m_pCursorSprite);  
        parentNode->removeChild(_CursorTextField);  
        _CursorTextField = NULL;  
    }  
}  