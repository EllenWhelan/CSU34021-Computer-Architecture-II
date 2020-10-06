#include <cmath>
#include <cstring>
#include <stdio.h>

class CacheSim
{
    public:
    int cacheHits;
    int cacheMisses;
    int L; // bytes per line = 4 words per line
    int K; // K-way cache
    int N; //number of sets
    int byteNum=128;
    int offset=4;
    int setBitsLen;
    int tagBitsPos;
    int tagBitsLen;

    int hexAddr[32] = {0x0000, 0x0004, 0x000c, 0x2200, 0x00d0, 0x00e0, 0x1130, 0x0028,
                  0x113c, 0x2204, 0x0010, 0x0020, 0x0004, 0x0040, 0x2208, 0x0008,
                  0x00a0, 0x0004, 0x1104, 0x0028, 0x000c, 0x0084, 0x000c, 0x3390,
                  0x00b0, 0x1100, 0x0028, 0x0064, 0x0070, 0x00d0, 0x0008, 0x3394};
    bool hitsArray[32];

    int cacheArray[8][8]; //as (i) has biggest num of sets 8 is used for sets, as iv has largest k with 8 way cache, 8 is used
    int cacheLine[8]; //temp cache line

    CacheSim(int l, int k)
    {
        L=l;
        K=k;
        N = byteNum / (L*K); //calculate number of sets
        setBitsLen = (int)log2(N);
        tagBitsPos = offset+setBitsLen;
        tagBitsLen = 16-tagBitsPos;
        //intialise all arrays to 'nulls'
        for(int i=0; i<32; i++)hitsArray[i]=false;
        for(int i=0; i<8; i++)cacheLine[i]=-1;

        for (int i=0; i<8;i++){
            for(int j=0; j<8; j++) {
                cacheArray[i][j] = -1;
            }
        }
        cacheHits=0;
        cacheMisses=0;
    }

    void runCacheSimulation()
    {
        int tmpAddr, lineMinusOffset, set, tag;
        for(int i=0; i<32;i++) //loop through all addresses
        {
            tmpAddr = hexAddr[i];
            lineMinusOffset = (tmpAddr>>4); //shift off offset
            set = lineMinusOffset & (N-1); // and with mask of N-1 to get all 1s where set bits are
            tag = (tmpAddr>>tagBitsPos); //shift bits by tag bit position to get tag bits
            for (int j=0; j<K;j++) { //iterate through k-way set
                if (tag==cacheArray[set][j]) {
                    hitsArray[i]=true;
                    cacheHits++;
                    continue;
                }
            }
            if (hitsArray[i]==false) { //Miss
                cacheArray[set][N-1] = tag; // replace oldest with new entry
                //updateCache(set, (N-1)); //add entry tp cache
                int tmp=N-1;
                cacheLine[0] = cacheArray[set][tmp];
                for (int j=0;j<tmp;j++) cacheLine[j+1]=cacheArray[set][j]; //update temp line
                for (int j=0;j<=tmp;j++) cacheArray[set][j]=cacheLine[j]; //update cache
                for(int k=0;k<8;k++)cacheLine[tmp]=-1; //delete temp cache line
                cacheMisses++;

            }
        }
    }
};

int main ()
{
    //loop through question i to iv 
    int l=16; //i to iv all have 16 bytes per line
    int k=1;
    for (int i=0; i<4; i++) {
        CacheSim cache(l,k);
        cache.runCacheSimulation();
        k = k*2;
        printf("L=%d,K=%d,N=%d\n", cache.L, cache.K, cache.N);
        printf("Cache Hits=%d, Cache Misses=%d\n", cache.cacheHits, cache.cacheMisses);
    }
        return(0);
}

