/*
Emulation, acquisition and data processing system for sensor matrices 
José Quinteros del Castillo
Instituto Balseiro
---
Data acquisition interface for CIAA-ACC AXI bus

Version: 2020-06-11
Comments:
*/

#include "CIAASistAdq.h"

// writes data to a memory register
int memwrite(uint32_t addr, const uint32_t *data, size_t count) {
	int result = -1;
	int fd = open("/dev/mem", O_RDWR);
	if (fd != -1) {
		uint32_t align_addr = addr & (~(PAGE_SIZE - 1));
		off_t align_offset = addr & (PAGE_SIZE - 1);
		uint8_t *ptr = mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED,
				fd, align_addr);
		if (ptr) {
			int n;
			for (n = 0; n < count; n++) {
				*((volatile uint32_t*) (ptr + align_offset)) = *data;
				if (MEM_INCR) {
					align_offset += sizeof(uint32_t);
				}
			}
			munmap(ptr, PAGE_SIZE);
			result = 0;
		} else
			puts("mmap fail");
		close(fd);
	} else
		puts("open /dev/mmap");
	return result;
}

// reads data from a memory register
int memread(uint32_t addr, uint32_t *data, size_t count) {
	int result = -1;
	int fd = open("/dev/mem", O_RDWR);
	if (fd != -1) {
		uint32_t align_addr = addr & (~(PAGE_SIZE - 1));
		off_t align_offset = addr & (PAGE_SIZE - 1);
		uint8_t *ptr = mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED,
				fd, align_addr);
		if (ptr) {
			while (count--) {
				*data++ = *((volatile uint32_t*) (ptr + align_offset));
				if (MEM_INCR) {
					align_offset += sizeof(uint32_t);
				}
			}
			munmap(ptr, PAGE_SIZE);
			result = 0;
		} else
			puts("mmap fail");
		close(fd);
	} else
		puts("open /dev/mmap");
	return result;
}

// converts FIFO flag register to FIFO flags structure
void fifoflags_reg_to_struct(fifo_flags_t *flags, uint32_t * flag_reg)
{
	flags->empty = *flag_reg & EMPTY_MASK;
	flags->full = *flag_reg & FULL_MASK;
	flags->overflow = *flag_reg & OVERFLOW_MASK;
	flags->rd_rst_busy = *flag_reg & RDRSTBUSY_MASK;
	flags->wr_rst_busy = *flag_reg & WRRSTBUSY_MASK;
    flags->prog_full = *flag_reg & PROGFULL_MASK;
    flags->rd_data_count = (*flag_reg & RDDATACOUNT_MASK) >> RDDATACOUNT_POS;
}

// human readable print of FIFO flags structure
void print_fifo_flags(fifo_flags_t *flags)
{
	printf("FIFO empty: %d\n",flags->empty);
	printf("FIFO full: %d\n",flags->full);
	printf("FIFO overflow: %d\n",flags->overflow);
	printf("FIFO wr_rst busy: %d\n",flags->wr_rst_busy);
	printf("FIFO rd_rst busy: %d\n",flags->rd_rst_busy);
    printf("FIFO prog full: %d\n",flags->prog_full);
    printf("FIFO read data count: %d\n",flags->rd_data_count);
}

// resets FIFO
void fifo_reset()
{
    uint32_t wr_data,rd_data;
    bool condition;

	//activate reset
    wr_data = 1;
    memwrite(AXI_BASE_ADDR + FIFORST_ADDR,&wr_data,1);

	//wait for assertion of wr_rst_busy and rd_rst_busy 
    do
    {
        memread(AXI_BASE_ADDR + FIFOFLAGS_ADDR,&rd_data,1);
        condition = (rd_data & WRRSTBUSY_MASK) && (rd_data & RDRSTBUSY_MASK);
    } while (!condition);

	//deactivate reset
    wr_data = 0;
    memwrite(AXI_BASE_ADDR + FIFORST_ADDR,&wr_data,1);

	//wait for deassertion of wr_rst_busy and rd_rst_busy 
    do
    {
        memread(AXI_BASE_ADDR + FIFOFLAGS_ADDR,&rd_data,1);
        condition = (rd_data & WRRSTBUSY_MASK) && (rd_data & RDRSTBUSY_MASK);
    } while (condition);
}

