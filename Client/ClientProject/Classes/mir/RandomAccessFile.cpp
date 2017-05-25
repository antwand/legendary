#include "RandomAccessFile.h"


RandomAccessFile::RandomAccessFile(void)
{
	m_skipOffset = 0;
	m_fileData = 0;
}

RandomAccessFile::RandomAccessFile(const char* filename, const char* mode)
{
	m_skipOffset = 0;
	m_fileData = 0;
	open(filename, mode);
}

RandomAccessFile::~RandomAccessFile(void)
{
	if (m_fileData != 0)
		delete m_fileData;
}

bool RandomAccessFile::open(const char* filename, const char* mode)
{
	bool isExist = FileUtils::getInstance()->isFileExist(filename);
	if (isExist == false)
	{
		log("no found file:%s", filename);
		return false;
	}

	m_fileData = (char*)FileUtils::getInstance()->getFileData(filename, mode, &m_fileLength);
	m_filename = filename;

	return true;
}

void RandomAccessFile::read(char* bytesInt, int size)
{
	//memccpy(bytesInt, m_fileData, m_skipOffset, size);
	//m_skipOffset += size;
	//strncpy((char*)bytesInt, (char*)(m_fileData+m_skipOffset), size);
	for (int i=0; i<size; ++i)
	{
		bytesInt[i] = m_fileData[m_skipOffset+i];//m_fileData[i];
	}

	skipBytes(size);
}

void RandomAccessFile::skipBytes(int size)
{
	if (m_skipOffset + size > this->m_fileLength-1)
		return;

	m_skipOffset += size;
}

short RandomAccessFile::readShort(int index, bool reverse)
{
	return 0;
}

void RandomAccessFile::readImage(char* bytesInt, int start, int size)
{
	strncpy((char*)bytesInt, (char*)(m_fileData+start), size);
}

void RandomAccessFile::seek(int size)
{
	if (size > this->m_fileLength-1)
		return;

	m_skipOffset = size;
}

void RandomAccessFile::setVisitTime(time_t time)
{
	this->m_lastVisitTime = time;
}

time_t RandomAccessFile::getVisitTime()
{
	return this->m_lastVisitTime;
}

ssize_t RandomAccessFile::getLength()
{
	return m_fileLength;
}

string RandomAccessFile::getFilename()
{
	return m_filename;
}

const char* RandomAccessFile::getFileData()
{
	return m_fileData;
}