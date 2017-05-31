#include "WZLReader.h"

WZLReader* WZLReader::m_pInstance = 0;

WZLReader::WZLReader(void)
{
	palletes[0][0] = 0;
	palletes[0][1] = 0;
	palletes[0][2] = 0;
	palletes[0][3] = 0;
	palletes[1][0] = -1;
	palletes[1][1] = -128;
	palletes[1][2] = 0;
	palletes[1][3] = 0;
	palletes[2][0] = -1;
	palletes[2][1] = 0;
	palletes[2][2] = -128;
	palletes[2][3] = 0;
	palletes[3][0] = -1;
	palletes[3][1] = -128;
	palletes[3][2] = -128;
	palletes[3][3] = 0;
	palletes[4][0] = -1;
	palletes[4][1] = 0;
	palletes[4][2] = 0;
	palletes[4][3] = -128;
	palletes[5][0] = -1;
	palletes[5][1] = -128;
	palletes[5][2] = 0;
	palletes[5][3] = -128;
	palletes[6][0] = -1;
	palletes[6][1] = 0;
	palletes[6][2] = -128;
	palletes[6][3] = -128;
	palletes[7][0] = -1;
	palletes[7][1] = -64;
	palletes[7][2] = -64;
	palletes[7][3] = -64;
	palletes[8][0] = -1;
	palletes[8][1] = 85;
	palletes[8][2] = -128;
	palletes[8][3] = -105;
	palletes[9][0] = -1;
	palletes[9][1] = -99;
	palletes[9][2] = -71;
	palletes[9][3] = -56;
	palletes[10][0] = -1;
	palletes[10][1] = 123;
	palletes[10][2] = 115;
	palletes[10][3] = 115;
	palletes[11][0] = -1;
	palletes[11][1] = 45;
	palletes[11][2] = 41;
	palletes[11][3] = 41;
	palletes[12][0] = -1;
	palletes[12][1] = 90;
	palletes[12][2] = 82;
	palletes[12][3] = 82;
	palletes[13][0] = -1;
	palletes[13][1] = 99;
	palletes[13][2] = 90;
	palletes[13][3] = 90;
	palletes[14][0] = -1;
	palletes[14][1] = 66;
	palletes[14][2] = 57;
	palletes[14][3] = 57;
	palletes[15][0] = -1;
	palletes[15][1] = 29;
	palletes[15][2] = 24;
	palletes[15][3] = 24;
	palletes[16][0] = -1;
	palletes[16][1] = 24;
	palletes[16][2] = 16;
	palletes[16][3] = 16;
	palletes[17][0] = -1;
	palletes[17][1] = 41;
	palletes[17][2] = 24;
	palletes[17][3] = 24;
	palletes[18][0] = -1;
	palletes[18][1] = 16;
	palletes[18][2] = 8;
	palletes[18][3] = 8;
	palletes[19][0] = -1;
	palletes[19][1] = -14;
	palletes[19][2] = 121;
	palletes[19][3] = 113;
	palletes[20][0] = -1;
	palletes[20][1] = -31;
	palletes[20][2] = 103;
	palletes[20][3] = 95;
	palletes[21][0] = -1;
	palletes[21][1] = -1;
	palletes[21][2] = 90;
	palletes[21][3] = 90;
	palletes[22][0] = -1;
	palletes[22][1] = -1;
	palletes[22][2] = 49;
	palletes[22][3] = 49;
	palletes[23][0] = -1;
	palletes[23][1] = -42;
	palletes[23][2] = 90;
	palletes[23][3] = 82;
	palletes[24][0] = -1;
	palletes[24][1] = -108;
	palletes[24][2] = 16;
	palletes[24][3] = 0;
	palletes[25][0] = -1;
	palletes[25][1] = -108;
	palletes[25][2] = 41;
	palletes[25][3] = 24;
	palletes[26][0] = -1;
	palletes[26][1] = 57;
	palletes[26][2] = 8;
	palletes[26][3] = 0;
	palletes[27][0] = -1;
	palletes[27][1] = 115;
	palletes[27][2] = 16;
	palletes[27][3] = 0;
	palletes[28][0] = -1;
	palletes[28][1] = -75;
	palletes[28][2] = 24;
	palletes[28][3] = 0;
	palletes[29][0] = -1;
	palletes[29][1] = -67;
	palletes[29][2] = 99;
	palletes[29][3] = 82;
	palletes[30][0] = -1;
	palletes[30][1] = 66;
	palletes[30][2] = 24;
	palletes[30][3] = 16;
	palletes[31][0] = -1;
	palletes[31][1] = -1;
	palletes[31][2] = -86;
	palletes[31][3] = -103;
	palletes[32][0] = -1;
	palletes[32][1] = 90;
	palletes[32][2] = 16;
	palletes[32][3] = 0;
	palletes[33][0] = -1;
	palletes[33][1] = 115;
	palletes[33][2] = 57;
	palletes[33][3] = 41;
	palletes[34][0] = -1;
	palletes[34][1] = -91;
	palletes[34][2] = 74;
	palletes[34][3] = 49;
	palletes[35][0] = -1;
	palletes[35][1] = -108;
	palletes[35][2] = 123;
	palletes[35][3] = 115;
	palletes[36][0] = -1;
	palletes[36][1] = -67;
	palletes[36][2] = 82;
	palletes[36][3] = 49;
	palletes[37][0] = -1;
	palletes[37][1] = 82;
	palletes[37][2] = 33;
	palletes[37][3] = 16;
	palletes[38][0] = -1;
	palletes[38][1] = 123;
	palletes[38][2] = 49;
	palletes[38][3] = 24;
	palletes[39][0] = -1;
	palletes[39][1] = 45;
	palletes[39][2] = 24;
	palletes[39][3] = 16;
	palletes[40][0] = -1;
	palletes[40][1] = -116;
	palletes[40][2] = 74;
	palletes[40][3] = 49;
	palletes[41][0] = -1;
	palletes[41][1] = -108;
	palletes[41][2] = 41;
	palletes[41][3] = 0;
	palletes[42][0] = -1;
	palletes[42][1] = -67;
	palletes[42][2] = 49;
	palletes[42][3] = 0;
	palletes[43][0] = -1;
	palletes[43][1] = -58;
	palletes[43][2] = 115;
	palletes[43][3] = 82;
	palletes[44][0] = -1;
	palletes[44][1] = 107;
	palletes[44][2] = 49;
	palletes[44][3] = 24;
	palletes[45][0] = -1;
	palletes[45][1] = -58;
	palletes[45][2] = 107;
	palletes[45][3] = 66;
	palletes[46][0] = -1;
	palletes[46][1] = -50;
	palletes[46][2] = 74;
	palletes[46][3] = 0;
	palletes[47][0] = -1;
	palletes[47][1] = -91;
	palletes[47][2] = 99;
	palletes[47][3] = 57;
	palletes[48][0] = -1;
	palletes[48][1] = 90;
	palletes[48][2] = 49;
	palletes[48][3] = 24;
	palletes[49][0] = -1;
	palletes[49][1] = 42;
	palletes[49][2] = 16;
	palletes[49][3] = 0;
	palletes[50][0] = -1;
	palletes[50][1] = 21;
	palletes[50][2] = 8;
	palletes[50][3] = 0;
	palletes[51][0] = -1;
	palletes[51][1] = 58;
	palletes[51][2] = 24;
	palletes[51][3] = 0;
	palletes[52][0] = -1;
	palletes[52][1] = 8;
	palletes[52][2] = 0;
	palletes[52][3] = 0;
	palletes[53][0] = -1;
	palletes[53][1] = 41;
	palletes[53][2] = 0;
	palletes[53][3] = 0;
	palletes[54][0] = -1;
	palletes[54][1] = 74;
	palletes[54][2] = 0;
	palletes[54][3] = 0;
	palletes[55][0] = -1;
	palletes[55][1] = -99;
	palletes[55][2] = 0;
	palletes[55][3] = 0;
	palletes[56][0] = -1;
	palletes[56][1] = -36;
	palletes[56][2] = 0;
	palletes[56][3] = 0;
	palletes[57][0] = -1;
	palletes[57][1] = -34;
	palletes[57][2] = 0;
	palletes[57][3] = 0;
	palletes[58][0] = -1;
	palletes[58][1] = -5;
	palletes[58][2] = 0;
	palletes[58][3] = 0;
	palletes[59][0] = -1;
	palletes[59][1] = -100;
	palletes[59][2] = 115;
	palletes[59][3] = 82;
	palletes[60][0] = -1;
	palletes[60][1] = -108;
	palletes[60][2] = 107;
	palletes[60][3] = 74;
	palletes[61][0] = -1;
	palletes[61][1] = 115;
	palletes[61][2] = 74;
	palletes[61][3] = 41;
	palletes[62][0] = -1;
	palletes[62][1] = 82;
	palletes[62][2] = 49;
	palletes[62][3] = 24;
	palletes[63][0] = -1;
	palletes[63][1] = -116;
	palletes[63][2] = 74;
	palletes[63][3] = 24;
	palletes[64][0] = -1;
	palletes[64][1] = -120;
	palletes[64][2] = 68;
	palletes[64][3] = 17;
	palletes[65][0] = -1;
	palletes[65][1] = 74;
	palletes[65][2] = 33;
	palletes[65][3] = 0;
	palletes[66][0] = -1;
	palletes[66][1] = 33;
	palletes[66][2] = 24;
	palletes[66][3] = 16;
	palletes[67][0] = -1;
	palletes[67][1] = -42;
	palletes[67][2] = -108;
	palletes[67][3] = 90;
	palletes[68][0] = -1;
	palletes[68][1] = -58;
	palletes[68][2] = 107;
	palletes[68][3] = 33;
	palletes[69][0] = -1;
	palletes[69][1] = -17;
	palletes[69][2] = 107;
	palletes[69][3] = 0;
	palletes[70][0] = -1;
	palletes[70][1] = -1;
	palletes[70][2] = 119;
	palletes[70][3] = 0;
	palletes[71][0] = -1;
	palletes[71][1] = -91;
	palletes[71][2] = -108;
	palletes[71][3] = -124;
	palletes[72][0] = -1;
	palletes[72][1] = 66;
	palletes[72][2] = 49;
	palletes[72][3] = 33;
	palletes[73][0] = -1;
	palletes[73][1] = 24;
	palletes[73][2] = 16;
	palletes[73][3] = 8;
	palletes[74][0] = -1;
	palletes[74][1] = 41;
	palletes[74][2] = 24;
	palletes[74][3] = 8;
	palletes[75][0] = -1;
	palletes[75][1] = 33;
	palletes[75][2] = 16;
	palletes[75][3] = 0;
	palletes[76][0] = -1;
	palletes[76][1] = 57;
	palletes[76][2] = 41;
	palletes[76][3] = 24;
	palletes[77][0] = -1;
	palletes[77][1] = -116;
	palletes[77][2] = 99;
	palletes[77][3] = 57;
	palletes[78][0] = -1;
	palletes[78][1] = 66;
	palletes[78][2] = 41;
	palletes[78][3] = 16;
	palletes[79][0] = -1;
	palletes[79][1] = 107;
	palletes[79][2] = 66;
	palletes[79][3] = 24;
	palletes[80][0] = -1;
	palletes[80][1] = 123;
	palletes[80][2] = 74;
	palletes[80][3] = 24;
	palletes[81][0] = -1;
	palletes[81][1] = -108;
	palletes[81][2] = 74;
	palletes[81][3] = 0;
	palletes[82][0] = -1;
	palletes[82][1] = -116;
	palletes[82][2] = -124;
	palletes[82][3] = 123;
	palletes[83][0] = -1;
	palletes[83][1] = 107;
	palletes[83][2] = 99;
	palletes[83][3] = 90;
	palletes[84][0] = -1;
	palletes[84][1] = 74;
	palletes[84][2] = 66;
	palletes[84][3] = 57;
	palletes[85][0] = -1;
	palletes[85][1] = 41;
	palletes[85][2] = 33;
	palletes[85][3] = 24;
	palletes[86][0] = -1;
	palletes[86][1] = 70;
	palletes[86][2] = 57;
	palletes[86][3] = 41;
	palletes[87][0] = -1;
	palletes[87][1] = -75;
	palletes[87][2] = -91;
	palletes[87][3] = -108;
	palletes[88][0] = -1;
	palletes[88][1] = 123;
	palletes[88][2] = 107;
	palletes[88][3] = 90;
	palletes[89][0] = -1;
	palletes[89][1] = -50;
	palletes[89][2] = -79;
	palletes[89][3] = -108;
	palletes[90][0] = -1;
	palletes[90][1] = -91;
	palletes[90][2] = -116;
	palletes[90][3] = 115;
	palletes[91][0] = -1;
	palletes[91][1] = -116;
	palletes[91][2] = 115;
	palletes[91][3] = 90;
	palletes[92][0] = -1;
	palletes[92][1] = -75;
	palletes[92][2] = -108;
	palletes[92][3] = 115;
	palletes[93][0] = -1;
	palletes[93][1] = -42;
	palletes[93][2] = -91;
	palletes[93][3] = 115;
	palletes[94][0] = -1;
	palletes[94][1] = -17;
	palletes[94][2] = -91;
	palletes[94][3] = 74;
	palletes[95][0] = -1;
	palletes[95][1] = -17;
	palletes[95][2] = -58;
	palletes[95][3] = -116;
	palletes[96][0] = -1;
	palletes[96][1] = 123;
	palletes[96][2] = 99;
	palletes[96][3] = 66;
	palletes[97][0] = -1;
	palletes[97][1] = 107;
	palletes[97][2] = 86;
	palletes[97][3] = 57;
	palletes[98][0] = -1;
	palletes[98][1] = -67;
	palletes[98][2] = -108;
	palletes[98][3] = 90;
	palletes[99][0] = -1;
	palletes[99][1] = 99;
	palletes[99][2] = 57;
	palletes[99][3] = 0;
	palletes[100][0] = -1;
	palletes[100][1] = -42;
	palletes[100][2] = -58;
	palletes[100][3] = -83;
	palletes[101][0] = -1;
	palletes[101][1] = 82;
	palletes[101][2] = 66;
	palletes[101][3] = 41;
	palletes[102][0] = -1;
	palletes[102][1] = -108;
	palletes[102][2] = 99;
	palletes[102][3] = 24;
	palletes[103][0] = -1;
	palletes[103][1] = -17;
	palletes[103][2] = -42;
	palletes[103][3] = -83;
	palletes[104][0] = -1;
	palletes[104][1] = -91;
	palletes[104][2] = -116;
	palletes[104][3] = 99;
	palletes[105][0] = -1;
	palletes[105][1] = 99;
	palletes[105][2] = 90;
	palletes[105][3] = 74;
	palletes[106][0] = -1;
	palletes[106][1] = -67;
	palletes[106][2] = -91;
	palletes[106][3] = 123;
	palletes[107][0] = -1;
	palletes[107][1] = 90;
	palletes[107][2] = 66;
	palletes[107][3] = 24;
	palletes[108][0] = -1;
	palletes[108][1] = -67;
	palletes[108][2] = -116;
	palletes[108][3] = 49;
	palletes[109][0] = -1;
	palletes[109][1] = 53;
	palletes[109][2] = 49;
	palletes[109][3] = 41;
	palletes[110][0] = -1;
	palletes[110][1] = -108;
	palletes[110][2] = -124;
	palletes[110][3] = 99;
	palletes[111][0] = -1;
	palletes[111][1] = 123;
	palletes[111][2] = 107;
	palletes[111][3] = 74;
	palletes[112][0] = -1;
	palletes[112][1] = -91;
	palletes[112][2] = -116;
	palletes[112][3] = 90;
	palletes[113][0] = -1;
	palletes[113][1] = 90;
	palletes[113][2] = 74;
	palletes[113][3] = 41;
	palletes[114][0] = -1;
	palletes[114][1] = -100;
	palletes[114][2] = 123;
	palletes[114][3] = 57;
	palletes[115][0] = -1;
	palletes[115][1] = 66;
	palletes[115][2] = 49;
	palletes[115][3] = 16;
	palletes[116][0] = -1;
	palletes[116][1] = -17;
	palletes[116][2] = -83;
	palletes[116][3] = 33;
	palletes[117][0] = -1;
	palletes[117][1] = 24;
	palletes[117][2] = 16;
	palletes[117][3] = 0;
	palletes[118][0] = -1;
	palletes[118][1] = 41;
	palletes[118][2] = 33;
	palletes[118][3] = 0;
	palletes[119][0] = -1;
	palletes[119][1] = -100;
	palletes[119][2] = 107;
	palletes[119][3] = 0;
	palletes[120][0] = -1;
	palletes[120][1] = -108;
	palletes[120][2] = -124;
	palletes[120][3] = 90;
	palletes[121][0] = -1;
	palletes[121][1] = 82;
	palletes[121][2] = 66;
	palletes[121][3] = 24;
	palletes[122][0] = -1;
	palletes[122][1] = 107;
	palletes[122][2] = 90;
	palletes[122][3] = 41;
	palletes[123][0] = -1;
	palletes[123][1] = 123;
	palletes[123][2] = 99;
	palletes[123][3] = 33;
	palletes[124][0] = -1;
	palletes[124][1] = -100;
	palletes[124][2] = 123;
	palletes[124][3] = 33;
	palletes[125][0] = -1;
	palletes[125][1] = -34;
	palletes[125][2] = -91;
	palletes[125][3] = 0;
	palletes[126][0] = -1;
	palletes[126][1] = 90;
	palletes[126][2] = 82;
	palletes[126][3] = 57;
	palletes[127][0] = -1;
	palletes[127][1] = 49;
	palletes[127][2] = 41;
	palletes[127][3] = 16;
	palletes[128][0] = -1;
	palletes[128][1] = -50;
	palletes[128][2] = -67;
	palletes[128][3] = 123;
	palletes[129][0] = -1;
	palletes[129][1] = 99;
	palletes[129][2] = 90;
	palletes[129][3] = 57;
	palletes[130][0] = -1;
	palletes[130][1] = -108;
	palletes[130][2] = -124;
	palletes[130][3] = 74;
	palletes[131][0] = -1;
	palletes[131][1] = -58;
	palletes[131][2] = -91;
	palletes[131][3] = 41;
	palletes[132][0] = -1;
	palletes[132][1] = 16;
	palletes[132][2] = -100;
	palletes[132][3] = 24;
	palletes[133][0] = -1;
	palletes[133][1] = 66;
	palletes[133][2] = -116;
	palletes[133][3] = 74;
	palletes[134][0] = -1;
	palletes[134][1] = 49;
	palletes[134][2] = -116;
	palletes[134][3] = 66;
	palletes[135][0] = -1;
	palletes[135][1] = 16;
	palletes[135][2] = -108;
	palletes[135][3] = 41;
	palletes[136][0] = -1;
	palletes[136][1] = 8;
	palletes[136][2] = 24;
	palletes[136][3] = 16;
	palletes[137][0] = -1;
	palletes[137][1] = 8;
	palletes[137][2] = 24;
	palletes[137][3] = 24;
	palletes[138][0] = -1;
	palletes[138][1] = 8;
	palletes[138][2] = 41;
	palletes[138][3] = 16;
	palletes[139][0] = -1;
	palletes[139][1] = 24;
	palletes[139][2] = 66;
	palletes[139][3] = 41;
	palletes[140][0] = -1;
	palletes[140][1] = -91;
	palletes[140][2] = -75;
	palletes[140][3] = -83;
	palletes[141][0] = -1;
	palletes[141][1] = 107;
	palletes[141][2] = 115;
	palletes[141][3] = 115;
	palletes[142][0] = -1;
	palletes[142][1] = 24;
	palletes[142][2] = 41;
	palletes[142][3] = 41;
	palletes[143][0] = -1;
	palletes[143][1] = 24;
	palletes[143][2] = 66;
	palletes[143][3] = 74;
	palletes[144][0] = -1;
	palletes[144][1] = 49;
	palletes[144][2] = 66;
	palletes[144][3] = 74;
	palletes[145][0] = -1;
	palletes[145][1] = 99;
	palletes[145][2] = -58;
	palletes[145][3] = -34;
	palletes[146][0] = -1;
	palletes[146][1] = 68;
	palletes[146][2] = -35;
	palletes[146][3] = -1;
	palletes[147][0] = -1;
	palletes[147][1] = -116;
	palletes[147][2] = -42;
	palletes[147][3] = -17;
	palletes[148][0] = -1;
	palletes[148][1] = 115;
	palletes[148][2] = 107;
	palletes[148][3] = 57;
	palletes[149][0] = -1;
	palletes[149][1] = -9;
	palletes[149][2] = -34;
	palletes[149][3] = 57;
	palletes[150][0] = -1;
	palletes[150][1] = -9;
	palletes[150][2] = -17;
	palletes[150][3] = -116;
	palletes[151][0] = -1;
	palletes[151][1] = -9;
	palletes[151][2] = -25;
	palletes[151][3] = 0;
	palletes[152][0] = -1;
	palletes[152][1] = 107;
	palletes[152][2] = 107;
	palletes[152][3] = 90;
	palletes[153][0] = -1;
	palletes[153][1] = 90;
	palletes[153][2] = -116;
	palletes[153][3] = -91;
	palletes[154][0] = -1;
	palletes[154][1] = 57;
	palletes[154][2] = -75;
	palletes[154][3] = -17;
	palletes[155][0] = -1;
	palletes[155][1] = 74;
	palletes[155][2] = -100;
	palletes[155][3] = -50;
	palletes[156][0] = -1;
	palletes[156][1] = 49;
	palletes[156][2] = -124;
	palletes[156][3] = -75;
	palletes[157][0] = -1;
	palletes[157][1] = 49;
	palletes[157][2] = 82;
	palletes[157][3] = 107;
	palletes[158][0] = -1;
	palletes[158][1] = -34;
	palletes[158][2] = -34;
	palletes[158][3] = -42;
	palletes[159][0] = -1;
	palletes[159][1] = -67;
	palletes[159][2] = -67;
	palletes[159][3] = -75;
	palletes[160][0] = -1;
	palletes[160][1] = -116;
	palletes[160][2] = -116;
	palletes[160][3] = -124;
	palletes[161][0] = -1;
	palletes[161][1] = -9;
	palletes[161][2] = -9;
	palletes[161][3] = -34;
	palletes[162][0] = -1;
	palletes[162][1] = 0;
	palletes[162][2] = 8;
	palletes[162][3] = 24;
	palletes[163][0] = -1;
	palletes[163][1] = 8;
	palletes[163][2] = 24;
	palletes[163][3] = 57;
	palletes[164][0] = -1;
	palletes[164][1] = 8;
	palletes[164][2] = 16;
	palletes[164][3] = 41;
	palletes[165][0] = -1;
	palletes[165][1] = 8;
	palletes[165][2] = 24;
	palletes[165][3] = 0;
	palletes[166][0] = -1;
	palletes[166][1] = 8;
	palletes[166][2] = 41;
	palletes[166][3] = 0;
	palletes[167][0] = -1;
	palletes[167][1] = 0;
	palletes[167][2] = 82;
	palletes[167][3] = -91;
	palletes[168][0] = -1;
	palletes[168][1] = 0;
	palletes[168][2] = 123;
	palletes[168][3] = -34;
	palletes[169][0] = -1;
	palletes[169][1] = 16;
	palletes[169][2] = 41;
	palletes[169][3] = 74;
	palletes[170][0] = -1;
	palletes[170][1] = 16;
	palletes[170][2] = 57;
	palletes[170][3] = 107;
	palletes[171][0] = -1;
	palletes[171][1] = 16;
	palletes[171][2] = 82;
	palletes[171][3] = -116;
	palletes[172][0] = -1;
	palletes[172][1] = 33;
	palletes[172][2] = 90;
	palletes[172][3] = -91;
	palletes[173][0] = -1;
	palletes[173][1] = 16;
	palletes[173][2] = 49;
	palletes[173][3] = 90;
	palletes[174][0] = -1;
	palletes[174][1] = 16;
	palletes[174][2] = 66;
	palletes[174][3] = -124;
	palletes[175][0] = -1;
	palletes[175][1] = 49;
	palletes[175][2] = 82;
	palletes[175][3] = -124;
	palletes[176][0] = -1;
	palletes[176][1] = 24;
	palletes[176][2] = 33;
	palletes[176][3] = 49;
	palletes[177][0] = -1;
	palletes[177][1] = 74;
	palletes[177][2] = 90;
	palletes[177][3] = 123;
	palletes[178][0] = -1;
	palletes[178][1] = 82;
	palletes[178][2] = 107;
	palletes[178][3] = -91;
	palletes[179][0] = -1;
	palletes[179][1] = 41;
	palletes[179][2] = 57;
	palletes[179][3] = 99;
	palletes[180][0] = -1;
	palletes[180][1] = 16;
	palletes[180][2] = 74;
	palletes[180][3] = -34;
	palletes[181][0] = -1;
	palletes[181][1] = 41;
	palletes[181][2] = 41;
	palletes[181][3] = 33;
	palletes[182][0] = -1;
	palletes[182][1] = 74;
	palletes[182][2] = 74;
	palletes[182][3] = 57;
	palletes[183][0] = -1;
	palletes[183][1] = 41;
	palletes[183][2] = 41;
	palletes[183][3] = 24;
	palletes[184][0] = -1;
	palletes[184][1] = 74;
	palletes[184][2] = 74;
	palletes[184][3] = 41;
	palletes[185][0] = -1;
	palletes[185][1] = 123;
	palletes[185][2] = 123;
	palletes[185][3] = 66;
	palletes[186][0] = -1;
	palletes[186][1] = -100;
	palletes[186][2] = -100;
	palletes[186][3] = 74;
	palletes[187][0] = -1;
	palletes[187][1] = 90;
	palletes[187][2] = 90;
	palletes[187][3] = 41;
	palletes[188][0] = -1;
	palletes[188][1] = 66;
	palletes[188][2] = 66;
	palletes[188][3] = 20;
	palletes[189][0] = -1;
	palletes[189][1] = 57;
	palletes[189][2] = 57;
	palletes[189][3] = 0;
	palletes[190][0] = -1;
	palletes[190][1] = 89;
	palletes[190][2] = 89;
	palletes[190][3] = 0;
	palletes[191][0] = -1;
	palletes[191][1] = -54;
	palletes[191][2] = 53;
	palletes[191][3] = 44;
	palletes[192][0] = -1;
	palletes[192][1] = 107;
	palletes[192][2] = 115;
	palletes[192][3] = 33;
	palletes[193][0] = -1;
	palletes[193][1] = 41;
	palletes[193][2] = 49;
	palletes[193][3] = 0;
	palletes[194][0] = -1;
	palletes[194][1] = 49;
	palletes[194][2] = 57;
	palletes[194][3] = 16;
	palletes[195][0] = -1;
	palletes[195][1] = 49;
	palletes[195][2] = 57;
	palletes[195][3] = 24;
	palletes[196][0] = -1;
	palletes[196][1] = 66;
	palletes[196][2] = 74;
	palletes[196][3] = 0;
	palletes[197][0] = -1;
	palletes[197][1] = 82;
	palletes[197][2] = 99;
	palletes[197][3] = 24;
	palletes[198][0] = -1;
	palletes[198][1] = 90;
	palletes[198][2] = 115;
	palletes[198][3] = 41;
	palletes[199][0] = -1;
	palletes[199][1] = 49;
	palletes[199][2] = 74;
	palletes[199][3] = 24;
	palletes[200][0] = -1;
	palletes[200][1] = 24;
	palletes[200][2] = 33;
	palletes[200][3] = 0;
	palletes[201][0] = -1;
	palletes[201][1] = 24;
	palletes[201][2] = 49;
	palletes[201][3] = 0;
	palletes[202][0] = -1;
	palletes[202][1] = 24;
	palletes[202][2] = 57;
	palletes[202][3] = 16;
	palletes[203][0] = -1;
	palletes[203][1] = 99;
	palletes[203][2] = -124;
	palletes[203][3] = 74;
	palletes[204][0] = -1;
	palletes[204][1] = 107;
	palletes[204][2] = -67;
	palletes[204][3] = 74;
	palletes[205][0] = -1;
	palletes[205][1] = 99;
	palletes[205][2] = -75;
	palletes[205][3] = 74;
	palletes[206][0] = -1;
	palletes[206][1] = 99;
	palletes[206][2] = -67;
	palletes[206][3] = 74;
	palletes[207][0] = -1;
	palletes[207][1] = 90;
	palletes[207][2] = -100;
	palletes[207][3] = 74;
	palletes[208][0] = -1;
	palletes[208][1] = 74;
	palletes[208][2] = -116;
	palletes[208][3] = 57;
	palletes[209][0] = -1;
	palletes[209][1] = 99;
	palletes[209][2] = -58;
	palletes[209][3] = 74;
	palletes[210][0] = -1;
	palletes[210][1] = 99;
	palletes[210][2] = -42;
	palletes[210][3] = 74;
	palletes[211][0] = -1;
	palletes[211][1] = 82;
	palletes[211][2] = -124;
	palletes[211][3] = 74;
	palletes[212][0] = -1;
	palletes[212][1] = 49;
	palletes[212][2] = 115;
	palletes[212][3] = 41;
	palletes[213][0] = -1;
	palletes[213][1] = 99;
	palletes[213][2] = -58;
	palletes[213][3] = 90;
	palletes[214][0] = -1;
	palletes[214][1] = 82;
	palletes[214][2] = -67;
	palletes[214][3] = 74;
	palletes[215][0] = -1;
	palletes[215][1] = 16;
	palletes[215][2] = -1;
	palletes[215][3] = 0;
	palletes[216][0] = -1;
	palletes[216][1] = 24;
	palletes[216][2] = 41;
	palletes[216][3] = 24;
	palletes[217][0] = -1;
	palletes[217][1] = 74;
	palletes[217][2] = -120;
	palletes[217][3] = 74;
	palletes[218][0] = -1;
	palletes[218][1] = 74;
	palletes[218][2] = -25;
	palletes[218][3] = 74;
	palletes[219][0] = -1;
	palletes[219][1] = 0;
	palletes[219][2] = 90;
	palletes[219][3] = 0;
	palletes[220][0] = -1;
	palletes[220][1] = 0;
	palletes[220][2] = -120;
	palletes[220][3] = 0;
	palletes[221][0] = -1;
	palletes[221][1] = 0;
	palletes[221][2] = -108;
	palletes[221][3] = 0;
	palletes[222][0] = -1;
	palletes[222][1] = 0;
	palletes[222][2] = -34;
	palletes[222][3] = 0;
	palletes[223][0] = -1;
	palletes[223][1] = 0;
	palletes[223][2] = -18;
	palletes[223][3] = 0;
	palletes[224][0] = -1;
	palletes[224][1] = 0;
	palletes[224][2] = -5;
	palletes[224][3] = 0;
	palletes[225][0] = -1;
	palletes[225][1] = 74;
	palletes[225][2] = 90;
	palletes[225][3] = -108;
	palletes[226][0] = -1;
	palletes[226][1] = 99;
	palletes[226][2] = 115;
	palletes[226][3] = -75;
	palletes[227][0] = -1;
	palletes[227][1] = 123;
	palletes[227][2] = -116;
	palletes[227][3] = -42;
	palletes[228][0] = -1;
	palletes[228][1] = 107;
	palletes[228][2] = 123;
	palletes[228][3] = -42;
	palletes[229][0] = -1;
	palletes[229][1] = 119;
	palletes[229][2] = -120;
	palletes[229][3] = -1;
	palletes[230][0] = -1;
	palletes[230][1] = -58;
	palletes[230][2] = -58;
	palletes[230][3] = -50;
	palletes[231][0] = -1;
	palletes[231][1] = -108;
	palletes[231][2] = -108;
	palletes[231][3] = -100;
	palletes[232][0] = -1;
	palletes[232][1] = -100;
	palletes[232][2] = -108;
	palletes[232][3] = -58;
	palletes[233][0] = -1;
	palletes[233][1] = 49;
	palletes[233][2] = 49;
	palletes[233][3] = 57;
	palletes[234][0] = -1;
	palletes[234][1] = 41;
	palletes[234][2] = 24;
	palletes[234][3] = -124;
	palletes[235][0] = -1;
	palletes[235][1] = 24;
	palletes[235][2] = 0;
	palletes[235][3] = -124;
	palletes[236][0] = -1;
	palletes[236][1] = 74;
	palletes[236][2] = 66;
	palletes[236][3] = 82;
	palletes[237][0] = -1;
	palletes[237][1] = 82;
	palletes[237][2] = 66;
	palletes[237][3] = 123;
	palletes[238][0] = -1;
	palletes[238][1] = 99;
	palletes[238][2] = 90;
	palletes[238][3] = 115;
	palletes[239][0] = -1;
	palletes[239][1] = -50;
	palletes[239][2] = -75;
	palletes[239][3] = -9;
	palletes[240][0] = -1;
	palletes[240][1] = -116;
	palletes[240][2] = 123;
	palletes[240][3] = -100;
	palletes[241][0] = -1;
	palletes[241][1] = 119;
	palletes[241][2] = 34;
	palletes[241][3] = -52;
	palletes[242][0] = -1;
	palletes[242][1] = -35;
	palletes[242][2] = -86;
	palletes[242][3] = -1;
	palletes[243][0] = -1;
	palletes[243][1] = -16;
	palletes[243][2] = -76;
	palletes[243][3] = 42;
	palletes[244][0] = -1;
	palletes[244][1] = -33;
	palletes[244][2] = 0;
	palletes[244][3] = -97;
	palletes[245][0] = -1;
	palletes[245][1] = -29;
	palletes[245][2] = 23;
	palletes[245][3] = -77;
	palletes[246][0] = -1;
	palletes[246][1] = -1;
	palletes[246][2] = -5;
	palletes[246][3] = -16;
	palletes[247][0] = -1;
	palletes[247][1] = -96;
	palletes[247][2] = -96;
	palletes[247][3] = -92;
	palletes[248][0] = -1;
	palletes[248][1] = -128;
	palletes[248][2] = -128;
	palletes[248][3] = -128;
	palletes[249][0] = -1;
	palletes[249][1] = -1;
	palletes[249][2] = 0;
	palletes[249][3] = 0;
	palletes[250][0] = -1;
	palletes[250][1] = 0;
	palletes[250][2] = -1;
	palletes[250][3] = 0;
	palletes[251][0] = -1;
	palletes[251][1] = -1;
	palletes[251][2] = -1;
	palletes[251][3] = 0;
	palletes[252][0] = -1;
	palletes[252][1] = 0;
	palletes[252][2] = 0;
	palletes[252][3] = -1;
	palletes[253][0] = -1;
	palletes[253][1] = -1;
	palletes[253][2] = 0;
	palletes[253][3] = -1;
	palletes[254][0] = -1;
	palletes[254][1] = 0;
	palletes[254][2] = -1;
	palletes[254][3] = -1;
	palletes[255][0] = -1;
	palletes[255][1] = -1;
	palletes[255][2] = -1;
	palletes[255][3] = -1;

	m_clearNearBlackColor = false;
}


