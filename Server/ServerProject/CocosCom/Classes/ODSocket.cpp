#include "ODSocket.h"
#include "stdio.h"

#ifdef WIN32
	#pragma comment(lib, "wsock32")
#endif


ODSocket::ODSocket(SOCKET sock)
{
	m_sock = sock;
	m_timeout.tv_sec = 0;
	m_timeout.tv_usec = 0;
}

ODSocket::~ODSocket()
{
}

int ODSocket::Init()
{
#ifdef WIN32
	/*
	http://msdn.microsoft.com/zh-cn/vstudio/ms741563(en-us,VS.85).aspx

	typedef struct WSAData { 
		WORD wVersion;								//winsock version
		WORD wHighVersion;							//The highest version of the Windows Sockets specification that the Ws2_32.dll can support
		char szDescription[WSADESCRIPTION_LEN+1]; 
		char szSystemStatus[WSASYSSTATUS_LEN+1]; 
		unsigned short iMaxSockets; 
		unsigned short iMaxUdpDg; 
		char FAR * lpVendorInfo; 
	}WSADATA, *LPWSADATA; 
	*/
	WSADATA wsaData;
	//#define MAKEWORD(a,b) ((WORD) (((BYTE) (a)) | ((WORD) ((BYTE) (b))) << 8)) 
	WORD version = MAKEWORD(2, 0);
	int ret = WSAStartup(version, &wsaData);//win sock start up
	if ( ret ) {
//		cerr << "Initilize winsock error !" << endl;
		return 0;
	}
#endif
	
	return 1;
}
//this is just for windows
int ODSocket::Clean()
{
#ifdef WIN32
		return (WSACleanup());
#endif
		return 0;
}

ODSocket& ODSocket::operator = (SOCKET s)
{
	m_sock = s;
	return (*this);
}

ODSocket::operator SOCKET ()
{
	return m_sock;
}
//create a socket object win/lin is the same
// af:
bool ODSocket::Create(int af, int type, int protocol)
{
	m_sock = socket(af, type, protocol);
	if ( m_sock == INVALID_SOCKET ) {
		return false;
	}
	return true;
}

bool ODSocket::Connect(const char* ip, unsigned short port)
{
	struct sockaddr_in svraddr;
	svraddr.sin_family = AF_INET;
	svraddr.sin_addr.s_addr = inet_addr(ip);
	svraddr.sin_port = htons(port);
	int ret = connect(m_sock, (struct sockaddr*)&svraddr, sizeof(svraddr));
	if ( ret == SOCKET_ERROR ) {
		return false;
	}
	return true;
}

bool ODSocket::Bind(unsigned short port)
{
	struct sockaddr_in svraddr;
	svraddr.sin_family = AF_INET;
	svraddr.sin_addr.s_addr = INADDR_ANY;
	svraddr.sin_port = htons(port);

	int opt =  1;
	if ( setsockopt(m_sock, SOL_SOCKET, SO_REUSEADDR, (char*)&opt, sizeof(opt)) < 0 ) 
		return false;

	int ret = bind(m_sock, (struct sockaddr*)&svraddr, sizeof(svraddr));
	if ( ret == SOCKET_ERROR ) {
		return false;
	}
	return true;
}
//for server
bool ODSocket::Listen(int backlog)
{
	int ret = listen(m_sock, backlog);
	if ( ret == SOCKET_ERROR ) {
		return false;
	}
	return true;
}

bool ODSocket::Accept(ODSocket& s, char* fromip)
{
	struct sockaddr_in cliaddr;
	socklen_t addrlen = sizeof(cliaddr);
	SOCKET sock = accept(m_sock, (struct sockaddr*)&cliaddr, &addrlen);
	if ( sock == SOCKET_ERROR ) {
		return false;
	}

	s = sock;
	if ( fromip != NULL )
		sprintf(fromip, "%s", inet_ntoa(cliaddr.sin_addr));

	return true;
}

int ODSocket::AsynRecv(char* buf, int len, int flags)
{
	FD_ZERO(&m_fds); //每次循环都要清空集合，否则不能检测描述符变化 

	FD_SET(m_sock,&m_fds); //添加描述符 
	int maxfdp = m_sock + 1;

	int ret = select(maxfdp,&m_fds,NULL,NULL,&m_timeout);
	switch(ret)
	{
		case -1:
			return -1;
		case 0:
			return -2;
		default:
			if (FD_ISSET(m_sock,&m_fds))
			{
				return Recv(buf, len, flags);
			}
	}

	//-1:error  0:offline   >=1:right -2:no msg
	return -2;
}

