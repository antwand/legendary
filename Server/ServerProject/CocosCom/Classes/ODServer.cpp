
#include "ODServer.h"
#include "TCPServer.h"
#include "UDPServer.h"

ODServer::ODServer()
{
	m_svrConn = 0;
}


ODServer::~ODServer()
{
}


bool ODServer::init()
{
	return true;
}

bool ODServer::createSocket(int af, int type, int protocol)
{
	bool ret = 0;
	switch (type)
	{
	case 1:
		m_svrConn = TCPServer::create();
		ret = ((TCPServer*)m_svrConn)->createSocket(af, type, protocol);
		break;
	case 2:
		m_svrConn = UDPServer::create();
		ret = ((UDPServer*)m_svrConn)->createSocket(af, type, protocol);
		break;
	}

	m_svrType = type + 1;

	return ret;
}

bool ODServer::bind(int port)
{
	return m_svrConn->bind(port);
}

bool ODServer::listen(bool isLaunchThread)
{
	m_svrConn->listen(isLaunchThread);

	return true;
}

void ODServer::listenBackFunc()
{
}

void ODServer::setListening(bool listening)
{
	m_svrConn->setListening(listening);
}

/*
vector<TCPClient*> ODServer::getClientGroups()
{
return m_clientGroups;
}
*/
bool ODServer::hasClient()
{
	return m_svrConn->hasClient();
}

ODClient* ODServer::popBackClient()
{
	MyClient* client = m_svrConn->popBackClient();
	ODClient* bigClient = NULL;
	if (client != NULL)
	{
		bigClient = ODClient::create();
		bigClient->setClient(client);
	}

	return bigClient;
}

bool ODServer::initClientStorage(int num)
{
	return true;
}

void ODServer::putClientInStorage(ODClient* client)
{
}

ODClient* ODServer::getFreeClient()
{
	return NULL;
}

void ODServer::clearClientGroups()
{
	m_svrConn->clearClientGroups();
}

void ODServer::clean()
{
	m_svrConn->clean();
}

void ODServer::autorelease()
{
	if (m_svrConn != 0)
		m_svrConn->autorelease();
}
