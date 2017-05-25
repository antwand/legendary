#include "Server.h"
#include "time.h"

long getCurrSystemTime()
{
	/*
	struct timeval tv;
	gettimeofday(&tv, nullptr);

	log("CurrentTime MillSecond %f", (double)tv.tv_sec * 1000 + (double)tv.tv_usec / 1000);

	return (double)tv.tv_sec * 1000 + (double)tv.tv_usec / 1000;
	*/
	auto time = clock();

	return time;
}

string Int2String(int num)
{
	char buf[12];
	return _itoa(num, buf, 10);
}