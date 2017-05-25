#include "ODClient.h"
#include "ODSocket.h"

ODClient::ODClient(void)
{
	m_isSuccess = false;
	m_isListening = false;
	m_isOffLine = false;
	m_currMsgIndex = 0;
	m_clientSocket = 0;
}


ODClient::~ODClient(void)
{
	if (m_clientSocket != 0)
		delete m_clientSocket;
}

bool ODClient::init()
{
	if (m_clientSocket == 0)
		m_clientSocket = new ODSocket();

	int ret = ((ODSocket*)m_clientSocket)->Init();

	if (ret == 0)
		return true;

	return false;
}
	
bool ODClient::createSocket(int af, int type, int protocol)
{
	return ((ODSocket*)m_clientSocket)->Create(af, type, protocol);
}

bool ODClient::connect(const char* ip, unsigned short port)
{
	if (m_isSuccess == false)
		m_isSuccess = ((ODSocket*)m_clientSocket)->Connect(ip, port);

	return m_isSuccess;
}

bool ODClient::listen()
{
	if (m_isSuccess && m_isListening == false)
	{
		m_isListening = true;
		m_isOffLine = false;

		std::thread t(&ODClient::listenBackFunc, this);
		t.detach();

		return true;
	}
	else
		return false;
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

void ODClient::listenBackFunc()
{
	while(m_isListening)
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

int	ODClient::send(const char* buf, int flags)
{
	int len = strlen(buf) + 1;

	char headBuff[4];
	memcpy(headBuff, &len, sizeof(len));

	//send msg head
	((ODSocket*)m_clientSocket)->Send(headBuff, 4, 0);

	int ret = ((ODSocket*)m_clientSocket)->Send(buf, len, 0);

	//send msg content
	return ret;
}

bool ODClient::getOffLine()
{
	return m_isOffLine;
}

bool ODClient::hasNewMessage()
{
	if (m_currMsgIndex >= m_msgVec.size())
		return false;

	return true;
}

char* ODClient::getNewMessage()
{
	if (m_currMsgIndex >= m_msgVec.size())
		return 0;

	char* msg = (char*)m_msgVec[m_currMsgIndex].c_str();

	//m_currMsgIndex ++;

	return msg;
}

void ODClient::popMessage()
{
	m_msgVec.erase(m_msgVec.begin());
}

void ODClient::setODSocket(void* socket)
{
	m_clientSocket = socket;
	m_isSuccess = true;
}

void ODClient::setID(int id)
{
	m_clientID = id;
}

int ODClient::getID()
{
	return m_clientID;
}


void ODClient::clean()
{
	if (m_clientSocket)
	{
		((ODSocket*)m_clientSocket)->Close();
		//((ODSocket*)m_clientSocket)->Clean();
		//delete m_clientSocket;
	}

	m_clientSocket = 0;
	m_isListening = false;
	m_isSuccess = false;
	m_isOffLine = true;
}

void ODClient::close()
{
	if (m_clientSocket)
	{
		((ODSocket*)m_clientSocket)->Close();
		((ODSocket*)m_clientSocket)->Clean();
		delete m_clientSocket;
	}

	m_clientSocket = 0;
	m_isListening = false;
	m_isSuccess = false;
	m_isOffLine = true;
}
