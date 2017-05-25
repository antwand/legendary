
#include "ODClient.h"
#include "TCPClient.h"
#include "UDPClient.h"

ODClient::ODClient()
{
	m_client = 0;
}


ODClient::~ODClient()
{
}

bool ODClient::init()
{
	return true;//((ODSocket*)m_clientSocket)->Init();
}

void ODClient::initClient(int type)
{
	switch (type)
	{
	case 1:
		m_client = TCPClient::create();
		break;
	case 2:
		m_client = UDPClient::create();
		break;
	}
}

void ODClient::setClient(void* client)
{
	m_client = client;
}

bool ODClient::createSocket(int af, int type, int protocol)
{
	initClient(type);
	return ((MyClient*)m_client)->createSocket(af, type, protocol);
}

bool ODClient::connect(const char* ip, unsigned short port)
{
	return ((MyClient*)m_client)->connect(ip, port);
}

bool ODClient::listen()
{
	return ((MyClient*)m_client)->listen();
}

void ODClient::listenBackFunc()
{

}

string ODClient::getIP()
{
	return ((MyClient*)m_client)->getIP();
}

void ODClient::setIP(const char* ip)
{
	((MyClient*)m_client)->setIP(ip);
}

int ODClient::getPort()
{
	return ((MyClient*)m_client)->getPort();
}

int	ODClient::send(const char* buf, int flags)
{
	return ((MyClient*)m_client)->send(buf, flags);
}

void ODClient::setConnectSuccess(bool success)
{
	((MyClient*)m_client)->setConnectSuccess(success);
}

bool ODClient::getOffLine()
{
	return ((MyClient*)m_client)->getOffLine();
}

bool ODClient::hasNewMessage()
{
	return ((MyClient*)m_client)->hasNewMessage();
}

char* ODClient::getNewMessage()
{
	return ((MyClient*)m_client)->getNewMessage();
}

bool ODClient::popMessage()
{
	return ((MyClient*)m_client)->popNewMessage();
}

void ODClient::setODSocket(void* socket)
{
	
}

void ODClient::setID(int id)
{
	((MyClient*)m_client)->setID(id);
}

int ODClient::getID()
{
	return ((MyClient*)m_client)->getID();
}


void ODClient::clean()
{
	((MyClient*)m_client)->clean();
}

void ODClient::close()
{
	((MyClient*)m_client)->clean();
}

void* ODClient::getODSocket()
{
	return NULL;
}

void ODClient::autorelease()
{
	if (m_client != 0)
		((MyClient*)m_client)->autorelease();
}