#include "SQLiter.h"
#include "../external/sqlite3/include/sqlite3.h"

#pragma comment (lib,"sqlite3.lib")

SQLiter::SQLiter(void)
{
}


SQLiter::~SQLiter(void)
{
}

bool SQLiter::init()
{
	return true;
}

bool SQLiter::initSql(const char* sqlName)
{
	sqlite3* pSqlite;

	auto sqlPath = FileUtils::getInstance()->fullPathForFilename(sqlName);
    //打开sqlite数据库
	int ret = sqlite3_open(sqlPath.c_str(), &pSqlite);
	
    //当sqllite数据库打开失败时
    if (ret != SQLITE_OK)
	{
        //获得sqltite数据库打开错误的信息
		const char* errmsg = sqlite3_errmsg(pSqlite);
		
        //打印数据库打开失败的信息
        CCLog("sqlite open error: %s", errmsg);
		
        return false;
	}

	m_pSqlite = pSqlite;

	return true;
}

bool SQLiter::open(const char* dbname)
{
	sqlite3* pSqlite = (sqlite3*)m_pSqlite;
	int ret = sqlite3_open(dbname, &pSqlite);

	//失败时
	if (ret != SQLITE_OK)
	{
		//得到向表中插入数据失败的信息
		const char* errmsg = sqlite3_errmsg(pSqlite);

		return false;
	}

	return true;
}

bool SQLiter::exec(const char* execStr)
{
	sqlite3* pSqlite = (sqlite3*)m_pSqlite;
	char* errmsg;
	int ret = sqlite3_exec(pSqlite, execStr, NULL, NULL, &errmsg);
     
	//当向表中插入数据失败时
	if (ret != SQLITE_OK)
	{
		//得到向表中插入数据失败的信息
		const char* errmsg = sqlite3_errmsg(pSqlite);

		return false;
	}

	return true;
}

string SQLiter::getTable(const char* sqlStr)
{
	sqlite3* pSqlite = (sqlite3*)m_pSqlite;

	char** pResult;
	int nRow;
	int nCol;

	int ret = sqlite3_get_table(pSqlite, sqlStr, &pResult, &nRow, &nCol, 0);

	string strOut;
    int nIndex = nCol;
    for(int i=0;i<nRow;i++)
    {
		strOut += "{";

        for(int j=0;j<nCol;j++)
        {
            strOut+=pResult[j];
            strOut+="='";
            strOut+=pResult[nIndex];
            strOut+="',";
            ++nIndex;
        }

		strOut += "},"; 
    }

    sqlite3_free_table(pResult);

	string result = "{" + strOut + "}";
	return result;
}

void SQLiter::close()
{
	sqlite3* pSqlite = (sqlite3*)m_pSqlite;
	//关闭数据库
	sqlite3_close(pSqlite);
}