WZLReader::~WZLReader(void)
{
}

WZLReader* WZLReader::getInstance()
{
	if (m_pInstance == 0)
		m_pInstance = new WZLReader();

	return m_pInstance;
}

vector<MirImageInfo*> WZLReader::readMirImageInfos(vector<int> idxs, 
											 RandomAccessFile* imageFile, 
											 RandomAccessFile* confFile)
{
	//vector<MirImageInfo*> wilImages;
	byte* bytesInt = new byte[4];

	// 读取wzx
	confFile->skipBytes(44); // 跳过标题
	confFile->read(bytesInt);

	int indexCount = Common::ReadInt(bytesInt, 0, true);

	vector<int> l_offsets;
	vector<int> lengths;
	vector<int> positions;
	
	// 读取特定图片
	int* a_offsets = new int[idxs.size()];
	int* b_offsets = new int[idxs.size()]; // 为了获取图片数据长度，读取下一个图片数据起始位置相减
	for (int i = 0; i < idxs.size(); ++i) {
		int position = idxs[i] * 4 + 48; // 跳过索引前图片/标题/图片数

		confFile->seek(position);
		confFile->read(bytesInt);
		a_offsets[i] = Common::ReadInt(bytesInt, 0, true);
		if(idxs[i] == indexCount - 1) {
			b_offsets[i] = (int) imageFile->getLength();
		} else {
			confFile->read(bytesInt);
			b_offsets[i] = Common::ReadInt(bytesInt, 0, true);
		}
	}
	for (int i = 0; i < idxs.size(); ++i) {
		l_offsets.push_back(a_offsets[i]);
		lengths.push_back(b_offsets[i] - a_offsets[i]);
		positions.push_back(i);
	}

	// 读取imgeinfo
	vector<MirImageInfo*> MirImageInfos;
	for (int i = 0; i < idxs.size(); ++i) {
		MirImageInfo* MirImageInfo = read(l_offsets[i], imageFile);
		MirImageInfo->setIndex((short)positions[i]);
		MirImageInfo->setDataStart(l_offsets[i]);
		MirImageInfo->setDataSize(lengths[i]);

		MirImageInfos.push_back(MirImageInfo);
	}

 	return MirImageInfos;
}

