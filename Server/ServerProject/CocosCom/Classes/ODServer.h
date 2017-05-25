
#ifndef _ODSERVER_H_
#define _ODSERVER_H_

#include <string>
#include "Server.h"
#include "ODClient.h"
#include "cocos2d.h"

using namespace std;
using namespace cocos2d;

class ODServer:public Node
{
	enum SvrType
	{
		TCP,
		UDP
	};

public:
	ODServer();
	~ODServer();

	bool				init();
	bool				createSocket(int af, int type, int protocol = 0);
	bool				bind(int port);
	bool				listen(bool isLaunchThread = false);
	void                listenBackFunc();
	void                setListening(bool listening);

	//vector<TCPClient*>	getClientGroups();
	bool				hasClient();
	ODClient*			popBackClient();
	void				clearClientGroups();

	bool				initClientStorage(int num);
	void                putClientInStorage(ODClient* client);
	ODClient*			getFreeClient();

	//release
	void				autorelease();
	void				clean();

	CREATE_FUNC(ODServer);

private:
	MyServer*			m_svrConn;
	int					m_svrType;
};

#endif