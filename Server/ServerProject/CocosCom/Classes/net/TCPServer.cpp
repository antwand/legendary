#include "TCPServer.h"
#include "ODSocket.h"

TCPServer::TCPServer(void)
{
	m_isListening = false;
}


TCPServer::~TCPServer(void)
{
}

bool TCPServer::init()
{
	m_svrSocket = new ODSocket();
	((ODSocket*)m_svrSocket)->Init();

	initClientStorage(10);

	return true;
}

bool TCPServer::initClientStorage(int num)
{
	for (int i=0;i<num;++i)
	{
		TCPClient* client = TCPClient::create();

		putClientInStorage(client);
	}

	return true;
}

void TCPServer::putClientInStorage(TCPClient* client)
{
	m_clientStorage.push_back(client);
}

TCPClient* TCPServer::getFreeClient()
{
	for (int i=0;i<m_clientStorage.size();++i)
	{
		TCPClient* client = m_clientStorage[i];

		if (client->m_isUsed == false)
		{
			client->m_isUsed = true;
			return client;
		}
	}

	TCPClient* client = TCPClient::create();
	putClientInStorage(client);

	client->m_isUsed = true;

	return client;
}

bool TCPServer::createSocket(int af, int type, int protocol)
{
	return ((ODSocket*)m_svrSocket)->Create(af, type, protocol);
}

TCPClient* TCPServer::accept()
{
	TCPClient* client = getFreeClient();
	char ipSocket[64];

	ODSocket* socket = (ODSocket*)client->getODSocket();
	bool ret = ((ODSocket*)m_svrSocket)->Accept(*socket, ipSocket);

	if (ret)
	{
		client->setIP(ipSocket);
		client->setID(int(client));
		client->setConnectSuccess(true);

		return client;
	}
	else
		return 0;
}

bool TCPServer::bind(int port)
{
	return ((ODSocket*)m_svrSocket)->Bind(port);
}

bool TCPServer::listen(bool isLaunchThread)
{
	if (m_isListening)
		return false;

	auto ret = ((ODSocket*)m_svrSocket)->Listen();

	if (!ret)
		return false;

	if (isLaunchThread)
	{
		std::thread t(&TCPServer::listenBackFunc, this);
		t.detach();
	}
	else
		listenBackFunc();

	return true;
}

void TCPServer::listenBackFunc()
{
	m_isListening = true;

	while(m_isListening)
	{
		TCPClient* client = accept();

		if (client == 0)
			return;

		m_mutex.lock();
		m_clientGroups.push_back(client);
		m_mutex.unlock();
	}

	m_isListening = false;
}

void TCPServer::setListening(bool listening)
{
	m_isListening = listening;
}

/*
vector<TCPClient*> TCPServer::getClientGroups()
{
	return m_clientGroups;
}
*/
bool TCPServer::hasClient()
{
	if (m_clientGroups.size() >= 1)
		return true;

	return false;
}

TCPClient* TCPServer::popBackClient()
{
	if (m_clientGroups.size() <= 0)
	{
		return 0;
	}

	TCPClient* client = m_clientGroups[m_clientGroups.size()-1];
	m_clientGroups.pop_back();

	return client;
}

void TCPServer::clearClientGroups()
{
	m_clientGroups.clear();
}

void TCPServer::clean()
{
	((ODSocket*)m_svrSocket)->Close();
	((ODSocket*)m_svrSocket)->Clean();
	m_isListening = false;

	for (int i=0;i<m_clientStorage.size();++i)
	{
		TCPClient* client = m_clientStorage[i];
		delete client;
	}

	m_clientStorage.clear();
	m_clientGroups.clear();
}

void TCPServer::autorelease()
{

}
