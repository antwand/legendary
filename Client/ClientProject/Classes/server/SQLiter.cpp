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
    //��sqlite���ݿ�
	int ret = sqlite3_open(sqlPath.c_str(), &pSqlite);
	
    //��sqllite���ݿ��ʧ��ʱ
    if (ret != SQLITE_OK)
	{
        //���sqltite���ݿ�򿪴������Ϣ
		const char* errmsg = sqlite3_errmsg(pSqlite);
		
        //��ӡ���ݿ��ʧ�ܵ���Ϣ
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

	//ʧ��ʱ
	if (ret != SQLITE_OK)
	{
		//�õ�����в�������ʧ�ܵ���Ϣ
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
     
	//������в�������ʧ��ʱ
	if (ret != SQLITE_OK)
	{
		//�õ�����в�������ʧ�ܵ���Ϣ
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
	//�ر����ݿ�
	sqlite3_close(pSqlite);
}