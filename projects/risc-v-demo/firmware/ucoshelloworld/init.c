#include <stdint.h>

extern uint32_t _sidata;
extern uint32_t _sdata;
extern uint32_t _edata;
extern uint32_t _sbss;
extern uint32_t _ebss;

static void 
copy_section(uint32_t *load_addr, uint32_t *cpy_addr, uint32_t *end_addr)
{
    while (cpy_addr < end_addr)
    {
        *cpy_addr = *load_addr;
        cpy_addr++;
        load_addr++;
    }
}

static void 
zero_section(uint32_t *start_addr, uint32_t *end_addr)
{
    uint32_t *addr = start_addr;
    while (addr <= end_addr)
    {
        *addr = 0;
        addr++;
    }
}

void _init(void)
{
    copy_section(&_sidata, &_sdata, &_edata);
    //zero_section(&_sbss, &_ebss);
}
