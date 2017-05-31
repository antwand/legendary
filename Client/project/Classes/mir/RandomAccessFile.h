#pragma once

#include "cocos2d.h"
#include <string>

using namespace std;
using namespace cocos2d;

class RandomAccessFile
{
public:
	RandomAccessFile(void);
	RandomAccessFile(const char* filename, const char* mode);
	~RandomAccessFile(void);

	void					readImage(char* bytesInt, int start, int size);

	bool					open(const char* filename, const char* mode);

	short                   readShort(int index, bool reverse);
	void					read(char* bytesInt, int size=4);
	void					skipBytes(int size);
	void					seek(int size);
	void                    setVisitTime(time_t time);
	time_t                  getVisitTime();

	string                  getFilename();
	ssize_t					getLength();
	const char*				getFileData();

private:
	char*					m_fileData;
	ssize_t					m_fileLength;
	ssize_t					m_skipOffset;
	string                  m_filename;
	time_t                  m_lastVisitTime;
};