bool ODSocket::isPortFree(int port)
{
	struct sockaddr_in sin;
	int                sock = -1;
	int                ret = 0;
	int                opt = 0;

	memset(&sin, 0, sizeof(sin));
	sin.sin_family = PF_INET;
	sin.sin_port = htons(port);

	sock = socket(PF_INET, SOCK_STREAM, 0);
	if (sock == -1)
		return -1;

	ret = setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, (char*)&opt, sizeof(opt));
	ret = bind(sock, (struct sockaddr *)&sin, sizeof(sin));
	
	#ifdef WIN32
		(closesocket(sock));
	#else
		(close(sock));
	#endif

	return (ret == 0) ? 1 : 0;
}

int ODSocket::Send(const char* buf, int len, int flags)
{
	int bytes;
	int count = 0;

	while ( count < len ) {

		bytes = send(m_sock, buf + count, len - count, flags);
		if ( bytes == -1 || bytes == 0 )
			return -1;
		count += bytes;
	} 

	return count;
}

int ODSocket::Recv(char* buf, int len, int flags)
{
	return (recv(m_sock, buf, len, flags));
}

int ODSocket::recvFrom(char* buf, int len, sockaddr* addr, int* fromLen, int flags)
{
	int iMode = 0; //1,非阻塞；0,阻塞
	ioctlsocket(m_sock, FIONBIO, (u_long FAR*) &iMode);//非阻塞设置

	int nRecvBuf = 32 * 1024;//设置为32K
	setsockopt(m_sock, SOL_SOCKET, SO_RCVBUF, (const char*)&nRecvBuf, sizeof(int));

	return recvfrom(m_sock, buf, len, flags, addr, fromLen);
}

int ODSocket::AsynRecvFrom(char* buf, int len, sockaddr* addr, int* fromLen, int flags)
{
	int iMode = 1; //1,非阻塞；0,阻塞
	ioctlsocket(m_sock, FIONBIO, (u_long FAR*) &iMode);//非阻塞设置

	int nRecvBuf = 32 * 1024;//设置为32K
	setsockopt(m_sock, SOL_SOCKET, SO_RCVBUF, (const char*)&nRecvBuf, sizeof(int));

	return recvfrom(m_sock, buf, len, flags, addr, fromLen);
}

void ODSocket::setTimeOut(int sec)
{
#ifdef WIN32
	int timeout = sec*1000; //3s
	int ret = setsockopt(m_sock, SOL_SOCKET, SO_RCVTIMEO, 
		(const char*)&timeout, sizeof(timeout));
#else
	struct timeval timeout = { sec,0 };//3s
	int ret = setsockopt(m_sock, SOL_SOCKET, SO_SNDTIMEO,
		(const char*)&timeout, sizeof(timeout));
#endif
}

int ODSocket::SendTo(const char* buf, int len, const sockaddr* to, int tolen, int flags)
{
	int nSendBuf = 32 * 1024;//设置为32K
	setsockopt(m_sock, SOL_SOCKET, SO_SNDBUF, (const char*)&nSendBuf, sizeof(int));

	return sendto(m_sock, buf, len, flags, to, tolen);
}

int ODSocket::Close()
{
#ifdef WIN32
	return (closesocket(m_sock));
#else
	return (close(m_sock));
#endif
}

int ODSocket::OffLine()
{
	char buff[1];
	int ret = recv(m_sock, buff, 1, MSG_PEEK);

	if (ret <= 0 && errno != 11)
		return 1;

	return 0;
}

int ODSocket::GetError()
{
#ifdef WIN32
	return (WSAGetLastError());
#else
	return (errno);
#endif
}

bool ODSocket::DnsParse(const char* domain, char* ip)
{
	struct hostent* p;
	if ( (p = gethostbyname(domain)) == NULL )
		return false;
		
	sprintf(ip, 
		"%u.%u.%u.%u",
		(unsigned char)p->h_addr_list[0][0], 
		(unsigned char)p->h_addr_list[0][1], 
		(unsigned char)p->h_addr_list[0][2], 
		(unsigned char)p->h_addr_list[0][3]);
	
	return true;
}
