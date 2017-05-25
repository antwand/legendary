#pragma once

#include "RandomAccessFile.h"
#include "Common.h"

class WILReader
{
public:
	~WILReader(void);

	static WILReader*   getInstance();

	vector<MirImageInfo*>	readMirImageInfos(vector<int> idxs, RandomAccessFile* imgeFile, RandomAccessFile* confFile);

	MirImageInfo*			readMirImageInfo(int index, RandomAccessFile* imgeFile, RandomAccessFile* confFile);

	void					setClearNearBlackColor(bool clear);

private:
	WILReader(void);
	static WILReader* m_pInstance;

	MirImageInfo*			read(int position, RandomAccessFile* imgeFile);
	void					readPixels(MirImageInfo* info, RandomAccessFile* imageFile);
	bool					checkBlackColor(int R, int G, int B);

private:
	int						palletes[256][4];
	bool					m_clearNearBlackColor;
	int						colorCount;
	int                     verFlag;
};
