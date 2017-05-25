#include "TCPClient.h"
#include "ODSocket.h"

TCPClient::TCPClient(void)
{
	m_isSuccess = false;
	m_currMsgIndex = 0;
	m_clientSocket = 0;
	m_isUsed = false;
	m_recvMsgHeadLength = 0;
	m_recvStatus = ClientRecvStatus::WAITING_FOR_MSG;
}


TCPClient::~TCPClient(void)
{
	if (m_clientSocket != 0)
		delete m_clientSocket;
}

bool TCPClient::init()
{
	if (m_clientSocket == 0)
		m_clientSocket = new ODSocket();

	return ((ODSocket*)m_clientSocket)->Init();
}

bool TCPClient::createSocket(int af, int type, int protocol)
{
	return ((ODSocket*)m_clientSocket)->Create(af, type, protocol);
}

bool TCPClient::connect(const char* ip, unsigned short port)
{
	m_isSuccess = ((ODSocket*)m_clientSocket)->Connect(ip, port);

	return m_isSuccess;
}

bool TCPClient::listen()
{
	if (m_isSuccess)
	{
		//std::thread t(&TCPClient::listenBackFunc, this);
		//t.detach();

		return true;
	}
	else
		return false;
}

void TCPClient::listenBackFunc()
{
	while(m_isSuccess)
	{
		char recvBuff[4];
		//char recvBuf[MSG_HEAD_LEN];// 获取请求头的 数据
		int ret = ((ODSocket*)m_clientSocket)->Recv(recvBuff, 4,0);

		if (ret == SOCKET_ERROR || ret == 0)
		{
			clean();
			return;
		}

		//请求数据主体
		int msgLen;
		memcpy(&msgLen, recvBuff, sizeof(msgLen));

		//short msgLen = my_atoi(recvBuf);
		char* msgBuf = new char[msgLen];
		((ODSocket*)m_clientSocket)->Recv(msgBuf, msgLen,0);

		m_mutex.lock();
		m_msgVec.push_back(msgBuf);
		m_mutex.unlock();

		delete msgBuf;
	}
}

string TCPClient::getIP()
{
	return m_ip;
}

void TCPClient::setIP(const char* ip)
{
	m_ip = ip;
}

int	TCPClient::send(const char* buf, int flags)
{
	if (m_isSuccess == false)
		return 0;

	int len = strlen(buf) + 1;

	char headBuff[4];
	memcpy(headBuff, &len, sizeof(len));

	//send msg head
	((ODSocket*)m_clientSocket)->Send(headBuff, 4, 0);

	int ret = ((ODSocket*)m_clientSocket)->Send(buf, len, 0);

	//send msg content
	return ret;
}

void TCPClient::setConnectSuccess(bool success)
{
	m_isSuccess = success;
}

bool TCPClient::getOffLine()
{
	if (m_clientSocket == 0)
		return true;

	return !m_isSuccess;
}

void TCPClient::recvMsgHead()
{
	char recvBuff[4];
	//char recvBuf[MSG_HEAD_LEN];// 获取请求头的 数据
	int ret = ((ODSocket*)m_clientSocket)->AsynRecv(recvBuff, 4,0);

	if (ret == SOCKET_ERROR || ret == 0)
		clean();
	else if(ret > 0)
	{
		memcpy(&m_recvMsgHeadLength, recvBuff, sizeof(m_recvMsgHeadLength));//获取消息头,表示后续消息的长度
		m_recvStatus = WAITING_FOR_MSG_CONTENT;
	}
}

void TCPClient::recvMsgContent()
{
	char* msgBuf = new char[m_recvMsgHeadLength];

	int ret = ((ODSocket*)m_clientSocket)->Recv(msgBuf, m_recvMsgHeadLength,0);
	if (ret == SOCKET_ERROR || ret == 0)
		clean();
	else if(ret > 0)
	{
		m_msgVec.push_back(msgBuf);
		m_recvStatus = WAITING_FOR_MSG;
	}

	delete[] msgBuf;
}

bool TCPClient::hasNewMessage()
{
	if (m_clientSocket != 0)
	{
		switch (m_recvStatus)
		{
			case ClientRecvStatus::WAITING_FOR_MSG:
				recvMsgHead();
				break;
			case ClientRecvStatus::WAITING_FOR_MSG_CONTENT:
				recvMsgContent();
				break;
		}
	}

	if (m_currMsgIndex < m_msgVec.size())
		return true;

	return false;
}

char* TCPClient::getNewMessage()
{
	if (m_currMsgIndex >= m_msgVec.size())
		return 0;

	char* msg = (char*)m_msgVec[m_currMsgIndex].c_str();

	//m_currMsgIndex ++;

	return msg;
}

bool TCPClient::popNewMessage()
{
	if (0 >= m_msgVec.size())
		return false;

	m_msgVec.erase(m_msgVec.begin());

	return true;
}

void TCPClient::setODSocket(void* socket)
{
	if (m_clientSocket != NULL)
		((ODSocket*)m_clientSocket)->Close();

	delete m_clientSocket;
	m_clientSocket = socket;
	m_isSuccess = true;
}

void TCPClient::setID(int id)
{
	m_clientID = id;
}

int TCPClient::getID()
{
	return m_clientID;
}


void TCPClient::clean()
{
	if (m_clientSocket)
	{
		((ODSocket*)m_clientSocket)->Close();
		((ODSocket*)m_clientSocket)->Clean();
		delete m_clientSocket;
	}

	m_clientSocket = 0;
	m_isSuccess = false;
	m_isUsed = false;
	m_recvMsgHeadLength = 0;
	m_recvStatus = ClientRecvStatus::WAITING_FOR_MSG;
}

void* TCPClient::getODSocket()
{
	return m_clientSocket;
}

void TCPClient::autorelease()
{

}

int my_atoi(const char *str)
{
	int result = 0;
	int signal = 1; /* 默认为正数 */
	if((*str>='0'&&*str<='9')||*str=='-'||*str=='+')
	{
		if(*str=='-'||*str=='+')
		{
			if(*str=='-')
				signal = -1; /* 输入负数 */
			str++;
		}
	}
	else
		return result;

	while(*str>='0'&&*str<='9')
		result = result*10+(*str++ -'0');

	return signal*result;
}