MirImageInfo*  WZLReader::readMirImageInfo(int index, 
			RandomAccessFile* imageFile, 
			RandomAccessFile* confFile)
{
	//vector<MirImageInfo*> wilImages;
	byte bytesInt[4];
	//printf("start read wzx:\n");
	// 读取wzx
	//confFile->seek(0);
	//imageFile->seek(0);
	//confFile->skipBytes(48); // 跳过标题
	//confFile->read(bytesInt);

	//int indexCount = Common::ReadInt(bytesInt, 0, true);

	// 读取特定图片
	 // 为了获取图片数据长度，读取下一个图片数据起始位置相减
	int a_offset = 0;
	int b_offset = 0;

	int position = index * 4 + 48; // 跳过索引前图片/标题/图片数

	//printf("start read offset:\n");
	confFile->seek(position);
	confFile->read(bytesInt);
	a_offset = Common::ReadInt(bytesInt, 0, true);

	imageFile->seek(a_offset + 12);
	imageFile->read(bytesInt);
	int length = Common::ReadInt(bytesInt, 0, true);

	//printf("start read MirImageInfo:\n");
	// 读取imgeinfo
	MirImageInfo* mirImageInfo = read(a_offset, imageFile);

	mirImageInfo->setIndex((short)index);
	mirImageInfo->setDataStart(a_offset);
	mirImageInfo->setDataSize(length);

	if (length >= 1000000 || mirImageInfo->getWidth() <= 0 || mirImageInfo->getHeight() <= 0
		|| mirImageInfo->getWidth() >= 10000 || mirImageInfo->getHeight() >= 10000)
	{
		mirImageInfo->setWidth(4);
		mirImageInfo->setHeight(4);
		mirImageInfo->setDataSize(12);
	}

	readPixels(mirImageInfo, imageFile);
	/*
	*/
	//Sprite* sprite = Sprite::create();
	//printf("start read pixels:\n");
	

 	return mirImageInfo;
}

