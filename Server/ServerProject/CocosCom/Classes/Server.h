
#ifndef _MYSERVER_H_
#define _MYSERVER_H_

#include <string>

using namespace std;

class MyClient
{
public:
	virtual bool			init() = 0;
	virtual bool			createSocket(int af, int type, int protocol = 0) = 0;
	virtual bool			connect(const char* ip, unsigned short port) = 0;
	virtual bool			listen() = 0;
	virtual void			listenBackFunc() = 0;
	virtual void            setODSocket(void*) = 0;
	virtual void            setID(int id) = 0;
	virtual int				getID() = 0;

	virtual void            setConnectSuccess(bool success) = 0;
	virtual bool			getOffLine() = 0;
	virtual bool			hasNewMessage() = 0;
	virtual char*			getNewMessage() = 0;
	virtual bool			popNewMessage() = 0;
	// Recv socket
	virtual int				send(const char* buf, int flags = 0) = 0;

	virtual string          getIP() = 0;
	virtual void            setIP(const char* ip) = 0;
	virtual int             getPort() = 0;

	virtual void*           getODSocket() = 0;
	virtual void			autorelease() = 0;
	virtual void			clean() = 0;
};

class MyServer
{
public:
	virtual bool				init() = 0;
	virtual bool				createSocket(int af, int type, int protocol = 0) = 0;
	virtual bool				bind(int port) = 0;
	virtual bool				listen(bool isLaunchThread = false) = 0;
	virtual void                setListening(bool listening) = 0;

	//vector<TCPClient*>	getClientGroups();
	virtual bool				hasClient() = 0;
	virtual MyClient*			popBackClient() = 0;
	virtual void				clearClientGroups() = 0;

	//release
	virtual void				autorelease() = 0;
	virtual void				clean() = 0;
};

long getCurrSystemTime();

string Int2String(int num);

#endif