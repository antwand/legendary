

#ifndef _ODCLIENT_H_
#define _ODCLIENT_H_

#include <string>
#include "cocos2d.h"

using namespace std;
using namespace cocos2d;

class ODClient : public Node
{
public:
	ODClient();
	~ODClient();

	bool			init();
	void            initClient(int type = 1);//1:tpc 2:udp
	void            setClient(void* client);
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
	bool			popMessage();
	// Recv socket
	int				send(const char* buf, int flags = 0);

	string          getIP();
	void            setIP(const char* ip);
	int             getPort();

	void*           getODSocket();
	void			autorelease();
	void			clean();
	void            close();

	CREATE_FUNC(ODClient);

private:
	void*     m_client;
};

#endif