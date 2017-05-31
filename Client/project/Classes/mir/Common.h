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
	/** ͼƬ��� */
private :
	short width;
	/** ͼƬ�߶� */
	short height;
	/** ͼƬ����ƫ���� */
	short offsetX;
	/** ͼƬ����ƫ���� */
	short offsetY;
	/** ͼƬ�����ڿ�����ʼλ�� */
	int dataStart;
	/** ͼƬ���ݴ�С */
	int dataSize;

	byte* data;
	int   dataLen;

	/** ͼƬ�ڿ��е����� */
	short index;

public:
	/** �޲ι��캯�� */
	MirImageInfo();
	~MirImageInfo();

	/** ��ȫ�������Ĺ��캯�� */
	MirImageInfo(short width, short height, short offsetX,
			short offsetY, int dataStart, int dataSize);

	void setData(byte* b);

	byte* getData();

	/** ��ȡͼƬ��� */
	short getWidth();

	/** ����ͼƬ�߶� */
	void setWidth(short width);

	/** ��ȡͼƬ�߶� */
	short getHeight();

	/** ����ͼƬ�߶� */
	void setHeight(short height);

	/** ��ȡͼƬ����ƫ���� */
	short getOffsetX();

	/** ����ͼƬ����ƫ���� */
	void setOffsetX(short offsetX);

	/** ��ȡͼƬ����ƫ���� */
	short getOffsetY();

	/** ����ͼƬ����ƫ���� */
	void setOffsetY(short offsetY);

	/** ��ȡͼƬ������ʼλ�� */
	int getDataStart();

	/** ����ͼƬ������ʼλ�� */
	void setDataStart(int dataStart);

	/** ��ȡͼƬ���ݴ�С */
	int getDataSize();

	/** ����ͼƬ���ݴ�С */
	void setDataSize(int dataSize);

	/** ��ȡͼƬ�ڿ��е����� */
	short getIndex();

	void setIndex(short _index);

	void release();
};
