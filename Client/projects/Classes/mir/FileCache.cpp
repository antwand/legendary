#include "FileCache.h"

FileCache* FileCache::m_pInstance = 0;

FileCache::FileCache(void)
{
	m_lastTime = time(0);
}


FileCache::~FileCache(void)
{
}

FileCache* FileCache::getInstance()
{
	if (m_pInstance == 0)
		m_pInstance = new FileCache();

	return m_pInstance;
}

void FileCache::release()
{
	for (map<string, RandomAccessFile*>::iterator iter=m_filesMap.begin();iter!=m_filesMap.end();++iter)
	{
		delete iter->second;
	}

	m_filesMap.clear();
}

void FileCache::updateFile()
{
	time_t delay = time(0) - m_lastTime;
	std::vector<string> waitingDelList;

	if (delay >= 10)
	{
		for (map<string, RandomAccessFile*>::iterator iter = m_filesMap.begin(); iter != m_filesMap.end(); ++iter)
		{
			RandomAccessFile* file = iter->second;
			time_t lastVisitTime = file->getVisitTime();
			time_t fileDelayTime = time(0) - lastVisitTime;

			//log("file:%s, current visit delay time:%d", file->getFilename().c_str(), fileDelayTime);
			if (fileDelayTime >= 10)
			{
				//log("------delete file %s,because to long no use", file->getFilename().c_str());
				waitingDelList.push_back(iter->first);
			}
		}

		m_lastTime = time(0);
	}

	for (int i = 0; i < waitingDelList.size(); i++)
	{	
		delFile(waitingDelList[i].c_str());
		printf("file %s del\n", waitingDelList[i].c_str());
	}
}

void FileCache::delFile(const char* filename)
{
	if (m_filesMap.find(filename) != m_filesMap.end())
	{
		map<string, RandomAccessFile*>::iterator iter = m_filesMap.find(filename);
		delete iter->second;
		m_filesMap.erase(iter);
	}
}

RandomAccessFile* FileCache::getFile(const char* filename)
{
	if (m_filesMap.find(filename) != m_filesMap.end())
	{
		time_t t = time(0);
		m_filesMap[filename]->setVisitTime(t);

		return m_filesMap[filename];
	}

	auto file = new RandomAccessFile(filename, "rb");
	m_filesMap[filename] = file;

	time_t t = time(0);
	file->setVisitTime(t);
	
	return file;
}