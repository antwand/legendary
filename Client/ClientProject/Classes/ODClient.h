
#include <string>
#include <vector>
#include <mutex>
#include <thread>
#include "cocos2d.h"

using namespace std;
using namespace cocos2d;

#define MSG_HEAD_LEN 5

class ODClient : public Node
{
public:
	ODClient(void);
	~ODClient(void);

	bool			init();
	bool			createSocket(int af, int type, int protocol = 0);
	bool			connect(const char* ip, unsigned short port);
	bool			listen();
	void			listenBackFunc();
	void            setODSocket(void*);
	void            setID(int id);
	void            popMessage();
	int				getID();

	bool            getOffLine();
	bool			hasNewMessage();
	char*			getNewMessage();
	// Recv socket
	int				send(const char* buf, int flags = 0);

	void			close();
	void			clean();

	CREATE_FUNC(ODClient);

private:
	void*				m_clientSocket;//ODSocket*
	mutex				m_mutex;

	bool				m_isSuccess;
	bool				m_isListening;
	bool				m_isOffLine;

	vector<string>		m_msgVec;
	int					m_currMsgIndex;
	int					m_clientID;
 };
