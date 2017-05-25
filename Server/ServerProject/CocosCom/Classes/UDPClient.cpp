
#include "UDPClient.h"
#include "UDPServer.h"
#include "ODSocket.h"

UDPClient::UDPClient()
{
	m_type = 0;
	m_recvPort = 0;
	m_state = ConState::SLEEP;
	m_clientSocket = 0;
	m_lastHeartSendTime = 0;
	m_lastHeartRecvTime = 0;
}


UDPClient::~UDPClient()
{
}

bool UDPClient::init()
{
	if (m_clientSocket == 0)
		m_clientSocket = new ODSocket();

	return ((ODSocket*)m_clientSocket)->Init();
}

void UDPClient::setODSocket(void* socket)
{
	if (m_clientSocket != NULL)
	{
		((ODSocket*)m_clientSocket)->Close();
		delete m_clientSocket;
	}

	m_clientSocket = socket;
	m_state = ConState::SLEEP;
}


bool UDPClient::createSocket(int af, int type, int protocol)
{
	return ((ODSocket*)m_clientSocket)->Create(af, type, protocol);
}

bool UDPClient::connect(const char* ip, unsigned short port)
{
	string _ip = ip;
	if (m_state == ConState::CONNECTED && _ip == m_ip && port == m_port)
		return true;

	if (m_state == ConState::CONNECTING)
		return false;

	auto socket = ((ODSocket*)m_clientSocket);
	//socket->Bind(port);
	m_recvPort = port+1;// socket->getFPort();
	if (m_recvPort == -1)
		return false;

	m_ip = ip;
	m_port = port;
	m_type = 1;

	//socket->Bind(m_recvPort);
	//bool r = socket->isPortFree(m_recvPort);
	//string clientPort = "port:" + Int2String(m_recvPort);
	//send(clientPort.c_str());

	listenForConnecting();

	return false;
}

void UDPClient::listenForConnecting()
{
	if (m_state == ConState::CONNECTING)
		return;

	m_state = ConState::CONNECTING;
	std::thread t(&UDPClient::listenBackFuncForConnecting, this);
	t.detach();
}

void UDPClient::listenBackFuncForConnecting()
{
	while (m_state == ConState::CONNECTING)
	{	
		struct sockaddr_in svraddr, peer;
		int addrLen = sizeof(peer);
		svraddr.sin_family = AF_INET;
		svraddr.sin_addr.s_addr = inet_addr(m_ip.c_str());
		svraddr.sin_port = htons(m_port);
		
		char buff[128];
		memset(buff, 0, sizeof(buff));
		int len = strlen("1");
		
		((ODSocket*)m_clientSocket)->SendTo("1", len, (struct sockaddr *)&svraddr,
			sizeof(SOCKADDR));

		((ODSocket*)m_clientSocket)->setTimeOut(5);
		((ODSocket*)m_clientSocket)->recvFrom(buff, sizeof(buff), 
			(struct sockaddr *)&peer, &addrLen);
		string msg = buff;
		if (msg.find(SHAKE_HAND_PROTO) != string::npos)
		{
			m_mutex.lock();
			addMessage(msg.c_str());
			m_mutex.unlock();
		}
		else
			m_state = ConState::FAILED;

		break;
	}

	//printf("quit listen thread for connecting:%d\n", m_state);
}

int UDPClient::getFreePortForRecv(int start)
{
	for (int i = 1; i <= 100; ++i)
	{
		bool isFree = ((ODSocket*)m_clientSocket)->isPortFree(i + start);
		if (isFree)
			return i + start;
	}

	return -1;
}

void UDPClient::setIP(const char* ip)
{

}

int UDPClient::getPort()
{ 
	return m_port; 
}

string UDPClient::getKey()
{ 
	return m_key; 
}

bool UDPClient::listen()
{
	if (m_state == ConState::CONNECTED)
	{
		std::thread t(&UDPClient::listenBackFunc, this);
		t.detach();

		return true;
	}
	else
		return false;
}

void UDPClient::listenBackFunc()
{
	while (m_state == ConState::CONNECTED)
	{
		((ODSocket*)m_clientSocket)->setTimeOut(0);
		string msg = recvMsgContent();
		if (msg != "")
		{
			m_mutex.lock();
			addMessage(msg.c_str());
			m_mutex.unlock();
		}
	}
}

