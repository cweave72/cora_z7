/*******************************************************************************
*//** @file tasks.c

    @brief Initializes system for multitasking and defines tasks.
*******************************************************************************/
#include "includes.h"

/** @brief IRQ numbers. */
#define SW_IRQ    0
#define TIMER_IRQ 1

/** @brief ISR Function pointer type */
typedef void (*ucos_task_t)(void *);

typedef struct TaskObj
{
    /** @brief Task name. */
    char *nm;
    /** @brief Priority (0 is highest) */
    uint8_t pri;
    /** @brief Task ID. */
    uint8_t id;
    /** @brief Task stack size. */
    uint32_t size;
    /** @brief Pointer to task stack. */
    OS_STK *stk;
    /** @brief Pointer to task function. */
    ucos_task_t task;
} TaskObj;

/* Declare task stacks and functions. */
OS_STK TaskStartStk[256];
static void TaskStart(void *pdata);

OS_STK Task1Stk[256];
static void Task1(void *pdata);

/** @brief Define task IDs. */
enum TaskIDs
{
    STARTTASK_ID = 0,
    TASK_1_ID,
    NUM_TASKS
};


#define GET_NUM_ITEMS(s)    (sizeof(s)/sizeof(s[0]))

/** @brief Helper macro for adding tasks to the list. */
#define ADD_TASK(name, task_id, priority, stack, task_fcn) \
    {.nm=(name), .id=(task_id), .pri=(priority), .stk=(stack), \
        .size=GET_NUM_ITEMS(stack), .task=(task_fcn)}

/** @brief Task list. */
static TaskObj tasks[NUM_TASKS] = {
    [STARTTASK_ID] = ADD_TASK("StartTask", STARTTASK_ID, 10, TaskStartStk, TaskStart),
    [TASK_1_ID]    = ADD_TASK("Task1", TASK_1_ID, 11, Task1Stk, Task1)
};

/** @brief ISRs provided by the ucos port. */
extern void Software_IRQHandler(void);  /* os_cpu_a.S */
extern void SysTick_Handler(void);      /* os_cpu_c.c */

/** @brief List of IRQ handlers. */
static IrqCtlr_HandlerItem handlers[] = {
    IRQCTLR_ADD_HANDLER(SW_IRQ, Software_IRQHandler),
    IRQCTLR_ADD_HANDLER(TIMER_IRQ, SysTick_Handler),
};

/*******************************************************************************
*//**   createTask

    @brief Function to create a task.

*******************************************************************************/
static void
createTask (TaskObj *tp)
{
    uint32_t size = tp->size;
    OS_STK *tos = &tp->stk[size-1];
    OS_STK *bos = &tp->stk[0];

    debug_printf("Creating Task: %s\n", tp->nm);
    OSTaskCreateExt(
        tp->task,
        (void *)0,
        tos,
        tp->pri,
        tp->id,
        bos,
        size,
        (void *)0,
        OS_TASK_OPT_STK_CHK | OS_TASK_OPT_STK_CLR);
}

/*******************************************************************************
*//**   TaskStart

    @brief The startup task.
*******************************************************************************/
static void
TaskStart(void *pdata)
{
    uint32_t count = 0;
    uint32_t i;
    OS_CPU_SR cpu_sr;

    pdata=pdata;

    debug_printf("In TaskStart().\n");

    /* Set timer for overflow at a rate of OS_TICKS_PER_SEC. */
    Timer_run(0, 1000000/OS_TICKS_PER_SEC, true);

    IrqCtlr_enableIrq(SW_IRQ);
    IrqCtlr_enableIrq(TIMER_IRQ);

    for (i = 1; i < NUM_TASKS; ++i)
    {
        createTask(&tasks[i]);
    }

    for(;;)
    {

        OS_ENTER_CRITICAL();
        debug_printf("hello from StartTask! (%u)\n", count++);
        OS_EXIT_CRITICAL();

        OSTimeDly(2);
    }
}

/*******************************************************************************
*//**   Task1

    @brief 
*******************************************************************************/
static void
Task1(void *pdata)
{
    uint32_t count = 0;
    uint32_t i;
    OS_CPU_SR cpu_sr;

    pdata=pdata;

    debug_printf("In Task1().\n");

    for(;;)
    {
        OS_ENTER_CRITICAL();
        debug_printf("hello from Task1! (%u)\n", count++);
        OS_EXIT_CRITICAL();

        OSTimeDly(1);
    }
}

/*******************************************************************************
*//**   Tasks_main

    @brief Performs system initialization and starts multitasking.
    1. Registers IRQ handlers with the IRQ controller.
    2. Clears all irqs.
    3. Enables the IRQ controller so that IRQ indications are asserting to the
    processor core. This is not the global interrupt enable which is handled by
    the UCOS port assembly code.
    4. Call OSInit() to initialize ucos.
    5. Create the startup task - this task sets up the timer and enables
    interrupts.
    6. Calls OSStart() which starts the OS.  This function never returns, the
    UCOS kernel takes over from here.
*******************************************************************************/
void
Tasks_main(void)
{
    debug_printf("Initializing....\n");

    IrqCtlr_registerHandlers(handlers, GET_NUM_ITEMS(handlers));

    /* Clear any irq which might be already set. */
    IrqCtlr_clrAllIrq();

    /*  Set the global interrupt controller enable.  Processor interrupts are
        disabled initially by startup code, then enabled by os init.  */
    IrqCtlr_enable();

    OSInit();

    /* Create the start task. */
    createTask(&tasks[STARTTASK_ID]);

    /* Start the os.  This function never returns. */
    OSStart();
}