// resets debug module for duration microseconds
void debug_reset(uint duration)
{
    uint32_t wr_data;

    wr_data = 1;
    memwrite(AXI_BASE_ADDR + DEBRST_ADDR,&wr_data,1);
    usleep(duration);
    wr_data = 0;
    memwrite(AXI_BASE_ADDR + DEBRST_ADDR,&wr_data,1);
}

//// MULTI MEM POINTER
//a Multi_MemPtr_t contains several mapped memory spaces for easy read/write operations
struct Multi_MemPtr_str
{
	uint32_t * addr;
	uint8_t ** ptr;
	off_t * align_offset;
	uint8_t mem_num;
};

// initializes a Multi_MemPtr_t, mapping the memory addresses passed as argument
static Multi_MemPtr_t * multi_minit(uint32_t * addr, uint8_t mem_num)
{
	Multi_MemPtr_t * multiPtr = malloc(sizeof(Multi_MemPtr_t));

    multiPtr->mem_num = mem_num;
	multiPtr->addr = malloc(mem_num*sizeof(uint32_t));
	memcpy(multiPtr->addr,addr,mem_num*sizeof(uint32_t));
	multiPtr->ptr = malloc(mem_num*sizeof(uint8_t*));
	multiPtr->align_offset = malloc(mem_num*sizeof(off_t));

	int fd = open("/dev/mem", O_RDWR);
	if (fd < 0) error("/dev/mem open in multi_memopen");

	uint32_t align_addr;

	int i;
	for(i=0;i<multiPtr->mem_num;i++)
	{
		align_addr = multiPtr->addr[i] & (~(PAGE_SIZE - 1));
		multiPtr->align_offset[i] = multiPtr->addr[i] & (PAGE_SIZE - 1);
		multiPtr->ptr[i] = mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, align_addr);
		if(multiPtr->ptr[i] == MAP_FAILED) error("mmap in multi_memopen");
	}
	close(fd);

	return multiPtr;
}

// destroys a Multi_MemPtr_t, unmapping its memory spaces
static void multi_mdestroy(Multi_MemPtr_t * multiPtr)
{
	int i;
	for(i=0;i<multiPtr->mem_num;i++)
	{
		if(munmap(multiPtr->ptr[i],PAGE_SIZE) < 0) error("munmap in multi_munmap");
	}

	free(multiPtr->addr);
	free(multiPtr->ptr);
	free(multiPtr->align_offset);
	free(multiPtr);
}

////ACQUISITION THREAD

// initializes an Acq_Thread_t
Acq_Thread_t * AcqThreadInit(Client_t * client)
{
    Acq_Thread_t * acqTh = malloc(sizeof(Acq_Thread_t));

    acqTh->client = client;

    acqTh->running = 0;

	//map memory spaces to read FIFO flags and data
	uint32_t addr[2];
	addr[0] = AXI_BASE_ADDR + FIFOFLAGS_ADDR;
	addr[1] = AXI_BASE_ADDR + FIFODATA_ADDR;
	acqTh->multiPtr = multi_minit(addr,2);

    return acqTh;
}

// destroys an Acq_Thread_t
void AcqThreadDestroy(Acq_Thread_t * acqTh)
{
	multi_mdestroy(acqTh->multiPtr);
    free(acqTh);
}

// fills an AcqPack_t with external data from Acquisition System
static void acquire_data(AcqPack_t * acqPack, Multi_MemPtr_t * multiPtr)
{
	int j = 0;
	
	//HEADER
		//timestamp
		if(clock_gettime(CLOCK_REALTIME,&acqPack->header.acq_timestamp) < 0) error("clock_gettime in acquire_data");
		//whatever we want to do with remaining header
	
	//ACQUIRE
		//read fifo flags and data
		for(j=0;j<PACK_SIZE;j++)
		{
            do
            {
                acqPack->flags[j] = *((volatile uint32_t*) (multiPtr->ptr[0] + multiPtr->align_offset[0]));
            } while (acqPack->flags[j]&EMPTY_MASK);           
			
			acqPack->data[j] = *((volatile uint32_t*) (multiPtr->ptr[1] + multiPtr->align_offset[1]));
		}
}

