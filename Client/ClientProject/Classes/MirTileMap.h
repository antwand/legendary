#include "MapTileInfo.h"
#include <vector>

using namespace std;

class MirTileMap : public Layer
{
public:
	MirTileMap(void);
	~MirTileMap(void);

	//初始化
	bool					init();
	CREATE_FUNC(MirTileMap);

	//创建地图数据
	void					showPart(int x, int y, int width, int height);
	void					showPartEx(int row, int col, int endRow, int endCol);
	void					hindPart(int row, int col, int rowCount, int colCount);
	bool					initWithMapFile(const char* filename, const char* loadingFinished);

	MapTileInfo*			getMapTiles();
	MapTileInfo*			getMapTile(int row, int col);
	
	bool					is1AtTopDigit(unsigned char target);
	bool					is1AtTopDigitForShort(short target);
	int						getInitComplete();
	int						getPortalCount();
	Vec2					getPortal(int index);
	
	short					getImgIdx(short param);
	short					readShort(unsigned char* chars, int index, bool reverse);

	void                    setShowTileDetail(bool show);
	void					setWidth(short);
	void					setHeight(short);
	void					setTileSize(short width, short height);
	void					setTileOrder(short bngOrder, short midOrder, short objOrder);
	void					release();

	short					getWidth();
	short					getHeight();

	//
	void                    updateTile(float delta);
	MapTileInfo*			readMapTileData(MapTileInfo* mapTile, unsigned char* data, int resOffset);
	bool					readMapData();
	bool					initMapTileSprite(MapTileInfo* mapTile);

private:
	short					m_width;
	short					m_height;
	short					m_tileWidth;
	short					m_tileHeight;
	MapTileInfo*		    m_pMapTiles;

	//层次
	short					m_bngOrder;
	short					m_midOrder;
	short					m_objOrder;

	//vector<MapTileInfo*>    m_showTileVec;
	vector<int>             m_showTilePointVec;
	vector<Vec2>            m_doorTileVec;
	int                     m_curShowTileCount;
	int                     m_showTileCountPerTime; 
	bool                    m_initComplete;
	bool                    m_showTileDetail;

	string                  m_filename;
	string					m_loadingFinished;
};

