
void set_pointer_to_self_receiver(void *pointer) {
#ifdef __aarch64__
    __asm__("mov x20, x0");
#endif
#ifdef __x86_64__
    __asm__("movq %rdi, %r13");
#endif
}


void *testAnyPointer() {
    extern void _mealy_testAny(void);
    return &_mealy_testAny;
}
