#ifndef _TCPCLIENT_H_
#define _TCPCLIENT_H_

#include "Server.h"
#include <string>
#include <vector>
#include <mutex>
#include <thread>
#include "cocos2d.h"

using namespace std;
using namespace cocos2d;

#define MSG_HEAD_LEN 5

enum ClientRecvStatus
{
	WAITING_FOR_MSG,
	WAITING_FOR_MSG_CONTENT,
};

class TCPClient : public MyClient
{
	friend class TCPServer;

public:
	TCPClient(void);
	~TCPClient(void);

	bool			init();
	bool			createSocket(int af, int type, int protocol = 0);
	bool			connect(const char* ip, unsigned short port);
	bool			listen();
	void			listenBackFunc();
	void            setODSocket(void*);
	void            setID(int id);
	int				getID();

	void            setConnectSuccess(bool success);
	bool			getOffLine();
	bool			hasNewMessage();
	char*			getNewMessage();
	bool			popNewMessage();
	// Recv socket
	int				send(const char* buf, int flags = 0);

	string          getIP();
	void            setIP(const char* ip);
	int             getPort() { return 0; }

	void*           getODSocket();
	void			autorelease();
	void			clean();

	CREATE_FUNC(TCPClient);

private:
	void*				m_clientSocket;//ODSocket*
	mutex				m_mutex;

	bool				m_isSuccess;

	vector<string>		m_msgVec;
	int					m_currMsgIndex;
	int					m_clientID;
	bool                m_isUsed;
	ClientRecvStatus    m_recvStatus;
	int                 m_recvMsgHeadLength;
	string              m_ip;

private:
	void                 recvMsgHead();
	void                 recvMsgContent();
 };

#endif