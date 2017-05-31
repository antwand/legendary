#include "Common.h"
#include "../external/win32-specific/zlib/include/zlib.h"

Common::Common(void)
{
}


Common::~Common(void)
{
}

short Common::ReadShort(const byte bytes[], int index, bool reverse) 
{
	if(reverse)
		return (short) ((bytes[index + 1] << 8) | (bytes[index] & 0xff));
	else
		return (short) ((bytes[index] << 8) | (bytes[index + 1] & 0xff));
}

int Common::ReadInt(byte bytes[], int index, bool reverse) 
{
	if(reverse)
		return (int) (((bytes[index + 3] & 0xff) << 24)  
	            | ((bytes[index + 2] & 0xff) << 16)  
	            | ((bytes[index + 1] & 0xff) << 8) 
	            | (bytes[index] & 0xff));
	else
		return (int) (((bytes[index] & 0xff) << 24)  
	            | ((bytes[index + 1] & 0xff) << 16)  
	            | ((bytes[index + 2] & 0xff) << 8) 
	            | (bytes[index + 3] & 0xff));
}

int Common::ColorCountToBitCount(int colorCount) 
{
	if(colorCount == 256) return 8;
	else if(colorCount == 65536) return 16;
	else if(colorCount == 16777216) return 24;
	else return 32;
}

void Common::VectorToArray(vector<int> vec, int* arr)
{
	for (int i=0;i<vec.size();++i)
	{
		arr[i] = vec[i];
	}
}

int	Common::skipBytes(int bit, int width)
{
	int bitCount = bit * width;
	
	return ((bitCount + 31) / 32 * 4) - width * (bit / 8);
}

char* Common::unzipEx(char* source, int len)
{
	uLongf uDestBufferLen = 1024000;//�˴�������Ҫ�㹻�������ɽ�ѹ��������
	char* uDestBuffer = (char*)::calloc((uInt)uDestBufferLen, 1);
	//��ѹ��buffer�е�����
	char uSorceBuffer[segment_size * 4] = { 0 };
	errno_t err = uncompress((Bytef*)uDestBuffer, (uLongf*)&uDestBufferLen, (Bytef*)uSorceBuffer, (uLongf)len);

	if (err != Z_OK)
	{
		log("��ѹ��ʧ�ܣ�%d",err);
		return NULL;
	}

	return uDestBuffer;
}

char* Common::unzip(char* source,int len, int maxLen)
{
	int err;
	z_stream d_stream;
	/*
	if (len > segment_size)
		log("need %d cache, but only have %d cache", len, segment_size);
	*/
	Byte *compr = new Byte[maxLen];
	Byte *uncompr = new Byte[maxLen * 4];
	memset(compr, 0, (maxLen) * sizeof(Byte));
	memset(uncompr, 0, (maxLen * 4) * sizeof(Byte));

	//Byte compr[segment_size]={0}, uncompr[segment_size*4]={0};

	/*Byte *compr = new Byte[len+1];
	memset(compr, 0, sizeof(Byte)*(len+1));

	Byte *uncompr = new Byte[(len+1)*4];
	memset(uncompr, 0, sizeof(Byte)*((len+1)*4));
	*/
	memcpy(compr, (Byte*)source, len);
	//int totalSize = sizeof(compr);
	//int size = sizeof(compr[0]);
	uLong comprLen = maxLen;// sizeof(compr) / sizeof(compr[0]);
	uLong uncomprLen = comprLen * 4;// 4 * comprLen;
	strcpy((char*)uncompr, "garbage");

	d_stream.zalloc = (alloc_func)0;
	d_stream.zfree = (free_func)0;
	d_stream.opaque = (voidpf)0;
	d_stream.next_in = compr;
	d_stream.avail_in = 0;
	d_stream.next_out = uncompr;

	err = inflateInit2(&d_stream, MAX_WBITS + 32);
	if (err != Z_OK)
	{
		printf("inflateInit2 error:%d", err);
		return NULL;
	}
	while (d_stream.total_out < uncomprLen && d_stream.total_in < comprLen)
	{
		d_stream.avail_in = d_stream.avail_out = 1;
		err = inflate(&d_stream, Z_NO_FLUSH);
		if (err == Z_STREAM_END) break;
		if (err != Z_OK)
		{
			printf("inflate error:%d", err);
			return NULL;
		}
	}

	err = inflateEnd(&d_stream);
	if (err != Z_OK)
	{
		printf("inflateEnd error:%d", err);
		return NULL;
	}

	//printf("count:%d   d_stream.total_out+1:%d\n", len, d_stream.total_out+1);

	char* b = new char[d_stream.total_out + 1];
	memset(b, 0, d_stream.total_out + 1);
	memcpy(b, (char*)uncompr, d_stream.total_out);

	//printf("count:%d   d_stream.total_out+1:%d\n", len, d_stream.total_out + 1);

	//char* achUncomp = new char[len];
	//uncompress(achUncomp,&nUncompLen, source,len); 

	return b;
}

MirImageInfo::MirImageInfo() 
{
	data = 0;
	width = 0;
	height = 0;
	offsetX = 0;
	offsetY = 0;
	dataStart = 0;
	dataSize = 0;
}

MirImageInfo::~MirImageInfo() 
{
	if (data != 0)
		delete[] data;
}

/** ��ȫ�������Ĺ��캯�� */
MirImageInfo::MirImageInfo(short width, short height, short offsetX,
		short offsetY, int dataStart, int dataSize) {
	this->width = width;
	this->height = height;
	this->offsetX = offsetX;
	this->offsetY = offsetY;
	this->dataStart = dataStart;
	this->dataSize = dataSize;
	this->data = 0;
}

void MirImageInfo::setData(byte* b)
{
	data = b;
}

byte* MirImageInfo::getData()
{
	return data;
}

/** ��ȡͼƬ��� */
short MirImageInfo::getWidth() {
	return width;
}

/** ����ͼƬ�߶� */
void MirImageInfo::setWidth(short width) {
	this->width = width;
}

/** ��ȡͼƬ�߶� */
short MirImageInfo::getHeight() {
	return height;
}

/** ����ͼƬ�߶� */
void MirImageInfo::setHeight(short height) {
	this->height = height;
}

/** ��ȡͼƬ����ƫ���� */
short MirImageInfo::getOffsetX() {
	return offsetX;
}

/** ����ͼƬ����ƫ���� */
void MirImageInfo::setOffsetX(short offsetX) {
	this->offsetX = offsetX;
}

/** ��ȡͼƬ����ƫ���� */
short MirImageInfo::getOffsetY() {
	return offsetY;
}

/** ����ͼƬ����ƫ���� */
void MirImageInfo::setOffsetY(short offsetY) {
	this->offsetY = offsetY;
}

/** ��ȡͼƬ������ʼλ�� */
int MirImageInfo::getDataStart() {
	return this->dataStart;
}

/** ����ͼƬ������ʼλ�� */
void MirImageInfo::setDataStart(int dataStart) {
	this->dataStart = dataStart;
}

/** ��ȡͼƬ���ݴ�С */
int MirImageInfo::getDataSize() {
	return this->dataSize;
}

/** ����ͼƬ���ݴ�С */
void MirImageInfo::setDataSize(int dataSize) {
	this->dataSize = dataSize;
}

/** ��ȡͼƬ�ڿ��е����� */
short MirImageInfo::getIndex() {
	return this->index;
}

void MirImageInfo::setIndex(short _index) {
	this->index = _index;
}

void MirImageInfo::release()
{
	delete[] data;
}