// function to be run by the acquisition thread
static void * acqTh_threadFunc(void * ctx)
{
    Acq_Thread_t * acqTh = (Acq_Thread_t *) ctx;
    uint64_t wr_buf;
	AcqPack_t * acqPack = malloc(sizeof(AcqPack_t));

	int count = acqTh->client->n_samples;

    if(acqTh->client->capMode == sampleNumber)
    {
        //capture until reaching the required number of samples or thread is stopped
        while(acqTh->running && count--)
		{
			acqPack = Rx_Queue_Acquire(acqTh->client->rxQ);
			acquire_data(acqPack,acqTh->multiPtr);
			Tx_QueuePut(acqTh->client->txQ,acqPack);
		}
        //notify client
        wr_buf = 1;
        write(acqTh->client->eventfd_samples,&wr_buf,sizeof(wr_buf));
    }
    else
    {
        //capture until thread is stopped
        while(acqTh->running)
		{
			acqPack = Rx_Queue_Acquire(acqTh->client->rxQ);
			acquire_data(acqPack,acqTh->multiPtr);
			Tx_QueuePut(acqTh->client->txQ,acqPack);
		}
    }

    //return to be joined
    return NULL;
}

// sets an acquisition thread to run
void AcqThreadRun(Acq_Thread_t * acqTh)
{
    if(acqTh->running == 1)
    {
        printf("Acquisition thread already running!\n");
        exit(1);
    }

    //assert running flag
    acqTh->running = 1;

    //create acquisition thread
    if(pthread_create(&acqTh->th,NULL,acqTh_threadFunc,acqTh) != 0) error("pthread_create of acqTh");
}

// stops an acquisition thread
void AcqThreadStop(Acq_Thread_t * acqTh)
{
    if(acqTh->running == 0)
    {
        printf("Acquisition thread already stopped!\n");
        exit(1);
    }

    //deassert running flag
    acqTh->running = 0;

    //wait for thread to finish and join
    if(pthread_join(acqTh->th,NULL) != 0) error("pthread_join of acqTh");
}

//// TRANSMISSION THREAD
// initializes a Tx_Thread_t
Tx_Thread_t * TxThreadInit(Client_t * client
#if TX_MODE == 1
, char * server_addr, const int server_portno
#endif
)
{
    //allocate memory for Tx_Thread_t
    Tx_Thread_t * txTh = malloc(sizeof(Tx_Thread_t));

    //assign client
    txTh->client = client;

    txTh->running = 0;

	#if TX_MODE == 1
	struct sockaddr_in serv_addr;
	memset(&serv_addr,0,sizeof(serv_addr));

	struct hostent *server;

	//save connection params (just in case we need them in the future)
	txTh->server_addr = server_addr;
	txTh->server_portno = server_portno;

	//open TCP/IP socket
	txTh->sockfd = socket(AF_INET,SOCK_STREAM,0);
	if(txTh->sockfd < 0) error("socket open in txTh");
	//find host
	server = gethostbyname(server_addr);
	if(server == NULL)
	{
		fprintf(stderr,"ERROR, no host found with that address\n");
		exit(1);
	}
	//get server address from host found
	serv_addr.sin_family = AF_INET;
	bcopy((char *)server->h_addr_list[0], 
		(char *)&serv_addr.sin_addr.s_addr,
		server->h_length);    //use port passed as argument
	serv_addr.sin_port=htons(server_portno);
	//connect to server
	if (connect(txTh->sockfd,(struct sockaddr *) &serv_addr,sizeof(serv_addr)) < 0) error("connect to server in txTh");
	printf("Client connected to %s:%d.\n",server_addr,server_portno);
	#endif
    
    return txTh;
}

// destroys a Tx_Thread_t
void TxThreadDestroy(Tx_Thread_t * txTh)
{
	#if TX_MODE == 1
    //close connection with server
    close(txTh->sockfd);
	#endif

    //release memory
    free(txTh);
}

