#pragma once

#include "cocos2d.h"
using namespace cocos2d;

#include <vector>
using namespace std;

#define byte char
#define segment_size 73417

#ifdef TILE_WIDTH
#else
	#define TILE_WIDTH 48
#endif

#ifdef TILE_HEIGHT
#else
	#define TILE_HEIGHT 32
#endif

class Common
{
public:
	Common(void);
	~Common(void);

	static int				ReadInt(byte bytes[], int index, bool reverse);


	static int				ColorCountToBitCount(int colorCount);


	static void				VectorToArray(vector<int> vec, int* arr);


	static short			ReadShort(const byte bytes[], int index, bool reverse);


	static char*			unzip(char* source,int len, int maxLen);

	static char*            unzipEx(char* source, int len);

	static int		        skipBytes(int bit, int width);
};

class MirImageInfo
{
	/** 图片宽度 */
private :
	short width;
	/** 图片高度 */
	short height;
	/** 图片横向偏移量 */
	short offsetX;
	/** 图片纵向偏移量 */
	short offsetY;
	/** 图片数据在库中起始位置 */
	int dataStart;
	/** 图片数据大小 */
	int dataSize;

	byte* data;
	int   dataLen;

	/** 图片在库中的索引 */
	short index;

public:
	/** 无参构造函数 */
	MirImageInfo();
	~MirImageInfo();

	/** 带全部参数的构造函数 */
	MirImageInfo(short width, short height, short offsetX,
			short offsetY, int dataStart, int dataSize);

	void setData(byte* b);

	byte* getData();

	/** 获取图片宽度 */
	short getWidth();

	/** 设置图片高度 */
	void setWidth(short width);

	/** 获取图片高度 */
	short getHeight();

	/** 设置图片高度 */
	void setHeight(short height);

	/** 获取图片横线偏移量 */
	short getOffsetX();

	/** 设置图片横向偏移量 */
	void setOffsetX(short offsetX);

	/** 获取图片纵向偏移量 */
	short getOffsetY();

	/** 设置图片纵向偏移量 */
	void setOffsetY(short offsetY);

	/** 获取图片数据起始位置 */
	int getDataStart();

	/** 设置图片数据起始位置 */
	void setDataStart(int dataStart);

	/** 获取图片数据大小 */
	int getDataSize();

	/** 设置图片数据大小 */
	void setDataSize(int dataSize);

	/** 获取图片在库中的索引 */
	short getIndex();

	void setIndex(short _index);

	void release();
};
