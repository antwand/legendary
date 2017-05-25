#pragma once

#include "RandomAccessFile.h"
#include "Common.h"

class WZLReader
{
public:
	~WZLReader(void);

	static WZLReader*   getInstance();

	vector<MirImageInfo*>	readMirImageInfos(vector<int> idxs, RandomAccessFile* imgeFile, RandomAccessFile* confFile);

	MirImageInfo*			readMirImageInfo(int index, RandomAccessFile* imgeFile, RandomAccessFile* confFile);

	void					setClearNearBlackColor(bool clear);

private:
	WZLReader(void);
	static WZLReader* m_pInstance;

	MirImageInfo*			read(int position, RandomAccessFile* imgeFile);
	void					readPixels(MirImageInfo* info, RandomAccessFile* imageFile);
	bool					checkBlackColor(int R, int G, int B);

private:
	int						palletes[256][4];
	bool					m_clearNearBlackColor;
};