MirImageInfo* WZLReader::read(int position, RandomAccessFile* imageFile)
{
	MirImageInfo* res = new MirImageInfo();
	//printf("init read image details:\n");
	imageFile->seek(position);
	//printf("start seek:\n");
	//printf("start read image details:\n");
	res->setWidth(Common::ReadShort(imageFile->getFileData(), position + 4, true));
	res->setHeight(Common::ReadShort(imageFile->getFileData(), position + 6, true));
	res->setOffsetX(Common::ReadShort(imageFile->getFileData(), position + 8, true));
	res->setOffsetY(Common::ReadShort(imageFile->getFileData(), position + 10, true));
	/*
	char* buff = new char[imageFile->getLength()];
	strcpy(buff, imageFile->getFileData());
	res->setWidth(Common::ReadShort(buff, position + 4, true));
	res->setHeight(Common::ReadShort(buff, position + 6, true));
	res->setOffsetX(Common::ReadShort(buff, position + 8, true));
	res->setOffsetY(Common::ReadShort(buff, position + 10, true));

	delete[] buff;*/

	return res;
}

void WZLReader::readPixels(MirImageInfo* MirImageInfo, 
			RandomAccessFile* imageFile)
{
	int width = MirImageInfo->getWidth();
	int height = MirImageInfo->getHeight();
	int offset = MirImageInfo->getDataStart();
	int length = MirImageInfo->getDataSize();

	byte* unpackedPixels = new byte[width * height * 4];
	int pixelLen = 0;
	//ByteBuffer unpackedPixels = ByteBuffer.allocateDirect(width * height * 4);
	//unpackedPixels.order(ByteOrder.nativeOrder());
		
	if(length < 13) {
		// 如果是空白图片
		width = 4;
		height = 4;
		for(int i = 0; i < width * height; ++i) {
			unpackedPixels[i*4] = palletes[0][1];
			unpackedPixels[i*4 + 1] = palletes[0][2];
			unpackedPixels[i*4 + 2] = palletes[0][3];
			unpackedPixels[i*4 + 3] = palletes[0][0];
			/*
			unpackedPixels[pixelLen] = palletes[0][1];
			unpackedPixels[pixelLen+1] = palletes[0][2];
			unpackedPixels[pixelLen+2] = palletes[0][3];
			unpackedPixels[pixelLen+3] = palletes[0][0];*/
		}
	} else {
		byte* oldPixels = new byte[length];
		imageFile->seek(offset + 16);  //WZL 为16 wil为8
		imageFile->read(oldPixels, length);

		//printf("before index:%d  pixels length:%d\n",MirImageInfo->getIndex(), length);
		byte* pixels = Common::unzip(oldPixels, length, width*height*2);

		//printf("index:%d  pixels length:%d\n",MirImageInfo->getIndex(), length);
		if (pixels == 0)
			log("index:%d  pixels length:%d  file:%s\n", MirImageInfo->getIndex(), length, imageFile->getFilename().c_str());

		int p_index = 0;
		for(int h = height - 1; h >= height - height; --h)
		{
			for(int w = width - width; w < width; ++w) {
				// 跳过填充字节
				if(w == width - width)
					p_index += Common::skipBytes(8, width);
				// 坐标转换，bmp中图片数据是从左到右，从下到上，而我们需要从下到上
				/*unpackedPixels[(h * width + w) * 4] = palletes[pixels[p_index] & 0xff][1];
				unpackedPixels[(h * width + w) * 4 + 1] = palletes[pixels[p_index] & 0xff][2];
				unpackedPixels[(h * width + w) * 4 + 2] = palletes[pixels[p_index] & 0xff][3];
				unpackedPixels[(h * width + w) * 4 + 3] = palletes[pixels[p_index++] & 0xff][0];
				*/
				if (pixels == 0)
				{
					unpackedPixels[(h * width + w) * 4] = palletes[0][1];
					unpackedPixels[(h * width + w) * 4 + 1] = palletes[0][2];;
					unpackedPixels[(h * width + w) * 4 + 2] = palletes[0][3];
					unpackedPixels[(h * width + w) * 4 + 3] = palletes[0][0];
				}
				else
				{
					int colorIndex = (pixels == 0 ? 0 : pixels[p_index] & 0xff);
					unpackedPixels[(h * width + w) * 4] = palletes[colorIndex][1];
					unpackedPixels[(h * width + w) * 4 + 1] = palletes[colorIndex][2];
					unpackedPixels[(h * width + w) * 4 + 2] = palletes[colorIndex][3];
					unpackedPixels[(h * width + w) * 4 + 3] = palletes[pixels[p_index++] & 0xff][0];
				}

				//black color
				if (m_clearNearBlackColor)
				{
					if (checkBlackColor(unpackedPixels[(h * width + w) * 4],
							unpackedPixels[(h * width + w) * 4 + 1],
							unpackedPixels[(h * width + w) * 4 + 2]))
					{
						unpackedPixels[(h * width + w) * 4 ] = 255;//palletes[0][1];
						unpackedPixels[(h * width + w) * 4 + 1] = 255;//palletes[0][2];
						unpackedPixels[(h * width + w) * 4 + 2] = 255;//palletes[0][3];
						unpackedPixels[(h * width + w) * 4 + 3] = 0;//palletes[0][0];
					}
				}
			}
		}

		delete oldPixels;
		delete pixels;
	}

	MirImageInfo->setData(unpackedPixels);
	MirImageInfo->setDataSize(width * height * 4);
}

bool WZLReader::checkBlackColor(int R, int G, int B)
{
	if (R == 8 && G == 24 && B == 16)
		return true;

	if (R == 8 && G == 24 && B == 24)
		return true;

	if (R == 24 && G == 24 && B == 24)
		return true;

	if (R == 0 && G == 8 && B == 24)
		return true;

	if (R < 24 && G < 24 && B <= 24)
		return true;

	return false;
}

void WZLReader::setClearNearBlackColor(bool clear)
{
	m_clearNearBlackColor = clear;
}