#include "fakeDataGen.h"
#include "client.h"

#define BD_ID 1
#define CH_ID 2
#define SERVER_ADDR "0.0.0.0"
#define SERVER_PORTNO 12345

int main()
{
    //initialize queues
    Rx_Queue_t * rxQ = Rx_QueueInit();
    Tx_Queue_t * txQ = Tx_QueueInit();

    //initialize FakeDataGen
    FakeDataGen_t * fdg = FakeDataGenInit(UPDATE_TIME_SEC,randConst);

    //initialize adquisition thread
    Adq_Thread_t * adqTh = AdqThreadInit(rxQ,txQ,BD_ID,CH_ID,fdg->pq);

    //initialize transmission thread
    Tx_Thread_t * txTh = TxThreadInit(txQ,rxQ,SERVER_ADDR,SERVER_PORTNO);

    //run threads
    AdqThreadRun(adqTh);
    TxThreadRun(txTh);

    //run fake data generator
    FakeDataGenRun(fdg);

    getchar();

    //stop all (be careful with stop precedence to avoid blocking)
    TxThreadStop(txTh);
    AdqThreadStop(adqTh);
    FakeDataGenStop(fdg);   

    //destroy all
    FakeDataGenDestroy(fdg);
    TxThreadDestroy(txTh);
    AdqThreadDestroy(adqTh);
    Rx_QueueDestroy(rxQ);
    Tx_QueueDestroy(txQ);

    return 0;
}