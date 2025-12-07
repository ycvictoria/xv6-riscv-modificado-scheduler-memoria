
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000c117          	auipc	sp,0xc
    80000004:	18010113          	addi	sp,sp,384 # 8000c180 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000024:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000028:	2781                	sext.w	a5,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037961b          	slliw	a2,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	963a                	add	a2,a2,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f46b7          	lui	a3,0xf4
    80000040:	24068693          	addi	a3,a3,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9736                	add	a4,a4,a3
    80000046:	e218                	sd	a4,0(a2)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00279713          	slli	a4,a5,0x2
    8000004c:	973e                	add	a4,a4,a5
    8000004e:	070e                	slli	a4,a4,0x3
    80000050:	0000c797          	auipc	a5,0xc
    80000054:	ff078793          	addi	a5,a5,-16 # 8000c040 <timer_scratch>
    80000058:	97ba                	add	a5,a5,a4
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef90                	sd	a2,24(a5)
  scratch[4] = interval;
    8000005c:	f394                	sd	a3,32(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	2be78793          	addi	a5,a5,702 # 80006320 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	60a2                	ld	ra,8(sp)
    80000088:	6402                	ld	s0,0(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd47ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	e5878793          	addi	a5,a5,-424 # 80000f06 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	711d                	addi	sp,sp,-96
    80000104:	ec86                	sd	ra,88(sp)
    80000106:	e8a2                	sd	s0,80(sp)
    80000108:	e0ca                	sd	s2,64(sp)
    8000010a:	1080                	addi	s0,sp,96
  int i;

  for(i = 0; i < n; i++){
    8000010c:	04c05b63          	blez	a2,80000162 <consolewrite+0x60>
    80000110:	e4a6                	sd	s1,72(sp)
    80000112:	fc4e                	sd	s3,56(sp)
    80000114:	f852                	sd	s4,48(sp)
    80000116:	f456                	sd	s5,40(sp)
    80000118:	f05a                	sd	s6,32(sp)
    8000011a:	ec5e                	sd	s7,24(sp)
    8000011c:	8a2a                	mv	s4,a0
    8000011e:	84ae                	mv	s1,a1
    80000120:	89b2                	mv	s3,a2
    80000122:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000124:	faf40b93          	addi	s7,s0,-81
    80000128:	4b05                	li	s6,1
    8000012a:	5afd                	li	s5,-1
    8000012c:	86da                	mv	a3,s6
    8000012e:	8626                	mv	a2,s1
    80000130:	85d2                	mv	a1,s4
    80000132:	855e                	mv	a0,s7
    80000134:	00002097          	auipc	ra,0x2
    80000138:	564080e7          	jalr	1380(ra) # 80002698 <either_copyin>
    8000013c:	03550563          	beq	a0,s5,80000166 <consolewrite+0x64>
      break;
    uartputc(c);
    80000140:	faf44503          	lbu	a0,-81(s0)
    80000144:	00000097          	auipc	ra,0x0
    80000148:	7d0080e7          	jalr	2000(ra) # 80000914 <uartputc>
  for(i = 0; i < n; i++){
    8000014c:	2905                	addiw	s2,s2,1
    8000014e:	0485                	addi	s1,s1,1
    80000150:	fd299ee3          	bne	s3,s2,8000012c <consolewrite+0x2a>
    80000154:	64a6                	ld	s1,72(sp)
    80000156:	79e2                	ld	s3,56(sp)
    80000158:	7a42                	ld	s4,48(sp)
    8000015a:	7aa2                	ld	s5,40(sp)
    8000015c:	7b02                	ld	s6,32(sp)
    8000015e:	6be2                	ld	s7,24(sp)
    80000160:	a809                	j	80000172 <consolewrite+0x70>
    80000162:	4901                	li	s2,0
    80000164:	a039                	j	80000172 <consolewrite+0x70>
    80000166:	64a6                	ld	s1,72(sp)
    80000168:	79e2                	ld	s3,56(sp)
    8000016a:	7a42                	ld	s4,48(sp)
    8000016c:	7aa2                	ld	s5,40(sp)
    8000016e:	7b02                	ld	s6,32(sp)
    80000170:	6be2                	ld	s7,24(sp)
  }

  return i;
}
    80000172:	854a                	mv	a0,s2
    80000174:	60e6                	ld	ra,88(sp)
    80000176:	6446                	ld	s0,80(sp)
    80000178:	6906                	ld	s2,64(sp)
    8000017a:	6125                	addi	sp,sp,96
    8000017c:	8082                	ret

000000008000017e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000017e:	711d                	addi	sp,sp,-96
    80000180:	ec86                	sd	ra,88(sp)
    80000182:	e8a2                	sd	s0,80(sp)
    80000184:	e4a6                	sd	s1,72(sp)
    80000186:	e0ca                	sd	s2,64(sp)
    80000188:	fc4e                	sd	s3,56(sp)
    8000018a:	f852                	sd	s4,48(sp)
    8000018c:	f05a                	sd	s6,32(sp)
    8000018e:	ec5e                	sd	s7,24(sp)
    80000190:	1080                	addi	s0,sp,96
    80000192:	8b2a                	mv	s6,a0
    80000194:	8a2e                	mv	s4,a1
    80000196:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000198:	8bb2                	mv	s7,a2
  acquire(&cons.lock);
    8000019a:	00014517          	auipc	a0,0x14
    8000019e:	fe650513          	addi	a0,a0,-26 # 80014180 <cons>
    800001a2:	00001097          	auipc	ra,0x1
    800001a6:	ab2080e7          	jalr	-1358(ra) # 80000c54 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001aa:	00014497          	auipc	s1,0x14
    800001ae:	fd648493          	addi	s1,s1,-42 # 80014180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001b2:	00014917          	auipc	s2,0x14
    800001b6:	06690913          	addi	s2,s2,102 # 80014218 <cons+0x98>
  while(n > 0){
    800001ba:	0d305263          	blez	s3,8000027e <consoleread+0x100>
    while(cons.r == cons.w){
    800001be:	0984a783          	lw	a5,152(s1)
    800001c2:	09c4a703          	lw	a4,156(s1)
    800001c6:	0af71763          	bne	a4,a5,80000274 <consoleread+0xf6>
      if(myproc()->killed){
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	8bc080e7          	jalr	-1860(ra) # 80001a86 <myproc>
    800001d2:	551c                	lw	a5,40(a0)
    800001d4:	e7ad                	bnez	a5,8000023e <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800001d6:	85a6                	mv	a1,s1
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	0ba080e7          	jalr	186(ra) # 80002294 <sleep>
    while(cons.r == cons.w){
    800001e2:	0984a783          	lw	a5,152(s1)
    800001e6:	09c4a703          	lw	a4,156(s1)
    800001ea:	fef700e3          	beq	a4,a5,800001ca <consoleread+0x4c>
    800001ee:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF];
    800001f0:	00014717          	auipc	a4,0x14
    800001f4:	f9070713          	addi	a4,a4,-112 # 80014180 <cons>
    800001f8:	0017869b          	addiw	a3,a5,1
    800001fc:	08d72c23          	sw	a3,152(a4)
    80000200:	07f7f693          	andi	a3,a5,127
    80000204:	9736                	add	a4,a4,a3
    80000206:	01874703          	lbu	a4,24(a4)
    8000020a:	00070a9b          	sext.w	s5,a4

    if(c == C('D')){  // end-of-file
    8000020e:	4691                	li	a3,4
    80000210:	04da8a63          	beq	s5,a3,80000264 <consoleread+0xe6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000214:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000218:	4685                	li	a3,1
    8000021a:	faf40613          	addi	a2,s0,-81
    8000021e:	85d2                	mv	a1,s4
    80000220:	855a                	mv	a0,s6
    80000222:	00002097          	auipc	ra,0x2
    80000226:	420080e7          	jalr	1056(ra) # 80002642 <either_copyout>
    8000022a:	57fd                	li	a5,-1
    8000022c:	04f50863          	beq	a0,a5,8000027c <consoleread+0xfe>
      break;

    dst++;
    80000230:	0a05                	addi	s4,s4,1
    --n;
    80000232:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80000234:	47a9                	li	a5,10
    80000236:	04fa8f63          	beq	s5,a5,80000294 <consoleread+0x116>
    8000023a:	7aa2                	ld	s5,40(sp)
    8000023c:	bfbd                	j	800001ba <consoleread+0x3c>
        release(&cons.lock);
    8000023e:	00014517          	auipc	a0,0x14
    80000242:	f4250513          	addi	a0,a0,-190 # 80014180 <cons>
    80000246:	00001097          	auipc	ra,0x1
    8000024a:	abe080e7          	jalr	-1346(ra) # 80000d04 <release>
        return -1;
    8000024e:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000250:	60e6                	ld	ra,88(sp)
    80000252:	6446                	ld	s0,80(sp)
    80000254:	64a6                	ld	s1,72(sp)
    80000256:	6906                	ld	s2,64(sp)
    80000258:	79e2                	ld	s3,56(sp)
    8000025a:	7a42                	ld	s4,48(sp)
    8000025c:	7b02                	ld	s6,32(sp)
    8000025e:	6be2                	ld	s7,24(sp)
    80000260:	6125                	addi	sp,sp,96
    80000262:	8082                	ret
      if(n < target){
    80000264:	0179fa63          	bgeu	s3,s7,80000278 <consoleread+0xfa>
        cons.r--;
    80000268:	00014717          	auipc	a4,0x14
    8000026c:	faf72823          	sw	a5,-80(a4) # 80014218 <cons+0x98>
    80000270:	7aa2                	ld	s5,40(sp)
    80000272:	a031                	j	8000027e <consoleread+0x100>
    80000274:	f456                	sd	s5,40(sp)
    80000276:	bfad                	j	800001f0 <consoleread+0x72>
    80000278:	7aa2                	ld	s5,40(sp)
    8000027a:	a011                	j	8000027e <consoleread+0x100>
    8000027c:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    8000027e:	00014517          	auipc	a0,0x14
    80000282:	f0250513          	addi	a0,a0,-254 # 80014180 <cons>
    80000286:	00001097          	auipc	ra,0x1
    8000028a:	a7e080e7          	jalr	-1410(ra) # 80000d04 <release>
  return target - n;
    8000028e:	413b853b          	subw	a0,s7,s3
    80000292:	bf7d                	j	80000250 <consoleread+0xd2>
    80000294:	7aa2                	ld	s5,40(sp)
    80000296:	b7e5                	j	8000027e <consoleread+0x100>

0000000080000298 <consputc>:
{
    80000298:	1141                	addi	sp,sp,-16
    8000029a:	e406                	sd	ra,8(sp)
    8000029c:	e022                	sd	s0,0(sp)
    8000029e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    800002a0:	10000793          	li	a5,256
    800002a4:	00f50a63          	beq	a0,a5,800002b8 <consputc+0x20>
    uartputc_sync(c);
    800002a8:	00000097          	auipc	ra,0x0
    800002ac:	58e080e7          	jalr	1422(ra) # 80000836 <uartputc_sync>
}
    800002b0:	60a2                	ld	ra,8(sp)
    800002b2:	6402                	ld	s0,0(sp)
    800002b4:	0141                	addi	sp,sp,16
    800002b6:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002b8:	4521                	li	a0,8
    800002ba:	00000097          	auipc	ra,0x0
    800002be:	57c080e7          	jalr	1404(ra) # 80000836 <uartputc_sync>
    800002c2:	02000513          	li	a0,32
    800002c6:	00000097          	auipc	ra,0x0
    800002ca:	570080e7          	jalr	1392(ra) # 80000836 <uartputc_sync>
    800002ce:	4521                	li	a0,8
    800002d0:	00000097          	auipc	ra,0x0
    800002d4:	566080e7          	jalr	1382(ra) # 80000836 <uartputc_sync>
    800002d8:	bfe1                	j	800002b0 <consputc+0x18>

00000000800002da <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002da:	1101                	addi	sp,sp,-32
    800002dc:	ec06                	sd	ra,24(sp)
    800002de:	e822                	sd	s0,16(sp)
    800002e0:	e426                	sd	s1,8(sp)
    800002e2:	1000                	addi	s0,sp,32
    800002e4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002e6:	00014517          	auipc	a0,0x14
    800002ea:	e9a50513          	addi	a0,a0,-358 # 80014180 <cons>
    800002ee:	00001097          	auipc	ra,0x1
    800002f2:	966080e7          	jalr	-1690(ra) # 80000c54 <acquire>

  switch(c){
    800002f6:	47d5                	li	a5,21
    800002f8:	0af48263          	beq	s1,a5,8000039c <consoleintr+0xc2>
    800002fc:	0297c963          	blt	a5,s1,8000032e <consoleintr+0x54>
    80000300:	47a1                	li	a5,8
    80000302:	0ef48963          	beq	s1,a5,800003f4 <consoleintr+0x11a>
    80000306:	47c1                	li	a5,16
    80000308:	10f49c63          	bne	s1,a5,80000420 <consoleintr+0x146>
  case C('P'):  // Print process list.
    procdump();
    8000030c:	00002097          	auipc	ra,0x2
    80000310:	3e2080e7          	jalr	994(ra) # 800026ee <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000314:	00014517          	auipc	a0,0x14
    80000318:	e6c50513          	addi	a0,a0,-404 # 80014180 <cons>
    8000031c:	00001097          	auipc	ra,0x1
    80000320:	9e8080e7          	jalr	-1560(ra) # 80000d04 <release>
}
    80000324:	60e2                	ld	ra,24(sp)
    80000326:	6442                	ld	s0,16(sp)
    80000328:	64a2                	ld	s1,8(sp)
    8000032a:	6105                	addi	sp,sp,32
    8000032c:	8082                	ret
  switch(c){
    8000032e:	07f00793          	li	a5,127
    80000332:	0cf48163          	beq	s1,a5,800003f4 <consoleintr+0x11a>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000336:	00014717          	auipc	a4,0x14
    8000033a:	e4a70713          	addi	a4,a4,-438 # 80014180 <cons>
    8000033e:	0a072783          	lw	a5,160(a4)
    80000342:	09872703          	lw	a4,152(a4)
    80000346:	9f99                	subw	a5,a5,a4
    80000348:	07f00713          	li	a4,127
    8000034c:	fcf764e3          	bltu	a4,a5,80000314 <consoleintr+0x3a>
      c = (c == '\r') ? '\n' : c;
    80000350:	47b5                	li	a5,13
    80000352:	0cf48a63          	beq	s1,a5,80000426 <consoleintr+0x14c>
      consputc(c);
    80000356:	8526                	mv	a0,s1
    80000358:	00000097          	auipc	ra,0x0
    8000035c:	f40080e7          	jalr	-192(ra) # 80000298 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000360:	00014717          	auipc	a4,0x14
    80000364:	e2070713          	addi	a4,a4,-480 # 80014180 <cons>
    80000368:	0a072683          	lw	a3,160(a4)
    8000036c:	0016879b          	addiw	a5,a3,1
    80000370:	863e                	mv	a2,a5
    80000372:	0af72023          	sw	a5,160(a4)
    80000376:	07f6f693          	andi	a3,a3,127
    8000037a:	9736                	add	a4,a4,a3
    8000037c:	00970c23          	sb	s1,24(a4)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000380:	ff648713          	addi	a4,s1,-10
    80000384:	c779                	beqz	a4,80000452 <consoleintr+0x178>
    80000386:	14f1                	addi	s1,s1,-4
    80000388:	c4e9                	beqz	s1,80000452 <consoleintr+0x178>
    8000038a:	00014797          	auipc	a5,0x14
    8000038e:	e8e7a783          	lw	a5,-370(a5) # 80014218 <cons+0x98>
    80000392:	0807879b          	addiw	a5,a5,128
    80000396:	f6f61fe3          	bne	a2,a5,80000314 <consoleintr+0x3a>
    8000039a:	a865                	j	80000452 <consoleintr+0x178>
    8000039c:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000039e:	00014717          	auipc	a4,0x14
    800003a2:	de270713          	addi	a4,a4,-542 # 80014180 <cons>
    800003a6:	0a072783          	lw	a5,160(a4)
    800003aa:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003ae:	00014497          	auipc	s1,0x14
    800003b2:	dd248493          	addi	s1,s1,-558 # 80014180 <cons>
    while(cons.e != cons.w &&
    800003b6:	4929                	li	s2,10
    800003b8:	02f70a63          	beq	a4,a5,800003ec <consoleintr+0x112>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003bc:	37fd                	addiw	a5,a5,-1
    800003be:	07f7f713          	andi	a4,a5,127
    800003c2:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003c4:	01874703          	lbu	a4,24(a4)
    800003c8:	03270463          	beq	a4,s2,800003f0 <consoleintr+0x116>
      cons.e--;
    800003cc:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003d0:	10000513          	li	a0,256
    800003d4:	00000097          	auipc	ra,0x0
    800003d8:	ec4080e7          	jalr	-316(ra) # 80000298 <consputc>
    while(cons.e != cons.w &&
    800003dc:	0a04a783          	lw	a5,160(s1)
    800003e0:	09c4a703          	lw	a4,156(s1)
    800003e4:	fcf71ce3          	bne	a4,a5,800003bc <consoleintr+0xe2>
    800003e8:	6902                	ld	s2,0(sp)
    800003ea:	b72d                	j	80000314 <consoleintr+0x3a>
    800003ec:	6902                	ld	s2,0(sp)
    800003ee:	b71d                	j	80000314 <consoleintr+0x3a>
    800003f0:	6902                	ld	s2,0(sp)
    800003f2:	b70d                	j	80000314 <consoleintr+0x3a>
    if(cons.e != cons.w){
    800003f4:	00014717          	auipc	a4,0x14
    800003f8:	d8c70713          	addi	a4,a4,-628 # 80014180 <cons>
    800003fc:	0a072783          	lw	a5,160(a4)
    80000400:	09c72703          	lw	a4,156(a4)
    80000404:	f0f708e3          	beq	a4,a5,80000314 <consoleintr+0x3a>
      cons.e--;
    80000408:	37fd                	addiw	a5,a5,-1
    8000040a:	00014717          	auipc	a4,0x14
    8000040e:	e0f72b23          	sw	a5,-490(a4) # 80014220 <cons+0xa0>
      consputc(BACKSPACE);
    80000412:	10000513          	li	a0,256
    80000416:	00000097          	auipc	ra,0x0
    8000041a:	e82080e7          	jalr	-382(ra) # 80000298 <consputc>
    8000041e:	bddd                	j	80000314 <consoleintr+0x3a>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000420:	ee048ae3          	beqz	s1,80000314 <consoleintr+0x3a>
    80000424:	bf09                	j	80000336 <consoleintr+0x5c>
      consputc(c);
    80000426:	4529                	li	a0,10
    80000428:	00000097          	auipc	ra,0x0
    8000042c:	e70080e7          	jalr	-400(ra) # 80000298 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000430:	00014717          	auipc	a4,0x14
    80000434:	d5070713          	addi	a4,a4,-688 # 80014180 <cons>
    80000438:	0a072683          	lw	a3,160(a4)
    8000043c:	0016861b          	addiw	a2,a3,1
    80000440:	87b2                	mv	a5,a2
    80000442:	0ac72023          	sw	a2,160(a4)
    80000446:	07f6f693          	andi	a3,a3,127
    8000044a:	9736                	add	a4,a4,a3
    8000044c:	46a9                	li	a3,10
    8000044e:	00d70c23          	sb	a3,24(a4)
        cons.w = cons.e;
    80000452:	00014717          	auipc	a4,0x14
    80000456:	dcf72523          	sw	a5,-566(a4) # 8001421c <cons+0x9c>
        wakeup(&cons.r);
    8000045a:	00014517          	auipc	a0,0x14
    8000045e:	dbe50513          	addi	a0,a0,-578 # 80014218 <cons+0x98>
    80000462:	00002097          	auipc	ra,0x2
    80000466:	fb8080e7          	jalr	-72(ra) # 8000241a <wakeup>
    8000046a:	b56d                	j	80000314 <consoleintr+0x3a>

000000008000046c <consoleinit>:

void
consoleinit(void)
{
    8000046c:	1141                	addi	sp,sp,-16
    8000046e:	e406                	sd	ra,8(sp)
    80000470:	e022                	sd	s0,0(sp)
    80000472:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000474:	00008597          	auipc	a1,0x8
    80000478:	b8c58593          	addi	a1,a1,-1140 # 80008000 <etext>
    8000047c:	00014517          	auipc	a0,0x14
    80000480:	d0450513          	addi	a0,a0,-764 # 80014180 <cons>
    80000484:	00000097          	auipc	ra,0x0
    80000488:	736080e7          	jalr	1846(ra) # 80000bba <initlock>

  uartinit();
    8000048c:	00000097          	auipc	ra,0x0
    80000490:	350080e7          	jalr	848(ra) # 800007dc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000494:	00025797          	auipc	a5,0x25
    80000498:	68478793          	addi	a5,a5,1668 # 80025b18 <devsw>
    8000049c:	00000717          	auipc	a4,0x0
    800004a0:	ce270713          	addi	a4,a4,-798 # 8000017e <consoleread>
    800004a4:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004a6:	00000717          	auipc	a4,0x0
    800004aa:	c5c70713          	addi	a4,a4,-932 # 80000102 <consolewrite>
    800004ae:	ef98                	sd	a4,24(a5)
}
    800004b0:	60a2                	ld	ra,8(sp)
    800004b2:	6402                	ld	s0,0(sp)
    800004b4:	0141                	addi	sp,sp,16
    800004b6:	8082                	ret

00000000800004b8 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004b8:	7179                	addi	sp,sp,-48
    800004ba:	f406                	sd	ra,40(sp)
    800004bc:	f022                	sd	s0,32(sp)
    800004be:	e84a                	sd	s2,16(sp)
    800004c0:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004c2:	c219                	beqz	a2,800004c8 <printint+0x10>
    800004c4:	08054563          	bltz	a0,8000054e <printint+0x96>
    x = -xx;
  else
    x = xx;
    800004c8:	4301                	li	t1,0

  i = 0;
    800004ca:	fd040913          	addi	s2,s0,-48
    x = xx;
    800004ce:	86ca                	mv	a3,s2
  i = 0;
    800004d0:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004d2:	00008817          	auipc	a6,0x8
    800004d6:	31e80813          	addi	a6,a6,798 # 800087f0 <digits>
    800004da:	88ba                	mv	a7,a4
    800004dc:	0017061b          	addiw	a2,a4,1
    800004e0:	8732                	mv	a4,a2
    800004e2:	02b577bb          	remuw	a5,a0,a1
    800004e6:	1782                	slli	a5,a5,0x20
    800004e8:	9381                	srli	a5,a5,0x20
    800004ea:	97c2                	add	a5,a5,a6
    800004ec:	0007c783          	lbu	a5,0(a5)
    800004f0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004f4:	87aa                	mv	a5,a0
    800004f6:	02b5553b          	divuw	a0,a0,a1
    800004fa:	0685                	addi	a3,a3,1
    800004fc:	fcb7ffe3          	bgeu	a5,a1,800004da <printint+0x22>

  if(sign)
    80000500:	00030c63          	beqz	t1,80000518 <printint+0x60>
    buf[i++] = '-';
    80000504:	fe060793          	addi	a5,a2,-32
    80000508:	00878633          	add	a2,a5,s0
    8000050c:	02d00793          	li	a5,45
    80000510:	fef60823          	sb	a5,-16(a2)
    80000514:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
    80000518:	02e05663          	blez	a4,80000544 <printint+0x8c>
    8000051c:	ec26                	sd	s1,24(sp)
    8000051e:	377d                	addiw	a4,a4,-1
    80000520:	00e904b3          	add	s1,s2,a4
    80000524:	197d                	addi	s2,s2,-1
    80000526:	993a                	add	s2,s2,a4
    80000528:	1702                	slli	a4,a4,0x20
    8000052a:	9301                	srli	a4,a4,0x20
    8000052c:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000530:	0004c503          	lbu	a0,0(s1)
    80000534:	00000097          	auipc	ra,0x0
    80000538:	d64080e7          	jalr	-668(ra) # 80000298 <consputc>
  while(--i >= 0)
    8000053c:	14fd                	addi	s1,s1,-1
    8000053e:	ff2499e3          	bne	s1,s2,80000530 <printint+0x78>
    80000542:	64e2                	ld	s1,24(sp)
}
    80000544:	70a2                	ld	ra,40(sp)
    80000546:	7402                	ld	s0,32(sp)
    80000548:	6942                	ld	s2,16(sp)
    8000054a:	6145                	addi	sp,sp,48
    8000054c:	8082                	ret
    x = -xx;
    8000054e:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000552:	4305                	li	t1,1
    x = -xx;
    80000554:	bf9d                	j	800004ca <printint+0x12>

0000000080000556 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000556:	1101                	addi	sp,sp,-32
    80000558:	ec06                	sd	ra,24(sp)
    8000055a:	e822                	sd	s0,16(sp)
    8000055c:	e426                	sd	s1,8(sp)
    8000055e:	1000                	addi	s0,sp,32
    80000560:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000562:	00014797          	auipc	a5,0x14
    80000566:	cc07af23          	sw	zero,-802(a5) # 80014240 <pr+0x18>
  printf("panic: ");
    8000056a:	00008517          	auipc	a0,0x8
    8000056e:	a9e50513          	addi	a0,a0,-1378 # 80008008 <etext+0x8>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	02e080e7          	jalr	46(ra) # 800005a0 <printf>
  printf(s);
    8000057a:	8526                	mv	a0,s1
    8000057c:	00000097          	auipc	ra,0x0
    80000580:	024080e7          	jalr	36(ra) # 800005a0 <printf>
  printf("\n");
    80000584:	00008517          	auipc	a0,0x8
    80000588:	a8c50513          	addi	a0,a0,-1396 # 80008010 <etext+0x10>
    8000058c:	00000097          	auipc	ra,0x0
    80000590:	014080e7          	jalr	20(ra) # 800005a0 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000594:	4785                	li	a5,1
    80000596:	0000c717          	auipc	a4,0xc
    8000059a:	a6f72523          	sw	a5,-1430(a4) # 8000c000 <panicked>
  for(;;)
    8000059e:	a001                	j	8000059e <panic+0x48>

00000000800005a0 <printf>:
{
    800005a0:	7131                	addi	sp,sp,-192
    800005a2:	fc86                	sd	ra,120(sp)
    800005a4:	f8a2                	sd	s0,112(sp)
    800005a6:	e8d2                	sd	s4,80(sp)
    800005a8:	ec6e                	sd	s11,24(sp)
    800005aa:	0100                	addi	s0,sp,128
    800005ac:	8a2a                	mv	s4,a0
    800005ae:	e40c                	sd	a1,8(s0)
    800005b0:	e810                	sd	a2,16(s0)
    800005b2:	ec14                	sd	a3,24(s0)
    800005b4:	f018                	sd	a4,32(s0)
    800005b6:	f41c                	sd	a5,40(s0)
    800005b8:	03043823          	sd	a6,48(s0)
    800005bc:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c0:	00014d97          	auipc	s11,0x14
    800005c4:	c80dad83          	lw	s11,-896(s11) # 80014240 <pr+0x18>
  if(locking)
    800005c8:	040d9463          	bnez	s11,80000610 <printf+0x70>
  if (fmt == 0)
    800005cc:	040a0b63          	beqz	s4,80000622 <printf+0x82>
  va_start(ap, fmt);
    800005d0:	00840793          	addi	a5,s0,8
    800005d4:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d8:	000a4503          	lbu	a0,0(s4)
    800005dc:	18050c63          	beqz	a0,80000774 <printf+0x1d4>
    800005e0:	f4a6                	sd	s1,104(sp)
    800005e2:	f0ca                	sd	s2,96(sp)
    800005e4:	ecce                	sd	s3,88(sp)
    800005e6:	e4d6                	sd	s5,72(sp)
    800005e8:	e0da                	sd	s6,64(sp)
    800005ea:	fc5e                	sd	s7,56(sp)
    800005ec:	f862                	sd	s8,48(sp)
    800005ee:	f466                	sd	s9,40(sp)
    800005f0:	f06a                	sd	s10,32(sp)
    800005f2:	4981                	li	s3,0
    if(c != '%'){
    800005f4:	02500b13          	li	s6,37
    switch(c){
    800005f8:	07000b93          	li	s7,112
  consputc('x');
    800005fc:	07800c93          	li	s9,120
    80000600:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000602:	00008a97          	auipc	s5,0x8
    80000606:	1eea8a93          	addi	s5,s5,494 # 800087f0 <digits>
    switch(c){
    8000060a:	07300c13          	li	s8,115
    8000060e:	a0b9                	j	8000065c <printf+0xbc>
    acquire(&pr.lock);
    80000610:	00014517          	auipc	a0,0x14
    80000614:	c1850513          	addi	a0,a0,-1000 # 80014228 <pr>
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	63c080e7          	jalr	1596(ra) # 80000c54 <acquire>
    80000620:	b775                	j	800005cc <printf+0x2c>
    80000622:	f4a6                	sd	s1,104(sp)
    80000624:	f0ca                	sd	s2,96(sp)
    80000626:	ecce                	sd	s3,88(sp)
    80000628:	e4d6                	sd	s5,72(sp)
    8000062a:	e0da                	sd	s6,64(sp)
    8000062c:	fc5e                	sd	s7,56(sp)
    8000062e:	f862                	sd	s8,48(sp)
    80000630:	f466                	sd	s9,40(sp)
    80000632:	f06a                	sd	s10,32(sp)
    panic("null fmt");
    80000634:	00008517          	auipc	a0,0x8
    80000638:	9ec50513          	addi	a0,a0,-1556 # 80008020 <etext+0x20>
    8000063c:	00000097          	auipc	ra,0x0
    80000640:	f1a080e7          	jalr	-230(ra) # 80000556 <panic>
      consputc(c);
    80000644:	00000097          	auipc	ra,0x0
    80000648:	c54080e7          	jalr	-940(ra) # 80000298 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000064c:	0019879b          	addiw	a5,s3,1
    80000650:	89be                	mv	s3,a5
    80000652:	97d2                	add	a5,a5,s4
    80000654:	0007c503          	lbu	a0,0(a5)
    80000658:	10050563          	beqz	a0,80000762 <printf+0x1c2>
    if(c != '%'){
    8000065c:	ff6514e3          	bne	a0,s6,80000644 <printf+0xa4>
    c = fmt[++i] & 0xff;
    80000660:	0019879b          	addiw	a5,s3,1
    80000664:	89be                	mv	s3,a5
    80000666:	97d2                	add	a5,a5,s4
    80000668:	0007c783          	lbu	a5,0(a5)
    8000066c:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000670:	10078a63          	beqz	a5,80000784 <printf+0x1e4>
    switch(c){
    80000674:	05778a63          	beq	a5,s7,800006c8 <printf+0x128>
    80000678:	02fbf463          	bgeu	s7,a5,800006a0 <printf+0x100>
    8000067c:	09878763          	beq	a5,s8,8000070a <printf+0x16a>
    80000680:	0d979663          	bne	a5,s9,8000074c <printf+0x1ac>
      printint(va_arg(ap, int), 16, 1);
    80000684:	f8843783          	ld	a5,-120(s0)
    80000688:	00878713          	addi	a4,a5,8
    8000068c:	f8e43423          	sd	a4,-120(s0)
    80000690:	4605                	li	a2,1
    80000692:	85ea                	mv	a1,s10
    80000694:	4388                	lw	a0,0(a5)
    80000696:	00000097          	auipc	ra,0x0
    8000069a:	e22080e7          	jalr	-478(ra) # 800004b8 <printint>
      break;
    8000069e:	b77d                	j	8000064c <printf+0xac>
    switch(c){
    800006a0:	0b678063          	beq	a5,s6,80000740 <printf+0x1a0>
    800006a4:	06400713          	li	a4,100
    800006a8:	0ae79263          	bne	a5,a4,8000074c <printf+0x1ac>
      printint(va_arg(ap, int), 10, 1);
    800006ac:	f8843783          	ld	a5,-120(s0)
    800006b0:	00878713          	addi	a4,a5,8
    800006b4:	f8e43423          	sd	a4,-120(s0)
    800006b8:	4605                	li	a2,1
    800006ba:	45a9                	li	a1,10
    800006bc:	4388                	lw	a0,0(a5)
    800006be:	00000097          	auipc	ra,0x0
    800006c2:	dfa080e7          	jalr	-518(ra) # 800004b8 <printint>
      break;
    800006c6:	b759                	j	8000064c <printf+0xac>
      printptr(va_arg(ap, uint64));
    800006c8:	f8843783          	ld	a5,-120(s0)
    800006cc:	00878713          	addi	a4,a5,8
    800006d0:	f8e43423          	sd	a4,-120(s0)
    800006d4:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006d8:	03000513          	li	a0,48
    800006dc:	00000097          	auipc	ra,0x0
    800006e0:	bbc080e7          	jalr	-1092(ra) # 80000298 <consputc>
  consputc('x');
    800006e4:	8566                	mv	a0,s9
    800006e6:	00000097          	auipc	ra,0x0
    800006ea:	bb2080e7          	jalr	-1102(ra) # 80000298 <consputc>
    800006ee:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006f0:	03c95793          	srli	a5,s2,0x3c
    800006f4:	97d6                	add	a5,a5,s5
    800006f6:	0007c503          	lbu	a0,0(a5)
    800006fa:	00000097          	auipc	ra,0x0
    800006fe:	b9e080e7          	jalr	-1122(ra) # 80000298 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000702:	0912                	slli	s2,s2,0x4
    80000704:	34fd                	addiw	s1,s1,-1
    80000706:	f4ed                	bnez	s1,800006f0 <printf+0x150>
    80000708:	b791                	j	8000064c <printf+0xac>
      if((s = va_arg(ap, char*)) == 0)
    8000070a:	f8843783          	ld	a5,-120(s0)
    8000070e:	00878713          	addi	a4,a5,8
    80000712:	f8e43423          	sd	a4,-120(s0)
    80000716:	6384                	ld	s1,0(a5)
    80000718:	cc89                	beqz	s1,80000732 <printf+0x192>
      for(; *s; s++)
    8000071a:	0004c503          	lbu	a0,0(s1)
    8000071e:	d51d                	beqz	a0,8000064c <printf+0xac>
        consputc(*s);
    80000720:	00000097          	auipc	ra,0x0
    80000724:	b78080e7          	jalr	-1160(ra) # 80000298 <consputc>
      for(; *s; s++)
    80000728:	0485                	addi	s1,s1,1
    8000072a:	0004c503          	lbu	a0,0(s1)
    8000072e:	f96d                	bnez	a0,80000720 <printf+0x180>
    80000730:	bf31                	j	8000064c <printf+0xac>
        s = "(null)";
    80000732:	00008497          	auipc	s1,0x8
    80000736:	8e648493          	addi	s1,s1,-1818 # 80008018 <etext+0x18>
      for(; *s; s++)
    8000073a:	02800513          	li	a0,40
    8000073e:	b7cd                	j	80000720 <printf+0x180>
      consputc('%');
    80000740:	855a                	mv	a0,s6
    80000742:	00000097          	auipc	ra,0x0
    80000746:	b56080e7          	jalr	-1194(ra) # 80000298 <consputc>
      break;
    8000074a:	b709                	j	8000064c <printf+0xac>
      consputc('%');
    8000074c:	855a                	mv	a0,s6
    8000074e:	00000097          	auipc	ra,0x0
    80000752:	b4a080e7          	jalr	-1206(ra) # 80000298 <consputc>
      consputc(c);
    80000756:	8526                	mv	a0,s1
    80000758:	00000097          	auipc	ra,0x0
    8000075c:	b40080e7          	jalr	-1216(ra) # 80000298 <consputc>
      break;
    80000760:	b5f5                	j	8000064c <printf+0xac>
    80000762:	74a6                	ld	s1,104(sp)
    80000764:	7906                	ld	s2,96(sp)
    80000766:	69e6                	ld	s3,88(sp)
    80000768:	6aa6                	ld	s5,72(sp)
    8000076a:	6b06                	ld	s6,64(sp)
    8000076c:	7be2                	ld	s7,56(sp)
    8000076e:	7c42                	ld	s8,48(sp)
    80000770:	7ca2                	ld	s9,40(sp)
    80000772:	7d02                	ld	s10,32(sp)
  if(locking)
    80000774:	020d9263          	bnez	s11,80000798 <printf+0x1f8>
}
    80000778:	70e6                	ld	ra,120(sp)
    8000077a:	7446                	ld	s0,112(sp)
    8000077c:	6a46                	ld	s4,80(sp)
    8000077e:	6de2                	ld	s11,24(sp)
    80000780:	6129                	addi	sp,sp,192
    80000782:	8082                	ret
    80000784:	74a6                	ld	s1,104(sp)
    80000786:	7906                	ld	s2,96(sp)
    80000788:	69e6                	ld	s3,88(sp)
    8000078a:	6aa6                	ld	s5,72(sp)
    8000078c:	6b06                	ld	s6,64(sp)
    8000078e:	7be2                	ld	s7,56(sp)
    80000790:	7c42                	ld	s8,48(sp)
    80000792:	7ca2                	ld	s9,40(sp)
    80000794:	7d02                	ld	s10,32(sp)
    80000796:	bff9                	j	80000774 <printf+0x1d4>
    release(&pr.lock);
    80000798:	00014517          	auipc	a0,0x14
    8000079c:	a9050513          	addi	a0,a0,-1392 # 80014228 <pr>
    800007a0:	00000097          	auipc	ra,0x0
    800007a4:	564080e7          	jalr	1380(ra) # 80000d04 <release>
}
    800007a8:	bfc1                	j	80000778 <printf+0x1d8>

00000000800007aa <printfinit>:
    ;
}

void
printfinit(void)
{
    800007aa:	1141                	addi	sp,sp,-16
    800007ac:	e406                	sd	ra,8(sp)
    800007ae:	e022                	sd	s0,0(sp)
    800007b0:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    800007b2:	00008597          	auipc	a1,0x8
    800007b6:	87e58593          	addi	a1,a1,-1922 # 80008030 <etext+0x30>
    800007ba:	00014517          	auipc	a0,0x14
    800007be:	a6e50513          	addi	a0,a0,-1426 # 80014228 <pr>
    800007c2:	00000097          	auipc	ra,0x0
    800007c6:	3f8080e7          	jalr	1016(ra) # 80000bba <initlock>
  pr.locking = 1;
    800007ca:	4785                	li	a5,1
    800007cc:	00014717          	auipc	a4,0x14
    800007d0:	a6f72a23          	sw	a5,-1420(a4) # 80014240 <pr+0x18>
}
    800007d4:	60a2                	ld	ra,8(sp)
    800007d6:	6402                	ld	s0,0(sp)
    800007d8:	0141                	addi	sp,sp,16
    800007da:	8082                	ret

00000000800007dc <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007dc:	1141                	addi	sp,sp,-16
    800007de:	e406                	sd	ra,8(sp)
    800007e0:	e022                	sd	s0,0(sp)
    800007e2:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007e4:	100007b7          	lui	a5,0x10000
    800007e8:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ec:	10000737          	lui	a4,0x10000
    800007f0:	f8000693          	li	a3,-128
    800007f4:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007f8:	468d                	li	a3,3
    800007fa:	10000637          	lui	a2,0x10000
    800007fe:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000802:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000806:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000080a:	8732                	mv	a4,a2
    8000080c:	461d                	li	a2,7
    8000080e:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000812:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000816:	00008597          	auipc	a1,0x8
    8000081a:	82258593          	addi	a1,a1,-2014 # 80008038 <etext+0x38>
    8000081e:	00014517          	auipc	a0,0x14
    80000822:	a2a50513          	addi	a0,a0,-1494 # 80014248 <uart_tx_lock>
    80000826:	00000097          	auipc	ra,0x0
    8000082a:	394080e7          	jalr	916(ra) # 80000bba <initlock>
}
    8000082e:	60a2                	ld	ra,8(sp)
    80000830:	6402                	ld	s0,0(sp)
    80000832:	0141                	addi	sp,sp,16
    80000834:	8082                	ret

0000000080000836 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000836:	1101                	addi	sp,sp,-32
    80000838:	ec06                	sd	ra,24(sp)
    8000083a:	e822                	sd	s0,16(sp)
    8000083c:	e426                	sd	s1,8(sp)
    8000083e:	1000                	addi	s0,sp,32
    80000840:	84aa                	mv	s1,a0
  push_off();
    80000842:	00000097          	auipc	ra,0x0
    80000846:	3c2080e7          	jalr	962(ra) # 80000c04 <push_off>

  if(panicked){
    8000084a:	0000b797          	auipc	a5,0xb
    8000084e:	7b67a783          	lw	a5,1974(a5) # 8000c000 <panicked>
    80000852:	eb85                	bnez	a5,80000882 <uartputc_sync+0x4c>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000854:	10000737          	lui	a4,0x10000
    80000858:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    8000085a:	00074783          	lbu	a5,0(a4)
    8000085e:	0207f793          	andi	a5,a5,32
    80000862:	dfe5                	beqz	a5,8000085a <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000864:	0ff4f513          	zext.b	a0,s1
    80000868:	100007b7          	lui	a5,0x10000
    8000086c:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000870:	00000097          	auipc	ra,0x0
    80000874:	438080e7          	jalr	1080(ra) # 80000ca8 <pop_off>
}
    80000878:	60e2                	ld	ra,24(sp)
    8000087a:	6442                	ld	s0,16(sp)
    8000087c:	64a2                	ld	s1,8(sp)
    8000087e:	6105                	addi	sp,sp,32
    80000880:	8082                	ret
    for(;;)
    80000882:	a001                	j	80000882 <uartputc_sync+0x4c>

0000000080000884 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000884:	0000b797          	auipc	a5,0xb
    80000888:	7847b783          	ld	a5,1924(a5) # 8000c008 <uart_tx_r>
    8000088c:	0000b717          	auipc	a4,0xb
    80000890:	78473703          	ld	a4,1924(a4) # 8000c010 <uart_tx_w>
    80000894:	06f70f63          	beq	a4,a5,80000912 <uartstart+0x8e>
{
    80000898:	7139                	addi	sp,sp,-64
    8000089a:	fc06                	sd	ra,56(sp)
    8000089c:	f822                	sd	s0,48(sp)
    8000089e:	f426                	sd	s1,40(sp)
    800008a0:	f04a                	sd	s2,32(sp)
    800008a2:	ec4e                	sd	s3,24(sp)
    800008a4:	e852                	sd	s4,16(sp)
    800008a6:	e456                	sd	s5,8(sp)
    800008a8:	e05a                	sd	s6,0(sp)
    800008aa:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008ac:	10000937          	lui	s2,0x10000
    800008b0:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008b2:	00014a97          	auipc	s5,0x14
    800008b6:	996a8a93          	addi	s5,s5,-1642 # 80014248 <uart_tx_lock>
    uart_tx_r += 1;
    800008ba:	0000b497          	auipc	s1,0xb
    800008be:	74e48493          	addi	s1,s1,1870 # 8000c008 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008c2:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008c6:	0000b997          	auipc	s3,0xb
    800008ca:	74a98993          	addi	s3,s3,1866 # 8000c010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008ce:	00094703          	lbu	a4,0(s2)
    800008d2:	02077713          	andi	a4,a4,32
    800008d6:	c705                	beqz	a4,800008fe <uartstart+0x7a>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008d8:	01f7f713          	andi	a4,a5,31
    800008dc:	9756                	add	a4,a4,s5
    800008de:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008e2:	0785                	addi	a5,a5,1
    800008e4:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008e6:	8526                	mv	a0,s1
    800008e8:	00002097          	auipc	ra,0x2
    800008ec:	b32080e7          	jalr	-1230(ra) # 8000241a <wakeup>
    WriteReg(THR, c);
    800008f0:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    800008f4:	609c                	ld	a5,0(s1)
    800008f6:	0009b703          	ld	a4,0(s3)
    800008fa:	fcf71ae3          	bne	a4,a5,800008ce <uartstart+0x4a>
  }
}
    800008fe:	70e2                	ld	ra,56(sp)
    80000900:	7442                	ld	s0,48(sp)
    80000902:	74a2                	ld	s1,40(sp)
    80000904:	7902                	ld	s2,32(sp)
    80000906:	69e2                	ld	s3,24(sp)
    80000908:	6a42                	ld	s4,16(sp)
    8000090a:	6aa2                	ld	s5,8(sp)
    8000090c:	6b02                	ld	s6,0(sp)
    8000090e:	6121                	addi	sp,sp,64
    80000910:	8082                	ret
    80000912:	8082                	ret

0000000080000914 <uartputc>:
{
    80000914:	7179                	addi	sp,sp,-48
    80000916:	f406                	sd	ra,40(sp)
    80000918:	f022                	sd	s0,32(sp)
    8000091a:	e052                	sd	s4,0(sp)
    8000091c:	1800                	addi	s0,sp,48
    8000091e:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80000920:	00014517          	auipc	a0,0x14
    80000924:	92850513          	addi	a0,a0,-1752 # 80014248 <uart_tx_lock>
    80000928:	00000097          	auipc	ra,0x0
    8000092c:	32c080e7          	jalr	812(ra) # 80000c54 <acquire>
  if(panicked){
    80000930:	0000b797          	auipc	a5,0xb
    80000934:	6d07a783          	lw	a5,1744(a5) # 8000c000 <panicked>
    80000938:	c391                	beqz	a5,8000093c <uartputc+0x28>
    for(;;)
    8000093a:	a001                	j	8000093a <uartputc+0x26>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000093c:	0000b717          	auipc	a4,0xb
    80000940:	6d473703          	ld	a4,1748(a4) # 8000c010 <uart_tx_w>
    80000944:	0000b797          	auipc	a5,0xb
    80000948:	6c47b783          	ld	a5,1732(a5) # 8000c008 <uart_tx_r>
    8000094c:	02078793          	addi	a5,a5,32
    80000950:	04e79163          	bne	a5,a4,80000992 <uartputc+0x7e>
    80000954:	ec26                	sd	s1,24(sp)
    80000956:	e84a                	sd	s2,16(sp)
    80000958:	e44e                	sd	s3,8(sp)
      sleep(&uart_tx_r, &uart_tx_lock);
    8000095a:	00014997          	auipc	s3,0x14
    8000095e:	8ee98993          	addi	s3,s3,-1810 # 80014248 <uart_tx_lock>
    80000962:	0000b497          	auipc	s1,0xb
    80000966:	6a648493          	addi	s1,s1,1702 # 8000c008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000096a:	0000b917          	auipc	s2,0xb
    8000096e:	6a690913          	addi	s2,s2,1702 # 8000c010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000972:	85ce                	mv	a1,s3
    80000974:	8526                	mv	a0,s1
    80000976:	00002097          	auipc	ra,0x2
    8000097a:	91e080e7          	jalr	-1762(ra) # 80002294 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000097e:	00093703          	ld	a4,0(s2)
    80000982:	609c                	ld	a5,0(s1)
    80000984:	02078793          	addi	a5,a5,32
    80000988:	fee785e3          	beq	a5,a4,80000972 <uartputc+0x5e>
    8000098c:	64e2                	ld	s1,24(sp)
    8000098e:	6942                	ld	s2,16(sp)
    80000990:	69a2                	ld	s3,8(sp)
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000992:	01f77693          	andi	a3,a4,31
    80000996:	00014797          	auipc	a5,0x14
    8000099a:	8b278793          	addi	a5,a5,-1870 # 80014248 <uart_tx_lock>
    8000099e:	97b6                	add	a5,a5,a3
    800009a0:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    800009a4:	0705                	addi	a4,a4,1
    800009a6:	0000b797          	auipc	a5,0xb
    800009aa:	66e7b523          	sd	a4,1642(a5) # 8000c010 <uart_tx_w>
      uartstart();
    800009ae:	00000097          	auipc	ra,0x0
    800009b2:	ed6080e7          	jalr	-298(ra) # 80000884 <uartstart>
      release(&uart_tx_lock);
    800009b6:	00014517          	auipc	a0,0x14
    800009ba:	89250513          	addi	a0,a0,-1902 # 80014248 <uart_tx_lock>
    800009be:	00000097          	auipc	ra,0x0
    800009c2:	346080e7          	jalr	838(ra) # 80000d04 <release>
}
    800009c6:	70a2                	ld	ra,40(sp)
    800009c8:	7402                	ld	s0,32(sp)
    800009ca:	6a02                	ld	s4,0(sp)
    800009cc:	6145                	addi	sp,sp,48
    800009ce:	8082                	ret

00000000800009d0 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009d0:	1141                	addi	sp,sp,-16
    800009d2:	e406                	sd	ra,8(sp)
    800009d4:	e022                	sd	s0,0(sp)
    800009d6:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009d8:	100007b7          	lui	a5,0x10000
    800009dc:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009e0:	8b85                	andi	a5,a5,1
    800009e2:	cb89                	beqz	a5,800009f4 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009e4:	100007b7          	lui	a5,0x10000
    800009e8:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009ec:	60a2                	ld	ra,8(sp)
    800009ee:	6402                	ld	s0,0(sp)
    800009f0:	0141                	addi	sp,sp,16
    800009f2:	8082                	ret
    return -1;
    800009f4:	557d                	li	a0,-1
    800009f6:	bfdd                	j	800009ec <uartgetc+0x1c>

00000000800009f8 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009f8:	1101                	addi	sp,sp,-32
    800009fa:	ec06                	sd	ra,24(sp)
    800009fc:	e822                	sd	s0,16(sp)
    800009fe:	e426                	sd	s1,8(sp)
    80000a00:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a02:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a04:	00000097          	auipc	ra,0x0
    80000a08:	fcc080e7          	jalr	-52(ra) # 800009d0 <uartgetc>
    if(c == -1)
    80000a0c:	00950763          	beq	a0,s1,80000a1a <uartintr+0x22>
      break;
    consoleintr(c);
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	8ca080e7          	jalr	-1846(ra) # 800002da <consoleintr>
  while(1){
    80000a18:	b7f5                	j	80000a04 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a1a:	00014517          	auipc	a0,0x14
    80000a1e:	82e50513          	addi	a0,a0,-2002 # 80014248 <uart_tx_lock>
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	232080e7          	jalr	562(ra) # 80000c54 <acquire>
  uartstart();
    80000a2a:	00000097          	auipc	ra,0x0
    80000a2e:	e5a080e7          	jalr	-422(ra) # 80000884 <uartstart>
  release(&uart_tx_lock);
    80000a32:	00014517          	auipc	a0,0x14
    80000a36:	81650513          	addi	a0,a0,-2026 # 80014248 <uart_tx_lock>
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	2ca080e7          	jalr	714(ra) # 80000d04 <release>
}
    80000a42:	60e2                	ld	ra,24(sp)
    80000a44:	6442                	ld	s0,16(sp)
    80000a46:	64a2                	ld	s1,8(sp)
    80000a48:	6105                	addi	sp,sp,32
    80000a4a:	8082                	ret

0000000080000a4c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a4c:	1101                	addi	sp,sp,-32
    80000a4e:	ec06                	sd	ra,24(sp)
    80000a50:	e822                	sd	s0,16(sp)
    80000a52:	e426                	sd	s1,8(sp)
    80000a54:	e04a                	sd	s2,0(sp)
    80000a56:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a58:	00029797          	auipc	a5,0x29
    80000a5c:	5a878793          	addi	a5,a5,1448 # 8002a000 <end>
    80000a60:	00f53733          	sltu	a4,a0,a5
    80000a64:	47c5                	li	a5,17
    80000a66:	07ee                	slli	a5,a5,0x1b
    80000a68:	17fd                	addi	a5,a5,-1
    80000a6a:	00a7b7b3          	sltu	a5,a5,a0
    80000a6e:	8fd9                	or	a5,a5,a4
    80000a70:	e7a1                	bnez	a5,80000ab8 <kfree+0x6c>
    80000a72:	84aa                	mv	s1,a0
    80000a74:	03451793          	slli	a5,a0,0x34
    80000a78:	e3a1                	bnez	a5,80000ab8 <kfree+0x6c>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a7a:	6605                	lui	a2,0x1
    80000a7c:	4585                	li	a1,1
    80000a7e:	00000097          	auipc	ra,0x0
    80000a82:	2ce080e7          	jalr	718(ra) # 80000d4c <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a86:	00013917          	auipc	s2,0x13
    80000a8a:	7fa90913          	addi	s2,s2,2042 # 80014280 <kmem>
    80000a8e:	854a                	mv	a0,s2
    80000a90:	00000097          	auipc	ra,0x0
    80000a94:	1c4080e7          	jalr	452(ra) # 80000c54 <acquire>
  r->next = kmem.freelist;
    80000a98:	01893783          	ld	a5,24(s2)
    80000a9c:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a9e:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000aa2:	854a                	mv	a0,s2
    80000aa4:	00000097          	auipc	ra,0x0
    80000aa8:	260080e7          	jalr	608(ra) # 80000d04 <release>
}
    80000aac:	60e2                	ld	ra,24(sp)
    80000aae:	6442                	ld	s0,16(sp)
    80000ab0:	64a2                	ld	s1,8(sp)
    80000ab2:	6902                	ld	s2,0(sp)
    80000ab4:	6105                	addi	sp,sp,32
    80000ab6:	8082                	ret
    panic("kfree");
    80000ab8:	00007517          	auipc	a0,0x7
    80000abc:	58850513          	addi	a0,a0,1416 # 80008040 <etext+0x40>
    80000ac0:	00000097          	auipc	ra,0x0
    80000ac4:	a96080e7          	jalr	-1386(ra) # 80000556 <panic>

0000000080000ac8 <freerange>:
{
    80000ac8:	7179                	addi	sp,sp,-48
    80000aca:	f406                	sd	ra,40(sp)
    80000acc:	f022                	sd	s0,32(sp)
    80000ace:	ec26                	sd	s1,24(sp)
    80000ad0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ad2:	6785                	lui	a5,0x1
    80000ad4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ad8:	00e504b3          	add	s1,a0,a4
    80000adc:	777d                	lui	a4,0xfffff
    80000ade:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae0:	94be                	add	s1,s1,a5
    80000ae2:	0295e463          	bltu	a1,s1,80000b0a <freerange+0x42>
    80000ae6:	e84a                	sd	s2,16(sp)
    80000ae8:	e44e                	sd	s3,8(sp)
    80000aea:	e052                	sd	s4,0(sp)
    80000aec:	892e                	mv	s2,a1
    kfree(p);
    80000aee:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af0:	89be                	mv	s3,a5
    kfree(p);
    80000af2:	01448533          	add	a0,s1,s4
    80000af6:	00000097          	auipc	ra,0x0
    80000afa:	f56080e7          	jalr	-170(ra) # 80000a4c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000afe:	94ce                	add	s1,s1,s3
    80000b00:	fe9979e3          	bgeu	s2,s1,80000af2 <freerange+0x2a>
    80000b04:	6942                	ld	s2,16(sp)
    80000b06:	69a2                	ld	s3,8(sp)
    80000b08:	6a02                	ld	s4,0(sp)
}
    80000b0a:	70a2                	ld	ra,40(sp)
    80000b0c:	7402                	ld	s0,32(sp)
    80000b0e:	64e2                	ld	s1,24(sp)
    80000b10:	6145                	addi	sp,sp,48
    80000b12:	8082                	ret

0000000080000b14 <kinit>:
{
    80000b14:	1141                	addi	sp,sp,-16
    80000b16:	e406                	sd	ra,8(sp)
    80000b18:	e022                	sd	s0,0(sp)
    80000b1a:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b1c:	00007597          	auipc	a1,0x7
    80000b20:	52c58593          	addi	a1,a1,1324 # 80008048 <etext+0x48>
    80000b24:	00013517          	auipc	a0,0x13
    80000b28:	75c50513          	addi	a0,a0,1884 # 80014280 <kmem>
    80000b2c:	00000097          	auipc	ra,0x0
    80000b30:	08e080e7          	jalr	142(ra) # 80000bba <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b34:	45c5                	li	a1,17
    80000b36:	05ee                	slli	a1,a1,0x1b
    80000b38:	00029517          	auipc	a0,0x29
    80000b3c:	4c850513          	addi	a0,a0,1224 # 8002a000 <end>
    80000b40:	00000097          	auipc	ra,0x0
    80000b44:	f88080e7          	jalr	-120(ra) # 80000ac8 <freerange>
}
    80000b48:	60a2                	ld	ra,8(sp)
    80000b4a:	6402                	ld	s0,0(sp)
    80000b4c:	0141                	addi	sp,sp,16
    80000b4e:	8082                	ret

0000000080000b50 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b50:	1101                	addi	sp,sp,-32
    80000b52:	ec06                	sd	ra,24(sp)
    80000b54:	e822                	sd	s0,16(sp)
    80000b56:	e426                	sd	s1,8(sp)
    80000b58:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b5a:	00013517          	auipc	a0,0x13
    80000b5e:	72650513          	addi	a0,a0,1830 # 80014280 <kmem>
    80000b62:	00000097          	auipc	ra,0x0
    80000b66:	0f2080e7          	jalr	242(ra) # 80000c54 <acquire>
  r = kmem.freelist;
    80000b6a:	00013497          	auipc	s1,0x13
    80000b6e:	72e4b483          	ld	s1,1838(s1) # 80014298 <kmem+0x18>
  if(r)
    80000b72:	c89d                	beqz	s1,80000ba8 <kalloc+0x58>
    kmem.freelist = r->next;
    80000b74:	609c                	ld	a5,0(s1)
    80000b76:	00013717          	auipc	a4,0x13
    80000b7a:	72f73123          	sd	a5,1826(a4) # 80014298 <kmem+0x18>
  release(&kmem.lock);
    80000b7e:	00013517          	auipc	a0,0x13
    80000b82:	70250513          	addi	a0,a0,1794 # 80014280 <kmem>
    80000b86:	00000097          	auipc	ra,0x0
    80000b8a:	17e080e7          	jalr	382(ra) # 80000d04 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b8e:	6605                	lui	a2,0x1
    80000b90:	4595                	li	a1,5
    80000b92:	8526                	mv	a0,s1
    80000b94:	00000097          	auipc	ra,0x0
    80000b98:	1b8080e7          	jalr	440(ra) # 80000d4c <memset>
  return (void*)r;
}
    80000b9c:	8526                	mv	a0,s1
    80000b9e:	60e2                	ld	ra,24(sp)
    80000ba0:	6442                	ld	s0,16(sp)
    80000ba2:	64a2                	ld	s1,8(sp)
    80000ba4:	6105                	addi	sp,sp,32
    80000ba6:	8082                	ret
  release(&kmem.lock);
    80000ba8:	00013517          	auipc	a0,0x13
    80000bac:	6d850513          	addi	a0,a0,1752 # 80014280 <kmem>
    80000bb0:	00000097          	auipc	ra,0x0
    80000bb4:	154080e7          	jalr	340(ra) # 80000d04 <release>
  if(r)
    80000bb8:	b7d5                	j	80000b9c <kalloc+0x4c>

0000000080000bba <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000bba:	1141                	addi	sp,sp,-16
    80000bbc:	e406                	sd	ra,8(sp)
    80000bbe:	e022                	sd	s0,0(sp)
    80000bc0:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bc2:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bc4:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bc8:	00053823          	sd	zero,16(a0)
}
    80000bcc:	60a2                	ld	ra,8(sp)
    80000bce:	6402                	ld	s0,0(sp)
    80000bd0:	0141                	addi	sp,sp,16
    80000bd2:	8082                	ret

0000000080000bd4 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bd4:	411c                	lw	a5,0(a0)
    80000bd6:	e399                	bnez	a5,80000bdc <holding+0x8>
    80000bd8:	4501                	li	a0,0
  return r;
}
    80000bda:	8082                	ret
{
    80000bdc:	1101                	addi	sp,sp,-32
    80000bde:	ec06                	sd	ra,24(sp)
    80000be0:	e822                	sd	s0,16(sp)
    80000be2:	e426                	sd	s1,8(sp)
    80000be4:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000be6:	691c                	ld	a5,16(a0)
    80000be8:	84be                	mv	s1,a5
    80000bea:	00001097          	auipc	ra,0x1
    80000bee:	e7c080e7          	jalr	-388(ra) # 80001a66 <mycpu>
    80000bf2:	40a48533          	sub	a0,s1,a0
    80000bf6:	00153513          	seqz	a0,a0
}
    80000bfa:	60e2                	ld	ra,24(sp)
    80000bfc:	6442                	ld	s0,16(sp)
    80000bfe:	64a2                	ld	s1,8(sp)
    80000c00:	6105                	addi	sp,sp,32
    80000c02:	8082                	ret

0000000080000c04 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c04:	1101                	addi	sp,sp,-32
    80000c06:	ec06                	sd	ra,24(sp)
    80000c08:	e822                	sd	s0,16(sp)
    80000c0a:	e426                	sd	s1,8(sp)
    80000c0c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c0e:	100027f3          	csrr	a5,sstatus
    80000c12:	84be                	mv	s1,a5
    80000c14:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c18:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c1a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c1e:	00001097          	auipc	ra,0x1
    80000c22:	e48080e7          	jalr	-440(ra) # 80001a66 <mycpu>
    80000c26:	5d3c                	lw	a5,120(a0)
    80000c28:	cf89                	beqz	a5,80000c42 <push_off+0x3e>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c2a:	00001097          	auipc	ra,0x1
    80000c2e:	e3c080e7          	jalr	-452(ra) # 80001a66 <mycpu>
    80000c32:	5d3c                	lw	a5,120(a0)
    80000c34:	2785                	addiw	a5,a5,1
    80000c36:	dd3c                	sw	a5,120(a0)
}
    80000c38:	60e2                	ld	ra,24(sp)
    80000c3a:	6442                	ld	s0,16(sp)
    80000c3c:	64a2                	ld	s1,8(sp)
    80000c3e:	6105                	addi	sp,sp,32
    80000c40:	8082                	ret
    mycpu()->intena = old;
    80000c42:	00001097          	auipc	ra,0x1
    80000c46:	e24080e7          	jalr	-476(ra) # 80001a66 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c4a:	0014d793          	srli	a5,s1,0x1
    80000c4e:	8b85                	andi	a5,a5,1
    80000c50:	dd7c                	sw	a5,124(a0)
    80000c52:	bfe1                	j	80000c2a <push_off+0x26>

0000000080000c54 <acquire>:
{
    80000c54:	1101                	addi	sp,sp,-32
    80000c56:	ec06                	sd	ra,24(sp)
    80000c58:	e822                	sd	s0,16(sp)
    80000c5a:	e426                	sd	s1,8(sp)
    80000c5c:	1000                	addi	s0,sp,32
    80000c5e:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c60:	00000097          	auipc	ra,0x0
    80000c64:	fa4080e7          	jalr	-92(ra) # 80000c04 <push_off>
  if(holding(lk))
    80000c68:	8526                	mv	a0,s1
    80000c6a:	00000097          	auipc	ra,0x0
    80000c6e:	f6a080e7          	jalr	-150(ra) # 80000bd4 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c72:	4705                	li	a4,1
  if(holding(lk))
    80000c74:	e115                	bnez	a0,80000c98 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c76:	87ba                	mv	a5,a4
    80000c78:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c7c:	2781                	sext.w	a5,a5
    80000c7e:	ffe5                	bnez	a5,80000c76 <acquire+0x22>
  __sync_synchronize();
    80000c80:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c84:	00001097          	auipc	ra,0x1
    80000c88:	de2080e7          	jalr	-542(ra) # 80001a66 <mycpu>
    80000c8c:	e888                	sd	a0,16(s1)
}
    80000c8e:	60e2                	ld	ra,24(sp)
    80000c90:	6442                	ld	s0,16(sp)
    80000c92:	64a2                	ld	s1,8(sp)
    80000c94:	6105                	addi	sp,sp,32
    80000c96:	8082                	ret
    panic("acquire");
    80000c98:	00007517          	auipc	a0,0x7
    80000c9c:	3b850513          	addi	a0,a0,952 # 80008050 <etext+0x50>
    80000ca0:	00000097          	auipc	ra,0x0
    80000ca4:	8b6080e7          	jalr	-1866(ra) # 80000556 <panic>

0000000080000ca8 <pop_off>:

void
pop_off(void)
{
    80000ca8:	1141                	addi	sp,sp,-16
    80000caa:	e406                	sd	ra,8(sp)
    80000cac:	e022                	sd	s0,0(sp)
    80000cae:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cb0:	00001097          	auipc	ra,0x1
    80000cb4:	db6080e7          	jalr	-586(ra) # 80001a66 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cb8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000cbc:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000cbe:	e39d                	bnez	a5,80000ce4 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000cc0:	5d3c                	lw	a5,120(a0)
    80000cc2:	02f05963          	blez	a5,80000cf4 <pop_off+0x4c>
    panic("pop_off");
  c->noff -= 1;
    80000cc6:	37fd                	addiw	a5,a5,-1
    80000cc8:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cca:	eb89                	bnez	a5,80000cdc <pop_off+0x34>
    80000ccc:	5d7c                	lw	a5,124(a0)
    80000cce:	c799                	beqz	a5,80000cdc <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cd0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cd4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cd8:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cdc:	60a2                	ld	ra,8(sp)
    80000cde:	6402                	ld	s0,0(sp)
    80000ce0:	0141                	addi	sp,sp,16
    80000ce2:	8082                	ret
    panic("pop_off - interruptible");
    80000ce4:	00007517          	auipc	a0,0x7
    80000ce8:	37450513          	addi	a0,a0,884 # 80008058 <etext+0x58>
    80000cec:	00000097          	auipc	ra,0x0
    80000cf0:	86a080e7          	jalr	-1942(ra) # 80000556 <panic>
    panic("pop_off");
    80000cf4:	00007517          	auipc	a0,0x7
    80000cf8:	37c50513          	addi	a0,a0,892 # 80008070 <etext+0x70>
    80000cfc:	00000097          	auipc	ra,0x0
    80000d00:	85a080e7          	jalr	-1958(ra) # 80000556 <panic>

0000000080000d04 <release>:
{
    80000d04:	1101                	addi	sp,sp,-32
    80000d06:	ec06                	sd	ra,24(sp)
    80000d08:	e822                	sd	s0,16(sp)
    80000d0a:	e426                	sd	s1,8(sp)
    80000d0c:	1000                	addi	s0,sp,32
    80000d0e:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d10:	00000097          	auipc	ra,0x0
    80000d14:	ec4080e7          	jalr	-316(ra) # 80000bd4 <holding>
    80000d18:	c115                	beqz	a0,80000d3c <release+0x38>
  lk->cpu = 0;
    80000d1a:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d1e:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000d22:	0310000f          	fence	rw,w
    80000d26:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000d2a:	00000097          	auipc	ra,0x0
    80000d2e:	f7e080e7          	jalr	-130(ra) # 80000ca8 <pop_off>
}
    80000d32:	60e2                	ld	ra,24(sp)
    80000d34:	6442                	ld	s0,16(sp)
    80000d36:	64a2                	ld	s1,8(sp)
    80000d38:	6105                	addi	sp,sp,32
    80000d3a:	8082                	ret
    panic("release");
    80000d3c:	00007517          	auipc	a0,0x7
    80000d40:	33c50513          	addi	a0,a0,828 # 80008078 <etext+0x78>
    80000d44:	00000097          	auipc	ra,0x0
    80000d48:	812080e7          	jalr	-2030(ra) # 80000556 <panic>

0000000080000d4c <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d4c:	1141                	addi	sp,sp,-16
    80000d4e:	e406                	sd	ra,8(sp)
    80000d50:	e022                	sd	s0,0(sp)
    80000d52:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d54:	ca19                	beqz	a2,80000d6a <memset+0x1e>
    80000d56:	87aa                	mv	a5,a0
    80000d58:	1602                	slli	a2,a2,0x20
    80000d5a:	9201                	srli	a2,a2,0x20
    80000d5c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d60:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d64:	0785                	addi	a5,a5,1
    80000d66:	fee79de3          	bne	a5,a4,80000d60 <memset+0x14>
  }
  return dst;
}
    80000d6a:	60a2                	ld	ra,8(sp)
    80000d6c:	6402                	ld	s0,0(sp)
    80000d6e:	0141                	addi	sp,sp,16
    80000d70:	8082                	ret

0000000080000d72 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d72:	1141                	addi	sp,sp,-16
    80000d74:	e406                	sd	ra,8(sp)
    80000d76:	e022                	sd	s0,0(sp)
    80000d78:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d7a:	c61d                	beqz	a2,80000da8 <memcmp+0x36>
    80000d7c:	1602                	slli	a2,a2,0x20
    80000d7e:	9201                	srli	a2,a2,0x20
    80000d80:	00c506b3          	add	a3,a0,a2
    if(*s1 != *s2)
    80000d84:	00054783          	lbu	a5,0(a0)
    80000d88:	0005c703          	lbu	a4,0(a1)
    80000d8c:	00e79863          	bne	a5,a4,80000d9c <memcmp+0x2a>
      return *s1 - *s2;
    s1++, s2++;
    80000d90:	0505                	addi	a0,a0,1
    80000d92:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d94:	fed518e3          	bne	a0,a3,80000d84 <memcmp+0x12>
  }

  return 0;
    80000d98:	4501                	li	a0,0
    80000d9a:	a019                	j	80000da0 <memcmp+0x2e>
      return *s1 - *s2;
    80000d9c:	40e7853b          	subw	a0,a5,a4
}
    80000da0:	60a2                	ld	ra,8(sp)
    80000da2:	6402                	ld	s0,0(sp)
    80000da4:	0141                	addi	sp,sp,16
    80000da6:	8082                	ret
  return 0;
    80000da8:	4501                	li	a0,0
    80000daa:	bfdd                	j	80000da0 <memcmp+0x2e>

0000000080000dac <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000dac:	1141                	addi	sp,sp,-16
    80000dae:	e406                	sd	ra,8(sp)
    80000db0:	e022                	sd	s0,0(sp)
    80000db2:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000db4:	c205                	beqz	a2,80000dd4 <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000db6:	02a5e363          	bltu	a1,a0,80000ddc <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000dba:	1602                	slli	a2,a2,0x20
    80000dbc:	9201                	srli	a2,a2,0x20
    80000dbe:	00c587b3          	add	a5,a1,a2
{
    80000dc2:	872a                	mv	a4,a0
      *d++ = *s++;
    80000dc4:	0585                	addi	a1,a1,1
    80000dc6:	0705                	addi	a4,a4,1
    80000dc8:	fff5c683          	lbu	a3,-1(a1)
    80000dcc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000dd0:	feb79ae3          	bne	a5,a1,80000dc4 <memmove+0x18>

  return dst;
}
    80000dd4:	60a2                	ld	ra,8(sp)
    80000dd6:	6402                	ld	s0,0(sp)
    80000dd8:	0141                	addi	sp,sp,16
    80000dda:	8082                	ret
  if(s < d && s + n > d){
    80000ddc:	02061693          	slli	a3,a2,0x20
    80000de0:	9281                	srli	a3,a3,0x20
    80000de2:	00d58733          	add	a4,a1,a3
    80000de6:	fce57ae3          	bgeu	a0,a4,80000dba <memmove+0xe>
    d += n;
    80000dea:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000dec:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000df0:	1782                	slli	a5,a5,0x20
    80000df2:	9381                	srli	a5,a5,0x20
    80000df4:	fff7c793          	not	a5,a5
    80000df8:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000dfa:	177d                	addi	a4,a4,-1
    80000dfc:	16fd                	addi	a3,a3,-1
    80000dfe:	00074603          	lbu	a2,0(a4)
    80000e02:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000e06:	fee79ae3          	bne	a5,a4,80000dfa <memmove+0x4e>
    80000e0a:	b7e9                	j	80000dd4 <memmove+0x28>

0000000080000e0c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e0c:	1141                	addi	sp,sp,-16
    80000e0e:	e406                	sd	ra,8(sp)
    80000e10:	e022                	sd	s0,0(sp)
    80000e12:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e14:	00000097          	auipc	ra,0x0
    80000e18:	f98080e7          	jalr	-104(ra) # 80000dac <memmove>
}
    80000e1c:	60a2                	ld	ra,8(sp)
    80000e1e:	6402                	ld	s0,0(sp)
    80000e20:	0141                	addi	sp,sp,16
    80000e22:	8082                	ret

0000000080000e24 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e24:	1141                	addi	sp,sp,-16
    80000e26:	e406                	sd	ra,8(sp)
    80000e28:	e022                	sd	s0,0(sp)
    80000e2a:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e2c:	ce11                	beqz	a2,80000e48 <strncmp+0x24>
    80000e2e:	00054783          	lbu	a5,0(a0)
    80000e32:	cf89                	beqz	a5,80000e4c <strncmp+0x28>
    80000e34:	0005c703          	lbu	a4,0(a1)
    80000e38:	00f71a63          	bne	a4,a5,80000e4c <strncmp+0x28>
    n--, p++, q++;
    80000e3c:	367d                	addiw	a2,a2,-1
    80000e3e:	0505                	addi	a0,a0,1
    80000e40:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e42:	f675                	bnez	a2,80000e2e <strncmp+0xa>
  if(n == 0)
    return 0;
    80000e44:	4501                	li	a0,0
    80000e46:	a801                	j	80000e56 <strncmp+0x32>
    80000e48:	4501                	li	a0,0
    80000e4a:	a031                	j	80000e56 <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000e4c:	00054503          	lbu	a0,0(a0)
    80000e50:	0005c783          	lbu	a5,0(a1)
    80000e54:	9d1d                	subw	a0,a0,a5
}
    80000e56:	60a2                	ld	ra,8(sp)
    80000e58:	6402                	ld	s0,0(sp)
    80000e5a:	0141                	addi	sp,sp,16
    80000e5c:	8082                	ret

0000000080000e5e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e5e:	1141                	addi	sp,sp,-16
    80000e60:	e406                	sd	ra,8(sp)
    80000e62:	e022                	sd	s0,0(sp)
    80000e64:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e66:	87aa                	mv	a5,a0
    80000e68:	a011                	j	80000e6c <strncpy+0xe>
    80000e6a:	8636                	mv	a2,a3
    80000e6c:	02c05863          	blez	a2,80000e9c <strncpy+0x3e>
    80000e70:	fff6069b          	addiw	a3,a2,-1
    80000e74:	8836                	mv	a6,a3
    80000e76:	0785                	addi	a5,a5,1
    80000e78:	0005c703          	lbu	a4,0(a1)
    80000e7c:	fee78fa3          	sb	a4,-1(a5)
    80000e80:	0585                	addi	a1,a1,1
    80000e82:	f765                	bnez	a4,80000e6a <strncpy+0xc>
    ;
  while(n-- > 0)
    80000e84:	873e                	mv	a4,a5
    80000e86:	01005b63          	blez	a6,80000e9c <strncpy+0x3e>
    80000e8a:	9fb1                	addw	a5,a5,a2
    80000e8c:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e8e:	0705                	addi	a4,a4,1
    80000e90:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e94:	40e786bb          	subw	a3,a5,a4
    80000e98:	fed04be3          	bgtz	a3,80000e8e <strncpy+0x30>
  return os;
}
    80000e9c:	60a2                	ld	ra,8(sp)
    80000e9e:	6402                	ld	s0,0(sp)
    80000ea0:	0141                	addi	sp,sp,16
    80000ea2:	8082                	ret

0000000080000ea4 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000ea4:	1141                	addi	sp,sp,-16
    80000ea6:	e406                	sd	ra,8(sp)
    80000ea8:	e022                	sd	s0,0(sp)
    80000eaa:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000eac:	02c05363          	blez	a2,80000ed2 <safestrcpy+0x2e>
    80000eb0:	fff6069b          	addiw	a3,a2,-1
    80000eb4:	1682                	slli	a3,a3,0x20
    80000eb6:	9281                	srli	a3,a3,0x20
    80000eb8:	96ae                	add	a3,a3,a1
    80000eba:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000ebc:	00d58963          	beq	a1,a3,80000ece <safestrcpy+0x2a>
    80000ec0:	0585                	addi	a1,a1,1
    80000ec2:	0785                	addi	a5,a5,1
    80000ec4:	fff5c703          	lbu	a4,-1(a1)
    80000ec8:	fee78fa3          	sb	a4,-1(a5)
    80000ecc:	fb65                	bnez	a4,80000ebc <safestrcpy+0x18>
    ;
  *s = 0;
    80000ece:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ed2:	60a2                	ld	ra,8(sp)
    80000ed4:	6402                	ld	s0,0(sp)
    80000ed6:	0141                	addi	sp,sp,16
    80000ed8:	8082                	ret

0000000080000eda <strlen>:

int
strlen(const char *s)
{
    80000eda:	1141                	addi	sp,sp,-16
    80000edc:	e406                	sd	ra,8(sp)
    80000ede:	e022                	sd	s0,0(sp)
    80000ee0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000ee2:	00054783          	lbu	a5,0(a0)
    80000ee6:	cf91                	beqz	a5,80000f02 <strlen+0x28>
    80000ee8:	00150793          	addi	a5,a0,1
    80000eec:	86be                	mv	a3,a5
    80000eee:	0785                	addi	a5,a5,1
    80000ef0:	fff7c703          	lbu	a4,-1(a5)
    80000ef4:	ff65                	bnez	a4,80000eec <strlen+0x12>
    80000ef6:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000efa:	60a2                	ld	ra,8(sp)
    80000efc:	6402                	ld	s0,0(sp)
    80000efe:	0141                	addi	sp,sp,16
    80000f00:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f02:	4501                	li	a0,0
    80000f04:	bfdd                	j	80000efa <strlen+0x20>

0000000080000f06 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f06:	1141                	addi	sp,sp,-16
    80000f08:	e406                	sd	ra,8(sp)
    80000f0a:	e022                	sd	s0,0(sp)
    80000f0c:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f0e:	00001097          	auipc	ra,0x1
    80000f12:	b44080e7          	jalr	-1212(ra) # 80001a52 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f16:	0000b717          	auipc	a4,0xb
    80000f1a:	10270713          	addi	a4,a4,258 # 8000c018 <started>
  if(cpuid() == 0){
    80000f1e:	c139                	beqz	a0,80000f64 <main+0x5e>
    while(started == 0)
    80000f20:	431c                	lw	a5,0(a4)
    80000f22:	2781                	sext.w	a5,a5
    80000f24:	dff5                	beqz	a5,80000f20 <main+0x1a>
      ;
    __sync_synchronize();
    80000f26:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000f2a:	00001097          	auipc	ra,0x1
    80000f2e:	b28080e7          	jalr	-1240(ra) # 80001a52 <cpuid>
    80000f32:	85aa                	mv	a1,a0
    80000f34:	00007517          	auipc	a0,0x7
    80000f38:	16450513          	addi	a0,a0,356 # 80008098 <etext+0x98>
    80000f3c:	fffff097          	auipc	ra,0xfffff
    80000f40:	664080e7          	jalr	1636(ra) # 800005a0 <printf>
    kvminithart();    // turn on paging
    80000f44:	00000097          	auipc	ra,0x0
    80000f48:	0d8080e7          	jalr	216(ra) # 8000101c <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f4c:	00002097          	auipc	ra,0x2
    80000f50:	b5e080e7          	jalr	-1186(ra) # 80002aaa <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f54:	00005097          	auipc	ra,0x5
    80000f58:	410080e7          	jalr	1040(ra) # 80006364 <plicinithart>
  }

  scheduler();        
    80000f5c:	00001097          	auipc	ra,0x1
    80000f60:	0ac080e7          	jalr	172(ra) # 80002008 <scheduler>
    consoleinit();
    80000f64:	fffff097          	auipc	ra,0xfffff
    80000f68:	508080e7          	jalr	1288(ra) # 8000046c <consoleinit>
    printfinit();
    80000f6c:	00000097          	auipc	ra,0x0
    80000f70:	83e080e7          	jalr	-1986(ra) # 800007aa <printfinit>
    printf("\n");
    80000f74:	00007517          	auipc	a0,0x7
    80000f78:	09c50513          	addi	a0,a0,156 # 80008010 <etext+0x10>
    80000f7c:	fffff097          	auipc	ra,0xfffff
    80000f80:	624080e7          	jalr	1572(ra) # 800005a0 <printf>
    printf("xv6 kernel is booting\n");
    80000f84:	00007517          	auipc	a0,0x7
    80000f88:	0fc50513          	addi	a0,a0,252 # 80008080 <etext+0x80>
    80000f8c:	fffff097          	auipc	ra,0xfffff
    80000f90:	614080e7          	jalr	1556(ra) # 800005a0 <printf>
    printf("\n");
    80000f94:	00007517          	auipc	a0,0x7
    80000f98:	07c50513          	addi	a0,a0,124 # 80008010 <etext+0x10>
    80000f9c:	fffff097          	auipc	ra,0xfffff
    80000fa0:	604080e7          	jalr	1540(ra) # 800005a0 <printf>
    kinit();         // physical page allocator
    80000fa4:	00000097          	auipc	ra,0x0
    80000fa8:	b70080e7          	jalr	-1168(ra) # 80000b14 <kinit>
    kvminit();       // create kernel page table
    80000fac:	00000097          	auipc	ra,0x0
    80000fb0:	320080e7          	jalr	800(ra) # 800012cc <kvminit>
    kvminithart();   // turn on paging
    80000fb4:	00000097          	auipc	ra,0x0
    80000fb8:	068080e7          	jalr	104(ra) # 8000101c <kvminithart>
    procinit();      // process table
    80000fbc:	00001097          	auipc	ra,0x1
    80000fc0:	9d8080e7          	jalr	-1576(ra) # 80001994 <procinit>
    trapinit();      // trap vectors
    80000fc4:	00002097          	auipc	ra,0x2
    80000fc8:	abe080e7          	jalr	-1346(ra) # 80002a82 <trapinit>
    trapinithart();  // install kernel trap vector
    80000fcc:	00002097          	auipc	ra,0x2
    80000fd0:	ade080e7          	jalr	-1314(ra) # 80002aaa <trapinithart>
    plicinit();      // set up interrupt controller
    80000fd4:	00005097          	auipc	ra,0x5
    80000fd8:	376080e7          	jalr	886(ra) # 8000634a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fdc:	00005097          	auipc	ra,0x5
    80000fe0:	388080e7          	jalr	904(ra) # 80006364 <plicinithart>
    binit();         // buffer cache
    80000fe4:	00002097          	auipc	ra,0x2
    80000fe8:	44c080e7          	jalr	1100(ra) # 80003430 <binit>
    iinit();         // inode table
    80000fec:	00003097          	auipc	ra,0x3
    80000ff0:	aaa080e7          	jalr	-1366(ra) # 80003a96 <iinit>
    fileinit();      // file table
    80000ff4:	00004097          	auipc	ra,0x4
    80000ff8:	a8c080e7          	jalr	-1396(ra) # 80004a80 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ffc:	00005097          	auipc	ra,0x5
    80001000:	488080e7          	jalr	1160(ra) # 80006484 <virtio_disk_init>
    userinit();      // first user process
    80001004:	00001097          	auipc	ra,0x1
    80001008:	d88080e7          	jalr	-632(ra) # 80001d8c <userinit>
    __sync_synchronize();
    8000100c:	0330000f          	fence	rw,rw
    started = 1;
    80001010:	4785                	li	a5,1
    80001012:	0000b717          	auipc	a4,0xb
    80001016:	00f72323          	sw	a5,6(a4) # 8000c018 <started>
    8000101a:	b789                	j	80000f5c <main+0x56>

000000008000101c <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    8000101c:	1141                	addi	sp,sp,-16
    8000101e:	e406                	sd	ra,8(sp)
    80001020:	e022                	sd	s0,0(sp)
    80001022:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80001024:	0000b797          	auipc	a5,0xb
    80001028:	ffc7b783          	ld	a5,-4(a5) # 8000c020 <kernel_pagetable>
    8000102c:	83b1                	srli	a5,a5,0xc
    8000102e:	577d                	li	a4,-1
    80001030:	177e                	slli	a4,a4,0x3f
    80001032:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001034:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001038:	12000073          	sfence.vma
  sfence_vma();
}
    8000103c:	60a2                	ld	ra,8(sp)
    8000103e:	6402                	ld	s0,0(sp)
    80001040:	0141                	addi	sp,sp,16
    80001042:	8082                	ret

0000000080001044 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001044:	7139                	addi	sp,sp,-64
    80001046:	fc06                	sd	ra,56(sp)
    80001048:	f822                	sd	s0,48(sp)
    8000104a:	f426                	sd	s1,40(sp)
    8000104c:	f04a                	sd	s2,32(sp)
    8000104e:	ec4e                	sd	s3,24(sp)
    80001050:	e852                	sd	s4,16(sp)
    80001052:	e456                	sd	s5,8(sp)
    80001054:	e05a                	sd	s6,0(sp)
    80001056:	0080                	addi	s0,sp,64
    80001058:	84aa                	mv	s1,a0
    8000105a:	89ae                	mv	s3,a1
    8000105c:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    8000105e:	57fd                	li	a5,-1
    80001060:	83e9                	srli	a5,a5,0x1a
    80001062:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001064:	4ab1                	li	s5,12
  if(va >= MAXVA)
    80001066:	04b7e263          	bltu	a5,a1,800010aa <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    8000106a:	0149d933          	srl	s2,s3,s4
    8000106e:	1ff97913          	andi	s2,s2,511
    80001072:	090e                	slli	s2,s2,0x3
    80001074:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001076:	00093483          	ld	s1,0(s2)
    8000107a:	0014f793          	andi	a5,s1,1
    8000107e:	cf95                	beqz	a5,800010ba <walk+0x76>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001080:	80a9                	srli	s1,s1,0xa
    80001082:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    80001084:	3a5d                	addiw	s4,s4,-9
    80001086:	ff5a12e3          	bne	s4,s5,8000106a <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    8000108a:	00c9d513          	srli	a0,s3,0xc
    8000108e:	1ff57513          	andi	a0,a0,511
    80001092:	050e                	slli	a0,a0,0x3
    80001094:	9526                	add	a0,a0,s1
}
    80001096:	70e2                	ld	ra,56(sp)
    80001098:	7442                	ld	s0,48(sp)
    8000109a:	74a2                	ld	s1,40(sp)
    8000109c:	7902                	ld	s2,32(sp)
    8000109e:	69e2                	ld	s3,24(sp)
    800010a0:	6a42                	ld	s4,16(sp)
    800010a2:	6aa2                	ld	s5,8(sp)
    800010a4:	6b02                	ld	s6,0(sp)
    800010a6:	6121                	addi	sp,sp,64
    800010a8:	8082                	ret
    panic("walk");
    800010aa:	00007517          	auipc	a0,0x7
    800010ae:	00650513          	addi	a0,a0,6 # 800080b0 <etext+0xb0>
    800010b2:	fffff097          	auipc	ra,0xfffff
    800010b6:	4a4080e7          	jalr	1188(ra) # 80000556 <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800010ba:	020b0663          	beqz	s6,800010e6 <walk+0xa2>
    800010be:	00000097          	auipc	ra,0x0
    800010c2:	a92080e7          	jalr	-1390(ra) # 80000b50 <kalloc>
    800010c6:	84aa                	mv	s1,a0
    800010c8:	d579                	beqz	a0,80001096 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    800010ca:	6605                	lui	a2,0x1
    800010cc:	4581                	li	a1,0
    800010ce:	00000097          	auipc	ra,0x0
    800010d2:	c7e080e7          	jalr	-898(ra) # 80000d4c <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800010d6:	00c4d793          	srli	a5,s1,0xc
    800010da:	07aa                	slli	a5,a5,0xa
    800010dc:	0017e793          	ori	a5,a5,1
    800010e0:	00f93023          	sd	a5,0(s2)
    800010e4:	b745                	j	80001084 <walk+0x40>
        return 0;
    800010e6:	4501                	li	a0,0
    800010e8:	b77d                	j	80001096 <walk+0x52>

00000000800010ea <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010ea:	57fd                	li	a5,-1
    800010ec:	83e9                	srli	a5,a5,0x1a
    800010ee:	00b7f463          	bgeu	a5,a1,800010f6 <walkaddr+0xc>
    return 0;
    800010f2:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010f4:	8082                	ret
{
    800010f6:	1141                	addi	sp,sp,-16
    800010f8:	e406                	sd	ra,8(sp)
    800010fa:	e022                	sd	s0,0(sp)
    800010fc:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010fe:	4601                	li	a2,0
    80001100:	00000097          	auipc	ra,0x0
    80001104:	f44080e7          	jalr	-188(ra) # 80001044 <walk>
  if(pte == 0)
    80001108:	c901                	beqz	a0,80001118 <walkaddr+0x2e>
  if((*pte & PTE_V) == 0)
    8000110a:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000110c:	0117f693          	andi	a3,a5,17
    80001110:	4745                	li	a4,17
    return 0;
    80001112:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001114:	00e68663          	beq	a3,a4,80001120 <walkaddr+0x36>
}
    80001118:	60a2                	ld	ra,8(sp)
    8000111a:	6402                	ld	s0,0(sp)
    8000111c:	0141                	addi	sp,sp,16
    8000111e:	8082                	ret
  pa = PTE2PA(*pte);
    80001120:	83a9                	srli	a5,a5,0xa
    80001122:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001126:	bfcd                	j	80001118 <walkaddr+0x2e>

0000000080001128 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001128:	715d                	addi	sp,sp,-80
    8000112a:	e486                	sd	ra,72(sp)
    8000112c:	e0a2                	sd	s0,64(sp)
    8000112e:	fc26                	sd	s1,56(sp)
    80001130:	f84a                	sd	s2,48(sp)
    80001132:	f44e                	sd	s3,40(sp)
    80001134:	f052                	sd	s4,32(sp)
    80001136:	ec56                	sd	s5,24(sp)
    80001138:	e85a                	sd	s6,16(sp)
    8000113a:	e45e                	sd	s7,8(sp)
    8000113c:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    8000113e:	ca21                	beqz	a2,8000118e <mappages+0x66>
    80001140:	8a2a                	mv	s4,a0
    80001142:	8aba                	mv	s5,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80001144:	777d                	lui	a4,0xfffff
    80001146:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    8000114a:	fff58913          	addi	s2,a1,-1
    8000114e:	9932                	add	s2,s2,a2
    80001150:	00e97933          	and	s2,s2,a4
  a = PGROUNDDOWN(va);
    80001154:	84be                	mv	s1,a5
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    80001156:	4b05                	li	s6,1
    80001158:	40f689b3          	sub	s3,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000115c:	6b85                	lui	s7,0x1
    if((pte = walk(pagetable, a, 1)) == 0)
    8000115e:	865a                	mv	a2,s6
    80001160:	85a6                	mv	a1,s1
    80001162:	8552                	mv	a0,s4
    80001164:	00000097          	auipc	ra,0x0
    80001168:	ee0080e7          	jalr	-288(ra) # 80001044 <walk>
    8000116c:	c129                	beqz	a0,800011ae <mappages+0x86>
    if(*pte & PTE_V)
    8000116e:	611c                	ld	a5,0(a0)
    80001170:	8b85                	andi	a5,a5,1
    80001172:	e795                	bnez	a5,8000119e <mappages+0x76>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001174:	013487b3          	add	a5,s1,s3
    80001178:	83b1                	srli	a5,a5,0xc
    8000117a:	07aa                	slli	a5,a5,0xa
    8000117c:	0157e7b3          	or	a5,a5,s5
    80001180:	0017e793          	ori	a5,a5,1
    80001184:	e11c                	sd	a5,0(a0)
    if(a == last)
    80001186:	05248063          	beq	s1,s2,800011c6 <mappages+0x9e>
    a += PGSIZE;
    8000118a:	94de                	add	s1,s1,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000118c:	bfc9                	j	8000115e <mappages+0x36>
    panic("mappages: size");
    8000118e:	00007517          	auipc	a0,0x7
    80001192:	f2a50513          	addi	a0,a0,-214 # 800080b8 <etext+0xb8>
    80001196:	fffff097          	auipc	ra,0xfffff
    8000119a:	3c0080e7          	jalr	960(ra) # 80000556 <panic>
      panic("mappages: remap");
    8000119e:	00007517          	auipc	a0,0x7
    800011a2:	f2a50513          	addi	a0,a0,-214 # 800080c8 <etext+0xc8>
    800011a6:	fffff097          	auipc	ra,0xfffff
    800011aa:	3b0080e7          	jalr	944(ra) # 80000556 <panic>
      return -1;
    800011ae:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800011b0:	60a6                	ld	ra,72(sp)
    800011b2:	6406                	ld	s0,64(sp)
    800011b4:	74e2                	ld	s1,56(sp)
    800011b6:	7942                	ld	s2,48(sp)
    800011b8:	79a2                	ld	s3,40(sp)
    800011ba:	7a02                	ld	s4,32(sp)
    800011bc:	6ae2                	ld	s5,24(sp)
    800011be:	6b42                	ld	s6,16(sp)
    800011c0:	6ba2                	ld	s7,8(sp)
    800011c2:	6161                	addi	sp,sp,80
    800011c4:	8082                	ret
  return 0;
    800011c6:	4501                	li	a0,0
    800011c8:	b7e5                	j	800011b0 <mappages+0x88>

00000000800011ca <kvmmap>:
{
    800011ca:	1141                	addi	sp,sp,-16
    800011cc:	e406                	sd	ra,8(sp)
    800011ce:	e022                	sd	s0,0(sp)
    800011d0:	0800                	addi	s0,sp,16
    800011d2:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800011d4:	86b2                	mv	a3,a2
    800011d6:	863e                	mv	a2,a5
    800011d8:	00000097          	auipc	ra,0x0
    800011dc:	f50080e7          	jalr	-176(ra) # 80001128 <mappages>
    800011e0:	e509                	bnez	a0,800011ea <kvmmap+0x20>
}
    800011e2:	60a2                	ld	ra,8(sp)
    800011e4:	6402                	ld	s0,0(sp)
    800011e6:	0141                	addi	sp,sp,16
    800011e8:	8082                	ret
    panic("kvmmap");
    800011ea:	00007517          	auipc	a0,0x7
    800011ee:	eee50513          	addi	a0,a0,-274 # 800080d8 <etext+0xd8>
    800011f2:	fffff097          	auipc	ra,0xfffff
    800011f6:	364080e7          	jalr	868(ra) # 80000556 <panic>

00000000800011fa <kvmmake>:
{
    800011fa:	1101                	addi	sp,sp,-32
    800011fc:	ec06                	sd	ra,24(sp)
    800011fe:	e822                	sd	s0,16(sp)
    80001200:	e426                	sd	s1,8(sp)
    80001202:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001204:	00000097          	auipc	ra,0x0
    80001208:	94c080e7          	jalr	-1716(ra) # 80000b50 <kalloc>
    8000120c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000120e:	6605                	lui	a2,0x1
    80001210:	4581                	li	a1,0
    80001212:	00000097          	auipc	ra,0x0
    80001216:	b3a080e7          	jalr	-1222(ra) # 80000d4c <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000121a:	4719                	li	a4,6
    8000121c:	6685                	lui	a3,0x1
    8000121e:	10000637          	lui	a2,0x10000
    80001222:	85b2                	mv	a1,a2
    80001224:	8526                	mv	a0,s1
    80001226:	00000097          	auipc	ra,0x0
    8000122a:	fa4080e7          	jalr	-92(ra) # 800011ca <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000122e:	4719                	li	a4,6
    80001230:	6685                	lui	a3,0x1
    80001232:	10001637          	lui	a2,0x10001
    80001236:	85b2                	mv	a1,a2
    80001238:	8526                	mv	a0,s1
    8000123a:	00000097          	auipc	ra,0x0
    8000123e:	f90080e7          	jalr	-112(ra) # 800011ca <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001242:	4719                	li	a4,6
    80001244:	004006b7          	lui	a3,0x400
    80001248:	0c000637          	lui	a2,0xc000
    8000124c:	85b2                	mv	a1,a2
    8000124e:	8526                	mv	a0,s1
    80001250:	00000097          	auipc	ra,0x0
    80001254:	f7a080e7          	jalr	-134(ra) # 800011ca <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001258:	4729                	li	a4,10
    8000125a:	80007697          	auipc	a3,0x80007
    8000125e:	da668693          	addi	a3,a3,-602 # 8000 <_entry-0x7fff8000>
    80001262:	4605                	li	a2,1
    80001264:	067e                	slli	a2,a2,0x1f
    80001266:	85b2                	mv	a1,a2
    80001268:	8526                	mv	a0,s1
    8000126a:	00000097          	auipc	ra,0x0
    8000126e:	f60080e7          	jalr	-160(ra) # 800011ca <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001272:	4719                	li	a4,6
    80001274:	00007697          	auipc	a3,0x7
    80001278:	d8c68693          	addi	a3,a3,-628 # 80008000 <etext>
    8000127c:	47c5                	li	a5,17
    8000127e:	07ee                	slli	a5,a5,0x1b
    80001280:	40d786b3          	sub	a3,a5,a3
    80001284:	00007617          	auipc	a2,0x7
    80001288:	d7c60613          	addi	a2,a2,-644 # 80008000 <etext>
    8000128c:	85b2                	mv	a1,a2
    8000128e:	8526                	mv	a0,s1
    80001290:	00000097          	auipc	ra,0x0
    80001294:	f3a080e7          	jalr	-198(ra) # 800011ca <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001298:	4729                	li	a4,10
    8000129a:	6685                	lui	a3,0x1
    8000129c:	00006617          	auipc	a2,0x6
    800012a0:	d6460613          	addi	a2,a2,-668 # 80007000 <_trampoline>
    800012a4:	040005b7          	lui	a1,0x4000
    800012a8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800012aa:	05b2                	slli	a1,a1,0xc
    800012ac:	8526                	mv	a0,s1
    800012ae:	00000097          	auipc	ra,0x0
    800012b2:	f1c080e7          	jalr	-228(ra) # 800011ca <kvmmap>
  proc_mapstacks(kpgtbl);
    800012b6:	8526                	mv	a0,s1
    800012b8:	00000097          	auipc	ra,0x0
    800012bc:	62c080e7          	jalr	1580(ra) # 800018e4 <proc_mapstacks>
}
    800012c0:	8526                	mv	a0,s1
    800012c2:	60e2                	ld	ra,24(sp)
    800012c4:	6442                	ld	s0,16(sp)
    800012c6:	64a2                	ld	s1,8(sp)
    800012c8:	6105                	addi	sp,sp,32
    800012ca:	8082                	ret

00000000800012cc <kvminit>:
{
    800012cc:	1141                	addi	sp,sp,-16
    800012ce:	e406                	sd	ra,8(sp)
    800012d0:	e022                	sd	s0,0(sp)
    800012d2:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800012d4:	00000097          	auipc	ra,0x0
    800012d8:	f26080e7          	jalr	-218(ra) # 800011fa <kvmmake>
    800012dc:	0000b797          	auipc	a5,0xb
    800012e0:	d4a7b223          	sd	a0,-700(a5) # 8000c020 <kernel_pagetable>
}
    800012e4:	60a2                	ld	ra,8(sp)
    800012e6:	6402                	ld	s0,0(sp)
    800012e8:	0141                	addi	sp,sp,16
    800012ea:	8082                	ret

00000000800012ec <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012ec:	715d                	addi	sp,sp,-80
    800012ee:	e486                	sd	ra,72(sp)
    800012f0:	e0a2                	sd	s0,64(sp)
    800012f2:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012f4:	03459793          	slli	a5,a1,0x34
    800012f8:	e39d                	bnez	a5,8000131e <uvmunmap+0x32>
    800012fa:	f84a                	sd	s2,48(sp)
    800012fc:	f44e                	sd	s3,40(sp)
    800012fe:	f052                	sd	s4,32(sp)
    80001300:	ec56                	sd	s5,24(sp)
    80001302:	e85a                	sd	s6,16(sp)
    80001304:	e45e                	sd	s7,8(sp)
    80001306:	8a2a                	mv	s4,a0
    80001308:	892e                	mv	s2,a1
    8000130a:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000130c:	0632                	slli	a2,a2,0xc
    8000130e:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001312:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001314:	6b05                	lui	s6,0x1
    80001316:	0935fb63          	bgeu	a1,s3,800013ac <uvmunmap+0xc0>
    8000131a:	fc26                	sd	s1,56(sp)
    8000131c:	a8a9                	j	80001376 <uvmunmap+0x8a>
    8000131e:	fc26                	sd	s1,56(sp)
    80001320:	f84a                	sd	s2,48(sp)
    80001322:	f44e                	sd	s3,40(sp)
    80001324:	f052                	sd	s4,32(sp)
    80001326:	ec56                	sd	s5,24(sp)
    80001328:	e85a                	sd	s6,16(sp)
    8000132a:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    8000132c:	00007517          	auipc	a0,0x7
    80001330:	db450513          	addi	a0,a0,-588 # 800080e0 <etext+0xe0>
    80001334:	fffff097          	auipc	ra,0xfffff
    80001338:	222080e7          	jalr	546(ra) # 80000556 <panic>
      panic("uvmunmap: walk");
    8000133c:	00007517          	auipc	a0,0x7
    80001340:	dbc50513          	addi	a0,a0,-580 # 800080f8 <etext+0xf8>
    80001344:	fffff097          	auipc	ra,0xfffff
    80001348:	212080e7          	jalr	530(ra) # 80000556 <panic>
      panic("uvmunmap: not mapped");
    8000134c:	00007517          	auipc	a0,0x7
    80001350:	dbc50513          	addi	a0,a0,-580 # 80008108 <etext+0x108>
    80001354:	fffff097          	auipc	ra,0xfffff
    80001358:	202080e7          	jalr	514(ra) # 80000556 <panic>
      panic("uvmunmap: not a leaf");
    8000135c:	00007517          	auipc	a0,0x7
    80001360:	dc450513          	addi	a0,a0,-572 # 80008120 <etext+0x120>
    80001364:	fffff097          	auipc	ra,0xfffff
    80001368:	1f2080e7          	jalr	498(ra) # 80000556 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000136c:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001370:	995a                	add	s2,s2,s6
    80001372:	03397c63          	bgeu	s2,s3,800013aa <uvmunmap+0xbe>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001376:	4601                	li	a2,0
    80001378:	85ca                	mv	a1,s2
    8000137a:	8552                	mv	a0,s4
    8000137c:	00000097          	auipc	ra,0x0
    80001380:	cc8080e7          	jalr	-824(ra) # 80001044 <walk>
    80001384:	84aa                	mv	s1,a0
    80001386:	d95d                	beqz	a0,8000133c <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)
    80001388:	6108                	ld	a0,0(a0)
    8000138a:	00157793          	andi	a5,a0,1
    8000138e:	dfdd                	beqz	a5,8000134c <uvmunmap+0x60>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001390:	3ff57793          	andi	a5,a0,1023
    80001394:	fd7784e3          	beq	a5,s7,8000135c <uvmunmap+0x70>
    if(do_free){
    80001398:	fc0a8ae3          	beqz	s5,8000136c <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
    8000139c:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000139e:	0532                	slli	a0,a0,0xc
    800013a0:	fffff097          	auipc	ra,0xfffff
    800013a4:	6ac080e7          	jalr	1708(ra) # 80000a4c <kfree>
    800013a8:	b7d1                	j	8000136c <uvmunmap+0x80>
    800013aa:	74e2                	ld	s1,56(sp)
    800013ac:	7942                	ld	s2,48(sp)
    800013ae:	79a2                	ld	s3,40(sp)
    800013b0:	7a02                	ld	s4,32(sp)
    800013b2:	6ae2                	ld	s5,24(sp)
    800013b4:	6b42                	ld	s6,16(sp)
    800013b6:	6ba2                	ld	s7,8(sp)
  }
}
    800013b8:	60a6                	ld	ra,72(sp)
    800013ba:	6406                	ld	s0,64(sp)
    800013bc:	6161                	addi	sp,sp,80
    800013be:	8082                	ret

00000000800013c0 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013c0:	1101                	addi	sp,sp,-32
    800013c2:	ec06                	sd	ra,24(sp)
    800013c4:	e822                	sd	s0,16(sp)
    800013c6:	e426                	sd	s1,8(sp)
    800013c8:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013ca:	fffff097          	auipc	ra,0xfffff
    800013ce:	786080e7          	jalr	1926(ra) # 80000b50 <kalloc>
    800013d2:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013d4:	c519                	beqz	a0,800013e2 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013d6:	6605                	lui	a2,0x1
    800013d8:	4581                	li	a1,0
    800013da:	00000097          	auipc	ra,0x0
    800013de:	972080e7          	jalr	-1678(ra) # 80000d4c <memset>
  return pagetable;
}
    800013e2:	8526                	mv	a0,s1
    800013e4:	60e2                	ld	ra,24(sp)
    800013e6:	6442                	ld	s0,16(sp)
    800013e8:	64a2                	ld	s1,8(sp)
    800013ea:	6105                	addi	sp,sp,32
    800013ec:	8082                	ret

00000000800013ee <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    800013ee:	7179                	addi	sp,sp,-48
    800013f0:	f406                	sd	ra,40(sp)
    800013f2:	f022                	sd	s0,32(sp)
    800013f4:	ec26                	sd	s1,24(sp)
    800013f6:	e84a                	sd	s2,16(sp)
    800013f8:	e44e                	sd	s3,8(sp)
    800013fa:	e052                	sd	s4,0(sp)
    800013fc:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013fe:	6785                	lui	a5,0x1
    80001400:	04f67863          	bgeu	a2,a5,80001450 <uvminit+0x62>
    80001404:	89aa                	mv	s3,a0
    80001406:	8a2e                	mv	s4,a1
    80001408:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    8000140a:	fffff097          	auipc	ra,0xfffff
    8000140e:	746080e7          	jalr	1862(ra) # 80000b50 <kalloc>
    80001412:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001414:	6605                	lui	a2,0x1
    80001416:	4581                	li	a1,0
    80001418:	00000097          	auipc	ra,0x0
    8000141c:	934080e7          	jalr	-1740(ra) # 80000d4c <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001420:	4779                	li	a4,30
    80001422:	86ca                	mv	a3,s2
    80001424:	6605                	lui	a2,0x1
    80001426:	4581                	li	a1,0
    80001428:	854e                	mv	a0,s3
    8000142a:	00000097          	auipc	ra,0x0
    8000142e:	cfe080e7          	jalr	-770(ra) # 80001128 <mappages>
  memmove(mem, src, sz);
    80001432:	8626                	mv	a2,s1
    80001434:	85d2                	mv	a1,s4
    80001436:	854a                	mv	a0,s2
    80001438:	00000097          	auipc	ra,0x0
    8000143c:	974080e7          	jalr	-1676(ra) # 80000dac <memmove>
}
    80001440:	70a2                	ld	ra,40(sp)
    80001442:	7402                	ld	s0,32(sp)
    80001444:	64e2                	ld	s1,24(sp)
    80001446:	6942                	ld	s2,16(sp)
    80001448:	69a2                	ld	s3,8(sp)
    8000144a:	6a02                	ld	s4,0(sp)
    8000144c:	6145                	addi	sp,sp,48
    8000144e:	8082                	ret
    panic("inituvm: more than a page");
    80001450:	00007517          	auipc	a0,0x7
    80001454:	ce850513          	addi	a0,a0,-792 # 80008138 <etext+0x138>
    80001458:	fffff097          	auipc	ra,0xfffff
    8000145c:	0fe080e7          	jalr	254(ra) # 80000556 <panic>

0000000080001460 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001460:	1101                	addi	sp,sp,-32
    80001462:	ec06                	sd	ra,24(sp)
    80001464:	e822                	sd	s0,16(sp)
    80001466:	e426                	sd	s1,8(sp)
    80001468:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000146a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000146c:	00b67d63          	bgeu	a2,a1,80001486 <uvmdealloc+0x26>
    80001470:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001472:	6785                	lui	a5,0x1
    80001474:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001476:	00f60733          	add	a4,a2,a5
    8000147a:	76fd                	lui	a3,0xfffff
    8000147c:	8f75                	and	a4,a4,a3
    8000147e:	97ae                	add	a5,a5,a1
    80001480:	8ff5                	and	a5,a5,a3
    80001482:	00f76863          	bltu	a4,a5,80001492 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001486:	8526                	mv	a0,s1
    80001488:	60e2                	ld	ra,24(sp)
    8000148a:	6442                	ld	s0,16(sp)
    8000148c:	64a2                	ld	s1,8(sp)
    8000148e:	6105                	addi	sp,sp,32
    80001490:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001492:	8f99                	sub	a5,a5,a4
    80001494:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001496:	4685                	li	a3,1
    80001498:	0007861b          	sext.w	a2,a5
    8000149c:	85ba                	mv	a1,a4
    8000149e:	00000097          	auipc	ra,0x0
    800014a2:	e4e080e7          	jalr	-434(ra) # 800012ec <uvmunmap>
    800014a6:	b7c5                	j	80001486 <uvmdealloc+0x26>

00000000800014a8 <uvmalloc>:
  if(newsz < oldsz)
    800014a8:	0ab66c63          	bltu	a2,a1,80001560 <uvmalloc+0xb8>
{
    800014ac:	715d                	addi	sp,sp,-80
    800014ae:	e486                	sd	ra,72(sp)
    800014b0:	e0a2                	sd	s0,64(sp)
    800014b2:	f84a                	sd	s2,48(sp)
    800014b4:	f052                	sd	s4,32(sp)
    800014b6:	ec56                	sd	s5,24(sp)
    800014b8:	e45e                	sd	s7,8(sp)
    800014ba:	0880                	addi	s0,sp,80
    800014bc:	8aaa                	mv	s5,a0
    800014be:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800014c0:	6785                	lui	a5,0x1
    800014c2:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014c4:	95be                	add	a1,a1,a5
    800014c6:	77fd                	lui	a5,0xfffff
    800014c8:	00f5f933          	and	s2,a1,a5
    800014cc:	8bca                	mv	s7,s2
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014ce:	08c97b63          	bgeu	s2,a2,80001564 <uvmalloc+0xbc>
    800014d2:	fc26                	sd	s1,56(sp)
    800014d4:	f44e                	sd	s3,40(sp)
    800014d6:	e85a                	sd	s6,16(sp)
    memset(mem, 0, PGSIZE);
    800014d8:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800014da:	4b79                	li	s6,30
    mem = kalloc();
    800014dc:	fffff097          	auipc	ra,0xfffff
    800014e0:	674080e7          	jalr	1652(ra) # 80000b50 <kalloc>
    800014e4:	84aa                	mv	s1,a0
    if(mem == 0){
    800014e6:	c90d                	beqz	a0,80001518 <uvmalloc+0x70>
    memset(mem, 0, PGSIZE);
    800014e8:	864e                	mv	a2,s3
    800014ea:	4581                	li	a1,0
    800014ec:	00000097          	auipc	ra,0x0
    800014f0:	860080e7          	jalr	-1952(ra) # 80000d4c <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800014f4:	875a                	mv	a4,s6
    800014f6:	86a6                	mv	a3,s1
    800014f8:	864e                	mv	a2,s3
    800014fa:	85ca                	mv	a1,s2
    800014fc:	8556                	mv	a0,s5
    800014fe:	00000097          	auipc	ra,0x0
    80001502:	c2a080e7          	jalr	-982(ra) # 80001128 <mappages>
    80001506:	ed05                	bnez	a0,8000153e <uvmalloc+0x96>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001508:	994e                	add	s2,s2,s3
    8000150a:	fd4969e3          	bltu	s2,s4,800014dc <uvmalloc+0x34>
  return newsz;
    8000150e:	8552                	mv	a0,s4
    80001510:	74e2                	ld	s1,56(sp)
    80001512:	79a2                	ld	s3,40(sp)
    80001514:	6b42                	ld	s6,16(sp)
    80001516:	a821                	j	8000152e <uvmalloc+0x86>
      uvmdealloc(pagetable, a, oldsz);
    80001518:	865e                	mv	a2,s7
    8000151a:	85ca                	mv	a1,s2
    8000151c:	8556                	mv	a0,s5
    8000151e:	00000097          	auipc	ra,0x0
    80001522:	f42080e7          	jalr	-190(ra) # 80001460 <uvmdealloc>
      return 0;
    80001526:	4501                	li	a0,0
    80001528:	74e2                	ld	s1,56(sp)
    8000152a:	79a2                	ld	s3,40(sp)
    8000152c:	6b42                	ld	s6,16(sp)
}
    8000152e:	60a6                	ld	ra,72(sp)
    80001530:	6406                	ld	s0,64(sp)
    80001532:	7942                	ld	s2,48(sp)
    80001534:	7a02                	ld	s4,32(sp)
    80001536:	6ae2                	ld	s5,24(sp)
    80001538:	6ba2                	ld	s7,8(sp)
    8000153a:	6161                	addi	sp,sp,80
    8000153c:	8082                	ret
      kfree(mem);
    8000153e:	8526                	mv	a0,s1
    80001540:	fffff097          	auipc	ra,0xfffff
    80001544:	50c080e7          	jalr	1292(ra) # 80000a4c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001548:	865e                	mv	a2,s7
    8000154a:	85ca                	mv	a1,s2
    8000154c:	8556                	mv	a0,s5
    8000154e:	00000097          	auipc	ra,0x0
    80001552:	f12080e7          	jalr	-238(ra) # 80001460 <uvmdealloc>
      return 0;
    80001556:	4501                	li	a0,0
    80001558:	74e2                	ld	s1,56(sp)
    8000155a:	79a2                	ld	s3,40(sp)
    8000155c:	6b42                	ld	s6,16(sp)
    8000155e:	bfc1                	j	8000152e <uvmalloc+0x86>
    return oldsz;
    80001560:	852e                	mv	a0,a1
}
    80001562:	8082                	ret
  return newsz;
    80001564:	8532                	mv	a0,a2
    80001566:	b7e1                	j	8000152e <uvmalloc+0x86>

0000000080001568 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001568:	7179                	addi	sp,sp,-48
    8000156a:	f406                	sd	ra,40(sp)
    8000156c:	f022                	sd	s0,32(sp)
    8000156e:	ec26                	sd	s1,24(sp)
    80001570:	e84a                	sd	s2,16(sp)
    80001572:	e44e                	sd	s3,8(sp)
    80001574:	1800                	addi	s0,sp,48
    80001576:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001578:	84aa                	mv	s1,a0
    8000157a:	6905                	lui	s2,0x1
    8000157c:	992a                	add	s2,s2,a0
    8000157e:	a821                	j	80001596 <freewalk+0x2e>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    80001580:	00007517          	auipc	a0,0x7
    80001584:	bd850513          	addi	a0,a0,-1064 # 80008158 <etext+0x158>
    80001588:	fffff097          	auipc	ra,0xfffff
    8000158c:	fce080e7          	jalr	-50(ra) # 80000556 <panic>
  for(int i = 0; i < 512; i++){
    80001590:	04a1                	addi	s1,s1,8
    80001592:	03248363          	beq	s1,s2,800015b8 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001596:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001598:	0017f713          	andi	a4,a5,1
    8000159c:	db75                	beqz	a4,80001590 <freewalk+0x28>
    8000159e:	00e7f713          	andi	a4,a5,14
    800015a2:	ff79                	bnez	a4,80001580 <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    800015a4:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800015a6:	00c79513          	slli	a0,a5,0xc
    800015aa:	00000097          	auipc	ra,0x0
    800015ae:	fbe080e7          	jalr	-66(ra) # 80001568 <freewalk>
      pagetable[i] = 0;
    800015b2:	0004b023          	sd	zero,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015b6:	bfe9                	j	80001590 <freewalk+0x28>
    }
  }
  kfree((void*)pagetable);
    800015b8:	854e                	mv	a0,s3
    800015ba:	fffff097          	auipc	ra,0xfffff
    800015be:	492080e7          	jalr	1170(ra) # 80000a4c <kfree>
}
    800015c2:	70a2                	ld	ra,40(sp)
    800015c4:	7402                	ld	s0,32(sp)
    800015c6:	64e2                	ld	s1,24(sp)
    800015c8:	6942                	ld	s2,16(sp)
    800015ca:	69a2                	ld	s3,8(sp)
    800015cc:	6145                	addi	sp,sp,48
    800015ce:	8082                	ret

00000000800015d0 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015d0:	1101                	addi	sp,sp,-32
    800015d2:	ec06                	sd	ra,24(sp)
    800015d4:	e822                	sd	s0,16(sp)
    800015d6:	e426                	sd	s1,8(sp)
    800015d8:	1000                	addi	s0,sp,32
    800015da:	84aa                	mv	s1,a0
  if(sz > 0)
    800015dc:	e999                	bnez	a1,800015f2 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015de:	8526                	mv	a0,s1
    800015e0:	00000097          	auipc	ra,0x0
    800015e4:	f88080e7          	jalr	-120(ra) # 80001568 <freewalk>
}
    800015e8:	60e2                	ld	ra,24(sp)
    800015ea:	6442                	ld	s0,16(sp)
    800015ec:	64a2                	ld	s1,8(sp)
    800015ee:	6105                	addi	sp,sp,32
    800015f0:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015f2:	6785                	lui	a5,0x1
    800015f4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015f6:	95be                	add	a1,a1,a5
    800015f8:	4685                	li	a3,1
    800015fa:	00c5d613          	srli	a2,a1,0xc
    800015fe:	4581                	li	a1,0
    80001600:	00000097          	auipc	ra,0x0
    80001604:	cec080e7          	jalr	-788(ra) # 800012ec <uvmunmap>
    80001608:	bfd9                	j	800015de <uvmfree+0xe>

000000008000160a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000160a:	c669                	beqz	a2,800016d4 <uvmcopy+0xca>
{
    8000160c:	715d                	addi	sp,sp,-80
    8000160e:	e486                	sd	ra,72(sp)
    80001610:	e0a2                	sd	s0,64(sp)
    80001612:	fc26                	sd	s1,56(sp)
    80001614:	f84a                	sd	s2,48(sp)
    80001616:	f44e                	sd	s3,40(sp)
    80001618:	f052                	sd	s4,32(sp)
    8000161a:	ec56                	sd	s5,24(sp)
    8000161c:	e85a                	sd	s6,16(sp)
    8000161e:	e45e                	sd	s7,8(sp)
    80001620:	0880                	addi	s0,sp,80
    80001622:	8b2a                	mv	s6,a0
    80001624:	8aae                	mv	s5,a1
    80001626:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001628:	4901                	li	s2,0
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000162a:	6985                	lui	s3,0x1
    if((pte = walk(old, i, 0)) == 0)
    8000162c:	4601                	li	a2,0
    8000162e:	85ca                	mv	a1,s2
    80001630:	855a                	mv	a0,s6
    80001632:	00000097          	auipc	ra,0x0
    80001636:	a12080e7          	jalr	-1518(ra) # 80001044 <walk>
    8000163a:	c139                	beqz	a0,80001680 <uvmcopy+0x76>
    if((*pte & PTE_V) == 0)
    8000163c:	00053b83          	ld	s7,0(a0)
    80001640:	001bf793          	andi	a5,s7,1
    80001644:	c7b1                	beqz	a5,80001690 <uvmcopy+0x86>
    if((mem = kalloc()) == 0)
    80001646:	fffff097          	auipc	ra,0xfffff
    8000164a:	50a080e7          	jalr	1290(ra) # 80000b50 <kalloc>
    8000164e:	84aa                	mv	s1,a0
    80001650:	cd29                	beqz	a0,800016aa <uvmcopy+0xa0>
    pa = PTE2PA(*pte);
    80001652:	00abd593          	srli	a1,s7,0xa
    memmove(mem, (char*)pa, PGSIZE);
    80001656:	864e                	mv	a2,s3
    80001658:	05b2                	slli	a1,a1,0xc
    8000165a:	fffff097          	auipc	ra,0xfffff
    8000165e:	752080e7          	jalr	1874(ra) # 80000dac <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001662:	3ffbf713          	andi	a4,s7,1023
    80001666:	86a6                	mv	a3,s1
    80001668:	864e                	mv	a2,s3
    8000166a:	85ca                	mv	a1,s2
    8000166c:	8556                	mv	a0,s5
    8000166e:	00000097          	auipc	ra,0x0
    80001672:	aba080e7          	jalr	-1350(ra) # 80001128 <mappages>
    80001676:	e50d                	bnez	a0,800016a0 <uvmcopy+0x96>
  for(i = 0; i < sz; i += PGSIZE){
    80001678:	994e                	add	s2,s2,s3
    8000167a:	fb4969e3          	bltu	s2,s4,8000162c <uvmcopy+0x22>
    8000167e:	a081                	j	800016be <uvmcopy+0xb4>
      panic("uvmcopy: pte should exist");
    80001680:	00007517          	auipc	a0,0x7
    80001684:	ae850513          	addi	a0,a0,-1304 # 80008168 <etext+0x168>
    80001688:	fffff097          	auipc	ra,0xfffff
    8000168c:	ece080e7          	jalr	-306(ra) # 80000556 <panic>
      panic("uvmcopy: page not present");
    80001690:	00007517          	auipc	a0,0x7
    80001694:	af850513          	addi	a0,a0,-1288 # 80008188 <etext+0x188>
    80001698:	fffff097          	auipc	ra,0xfffff
    8000169c:	ebe080e7          	jalr	-322(ra) # 80000556 <panic>
      kfree(mem);
    800016a0:	8526                	mv	a0,s1
    800016a2:	fffff097          	auipc	ra,0xfffff
    800016a6:	3aa080e7          	jalr	938(ra) # 80000a4c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016aa:	4685                	li	a3,1
    800016ac:	00c95613          	srli	a2,s2,0xc
    800016b0:	4581                	li	a1,0
    800016b2:	8556                	mv	a0,s5
    800016b4:	00000097          	auipc	ra,0x0
    800016b8:	c38080e7          	jalr	-968(ra) # 800012ec <uvmunmap>
  return -1;
    800016bc:	557d                	li	a0,-1
}
    800016be:	60a6                	ld	ra,72(sp)
    800016c0:	6406                	ld	s0,64(sp)
    800016c2:	74e2                	ld	s1,56(sp)
    800016c4:	7942                	ld	s2,48(sp)
    800016c6:	79a2                	ld	s3,40(sp)
    800016c8:	7a02                	ld	s4,32(sp)
    800016ca:	6ae2                	ld	s5,24(sp)
    800016cc:	6b42                	ld	s6,16(sp)
    800016ce:	6ba2                	ld	s7,8(sp)
    800016d0:	6161                	addi	sp,sp,80
    800016d2:	8082                	ret
  return 0;
    800016d4:	4501                	li	a0,0
}
    800016d6:	8082                	ret

00000000800016d8 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016d8:	1141                	addi	sp,sp,-16
    800016da:	e406                	sd	ra,8(sp)
    800016dc:	e022                	sd	s0,0(sp)
    800016de:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016e0:	4601                	li	a2,0
    800016e2:	00000097          	auipc	ra,0x0
    800016e6:	962080e7          	jalr	-1694(ra) # 80001044 <walk>
  if(pte == 0)
    800016ea:	c901                	beqz	a0,800016fa <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016ec:	611c                	ld	a5,0(a0)
    800016ee:	9bbd                	andi	a5,a5,-17
    800016f0:	e11c                	sd	a5,0(a0)
}
    800016f2:	60a2                	ld	ra,8(sp)
    800016f4:	6402                	ld	s0,0(sp)
    800016f6:	0141                	addi	sp,sp,16
    800016f8:	8082                	ret
    panic("uvmclear");
    800016fa:	00007517          	auipc	a0,0x7
    800016fe:	aae50513          	addi	a0,a0,-1362 # 800081a8 <etext+0x1a8>
    80001702:	fffff097          	auipc	ra,0xfffff
    80001706:	e54080e7          	jalr	-428(ra) # 80000556 <panic>

000000008000170a <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000170a:	c6bd                	beqz	a3,80001778 <copyout+0x6e>
{
    8000170c:	715d                	addi	sp,sp,-80
    8000170e:	e486                	sd	ra,72(sp)
    80001710:	e0a2                	sd	s0,64(sp)
    80001712:	fc26                	sd	s1,56(sp)
    80001714:	f84a                	sd	s2,48(sp)
    80001716:	f44e                	sd	s3,40(sp)
    80001718:	f052                	sd	s4,32(sp)
    8000171a:	ec56                	sd	s5,24(sp)
    8000171c:	e85a                	sd	s6,16(sp)
    8000171e:	e45e                	sd	s7,8(sp)
    80001720:	e062                	sd	s8,0(sp)
    80001722:	0880                	addi	s0,sp,80
    80001724:	8b2a                	mv	s6,a0
    80001726:	8c2e                	mv	s8,a1
    80001728:	8a32                	mv	s4,a2
    8000172a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000172c:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000172e:	6a85                	lui	s5,0x1
    80001730:	a015                	j	80001754 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001732:	9562                	add	a0,a0,s8
    80001734:	0004861b          	sext.w	a2,s1
    80001738:	85d2                	mv	a1,s4
    8000173a:	41250533          	sub	a0,a0,s2
    8000173e:	fffff097          	auipc	ra,0xfffff
    80001742:	66e080e7          	jalr	1646(ra) # 80000dac <memmove>

    len -= n;
    80001746:	409989b3          	sub	s3,s3,s1
    src += n;
    8000174a:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    8000174c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001750:	02098263          	beqz	s3,80001774 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001754:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001758:	85ca                	mv	a1,s2
    8000175a:	855a                	mv	a0,s6
    8000175c:	00000097          	auipc	ra,0x0
    80001760:	98e080e7          	jalr	-1650(ra) # 800010ea <walkaddr>
    if(pa0 == 0)
    80001764:	cd01                	beqz	a0,8000177c <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001766:	418904b3          	sub	s1,s2,s8
    8000176a:	94d6                	add	s1,s1,s5
    if(n > len)
    8000176c:	fc99f3e3          	bgeu	s3,s1,80001732 <copyout+0x28>
    80001770:	84ce                	mv	s1,s3
    80001772:	b7c1                	j	80001732 <copyout+0x28>
  }
  return 0;
    80001774:	4501                	li	a0,0
    80001776:	a021                	j	8000177e <copyout+0x74>
    80001778:	4501                	li	a0,0
}
    8000177a:	8082                	ret
      return -1;
    8000177c:	557d                	li	a0,-1
}
    8000177e:	60a6                	ld	ra,72(sp)
    80001780:	6406                	ld	s0,64(sp)
    80001782:	74e2                	ld	s1,56(sp)
    80001784:	7942                	ld	s2,48(sp)
    80001786:	79a2                	ld	s3,40(sp)
    80001788:	7a02                	ld	s4,32(sp)
    8000178a:	6ae2                	ld	s5,24(sp)
    8000178c:	6b42                	ld	s6,16(sp)
    8000178e:	6ba2                	ld	s7,8(sp)
    80001790:	6c02                	ld	s8,0(sp)
    80001792:	6161                	addi	sp,sp,80
    80001794:	8082                	ret

0000000080001796 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001796:	caa5                	beqz	a3,80001806 <copyin+0x70>
{
    80001798:	715d                	addi	sp,sp,-80
    8000179a:	e486                	sd	ra,72(sp)
    8000179c:	e0a2                	sd	s0,64(sp)
    8000179e:	fc26                	sd	s1,56(sp)
    800017a0:	f84a                	sd	s2,48(sp)
    800017a2:	f44e                	sd	s3,40(sp)
    800017a4:	f052                	sd	s4,32(sp)
    800017a6:	ec56                	sd	s5,24(sp)
    800017a8:	e85a                	sd	s6,16(sp)
    800017aa:	e45e                	sd	s7,8(sp)
    800017ac:	e062                	sd	s8,0(sp)
    800017ae:	0880                	addi	s0,sp,80
    800017b0:	8b2a                	mv	s6,a0
    800017b2:	8a2e                	mv	s4,a1
    800017b4:	8c32                	mv	s8,a2
    800017b6:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017b8:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017ba:	6a85                	lui	s5,0x1
    800017bc:	a01d                	j	800017e2 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800017be:	018505b3          	add	a1,a0,s8
    800017c2:	0004861b          	sext.w	a2,s1
    800017c6:	412585b3          	sub	a1,a1,s2
    800017ca:	8552                	mv	a0,s4
    800017cc:	fffff097          	auipc	ra,0xfffff
    800017d0:	5e0080e7          	jalr	1504(ra) # 80000dac <memmove>

    len -= n;
    800017d4:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017d8:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017da:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017de:	02098263          	beqz	s3,80001802 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017e2:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017e6:	85ca                	mv	a1,s2
    800017e8:	855a                	mv	a0,s6
    800017ea:	00000097          	auipc	ra,0x0
    800017ee:	900080e7          	jalr	-1792(ra) # 800010ea <walkaddr>
    if(pa0 == 0)
    800017f2:	cd01                	beqz	a0,8000180a <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800017f4:	418904b3          	sub	s1,s2,s8
    800017f8:	94d6                	add	s1,s1,s5
    if(n > len)
    800017fa:	fc99f2e3          	bgeu	s3,s1,800017be <copyin+0x28>
    800017fe:	84ce                	mv	s1,s3
    80001800:	bf7d                	j	800017be <copyin+0x28>
  }
  return 0;
    80001802:	4501                	li	a0,0
    80001804:	a021                	j	8000180c <copyin+0x76>
    80001806:	4501                	li	a0,0
}
    80001808:	8082                	ret
      return -1;
    8000180a:	557d                	li	a0,-1
}
    8000180c:	60a6                	ld	ra,72(sp)
    8000180e:	6406                	ld	s0,64(sp)
    80001810:	74e2                	ld	s1,56(sp)
    80001812:	7942                	ld	s2,48(sp)
    80001814:	79a2                	ld	s3,40(sp)
    80001816:	7a02                	ld	s4,32(sp)
    80001818:	6ae2                	ld	s5,24(sp)
    8000181a:	6b42                	ld	s6,16(sp)
    8000181c:	6ba2                	ld	s7,8(sp)
    8000181e:	6c02                	ld	s8,0(sp)
    80001820:	6161                	addi	sp,sp,80
    80001822:	8082                	ret

0000000080001824 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001824:	cad5                	beqz	a3,800018d8 <copyinstr+0xb4>
{
    80001826:	715d                	addi	sp,sp,-80
    80001828:	e486                	sd	ra,72(sp)
    8000182a:	e0a2                	sd	s0,64(sp)
    8000182c:	fc26                	sd	s1,56(sp)
    8000182e:	f84a                	sd	s2,48(sp)
    80001830:	f44e                	sd	s3,40(sp)
    80001832:	f052                	sd	s4,32(sp)
    80001834:	ec56                	sd	s5,24(sp)
    80001836:	e85a                	sd	s6,16(sp)
    80001838:	e45e                	sd	s7,8(sp)
    8000183a:	0880                	addi	s0,sp,80
    8000183c:	8aaa                	mv	s5,a0
    8000183e:	84ae                	mv	s1,a1
    80001840:	8bb2                	mv	s7,a2
    80001842:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001844:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001846:	6a05                	lui	s4,0x1
    80001848:	a82d                	j	80001882 <copyinstr+0x5e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000184a:	00078023          	sb	zero,0(a5)
        got_null = 1;
    8000184e:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001850:	0017c793          	xori	a5,a5,1
    80001854:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001858:	60a6                	ld	ra,72(sp)
    8000185a:	6406                	ld	s0,64(sp)
    8000185c:	74e2                	ld	s1,56(sp)
    8000185e:	7942                	ld	s2,48(sp)
    80001860:	79a2                	ld	s3,40(sp)
    80001862:	7a02                	ld	s4,32(sp)
    80001864:	6ae2                	ld	s5,24(sp)
    80001866:	6b42                	ld	s6,16(sp)
    80001868:	6ba2                	ld	s7,8(sp)
    8000186a:	6161                	addi	sp,sp,80
    8000186c:	8082                	ret
    8000186e:	fff98713          	addi	a4,s3,-1 # fff <_entry-0x7ffff001>
    80001872:	9726                	add	a4,a4,s1
      --max;
    80001874:	40b709b3          	sub	s3,a4,a1
    srcva = va0 + PGSIZE;
    80001878:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    8000187c:	04e58663          	beq	a1,a4,800018c8 <copyinstr+0xa4>
{
    80001880:	84be                	mv	s1,a5
    va0 = PGROUNDDOWN(srcva);
    80001882:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    80001886:	85ca                	mv	a1,s2
    80001888:	8556                	mv	a0,s5
    8000188a:	00000097          	auipc	ra,0x0
    8000188e:	860080e7          	jalr	-1952(ra) # 800010ea <walkaddr>
    if(pa0 == 0)
    80001892:	cd0d                	beqz	a0,800018cc <copyinstr+0xa8>
    n = PGSIZE - (srcva - va0);
    80001894:	417906b3          	sub	a3,s2,s7
    80001898:	96d2                	add	a3,a3,s4
    if(n > max)
    8000189a:	00d9f363          	bgeu	s3,a3,800018a0 <copyinstr+0x7c>
    8000189e:	86ce                	mv	a3,s3
    while(n > 0){
    800018a0:	ca85                	beqz	a3,800018d0 <copyinstr+0xac>
    char *p = (char *) (pa0 + (srcva - va0));
    800018a2:	01750633          	add	a2,a0,s7
    800018a6:	41260633          	sub	a2,a2,s2
    800018aa:	87a6                	mv	a5,s1
      if(*p == '\0'){
    800018ac:	8e05                	sub	a2,a2,s1
    while(n > 0){
    800018ae:	96a6                	add	a3,a3,s1
    800018b0:	85be                	mv	a1,a5
      if(*p == '\0'){
    800018b2:	00f60733          	add	a4,a2,a5
    800018b6:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd5000>
    800018ba:	db41                	beqz	a4,8000184a <copyinstr+0x26>
        *dst = *p;
    800018bc:	00e78023          	sb	a4,0(a5)
      dst++;
    800018c0:	0785                	addi	a5,a5,1
    while(n > 0){
    800018c2:	fed797e3          	bne	a5,a3,800018b0 <copyinstr+0x8c>
    800018c6:	b765                	j	8000186e <copyinstr+0x4a>
    800018c8:	4781                	li	a5,0
    800018ca:	b759                	j	80001850 <copyinstr+0x2c>
      return -1;
    800018cc:	557d                	li	a0,-1
    800018ce:	b769                	j	80001858 <copyinstr+0x34>
    srcva = va0 + PGSIZE;
    800018d0:	6b85                	lui	s7,0x1
    800018d2:	9bca                	add	s7,s7,s2
    800018d4:	87a6                	mv	a5,s1
    800018d6:	b76d                	j	80001880 <copyinstr+0x5c>
  int got_null = 0;
    800018d8:	4781                	li	a5,0
  if(got_null){
    800018da:	0017c793          	xori	a5,a5,1
    800018de:	40f0053b          	negw	a0,a5
}
    800018e2:	8082                	ret

00000000800018e4 <proc_mapstacks>:
// Lock global usado por wait() para evitar condiciones de carrera
struct spinlock wait_lock;

// Mapea un stack de kernel para cada proceso
void
proc_mapstacks(pagetable_t kpgtbl) {
    800018e4:	715d                	addi	sp,sp,-80
    800018e6:	e486                	sd	ra,72(sp)
    800018e8:	e0a2                	sd	s0,64(sp)
    800018ea:	fc26                	sd	s1,56(sp)
    800018ec:	f84a                	sd	s2,48(sp)
    800018ee:	f44e                	sd	s3,40(sp)
    800018f0:	f052                	sd	s4,32(sp)
    800018f2:	ec56                	sd	s5,24(sp)
    800018f4:	e85a                	sd	s6,16(sp)
    800018f6:	e45e                	sd	s7,8(sp)
    800018f8:	e062                	sd	s8,0(sp)
    800018fa:	0880                	addi	s0,sp,80
    800018fc:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800018fe:	00013497          	auipc	s1,0x13
    80001902:	dd248493          	addi	s1,s1,-558 # 800146d0 <proc>
    char *pa = kalloc(); // se reserva memoria fisica
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc)); // direccion virtual del stack del proceso
    80001906:	8c26                	mv	s8,s1
    80001908:	ff048937          	lui	s2,0xff048
    8000190c:	dc190913          	addi	s2,s2,-575 # ffffffffff047dc1 <end+0xffffffff7f01ddc1>
    80001910:	0932                	slli	s2,s2,0xc
    80001912:	1f790913          	addi	s2,s2,503
    80001916:	093e                	slli	s2,s2,0xf
    80001918:	23f90913          	addi	s2,s2,575
    8000191c:	0932                	slli	s2,s2,0xc
    8000191e:	e0990913          	addi	s2,s2,-503
    80001922:	040009b7          	lui	s3,0x4000
    80001926:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001928:	09b2                	slli	s3,s3,0xc
    // Se mapea el stack del kernel en el espacio del kernel
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000192a:	4b99                	li	s7,6
    8000192c:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    8000192e:	0001aa97          	auipc	s5,0x1a
    80001932:	fa2a8a93          	addi	s5,s5,-94 # 8001b8d0 <tickslock>
    char *pa = kalloc(); // se reserva memoria fisica
    80001936:	fffff097          	auipc	ra,0xfffff
    8000193a:	21a080e7          	jalr	538(ra) # 80000b50 <kalloc>
    8000193e:	862a                	mv	a2,a0
    if(pa == 0)
    80001940:	c131                	beqz	a0,80001984 <proc_mapstacks+0xa0>
    uint64 va = KSTACK((int) (p - proc)); // direccion virtual del stack del proceso
    80001942:	418485b3          	sub	a1,s1,s8
    80001946:	858d                	srai	a1,a1,0x3
    80001948:	032585b3          	mul	a1,a1,s2
    8000194c:	05b6                	slli	a1,a1,0xd
    8000194e:	6789                	lui	a5,0x2
    80001950:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001952:	875e                	mv	a4,s7
    80001954:	86da                	mv	a3,s6
    80001956:	40b985b3          	sub	a1,s3,a1
    8000195a:	8552                	mv	a0,s4
    8000195c:	00000097          	auipc	ra,0x0
    80001960:	86e080e7          	jalr	-1938(ra) # 800011ca <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001964:	1c848493          	addi	s1,s1,456
    80001968:	fd5497e3          	bne	s1,s5,80001936 <proc_mapstacks+0x52>
  }
}
    8000196c:	60a6                	ld	ra,72(sp)
    8000196e:	6406                	ld	s0,64(sp)
    80001970:	74e2                	ld	s1,56(sp)
    80001972:	7942                	ld	s2,48(sp)
    80001974:	79a2                	ld	s3,40(sp)
    80001976:	7a02                	ld	s4,32(sp)
    80001978:	6ae2                	ld	s5,24(sp)
    8000197a:	6b42                	ld	s6,16(sp)
    8000197c:	6ba2                	ld	s7,8(sp)
    8000197e:	6c02                	ld	s8,0(sp)
    80001980:	6161                	addi	sp,sp,80
    80001982:	8082                	ret
      panic("kalloc");
    80001984:	00007517          	auipc	a0,0x7
    80001988:	83450513          	addi	a0,a0,-1996 # 800081b8 <etext+0x1b8>
    8000198c:	fffff097          	auipc	ra,0xfffff
    80001990:	bca080e7          	jalr	-1078(ra) # 80000556 <panic>

0000000080001994 <procinit>:

// Inicializa la tabla de procesos al arrancar el sistema
void
procinit(void)
{
    80001994:	7139                	addi	sp,sp,-64
    80001996:	fc06                	sd	ra,56(sp)
    80001998:	f822                	sd	s0,48(sp)
    8000199a:	f426                	sd	s1,40(sp)
    8000199c:	f04a                	sd	s2,32(sp)
    8000199e:	ec4e                	sd	s3,24(sp)
    800019a0:	e852                	sd	s4,16(sp)
    800019a2:	e456                	sd	s5,8(sp)
    800019a4:	e05a                	sd	s6,0(sp)
    800019a6:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");   // lock para generar PIDs
    800019a8:	00007597          	auipc	a1,0x7
    800019ac:	81858593          	addi	a1,a1,-2024 # 800081c0 <etext+0x1c0>
    800019b0:	00013517          	auipc	a0,0x13
    800019b4:	8f050513          	addi	a0,a0,-1808 # 800142a0 <pid_lock>
    800019b8:	fffff097          	auipc	ra,0xfffff
    800019bc:	202080e7          	jalr	514(ra) # 80000bba <initlock>
  initlock(&wait_lock, "wait_lock");// lock para wait()
    800019c0:	00007597          	auipc	a1,0x7
    800019c4:	80858593          	addi	a1,a1,-2040 # 800081c8 <etext+0x1c8>
    800019c8:	00013517          	auipc	a0,0x13
    800019cc:	8f050513          	addi	a0,a0,-1808 # 800142b8 <wait_lock>
    800019d0:	fffff097          	auipc	ra,0xfffff
    800019d4:	1ea080e7          	jalr	490(ra) # 80000bba <initlock>

  for(p = proc; p < &proc[NPROC]; p++) {
    800019d8:	00013497          	auipc	s1,0x13
    800019dc:	cf848493          	addi	s1,s1,-776 # 800146d0 <proc>
      initlock(&p->lock, "proc");   // lock por proceso
    800019e0:	00006b17          	auipc	s6,0x6
    800019e4:	7f8b0b13          	addi	s6,s6,2040 # 800081d8 <etext+0x1d8>
      p->kstack = KSTACK((int) (p - proc)); // direccion del stack del kernel
    800019e8:	8aa6                	mv	s5,s1
    800019ea:	ff048937          	lui	s2,0xff048
    800019ee:	dc190913          	addi	s2,s2,-575 # ffffffffff047dc1 <end+0xffffffff7f01ddc1>
    800019f2:	0932                	slli	s2,s2,0xc
    800019f4:	1f790913          	addi	s2,s2,503
    800019f8:	093e                	slli	s2,s2,0xf
    800019fa:	23f90913          	addi	s2,s2,575
    800019fe:	0932                	slli	s2,s2,0xc
    80001a00:	e0990913          	addi	s2,s2,-503
    80001a04:	040009b7          	lui	s3,0x4000
    80001a08:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001a0a:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a0c:	0001aa17          	auipc	s4,0x1a
    80001a10:	ec4a0a13          	addi	s4,s4,-316 # 8001b8d0 <tickslock>
      initlock(&p->lock, "proc");   // lock por proceso
    80001a14:	85da                	mv	a1,s6
    80001a16:	8526                	mv	a0,s1
    80001a18:	fffff097          	auipc	ra,0xfffff
    80001a1c:	1a2080e7          	jalr	418(ra) # 80000bba <initlock>
      p->kstack = KSTACK((int) (p - proc)); // direccion del stack del kernel
    80001a20:	415487b3          	sub	a5,s1,s5
    80001a24:	878d                	srai	a5,a5,0x3
    80001a26:	032787b3          	mul	a5,a5,s2
    80001a2a:	07b6                	slli	a5,a5,0xd
    80001a2c:	6709                	lui	a4,0x2
    80001a2e:	9fb9                	addw	a5,a5,a4
    80001a30:	40f987b3          	sub	a5,s3,a5
    80001a34:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a36:	1c848493          	addi	s1,s1,456
    80001a3a:	fd449de3          	bne	s1,s4,80001a14 <procinit+0x80>
  }
}
    80001a3e:	70e2                	ld	ra,56(sp)
    80001a40:	7442                	ld	s0,48(sp)
    80001a42:	74a2                	ld	s1,40(sp)
    80001a44:	7902                	ld	s2,32(sp)
    80001a46:	69e2                	ld	s3,24(sp)
    80001a48:	6a42                	ld	s4,16(sp)
    80001a4a:	6aa2                	ld	s5,8(sp)
    80001a4c:	6b02                	ld	s6,0(sp)
    80001a4e:	6121                	addi	sp,sp,64
    80001a50:	8082                	ret

0000000080001a52 <cpuid>:

// Retorna el ID del CPU actual
int
cpuid()
{
    80001a52:	1141                	addi	sp,sp,-16
    80001a54:	e406                	sd	ra,8(sp)
    80001a56:	e022                	sd	s0,0(sp)
    80001a58:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a5a:	8512                	mv	a0,tp
  int id = r_tp(); // tp contiene el hartid
  return id;
}
    80001a5c:	2501                	sext.w	a0,a0
    80001a5e:	60a2                	ld	ra,8(sp)
    80001a60:	6402                	ld	s0,0(sp)
    80001a62:	0141                	addi	sp,sp,16
    80001a64:	8082                	ret

0000000080001a66 <mycpu>:

// Retorna la estructura cpu correspondiente al CPU actual
struct cpu*
mycpu(void) {
    80001a66:	1141                	addi	sp,sp,-16
    80001a68:	e406                	sd	ra,8(sp)
    80001a6a:	e022                	sd	s0,0(sp)
    80001a6c:	0800                	addi	s0,sp,16
    80001a6e:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a70:	2781                	sext.w	a5,a5
    80001a72:	079e                	slli	a5,a5,0x7
  return c;
}
    80001a74:	00013517          	auipc	a0,0x13
    80001a78:	85c50513          	addi	a0,a0,-1956 # 800142d0 <cpus>
    80001a7c:	953e                	add	a0,a0,a5
    80001a7e:	60a2                	ld	ra,8(sp)
    80001a80:	6402                	ld	s0,0(sp)
    80001a82:	0141                	addi	sp,sp,16
    80001a84:	8082                	ret

0000000080001a86 <myproc>:

// Retorna el proceso actual en ejecucion
struct proc*
myproc(void) {
    80001a86:	1101                	addi	sp,sp,-32
    80001a88:	ec06                	sd	ra,24(sp)
    80001a8a:	e822                	sd	s0,16(sp)
    80001a8c:	e426                	sd	s1,8(sp)
    80001a8e:	1000                	addi	s0,sp,32
  push_off(); // deshabilitar interrupciones
    80001a90:	fffff097          	auipc	ra,0xfffff
    80001a94:	174080e7          	jalr	372(ra) # 80000c04 <push_off>
    80001a98:	8792                	mv	a5,tp
  struct cpu *c = mycpu(); 
  struct proc *p = c->proc;
    80001a9a:	2781                	sext.w	a5,a5
    80001a9c:	079e                	slli	a5,a5,0x7
    80001a9e:	00013717          	auipc	a4,0x13
    80001aa2:	80270713          	addi	a4,a4,-2046 # 800142a0 <pid_lock>
    80001aa6:	97ba                	add	a5,a5,a4
    80001aa8:	7b9c                	ld	a5,48(a5)
    80001aaa:	84be                	mv	s1,a5
  pop_off();
    80001aac:	fffff097          	auipc	ra,0xfffff
    80001ab0:	1fc080e7          	jalr	508(ra) # 80000ca8 <pop_off>
  return p;
}
    80001ab4:	8526                	mv	a0,s1
    80001ab6:	60e2                	ld	ra,24(sp)
    80001ab8:	6442                	ld	s0,16(sp)
    80001aba:	64a2                	ld	s1,8(sp)
    80001abc:	6105                	addi	sp,sp,32
    80001abe:	8082                	ret

0000000080001ac0 <forkret>:
}

// Entrada del primer scheduler despues de fork
void
forkret(void)
{
    80001ac0:	1141                	addi	sp,sp,-16
    80001ac2:	e406                	sd	ra,8(sp)
    80001ac4:	e022                	sd	s0,0(sp)
    80001ac6:	0800                	addi	s0,sp,16
  static int first = 1;

  release(&myproc()->lock);
    80001ac8:	00000097          	auipc	ra,0x0
    80001acc:	fbe080e7          	jalr	-66(ra) # 80001a86 <myproc>
    80001ad0:	fffff097          	auipc	ra,0xfffff
    80001ad4:	234080e7          	jalr	564(ra) # 80000d04 <release>

  if (first) {
    80001ad8:	0000a797          	auipc	a5,0xa
    80001adc:	9987a783          	lw	a5,-1640(a5) # 8000b470 <first.1>
    80001ae0:	eb89                	bnez	a5,80001af2 <forkret+0x32>
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001ae2:	00001097          	auipc	ra,0x1
    80001ae6:	fe4080e7          	jalr	-28(ra) # 80002ac6 <usertrapret>
}
    80001aea:	60a2                	ld	ra,8(sp)
    80001aec:	6402                	ld	s0,0(sp)
    80001aee:	0141                	addi	sp,sp,16
    80001af0:	8082                	ret
    first = 0;
    80001af2:	0000a797          	auipc	a5,0xa
    80001af6:	9607af23          	sw	zero,-1666(a5) # 8000b470 <first.1>
    fsinit(ROOTDEV);
    80001afa:	4505                	li	a0,1
    80001afc:	00002097          	auipc	ra,0x2
    80001b00:	f1c080e7          	jalr	-228(ra) # 80003a18 <fsinit>
    80001b04:	bff9                	j	80001ae2 <forkret+0x22>

0000000080001b06 <allocpid>:
allocpid() {
    80001b06:	1101                	addi	sp,sp,-32
    80001b08:	ec06                	sd	ra,24(sp)
    80001b0a:	e822                	sd	s0,16(sp)
    80001b0c:	e426                	sd	s1,8(sp)
    80001b0e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b10:	00012517          	auipc	a0,0x12
    80001b14:	79050513          	addi	a0,a0,1936 # 800142a0 <pid_lock>
    80001b18:	fffff097          	auipc	ra,0xfffff
    80001b1c:	13c080e7          	jalr	316(ra) # 80000c54 <acquire>
  pid = nextpid;
    80001b20:	0000a797          	auipc	a5,0xa
    80001b24:	95478793          	addi	a5,a5,-1708 # 8000b474 <nextpid>
    80001b28:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1; // incrementa PID
    80001b2a:	0014871b          	addiw	a4,s1,1
    80001b2e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b30:	00012517          	auipc	a0,0x12
    80001b34:	77050513          	addi	a0,a0,1904 # 800142a0 <pid_lock>
    80001b38:	fffff097          	auipc	ra,0xfffff
    80001b3c:	1cc080e7          	jalr	460(ra) # 80000d04 <release>
}
    80001b40:	8526                	mv	a0,s1
    80001b42:	60e2                	ld	ra,24(sp)
    80001b44:	6442                	ld	s0,16(sp)
    80001b46:	64a2                	ld	s1,8(sp)
    80001b48:	6105                	addi	sp,sp,32
    80001b4a:	8082                	ret

0000000080001b4c <proc_pagetable>:
{
    80001b4c:	1101                	addi	sp,sp,-32
    80001b4e:	ec06                	sd	ra,24(sp)
    80001b50:	e822                	sd	s0,16(sp)
    80001b52:	e426                	sd	s1,8(sp)
    80001b54:	e04a                	sd	s2,0(sp)
    80001b56:	1000                	addi	s0,sp,32
    80001b58:	892a                	mv	s2,a0
  pagetable = uvmcreate(); // tabla vacia
    80001b5a:	00000097          	auipc	ra,0x0
    80001b5e:	866080e7          	jalr	-1946(ra) # 800013c0 <uvmcreate>
    80001b62:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b64:	c121                	beqz	a0,80001ba4 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b66:	4729                	li	a4,10
    80001b68:	00005697          	auipc	a3,0x5
    80001b6c:	49868693          	addi	a3,a3,1176 # 80007000 <_trampoline>
    80001b70:	6605                	lui	a2,0x1
    80001b72:	040005b7          	lui	a1,0x4000
    80001b76:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b78:	05b2                	slli	a1,a1,0xc
    80001b7a:	fffff097          	auipc	ra,0xfffff
    80001b7e:	5ae080e7          	jalr	1454(ra) # 80001128 <mappages>
    80001b82:	02054863          	bltz	a0,80001bb2 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b86:	4719                	li	a4,6
    80001b88:	05893683          	ld	a3,88(s2)
    80001b8c:	6605                	lui	a2,0x1
    80001b8e:	020005b7          	lui	a1,0x2000
    80001b92:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b94:	05b6                	slli	a1,a1,0xd
    80001b96:	8526                	mv	a0,s1
    80001b98:	fffff097          	auipc	ra,0xfffff
    80001b9c:	590080e7          	jalr	1424(ra) # 80001128 <mappages>
    80001ba0:	02054163          	bltz	a0,80001bc2 <proc_pagetable+0x76>
}
    80001ba4:	8526                	mv	a0,s1
    80001ba6:	60e2                	ld	ra,24(sp)
    80001ba8:	6442                	ld	s0,16(sp)
    80001baa:	64a2                	ld	s1,8(sp)
    80001bac:	6902                	ld	s2,0(sp)
    80001bae:	6105                	addi	sp,sp,32
    80001bb0:	8082                	ret
    uvmfree(pagetable, 0);
    80001bb2:	4581                	li	a1,0
    80001bb4:	8526                	mv	a0,s1
    80001bb6:	00000097          	auipc	ra,0x0
    80001bba:	a1a080e7          	jalr	-1510(ra) # 800015d0 <uvmfree>
    return 0;
    80001bbe:	4481                	li	s1,0
    80001bc0:	b7d5                	j	80001ba4 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bc2:	4681                	li	a3,0
    80001bc4:	4605                	li	a2,1
    80001bc6:	040005b7          	lui	a1,0x4000
    80001bca:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bcc:	05b2                	slli	a1,a1,0xc
    80001bce:	8526                	mv	a0,s1
    80001bd0:	fffff097          	auipc	ra,0xfffff
    80001bd4:	71c080e7          	jalr	1820(ra) # 800012ec <uvmunmap>
    uvmfree(pagetable, 0);
    80001bd8:	4581                	li	a1,0
    80001bda:	8526                	mv	a0,s1
    80001bdc:	00000097          	auipc	ra,0x0
    80001be0:	9f4080e7          	jalr	-1548(ra) # 800015d0 <uvmfree>
    return 0;
    80001be4:	4481                	li	s1,0
    80001be6:	bf7d                	j	80001ba4 <proc_pagetable+0x58>

0000000080001be8 <proc_freepagetable>:
{
    80001be8:	1101                	addi	sp,sp,-32
    80001bea:	ec06                	sd	ra,24(sp)
    80001bec:	e822                	sd	s0,16(sp)
    80001bee:	e426                	sd	s1,8(sp)
    80001bf0:	e04a                	sd	s2,0(sp)
    80001bf2:	1000                	addi	s0,sp,32
    80001bf4:	84aa                	mv	s1,a0
    80001bf6:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bf8:	4681                	li	a3,0
    80001bfa:	4605                	li	a2,1
    80001bfc:	040005b7          	lui	a1,0x4000
    80001c00:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c02:	05b2                	slli	a1,a1,0xc
    80001c04:	fffff097          	auipc	ra,0xfffff
    80001c08:	6e8080e7          	jalr	1768(ra) # 800012ec <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c0c:	4681                	li	a3,0
    80001c0e:	4605                	li	a2,1
    80001c10:	020005b7          	lui	a1,0x2000
    80001c14:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c16:	05b6                	slli	a1,a1,0xd
    80001c18:	8526                	mv	a0,s1
    80001c1a:	fffff097          	auipc	ra,0xfffff
    80001c1e:	6d2080e7          	jalr	1746(ra) # 800012ec <uvmunmap>
  uvmfree(pagetable, sz); // liberar memoria
    80001c22:	85ca                	mv	a1,s2
    80001c24:	8526                	mv	a0,s1
    80001c26:	00000097          	auipc	ra,0x0
    80001c2a:	9aa080e7          	jalr	-1622(ra) # 800015d0 <uvmfree>
}
    80001c2e:	60e2                	ld	ra,24(sp)
    80001c30:	6442                	ld	s0,16(sp)
    80001c32:	64a2                	ld	s1,8(sp)
    80001c34:	6902                	ld	s2,0(sp)
    80001c36:	6105                	addi	sp,sp,32
    80001c38:	8082                	ret

0000000080001c3a <freeproc>:
{
    80001c3a:	1101                	addi	sp,sp,-32
    80001c3c:	ec06                	sd	ra,24(sp)
    80001c3e:	e822                	sd	s0,16(sp)
    80001c40:	e426                	sd	s1,8(sp)
    80001c42:	1000                	addi	s0,sp,32
    80001c44:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c46:	6d28                	ld	a0,88(a0)
    80001c48:	c509                	beqz	a0,80001c52 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	e02080e7          	jalr	-510(ra) # 80000a4c <kfree>
  p->trapframe = 0;
    80001c52:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001c56:	68a8                	ld	a0,80(s1)
    80001c58:	c511                	beqz	a0,80001c64 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz); // liberar memoria del usuario
    80001c5a:	64ac                	ld	a1,72(s1)
    80001c5c:	00000097          	auipc	ra,0x0
    80001c60:	f8c080e7          	jalr	-116(ra) # 80001be8 <proc_freepagetable>
  p->pagetable = 0;
    80001c64:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c68:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c6c:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c70:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;   // limpiar nombre
    80001c74:	14048c23          	sb	zero,344(s1)
  p->chan = 0;      // canal de sleep
    80001c78:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c7c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c80:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED; // disponible nuevamente
    80001c84:	0004ac23          	sw	zero,24(s1)
}
    80001c88:	60e2                	ld	ra,24(sp)
    80001c8a:	6442                	ld	s0,16(sp)
    80001c8c:	64a2                	ld	s1,8(sp)
    80001c8e:	6105                	addi	sp,sp,32
    80001c90:	8082                	ret

0000000080001c92 <allocproc>:
{
    80001c92:	1101                	addi	sp,sp,-32
    80001c94:	ec06                	sd	ra,24(sp)
    80001c96:	e822                	sd	s0,16(sp)
    80001c98:	e426                	sd	s1,8(sp)
    80001c9a:	e04a                	sd	s2,0(sp)
    80001c9c:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c9e:	00013497          	auipc	s1,0x13
    80001ca2:	a3248493          	addi	s1,s1,-1486 # 800146d0 <proc>
    80001ca6:	0001a917          	auipc	s2,0x1a
    80001caa:	c2a90913          	addi	s2,s2,-982 # 8001b8d0 <tickslock>
    acquire(&p->lock);
    80001cae:	8526                	mv	a0,s1
    80001cb0:	fffff097          	auipc	ra,0xfffff
    80001cb4:	fa4080e7          	jalr	-92(ra) # 80000c54 <acquire>
    if(p->state == UNUSED) {
    80001cb8:	4c9c                	lw	a5,24(s1)
    80001cba:	cf81                	beqz	a5,80001cd2 <allocproc+0x40>
      release(&p->lock);
    80001cbc:	8526                	mv	a0,s1
    80001cbe:	fffff097          	auipc	ra,0xfffff
    80001cc2:	046080e7          	jalr	70(ra) # 80000d04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cc6:	1c848493          	addi	s1,s1,456
    80001cca:	ff2492e3          	bne	s1,s2,80001cae <allocproc+0x1c>
  return 0;
    80001cce:	4481                	li	s1,0
    80001cd0:	a8bd                	j	80001d4e <allocproc+0xbc>
  p->pid = allocpid();   // asignar un PID
    80001cd2:	00000097          	auipc	ra,0x0
    80001cd6:	e34080e7          	jalr	-460(ra) # 80001b06 <allocpid>
    80001cda:	d888                	sw	a0,48(s1)
  p->state = USED;       // el proceso ahora esta ocupado
    80001cdc:	4785                	li	a5,1
    80001cde:	cc9c                	sw	a5,24(s1)
  p->create_time = ticks;
    80001ce0:	0000a797          	auipc	a5,0xa
    80001ce4:	3507e783          	lwu	a5,848(a5) # 8000c030 <ticks>
    80001ce8:	16f4b823          	sd	a5,368(s1)
  p->run_time = 0;
    80001cec:	1604bc23          	sd	zero,376(s1)
  p->start_time = 0;
    80001cf0:	1804b823          	sd	zero,400(s1)
  p->sleep_time = 0;
    80001cf4:	1804bc23          	sd	zero,408(s1)
  p->total_run_time = 0;
    80001cf8:	1804b023          	sd	zero,384(s1)
  p->exit_time = 0;
    80001cfc:	1a04b023          	sd	zero,416(s1)
  p->n_runs = 0;
    80001d00:	1a04b423          	sd	zero,424(s1)
  p->priority = 60; // prioridad por defecto usada en PBS
    80001d04:	03c00793          	li	a5,60
    80001d08:	1af4b823          	sd	a5,432(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001d0c:	fffff097          	auipc	ra,0xfffff
    80001d10:	e44080e7          	jalr	-444(ra) # 80000b50 <kalloc>
    80001d14:	892a                	mv	s2,a0
    80001d16:	eca8                	sd	a0,88(s1)
    80001d18:	c131                	beqz	a0,80001d5c <allocproc+0xca>
  p->pagetable = proc_pagetable(p);
    80001d1a:	8526                	mv	a0,s1
    80001d1c:	00000097          	auipc	ra,0x0
    80001d20:	e30080e7          	jalr	-464(ra) # 80001b4c <proc_pagetable>
    80001d24:	892a                	mv	s2,a0
    80001d26:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001d28:	c531                	beqz	a0,80001d74 <allocproc+0xe2>
  memset(&p->context, 0, sizeof(p->context));
    80001d2a:	07000613          	li	a2,112
    80001d2e:	4581                	li	a1,0
    80001d30:	06048513          	addi	a0,s1,96
    80001d34:	fffff097          	auipc	ra,0xfffff
    80001d38:	018080e7          	jalr	24(ra) # 80000d4c <memset>
  p->context.ra = (uint64)forkret;     // direccion de retorno para fork()
    80001d3c:	00000797          	auipc	a5,0x0
    80001d40:	d8478793          	addi	a5,a5,-636 # 80001ac0 <forkret>
    80001d44:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;  // stack pointer del kernel
    80001d46:	60bc                	ld	a5,64(s1)
    80001d48:	6705                	lui	a4,0x1
    80001d4a:	97ba                	add	a5,a5,a4
    80001d4c:	f4bc                	sd	a5,104(s1)
}
    80001d4e:	8526                	mv	a0,s1
    80001d50:	60e2                	ld	ra,24(sp)
    80001d52:	6442                	ld	s0,16(sp)
    80001d54:	64a2                	ld	s1,8(sp)
    80001d56:	6902                	ld	s2,0(sp)
    80001d58:	6105                	addi	sp,sp,32
    80001d5a:	8082                	ret
    freeproc(p); // si falla memoria se limpia el proceso
    80001d5c:	8526                	mv	a0,s1
    80001d5e:	00000097          	auipc	ra,0x0
    80001d62:	edc080e7          	jalr	-292(ra) # 80001c3a <freeproc>
    release(&p->lock);
    80001d66:	8526                	mv	a0,s1
    80001d68:	fffff097          	auipc	ra,0xfffff
    80001d6c:	f9c080e7          	jalr	-100(ra) # 80000d04 <release>
    return 0;
    80001d70:	84ca                	mv	s1,s2
    80001d72:	bff1                	j	80001d4e <allocproc+0xbc>
    freeproc(p);
    80001d74:	8526                	mv	a0,s1
    80001d76:	00000097          	auipc	ra,0x0
    80001d7a:	ec4080e7          	jalr	-316(ra) # 80001c3a <freeproc>
    release(&p->lock);
    80001d7e:	8526                	mv	a0,s1
    80001d80:	fffff097          	auipc	ra,0xfffff
    80001d84:	f84080e7          	jalr	-124(ra) # 80000d04 <release>
    return 0;
    80001d88:	84ca                	mv	s1,s2
    80001d8a:	b7d1                	j	80001d4e <allocproc+0xbc>

0000000080001d8c <userinit>:
{
    80001d8c:	1101                	addi	sp,sp,-32
    80001d8e:	ec06                	sd	ra,24(sp)
    80001d90:	e822                	sd	s0,16(sp)
    80001d92:	e426                	sd	s1,8(sp)
    80001d94:	1000                	addi	s0,sp,32
  p = allocproc(); // nuevo proceso
    80001d96:	00000097          	auipc	ra,0x0
    80001d9a:	efc080e7          	jalr	-260(ra) # 80001c92 <allocproc>
    80001d9e:	84aa                	mv	s1,a0
  initproc = p;
    80001da0:	0000a797          	auipc	a5,0xa
    80001da4:	28a7b423          	sd	a0,648(a5) # 8000c028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001da8:	03400613          	li	a2,52
    80001dac:	00009597          	auipc	a1,0x9
    80001db0:	6d458593          	addi	a1,a1,1748 # 8000b480 <initcode>
    80001db4:	6928                	ld	a0,80(a0)
    80001db6:	fffff097          	auipc	ra,0xfffff
    80001dba:	638080e7          	jalr	1592(ra) # 800013ee <uvminit>
  p->sz = PGSIZE;
    80001dbe:	6785                	lui	a5,0x1
    80001dc0:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;
    80001dc2:	6cb8                	ld	a4,88(s1)
    80001dc4:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;
    80001dc8:	6cb8                	ld	a4,88(s1)
    80001dca:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001dcc:	4641                	li	a2,16
    80001dce:	00006597          	auipc	a1,0x6
    80001dd2:	41258593          	addi	a1,a1,1042 # 800081e0 <etext+0x1e0>
    80001dd6:	15848513          	addi	a0,s1,344
    80001dda:	fffff097          	auipc	ra,0xfffff
    80001dde:	0ca080e7          	jalr	202(ra) # 80000ea4 <safestrcpy>
  p->cwd = namei("/"); // directorio raiz
    80001de2:	00006517          	auipc	a0,0x6
    80001de6:	40e50513          	addi	a0,a0,1038 # 800081f0 <etext+0x1f0>
    80001dea:	00002097          	auipc	ra,0x2
    80001dee:	692080e7          	jalr	1682(ra) # 8000447c <namei>
    80001df2:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE; // listo para ejecutar
    80001df6:	478d                	li	a5,3
    80001df8:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001dfa:	8526                	mv	a0,s1
    80001dfc:	fffff097          	auipc	ra,0xfffff
    80001e00:	f08080e7          	jalr	-248(ra) # 80000d04 <release>
}
    80001e04:	60e2                	ld	ra,24(sp)
    80001e06:	6442                	ld	s0,16(sp)
    80001e08:	64a2                	ld	s1,8(sp)
    80001e0a:	6105                	addi	sp,sp,32
    80001e0c:	8082                	ret

0000000080001e0e <growproc>:
{
    80001e0e:	1101                	addi	sp,sp,-32
    80001e10:	ec06                	sd	ra,24(sp)
    80001e12:	e822                	sd	s0,16(sp)
    80001e14:	e426                	sd	s1,8(sp)
    80001e16:	e04a                	sd	s2,0(sp)
    80001e18:	1000                	addi	s0,sp,32
    80001e1a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001e1c:	00000097          	auipc	ra,0x0
    80001e20:	c6a080e7          	jalr	-918(ra) # 80001a86 <myproc>
    80001e24:	892a                	mv	s2,a0
  sz = p->sz;
    80001e26:	652c                	ld	a1,72(a0)
    80001e28:	0005879b          	sext.w	a5,a1
  if(n > 0){
    80001e2c:	00904f63          	bgtz	s1,80001e4a <growproc+0x3c>
  } else if(n < 0){
    80001e30:	0204cd63          	bltz	s1,80001e6a <growproc+0x5c>
  p->sz = sz;
    80001e34:	1782                	slli	a5,a5,0x20
    80001e36:	9381                	srli	a5,a5,0x20
    80001e38:	04f93423          	sd	a5,72(s2)
  return 0;
    80001e3c:	4501                	li	a0,0
}
    80001e3e:	60e2                	ld	ra,24(sp)
    80001e40:	6442                	ld	s0,16(sp)
    80001e42:	64a2                	ld	s1,8(sp)
    80001e44:	6902                	ld	s2,0(sp)
    80001e46:	6105                	addi	sp,sp,32
    80001e48:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0)
    80001e4a:	00f4863b          	addw	a2,s1,a5
    80001e4e:	1602                	slli	a2,a2,0x20
    80001e50:	9201                	srli	a2,a2,0x20
    80001e52:	1582                	slli	a1,a1,0x20
    80001e54:	9181                	srli	a1,a1,0x20
    80001e56:	6928                	ld	a0,80(a0)
    80001e58:	fffff097          	auipc	ra,0xfffff
    80001e5c:	650080e7          	jalr	1616(ra) # 800014a8 <uvmalloc>
    80001e60:	0005079b          	sext.w	a5,a0
    80001e64:	fbe1                	bnez	a5,80001e34 <growproc+0x26>
      return -1;
    80001e66:	557d                	li	a0,-1
    80001e68:	bfd9                	j	80001e3e <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e6a:	00f4863b          	addw	a2,s1,a5
    80001e6e:	1602                	slli	a2,a2,0x20
    80001e70:	9201                	srli	a2,a2,0x20
    80001e72:	1582                	slli	a1,a1,0x20
    80001e74:	9181                	srli	a1,a1,0x20
    80001e76:	6928                	ld	a0,80(a0)
    80001e78:	fffff097          	auipc	ra,0xfffff
    80001e7c:	5e8080e7          	jalr	1512(ra) # 80001460 <uvmdealloc>
    80001e80:	0005079b          	sext.w	a5,a0
    80001e84:	bf45                	j	80001e34 <growproc+0x26>

0000000080001e86 <fork>:
{
    80001e86:	7139                	addi	sp,sp,-64
    80001e88:	fc06                	sd	ra,56(sp)
    80001e8a:	f822                	sd	s0,48(sp)
    80001e8c:	f426                	sd	s1,40(sp)
    80001e8e:	e456                	sd	s5,8(sp)
    80001e90:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e92:	00000097          	auipc	ra,0x0
    80001e96:	bf4080e7          	jalr	-1036(ra) # 80001a86 <myproc>
    80001e9a:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0) // nuevo proceso
    80001e9c:	00000097          	auipc	ra,0x0
    80001ea0:	df6080e7          	jalr	-522(ra) # 80001c92 <allocproc>
    80001ea4:	12050463          	beqz	a0,80001fcc <fork+0x146>
    80001ea8:	ec4e                	sd	s3,24(sp)
    80001eaa:	89aa                	mv	s3,a0
  np->mask = p->mask; // copiar mascara de syscalls
    80001eac:	168aa783          	lw	a5,360(s5)
    80001eb0:	16f52423          	sw	a5,360(a0)
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001eb4:	048ab603          	ld	a2,72(s5)
    80001eb8:	692c                	ld	a1,80(a0)
    80001eba:	050ab503          	ld	a0,80(s5)
    80001ebe:	fffff097          	auipc	ra,0xfffff
    80001ec2:	74c080e7          	jalr	1868(ra) # 8000160a <uvmcopy>
    80001ec6:	04054863          	bltz	a0,80001f16 <fork+0x90>
    80001eca:	f04a                	sd	s2,32(sp)
    80001ecc:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001ece:	048ab783          	ld	a5,72(s5)
    80001ed2:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001ed6:	058ab683          	ld	a3,88(s5)
    80001eda:	87b6                	mv	a5,a3
    80001edc:	0589b703          	ld	a4,88(s3)
    80001ee0:	12068693          	addi	a3,a3,288
    80001ee4:	6388                	ld	a0,0(a5)
    80001ee6:	678c                	ld	a1,8(a5)
    80001ee8:	6b90                	ld	a2,16(a5)
    80001eea:	e308                	sd	a0,0(a4)
    80001eec:	e70c                	sd	a1,8(a4)
    80001eee:	eb10                	sd	a2,16(a4)
    80001ef0:	6f90                	ld	a2,24(a5)
    80001ef2:	ef10                	sd	a2,24(a4)
    80001ef4:	02078793          	addi	a5,a5,32 # 1020 <_entry-0x7fffefe0>
    80001ef8:	02070713          	addi	a4,a4,32
    80001efc:	fed794e3          	bne	a5,a3,80001ee4 <fork+0x5e>
  np->trapframe->a0 = 0;
    80001f00:	0589b783          	ld	a5,88(s3)
    80001f04:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001f08:	0d0a8493          	addi	s1,s5,208
    80001f0c:	0d098913          	addi	s2,s3,208
    80001f10:	150a8a13          	addi	s4,s5,336
    80001f14:	a015                	j	80001f38 <fork+0xb2>
    freeproc(np);
    80001f16:	854e                	mv	a0,s3
    80001f18:	00000097          	auipc	ra,0x0
    80001f1c:	d22080e7          	jalr	-734(ra) # 80001c3a <freeproc>
    release(&np->lock);
    80001f20:	854e                	mv	a0,s3
    80001f22:	fffff097          	auipc	ra,0xfffff
    80001f26:	de2080e7          	jalr	-542(ra) # 80000d04 <release>
    return -1;
    80001f2a:	54fd                	li	s1,-1
    80001f2c:	69e2                	ld	s3,24(sp)
    80001f2e:	a841                	j	80001fbe <fork+0x138>
  for(i = 0; i < NOFILE; i++)
    80001f30:	04a1                	addi	s1,s1,8
    80001f32:	0921                	addi	s2,s2,8
    80001f34:	01448b63          	beq	s1,s4,80001f4a <fork+0xc4>
    if(p->ofile[i])
    80001f38:	6088                	ld	a0,0(s1)
    80001f3a:	d97d                	beqz	a0,80001f30 <fork+0xaa>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f3c:	00003097          	auipc	ra,0x3
    80001f40:	bd6080e7          	jalr	-1066(ra) # 80004b12 <filedup>
    80001f44:	00a93023          	sd	a0,0(s2)
    80001f48:	b7e5                	j	80001f30 <fork+0xaa>
  np->cwd = idup(p->cwd);
    80001f4a:	150ab503          	ld	a0,336(s5)
    80001f4e:	00002097          	auipc	ra,0x2
    80001f52:	cfe080e7          	jalr	-770(ra) # 80003c4c <idup>
    80001f56:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f5a:	4641                	li	a2,16
    80001f5c:	158a8593          	addi	a1,s5,344
    80001f60:	15898513          	addi	a0,s3,344
    80001f64:	fffff097          	auipc	ra,0xfffff
    80001f68:	f40080e7          	jalr	-192(ra) # 80000ea4 <safestrcpy>
  pid = np->pid;
    80001f6c:	0309a483          	lw	s1,48(s3)
  release(&np->lock);
    80001f70:	854e                	mv	a0,s3
    80001f72:	fffff097          	auipc	ra,0xfffff
    80001f76:	d92080e7          	jalr	-622(ra) # 80000d04 <release>
  acquire(&wait_lock);
    80001f7a:	00012517          	auipc	a0,0x12
    80001f7e:	33e50513          	addi	a0,a0,830 # 800142b8 <wait_lock>
    80001f82:	fffff097          	auipc	ra,0xfffff
    80001f86:	cd2080e7          	jalr	-814(ra) # 80000c54 <acquire>
  np->parent = p; // asignar padre
    80001f8a:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001f8e:	00012517          	auipc	a0,0x12
    80001f92:	32a50513          	addi	a0,a0,810 # 800142b8 <wait_lock>
    80001f96:	fffff097          	auipc	ra,0xfffff
    80001f9a:	d6e080e7          	jalr	-658(ra) # 80000d04 <release>
  acquire(&np->lock);
    80001f9e:	854e                	mv	a0,s3
    80001fa0:	fffff097          	auipc	ra,0xfffff
    80001fa4:	cb4080e7          	jalr	-844(ra) # 80000c54 <acquire>
  np->state = RUNNABLE; // listo para ejecutar
    80001fa8:	478d                	li	a5,3
    80001faa:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001fae:	854e                	mv	a0,s3
    80001fb0:	fffff097          	auipc	ra,0xfffff
    80001fb4:	d54080e7          	jalr	-684(ra) # 80000d04 <release>
  return pid;
    80001fb8:	7902                	ld	s2,32(sp)
    80001fba:	69e2                	ld	s3,24(sp)
    80001fbc:	6a42                	ld	s4,16(sp)
}
    80001fbe:	8526                	mv	a0,s1
    80001fc0:	70e2                	ld	ra,56(sp)
    80001fc2:	7442                	ld	s0,48(sp)
    80001fc4:	74a2                	ld	s1,40(sp)
    80001fc6:	6aa2                	ld	s5,8(sp)
    80001fc8:	6121                	addi	sp,sp,64
    80001fca:	8082                	ret
    return -1;
    80001fcc:	54fd                	li	s1,-1
    80001fce:	bfc5                	j	80001fbe <fork+0x138>

0000000080001fd0 <max>:
int max(int a, int b){
    80001fd0:	1141                	addi	sp,sp,-16
    80001fd2:	e406                	sd	ra,8(sp)
    80001fd4:	e022                	sd	s0,0(sp)
    80001fd6:	0800                	addi	s0,sp,16
  if(a > b) return a;
    80001fd8:	87aa                	mv	a5,a0
    80001fda:	00b55363          	bge	a0,a1,80001fe0 <max+0x10>
    80001fde:	87ae                	mv	a5,a1
}
    80001fe0:	0007851b          	sext.w	a0,a5
    80001fe4:	60a2                	ld	ra,8(sp)
    80001fe6:	6402                	ld	s0,0(sp)
    80001fe8:	0141                	addi	sp,sp,16
    80001fea:	8082                	ret

0000000080001fec <min>:
int min(int a, int b){
    80001fec:	1141                	addi	sp,sp,-16
    80001fee:	e406                	sd	ra,8(sp)
    80001ff0:	e022                	sd	s0,0(sp)
    80001ff2:	0800                	addi	s0,sp,16
  if(a < b) return a;
    80001ff4:	87aa                	mv	a5,a0
    80001ff6:	00a5d363          	bge	a1,a0,80001ffc <min+0x10>
    80001ffa:	87ae                	mv	a5,a1
}
    80001ffc:	0007851b          	sext.w	a0,a5
    80002000:	60a2                	ld	ra,8(sp)
    80002002:	6402                	ld	s0,0(sp)
    80002004:	0141                	addi	sp,sp,16
    80002006:	8082                	ret

0000000080002008 <scheduler>:
{
    80002008:	7119                	addi	sp,sp,-128
    8000200a:	fc86                	sd	ra,120(sp)
    8000200c:	f8a2                	sd	s0,112(sp)
    8000200e:	f4a6                	sd	s1,104(sp)
    80002010:	f0ca                	sd	s2,96(sp)
    80002012:	ecce                	sd	s3,88(sp)
    80002014:	e8d2                	sd	s4,80(sp)
    80002016:	e4d6                	sd	s5,72(sp)
    80002018:	e0da                	sd	s6,64(sp)
    8000201a:	fc5e                	sd	s7,56(sp)
    8000201c:	f862                	sd	s8,48(sp)
    8000201e:	f466                	sd	s9,40(sp)
    80002020:	f06a                	sd	s10,32(sp)
    80002022:	ec6e                	sd	s11,24(sp)
    80002024:	0100                	addi	s0,sp,128
    80002026:	8792                	mv	a5,tp
  int id = r_tp(); // tp contiene el hartid
    80002028:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000202a:	00779693          	slli	a3,a5,0x7
    8000202e:	00012717          	auipc	a4,0x12
    80002032:	27270713          	addi	a4,a4,626 # 800142a0 <pid_lock>
    80002036:	9736                	add	a4,a4,a3
    80002038:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &high_priority_proc->context);
    8000203c:	00012717          	auipc	a4,0x12
    80002040:	29c70713          	addi	a4,a4,668 # 800142d8 <cpus+0x8>
    80002044:	9736                	add	a4,a4,a3
    80002046:	f8e43423          	sd	a4,-120(s0)
        nice = 5;
    8000204a:	4c15                	li	s8,5
  if(a < b) return a;
    8000204c:	06400c93          	li	s9,100
    for(p = proc; p < &proc[NPROC]; p++) {
    80002050:	0001ab97          	auipc	s7,0x1a
    80002054:	880b8b93          	addi	s7,s7,-1920 # 8001b8d0 <tickslock>
      c->proc = high_priority_proc;
    80002058:	00012d97          	auipc	s11,0x12
    8000205c:	248d8d93          	addi	s11,s11,584 # 800142a0 <pid_lock>
    80002060:	9db6                	add	s11,s11,a3
    80002062:	a8ed                	j	8000215c <scheduler+0x154>
  if(a > b) return a;
    80002064:	4901                	li	s2,0
    80002066:	a849                	j	800020f8 <scheduler+0xf0>
            dp_check && p->n_runs < high_priority_proc->n_runs;
    80002068:	1a84b683          	ld	a3,424(s1)
    8000206c:	1a89b703          	ld	a4,424(s3)
    80002070:	00e6b633          	sltu	a2,a3,a4
            high_priority_proc->n_runs == p->n_runs &&
    80002074:	4781                	li	a5,0
            dp_check &&
    80002076:	02e68163          	beq	a3,a4,80002098 <scheduler+0x90>
           check_1 ||
    8000207a:	8fd1                	or	a5,a5,a2
    8000207c:	c78d                	beqz	a5,800020a6 <scheduler+0x9e>
            release(&high_priority_proc->lock);
    8000207e:	854e                	mv	a0,s3
    80002080:	fffff097          	auipc	ra,0xfffff
    80002084:	c84080e7          	jalr	-892(ra) # 80000d04 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002088:	1c848793          	addi	a5,s1,456
    8000208c:	09778663          	beq	a5,s7,80002118 <scheduler+0x110>
    80002090:	8a4a                	mv	s4,s2
    80002092:	89a6                	mv	s3,s1
    80002094:	84be                	mv	s1,a5
    80002096:	a00d                	j	800020b8 <scheduler+0xb0>
            high_priority_proc->n_runs == p->n_runs &&
    80002098:	1704b783          	ld	a5,368(s1)
    8000209c:	1709b703          	ld	a4,368(s3)
    800020a0:	00e7b7b3          	sltu	a5,a5,a4
    800020a4:	bfd9                	j	8000207a <scheduler+0x72>
      release(&p->lock);
    800020a6:	8526                	mv	a0,s1
    800020a8:	fffff097          	auipc	ra,0xfffff
    800020ac:	c5c080e7          	jalr	-932(ra) # 80000d04 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800020b0:	1c848493          	addi	s1,s1,456
    800020b4:	05748f63          	beq	s1,s7,80002112 <scheduler+0x10a>
      acquire(&p->lock);
    800020b8:	8526                	mv	a0,s1
    800020ba:	fffff097          	auipc	ra,0xfffff
    800020be:	b9a080e7          	jalr	-1126(ra) # 80000c54 <acquire>
      if(p->run_time + p->sleep_time > 0){
    800020c2:	1984b683          	ld	a3,408(s1)
    800020c6:	1784b783          	ld	a5,376(s1)
    800020ca:	97b6                	add	a5,a5,a3
        nice = 5;
    800020cc:	8762                	mv	a4,s8
      if(p->run_time + p->sleep_time > 0){
    800020ce:	cb89                	beqz	a5,800020e0 <scheduler+0xd8>
        nice = p->sleep_time * 10;
    800020d0:	0026971b          	slliw	a4,a3,0x2
    800020d4:	9f35                	addw	a4,a4,a3
    800020d6:	0017171b          	slliw	a4,a4,0x1
        nice = nice / (p->sleep_time + p->run_time);
    800020da:	02f75733          	divu	a4,a4,a5
    800020de:	2701                	sext.w	a4,a4
          max(0, min(p->priority - nice + 5, 100));
    800020e0:	1b04b783          	ld	a5,432(s1)
    800020e4:	2795                	addiw	a5,a5,5
    800020e6:	9f99                	subw	a5,a5,a4
    800020e8:	893e                	mv	s2,a5
  if(a < b) return a;
    800020ea:	00fb5363          	bge	s6,a5,800020f0 <scheduler+0xe8>
    800020ee:	8966                	mv	s2,s9
  if(a > b) return a;
    800020f0:	02091793          	slli	a5,s2,0x20
    800020f4:	f607c8e3          	bltz	a5,80002064 <scheduler+0x5c>
    800020f8:	2901                	sext.w	s2,s2
      if(p->state == RUNNABLE){
    800020fa:	4c9c                	lw	a5,24(s1)
    800020fc:	fb5795e3          	bne	a5,s5,800020a6 <scheduler+0x9e>
            dp_check && p->n_runs < high_priority_proc->n_runs;
    80002100:	f74904e3          	beq	s2,s4,80002068 <scheduler+0x60>
        if(high_priority_proc == 0 ||
    80002104:	00098463          	beqz	s3,8000210c <scheduler+0x104>
    80002108:	f92a5fe3          	bge	s4,s2,800020a6 <scheduler+0x9e>
          if(high_priority_proc != 0)
    8000210c:	f6098ee3          	beqz	s3,80002088 <scheduler+0x80>
    80002110:	b7bd                	j	8000207e <scheduler+0x76>
    if(high_priority_proc != 0){
    80002112:	04098a63          	beqz	s3,80002166 <scheduler+0x15e>
    80002116:	84ce                	mv	s1,s3
      high_priority_proc->state = RUNNING;
    80002118:	4791                	li	a5,4
    8000211a:	cc9c                	sw	a5,24(s1)
      high_priority_proc->start_time = ticks;
    8000211c:	0000a797          	auipc	a5,0xa
    80002120:	f147e783          	lwu	a5,-236(a5) # 8000c030 <ticks>
    80002124:	18f4b823          	sd	a5,400(s1)
      high_priority_proc->run_time = 0;
    80002128:	1604bc23          	sd	zero,376(s1)
      high_priority_proc->sleep_time = 0;
    8000212c:	1804bc23          	sd	zero,408(s1)
      high_priority_proc->n_runs += 1;
    80002130:	1a84b783          	ld	a5,424(s1)
    80002134:	0785                	addi	a5,a5,1
    80002136:	1af4b423          	sd	a5,424(s1)
      c->proc = high_priority_proc;
    8000213a:	029db823          	sd	s1,48(s11)
      swtch(&c->context, &high_priority_proc->context);
    8000213e:	06048593          	addi	a1,s1,96
    80002142:	f8843503          	ld	a0,-120(s0)
    80002146:	00001097          	auipc	ra,0x1
    8000214a:	8d2080e7          	jalr	-1838(ra) # 80002a18 <swtch>
      c->proc = 0;
    8000214e:	020db823          	sd	zero,48(s11)
      release(&high_priority_proc->lock);
    80002152:	8526                	mv	a0,s1
    80002154:	fffff097          	auipc	ra,0xfffff
    80002158:	bb0080e7          	jalr	-1104(ra) # 80000d04 <release>
    int dynamic_priority = 101;
    8000215c:	06500d13          	li	s10,101
  if(a < b) return a;
    80002160:	06400b13          	li	s6,100
      if(p->state == RUNNABLE){
    80002164:	4a8d                	li	s5,3
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002166:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000216a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000216e:	10079073          	csrw	sstatus,a5
    int dynamic_priority = 101;
    80002172:	8a6a                	mv	s4,s10
    struct proc* high_priority_proc = 0;
    80002174:	4981                	li	s3,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002176:	00012497          	auipc	s1,0x12
    8000217a:	55a48493          	addi	s1,s1,1370 # 800146d0 <proc>
    8000217e:	bf2d                	j	800020b8 <scheduler+0xb0>

0000000080002180 <sched>:
{
    80002180:	7179                	addi	sp,sp,-48
    80002182:	f406                	sd	ra,40(sp)
    80002184:	f022                	sd	s0,32(sp)
    80002186:	ec26                	sd	s1,24(sp)
    80002188:	e84a                	sd	s2,16(sp)
    8000218a:	e44e                	sd	s3,8(sp)
    8000218c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000218e:	00000097          	auipc	ra,0x0
    80002192:	8f8080e7          	jalr	-1800(ra) # 80001a86 <myproc>
    80002196:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002198:	fffff097          	auipc	ra,0xfffff
    8000219c:	a3c080e7          	jalr	-1476(ra) # 80000bd4 <holding>
    800021a0:	cd25                	beqz	a0,80002218 <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    800021a2:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800021a4:	2781                	sext.w	a5,a5
    800021a6:	079e                	slli	a5,a5,0x7
    800021a8:	00012717          	auipc	a4,0x12
    800021ac:	0f870713          	addi	a4,a4,248 # 800142a0 <pid_lock>
    800021b0:	97ba                	add	a5,a5,a4
    800021b2:	0a87a703          	lw	a4,168(a5)
    800021b6:	4785                	li	a5,1
    800021b8:	06f71863          	bne	a4,a5,80002228 <sched+0xa8>
  if(p->state == RUNNING)
    800021bc:	4c98                	lw	a4,24(s1)
    800021be:	4791                	li	a5,4
    800021c0:	06f70c63          	beq	a4,a5,80002238 <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800021c4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800021c8:	8b89                	andi	a5,a5,2
  if(intr_get())
    800021ca:	efbd                	bnez	a5,80002248 <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    800021cc:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800021ce:	00012917          	auipc	s2,0x12
    800021d2:	0d290913          	addi	s2,s2,210 # 800142a0 <pid_lock>
    800021d6:	2781                	sext.w	a5,a5
    800021d8:	079e                	slli	a5,a5,0x7
    800021da:	97ca                	add	a5,a5,s2
    800021dc:	0ac7a983          	lw	s3,172(a5)
    800021e0:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800021e2:	2781                	sext.w	a5,a5
    800021e4:	079e                	slli	a5,a5,0x7
    800021e6:	07a1                	addi	a5,a5,8
    800021e8:	00012597          	auipc	a1,0x12
    800021ec:	0e858593          	addi	a1,a1,232 # 800142d0 <cpus>
    800021f0:	95be                	add	a1,a1,a5
    800021f2:	06048513          	addi	a0,s1,96
    800021f6:	00001097          	auipc	ra,0x1
    800021fa:	822080e7          	jalr	-2014(ra) # 80002a18 <swtch>
    800021fe:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002200:	2781                	sext.w	a5,a5
    80002202:	079e                	slli	a5,a5,0x7
    80002204:	993e                	add	s2,s2,a5
    80002206:	0b392623          	sw	s3,172(s2)
}
    8000220a:	70a2                	ld	ra,40(sp)
    8000220c:	7402                	ld	s0,32(sp)
    8000220e:	64e2                	ld	s1,24(sp)
    80002210:	6942                	ld	s2,16(sp)
    80002212:	69a2                	ld	s3,8(sp)
    80002214:	6145                	addi	sp,sp,48
    80002216:	8082                	ret
    panic("sched p->lock");
    80002218:	00006517          	auipc	a0,0x6
    8000221c:	fe050513          	addi	a0,a0,-32 # 800081f8 <etext+0x1f8>
    80002220:	ffffe097          	auipc	ra,0xffffe
    80002224:	336080e7          	jalr	822(ra) # 80000556 <panic>
    panic("sched locks");
    80002228:	00006517          	auipc	a0,0x6
    8000222c:	fe050513          	addi	a0,a0,-32 # 80008208 <etext+0x208>
    80002230:	ffffe097          	auipc	ra,0xffffe
    80002234:	326080e7          	jalr	806(ra) # 80000556 <panic>
    panic("sched running");
    80002238:	00006517          	auipc	a0,0x6
    8000223c:	fe050513          	addi	a0,a0,-32 # 80008218 <etext+0x218>
    80002240:	ffffe097          	auipc	ra,0xffffe
    80002244:	316080e7          	jalr	790(ra) # 80000556 <panic>
    panic("sched interruptible");
    80002248:	00006517          	auipc	a0,0x6
    8000224c:	fe050513          	addi	a0,a0,-32 # 80008228 <etext+0x228>
    80002250:	ffffe097          	auipc	ra,0xffffe
    80002254:	306080e7          	jalr	774(ra) # 80000556 <panic>

0000000080002258 <yield>:
{
    80002258:	1101                	addi	sp,sp,-32
    8000225a:	ec06                	sd	ra,24(sp)
    8000225c:	e822                	sd	s0,16(sp)
    8000225e:	e426                	sd	s1,8(sp)
    80002260:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002262:	00000097          	auipc	ra,0x0
    80002266:	824080e7          	jalr	-2012(ra) # 80001a86 <myproc>
    8000226a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000226c:	fffff097          	auipc	ra,0xfffff
    80002270:	9e8080e7          	jalr	-1560(ra) # 80000c54 <acquire>
  p->state = RUNNABLE;
    80002274:	478d                	li	a5,3
    80002276:	cc9c                	sw	a5,24(s1)
  sched();
    80002278:	00000097          	auipc	ra,0x0
    8000227c:	f08080e7          	jalr	-248(ra) # 80002180 <sched>
  release(&p->lock);
    80002280:	8526                	mv	a0,s1
    80002282:	fffff097          	auipc	ra,0xfffff
    80002286:	a82080e7          	jalr	-1406(ra) # 80000d04 <release>
}
    8000228a:	60e2                	ld	ra,24(sp)
    8000228c:	6442                	ld	s0,16(sp)
    8000228e:	64a2                	ld	s1,8(sp)
    80002290:	6105                	addi	sp,sp,32
    80002292:	8082                	ret

0000000080002294 <sleep>:

// Pone un proceso a dormir
void
sleep(void *chan, struct spinlock *lk)
{
    80002294:	7179                	addi	sp,sp,-48
    80002296:	f406                	sd	ra,40(sp)
    80002298:	f022                	sd	s0,32(sp)
    8000229a:	ec26                	sd	s1,24(sp)
    8000229c:	e84a                	sd	s2,16(sp)
    8000229e:	e44e                	sd	s3,8(sp)
    800022a0:	1800                	addi	s0,sp,48
    800022a2:	89aa                	mv	s3,a0
    800022a4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800022a6:	fffff097          	auipc	ra,0xfffff
    800022aa:	7e0080e7          	jalr	2016(ra) # 80001a86 <myproc>
    800022ae:	84aa                	mv	s1,a0
  
  acquire(&p->lock);
    800022b0:	fffff097          	auipc	ra,0xfffff
    800022b4:	9a4080e7          	jalr	-1628(ra) # 80000c54 <acquire>
  release(lk);
    800022b8:	854a                	mv	a0,s2
    800022ba:	fffff097          	auipc	ra,0xfffff
    800022be:	a4a080e7          	jalr	-1462(ra) # 80000d04 <release>

  p->chan = chan;
    800022c2:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800022c6:	4789                	li	a5,2
    800022c8:	cc9c                	sw	a5,24(s1)

  sched();
    800022ca:	00000097          	auipc	ra,0x0
    800022ce:	eb6080e7          	jalr	-330(ra) # 80002180 <sched>

  p->chan = 0;
    800022d2:	0204b023          	sd	zero,32(s1)

  release(&p->lock);
    800022d6:	8526                	mv	a0,s1
    800022d8:	fffff097          	auipc	ra,0xfffff
    800022dc:	a2c080e7          	jalr	-1492(ra) # 80000d04 <release>
  acquire(lk);
    800022e0:	854a                	mv	a0,s2
    800022e2:	fffff097          	auipc	ra,0xfffff
    800022e6:	972080e7          	jalr	-1678(ra) # 80000c54 <acquire>
}
    800022ea:	70a2                	ld	ra,40(sp)
    800022ec:	7402                	ld	s0,32(sp)
    800022ee:	64e2                	ld	s1,24(sp)
    800022f0:	6942                	ld	s2,16(sp)
    800022f2:	69a2                	ld	s3,8(sp)
    800022f4:	6145                	addi	sp,sp,48
    800022f6:	8082                	ret

00000000800022f8 <wait>:
{
    800022f8:	715d                	addi	sp,sp,-80
    800022fa:	e486                	sd	ra,72(sp)
    800022fc:	e0a2                	sd	s0,64(sp)
    800022fe:	fc26                	sd	s1,56(sp)
    80002300:	f84a                	sd	s2,48(sp)
    80002302:	f44e                	sd	s3,40(sp)
    80002304:	f052                	sd	s4,32(sp)
    80002306:	ec56                	sd	s5,24(sp)
    80002308:	e85a                	sd	s6,16(sp)
    8000230a:	e45e                	sd	s7,8(sp)
    8000230c:	0880                	addi	s0,sp,80
    8000230e:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002310:	fffff097          	auipc	ra,0xfffff
    80002314:	776080e7          	jalr	1910(ra) # 80001a86 <myproc>
    80002318:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000231a:	00012517          	auipc	a0,0x12
    8000231e:	f9e50513          	addi	a0,a0,-98 # 800142b8 <wait_lock>
    80002322:	fffff097          	auipc	ra,0xfffff
    80002326:	932080e7          	jalr	-1742(ra) # 80000c54 <acquire>
        if(np->state == ZOMBIE){
    8000232a:	4a15                	li	s4,5
        havekids = 1;
    8000232c:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    8000232e:	00019997          	auipc	s3,0x19
    80002332:	5a298993          	addi	s3,s3,1442 # 8001b8d0 <tickslock>
    sleep(p, &wait_lock);
    80002336:	00012b17          	auipc	s6,0x12
    8000233a:	f82b0b13          	addi	s6,s6,-126 # 800142b8 <wait_lock>
    8000233e:	a875                	j	800023fa <wait+0x102>
          pid = np->pid;
    80002340:	0304a983          	lw	s3,48(s1)
          if(addr != 0 &&
    80002344:	000b8e63          	beqz	s7,80002360 <wait+0x68>
             copyout(p->pagetable, addr,
    80002348:	4691                	li	a3,4
    8000234a:	02c48613          	addi	a2,s1,44
    8000234e:	85de                	mv	a1,s7
    80002350:	05093503          	ld	a0,80(s2)
    80002354:	fffff097          	auipc	ra,0xfffff
    80002358:	3b6080e7          	jalr	950(ra) # 8000170a <copyout>
          if(addr != 0 &&
    8000235c:	04054063          	bltz	a0,8000239c <wait+0xa4>
          freeproc(np); // liberar proceso
    80002360:	8526                	mv	a0,s1
    80002362:	00000097          	auipc	ra,0x0
    80002366:	8d8080e7          	jalr	-1832(ra) # 80001c3a <freeproc>
          release(&np->lock);
    8000236a:	8526                	mv	a0,s1
    8000236c:	fffff097          	auipc	ra,0xfffff
    80002370:	998080e7          	jalr	-1640(ra) # 80000d04 <release>
          release(&wait_lock);
    80002374:	00012517          	auipc	a0,0x12
    80002378:	f4450513          	addi	a0,a0,-188 # 800142b8 <wait_lock>
    8000237c:	fffff097          	auipc	ra,0xfffff
    80002380:	988080e7          	jalr	-1656(ra) # 80000d04 <release>
}
    80002384:	854e                	mv	a0,s3
    80002386:	60a6                	ld	ra,72(sp)
    80002388:	6406                	ld	s0,64(sp)
    8000238a:	74e2                	ld	s1,56(sp)
    8000238c:	7942                	ld	s2,48(sp)
    8000238e:	79a2                	ld	s3,40(sp)
    80002390:	7a02                	ld	s4,32(sp)
    80002392:	6ae2                	ld	s5,24(sp)
    80002394:	6b42                	ld	s6,16(sp)
    80002396:	6ba2                	ld	s7,8(sp)
    80002398:	6161                	addi	sp,sp,80
    8000239a:	8082                	ret
            release(&np->lock);
    8000239c:	8526                	mv	a0,s1
    8000239e:	fffff097          	auipc	ra,0xfffff
    800023a2:	966080e7          	jalr	-1690(ra) # 80000d04 <release>
            release(&wait_lock);
    800023a6:	00012517          	auipc	a0,0x12
    800023aa:	f1250513          	addi	a0,a0,-238 # 800142b8 <wait_lock>
    800023ae:	fffff097          	auipc	ra,0xfffff
    800023b2:	956080e7          	jalr	-1706(ra) # 80000d04 <release>
            return -1;
    800023b6:	59fd                	li	s3,-1
    800023b8:	b7f1                	j	80002384 <wait+0x8c>
    for(np = proc; np < &proc[NPROC]; np++){
    800023ba:	1c848493          	addi	s1,s1,456
    800023be:	03348463          	beq	s1,s3,800023e6 <wait+0xee>
      if(np->parent == p){
    800023c2:	7c9c                	ld	a5,56(s1)
    800023c4:	ff279be3          	bne	a5,s2,800023ba <wait+0xc2>
        acquire(&np->lock);
    800023c8:	8526                	mv	a0,s1
    800023ca:	fffff097          	auipc	ra,0xfffff
    800023ce:	88a080e7          	jalr	-1910(ra) # 80000c54 <acquire>
        if(np->state == ZOMBIE){
    800023d2:	4c9c                	lw	a5,24(s1)
    800023d4:	f74786e3          	beq	a5,s4,80002340 <wait+0x48>
        release(&np->lock);
    800023d8:	8526                	mv	a0,s1
    800023da:	fffff097          	auipc	ra,0xfffff
    800023de:	92a080e7          	jalr	-1750(ra) # 80000d04 <release>
        havekids = 1;
    800023e2:	8756                	mv	a4,s5
    800023e4:	bfd9                	j	800023ba <wait+0xc2>
    if(!havekids || p->killed){
    800023e6:	c305                	beqz	a4,80002406 <wait+0x10e>
    800023e8:	02892783          	lw	a5,40(s2)
    800023ec:	ef89                	bnez	a5,80002406 <wait+0x10e>
    sleep(p, &wait_lock);
    800023ee:	85da                	mv	a1,s6
    800023f0:	854a                	mv	a0,s2
    800023f2:	00000097          	auipc	ra,0x0
    800023f6:	ea2080e7          	jalr	-350(ra) # 80002294 <sleep>
    havekids = 0;
    800023fa:	4701                	li	a4,0
    for(np = proc; np < &proc[NPROC]; np++){
    800023fc:	00012497          	auipc	s1,0x12
    80002400:	2d448493          	addi	s1,s1,724 # 800146d0 <proc>
    80002404:	bf7d                	j	800023c2 <wait+0xca>
      release(&wait_lock);
    80002406:	00012517          	auipc	a0,0x12
    8000240a:	eb250513          	addi	a0,a0,-334 # 800142b8 <wait_lock>
    8000240e:	fffff097          	auipc	ra,0xfffff
    80002412:	8f6080e7          	jalr	-1802(ra) # 80000d04 <release>
      return -1;
    80002416:	59fd                	li	s3,-1
    80002418:	b7b5                	j	80002384 <wait+0x8c>

000000008000241a <wakeup>:

// Despertar procesos dormidos
void
wakeup(void *chan)
{
    8000241a:	7139                	addi	sp,sp,-64
    8000241c:	fc06                	sd	ra,56(sp)
    8000241e:	f822                	sd	s0,48(sp)
    80002420:	f426                	sd	s1,40(sp)
    80002422:	f04a                	sd	s2,32(sp)
    80002424:	ec4e                	sd	s3,24(sp)
    80002426:	e852                	sd	s4,16(sp)
    80002428:	e456                	sd	s5,8(sp)
    8000242a:	0080                	addi	s0,sp,64
    8000242c:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000242e:	00012497          	auipc	s1,0x12
    80002432:	2a248493          	addi	s1,s1,674 # 800146d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);

      if(p->state == SLEEPING && p->chan == chan)
    80002436:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002438:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000243a:	00019917          	auipc	s2,0x19
    8000243e:	49690913          	addi	s2,s2,1174 # 8001b8d0 <tickslock>
    80002442:	a811                	j	80002456 <wakeup+0x3c>

      release(&p->lock);
    80002444:	8526                	mv	a0,s1
    80002446:	fffff097          	auipc	ra,0xfffff
    8000244a:	8be080e7          	jalr	-1858(ra) # 80000d04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000244e:	1c848493          	addi	s1,s1,456
    80002452:	03248663          	beq	s1,s2,8000247e <wakeup+0x64>
    if(p != myproc()){
    80002456:	fffff097          	auipc	ra,0xfffff
    8000245a:	630080e7          	jalr	1584(ra) # 80001a86 <myproc>
    8000245e:	fe9508e3          	beq	a0,s1,8000244e <wakeup+0x34>
      acquire(&p->lock);
    80002462:	8526                	mv	a0,s1
    80002464:	ffffe097          	auipc	ra,0xffffe
    80002468:	7f0080e7          	jalr	2032(ra) # 80000c54 <acquire>
      if(p->state == SLEEPING && p->chan == chan)
    8000246c:	4c9c                	lw	a5,24(s1)
    8000246e:	fd379be3          	bne	a5,s3,80002444 <wakeup+0x2a>
    80002472:	709c                	ld	a5,32(s1)
    80002474:	fd4798e3          	bne	a5,s4,80002444 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002478:	0154ac23          	sw	s5,24(s1)
    8000247c:	b7e1                	j	80002444 <wakeup+0x2a>
    }
  }
}
    8000247e:	70e2                	ld	ra,56(sp)
    80002480:	7442                	ld	s0,48(sp)
    80002482:	74a2                	ld	s1,40(sp)
    80002484:	7902                	ld	s2,32(sp)
    80002486:	69e2                	ld	s3,24(sp)
    80002488:	6a42                	ld	s4,16(sp)
    8000248a:	6aa2                	ld	s5,8(sp)
    8000248c:	6121                	addi	sp,sp,64
    8000248e:	8082                	ret

0000000080002490 <reparent>:
{
    80002490:	7179                	addi	sp,sp,-48
    80002492:	f406                	sd	ra,40(sp)
    80002494:	f022                	sd	s0,32(sp)
    80002496:	ec26                	sd	s1,24(sp)
    80002498:	e84a                	sd	s2,16(sp)
    8000249a:	e44e                	sd	s3,8(sp)
    8000249c:	e052                	sd	s4,0(sp)
    8000249e:	1800                	addi	s0,sp,48
    800024a0:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800024a2:	00012497          	auipc	s1,0x12
    800024a6:	22e48493          	addi	s1,s1,558 # 800146d0 <proc>
      pp->parent = initproc;
    800024aa:	0000aa17          	auipc	s4,0xa
    800024ae:	b7ea0a13          	addi	s4,s4,-1154 # 8000c028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800024b2:	00019997          	auipc	s3,0x19
    800024b6:	41e98993          	addi	s3,s3,1054 # 8001b8d0 <tickslock>
    800024ba:	a029                	j	800024c4 <reparent+0x34>
    800024bc:	1c848493          	addi	s1,s1,456
    800024c0:	01348d63          	beq	s1,s3,800024da <reparent+0x4a>
    if(pp->parent == p){
    800024c4:	7c9c                	ld	a5,56(s1)
    800024c6:	ff279be3          	bne	a5,s2,800024bc <reparent+0x2c>
      pp->parent = initproc;
    800024ca:	000a3503          	ld	a0,0(s4)
    800024ce:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800024d0:	00000097          	auipc	ra,0x0
    800024d4:	f4a080e7          	jalr	-182(ra) # 8000241a <wakeup>
    800024d8:	b7d5                	j	800024bc <reparent+0x2c>
}
    800024da:	70a2                	ld	ra,40(sp)
    800024dc:	7402                	ld	s0,32(sp)
    800024de:	64e2                	ld	s1,24(sp)
    800024e0:	6942                	ld	s2,16(sp)
    800024e2:	69a2                	ld	s3,8(sp)
    800024e4:	6a02                	ld	s4,0(sp)
    800024e6:	6145                	addi	sp,sp,48
    800024e8:	8082                	ret

00000000800024ea <exit>:
{
    800024ea:	7179                	addi	sp,sp,-48
    800024ec:	f406                	sd	ra,40(sp)
    800024ee:	f022                	sd	s0,32(sp)
    800024f0:	ec26                	sd	s1,24(sp)
    800024f2:	e84a                	sd	s2,16(sp)
    800024f4:	e44e                	sd	s3,8(sp)
    800024f6:	e052                	sd	s4,0(sp)
    800024f8:	1800                	addi	s0,sp,48
    800024fa:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800024fc:	fffff097          	auipc	ra,0xfffff
    80002500:	58a080e7          	jalr	1418(ra) # 80001a86 <myproc>
    80002504:	89aa                	mv	s3,a0
  if(p == initproc)
    80002506:	0000a797          	auipc	a5,0xa
    8000250a:	b227b783          	ld	a5,-1246(a5) # 8000c028 <initproc>
    8000250e:	0d050493          	addi	s1,a0,208
    80002512:	15050913          	addi	s2,a0,336
    80002516:	00a79d63          	bne	a5,a0,80002530 <exit+0x46>
    panic("init exiting");
    8000251a:	00006517          	auipc	a0,0x6
    8000251e:	d2650513          	addi	a0,a0,-730 # 80008240 <etext+0x240>
    80002522:	ffffe097          	auipc	ra,0xffffe
    80002526:	034080e7          	jalr	52(ra) # 80000556 <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    8000252a:	04a1                	addi	s1,s1,8
    8000252c:	01248b63          	beq	s1,s2,80002542 <exit+0x58>
    if(p->ofile[fd]){
    80002530:	6088                	ld	a0,0(s1)
    80002532:	dd65                	beqz	a0,8000252a <exit+0x40>
      fileclose(f);
    80002534:	00002097          	auipc	ra,0x2
    80002538:	630080e7          	jalr	1584(ra) # 80004b64 <fileclose>
      p->ofile[fd] = 0;
    8000253c:	0004b023          	sd	zero,0(s1)
    80002540:	b7ed                	j	8000252a <exit+0x40>
  begin_op();
    80002542:	00002097          	auipc	ra,0x2
    80002546:	140080e7          	jalr	320(ra) # 80004682 <begin_op>
  iput(p->cwd);
    8000254a:	1509b503          	ld	a0,336(s3)
    8000254e:	00002097          	auipc	ra,0x2
    80002552:	8fa080e7          	jalr	-1798(ra) # 80003e48 <iput>
  end_op();
    80002556:	00002097          	auipc	ra,0x2
    8000255a:	1ac080e7          	jalr	428(ra) # 80004702 <end_op>
  p->cwd = 0;
    8000255e:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002562:	00012517          	auipc	a0,0x12
    80002566:	d5650513          	addi	a0,a0,-682 # 800142b8 <wait_lock>
    8000256a:	ffffe097          	auipc	ra,0xffffe
    8000256e:	6ea080e7          	jalr	1770(ra) # 80000c54 <acquire>
  reparent(p);
    80002572:	854e                	mv	a0,s3
    80002574:	00000097          	auipc	ra,0x0
    80002578:	f1c080e7          	jalr	-228(ra) # 80002490 <reparent>
  wakeup(p->parent);
    8000257c:	0389b503          	ld	a0,56(s3)
    80002580:	00000097          	auipc	ra,0x0
    80002584:	e9a080e7          	jalr	-358(ra) # 8000241a <wakeup>
  acquire(&p->lock);
    80002588:	854e                	mv	a0,s3
    8000258a:	ffffe097          	auipc	ra,0xffffe
    8000258e:	6ca080e7          	jalr	1738(ra) # 80000c54 <acquire>
  p->xstate = status;  // codigo de salida
    80002592:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;   // proceso muerto
    80002596:	4795                	li	a5,5
    80002598:	00f9ac23          	sw	a5,24(s3)
  p->exit_time = ticks;// registrar tiempo de salida
    8000259c:	0000a797          	auipc	a5,0xa
    800025a0:	a947e783          	lwu	a5,-1388(a5) # 8000c030 <ticks>
    800025a4:	1af9b023          	sd	a5,416(s3)
  release(&wait_lock);
    800025a8:	00012517          	auipc	a0,0x12
    800025ac:	d1050513          	addi	a0,a0,-752 # 800142b8 <wait_lock>
    800025b0:	ffffe097          	auipc	ra,0xffffe
    800025b4:	754080e7          	jalr	1876(ra) # 80000d04 <release>
  sched(); // ceder CPU
    800025b8:	00000097          	auipc	ra,0x0
    800025bc:	bc8080e7          	jalr	-1080(ra) # 80002180 <sched>
  panic("zombie exit");
    800025c0:	00006517          	auipc	a0,0x6
    800025c4:	c9050513          	addi	a0,a0,-880 # 80008250 <etext+0x250>
    800025c8:	ffffe097          	auipc	ra,0xffffe
    800025cc:	f8e080e7          	jalr	-114(ra) # 80000556 <panic>

00000000800025d0 <kill>:

// Mata un proceso por pid
int
kill(int pid)
{
    800025d0:	7179                	addi	sp,sp,-48
    800025d2:	f406                	sd	ra,40(sp)
    800025d4:	f022                	sd	s0,32(sp)
    800025d6:	ec26                	sd	s1,24(sp)
    800025d8:	e84a                	sd	s2,16(sp)
    800025da:	e44e                	sd	s3,8(sp)
    800025dc:	1800                	addi	s0,sp,48
    800025de:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800025e0:	00012497          	auipc	s1,0x12
    800025e4:	0f048493          	addi	s1,s1,240 # 800146d0 <proc>
    800025e8:	00019997          	auipc	s3,0x19
    800025ec:	2e898993          	addi	s3,s3,744 # 8001b8d0 <tickslock>
    acquire(&p->lock);
    800025f0:	8526                	mv	a0,s1
    800025f2:	ffffe097          	auipc	ra,0xffffe
    800025f6:	662080e7          	jalr	1634(ra) # 80000c54 <acquire>

    if(p->pid == pid){
    800025fa:	589c                	lw	a5,48(s1)
    800025fc:	01278d63          	beq	a5,s2,80002616 <kill+0x46>

      release(&p->lock);
      return 0;
    }

    release(&p->lock);
    80002600:	8526                	mv	a0,s1
    80002602:	ffffe097          	auipc	ra,0xffffe
    80002606:	702080e7          	jalr	1794(ra) # 80000d04 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000260a:	1c848493          	addi	s1,s1,456
    8000260e:	ff3491e3          	bne	s1,s3,800025f0 <kill+0x20>
  }

  return -1;
    80002612:	557d                	li	a0,-1
    80002614:	a829                	j	8000262e <kill+0x5e>
      p->killed = 1;
    80002616:	4785                	li	a5,1
    80002618:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING)
    8000261a:	4c98                	lw	a4,24(s1)
    8000261c:	4789                	li	a5,2
    8000261e:	00f70f63          	beq	a4,a5,8000263c <kill+0x6c>
      release(&p->lock);
    80002622:	8526                	mv	a0,s1
    80002624:	ffffe097          	auipc	ra,0xffffe
    80002628:	6e0080e7          	jalr	1760(ra) # 80000d04 <release>
      return 0;
    8000262c:	4501                	li	a0,0
}
    8000262e:	70a2                	ld	ra,40(sp)
    80002630:	7402                	ld	s0,32(sp)
    80002632:	64e2                	ld	s1,24(sp)
    80002634:	6942                	ld	s2,16(sp)
    80002636:	69a2                	ld	s3,8(sp)
    80002638:	6145                	addi	sp,sp,48
    8000263a:	8082                	ret
        p->state = RUNNABLE;
    8000263c:	478d                	li	a5,3
    8000263e:	cc9c                	sw	a5,24(s1)
    80002640:	b7cd                	j	80002622 <kill+0x52>

0000000080002642 <either_copyout>:

// Copia datos a espacio de usuario o kernel
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002642:	7179                	addi	sp,sp,-48
    80002644:	f406                	sd	ra,40(sp)
    80002646:	f022                	sd	s0,32(sp)
    80002648:	ec26                	sd	s1,24(sp)
    8000264a:	e84a                	sd	s2,16(sp)
    8000264c:	e44e                	sd	s3,8(sp)
    8000264e:	e052                	sd	s4,0(sp)
    80002650:	1800                	addi	s0,sp,48
    80002652:	84aa                	mv	s1,a0
    80002654:	8a2e                	mv	s4,a1
    80002656:	89b2                	mv	s3,a2
    80002658:	8936                	mv	s2,a3
  struct proc *p = myproc();
    8000265a:	fffff097          	auipc	ra,0xfffff
    8000265e:	42c080e7          	jalr	1068(ra) # 80001a86 <myproc>

  if(user_dst)
    80002662:	c08d                	beqz	s1,80002684 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002664:	86ca                	mv	a3,s2
    80002666:	864e                	mv	a2,s3
    80002668:	85d2                	mv	a1,s4
    8000266a:	6928                	ld	a0,80(a0)
    8000266c:	fffff097          	auipc	ra,0xfffff
    80002670:	09e080e7          	jalr	158(ra) # 8000170a <copyout>
  else{
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002674:	70a2                	ld	ra,40(sp)
    80002676:	7402                	ld	s0,32(sp)
    80002678:	64e2                	ld	s1,24(sp)
    8000267a:	6942                	ld	s2,16(sp)
    8000267c:	69a2                	ld	s3,8(sp)
    8000267e:	6a02                	ld	s4,0(sp)
    80002680:	6145                	addi	sp,sp,48
    80002682:	8082                	ret
    memmove((char *)dst, src, len);
    80002684:	0009061b          	sext.w	a2,s2
    80002688:	85ce                	mv	a1,s3
    8000268a:	8552                	mv	a0,s4
    8000268c:	ffffe097          	auipc	ra,0xffffe
    80002690:	720080e7          	jalr	1824(ra) # 80000dac <memmove>
    return 0;
    80002694:	8526                	mv	a0,s1
    80002696:	bff9                	j	80002674 <either_copyout+0x32>

0000000080002698 <either_copyin>:

// Copia datos desde espacio de usuario o kernel
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002698:	7179                	addi	sp,sp,-48
    8000269a:	f406                	sd	ra,40(sp)
    8000269c:	f022                	sd	s0,32(sp)
    8000269e:	ec26                	sd	s1,24(sp)
    800026a0:	e84a                	sd	s2,16(sp)
    800026a2:	e44e                	sd	s3,8(sp)
    800026a4:	e052                	sd	s4,0(sp)
    800026a6:	1800                	addi	s0,sp,48
    800026a8:	8a2a                	mv	s4,a0
    800026aa:	84ae                	mv	s1,a1
    800026ac:	89b2                	mv	s3,a2
    800026ae:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800026b0:	fffff097          	auipc	ra,0xfffff
    800026b4:	3d6080e7          	jalr	982(ra) # 80001a86 <myproc>

  if(user_src)
    800026b8:	c08d                	beqz	s1,800026da <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800026ba:	86ca                	mv	a3,s2
    800026bc:	864e                	mv	a2,s3
    800026be:	85d2                	mv	a1,s4
    800026c0:	6928                	ld	a0,80(a0)
    800026c2:	fffff097          	auipc	ra,0xfffff
    800026c6:	0d4080e7          	jalr	212(ra) # 80001796 <copyin>
  else{
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800026ca:	70a2                	ld	ra,40(sp)
    800026cc:	7402                	ld	s0,32(sp)
    800026ce:	64e2                	ld	s1,24(sp)
    800026d0:	6942                	ld	s2,16(sp)
    800026d2:	69a2                	ld	s3,8(sp)
    800026d4:	6a02                	ld	s4,0(sp)
    800026d6:	6145                	addi	sp,sp,48
    800026d8:	8082                	ret
    memmove(dst, (char*)src, len);
    800026da:	0009061b          	sext.w	a2,s2
    800026de:	85ce                	mv	a1,s3
    800026e0:	8552                	mv	a0,s4
    800026e2:	ffffe097          	auipc	ra,0xffffe
    800026e6:	6ca080e7          	jalr	1738(ra) # 80000dac <memmove>
    return 0;
    800026ea:	8526                	mv	a0,s1
    800026ec:	bff9                	j	800026ca <either_copyin+0x32>

00000000800026ee <procdump>:

// Imprime informacion de procesos (Ctrl+P)
void
procdump(void)
{
    800026ee:	715d                	addi	sp,sp,-80
    800026f0:	e486                	sd	ra,72(sp)
    800026f2:	e0a2                	sd	s0,64(sp)
    800026f4:	fc26                	sd	s1,56(sp)
    800026f6:	f84a                	sd	s2,48(sp)
    800026f8:	f44e                	sd	s3,40(sp)
    800026fa:	f052                	sd	s4,32(sp)
    800026fc:	ec56                	sd	s5,24(sp)
    800026fe:	e85a                	sd	s6,16(sp)
    80002700:	e45e                	sd	s7,8(sp)
    80002702:	e062                	sd	s8,0(sp)
    80002704:	0880                	addi	s0,sp,80
  };

  struct proc *p;
  char *state;

  printf("\n");
    80002706:	00006517          	auipc	a0,0x6
    8000270a:	90a50513          	addi	a0,a0,-1782 # 80008010 <etext+0x10>
    8000270e:	ffffe097          	auipc	ra,0xffffe
    80002712:	e92080e7          	jalr	-366(ra) # 800005a0 <printf>

  for(p = proc; p < &proc[NPROC]; p++){
    80002716:	00012497          	auipc	s1,0x12
    8000271a:	fba48493          	addi	s1,s1,-70 # 800146d0 <proc>
    if(p->state == UNUSED)
      continue;

    if(p->state >= 0 && p->state < NELEM(states))
    8000271e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002720:	00006a97          	auipc	s5,0x6
    80002724:	b40a8a93          	addi	s5,s5,-1216 # 80008260 <etext+0x260>
    if(p->exit_time > 0)
      wait_time = p->exit_time - p->create_time - p->total_run_time;
    else
      wait_time = ticks - p->create_time - p->total_run_time;

    printf("%d %d %s %d %d %d",
    80002728:	00006a17          	auipc	s4,0x6
    8000272c:	b40a0a13          	addi	s4,s4,-1216 # 80008268 <etext+0x268>
           p->total_run_time,
           wait_time,
           p->n_runs);
#endif

    printf("\n");
    80002730:	00006997          	auipc	s3,0x6
    80002734:	8e098993          	addi	s3,s3,-1824 # 80008010 <etext+0x10>
      wait_time = ticks - p->create_time - p->total_run_time;
    80002738:	0000ac17          	auipc	s8,0xa
    8000273c:	8f8c0c13          	addi	s8,s8,-1800 # 8000c030 <ticks>
      state = states[p->state];
    80002740:	00006b97          	auipc	s7,0x6
    80002744:	0c8b8b93          	addi	s7,s7,200 # 80008808 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    80002748:	00019917          	auipc	s2,0x19
    8000274c:	18890913          	addi	s2,s2,392 # 8001b8d0 <tickslock>
    80002750:	a835                	j	8000278c <procdump+0x9e>
      wait_time = ticks - p->create_time - p->total_run_time;
    80002752:	1704b703          	ld	a4,368(s1)
    80002756:	1804b783          	ld	a5,384(s1)
    8000275a:	9f3d                	addw	a4,a4,a5
    8000275c:	000c2783          	lw	a5,0(s8)
    80002760:	9f99                	subw	a5,a5,a4
    printf("%d %d %s %d %d %d",
    80002762:	1a84b803          	ld	a6,424(s1)
    80002766:	1804b703          	ld	a4,384(s1)
    8000276a:	1b04b603          	ld	a2,432(s1)
    8000276e:	588c                	lw	a1,48(s1)
    80002770:	8552                	mv	a0,s4
    80002772:	ffffe097          	auipc	ra,0xffffe
    80002776:	e2e080e7          	jalr	-466(ra) # 800005a0 <printf>
    printf("\n");
    8000277a:	854e                	mv	a0,s3
    8000277c:	ffffe097          	auipc	ra,0xffffe
    80002780:	e24080e7          	jalr	-476(ra) # 800005a0 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002784:	1c848493          	addi	s1,s1,456
    80002788:	03248763          	beq	s1,s2,800027b6 <procdump+0xc8>
    if(p->state == UNUSED)
    8000278c:	4c9c                	lw	a5,24(s1)
    8000278e:	dbfd                	beqz	a5,80002784 <procdump+0x96>
      state = "???";
    80002790:	86d6                	mv	a3,s5
    if(p->state >= 0 && p->state < NELEM(states))
    80002792:	00fb6863          	bltu	s6,a5,800027a2 <procdump+0xb4>
      state = states[p->state];
    80002796:	02079713          	slli	a4,a5,0x20
    8000279a:	01d75793          	srli	a5,a4,0x1d
    8000279e:	97de                	add	a5,a5,s7
    800027a0:	6394                	ld	a3,0(a5)
    if(p->exit_time > 0)
    800027a2:	1a04b783          	ld	a5,416(s1)
    800027a6:	d7d5                	beqz	a5,80002752 <procdump+0x64>
      wait_time = p->exit_time - p->create_time - p->total_run_time;
    800027a8:	1704b703          	ld	a4,368(s1)
    800027ac:	1804b603          	ld	a2,384(s1)
    800027b0:	9f31                	addw	a4,a4,a2
    800027b2:	9f99                	subw	a5,a5,a4
    800027b4:	b77d                	j	80002762 <procdump+0x74>
  }
}
    800027b6:	60a6                	ld	ra,72(sp)
    800027b8:	6406                	ld	s0,64(sp)
    800027ba:	74e2                	ld	s1,56(sp)
    800027bc:	7942                	ld	s2,48(sp)
    800027be:	79a2                	ld	s3,40(sp)
    800027c0:	7a02                	ld	s4,32(sp)
    800027c2:	6ae2                	ld	s5,24(sp)
    800027c4:	6b42                	ld	s6,16(sp)
    800027c6:	6ba2                	ld	s7,8(sp)
    800027c8:	6c02                	ld	s8,0(sp)
    800027ca:	6161                	addi	sp,sp,80
    800027cc:	8082                	ret

00000000800027ce <update_time>:

// Actualiza run_time y sleep_time cada tick
void
update_time(void)
{
    800027ce:	7179                	addi	sp,sp,-48
    800027d0:	f406                	sd	ra,40(sp)
    800027d2:	f022                	sd	s0,32(sp)
    800027d4:	ec26                	sd	s1,24(sp)
    800027d6:	e84a                	sd	s2,16(sp)
    800027d8:	e44e                	sd	s3,8(sp)
    800027da:	e052                	sd	s4,0(sp)
    800027dc:	1800                	addi	s0,sp,48
  struct proc* p;

  for(p = proc; p < &proc[NPROC]; p++)
    800027de:	00012497          	auipc	s1,0x12
    800027e2:	ef248493          	addi	s1,s1,-270 # 800146d0 <proc>
  {
    acquire(&p->lock);

    if(p->state == RUNNING){
    800027e6:	4991                	li	s3,4
      p->run_time += 1;
      p->total_run_time += 1;
    }
    else if(p->state == SLEEPING){
    800027e8:	4a09                	li	s4,2
  for(p = proc; p < &proc[NPROC]; p++)
    800027ea:	00019917          	auipc	s2,0x19
    800027ee:	0e690913          	addi	s2,s2,230 # 8001b8d0 <tickslock>
    800027f2:	a025                	j	8000281a <update_time+0x4c>
      p->run_time += 1;
    800027f4:	1784b783          	ld	a5,376(s1)
    800027f8:	0785                	addi	a5,a5,1
    800027fa:	16f4bc23          	sd	a5,376(s1)
      p->total_run_time += 1;
    800027fe:	1804b783          	ld	a5,384(s1)
    80002802:	0785                	addi	a5,a5,1
    80002804:	18f4b023          	sd	a5,384(s1)
      p->sleep_time += 1;
    }

    release(&p->lock);
    80002808:	8526                	mv	a0,s1
    8000280a:	ffffe097          	auipc	ra,0xffffe
    8000280e:	4fa080e7          	jalr	1274(ra) # 80000d04 <release>
  for(p = proc; p < &proc[NPROC]; p++)
    80002812:	1c848493          	addi	s1,s1,456
    80002816:	03248263          	beq	s1,s2,8000283a <update_time+0x6c>
    acquire(&p->lock);
    8000281a:	8526                	mv	a0,s1
    8000281c:	ffffe097          	auipc	ra,0xffffe
    80002820:	438080e7          	jalr	1080(ra) # 80000c54 <acquire>
    if(p->state == RUNNING){
    80002824:	4c9c                	lw	a5,24(s1)
    80002826:	fd3787e3          	beq	a5,s3,800027f4 <update_time+0x26>
    else if(p->state == SLEEPING){
    8000282a:	fd479fe3          	bne	a5,s4,80002808 <update_time+0x3a>
      p->sleep_time += 1;
    8000282e:	1984b783          	ld	a5,408(s1)
    80002832:	0785                	addi	a5,a5,1
    80002834:	18f4bc23          	sd	a5,408(s1)
    80002838:	bfc1                	j	80002808 <update_time+0x3a>
  }
}
    8000283a:	70a2                	ld	ra,40(sp)
    8000283c:	7402                	ld	s0,32(sp)
    8000283e:	64e2                	ld	s1,24(sp)
    80002840:	6942                	ld	s2,16(sp)
    80002842:	69a2                	ld	s3,8(sp)
    80002844:	6a02                	ld	s4,0(sp)
    80002846:	6145                	addi	sp,sp,48
    80002848:	8082                	ret

000000008000284a <setpriority>:

// Cambia prioridad estatica PBS
int
setpriority(int new_priority, int pid)
{
    8000284a:	7179                	addi	sp,sp,-48
    8000284c:	f406                	sd	ra,40(sp)
    8000284e:	f022                	sd	s0,32(sp)
    80002850:	ec26                	sd	s1,24(sp)
    80002852:	e84a                	sd	s2,16(sp)
    80002854:	e44e                	sd	s3,8(sp)
    80002856:	e052                	sd	s4,0(sp)
    80002858:	1800                	addi	s0,sp,48
    8000285a:	8a2a                	mv	s4,a0
    8000285c:	892e                	mv	s2,a1
  int prev_priority = 0;
  struct proc* p;

  for(p = proc; p < &proc[NPROC]; p++)
    8000285e:	00012497          	auipc	s1,0x12
    80002862:	e7248493          	addi	s1,s1,-398 # 800146d0 <proc>
    80002866:	00019997          	auipc	s3,0x19
    8000286a:	06a98993          	addi	s3,s3,106 # 8001b8d0 <tickslock>
  {
    acquire(&p->lock);
    8000286e:	8526                	mv	a0,s1
    80002870:	ffffe097          	auipc	ra,0xffffe
    80002874:	3e4080e7          	jalr	996(ra) # 80000c54 <acquire>

    if(p->pid == pid)
    80002878:	589c                	lw	a5,48(s1)
    8000287a:	01278d63          	beq	a5,s2,80002894 <setpriority+0x4a>
        yield();

      break;
    }

    release(&p->lock);
    8000287e:	8526                	mv	a0,s1
    80002880:	ffffe097          	auipc	ra,0xffffe
    80002884:	484080e7          	jalr	1156(ra) # 80000d04 <release>
  for(p = proc; p < &proc[NPROC]; p++)
    80002888:	1c848493          	addi	s1,s1,456
    8000288c:	ff3491e3          	bne	s1,s3,8000286e <setpriority+0x24>
  int prev_priority = 0;
    80002890:	4901                	li	s2,0
    80002892:	a005                	j	800028b2 <setpriority+0x68>
      prev_priority = p->priority;
    80002894:	1b04a903          	lw	s2,432(s1)
      p->priority = new_priority;
    80002898:	1b44b823          	sd	s4,432(s1)
      p->sleep_time = 0;
    8000289c:	1804bc23          	sd	zero,408(s1)
      p->run_time = 0;
    800028a0:	1604bc23          	sd	zero,376(s1)
      release(&p->lock);
    800028a4:	8526                	mv	a0,s1
    800028a6:	ffffe097          	auipc	ra,0xffffe
    800028aa:	45e080e7          	jalr	1118(ra) # 80000d04 <release>
      if(reschedule)
    800028ae:	012a4b63          	blt	s4,s2,800028c4 <setpriority+0x7a>
  }

  return prev_priority;
}
    800028b2:	854a                	mv	a0,s2
    800028b4:	70a2                	ld	ra,40(sp)
    800028b6:	7402                	ld	s0,32(sp)
    800028b8:	64e2                	ld	s1,24(sp)
    800028ba:	6942                	ld	s2,16(sp)
    800028bc:	69a2                	ld	s3,8(sp)
    800028be:	6a02                	ld	s4,0(sp)
    800028c0:	6145                	addi	sp,sp,48
    800028c2:	8082                	ret
        yield();
    800028c4:	00000097          	auipc	ra,0x0
    800028c8:	994080e7          	jalr	-1644(ra) # 80002258 <yield>
    800028cc:	b7dd                	j	800028b2 <setpriority+0x68>

00000000800028ce <waitx>:

// waitx: igual que wait pero devuelve tiempos rtime y wtime
int
waitx(uint64 addr, uint* rtime, uint* wtime)
{
    800028ce:	711d                	addi	sp,sp,-96
    800028d0:	ec86                	sd	ra,88(sp)
    800028d2:	e8a2                	sd	s0,80(sp)
    800028d4:	e4a6                	sd	s1,72(sp)
    800028d6:	e0ca                	sd	s2,64(sp)
    800028d8:	fc4e                	sd	s3,56(sp)
    800028da:	f852                	sd	s4,48(sp)
    800028dc:	f456                	sd	s5,40(sp)
    800028de:	f05a                	sd	s6,32(sp)
    800028e0:	ec5e                	sd	s7,24(sp)
    800028e2:	e862                	sd	s8,16(sp)
    800028e4:	e466                	sd	s9,8(sp)
    800028e6:	1080                	addi	s0,sp,96
    800028e8:	8baa                	mv	s7,a0
    800028ea:	8c2e                	mv	s8,a1
    800028ec:	8cb2                	mv	s9,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    800028ee:	fffff097          	auipc	ra,0xfffff
    800028f2:	198080e7          	jalr	408(ra) # 80001a86 <myproc>
    800028f6:	892a                	mv	s2,a0

  acquire(&wait_lock);
    800028f8:	00012517          	auipc	a0,0x12
    800028fc:	9c050513          	addi	a0,a0,-1600 # 800142b8 <wait_lock>
    80002900:	ffffe097          	auipc	ra,0xffffe
    80002904:	354080e7          	jalr	852(ra) # 80000c54 <acquire>
      if(np->parent == p){

        acquire(&np->lock);
        havekids = 1;

        if(np->state == ZOMBIE){
    80002908:	4a15                	li	s4,5
        havekids = 1;
    8000290a:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    8000290c:	00019997          	auipc	s3,0x19
    80002910:	fc498993          	addi	s3,s3,-60 # 8001b8d0 <tickslock>
    if(!havekids || p->killed){
      release(&wait_lock);
      return -1;
    }

    sleep(p, &wait_lock);
    80002914:	00012b17          	auipc	s6,0x12
    80002918:	9a4b0b13          	addi	s6,s6,-1628 # 800142b8 <wait_lock>
    8000291c:	a8f1                	j	800029f8 <waitx+0x12a>
          pid = np->pid;
    8000291e:	0304a983          	lw	s3,48(s1)
          *rtime = np->run_time;
    80002922:	1784b783          	ld	a5,376(s1)
    80002926:	00fc2023          	sw	a5,0(s8)
          *wtime = np->exit_time - np->create_time - np->run_time;
    8000292a:	1a04b783          	ld	a5,416(s1)
    8000292e:	1704b703          	ld	a4,368(s1)
    80002932:	1784b683          	ld	a3,376(s1)
    80002936:	9f35                	addw	a4,a4,a3
    80002938:	9f99                	subw	a5,a5,a4
    8000293a:	00fca023          	sw	a5,0(s9)
          if(addr != 0 &&
    8000293e:	000b8e63          	beqz	s7,8000295a <waitx+0x8c>
             copyout(p->pagetable,
    80002942:	4691                	li	a3,4
    80002944:	02c48613          	addi	a2,s1,44
    80002948:	85de                	mv	a1,s7
    8000294a:	05093503          	ld	a0,80(s2)
    8000294e:	fffff097          	auipc	ra,0xfffff
    80002952:	dbc080e7          	jalr	-580(ra) # 8000170a <copyout>
          if(addr != 0 &&
    80002956:	04054263          	bltz	a0,8000299a <waitx+0xcc>
          freeproc(np);
    8000295a:	8526                	mv	a0,s1
    8000295c:	fffff097          	auipc	ra,0xfffff
    80002960:	2de080e7          	jalr	734(ra) # 80001c3a <freeproc>
          release(&np->lock);
    80002964:	8526                	mv	a0,s1
    80002966:	ffffe097          	auipc	ra,0xffffe
    8000296a:	39e080e7          	jalr	926(ra) # 80000d04 <release>
          release(&wait_lock);
    8000296e:	00012517          	auipc	a0,0x12
    80002972:	94a50513          	addi	a0,a0,-1718 # 800142b8 <wait_lock>
    80002976:	ffffe097          	auipc	ra,0xffffe
    8000297a:	38e080e7          	jalr	910(ra) # 80000d04 <release>
  }
}
    8000297e:	854e                	mv	a0,s3
    80002980:	60e6                	ld	ra,88(sp)
    80002982:	6446                	ld	s0,80(sp)
    80002984:	64a6                	ld	s1,72(sp)
    80002986:	6906                	ld	s2,64(sp)
    80002988:	79e2                	ld	s3,56(sp)
    8000298a:	7a42                	ld	s4,48(sp)
    8000298c:	7aa2                	ld	s5,40(sp)
    8000298e:	7b02                	ld	s6,32(sp)
    80002990:	6be2                	ld	s7,24(sp)
    80002992:	6c42                	ld	s8,16(sp)
    80002994:	6ca2                	ld	s9,8(sp)
    80002996:	6125                	addi	sp,sp,96
    80002998:	8082                	ret
            release(&np->lock);
    8000299a:	8526                	mv	a0,s1
    8000299c:	ffffe097          	auipc	ra,0xffffe
    800029a0:	368080e7          	jalr	872(ra) # 80000d04 <release>
            release(&wait_lock);
    800029a4:	00012517          	auipc	a0,0x12
    800029a8:	91450513          	addi	a0,a0,-1772 # 800142b8 <wait_lock>
    800029ac:	ffffe097          	auipc	ra,0xffffe
    800029b0:	358080e7          	jalr	856(ra) # 80000d04 <release>
            return -1;
    800029b4:	59fd                	li	s3,-1
    800029b6:	b7e1                	j	8000297e <waitx+0xb0>
    for(np = proc; np < &proc[NPROC]; np++){
    800029b8:	1c848493          	addi	s1,s1,456
    800029bc:	03348463          	beq	s1,s3,800029e4 <waitx+0x116>
      if(np->parent == p){
    800029c0:	7c9c                	ld	a5,56(s1)
    800029c2:	ff279be3          	bne	a5,s2,800029b8 <waitx+0xea>
        acquire(&np->lock);
    800029c6:	8526                	mv	a0,s1
    800029c8:	ffffe097          	auipc	ra,0xffffe
    800029cc:	28c080e7          	jalr	652(ra) # 80000c54 <acquire>
        if(np->state == ZOMBIE){
    800029d0:	4c9c                	lw	a5,24(s1)
    800029d2:	f54786e3          	beq	a5,s4,8000291e <waitx+0x50>
        release(&np->lock);
    800029d6:	8526                	mv	a0,s1
    800029d8:	ffffe097          	auipc	ra,0xffffe
    800029dc:	32c080e7          	jalr	812(ra) # 80000d04 <release>
        havekids = 1;
    800029e0:	8756                	mv	a4,s5
    800029e2:	bfd9                	j	800029b8 <waitx+0xea>
    if(!havekids || p->killed){
    800029e4:	c305                	beqz	a4,80002a04 <waitx+0x136>
    800029e6:	02892783          	lw	a5,40(s2)
    800029ea:	ef89                	bnez	a5,80002a04 <waitx+0x136>
    sleep(p, &wait_lock);
    800029ec:	85da                	mv	a1,s6
    800029ee:	854a                	mv	a0,s2
    800029f0:	00000097          	auipc	ra,0x0
    800029f4:	8a4080e7          	jalr	-1884(ra) # 80002294 <sleep>
    havekids = 0;
    800029f8:	4701                	li	a4,0
    for(np = proc; np < &proc[NPROC]; np++){
    800029fa:	00012497          	auipc	s1,0x12
    800029fe:	cd648493          	addi	s1,s1,-810 # 800146d0 <proc>
    80002a02:	bf7d                	j	800029c0 <waitx+0xf2>
      release(&wait_lock);
    80002a04:	00012517          	auipc	a0,0x12
    80002a08:	8b450513          	addi	a0,a0,-1868 # 800142b8 <wait_lock>
    80002a0c:	ffffe097          	auipc	ra,0xffffe
    80002a10:	2f8080e7          	jalr	760(ra) # 80000d04 <release>
      return -1;
    80002a14:	59fd                	li	s3,-1
    80002a16:	b7a5                	j	8000297e <waitx+0xb0>

0000000080002a18 <swtch>:
    80002a18:	00153023          	sd	ra,0(a0)
    80002a1c:	00253423          	sd	sp,8(a0)
    80002a20:	e900                	sd	s0,16(a0)
    80002a22:	ed04                	sd	s1,24(a0)
    80002a24:	03253023          	sd	s2,32(a0)
    80002a28:	03353423          	sd	s3,40(a0)
    80002a2c:	03453823          	sd	s4,48(a0)
    80002a30:	03553c23          	sd	s5,56(a0)
    80002a34:	05653023          	sd	s6,64(a0)
    80002a38:	05753423          	sd	s7,72(a0)
    80002a3c:	05853823          	sd	s8,80(a0)
    80002a40:	05953c23          	sd	s9,88(a0)
    80002a44:	07a53023          	sd	s10,96(a0)
    80002a48:	07b53423          	sd	s11,104(a0)
    80002a4c:	0005b083          	ld	ra,0(a1)
    80002a50:	0085b103          	ld	sp,8(a1)
    80002a54:	6980                	ld	s0,16(a1)
    80002a56:	6d84                	ld	s1,24(a1)
    80002a58:	0205b903          	ld	s2,32(a1)
    80002a5c:	0285b983          	ld	s3,40(a1)
    80002a60:	0305ba03          	ld	s4,48(a1)
    80002a64:	0385ba83          	ld	s5,56(a1)
    80002a68:	0405bb03          	ld	s6,64(a1)
    80002a6c:	0485bb83          	ld	s7,72(a1)
    80002a70:	0505bc03          	ld	s8,80(a1)
    80002a74:	0585bc83          	ld	s9,88(a1)
    80002a78:	0605bd03          	ld	s10,96(a1)
    80002a7c:	0685bd83          	ld	s11,104(a1)
    80002a80:	8082                	ret

0000000080002a82 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002a82:	1141                	addi	sp,sp,-16
    80002a84:	e406                	sd	ra,8(sp)
    80002a86:	e022                	sd	s0,0(sp)
    80002a88:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002a8a:	00006597          	auipc	a1,0x6
    80002a8e:	82658593          	addi	a1,a1,-2010 # 800082b0 <etext+0x2b0>
    80002a92:	00019517          	auipc	a0,0x19
    80002a96:	e3e50513          	addi	a0,a0,-450 # 8001b8d0 <tickslock>
    80002a9a:	ffffe097          	auipc	ra,0xffffe
    80002a9e:	120080e7          	jalr	288(ra) # 80000bba <initlock>
}
    80002aa2:	60a2                	ld	ra,8(sp)
    80002aa4:	6402                	ld	s0,0(sp)
    80002aa6:	0141                	addi	sp,sp,16
    80002aa8:	8082                	ret

0000000080002aaa <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002aaa:	1141                	addi	sp,sp,-16
    80002aac:	e406                	sd	ra,8(sp)
    80002aae:	e022                	sd	s0,0(sp)
    80002ab0:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ab2:	00003797          	auipc	a5,0x3
    80002ab6:	7de78793          	addi	a5,a5,2014 # 80006290 <kernelvec>
    80002aba:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002abe:	60a2                	ld	ra,8(sp)
    80002ac0:	6402                	ld	s0,0(sp)
    80002ac2:	0141                	addi	sp,sp,16
    80002ac4:	8082                	ret

0000000080002ac6 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002ac6:	1141                	addi	sp,sp,-16
    80002ac8:	e406                	sd	ra,8(sp)
    80002aca:	e022                	sd	s0,0(sp)
    80002acc:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002ace:	fffff097          	auipc	ra,0xfffff
    80002ad2:	fb8080e7          	jalr	-72(ra) # 80001a86 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ad6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002ada:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002adc:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002ae0:	00004697          	auipc	a3,0x4
    80002ae4:	52068693          	addi	a3,a3,1312 # 80007000 <_trampoline>
    80002ae8:	00004717          	auipc	a4,0x4
    80002aec:	51870713          	addi	a4,a4,1304 # 80007000 <_trampoline>
    80002af0:	8f15                	sub	a4,a4,a3
    80002af2:	040007b7          	lui	a5,0x4000
    80002af6:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002af8:	07b2                	slli	a5,a5,0xc
    80002afa:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002afc:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002b00:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002b02:	18002673          	csrr	a2,satp
    80002b06:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002b08:	6d30                	ld	a2,88(a0)
    80002b0a:	6138                	ld	a4,64(a0)
    80002b0c:	6585                	lui	a1,0x1
    80002b0e:	972e                	add	a4,a4,a1
    80002b10:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002b12:	6d38                	ld	a4,88(a0)
    80002b14:	00000617          	auipc	a2,0x0
    80002b18:	15260613          	addi	a2,a2,338 # 80002c66 <usertrap>
    80002b1c:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002b1e:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002b20:	8612                	mv	a2,tp
    80002b22:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b24:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002b28:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002b2c:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b30:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002b34:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b36:	6f18                	ld	a4,24(a4)
    80002b38:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b3c:	692c                	ld	a1,80(a0)
    80002b3e:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002b40:	00004717          	auipc	a4,0x4
    80002b44:	55070713          	addi	a4,a4,1360 # 80007090 <userret>
    80002b48:	8f15                	sub	a4,a4,a3
    80002b4a:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002b4c:	577d                	li	a4,-1
    80002b4e:	177e                	slli	a4,a4,0x3f
    80002b50:	8dd9                	or	a1,a1,a4
    80002b52:	02000537          	lui	a0,0x2000
    80002b56:	157d                	addi	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    80002b58:	0536                	slli	a0,a0,0xd
    80002b5a:	9782                	jalr	a5
}
    80002b5c:	60a2                	ld	ra,8(sp)
    80002b5e:	6402                	ld	s0,0(sp)
    80002b60:	0141                	addi	sp,sp,16
    80002b62:	8082                	ret

0000000080002b64 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002b64:	1141                	addi	sp,sp,-16
    80002b66:	e406                	sd	ra,8(sp)
    80002b68:	e022                	sd	s0,0(sp)
    80002b6a:	0800                	addi	s0,sp,16
  acquire(&tickslock);
    80002b6c:	00019517          	auipc	a0,0x19
    80002b70:	d6450513          	addi	a0,a0,-668 # 8001b8d0 <tickslock>
    80002b74:	ffffe097          	auipc	ra,0xffffe
    80002b78:	0e0080e7          	jalr	224(ra) # 80000c54 <acquire>
  ticks++;
    80002b7c:	00009717          	auipc	a4,0x9
    80002b80:	4b470713          	addi	a4,a4,1204 # 8000c030 <ticks>
    80002b84:	431c                	lw	a5,0(a4)
    80002b86:	2785                	addiw	a5,a5,1
    80002b88:	c31c                	sw	a5,0(a4)
  update_time();
    80002b8a:	00000097          	auipc	ra,0x0
    80002b8e:	c44080e7          	jalr	-956(ra) # 800027ce <update_time>
  wakeup(&ticks);
    80002b92:	00009517          	auipc	a0,0x9
    80002b96:	49e50513          	addi	a0,a0,1182 # 8000c030 <ticks>
    80002b9a:	00000097          	auipc	ra,0x0
    80002b9e:	880080e7          	jalr	-1920(ra) # 8000241a <wakeup>
  release(&tickslock);
    80002ba2:	00019517          	auipc	a0,0x19
    80002ba6:	d2e50513          	addi	a0,a0,-722 # 8001b8d0 <tickslock>
    80002baa:	ffffe097          	auipc	ra,0xffffe
    80002bae:	15a080e7          	jalr	346(ra) # 80000d04 <release>
}
    80002bb2:	60a2                	ld	ra,8(sp)
    80002bb4:	6402                	ld	s0,0(sp)
    80002bb6:	0141                	addi	sp,sp,16
    80002bb8:	8082                	ret

0000000080002bba <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bba:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002bbe:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002bc0:	0a07d263          	bgez	a5,80002c64 <devintr+0xaa>
{
    80002bc4:	1101                	addi	sp,sp,-32
    80002bc6:	ec06                	sd	ra,24(sp)
    80002bc8:	e822                	sd	s0,16(sp)
    80002bca:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    80002bcc:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002bd0:	46a5                	li	a3,9
    80002bd2:	00d70c63          	beq	a4,a3,80002bea <devintr+0x30>
  } else if(scause == 0x8000000000000001L){
    80002bd6:	577d                	li	a4,-1
    80002bd8:	177e                	slli	a4,a4,0x3f
    80002bda:	0705                	addi	a4,a4,1
    return 0;
    80002bdc:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002bde:	06e78263          	beq	a5,a4,80002c42 <devintr+0x88>
  }
}
    80002be2:	60e2                	ld	ra,24(sp)
    80002be4:	6442                	ld	s0,16(sp)
    80002be6:	6105                	addi	sp,sp,32
    80002be8:	8082                	ret
    80002bea:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002bec:	00003097          	auipc	ra,0x3
    80002bf0:	7b0080e7          	jalr	1968(ra) # 8000639c <plic_claim>
    80002bf4:	872a                	mv	a4,a0
    80002bf6:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002bf8:	47a9                	li	a5,10
    80002bfa:	00f50963          	beq	a0,a5,80002c0c <devintr+0x52>
    } else if(irq == VIRTIO0_IRQ){
    80002bfe:	4785                	li	a5,1
    80002c00:	00f50b63          	beq	a0,a5,80002c16 <devintr+0x5c>
    return 1;
    80002c04:	4505                	li	a0,1
    } else if(irq){
    80002c06:	ef09                	bnez	a4,80002c20 <devintr+0x66>
    80002c08:	64a2                	ld	s1,8(sp)
    80002c0a:	bfe1                	j	80002be2 <devintr+0x28>
      uartintr();
    80002c0c:	ffffe097          	auipc	ra,0xffffe
    80002c10:	dec080e7          	jalr	-532(ra) # 800009f8 <uartintr>
    if(irq)
    80002c14:	a839                	j	80002c32 <devintr+0x78>
      virtio_disk_intr();
    80002c16:	00004097          	auipc	ra,0x4
    80002c1a:	c40080e7          	jalr	-960(ra) # 80006856 <virtio_disk_intr>
    if(irq)
    80002c1e:	a811                	j	80002c32 <devintr+0x78>
      printf("unexpected interrupt irq=%d\n", irq);
    80002c20:	85ba                	mv	a1,a4
    80002c22:	00005517          	auipc	a0,0x5
    80002c26:	69650513          	addi	a0,a0,1686 # 800082b8 <etext+0x2b8>
    80002c2a:	ffffe097          	auipc	ra,0xffffe
    80002c2e:	976080e7          	jalr	-1674(ra) # 800005a0 <printf>
      plic_complete(irq);
    80002c32:	8526                	mv	a0,s1
    80002c34:	00003097          	auipc	ra,0x3
    80002c38:	78c080e7          	jalr	1932(ra) # 800063c0 <plic_complete>
    return 1;
    80002c3c:	4505                	li	a0,1
    80002c3e:	64a2                	ld	s1,8(sp)
    80002c40:	b74d                	j	80002be2 <devintr+0x28>
    if(cpuid() == 0){
    80002c42:	fffff097          	auipc	ra,0xfffff
    80002c46:	e10080e7          	jalr	-496(ra) # 80001a52 <cpuid>
    80002c4a:	c901                	beqz	a0,80002c5a <devintr+0xa0>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002c4c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002c50:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002c52:	14479073          	csrw	sip,a5
    return 2;
    80002c56:	4509                	li	a0,2
    80002c58:	b769                	j	80002be2 <devintr+0x28>
      clockintr();
    80002c5a:	00000097          	auipc	ra,0x0
    80002c5e:	f0a080e7          	jalr	-246(ra) # 80002b64 <clockintr>
    80002c62:	b7ed                	j	80002c4c <devintr+0x92>
}
    80002c64:	8082                	ret

0000000080002c66 <usertrap>:
{
    80002c66:	1101                	addi	sp,sp,-32
    80002c68:	ec06                	sd	ra,24(sp)
    80002c6a:	e822                	sd	s0,16(sp)
    80002c6c:	e426                	sd	s1,8(sp)
    80002c6e:	e04a                	sd	s2,0(sp)
    80002c70:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c72:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002c76:	1007f793          	andi	a5,a5,256
    80002c7a:	e3ad                	bnez	a5,80002cdc <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c7c:	00003797          	auipc	a5,0x3
    80002c80:	61478793          	addi	a5,a5,1556 # 80006290 <kernelvec>
    80002c84:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002c88:	fffff097          	auipc	ra,0xfffff
    80002c8c:	dfe080e7          	jalr	-514(ra) # 80001a86 <myproc>
    80002c90:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002c92:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c94:	14102773          	csrr	a4,sepc
    80002c98:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c9a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002c9e:	47a1                	li	a5,8
    80002ca0:	04f71c63          	bne	a4,a5,80002cf8 <usertrap+0x92>
    if(p->killed)
    80002ca4:	551c                	lw	a5,40(a0)
    80002ca6:	e3b9                	bnez	a5,80002cec <usertrap+0x86>
    p->trapframe->epc += 4;
    80002ca8:	6cb8                	ld	a4,88(s1)
    80002caa:	6f1c                	ld	a5,24(a4)
    80002cac:	0791                	addi	a5,a5,4
    80002cae:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cb0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002cb4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002cb8:	10079073          	csrw	sstatus,a5
    syscall();
    80002cbc:	00000097          	auipc	ra,0x0
    80002cc0:	2e2080e7          	jalr	738(ra) # 80002f9e <syscall>
  if(p->killed)
    80002cc4:	549c                	lw	a5,40(s1)
    80002cc6:	ebc1                	bnez	a5,80002d56 <usertrap+0xf0>
  usertrapret();
    80002cc8:	00000097          	auipc	ra,0x0
    80002ccc:	dfe080e7          	jalr	-514(ra) # 80002ac6 <usertrapret>
}
    80002cd0:	60e2                	ld	ra,24(sp)
    80002cd2:	6442                	ld	s0,16(sp)
    80002cd4:	64a2                	ld	s1,8(sp)
    80002cd6:	6902                	ld	s2,0(sp)
    80002cd8:	6105                	addi	sp,sp,32
    80002cda:	8082                	ret
    panic("usertrap: not from user mode");
    80002cdc:	00005517          	auipc	a0,0x5
    80002ce0:	5fc50513          	addi	a0,a0,1532 # 800082d8 <etext+0x2d8>
    80002ce4:	ffffe097          	auipc	ra,0xffffe
    80002ce8:	872080e7          	jalr	-1934(ra) # 80000556 <panic>
      exit(-1);
    80002cec:	557d                	li	a0,-1
    80002cee:	fffff097          	auipc	ra,0xfffff
    80002cf2:	7fc080e7          	jalr	2044(ra) # 800024ea <exit>
    80002cf6:	bf4d                	j	80002ca8 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002cf8:	00000097          	auipc	ra,0x0
    80002cfc:	ec2080e7          	jalr	-318(ra) # 80002bba <devintr>
    80002d00:	892a                	mv	s2,a0
    80002d02:	c501                	beqz	a0,80002d0a <usertrap+0xa4>
  if(p->killed)
    80002d04:	549c                	lw	a5,40(s1)
    80002d06:	c3a1                	beqz	a5,80002d46 <usertrap+0xe0>
    80002d08:	a815                	j	80002d3c <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d0a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002d0e:	5890                	lw	a2,48(s1)
    80002d10:	00005517          	auipc	a0,0x5
    80002d14:	5e850513          	addi	a0,a0,1512 # 800082f8 <etext+0x2f8>
    80002d18:	ffffe097          	auipc	ra,0xffffe
    80002d1c:	888080e7          	jalr	-1912(ra) # 800005a0 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d20:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d24:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d28:	00005517          	auipc	a0,0x5
    80002d2c:	60050513          	addi	a0,a0,1536 # 80008328 <etext+0x328>
    80002d30:	ffffe097          	auipc	ra,0xffffe
    80002d34:	870080e7          	jalr	-1936(ra) # 800005a0 <printf>
    p->killed = 1;
    80002d38:	4785                	li	a5,1
    80002d3a:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002d3c:	557d                	li	a0,-1
    80002d3e:	fffff097          	auipc	ra,0xfffff
    80002d42:	7ac080e7          	jalr	1964(ra) # 800024ea <exit>
  if(which_dev == 2)
    80002d46:	4789                	li	a5,2
    80002d48:	f8f910e3          	bne	s2,a5,80002cc8 <usertrap+0x62>
    yield();
    80002d4c:	fffff097          	auipc	ra,0xfffff
    80002d50:	50c080e7          	jalr	1292(ra) # 80002258 <yield>
    80002d54:	bf95                	j	80002cc8 <usertrap+0x62>
  int which_dev = 0;
    80002d56:	4901                	li	s2,0
    80002d58:	b7d5                	j	80002d3c <usertrap+0xd6>

0000000080002d5a <kerneltrap>:
{
    80002d5a:	7179                	addi	sp,sp,-48
    80002d5c:	f406                	sd	ra,40(sp)
    80002d5e:	f022                	sd	s0,32(sp)
    80002d60:	ec26                	sd	s1,24(sp)
    80002d62:	e84a                	sd	s2,16(sp)
    80002d64:	e44e                	sd	s3,8(sp)
    80002d66:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d68:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d6c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d70:	142027f3          	csrr	a5,scause
    80002d74:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    80002d76:	1004f793          	andi	a5,s1,256
    80002d7a:	cb85                	beqz	a5,80002daa <kerneltrap+0x50>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d7c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002d80:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002d82:	ef85                	bnez	a5,80002dba <kerneltrap+0x60>
  if((which_dev = devintr()) == 0){
    80002d84:	00000097          	auipc	ra,0x0
    80002d88:	e36080e7          	jalr	-458(ra) # 80002bba <devintr>
    80002d8c:	cd1d                	beqz	a0,80002dca <kerneltrap+0x70>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d8e:	4789                	li	a5,2
    80002d90:	06f50a63          	beq	a0,a5,80002e04 <kerneltrap+0xaa>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d94:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d98:	10049073          	csrw	sstatus,s1
}
    80002d9c:	70a2                	ld	ra,40(sp)
    80002d9e:	7402                	ld	s0,32(sp)
    80002da0:	64e2                	ld	s1,24(sp)
    80002da2:	6942                	ld	s2,16(sp)
    80002da4:	69a2                	ld	s3,8(sp)
    80002da6:	6145                	addi	sp,sp,48
    80002da8:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002daa:	00005517          	auipc	a0,0x5
    80002dae:	59e50513          	addi	a0,a0,1438 # 80008348 <etext+0x348>
    80002db2:	ffffd097          	auipc	ra,0xffffd
    80002db6:	7a4080e7          	jalr	1956(ra) # 80000556 <panic>
    panic("kerneltrap: interrupts enabled");
    80002dba:	00005517          	auipc	a0,0x5
    80002dbe:	5b650513          	addi	a0,a0,1462 # 80008370 <etext+0x370>
    80002dc2:	ffffd097          	auipc	ra,0xffffd
    80002dc6:	794080e7          	jalr	1940(ra) # 80000556 <panic>
    printf("scause %p\n", scause);
    80002dca:	85ce                	mv	a1,s3
    80002dcc:	00005517          	auipc	a0,0x5
    80002dd0:	5c450513          	addi	a0,a0,1476 # 80008390 <etext+0x390>
    80002dd4:	ffffd097          	auipc	ra,0xffffd
    80002dd8:	7cc080e7          	jalr	1996(ra) # 800005a0 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ddc:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002de0:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002de4:	00005517          	auipc	a0,0x5
    80002de8:	5bc50513          	addi	a0,a0,1468 # 800083a0 <etext+0x3a0>
    80002dec:	ffffd097          	auipc	ra,0xffffd
    80002df0:	7b4080e7          	jalr	1972(ra) # 800005a0 <printf>
    panic("kerneltrap");
    80002df4:	00005517          	auipc	a0,0x5
    80002df8:	5c450513          	addi	a0,a0,1476 # 800083b8 <etext+0x3b8>
    80002dfc:	ffffd097          	auipc	ra,0xffffd
    80002e00:	75a080e7          	jalr	1882(ra) # 80000556 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002e04:	fffff097          	auipc	ra,0xfffff
    80002e08:	c82080e7          	jalr	-894(ra) # 80001a86 <myproc>
    80002e0c:	d541                	beqz	a0,80002d94 <kerneltrap+0x3a>
    80002e0e:	fffff097          	auipc	ra,0xfffff
    80002e12:	c78080e7          	jalr	-904(ra) # 80001a86 <myproc>
    80002e16:	4d18                	lw	a4,24(a0)
    80002e18:	4791                	li	a5,4
    80002e1a:	f6f71de3          	bne	a4,a5,80002d94 <kerneltrap+0x3a>
    yield();
    80002e1e:	fffff097          	auipc	ra,0xfffff
    80002e22:	43a080e7          	jalr	1082(ra) # 80002258 <yield>
    80002e26:	b7bd                	j	80002d94 <kerneltrap+0x3a>

0000000080002e28 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002e28:	1101                	addi	sp,sp,-32
    80002e2a:	ec06                	sd	ra,24(sp)
    80002e2c:	e822                	sd	s0,16(sp)
    80002e2e:	e426                	sd	s1,8(sp)
    80002e30:	1000                	addi	s0,sp,32
    80002e32:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002e34:	fffff097          	auipc	ra,0xfffff
    80002e38:	c52080e7          	jalr	-942(ra) # 80001a86 <myproc>
  switch (n) {
    80002e3c:	4795                	li	a5,5
    80002e3e:	0497e163          	bltu	a5,s1,80002e80 <argraw+0x58>
    80002e42:	048a                	slli	s1,s1,0x2
    80002e44:	00006717          	auipc	a4,0x6
    80002e48:	9f470713          	addi	a4,a4,-1548 # 80008838 <states.0+0x30>
    80002e4c:	94ba                	add	s1,s1,a4
    80002e4e:	409c                	lw	a5,0(s1)
    80002e50:	97ba                	add	a5,a5,a4
    80002e52:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002e54:	6d3c                	ld	a5,88(a0)
    80002e56:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002e58:	60e2                	ld	ra,24(sp)
    80002e5a:	6442                	ld	s0,16(sp)
    80002e5c:	64a2                	ld	s1,8(sp)
    80002e5e:	6105                	addi	sp,sp,32
    80002e60:	8082                	ret
    return p->trapframe->a1;
    80002e62:	6d3c                	ld	a5,88(a0)
    80002e64:	7fa8                	ld	a0,120(a5)
    80002e66:	bfcd                	j	80002e58 <argraw+0x30>
    return p->trapframe->a2;
    80002e68:	6d3c                	ld	a5,88(a0)
    80002e6a:	63c8                	ld	a0,128(a5)
    80002e6c:	b7f5                	j	80002e58 <argraw+0x30>
    return p->trapframe->a3;
    80002e6e:	6d3c                	ld	a5,88(a0)
    80002e70:	67c8                	ld	a0,136(a5)
    80002e72:	b7dd                	j	80002e58 <argraw+0x30>
    return p->trapframe->a4;
    80002e74:	6d3c                	ld	a5,88(a0)
    80002e76:	6bc8                	ld	a0,144(a5)
    80002e78:	b7c5                	j	80002e58 <argraw+0x30>
    return p->trapframe->a5;
    80002e7a:	6d3c                	ld	a5,88(a0)
    80002e7c:	6fc8                	ld	a0,152(a5)
    80002e7e:	bfe9                	j	80002e58 <argraw+0x30>
  panic("argraw");
    80002e80:	00005517          	auipc	a0,0x5
    80002e84:	54850513          	addi	a0,a0,1352 # 800083c8 <etext+0x3c8>
    80002e88:	ffffd097          	auipc	ra,0xffffd
    80002e8c:	6ce080e7          	jalr	1742(ra) # 80000556 <panic>

0000000080002e90 <fetchaddr>:
{
    80002e90:	1101                	addi	sp,sp,-32
    80002e92:	ec06                	sd	ra,24(sp)
    80002e94:	e822                	sd	s0,16(sp)
    80002e96:	e426                	sd	s1,8(sp)
    80002e98:	e04a                	sd	s2,0(sp)
    80002e9a:	1000                	addi	s0,sp,32
    80002e9c:	84aa                	mv	s1,a0
    80002e9e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002ea0:	fffff097          	auipc	ra,0xfffff
    80002ea4:	be6080e7          	jalr	-1050(ra) # 80001a86 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002ea8:	653c                	ld	a5,72(a0)
    80002eaa:	02f4f863          	bgeu	s1,a5,80002eda <fetchaddr+0x4a>
    80002eae:	00848713          	addi	a4,s1,8
    80002eb2:	02e7e663          	bltu	a5,a4,80002ede <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002eb6:	46a1                	li	a3,8
    80002eb8:	8626                	mv	a2,s1
    80002eba:	85ca                	mv	a1,s2
    80002ebc:	6928                	ld	a0,80(a0)
    80002ebe:	fffff097          	auipc	ra,0xfffff
    80002ec2:	8d8080e7          	jalr	-1832(ra) # 80001796 <copyin>
    80002ec6:	00a03533          	snez	a0,a0
    80002eca:	40a0053b          	negw	a0,a0
}
    80002ece:	60e2                	ld	ra,24(sp)
    80002ed0:	6442                	ld	s0,16(sp)
    80002ed2:	64a2                	ld	s1,8(sp)
    80002ed4:	6902                	ld	s2,0(sp)
    80002ed6:	6105                	addi	sp,sp,32
    80002ed8:	8082                	ret
    return -1;
    80002eda:	557d                	li	a0,-1
    80002edc:	bfcd                	j	80002ece <fetchaddr+0x3e>
    80002ede:	557d                	li	a0,-1
    80002ee0:	b7fd                	j	80002ece <fetchaddr+0x3e>

0000000080002ee2 <fetchstr>:
{
    80002ee2:	7179                	addi	sp,sp,-48
    80002ee4:	f406                	sd	ra,40(sp)
    80002ee6:	f022                	sd	s0,32(sp)
    80002ee8:	ec26                	sd	s1,24(sp)
    80002eea:	e84a                	sd	s2,16(sp)
    80002eec:	e44e                	sd	s3,8(sp)
    80002eee:	1800                	addi	s0,sp,48
    80002ef0:	89aa                	mv	s3,a0
    80002ef2:	84ae                	mv	s1,a1
    80002ef4:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002ef6:	fffff097          	auipc	ra,0xfffff
    80002efa:	b90080e7          	jalr	-1136(ra) # 80001a86 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002efe:	86ca                	mv	a3,s2
    80002f00:	864e                	mv	a2,s3
    80002f02:	85a6                	mv	a1,s1
    80002f04:	6928                	ld	a0,80(a0)
    80002f06:	fffff097          	auipc	ra,0xfffff
    80002f0a:	91e080e7          	jalr	-1762(ra) # 80001824 <copyinstr>
  if(err < 0)
    80002f0e:	00054763          	bltz	a0,80002f1c <fetchstr+0x3a>
  return strlen(buf);
    80002f12:	8526                	mv	a0,s1
    80002f14:	ffffe097          	auipc	ra,0xffffe
    80002f18:	fc6080e7          	jalr	-58(ra) # 80000eda <strlen>
}
    80002f1c:	70a2                	ld	ra,40(sp)
    80002f1e:	7402                	ld	s0,32(sp)
    80002f20:	64e2                	ld	s1,24(sp)
    80002f22:	6942                	ld	s2,16(sp)
    80002f24:	69a2                	ld	s3,8(sp)
    80002f26:	6145                	addi	sp,sp,48
    80002f28:	8082                	ret

0000000080002f2a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002f2a:	1101                	addi	sp,sp,-32
    80002f2c:	ec06                	sd	ra,24(sp)
    80002f2e:	e822                	sd	s0,16(sp)
    80002f30:	e426                	sd	s1,8(sp)
    80002f32:	1000                	addi	s0,sp,32
    80002f34:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f36:	00000097          	auipc	ra,0x0
    80002f3a:	ef2080e7          	jalr	-270(ra) # 80002e28 <argraw>
    80002f3e:	c088                	sw	a0,0(s1)
  return 0;
}
    80002f40:	4501                	li	a0,0
    80002f42:	60e2                	ld	ra,24(sp)
    80002f44:	6442                	ld	s0,16(sp)
    80002f46:	64a2                	ld	s1,8(sp)
    80002f48:	6105                	addi	sp,sp,32
    80002f4a:	8082                	ret

0000000080002f4c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002f4c:	1101                	addi	sp,sp,-32
    80002f4e:	ec06                	sd	ra,24(sp)
    80002f50:	e822                	sd	s0,16(sp)
    80002f52:	e426                	sd	s1,8(sp)
    80002f54:	1000                	addi	s0,sp,32
    80002f56:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f58:	00000097          	auipc	ra,0x0
    80002f5c:	ed0080e7          	jalr	-304(ra) # 80002e28 <argraw>
    80002f60:	e088                	sd	a0,0(s1)
  return 0;
}
    80002f62:	4501                	li	a0,0
    80002f64:	60e2                	ld	ra,24(sp)
    80002f66:	6442                	ld	s0,16(sp)
    80002f68:	64a2                	ld	s1,8(sp)
    80002f6a:	6105                	addi	sp,sp,32
    80002f6c:	8082                	ret

0000000080002f6e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002f6e:	1101                	addi	sp,sp,-32
    80002f70:	ec06                	sd	ra,24(sp)
    80002f72:	e822                	sd	s0,16(sp)
    80002f74:	e426                	sd	s1,8(sp)
    80002f76:	e04a                	sd	s2,0(sp)
    80002f78:	1000                	addi	s0,sp,32
    80002f7a:	892e                	mv	s2,a1
    80002f7c:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002f7e:	00000097          	auipc	ra,0x0
    80002f82:	eaa080e7          	jalr	-342(ra) # 80002e28 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002f86:	8626                	mv	a2,s1
    80002f88:	85ca                	mv	a1,s2
    80002f8a:	00000097          	auipc	ra,0x0
    80002f8e:	f58080e7          	jalr	-168(ra) # 80002ee2 <fetchstr>
}
    80002f92:	60e2                	ld	ra,24(sp)
    80002f94:	6442                	ld	s0,16(sp)
    80002f96:	64a2                	ld	s1,8(sp)
    80002f98:	6902                	ld	s2,0(sp)
    80002f9a:	6105                	addi	sp,sp,32
    80002f9c:	8082                	ret

0000000080002f9e <syscall>:
[SYS_setpriority] 2,
};

void
syscall(void)
{
    80002f9e:	715d                	addi	sp,sp,-80
    80002fa0:	e486                	sd	ra,72(sp)
    80002fa2:	e0a2                	sd	s0,64(sp)
    80002fa4:	fc26                	sd	s1,56(sp)
    80002fa6:	f84a                	sd	s2,48(sp)
    80002fa8:	f44e                	sd	s3,40(sp)
    80002faa:	f052                	sd	s4,32(sp)
    80002fac:	ec56                	sd	s5,24(sp)
    80002fae:	e85a                	sd	s6,16(sp)
    80002fb0:	e45e                	sd	s7,8(sp)
    80002fb2:	e062                	sd	s8,0(sp)
    80002fb4:	0880                	addi	s0,sp,80
  int num, num_args;
  struct proc *p = myproc();
    80002fb6:	fffff097          	auipc	ra,0xfffff
    80002fba:	ad0080e7          	jalr	-1328(ra) # 80001a86 <myproc>
    80002fbe:	8a2a                	mv	s4,a0

  num = p->trapframe->a7;
    80002fc0:	6d3c                	ld	a5,88(a0)
    80002fc2:	0a87ba83          	ld	s5,168(a5)
    80002fc6:	000a8b1b          	sext.w	s6,s5
  num_args = syscall_num[num];
    80002fca:	002b1713          	slli	a4,s6,0x2
    80002fce:	00006797          	auipc	a5,0x6
    80002fd2:	88278793          	addi	a5,a5,-1918 # 80008850 <syscall_num>
    80002fd6:	97ba                	add	a5,a5,a4
    80002fd8:	0007a983          	lw	s3,0(a5)
  
  int arr[num_args];
    80002fdc:	00299b93          	slli	s7,s3,0x2
    80002fe0:	00fb8793          	addi	a5,s7,15
    80002fe4:	9bc1                	andi	a5,a5,-16
    80002fe6:	40f10133          	sub	sp,sp,a5
    80002fea:	8c0a                	mv	s8,sp
  for(int i = 0; i < num_args ; i++){
    80002fec:	01305f63          	blez	s3,8000300a <syscall+0x6c>
    80002ff0:	890a                	mv	s2,sp
    80002ff2:	4481                	li	s1,0
    arr[i] = argraw(i);
    80002ff4:	8526                	mv	a0,s1
    80002ff6:	00000097          	auipc	ra,0x0
    80002ffa:	e32080e7          	jalr	-462(ra) # 80002e28 <argraw>
    80002ffe:	00a92023          	sw	a0,0(s2)
  for(int i = 0; i < num_args ; i++){
    80003002:	2485                	addiw	s1,s1,1
    80003004:	0911                	addi	s2,s2,4
    80003006:	fe9997e3          	bne	s3,s1,80002ff4 <syscall+0x56>
  }

  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000300a:	3afd                	addiw	s5,s5,-1
    8000300c:	47dd                	li	a5,23
    8000300e:	0b57e763          	bltu	a5,s5,800030bc <syscall+0x11e>
    80003012:	003b1713          	slli	a4,s6,0x3
    80003016:	00006797          	auipc	a5,0x6
    8000301a:	83a78793          	addi	a5,a5,-1990 # 80008850 <syscall_num>
    8000301e:	97ba                	add	a5,a5,a4
    80003020:	77bc                	ld	a5,104(a5)
    80003022:	cfc9                	beqz	a5,800030bc <syscall+0x11e>
    p->trapframe->a0 = syscalls[num]();
    80003024:	058a3483          	ld	s1,88(s4)
    80003028:	9782                	jalr	a5
    8000302a:	f8a8                	sd	a0,112(s1)
    if((p -> mask >> num) & 1)
    8000302c:	168a2783          	lw	a5,360(s4)
    80003030:	4167d7bb          	sraw	a5,a5,s6
    80003034:	8b85                	andi	a5,a5,1
    80003036:	c7c5                	beqz	a5,800030de <syscall+0x140>
    {
      printf("%d: syscall %s (", p -> pid, syscall_names[num]);
    80003038:	0b0e                	slli	s6,s6,0x3
    8000303a:	00006797          	auipc	a5,0x6
    8000303e:	81678793          	addi	a5,a5,-2026 # 80008850 <syscall_num>
    80003042:	97da                	add	a5,a5,s6
    80003044:	1307b603          	ld	a2,304(a5)
    80003048:	030a2583          	lw	a1,48(s4)
    8000304c:	00005517          	auipc	a0,0x5
    80003050:	38450513          	addi	a0,a0,900 # 800083d0 <etext+0x3d0>
    80003054:	ffffd097          	auipc	ra,0xffffd
    80003058:	54c080e7          	jalr	1356(ra) # 800005a0 <printf>

      for(int i = 0; i < syscall_num[num]; i++)
    8000305c:	03305163          	blez	s3,8000307e <syscall+0xe0>
    80003060:	84e2                	mv	s1,s8
    80003062:	9be2                	add	s7,s7,s8
      {
        printf("%d ", arr[i]);
    80003064:	00005997          	auipc	s3,0x5
    80003068:	38498993          	addi	s3,s3,900 # 800083e8 <etext+0x3e8>
    8000306c:	408c                	lw	a1,0(s1)
    8000306e:	854e                	mv	a0,s3
    80003070:	ffffd097          	auipc	ra,0xffffd
    80003074:	530080e7          	jalr	1328(ra) # 800005a0 <printf>
      for(int i = 0; i < syscall_num[num]; i++)
    80003078:	0491                	addi	s1,s1,4
    8000307a:	ff7499e3          	bne	s1,s7,8000306c <syscall+0xce>
      }

      printf("\b");
    8000307e:	00005517          	auipc	a0,0x5
    80003082:	37250513          	addi	a0,a0,882 # 800083f0 <etext+0x3f0>
    80003086:	ffffd097          	auipc	ra,0xffffd
    8000308a:	51a080e7          	jalr	1306(ra) # 800005a0 <printf>
      printf(") -> %d", argraw(0));  
    8000308e:	4501                	li	a0,0
    80003090:	00000097          	auipc	ra,0x0
    80003094:	d98080e7          	jalr	-616(ra) # 80002e28 <argraw>
    80003098:	85aa                	mv	a1,a0
    8000309a:	00005517          	auipc	a0,0x5
    8000309e:	35e50513          	addi	a0,a0,862 # 800083f8 <etext+0x3f8>
    800030a2:	ffffd097          	auipc	ra,0xffffd
    800030a6:	4fe080e7          	jalr	1278(ra) # 800005a0 <printf>
      printf("\n");
    800030aa:	00005517          	auipc	a0,0x5
    800030ae:	f6650513          	addi	a0,a0,-154 # 80008010 <etext+0x10>
    800030b2:	ffffd097          	auipc	ra,0xffffd
    800030b6:	4ee080e7          	jalr	1262(ra) # 800005a0 <printf>
    800030ba:	a015                	j	800030de <syscall+0x140>
    }
  } else {
    printf("%d %s: unknown sys call %d\n",p->pid, p->name, num);
    800030bc:	86da                	mv	a3,s6
    800030be:	158a0613          	addi	a2,s4,344
    800030c2:	030a2583          	lw	a1,48(s4)
    800030c6:	00005517          	auipc	a0,0x5
    800030ca:	33a50513          	addi	a0,a0,826 # 80008400 <etext+0x400>
    800030ce:	ffffd097          	auipc	ra,0xffffd
    800030d2:	4d2080e7          	jalr	1234(ra) # 800005a0 <printf>
    p->trapframe->a0 = -1;
    800030d6:	058a3783          	ld	a5,88(s4)
    800030da:	577d                	li	a4,-1
    800030dc:	fbb8                	sd	a4,112(a5)
  }
}
    800030de:	fb040113          	addi	sp,s0,-80
    800030e2:	60a6                	ld	ra,72(sp)
    800030e4:	6406                	ld	s0,64(sp)
    800030e6:	74e2                	ld	s1,56(sp)
    800030e8:	7942                	ld	s2,48(sp)
    800030ea:	79a2                	ld	s3,40(sp)
    800030ec:	7a02                	ld	s4,32(sp)
    800030ee:	6ae2                	ld	s5,24(sp)
    800030f0:	6b42                	ld	s6,16(sp)
    800030f2:	6ba2                	ld	s7,8(sp)
    800030f4:	6c02                	ld	s8,0(sp)
    800030f6:	6161                	addi	sp,sp,80
    800030f8:	8082                	ret

00000000800030fa <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800030fa:	1101                	addi	sp,sp,-32
    800030fc:	ec06                	sd	ra,24(sp)
    800030fe:	e822                	sd	s0,16(sp)
    80003100:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003102:	fec40593          	addi	a1,s0,-20
    80003106:	4501                	li	a0,0
    80003108:	00000097          	auipc	ra,0x0
    8000310c:	e22080e7          	jalr	-478(ra) # 80002f2a <argint>
    return -1;
    80003110:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003112:	00054963          	bltz	a0,80003124 <sys_exit+0x2a>
  exit(n);
    80003116:	fec42503          	lw	a0,-20(s0)
    8000311a:	fffff097          	auipc	ra,0xfffff
    8000311e:	3d0080e7          	jalr	976(ra) # 800024ea <exit>
  return 0;  // not reached
    80003122:	4781                	li	a5,0
}
    80003124:	853e                	mv	a0,a5
    80003126:	60e2                	ld	ra,24(sp)
    80003128:	6442                	ld	s0,16(sp)
    8000312a:	6105                	addi	sp,sp,32
    8000312c:	8082                	ret

000000008000312e <sys_getpid>:

uint64
sys_getpid(void)
{
    8000312e:	1141                	addi	sp,sp,-16
    80003130:	e406                	sd	ra,8(sp)
    80003132:	e022                	sd	s0,0(sp)
    80003134:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003136:	fffff097          	auipc	ra,0xfffff
    8000313a:	950080e7          	jalr	-1712(ra) # 80001a86 <myproc>
}
    8000313e:	5908                	lw	a0,48(a0)
    80003140:	60a2                	ld	ra,8(sp)
    80003142:	6402                	ld	s0,0(sp)
    80003144:	0141                	addi	sp,sp,16
    80003146:	8082                	ret

0000000080003148 <sys_fork>:

uint64
sys_fork(void)
{
    80003148:	1141                	addi	sp,sp,-16
    8000314a:	e406                	sd	ra,8(sp)
    8000314c:	e022                	sd	s0,0(sp)
    8000314e:	0800                	addi	s0,sp,16
  return fork();
    80003150:	fffff097          	auipc	ra,0xfffff
    80003154:	d36080e7          	jalr	-714(ra) # 80001e86 <fork>
}
    80003158:	60a2                	ld	ra,8(sp)
    8000315a:	6402                	ld	s0,0(sp)
    8000315c:	0141                	addi	sp,sp,16
    8000315e:	8082                	ret

0000000080003160 <sys_wait>:

uint64
sys_wait(void)
{
    80003160:	1101                	addi	sp,sp,-32
    80003162:	ec06                	sd	ra,24(sp)
    80003164:	e822                	sd	s0,16(sp)
    80003166:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003168:	fe840593          	addi	a1,s0,-24
    8000316c:	4501                	li	a0,0
    8000316e:	00000097          	auipc	ra,0x0
    80003172:	dde080e7          	jalr	-546(ra) # 80002f4c <argaddr>
    80003176:	87aa                	mv	a5,a0
    return -1;
    80003178:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    8000317a:	0007c863          	bltz	a5,8000318a <sys_wait+0x2a>
  return wait(p);
    8000317e:	fe843503          	ld	a0,-24(s0)
    80003182:	fffff097          	auipc	ra,0xfffff
    80003186:	176080e7          	jalr	374(ra) # 800022f8 <wait>
}
    8000318a:	60e2                	ld	ra,24(sp)
    8000318c:	6442                	ld	s0,16(sp)
    8000318e:	6105                	addi	sp,sp,32
    80003190:	8082                	ret

0000000080003192 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003192:	7179                	addi	sp,sp,-48
    80003194:	f406                	sd	ra,40(sp)
    80003196:	f022                	sd	s0,32(sp)
    80003198:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    8000319a:	fdc40593          	addi	a1,s0,-36
    8000319e:	4501                	li	a0,0
    800031a0:	00000097          	auipc	ra,0x0
    800031a4:	d8a080e7          	jalr	-630(ra) # 80002f2a <argint>
    return -1;
    800031a8:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800031aa:	02054363          	bltz	a0,800031d0 <sys_sbrk+0x3e>
    800031ae:	ec26                	sd	s1,24(sp)
  addr = myproc()->sz;
    800031b0:	fffff097          	auipc	ra,0xfffff
    800031b4:	8d6080e7          	jalr	-1834(ra) # 80001a86 <myproc>
    800031b8:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    800031ba:	fdc42503          	lw	a0,-36(s0)
    800031be:	fffff097          	auipc	ra,0xfffff
    800031c2:	c50080e7          	jalr	-944(ra) # 80001e0e <growproc>
    800031c6:	00054a63          	bltz	a0,800031da <sys_sbrk+0x48>
    return -1;
  return addr;
    800031ca:	0004879b          	sext.w	a5,s1
    800031ce:	64e2                	ld	s1,24(sp)
}
    800031d0:	853e                	mv	a0,a5
    800031d2:	70a2                	ld	ra,40(sp)
    800031d4:	7402                	ld	s0,32(sp)
    800031d6:	6145                	addi	sp,sp,48
    800031d8:	8082                	ret
    return -1;
    800031da:	57fd                	li	a5,-1
    800031dc:	64e2                	ld	s1,24(sp)
    800031de:	bfcd                	j	800031d0 <sys_sbrk+0x3e>

00000000800031e0 <sys_sleep>:

uint64
sys_sleep(void)
{
    800031e0:	7139                	addi	sp,sp,-64
    800031e2:	fc06                	sd	ra,56(sp)
    800031e4:	f822                	sd	s0,48(sp)
    800031e6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    800031e8:	fcc40593          	addi	a1,s0,-52
    800031ec:	4501                	li	a0,0
    800031ee:	00000097          	auipc	ra,0x0
    800031f2:	d3c080e7          	jalr	-708(ra) # 80002f2a <argint>
    return -1;
    800031f6:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800031f8:	06054b63          	bltz	a0,8000326e <sys_sleep+0x8e>
  acquire(&tickslock);
    800031fc:	00018517          	auipc	a0,0x18
    80003200:	6d450513          	addi	a0,a0,1748 # 8001b8d0 <tickslock>
    80003204:	ffffe097          	auipc	ra,0xffffe
    80003208:	a50080e7          	jalr	-1456(ra) # 80000c54 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    8000320c:	fcc42783          	lw	a5,-52(s0)
    80003210:	c7b1                	beqz	a5,8000325c <sys_sleep+0x7c>
    80003212:	f426                	sd	s1,40(sp)
    80003214:	f04a                	sd	s2,32(sp)
    80003216:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80003218:	00009997          	auipc	s3,0x9
    8000321c:	e189a983          	lw	s3,-488(s3) # 8000c030 <ticks>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003220:	00018917          	auipc	s2,0x18
    80003224:	6b090913          	addi	s2,s2,1712 # 8001b8d0 <tickslock>
    80003228:	00009497          	auipc	s1,0x9
    8000322c:	e0848493          	addi	s1,s1,-504 # 8000c030 <ticks>
    if(myproc()->killed){
    80003230:	fffff097          	auipc	ra,0xfffff
    80003234:	856080e7          	jalr	-1962(ra) # 80001a86 <myproc>
    80003238:	551c                	lw	a5,40(a0)
    8000323a:	ef9d                	bnez	a5,80003278 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    8000323c:	85ca                	mv	a1,s2
    8000323e:	8526                	mv	a0,s1
    80003240:	fffff097          	auipc	ra,0xfffff
    80003244:	054080e7          	jalr	84(ra) # 80002294 <sleep>
  while(ticks - ticks0 < n){
    80003248:	409c                	lw	a5,0(s1)
    8000324a:	413787bb          	subw	a5,a5,s3
    8000324e:	fcc42703          	lw	a4,-52(s0)
    80003252:	fce7efe3          	bltu	a5,a4,80003230 <sys_sleep+0x50>
    80003256:	74a2                	ld	s1,40(sp)
    80003258:	7902                	ld	s2,32(sp)
    8000325a:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    8000325c:	00018517          	auipc	a0,0x18
    80003260:	67450513          	addi	a0,a0,1652 # 8001b8d0 <tickslock>
    80003264:	ffffe097          	auipc	ra,0xffffe
    80003268:	aa0080e7          	jalr	-1376(ra) # 80000d04 <release>
  return 0;
    8000326c:	4781                	li	a5,0
}
    8000326e:	853e                	mv	a0,a5
    80003270:	70e2                	ld	ra,56(sp)
    80003272:	7442                	ld	s0,48(sp)
    80003274:	6121                	addi	sp,sp,64
    80003276:	8082                	ret
      release(&tickslock);
    80003278:	00018517          	auipc	a0,0x18
    8000327c:	65850513          	addi	a0,a0,1624 # 8001b8d0 <tickslock>
    80003280:	ffffe097          	auipc	ra,0xffffe
    80003284:	a84080e7          	jalr	-1404(ra) # 80000d04 <release>
      return -1;
    80003288:	57fd                	li	a5,-1
    8000328a:	74a2                	ld	s1,40(sp)
    8000328c:	7902                	ld	s2,32(sp)
    8000328e:	69e2                	ld	s3,24(sp)
    80003290:	bff9                	j	8000326e <sys_sleep+0x8e>

0000000080003292 <sys_kill>:

uint64
sys_kill(void)
{
    80003292:	1101                	addi	sp,sp,-32
    80003294:	ec06                	sd	ra,24(sp)
    80003296:	e822                	sd	s0,16(sp)
    80003298:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    8000329a:	fec40593          	addi	a1,s0,-20
    8000329e:	4501                	li	a0,0
    800032a0:	00000097          	auipc	ra,0x0
    800032a4:	c8a080e7          	jalr	-886(ra) # 80002f2a <argint>
    800032a8:	87aa                	mv	a5,a0
    return -1;
    800032aa:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    800032ac:	0007c863          	bltz	a5,800032bc <sys_kill+0x2a>
  return kill(pid);
    800032b0:	fec42503          	lw	a0,-20(s0)
    800032b4:	fffff097          	auipc	ra,0xfffff
    800032b8:	31c080e7          	jalr	796(ra) # 800025d0 <kill>
}
    800032bc:	60e2                	ld	ra,24(sp)
    800032be:	6442                	ld	s0,16(sp)
    800032c0:	6105                	addi	sp,sp,32
    800032c2:	8082                	ret

00000000800032c4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800032c4:	1101                	addi	sp,sp,-32
    800032c6:	ec06                	sd	ra,24(sp)
    800032c8:	e822                	sd	s0,16(sp)
    800032ca:	e426                	sd	s1,8(sp)
    800032cc:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800032ce:	00018517          	auipc	a0,0x18
    800032d2:	60250513          	addi	a0,a0,1538 # 8001b8d0 <tickslock>
    800032d6:	ffffe097          	auipc	ra,0xffffe
    800032da:	97e080e7          	jalr	-1666(ra) # 80000c54 <acquire>
  xticks = ticks;
    800032de:	00009797          	auipc	a5,0x9
    800032e2:	d527a783          	lw	a5,-686(a5) # 8000c030 <ticks>
    800032e6:	84be                	mv	s1,a5
  release(&tickslock);
    800032e8:	00018517          	auipc	a0,0x18
    800032ec:	5e850513          	addi	a0,a0,1512 # 8001b8d0 <tickslock>
    800032f0:	ffffe097          	auipc	ra,0xffffe
    800032f4:	a14080e7          	jalr	-1516(ra) # 80000d04 <release>
  return xticks;
}
    800032f8:	02049513          	slli	a0,s1,0x20
    800032fc:	9101                	srli	a0,a0,0x20
    800032fe:	60e2                	ld	ra,24(sp)
    80003300:	6442                	ld	s0,16(sp)
    80003302:	64a2                	ld	s1,8(sp)
    80003304:	6105                	addi	sp,sp,32
    80003306:	8082                	ret

0000000080003308 <sys_trace>:

uint64
sys_trace()
{
    80003308:	1101                	addi	sp,sp,-32
    8000330a:	ec06                	sd	ra,24(sp)
    8000330c:	e822                	sd	s0,16(sp)
    8000330e:	1000                	addi	s0,sp,32
  int mask;
  int arg_num = 0;

  if(argint(arg_num, &mask) >= 0)
    80003310:	fec40593          	addi	a1,s0,-20
    80003314:	4501                	li	a0,0
    80003316:	00000097          	auipc	ra,0x0
    8000331a:	c14080e7          	jalr	-1004(ra) # 80002f2a <argint>
    myproc() -> mask = mask;
    return 0;
  }
  else
  {
    return -1;
    8000331e:	57fd                	li	a5,-1
  if(argint(arg_num, &mask) >= 0)
    80003320:	00054b63          	bltz	a0,80003336 <sys_trace+0x2e>
    myproc() -> mask = mask;
    80003324:	ffffe097          	auipc	ra,0xffffe
    80003328:	762080e7          	jalr	1890(ra) # 80001a86 <myproc>
    8000332c:	fec42783          	lw	a5,-20(s0)
    80003330:	16f52423          	sw	a5,360(a0)
    return 0;
    80003334:	4781                	li	a5,0
  }  
}
    80003336:	853e                	mv	a0,a5
    80003338:	60e2                	ld	ra,24(sp)
    8000333a:	6442                	ld	s0,16(sp)
    8000333c:	6105                	addi	sp,sp,32
    8000333e:	8082                	ret

0000000080003340 <sys_setpriority>:

uint64
sys_setpriority()
{
    80003340:	1101                	addi	sp,sp,-32
    80003342:	ec06                	sd	ra,24(sp)
    80003344:	e822                	sd	s0,16(sp)
    80003346:	1000                	addi	s0,sp,32
  int pid, priority;
  int arg_num[2] = {0, 1};

  if(argint(arg_num[0], &priority) < 0)
    80003348:	fe840593          	addi	a1,s0,-24
    8000334c:	4501                	li	a0,0
    8000334e:	00000097          	auipc	ra,0x0
    80003352:	bdc080e7          	jalr	-1060(ra) # 80002f2a <argint>
  {
    return -1;
    80003356:	57fd                	li	a5,-1
  if(argint(arg_num[0], &priority) < 0)
    80003358:	02054563          	bltz	a0,80003382 <sys_setpriority+0x42>
  }
  if(argint(arg_num[1], &pid) < 0)
    8000335c:	fec40593          	addi	a1,s0,-20
    80003360:	4505                	li	a0,1
    80003362:	00000097          	auipc	ra,0x0
    80003366:	bc8080e7          	jalr	-1080(ra) # 80002f2a <argint>
  {
    return -1;
    8000336a:	57fd                	li	a5,-1
  if(argint(arg_num[1], &pid) < 0)
    8000336c:	00054b63          	bltz	a0,80003382 <sys_setpriority+0x42>
  }
   
  return setpriority(priority, pid);
    80003370:	fec42583          	lw	a1,-20(s0)
    80003374:	fe842503          	lw	a0,-24(s0)
    80003378:	fffff097          	auipc	ra,0xfffff
    8000337c:	4d2080e7          	jalr	1234(ra) # 8000284a <setpriority>
    80003380:	87aa                	mv	a5,a0
}
    80003382:	853e                	mv	a0,a5
    80003384:	60e2                	ld	ra,24(sp)
    80003386:	6442                	ld	s0,16(sp)
    80003388:	6105                	addi	sp,sp,32
    8000338a:	8082                	ret

000000008000338c <sys_waitx>:

uint64
sys_waitx(void)
{
    8000338c:	7139                	addi	sp,sp,-64
    8000338e:	fc06                	sd	ra,56(sp)
    80003390:	f822                	sd	s0,48(sp)
    80003392:	f426                	sd	s1,40(sp)
    80003394:	0080                	addi	s0,sp,64
  uint64 p, rt, wt;
  int rtime, wtime;

  // argumentos desde el usuario
  argaddr(0, &p);   // int *status
    80003396:	fd840593          	addi	a1,s0,-40
    8000339a:	4501                	li	a0,0
    8000339c:	00000097          	auipc	ra,0x0
    800033a0:	bb0080e7          	jalr	-1104(ra) # 80002f4c <argaddr>
  argaddr(1, &rt);  // int *rtime
    800033a4:	fd040593          	addi	a1,s0,-48
    800033a8:	4505                	li	a0,1
    800033aa:	00000097          	auipc	ra,0x0
    800033ae:	ba2080e7          	jalr	-1118(ra) # 80002f4c <argaddr>
  argaddr(2, &wt);  // int *wtime
    800033b2:	fc840593          	addi	a1,s0,-56
    800033b6:	4509                	li	a0,2
    800033b8:	00000097          	auipc	ra,0x0
    800033bc:	b94080e7          	jalr	-1132(ra) # 80002f4c <argaddr>

  int pid = waitx(p, &rtime, &wtime);
    800033c0:	fc040613          	addi	a2,s0,-64
    800033c4:	fc440593          	addi	a1,s0,-60
    800033c8:	fd843503          	ld	a0,-40(s0)
    800033cc:	fffff097          	auipc	ra,0xfffff
    800033d0:	502080e7          	jalr	1282(ra) # 800028ce <waitx>
    800033d4:	84aa                	mv	s1,a0

  if (pid < 0)
    return -1;
    800033d6:	557d                	li	a0,-1
  if (pid < 0)
    800033d8:	0404c563          	bltz	s1,80003422 <sys_waitx+0x96>

  // copiar rtime al espacio de usuario
  if (copyout(myproc()->pagetable, rt, (char*)&rtime, sizeof(rtime)) < 0)
    800033dc:	ffffe097          	auipc	ra,0xffffe
    800033e0:	6aa080e7          	jalr	1706(ra) # 80001a86 <myproc>
    800033e4:	4691                	li	a3,4
    800033e6:	fc440613          	addi	a2,s0,-60
    800033ea:	fd043583          	ld	a1,-48(s0)
    800033ee:	6928                	ld	a0,80(a0)
    800033f0:	ffffe097          	auipc	ra,0xffffe
    800033f4:	31a080e7          	jalr	794(ra) # 8000170a <copyout>
    800033f8:	87aa                	mv	a5,a0
    return -1;
    800033fa:	557d                	li	a0,-1
  if (copyout(myproc()->pagetable, rt, (char*)&rtime, sizeof(rtime)) < 0)
    800033fc:	0207c363          	bltz	a5,80003422 <sys_waitx+0x96>

  // copiar wtime al espacio de usuario
  if (copyout(myproc()->pagetable, wt, (char*)&wtime, sizeof(wtime)) < 0)
    80003400:	ffffe097          	auipc	ra,0xffffe
    80003404:	686080e7          	jalr	1670(ra) # 80001a86 <myproc>
    80003408:	4691                	li	a3,4
    8000340a:	fc040613          	addi	a2,s0,-64
    8000340e:	fc843583          	ld	a1,-56(s0)
    80003412:	6928                	ld	a0,80(a0)
    80003414:	ffffe097          	auipc	ra,0xffffe
    80003418:	2f6080e7          	jalr	758(ra) # 8000170a <copyout>
    8000341c:	00054863          	bltz	a0,8000342c <sys_waitx+0xa0>
    return -1;

  return pid;
    80003420:	8526                	mv	a0,s1
}
    80003422:	70e2                	ld	ra,56(sp)
    80003424:	7442                	ld	s0,48(sp)
    80003426:	74a2                	ld	s1,40(sp)
    80003428:	6121                	addi	sp,sp,64
    8000342a:	8082                	ret
    return -1;
    8000342c:	557d                	li	a0,-1
    8000342e:	bfd5                	j	80003422 <sys_waitx+0x96>

0000000080003430 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003430:	7179                	addi	sp,sp,-48
    80003432:	f406                	sd	ra,40(sp)
    80003434:	f022                	sd	s0,32(sp)
    80003436:	ec26                	sd	s1,24(sp)
    80003438:	e84a                	sd	s2,16(sp)
    8000343a:	e44e                	sd	s3,8(sp)
    8000343c:	e052                	sd	s4,0(sp)
    8000343e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003440:	00005597          	auipc	a1,0x5
    80003444:	0a058593          	addi	a1,a1,160 # 800084e0 <etext+0x4e0>
    80003448:	00018517          	auipc	a0,0x18
    8000344c:	4a050513          	addi	a0,a0,1184 # 8001b8e8 <bcache>
    80003450:	ffffd097          	auipc	ra,0xffffd
    80003454:	76a080e7          	jalr	1898(ra) # 80000bba <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003458:	00020797          	auipc	a5,0x20
    8000345c:	49078793          	addi	a5,a5,1168 # 800238e8 <bcache+0x8000>
    80003460:	00020717          	auipc	a4,0x20
    80003464:	6f070713          	addi	a4,a4,1776 # 80023b50 <bcache+0x8268>
    80003468:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000346c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003470:	00018497          	auipc	s1,0x18
    80003474:	49048493          	addi	s1,s1,1168 # 8001b900 <bcache+0x18>
    b->next = bcache.head.next;
    80003478:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000347a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000347c:	00005a17          	auipc	s4,0x5
    80003480:	06ca0a13          	addi	s4,s4,108 # 800084e8 <etext+0x4e8>
    b->next = bcache.head.next;
    80003484:	2b893783          	ld	a5,696(s2)
    80003488:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000348a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000348e:	85d2                	mv	a1,s4
    80003490:	01048513          	addi	a0,s1,16
    80003494:	00001097          	auipc	ra,0x1
    80003498:	4c2080e7          	jalr	1218(ra) # 80004956 <initsleeplock>
    bcache.head.next->prev = b;
    8000349c:	2b893783          	ld	a5,696(s2)
    800034a0:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800034a2:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800034a6:	45848493          	addi	s1,s1,1112
    800034aa:	fd349de3          	bne	s1,s3,80003484 <binit+0x54>
  }
}
    800034ae:	70a2                	ld	ra,40(sp)
    800034b0:	7402                	ld	s0,32(sp)
    800034b2:	64e2                	ld	s1,24(sp)
    800034b4:	6942                	ld	s2,16(sp)
    800034b6:	69a2                	ld	s3,8(sp)
    800034b8:	6a02                	ld	s4,0(sp)
    800034ba:	6145                	addi	sp,sp,48
    800034bc:	8082                	ret

00000000800034be <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800034be:	7179                	addi	sp,sp,-48
    800034c0:	f406                	sd	ra,40(sp)
    800034c2:	f022                	sd	s0,32(sp)
    800034c4:	ec26                	sd	s1,24(sp)
    800034c6:	e84a                	sd	s2,16(sp)
    800034c8:	e44e                	sd	s3,8(sp)
    800034ca:	1800                	addi	s0,sp,48
    800034cc:	892a                	mv	s2,a0
    800034ce:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800034d0:	00018517          	auipc	a0,0x18
    800034d4:	41850513          	addi	a0,a0,1048 # 8001b8e8 <bcache>
    800034d8:	ffffd097          	auipc	ra,0xffffd
    800034dc:	77c080e7          	jalr	1916(ra) # 80000c54 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800034e0:	00020497          	auipc	s1,0x20
    800034e4:	6c04b483          	ld	s1,1728(s1) # 80023ba0 <bcache+0x82b8>
    800034e8:	00020797          	auipc	a5,0x20
    800034ec:	66878793          	addi	a5,a5,1640 # 80023b50 <bcache+0x8268>
    800034f0:	02f48f63          	beq	s1,a5,8000352e <bread+0x70>
    800034f4:	873e                	mv	a4,a5
    800034f6:	a021                	j	800034fe <bread+0x40>
    800034f8:	68a4                	ld	s1,80(s1)
    800034fa:	02e48a63          	beq	s1,a4,8000352e <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800034fe:	449c                	lw	a5,8(s1)
    80003500:	ff279ce3          	bne	a5,s2,800034f8 <bread+0x3a>
    80003504:	44dc                	lw	a5,12(s1)
    80003506:	ff3799e3          	bne	a5,s3,800034f8 <bread+0x3a>
      b->refcnt++;
    8000350a:	40bc                	lw	a5,64(s1)
    8000350c:	2785                	addiw	a5,a5,1
    8000350e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003510:	00018517          	auipc	a0,0x18
    80003514:	3d850513          	addi	a0,a0,984 # 8001b8e8 <bcache>
    80003518:	ffffd097          	auipc	ra,0xffffd
    8000351c:	7ec080e7          	jalr	2028(ra) # 80000d04 <release>
      acquiresleep(&b->lock);
    80003520:	01048513          	addi	a0,s1,16
    80003524:	00001097          	auipc	ra,0x1
    80003528:	46c080e7          	jalr	1132(ra) # 80004990 <acquiresleep>
      return b;
    8000352c:	a8b9                	j	8000358a <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000352e:	00020497          	auipc	s1,0x20
    80003532:	66a4b483          	ld	s1,1642(s1) # 80023b98 <bcache+0x82b0>
    80003536:	00020797          	auipc	a5,0x20
    8000353a:	61a78793          	addi	a5,a5,1562 # 80023b50 <bcache+0x8268>
    8000353e:	00f48863          	beq	s1,a5,8000354e <bread+0x90>
    80003542:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003544:	40bc                	lw	a5,64(s1)
    80003546:	cf81                	beqz	a5,8000355e <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003548:	64a4                	ld	s1,72(s1)
    8000354a:	fee49de3          	bne	s1,a4,80003544 <bread+0x86>
  panic("bget: no buffers");
    8000354e:	00005517          	auipc	a0,0x5
    80003552:	fa250513          	addi	a0,a0,-94 # 800084f0 <etext+0x4f0>
    80003556:	ffffd097          	auipc	ra,0xffffd
    8000355a:	000080e7          	jalr	ra # 80000556 <panic>
      b->dev = dev;
    8000355e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003562:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003566:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000356a:	4785                	li	a5,1
    8000356c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000356e:	00018517          	auipc	a0,0x18
    80003572:	37a50513          	addi	a0,a0,890 # 8001b8e8 <bcache>
    80003576:	ffffd097          	auipc	ra,0xffffd
    8000357a:	78e080e7          	jalr	1934(ra) # 80000d04 <release>
      acquiresleep(&b->lock);
    8000357e:	01048513          	addi	a0,s1,16
    80003582:	00001097          	auipc	ra,0x1
    80003586:	40e080e7          	jalr	1038(ra) # 80004990 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000358a:	409c                	lw	a5,0(s1)
    8000358c:	cb89                	beqz	a5,8000359e <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000358e:	8526                	mv	a0,s1
    80003590:	70a2                	ld	ra,40(sp)
    80003592:	7402                	ld	s0,32(sp)
    80003594:	64e2                	ld	s1,24(sp)
    80003596:	6942                	ld	s2,16(sp)
    80003598:	69a2                	ld	s3,8(sp)
    8000359a:	6145                	addi	sp,sp,48
    8000359c:	8082                	ret
    virtio_disk_rw(b, 0);
    8000359e:	4581                	li	a1,0
    800035a0:	8526                	mv	a0,s1
    800035a2:	00003097          	auipc	ra,0x3
    800035a6:	02c080e7          	jalr	44(ra) # 800065ce <virtio_disk_rw>
    b->valid = 1;
    800035aa:	4785                	li	a5,1
    800035ac:	c09c                	sw	a5,0(s1)
  return b;
    800035ae:	b7c5                	j	8000358e <bread+0xd0>

00000000800035b0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800035b0:	1101                	addi	sp,sp,-32
    800035b2:	ec06                	sd	ra,24(sp)
    800035b4:	e822                	sd	s0,16(sp)
    800035b6:	e426                	sd	s1,8(sp)
    800035b8:	1000                	addi	s0,sp,32
    800035ba:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800035bc:	0541                	addi	a0,a0,16
    800035be:	00001097          	auipc	ra,0x1
    800035c2:	46c080e7          	jalr	1132(ra) # 80004a2a <holdingsleep>
    800035c6:	cd01                	beqz	a0,800035de <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800035c8:	4585                	li	a1,1
    800035ca:	8526                	mv	a0,s1
    800035cc:	00003097          	auipc	ra,0x3
    800035d0:	002080e7          	jalr	2(ra) # 800065ce <virtio_disk_rw>
}
    800035d4:	60e2                	ld	ra,24(sp)
    800035d6:	6442                	ld	s0,16(sp)
    800035d8:	64a2                	ld	s1,8(sp)
    800035da:	6105                	addi	sp,sp,32
    800035dc:	8082                	ret
    panic("bwrite");
    800035de:	00005517          	auipc	a0,0x5
    800035e2:	f2a50513          	addi	a0,a0,-214 # 80008508 <etext+0x508>
    800035e6:	ffffd097          	auipc	ra,0xffffd
    800035ea:	f70080e7          	jalr	-144(ra) # 80000556 <panic>

00000000800035ee <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800035ee:	1101                	addi	sp,sp,-32
    800035f0:	ec06                	sd	ra,24(sp)
    800035f2:	e822                	sd	s0,16(sp)
    800035f4:	e426                	sd	s1,8(sp)
    800035f6:	e04a                	sd	s2,0(sp)
    800035f8:	1000                	addi	s0,sp,32
    800035fa:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800035fc:	01050913          	addi	s2,a0,16
    80003600:	854a                	mv	a0,s2
    80003602:	00001097          	auipc	ra,0x1
    80003606:	428080e7          	jalr	1064(ra) # 80004a2a <holdingsleep>
    8000360a:	c535                	beqz	a0,80003676 <brelse+0x88>
    panic("brelse");

  releasesleep(&b->lock);
    8000360c:	854a                	mv	a0,s2
    8000360e:	00001097          	auipc	ra,0x1
    80003612:	3d8080e7          	jalr	984(ra) # 800049e6 <releasesleep>

  acquire(&bcache.lock);
    80003616:	00018517          	auipc	a0,0x18
    8000361a:	2d250513          	addi	a0,a0,722 # 8001b8e8 <bcache>
    8000361e:	ffffd097          	auipc	ra,0xffffd
    80003622:	636080e7          	jalr	1590(ra) # 80000c54 <acquire>
  b->refcnt--;
    80003626:	40bc                	lw	a5,64(s1)
    80003628:	37fd                	addiw	a5,a5,-1
    8000362a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000362c:	e79d                	bnez	a5,8000365a <brelse+0x6c>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000362e:	68b8                	ld	a4,80(s1)
    80003630:	64bc                	ld	a5,72(s1)
    80003632:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003634:	68b8                	ld	a4,80(s1)
    80003636:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003638:	00020797          	auipc	a5,0x20
    8000363c:	2b078793          	addi	a5,a5,688 # 800238e8 <bcache+0x8000>
    80003640:	2b87b703          	ld	a4,696(a5)
    80003644:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003646:	00020717          	auipc	a4,0x20
    8000364a:	50a70713          	addi	a4,a4,1290 # 80023b50 <bcache+0x8268>
    8000364e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003650:	2b87b703          	ld	a4,696(a5)
    80003654:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003656:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000365a:	00018517          	auipc	a0,0x18
    8000365e:	28e50513          	addi	a0,a0,654 # 8001b8e8 <bcache>
    80003662:	ffffd097          	auipc	ra,0xffffd
    80003666:	6a2080e7          	jalr	1698(ra) # 80000d04 <release>
}
    8000366a:	60e2                	ld	ra,24(sp)
    8000366c:	6442                	ld	s0,16(sp)
    8000366e:	64a2                	ld	s1,8(sp)
    80003670:	6902                	ld	s2,0(sp)
    80003672:	6105                	addi	sp,sp,32
    80003674:	8082                	ret
    panic("brelse");
    80003676:	00005517          	auipc	a0,0x5
    8000367a:	e9a50513          	addi	a0,a0,-358 # 80008510 <etext+0x510>
    8000367e:	ffffd097          	auipc	ra,0xffffd
    80003682:	ed8080e7          	jalr	-296(ra) # 80000556 <panic>

0000000080003686 <bpin>:

void
bpin(struct buf *b) {
    80003686:	1101                	addi	sp,sp,-32
    80003688:	ec06                	sd	ra,24(sp)
    8000368a:	e822                	sd	s0,16(sp)
    8000368c:	e426                	sd	s1,8(sp)
    8000368e:	1000                	addi	s0,sp,32
    80003690:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003692:	00018517          	auipc	a0,0x18
    80003696:	25650513          	addi	a0,a0,598 # 8001b8e8 <bcache>
    8000369a:	ffffd097          	auipc	ra,0xffffd
    8000369e:	5ba080e7          	jalr	1466(ra) # 80000c54 <acquire>
  b->refcnt++;
    800036a2:	40bc                	lw	a5,64(s1)
    800036a4:	2785                	addiw	a5,a5,1
    800036a6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800036a8:	00018517          	auipc	a0,0x18
    800036ac:	24050513          	addi	a0,a0,576 # 8001b8e8 <bcache>
    800036b0:	ffffd097          	auipc	ra,0xffffd
    800036b4:	654080e7          	jalr	1620(ra) # 80000d04 <release>
}
    800036b8:	60e2                	ld	ra,24(sp)
    800036ba:	6442                	ld	s0,16(sp)
    800036bc:	64a2                	ld	s1,8(sp)
    800036be:	6105                	addi	sp,sp,32
    800036c0:	8082                	ret

00000000800036c2 <bunpin>:

void
bunpin(struct buf *b) {
    800036c2:	1101                	addi	sp,sp,-32
    800036c4:	ec06                	sd	ra,24(sp)
    800036c6:	e822                	sd	s0,16(sp)
    800036c8:	e426                	sd	s1,8(sp)
    800036ca:	1000                	addi	s0,sp,32
    800036cc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800036ce:	00018517          	auipc	a0,0x18
    800036d2:	21a50513          	addi	a0,a0,538 # 8001b8e8 <bcache>
    800036d6:	ffffd097          	auipc	ra,0xffffd
    800036da:	57e080e7          	jalr	1406(ra) # 80000c54 <acquire>
  b->refcnt--;
    800036de:	40bc                	lw	a5,64(s1)
    800036e0:	37fd                	addiw	a5,a5,-1
    800036e2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800036e4:	00018517          	auipc	a0,0x18
    800036e8:	20450513          	addi	a0,a0,516 # 8001b8e8 <bcache>
    800036ec:	ffffd097          	auipc	ra,0xffffd
    800036f0:	618080e7          	jalr	1560(ra) # 80000d04 <release>
}
    800036f4:	60e2                	ld	ra,24(sp)
    800036f6:	6442                	ld	s0,16(sp)
    800036f8:	64a2                	ld	s1,8(sp)
    800036fa:	6105                	addi	sp,sp,32
    800036fc:	8082                	ret

00000000800036fe <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800036fe:	1101                	addi	sp,sp,-32
    80003700:	ec06                	sd	ra,24(sp)
    80003702:	e822                	sd	s0,16(sp)
    80003704:	e426                	sd	s1,8(sp)
    80003706:	e04a                	sd	s2,0(sp)
    80003708:	1000                	addi	s0,sp,32
    8000370a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000370c:	00d5d79b          	srliw	a5,a1,0xd
    80003710:	00021597          	auipc	a1,0x21
    80003714:	8b45a583          	lw	a1,-1868(a1) # 80023fc4 <sb+0x1c>
    80003718:	9dbd                	addw	a1,a1,a5
    8000371a:	00000097          	auipc	ra,0x0
    8000371e:	da4080e7          	jalr	-604(ra) # 800034be <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003722:	0074f713          	andi	a4,s1,7
    80003726:	4785                	li	a5,1
    80003728:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    8000372c:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    8000372e:	90d9                	srli	s1,s1,0x36
    80003730:	00950733          	add	a4,a0,s1
    80003734:	05874703          	lbu	a4,88(a4)
    80003738:	00e7f6b3          	and	a3,a5,a4
    8000373c:	c69d                	beqz	a3,8000376a <bfree+0x6c>
    8000373e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003740:	94aa                	add	s1,s1,a0
    80003742:	fff7c793          	not	a5,a5
    80003746:	8f7d                	and	a4,a4,a5
    80003748:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000374c:	00001097          	auipc	ra,0x1
    80003750:	124080e7          	jalr	292(ra) # 80004870 <log_write>
  brelse(bp);
    80003754:	854a                	mv	a0,s2
    80003756:	00000097          	auipc	ra,0x0
    8000375a:	e98080e7          	jalr	-360(ra) # 800035ee <brelse>
}
    8000375e:	60e2                	ld	ra,24(sp)
    80003760:	6442                	ld	s0,16(sp)
    80003762:	64a2                	ld	s1,8(sp)
    80003764:	6902                	ld	s2,0(sp)
    80003766:	6105                	addi	sp,sp,32
    80003768:	8082                	ret
    panic("freeing free block");
    8000376a:	00005517          	auipc	a0,0x5
    8000376e:	dae50513          	addi	a0,a0,-594 # 80008518 <etext+0x518>
    80003772:	ffffd097          	auipc	ra,0xffffd
    80003776:	de4080e7          	jalr	-540(ra) # 80000556 <panic>

000000008000377a <balloc>:
{
    8000377a:	715d                	addi	sp,sp,-80
    8000377c:	e486                	sd	ra,72(sp)
    8000377e:	e0a2                	sd	s0,64(sp)
    80003780:	fc26                	sd	s1,56(sp)
    80003782:	f84a                	sd	s2,48(sp)
    80003784:	f44e                	sd	s3,40(sp)
    80003786:	f052                	sd	s4,32(sp)
    80003788:	ec56                	sd	s5,24(sp)
    8000378a:	e85a                	sd	s6,16(sp)
    8000378c:	e45e                	sd	s7,8(sp)
    8000378e:	e062                	sd	s8,0(sp)
    80003790:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80003792:	00021797          	auipc	a5,0x21
    80003796:	81a7a783          	lw	a5,-2022(a5) # 80023fac <sb+0x4>
    8000379a:	cfb5                	beqz	a5,80003816 <balloc+0x9c>
    8000379c:	8baa                	mv	s7,a0
    8000379e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800037a0:	00021b17          	auipc	s6,0x21
    800037a4:	808b0b13          	addi	s6,s6,-2040 # 80023fa8 <sb>
      m = 1 << (bi % 8);
    800037a8:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037aa:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800037ac:	6c09                	lui	s8,0x2
    800037ae:	a821                	j	800037c6 <balloc+0x4c>
    brelse(bp);
    800037b0:	854a                	mv	a0,s2
    800037b2:	00000097          	auipc	ra,0x0
    800037b6:	e3c080e7          	jalr	-452(ra) # 800035ee <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800037ba:	015c0abb          	addw	s5,s8,s5
    800037be:	004b2783          	lw	a5,4(s6)
    800037c2:	04fafa63          	bgeu	s5,a5,80003816 <balloc+0x9c>
    bp = bread(dev, BBLOCK(b, sb));
    800037c6:	40dad59b          	sraiw	a1,s5,0xd
    800037ca:	01cb2783          	lw	a5,28(s6)
    800037ce:	9dbd                	addw	a1,a1,a5
    800037d0:	855e                	mv	a0,s7
    800037d2:	00000097          	auipc	ra,0x0
    800037d6:	cec080e7          	jalr	-788(ra) # 800034be <bread>
    800037da:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037dc:	004b2503          	lw	a0,4(s6)
    800037e0:	84d6                	mv	s1,s5
    800037e2:	4701                	li	a4,0
    800037e4:	fca4f6e3          	bgeu	s1,a0,800037b0 <balloc+0x36>
      m = 1 << (bi % 8);
    800037e8:	00777693          	andi	a3,a4,7
    800037ec:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800037f0:	41f7579b          	sraiw	a5,a4,0x1f
    800037f4:	01d7d79b          	srliw	a5,a5,0x1d
    800037f8:	9fb9                	addw	a5,a5,a4
    800037fa:	4037d79b          	sraiw	a5,a5,0x3
    800037fe:	00f90633          	add	a2,s2,a5
    80003802:	05864603          	lbu	a2,88(a2)
    80003806:	00c6f5b3          	and	a1,a3,a2
    8000380a:	cd91                	beqz	a1,80003826 <balloc+0xac>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000380c:	2705                	addiw	a4,a4,1
    8000380e:	2485                	addiw	s1,s1,1
    80003810:	fd471ae3          	bne	a4,s4,800037e4 <balloc+0x6a>
    80003814:	bf71                	j	800037b0 <balloc+0x36>
  panic("balloc: out of blocks");
    80003816:	00005517          	auipc	a0,0x5
    8000381a:	d1a50513          	addi	a0,a0,-742 # 80008530 <etext+0x530>
    8000381e:	ffffd097          	auipc	ra,0xffffd
    80003822:	d38080e7          	jalr	-712(ra) # 80000556 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003826:	97ca                	add	a5,a5,s2
    80003828:	8e55                	or	a2,a2,a3
    8000382a:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000382e:	854a                	mv	a0,s2
    80003830:	00001097          	auipc	ra,0x1
    80003834:	040080e7          	jalr	64(ra) # 80004870 <log_write>
        brelse(bp);
    80003838:	854a                	mv	a0,s2
    8000383a:	00000097          	auipc	ra,0x0
    8000383e:	db4080e7          	jalr	-588(ra) # 800035ee <brelse>
  bp = bread(dev, bno);
    80003842:	85a6                	mv	a1,s1
    80003844:	855e                	mv	a0,s7
    80003846:	00000097          	auipc	ra,0x0
    8000384a:	c78080e7          	jalr	-904(ra) # 800034be <bread>
    8000384e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003850:	40000613          	li	a2,1024
    80003854:	4581                	li	a1,0
    80003856:	05850513          	addi	a0,a0,88
    8000385a:	ffffd097          	auipc	ra,0xffffd
    8000385e:	4f2080e7          	jalr	1266(ra) # 80000d4c <memset>
  log_write(bp);
    80003862:	854a                	mv	a0,s2
    80003864:	00001097          	auipc	ra,0x1
    80003868:	00c080e7          	jalr	12(ra) # 80004870 <log_write>
  brelse(bp);
    8000386c:	854a                	mv	a0,s2
    8000386e:	00000097          	auipc	ra,0x0
    80003872:	d80080e7          	jalr	-640(ra) # 800035ee <brelse>
}
    80003876:	8526                	mv	a0,s1
    80003878:	60a6                	ld	ra,72(sp)
    8000387a:	6406                	ld	s0,64(sp)
    8000387c:	74e2                	ld	s1,56(sp)
    8000387e:	7942                	ld	s2,48(sp)
    80003880:	79a2                	ld	s3,40(sp)
    80003882:	7a02                	ld	s4,32(sp)
    80003884:	6ae2                	ld	s5,24(sp)
    80003886:	6b42                	ld	s6,16(sp)
    80003888:	6ba2                	ld	s7,8(sp)
    8000388a:	6c02                	ld	s8,0(sp)
    8000388c:	6161                	addi	sp,sp,80
    8000388e:	8082                	ret

0000000080003890 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003890:	7179                	addi	sp,sp,-48
    80003892:	f406                	sd	ra,40(sp)
    80003894:	f022                	sd	s0,32(sp)
    80003896:	ec26                	sd	s1,24(sp)
    80003898:	e84a                	sd	s2,16(sp)
    8000389a:	e44e                	sd	s3,8(sp)
    8000389c:	1800                	addi	s0,sp,48
    8000389e:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800038a0:	47ad                	li	a5,11
    800038a2:	04b7fd63          	bgeu	a5,a1,800038fc <bmap+0x6c>
    800038a6:	e052                	sd	s4,0(sp)
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800038a8:	ff45849b          	addiw	s1,a1,-12

  if(bn < NINDIRECT){
    800038ac:	0ff00793          	li	a5,255
    800038b0:	0897ef63          	bltu	a5,s1,8000394e <bmap+0xbe>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800038b4:	08052583          	lw	a1,128(a0)
    800038b8:	c5a5                	beqz	a1,80003920 <bmap+0x90>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800038ba:	00092503          	lw	a0,0(s2)
    800038be:	00000097          	auipc	ra,0x0
    800038c2:	c00080e7          	jalr	-1024(ra) # 800034be <bread>
    800038c6:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800038c8:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800038cc:	02049713          	slli	a4,s1,0x20
    800038d0:	01e75593          	srli	a1,a4,0x1e
    800038d4:	00b784b3          	add	s1,a5,a1
    800038d8:	0004a983          	lw	s3,0(s1)
    800038dc:	04098b63          	beqz	s3,80003932 <bmap+0xa2>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800038e0:	8552                	mv	a0,s4
    800038e2:	00000097          	auipc	ra,0x0
    800038e6:	d0c080e7          	jalr	-756(ra) # 800035ee <brelse>
    return addr;
    800038ea:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800038ec:	854e                	mv	a0,s3
    800038ee:	70a2                	ld	ra,40(sp)
    800038f0:	7402                	ld	s0,32(sp)
    800038f2:	64e2                	ld	s1,24(sp)
    800038f4:	6942                	ld	s2,16(sp)
    800038f6:	69a2                	ld	s3,8(sp)
    800038f8:	6145                	addi	sp,sp,48
    800038fa:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800038fc:	02059793          	slli	a5,a1,0x20
    80003900:	01e7d593          	srli	a1,a5,0x1e
    80003904:	00b504b3          	add	s1,a0,a1
    80003908:	0504a983          	lw	s3,80(s1)
    8000390c:	fe0990e3          	bnez	s3,800038ec <bmap+0x5c>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003910:	4108                	lw	a0,0(a0)
    80003912:	00000097          	auipc	ra,0x0
    80003916:	e68080e7          	jalr	-408(ra) # 8000377a <balloc>
    8000391a:	89aa                	mv	s3,a0
    8000391c:	c8a8                	sw	a0,80(s1)
    8000391e:	b7f9                	j	800038ec <bmap+0x5c>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003920:	4108                	lw	a0,0(a0)
    80003922:	00000097          	auipc	ra,0x0
    80003926:	e58080e7          	jalr	-424(ra) # 8000377a <balloc>
    8000392a:	85aa                	mv	a1,a0
    8000392c:	08a92023          	sw	a0,128(s2)
    80003930:	b769                	j	800038ba <bmap+0x2a>
      a[bn] = addr = balloc(ip->dev);
    80003932:	00092503          	lw	a0,0(s2)
    80003936:	00000097          	auipc	ra,0x0
    8000393a:	e44080e7          	jalr	-444(ra) # 8000377a <balloc>
    8000393e:	89aa                	mv	s3,a0
    80003940:	c088                	sw	a0,0(s1)
      log_write(bp);
    80003942:	8552                	mv	a0,s4
    80003944:	00001097          	auipc	ra,0x1
    80003948:	f2c080e7          	jalr	-212(ra) # 80004870 <log_write>
    8000394c:	bf51                	j	800038e0 <bmap+0x50>
  panic("bmap: out of range");
    8000394e:	00005517          	auipc	a0,0x5
    80003952:	bfa50513          	addi	a0,a0,-1030 # 80008548 <etext+0x548>
    80003956:	ffffd097          	auipc	ra,0xffffd
    8000395a:	c00080e7          	jalr	-1024(ra) # 80000556 <panic>

000000008000395e <iget>:
{
    8000395e:	7179                	addi	sp,sp,-48
    80003960:	f406                	sd	ra,40(sp)
    80003962:	f022                	sd	s0,32(sp)
    80003964:	ec26                	sd	s1,24(sp)
    80003966:	e84a                	sd	s2,16(sp)
    80003968:	e44e                	sd	s3,8(sp)
    8000396a:	e052                	sd	s4,0(sp)
    8000396c:	1800                	addi	s0,sp,48
    8000396e:	892a                	mv	s2,a0
    80003970:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003972:	00020517          	auipc	a0,0x20
    80003976:	65650513          	addi	a0,a0,1622 # 80023fc8 <itable>
    8000397a:	ffffd097          	auipc	ra,0xffffd
    8000397e:	2da080e7          	jalr	730(ra) # 80000c54 <acquire>
  empty = 0;
    80003982:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003984:	00020497          	auipc	s1,0x20
    80003988:	65c48493          	addi	s1,s1,1628 # 80023fe0 <itable+0x18>
    8000398c:	00022697          	auipc	a3,0x22
    80003990:	0e468693          	addi	a3,a3,228 # 80025a70 <log>
    80003994:	a809                	j	800039a6 <iget+0x48>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003996:	e781                	bnez	a5,8000399e <iget+0x40>
    80003998:	00099363          	bnez	s3,8000399e <iget+0x40>
      empty = ip;
    8000399c:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000399e:	08848493          	addi	s1,s1,136
    800039a2:	02d48763          	beq	s1,a3,800039d0 <iget+0x72>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800039a6:	449c                	lw	a5,8(s1)
    800039a8:	fef057e3          	blez	a5,80003996 <iget+0x38>
    800039ac:	4098                	lw	a4,0(s1)
    800039ae:	ff2718e3          	bne	a4,s2,8000399e <iget+0x40>
    800039b2:	40d8                	lw	a4,4(s1)
    800039b4:	ff4715e3          	bne	a4,s4,8000399e <iget+0x40>
      ip->ref++;
    800039b8:	2785                	addiw	a5,a5,1
    800039ba:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800039bc:	00020517          	auipc	a0,0x20
    800039c0:	60c50513          	addi	a0,a0,1548 # 80023fc8 <itable>
    800039c4:	ffffd097          	auipc	ra,0xffffd
    800039c8:	340080e7          	jalr	832(ra) # 80000d04 <release>
      return ip;
    800039cc:	89a6                	mv	s3,s1
    800039ce:	a025                	j	800039f6 <iget+0x98>
  if(empty == 0)
    800039d0:	02098c63          	beqz	s3,80003a08 <iget+0xaa>
  ip->dev = dev;
    800039d4:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    800039d8:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    800039dc:	4785                	li	a5,1
    800039de:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    800039e2:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    800039e6:	00020517          	auipc	a0,0x20
    800039ea:	5e250513          	addi	a0,a0,1506 # 80023fc8 <itable>
    800039ee:	ffffd097          	auipc	ra,0xffffd
    800039f2:	316080e7          	jalr	790(ra) # 80000d04 <release>
}
    800039f6:	854e                	mv	a0,s3
    800039f8:	70a2                	ld	ra,40(sp)
    800039fa:	7402                	ld	s0,32(sp)
    800039fc:	64e2                	ld	s1,24(sp)
    800039fe:	6942                	ld	s2,16(sp)
    80003a00:	69a2                	ld	s3,8(sp)
    80003a02:	6a02                	ld	s4,0(sp)
    80003a04:	6145                	addi	sp,sp,48
    80003a06:	8082                	ret
    panic("iget: no inodes");
    80003a08:	00005517          	auipc	a0,0x5
    80003a0c:	b5850513          	addi	a0,a0,-1192 # 80008560 <etext+0x560>
    80003a10:	ffffd097          	auipc	ra,0xffffd
    80003a14:	b46080e7          	jalr	-1210(ra) # 80000556 <panic>

0000000080003a18 <fsinit>:
fsinit(int dev) {
    80003a18:	1101                	addi	sp,sp,-32
    80003a1a:	ec06                	sd	ra,24(sp)
    80003a1c:	e822                	sd	s0,16(sp)
    80003a1e:	e426                	sd	s1,8(sp)
    80003a20:	e04a                	sd	s2,0(sp)
    80003a22:	1000                	addi	s0,sp,32
    80003a24:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003a26:	4585                	li	a1,1
    80003a28:	00000097          	auipc	ra,0x0
    80003a2c:	a96080e7          	jalr	-1386(ra) # 800034be <bread>
    80003a30:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003a32:	02000613          	li	a2,32
    80003a36:	05850593          	addi	a1,a0,88
    80003a3a:	00020517          	auipc	a0,0x20
    80003a3e:	56e50513          	addi	a0,a0,1390 # 80023fa8 <sb>
    80003a42:	ffffd097          	auipc	ra,0xffffd
    80003a46:	36a080e7          	jalr	874(ra) # 80000dac <memmove>
  brelse(bp);
    80003a4a:	8526                	mv	a0,s1
    80003a4c:	00000097          	auipc	ra,0x0
    80003a50:	ba2080e7          	jalr	-1118(ra) # 800035ee <brelse>
  if(sb.magic != FSMAGIC)
    80003a54:	00020717          	auipc	a4,0x20
    80003a58:	55472703          	lw	a4,1364(a4) # 80023fa8 <sb>
    80003a5c:	102037b7          	lui	a5,0x10203
    80003a60:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003a64:	02f71163          	bne	a4,a5,80003a86 <fsinit+0x6e>
  initlog(dev, &sb);
    80003a68:	00020597          	auipc	a1,0x20
    80003a6c:	54058593          	addi	a1,a1,1344 # 80023fa8 <sb>
    80003a70:	854a                	mv	a0,s2
    80003a72:	00001097          	auipc	ra,0x1
    80003a76:	b78080e7          	jalr	-1160(ra) # 800045ea <initlog>
}
    80003a7a:	60e2                	ld	ra,24(sp)
    80003a7c:	6442                	ld	s0,16(sp)
    80003a7e:	64a2                	ld	s1,8(sp)
    80003a80:	6902                	ld	s2,0(sp)
    80003a82:	6105                	addi	sp,sp,32
    80003a84:	8082                	ret
    panic("invalid file system");
    80003a86:	00005517          	auipc	a0,0x5
    80003a8a:	aea50513          	addi	a0,a0,-1302 # 80008570 <etext+0x570>
    80003a8e:	ffffd097          	auipc	ra,0xffffd
    80003a92:	ac8080e7          	jalr	-1336(ra) # 80000556 <panic>

0000000080003a96 <iinit>:
{
    80003a96:	7179                	addi	sp,sp,-48
    80003a98:	f406                	sd	ra,40(sp)
    80003a9a:	f022                	sd	s0,32(sp)
    80003a9c:	ec26                	sd	s1,24(sp)
    80003a9e:	e84a                	sd	s2,16(sp)
    80003aa0:	e44e                	sd	s3,8(sp)
    80003aa2:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003aa4:	00005597          	auipc	a1,0x5
    80003aa8:	ae458593          	addi	a1,a1,-1308 # 80008588 <etext+0x588>
    80003aac:	00020517          	auipc	a0,0x20
    80003ab0:	51c50513          	addi	a0,a0,1308 # 80023fc8 <itable>
    80003ab4:	ffffd097          	auipc	ra,0xffffd
    80003ab8:	106080e7          	jalr	262(ra) # 80000bba <initlock>
  for(i = 0; i < NINODE; i++) {
    80003abc:	00020497          	auipc	s1,0x20
    80003ac0:	53448493          	addi	s1,s1,1332 # 80023ff0 <itable+0x28>
    80003ac4:	00022997          	auipc	s3,0x22
    80003ac8:	fbc98993          	addi	s3,s3,-68 # 80025a80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003acc:	00005917          	auipc	s2,0x5
    80003ad0:	ac490913          	addi	s2,s2,-1340 # 80008590 <etext+0x590>
    80003ad4:	85ca                	mv	a1,s2
    80003ad6:	8526                	mv	a0,s1
    80003ad8:	00001097          	auipc	ra,0x1
    80003adc:	e7e080e7          	jalr	-386(ra) # 80004956 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003ae0:	08848493          	addi	s1,s1,136
    80003ae4:	ff3498e3          	bne	s1,s3,80003ad4 <iinit+0x3e>
}
    80003ae8:	70a2                	ld	ra,40(sp)
    80003aea:	7402                	ld	s0,32(sp)
    80003aec:	64e2                	ld	s1,24(sp)
    80003aee:	6942                	ld	s2,16(sp)
    80003af0:	69a2                	ld	s3,8(sp)
    80003af2:	6145                	addi	sp,sp,48
    80003af4:	8082                	ret

0000000080003af6 <ialloc>:
{
    80003af6:	7139                	addi	sp,sp,-64
    80003af8:	fc06                	sd	ra,56(sp)
    80003afa:	f822                	sd	s0,48(sp)
    80003afc:	f426                	sd	s1,40(sp)
    80003afe:	f04a                	sd	s2,32(sp)
    80003b00:	ec4e                	sd	s3,24(sp)
    80003b02:	e852                	sd	s4,16(sp)
    80003b04:	e456                	sd	s5,8(sp)
    80003b06:	e05a                	sd	s6,0(sp)
    80003b08:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b0a:	00020717          	auipc	a4,0x20
    80003b0e:	4aa72703          	lw	a4,1194(a4) # 80023fb4 <sb+0xc>
    80003b12:	4785                	li	a5,1
    80003b14:	04e7f863          	bgeu	a5,a4,80003b64 <ialloc+0x6e>
    80003b18:	8aaa                	mv	s5,a0
    80003b1a:	8b2e                	mv	s6,a1
    80003b1c:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003b1e:	00020a17          	auipc	s4,0x20
    80003b22:	48aa0a13          	addi	s4,s4,1162 # 80023fa8 <sb>
    80003b26:	00495593          	srli	a1,s2,0x4
    80003b2a:	018a2783          	lw	a5,24(s4)
    80003b2e:	9dbd                	addw	a1,a1,a5
    80003b30:	8556                	mv	a0,s5
    80003b32:	00000097          	auipc	ra,0x0
    80003b36:	98c080e7          	jalr	-1652(ra) # 800034be <bread>
    80003b3a:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003b3c:	05850993          	addi	s3,a0,88
    80003b40:	00f97793          	andi	a5,s2,15
    80003b44:	079a                	slli	a5,a5,0x6
    80003b46:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003b48:	00099783          	lh	a5,0(s3)
    80003b4c:	c785                	beqz	a5,80003b74 <ialloc+0x7e>
    brelse(bp);
    80003b4e:	00000097          	auipc	ra,0x0
    80003b52:	aa0080e7          	jalr	-1376(ra) # 800035ee <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b56:	0905                	addi	s2,s2,1
    80003b58:	00ca2703          	lw	a4,12(s4)
    80003b5c:	0009079b          	sext.w	a5,s2
    80003b60:	fce7e3e3          	bltu	a5,a4,80003b26 <ialloc+0x30>
  panic("ialloc: no inodes");
    80003b64:	00005517          	auipc	a0,0x5
    80003b68:	a3450513          	addi	a0,a0,-1484 # 80008598 <etext+0x598>
    80003b6c:	ffffd097          	auipc	ra,0xffffd
    80003b70:	9ea080e7          	jalr	-1558(ra) # 80000556 <panic>
      memset(dip, 0, sizeof(*dip));
    80003b74:	04000613          	li	a2,64
    80003b78:	4581                	li	a1,0
    80003b7a:	854e                	mv	a0,s3
    80003b7c:	ffffd097          	auipc	ra,0xffffd
    80003b80:	1d0080e7          	jalr	464(ra) # 80000d4c <memset>
      dip->type = type;
    80003b84:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003b88:	8526                	mv	a0,s1
    80003b8a:	00001097          	auipc	ra,0x1
    80003b8e:	ce6080e7          	jalr	-794(ra) # 80004870 <log_write>
      brelse(bp);
    80003b92:	8526                	mv	a0,s1
    80003b94:	00000097          	auipc	ra,0x0
    80003b98:	a5a080e7          	jalr	-1446(ra) # 800035ee <brelse>
      return iget(dev, inum);
    80003b9c:	0009059b          	sext.w	a1,s2
    80003ba0:	8556                	mv	a0,s5
    80003ba2:	00000097          	auipc	ra,0x0
    80003ba6:	dbc080e7          	jalr	-580(ra) # 8000395e <iget>
}
    80003baa:	70e2                	ld	ra,56(sp)
    80003bac:	7442                	ld	s0,48(sp)
    80003bae:	74a2                	ld	s1,40(sp)
    80003bb0:	7902                	ld	s2,32(sp)
    80003bb2:	69e2                	ld	s3,24(sp)
    80003bb4:	6a42                	ld	s4,16(sp)
    80003bb6:	6aa2                	ld	s5,8(sp)
    80003bb8:	6b02                	ld	s6,0(sp)
    80003bba:	6121                	addi	sp,sp,64
    80003bbc:	8082                	ret

0000000080003bbe <iupdate>:
{
    80003bbe:	1101                	addi	sp,sp,-32
    80003bc0:	ec06                	sd	ra,24(sp)
    80003bc2:	e822                	sd	s0,16(sp)
    80003bc4:	e426                	sd	s1,8(sp)
    80003bc6:	e04a                	sd	s2,0(sp)
    80003bc8:	1000                	addi	s0,sp,32
    80003bca:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003bcc:	415c                	lw	a5,4(a0)
    80003bce:	0047d79b          	srliw	a5,a5,0x4
    80003bd2:	00020597          	auipc	a1,0x20
    80003bd6:	3ee5a583          	lw	a1,1006(a1) # 80023fc0 <sb+0x18>
    80003bda:	9dbd                	addw	a1,a1,a5
    80003bdc:	4108                	lw	a0,0(a0)
    80003bde:	00000097          	auipc	ra,0x0
    80003be2:	8e0080e7          	jalr	-1824(ra) # 800034be <bread>
    80003be6:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003be8:	05850793          	addi	a5,a0,88
    80003bec:	40d8                	lw	a4,4(s1)
    80003bee:	8b3d                	andi	a4,a4,15
    80003bf0:	071a                	slli	a4,a4,0x6
    80003bf2:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003bf4:	04449703          	lh	a4,68(s1)
    80003bf8:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003bfc:	04649703          	lh	a4,70(s1)
    80003c00:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003c04:	04849703          	lh	a4,72(s1)
    80003c08:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003c0c:	04a49703          	lh	a4,74(s1)
    80003c10:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003c14:	44f8                	lw	a4,76(s1)
    80003c16:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003c18:	03400613          	li	a2,52
    80003c1c:	05048593          	addi	a1,s1,80
    80003c20:	00c78513          	addi	a0,a5,12
    80003c24:	ffffd097          	auipc	ra,0xffffd
    80003c28:	188080e7          	jalr	392(ra) # 80000dac <memmove>
  log_write(bp);
    80003c2c:	854a                	mv	a0,s2
    80003c2e:	00001097          	auipc	ra,0x1
    80003c32:	c42080e7          	jalr	-958(ra) # 80004870 <log_write>
  brelse(bp);
    80003c36:	854a                	mv	a0,s2
    80003c38:	00000097          	auipc	ra,0x0
    80003c3c:	9b6080e7          	jalr	-1610(ra) # 800035ee <brelse>
}
    80003c40:	60e2                	ld	ra,24(sp)
    80003c42:	6442                	ld	s0,16(sp)
    80003c44:	64a2                	ld	s1,8(sp)
    80003c46:	6902                	ld	s2,0(sp)
    80003c48:	6105                	addi	sp,sp,32
    80003c4a:	8082                	ret

0000000080003c4c <idup>:
{
    80003c4c:	1101                	addi	sp,sp,-32
    80003c4e:	ec06                	sd	ra,24(sp)
    80003c50:	e822                	sd	s0,16(sp)
    80003c52:	e426                	sd	s1,8(sp)
    80003c54:	1000                	addi	s0,sp,32
    80003c56:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c58:	00020517          	auipc	a0,0x20
    80003c5c:	37050513          	addi	a0,a0,880 # 80023fc8 <itable>
    80003c60:	ffffd097          	auipc	ra,0xffffd
    80003c64:	ff4080e7          	jalr	-12(ra) # 80000c54 <acquire>
  ip->ref++;
    80003c68:	449c                	lw	a5,8(s1)
    80003c6a:	2785                	addiw	a5,a5,1
    80003c6c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c6e:	00020517          	auipc	a0,0x20
    80003c72:	35a50513          	addi	a0,a0,858 # 80023fc8 <itable>
    80003c76:	ffffd097          	auipc	ra,0xffffd
    80003c7a:	08e080e7          	jalr	142(ra) # 80000d04 <release>
}
    80003c7e:	8526                	mv	a0,s1
    80003c80:	60e2                	ld	ra,24(sp)
    80003c82:	6442                	ld	s0,16(sp)
    80003c84:	64a2                	ld	s1,8(sp)
    80003c86:	6105                	addi	sp,sp,32
    80003c88:	8082                	ret

0000000080003c8a <ilock>:
{
    80003c8a:	1101                	addi	sp,sp,-32
    80003c8c:	ec06                	sd	ra,24(sp)
    80003c8e:	e822                	sd	s0,16(sp)
    80003c90:	e426                	sd	s1,8(sp)
    80003c92:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003c94:	c10d                	beqz	a0,80003cb6 <ilock+0x2c>
    80003c96:	84aa                	mv	s1,a0
    80003c98:	451c                	lw	a5,8(a0)
    80003c9a:	00f05e63          	blez	a5,80003cb6 <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003c9e:	0541                	addi	a0,a0,16
    80003ca0:	00001097          	auipc	ra,0x1
    80003ca4:	cf0080e7          	jalr	-784(ra) # 80004990 <acquiresleep>
  if(ip->valid == 0){
    80003ca8:	40bc                	lw	a5,64(s1)
    80003caa:	cf99                	beqz	a5,80003cc8 <ilock+0x3e>
}
    80003cac:	60e2                	ld	ra,24(sp)
    80003cae:	6442                	ld	s0,16(sp)
    80003cb0:	64a2                	ld	s1,8(sp)
    80003cb2:	6105                	addi	sp,sp,32
    80003cb4:	8082                	ret
    80003cb6:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003cb8:	00005517          	auipc	a0,0x5
    80003cbc:	8f850513          	addi	a0,a0,-1800 # 800085b0 <etext+0x5b0>
    80003cc0:	ffffd097          	auipc	ra,0xffffd
    80003cc4:	896080e7          	jalr	-1898(ra) # 80000556 <panic>
    80003cc8:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003cca:	40dc                	lw	a5,4(s1)
    80003ccc:	0047d79b          	srliw	a5,a5,0x4
    80003cd0:	00020597          	auipc	a1,0x20
    80003cd4:	2f05a583          	lw	a1,752(a1) # 80023fc0 <sb+0x18>
    80003cd8:	9dbd                	addw	a1,a1,a5
    80003cda:	4088                	lw	a0,0(s1)
    80003cdc:	fffff097          	auipc	ra,0xfffff
    80003ce0:	7e2080e7          	jalr	2018(ra) # 800034be <bread>
    80003ce4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ce6:	05850593          	addi	a1,a0,88
    80003cea:	40dc                	lw	a5,4(s1)
    80003cec:	8bbd                	andi	a5,a5,15
    80003cee:	079a                	slli	a5,a5,0x6
    80003cf0:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003cf2:	00059783          	lh	a5,0(a1)
    80003cf6:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003cfa:	00259783          	lh	a5,2(a1)
    80003cfe:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003d02:	00459783          	lh	a5,4(a1)
    80003d06:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003d0a:	00659783          	lh	a5,6(a1)
    80003d0e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003d12:	459c                	lw	a5,8(a1)
    80003d14:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003d16:	03400613          	li	a2,52
    80003d1a:	05b1                	addi	a1,a1,12
    80003d1c:	05048513          	addi	a0,s1,80
    80003d20:	ffffd097          	auipc	ra,0xffffd
    80003d24:	08c080e7          	jalr	140(ra) # 80000dac <memmove>
    brelse(bp);
    80003d28:	854a                	mv	a0,s2
    80003d2a:	00000097          	auipc	ra,0x0
    80003d2e:	8c4080e7          	jalr	-1852(ra) # 800035ee <brelse>
    ip->valid = 1;
    80003d32:	4785                	li	a5,1
    80003d34:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003d36:	04449783          	lh	a5,68(s1)
    80003d3a:	c399                	beqz	a5,80003d40 <ilock+0xb6>
    80003d3c:	6902                	ld	s2,0(sp)
    80003d3e:	b7bd                	j	80003cac <ilock+0x22>
      panic("ilock: no type");
    80003d40:	00005517          	auipc	a0,0x5
    80003d44:	87850513          	addi	a0,a0,-1928 # 800085b8 <etext+0x5b8>
    80003d48:	ffffd097          	auipc	ra,0xffffd
    80003d4c:	80e080e7          	jalr	-2034(ra) # 80000556 <panic>

0000000080003d50 <iunlock>:
{
    80003d50:	1101                	addi	sp,sp,-32
    80003d52:	ec06                	sd	ra,24(sp)
    80003d54:	e822                	sd	s0,16(sp)
    80003d56:	e426                	sd	s1,8(sp)
    80003d58:	e04a                	sd	s2,0(sp)
    80003d5a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003d5c:	c905                	beqz	a0,80003d8c <iunlock+0x3c>
    80003d5e:	84aa                	mv	s1,a0
    80003d60:	01050913          	addi	s2,a0,16
    80003d64:	854a                	mv	a0,s2
    80003d66:	00001097          	auipc	ra,0x1
    80003d6a:	cc4080e7          	jalr	-828(ra) # 80004a2a <holdingsleep>
    80003d6e:	cd19                	beqz	a0,80003d8c <iunlock+0x3c>
    80003d70:	449c                	lw	a5,8(s1)
    80003d72:	00f05d63          	blez	a5,80003d8c <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003d76:	854a                	mv	a0,s2
    80003d78:	00001097          	auipc	ra,0x1
    80003d7c:	c6e080e7          	jalr	-914(ra) # 800049e6 <releasesleep>
}
    80003d80:	60e2                	ld	ra,24(sp)
    80003d82:	6442                	ld	s0,16(sp)
    80003d84:	64a2                	ld	s1,8(sp)
    80003d86:	6902                	ld	s2,0(sp)
    80003d88:	6105                	addi	sp,sp,32
    80003d8a:	8082                	ret
    panic("iunlock");
    80003d8c:	00005517          	auipc	a0,0x5
    80003d90:	83c50513          	addi	a0,a0,-1988 # 800085c8 <etext+0x5c8>
    80003d94:	ffffc097          	auipc	ra,0xffffc
    80003d98:	7c2080e7          	jalr	1986(ra) # 80000556 <panic>

0000000080003d9c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003d9c:	7179                	addi	sp,sp,-48
    80003d9e:	f406                	sd	ra,40(sp)
    80003da0:	f022                	sd	s0,32(sp)
    80003da2:	ec26                	sd	s1,24(sp)
    80003da4:	e84a                	sd	s2,16(sp)
    80003da6:	e44e                	sd	s3,8(sp)
    80003da8:	1800                	addi	s0,sp,48
    80003daa:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003dac:	05050493          	addi	s1,a0,80
    80003db0:	08050913          	addi	s2,a0,128
    80003db4:	a021                	j	80003dbc <itrunc+0x20>
    80003db6:	0491                	addi	s1,s1,4
    80003db8:	01248d63          	beq	s1,s2,80003dd2 <itrunc+0x36>
    if(ip->addrs[i]){
    80003dbc:	408c                	lw	a1,0(s1)
    80003dbe:	dde5                	beqz	a1,80003db6 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003dc0:	0009a503          	lw	a0,0(s3)
    80003dc4:	00000097          	auipc	ra,0x0
    80003dc8:	93a080e7          	jalr	-1734(ra) # 800036fe <bfree>
      ip->addrs[i] = 0;
    80003dcc:	0004a023          	sw	zero,0(s1)
    80003dd0:	b7dd                	j	80003db6 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003dd2:	0809a583          	lw	a1,128(s3)
    80003dd6:	ed99                	bnez	a1,80003df4 <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003dd8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003ddc:	854e                	mv	a0,s3
    80003dde:	00000097          	auipc	ra,0x0
    80003de2:	de0080e7          	jalr	-544(ra) # 80003bbe <iupdate>
}
    80003de6:	70a2                	ld	ra,40(sp)
    80003de8:	7402                	ld	s0,32(sp)
    80003dea:	64e2                	ld	s1,24(sp)
    80003dec:	6942                	ld	s2,16(sp)
    80003dee:	69a2                	ld	s3,8(sp)
    80003df0:	6145                	addi	sp,sp,48
    80003df2:	8082                	ret
    80003df4:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003df6:	0009a503          	lw	a0,0(s3)
    80003dfa:	fffff097          	auipc	ra,0xfffff
    80003dfe:	6c4080e7          	jalr	1732(ra) # 800034be <bread>
    80003e02:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003e04:	05850493          	addi	s1,a0,88
    80003e08:	45850913          	addi	s2,a0,1112
    80003e0c:	a021                	j	80003e14 <itrunc+0x78>
    80003e0e:	0491                	addi	s1,s1,4
    80003e10:	01248b63          	beq	s1,s2,80003e26 <itrunc+0x8a>
      if(a[j])
    80003e14:	408c                	lw	a1,0(s1)
    80003e16:	dde5                	beqz	a1,80003e0e <itrunc+0x72>
        bfree(ip->dev, a[j]);
    80003e18:	0009a503          	lw	a0,0(s3)
    80003e1c:	00000097          	auipc	ra,0x0
    80003e20:	8e2080e7          	jalr	-1822(ra) # 800036fe <bfree>
    80003e24:	b7ed                	j	80003e0e <itrunc+0x72>
    brelse(bp);
    80003e26:	8552                	mv	a0,s4
    80003e28:	fffff097          	auipc	ra,0xfffff
    80003e2c:	7c6080e7          	jalr	1990(ra) # 800035ee <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003e30:	0809a583          	lw	a1,128(s3)
    80003e34:	0009a503          	lw	a0,0(s3)
    80003e38:	00000097          	auipc	ra,0x0
    80003e3c:	8c6080e7          	jalr	-1850(ra) # 800036fe <bfree>
    ip->addrs[NDIRECT] = 0;
    80003e40:	0809a023          	sw	zero,128(s3)
    80003e44:	6a02                	ld	s4,0(sp)
    80003e46:	bf49                	j	80003dd8 <itrunc+0x3c>

0000000080003e48 <iput>:
{
    80003e48:	1101                	addi	sp,sp,-32
    80003e4a:	ec06                	sd	ra,24(sp)
    80003e4c:	e822                	sd	s0,16(sp)
    80003e4e:	e426                	sd	s1,8(sp)
    80003e50:	1000                	addi	s0,sp,32
    80003e52:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e54:	00020517          	auipc	a0,0x20
    80003e58:	17450513          	addi	a0,a0,372 # 80023fc8 <itable>
    80003e5c:	ffffd097          	auipc	ra,0xffffd
    80003e60:	df8080e7          	jalr	-520(ra) # 80000c54 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e64:	4498                	lw	a4,8(s1)
    80003e66:	4785                	li	a5,1
    80003e68:	02f70263          	beq	a4,a5,80003e8c <iput+0x44>
  ip->ref--;
    80003e6c:	449c                	lw	a5,8(s1)
    80003e6e:	37fd                	addiw	a5,a5,-1
    80003e70:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e72:	00020517          	auipc	a0,0x20
    80003e76:	15650513          	addi	a0,a0,342 # 80023fc8 <itable>
    80003e7a:	ffffd097          	auipc	ra,0xffffd
    80003e7e:	e8a080e7          	jalr	-374(ra) # 80000d04 <release>
}
    80003e82:	60e2                	ld	ra,24(sp)
    80003e84:	6442                	ld	s0,16(sp)
    80003e86:	64a2                	ld	s1,8(sp)
    80003e88:	6105                	addi	sp,sp,32
    80003e8a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e8c:	40bc                	lw	a5,64(s1)
    80003e8e:	dff9                	beqz	a5,80003e6c <iput+0x24>
    80003e90:	04a49783          	lh	a5,74(s1)
    80003e94:	ffe1                	bnez	a5,80003e6c <iput+0x24>
    80003e96:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003e98:	01048793          	addi	a5,s1,16
    80003e9c:	893e                	mv	s2,a5
    80003e9e:	853e                	mv	a0,a5
    80003ea0:	00001097          	auipc	ra,0x1
    80003ea4:	af0080e7          	jalr	-1296(ra) # 80004990 <acquiresleep>
    release(&itable.lock);
    80003ea8:	00020517          	auipc	a0,0x20
    80003eac:	12050513          	addi	a0,a0,288 # 80023fc8 <itable>
    80003eb0:	ffffd097          	auipc	ra,0xffffd
    80003eb4:	e54080e7          	jalr	-428(ra) # 80000d04 <release>
    itrunc(ip);
    80003eb8:	8526                	mv	a0,s1
    80003eba:	00000097          	auipc	ra,0x0
    80003ebe:	ee2080e7          	jalr	-286(ra) # 80003d9c <itrunc>
    ip->type = 0;
    80003ec2:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003ec6:	8526                	mv	a0,s1
    80003ec8:	00000097          	auipc	ra,0x0
    80003ecc:	cf6080e7          	jalr	-778(ra) # 80003bbe <iupdate>
    ip->valid = 0;
    80003ed0:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003ed4:	854a                	mv	a0,s2
    80003ed6:	00001097          	auipc	ra,0x1
    80003eda:	b10080e7          	jalr	-1264(ra) # 800049e6 <releasesleep>
    acquire(&itable.lock);
    80003ede:	00020517          	auipc	a0,0x20
    80003ee2:	0ea50513          	addi	a0,a0,234 # 80023fc8 <itable>
    80003ee6:	ffffd097          	auipc	ra,0xffffd
    80003eea:	d6e080e7          	jalr	-658(ra) # 80000c54 <acquire>
    80003eee:	6902                	ld	s2,0(sp)
    80003ef0:	bfb5                	j	80003e6c <iput+0x24>

0000000080003ef2 <iunlockput>:
{
    80003ef2:	1101                	addi	sp,sp,-32
    80003ef4:	ec06                	sd	ra,24(sp)
    80003ef6:	e822                	sd	s0,16(sp)
    80003ef8:	e426                	sd	s1,8(sp)
    80003efa:	1000                	addi	s0,sp,32
    80003efc:	84aa                	mv	s1,a0
  iunlock(ip);
    80003efe:	00000097          	auipc	ra,0x0
    80003f02:	e52080e7          	jalr	-430(ra) # 80003d50 <iunlock>
  iput(ip);
    80003f06:	8526                	mv	a0,s1
    80003f08:	00000097          	auipc	ra,0x0
    80003f0c:	f40080e7          	jalr	-192(ra) # 80003e48 <iput>
}
    80003f10:	60e2                	ld	ra,24(sp)
    80003f12:	6442                	ld	s0,16(sp)
    80003f14:	64a2                	ld	s1,8(sp)
    80003f16:	6105                	addi	sp,sp,32
    80003f18:	8082                	ret

0000000080003f1a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003f1a:	1141                	addi	sp,sp,-16
    80003f1c:	e406                	sd	ra,8(sp)
    80003f1e:	e022                	sd	s0,0(sp)
    80003f20:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003f22:	411c                	lw	a5,0(a0)
    80003f24:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003f26:	415c                	lw	a5,4(a0)
    80003f28:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003f2a:	04451783          	lh	a5,68(a0)
    80003f2e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003f32:	04a51783          	lh	a5,74(a0)
    80003f36:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003f3a:	04c56783          	lwu	a5,76(a0)
    80003f3e:	e99c                	sd	a5,16(a1)
}
    80003f40:	60a2                	ld	ra,8(sp)
    80003f42:	6402                	ld	s0,0(sp)
    80003f44:	0141                	addi	sp,sp,16
    80003f46:	8082                	ret

0000000080003f48 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f48:	457c                	lw	a5,76(a0)
    80003f4a:	0ed7ea63          	bltu	a5,a3,8000403e <readi+0xf6>
{
    80003f4e:	7159                	addi	sp,sp,-112
    80003f50:	f486                	sd	ra,104(sp)
    80003f52:	f0a2                	sd	s0,96(sp)
    80003f54:	eca6                	sd	s1,88(sp)
    80003f56:	fc56                	sd	s5,56(sp)
    80003f58:	f85a                	sd	s6,48(sp)
    80003f5a:	f45e                	sd	s7,40(sp)
    80003f5c:	ec66                	sd	s9,24(sp)
    80003f5e:	1880                	addi	s0,sp,112
    80003f60:	8baa                	mv	s7,a0
    80003f62:	8cae                	mv	s9,a1
    80003f64:	8ab2                	mv	s5,a2
    80003f66:	84b6                	mv	s1,a3
    80003f68:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003f6a:	9f35                	addw	a4,a4,a3
    return 0;
    80003f6c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003f6e:	0ad76763          	bltu	a4,a3,8000401c <readi+0xd4>
    80003f72:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003f74:	00e7f463          	bgeu	a5,a4,80003f7c <readi+0x34>
    n = ip->size - off;
    80003f78:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f7c:	0a0b0f63          	beqz	s6,8000403a <readi+0xf2>
    80003f80:	e8ca                	sd	s2,80(sp)
    80003f82:	e0d2                	sd	s4,64(sp)
    80003f84:	f062                	sd	s8,32(sp)
    80003f86:	e86a                	sd	s10,16(sp)
    80003f88:	e46e                	sd	s11,8(sp)
    80003f8a:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f8c:	40000d93          	li	s11,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003f90:	5d7d                	li	s10,-1
    80003f92:	a82d                	j	80003fcc <readi+0x84>
    80003f94:	020a1c13          	slli	s8,s4,0x20
    80003f98:	020c5c13          	srli	s8,s8,0x20
    80003f9c:	05890613          	addi	a2,s2,88
    80003fa0:	86e2                	mv	a3,s8
    80003fa2:	963e                	add	a2,a2,a5
    80003fa4:	85d6                	mv	a1,s5
    80003fa6:	8566                	mv	a0,s9
    80003fa8:	ffffe097          	auipc	ra,0xffffe
    80003fac:	69a080e7          	jalr	1690(ra) # 80002642 <either_copyout>
    80003fb0:	05a50963          	beq	a0,s10,80004002 <readi+0xba>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003fb4:	854a                	mv	a0,s2
    80003fb6:	fffff097          	auipc	ra,0xfffff
    80003fba:	638080e7          	jalr	1592(ra) # 800035ee <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fbe:	013a09bb          	addw	s3,s4,s3
    80003fc2:	009a04bb          	addw	s1,s4,s1
    80003fc6:	9ae2                	add	s5,s5,s8
    80003fc8:	0769f363          	bgeu	s3,s6,8000402e <readi+0xe6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003fcc:	000ba903          	lw	s2,0(s7)
    80003fd0:	00a4d59b          	srliw	a1,s1,0xa
    80003fd4:	855e                	mv	a0,s7
    80003fd6:	00000097          	auipc	ra,0x0
    80003fda:	8ba080e7          	jalr	-1862(ra) # 80003890 <bmap>
    80003fde:	85aa                	mv	a1,a0
    80003fe0:	854a                	mv	a0,s2
    80003fe2:	fffff097          	auipc	ra,0xfffff
    80003fe6:	4dc080e7          	jalr	1244(ra) # 800034be <bread>
    80003fea:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fec:	3ff4f793          	andi	a5,s1,1023
    80003ff0:	40fd873b          	subw	a4,s11,a5
    80003ff4:	413b06bb          	subw	a3,s6,s3
    80003ff8:	8a3a                	mv	s4,a4
    80003ffa:	f8e6fde3          	bgeu	a3,a4,80003f94 <readi+0x4c>
    80003ffe:	8a36                	mv	s4,a3
    80004000:	bf51                	j	80003f94 <readi+0x4c>
      brelse(bp);
    80004002:	854a                	mv	a0,s2
    80004004:	fffff097          	auipc	ra,0xfffff
    80004008:	5ea080e7          	jalr	1514(ra) # 800035ee <brelse>
      tot = -1;
    8000400c:	59fd                	li	s3,-1
      break;
    8000400e:	6946                	ld	s2,80(sp)
    80004010:	6a06                	ld	s4,64(sp)
    80004012:	7c02                	ld	s8,32(sp)
    80004014:	6d42                	ld	s10,16(sp)
    80004016:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80004018:	854e                	mv	a0,s3
    8000401a:	69a6                	ld	s3,72(sp)
}
    8000401c:	70a6                	ld	ra,104(sp)
    8000401e:	7406                	ld	s0,96(sp)
    80004020:	64e6                	ld	s1,88(sp)
    80004022:	7ae2                	ld	s5,56(sp)
    80004024:	7b42                	ld	s6,48(sp)
    80004026:	7ba2                	ld	s7,40(sp)
    80004028:	6ce2                	ld	s9,24(sp)
    8000402a:	6165                	addi	sp,sp,112
    8000402c:	8082                	ret
    8000402e:	6946                	ld	s2,80(sp)
    80004030:	6a06                	ld	s4,64(sp)
    80004032:	7c02                	ld	s8,32(sp)
    80004034:	6d42                	ld	s10,16(sp)
    80004036:	6da2                	ld	s11,8(sp)
    80004038:	b7c5                	j	80004018 <readi+0xd0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000403a:	89da                	mv	s3,s6
    8000403c:	bff1                	j	80004018 <readi+0xd0>
    return 0;
    8000403e:	4501                	li	a0,0
}
    80004040:	8082                	ret

0000000080004042 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004042:	457c                	lw	a5,76(a0)
    80004044:	10d7e963          	bltu	a5,a3,80004156 <writei+0x114>
{
    80004048:	7159                	addi	sp,sp,-112
    8000404a:	f486                	sd	ra,104(sp)
    8000404c:	f0a2                	sd	s0,96(sp)
    8000404e:	e8ca                	sd	s2,80(sp)
    80004050:	fc56                	sd	s5,56(sp)
    80004052:	f45e                	sd	s7,40(sp)
    80004054:	f062                	sd	s8,32(sp)
    80004056:	ec66                	sd	s9,24(sp)
    80004058:	1880                	addi	s0,sp,112
    8000405a:	8baa                	mv	s7,a0
    8000405c:	8cae                	mv	s9,a1
    8000405e:	8ab2                	mv	s5,a2
    80004060:	8936                	mv	s2,a3
    80004062:	8c3a                	mv	s8,a4
  if(off > ip->size || off + n < off)
    80004064:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004068:	00043737          	lui	a4,0x43
    8000406c:	0ef76763          	bltu	a4,a5,8000415a <writei+0x118>
    80004070:	0ed7e563          	bltu	a5,a3,8000415a <writei+0x118>
    80004074:	e0d2                	sd	s4,64(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004076:	0c0c0863          	beqz	s8,80004146 <writei+0x104>
    8000407a:	eca6                	sd	s1,88(sp)
    8000407c:	e4ce                	sd	s3,72(sp)
    8000407e:	f85a                	sd	s6,48(sp)
    80004080:	e86a                	sd	s10,16(sp)
    80004082:	e46e                	sd	s11,8(sp)
    80004084:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004086:	40000d93          	li	s11,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000408a:	5d7d                	li	s10,-1
    8000408c:	a091                	j	800040d0 <writei+0x8e>
    8000408e:	02099b13          	slli	s6,s3,0x20
    80004092:	020b5b13          	srli	s6,s6,0x20
    80004096:	05848513          	addi	a0,s1,88
    8000409a:	86da                	mv	a3,s6
    8000409c:	8656                	mv	a2,s5
    8000409e:	85e6                	mv	a1,s9
    800040a0:	953e                	add	a0,a0,a5
    800040a2:	ffffe097          	auipc	ra,0xffffe
    800040a6:	5f6080e7          	jalr	1526(ra) # 80002698 <either_copyin>
    800040aa:	05a50e63          	beq	a0,s10,80004106 <writei+0xc4>
      brelse(bp);
      break;
    }
    log_write(bp);
    800040ae:	8526                	mv	a0,s1
    800040b0:	00000097          	auipc	ra,0x0
    800040b4:	7c0080e7          	jalr	1984(ra) # 80004870 <log_write>
    brelse(bp);
    800040b8:	8526                	mv	a0,s1
    800040ba:	fffff097          	auipc	ra,0xfffff
    800040be:	534080e7          	jalr	1332(ra) # 800035ee <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040c2:	01498a3b          	addw	s4,s3,s4
    800040c6:	0129893b          	addw	s2,s3,s2
    800040ca:	9ada                	add	s5,s5,s6
    800040cc:	058a7263          	bgeu	s4,s8,80004110 <writei+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800040d0:	000ba483          	lw	s1,0(s7)
    800040d4:	00a9559b          	srliw	a1,s2,0xa
    800040d8:	855e                	mv	a0,s7
    800040da:	fffff097          	auipc	ra,0xfffff
    800040de:	7b6080e7          	jalr	1974(ra) # 80003890 <bmap>
    800040e2:	85aa                	mv	a1,a0
    800040e4:	8526                	mv	a0,s1
    800040e6:	fffff097          	auipc	ra,0xfffff
    800040ea:	3d8080e7          	jalr	984(ra) # 800034be <bread>
    800040ee:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800040f0:	3ff97793          	andi	a5,s2,1023
    800040f4:	40fd873b          	subw	a4,s11,a5
    800040f8:	414c06bb          	subw	a3,s8,s4
    800040fc:	89ba                	mv	s3,a4
    800040fe:	f8e6f8e3          	bgeu	a3,a4,8000408e <writei+0x4c>
    80004102:	89b6                	mv	s3,a3
    80004104:	b769                	j	8000408e <writei+0x4c>
      brelse(bp);
    80004106:	8526                	mv	a0,s1
    80004108:	fffff097          	auipc	ra,0xfffff
    8000410c:	4e6080e7          	jalr	1254(ra) # 800035ee <brelse>
  }

  if(off > ip->size)
    80004110:	04cba783          	lw	a5,76(s7)
    80004114:	0327fb63          	bgeu	a5,s2,8000414a <writei+0x108>
    ip->size = off;
    80004118:	052ba623          	sw	s2,76(s7)
    8000411c:	64e6                	ld	s1,88(sp)
    8000411e:	69a6                	ld	s3,72(sp)
    80004120:	7b42                	ld	s6,48(sp)
    80004122:	6d42                	ld	s10,16(sp)
    80004124:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004126:	855e                	mv	a0,s7
    80004128:	00000097          	auipc	ra,0x0
    8000412c:	a96080e7          	jalr	-1386(ra) # 80003bbe <iupdate>

  return tot;
    80004130:	8552                	mv	a0,s4
    80004132:	6a06                	ld	s4,64(sp)
}
    80004134:	70a6                	ld	ra,104(sp)
    80004136:	7406                	ld	s0,96(sp)
    80004138:	6946                	ld	s2,80(sp)
    8000413a:	7ae2                	ld	s5,56(sp)
    8000413c:	7ba2                	ld	s7,40(sp)
    8000413e:	7c02                	ld	s8,32(sp)
    80004140:	6ce2                	ld	s9,24(sp)
    80004142:	6165                	addi	sp,sp,112
    80004144:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004146:	8a62                	mv	s4,s8
    80004148:	bff9                	j	80004126 <writei+0xe4>
    8000414a:	64e6                	ld	s1,88(sp)
    8000414c:	69a6                	ld	s3,72(sp)
    8000414e:	7b42                	ld	s6,48(sp)
    80004150:	6d42                	ld	s10,16(sp)
    80004152:	6da2                	ld	s11,8(sp)
    80004154:	bfc9                	j	80004126 <writei+0xe4>
    return -1;
    80004156:	557d                	li	a0,-1
}
    80004158:	8082                	ret
    return -1;
    8000415a:	557d                	li	a0,-1
    8000415c:	bfe1                	j	80004134 <writei+0xf2>

000000008000415e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000415e:	1141                	addi	sp,sp,-16
    80004160:	e406                	sd	ra,8(sp)
    80004162:	e022                	sd	s0,0(sp)
    80004164:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004166:	4639                	li	a2,14
    80004168:	ffffd097          	auipc	ra,0xffffd
    8000416c:	cbc080e7          	jalr	-836(ra) # 80000e24 <strncmp>
}
    80004170:	60a2                	ld	ra,8(sp)
    80004172:	6402                	ld	s0,0(sp)
    80004174:	0141                	addi	sp,sp,16
    80004176:	8082                	ret

0000000080004178 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004178:	711d                	addi	sp,sp,-96
    8000417a:	ec86                	sd	ra,88(sp)
    8000417c:	e8a2                	sd	s0,80(sp)
    8000417e:	e4a6                	sd	s1,72(sp)
    80004180:	e0ca                	sd	s2,64(sp)
    80004182:	fc4e                	sd	s3,56(sp)
    80004184:	f852                	sd	s4,48(sp)
    80004186:	f456                	sd	s5,40(sp)
    80004188:	f05a                	sd	s6,32(sp)
    8000418a:	ec5e                	sd	s7,24(sp)
    8000418c:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000418e:	04451703          	lh	a4,68(a0)
    80004192:	4785                	li	a5,1
    80004194:	00f71f63          	bne	a4,a5,800041b2 <dirlookup+0x3a>
    80004198:	892a                	mv	s2,a0
    8000419a:	8aae                	mv	s5,a1
    8000419c:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000419e:	457c                	lw	a5,76(a0)
    800041a0:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041a2:	fa040a13          	addi	s4,s0,-96
    800041a6:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    800041a8:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800041ac:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041ae:	e79d                	bnez	a5,800041dc <dirlookup+0x64>
    800041b0:	a88d                	j	80004222 <dirlookup+0xaa>
    panic("dirlookup not DIR");
    800041b2:	00004517          	auipc	a0,0x4
    800041b6:	41e50513          	addi	a0,a0,1054 # 800085d0 <etext+0x5d0>
    800041ba:	ffffc097          	auipc	ra,0xffffc
    800041be:	39c080e7          	jalr	924(ra) # 80000556 <panic>
      panic("dirlookup read");
    800041c2:	00004517          	auipc	a0,0x4
    800041c6:	42650513          	addi	a0,a0,1062 # 800085e8 <etext+0x5e8>
    800041ca:	ffffc097          	auipc	ra,0xffffc
    800041ce:	38c080e7          	jalr	908(ra) # 80000556 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041d2:	24c1                	addiw	s1,s1,16
    800041d4:	04c92783          	lw	a5,76(s2)
    800041d8:	04f4f463          	bgeu	s1,a5,80004220 <dirlookup+0xa8>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041dc:	874e                	mv	a4,s3
    800041de:	86a6                	mv	a3,s1
    800041e0:	8652                	mv	a2,s4
    800041e2:	4581                	li	a1,0
    800041e4:	854a                	mv	a0,s2
    800041e6:	00000097          	auipc	ra,0x0
    800041ea:	d62080e7          	jalr	-670(ra) # 80003f48 <readi>
    800041ee:	fd351ae3          	bne	a0,s3,800041c2 <dirlookup+0x4a>
    if(de.inum == 0)
    800041f2:	fa045783          	lhu	a5,-96(s0)
    800041f6:	dff1                	beqz	a5,800041d2 <dirlookup+0x5a>
    if(namecmp(name, de.name) == 0){
    800041f8:	85da                	mv	a1,s6
    800041fa:	8556                	mv	a0,s5
    800041fc:	00000097          	auipc	ra,0x0
    80004200:	f62080e7          	jalr	-158(ra) # 8000415e <namecmp>
    80004204:	f579                	bnez	a0,800041d2 <dirlookup+0x5a>
      if(poff)
    80004206:	000b8463          	beqz	s7,8000420e <dirlookup+0x96>
        *poff = off;
    8000420a:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    8000420e:	fa045583          	lhu	a1,-96(s0)
    80004212:	00092503          	lw	a0,0(s2)
    80004216:	fffff097          	auipc	ra,0xfffff
    8000421a:	748080e7          	jalr	1864(ra) # 8000395e <iget>
    8000421e:	a011                	j	80004222 <dirlookup+0xaa>
  return 0;
    80004220:	4501                	li	a0,0
}
    80004222:	60e6                	ld	ra,88(sp)
    80004224:	6446                	ld	s0,80(sp)
    80004226:	64a6                	ld	s1,72(sp)
    80004228:	6906                	ld	s2,64(sp)
    8000422a:	79e2                	ld	s3,56(sp)
    8000422c:	7a42                	ld	s4,48(sp)
    8000422e:	7aa2                	ld	s5,40(sp)
    80004230:	7b02                	ld	s6,32(sp)
    80004232:	6be2                	ld	s7,24(sp)
    80004234:	6125                	addi	sp,sp,96
    80004236:	8082                	ret

0000000080004238 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004238:	711d                	addi	sp,sp,-96
    8000423a:	ec86                	sd	ra,88(sp)
    8000423c:	e8a2                	sd	s0,80(sp)
    8000423e:	e4a6                	sd	s1,72(sp)
    80004240:	e0ca                	sd	s2,64(sp)
    80004242:	fc4e                	sd	s3,56(sp)
    80004244:	f852                	sd	s4,48(sp)
    80004246:	f456                	sd	s5,40(sp)
    80004248:	f05a                	sd	s6,32(sp)
    8000424a:	ec5e                	sd	s7,24(sp)
    8000424c:	e862                	sd	s8,16(sp)
    8000424e:	e466                	sd	s9,8(sp)
    80004250:	e06a                	sd	s10,0(sp)
    80004252:	1080                	addi	s0,sp,96
    80004254:	84aa                	mv	s1,a0
    80004256:	8b2e                	mv	s6,a1
    80004258:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000425a:	00054703          	lbu	a4,0(a0)
    8000425e:	02f00793          	li	a5,47
    80004262:	02f70363          	beq	a4,a5,80004288 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004266:	ffffe097          	auipc	ra,0xffffe
    8000426a:	820080e7          	jalr	-2016(ra) # 80001a86 <myproc>
    8000426e:	15053503          	ld	a0,336(a0)
    80004272:	00000097          	auipc	ra,0x0
    80004276:	9da080e7          	jalr	-1574(ra) # 80003c4c <idup>
    8000427a:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000427c:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80004280:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80004282:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004284:	4b85                	li	s7,1
    80004286:	a87d                	j	80004344 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80004288:	4585                	li	a1,1
    8000428a:	852e                	mv	a0,a1
    8000428c:	fffff097          	auipc	ra,0xfffff
    80004290:	6d2080e7          	jalr	1746(ra) # 8000395e <iget>
    80004294:	8a2a                	mv	s4,a0
    80004296:	b7dd                	j	8000427c <namex+0x44>
      iunlockput(ip);
    80004298:	8552                	mv	a0,s4
    8000429a:	00000097          	auipc	ra,0x0
    8000429e:	c58080e7          	jalr	-936(ra) # 80003ef2 <iunlockput>
      return 0;
    800042a2:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800042a4:	8552                	mv	a0,s4
    800042a6:	60e6                	ld	ra,88(sp)
    800042a8:	6446                	ld	s0,80(sp)
    800042aa:	64a6                	ld	s1,72(sp)
    800042ac:	6906                	ld	s2,64(sp)
    800042ae:	79e2                	ld	s3,56(sp)
    800042b0:	7a42                	ld	s4,48(sp)
    800042b2:	7aa2                	ld	s5,40(sp)
    800042b4:	7b02                	ld	s6,32(sp)
    800042b6:	6be2                	ld	s7,24(sp)
    800042b8:	6c42                	ld	s8,16(sp)
    800042ba:	6ca2                	ld	s9,8(sp)
    800042bc:	6d02                	ld	s10,0(sp)
    800042be:	6125                	addi	sp,sp,96
    800042c0:	8082                	ret
      iunlock(ip);
    800042c2:	8552                	mv	a0,s4
    800042c4:	00000097          	auipc	ra,0x0
    800042c8:	a8c080e7          	jalr	-1396(ra) # 80003d50 <iunlock>
      return ip;
    800042cc:	bfe1                	j	800042a4 <namex+0x6c>
      iunlockput(ip);
    800042ce:	8552                	mv	a0,s4
    800042d0:	00000097          	auipc	ra,0x0
    800042d4:	c22080e7          	jalr	-990(ra) # 80003ef2 <iunlockput>
      return 0;
    800042d8:	8a4a                	mv	s4,s2
    800042da:	b7e9                	j	800042a4 <namex+0x6c>
  len = path - s;
    800042dc:	40990633          	sub	a2,s2,s1
    800042e0:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    800042e4:	09ac5c63          	bge	s8,s10,8000437c <namex+0x144>
    memmove(name, s, DIRSIZ);
    800042e8:	8666                	mv	a2,s9
    800042ea:	85a6                	mv	a1,s1
    800042ec:	8556                	mv	a0,s5
    800042ee:	ffffd097          	auipc	ra,0xffffd
    800042f2:	abe080e7          	jalr	-1346(ra) # 80000dac <memmove>
    800042f6:	84ca                	mv	s1,s2
  while(*path == '/')
    800042f8:	0004c783          	lbu	a5,0(s1)
    800042fc:	01379763          	bne	a5,s3,8000430a <namex+0xd2>
    path++;
    80004300:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004302:	0004c783          	lbu	a5,0(s1)
    80004306:	ff378de3          	beq	a5,s3,80004300 <namex+0xc8>
    ilock(ip);
    8000430a:	8552                	mv	a0,s4
    8000430c:	00000097          	auipc	ra,0x0
    80004310:	97e080e7          	jalr	-1666(ra) # 80003c8a <ilock>
    if(ip->type != T_DIR){
    80004314:	044a1783          	lh	a5,68(s4)
    80004318:	f97790e3          	bne	a5,s7,80004298 <namex+0x60>
    if(nameiparent && *path == '\0'){
    8000431c:	000b0563          	beqz	s6,80004326 <namex+0xee>
    80004320:	0004c783          	lbu	a5,0(s1)
    80004324:	dfd9                	beqz	a5,800042c2 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004326:	4601                	li	a2,0
    80004328:	85d6                	mv	a1,s5
    8000432a:	8552                	mv	a0,s4
    8000432c:	00000097          	auipc	ra,0x0
    80004330:	e4c080e7          	jalr	-436(ra) # 80004178 <dirlookup>
    80004334:	892a                	mv	s2,a0
    80004336:	dd41                	beqz	a0,800042ce <namex+0x96>
    iunlockput(ip);
    80004338:	8552                	mv	a0,s4
    8000433a:	00000097          	auipc	ra,0x0
    8000433e:	bb8080e7          	jalr	-1096(ra) # 80003ef2 <iunlockput>
    ip = next;
    80004342:	8a4a                	mv	s4,s2
  while(*path == '/')
    80004344:	0004c783          	lbu	a5,0(s1)
    80004348:	01379763          	bne	a5,s3,80004356 <namex+0x11e>
    path++;
    8000434c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000434e:	0004c783          	lbu	a5,0(s1)
    80004352:	ff378de3          	beq	a5,s3,8000434c <namex+0x114>
  if(*path == 0)
    80004356:	cf9d                	beqz	a5,80004394 <namex+0x15c>
  while(*path != '/' && *path != 0)
    80004358:	0004c783          	lbu	a5,0(s1)
    8000435c:	fd178713          	addi	a4,a5,-47
    80004360:	cb19                	beqz	a4,80004376 <namex+0x13e>
    80004362:	cb91                	beqz	a5,80004376 <namex+0x13e>
    80004364:	8926                	mv	s2,s1
    path++;
    80004366:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80004368:	00094783          	lbu	a5,0(s2)
    8000436c:	fd178713          	addi	a4,a5,-47
    80004370:	d735                	beqz	a4,800042dc <namex+0xa4>
    80004372:	fbf5                	bnez	a5,80004366 <namex+0x12e>
    80004374:	b7a5                	j	800042dc <namex+0xa4>
    80004376:	8926                	mv	s2,s1
  len = path - s;
    80004378:	4d01                	li	s10,0
    8000437a:	4601                	li	a2,0
    memmove(name, s, len);
    8000437c:	2601                	sext.w	a2,a2
    8000437e:	85a6                	mv	a1,s1
    80004380:	8556                	mv	a0,s5
    80004382:	ffffd097          	auipc	ra,0xffffd
    80004386:	a2a080e7          	jalr	-1494(ra) # 80000dac <memmove>
    name[len] = 0;
    8000438a:	9d56                	add	s10,s10,s5
    8000438c:	000d0023          	sb	zero,0(s10)
    80004390:	84ca                	mv	s1,s2
    80004392:	b79d                	j	800042f8 <namex+0xc0>
  if(nameiparent){
    80004394:	f00b08e3          	beqz	s6,800042a4 <namex+0x6c>
    iput(ip);
    80004398:	8552                	mv	a0,s4
    8000439a:	00000097          	auipc	ra,0x0
    8000439e:	aae080e7          	jalr	-1362(ra) # 80003e48 <iput>
    return 0;
    800043a2:	4a01                	li	s4,0
    800043a4:	b701                	j	800042a4 <namex+0x6c>

00000000800043a6 <dirlink>:
{
    800043a6:	715d                	addi	sp,sp,-80
    800043a8:	e486                	sd	ra,72(sp)
    800043aa:	e0a2                	sd	s0,64(sp)
    800043ac:	f84a                	sd	s2,48(sp)
    800043ae:	ec56                	sd	s5,24(sp)
    800043b0:	e85a                	sd	s6,16(sp)
    800043b2:	0880                	addi	s0,sp,80
    800043b4:	892a                	mv	s2,a0
    800043b6:	8aae                	mv	s5,a1
    800043b8:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800043ba:	4601                	li	a2,0
    800043bc:	00000097          	auipc	ra,0x0
    800043c0:	dbc080e7          	jalr	-580(ra) # 80004178 <dirlookup>
    800043c4:	e129                	bnez	a0,80004406 <dirlink+0x60>
    800043c6:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043c8:	04c92483          	lw	s1,76(s2)
    800043cc:	cca9                	beqz	s1,80004426 <dirlink+0x80>
    800043ce:	f44e                	sd	s3,40(sp)
    800043d0:	f052                	sd	s4,32(sp)
    800043d2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043d4:	fb040a13          	addi	s4,s0,-80
    800043d8:	49c1                	li	s3,16
    800043da:	874e                	mv	a4,s3
    800043dc:	86a6                	mv	a3,s1
    800043de:	8652                	mv	a2,s4
    800043e0:	4581                	li	a1,0
    800043e2:	854a                	mv	a0,s2
    800043e4:	00000097          	auipc	ra,0x0
    800043e8:	b64080e7          	jalr	-1180(ra) # 80003f48 <readi>
    800043ec:	03351363          	bne	a0,s3,80004412 <dirlink+0x6c>
    if(de.inum == 0)
    800043f0:	fb045783          	lhu	a5,-80(s0)
    800043f4:	c79d                	beqz	a5,80004422 <dirlink+0x7c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043f6:	24c1                	addiw	s1,s1,16
    800043f8:	04c92783          	lw	a5,76(s2)
    800043fc:	fcf4efe3          	bltu	s1,a5,800043da <dirlink+0x34>
    80004400:	79a2                	ld	s3,40(sp)
    80004402:	7a02                	ld	s4,32(sp)
    80004404:	a00d                	j	80004426 <dirlink+0x80>
    iput(ip);
    80004406:	00000097          	auipc	ra,0x0
    8000440a:	a42080e7          	jalr	-1470(ra) # 80003e48 <iput>
    return -1;
    8000440e:	557d                	li	a0,-1
    80004410:	a0a9                	j	8000445a <dirlink+0xb4>
      panic("dirlink read");
    80004412:	00004517          	auipc	a0,0x4
    80004416:	1e650513          	addi	a0,a0,486 # 800085f8 <etext+0x5f8>
    8000441a:	ffffc097          	auipc	ra,0xffffc
    8000441e:	13c080e7          	jalr	316(ra) # 80000556 <panic>
    80004422:	79a2                	ld	s3,40(sp)
    80004424:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80004426:	4639                	li	a2,14
    80004428:	85d6                	mv	a1,s5
    8000442a:	fb240513          	addi	a0,s0,-78
    8000442e:	ffffd097          	auipc	ra,0xffffd
    80004432:	a30080e7          	jalr	-1488(ra) # 80000e5e <strncpy>
  de.inum = inum;
    80004436:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000443a:	4741                	li	a4,16
    8000443c:	86a6                	mv	a3,s1
    8000443e:	fb040613          	addi	a2,s0,-80
    80004442:	4581                	li	a1,0
    80004444:	854a                	mv	a0,s2
    80004446:	00000097          	auipc	ra,0x0
    8000444a:	bfc080e7          	jalr	-1028(ra) # 80004042 <writei>
    8000444e:	872a                	mv	a4,a0
    80004450:	47c1                	li	a5,16
  return 0;
    80004452:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004454:	00f71a63          	bne	a4,a5,80004468 <dirlink+0xc2>
    80004458:	74e2                	ld	s1,56(sp)
}
    8000445a:	60a6                	ld	ra,72(sp)
    8000445c:	6406                	ld	s0,64(sp)
    8000445e:	7942                	ld	s2,48(sp)
    80004460:	6ae2                	ld	s5,24(sp)
    80004462:	6b42                	ld	s6,16(sp)
    80004464:	6161                	addi	sp,sp,80
    80004466:	8082                	ret
    80004468:	f44e                	sd	s3,40(sp)
    8000446a:	f052                	sd	s4,32(sp)
    panic("dirlink");
    8000446c:	00004517          	auipc	a0,0x4
    80004470:	29450513          	addi	a0,a0,660 # 80008700 <etext+0x700>
    80004474:	ffffc097          	auipc	ra,0xffffc
    80004478:	0e2080e7          	jalr	226(ra) # 80000556 <panic>

000000008000447c <namei>:

struct inode*
namei(char *path)
{
    8000447c:	1101                	addi	sp,sp,-32
    8000447e:	ec06                	sd	ra,24(sp)
    80004480:	e822                	sd	s0,16(sp)
    80004482:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004484:	fe040613          	addi	a2,s0,-32
    80004488:	4581                	li	a1,0
    8000448a:	00000097          	auipc	ra,0x0
    8000448e:	dae080e7          	jalr	-594(ra) # 80004238 <namex>
}
    80004492:	60e2                	ld	ra,24(sp)
    80004494:	6442                	ld	s0,16(sp)
    80004496:	6105                	addi	sp,sp,32
    80004498:	8082                	ret

000000008000449a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000449a:	1141                	addi	sp,sp,-16
    8000449c:	e406                	sd	ra,8(sp)
    8000449e:	e022                	sd	s0,0(sp)
    800044a0:	0800                	addi	s0,sp,16
    800044a2:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800044a4:	4585                	li	a1,1
    800044a6:	00000097          	auipc	ra,0x0
    800044aa:	d92080e7          	jalr	-622(ra) # 80004238 <namex>
}
    800044ae:	60a2                	ld	ra,8(sp)
    800044b0:	6402                	ld	s0,0(sp)
    800044b2:	0141                	addi	sp,sp,16
    800044b4:	8082                	ret

00000000800044b6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800044b6:	1101                	addi	sp,sp,-32
    800044b8:	ec06                	sd	ra,24(sp)
    800044ba:	e822                	sd	s0,16(sp)
    800044bc:	e426                	sd	s1,8(sp)
    800044be:	e04a                	sd	s2,0(sp)
    800044c0:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800044c2:	00021917          	auipc	s2,0x21
    800044c6:	5ae90913          	addi	s2,s2,1454 # 80025a70 <log>
    800044ca:	01892583          	lw	a1,24(s2)
    800044ce:	02892503          	lw	a0,40(s2)
    800044d2:	fffff097          	auipc	ra,0xfffff
    800044d6:	fec080e7          	jalr	-20(ra) # 800034be <bread>
    800044da:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800044dc:	02c92603          	lw	a2,44(s2)
    800044e0:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800044e2:	00c05f63          	blez	a2,80004500 <write_head+0x4a>
    800044e6:	00021717          	auipc	a4,0x21
    800044ea:	5ba70713          	addi	a4,a4,1466 # 80025aa0 <log+0x30>
    800044ee:	87aa                	mv	a5,a0
    800044f0:	060a                	slli	a2,a2,0x2
    800044f2:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800044f4:	4314                	lw	a3,0(a4)
    800044f6:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800044f8:	0711                	addi	a4,a4,4
    800044fa:	0791                	addi	a5,a5,4
    800044fc:	fec79ce3          	bne	a5,a2,800044f4 <write_head+0x3e>
  }
  bwrite(buf);
    80004500:	8526                	mv	a0,s1
    80004502:	fffff097          	auipc	ra,0xfffff
    80004506:	0ae080e7          	jalr	174(ra) # 800035b0 <bwrite>
  brelse(buf);
    8000450a:	8526                	mv	a0,s1
    8000450c:	fffff097          	auipc	ra,0xfffff
    80004510:	0e2080e7          	jalr	226(ra) # 800035ee <brelse>
}
    80004514:	60e2                	ld	ra,24(sp)
    80004516:	6442                	ld	s0,16(sp)
    80004518:	64a2                	ld	s1,8(sp)
    8000451a:	6902                	ld	s2,0(sp)
    8000451c:	6105                	addi	sp,sp,32
    8000451e:	8082                	ret

0000000080004520 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004520:	00021797          	auipc	a5,0x21
    80004524:	57c7a783          	lw	a5,1404(a5) # 80025a9c <log+0x2c>
    80004528:	0cf05063          	blez	a5,800045e8 <install_trans+0xc8>
{
    8000452c:	715d                	addi	sp,sp,-80
    8000452e:	e486                	sd	ra,72(sp)
    80004530:	e0a2                	sd	s0,64(sp)
    80004532:	fc26                	sd	s1,56(sp)
    80004534:	f84a                	sd	s2,48(sp)
    80004536:	f44e                	sd	s3,40(sp)
    80004538:	f052                	sd	s4,32(sp)
    8000453a:	ec56                	sd	s5,24(sp)
    8000453c:	e85a                	sd	s6,16(sp)
    8000453e:	e45e                	sd	s7,8(sp)
    80004540:	0880                	addi	s0,sp,80
    80004542:	8b2a                	mv	s6,a0
    80004544:	00021a97          	auipc	s5,0x21
    80004548:	55ca8a93          	addi	s5,s5,1372 # 80025aa0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000454c:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000454e:	00021997          	auipc	s3,0x21
    80004552:	52298993          	addi	s3,s3,1314 # 80025a70 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004556:	40000b93          	li	s7,1024
    8000455a:	a00d                	j	8000457c <install_trans+0x5c>
    brelse(lbuf);
    8000455c:	854a                	mv	a0,s2
    8000455e:	fffff097          	auipc	ra,0xfffff
    80004562:	090080e7          	jalr	144(ra) # 800035ee <brelse>
    brelse(dbuf);
    80004566:	8526                	mv	a0,s1
    80004568:	fffff097          	auipc	ra,0xfffff
    8000456c:	086080e7          	jalr	134(ra) # 800035ee <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004570:	2a05                	addiw	s4,s4,1
    80004572:	0a91                	addi	s5,s5,4
    80004574:	02c9a783          	lw	a5,44(s3)
    80004578:	04fa5d63          	bge	s4,a5,800045d2 <install_trans+0xb2>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000457c:	0189a583          	lw	a1,24(s3)
    80004580:	014585bb          	addw	a1,a1,s4
    80004584:	2585                	addiw	a1,a1,1
    80004586:	0289a503          	lw	a0,40(s3)
    8000458a:	fffff097          	auipc	ra,0xfffff
    8000458e:	f34080e7          	jalr	-204(ra) # 800034be <bread>
    80004592:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004594:	000aa583          	lw	a1,0(s5)
    80004598:	0289a503          	lw	a0,40(s3)
    8000459c:	fffff097          	auipc	ra,0xfffff
    800045a0:	f22080e7          	jalr	-222(ra) # 800034be <bread>
    800045a4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800045a6:	865e                	mv	a2,s7
    800045a8:	05890593          	addi	a1,s2,88
    800045ac:	05850513          	addi	a0,a0,88
    800045b0:	ffffc097          	auipc	ra,0xffffc
    800045b4:	7fc080e7          	jalr	2044(ra) # 80000dac <memmove>
    bwrite(dbuf);  // write dst to disk
    800045b8:	8526                	mv	a0,s1
    800045ba:	fffff097          	auipc	ra,0xfffff
    800045be:	ff6080e7          	jalr	-10(ra) # 800035b0 <bwrite>
    if(recovering == 0)
    800045c2:	f80b1de3          	bnez	s6,8000455c <install_trans+0x3c>
      bunpin(dbuf);
    800045c6:	8526                	mv	a0,s1
    800045c8:	fffff097          	auipc	ra,0xfffff
    800045cc:	0fa080e7          	jalr	250(ra) # 800036c2 <bunpin>
    800045d0:	b771                	j	8000455c <install_trans+0x3c>
}
    800045d2:	60a6                	ld	ra,72(sp)
    800045d4:	6406                	ld	s0,64(sp)
    800045d6:	74e2                	ld	s1,56(sp)
    800045d8:	7942                	ld	s2,48(sp)
    800045da:	79a2                	ld	s3,40(sp)
    800045dc:	7a02                	ld	s4,32(sp)
    800045de:	6ae2                	ld	s5,24(sp)
    800045e0:	6b42                	ld	s6,16(sp)
    800045e2:	6ba2                	ld	s7,8(sp)
    800045e4:	6161                	addi	sp,sp,80
    800045e6:	8082                	ret
    800045e8:	8082                	ret

00000000800045ea <initlog>:
{
    800045ea:	7179                	addi	sp,sp,-48
    800045ec:	f406                	sd	ra,40(sp)
    800045ee:	f022                	sd	s0,32(sp)
    800045f0:	ec26                	sd	s1,24(sp)
    800045f2:	e84a                	sd	s2,16(sp)
    800045f4:	e44e                	sd	s3,8(sp)
    800045f6:	1800                	addi	s0,sp,48
    800045f8:	892a                	mv	s2,a0
    800045fa:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800045fc:	00021497          	auipc	s1,0x21
    80004600:	47448493          	addi	s1,s1,1140 # 80025a70 <log>
    80004604:	00004597          	auipc	a1,0x4
    80004608:	00458593          	addi	a1,a1,4 # 80008608 <etext+0x608>
    8000460c:	8526                	mv	a0,s1
    8000460e:	ffffc097          	auipc	ra,0xffffc
    80004612:	5ac080e7          	jalr	1452(ra) # 80000bba <initlock>
  log.start = sb->logstart;
    80004616:	0149a583          	lw	a1,20(s3)
    8000461a:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000461c:	0109a783          	lw	a5,16(s3)
    80004620:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004622:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004626:	854a                	mv	a0,s2
    80004628:	fffff097          	auipc	ra,0xfffff
    8000462c:	e96080e7          	jalr	-362(ra) # 800034be <bread>
  log.lh.n = lh->n;
    80004630:	4d30                	lw	a2,88(a0)
    80004632:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004634:	00c05f63          	blez	a2,80004652 <initlog+0x68>
    80004638:	87aa                	mv	a5,a0
    8000463a:	00021717          	auipc	a4,0x21
    8000463e:	46670713          	addi	a4,a4,1126 # 80025aa0 <log+0x30>
    80004642:	060a                	slli	a2,a2,0x2
    80004644:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004646:	4ff4                	lw	a3,92(a5)
    80004648:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000464a:	0791                	addi	a5,a5,4
    8000464c:	0711                	addi	a4,a4,4
    8000464e:	fec79ce3          	bne	a5,a2,80004646 <initlog+0x5c>
  brelse(buf);
    80004652:	fffff097          	auipc	ra,0xfffff
    80004656:	f9c080e7          	jalr	-100(ra) # 800035ee <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000465a:	4505                	li	a0,1
    8000465c:	00000097          	auipc	ra,0x0
    80004660:	ec4080e7          	jalr	-316(ra) # 80004520 <install_trans>
  log.lh.n = 0;
    80004664:	00021797          	auipc	a5,0x21
    80004668:	4207ac23          	sw	zero,1080(a5) # 80025a9c <log+0x2c>
  write_head(); // clear the log
    8000466c:	00000097          	auipc	ra,0x0
    80004670:	e4a080e7          	jalr	-438(ra) # 800044b6 <write_head>
}
    80004674:	70a2                	ld	ra,40(sp)
    80004676:	7402                	ld	s0,32(sp)
    80004678:	64e2                	ld	s1,24(sp)
    8000467a:	6942                	ld	s2,16(sp)
    8000467c:	69a2                	ld	s3,8(sp)
    8000467e:	6145                	addi	sp,sp,48
    80004680:	8082                	ret

0000000080004682 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004682:	1101                	addi	sp,sp,-32
    80004684:	ec06                	sd	ra,24(sp)
    80004686:	e822                	sd	s0,16(sp)
    80004688:	e426                	sd	s1,8(sp)
    8000468a:	e04a                	sd	s2,0(sp)
    8000468c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000468e:	00021517          	auipc	a0,0x21
    80004692:	3e250513          	addi	a0,a0,994 # 80025a70 <log>
    80004696:	ffffc097          	auipc	ra,0xffffc
    8000469a:	5be080e7          	jalr	1470(ra) # 80000c54 <acquire>
  while(1){
    if(log.committing){
    8000469e:	00021497          	auipc	s1,0x21
    800046a2:	3d248493          	addi	s1,s1,978 # 80025a70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800046a6:	4979                	li	s2,30
    800046a8:	a039                	j	800046b6 <begin_op+0x34>
      sleep(&log, &log.lock);
    800046aa:	85a6                	mv	a1,s1
    800046ac:	8526                	mv	a0,s1
    800046ae:	ffffe097          	auipc	ra,0xffffe
    800046b2:	be6080e7          	jalr	-1050(ra) # 80002294 <sleep>
    if(log.committing){
    800046b6:	50dc                	lw	a5,36(s1)
    800046b8:	fbed                	bnez	a5,800046aa <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800046ba:	5098                	lw	a4,32(s1)
    800046bc:	2705                	addiw	a4,a4,1
    800046be:	0027179b          	slliw	a5,a4,0x2
    800046c2:	9fb9                	addw	a5,a5,a4
    800046c4:	0017979b          	slliw	a5,a5,0x1
    800046c8:	54d4                	lw	a3,44(s1)
    800046ca:	9fb5                	addw	a5,a5,a3
    800046cc:	00f95963          	bge	s2,a5,800046de <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800046d0:	85a6                	mv	a1,s1
    800046d2:	8526                	mv	a0,s1
    800046d4:	ffffe097          	auipc	ra,0xffffe
    800046d8:	bc0080e7          	jalr	-1088(ra) # 80002294 <sleep>
    800046dc:	bfe9                	j	800046b6 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800046de:	00021797          	auipc	a5,0x21
    800046e2:	3ae7a923          	sw	a4,946(a5) # 80025a90 <log+0x20>
      release(&log.lock);
    800046e6:	00021517          	auipc	a0,0x21
    800046ea:	38a50513          	addi	a0,a0,906 # 80025a70 <log>
    800046ee:	ffffc097          	auipc	ra,0xffffc
    800046f2:	616080e7          	jalr	1558(ra) # 80000d04 <release>
      break;
    }
  }
}
    800046f6:	60e2                	ld	ra,24(sp)
    800046f8:	6442                	ld	s0,16(sp)
    800046fa:	64a2                	ld	s1,8(sp)
    800046fc:	6902                	ld	s2,0(sp)
    800046fe:	6105                	addi	sp,sp,32
    80004700:	8082                	ret

0000000080004702 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004702:	7139                	addi	sp,sp,-64
    80004704:	fc06                	sd	ra,56(sp)
    80004706:	f822                	sd	s0,48(sp)
    80004708:	f426                	sd	s1,40(sp)
    8000470a:	f04a                	sd	s2,32(sp)
    8000470c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000470e:	00021497          	auipc	s1,0x21
    80004712:	36248493          	addi	s1,s1,866 # 80025a70 <log>
    80004716:	8526                	mv	a0,s1
    80004718:	ffffc097          	auipc	ra,0xffffc
    8000471c:	53c080e7          	jalr	1340(ra) # 80000c54 <acquire>
  log.outstanding -= 1;
    80004720:	509c                	lw	a5,32(s1)
    80004722:	37fd                	addiw	a5,a5,-1
    80004724:	893e                	mv	s2,a5
    80004726:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004728:	50dc                	lw	a5,36(s1)
    8000472a:	efb1                	bnez	a5,80004786 <end_op+0x84>
    panic("log.committing");
  if(log.outstanding == 0){
    8000472c:	06091863          	bnez	s2,8000479c <end_op+0x9a>
    do_commit = 1;
    log.committing = 1;
    80004730:	00021497          	auipc	s1,0x21
    80004734:	34048493          	addi	s1,s1,832 # 80025a70 <log>
    80004738:	4785                	li	a5,1
    8000473a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000473c:	8526                	mv	a0,s1
    8000473e:	ffffc097          	auipc	ra,0xffffc
    80004742:	5c6080e7          	jalr	1478(ra) # 80000d04 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004746:	54dc                	lw	a5,44(s1)
    80004748:	08f04063          	bgtz	a5,800047c8 <end_op+0xc6>
    acquire(&log.lock);
    8000474c:	00021517          	auipc	a0,0x21
    80004750:	32450513          	addi	a0,a0,804 # 80025a70 <log>
    80004754:	ffffc097          	auipc	ra,0xffffc
    80004758:	500080e7          	jalr	1280(ra) # 80000c54 <acquire>
    log.committing = 0;
    8000475c:	00021797          	auipc	a5,0x21
    80004760:	3207ac23          	sw	zero,824(a5) # 80025a94 <log+0x24>
    wakeup(&log);
    80004764:	00021517          	auipc	a0,0x21
    80004768:	30c50513          	addi	a0,a0,780 # 80025a70 <log>
    8000476c:	ffffe097          	auipc	ra,0xffffe
    80004770:	cae080e7          	jalr	-850(ra) # 8000241a <wakeup>
    release(&log.lock);
    80004774:	00021517          	auipc	a0,0x21
    80004778:	2fc50513          	addi	a0,a0,764 # 80025a70 <log>
    8000477c:	ffffc097          	auipc	ra,0xffffc
    80004780:	588080e7          	jalr	1416(ra) # 80000d04 <release>
}
    80004784:	a825                	j	800047bc <end_op+0xba>
    80004786:	ec4e                	sd	s3,24(sp)
    80004788:	e852                	sd	s4,16(sp)
    8000478a:	e456                	sd	s5,8(sp)
    panic("log.committing");
    8000478c:	00004517          	auipc	a0,0x4
    80004790:	e8450513          	addi	a0,a0,-380 # 80008610 <etext+0x610>
    80004794:	ffffc097          	auipc	ra,0xffffc
    80004798:	dc2080e7          	jalr	-574(ra) # 80000556 <panic>
    wakeup(&log);
    8000479c:	00021517          	auipc	a0,0x21
    800047a0:	2d450513          	addi	a0,a0,724 # 80025a70 <log>
    800047a4:	ffffe097          	auipc	ra,0xffffe
    800047a8:	c76080e7          	jalr	-906(ra) # 8000241a <wakeup>
  release(&log.lock);
    800047ac:	00021517          	auipc	a0,0x21
    800047b0:	2c450513          	addi	a0,a0,708 # 80025a70 <log>
    800047b4:	ffffc097          	auipc	ra,0xffffc
    800047b8:	550080e7          	jalr	1360(ra) # 80000d04 <release>
}
    800047bc:	70e2                	ld	ra,56(sp)
    800047be:	7442                	ld	s0,48(sp)
    800047c0:	74a2                	ld	s1,40(sp)
    800047c2:	7902                	ld	s2,32(sp)
    800047c4:	6121                	addi	sp,sp,64
    800047c6:	8082                	ret
    800047c8:	ec4e                	sd	s3,24(sp)
    800047ca:	e852                	sd	s4,16(sp)
    800047cc:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800047ce:	00021a97          	auipc	s5,0x21
    800047d2:	2d2a8a93          	addi	s5,s5,722 # 80025aa0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800047d6:	00021a17          	auipc	s4,0x21
    800047da:	29aa0a13          	addi	s4,s4,666 # 80025a70 <log>
    800047de:	018a2583          	lw	a1,24(s4)
    800047e2:	012585bb          	addw	a1,a1,s2
    800047e6:	2585                	addiw	a1,a1,1
    800047e8:	028a2503          	lw	a0,40(s4)
    800047ec:	fffff097          	auipc	ra,0xfffff
    800047f0:	cd2080e7          	jalr	-814(ra) # 800034be <bread>
    800047f4:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800047f6:	000aa583          	lw	a1,0(s5)
    800047fa:	028a2503          	lw	a0,40(s4)
    800047fe:	fffff097          	auipc	ra,0xfffff
    80004802:	cc0080e7          	jalr	-832(ra) # 800034be <bread>
    80004806:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004808:	40000613          	li	a2,1024
    8000480c:	05850593          	addi	a1,a0,88
    80004810:	05848513          	addi	a0,s1,88
    80004814:	ffffc097          	auipc	ra,0xffffc
    80004818:	598080e7          	jalr	1432(ra) # 80000dac <memmove>
    bwrite(to);  // write the log
    8000481c:	8526                	mv	a0,s1
    8000481e:	fffff097          	auipc	ra,0xfffff
    80004822:	d92080e7          	jalr	-622(ra) # 800035b0 <bwrite>
    brelse(from);
    80004826:	854e                	mv	a0,s3
    80004828:	fffff097          	auipc	ra,0xfffff
    8000482c:	dc6080e7          	jalr	-570(ra) # 800035ee <brelse>
    brelse(to);
    80004830:	8526                	mv	a0,s1
    80004832:	fffff097          	auipc	ra,0xfffff
    80004836:	dbc080e7          	jalr	-580(ra) # 800035ee <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000483a:	2905                	addiw	s2,s2,1
    8000483c:	0a91                	addi	s5,s5,4
    8000483e:	02ca2783          	lw	a5,44(s4)
    80004842:	f8f94ee3          	blt	s2,a5,800047de <end_op+0xdc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004846:	00000097          	auipc	ra,0x0
    8000484a:	c70080e7          	jalr	-912(ra) # 800044b6 <write_head>
    install_trans(0); // Now install writes to home locations
    8000484e:	4501                	li	a0,0
    80004850:	00000097          	auipc	ra,0x0
    80004854:	cd0080e7          	jalr	-816(ra) # 80004520 <install_trans>
    log.lh.n = 0;
    80004858:	00021797          	auipc	a5,0x21
    8000485c:	2407a223          	sw	zero,580(a5) # 80025a9c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004860:	00000097          	auipc	ra,0x0
    80004864:	c56080e7          	jalr	-938(ra) # 800044b6 <write_head>
    80004868:	69e2                	ld	s3,24(sp)
    8000486a:	6a42                	ld	s4,16(sp)
    8000486c:	6aa2                	ld	s5,8(sp)
    8000486e:	bdf9                	j	8000474c <end_op+0x4a>

0000000080004870 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004870:	1101                	addi	sp,sp,-32
    80004872:	ec06                	sd	ra,24(sp)
    80004874:	e822                	sd	s0,16(sp)
    80004876:	e426                	sd	s1,8(sp)
    80004878:	1000                	addi	s0,sp,32
    8000487a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000487c:	00021517          	auipc	a0,0x21
    80004880:	1f450513          	addi	a0,a0,500 # 80025a70 <log>
    80004884:	ffffc097          	auipc	ra,0xffffc
    80004888:	3d0080e7          	jalr	976(ra) # 80000c54 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000488c:	00021617          	auipc	a2,0x21
    80004890:	21062603          	lw	a2,528(a2) # 80025a9c <log+0x2c>
    80004894:	47f5                	li	a5,29
    80004896:	06c7c663          	blt	a5,a2,80004902 <log_write+0x92>
    8000489a:	00021797          	auipc	a5,0x21
    8000489e:	1f27a783          	lw	a5,498(a5) # 80025a8c <log+0x1c>
    800048a2:	37fd                	addiw	a5,a5,-1
    800048a4:	04f65f63          	bge	a2,a5,80004902 <log_write+0x92>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800048a8:	00021797          	auipc	a5,0x21
    800048ac:	1e87a783          	lw	a5,488(a5) # 80025a90 <log+0x20>
    800048b0:	06f05163          	blez	a5,80004912 <log_write+0xa2>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800048b4:	4781                	li	a5,0
    800048b6:	06c05663          	blez	a2,80004922 <log_write+0xb2>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800048ba:	44cc                	lw	a1,12(s1)
    800048bc:	00021717          	auipc	a4,0x21
    800048c0:	1e470713          	addi	a4,a4,484 # 80025aa0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800048c4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800048c6:	4314                	lw	a3,0(a4)
    800048c8:	04b68d63          	beq	a3,a1,80004922 <log_write+0xb2>
  for (i = 0; i < log.lh.n; i++) {
    800048cc:	2785                	addiw	a5,a5,1
    800048ce:	0711                	addi	a4,a4,4
    800048d0:	fef61be3          	bne	a2,a5,800048c6 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800048d4:	060a                	slli	a2,a2,0x2
    800048d6:	02060613          	addi	a2,a2,32
    800048da:	00021797          	auipc	a5,0x21
    800048de:	19678793          	addi	a5,a5,406 # 80025a70 <log>
    800048e2:	97b2                	add	a5,a5,a2
    800048e4:	44d8                	lw	a4,12(s1)
    800048e6:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800048e8:	8526                	mv	a0,s1
    800048ea:	fffff097          	auipc	ra,0xfffff
    800048ee:	d9c080e7          	jalr	-612(ra) # 80003686 <bpin>
    log.lh.n++;
    800048f2:	00021717          	auipc	a4,0x21
    800048f6:	17e70713          	addi	a4,a4,382 # 80025a70 <log>
    800048fa:	575c                	lw	a5,44(a4)
    800048fc:	2785                	addiw	a5,a5,1
    800048fe:	d75c                	sw	a5,44(a4)
    80004900:	a835                	j	8000493c <log_write+0xcc>
    panic("too big a transaction");
    80004902:	00004517          	auipc	a0,0x4
    80004906:	d1e50513          	addi	a0,a0,-738 # 80008620 <etext+0x620>
    8000490a:	ffffc097          	auipc	ra,0xffffc
    8000490e:	c4c080e7          	jalr	-948(ra) # 80000556 <panic>
    panic("log_write outside of trans");
    80004912:	00004517          	auipc	a0,0x4
    80004916:	d2650513          	addi	a0,a0,-730 # 80008638 <etext+0x638>
    8000491a:	ffffc097          	auipc	ra,0xffffc
    8000491e:	c3c080e7          	jalr	-964(ra) # 80000556 <panic>
  log.lh.block[i] = b->blockno;
    80004922:	00279693          	slli	a3,a5,0x2
    80004926:	02068693          	addi	a3,a3,32
    8000492a:	00021717          	auipc	a4,0x21
    8000492e:	14670713          	addi	a4,a4,326 # 80025a70 <log>
    80004932:	9736                	add	a4,a4,a3
    80004934:	44d4                	lw	a3,12(s1)
    80004936:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004938:	faf608e3          	beq	a2,a5,800048e8 <log_write+0x78>
  }
  release(&log.lock);
    8000493c:	00021517          	auipc	a0,0x21
    80004940:	13450513          	addi	a0,a0,308 # 80025a70 <log>
    80004944:	ffffc097          	auipc	ra,0xffffc
    80004948:	3c0080e7          	jalr	960(ra) # 80000d04 <release>
}
    8000494c:	60e2                	ld	ra,24(sp)
    8000494e:	6442                	ld	s0,16(sp)
    80004950:	64a2                	ld	s1,8(sp)
    80004952:	6105                	addi	sp,sp,32
    80004954:	8082                	ret

0000000080004956 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004956:	1101                	addi	sp,sp,-32
    80004958:	ec06                	sd	ra,24(sp)
    8000495a:	e822                	sd	s0,16(sp)
    8000495c:	e426                	sd	s1,8(sp)
    8000495e:	e04a                	sd	s2,0(sp)
    80004960:	1000                	addi	s0,sp,32
    80004962:	84aa                	mv	s1,a0
    80004964:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004966:	00004597          	auipc	a1,0x4
    8000496a:	cf258593          	addi	a1,a1,-782 # 80008658 <etext+0x658>
    8000496e:	0521                	addi	a0,a0,8
    80004970:	ffffc097          	auipc	ra,0xffffc
    80004974:	24a080e7          	jalr	586(ra) # 80000bba <initlock>
  lk->name = name;
    80004978:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000497c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004980:	0204a423          	sw	zero,40(s1)
}
    80004984:	60e2                	ld	ra,24(sp)
    80004986:	6442                	ld	s0,16(sp)
    80004988:	64a2                	ld	s1,8(sp)
    8000498a:	6902                	ld	s2,0(sp)
    8000498c:	6105                	addi	sp,sp,32
    8000498e:	8082                	ret

0000000080004990 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004990:	1101                	addi	sp,sp,-32
    80004992:	ec06                	sd	ra,24(sp)
    80004994:	e822                	sd	s0,16(sp)
    80004996:	e426                	sd	s1,8(sp)
    80004998:	e04a                	sd	s2,0(sp)
    8000499a:	1000                	addi	s0,sp,32
    8000499c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000499e:	00850913          	addi	s2,a0,8
    800049a2:	854a                	mv	a0,s2
    800049a4:	ffffc097          	auipc	ra,0xffffc
    800049a8:	2b0080e7          	jalr	688(ra) # 80000c54 <acquire>
  while (lk->locked) {
    800049ac:	409c                	lw	a5,0(s1)
    800049ae:	cb89                	beqz	a5,800049c0 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800049b0:	85ca                	mv	a1,s2
    800049b2:	8526                	mv	a0,s1
    800049b4:	ffffe097          	auipc	ra,0xffffe
    800049b8:	8e0080e7          	jalr	-1824(ra) # 80002294 <sleep>
  while (lk->locked) {
    800049bc:	409c                	lw	a5,0(s1)
    800049be:	fbed                	bnez	a5,800049b0 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800049c0:	4785                	li	a5,1
    800049c2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800049c4:	ffffd097          	auipc	ra,0xffffd
    800049c8:	0c2080e7          	jalr	194(ra) # 80001a86 <myproc>
    800049cc:	591c                	lw	a5,48(a0)
    800049ce:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800049d0:	854a                	mv	a0,s2
    800049d2:	ffffc097          	auipc	ra,0xffffc
    800049d6:	332080e7          	jalr	818(ra) # 80000d04 <release>
}
    800049da:	60e2                	ld	ra,24(sp)
    800049dc:	6442                	ld	s0,16(sp)
    800049de:	64a2                	ld	s1,8(sp)
    800049e0:	6902                	ld	s2,0(sp)
    800049e2:	6105                	addi	sp,sp,32
    800049e4:	8082                	ret

00000000800049e6 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800049e6:	1101                	addi	sp,sp,-32
    800049e8:	ec06                	sd	ra,24(sp)
    800049ea:	e822                	sd	s0,16(sp)
    800049ec:	e426                	sd	s1,8(sp)
    800049ee:	e04a                	sd	s2,0(sp)
    800049f0:	1000                	addi	s0,sp,32
    800049f2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800049f4:	00850913          	addi	s2,a0,8
    800049f8:	854a                	mv	a0,s2
    800049fa:	ffffc097          	auipc	ra,0xffffc
    800049fe:	25a080e7          	jalr	602(ra) # 80000c54 <acquire>
  lk->locked = 0;
    80004a02:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a06:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004a0a:	8526                	mv	a0,s1
    80004a0c:	ffffe097          	auipc	ra,0xffffe
    80004a10:	a0e080e7          	jalr	-1522(ra) # 8000241a <wakeup>
  release(&lk->lk);
    80004a14:	854a                	mv	a0,s2
    80004a16:	ffffc097          	auipc	ra,0xffffc
    80004a1a:	2ee080e7          	jalr	750(ra) # 80000d04 <release>
}
    80004a1e:	60e2                	ld	ra,24(sp)
    80004a20:	6442                	ld	s0,16(sp)
    80004a22:	64a2                	ld	s1,8(sp)
    80004a24:	6902                	ld	s2,0(sp)
    80004a26:	6105                	addi	sp,sp,32
    80004a28:	8082                	ret

0000000080004a2a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004a2a:	7179                	addi	sp,sp,-48
    80004a2c:	f406                	sd	ra,40(sp)
    80004a2e:	f022                	sd	s0,32(sp)
    80004a30:	ec26                	sd	s1,24(sp)
    80004a32:	e84a                	sd	s2,16(sp)
    80004a34:	1800                	addi	s0,sp,48
    80004a36:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004a38:	00850913          	addi	s2,a0,8
    80004a3c:	854a                	mv	a0,s2
    80004a3e:	ffffc097          	auipc	ra,0xffffc
    80004a42:	216080e7          	jalr	534(ra) # 80000c54 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a46:	409c                	lw	a5,0(s1)
    80004a48:	ef91                	bnez	a5,80004a64 <holdingsleep+0x3a>
    80004a4a:	4481                	li	s1,0
  release(&lk->lk);
    80004a4c:	854a                	mv	a0,s2
    80004a4e:	ffffc097          	auipc	ra,0xffffc
    80004a52:	2b6080e7          	jalr	694(ra) # 80000d04 <release>
  return r;
}
    80004a56:	8526                	mv	a0,s1
    80004a58:	70a2                	ld	ra,40(sp)
    80004a5a:	7402                	ld	s0,32(sp)
    80004a5c:	64e2                	ld	s1,24(sp)
    80004a5e:	6942                	ld	s2,16(sp)
    80004a60:	6145                	addi	sp,sp,48
    80004a62:	8082                	ret
    80004a64:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a66:	0284a983          	lw	s3,40(s1)
    80004a6a:	ffffd097          	auipc	ra,0xffffd
    80004a6e:	01c080e7          	jalr	28(ra) # 80001a86 <myproc>
    80004a72:	5904                	lw	s1,48(a0)
    80004a74:	413484b3          	sub	s1,s1,s3
    80004a78:	0014b493          	seqz	s1,s1
    80004a7c:	69a2                	ld	s3,8(sp)
    80004a7e:	b7f9                	j	80004a4c <holdingsleep+0x22>

0000000080004a80 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004a80:	1141                	addi	sp,sp,-16
    80004a82:	e406                	sd	ra,8(sp)
    80004a84:	e022                	sd	s0,0(sp)
    80004a86:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004a88:	00004597          	auipc	a1,0x4
    80004a8c:	be058593          	addi	a1,a1,-1056 # 80008668 <etext+0x668>
    80004a90:	00021517          	auipc	a0,0x21
    80004a94:	12850513          	addi	a0,a0,296 # 80025bb8 <ftable>
    80004a98:	ffffc097          	auipc	ra,0xffffc
    80004a9c:	122080e7          	jalr	290(ra) # 80000bba <initlock>
}
    80004aa0:	60a2                	ld	ra,8(sp)
    80004aa2:	6402                	ld	s0,0(sp)
    80004aa4:	0141                	addi	sp,sp,16
    80004aa6:	8082                	ret

0000000080004aa8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004aa8:	1101                	addi	sp,sp,-32
    80004aaa:	ec06                	sd	ra,24(sp)
    80004aac:	e822                	sd	s0,16(sp)
    80004aae:	e426                	sd	s1,8(sp)
    80004ab0:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004ab2:	00021517          	auipc	a0,0x21
    80004ab6:	10650513          	addi	a0,a0,262 # 80025bb8 <ftable>
    80004aba:	ffffc097          	auipc	ra,0xffffc
    80004abe:	19a080e7          	jalr	410(ra) # 80000c54 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004ac2:	00021497          	auipc	s1,0x21
    80004ac6:	10e48493          	addi	s1,s1,270 # 80025bd0 <ftable+0x18>
    80004aca:	00022717          	auipc	a4,0x22
    80004ace:	0a670713          	addi	a4,a4,166 # 80026b70 <ftable+0xfb8>
    if(f->ref == 0){
    80004ad2:	40dc                	lw	a5,4(s1)
    80004ad4:	cf99                	beqz	a5,80004af2 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004ad6:	02848493          	addi	s1,s1,40
    80004ada:	fee49ce3          	bne	s1,a4,80004ad2 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004ade:	00021517          	auipc	a0,0x21
    80004ae2:	0da50513          	addi	a0,a0,218 # 80025bb8 <ftable>
    80004ae6:	ffffc097          	auipc	ra,0xffffc
    80004aea:	21e080e7          	jalr	542(ra) # 80000d04 <release>
  return 0;
    80004aee:	4481                	li	s1,0
    80004af0:	a819                	j	80004b06 <filealloc+0x5e>
      f->ref = 1;
    80004af2:	4785                	li	a5,1
    80004af4:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004af6:	00021517          	auipc	a0,0x21
    80004afa:	0c250513          	addi	a0,a0,194 # 80025bb8 <ftable>
    80004afe:	ffffc097          	auipc	ra,0xffffc
    80004b02:	206080e7          	jalr	518(ra) # 80000d04 <release>
}
    80004b06:	8526                	mv	a0,s1
    80004b08:	60e2                	ld	ra,24(sp)
    80004b0a:	6442                	ld	s0,16(sp)
    80004b0c:	64a2                	ld	s1,8(sp)
    80004b0e:	6105                	addi	sp,sp,32
    80004b10:	8082                	ret

0000000080004b12 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004b12:	1101                	addi	sp,sp,-32
    80004b14:	ec06                	sd	ra,24(sp)
    80004b16:	e822                	sd	s0,16(sp)
    80004b18:	e426                	sd	s1,8(sp)
    80004b1a:	1000                	addi	s0,sp,32
    80004b1c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004b1e:	00021517          	auipc	a0,0x21
    80004b22:	09a50513          	addi	a0,a0,154 # 80025bb8 <ftable>
    80004b26:	ffffc097          	auipc	ra,0xffffc
    80004b2a:	12e080e7          	jalr	302(ra) # 80000c54 <acquire>
  if(f->ref < 1)
    80004b2e:	40dc                	lw	a5,4(s1)
    80004b30:	02f05263          	blez	a5,80004b54 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004b34:	2785                	addiw	a5,a5,1
    80004b36:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004b38:	00021517          	auipc	a0,0x21
    80004b3c:	08050513          	addi	a0,a0,128 # 80025bb8 <ftable>
    80004b40:	ffffc097          	auipc	ra,0xffffc
    80004b44:	1c4080e7          	jalr	452(ra) # 80000d04 <release>
  return f;
}
    80004b48:	8526                	mv	a0,s1
    80004b4a:	60e2                	ld	ra,24(sp)
    80004b4c:	6442                	ld	s0,16(sp)
    80004b4e:	64a2                	ld	s1,8(sp)
    80004b50:	6105                	addi	sp,sp,32
    80004b52:	8082                	ret
    panic("filedup");
    80004b54:	00004517          	auipc	a0,0x4
    80004b58:	b1c50513          	addi	a0,a0,-1252 # 80008670 <etext+0x670>
    80004b5c:	ffffc097          	auipc	ra,0xffffc
    80004b60:	9fa080e7          	jalr	-1542(ra) # 80000556 <panic>

0000000080004b64 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004b64:	7139                	addi	sp,sp,-64
    80004b66:	fc06                	sd	ra,56(sp)
    80004b68:	f822                	sd	s0,48(sp)
    80004b6a:	f426                	sd	s1,40(sp)
    80004b6c:	0080                	addi	s0,sp,64
    80004b6e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004b70:	00021517          	auipc	a0,0x21
    80004b74:	04850513          	addi	a0,a0,72 # 80025bb8 <ftable>
    80004b78:	ffffc097          	auipc	ra,0xffffc
    80004b7c:	0dc080e7          	jalr	220(ra) # 80000c54 <acquire>
  if(f->ref < 1)
    80004b80:	40dc                	lw	a5,4(s1)
    80004b82:	04f05c63          	blez	a5,80004bda <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    80004b86:	37fd                	addiw	a5,a5,-1
    80004b88:	c0dc                	sw	a5,4(s1)
    80004b8a:	06f04463          	bgtz	a5,80004bf2 <fileclose+0x8e>
    80004b8e:	f04a                	sd	s2,32(sp)
    80004b90:	ec4e                	sd	s3,24(sp)
    80004b92:	e852                	sd	s4,16(sp)
    80004b94:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004b96:	0004a903          	lw	s2,0(s1)
    80004b9a:	0094c783          	lbu	a5,9(s1)
    80004b9e:	89be                	mv	s3,a5
    80004ba0:	689c                	ld	a5,16(s1)
    80004ba2:	8a3e                	mv	s4,a5
    80004ba4:	6c9c                	ld	a5,24(s1)
    80004ba6:	8abe                	mv	s5,a5
  f->ref = 0;
    80004ba8:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004bac:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004bb0:	00021517          	auipc	a0,0x21
    80004bb4:	00850513          	addi	a0,a0,8 # 80025bb8 <ftable>
    80004bb8:	ffffc097          	auipc	ra,0xffffc
    80004bbc:	14c080e7          	jalr	332(ra) # 80000d04 <release>

  if(ff.type == FD_PIPE){
    80004bc0:	4785                	li	a5,1
    80004bc2:	04f90563          	beq	s2,a5,80004c0c <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004bc6:	ffe9079b          	addiw	a5,s2,-2
    80004bca:	4705                	li	a4,1
    80004bcc:	04f77b63          	bgeu	a4,a5,80004c22 <fileclose+0xbe>
    80004bd0:	7902                	ld	s2,32(sp)
    80004bd2:	69e2                	ld	s3,24(sp)
    80004bd4:	6a42                	ld	s4,16(sp)
    80004bd6:	6aa2                	ld	s5,8(sp)
    80004bd8:	a02d                	j	80004c02 <fileclose+0x9e>
    80004bda:	f04a                	sd	s2,32(sp)
    80004bdc:	ec4e                	sd	s3,24(sp)
    80004bde:	e852                	sd	s4,16(sp)
    80004be0:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004be2:	00004517          	auipc	a0,0x4
    80004be6:	a9650513          	addi	a0,a0,-1386 # 80008678 <etext+0x678>
    80004bea:	ffffc097          	auipc	ra,0xffffc
    80004bee:	96c080e7          	jalr	-1684(ra) # 80000556 <panic>
    release(&ftable.lock);
    80004bf2:	00021517          	auipc	a0,0x21
    80004bf6:	fc650513          	addi	a0,a0,-58 # 80025bb8 <ftable>
    80004bfa:	ffffc097          	auipc	ra,0xffffc
    80004bfe:	10a080e7          	jalr	266(ra) # 80000d04 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004c02:	70e2                	ld	ra,56(sp)
    80004c04:	7442                	ld	s0,48(sp)
    80004c06:	74a2                	ld	s1,40(sp)
    80004c08:	6121                	addi	sp,sp,64
    80004c0a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004c0c:	85ce                	mv	a1,s3
    80004c0e:	8552                	mv	a0,s4
    80004c10:	00000097          	auipc	ra,0x0
    80004c14:	3b4080e7          	jalr	948(ra) # 80004fc4 <pipeclose>
    80004c18:	7902                	ld	s2,32(sp)
    80004c1a:	69e2                	ld	s3,24(sp)
    80004c1c:	6a42                	ld	s4,16(sp)
    80004c1e:	6aa2                	ld	s5,8(sp)
    80004c20:	b7cd                	j	80004c02 <fileclose+0x9e>
    begin_op();
    80004c22:	00000097          	auipc	ra,0x0
    80004c26:	a60080e7          	jalr	-1440(ra) # 80004682 <begin_op>
    iput(ff.ip);
    80004c2a:	8556                	mv	a0,s5
    80004c2c:	fffff097          	auipc	ra,0xfffff
    80004c30:	21c080e7          	jalr	540(ra) # 80003e48 <iput>
    end_op();
    80004c34:	00000097          	auipc	ra,0x0
    80004c38:	ace080e7          	jalr	-1330(ra) # 80004702 <end_op>
    80004c3c:	7902                	ld	s2,32(sp)
    80004c3e:	69e2                	ld	s3,24(sp)
    80004c40:	6a42                	ld	s4,16(sp)
    80004c42:	6aa2                	ld	s5,8(sp)
    80004c44:	bf7d                	j	80004c02 <fileclose+0x9e>

0000000080004c46 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004c46:	715d                	addi	sp,sp,-80
    80004c48:	e486                	sd	ra,72(sp)
    80004c4a:	e0a2                	sd	s0,64(sp)
    80004c4c:	fc26                	sd	s1,56(sp)
    80004c4e:	f052                	sd	s4,32(sp)
    80004c50:	0880                	addi	s0,sp,80
    80004c52:	84aa                	mv	s1,a0
    80004c54:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004c56:	ffffd097          	auipc	ra,0xffffd
    80004c5a:	e30080e7          	jalr	-464(ra) # 80001a86 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004c5e:	409c                	lw	a5,0(s1)
    80004c60:	37f9                	addiw	a5,a5,-2
    80004c62:	4705                	li	a4,1
    80004c64:	04f76a63          	bltu	a4,a5,80004cb8 <filestat+0x72>
    80004c68:	f84a                	sd	s2,48(sp)
    80004c6a:	f44e                	sd	s3,40(sp)
    80004c6c:	89aa                	mv	s3,a0
    ilock(f->ip);
    80004c6e:	6c88                	ld	a0,24(s1)
    80004c70:	fffff097          	auipc	ra,0xfffff
    80004c74:	01a080e7          	jalr	26(ra) # 80003c8a <ilock>
    stati(f->ip, &st);
    80004c78:	fb840913          	addi	s2,s0,-72
    80004c7c:	85ca                	mv	a1,s2
    80004c7e:	6c88                	ld	a0,24(s1)
    80004c80:	fffff097          	auipc	ra,0xfffff
    80004c84:	29a080e7          	jalr	666(ra) # 80003f1a <stati>
    iunlock(f->ip);
    80004c88:	6c88                	ld	a0,24(s1)
    80004c8a:	fffff097          	auipc	ra,0xfffff
    80004c8e:	0c6080e7          	jalr	198(ra) # 80003d50 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004c92:	46e1                	li	a3,24
    80004c94:	864a                	mv	a2,s2
    80004c96:	85d2                	mv	a1,s4
    80004c98:	0509b503          	ld	a0,80(s3)
    80004c9c:	ffffd097          	auipc	ra,0xffffd
    80004ca0:	a6e080e7          	jalr	-1426(ra) # 8000170a <copyout>
    80004ca4:	41f5551b          	sraiw	a0,a0,0x1f
    80004ca8:	7942                	ld	s2,48(sp)
    80004caa:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004cac:	60a6                	ld	ra,72(sp)
    80004cae:	6406                	ld	s0,64(sp)
    80004cb0:	74e2                	ld	s1,56(sp)
    80004cb2:	7a02                	ld	s4,32(sp)
    80004cb4:	6161                	addi	sp,sp,80
    80004cb6:	8082                	ret
  return -1;
    80004cb8:	557d                	li	a0,-1
    80004cba:	bfcd                	j	80004cac <filestat+0x66>

0000000080004cbc <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004cbc:	7179                	addi	sp,sp,-48
    80004cbe:	f406                	sd	ra,40(sp)
    80004cc0:	f022                	sd	s0,32(sp)
    80004cc2:	e84a                	sd	s2,16(sp)
    80004cc4:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004cc6:	00854783          	lbu	a5,8(a0)
    80004cca:	cbc5                	beqz	a5,80004d7a <fileread+0xbe>
    80004ccc:	ec26                	sd	s1,24(sp)
    80004cce:	e44e                	sd	s3,8(sp)
    80004cd0:	84aa                	mv	s1,a0
    80004cd2:	892e                	mv	s2,a1
    80004cd4:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    80004cd6:	411c                	lw	a5,0(a0)
    80004cd8:	4705                	li	a4,1
    80004cda:	04e78963          	beq	a5,a4,80004d2c <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004cde:	470d                	li	a4,3
    80004ce0:	04e78f63          	beq	a5,a4,80004d3e <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004ce4:	4709                	li	a4,2
    80004ce6:	08e79263          	bne	a5,a4,80004d6a <fileread+0xae>
    ilock(f->ip);
    80004cea:	6d08                	ld	a0,24(a0)
    80004cec:	fffff097          	auipc	ra,0xfffff
    80004cf0:	f9e080e7          	jalr	-98(ra) # 80003c8a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004cf4:	874e                	mv	a4,s3
    80004cf6:	5094                	lw	a3,32(s1)
    80004cf8:	864a                	mv	a2,s2
    80004cfa:	4585                	li	a1,1
    80004cfc:	6c88                	ld	a0,24(s1)
    80004cfe:	fffff097          	auipc	ra,0xfffff
    80004d02:	24a080e7          	jalr	586(ra) # 80003f48 <readi>
    80004d06:	892a                	mv	s2,a0
    80004d08:	00a05563          	blez	a0,80004d12 <fileread+0x56>
      f->off += r;
    80004d0c:	509c                	lw	a5,32(s1)
    80004d0e:	9fa9                	addw	a5,a5,a0
    80004d10:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004d12:	6c88                	ld	a0,24(s1)
    80004d14:	fffff097          	auipc	ra,0xfffff
    80004d18:	03c080e7          	jalr	60(ra) # 80003d50 <iunlock>
    80004d1c:	64e2                	ld	s1,24(sp)
    80004d1e:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004d20:	854a                	mv	a0,s2
    80004d22:	70a2                	ld	ra,40(sp)
    80004d24:	7402                	ld	s0,32(sp)
    80004d26:	6942                	ld	s2,16(sp)
    80004d28:	6145                	addi	sp,sp,48
    80004d2a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004d2c:	6908                	ld	a0,16(a0)
    80004d2e:	00000097          	auipc	ra,0x0
    80004d32:	422080e7          	jalr	1058(ra) # 80005150 <piperead>
    80004d36:	892a                	mv	s2,a0
    80004d38:	64e2                	ld	s1,24(sp)
    80004d3a:	69a2                	ld	s3,8(sp)
    80004d3c:	b7d5                	j	80004d20 <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004d3e:	02451783          	lh	a5,36(a0)
    80004d42:	03079693          	slli	a3,a5,0x30
    80004d46:	92c1                	srli	a3,a3,0x30
    80004d48:	4725                	li	a4,9
    80004d4a:	02d76b63          	bltu	a4,a3,80004d80 <fileread+0xc4>
    80004d4e:	0792                	slli	a5,a5,0x4
    80004d50:	00021717          	auipc	a4,0x21
    80004d54:	dc870713          	addi	a4,a4,-568 # 80025b18 <devsw>
    80004d58:	97ba                	add	a5,a5,a4
    80004d5a:	639c                	ld	a5,0(a5)
    80004d5c:	c79d                	beqz	a5,80004d8a <fileread+0xce>
    r = devsw[f->major].read(1, addr, n);
    80004d5e:	4505                	li	a0,1
    80004d60:	9782                	jalr	a5
    80004d62:	892a                	mv	s2,a0
    80004d64:	64e2                	ld	s1,24(sp)
    80004d66:	69a2                	ld	s3,8(sp)
    80004d68:	bf65                	j	80004d20 <fileread+0x64>
    panic("fileread");
    80004d6a:	00004517          	auipc	a0,0x4
    80004d6e:	91e50513          	addi	a0,a0,-1762 # 80008688 <etext+0x688>
    80004d72:	ffffb097          	auipc	ra,0xffffb
    80004d76:	7e4080e7          	jalr	2020(ra) # 80000556 <panic>
    return -1;
    80004d7a:	57fd                	li	a5,-1
    80004d7c:	893e                	mv	s2,a5
    80004d7e:	b74d                	j	80004d20 <fileread+0x64>
      return -1;
    80004d80:	57fd                	li	a5,-1
    80004d82:	893e                	mv	s2,a5
    80004d84:	64e2                	ld	s1,24(sp)
    80004d86:	69a2                	ld	s3,8(sp)
    80004d88:	bf61                	j	80004d20 <fileread+0x64>
    80004d8a:	57fd                	li	a5,-1
    80004d8c:	893e                	mv	s2,a5
    80004d8e:	64e2                	ld	s1,24(sp)
    80004d90:	69a2                	ld	s3,8(sp)
    80004d92:	b779                	j	80004d20 <fileread+0x64>

0000000080004d94 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004d94:	00954783          	lbu	a5,9(a0)
    80004d98:	12078d63          	beqz	a5,80004ed2 <filewrite+0x13e>
{
    80004d9c:	711d                	addi	sp,sp,-96
    80004d9e:	ec86                	sd	ra,88(sp)
    80004da0:	e8a2                	sd	s0,80(sp)
    80004da2:	e0ca                	sd	s2,64(sp)
    80004da4:	f456                	sd	s5,40(sp)
    80004da6:	f05a                	sd	s6,32(sp)
    80004da8:	1080                	addi	s0,sp,96
    80004daa:	892a                	mv	s2,a0
    80004dac:	8b2e                	mv	s6,a1
    80004dae:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    80004db0:	411c                	lw	a5,0(a0)
    80004db2:	4705                	li	a4,1
    80004db4:	02e78a63          	beq	a5,a4,80004de8 <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004db8:	470d                	li	a4,3
    80004dba:	02e78d63          	beq	a5,a4,80004df4 <filewrite+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004dbe:	4709                	li	a4,2
    80004dc0:	0ee79b63          	bne	a5,a4,80004eb6 <filewrite+0x122>
    80004dc4:	f852                	sd	s4,48(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004dc6:	0cc05663          	blez	a2,80004e92 <filewrite+0xfe>
    80004dca:	e4a6                	sd	s1,72(sp)
    80004dcc:	fc4e                	sd	s3,56(sp)
    80004dce:	ec5e                	sd	s7,24(sp)
    80004dd0:	e862                	sd	s8,16(sp)
    80004dd2:	e466                	sd	s9,8(sp)
    int i = 0;
    80004dd4:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80004dd6:	6b85                	lui	s7,0x1
    80004dd8:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004ddc:	6785                	lui	a5,0x1
    80004dde:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80004de2:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004de4:	4c05                	li	s8,1
    80004de6:	a849                	j	80004e78 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004de8:	6908                	ld	a0,16(a0)
    80004dea:	00000097          	auipc	ra,0x0
    80004dee:	250080e7          	jalr	592(ra) # 8000503a <pipewrite>
    80004df2:	a85d                	j	80004ea8 <filewrite+0x114>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004df4:	02451783          	lh	a5,36(a0)
    80004df8:	03079693          	slli	a3,a5,0x30
    80004dfc:	92c1                	srli	a3,a3,0x30
    80004dfe:	4725                	li	a4,9
    80004e00:	0cd76b63          	bltu	a4,a3,80004ed6 <filewrite+0x142>
    80004e04:	0792                	slli	a5,a5,0x4
    80004e06:	00021717          	auipc	a4,0x21
    80004e0a:	d1270713          	addi	a4,a4,-750 # 80025b18 <devsw>
    80004e0e:	97ba                	add	a5,a5,a4
    80004e10:	679c                	ld	a5,8(a5)
    80004e12:	c7e1                	beqz	a5,80004eda <filewrite+0x146>
    ret = devsw[f->major].write(1, addr, n);
    80004e14:	4505                	li	a0,1
    80004e16:	9782                	jalr	a5
    80004e18:	a841                	j	80004ea8 <filewrite+0x114>
      if(n1 > max)
    80004e1a:	2981                	sext.w	s3,s3
      begin_op();
    80004e1c:	00000097          	auipc	ra,0x0
    80004e20:	866080e7          	jalr	-1946(ra) # 80004682 <begin_op>
      ilock(f->ip);
    80004e24:	01893503          	ld	a0,24(s2)
    80004e28:	fffff097          	auipc	ra,0xfffff
    80004e2c:	e62080e7          	jalr	-414(ra) # 80003c8a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004e30:	874e                	mv	a4,s3
    80004e32:	02092683          	lw	a3,32(s2)
    80004e36:	016a0633          	add	a2,s4,s6
    80004e3a:	85e2                	mv	a1,s8
    80004e3c:	01893503          	ld	a0,24(s2)
    80004e40:	fffff097          	auipc	ra,0xfffff
    80004e44:	202080e7          	jalr	514(ra) # 80004042 <writei>
    80004e48:	84aa                	mv	s1,a0
    80004e4a:	00a05763          	blez	a0,80004e58 <filewrite+0xc4>
        f->off += r;
    80004e4e:	02092783          	lw	a5,32(s2)
    80004e52:	9fa9                	addw	a5,a5,a0
    80004e54:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004e58:	01893503          	ld	a0,24(s2)
    80004e5c:	fffff097          	auipc	ra,0xfffff
    80004e60:	ef4080e7          	jalr	-268(ra) # 80003d50 <iunlock>
      end_op();
    80004e64:	00000097          	auipc	ra,0x0
    80004e68:	89e080e7          	jalr	-1890(ra) # 80004702 <end_op>

      if(r != n1){
    80004e6c:	02999563          	bne	s3,s1,80004e96 <filewrite+0x102>
        // error from writei
        break;
      }
      i += r;
    80004e70:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    80004e74:	015a5963          	bge	s4,s5,80004e86 <filewrite+0xf2>
      int n1 = n - i;
    80004e78:	414a87bb          	subw	a5,s5,s4
    80004e7c:	89be                	mv	s3,a5
      if(n1 > max)
    80004e7e:	f8fbdee3          	bge	s7,a5,80004e1a <filewrite+0x86>
    80004e82:	89e6                	mv	s3,s9
    80004e84:	bf59                	j	80004e1a <filewrite+0x86>
    80004e86:	64a6                	ld	s1,72(sp)
    80004e88:	79e2                	ld	s3,56(sp)
    80004e8a:	6be2                	ld	s7,24(sp)
    80004e8c:	6c42                	ld	s8,16(sp)
    80004e8e:	6ca2                	ld	s9,8(sp)
    80004e90:	a801                	j	80004ea0 <filewrite+0x10c>
    int i = 0;
    80004e92:	4a01                	li	s4,0
    80004e94:	a031                	j	80004ea0 <filewrite+0x10c>
    80004e96:	64a6                	ld	s1,72(sp)
    80004e98:	79e2                	ld	s3,56(sp)
    80004e9a:	6be2                	ld	s7,24(sp)
    80004e9c:	6c42                	ld	s8,16(sp)
    80004e9e:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004ea0:	034a9f63          	bne	s5,s4,80004ede <filewrite+0x14a>
    80004ea4:	8556                	mv	a0,s5
    80004ea6:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004ea8:	60e6                	ld	ra,88(sp)
    80004eaa:	6446                	ld	s0,80(sp)
    80004eac:	6906                	ld	s2,64(sp)
    80004eae:	7aa2                	ld	s5,40(sp)
    80004eb0:	7b02                	ld	s6,32(sp)
    80004eb2:	6125                	addi	sp,sp,96
    80004eb4:	8082                	ret
    80004eb6:	e4a6                	sd	s1,72(sp)
    80004eb8:	fc4e                	sd	s3,56(sp)
    80004eba:	f852                	sd	s4,48(sp)
    80004ebc:	ec5e                	sd	s7,24(sp)
    80004ebe:	e862                	sd	s8,16(sp)
    80004ec0:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004ec2:	00003517          	auipc	a0,0x3
    80004ec6:	7d650513          	addi	a0,a0,2006 # 80008698 <etext+0x698>
    80004eca:	ffffb097          	auipc	ra,0xffffb
    80004ece:	68c080e7          	jalr	1676(ra) # 80000556 <panic>
    return -1;
    80004ed2:	557d                	li	a0,-1
}
    80004ed4:	8082                	ret
      return -1;
    80004ed6:	557d                	li	a0,-1
    80004ed8:	bfc1                	j	80004ea8 <filewrite+0x114>
    80004eda:	557d                	li	a0,-1
    80004edc:	b7f1                	j	80004ea8 <filewrite+0x114>
    ret = (i == n ? n : -1);
    80004ede:	557d                	li	a0,-1
    80004ee0:	7a42                	ld	s4,48(sp)
    80004ee2:	b7d9                	j	80004ea8 <filewrite+0x114>

0000000080004ee4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ee4:	7179                	addi	sp,sp,-48
    80004ee6:	f406                	sd	ra,40(sp)
    80004ee8:	f022                	sd	s0,32(sp)
    80004eea:	ec26                	sd	s1,24(sp)
    80004eec:	e052                	sd	s4,0(sp)
    80004eee:	1800                	addi	s0,sp,48
    80004ef0:	84aa                	mv	s1,a0
    80004ef2:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004ef4:	0005b023          	sd	zero,0(a1)
    80004ef8:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004efc:	00000097          	auipc	ra,0x0
    80004f00:	bac080e7          	jalr	-1108(ra) # 80004aa8 <filealloc>
    80004f04:	e088                	sd	a0,0(s1)
    80004f06:	cd49                	beqz	a0,80004fa0 <pipealloc+0xbc>
    80004f08:	00000097          	auipc	ra,0x0
    80004f0c:	ba0080e7          	jalr	-1120(ra) # 80004aa8 <filealloc>
    80004f10:	00aa3023          	sd	a0,0(s4)
    80004f14:	c141                	beqz	a0,80004f94 <pipealloc+0xb0>
    80004f16:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004f18:	ffffc097          	auipc	ra,0xffffc
    80004f1c:	c38080e7          	jalr	-968(ra) # 80000b50 <kalloc>
    80004f20:	892a                	mv	s2,a0
    80004f22:	c13d                	beqz	a0,80004f88 <pipealloc+0xa4>
    80004f24:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004f26:	4985                	li	s3,1
    80004f28:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004f2c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004f30:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004f34:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004f38:	00003597          	auipc	a1,0x3
    80004f3c:	50058593          	addi	a1,a1,1280 # 80008438 <etext+0x438>
    80004f40:	ffffc097          	auipc	ra,0xffffc
    80004f44:	c7a080e7          	jalr	-902(ra) # 80000bba <initlock>
  (*f0)->type = FD_PIPE;
    80004f48:	609c                	ld	a5,0(s1)
    80004f4a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004f4e:	609c                	ld	a5,0(s1)
    80004f50:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004f54:	609c                	ld	a5,0(s1)
    80004f56:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004f5a:	609c                	ld	a5,0(s1)
    80004f5c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004f60:	000a3783          	ld	a5,0(s4)
    80004f64:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004f68:	000a3783          	ld	a5,0(s4)
    80004f6c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004f70:	000a3783          	ld	a5,0(s4)
    80004f74:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004f78:	000a3783          	ld	a5,0(s4)
    80004f7c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004f80:	4501                	li	a0,0
    80004f82:	6942                	ld	s2,16(sp)
    80004f84:	69a2                	ld	s3,8(sp)
    80004f86:	a03d                	j	80004fb4 <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004f88:	6088                	ld	a0,0(s1)
    80004f8a:	c119                	beqz	a0,80004f90 <pipealloc+0xac>
    80004f8c:	6942                	ld	s2,16(sp)
    80004f8e:	a029                	j	80004f98 <pipealloc+0xb4>
    80004f90:	6942                	ld	s2,16(sp)
    80004f92:	a039                	j	80004fa0 <pipealloc+0xbc>
    80004f94:	6088                	ld	a0,0(s1)
    80004f96:	c50d                	beqz	a0,80004fc0 <pipealloc+0xdc>
    fileclose(*f0);
    80004f98:	00000097          	auipc	ra,0x0
    80004f9c:	bcc080e7          	jalr	-1076(ra) # 80004b64 <fileclose>
  if(*f1)
    80004fa0:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004fa4:	557d                	li	a0,-1
  if(*f1)
    80004fa6:	c799                	beqz	a5,80004fb4 <pipealloc+0xd0>
    fileclose(*f1);
    80004fa8:	853e                	mv	a0,a5
    80004faa:	00000097          	auipc	ra,0x0
    80004fae:	bba080e7          	jalr	-1094(ra) # 80004b64 <fileclose>
  return -1;
    80004fb2:	557d                	li	a0,-1
}
    80004fb4:	70a2                	ld	ra,40(sp)
    80004fb6:	7402                	ld	s0,32(sp)
    80004fb8:	64e2                	ld	s1,24(sp)
    80004fba:	6a02                	ld	s4,0(sp)
    80004fbc:	6145                	addi	sp,sp,48
    80004fbe:	8082                	ret
  return -1;
    80004fc0:	557d                	li	a0,-1
    80004fc2:	bfcd                	j	80004fb4 <pipealloc+0xd0>

0000000080004fc4 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004fc4:	1101                	addi	sp,sp,-32
    80004fc6:	ec06                	sd	ra,24(sp)
    80004fc8:	e822                	sd	s0,16(sp)
    80004fca:	e426                	sd	s1,8(sp)
    80004fcc:	e04a                	sd	s2,0(sp)
    80004fce:	1000                	addi	s0,sp,32
    80004fd0:	84aa                	mv	s1,a0
    80004fd2:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004fd4:	ffffc097          	auipc	ra,0xffffc
    80004fd8:	c80080e7          	jalr	-896(ra) # 80000c54 <acquire>
  if(writable){
    80004fdc:	02090b63          	beqz	s2,80005012 <pipeclose+0x4e>
    pi->writeopen = 0;
    80004fe0:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004fe4:	21848513          	addi	a0,s1,536
    80004fe8:	ffffd097          	auipc	ra,0xffffd
    80004fec:	432080e7          	jalr	1074(ra) # 8000241a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004ff0:	2204a783          	lw	a5,544(s1)
    80004ff4:	e781                	bnez	a5,80004ffc <pipeclose+0x38>
    80004ff6:	2244a783          	lw	a5,548(s1)
    80004ffa:	c78d                	beqz	a5,80005024 <pipeclose+0x60>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    80004ffc:	8526                	mv	a0,s1
    80004ffe:	ffffc097          	auipc	ra,0xffffc
    80005002:	d06080e7          	jalr	-762(ra) # 80000d04 <release>
}
    80005006:	60e2                	ld	ra,24(sp)
    80005008:	6442                	ld	s0,16(sp)
    8000500a:	64a2                	ld	s1,8(sp)
    8000500c:	6902                	ld	s2,0(sp)
    8000500e:	6105                	addi	sp,sp,32
    80005010:	8082                	ret
    pi->readopen = 0;
    80005012:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005016:	21c48513          	addi	a0,s1,540
    8000501a:	ffffd097          	auipc	ra,0xffffd
    8000501e:	400080e7          	jalr	1024(ra) # 8000241a <wakeup>
    80005022:	b7f9                	j	80004ff0 <pipeclose+0x2c>
    release(&pi->lock);
    80005024:	8526                	mv	a0,s1
    80005026:	ffffc097          	auipc	ra,0xffffc
    8000502a:	cde080e7          	jalr	-802(ra) # 80000d04 <release>
    kfree((char*)pi);
    8000502e:	8526                	mv	a0,s1
    80005030:	ffffc097          	auipc	ra,0xffffc
    80005034:	a1c080e7          	jalr	-1508(ra) # 80000a4c <kfree>
    80005038:	b7f9                	j	80005006 <pipeclose+0x42>

000000008000503a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000503a:	7159                	addi	sp,sp,-112
    8000503c:	f486                	sd	ra,104(sp)
    8000503e:	f0a2                	sd	s0,96(sp)
    80005040:	eca6                	sd	s1,88(sp)
    80005042:	e8ca                	sd	s2,80(sp)
    80005044:	e4ce                	sd	s3,72(sp)
    80005046:	e0d2                	sd	s4,64(sp)
    80005048:	fc56                	sd	s5,56(sp)
    8000504a:	1880                	addi	s0,sp,112
    8000504c:	84aa                	mv	s1,a0
    8000504e:	8aae                	mv	s5,a1
    80005050:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005052:	ffffd097          	auipc	ra,0xffffd
    80005056:	a34080e7          	jalr	-1484(ra) # 80001a86 <myproc>
    8000505a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000505c:	8526                	mv	a0,s1
    8000505e:	ffffc097          	auipc	ra,0xffffc
    80005062:	bf6080e7          	jalr	-1034(ra) # 80000c54 <acquire>
  while(i < n){
    80005066:	0d405d63          	blez	s4,80005140 <pipewrite+0x106>
    8000506a:	f85a                	sd	s6,48(sp)
    8000506c:	f45e                	sd	s7,40(sp)
    8000506e:	f062                	sd	s8,32(sp)
    80005070:	ec66                	sd	s9,24(sp)
    80005072:	e86a                	sd	s10,16(sp)
  int i = 0;
    80005074:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005076:	f9f40c13          	addi	s8,s0,-97
    8000507a:	4b85                	li	s7,1
    8000507c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000507e:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005082:	21c48c93          	addi	s9,s1,540
    80005086:	a099                	j	800050cc <pipewrite+0x92>
      release(&pi->lock);
    80005088:	8526                	mv	a0,s1
    8000508a:	ffffc097          	auipc	ra,0xffffc
    8000508e:	c7a080e7          	jalr	-902(ra) # 80000d04 <release>
      return -1;
    80005092:	597d                	li	s2,-1
    80005094:	7b42                	ld	s6,48(sp)
    80005096:	7ba2                	ld	s7,40(sp)
    80005098:	7c02                	ld	s8,32(sp)
    8000509a:	6ce2                	ld	s9,24(sp)
    8000509c:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000509e:	854a                	mv	a0,s2
    800050a0:	70a6                	ld	ra,104(sp)
    800050a2:	7406                	ld	s0,96(sp)
    800050a4:	64e6                	ld	s1,88(sp)
    800050a6:	6946                	ld	s2,80(sp)
    800050a8:	69a6                	ld	s3,72(sp)
    800050aa:	6a06                	ld	s4,64(sp)
    800050ac:	7ae2                	ld	s5,56(sp)
    800050ae:	6165                	addi	sp,sp,112
    800050b0:	8082                	ret
      wakeup(&pi->nread);
    800050b2:	856a                	mv	a0,s10
    800050b4:	ffffd097          	auipc	ra,0xffffd
    800050b8:	366080e7          	jalr	870(ra) # 8000241a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800050bc:	85a6                	mv	a1,s1
    800050be:	8566                	mv	a0,s9
    800050c0:	ffffd097          	auipc	ra,0xffffd
    800050c4:	1d4080e7          	jalr	468(ra) # 80002294 <sleep>
  while(i < n){
    800050c8:	05495b63          	bge	s2,s4,8000511e <pipewrite+0xe4>
    if(pi->readopen == 0 || pr->killed){
    800050cc:	2204a783          	lw	a5,544(s1)
    800050d0:	dfc5                	beqz	a5,80005088 <pipewrite+0x4e>
    800050d2:	0289a783          	lw	a5,40(s3)
    800050d6:	fbcd                	bnez	a5,80005088 <pipewrite+0x4e>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800050d8:	2184a783          	lw	a5,536(s1)
    800050dc:	21c4a703          	lw	a4,540(s1)
    800050e0:	2007879b          	addiw	a5,a5,512
    800050e4:	fcf707e3          	beq	a4,a5,800050b2 <pipewrite+0x78>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800050e8:	86de                	mv	a3,s7
    800050ea:	01590633          	add	a2,s2,s5
    800050ee:	85e2                	mv	a1,s8
    800050f0:	0509b503          	ld	a0,80(s3)
    800050f4:	ffffc097          	auipc	ra,0xffffc
    800050f8:	6a2080e7          	jalr	1698(ra) # 80001796 <copyin>
    800050fc:	05650463          	beq	a0,s6,80005144 <pipewrite+0x10a>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005100:	21c4a783          	lw	a5,540(s1)
    80005104:	0017871b          	addiw	a4,a5,1
    80005108:	20e4ae23          	sw	a4,540(s1)
    8000510c:	1ff7f793          	andi	a5,a5,511
    80005110:	97a6                	add	a5,a5,s1
    80005112:	f9f44703          	lbu	a4,-97(s0)
    80005116:	00e78c23          	sb	a4,24(a5)
      i++;
    8000511a:	2905                	addiw	s2,s2,1
    8000511c:	b775                	j	800050c8 <pipewrite+0x8e>
    8000511e:	7b42                	ld	s6,48(sp)
    80005120:	7ba2                	ld	s7,40(sp)
    80005122:	7c02                	ld	s8,32(sp)
    80005124:	6ce2                	ld	s9,24(sp)
    80005126:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80005128:	21848513          	addi	a0,s1,536
    8000512c:	ffffd097          	auipc	ra,0xffffd
    80005130:	2ee080e7          	jalr	750(ra) # 8000241a <wakeup>
  release(&pi->lock);
    80005134:	8526                	mv	a0,s1
    80005136:	ffffc097          	auipc	ra,0xffffc
    8000513a:	bce080e7          	jalr	-1074(ra) # 80000d04 <release>
  return i;
    8000513e:	b785                	j	8000509e <pipewrite+0x64>
  int i = 0;
    80005140:	4901                	li	s2,0
    80005142:	b7dd                	j	80005128 <pipewrite+0xee>
    80005144:	7b42                	ld	s6,48(sp)
    80005146:	7ba2                	ld	s7,40(sp)
    80005148:	7c02                	ld	s8,32(sp)
    8000514a:	6ce2                	ld	s9,24(sp)
    8000514c:	6d42                	ld	s10,16(sp)
    8000514e:	bfe9                	j	80005128 <pipewrite+0xee>

0000000080005150 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005150:	711d                	addi	sp,sp,-96
    80005152:	ec86                	sd	ra,88(sp)
    80005154:	e8a2                	sd	s0,80(sp)
    80005156:	e4a6                	sd	s1,72(sp)
    80005158:	e0ca                	sd	s2,64(sp)
    8000515a:	fc4e                	sd	s3,56(sp)
    8000515c:	f852                	sd	s4,48(sp)
    8000515e:	f456                	sd	s5,40(sp)
    80005160:	1080                	addi	s0,sp,96
    80005162:	84aa                	mv	s1,a0
    80005164:	892e                	mv	s2,a1
    80005166:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005168:	ffffd097          	auipc	ra,0xffffd
    8000516c:	91e080e7          	jalr	-1762(ra) # 80001a86 <myproc>
    80005170:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005172:	8526                	mv	a0,s1
    80005174:	ffffc097          	auipc	ra,0xffffc
    80005178:	ae0080e7          	jalr	-1312(ra) # 80000c54 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000517c:	2184a703          	lw	a4,536(s1)
    80005180:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005184:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005188:	02f71863          	bne	a4,a5,800051b8 <piperead+0x68>
    8000518c:	2244a783          	lw	a5,548(s1)
    80005190:	cf9d                	beqz	a5,800051ce <piperead+0x7e>
    if(pr->killed){
    80005192:	028a2783          	lw	a5,40(s4)
    80005196:	e78d                	bnez	a5,800051c0 <piperead+0x70>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005198:	85a6                	mv	a1,s1
    8000519a:	854e                	mv	a0,s3
    8000519c:	ffffd097          	auipc	ra,0xffffd
    800051a0:	0f8080e7          	jalr	248(ra) # 80002294 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800051a4:	2184a703          	lw	a4,536(s1)
    800051a8:	21c4a783          	lw	a5,540(s1)
    800051ac:	fef700e3          	beq	a4,a5,8000518c <piperead+0x3c>
    800051b0:	f05a                	sd	s6,32(sp)
    800051b2:	ec5e                	sd	s7,24(sp)
    800051b4:	e862                	sd	s8,16(sp)
    800051b6:	a839                	j	800051d4 <piperead+0x84>
    800051b8:	f05a                	sd	s6,32(sp)
    800051ba:	ec5e                	sd	s7,24(sp)
    800051bc:	e862                	sd	s8,16(sp)
    800051be:	a819                	j	800051d4 <piperead+0x84>
      release(&pi->lock);
    800051c0:	8526                	mv	a0,s1
    800051c2:	ffffc097          	auipc	ra,0xffffc
    800051c6:	b42080e7          	jalr	-1214(ra) # 80000d04 <release>
      return -1;
    800051ca:	59fd                	li	s3,-1
    800051cc:	a88d                	j	8000523e <piperead+0xee>
    800051ce:	f05a                	sd	s6,32(sp)
    800051d0:	ec5e                	sd	s7,24(sp)
    800051d2:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051d4:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800051d6:	faf40c13          	addi	s8,s0,-81
    800051da:	4b85                	li	s7,1
    800051dc:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051de:	05505263          	blez	s5,80005222 <piperead+0xd2>
    if(pi->nread == pi->nwrite)
    800051e2:	2184a783          	lw	a5,536(s1)
    800051e6:	21c4a703          	lw	a4,540(s1)
    800051ea:	02f70c63          	beq	a4,a5,80005222 <piperead+0xd2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800051ee:	0017871b          	addiw	a4,a5,1
    800051f2:	20e4ac23          	sw	a4,536(s1)
    800051f6:	1ff7f793          	andi	a5,a5,511
    800051fa:	97a6                	add	a5,a5,s1
    800051fc:	0187c783          	lbu	a5,24(a5)
    80005200:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005204:	86de                	mv	a3,s7
    80005206:	8662                	mv	a2,s8
    80005208:	85ca                	mv	a1,s2
    8000520a:	050a3503          	ld	a0,80(s4)
    8000520e:	ffffc097          	auipc	ra,0xffffc
    80005212:	4fc080e7          	jalr	1276(ra) # 8000170a <copyout>
    80005216:	01650663          	beq	a0,s6,80005222 <piperead+0xd2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000521a:	2985                	addiw	s3,s3,1
    8000521c:	0905                	addi	s2,s2,1
    8000521e:	fd3a92e3          	bne	s5,s3,800051e2 <piperead+0x92>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005222:	21c48513          	addi	a0,s1,540
    80005226:	ffffd097          	auipc	ra,0xffffd
    8000522a:	1f4080e7          	jalr	500(ra) # 8000241a <wakeup>
  release(&pi->lock);
    8000522e:	8526                	mv	a0,s1
    80005230:	ffffc097          	auipc	ra,0xffffc
    80005234:	ad4080e7          	jalr	-1324(ra) # 80000d04 <release>
    80005238:	7b02                	ld	s6,32(sp)
    8000523a:	6be2                	ld	s7,24(sp)
    8000523c:	6c42                	ld	s8,16(sp)
  return i;
}
    8000523e:	854e                	mv	a0,s3
    80005240:	60e6                	ld	ra,88(sp)
    80005242:	6446                	ld	s0,80(sp)
    80005244:	64a6                	ld	s1,72(sp)
    80005246:	6906                	ld	s2,64(sp)
    80005248:	79e2                	ld	s3,56(sp)
    8000524a:	7a42                	ld	s4,48(sp)
    8000524c:	7aa2                	ld	s5,40(sp)
    8000524e:	6125                	addi	sp,sp,96
    80005250:	8082                	ret

0000000080005252 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005252:	de010113          	addi	sp,sp,-544
    80005256:	20113c23          	sd	ra,536(sp)
    8000525a:	20813823          	sd	s0,528(sp)
    8000525e:	20913423          	sd	s1,520(sp)
    80005262:	21213023          	sd	s2,512(sp)
    80005266:	1400                	addi	s0,sp,544
    80005268:	892a                	mv	s2,a0
    8000526a:	dea43823          	sd	a0,-528(s0)
    8000526e:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005272:	ffffd097          	auipc	ra,0xffffd
    80005276:	814080e7          	jalr	-2028(ra) # 80001a86 <myproc>
    8000527a:	84aa                	mv	s1,a0

  begin_op();
    8000527c:	fffff097          	auipc	ra,0xfffff
    80005280:	406080e7          	jalr	1030(ra) # 80004682 <begin_op>

  if((ip = namei(path)) == 0){
    80005284:	854a                	mv	a0,s2
    80005286:	fffff097          	auipc	ra,0xfffff
    8000528a:	1f6080e7          	jalr	502(ra) # 8000447c <namei>
    8000528e:	c525                	beqz	a0,800052f6 <exec+0xa4>
    80005290:	fbd2                	sd	s4,496(sp)
    80005292:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005294:	fffff097          	auipc	ra,0xfffff
    80005298:	9f6080e7          	jalr	-1546(ra) # 80003c8a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000529c:	04000713          	li	a4,64
    800052a0:	4681                	li	a3,0
    800052a2:	e5040613          	addi	a2,s0,-432
    800052a6:	4581                	li	a1,0
    800052a8:	8552                	mv	a0,s4
    800052aa:	fffff097          	auipc	ra,0xfffff
    800052ae:	c9e080e7          	jalr	-866(ra) # 80003f48 <readi>
    800052b2:	04000793          	li	a5,64
    800052b6:	00f51a63          	bne	a0,a5,800052ca <exec+0x78>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    800052ba:	e5042703          	lw	a4,-432(s0)
    800052be:	464c47b7          	lui	a5,0x464c4
    800052c2:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800052c6:	02f70e63          	beq	a4,a5,80005302 <exec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800052ca:	8552                	mv	a0,s4
    800052cc:	fffff097          	auipc	ra,0xfffff
    800052d0:	c26080e7          	jalr	-986(ra) # 80003ef2 <iunlockput>
    end_op();
    800052d4:	fffff097          	auipc	ra,0xfffff
    800052d8:	42e080e7          	jalr	1070(ra) # 80004702 <end_op>
  }
  return -1;
    800052dc:	557d                	li	a0,-1
    800052de:	7a5e                	ld	s4,496(sp)
}
    800052e0:	21813083          	ld	ra,536(sp)
    800052e4:	21013403          	ld	s0,528(sp)
    800052e8:	20813483          	ld	s1,520(sp)
    800052ec:	20013903          	ld	s2,512(sp)
    800052f0:	22010113          	addi	sp,sp,544
    800052f4:	8082                	ret
    end_op();
    800052f6:	fffff097          	auipc	ra,0xfffff
    800052fa:	40c080e7          	jalr	1036(ra) # 80004702 <end_op>
    return -1;
    800052fe:	557d                	li	a0,-1
    80005300:	b7c5                	j	800052e0 <exec+0x8e>
    80005302:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80005304:	8526                	mv	a0,s1
    80005306:	ffffd097          	auipc	ra,0xffffd
    8000530a:	846080e7          	jalr	-1978(ra) # 80001b4c <proc_pagetable>
    8000530e:	8b2a                	mv	s6,a0
    80005310:	2a050a63          	beqz	a0,800055c4 <exec+0x372>
    80005314:	ffce                	sd	s3,504(sp)
    80005316:	f7d6                	sd	s5,488(sp)
    80005318:	efde                	sd	s7,472(sp)
    8000531a:	ebe2                	sd	s8,464(sp)
    8000531c:	e7e6                	sd	s9,456(sp)
    8000531e:	e3ea                	sd	s10,448(sp)
    80005320:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005322:	e8845783          	lhu	a5,-376(s0)
    80005326:	cfed                	beqz	a5,80005420 <exec+0x1ce>
    80005328:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000532c:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000532e:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005330:	03800d93          	li	s11,56
    if((ph.vaddr % PGSIZE) != 0)
    80005334:	6c85                	lui	s9,0x1
    80005336:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000533a:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000533e:	6a85                	lui	s5,0x1
    80005340:	a0b5                	j	800053ac <exec+0x15a>
      panic("loadseg: address should exist");
    80005342:	00003517          	auipc	a0,0x3
    80005346:	36650513          	addi	a0,a0,870 # 800086a8 <etext+0x6a8>
    8000534a:	ffffb097          	auipc	ra,0xffffb
    8000534e:	20c080e7          	jalr	524(ra) # 80000556 <panic>
    if(sz - i < PGSIZE)
    80005352:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005354:	874a                	mv	a4,s2
    80005356:	009c06bb          	addw	a3,s8,s1
    8000535a:	4581                	li	a1,0
    8000535c:	8552                	mv	a0,s4
    8000535e:	fffff097          	auipc	ra,0xfffff
    80005362:	bea080e7          	jalr	-1046(ra) # 80003f48 <readi>
    80005366:	26a91363          	bne	s2,a0,800055cc <exec+0x37a>
  for(i = 0; i < sz; i += PGSIZE){
    8000536a:	009a84bb          	addw	s1,s5,s1
    8000536e:	0334f463          	bgeu	s1,s3,80005396 <exec+0x144>
    pa = walkaddr(pagetable, va + i);
    80005372:	02049593          	slli	a1,s1,0x20
    80005376:	9181                	srli	a1,a1,0x20
    80005378:	95de                	add	a1,a1,s7
    8000537a:	855a                	mv	a0,s6
    8000537c:	ffffc097          	auipc	ra,0xffffc
    80005380:	d6e080e7          	jalr	-658(ra) # 800010ea <walkaddr>
    80005384:	862a                	mv	a2,a0
    if(pa == 0)
    80005386:	dd55                	beqz	a0,80005342 <exec+0xf0>
    if(sz - i < PGSIZE)
    80005388:	409987bb          	subw	a5,s3,s1
    8000538c:	893e                	mv	s2,a5
    8000538e:	fcfcf2e3          	bgeu	s9,a5,80005352 <exec+0x100>
    80005392:	8956                	mv	s2,s5
    80005394:	bf7d                	j	80005352 <exec+0x100>
    sz = sz1;
    80005396:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000539a:	2d05                	addiw	s10,s10,1
    8000539c:	e0843783          	ld	a5,-504(s0)
    800053a0:	0387869b          	addiw	a3,a5,56
    800053a4:	e8845783          	lhu	a5,-376(s0)
    800053a8:	06fd5d63          	bge	s10,a5,80005422 <exec+0x1d0>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800053ac:	e0d43423          	sd	a3,-504(s0)
    800053b0:	876e                	mv	a4,s11
    800053b2:	e1840613          	addi	a2,s0,-488
    800053b6:	4581                	li	a1,0
    800053b8:	8552                	mv	a0,s4
    800053ba:	fffff097          	auipc	ra,0xfffff
    800053be:	b8e080e7          	jalr	-1138(ra) # 80003f48 <readi>
    800053c2:	21b51363          	bne	a0,s11,800055c8 <exec+0x376>
    if(ph.type != ELF_PROG_LOAD)
    800053c6:	e1842783          	lw	a5,-488(s0)
    800053ca:	4705                	li	a4,1
    800053cc:	fce797e3          	bne	a5,a4,8000539a <exec+0x148>
    if(ph.memsz < ph.filesz)
    800053d0:	e4043603          	ld	a2,-448(s0)
    800053d4:	e3843783          	ld	a5,-456(s0)
    800053d8:	20f66a63          	bltu	a2,a5,800055ec <exec+0x39a>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800053dc:	e2843783          	ld	a5,-472(s0)
    800053e0:	963e                	add	a2,a2,a5
    800053e2:	20f66863          	bltu	a2,a5,800055f2 <exec+0x3a0>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800053e6:	85a6                	mv	a1,s1
    800053e8:	855a                	mv	a0,s6
    800053ea:	ffffc097          	auipc	ra,0xffffc
    800053ee:	0be080e7          	jalr	190(ra) # 800014a8 <uvmalloc>
    800053f2:	dea43c23          	sd	a0,-520(s0)
    800053f6:	20050163          	beqz	a0,800055f8 <exec+0x3a6>
    if((ph.vaddr % PGSIZE) != 0)
    800053fa:	e2843b83          	ld	s7,-472(s0)
    800053fe:	de843783          	ld	a5,-536(s0)
    80005402:	00fbf7b3          	and	a5,s7,a5
    80005406:	1c079363          	bnez	a5,800055cc <exec+0x37a>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000540a:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000540e:	00098663          	beqz	s3,8000541a <exec+0x1c8>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005412:	e2042c03          	lw	s8,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005416:	4481                	li	s1,0
    80005418:	bfa9                	j	80005372 <exec+0x120>
    sz = sz1;
    8000541a:	df843483          	ld	s1,-520(s0)
    8000541e:	bfb5                	j	8000539a <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005420:	4481                	li	s1,0
  iunlockput(ip);
    80005422:	8552                	mv	a0,s4
    80005424:	fffff097          	auipc	ra,0xfffff
    80005428:	ace080e7          	jalr	-1330(ra) # 80003ef2 <iunlockput>
  end_op();
    8000542c:	fffff097          	auipc	ra,0xfffff
    80005430:	2d6080e7          	jalr	726(ra) # 80004702 <end_op>
  p = myproc();
    80005434:	ffffc097          	auipc	ra,0xffffc
    80005438:	652080e7          	jalr	1618(ra) # 80001a86 <myproc>
    8000543c:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000543e:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005442:	6985                	lui	s3,0x1
    80005444:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80005446:	99a6                	add	s3,s3,s1
    80005448:	77fd                	lui	a5,0xfffff
    8000544a:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000544e:	6609                	lui	a2,0x2
    80005450:	964e                	add	a2,a2,s3
    80005452:	85ce                	mv	a1,s3
    80005454:	855a                	mv	a0,s6
    80005456:	ffffc097          	auipc	ra,0xffffc
    8000545a:	052080e7          	jalr	82(ra) # 800014a8 <uvmalloc>
    8000545e:	8a2a                	mv	s4,a0
    80005460:	e115                	bnez	a0,80005484 <exec+0x232>
    proc_freepagetable(pagetable, sz);
    80005462:	85ce                	mv	a1,s3
    80005464:	855a                	mv	a0,s6
    80005466:	ffffc097          	auipc	ra,0xffffc
    8000546a:	782080e7          	jalr	1922(ra) # 80001be8 <proc_freepagetable>
  return -1;
    8000546e:	557d                	li	a0,-1
    80005470:	79fe                	ld	s3,504(sp)
    80005472:	7a5e                	ld	s4,496(sp)
    80005474:	7abe                	ld	s5,488(sp)
    80005476:	7b1e                	ld	s6,480(sp)
    80005478:	6bfe                	ld	s7,472(sp)
    8000547a:	6c5e                	ld	s8,464(sp)
    8000547c:	6cbe                	ld	s9,456(sp)
    8000547e:	6d1e                	ld	s10,448(sp)
    80005480:	7dfa                	ld	s11,440(sp)
    80005482:	bdb9                	j	800052e0 <exec+0x8e>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005484:	75f9                	lui	a1,0xffffe
    80005486:	95aa                	add	a1,a1,a0
    80005488:	855a                	mv	a0,s6
    8000548a:	ffffc097          	auipc	ra,0xffffc
    8000548e:	24e080e7          	jalr	590(ra) # 800016d8 <uvmclear>
  stackbase = sp - PGSIZE;
    80005492:	800a0b93          	addi	s7,s4,-2048
    80005496:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    8000549a:	e0043783          	ld	a5,-512(s0)
    8000549e:	6388                	ld	a0,0(a5)
  sp = sz;
    800054a0:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    800054a2:	4481                	li	s1,0
    ustack[argc] = sp;
    800054a4:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    800054a8:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    800054ac:	c135                	beqz	a0,80005510 <exec+0x2be>
    sp -= strlen(argv[argc]) + 1;
    800054ae:	ffffc097          	auipc	ra,0xffffc
    800054b2:	a2c080e7          	jalr	-1492(ra) # 80000eda <strlen>
    800054b6:	0015079b          	addiw	a5,a0,1
    800054ba:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800054be:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800054c2:	13796e63          	bltu	s2,s7,800055fe <exec+0x3ac>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800054c6:	e0043d83          	ld	s11,-512(s0)
    800054ca:	000db983          	ld	s3,0(s11)
    800054ce:	854e                	mv	a0,s3
    800054d0:	ffffc097          	auipc	ra,0xffffc
    800054d4:	a0a080e7          	jalr	-1526(ra) # 80000eda <strlen>
    800054d8:	0015069b          	addiw	a3,a0,1
    800054dc:	864e                	mv	a2,s3
    800054de:	85ca                	mv	a1,s2
    800054e0:	855a                	mv	a0,s6
    800054e2:	ffffc097          	auipc	ra,0xffffc
    800054e6:	228080e7          	jalr	552(ra) # 8000170a <copyout>
    800054ea:	10054c63          	bltz	a0,80005602 <exec+0x3b0>
    ustack[argc] = sp;
    800054ee:	00349793          	slli	a5,s1,0x3
    800054f2:	97e6                	add	a5,a5,s9
    800054f4:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffd5000>
  for(argc = 0; argv[argc]; argc++) {
    800054f8:	0485                	addi	s1,s1,1
    800054fa:	008d8793          	addi	a5,s11,8
    800054fe:	e0f43023          	sd	a5,-512(s0)
    80005502:	008db503          	ld	a0,8(s11)
    80005506:	c509                	beqz	a0,80005510 <exec+0x2be>
    if(argc >= MAXARG)
    80005508:	fb8493e3          	bne	s1,s8,800054ae <exec+0x25c>
  sz = sz1;
    8000550c:	89d2                	mv	s3,s4
    8000550e:	bf91                	j	80005462 <exec+0x210>
  ustack[argc] = 0;
    80005510:	00349793          	slli	a5,s1,0x3
    80005514:	f9078793          	addi	a5,a5,-112
    80005518:	97a2                	add	a5,a5,s0
    8000551a:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    8000551e:	00349693          	slli	a3,s1,0x3
    80005522:	06a1                	addi	a3,a3,8
    80005524:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005528:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    8000552c:	89d2                	mv	s3,s4
  if(sp < stackbase)
    8000552e:	f3796ae3          	bltu	s2,s7,80005462 <exec+0x210>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005532:	e9040613          	addi	a2,s0,-368
    80005536:	85ca                	mv	a1,s2
    80005538:	855a                	mv	a0,s6
    8000553a:	ffffc097          	auipc	ra,0xffffc
    8000553e:	1d0080e7          	jalr	464(ra) # 8000170a <copyout>
    80005542:	f20540e3          	bltz	a0,80005462 <exec+0x210>
  p->trapframe->a1 = sp;
    80005546:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    8000554a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000554e:	df043783          	ld	a5,-528(s0)
    80005552:	0007c703          	lbu	a4,0(a5)
    80005556:	cf11                	beqz	a4,80005572 <exec+0x320>
    80005558:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000555a:	02f00693          	li	a3,47
    8000555e:	a029                	j	80005568 <exec+0x316>
  for(last=s=path; *s; s++)
    80005560:	0785                	addi	a5,a5,1
    80005562:	fff7c703          	lbu	a4,-1(a5)
    80005566:	c711                	beqz	a4,80005572 <exec+0x320>
    if(*s == '/')
    80005568:	fed71ce3          	bne	a4,a3,80005560 <exec+0x30e>
      last = s+1;
    8000556c:	def43823          	sd	a5,-528(s0)
    80005570:	bfc5                	j	80005560 <exec+0x30e>
  safestrcpy(p->name, last, sizeof(p->name));
    80005572:	4641                	li	a2,16
    80005574:	df043583          	ld	a1,-528(s0)
    80005578:	158a8513          	addi	a0,s5,344
    8000557c:	ffffc097          	auipc	ra,0xffffc
    80005580:	928080e7          	jalr	-1752(ra) # 80000ea4 <safestrcpy>
  oldpagetable = p->pagetable;
    80005584:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005588:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    8000558c:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005590:	058ab783          	ld	a5,88(s5)
    80005594:	e6843703          	ld	a4,-408(s0)
    80005598:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000559a:	058ab783          	ld	a5,88(s5)
    8000559e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800055a2:	85ea                	mv	a1,s10
    800055a4:	ffffc097          	auipc	ra,0xffffc
    800055a8:	644080e7          	jalr	1604(ra) # 80001be8 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800055ac:	0004851b          	sext.w	a0,s1
    800055b0:	79fe                	ld	s3,504(sp)
    800055b2:	7a5e                	ld	s4,496(sp)
    800055b4:	7abe                	ld	s5,488(sp)
    800055b6:	7b1e                	ld	s6,480(sp)
    800055b8:	6bfe                	ld	s7,472(sp)
    800055ba:	6c5e                	ld	s8,464(sp)
    800055bc:	6cbe                	ld	s9,456(sp)
    800055be:	6d1e                	ld	s10,448(sp)
    800055c0:	7dfa                	ld	s11,440(sp)
    800055c2:	bb39                	j	800052e0 <exec+0x8e>
    800055c4:	7b1e                	ld	s6,480(sp)
    800055c6:	b311                	j	800052ca <exec+0x78>
    800055c8:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    800055cc:	df843583          	ld	a1,-520(s0)
    800055d0:	855a                	mv	a0,s6
    800055d2:	ffffc097          	auipc	ra,0xffffc
    800055d6:	616080e7          	jalr	1558(ra) # 80001be8 <proc_freepagetable>
  if(ip){
    800055da:	79fe                	ld	s3,504(sp)
    800055dc:	7abe                	ld	s5,488(sp)
    800055de:	7b1e                	ld	s6,480(sp)
    800055e0:	6bfe                	ld	s7,472(sp)
    800055e2:	6c5e                	ld	s8,464(sp)
    800055e4:	6cbe                	ld	s9,456(sp)
    800055e6:	6d1e                	ld	s10,448(sp)
    800055e8:	7dfa                	ld	s11,440(sp)
    800055ea:	b1c5                	j	800052ca <exec+0x78>
    800055ec:	de943c23          	sd	s1,-520(s0)
    800055f0:	bff1                	j	800055cc <exec+0x37a>
    800055f2:	de943c23          	sd	s1,-520(s0)
    800055f6:	bfd9                	j	800055cc <exec+0x37a>
    800055f8:	de943c23          	sd	s1,-520(s0)
    800055fc:	bfc1                	j	800055cc <exec+0x37a>
  sz = sz1;
    800055fe:	89d2                	mv	s3,s4
    80005600:	b58d                	j	80005462 <exec+0x210>
    80005602:	89d2                	mv	s3,s4
    80005604:	bdb9                	j	80005462 <exec+0x210>

0000000080005606 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005606:	7179                	addi	sp,sp,-48
    80005608:	f406                	sd	ra,40(sp)
    8000560a:	f022                	sd	s0,32(sp)
    8000560c:	ec26                	sd	s1,24(sp)
    8000560e:	e84a                	sd	s2,16(sp)
    80005610:	1800                	addi	s0,sp,48
    80005612:	892e                	mv	s2,a1
    80005614:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005616:	fdc40593          	addi	a1,s0,-36
    8000561a:	ffffe097          	auipc	ra,0xffffe
    8000561e:	910080e7          	jalr	-1776(ra) # 80002f2a <argint>
    80005622:	04054163          	bltz	a0,80005664 <argfd+0x5e>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005626:	fdc42703          	lw	a4,-36(s0)
    8000562a:	47bd                	li	a5,15
    8000562c:	02e7ee63          	bltu	a5,a4,80005668 <argfd+0x62>
    80005630:	ffffc097          	auipc	ra,0xffffc
    80005634:	456080e7          	jalr	1110(ra) # 80001a86 <myproc>
    80005638:	fdc42703          	lw	a4,-36(s0)
    8000563c:	00371793          	slli	a5,a4,0x3
    80005640:	0d078793          	addi	a5,a5,208
    80005644:	953e                	add	a0,a0,a5
    80005646:	611c                	ld	a5,0(a0)
    80005648:	c395                	beqz	a5,8000566c <argfd+0x66>
    return -1;
  if(pfd)
    8000564a:	00090463          	beqz	s2,80005652 <argfd+0x4c>
    *pfd = fd;
    8000564e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005652:	4501                	li	a0,0
  if(pf)
    80005654:	c091                	beqz	s1,80005658 <argfd+0x52>
    *pf = f;
    80005656:	e09c                	sd	a5,0(s1)
}
    80005658:	70a2                	ld	ra,40(sp)
    8000565a:	7402                	ld	s0,32(sp)
    8000565c:	64e2                	ld	s1,24(sp)
    8000565e:	6942                	ld	s2,16(sp)
    80005660:	6145                	addi	sp,sp,48
    80005662:	8082                	ret
    return -1;
    80005664:	557d                	li	a0,-1
    80005666:	bfcd                	j	80005658 <argfd+0x52>
    return -1;
    80005668:	557d                	li	a0,-1
    8000566a:	b7fd                	j	80005658 <argfd+0x52>
    8000566c:	557d                	li	a0,-1
    8000566e:	b7ed                	j	80005658 <argfd+0x52>

0000000080005670 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005670:	1101                	addi	sp,sp,-32
    80005672:	ec06                	sd	ra,24(sp)
    80005674:	e822                	sd	s0,16(sp)
    80005676:	e426                	sd	s1,8(sp)
    80005678:	1000                	addi	s0,sp,32
    8000567a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000567c:	ffffc097          	auipc	ra,0xffffc
    80005680:	40a080e7          	jalr	1034(ra) # 80001a86 <myproc>
    80005684:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005686:	0d050793          	addi	a5,a0,208
    8000568a:	4501                	li	a0,0
    8000568c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000568e:	6398                	ld	a4,0(a5)
    80005690:	cb19                	beqz	a4,800056a6 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005692:	2505                	addiw	a0,a0,1
    80005694:	07a1                	addi	a5,a5,8
    80005696:	fed51ce3          	bne	a0,a3,8000568e <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000569a:	557d                	li	a0,-1
}
    8000569c:	60e2                	ld	ra,24(sp)
    8000569e:	6442                	ld	s0,16(sp)
    800056a0:	64a2                	ld	s1,8(sp)
    800056a2:	6105                	addi	sp,sp,32
    800056a4:	8082                	ret
      p->ofile[fd] = f;
    800056a6:	00351793          	slli	a5,a0,0x3
    800056aa:	0d078793          	addi	a5,a5,208
    800056ae:	963e                	add	a2,a2,a5
    800056b0:	e204                	sd	s1,0(a2)
      return fd;
    800056b2:	b7ed                	j	8000569c <fdalloc+0x2c>

00000000800056b4 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800056b4:	715d                	addi	sp,sp,-80
    800056b6:	e486                	sd	ra,72(sp)
    800056b8:	e0a2                	sd	s0,64(sp)
    800056ba:	fc26                	sd	s1,56(sp)
    800056bc:	f84a                	sd	s2,48(sp)
    800056be:	f44e                	sd	s3,40(sp)
    800056c0:	f052                	sd	s4,32(sp)
    800056c2:	ec56                	sd	s5,24(sp)
    800056c4:	0880                	addi	s0,sp,80
    800056c6:	89ae                	mv	s3,a1
    800056c8:	8a32                	mv	s4,a2
    800056ca:	8ab6                	mv	s5,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800056cc:	fb040593          	addi	a1,s0,-80
    800056d0:	fffff097          	auipc	ra,0xfffff
    800056d4:	dca080e7          	jalr	-566(ra) # 8000449a <nameiparent>
    800056d8:	892a                	mv	s2,a0
    800056da:	12050d63          	beqz	a0,80005814 <create+0x160>
    return 0;

  ilock(dp);
    800056de:	ffffe097          	auipc	ra,0xffffe
    800056e2:	5ac080e7          	jalr	1452(ra) # 80003c8a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800056e6:	4601                	li	a2,0
    800056e8:	fb040593          	addi	a1,s0,-80
    800056ec:	854a                	mv	a0,s2
    800056ee:	fffff097          	auipc	ra,0xfffff
    800056f2:	a8a080e7          	jalr	-1398(ra) # 80004178 <dirlookup>
    800056f6:	84aa                	mv	s1,a0
    800056f8:	c539                	beqz	a0,80005746 <create+0x92>
    iunlockput(dp);
    800056fa:	854a                	mv	a0,s2
    800056fc:	ffffe097          	auipc	ra,0xffffe
    80005700:	7f6080e7          	jalr	2038(ra) # 80003ef2 <iunlockput>
    ilock(ip);
    80005704:	8526                	mv	a0,s1
    80005706:	ffffe097          	auipc	ra,0xffffe
    8000570a:	584080e7          	jalr	1412(ra) # 80003c8a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000570e:	4789                	li	a5,2
    80005710:	02f99463          	bne	s3,a5,80005738 <create+0x84>
    80005714:	0444d783          	lhu	a5,68(s1)
    80005718:	37f9                	addiw	a5,a5,-2
    8000571a:	17c2                	slli	a5,a5,0x30
    8000571c:	93c1                	srli	a5,a5,0x30
    8000571e:	4705                	li	a4,1
    80005720:	00f76c63          	bltu	a4,a5,80005738 <create+0x84>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005724:	8526                	mv	a0,s1
    80005726:	60a6                	ld	ra,72(sp)
    80005728:	6406                	ld	s0,64(sp)
    8000572a:	74e2                	ld	s1,56(sp)
    8000572c:	7942                	ld	s2,48(sp)
    8000572e:	79a2                	ld	s3,40(sp)
    80005730:	7a02                	ld	s4,32(sp)
    80005732:	6ae2                	ld	s5,24(sp)
    80005734:	6161                	addi	sp,sp,80
    80005736:	8082                	ret
    iunlockput(ip);
    80005738:	8526                	mv	a0,s1
    8000573a:	ffffe097          	auipc	ra,0xffffe
    8000573e:	7b8080e7          	jalr	1976(ra) # 80003ef2 <iunlockput>
    return 0;
    80005742:	4481                	li	s1,0
    80005744:	b7c5                	j	80005724 <create+0x70>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005746:	85ce                	mv	a1,s3
    80005748:	00092503          	lw	a0,0(s2)
    8000574c:	ffffe097          	auipc	ra,0xffffe
    80005750:	3aa080e7          	jalr	938(ra) # 80003af6 <ialloc>
    80005754:	84aa                	mv	s1,a0
    80005756:	c521                	beqz	a0,8000579e <create+0xea>
  ilock(ip);
    80005758:	ffffe097          	auipc	ra,0xffffe
    8000575c:	532080e7          	jalr	1330(ra) # 80003c8a <ilock>
  ip->major = major;
    80005760:	05449323          	sh	s4,70(s1)
  ip->minor = minor;
    80005764:	05549423          	sh	s5,72(s1)
  ip->nlink = 1;
    80005768:	4785                	li	a5,1
    8000576a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000576e:	8526                	mv	a0,s1
    80005770:	ffffe097          	auipc	ra,0xffffe
    80005774:	44e080e7          	jalr	1102(ra) # 80003bbe <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005778:	4705                	li	a4,1
    8000577a:	02e98a63          	beq	s3,a4,800057ae <create+0xfa>
  if(dirlink(dp, name, ip->inum) < 0)
    8000577e:	40d0                	lw	a2,4(s1)
    80005780:	fb040593          	addi	a1,s0,-80
    80005784:	854a                	mv	a0,s2
    80005786:	fffff097          	auipc	ra,0xfffff
    8000578a:	c20080e7          	jalr	-992(ra) # 800043a6 <dirlink>
    8000578e:	06054b63          	bltz	a0,80005804 <create+0x150>
  iunlockput(dp);
    80005792:	854a                	mv	a0,s2
    80005794:	ffffe097          	auipc	ra,0xffffe
    80005798:	75e080e7          	jalr	1886(ra) # 80003ef2 <iunlockput>
  return ip;
    8000579c:	b761                	j	80005724 <create+0x70>
    panic("create: ialloc");
    8000579e:	00003517          	auipc	a0,0x3
    800057a2:	f2a50513          	addi	a0,a0,-214 # 800086c8 <etext+0x6c8>
    800057a6:	ffffb097          	auipc	ra,0xffffb
    800057aa:	db0080e7          	jalr	-592(ra) # 80000556 <panic>
    dp->nlink++;  // for ".."
    800057ae:	04a95783          	lhu	a5,74(s2)
    800057b2:	2785                	addiw	a5,a5,1
    800057b4:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800057b8:	854a                	mv	a0,s2
    800057ba:	ffffe097          	auipc	ra,0xffffe
    800057be:	404080e7          	jalr	1028(ra) # 80003bbe <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800057c2:	40d0                	lw	a2,4(s1)
    800057c4:	00003597          	auipc	a1,0x3
    800057c8:	f1458593          	addi	a1,a1,-236 # 800086d8 <etext+0x6d8>
    800057cc:	8526                	mv	a0,s1
    800057ce:	fffff097          	auipc	ra,0xfffff
    800057d2:	bd8080e7          	jalr	-1064(ra) # 800043a6 <dirlink>
    800057d6:	00054f63          	bltz	a0,800057f4 <create+0x140>
    800057da:	00492603          	lw	a2,4(s2)
    800057de:	00003597          	auipc	a1,0x3
    800057e2:	f0258593          	addi	a1,a1,-254 # 800086e0 <etext+0x6e0>
    800057e6:	8526                	mv	a0,s1
    800057e8:	fffff097          	auipc	ra,0xfffff
    800057ec:	bbe080e7          	jalr	-1090(ra) # 800043a6 <dirlink>
    800057f0:	f80557e3          	bgez	a0,8000577e <create+0xca>
      panic("create dots");
    800057f4:	00003517          	auipc	a0,0x3
    800057f8:	ef450513          	addi	a0,a0,-268 # 800086e8 <etext+0x6e8>
    800057fc:	ffffb097          	auipc	ra,0xffffb
    80005800:	d5a080e7          	jalr	-678(ra) # 80000556 <panic>
    panic("create: dirlink");
    80005804:	00003517          	auipc	a0,0x3
    80005808:	ef450513          	addi	a0,a0,-268 # 800086f8 <etext+0x6f8>
    8000580c:	ffffb097          	auipc	ra,0xffffb
    80005810:	d4a080e7          	jalr	-694(ra) # 80000556 <panic>
    return 0;
    80005814:	84aa                	mv	s1,a0
    80005816:	b739                	j	80005724 <create+0x70>

0000000080005818 <sys_dup>:
{
    80005818:	7179                	addi	sp,sp,-48
    8000581a:	f406                	sd	ra,40(sp)
    8000581c:	f022                	sd	s0,32(sp)
    8000581e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005820:	fd840613          	addi	a2,s0,-40
    80005824:	4581                	li	a1,0
    80005826:	4501                	li	a0,0
    80005828:	00000097          	auipc	ra,0x0
    8000582c:	dde080e7          	jalr	-546(ra) # 80005606 <argfd>
    return -1;
    80005830:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005832:	02054763          	bltz	a0,80005860 <sys_dup+0x48>
    80005836:	ec26                	sd	s1,24(sp)
    80005838:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    8000583a:	fd843483          	ld	s1,-40(s0)
    8000583e:	8526                	mv	a0,s1
    80005840:	00000097          	auipc	ra,0x0
    80005844:	e30080e7          	jalr	-464(ra) # 80005670 <fdalloc>
    80005848:	892a                	mv	s2,a0
    return -1;
    8000584a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000584c:	00054f63          	bltz	a0,8000586a <sys_dup+0x52>
  filedup(f);
    80005850:	8526                	mv	a0,s1
    80005852:	fffff097          	auipc	ra,0xfffff
    80005856:	2c0080e7          	jalr	704(ra) # 80004b12 <filedup>
  return fd;
    8000585a:	87ca                	mv	a5,s2
    8000585c:	64e2                	ld	s1,24(sp)
    8000585e:	6942                	ld	s2,16(sp)
}
    80005860:	853e                	mv	a0,a5
    80005862:	70a2                	ld	ra,40(sp)
    80005864:	7402                	ld	s0,32(sp)
    80005866:	6145                	addi	sp,sp,48
    80005868:	8082                	ret
    8000586a:	64e2                	ld	s1,24(sp)
    8000586c:	6942                	ld	s2,16(sp)
    8000586e:	bfcd                	j	80005860 <sys_dup+0x48>

0000000080005870 <sys_read>:
{
    80005870:	7179                	addi	sp,sp,-48
    80005872:	f406                	sd	ra,40(sp)
    80005874:	f022                	sd	s0,32(sp)
    80005876:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005878:	fe840613          	addi	a2,s0,-24
    8000587c:	4581                	li	a1,0
    8000587e:	4501                	li	a0,0
    80005880:	00000097          	auipc	ra,0x0
    80005884:	d86080e7          	jalr	-634(ra) # 80005606 <argfd>
    return -1;
    80005888:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000588a:	04054163          	bltz	a0,800058cc <sys_read+0x5c>
    8000588e:	fe440593          	addi	a1,s0,-28
    80005892:	4509                	li	a0,2
    80005894:	ffffd097          	auipc	ra,0xffffd
    80005898:	696080e7          	jalr	1686(ra) # 80002f2a <argint>
    return -1;
    8000589c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000589e:	02054763          	bltz	a0,800058cc <sys_read+0x5c>
    800058a2:	fd840593          	addi	a1,s0,-40
    800058a6:	4505                	li	a0,1
    800058a8:	ffffd097          	auipc	ra,0xffffd
    800058ac:	6a4080e7          	jalr	1700(ra) # 80002f4c <argaddr>
    return -1;
    800058b0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058b2:	00054d63          	bltz	a0,800058cc <sys_read+0x5c>
  return fileread(f, p, n);
    800058b6:	fe442603          	lw	a2,-28(s0)
    800058ba:	fd843583          	ld	a1,-40(s0)
    800058be:	fe843503          	ld	a0,-24(s0)
    800058c2:	fffff097          	auipc	ra,0xfffff
    800058c6:	3fa080e7          	jalr	1018(ra) # 80004cbc <fileread>
    800058ca:	87aa                	mv	a5,a0
}
    800058cc:	853e                	mv	a0,a5
    800058ce:	70a2                	ld	ra,40(sp)
    800058d0:	7402                	ld	s0,32(sp)
    800058d2:	6145                	addi	sp,sp,48
    800058d4:	8082                	ret

00000000800058d6 <sys_write>:
{
    800058d6:	7179                	addi	sp,sp,-48
    800058d8:	f406                	sd	ra,40(sp)
    800058da:	f022                	sd	s0,32(sp)
    800058dc:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058de:	fe840613          	addi	a2,s0,-24
    800058e2:	4581                	li	a1,0
    800058e4:	4501                	li	a0,0
    800058e6:	00000097          	auipc	ra,0x0
    800058ea:	d20080e7          	jalr	-736(ra) # 80005606 <argfd>
    return -1;
    800058ee:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058f0:	04054163          	bltz	a0,80005932 <sys_write+0x5c>
    800058f4:	fe440593          	addi	a1,s0,-28
    800058f8:	4509                	li	a0,2
    800058fa:	ffffd097          	auipc	ra,0xffffd
    800058fe:	630080e7          	jalr	1584(ra) # 80002f2a <argint>
    return -1;
    80005902:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005904:	02054763          	bltz	a0,80005932 <sys_write+0x5c>
    80005908:	fd840593          	addi	a1,s0,-40
    8000590c:	4505                	li	a0,1
    8000590e:	ffffd097          	auipc	ra,0xffffd
    80005912:	63e080e7          	jalr	1598(ra) # 80002f4c <argaddr>
    return -1;
    80005916:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005918:	00054d63          	bltz	a0,80005932 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000591c:	fe442603          	lw	a2,-28(s0)
    80005920:	fd843583          	ld	a1,-40(s0)
    80005924:	fe843503          	ld	a0,-24(s0)
    80005928:	fffff097          	auipc	ra,0xfffff
    8000592c:	46c080e7          	jalr	1132(ra) # 80004d94 <filewrite>
    80005930:	87aa                	mv	a5,a0
}
    80005932:	853e                	mv	a0,a5
    80005934:	70a2                	ld	ra,40(sp)
    80005936:	7402                	ld	s0,32(sp)
    80005938:	6145                	addi	sp,sp,48
    8000593a:	8082                	ret

000000008000593c <sys_close>:
{
    8000593c:	1101                	addi	sp,sp,-32
    8000593e:	ec06                	sd	ra,24(sp)
    80005940:	e822                	sd	s0,16(sp)
    80005942:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005944:	fe040613          	addi	a2,s0,-32
    80005948:	fec40593          	addi	a1,s0,-20
    8000594c:	4501                	li	a0,0
    8000594e:	00000097          	auipc	ra,0x0
    80005952:	cb8080e7          	jalr	-840(ra) # 80005606 <argfd>
    return -1;
    80005956:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005958:	02054563          	bltz	a0,80005982 <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    8000595c:	ffffc097          	auipc	ra,0xffffc
    80005960:	12a080e7          	jalr	298(ra) # 80001a86 <myproc>
    80005964:	fec42783          	lw	a5,-20(s0)
    80005968:	078e                	slli	a5,a5,0x3
    8000596a:	0d078793          	addi	a5,a5,208
    8000596e:	953e                	add	a0,a0,a5
    80005970:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005974:	fe043503          	ld	a0,-32(s0)
    80005978:	fffff097          	auipc	ra,0xfffff
    8000597c:	1ec080e7          	jalr	492(ra) # 80004b64 <fileclose>
  return 0;
    80005980:	4781                	li	a5,0
}
    80005982:	853e                	mv	a0,a5
    80005984:	60e2                	ld	ra,24(sp)
    80005986:	6442                	ld	s0,16(sp)
    80005988:	6105                	addi	sp,sp,32
    8000598a:	8082                	ret

000000008000598c <sys_fstat>:
{
    8000598c:	1101                	addi	sp,sp,-32
    8000598e:	ec06                	sd	ra,24(sp)
    80005990:	e822                	sd	s0,16(sp)
    80005992:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005994:	fe840613          	addi	a2,s0,-24
    80005998:	4581                	li	a1,0
    8000599a:	4501                	li	a0,0
    8000599c:	00000097          	auipc	ra,0x0
    800059a0:	c6a080e7          	jalr	-918(ra) # 80005606 <argfd>
    return -1;
    800059a4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800059a6:	02054563          	bltz	a0,800059d0 <sys_fstat+0x44>
    800059aa:	fe040593          	addi	a1,s0,-32
    800059ae:	4505                	li	a0,1
    800059b0:	ffffd097          	auipc	ra,0xffffd
    800059b4:	59c080e7          	jalr	1436(ra) # 80002f4c <argaddr>
    return -1;
    800059b8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800059ba:	00054b63          	bltz	a0,800059d0 <sys_fstat+0x44>
  return filestat(f, st);
    800059be:	fe043583          	ld	a1,-32(s0)
    800059c2:	fe843503          	ld	a0,-24(s0)
    800059c6:	fffff097          	auipc	ra,0xfffff
    800059ca:	280080e7          	jalr	640(ra) # 80004c46 <filestat>
    800059ce:	87aa                	mv	a5,a0
}
    800059d0:	853e                	mv	a0,a5
    800059d2:	60e2                	ld	ra,24(sp)
    800059d4:	6442                	ld	s0,16(sp)
    800059d6:	6105                	addi	sp,sp,32
    800059d8:	8082                	ret

00000000800059da <sys_link>:
{
    800059da:	7169                	addi	sp,sp,-304
    800059dc:	f606                	sd	ra,296(sp)
    800059de:	f222                	sd	s0,288(sp)
    800059e0:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059e2:	08000613          	li	a2,128
    800059e6:	ed040593          	addi	a1,s0,-304
    800059ea:	4501                	li	a0,0
    800059ec:	ffffd097          	auipc	ra,0xffffd
    800059f0:	582080e7          	jalr	1410(ra) # 80002f6e <argstr>
    return -1;
    800059f4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059f6:	12054663          	bltz	a0,80005b22 <sys_link+0x148>
    800059fa:	08000613          	li	a2,128
    800059fe:	f5040593          	addi	a1,s0,-176
    80005a02:	4505                	li	a0,1
    80005a04:	ffffd097          	auipc	ra,0xffffd
    80005a08:	56a080e7          	jalr	1386(ra) # 80002f6e <argstr>
    return -1;
    80005a0c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a0e:	10054a63          	bltz	a0,80005b22 <sys_link+0x148>
    80005a12:	ee26                	sd	s1,280(sp)
  begin_op();
    80005a14:	fffff097          	auipc	ra,0xfffff
    80005a18:	c6e080e7          	jalr	-914(ra) # 80004682 <begin_op>
  if((ip = namei(old)) == 0){
    80005a1c:	ed040513          	addi	a0,s0,-304
    80005a20:	fffff097          	auipc	ra,0xfffff
    80005a24:	a5c080e7          	jalr	-1444(ra) # 8000447c <namei>
    80005a28:	84aa                	mv	s1,a0
    80005a2a:	c949                	beqz	a0,80005abc <sys_link+0xe2>
  ilock(ip);
    80005a2c:	ffffe097          	auipc	ra,0xffffe
    80005a30:	25e080e7          	jalr	606(ra) # 80003c8a <ilock>
  if(ip->type == T_DIR){
    80005a34:	04449703          	lh	a4,68(s1)
    80005a38:	4785                	li	a5,1
    80005a3a:	08f70863          	beq	a4,a5,80005aca <sys_link+0xf0>
    80005a3e:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005a40:	04a4d783          	lhu	a5,74(s1)
    80005a44:	2785                	addiw	a5,a5,1
    80005a46:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a4a:	8526                	mv	a0,s1
    80005a4c:	ffffe097          	auipc	ra,0xffffe
    80005a50:	172080e7          	jalr	370(ra) # 80003bbe <iupdate>
  iunlock(ip);
    80005a54:	8526                	mv	a0,s1
    80005a56:	ffffe097          	auipc	ra,0xffffe
    80005a5a:	2fa080e7          	jalr	762(ra) # 80003d50 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005a5e:	fd040593          	addi	a1,s0,-48
    80005a62:	f5040513          	addi	a0,s0,-176
    80005a66:	fffff097          	auipc	ra,0xfffff
    80005a6a:	a34080e7          	jalr	-1484(ra) # 8000449a <nameiparent>
    80005a6e:	892a                	mv	s2,a0
    80005a70:	cd35                	beqz	a0,80005aec <sys_link+0x112>
  ilock(dp);
    80005a72:	ffffe097          	auipc	ra,0xffffe
    80005a76:	218080e7          	jalr	536(ra) # 80003c8a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005a7a:	854a                	mv	a0,s2
    80005a7c:	00092703          	lw	a4,0(s2)
    80005a80:	409c                	lw	a5,0(s1)
    80005a82:	06f71063          	bne	a4,a5,80005ae2 <sys_link+0x108>
    80005a86:	40d0                	lw	a2,4(s1)
    80005a88:	fd040593          	addi	a1,s0,-48
    80005a8c:	fffff097          	auipc	ra,0xfffff
    80005a90:	91a080e7          	jalr	-1766(ra) # 800043a6 <dirlink>
    80005a94:	04054763          	bltz	a0,80005ae2 <sys_link+0x108>
  iunlockput(dp);
    80005a98:	854a                	mv	a0,s2
    80005a9a:	ffffe097          	auipc	ra,0xffffe
    80005a9e:	458080e7          	jalr	1112(ra) # 80003ef2 <iunlockput>
  iput(ip);
    80005aa2:	8526                	mv	a0,s1
    80005aa4:	ffffe097          	auipc	ra,0xffffe
    80005aa8:	3a4080e7          	jalr	932(ra) # 80003e48 <iput>
  end_op();
    80005aac:	fffff097          	auipc	ra,0xfffff
    80005ab0:	c56080e7          	jalr	-938(ra) # 80004702 <end_op>
  return 0;
    80005ab4:	4781                	li	a5,0
    80005ab6:	64f2                	ld	s1,280(sp)
    80005ab8:	6952                	ld	s2,272(sp)
    80005aba:	a0a5                	j	80005b22 <sys_link+0x148>
    end_op();
    80005abc:	fffff097          	auipc	ra,0xfffff
    80005ac0:	c46080e7          	jalr	-954(ra) # 80004702 <end_op>
    return -1;
    80005ac4:	57fd                	li	a5,-1
    80005ac6:	64f2                	ld	s1,280(sp)
    80005ac8:	a8a9                	j	80005b22 <sys_link+0x148>
    iunlockput(ip);
    80005aca:	8526                	mv	a0,s1
    80005acc:	ffffe097          	auipc	ra,0xffffe
    80005ad0:	426080e7          	jalr	1062(ra) # 80003ef2 <iunlockput>
    end_op();
    80005ad4:	fffff097          	auipc	ra,0xfffff
    80005ad8:	c2e080e7          	jalr	-978(ra) # 80004702 <end_op>
    return -1;
    80005adc:	57fd                	li	a5,-1
    80005ade:	64f2                	ld	s1,280(sp)
    80005ae0:	a089                	j	80005b22 <sys_link+0x148>
    iunlockput(dp);
    80005ae2:	854a                	mv	a0,s2
    80005ae4:	ffffe097          	auipc	ra,0xffffe
    80005ae8:	40e080e7          	jalr	1038(ra) # 80003ef2 <iunlockput>
  ilock(ip);
    80005aec:	8526                	mv	a0,s1
    80005aee:	ffffe097          	auipc	ra,0xffffe
    80005af2:	19c080e7          	jalr	412(ra) # 80003c8a <ilock>
  ip->nlink--;
    80005af6:	04a4d783          	lhu	a5,74(s1)
    80005afa:	37fd                	addiw	a5,a5,-1
    80005afc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005b00:	8526                	mv	a0,s1
    80005b02:	ffffe097          	auipc	ra,0xffffe
    80005b06:	0bc080e7          	jalr	188(ra) # 80003bbe <iupdate>
  iunlockput(ip);
    80005b0a:	8526                	mv	a0,s1
    80005b0c:	ffffe097          	auipc	ra,0xffffe
    80005b10:	3e6080e7          	jalr	998(ra) # 80003ef2 <iunlockput>
  end_op();
    80005b14:	fffff097          	auipc	ra,0xfffff
    80005b18:	bee080e7          	jalr	-1042(ra) # 80004702 <end_op>
  return -1;
    80005b1c:	57fd                	li	a5,-1
    80005b1e:	64f2                	ld	s1,280(sp)
    80005b20:	6952                	ld	s2,272(sp)
}
    80005b22:	853e                	mv	a0,a5
    80005b24:	70b2                	ld	ra,296(sp)
    80005b26:	7412                	ld	s0,288(sp)
    80005b28:	6155                	addi	sp,sp,304
    80005b2a:	8082                	ret

0000000080005b2c <sys_unlink>:
{
    80005b2c:	7151                	addi	sp,sp,-240
    80005b2e:	f586                	sd	ra,232(sp)
    80005b30:	f1a2                	sd	s0,224(sp)
    80005b32:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005b34:	08000613          	li	a2,128
    80005b38:	f3040593          	addi	a1,s0,-208
    80005b3c:	4501                	li	a0,0
    80005b3e:	ffffd097          	auipc	ra,0xffffd
    80005b42:	430080e7          	jalr	1072(ra) # 80002f6e <argstr>
    80005b46:	1a054763          	bltz	a0,80005cf4 <sys_unlink+0x1c8>
    80005b4a:	eda6                	sd	s1,216(sp)
  begin_op();
    80005b4c:	fffff097          	auipc	ra,0xfffff
    80005b50:	b36080e7          	jalr	-1226(ra) # 80004682 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005b54:	fb040593          	addi	a1,s0,-80
    80005b58:	f3040513          	addi	a0,s0,-208
    80005b5c:	fffff097          	auipc	ra,0xfffff
    80005b60:	93e080e7          	jalr	-1730(ra) # 8000449a <nameiparent>
    80005b64:	84aa                	mv	s1,a0
    80005b66:	c165                	beqz	a0,80005c46 <sys_unlink+0x11a>
  ilock(dp);
    80005b68:	ffffe097          	auipc	ra,0xffffe
    80005b6c:	122080e7          	jalr	290(ra) # 80003c8a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005b70:	00003597          	auipc	a1,0x3
    80005b74:	b6858593          	addi	a1,a1,-1176 # 800086d8 <etext+0x6d8>
    80005b78:	fb040513          	addi	a0,s0,-80
    80005b7c:	ffffe097          	auipc	ra,0xffffe
    80005b80:	5e2080e7          	jalr	1506(ra) # 8000415e <namecmp>
    80005b84:	14050963          	beqz	a0,80005cd6 <sys_unlink+0x1aa>
    80005b88:	00003597          	auipc	a1,0x3
    80005b8c:	b5858593          	addi	a1,a1,-1192 # 800086e0 <etext+0x6e0>
    80005b90:	fb040513          	addi	a0,s0,-80
    80005b94:	ffffe097          	auipc	ra,0xffffe
    80005b98:	5ca080e7          	jalr	1482(ra) # 8000415e <namecmp>
    80005b9c:	12050d63          	beqz	a0,80005cd6 <sys_unlink+0x1aa>
    80005ba0:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005ba2:	f2c40613          	addi	a2,s0,-212
    80005ba6:	fb040593          	addi	a1,s0,-80
    80005baa:	8526                	mv	a0,s1
    80005bac:	ffffe097          	auipc	ra,0xffffe
    80005bb0:	5cc080e7          	jalr	1484(ra) # 80004178 <dirlookup>
    80005bb4:	892a                	mv	s2,a0
    80005bb6:	10050f63          	beqz	a0,80005cd4 <sys_unlink+0x1a8>
    80005bba:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80005bbc:	ffffe097          	auipc	ra,0xffffe
    80005bc0:	0ce080e7          	jalr	206(ra) # 80003c8a <ilock>
  if(ip->nlink < 1)
    80005bc4:	04a91783          	lh	a5,74(s2)
    80005bc8:	08f05663          	blez	a5,80005c54 <sys_unlink+0x128>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005bcc:	04491703          	lh	a4,68(s2)
    80005bd0:	4785                	li	a5,1
    80005bd2:	08f70963          	beq	a4,a5,80005c64 <sys_unlink+0x138>
  memset(&de, 0, sizeof(de));
    80005bd6:	fc040993          	addi	s3,s0,-64
    80005bda:	4641                	li	a2,16
    80005bdc:	4581                	li	a1,0
    80005bde:	854e                	mv	a0,s3
    80005be0:	ffffb097          	auipc	ra,0xffffb
    80005be4:	16c080e7          	jalr	364(ra) # 80000d4c <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005be8:	4741                	li	a4,16
    80005bea:	f2c42683          	lw	a3,-212(s0)
    80005bee:	864e                	mv	a2,s3
    80005bf0:	4581                	li	a1,0
    80005bf2:	8526                	mv	a0,s1
    80005bf4:	ffffe097          	auipc	ra,0xffffe
    80005bf8:	44e080e7          	jalr	1102(ra) # 80004042 <writei>
    80005bfc:	47c1                	li	a5,16
    80005bfe:	0af51863          	bne	a0,a5,80005cae <sys_unlink+0x182>
  if(ip->type == T_DIR){
    80005c02:	04491703          	lh	a4,68(s2)
    80005c06:	4785                	li	a5,1
    80005c08:	0af70b63          	beq	a4,a5,80005cbe <sys_unlink+0x192>
  iunlockput(dp);
    80005c0c:	8526                	mv	a0,s1
    80005c0e:	ffffe097          	auipc	ra,0xffffe
    80005c12:	2e4080e7          	jalr	740(ra) # 80003ef2 <iunlockput>
  ip->nlink--;
    80005c16:	04a95783          	lhu	a5,74(s2)
    80005c1a:	37fd                	addiw	a5,a5,-1
    80005c1c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005c20:	854a                	mv	a0,s2
    80005c22:	ffffe097          	auipc	ra,0xffffe
    80005c26:	f9c080e7          	jalr	-100(ra) # 80003bbe <iupdate>
  iunlockput(ip);
    80005c2a:	854a                	mv	a0,s2
    80005c2c:	ffffe097          	auipc	ra,0xffffe
    80005c30:	2c6080e7          	jalr	710(ra) # 80003ef2 <iunlockput>
  end_op();
    80005c34:	fffff097          	auipc	ra,0xfffff
    80005c38:	ace080e7          	jalr	-1330(ra) # 80004702 <end_op>
  return 0;
    80005c3c:	4501                	li	a0,0
    80005c3e:	64ee                	ld	s1,216(sp)
    80005c40:	694e                	ld	s2,208(sp)
    80005c42:	69ae                	ld	s3,200(sp)
    80005c44:	a065                	j	80005cec <sys_unlink+0x1c0>
    end_op();
    80005c46:	fffff097          	auipc	ra,0xfffff
    80005c4a:	abc080e7          	jalr	-1348(ra) # 80004702 <end_op>
    return -1;
    80005c4e:	557d                	li	a0,-1
    80005c50:	64ee                	ld	s1,216(sp)
    80005c52:	a869                	j	80005cec <sys_unlink+0x1c0>
    panic("unlink: nlink < 1");
    80005c54:	00003517          	auipc	a0,0x3
    80005c58:	ab450513          	addi	a0,a0,-1356 # 80008708 <etext+0x708>
    80005c5c:	ffffb097          	auipc	ra,0xffffb
    80005c60:	8fa080e7          	jalr	-1798(ra) # 80000556 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005c64:	04c92703          	lw	a4,76(s2)
    80005c68:	02000793          	li	a5,32
    80005c6c:	f6e7f5e3          	bgeu	a5,a4,80005bd6 <sys_unlink+0xaa>
    80005c70:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005c72:	4741                	li	a4,16
    80005c74:	86ce                	mv	a3,s3
    80005c76:	f1840613          	addi	a2,s0,-232
    80005c7a:	4581                	li	a1,0
    80005c7c:	854a                	mv	a0,s2
    80005c7e:	ffffe097          	auipc	ra,0xffffe
    80005c82:	2ca080e7          	jalr	714(ra) # 80003f48 <readi>
    80005c86:	47c1                	li	a5,16
    80005c88:	00f51b63          	bne	a0,a5,80005c9e <sys_unlink+0x172>
    if(de.inum != 0)
    80005c8c:	f1845783          	lhu	a5,-232(s0)
    80005c90:	e7a5                	bnez	a5,80005cf8 <sys_unlink+0x1cc>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005c92:	29c1                	addiw	s3,s3,16
    80005c94:	04c92783          	lw	a5,76(s2)
    80005c98:	fcf9ede3          	bltu	s3,a5,80005c72 <sys_unlink+0x146>
    80005c9c:	bf2d                	j	80005bd6 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005c9e:	00003517          	auipc	a0,0x3
    80005ca2:	a8250513          	addi	a0,a0,-1406 # 80008720 <etext+0x720>
    80005ca6:	ffffb097          	auipc	ra,0xffffb
    80005caa:	8b0080e7          	jalr	-1872(ra) # 80000556 <panic>
    panic("unlink: writei");
    80005cae:	00003517          	auipc	a0,0x3
    80005cb2:	a8a50513          	addi	a0,a0,-1398 # 80008738 <etext+0x738>
    80005cb6:	ffffb097          	auipc	ra,0xffffb
    80005cba:	8a0080e7          	jalr	-1888(ra) # 80000556 <panic>
    dp->nlink--;
    80005cbe:	04a4d783          	lhu	a5,74(s1)
    80005cc2:	37fd                	addiw	a5,a5,-1
    80005cc4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005cc8:	8526                	mv	a0,s1
    80005cca:	ffffe097          	auipc	ra,0xffffe
    80005cce:	ef4080e7          	jalr	-268(ra) # 80003bbe <iupdate>
    80005cd2:	bf2d                	j	80005c0c <sys_unlink+0xe0>
    80005cd4:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005cd6:	8526                	mv	a0,s1
    80005cd8:	ffffe097          	auipc	ra,0xffffe
    80005cdc:	21a080e7          	jalr	538(ra) # 80003ef2 <iunlockput>
  end_op();
    80005ce0:	fffff097          	auipc	ra,0xfffff
    80005ce4:	a22080e7          	jalr	-1502(ra) # 80004702 <end_op>
  return -1;
    80005ce8:	557d                	li	a0,-1
    80005cea:	64ee                	ld	s1,216(sp)
}
    80005cec:	70ae                	ld	ra,232(sp)
    80005cee:	740e                	ld	s0,224(sp)
    80005cf0:	616d                	addi	sp,sp,240
    80005cf2:	8082                	ret
    return -1;
    80005cf4:	557d                	li	a0,-1
    80005cf6:	bfdd                	j	80005cec <sys_unlink+0x1c0>
    iunlockput(ip);
    80005cf8:	854a                	mv	a0,s2
    80005cfa:	ffffe097          	auipc	ra,0xffffe
    80005cfe:	1f8080e7          	jalr	504(ra) # 80003ef2 <iunlockput>
    goto bad;
    80005d02:	694e                	ld	s2,208(sp)
    80005d04:	69ae                	ld	s3,200(sp)
    80005d06:	bfc1                	j	80005cd6 <sys_unlink+0x1aa>

0000000080005d08 <sys_open>:

uint64
sys_open(void)
{
    80005d08:	7131                	addi	sp,sp,-192
    80005d0a:	fd06                	sd	ra,184(sp)
    80005d0c:	f922                	sd	s0,176(sp)
    80005d0e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005d10:	08000613          	li	a2,128
    80005d14:	f5040593          	addi	a1,s0,-176
    80005d18:	4501                	li	a0,0
    80005d1a:	ffffd097          	auipc	ra,0xffffd
    80005d1e:	254080e7          	jalr	596(ra) # 80002f6e <argstr>
    return -1;
    80005d22:	57fd                	li	a5,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005d24:	0c054963          	bltz	a0,80005df6 <sys_open+0xee>
    80005d28:	f4c40593          	addi	a1,s0,-180
    80005d2c:	4505                	li	a0,1
    80005d2e:	ffffd097          	auipc	ra,0xffffd
    80005d32:	1fc080e7          	jalr	508(ra) # 80002f2a <argint>
    return -1;
    80005d36:	57fd                	li	a5,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005d38:	0a054f63          	bltz	a0,80005df6 <sys_open+0xee>
    80005d3c:	f526                	sd	s1,168(sp)

  begin_op();
    80005d3e:	fffff097          	auipc	ra,0xfffff
    80005d42:	944080e7          	jalr	-1724(ra) # 80004682 <begin_op>

  if(omode & O_CREATE){
    80005d46:	f4c42783          	lw	a5,-180(s0)
    80005d4a:	2007f793          	andi	a5,a5,512
    80005d4e:	c3e1                	beqz	a5,80005e0e <sys_open+0x106>
    ip = create(path, T_FILE, 0, 0);
    80005d50:	4681                	li	a3,0
    80005d52:	4601                	li	a2,0
    80005d54:	4589                	li	a1,2
    80005d56:	f5040513          	addi	a0,s0,-176
    80005d5a:	00000097          	auipc	ra,0x0
    80005d5e:	95a080e7          	jalr	-1702(ra) # 800056b4 <create>
    80005d62:	84aa                	mv	s1,a0
    if(ip == 0){
    80005d64:	cd51                	beqz	a0,80005e00 <sys_open+0xf8>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005d66:	04449703          	lh	a4,68(s1)
    80005d6a:	478d                	li	a5,3
    80005d6c:	00f71763          	bne	a4,a5,80005d7a <sys_open+0x72>
    80005d70:	0464d703          	lhu	a4,70(s1)
    80005d74:	47a5                	li	a5,9
    80005d76:	0ee7e363          	bltu	a5,a4,80005e5c <sys_open+0x154>
    80005d7a:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005d7c:	fffff097          	auipc	ra,0xfffff
    80005d80:	d2c080e7          	jalr	-724(ra) # 80004aa8 <filealloc>
    80005d84:	892a                	mv	s2,a0
    80005d86:	cd6d                	beqz	a0,80005e80 <sys_open+0x178>
    80005d88:	ed4e                	sd	s3,152(sp)
    80005d8a:	00000097          	auipc	ra,0x0
    80005d8e:	8e6080e7          	jalr	-1818(ra) # 80005670 <fdalloc>
    80005d92:	89aa                	mv	s3,a0
    80005d94:	0e054063          	bltz	a0,80005e74 <sys_open+0x16c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005d98:	04449703          	lh	a4,68(s1)
    80005d9c:	478d                	li	a5,3
    80005d9e:	0ef70e63          	beq	a4,a5,80005e9a <sys_open+0x192>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005da2:	4789                	li	a5,2
    80005da4:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005da8:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005dac:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005db0:	f4c42783          	lw	a5,-180(s0)
    80005db4:	0017f713          	andi	a4,a5,1
    80005db8:	00174713          	xori	a4,a4,1
    80005dbc:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005dc0:	0037f713          	andi	a4,a5,3
    80005dc4:	00e03733          	snez	a4,a4
    80005dc8:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005dcc:	4007f793          	andi	a5,a5,1024
    80005dd0:	c791                	beqz	a5,80005ddc <sys_open+0xd4>
    80005dd2:	04449703          	lh	a4,68(s1)
    80005dd6:	4789                	li	a5,2
    80005dd8:	0cf70863          	beq	a4,a5,80005ea8 <sys_open+0x1a0>
    itrunc(ip);
  }

  iunlock(ip);
    80005ddc:	8526                	mv	a0,s1
    80005dde:	ffffe097          	auipc	ra,0xffffe
    80005de2:	f72080e7          	jalr	-142(ra) # 80003d50 <iunlock>
  end_op();
    80005de6:	fffff097          	auipc	ra,0xfffff
    80005dea:	91c080e7          	jalr	-1764(ra) # 80004702 <end_op>

  return fd;
    80005dee:	87ce                	mv	a5,s3
    80005df0:	74aa                	ld	s1,168(sp)
    80005df2:	790a                	ld	s2,160(sp)
    80005df4:	69ea                	ld	s3,152(sp)
}
    80005df6:	853e                	mv	a0,a5
    80005df8:	70ea                	ld	ra,184(sp)
    80005dfa:	744a                	ld	s0,176(sp)
    80005dfc:	6129                	addi	sp,sp,192
    80005dfe:	8082                	ret
      end_op();
    80005e00:	fffff097          	auipc	ra,0xfffff
    80005e04:	902080e7          	jalr	-1790(ra) # 80004702 <end_op>
      return -1;
    80005e08:	57fd                	li	a5,-1
    80005e0a:	74aa                	ld	s1,168(sp)
    80005e0c:	b7ed                	j	80005df6 <sys_open+0xee>
    if((ip = namei(path)) == 0){
    80005e0e:	f5040513          	addi	a0,s0,-176
    80005e12:	ffffe097          	auipc	ra,0xffffe
    80005e16:	66a080e7          	jalr	1642(ra) # 8000447c <namei>
    80005e1a:	84aa                	mv	s1,a0
    80005e1c:	c90d                	beqz	a0,80005e4e <sys_open+0x146>
    ilock(ip);
    80005e1e:	ffffe097          	auipc	ra,0xffffe
    80005e22:	e6c080e7          	jalr	-404(ra) # 80003c8a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005e26:	04449703          	lh	a4,68(s1)
    80005e2a:	4785                	li	a5,1
    80005e2c:	f2f71de3          	bne	a4,a5,80005d66 <sys_open+0x5e>
    80005e30:	f4c42783          	lw	a5,-180(s0)
    80005e34:	d3b9                	beqz	a5,80005d7a <sys_open+0x72>
      iunlockput(ip);
    80005e36:	8526                	mv	a0,s1
    80005e38:	ffffe097          	auipc	ra,0xffffe
    80005e3c:	0ba080e7          	jalr	186(ra) # 80003ef2 <iunlockput>
      end_op();
    80005e40:	fffff097          	auipc	ra,0xfffff
    80005e44:	8c2080e7          	jalr	-1854(ra) # 80004702 <end_op>
      return -1;
    80005e48:	57fd                	li	a5,-1
    80005e4a:	74aa                	ld	s1,168(sp)
    80005e4c:	b76d                	j	80005df6 <sys_open+0xee>
      end_op();
    80005e4e:	fffff097          	auipc	ra,0xfffff
    80005e52:	8b4080e7          	jalr	-1868(ra) # 80004702 <end_op>
      return -1;
    80005e56:	57fd                	li	a5,-1
    80005e58:	74aa                	ld	s1,168(sp)
    80005e5a:	bf71                	j	80005df6 <sys_open+0xee>
    iunlockput(ip);
    80005e5c:	8526                	mv	a0,s1
    80005e5e:	ffffe097          	auipc	ra,0xffffe
    80005e62:	094080e7          	jalr	148(ra) # 80003ef2 <iunlockput>
    end_op();
    80005e66:	fffff097          	auipc	ra,0xfffff
    80005e6a:	89c080e7          	jalr	-1892(ra) # 80004702 <end_op>
    return -1;
    80005e6e:	57fd                	li	a5,-1
    80005e70:	74aa                	ld	s1,168(sp)
    80005e72:	b751                	j	80005df6 <sys_open+0xee>
      fileclose(f);
    80005e74:	854a                	mv	a0,s2
    80005e76:	fffff097          	auipc	ra,0xfffff
    80005e7a:	cee080e7          	jalr	-786(ra) # 80004b64 <fileclose>
    80005e7e:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005e80:	8526                	mv	a0,s1
    80005e82:	ffffe097          	auipc	ra,0xffffe
    80005e86:	070080e7          	jalr	112(ra) # 80003ef2 <iunlockput>
    end_op();
    80005e8a:	fffff097          	auipc	ra,0xfffff
    80005e8e:	878080e7          	jalr	-1928(ra) # 80004702 <end_op>
    return -1;
    80005e92:	57fd                	li	a5,-1
    80005e94:	74aa                	ld	s1,168(sp)
    80005e96:	790a                	ld	s2,160(sp)
    80005e98:	bfb9                	j	80005df6 <sys_open+0xee>
    f->type = FD_DEVICE;
    80005e9a:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005e9e:	04649783          	lh	a5,70(s1)
    80005ea2:	02f91223          	sh	a5,36(s2)
    80005ea6:	b719                	j	80005dac <sys_open+0xa4>
    itrunc(ip);
    80005ea8:	8526                	mv	a0,s1
    80005eaa:	ffffe097          	auipc	ra,0xffffe
    80005eae:	ef2080e7          	jalr	-270(ra) # 80003d9c <itrunc>
    80005eb2:	b72d                	j	80005ddc <sys_open+0xd4>

0000000080005eb4 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005eb4:	7175                	addi	sp,sp,-144
    80005eb6:	e506                	sd	ra,136(sp)
    80005eb8:	e122                	sd	s0,128(sp)
    80005eba:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005ebc:	ffffe097          	auipc	ra,0xffffe
    80005ec0:	7c6080e7          	jalr	1990(ra) # 80004682 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005ec4:	08000613          	li	a2,128
    80005ec8:	f7040593          	addi	a1,s0,-144
    80005ecc:	4501                	li	a0,0
    80005ece:	ffffd097          	auipc	ra,0xffffd
    80005ed2:	0a0080e7          	jalr	160(ra) # 80002f6e <argstr>
    80005ed6:	02054963          	bltz	a0,80005f08 <sys_mkdir+0x54>
    80005eda:	4681                	li	a3,0
    80005edc:	4601                	li	a2,0
    80005ede:	4585                	li	a1,1
    80005ee0:	f7040513          	addi	a0,s0,-144
    80005ee4:	fffff097          	auipc	ra,0xfffff
    80005ee8:	7d0080e7          	jalr	2000(ra) # 800056b4 <create>
    80005eec:	cd11                	beqz	a0,80005f08 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005eee:	ffffe097          	auipc	ra,0xffffe
    80005ef2:	004080e7          	jalr	4(ra) # 80003ef2 <iunlockput>
  end_op();
    80005ef6:	fffff097          	auipc	ra,0xfffff
    80005efa:	80c080e7          	jalr	-2036(ra) # 80004702 <end_op>
  return 0;
    80005efe:	4501                	li	a0,0
}
    80005f00:	60aa                	ld	ra,136(sp)
    80005f02:	640a                	ld	s0,128(sp)
    80005f04:	6149                	addi	sp,sp,144
    80005f06:	8082                	ret
    end_op();
    80005f08:	ffffe097          	auipc	ra,0xffffe
    80005f0c:	7fa080e7          	jalr	2042(ra) # 80004702 <end_op>
    return -1;
    80005f10:	557d                	li	a0,-1
    80005f12:	b7fd                	j	80005f00 <sys_mkdir+0x4c>

0000000080005f14 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005f14:	7135                	addi	sp,sp,-160
    80005f16:	ed06                	sd	ra,152(sp)
    80005f18:	e922                	sd	s0,144(sp)
    80005f1a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005f1c:	ffffe097          	auipc	ra,0xffffe
    80005f20:	766080e7          	jalr	1894(ra) # 80004682 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005f24:	08000613          	li	a2,128
    80005f28:	f7040593          	addi	a1,s0,-144
    80005f2c:	4501                	li	a0,0
    80005f2e:	ffffd097          	auipc	ra,0xffffd
    80005f32:	040080e7          	jalr	64(ra) # 80002f6e <argstr>
    80005f36:	04054a63          	bltz	a0,80005f8a <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005f3a:	f6c40593          	addi	a1,s0,-148
    80005f3e:	4505                	li	a0,1
    80005f40:	ffffd097          	auipc	ra,0xffffd
    80005f44:	fea080e7          	jalr	-22(ra) # 80002f2a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005f48:	04054163          	bltz	a0,80005f8a <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005f4c:	f6840593          	addi	a1,s0,-152
    80005f50:	4509                	li	a0,2
    80005f52:	ffffd097          	auipc	ra,0xffffd
    80005f56:	fd8080e7          	jalr	-40(ra) # 80002f2a <argint>
     argint(1, &major) < 0 ||
    80005f5a:	02054863          	bltz	a0,80005f8a <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005f5e:	f6841683          	lh	a3,-152(s0)
    80005f62:	f6c41603          	lh	a2,-148(s0)
    80005f66:	458d                	li	a1,3
    80005f68:	f7040513          	addi	a0,s0,-144
    80005f6c:	fffff097          	auipc	ra,0xfffff
    80005f70:	748080e7          	jalr	1864(ra) # 800056b4 <create>
     argint(2, &minor) < 0 ||
    80005f74:	c919                	beqz	a0,80005f8a <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005f76:	ffffe097          	auipc	ra,0xffffe
    80005f7a:	f7c080e7          	jalr	-132(ra) # 80003ef2 <iunlockput>
  end_op();
    80005f7e:	ffffe097          	auipc	ra,0xffffe
    80005f82:	784080e7          	jalr	1924(ra) # 80004702 <end_op>
  return 0;
    80005f86:	4501                	li	a0,0
    80005f88:	a031                	j	80005f94 <sys_mknod+0x80>
    end_op();
    80005f8a:	ffffe097          	auipc	ra,0xffffe
    80005f8e:	778080e7          	jalr	1912(ra) # 80004702 <end_op>
    return -1;
    80005f92:	557d                	li	a0,-1
}
    80005f94:	60ea                	ld	ra,152(sp)
    80005f96:	644a                	ld	s0,144(sp)
    80005f98:	610d                	addi	sp,sp,160
    80005f9a:	8082                	ret

0000000080005f9c <sys_chdir>:

uint64
sys_chdir(void)
{
    80005f9c:	7135                	addi	sp,sp,-160
    80005f9e:	ed06                	sd	ra,152(sp)
    80005fa0:	e922                	sd	s0,144(sp)
    80005fa2:	e14a                	sd	s2,128(sp)
    80005fa4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005fa6:	ffffc097          	auipc	ra,0xffffc
    80005faa:	ae0080e7          	jalr	-1312(ra) # 80001a86 <myproc>
    80005fae:	892a                	mv	s2,a0
  
  begin_op();
    80005fb0:	ffffe097          	auipc	ra,0xffffe
    80005fb4:	6d2080e7          	jalr	1746(ra) # 80004682 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005fb8:	08000613          	li	a2,128
    80005fbc:	f6040593          	addi	a1,s0,-160
    80005fc0:	4501                	li	a0,0
    80005fc2:	ffffd097          	auipc	ra,0xffffd
    80005fc6:	fac080e7          	jalr	-84(ra) # 80002f6e <argstr>
    80005fca:	04054d63          	bltz	a0,80006024 <sys_chdir+0x88>
    80005fce:	e526                	sd	s1,136(sp)
    80005fd0:	f6040513          	addi	a0,s0,-160
    80005fd4:	ffffe097          	auipc	ra,0xffffe
    80005fd8:	4a8080e7          	jalr	1192(ra) # 8000447c <namei>
    80005fdc:	84aa                	mv	s1,a0
    80005fde:	c131                	beqz	a0,80006022 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005fe0:	ffffe097          	auipc	ra,0xffffe
    80005fe4:	caa080e7          	jalr	-854(ra) # 80003c8a <ilock>
  if(ip->type != T_DIR){
    80005fe8:	04449703          	lh	a4,68(s1)
    80005fec:	4785                	li	a5,1
    80005fee:	04f71163          	bne	a4,a5,80006030 <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005ff2:	8526                	mv	a0,s1
    80005ff4:	ffffe097          	auipc	ra,0xffffe
    80005ff8:	d5c080e7          	jalr	-676(ra) # 80003d50 <iunlock>
  iput(p->cwd);
    80005ffc:	15093503          	ld	a0,336(s2)
    80006000:	ffffe097          	auipc	ra,0xffffe
    80006004:	e48080e7          	jalr	-440(ra) # 80003e48 <iput>
  end_op();
    80006008:	ffffe097          	auipc	ra,0xffffe
    8000600c:	6fa080e7          	jalr	1786(ra) # 80004702 <end_op>
  p->cwd = ip;
    80006010:	14993823          	sd	s1,336(s2)
  return 0;
    80006014:	4501                	li	a0,0
    80006016:	64aa                	ld	s1,136(sp)
}
    80006018:	60ea                	ld	ra,152(sp)
    8000601a:	644a                	ld	s0,144(sp)
    8000601c:	690a                	ld	s2,128(sp)
    8000601e:	610d                	addi	sp,sp,160
    80006020:	8082                	ret
    80006022:	64aa                	ld	s1,136(sp)
    end_op();
    80006024:	ffffe097          	auipc	ra,0xffffe
    80006028:	6de080e7          	jalr	1758(ra) # 80004702 <end_op>
    return -1;
    8000602c:	557d                	li	a0,-1
    8000602e:	b7ed                	j	80006018 <sys_chdir+0x7c>
    iunlockput(ip);
    80006030:	8526                	mv	a0,s1
    80006032:	ffffe097          	auipc	ra,0xffffe
    80006036:	ec0080e7          	jalr	-320(ra) # 80003ef2 <iunlockput>
    end_op();
    8000603a:	ffffe097          	auipc	ra,0xffffe
    8000603e:	6c8080e7          	jalr	1736(ra) # 80004702 <end_op>
    return -1;
    80006042:	557d                	li	a0,-1
    80006044:	64aa                	ld	s1,136(sp)
    80006046:	bfc9                	j	80006018 <sys_chdir+0x7c>

0000000080006048 <sys_exec>:

uint64
sys_exec(void)
{
    80006048:	7145                	addi	sp,sp,-464
    8000604a:	e786                	sd	ra,456(sp)
    8000604c:	e3a2                	sd	s0,448(sp)
    8000604e:	fb4a                	sd	s2,432(sp)
    80006050:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006052:	08000613          	li	a2,128
    80006056:	f4040593          	addi	a1,s0,-192
    8000605a:	4501                	li	a0,0
    8000605c:	ffffd097          	auipc	ra,0xffffd
    80006060:	f12080e7          	jalr	-238(ra) # 80002f6e <argstr>
    return -1;
    80006064:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006066:	10054463          	bltz	a0,8000616e <sys_exec+0x126>
    8000606a:	e3840593          	addi	a1,s0,-456
    8000606e:	4505                	li	a0,1
    80006070:	ffffd097          	auipc	ra,0xffffd
    80006074:	edc080e7          	jalr	-292(ra) # 80002f4c <argaddr>
    80006078:	0e054b63          	bltz	a0,8000616e <sys_exec+0x126>
    8000607c:	ff26                	sd	s1,440(sp)
    8000607e:	f74e                	sd	s3,424(sp)
    80006080:	f352                	sd	s4,416(sp)
    80006082:	ef56                	sd	s5,408(sp)
    80006084:	eb5a                	sd	s6,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80006086:	10000613          	li	a2,256
    8000608a:	4581                	li	a1,0
    8000608c:	e4040513          	addi	a0,s0,-448
    80006090:	ffffb097          	auipc	ra,0xffffb
    80006094:	cbc080e7          	jalr	-836(ra) # 80000d4c <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006098:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    8000609c:	89a6                	mv	s3,s1
    8000609e:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800060a0:	e3040a13          	addi	s4,s0,-464
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800060a4:	6a85                	lui	s5,0x1
    if(i >= NELEM(argv)){
    800060a6:	02000b13          	li	s6,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800060aa:	00391513          	slli	a0,s2,0x3
    800060ae:	85d2                	mv	a1,s4
    800060b0:	e3843783          	ld	a5,-456(s0)
    800060b4:	953e                	add	a0,a0,a5
    800060b6:	ffffd097          	auipc	ra,0xffffd
    800060ba:	dda080e7          	jalr	-550(ra) # 80002e90 <fetchaddr>
    800060be:	02054a63          	bltz	a0,800060f2 <sys_exec+0xaa>
    if(uarg == 0){
    800060c2:	e3043783          	ld	a5,-464(s0)
    800060c6:	cba1                	beqz	a5,80006116 <sys_exec+0xce>
    argv[i] = kalloc();
    800060c8:	ffffb097          	auipc	ra,0xffffb
    800060cc:	a88080e7          	jalr	-1400(ra) # 80000b50 <kalloc>
    800060d0:	85aa                	mv	a1,a0
    800060d2:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800060d6:	cd11                	beqz	a0,800060f2 <sys_exec+0xaa>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800060d8:	8656                	mv	a2,s5
    800060da:	e3043503          	ld	a0,-464(s0)
    800060de:	ffffd097          	auipc	ra,0xffffd
    800060e2:	e04080e7          	jalr	-508(ra) # 80002ee2 <fetchstr>
    800060e6:	00054663          	bltz	a0,800060f2 <sys_exec+0xaa>
    if(i >= NELEM(argv)){
    800060ea:	0905                	addi	s2,s2,1
    800060ec:	09a1                	addi	s3,s3,8
    800060ee:	fb691ee3          	bne	s2,s6,800060aa <sys_exec+0x62>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060f2:	f4040913          	addi	s2,s0,-192
    800060f6:	6088                	ld	a0,0(s1)
    800060f8:	c52d                	beqz	a0,80006162 <sys_exec+0x11a>
    kfree(argv[i]);
    800060fa:	ffffb097          	auipc	ra,0xffffb
    800060fe:	952080e7          	jalr	-1710(ra) # 80000a4c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006102:	04a1                	addi	s1,s1,8
    80006104:	ff2499e3          	bne	s1,s2,800060f6 <sys_exec+0xae>
  return -1;
    80006108:	597d                	li	s2,-1
    8000610a:	74fa                	ld	s1,440(sp)
    8000610c:	79ba                	ld	s3,424(sp)
    8000610e:	7a1a                	ld	s4,416(sp)
    80006110:	6afa                	ld	s5,408(sp)
    80006112:	6b5a                	ld	s6,400(sp)
    80006114:	a8a9                	j	8000616e <sys_exec+0x126>
      argv[i] = 0;
    80006116:	0009079b          	sext.w	a5,s2
    8000611a:	e4040593          	addi	a1,s0,-448
    8000611e:	078e                	slli	a5,a5,0x3
    80006120:	97ae                	add	a5,a5,a1
    80006122:	0007b023          	sd	zero,0(a5)
  int ret = exec(path, argv);
    80006126:	f4040513          	addi	a0,s0,-192
    8000612a:	fffff097          	auipc	ra,0xfffff
    8000612e:	128080e7          	jalr	296(ra) # 80005252 <exec>
    80006132:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006134:	f4040993          	addi	s3,s0,-192
    80006138:	6088                	ld	a0,0(s1)
    8000613a:	cd11                	beqz	a0,80006156 <sys_exec+0x10e>
    kfree(argv[i]);
    8000613c:	ffffb097          	auipc	ra,0xffffb
    80006140:	910080e7          	jalr	-1776(ra) # 80000a4c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006144:	04a1                	addi	s1,s1,8
    80006146:	ff3499e3          	bne	s1,s3,80006138 <sys_exec+0xf0>
    8000614a:	74fa                	ld	s1,440(sp)
    8000614c:	79ba                	ld	s3,424(sp)
    8000614e:	7a1a                	ld	s4,416(sp)
    80006150:	6afa                	ld	s5,408(sp)
    80006152:	6b5a                	ld	s6,400(sp)
    80006154:	a829                	j	8000616e <sys_exec+0x126>
  return ret;
    80006156:	74fa                	ld	s1,440(sp)
    80006158:	79ba                	ld	s3,424(sp)
    8000615a:	7a1a                	ld	s4,416(sp)
    8000615c:	6afa                	ld	s5,408(sp)
    8000615e:	6b5a                	ld	s6,400(sp)
    80006160:	a039                	j	8000616e <sys_exec+0x126>
  return -1;
    80006162:	597d                	li	s2,-1
    80006164:	74fa                	ld	s1,440(sp)
    80006166:	79ba                	ld	s3,424(sp)
    80006168:	7a1a                	ld	s4,416(sp)
    8000616a:	6afa                	ld	s5,408(sp)
    8000616c:	6b5a                	ld	s6,400(sp)
}
    8000616e:	854a                	mv	a0,s2
    80006170:	60be                	ld	ra,456(sp)
    80006172:	641e                	ld	s0,448(sp)
    80006174:	795a                	ld	s2,432(sp)
    80006176:	6179                	addi	sp,sp,464
    80006178:	8082                	ret

000000008000617a <sys_pipe>:

uint64
sys_pipe(void)
{
    8000617a:	7139                	addi	sp,sp,-64
    8000617c:	fc06                	sd	ra,56(sp)
    8000617e:	f822                	sd	s0,48(sp)
    80006180:	f426                	sd	s1,40(sp)
    80006182:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006184:	ffffc097          	auipc	ra,0xffffc
    80006188:	902080e7          	jalr	-1790(ra) # 80001a86 <myproc>
    8000618c:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    8000618e:	fd840593          	addi	a1,s0,-40
    80006192:	4501                	li	a0,0
    80006194:	ffffd097          	auipc	ra,0xffffd
    80006198:	db8080e7          	jalr	-584(ra) # 80002f4c <argaddr>
    return -1;
    8000619c:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    8000619e:	0e054363          	bltz	a0,80006284 <sys_pipe+0x10a>
  if(pipealloc(&rf, &wf) < 0)
    800061a2:	fc840593          	addi	a1,s0,-56
    800061a6:	fd040513          	addi	a0,s0,-48
    800061aa:	fffff097          	auipc	ra,0xfffff
    800061ae:	d3a080e7          	jalr	-710(ra) # 80004ee4 <pipealloc>
    return -1;
    800061b2:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800061b4:	0c054863          	bltz	a0,80006284 <sys_pipe+0x10a>
  fd0 = -1;
    800061b8:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800061bc:	fd043503          	ld	a0,-48(s0)
    800061c0:	fffff097          	auipc	ra,0xfffff
    800061c4:	4b0080e7          	jalr	1200(ra) # 80005670 <fdalloc>
    800061c8:	fca42223          	sw	a0,-60(s0)
    800061cc:	08054f63          	bltz	a0,8000626a <sys_pipe+0xf0>
    800061d0:	fc843503          	ld	a0,-56(s0)
    800061d4:	fffff097          	auipc	ra,0xfffff
    800061d8:	49c080e7          	jalr	1180(ra) # 80005670 <fdalloc>
    800061dc:	fca42023          	sw	a0,-64(s0)
    800061e0:	06054b63          	bltz	a0,80006256 <sys_pipe+0xdc>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800061e4:	4691                	li	a3,4
    800061e6:	fc440613          	addi	a2,s0,-60
    800061ea:	fd843583          	ld	a1,-40(s0)
    800061ee:	68a8                	ld	a0,80(s1)
    800061f0:	ffffb097          	auipc	ra,0xffffb
    800061f4:	51a080e7          	jalr	1306(ra) # 8000170a <copyout>
    800061f8:	02054063          	bltz	a0,80006218 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800061fc:	4691                	li	a3,4
    800061fe:	fc040613          	addi	a2,s0,-64
    80006202:	fd843583          	ld	a1,-40(s0)
    80006206:	95b6                	add	a1,a1,a3
    80006208:	68a8                	ld	a0,80(s1)
    8000620a:	ffffb097          	auipc	ra,0xffffb
    8000620e:	500080e7          	jalr	1280(ra) # 8000170a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006212:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006214:	06055863          	bgez	a0,80006284 <sys_pipe+0x10a>
    p->ofile[fd0] = 0;
    80006218:	fc442783          	lw	a5,-60(s0)
    8000621c:	078e                	slli	a5,a5,0x3
    8000621e:	0d078793          	addi	a5,a5,208
    80006222:	97a6                	add	a5,a5,s1
    80006224:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006228:	fc042783          	lw	a5,-64(s0)
    8000622c:	078e                	slli	a5,a5,0x3
    8000622e:	0d078793          	addi	a5,a5,208
    80006232:	00f48533          	add	a0,s1,a5
    80006236:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    8000623a:	fd043503          	ld	a0,-48(s0)
    8000623e:	fffff097          	auipc	ra,0xfffff
    80006242:	926080e7          	jalr	-1754(ra) # 80004b64 <fileclose>
    fileclose(wf);
    80006246:	fc843503          	ld	a0,-56(s0)
    8000624a:	fffff097          	auipc	ra,0xfffff
    8000624e:	91a080e7          	jalr	-1766(ra) # 80004b64 <fileclose>
    return -1;
    80006252:	57fd                	li	a5,-1
    80006254:	a805                	j	80006284 <sys_pipe+0x10a>
    if(fd0 >= 0)
    80006256:	fc442783          	lw	a5,-60(s0)
    8000625a:	0007c863          	bltz	a5,8000626a <sys_pipe+0xf0>
      p->ofile[fd0] = 0;
    8000625e:	078e                	slli	a5,a5,0x3
    80006260:	0d078793          	addi	a5,a5,208
    80006264:	97a6                	add	a5,a5,s1
    80006266:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000626a:	fd043503          	ld	a0,-48(s0)
    8000626e:	fffff097          	auipc	ra,0xfffff
    80006272:	8f6080e7          	jalr	-1802(ra) # 80004b64 <fileclose>
    fileclose(wf);
    80006276:	fc843503          	ld	a0,-56(s0)
    8000627a:	fffff097          	auipc	ra,0xfffff
    8000627e:	8ea080e7          	jalr	-1814(ra) # 80004b64 <fileclose>
    return -1;
    80006282:	57fd                	li	a5,-1
}
    80006284:	853e                	mv	a0,a5
    80006286:	70e2                	ld	ra,56(sp)
    80006288:	7442                	ld	s0,48(sp)
    8000628a:	74a2                	ld	s1,40(sp)
    8000628c:	6121                	addi	sp,sp,64
    8000628e:	8082                	ret

0000000080006290 <kernelvec>:
    80006290:	7111                	addi	sp,sp,-256
    80006292:	e006                	sd	ra,0(sp)
    80006294:	e40a                	sd	sp,8(sp)
    80006296:	e80e                	sd	gp,16(sp)
    80006298:	ec12                	sd	tp,24(sp)
    8000629a:	f016                	sd	t0,32(sp)
    8000629c:	f41a                	sd	t1,40(sp)
    8000629e:	f81e                	sd	t2,48(sp)
    800062a0:	fc22                	sd	s0,56(sp)
    800062a2:	e0a6                	sd	s1,64(sp)
    800062a4:	e4aa                	sd	a0,72(sp)
    800062a6:	e8ae                	sd	a1,80(sp)
    800062a8:	ecb2                	sd	a2,88(sp)
    800062aa:	f0b6                	sd	a3,96(sp)
    800062ac:	f4ba                	sd	a4,104(sp)
    800062ae:	f8be                	sd	a5,112(sp)
    800062b0:	fcc2                	sd	a6,120(sp)
    800062b2:	e146                	sd	a7,128(sp)
    800062b4:	e54a                	sd	s2,136(sp)
    800062b6:	e94e                	sd	s3,144(sp)
    800062b8:	ed52                	sd	s4,152(sp)
    800062ba:	f156                	sd	s5,160(sp)
    800062bc:	f55a                	sd	s6,168(sp)
    800062be:	f95e                	sd	s7,176(sp)
    800062c0:	fd62                	sd	s8,184(sp)
    800062c2:	e1e6                	sd	s9,192(sp)
    800062c4:	e5ea                	sd	s10,200(sp)
    800062c6:	e9ee                	sd	s11,208(sp)
    800062c8:	edf2                	sd	t3,216(sp)
    800062ca:	f1f6                	sd	t4,224(sp)
    800062cc:	f5fa                	sd	t5,232(sp)
    800062ce:	f9fe                	sd	t6,240(sp)
    800062d0:	a8bfc0ef          	jal	80002d5a <kerneltrap>
    800062d4:	6082                	ld	ra,0(sp)
    800062d6:	6122                	ld	sp,8(sp)
    800062d8:	61c2                	ld	gp,16(sp)
    800062da:	7282                	ld	t0,32(sp)
    800062dc:	7322                	ld	t1,40(sp)
    800062de:	73c2                	ld	t2,48(sp)
    800062e0:	7462                	ld	s0,56(sp)
    800062e2:	6486                	ld	s1,64(sp)
    800062e4:	6526                	ld	a0,72(sp)
    800062e6:	65c6                	ld	a1,80(sp)
    800062e8:	6666                	ld	a2,88(sp)
    800062ea:	7686                	ld	a3,96(sp)
    800062ec:	7726                	ld	a4,104(sp)
    800062ee:	77c6                	ld	a5,112(sp)
    800062f0:	7866                	ld	a6,120(sp)
    800062f2:	688a                	ld	a7,128(sp)
    800062f4:	692a                	ld	s2,136(sp)
    800062f6:	69ca                	ld	s3,144(sp)
    800062f8:	6a6a                	ld	s4,152(sp)
    800062fa:	7a8a                	ld	s5,160(sp)
    800062fc:	7b2a                	ld	s6,168(sp)
    800062fe:	7bca                	ld	s7,176(sp)
    80006300:	7c6a                	ld	s8,184(sp)
    80006302:	6c8e                	ld	s9,192(sp)
    80006304:	6d2e                	ld	s10,200(sp)
    80006306:	6dce                	ld	s11,208(sp)
    80006308:	6e6e                	ld	t3,216(sp)
    8000630a:	7e8e                	ld	t4,224(sp)
    8000630c:	7f2e                	ld	t5,232(sp)
    8000630e:	7fce                	ld	t6,240(sp)
    80006310:	6111                	addi	sp,sp,256
    80006312:	10200073          	sret
    80006316:	00000013          	nop
    8000631a:	00000013          	nop
    8000631e:	0001                	nop

0000000080006320 <timervec>:
    80006320:	34051573          	csrrw	a0,mscratch,a0
    80006324:	e10c                	sd	a1,0(a0)
    80006326:	e510                	sd	a2,8(a0)
    80006328:	e914                	sd	a3,16(a0)
    8000632a:	6d0c                	ld	a1,24(a0)
    8000632c:	7110                	ld	a2,32(a0)
    8000632e:	6194                	ld	a3,0(a1)
    80006330:	96b2                	add	a3,a3,a2
    80006332:	e194                	sd	a3,0(a1)
    80006334:	4589                	li	a1,2
    80006336:	14459073          	csrw	sip,a1
    8000633a:	6914                	ld	a3,16(a0)
    8000633c:	6510                	ld	a2,8(a0)
    8000633e:	610c                	ld	a1,0(a0)
    80006340:	34051573          	csrrw	a0,mscratch,a0
    80006344:	30200073          	mret
    80006348:	0001                	nop

000000008000634a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000634a:	1141                	addi	sp,sp,-16
    8000634c:	e406                	sd	ra,8(sp)
    8000634e:	e022                	sd	s0,0(sp)
    80006350:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006352:	0c000737          	lui	a4,0xc000
    80006356:	4785                	li	a5,1
    80006358:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000635a:	c35c                	sw	a5,4(a4)
}
    8000635c:	60a2                	ld	ra,8(sp)
    8000635e:	6402                	ld	s0,0(sp)
    80006360:	0141                	addi	sp,sp,16
    80006362:	8082                	ret

0000000080006364 <plicinithart>:

void
plicinithart(void)
{
    80006364:	1141                	addi	sp,sp,-16
    80006366:	e406                	sd	ra,8(sp)
    80006368:	e022                	sd	s0,0(sp)
    8000636a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000636c:	ffffb097          	auipc	ra,0xffffb
    80006370:	6e6080e7          	jalr	1766(ra) # 80001a52 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006374:	0085171b          	slliw	a4,a0,0x8
    80006378:	0c0027b7          	lui	a5,0xc002
    8000637c:	97ba                	add	a5,a5,a4
    8000637e:	40200713          	li	a4,1026
    80006382:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006386:	00d5151b          	slliw	a0,a0,0xd
    8000638a:	0c2017b7          	lui	a5,0xc201
    8000638e:	97aa                	add	a5,a5,a0
    80006390:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006394:	60a2                	ld	ra,8(sp)
    80006396:	6402                	ld	s0,0(sp)
    80006398:	0141                	addi	sp,sp,16
    8000639a:	8082                	ret

000000008000639c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000639c:	1141                	addi	sp,sp,-16
    8000639e:	e406                	sd	ra,8(sp)
    800063a0:	e022                	sd	s0,0(sp)
    800063a2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800063a4:	ffffb097          	auipc	ra,0xffffb
    800063a8:	6ae080e7          	jalr	1710(ra) # 80001a52 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800063ac:	00d5151b          	slliw	a0,a0,0xd
    800063b0:	0c2017b7          	lui	a5,0xc201
    800063b4:	97aa                	add	a5,a5,a0
  return irq;
}
    800063b6:	43c8                	lw	a0,4(a5)
    800063b8:	60a2                	ld	ra,8(sp)
    800063ba:	6402                	ld	s0,0(sp)
    800063bc:	0141                	addi	sp,sp,16
    800063be:	8082                	ret

00000000800063c0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800063c0:	1101                	addi	sp,sp,-32
    800063c2:	ec06                	sd	ra,24(sp)
    800063c4:	e822                	sd	s0,16(sp)
    800063c6:	e426                	sd	s1,8(sp)
    800063c8:	1000                	addi	s0,sp,32
    800063ca:	84aa                	mv	s1,a0
  int hart = cpuid();
    800063cc:	ffffb097          	auipc	ra,0xffffb
    800063d0:	686080e7          	jalr	1670(ra) # 80001a52 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800063d4:	00d5179b          	slliw	a5,a0,0xd
    800063d8:	0c201737          	lui	a4,0xc201
    800063dc:	97ba                	add	a5,a5,a4
    800063de:	c3c4                	sw	s1,4(a5)
}
    800063e0:	60e2                	ld	ra,24(sp)
    800063e2:	6442                	ld	s0,16(sp)
    800063e4:	64a2                	ld	s1,8(sp)
    800063e6:	6105                	addi	sp,sp,32
    800063e8:	8082                	ret

00000000800063ea <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800063ea:	1141                	addi	sp,sp,-16
    800063ec:	e406                	sd	ra,8(sp)
    800063ee:	e022                	sd	s0,0(sp)
    800063f0:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800063f2:	479d                	li	a5,7
    800063f4:	06a7c863          	blt	a5,a0,80006464 <free_desc+0x7a>
    panic("free_desc 1");
  if(disk.free[i])
    800063f8:	00021717          	auipc	a4,0x21
    800063fc:	c0870713          	addi	a4,a4,-1016 # 80027000 <disk>
    80006400:	972a                	add	a4,a4,a0
    80006402:	6789                	lui	a5,0x2
    80006404:	97ba                	add	a5,a5,a4
    80006406:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    8000640a:	e7ad                	bnez	a5,80006474 <free_desc+0x8a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000640c:	00451793          	slli	a5,a0,0x4
    80006410:	00023717          	auipc	a4,0x23
    80006414:	bf070713          	addi	a4,a4,-1040 # 80029000 <disk+0x2000>
    80006418:	6314                	ld	a3,0(a4)
    8000641a:	96be                	add	a3,a3,a5
    8000641c:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006420:	6314                	ld	a3,0(a4)
    80006422:	96be                	add	a3,a3,a5
    80006424:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006428:	6314                	ld	a3,0(a4)
    8000642a:	96be                	add	a3,a3,a5
    8000642c:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80006430:	6318                	ld	a4,0(a4)
    80006432:	97ba                	add	a5,a5,a4
    80006434:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006438:	00021717          	auipc	a4,0x21
    8000643c:	bc870713          	addi	a4,a4,-1080 # 80027000 <disk>
    80006440:	972a                	add	a4,a4,a0
    80006442:	6789                	lui	a5,0x2
    80006444:	97ba                	add	a5,a5,a4
    80006446:	4705                	li	a4,1
    80006448:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000644c:	00023517          	auipc	a0,0x23
    80006450:	bcc50513          	addi	a0,a0,-1076 # 80029018 <disk+0x2018>
    80006454:	ffffc097          	auipc	ra,0xffffc
    80006458:	fc6080e7          	jalr	-58(ra) # 8000241a <wakeup>
}
    8000645c:	60a2                	ld	ra,8(sp)
    8000645e:	6402                	ld	s0,0(sp)
    80006460:	0141                	addi	sp,sp,16
    80006462:	8082                	ret
    panic("free_desc 1");
    80006464:	00002517          	auipc	a0,0x2
    80006468:	2e450513          	addi	a0,a0,740 # 80008748 <etext+0x748>
    8000646c:	ffffa097          	auipc	ra,0xffffa
    80006470:	0ea080e7          	jalr	234(ra) # 80000556 <panic>
    panic("free_desc 2");
    80006474:	00002517          	auipc	a0,0x2
    80006478:	2e450513          	addi	a0,a0,740 # 80008758 <etext+0x758>
    8000647c:	ffffa097          	auipc	ra,0xffffa
    80006480:	0da080e7          	jalr	218(ra) # 80000556 <panic>

0000000080006484 <virtio_disk_init>:
{
    80006484:	1141                	addi	sp,sp,-16
    80006486:	e406                	sd	ra,8(sp)
    80006488:	e022                	sd	s0,0(sp)
    8000648a:	0800                	addi	s0,sp,16
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000648c:	00002597          	auipc	a1,0x2
    80006490:	2dc58593          	addi	a1,a1,732 # 80008768 <etext+0x768>
    80006494:	00023517          	auipc	a0,0x23
    80006498:	c9450513          	addi	a0,a0,-876 # 80029128 <disk+0x2128>
    8000649c:	ffffa097          	auipc	ra,0xffffa
    800064a0:	71e080e7          	jalr	1822(ra) # 80000bba <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800064a4:	100017b7          	lui	a5,0x10001
    800064a8:	4398                	lw	a4,0(a5)
    800064aa:	2701                	sext.w	a4,a4
    800064ac:	747277b7          	lui	a5,0x74727
    800064b0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800064b4:	0ef71563          	bne	a4,a5,8000659e <virtio_disk_init+0x11a>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800064b8:	100017b7          	lui	a5,0x10001
    800064bc:	43dc                	lw	a5,4(a5)
    800064be:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800064c0:	4705                	li	a4,1
    800064c2:	0ce79e63          	bne	a5,a4,8000659e <virtio_disk_init+0x11a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800064c6:	100017b7          	lui	a5,0x10001
    800064ca:	479c                	lw	a5,8(a5)
    800064cc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800064ce:	4709                	li	a4,2
    800064d0:	0ce79763          	bne	a5,a4,8000659e <virtio_disk_init+0x11a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800064d4:	100017b7          	lui	a5,0x10001
    800064d8:	47d8                	lw	a4,12(a5)
    800064da:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800064dc:	554d47b7          	lui	a5,0x554d4
    800064e0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800064e4:	0af71d63          	bne	a4,a5,8000659e <virtio_disk_init+0x11a>
  *R(VIRTIO_MMIO_STATUS) = status;
    800064e8:	100017b7          	lui	a5,0x10001
    800064ec:	4705                	li	a4,1
    800064ee:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800064f0:	470d                	li	a4,3
    800064f2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800064f4:	10001737          	lui	a4,0x10001
    800064f8:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800064fa:	c7ffe6b7          	lui	a3,0xc7ffe
    800064fe:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd475f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006502:	8f75                	and	a4,a4,a3
    80006504:	100016b7          	lui	a3,0x10001
    80006508:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000650a:	472d                	li	a4,11
    8000650c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000650e:	473d                	li	a4,15
    80006510:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006512:	6705                	lui	a4,0x1
    80006514:	d698                	sw	a4,40(a3)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006516:	0206a823          	sw	zero,48(a3) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000651a:	5adc                	lw	a5,52(a3)
    8000651c:	2781                	sext.w	a5,a5
  if(max == 0)
    8000651e:	cbc1                	beqz	a5,800065ae <virtio_disk_init+0x12a>
  if(max < NUM)
    80006520:	471d                	li	a4,7
    80006522:	08f77e63          	bgeu	a4,a5,800065be <virtio_disk_init+0x13a>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006526:	100017b7          	lui	a5,0x10001
    8000652a:	4721                	li	a4,8
    8000652c:	df98                	sw	a4,56(a5)
  memset(disk.pages, 0, sizeof(disk.pages));
    8000652e:	6609                	lui	a2,0x2
    80006530:	4581                	li	a1,0
    80006532:	00021517          	auipc	a0,0x21
    80006536:	ace50513          	addi	a0,a0,-1330 # 80027000 <disk>
    8000653a:	ffffb097          	auipc	ra,0xffffb
    8000653e:	812080e7          	jalr	-2030(ra) # 80000d4c <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006542:	00021717          	auipc	a4,0x21
    80006546:	abe70713          	addi	a4,a4,-1346 # 80027000 <disk>
    8000654a:	00c75793          	srli	a5,a4,0xc
    8000654e:	2781                	sext.w	a5,a5
    80006550:	100016b7          	lui	a3,0x10001
    80006554:	c2bc                	sw	a5,64(a3)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006556:	00023797          	auipc	a5,0x23
    8000655a:	aaa78793          	addi	a5,a5,-1366 # 80029000 <disk+0x2000>
    8000655e:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006560:	00021717          	auipc	a4,0x21
    80006564:	b2070713          	addi	a4,a4,-1248 # 80027080 <disk+0x80>
    80006568:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    8000656a:	00022717          	auipc	a4,0x22
    8000656e:	a9670713          	addi	a4,a4,-1386 # 80028000 <disk+0x1000>
    80006572:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006574:	4705                	li	a4,1
    80006576:	00e78c23          	sb	a4,24(a5)
    8000657a:	00e78ca3          	sb	a4,25(a5)
    8000657e:	00e78d23          	sb	a4,26(a5)
    80006582:	00e78da3          	sb	a4,27(a5)
    80006586:	00e78e23          	sb	a4,28(a5)
    8000658a:	00e78ea3          	sb	a4,29(a5)
    8000658e:	00e78f23          	sb	a4,30(a5)
    80006592:	00e78fa3          	sb	a4,31(a5)
}
    80006596:	60a2                	ld	ra,8(sp)
    80006598:	6402                	ld	s0,0(sp)
    8000659a:	0141                	addi	sp,sp,16
    8000659c:	8082                	ret
    panic("could not find virtio disk");
    8000659e:	00002517          	auipc	a0,0x2
    800065a2:	1da50513          	addi	a0,a0,474 # 80008778 <etext+0x778>
    800065a6:	ffffa097          	auipc	ra,0xffffa
    800065aa:	fb0080e7          	jalr	-80(ra) # 80000556 <panic>
    panic("virtio disk has no queue 0");
    800065ae:	00002517          	auipc	a0,0x2
    800065b2:	1ea50513          	addi	a0,a0,490 # 80008798 <etext+0x798>
    800065b6:	ffffa097          	auipc	ra,0xffffa
    800065ba:	fa0080e7          	jalr	-96(ra) # 80000556 <panic>
    panic("virtio disk max queue too short");
    800065be:	00002517          	auipc	a0,0x2
    800065c2:	1fa50513          	addi	a0,a0,506 # 800087b8 <etext+0x7b8>
    800065c6:	ffffa097          	auipc	ra,0xffffa
    800065ca:	f90080e7          	jalr	-112(ra) # 80000556 <panic>

00000000800065ce <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800065ce:	711d                	addi	sp,sp,-96
    800065d0:	ec86                	sd	ra,88(sp)
    800065d2:	e8a2                	sd	s0,80(sp)
    800065d4:	e4a6                	sd	s1,72(sp)
    800065d6:	e0ca                	sd	s2,64(sp)
    800065d8:	fc4e                	sd	s3,56(sp)
    800065da:	f852                	sd	s4,48(sp)
    800065dc:	f456                	sd	s5,40(sp)
    800065de:	f05a                	sd	s6,32(sp)
    800065e0:	ec5e                	sd	s7,24(sp)
    800065e2:	e862                	sd	s8,16(sp)
    800065e4:	1080                	addi	s0,sp,96
    800065e6:	89aa                	mv	s3,a0
    800065e8:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800065ea:	00c52b83          	lw	s7,12(a0)
    800065ee:	001b9b9b          	slliw	s7,s7,0x1
    800065f2:	1b82                	slli	s7,s7,0x20
    800065f4:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    800065f8:	00023517          	auipc	a0,0x23
    800065fc:	b3050513          	addi	a0,a0,-1232 # 80029128 <disk+0x2128>
    80006600:	ffffa097          	auipc	ra,0xffffa
    80006604:	654080e7          	jalr	1620(ra) # 80000c54 <acquire>
  for(int i = 0; i < NUM; i++){
    80006608:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000660a:	00021b17          	auipc	s6,0x21
    8000660e:	9f6b0b13          	addi	s6,s6,-1546 # 80027000 <disk>
    80006612:	6a89                	lui	s5,0x2
  for(int i = 0; i < 3; i++){
    80006614:	4a0d                	li	s4,3
    80006616:	a88d                	j	80006688 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006618:	00fb0733          	add	a4,s6,a5
    8000661c:	9756                	add	a4,a4,s5
    8000661e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006622:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006624:	0207c563          	bltz	a5,8000664e <virtio_disk_rw+0x80>
  for(int i = 0; i < 3; i++){
    80006628:	2905                	addiw	s2,s2,1
    8000662a:	0611                	addi	a2,a2,4 # 2004 <_entry-0x7fffdffc>
    8000662c:	1b490063          	beq	s2,s4,800067cc <virtio_disk_rw+0x1fe>
    idx[i] = alloc_desc();
    80006630:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006632:	00023717          	auipc	a4,0x23
    80006636:	9e670713          	addi	a4,a4,-1562 # 80029018 <disk+0x2018>
    8000663a:	4781                	li	a5,0
    if(disk.free[i]){
    8000663c:	00074683          	lbu	a3,0(a4)
    80006640:	fee1                	bnez	a3,80006618 <virtio_disk_rw+0x4a>
  for(int i = 0; i < NUM; i++){
    80006642:	2785                	addiw	a5,a5,1
    80006644:	0705                	addi	a4,a4,1
    80006646:	fe979be3          	bne	a5,s1,8000663c <virtio_disk_rw+0x6e>
    idx[i] = alloc_desc();
    8000664a:	57fd                	li	a5,-1
    8000664c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000664e:	03205163          	blez	s2,80006670 <virtio_disk_rw+0xa2>
        free_desc(idx[j]);
    80006652:	fa042503          	lw	a0,-96(s0)
    80006656:	00000097          	auipc	ra,0x0
    8000665a:	d94080e7          	jalr	-620(ra) # 800063ea <free_desc>
      for(int j = 0; j < i; j++)
    8000665e:	4785                	li	a5,1
    80006660:	0127d863          	bge	a5,s2,80006670 <virtio_disk_rw+0xa2>
        free_desc(idx[j]);
    80006664:	fa442503          	lw	a0,-92(s0)
    80006668:	00000097          	auipc	ra,0x0
    8000666c:	d82080e7          	jalr	-638(ra) # 800063ea <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006670:	00023597          	auipc	a1,0x23
    80006674:	ab858593          	addi	a1,a1,-1352 # 80029128 <disk+0x2128>
    80006678:	00023517          	auipc	a0,0x23
    8000667c:	9a050513          	addi	a0,a0,-1632 # 80029018 <disk+0x2018>
    80006680:	ffffc097          	auipc	ra,0xffffc
    80006684:	c14080e7          	jalr	-1004(ra) # 80002294 <sleep>
  for(int i = 0; i < 3; i++){
    80006688:	fa040613          	addi	a2,s0,-96
    8000668c:	4901                	li	s2,0
    8000668e:	b74d                	j	80006630 <virtio_disk_rw+0x62>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006690:	00023717          	auipc	a4,0x23
    80006694:	97073703          	ld	a4,-1680(a4) # 80029000 <disk+0x2000>
    80006698:	973e                	add	a4,a4,a5
    8000669a:	00071623          	sh	zero,12(a4)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000669e:	00021897          	auipc	a7,0x21
    800066a2:	96288893          	addi	a7,a7,-1694 # 80027000 <disk>
    800066a6:	00023717          	auipc	a4,0x23
    800066aa:	95a70713          	addi	a4,a4,-1702 # 80029000 <disk+0x2000>
    800066ae:	6314                	ld	a3,0(a4)
    800066b0:	96be                	add	a3,a3,a5
    800066b2:	00c6d583          	lhu	a1,12(a3) # 1000100c <_entry-0x6fffeff4>
    800066b6:	0015e593          	ori	a1,a1,1
    800066ba:	00b69623          	sh	a1,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800066be:	fa842683          	lw	a3,-88(s0)
    800066c2:	630c                	ld	a1,0(a4)
    800066c4:	97ae                	add	a5,a5,a1
    800066c6:	00d79723          	sh	a3,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800066ca:	20050593          	addi	a1,a0,512
    800066ce:	0592                	slli	a1,a1,0x4
    800066d0:	95c6                	add	a1,a1,a7
    800066d2:	57fd                	li	a5,-1
    800066d4:	02f58823          	sb	a5,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800066d8:	00469793          	slli	a5,a3,0x4
    800066dc:	00073803          	ld	a6,0(a4)
    800066e0:	983e                	add	a6,a6,a5
    800066e2:	6689                	lui	a3,0x2
    800066e4:	03068693          	addi	a3,a3,48 # 2030 <_entry-0x7fffdfd0>
    800066e8:	96b2                	add	a3,a3,a2
    800066ea:	96c6                	add	a3,a3,a7
    800066ec:	00d83023          	sd	a3,0(a6)
  disk.desc[idx[2]].len = 1;
    800066f0:	6314                	ld	a3,0(a4)
    800066f2:	96be                	add	a3,a3,a5
    800066f4:	4605                	li	a2,1
    800066f6:	c690                	sw	a2,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800066f8:	6314                	ld	a3,0(a4)
    800066fa:	96be                	add	a3,a3,a5
    800066fc:	4809                	li	a6,2
    800066fe:	01069623          	sh	a6,12(a3)
  disk.desc[idx[2]].next = 0;
    80006702:	6314                	ld	a3,0(a4)
    80006704:	97b6                	add	a5,a5,a3
    80006706:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000670a:	00c9a223          	sw	a2,4(s3)
  disk.info[idx[0]].b = b;
    8000670e:	0335b423          	sd	s3,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006712:	6714                	ld	a3,8(a4)
    80006714:	0026d783          	lhu	a5,2(a3)
    80006718:	8b9d                	andi	a5,a5,7
    8000671a:	0786                	slli	a5,a5,0x1
    8000671c:	96be                	add	a3,a3,a5
    8000671e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006722:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006726:	6718                	ld	a4,8(a4)
    80006728:	00275783          	lhu	a5,2(a4)
    8000672c:	2785                	addiw	a5,a5,1
    8000672e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006732:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006736:	100017b7          	lui	a5,0x10001
    8000673a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000673e:	0049a783          	lw	a5,4(s3)
    80006742:	02c79163          	bne	a5,a2,80006764 <virtio_disk_rw+0x196>
    sleep(b, &disk.vdisk_lock);
    80006746:	00023917          	auipc	s2,0x23
    8000674a:	9e290913          	addi	s2,s2,-1566 # 80029128 <disk+0x2128>
  while(b->disk == 1) {
    8000674e:	84be                	mv	s1,a5
    sleep(b, &disk.vdisk_lock);
    80006750:	85ca                	mv	a1,s2
    80006752:	854e                	mv	a0,s3
    80006754:	ffffc097          	auipc	ra,0xffffc
    80006758:	b40080e7          	jalr	-1216(ra) # 80002294 <sleep>
  while(b->disk == 1) {
    8000675c:	0049a783          	lw	a5,4(s3)
    80006760:	fe9788e3          	beq	a5,s1,80006750 <virtio_disk_rw+0x182>
  }

  disk.info[idx[0]].b = 0;
    80006764:	fa042903          	lw	s2,-96(s0)
    80006768:	20090713          	addi	a4,s2,512
    8000676c:	0712                	slli	a4,a4,0x4
    8000676e:	00021797          	auipc	a5,0x21
    80006772:	89278793          	addi	a5,a5,-1902 # 80027000 <disk>
    80006776:	97ba                	add	a5,a5,a4
    80006778:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    8000677c:	00023997          	auipc	s3,0x23
    80006780:	88498993          	addi	s3,s3,-1916 # 80029000 <disk+0x2000>
    80006784:	00491713          	slli	a4,s2,0x4
    80006788:	0009b783          	ld	a5,0(s3)
    8000678c:	97ba                	add	a5,a5,a4
    8000678e:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006792:	854a                	mv	a0,s2
    80006794:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006798:	00000097          	auipc	ra,0x0
    8000679c:	c52080e7          	jalr	-942(ra) # 800063ea <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800067a0:	8885                	andi	s1,s1,1
    800067a2:	f0ed                	bnez	s1,80006784 <virtio_disk_rw+0x1b6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800067a4:	00023517          	auipc	a0,0x23
    800067a8:	98450513          	addi	a0,a0,-1660 # 80029128 <disk+0x2128>
    800067ac:	ffffa097          	auipc	ra,0xffffa
    800067b0:	558080e7          	jalr	1368(ra) # 80000d04 <release>
}
    800067b4:	60e6                	ld	ra,88(sp)
    800067b6:	6446                	ld	s0,80(sp)
    800067b8:	64a6                	ld	s1,72(sp)
    800067ba:	6906                	ld	s2,64(sp)
    800067bc:	79e2                	ld	s3,56(sp)
    800067be:	7a42                	ld	s4,48(sp)
    800067c0:	7aa2                	ld	s5,40(sp)
    800067c2:	7b02                	ld	s6,32(sp)
    800067c4:	6be2                	ld	s7,24(sp)
    800067c6:	6c42                	ld	s8,16(sp)
    800067c8:	6125                	addi	sp,sp,96
    800067ca:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800067cc:	fa042503          	lw	a0,-96(s0)
    800067d0:	00451613          	slli	a2,a0,0x4
  if(write)
    800067d4:	00021597          	auipc	a1,0x21
    800067d8:	82c58593          	addi	a1,a1,-2004 # 80027000 <disk>
    800067dc:	20050793          	addi	a5,a0,512
    800067e0:	0792                	slli	a5,a5,0x4
    800067e2:	97ae                	add	a5,a5,a1
    800067e4:	01803733          	snez	a4,s8
    800067e8:	0ae7a423          	sw	a4,168(a5)
  buf0->reserved = 0;
    800067ec:	0a07a623          	sw	zero,172(a5)
  buf0->sector = sector;
    800067f0:	0b77b823          	sd	s7,176(a5)
  disk.desc[idx[0]].addr = (uint64) buf0;
    800067f4:	00023717          	auipc	a4,0x23
    800067f8:	80c70713          	addi	a4,a4,-2036 # 80029000 <disk+0x2000>
    800067fc:	6314                	ld	a3,0(a4)
    800067fe:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006800:	6789                	lui	a5,0x2
    80006802:	0a878793          	addi	a5,a5,168 # 20a8 <_entry-0x7fffdf58>
    80006806:	97b2                	add	a5,a5,a2
    80006808:	97ae                	add	a5,a5,a1
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000680a:	e29c                	sd	a5,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000680c:	631c                	ld	a5,0(a4)
    8000680e:	97b2                	add	a5,a5,a2
    80006810:	46c1                	li	a3,16
    80006812:	c794                	sw	a3,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006814:	631c                	ld	a5,0(a4)
    80006816:	97b2                	add	a5,a5,a2
    80006818:	4685                	li	a3,1
    8000681a:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[0]].next = idx[1];
    8000681e:	fa442783          	lw	a5,-92(s0)
    80006822:	6314                	ld	a3,0(a4)
    80006824:	96b2                	add	a3,a3,a2
    80006826:	00f69723          	sh	a5,14(a3)
  disk.desc[idx[1]].addr = (uint64) b->data;
    8000682a:	0792                	slli	a5,a5,0x4
    8000682c:	6314                	ld	a3,0(a4)
    8000682e:	96be                	add	a3,a3,a5
    80006830:	05898593          	addi	a1,s3,88
    80006834:	e28c                	sd	a1,0(a3)
  disk.desc[idx[1]].len = BSIZE;
    80006836:	6318                	ld	a4,0(a4)
    80006838:	973e                	add	a4,a4,a5
    8000683a:	40000693          	li	a3,1024
    8000683e:	c714                	sw	a3,8(a4)
  if(write)
    80006840:	e40c18e3          	bnez	s8,80006690 <virtio_disk_rw+0xc2>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006844:	00022717          	auipc	a4,0x22
    80006848:	7bc73703          	ld	a4,1980(a4) # 80029000 <disk+0x2000>
    8000684c:	973e                	add	a4,a4,a5
    8000684e:	4689                	li	a3,2
    80006850:	00d71623          	sh	a3,12(a4)
    80006854:	b5a9                	j	8000669e <virtio_disk_rw+0xd0>

0000000080006856 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006856:	1101                	addi	sp,sp,-32
    80006858:	ec06                	sd	ra,24(sp)
    8000685a:	e822                	sd	s0,16(sp)
    8000685c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000685e:	00023517          	auipc	a0,0x23
    80006862:	8ca50513          	addi	a0,a0,-1846 # 80029128 <disk+0x2128>
    80006866:	ffffa097          	auipc	ra,0xffffa
    8000686a:	3ee080e7          	jalr	1006(ra) # 80000c54 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000686e:	100017b7          	lui	a5,0x10001
    80006872:	53bc                	lw	a5,96(a5)
    80006874:	8b8d                	andi	a5,a5,3
    80006876:	10001737          	lui	a4,0x10001
    8000687a:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000687c:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006880:	00022797          	auipc	a5,0x22
    80006884:	78078793          	addi	a5,a5,1920 # 80029000 <disk+0x2000>
    80006888:	6b94                	ld	a3,16(a5)
    8000688a:	0207d703          	lhu	a4,32(a5)
    8000688e:	0026d783          	lhu	a5,2(a3)
    80006892:	06f70563          	beq	a4,a5,800068fc <virtio_disk_intr+0xa6>
    80006896:	e426                	sd	s1,8(sp)
    80006898:	e04a                	sd	s2,0(sp)
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000689a:	00020917          	auipc	s2,0x20
    8000689e:	76690913          	addi	s2,s2,1894 # 80027000 <disk>
    800068a2:	00022497          	auipc	s1,0x22
    800068a6:	75e48493          	addi	s1,s1,1886 # 80029000 <disk+0x2000>
    __sync_synchronize();
    800068aa:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800068ae:	6898                	ld	a4,16(s1)
    800068b0:	0204d783          	lhu	a5,32(s1)
    800068b4:	8b9d                	andi	a5,a5,7
    800068b6:	078e                	slli	a5,a5,0x3
    800068b8:	97ba                	add	a5,a5,a4
    800068ba:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800068bc:	20078713          	addi	a4,a5,512
    800068c0:	0712                	slli	a4,a4,0x4
    800068c2:	974a                	add	a4,a4,s2
    800068c4:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800068c8:	e731                	bnez	a4,80006914 <virtio_disk_intr+0xbe>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800068ca:	20078793          	addi	a5,a5,512
    800068ce:	0792                	slli	a5,a5,0x4
    800068d0:	97ca                	add	a5,a5,s2
    800068d2:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800068d4:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800068d8:	ffffc097          	auipc	ra,0xffffc
    800068dc:	b42080e7          	jalr	-1214(ra) # 8000241a <wakeup>

    disk.used_idx += 1;
    800068e0:	0204d783          	lhu	a5,32(s1)
    800068e4:	2785                	addiw	a5,a5,1
    800068e6:	17c2                	slli	a5,a5,0x30
    800068e8:	93c1                	srli	a5,a5,0x30
    800068ea:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800068ee:	6898                	ld	a4,16(s1)
    800068f0:	00275703          	lhu	a4,2(a4)
    800068f4:	faf71be3          	bne	a4,a5,800068aa <virtio_disk_intr+0x54>
    800068f8:	64a2                	ld	s1,8(sp)
    800068fa:	6902                	ld	s2,0(sp)
  }

  release(&disk.vdisk_lock);
    800068fc:	00023517          	auipc	a0,0x23
    80006900:	82c50513          	addi	a0,a0,-2004 # 80029128 <disk+0x2128>
    80006904:	ffffa097          	auipc	ra,0xffffa
    80006908:	400080e7          	jalr	1024(ra) # 80000d04 <release>
}
    8000690c:	60e2                	ld	ra,24(sp)
    8000690e:	6442                	ld	s0,16(sp)
    80006910:	6105                	addi	sp,sp,32
    80006912:	8082                	ret
      panic("virtio_disk_intr status");
    80006914:	00002517          	auipc	a0,0x2
    80006918:	ec450513          	addi	a0,a0,-316 # 800087d8 <etext+0x7d8>
    8000691c:	ffffa097          	auipc	ra,0xffffa
    80006920:	c3a080e7          	jalr	-966(ra) # 80000556 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