#if TX_MODE == 1
// writes a msg to sockfd. Retries writing until full msg is sent. Returns 0 on success, -1 on write error, 1 on connection closed
static int socketWrite(int sockfd, void * msg, size_t size_msg)
{
    int n;

    //cast msg to char * to be able to chop it
    char * msg_c = (char *) msg;

    n = write(sockfd,msg_c,size_msg);

    if(n == size_msg)
    {
        return 0;
    }
    else if(n > 0)
    {
        return socketWrite(sockfd,msg_c+n,size_msg-n);
    }
    else if(n == 0)
    {
        return 1;
    }
    else // n < 0
    {
        return -1;
    }    
}
#else

// opens a file with current time as name, and brief description of content
static int fileOpen()
{
	int fout;
    struct timespec t;
    char * word1;
    //char * word2 = NULL;

    //get time from clock and place it formatted in word 1
    if(clock_gettime(CLOCK_REALTIME,&t) < 0) error("clock_gettime in fileOpen");
    word1 = ctime(&t.tv_sec);
    //remove last char
    word1[strlen(word1)-1] = ' ';
    //remove undesired chars
    char * target;
    while(target = strchr(word1,':'),target !=NULL)
    {
        *target = '_';
    }
    while(target = strchr(word1,' '),target !=NULL)
    {
        *target = '_';
    }
    //open file with name
    fout = open(word1,O_CREAT|O_RDWR,0640);
    if(fout < 0) error("open in fileOpen");

    //notify
    printf("txTh: opened file with name %s\n",word1);

    return fout;
}

// writes the contents of an acqPack into file fout
static void fileWrite(int fout, AcqPack_t * acqPack)
{
	if(write(fout,acqPack,sizeof(AcqPack_t)) < 0) error("write in fileWrite");
}
#endif

// function to be run by a transmission thread
static void * txTh_threadFunc(void * ctx)
{
    Tx_Thread_t * txTh = (Tx_Thread_t *) ctx;
    Tx_Queue_t * txQ = txTh->client->txQ;
    Rx_Queue_t * rxQ = txTh->client->rxQ;
    AcqPack_t * acqPack;

    #if TX_MODE == 1
	int wr_ret;
    while(txTh->running || Tx_QueueSize(txQ) < 1)
    {
        //capture from Tx_Queue
        acqPack = Tx_QueueGet(txQ);
		
        //send buffer to socket
        wr_ret = socketWrite(txTh->sockfd,rxBuf,sizeof(Buffer_t));
        if(wr_ret > 0)
        {
            //do something for closed server. Die perhaps?
        }
        if(wr_ret < 0) error("socket write in txTh");
		

        //release buffer
        Rx_Queue_Release(rxQ,acqPack);
    }
	#else

	//open file
	int fout = fileOpen();
	while(txTh->running && txTh->client->acqTh->running)
    {
        //capture from Tx_Queue
        acqPack = Tx_QueueGet(txQ);

		//write to file
		fileWrite(fout,acqPack);

        //release buffer
        Rx_Queue_Release(rxQ,acqPack);
    }

    //if needed, empty Tx_Queue
    while(Tx_QueueSize(txQ) > 0)
    {
        //capture from Tx_Queue
        acqPack = Tx_QueueGet(txQ);

		//write to file
		fileWrite(fout,acqPack);

        //release buffer
        Rx_Queue_Release(rxQ,acqPack);
    }

	//close file
	close(fout);
	
	#endif

    //return to be joined
    return NULL;
}

// sets a transmission thread to run
void TxThreadRun(Tx_Thread_t * txTh)
{
    if(txTh->running == 1)
    {
        printf("Transmission thread is already running!\n");
        exit(1);
    }

    //assert running flag
    txTh->running = 1;

    //create thread
    if(pthread_create(&txTh->th,NULL,txTh_threadFunc,txTh) != 0) error ("pthread_create in txTh");
}

// stops a transmission thread
void TxThreadStop(Tx_Thread_t * txTh)
{
    if(txTh->running == 0)
    {
        printf("Transmission thread is already stopped!\n");
        exit(1);
    }

    //deassert running flag
    txTh->running = 0;

    //wait for thread to finish and join
    if(pthread_join(txTh->th,NULL) != 0) error("pthread_join in txTh");
}

