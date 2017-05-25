
#include "UDPServer.h"
#include "ODSocket.h"
#include <string.h>

using namespace std;

UDPServer::UDPServer()
{
	m_isListening = false;
}


UDPServer::~UDPServer()
{
}

bool UDPServer::init()
{
	m_svrSocket = new ODSocket();
	((ODSocket*)m_svrSocket)->Init();

	initClientStorage(10);

	return true;
}

bool UDPServer::initClientStorage(int num)
{
	for (int i = 0; i<num; ++i)
	{
		UDPClient* client = UDPClient::create();
		client->setServer(this);

		putClientInStorage(client);
	}

	return true;
}

void UDPServer::putClientInStorage(UDPClient* client)
{
	m_clientStorage.push_back(client);
}

UDPClient* UDPServer::getFreeClient()
{
	for (int i = 0; i<m_clientStorage.size(); ++i)
	{
		UDPClient* client = m_clientStorage[i];

		if (client->m_isUsed == false)
		{
			client->m_isUsed = true;
			return client;
		}
	}

	UDPClient* client = UDPClient::create();
	client->setServer(this);
	putClientInStorage(client);

	client->m_isUsed = true;

	return client;
}

bool UDPServer::createSocket(int af, int type, int protocol)
{
	return ((ODSocket*)m_svrSocket)->Create(af, type, protocol);
}

UDPClient* UDPServer::accept()
{
	UDPClient* client = recvMsgContent();

	if (client != NULL)
	{
		//client->setIP(ipSocket);
		//client->setID(int(client));
		//client->setODSocket(m_svrSocket);

		return client;
	}
	else
		return 0;
}

bool UDPServer::bind(int port)
{
	m_port = port;
	return ((ODSocket*)m_svrSocket)->Bind(port);
}

bool UDPServer::listen(bool isLaunchThread)
{
	if (m_isListening)
		return false;

	if (isLaunchThread)
	{
		std::thread t(&UDPServer::listenBackFunc, this);
		t.detach();
	}
	else
		listenBackFunc();

	return true;
}

void UDPServer::autorelease()
{

}

void UDPServer::listenBackFunc()
{
	m_isListening = true;

	while (m_isListening)
	{
		UDPClient* client = accept();

		if (client != 0)
		{
			m_mutex.lock();
			m_clientGroups.push_back(client);
			m_mutex.unlock();
		}
	}

	m_isListening = false;
}

void UDPServer::setListening(bool listening)
{
	m_isListening = listening;
}

void UDPServer::sendTo(int clientId, const char* str)
{
	//((ODSocket*)m_svrSocket)->SendTo();
}

UDPClient* UDPServer::distributeMsg(const char* str, struct sockaddr_in* addr)
{
	string ip = inet_ntoa(addr->sin_addr);
	int port = htons(addr->sin_port);
	//printf("Received a string from client %s:%d, string is: %s\n", ip.c_str(), port, str);

	string key = ip;
	key += ":";
	key += Int2String(port);

	/*
	string content = str;
	if (content.find("port:") != string::npos)
	{
		port = atoi(content.replace(content.find("port:"), 5, "").c_str());
	}
	*/
	if (m_currConnectedClient.find(key) == m_currConnectedClient.end())
	{
		UDPClient* client = getFreeClient();
		client->setODSocket(m_svrSocket);
		client->m_ip = ip;
		client->m_port = port;//recvMsgContent
		client->m_key = key;
		client->setConnectSuccess(true);
		m_currConnectedClient[key] = client;

		string str = SHAKE_HAND_PROTO;
		str += ":" + Int2String(port);
		//((ODSocket*)m_svrSocket)->SendTo(str.c_str(), sizeof(SHAKE_HAND_PROTO),
		//	(struct sockaddr *)&addr, sizeof(struct sockaddr_in));
		client->send(str.c_str());

		return client;
	}
	else
	{
		m_mutex.lock();
		m_currConnectedClient[key]->addMessage(str);
		m_mutex.unlock();

		return NULL;
	}
}

void UDPServer::close(string key)
{
	if (m_currConnectedClient.find(key) != m_currConnectedClient.end())
	{
		auto client = m_currConnectedClient[key];
		m_currConnectedClient.erase(m_currConnectedClient.find(key));
	}
}

UDPClient* UDPServer::recvMsgContent()
{
	char msgBuf[READ_CACHE_LEN];
	memset(msgBuf, 0, sizeof(msgBuf));
	//char* msgBuf = new char[];
	
	struct sockaddr_in addr;
	int addr_len = sizeof(struct sockaddr_in);

	memset(&addr, 0, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_port = htons(m_port);
	addr.sin_addr.s_addr = htonl(INADDR_ANY);// 接收任意IP发来的数据

	int ret = ((ODSocket*)m_svrSocket)->recvFrom(msgBuf, READ_CACHE_LEN,
		(struct sockaddr *)&addr, 
		&addr_len);

	//printf("recv msg [[%s]] from %s:%d\n", msgBuf, inet_ntoa(addr.sin_addr), htons(addr.sin_port));
	if (ret == SOCKET_ERROR || ret == 0)
	{
		int errorCode = WSAGetLastError();
		//printf("recvfrom error code:%d\n", errorCode);
		if (errorCode != 10054)
			clean();
	}
	else if (ret > 0)
	{
		//((ODSocket*)m_svrSocket)->SendTo(msgBuf, strlen(msgBuf), (struct sockaddr *)&addr, addr_len);
		//add msg
		return distributeMsg(msgBuf, &addr);// inet_ntoa(addr.sin_addr), addr.sin_port);
	}

	return NULL;
}

bool UDPServer::hasClient()
{
	//update client heart freuq
	/*
	for (map<string, UDPClient*>::iterator iter = m_currConnectedClient.begin();
		iter != m_currConnectedClient.end(); ++iter)
	{
		iter->second->getOffLine
		iter->second->updateHeartFreq();
	}
	*/

	if (m_clientGroups.size() >= 1)
		return true;

	return false;
}

UDPClient* UDPServer::popBackClient()
{
	if (m_clientGroups.size() <= 0)
	{
		return 0;
	}

	m_mutex.lock();
	UDPClient* client = m_clientGroups[m_clientGroups.size() - 1];
	m_clientGroups.pop_back();
	m_mutex.unlock();

	return client;
}

void UDPServer::clearClientGroups()
{
	m_clientGroups.clear();
}

void UDPServer::clean()
{
	((ODSocket*)m_svrSocket)->Close();
	((ODSocket*)m_svrSocket)->Clean();
	m_isListening = false;

	for (int i = 0; i < m_clientStorage.size(); ++i)
	{
		UDPClient* client = m_clientStorage[i];
		client->setConnectSuccess(false);
	}

	m_clientStorage.clear();
	m_clientGroups.clear();
	m_currConnectedClient.clear();
}