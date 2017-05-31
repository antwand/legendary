#pragma once

#include "RandomAccessFile.h"
#include <map>
#include <string>
using namespace std;

class FileCache
{
public:
	~FileCache(void);

	static FileCache*						getInstance();

	void                                    updateFile();
	RandomAccessFile*						getFile(const char* filename);
	void                                    delFile(const char* filename);

	void									release();

private:
	FileCache(void);
	static FileCache*						m_pInstance;
		
	map<string, RandomAccessFile*>			m_filesMap;	
	time_t                                  m_lastTime;
};

