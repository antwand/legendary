
#ifndef _UDPSERVER_H_
#define _UDPSERVER_H_

#include "UDPClient.h"
#include <string>
#include <map>
#include <mutex>
#include <thread>

using namespace std;

class UDPServer: public MyServer
{
public:
	UDPServer();
	~UDPServer();

	bool				init();
	bool				createSocket(int af, int type, int protocol = 0);
	bool				bind(int port);
	bool				listen(bool isLaunchThread = false);
	void                listenBackFunc();
	void                setListening(bool listening);

	bool				initClientStorage(int num);
	void                putClientInStorage(UDPClient* client);
	UDPClient*			getFreeClient();

	//vector<TCPClient*>	getClientGroups();
	bool				hasClient();
	UDPClient*			popBackClient();
	void				clearClientGroups();

	//release
	void                close(string key);
	void				clean();
	void                sendTo(int clientId, const char* str);
	void                autorelease();

	CREATE_FUNC(UDPServer);

private:
	UDPClient*				accept();
	void*					m_svrSocket;
	bool					m_isListening;
	mutex					m_mutex;

	int                     m_port;

	vector<UDPClient*>		 m_clientGroups;
	vector<UDPClient*>		 m_clientStorage;
	map<string, UDPClient*>  m_currConnectedClient;

private:
	UDPClient*	        distributeMsg(const char* str, struct sockaddr_in* addr);
	//UDPClient*	        distributeMsg(const char* str, const char* ip, int port);
	UDPClient*			recvMsgContent();
};

#endif