//// CLIENT
// initializes a Client_t
Client_t * ClientInit(ClParams_t * params)
{
    Client_t * client = malloc(sizeof(Client_t));
    memset(client,0,sizeof(Client_t));

    struct itimerspec timerfd_start_spec;

    //rx and tx queues must be initialized
    client->rxQ = Rx_QueueInit();
    client->txQ = Tx_QueueInit();

    //initialize threads
    client->acqTh = AcqThreadInit(client);
    client->txTh = TxThreadInit(client
	#if TX_MODE == 1
	,params->serv_addr,params->server_portno
	#endif
	);

    //modes from params
    client->capMode = params->capMode;
    client->trigMode = params->trigMode;

    switch (client->capMode)
    {
    case sampleNumber:
        //initialize eventfd for acqTh notification
        client->eventfd_samples = eventfd(0,0);
        //get sample number from params      
        client->n_samples = params->n_samples;
        break;

    case timeInterval:
        //get time interval from params
        client->timerfd_stop_spec = params->timerfd_stop_spec;
        //create timer
        client->timerfd_stop = timerfd_create(CLOCK_REALTIME,0);
        if(client->timerfd_stop < 0) error("timerfd_create in ClientInit");    
        break;

    default:
        break;
    }

    switch (client->trigMode)
    {
    case manual:
        //nothing to be done here. Manual trigger is set in ClientRun()
        break;
    
    case timer:
        //clear timer start time
        memset(&timerfd_start_spec,0,sizeof(timerfd_start_spec));
        //get start time from params
        timerfd_start_spec.it_value.tv_sec = mktime(&params->timerfd_start_br);
        //create and start timer
        client->timerfd_start = timerfd_create(CLOCK_REALTIME,0);
        timerfd_settime(client->timerfd_start,TFD_TIMER_ABSTIME,&timerfd_start_spec,NULL);
        break;

    case noDelay:
        //nothing to be done here. No delay trigger is set in ClientRun()
        break;

    default:
        break;
    }

    return client;
}

// destroys a Client_t
void ClientDestroy(Client_t * client)
{
    TxThreadDestroy(client->txTh);
    AcqThreadDestroy(client->acqTh);
    Rx_QueueDestroy(client->rxQ);
    Tx_QueueDestroy(client->txQ);
    if(client->timerfd_start) close(client->timerfd_start);
    if(client->timerfd_stop) close(client->timerfd_stop);
    if(client->timerfd_stop) close(client->eventfd_samples);
}

// stops a Client_t
void ClientStop(Client_t * client)
{
    AcqThreadStop(client->acqTh);
    TxThreadStop(client->txTh);
}

// runs a Client_t
void ClientRun(Client_t * client)
{
    uint64_t rd_buf;
    struct timespec tspec;

    switch (client->trigMode)
    {
        case manual:
            printf("Client ready to capture. Press any key to start capture...\n");
            getchar();
            getchar();
            break;
        
        case timer:
            printf("Client waiting for timer to run.\n");
            read(client->timerfd_start,&rd_buf,sizeof(rd_buf));
            break;
        
        case noDelay:
            //do nothing. Start at once
            break;
        default:
            break;
    }

    clock_gettime(CLOCK_REALTIME,&tspec);
    printf("Client started capture at time %s",ctime(&tspec.tv_sec));
    //if capture with time interval, start this timer
    if(client->capMode == timeInterval)
    {
        timerfd_settime(client->timerfd_stop,0,&client->timerfd_stop_spec,NULL);
    }

    //run threads
    AcqThreadRun(client->acqTh);
    TxThreadRun(client->txTh);

    switch (client->capMode)
    {
    case sampleNumber:
        //wait for acqThread notification
        read(client->eventfd_samples,&rd_buf,sizeof(rd_buf));
        ClientStop(client);
        break;
    
    case timeInterval:
        //wait for time Interval
        read(client->timerfd_stop,&rd_buf,sizeof(rd_buf));
        ClientStop(client);
        break;
    default:
        break;
    }

}