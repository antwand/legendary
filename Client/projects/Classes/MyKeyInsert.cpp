#include "MyKeyInsert.h"

USING_NS_CC;

static KeyInsert * _KeyInsert = NULL;

KeyInsert::KeyInsert()
{
    _KeyInsert = this;
    _KeyInsert->autorelease();
}

KeyInsert::~KeyInsert()
{
}

KeyInsert * KeyInsert::getinstence()
{
    if (_KeyInsert == NULL)
    {
        _KeyInsert = new (std::nothrow)KeyInsert();
    }
    return _KeyInsert;
}

void KeyInsert::destoryinstence()
{
    Director::getInstance()->getEventDispatcher()->removeEventListener(_KeyInsert->_keyBordListener);
    CC_SAFE_RELEASE(_KeyInsert);
}

void KeyInsert::addKeyBordClick(cocos2d::Node * node)
{
    _KeyInsert->parentNode = node;
    _KeyInsert->_keyBordListener = EventListenerKeyboard::create();
    _KeyInsert->_keyBordListener->onKeyPressed = CC_CALLBACK_2(KeyInsert::onKeyPressed, this);
    _KeyInsert->_keyBordListener->onKeyReleased = CC_CALLBACK_2(KeyInsert::onKeyReleased, this);
    Director::getInstance()->getEventDispatcher()->addEventListenerWithSceneGraphPriority(_keyBordListener, _KeyInsert->parentNode);
}

void KeyInsert::onKeyPressed(EventKeyboard::KeyCode keycode, Event* event)
{
    switch (keycode)
    {
    case EventKeyboard::KeyCode::KEY_LEFT_ARROW:
        log("Left");
        //BlickSpriteLeft();
        break;
    case EventKeyboard::KeyCode::KEY_RIGHT_ARROW:
        log("right");
        //BlickSpriteRight();
        break;
    case EventKeyboard::KeyCode::KEY_DELETE :
        //KeyDelete();
        break;
    case EventKeyboard::KeyCode::KEY_UP_ARROW:
        log("Up");
        break;
    case EventKeyboard::KeyCode::KEY_DOWN_ARROW:
        log("DOWN");
        break;
    default:
        break;
    }
}

void KeyInsert::onKeyReleased(EventKeyboard::KeyCode keycode, Event* event)
{
    //log("BBB");
}
