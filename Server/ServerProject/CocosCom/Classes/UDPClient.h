
#ifndef _UDPCLIENT_H_
#define _UDPCLIENT_H_

#ifdef WIN32
	#include <winsock2.h>
	#include<windows.h>
#endif

#include "Server.h"
#include <string>
#include <vector>
#include <mutex>
#include <thread>
#include "cocos2d.h"

using namespace std;
using namespace cocos2d;

#define UDP_HEART_FREQ 4000
#define UDP_HEART_STRING "heartPack"
#define UDP_HEART_CHECK_FREQ 10000
#define READ_CACHE_LEN 1024*32
#define SHAKE_HAND_PROTO "SHAKE_HAND_PROTO"

class UDPClient : public MyClient
{
	friend class UDPServer;

	enum ConState
	{
		SLEEP,
		CONNECTING,
		CONNECTED,
		FAILED
	};

public:
	UDPClient();
	~UDPClient();

	bool			init();
	bool			createSocket(int af, int type, int protocol = 0);
	bool			connect(const char* ip, unsigned short port);
	bool			listen();
	void			listenBackFunc();
	void            setODSocket(void*);
	void            setID(int id);
	int				getID();

	void            updateHeartFreq();
	void            setConnectSuccess(bool success);
	bool			getOffLine();
	void            addMessage(const char* str);
	bool			hasNewMessage();
	char*			getNewMessage();
	bool			popNewMessage();
	// Recv socket
	int				send(const char* buf, int flags = 0);

	int             getPort();
	string          getKey();
	string          getIP();
	void            setIP(const char* ip);
	void*           getODSocket();
	void			autorelease();
	void			clean();

	CREATE_FUNC(UDPClient);

private:
	void*				m_clientSocket;//ODSocket*
	mutex				m_mutex;

	ConState            m_state; // 1:sleep, 2:connecting, 3:failed

	//for reading message
	vector<string>		m_msgVec;
	bool                m_isUsed;
	double              m_lastHeartRecvTime;
	double              m_lastHeartSendTime;

	string				recvMsgContent(bool isStock = true);
	void                setServer(void* ptr) { m_svr = ptr; };
	void*               m_svr;
	//atttribute
private:
	string              m_ip;
	int                 m_port;
	int                 m_recvPort;
	int                 m_type;
	string              m_key;
	int					m_clientID;

	int                 getFreePortForRecv(int start);
	void                listenForConnecting();
	void                listenBackFuncForConnecting();
};

#endif
