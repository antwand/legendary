#ifndef _TCPSERVER_H_
#define _TCPSERVER_H_

#include "TCPClient.h"
#include <string>
#include <map>
#include <mutex>
#include <thread>

using namespace std;

class TCPServer : public MyServer
{
public:
	TCPServer(void);
	~TCPServer(void);

	bool				init();
	bool				createSocket(int af, int type, int protocol = 0);
	bool				bind(int port);
	bool				listen(bool isLaunchThread=false);
	void                listenBackFunc();
	void                setListening(bool listening);

	bool				initClientStorage(int num);
	void                putClientInStorage(TCPClient* client);
	TCPClient*			getFreeClient();

	//vector<TCPClient*>	getClientGroups();
	bool				hasClient();
	TCPClient*			popBackClient();
	void				clearClientGroups();

	//release
	void				autorelease();
	void				clean();

	CREATE_FUNC(TCPServer);

private:
	TCPClient*			accept();
	void*				m_svrSocket;
	bool				m_isListening;
	mutex				m_mutex;

	vector<TCPClient*>	m_clientGroups;
	vector<TCPClient*>	m_clientStorage;
};

#endif