int	UDPClient::send(const char* buf, int flags)
{
	if (m_clientSocket == 0)
		return 0;

	struct sockaddr_in svraddr;
	svraddr.sin_family = AF_INET;
	svraddr.sin_addr.s_addr = inet_addr(m_ip.c_str());
	svraddr.sin_port = htons(m_port);

	int len = strlen(buf);
	int ret = ((ODSocket*)m_clientSocket)->SendTo(buf, len, (struct sockaddr *)&svraddr, 
		sizeof(svraddr), 0);

	if (ret == SOCKET_ERROR)
		clean();

	//send msg content
	return ret;
}

void UDPClient::setConnectSuccess(bool success)
{
	if (success)
		m_state = ConState::CONNECTED;
	else
		m_state = ConState::SLEEP;

	m_lastHeartRecvTime = getCurrSystemTime();
}

bool UDPClient::getOffLine()
{
	if (m_clientSocket == 0)
		return true;

	if (m_state == ConState::CONNECTED)
		return false;

	return true;
}

bool UDPClient::hasNewMessage()
{
	updateHeartFreq();

	if (m_msgVec.size() > 0)
		return true;

	return false;
}

string UDPClient::recvMsgContent(bool isStock)
{
	char msgBuf[READ_CACHE_LEN];
	memset(msgBuf, 0, sizeof(msgBuf));
	//char* msgBuf = new char[];

	struct sockaddr_in addr;
	int sockfd, len = 0;
	int addr_len = sizeof(struct sockaddr_in);

	memset(&addr, 0, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_port = htons(m_recvPort);
	addr.sin_addr.s_addr = inet_addr(m_ip.c_str());// 接收任意IP发来的数据

	int ret = 0;
	if (isStock)
		ret = ((ODSocket*)m_clientSocket)->recvFrom(msgBuf, READ_CACHE_LEN,
		(struct sockaddr *)&addr,&addr_len);
	else
		ret = ((ODSocket*)m_clientSocket)->AsynRecvFrom(msgBuf, READ_CACHE_LEN,
		(struct sockaddr *)&addr, &addr_len);

	if (ret == SOCKET_ERROR || ret == 0)
	{
		int errorCode = WSAGetLastError();
		//printf("recv error:%d\n", errorCode);
	}
	else if (ret > 0)
	{
		return msgBuf;
		//addMessage(msgBuf);
	}

	return "";
}

char* UDPClient::getNewMessage()
{
	if (m_msgVec.size() <= 0)
		return 0;

	char* msg = (char*)m_msgVec[0].c_str();

	//m_currMsgIndex ++;

	return msg;
}

void UDPClient::updateHeartFreq()
{
	long delta = getCurrSystemTime() - m_lastHeartSendTime;
	if (delta > UDP_HEART_FREQ)
	{
		send(UDP_HEART_STRING);
		m_lastHeartSendTime = getCurrSystemTime();
		//printf("send UDP_HEART_STRING\n");
	}

	long recvDelta = getCurrSystemTime() - m_lastHeartRecvTime;
	if (recvDelta > UDP_HEART_CHECK_FREQ)
	{
		clean();

		//printf("close client for UDP_HEART_CHECK_FREQ\n");
	}

	//printf("delta:%ld,recvDelta:%ld\n", delta, recvDelta);
}

void UDPClient::addMessage(const char* str)
{
	string strFor = str;
	if (strFor.find(SHAKE_HAND_PROTO) != string::npos)
	{
		int port = atoi(strFor.replace(strFor.find("SHAKE_HAND_PROTO"), 17, "").c_str());
		if (m_state == ConState::CONNECTING)
		{
			m_state = ConState::CONNECTED;
			m_recvPort = port;
		}
	}
	else if (strFor == UDP_HEART_STRING)
	{
		m_lastHeartRecvTime = getCurrSystemTime();
	}
	else
		m_msgVec.push_back(str);

	//printf("recv msg %s\n", str);
}

bool UDPClient::popNewMessage()
{
	if (0 >= m_msgVec.size())
		return false;

	m_msgVec.erase(m_msgVec.begin());

	return true;
}

string UDPClient::getIP()
{
	return m_ip;
}

void UDPClient::setID(int id)
{
	m_clientID = id;
}

int UDPClient::getID()
{
	return m_clientID;
}

void UDPClient::clean()
{
	switch (m_type)
	{
	case 1:
		((ODSocket*)m_clientSocket)->Close();
		((ODSocket*)m_clientSocket)->Clean();
		delete m_clientSocket;
		break;
	case 0:
		((UDPServer*)m_svr)->close(getKey());
		break;
	}

	m_clientSocket = 0;
	m_state = ConState::SLEEP;
	m_isUsed = false;
}

void* UDPClient::getODSocket()
{
	return m_clientSocket;
}

void UDPClient::autorelease()
{

}