
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
    80000066:	2ae78793          	addi	a5,a5,686 # 80006310 <timervec>
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
    80000138:	598080e7          	jalr	1432(ra) # 800026cc <either_copyin>
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
    800001de:	0ee080e7          	jalr	238(ra) # 800022c8 <sleep>
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
    80000226:	454080e7          	jalr	1108(ra) # 80002676 <either_copyout>
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
    80000310:	416080e7          	jalr	1046(ra) # 80002722 <procdump>
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
    80000466:	fec080e7          	jalr	-20(ra) # 8000244e <wakeup>
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
    800004d6:	30680813          	addi	a6,a6,774 # 800087d8 <digits>
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
    80000606:	1d6a8a93          	addi	s5,s5,470 # 800087d8 <digits>
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
    800008ec:	b66080e7          	jalr	-1178(ra) # 8000244e <wakeup>
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
    8000097a:	952080e7          	jalr	-1710(ra) # 800022c8 <sleep>
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
    80000f50:	b10080e7          	jalr	-1264(ra) # 80002a5c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f54:	00005097          	auipc	ra,0x5
    80000f58:	400080e7          	jalr	1024(ra) # 80006354 <plicinithart>
  }

  scheduler();        
    80000f5c:	00001097          	auipc	ra,0x1
    80000f60:	0d4080e7          	jalr	212(ra) # 80002030 <scheduler>
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
    80000fc8:	a70080e7          	jalr	-1424(ra) # 80002a34 <trapinit>
    trapinithart();  // install kernel trap vector
    80000fcc:	00002097          	auipc	ra,0x2
    80000fd0:	a90080e7          	jalr	-1392(ra) # 80002a5c <trapinithart>
    plicinit();      // set up interrupt controller
    80000fd4:	00005097          	auipc	ra,0x5
    80000fd8:	366080e7          	jalr	870(ra) # 8000633a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fdc:	00005097          	auipc	ra,0x5
    80000fe0:	378080e7          	jalr	888(ra) # 80006354 <plicinithart>
    binit();         // buffer cache
    80000fe4:	00002097          	auipc	ra,0x2
    80000fe8:	430080e7          	jalr	1072(ra) # 80003414 <binit>
    iinit();         // inode table
    80000fec:	00003097          	auipc	ra,0x3
    80000ff0:	a8e080e7          	jalr	-1394(ra) # 80003a7a <iinit>
    fileinit();      // file table
    80000ff4:	00004097          	auipc	ra,0x4
    80000ff8:	a70080e7          	jalr	-1424(ra) # 80004a64 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ffc:	00005097          	auipc	ra,0x5
    80001000:	478080e7          	jalr	1144(ra) # 80006474 <virtio_disk_init>
    userinit();      // first user process
    80001004:	00001097          	auipc	ra,0x1
    80001008:	d90080e7          	jalr	-624(ra) # 80001d94 <userinit>
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
    80001adc:	9687a783          	lw	a5,-1688(a5) # 8000b440 <first.1>
    80001ae0:	eb89                	bnez	a5,80001af2 <forkret+0x32>
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001ae2:	00001097          	auipc	ra,0x1
    80001ae6:	f96080e7          	jalr	-106(ra) # 80002a78 <usertrapret>
}
    80001aea:	60a2                	ld	ra,8(sp)
    80001aec:	6402                	ld	s0,0(sp)
    80001aee:	0141                	addi	sp,sp,16
    80001af0:	8082                	ret
    first = 0;
    80001af2:	0000a797          	auipc	a5,0xa
    80001af6:	9407a723          	sw	zero,-1714(a5) # 8000b440 <first.1>
    fsinit(ROOTDEV);
    80001afa:	4505                	li	a0,1
    80001afc:	00002097          	auipc	ra,0x2
    80001b00:	f00080e7          	jalr	-256(ra) # 800039fc <fsinit>
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
    80001b24:	92478793          	addi	a5,a5,-1756 # 8000b444 <nextpid>
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
    80001cd0:	a059                	j	80001d56 <allocproc+0xc4>
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
    p->max_mem = 128 * 1024;
    80001d0c:	000207b7          	lui	a5,0x20
    80001d10:	1af4bc23          	sd	a5,440(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001d14:	fffff097          	auipc	ra,0xfffff
    80001d18:	e3c080e7          	jalr	-452(ra) # 80000b50 <kalloc>
    80001d1c:	892a                	mv	s2,a0
    80001d1e:	eca8                	sd	a0,88(s1)
    80001d20:	c131                	beqz	a0,80001d64 <allocproc+0xd2>
  p->pagetable = proc_pagetable(p);
    80001d22:	8526                	mv	a0,s1
    80001d24:	00000097          	auipc	ra,0x0
    80001d28:	e28080e7          	jalr	-472(ra) # 80001b4c <proc_pagetable>
    80001d2c:	892a                	mv	s2,a0
    80001d2e:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001d30:	c531                	beqz	a0,80001d7c <allocproc+0xea>
  memset(&p->context, 0, sizeof(p->context));
    80001d32:	07000613          	li	a2,112
    80001d36:	4581                	li	a1,0
    80001d38:	06048513          	addi	a0,s1,96
    80001d3c:	fffff097          	auipc	ra,0xfffff
    80001d40:	010080e7          	jalr	16(ra) # 80000d4c <memset>
  p->context.ra = (uint64)forkret;     // direccion de retorno para fork()
    80001d44:	00000797          	auipc	a5,0x0
    80001d48:	d7c78793          	addi	a5,a5,-644 # 80001ac0 <forkret>
    80001d4c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;  // stack pointer del kernel
    80001d4e:	60bc                	ld	a5,64(s1)
    80001d50:	6705                	lui	a4,0x1
    80001d52:	97ba                	add	a5,a5,a4
    80001d54:	f4bc                	sd	a5,104(s1)
}
    80001d56:	8526                	mv	a0,s1
    80001d58:	60e2                	ld	ra,24(sp)
    80001d5a:	6442                	ld	s0,16(sp)
    80001d5c:	64a2                	ld	s1,8(sp)
    80001d5e:	6902                	ld	s2,0(sp)
    80001d60:	6105                	addi	sp,sp,32
    80001d62:	8082                	ret
    freeproc(p); // si falla memoria se limpia el proceso
    80001d64:	8526                	mv	a0,s1
    80001d66:	00000097          	auipc	ra,0x0
    80001d6a:	ed4080e7          	jalr	-300(ra) # 80001c3a <freeproc>
    release(&p->lock);
    80001d6e:	8526                	mv	a0,s1
    80001d70:	fffff097          	auipc	ra,0xfffff
    80001d74:	f94080e7          	jalr	-108(ra) # 80000d04 <release>
    return 0;
    80001d78:	84ca                	mv	s1,s2
    80001d7a:	bff1                	j	80001d56 <allocproc+0xc4>
    freeproc(p);
    80001d7c:	8526                	mv	a0,s1
    80001d7e:	00000097          	auipc	ra,0x0
    80001d82:	ebc080e7          	jalr	-324(ra) # 80001c3a <freeproc>
    release(&p->lock);
    80001d86:	8526                	mv	a0,s1
    80001d88:	fffff097          	auipc	ra,0xfffff
    80001d8c:	f7c080e7          	jalr	-132(ra) # 80000d04 <release>
    return 0;
    80001d90:	84ca                	mv	s1,s2
    80001d92:	b7d1                	j	80001d56 <allocproc+0xc4>

0000000080001d94 <userinit>:
{
    80001d94:	1101                	addi	sp,sp,-32
    80001d96:	ec06                	sd	ra,24(sp)
    80001d98:	e822                	sd	s0,16(sp)
    80001d9a:	e426                	sd	s1,8(sp)
    80001d9c:	1000                	addi	s0,sp,32
  p = allocproc(); // nuevo proceso
    80001d9e:	00000097          	auipc	ra,0x0
    80001da2:	ef4080e7          	jalr	-268(ra) # 80001c92 <allocproc>
    80001da6:	84aa                	mv	s1,a0
  initproc = p;
    80001da8:	0000a797          	auipc	a5,0xa
    80001dac:	28a7b023          	sd	a0,640(a5) # 8000c028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001db0:	03400613          	li	a2,52
    80001db4:	00009597          	auipc	a1,0x9
    80001db8:	69c58593          	addi	a1,a1,1692 # 8000b450 <initcode>
    80001dbc:	6928                	ld	a0,80(a0)
    80001dbe:	fffff097          	auipc	ra,0xfffff
    80001dc2:	630080e7          	jalr	1584(ra) # 800013ee <uvminit>
  p->sz = PGSIZE;
    80001dc6:	6785                	lui	a5,0x1
    80001dc8:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;
    80001dca:	6cb8                	ld	a4,88(s1)
    80001dcc:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;
    80001dd0:	6cb8                	ld	a4,88(s1)
    80001dd2:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001dd4:	4641                	li	a2,16
    80001dd6:	00006597          	auipc	a1,0x6
    80001dda:	40a58593          	addi	a1,a1,1034 # 800081e0 <etext+0x1e0>
    80001dde:	15848513          	addi	a0,s1,344
    80001de2:	fffff097          	auipc	ra,0xfffff
    80001de6:	0c2080e7          	jalr	194(ra) # 80000ea4 <safestrcpy>
  p->cwd = namei("/"); // directorio raiz
    80001dea:	00006517          	auipc	a0,0x6
    80001dee:	40650513          	addi	a0,a0,1030 # 800081f0 <etext+0x1f0>
    80001df2:	00002097          	auipc	ra,0x2
    80001df6:	66e080e7          	jalr	1646(ra) # 80004460 <namei>
    80001dfa:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE; // listo para ejecutar
    80001dfe:	478d                	li	a5,3
    80001e00:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001e02:	8526                	mv	a0,s1
    80001e04:	fffff097          	auipc	ra,0xfffff
    80001e08:	f00080e7          	jalr	-256(ra) # 80000d04 <release>
}
    80001e0c:	60e2                	ld	ra,24(sp)
    80001e0e:	6442                	ld	s0,16(sp)
    80001e10:	64a2                	ld	s1,8(sp)
    80001e12:	6105                	addi	sp,sp,32
    80001e14:	8082                	ret

0000000080001e16 <growproc>:
{
    80001e16:	1101                	addi	sp,sp,-32
    80001e18:	ec06                	sd	ra,24(sp)
    80001e1a:	e822                	sd	s0,16(sp)
    80001e1c:	e426                	sd	s1,8(sp)
    80001e1e:	e04a                	sd	s2,0(sp)
    80001e20:	1000                	addi	s0,sp,32
    80001e22:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001e24:	00000097          	auipc	ra,0x0
    80001e28:	c62080e7          	jalr	-926(ra) # 80001a86 <myproc>
    80001e2c:	892a                	mv	s2,a0
  sz = p->sz;
    80001e2e:	652c                	ld	a1,72(a0)
    80001e30:	0005879b          	sext.w	a5,a1
  if(n > 0){
    80001e34:	04905b63          	blez	s1,80001e8a <growproc+0x74>
    uint64 new_sz = sz + n;
    80001e38:	00f4863b          	addw	a2,s1,a5
    80001e3c:	1602                	slli	a2,a2,0x20
    80001e3e:	9201                	srli	a2,a2,0x20
    if(new_sz > p->max_mem){
    80001e40:	1b853783          	ld	a5,440(a0)
    80001e44:	02c7e763          	bltu	a5,a2,80001e72 <growproc+0x5c>
    if((sz = uvmalloc(p->pagetable, sz, new_sz)) == 0){
    80001e48:	1582                	slli	a1,a1,0x20
    80001e4a:	9181                	srli	a1,a1,0x20
    80001e4c:	6928                	ld	a0,80(a0)
    80001e4e:	fffff097          	auipc	ra,0xfffff
    80001e52:	65a080e7          	jalr	1626(ra) # 800014a8 <uvmalloc>
    80001e56:	0005079b          	sext.w	a5,a0
    80001e5a:	cba1                	beqz	a5,80001eaa <growproc+0x94>
  p->sz = sz;
    80001e5c:	1782                	slli	a5,a5,0x20
    80001e5e:	9381                	srli	a5,a5,0x20
    80001e60:	04f93423          	sd	a5,72(s2)
  return 0;
    80001e64:	4501                	li	a0,0
}
    80001e66:	60e2                	ld	ra,24(sp)
    80001e68:	6442                	ld	s0,16(sp)
    80001e6a:	64a2                	ld	s1,8(sp)
    80001e6c:	6902                	ld	s2,0(sp)
    80001e6e:	6105                	addi	sp,sp,32
    80001e70:	8082                	ret
      printf("Proceso %d excedio su limite de memoria (%d bytes)\n",
    80001e72:	863e                	mv	a2,a5
    80001e74:	590c                	lw	a1,48(a0)
    80001e76:	00006517          	auipc	a0,0x6
    80001e7a:	38250513          	addi	a0,a0,898 # 800081f8 <etext+0x1f8>
    80001e7e:	ffffe097          	auipc	ra,0xffffe
    80001e82:	722080e7          	jalr	1826(ra) # 800005a0 <printf>
      return -1;
    80001e86:	557d                	li	a0,-1
    80001e88:	bff9                	j	80001e66 <growproc+0x50>
  else if(n < 0){
    80001e8a:	fc04d9e3          	bgez	s1,80001e5c <growproc+0x46>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e8e:	00f4863b          	addw	a2,s1,a5
    80001e92:	1602                	slli	a2,a2,0x20
    80001e94:	9201                	srli	a2,a2,0x20
    80001e96:	1582                	slli	a1,a1,0x20
    80001e98:	9181                	srli	a1,a1,0x20
    80001e9a:	6928                	ld	a0,80(a0)
    80001e9c:	fffff097          	auipc	ra,0xfffff
    80001ea0:	5c4080e7          	jalr	1476(ra) # 80001460 <uvmdealloc>
    80001ea4:	0005079b          	sext.w	a5,a0
    80001ea8:	bf55                	j	80001e5c <growproc+0x46>
      return -1;
    80001eaa:	557d                	li	a0,-1
    80001eac:	bf6d                	j	80001e66 <growproc+0x50>

0000000080001eae <fork>:
{
    80001eae:	7139                	addi	sp,sp,-64
    80001eb0:	fc06                	sd	ra,56(sp)
    80001eb2:	f822                	sd	s0,48(sp)
    80001eb4:	f426                	sd	s1,40(sp)
    80001eb6:	e456                	sd	s5,8(sp)
    80001eb8:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001eba:	00000097          	auipc	ra,0x0
    80001ebe:	bcc080e7          	jalr	-1076(ra) # 80001a86 <myproc>
    80001ec2:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0) // nuevo proceso
    80001ec4:	00000097          	auipc	ra,0x0
    80001ec8:	dce080e7          	jalr	-562(ra) # 80001c92 <allocproc>
    80001ecc:	12050463          	beqz	a0,80001ff4 <fork+0x146>
    80001ed0:	ec4e                	sd	s3,24(sp)
    80001ed2:	89aa                	mv	s3,a0
  np->mask = p->mask; // copiar mascara de syscalls
    80001ed4:	168aa783          	lw	a5,360(s5)
    80001ed8:	16f52423          	sw	a5,360(a0)
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001edc:	048ab603          	ld	a2,72(s5)
    80001ee0:	692c                	ld	a1,80(a0)
    80001ee2:	050ab503          	ld	a0,80(s5)
    80001ee6:	fffff097          	auipc	ra,0xfffff
    80001eea:	724080e7          	jalr	1828(ra) # 8000160a <uvmcopy>
    80001eee:	04054863          	bltz	a0,80001f3e <fork+0x90>
    80001ef2:	f04a                	sd	s2,32(sp)
    80001ef4:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001ef6:	048ab783          	ld	a5,72(s5)
    80001efa:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001efe:	058ab683          	ld	a3,88(s5)
    80001f02:	87b6                	mv	a5,a3
    80001f04:	0589b703          	ld	a4,88(s3)
    80001f08:	12068693          	addi	a3,a3,288
    80001f0c:	6388                	ld	a0,0(a5)
    80001f0e:	678c                	ld	a1,8(a5)
    80001f10:	6b90                	ld	a2,16(a5)
    80001f12:	e308                	sd	a0,0(a4)
    80001f14:	e70c                	sd	a1,8(a4)
    80001f16:	eb10                	sd	a2,16(a4)
    80001f18:	6f90                	ld	a2,24(a5)
    80001f1a:	ef10                	sd	a2,24(a4)
    80001f1c:	02078793          	addi	a5,a5,32 # 1020 <_entry-0x7fffefe0>
    80001f20:	02070713          	addi	a4,a4,32
    80001f24:	fed794e3          	bne	a5,a3,80001f0c <fork+0x5e>
  np->trapframe->a0 = 0;
    80001f28:	0589b783          	ld	a5,88(s3)
    80001f2c:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001f30:	0d0a8493          	addi	s1,s5,208
    80001f34:	0d098913          	addi	s2,s3,208
    80001f38:	150a8a13          	addi	s4,s5,336
    80001f3c:	a015                	j	80001f60 <fork+0xb2>
    freeproc(np);
    80001f3e:	854e                	mv	a0,s3
    80001f40:	00000097          	auipc	ra,0x0
    80001f44:	cfa080e7          	jalr	-774(ra) # 80001c3a <freeproc>
    release(&np->lock);
    80001f48:	854e                	mv	a0,s3
    80001f4a:	fffff097          	auipc	ra,0xfffff
    80001f4e:	dba080e7          	jalr	-582(ra) # 80000d04 <release>
    return -1;
    80001f52:	54fd                	li	s1,-1
    80001f54:	69e2                	ld	s3,24(sp)
    80001f56:	a841                	j	80001fe6 <fork+0x138>
  for(i = 0; i < NOFILE; i++)
    80001f58:	04a1                	addi	s1,s1,8
    80001f5a:	0921                	addi	s2,s2,8
    80001f5c:	01448b63          	beq	s1,s4,80001f72 <fork+0xc4>
    if(p->ofile[i])
    80001f60:	6088                	ld	a0,0(s1)
    80001f62:	d97d                	beqz	a0,80001f58 <fork+0xaa>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f64:	00003097          	auipc	ra,0x3
    80001f68:	b92080e7          	jalr	-1134(ra) # 80004af6 <filedup>
    80001f6c:	00a93023          	sd	a0,0(s2)
    80001f70:	b7e5                	j	80001f58 <fork+0xaa>
  np->cwd = idup(p->cwd);
    80001f72:	150ab503          	ld	a0,336(s5)
    80001f76:	00002097          	auipc	ra,0x2
    80001f7a:	cba080e7          	jalr	-838(ra) # 80003c30 <idup>
    80001f7e:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f82:	4641                	li	a2,16
    80001f84:	158a8593          	addi	a1,s5,344
    80001f88:	15898513          	addi	a0,s3,344
    80001f8c:	fffff097          	auipc	ra,0xfffff
    80001f90:	f18080e7          	jalr	-232(ra) # 80000ea4 <safestrcpy>
  pid = np->pid;
    80001f94:	0309a483          	lw	s1,48(s3)
  release(&np->lock);
    80001f98:	854e                	mv	a0,s3
    80001f9a:	fffff097          	auipc	ra,0xfffff
    80001f9e:	d6a080e7          	jalr	-662(ra) # 80000d04 <release>
  acquire(&wait_lock);
    80001fa2:	00012517          	auipc	a0,0x12
    80001fa6:	31650513          	addi	a0,a0,790 # 800142b8 <wait_lock>
    80001faa:	fffff097          	auipc	ra,0xfffff
    80001fae:	caa080e7          	jalr	-854(ra) # 80000c54 <acquire>
  np->parent = p; // asignar padre
    80001fb2:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001fb6:	00012517          	auipc	a0,0x12
    80001fba:	30250513          	addi	a0,a0,770 # 800142b8 <wait_lock>
    80001fbe:	fffff097          	auipc	ra,0xfffff
    80001fc2:	d46080e7          	jalr	-698(ra) # 80000d04 <release>
  acquire(&np->lock);
    80001fc6:	854e                	mv	a0,s3
    80001fc8:	fffff097          	auipc	ra,0xfffff
    80001fcc:	c8c080e7          	jalr	-884(ra) # 80000c54 <acquire>
  np->state = RUNNABLE; // listo para ejecutar
    80001fd0:	478d                	li	a5,3
    80001fd2:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001fd6:	854e                	mv	a0,s3
    80001fd8:	fffff097          	auipc	ra,0xfffff
    80001fdc:	d2c080e7          	jalr	-724(ra) # 80000d04 <release>
  return pid;
    80001fe0:	7902                	ld	s2,32(sp)
    80001fe2:	69e2                	ld	s3,24(sp)
    80001fe4:	6a42                	ld	s4,16(sp)
}
    80001fe6:	8526                	mv	a0,s1
    80001fe8:	70e2                	ld	ra,56(sp)
    80001fea:	7442                	ld	s0,48(sp)
    80001fec:	74a2                	ld	s1,40(sp)
    80001fee:	6aa2                	ld	s5,8(sp)
    80001ff0:	6121                	addi	sp,sp,64
    80001ff2:	8082                	ret
    return -1;
    80001ff4:	54fd                	li	s1,-1
    80001ff6:	bfc5                	j	80001fe6 <fork+0x138>

0000000080001ff8 <max>:
int max(int a, int b){
    80001ff8:	1141                	addi	sp,sp,-16
    80001ffa:	e406                	sd	ra,8(sp)
    80001ffc:	e022                	sd	s0,0(sp)
    80001ffe:	0800                	addi	s0,sp,16
  if(a > b) return a;
    80002000:	87aa                	mv	a5,a0
    80002002:	00b55363          	bge	a0,a1,80002008 <max+0x10>
    80002006:	87ae                	mv	a5,a1
}
    80002008:	0007851b          	sext.w	a0,a5
    8000200c:	60a2                	ld	ra,8(sp)
    8000200e:	6402                	ld	s0,0(sp)
    80002010:	0141                	addi	sp,sp,16
    80002012:	8082                	ret

0000000080002014 <min>:
int min(int a, int b){
    80002014:	1141                	addi	sp,sp,-16
    80002016:	e406                	sd	ra,8(sp)
    80002018:	e022                	sd	s0,0(sp)
    8000201a:	0800                	addi	s0,sp,16
  if(a < b) return a;
    8000201c:	87aa                	mv	a5,a0
    8000201e:	00a5d363          	bge	a1,a0,80002024 <min+0x10>
    80002022:	87ae                	mv	a5,a1
}
    80002024:	0007851b          	sext.w	a0,a5
    80002028:	60a2                	ld	ra,8(sp)
    8000202a:	6402                	ld	s0,0(sp)
    8000202c:	0141                	addi	sp,sp,16
    8000202e:	8082                	ret

0000000080002030 <scheduler>:
{
    80002030:	7119                	addi	sp,sp,-128
    80002032:	fc86                	sd	ra,120(sp)
    80002034:	f8a2                	sd	s0,112(sp)
    80002036:	f4a6                	sd	s1,104(sp)
    80002038:	f0ca                	sd	s2,96(sp)
    8000203a:	ecce                	sd	s3,88(sp)
    8000203c:	e8d2                	sd	s4,80(sp)
    8000203e:	e4d6                	sd	s5,72(sp)
    80002040:	e0da                	sd	s6,64(sp)
    80002042:	fc5e                	sd	s7,56(sp)
    80002044:	f862                	sd	s8,48(sp)
    80002046:	f466                	sd	s9,40(sp)
    80002048:	f06a                	sd	s10,32(sp)
    8000204a:	ec6e                	sd	s11,24(sp)
    8000204c:	0100                	addi	s0,sp,128
    8000204e:	8d92                	mv	s11,tp
  int id = r_tp(); // tp contiene el hartid
    80002050:	2d81                	sext.w	s11,s11
    c->proc = 0;
    80002052:	007d9713          	slli	a4,s11,0x7
    80002056:	00012797          	auipc	a5,0x12
    8000205a:	24a78793          	addi	a5,a5,586 # 800142a0 <pid_lock>
    8000205e:	97ba                	add	a5,a5,a4
    80002060:	0207b823          	sd	zero,48(a5)
            swtch(&c->context, &best->context);
    80002064:	00012797          	auipc	a5,0x12
    80002068:	27478793          	addi	a5,a5,628 # 800142d8 <cpus+0x8>
    8000206c:	97ba                	add	a5,a5,a4
    8000206e:	f8f43423          	sd	a5,-120(s0)
        for(p = proc; p < &proc[NPROC]; p++){
    80002072:	0001ab17          	auipc	s6,0x1a
    80002076:	85eb0b13          	addi	s6,s6,-1954 # 8001b8d0 <tickslock>
                nice = 5;  // valor por defecto
    8000207a:	4c15                	li	s8,5
            if(dp > 100) dp = 100;
    8000207c:	06400b93          	li	s7,100
    80002080:	06400c93          	li	s9,100
    80002084:	a231                	j	80002190 <scheduler+0x160>
                release(&p->lock);
    80002086:	8526                	mv	a0,s1
    80002088:	fffff097          	auipc	ra,0xfffff
    8000208c:	c7c080e7          	jalr	-900(ra) # 80000d04 <release>
                continue;
    80002090:	a811                	j	800020a4 <scheduler+0x74>
            if(dp < 0) dp = 0;
    80002092:	4901                	li	s2,0
    80002094:	a8b1                	j	800020f0 <scheduler+0xc0>
            else if(dp == best_dp && best &&
    80002096:	08f70763          	beq	a4,a5,80002124 <scheduler+0xf4>
            release(&p->lock);
    8000209a:	8526                	mv	a0,s1
    8000209c:	fffff097          	auipc	ra,0xfffff
    800020a0:	c68080e7          	jalr	-920(ra) # 80000d04 <release>
        for(p = proc; p < &proc[NPROC]; p++){
    800020a4:	1c848493          	addi	s1,s1,456
    800020a8:	09648863          	beq	s1,s6,80002138 <scheduler+0x108>
            acquire(&p->lock);
    800020ac:	8526                	mv	a0,s1
    800020ae:	fffff097          	auipc	ra,0xfffff
    800020b2:	ba6080e7          	jalr	-1114(ra) # 80000c54 <acquire>
            if(p->state != RUNNABLE){
    800020b6:	4c9c                	lw	a5,24(s1)
    800020b8:	fd5797e3          	bne	a5,s5,80002086 <scheduler+0x56>
            if(p->run_time + p->sleep_time > 0)
    800020bc:	1984b683          	ld	a3,408(s1)
    800020c0:	1784b783          	ld	a5,376(s1)
    800020c4:	97b6                	add	a5,a5,a3
                nice = 5;  // valor por defecto
    800020c6:	8762                	mv	a4,s8
            if(p->run_time + p->sleep_time > 0)
    800020c8:	cb81                	beqz	a5,800020d8 <scheduler+0xa8>
                nice = (p->sleep_time * 10) / (p->run_time + p->sleep_time);
    800020ca:	00269713          	slli	a4,a3,0x2
    800020ce:	9736                	add	a4,a4,a3
    800020d0:	0706                	slli	a4,a4,0x1
    800020d2:	02f75733          	divu	a4,a4,a5
    800020d6:	2701                	sext.w	a4,a4
            int dp = p->priority - nice + 5;
    800020d8:	1b04b783          	ld	a5,432(s1)
    800020dc:	2795                	addiw	a5,a5,5
    800020de:	9f99                	subw	a5,a5,a4
    800020e0:	893e                	mv	s2,a5
            if(dp > 100) dp = 100;
    800020e2:	00fbd363          	bge	s7,a5,800020e8 <scheduler+0xb8>
    800020e6:	8966                	mv	s2,s9
            if(dp < 0) dp = 0;
    800020e8:	02091793          	slli	a5,s2,0x20
    800020ec:	fa07c3e3          	bltz	a5,80002092 <scheduler+0x62>
    800020f0:	2901                	sext.w	s2,s2
            if(dp < best_dp) {
    800020f2:	05394063          	blt	s2,s3,80002132 <scheduler+0x102>
            else if(dp == best_dp && best && p->n_runs < best->n_runs) {
    800020f6:	fb3912e3          	bne	s2,s3,8000209a <scheduler+0x6a>
    800020fa:	fa0a00e3          	beqz	s4,8000209a <scheduler+0x6a>
    800020fe:	1a84b703          	ld	a4,424(s1)
    80002102:	1a8a3783          	ld	a5,424(s4)
    80002106:	f8f778e3          	bgeu	a4,a5,80002096 <scheduler+0x66>
                    release(&best->lock); // soltar lock anterior
    8000210a:	8552                	mv	a0,s4
    8000210c:	fffff097          	auipc	ra,0xfffff
    80002110:	bf8080e7          	jalr	-1032(ra) # 80000d04 <release>
        for(p = proc; p < &proc[NPROC]; p++){
    80002114:	1c848793          	addi	a5,s1,456
    80002118:	03678363          	beq	a5,s6,8000213e <scheduler+0x10e>
    8000211c:	89ca                	mv	s3,s2
    8000211e:	8a26                	mv	s4,s1
    80002120:	84be                	mv	s1,a5
    80002122:	b769                	j	800020ac <scheduler+0x7c>
                    p->n_runs == best->n_runs &&
    80002124:	1704b703          	ld	a4,368(s1)
    80002128:	170a3783          	ld	a5,368(s4)
    8000212c:	f6f777e3          	bgeu	a4,a5,8000209a <scheduler+0x6a>
    80002130:	bfe9                	j	8000210a <scheduler+0xda>
                if(best != 0)
    80002132:	fe0a01e3          	beqz	s4,80002114 <scheduler+0xe4>
    80002136:	bfd1                	j	8000210a <scheduler+0xda>
        if(best != 0){
    80002138:	060a0063          	beqz	s4,80002198 <scheduler+0x168>
    8000213c:	84d2                	mv	s1,s4
            best->state = RUNNING;
    8000213e:	4791                	li	a5,4
    80002140:	cc9c                	sw	a5,24(s1)
            best->start_time = ticks;
    80002142:	0000a797          	auipc	a5,0xa
    80002146:	eee7e783          	lwu	a5,-274(a5) # 8000c030 <ticks>
    8000214a:	18f4b823          	sd	a5,400(s1)
            best->run_time = 0;       // reset para nice
    8000214e:	1604bc23          	sd	zero,376(s1)
            best->sleep_time = 0;     // reset para nice
    80002152:	1804bc23          	sd	zero,408(s1)
            best->n_runs++;
    80002156:	1a84b783          	ld	a5,424(s1)
    8000215a:	0785                	addi	a5,a5,1
    8000215c:	1af4b423          	sd	a5,424(s1)
            c->proc = best;
    80002160:	007d9793          	slli	a5,s11,0x7
    80002164:	00012917          	auipc	s2,0x12
    80002168:	13c90913          	addi	s2,s2,316 # 800142a0 <pid_lock>
    8000216c:	993e                	add	s2,s2,a5
    8000216e:	02993823          	sd	s1,48(s2)
            swtch(&c->context, &best->context);
    80002172:	06048593          	addi	a1,s1,96
    80002176:	f8843503          	ld	a0,-120(s0)
    8000217a:	00001097          	auipc	ra,0x1
    8000217e:	850080e7          	jalr	-1968(ra) # 800029ca <swtch>
            c->proc = 0;
    80002182:	02093823          	sd	zero,48(s2)
            release(&best->lock);
    80002186:	8526                	mv	a0,s1
    80002188:	fffff097          	auipc	ra,0xfffff
    8000218c:	b7c080e7          	jalr	-1156(ra) # 80000d04 <release>
        int best_dp = 999999;   // prioridad dinamica minima (mejor proceso)
    80002190:	000f4d37          	lui	s10,0xf4
    80002194:	23fd0d13          	addi	s10,s10,575 # f423f <_entry-0x7ff0bdc1>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002198:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000219c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800021a0:	10079073          	csrw	sstatus,a5
    800021a4:	89ea                	mv	s3,s10
        struct proc *best = 0;
    800021a6:	4a01                	li	s4,0
        for(p = proc; p < &proc[NPROC]; p++){
    800021a8:	00012497          	auipc	s1,0x12
    800021ac:	52848493          	addi	s1,s1,1320 # 800146d0 <proc>
            if(p->state != RUNNABLE){
    800021b0:	4a8d                	li	s5,3
    800021b2:	bded                	j	800020ac <scheduler+0x7c>

00000000800021b4 <sched>:
{
    800021b4:	7179                	addi	sp,sp,-48
    800021b6:	f406                	sd	ra,40(sp)
    800021b8:	f022                	sd	s0,32(sp)
    800021ba:	ec26                	sd	s1,24(sp)
    800021bc:	e84a                	sd	s2,16(sp)
    800021be:	e44e                	sd	s3,8(sp)
    800021c0:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800021c2:	00000097          	auipc	ra,0x0
    800021c6:	8c4080e7          	jalr	-1852(ra) # 80001a86 <myproc>
    800021ca:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800021cc:	fffff097          	auipc	ra,0xfffff
    800021d0:	a08080e7          	jalr	-1528(ra) # 80000bd4 <holding>
    800021d4:	cd25                	beqz	a0,8000224c <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    800021d6:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800021d8:	2781                	sext.w	a5,a5
    800021da:	079e                	slli	a5,a5,0x7
    800021dc:	00012717          	auipc	a4,0x12
    800021e0:	0c470713          	addi	a4,a4,196 # 800142a0 <pid_lock>
    800021e4:	97ba                	add	a5,a5,a4
    800021e6:	0a87a703          	lw	a4,168(a5)
    800021ea:	4785                	li	a5,1
    800021ec:	06f71863          	bne	a4,a5,8000225c <sched+0xa8>
  if(p->state == RUNNING)
    800021f0:	4c98                	lw	a4,24(s1)
    800021f2:	4791                	li	a5,4
    800021f4:	06f70c63          	beq	a4,a5,8000226c <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800021f8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800021fc:	8b89                	andi	a5,a5,2
  if(intr_get())
    800021fe:	efbd                	bnez	a5,8000227c <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002200:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002202:	00012917          	auipc	s2,0x12
    80002206:	09e90913          	addi	s2,s2,158 # 800142a0 <pid_lock>
    8000220a:	2781                	sext.w	a5,a5
    8000220c:	079e                	slli	a5,a5,0x7
    8000220e:	97ca                	add	a5,a5,s2
    80002210:	0ac7a983          	lw	s3,172(a5)
    80002214:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002216:	2781                	sext.w	a5,a5
    80002218:	079e                	slli	a5,a5,0x7
    8000221a:	07a1                	addi	a5,a5,8
    8000221c:	00012597          	auipc	a1,0x12
    80002220:	0b458593          	addi	a1,a1,180 # 800142d0 <cpus>
    80002224:	95be                	add	a1,a1,a5
    80002226:	06048513          	addi	a0,s1,96
    8000222a:	00000097          	auipc	ra,0x0
    8000222e:	7a0080e7          	jalr	1952(ra) # 800029ca <swtch>
    80002232:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002234:	2781                	sext.w	a5,a5
    80002236:	079e                	slli	a5,a5,0x7
    80002238:	993e                	add	s2,s2,a5
    8000223a:	0b392623          	sw	s3,172(s2)
}
    8000223e:	70a2                	ld	ra,40(sp)
    80002240:	7402                	ld	s0,32(sp)
    80002242:	64e2                	ld	s1,24(sp)
    80002244:	6942                	ld	s2,16(sp)
    80002246:	69a2                	ld	s3,8(sp)
    80002248:	6145                	addi	sp,sp,48
    8000224a:	8082                	ret
    panic("sched p->lock");
    8000224c:	00006517          	auipc	a0,0x6
    80002250:	fe450513          	addi	a0,a0,-28 # 80008230 <etext+0x230>
    80002254:	ffffe097          	auipc	ra,0xffffe
    80002258:	302080e7          	jalr	770(ra) # 80000556 <panic>
    panic("sched locks");
    8000225c:	00006517          	auipc	a0,0x6
    80002260:	fe450513          	addi	a0,a0,-28 # 80008240 <etext+0x240>
    80002264:	ffffe097          	auipc	ra,0xffffe
    80002268:	2f2080e7          	jalr	754(ra) # 80000556 <panic>
    panic("sched running");
    8000226c:	00006517          	auipc	a0,0x6
    80002270:	fe450513          	addi	a0,a0,-28 # 80008250 <etext+0x250>
    80002274:	ffffe097          	auipc	ra,0xffffe
    80002278:	2e2080e7          	jalr	738(ra) # 80000556 <panic>
    panic("sched interruptible");
    8000227c:	00006517          	auipc	a0,0x6
    80002280:	fe450513          	addi	a0,a0,-28 # 80008260 <etext+0x260>
    80002284:	ffffe097          	auipc	ra,0xffffe
    80002288:	2d2080e7          	jalr	722(ra) # 80000556 <panic>

000000008000228c <yield>:
{
    8000228c:	1101                	addi	sp,sp,-32
    8000228e:	ec06                	sd	ra,24(sp)
    80002290:	e822                	sd	s0,16(sp)
    80002292:	e426                	sd	s1,8(sp)
    80002294:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002296:	fffff097          	auipc	ra,0xfffff
    8000229a:	7f0080e7          	jalr	2032(ra) # 80001a86 <myproc>
    8000229e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022a0:	fffff097          	auipc	ra,0xfffff
    800022a4:	9b4080e7          	jalr	-1612(ra) # 80000c54 <acquire>
  p->state = RUNNABLE;
    800022a8:	478d                	li	a5,3
    800022aa:	cc9c                	sw	a5,24(s1)
  sched();
    800022ac:	00000097          	auipc	ra,0x0
    800022b0:	f08080e7          	jalr	-248(ra) # 800021b4 <sched>
  release(&p->lock);
    800022b4:	8526                	mv	a0,s1
    800022b6:	fffff097          	auipc	ra,0xfffff
    800022ba:	a4e080e7          	jalr	-1458(ra) # 80000d04 <release>
}
    800022be:	60e2                	ld	ra,24(sp)
    800022c0:	6442                	ld	s0,16(sp)
    800022c2:	64a2                	ld	s1,8(sp)
    800022c4:	6105                	addi	sp,sp,32
    800022c6:	8082                	ret

00000000800022c8 <sleep>:

// Pone un proceso a dormir
void
sleep(void *chan, struct spinlock *lk)
{
    800022c8:	7179                	addi	sp,sp,-48
    800022ca:	f406                	sd	ra,40(sp)
    800022cc:	f022                	sd	s0,32(sp)
    800022ce:	ec26                	sd	s1,24(sp)
    800022d0:	e84a                	sd	s2,16(sp)
    800022d2:	e44e                	sd	s3,8(sp)
    800022d4:	1800                	addi	s0,sp,48
    800022d6:	89aa                	mv	s3,a0
    800022d8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800022da:	fffff097          	auipc	ra,0xfffff
    800022de:	7ac080e7          	jalr	1964(ra) # 80001a86 <myproc>
    800022e2:	84aa                	mv	s1,a0
  
  acquire(&p->lock);
    800022e4:	fffff097          	auipc	ra,0xfffff
    800022e8:	970080e7          	jalr	-1680(ra) # 80000c54 <acquire>
  release(lk);
    800022ec:	854a                	mv	a0,s2
    800022ee:	fffff097          	auipc	ra,0xfffff
    800022f2:	a16080e7          	jalr	-1514(ra) # 80000d04 <release>

  p->chan = chan;
    800022f6:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800022fa:	4789                	li	a5,2
    800022fc:	cc9c                	sw	a5,24(s1)

  sched();
    800022fe:	00000097          	auipc	ra,0x0
    80002302:	eb6080e7          	jalr	-330(ra) # 800021b4 <sched>

  p->chan = 0;
    80002306:	0204b023          	sd	zero,32(s1)

  release(&p->lock);
    8000230a:	8526                	mv	a0,s1
    8000230c:	fffff097          	auipc	ra,0xfffff
    80002310:	9f8080e7          	jalr	-1544(ra) # 80000d04 <release>
  acquire(lk);
    80002314:	854a                	mv	a0,s2
    80002316:	fffff097          	auipc	ra,0xfffff
    8000231a:	93e080e7          	jalr	-1730(ra) # 80000c54 <acquire>
}
    8000231e:	70a2                	ld	ra,40(sp)
    80002320:	7402                	ld	s0,32(sp)
    80002322:	64e2                	ld	s1,24(sp)
    80002324:	6942                	ld	s2,16(sp)
    80002326:	69a2                	ld	s3,8(sp)
    80002328:	6145                	addi	sp,sp,48
    8000232a:	8082                	ret

000000008000232c <wait>:
{
    8000232c:	715d                	addi	sp,sp,-80
    8000232e:	e486                	sd	ra,72(sp)
    80002330:	e0a2                	sd	s0,64(sp)
    80002332:	fc26                	sd	s1,56(sp)
    80002334:	f84a                	sd	s2,48(sp)
    80002336:	f44e                	sd	s3,40(sp)
    80002338:	f052                	sd	s4,32(sp)
    8000233a:	ec56                	sd	s5,24(sp)
    8000233c:	e85a                	sd	s6,16(sp)
    8000233e:	e45e                	sd	s7,8(sp)
    80002340:	0880                	addi	s0,sp,80
    80002342:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002344:	fffff097          	auipc	ra,0xfffff
    80002348:	742080e7          	jalr	1858(ra) # 80001a86 <myproc>
    8000234c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000234e:	00012517          	auipc	a0,0x12
    80002352:	f6a50513          	addi	a0,a0,-150 # 800142b8 <wait_lock>
    80002356:	fffff097          	auipc	ra,0xfffff
    8000235a:	8fe080e7          	jalr	-1794(ra) # 80000c54 <acquire>
        if(np->state == ZOMBIE){
    8000235e:	4a15                	li	s4,5
        havekids = 1;
    80002360:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002362:	00019997          	auipc	s3,0x19
    80002366:	56e98993          	addi	s3,s3,1390 # 8001b8d0 <tickslock>
    sleep(p, &wait_lock);
    8000236a:	00012b17          	auipc	s6,0x12
    8000236e:	f4eb0b13          	addi	s6,s6,-178 # 800142b8 <wait_lock>
    80002372:	a875                	j	8000242e <wait+0x102>
          pid = np->pid;
    80002374:	0304a983          	lw	s3,48(s1)
          if(addr != 0 &&
    80002378:	000b8e63          	beqz	s7,80002394 <wait+0x68>
             copyout(p->pagetable, addr,
    8000237c:	4691                	li	a3,4
    8000237e:	02c48613          	addi	a2,s1,44
    80002382:	85de                	mv	a1,s7
    80002384:	05093503          	ld	a0,80(s2)
    80002388:	fffff097          	auipc	ra,0xfffff
    8000238c:	382080e7          	jalr	898(ra) # 8000170a <copyout>
          if(addr != 0 &&
    80002390:	04054063          	bltz	a0,800023d0 <wait+0xa4>
          freeproc(np); // liberar proceso
    80002394:	8526                	mv	a0,s1
    80002396:	00000097          	auipc	ra,0x0
    8000239a:	8a4080e7          	jalr	-1884(ra) # 80001c3a <freeproc>
          release(&np->lock);
    8000239e:	8526                	mv	a0,s1
    800023a0:	fffff097          	auipc	ra,0xfffff
    800023a4:	964080e7          	jalr	-1692(ra) # 80000d04 <release>
          release(&wait_lock);
    800023a8:	00012517          	auipc	a0,0x12
    800023ac:	f1050513          	addi	a0,a0,-240 # 800142b8 <wait_lock>
    800023b0:	fffff097          	auipc	ra,0xfffff
    800023b4:	954080e7          	jalr	-1708(ra) # 80000d04 <release>
}
    800023b8:	854e                	mv	a0,s3
    800023ba:	60a6                	ld	ra,72(sp)
    800023bc:	6406                	ld	s0,64(sp)
    800023be:	74e2                	ld	s1,56(sp)
    800023c0:	7942                	ld	s2,48(sp)
    800023c2:	79a2                	ld	s3,40(sp)
    800023c4:	7a02                	ld	s4,32(sp)
    800023c6:	6ae2                	ld	s5,24(sp)
    800023c8:	6b42                	ld	s6,16(sp)
    800023ca:	6ba2                	ld	s7,8(sp)
    800023cc:	6161                	addi	sp,sp,80
    800023ce:	8082                	ret
            release(&np->lock);
    800023d0:	8526                	mv	a0,s1
    800023d2:	fffff097          	auipc	ra,0xfffff
    800023d6:	932080e7          	jalr	-1742(ra) # 80000d04 <release>
            release(&wait_lock);
    800023da:	00012517          	auipc	a0,0x12
    800023de:	ede50513          	addi	a0,a0,-290 # 800142b8 <wait_lock>
    800023e2:	fffff097          	auipc	ra,0xfffff
    800023e6:	922080e7          	jalr	-1758(ra) # 80000d04 <release>
            return -1;
    800023ea:	59fd                	li	s3,-1
    800023ec:	b7f1                	j	800023b8 <wait+0x8c>
    for(np = proc; np < &proc[NPROC]; np++){
    800023ee:	1c848493          	addi	s1,s1,456
    800023f2:	03348463          	beq	s1,s3,8000241a <wait+0xee>
      if(np->parent == p){
    800023f6:	7c9c                	ld	a5,56(s1)
    800023f8:	ff279be3          	bne	a5,s2,800023ee <wait+0xc2>
        acquire(&np->lock);
    800023fc:	8526                	mv	a0,s1
    800023fe:	fffff097          	auipc	ra,0xfffff
    80002402:	856080e7          	jalr	-1962(ra) # 80000c54 <acquire>
        if(np->state == ZOMBIE){
    80002406:	4c9c                	lw	a5,24(s1)
    80002408:	f74786e3          	beq	a5,s4,80002374 <wait+0x48>
        release(&np->lock);
    8000240c:	8526                	mv	a0,s1
    8000240e:	fffff097          	auipc	ra,0xfffff
    80002412:	8f6080e7          	jalr	-1802(ra) # 80000d04 <release>
        havekids = 1;
    80002416:	8756                	mv	a4,s5
    80002418:	bfd9                	j	800023ee <wait+0xc2>
    if(!havekids || p->killed){
    8000241a:	c305                	beqz	a4,8000243a <wait+0x10e>
    8000241c:	02892783          	lw	a5,40(s2)
    80002420:	ef89                	bnez	a5,8000243a <wait+0x10e>
    sleep(p, &wait_lock);
    80002422:	85da                	mv	a1,s6
    80002424:	854a                	mv	a0,s2
    80002426:	00000097          	auipc	ra,0x0
    8000242a:	ea2080e7          	jalr	-350(ra) # 800022c8 <sleep>
    havekids = 0;
    8000242e:	4701                	li	a4,0
    for(np = proc; np < &proc[NPROC]; np++){
    80002430:	00012497          	auipc	s1,0x12
    80002434:	2a048493          	addi	s1,s1,672 # 800146d0 <proc>
    80002438:	bf7d                	j	800023f6 <wait+0xca>
      release(&wait_lock);
    8000243a:	00012517          	auipc	a0,0x12
    8000243e:	e7e50513          	addi	a0,a0,-386 # 800142b8 <wait_lock>
    80002442:	fffff097          	auipc	ra,0xfffff
    80002446:	8c2080e7          	jalr	-1854(ra) # 80000d04 <release>
      return -1;
    8000244a:	59fd                	li	s3,-1
    8000244c:	b7b5                	j	800023b8 <wait+0x8c>

000000008000244e <wakeup>:

// Despertar procesos dormidos
void
wakeup(void *chan)
{
    8000244e:	7139                	addi	sp,sp,-64
    80002450:	fc06                	sd	ra,56(sp)
    80002452:	f822                	sd	s0,48(sp)
    80002454:	f426                	sd	s1,40(sp)
    80002456:	f04a                	sd	s2,32(sp)
    80002458:	ec4e                	sd	s3,24(sp)
    8000245a:	e852                	sd	s4,16(sp)
    8000245c:	e456                	sd	s5,8(sp)
    8000245e:	0080                	addi	s0,sp,64
    80002460:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002462:	00012497          	auipc	s1,0x12
    80002466:	26e48493          	addi	s1,s1,622 # 800146d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);

      if(p->state == SLEEPING && p->chan == chan)
    8000246a:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000246c:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000246e:	00019917          	auipc	s2,0x19
    80002472:	46290913          	addi	s2,s2,1122 # 8001b8d0 <tickslock>
    80002476:	a811                	j	8000248a <wakeup+0x3c>

      release(&p->lock);
    80002478:	8526                	mv	a0,s1
    8000247a:	fffff097          	auipc	ra,0xfffff
    8000247e:	88a080e7          	jalr	-1910(ra) # 80000d04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002482:	1c848493          	addi	s1,s1,456
    80002486:	03248663          	beq	s1,s2,800024b2 <wakeup+0x64>
    if(p != myproc()){
    8000248a:	fffff097          	auipc	ra,0xfffff
    8000248e:	5fc080e7          	jalr	1532(ra) # 80001a86 <myproc>
    80002492:	fe9508e3          	beq	a0,s1,80002482 <wakeup+0x34>
      acquire(&p->lock);
    80002496:	8526                	mv	a0,s1
    80002498:	ffffe097          	auipc	ra,0xffffe
    8000249c:	7bc080e7          	jalr	1980(ra) # 80000c54 <acquire>
      if(p->state == SLEEPING && p->chan == chan)
    800024a0:	4c9c                	lw	a5,24(s1)
    800024a2:	fd379be3          	bne	a5,s3,80002478 <wakeup+0x2a>
    800024a6:	709c                	ld	a5,32(s1)
    800024a8:	fd4798e3          	bne	a5,s4,80002478 <wakeup+0x2a>
        p->state = RUNNABLE;
    800024ac:	0154ac23          	sw	s5,24(s1)
    800024b0:	b7e1                	j	80002478 <wakeup+0x2a>
    }
  }
}
    800024b2:	70e2                	ld	ra,56(sp)
    800024b4:	7442                	ld	s0,48(sp)
    800024b6:	74a2                	ld	s1,40(sp)
    800024b8:	7902                	ld	s2,32(sp)
    800024ba:	69e2                	ld	s3,24(sp)
    800024bc:	6a42                	ld	s4,16(sp)
    800024be:	6aa2                	ld	s5,8(sp)
    800024c0:	6121                	addi	sp,sp,64
    800024c2:	8082                	ret

00000000800024c4 <reparent>:
{
    800024c4:	7179                	addi	sp,sp,-48
    800024c6:	f406                	sd	ra,40(sp)
    800024c8:	f022                	sd	s0,32(sp)
    800024ca:	ec26                	sd	s1,24(sp)
    800024cc:	e84a                	sd	s2,16(sp)
    800024ce:	e44e                	sd	s3,8(sp)
    800024d0:	e052                	sd	s4,0(sp)
    800024d2:	1800                	addi	s0,sp,48
    800024d4:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800024d6:	00012497          	auipc	s1,0x12
    800024da:	1fa48493          	addi	s1,s1,506 # 800146d0 <proc>
      pp->parent = initproc;
    800024de:	0000aa17          	auipc	s4,0xa
    800024e2:	b4aa0a13          	addi	s4,s4,-1206 # 8000c028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800024e6:	00019997          	auipc	s3,0x19
    800024ea:	3ea98993          	addi	s3,s3,1002 # 8001b8d0 <tickslock>
    800024ee:	a029                	j	800024f8 <reparent+0x34>
    800024f0:	1c848493          	addi	s1,s1,456
    800024f4:	01348d63          	beq	s1,s3,8000250e <reparent+0x4a>
    if(pp->parent == p){
    800024f8:	7c9c                	ld	a5,56(s1)
    800024fa:	ff279be3          	bne	a5,s2,800024f0 <reparent+0x2c>
      pp->parent = initproc;
    800024fe:	000a3503          	ld	a0,0(s4)
    80002502:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002504:	00000097          	auipc	ra,0x0
    80002508:	f4a080e7          	jalr	-182(ra) # 8000244e <wakeup>
    8000250c:	b7d5                	j	800024f0 <reparent+0x2c>
}
    8000250e:	70a2                	ld	ra,40(sp)
    80002510:	7402                	ld	s0,32(sp)
    80002512:	64e2                	ld	s1,24(sp)
    80002514:	6942                	ld	s2,16(sp)
    80002516:	69a2                	ld	s3,8(sp)
    80002518:	6a02                	ld	s4,0(sp)
    8000251a:	6145                	addi	sp,sp,48
    8000251c:	8082                	ret

000000008000251e <exit>:
{
    8000251e:	7179                	addi	sp,sp,-48
    80002520:	f406                	sd	ra,40(sp)
    80002522:	f022                	sd	s0,32(sp)
    80002524:	ec26                	sd	s1,24(sp)
    80002526:	e84a                	sd	s2,16(sp)
    80002528:	e44e                	sd	s3,8(sp)
    8000252a:	e052                	sd	s4,0(sp)
    8000252c:	1800                	addi	s0,sp,48
    8000252e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002530:	fffff097          	auipc	ra,0xfffff
    80002534:	556080e7          	jalr	1366(ra) # 80001a86 <myproc>
    80002538:	89aa                	mv	s3,a0
  if(p == initproc)
    8000253a:	0000a797          	auipc	a5,0xa
    8000253e:	aee7b783          	ld	a5,-1298(a5) # 8000c028 <initproc>
    80002542:	0d050493          	addi	s1,a0,208
    80002546:	15050913          	addi	s2,a0,336
    8000254a:	00a79d63          	bne	a5,a0,80002564 <exit+0x46>
    panic("init exiting");
    8000254e:	00006517          	auipc	a0,0x6
    80002552:	d2a50513          	addi	a0,a0,-726 # 80008278 <etext+0x278>
    80002556:	ffffe097          	auipc	ra,0xffffe
    8000255a:	000080e7          	jalr	ra # 80000556 <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    8000255e:	04a1                	addi	s1,s1,8
    80002560:	01248b63          	beq	s1,s2,80002576 <exit+0x58>
    if(p->ofile[fd]){
    80002564:	6088                	ld	a0,0(s1)
    80002566:	dd65                	beqz	a0,8000255e <exit+0x40>
      fileclose(f);
    80002568:	00002097          	auipc	ra,0x2
    8000256c:	5e0080e7          	jalr	1504(ra) # 80004b48 <fileclose>
      p->ofile[fd] = 0;
    80002570:	0004b023          	sd	zero,0(s1)
    80002574:	b7ed                	j	8000255e <exit+0x40>
  begin_op();
    80002576:	00002097          	auipc	ra,0x2
    8000257a:	0f0080e7          	jalr	240(ra) # 80004666 <begin_op>
  iput(p->cwd);
    8000257e:	1509b503          	ld	a0,336(s3)
    80002582:	00002097          	auipc	ra,0x2
    80002586:	8aa080e7          	jalr	-1878(ra) # 80003e2c <iput>
  end_op();
    8000258a:	00002097          	auipc	ra,0x2
    8000258e:	15c080e7          	jalr	348(ra) # 800046e6 <end_op>
  p->cwd = 0;
    80002592:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002596:	00012517          	auipc	a0,0x12
    8000259a:	d2250513          	addi	a0,a0,-734 # 800142b8 <wait_lock>
    8000259e:	ffffe097          	auipc	ra,0xffffe
    800025a2:	6b6080e7          	jalr	1718(ra) # 80000c54 <acquire>
  reparent(p);
    800025a6:	854e                	mv	a0,s3
    800025a8:	00000097          	auipc	ra,0x0
    800025ac:	f1c080e7          	jalr	-228(ra) # 800024c4 <reparent>
  wakeup(p->parent);
    800025b0:	0389b503          	ld	a0,56(s3)
    800025b4:	00000097          	auipc	ra,0x0
    800025b8:	e9a080e7          	jalr	-358(ra) # 8000244e <wakeup>
  acquire(&p->lock);
    800025bc:	854e                	mv	a0,s3
    800025be:	ffffe097          	auipc	ra,0xffffe
    800025c2:	696080e7          	jalr	1686(ra) # 80000c54 <acquire>
  p->xstate = status;  // codigo de salida
    800025c6:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;   // proceso muerto
    800025ca:	4795                	li	a5,5
    800025cc:	00f9ac23          	sw	a5,24(s3)
  p->exit_time = ticks;// registrar tiempo de salida
    800025d0:	0000a797          	auipc	a5,0xa
    800025d4:	a607e783          	lwu	a5,-1440(a5) # 8000c030 <ticks>
    800025d8:	1af9b023          	sd	a5,416(s3)
  release(&wait_lock);
    800025dc:	00012517          	auipc	a0,0x12
    800025e0:	cdc50513          	addi	a0,a0,-804 # 800142b8 <wait_lock>
    800025e4:	ffffe097          	auipc	ra,0xffffe
    800025e8:	720080e7          	jalr	1824(ra) # 80000d04 <release>
  sched(); // ceder CPU
    800025ec:	00000097          	auipc	ra,0x0
    800025f0:	bc8080e7          	jalr	-1080(ra) # 800021b4 <sched>
  panic("zombie exit");
    800025f4:	00006517          	auipc	a0,0x6
    800025f8:	c9450513          	addi	a0,a0,-876 # 80008288 <etext+0x288>
    800025fc:	ffffe097          	auipc	ra,0xffffe
    80002600:	f5a080e7          	jalr	-166(ra) # 80000556 <panic>

0000000080002604 <kill>:

// Mata un proceso por pid
int
kill(int pid)
{
    80002604:	7179                	addi	sp,sp,-48
    80002606:	f406                	sd	ra,40(sp)
    80002608:	f022                	sd	s0,32(sp)
    8000260a:	ec26                	sd	s1,24(sp)
    8000260c:	e84a                	sd	s2,16(sp)
    8000260e:	e44e                	sd	s3,8(sp)
    80002610:	1800                	addi	s0,sp,48
    80002612:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002614:	00012497          	auipc	s1,0x12
    80002618:	0bc48493          	addi	s1,s1,188 # 800146d0 <proc>
    8000261c:	00019997          	auipc	s3,0x19
    80002620:	2b498993          	addi	s3,s3,692 # 8001b8d0 <tickslock>
    acquire(&p->lock);
    80002624:	8526                	mv	a0,s1
    80002626:	ffffe097          	auipc	ra,0xffffe
    8000262a:	62e080e7          	jalr	1582(ra) # 80000c54 <acquire>

    if(p->pid == pid){
    8000262e:	589c                	lw	a5,48(s1)
    80002630:	01278d63          	beq	a5,s2,8000264a <kill+0x46>

      release(&p->lock);
      return 0;
    }

    release(&p->lock);
    80002634:	8526                	mv	a0,s1
    80002636:	ffffe097          	auipc	ra,0xffffe
    8000263a:	6ce080e7          	jalr	1742(ra) # 80000d04 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000263e:	1c848493          	addi	s1,s1,456
    80002642:	ff3491e3          	bne	s1,s3,80002624 <kill+0x20>
  }

  return -1;
    80002646:	557d                	li	a0,-1
    80002648:	a829                	j	80002662 <kill+0x5e>
      p->killed = 1;
    8000264a:	4785                	li	a5,1
    8000264c:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING)
    8000264e:	4c98                	lw	a4,24(s1)
    80002650:	4789                	li	a5,2
    80002652:	00f70f63          	beq	a4,a5,80002670 <kill+0x6c>
      release(&p->lock);
    80002656:	8526                	mv	a0,s1
    80002658:	ffffe097          	auipc	ra,0xffffe
    8000265c:	6ac080e7          	jalr	1708(ra) # 80000d04 <release>
      return 0;
    80002660:	4501                	li	a0,0
}
    80002662:	70a2                	ld	ra,40(sp)
    80002664:	7402                	ld	s0,32(sp)
    80002666:	64e2                	ld	s1,24(sp)
    80002668:	6942                	ld	s2,16(sp)
    8000266a:	69a2                	ld	s3,8(sp)
    8000266c:	6145                	addi	sp,sp,48
    8000266e:	8082                	ret
        p->state = RUNNABLE;
    80002670:	478d                	li	a5,3
    80002672:	cc9c                	sw	a5,24(s1)
    80002674:	b7cd                	j	80002656 <kill+0x52>

0000000080002676 <either_copyout>:

// Copia datos a espacio de usuario o kernel
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002676:	7179                	addi	sp,sp,-48
    80002678:	f406                	sd	ra,40(sp)
    8000267a:	f022                	sd	s0,32(sp)
    8000267c:	ec26                	sd	s1,24(sp)
    8000267e:	e84a                	sd	s2,16(sp)
    80002680:	e44e                	sd	s3,8(sp)
    80002682:	e052                	sd	s4,0(sp)
    80002684:	1800                	addi	s0,sp,48
    80002686:	84aa                	mv	s1,a0
    80002688:	8a2e                	mv	s4,a1
    8000268a:	89b2                	mv	s3,a2
    8000268c:	8936                	mv	s2,a3
  struct proc *p = myproc();
    8000268e:	fffff097          	auipc	ra,0xfffff
    80002692:	3f8080e7          	jalr	1016(ra) # 80001a86 <myproc>

  if(user_dst)
    80002696:	c08d                	beqz	s1,800026b8 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002698:	86ca                	mv	a3,s2
    8000269a:	864e                	mv	a2,s3
    8000269c:	85d2                	mv	a1,s4
    8000269e:	6928                	ld	a0,80(a0)
    800026a0:	fffff097          	auipc	ra,0xfffff
    800026a4:	06a080e7          	jalr	106(ra) # 8000170a <copyout>
  else{
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800026a8:	70a2                	ld	ra,40(sp)
    800026aa:	7402                	ld	s0,32(sp)
    800026ac:	64e2                	ld	s1,24(sp)
    800026ae:	6942                	ld	s2,16(sp)
    800026b0:	69a2                	ld	s3,8(sp)
    800026b2:	6a02                	ld	s4,0(sp)
    800026b4:	6145                	addi	sp,sp,48
    800026b6:	8082                	ret
    memmove((char *)dst, src, len);
    800026b8:	0009061b          	sext.w	a2,s2
    800026bc:	85ce                	mv	a1,s3
    800026be:	8552                	mv	a0,s4
    800026c0:	ffffe097          	auipc	ra,0xffffe
    800026c4:	6ec080e7          	jalr	1772(ra) # 80000dac <memmove>
    return 0;
    800026c8:	8526                	mv	a0,s1
    800026ca:	bff9                	j	800026a8 <either_copyout+0x32>

00000000800026cc <either_copyin>:

// Copia datos desde espacio de usuario o kernel
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800026cc:	7179                	addi	sp,sp,-48
    800026ce:	f406                	sd	ra,40(sp)
    800026d0:	f022                	sd	s0,32(sp)
    800026d2:	ec26                	sd	s1,24(sp)
    800026d4:	e84a                	sd	s2,16(sp)
    800026d6:	e44e                	sd	s3,8(sp)
    800026d8:	e052                	sd	s4,0(sp)
    800026da:	1800                	addi	s0,sp,48
    800026dc:	8a2a                	mv	s4,a0
    800026de:	84ae                	mv	s1,a1
    800026e0:	89b2                	mv	s3,a2
    800026e2:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800026e4:	fffff097          	auipc	ra,0xfffff
    800026e8:	3a2080e7          	jalr	930(ra) # 80001a86 <myproc>

  if(user_src)
    800026ec:	c08d                	beqz	s1,8000270e <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800026ee:	86ca                	mv	a3,s2
    800026f0:	864e                	mv	a2,s3
    800026f2:	85d2                	mv	a1,s4
    800026f4:	6928                	ld	a0,80(a0)
    800026f6:	fffff097          	auipc	ra,0xfffff
    800026fa:	0a0080e7          	jalr	160(ra) # 80001796 <copyin>
  else{
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800026fe:	70a2                	ld	ra,40(sp)
    80002700:	7402                	ld	s0,32(sp)
    80002702:	64e2                	ld	s1,24(sp)
    80002704:	6942                	ld	s2,16(sp)
    80002706:	69a2                	ld	s3,8(sp)
    80002708:	6a02                	ld	s4,0(sp)
    8000270a:	6145                	addi	sp,sp,48
    8000270c:	8082                	ret
    memmove(dst, (char*)src, len);
    8000270e:	0009061b          	sext.w	a2,s2
    80002712:	85ce                	mv	a1,s3
    80002714:	8552                	mv	a0,s4
    80002716:	ffffe097          	auipc	ra,0xffffe
    8000271a:	696080e7          	jalr	1686(ra) # 80000dac <memmove>
    return 0;
    8000271e:	8526                	mv	a0,s1
    80002720:	bff9                	j	800026fe <either_copyin+0x32>

0000000080002722 <procdump>:

// Imprime informacion de procesos (Ctrl+P)
void
procdump(void)
{
    80002722:	7179                	addi	sp,sp,-48
    80002724:	f406                	sd	ra,40(sp)
    80002726:	f022                	sd	s0,32(sp)
    80002728:	ec26                	sd	s1,24(sp)
    8000272a:	e84a                	sd	s2,16(sp)
    8000272c:	e44e                	sd	s3,8(sp)
    8000272e:	1800                	addi	s0,sp,48
  };

  struct proc *p;
  char *state;

  printf("\n");
    80002730:	00006517          	auipc	a0,0x6
    80002734:	8e050513          	addi	a0,a0,-1824 # 80008010 <etext+0x10>
    80002738:	ffffe097          	auipc	ra,0xffffe
    8000273c:	e68080e7          	jalr	-408(ra) # 800005a0 <printf>

  for(p = proc; p < &proc[NPROC]; p++){
    80002740:	00012497          	auipc	s1,0x12
    80002744:	f9048493          	addi	s1,s1,-112 # 800146d0 <proc>
           p->total_run_time,
           wait_time,
           p->n_runs);
#endif

    printf("\n");
    80002748:	00006997          	auipc	s3,0x6
    8000274c:	8c898993          	addi	s3,s3,-1848 # 80008010 <etext+0x10>
  for(p = proc; p < &proc[NPROC]; p++){
    80002750:	00019917          	auipc	s2,0x19
    80002754:	18090913          	addi	s2,s2,384 # 8001b8d0 <tickslock>
    80002758:	a029                	j	80002762 <procdump+0x40>
    8000275a:	1c848493          	addi	s1,s1,456
    8000275e:	01248a63          	beq	s1,s2,80002772 <procdump+0x50>
    if(p->state == UNUSED)
    80002762:	4c9c                	lw	a5,24(s1)
    80002764:	dbfd                	beqz	a5,8000275a <procdump+0x38>
    printf("\n");
    80002766:	854e                	mv	a0,s3
    80002768:	ffffe097          	auipc	ra,0xffffe
    8000276c:	e38080e7          	jalr	-456(ra) # 800005a0 <printf>
    80002770:	b7ed                	j	8000275a <procdump+0x38>
  }
}
    80002772:	70a2                	ld	ra,40(sp)
    80002774:	7402                	ld	s0,32(sp)
    80002776:	64e2                	ld	s1,24(sp)
    80002778:	6942                	ld	s2,16(sp)
    8000277a:	69a2                	ld	s3,8(sp)
    8000277c:	6145                	addi	sp,sp,48
    8000277e:	8082                	ret

0000000080002780 <update_time>:

// Actualiza run_time y sleep_time cada tick
void
update_time(void)
{
    80002780:	7179                	addi	sp,sp,-48
    80002782:	f406                	sd	ra,40(sp)
    80002784:	f022                	sd	s0,32(sp)
    80002786:	ec26                	sd	s1,24(sp)
    80002788:	e84a                	sd	s2,16(sp)
    8000278a:	e44e                	sd	s3,8(sp)
    8000278c:	e052                	sd	s4,0(sp)
    8000278e:	1800                	addi	s0,sp,48
  struct proc* p;

  for(p = proc; p < &proc[NPROC]; p++)
    80002790:	00012497          	auipc	s1,0x12
    80002794:	f4048493          	addi	s1,s1,-192 # 800146d0 <proc>
  {
    acquire(&p->lock);

    if(p->state == RUNNING){
    80002798:	4991                	li	s3,4
      p->run_time += 1;
      p->total_run_time += 1;
    }
    else if(p->state == SLEEPING){
    8000279a:	4a09                	li	s4,2
  for(p = proc; p < &proc[NPROC]; p++)
    8000279c:	00019917          	auipc	s2,0x19
    800027a0:	13490913          	addi	s2,s2,308 # 8001b8d0 <tickslock>
    800027a4:	a025                	j	800027cc <update_time+0x4c>
      p->run_time += 1;
    800027a6:	1784b783          	ld	a5,376(s1)
    800027aa:	0785                	addi	a5,a5,1
    800027ac:	16f4bc23          	sd	a5,376(s1)
      p->total_run_time += 1;
    800027b0:	1804b783          	ld	a5,384(s1)
    800027b4:	0785                	addi	a5,a5,1
    800027b6:	18f4b023          	sd	a5,384(s1)
      p->sleep_time += 1;
    }

    release(&p->lock);
    800027ba:	8526                	mv	a0,s1
    800027bc:	ffffe097          	auipc	ra,0xffffe
    800027c0:	548080e7          	jalr	1352(ra) # 80000d04 <release>
  for(p = proc; p < &proc[NPROC]; p++)
    800027c4:	1c848493          	addi	s1,s1,456
    800027c8:	03248263          	beq	s1,s2,800027ec <update_time+0x6c>
    acquire(&p->lock);
    800027cc:	8526                	mv	a0,s1
    800027ce:	ffffe097          	auipc	ra,0xffffe
    800027d2:	486080e7          	jalr	1158(ra) # 80000c54 <acquire>
    if(p->state == RUNNING){
    800027d6:	4c9c                	lw	a5,24(s1)
    800027d8:	fd3787e3          	beq	a5,s3,800027a6 <update_time+0x26>
    else if(p->state == SLEEPING){
    800027dc:	fd479fe3          	bne	a5,s4,800027ba <update_time+0x3a>
      p->sleep_time += 1;
    800027e0:	1984b783          	ld	a5,408(s1)
    800027e4:	0785                	addi	a5,a5,1
    800027e6:	18f4bc23          	sd	a5,408(s1)
    800027ea:	bfc1                	j	800027ba <update_time+0x3a>
  }
}
    800027ec:	70a2                	ld	ra,40(sp)
    800027ee:	7402                	ld	s0,32(sp)
    800027f0:	64e2                	ld	s1,24(sp)
    800027f2:	6942                	ld	s2,16(sp)
    800027f4:	69a2                	ld	s3,8(sp)
    800027f6:	6a02                	ld	s4,0(sp)
    800027f8:	6145                	addi	sp,sp,48
    800027fa:	8082                	ret

00000000800027fc <setpriority>:

// Cambia prioridad estatica PBS
int
setpriority(int new_priority, int pid)
{
    800027fc:	7179                	addi	sp,sp,-48
    800027fe:	f406                	sd	ra,40(sp)
    80002800:	f022                	sd	s0,32(sp)
    80002802:	ec26                	sd	s1,24(sp)
    80002804:	e84a                	sd	s2,16(sp)
    80002806:	e44e                	sd	s3,8(sp)
    80002808:	e052                	sd	s4,0(sp)
    8000280a:	1800                	addi	s0,sp,48
    8000280c:	8a2a                	mv	s4,a0
    8000280e:	892e                	mv	s2,a1
  int prev_priority = 0;
  struct proc* p;

  for(p = proc; p < &proc[NPROC]; p++)
    80002810:	00012497          	auipc	s1,0x12
    80002814:	ec048493          	addi	s1,s1,-320 # 800146d0 <proc>
    80002818:	00019997          	auipc	s3,0x19
    8000281c:	0b898993          	addi	s3,s3,184 # 8001b8d0 <tickslock>
  {
    acquire(&p->lock);
    80002820:	8526                	mv	a0,s1
    80002822:	ffffe097          	auipc	ra,0xffffe
    80002826:	432080e7          	jalr	1074(ra) # 80000c54 <acquire>

    if(p->pid == pid)
    8000282a:	589c                	lw	a5,48(s1)
    8000282c:	01278d63          	beq	a5,s2,80002846 <setpriority+0x4a>
        yield();

      break;
    }

    release(&p->lock);
    80002830:	8526                	mv	a0,s1
    80002832:	ffffe097          	auipc	ra,0xffffe
    80002836:	4d2080e7          	jalr	1234(ra) # 80000d04 <release>
  for(p = proc; p < &proc[NPROC]; p++)
    8000283a:	1c848493          	addi	s1,s1,456
    8000283e:	ff3491e3          	bne	s1,s3,80002820 <setpriority+0x24>
  int prev_priority = 0;
    80002842:	4901                	li	s2,0
    80002844:	a005                	j	80002864 <setpriority+0x68>
      prev_priority = p->priority;
    80002846:	1b04a903          	lw	s2,432(s1)
      p->priority = new_priority;
    8000284a:	1b44b823          	sd	s4,432(s1)
      p->sleep_time = 0;
    8000284e:	1804bc23          	sd	zero,408(s1)
      p->run_time = 0;
    80002852:	1604bc23          	sd	zero,376(s1)
      release(&p->lock);
    80002856:	8526                	mv	a0,s1
    80002858:	ffffe097          	auipc	ra,0xffffe
    8000285c:	4ac080e7          	jalr	1196(ra) # 80000d04 <release>
      if(reschedule)
    80002860:	012a4b63          	blt	s4,s2,80002876 <setpriority+0x7a>
  }

  return prev_priority;
}
    80002864:	854a                	mv	a0,s2
    80002866:	70a2                	ld	ra,40(sp)
    80002868:	7402                	ld	s0,32(sp)
    8000286a:	64e2                	ld	s1,24(sp)
    8000286c:	6942                	ld	s2,16(sp)
    8000286e:	69a2                	ld	s3,8(sp)
    80002870:	6a02                	ld	s4,0(sp)
    80002872:	6145                	addi	sp,sp,48
    80002874:	8082                	ret
        yield();
    80002876:	00000097          	auipc	ra,0x0
    8000287a:	a16080e7          	jalr	-1514(ra) # 8000228c <yield>
    8000287e:	b7dd                	j	80002864 <setpriority+0x68>

0000000080002880 <waitx>:

// waitx: igual que wait pero devuelve tiempos rtime y wtime
int
waitx(uint64 addr, uint* rtime, uint* wtime)
{
    80002880:	711d                	addi	sp,sp,-96
    80002882:	ec86                	sd	ra,88(sp)
    80002884:	e8a2                	sd	s0,80(sp)
    80002886:	e4a6                	sd	s1,72(sp)
    80002888:	e0ca                	sd	s2,64(sp)
    8000288a:	fc4e                	sd	s3,56(sp)
    8000288c:	f852                	sd	s4,48(sp)
    8000288e:	f456                	sd	s5,40(sp)
    80002890:	f05a                	sd	s6,32(sp)
    80002892:	ec5e                	sd	s7,24(sp)
    80002894:	e862                	sd	s8,16(sp)
    80002896:	e466                	sd	s9,8(sp)
    80002898:	1080                	addi	s0,sp,96
    8000289a:	8baa                	mv	s7,a0
    8000289c:	8c2e                	mv	s8,a1
    8000289e:	8cb2                	mv	s9,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    800028a0:	fffff097          	auipc	ra,0xfffff
    800028a4:	1e6080e7          	jalr	486(ra) # 80001a86 <myproc>
    800028a8:	892a                	mv	s2,a0

  acquire(&wait_lock);
    800028aa:	00012517          	auipc	a0,0x12
    800028ae:	a0e50513          	addi	a0,a0,-1522 # 800142b8 <wait_lock>
    800028b2:	ffffe097          	auipc	ra,0xffffe
    800028b6:	3a2080e7          	jalr	930(ra) # 80000c54 <acquire>
      if(np->parent == p){

        acquire(&np->lock);
        havekids = 1;

        if(np->state == ZOMBIE){
    800028ba:	4a15                	li	s4,5
        havekids = 1;
    800028bc:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800028be:	00019997          	auipc	s3,0x19
    800028c2:	01298993          	addi	s3,s3,18 # 8001b8d0 <tickslock>
    if(!havekids || p->killed){
      release(&wait_lock);
      return -1;
    }

    sleep(p, &wait_lock);
    800028c6:	00012b17          	auipc	s6,0x12
    800028ca:	9f2b0b13          	addi	s6,s6,-1550 # 800142b8 <wait_lock>
    800028ce:	a8f1                	j	800029aa <waitx+0x12a>
          pid = np->pid;
    800028d0:	0304a983          	lw	s3,48(s1)
          *rtime = np->run_time;
    800028d4:	1784b783          	ld	a5,376(s1)
    800028d8:	00fc2023          	sw	a5,0(s8)
          *wtime = np->exit_time - np->create_time - np->run_time;
    800028dc:	1a04b783          	ld	a5,416(s1)
    800028e0:	1704b703          	ld	a4,368(s1)
    800028e4:	1784b683          	ld	a3,376(s1)
    800028e8:	9f35                	addw	a4,a4,a3
    800028ea:	9f99                	subw	a5,a5,a4
    800028ec:	00fca023          	sw	a5,0(s9)
          if(addr != 0 &&
    800028f0:	000b8e63          	beqz	s7,8000290c <waitx+0x8c>
             copyout(p->pagetable,
    800028f4:	4691                	li	a3,4
    800028f6:	02c48613          	addi	a2,s1,44
    800028fa:	85de                	mv	a1,s7
    800028fc:	05093503          	ld	a0,80(s2)
    80002900:	fffff097          	auipc	ra,0xfffff
    80002904:	e0a080e7          	jalr	-502(ra) # 8000170a <copyout>
          if(addr != 0 &&
    80002908:	04054263          	bltz	a0,8000294c <waitx+0xcc>
          freeproc(np);
    8000290c:	8526                	mv	a0,s1
    8000290e:	fffff097          	auipc	ra,0xfffff
    80002912:	32c080e7          	jalr	812(ra) # 80001c3a <freeproc>
          release(&np->lock);
    80002916:	8526                	mv	a0,s1
    80002918:	ffffe097          	auipc	ra,0xffffe
    8000291c:	3ec080e7          	jalr	1004(ra) # 80000d04 <release>
          release(&wait_lock);
    80002920:	00012517          	auipc	a0,0x12
    80002924:	99850513          	addi	a0,a0,-1640 # 800142b8 <wait_lock>
    80002928:	ffffe097          	auipc	ra,0xffffe
    8000292c:	3dc080e7          	jalr	988(ra) # 80000d04 <release>
  }
}
    80002930:	854e                	mv	a0,s3
    80002932:	60e6                	ld	ra,88(sp)
    80002934:	6446                	ld	s0,80(sp)
    80002936:	64a6                	ld	s1,72(sp)
    80002938:	6906                	ld	s2,64(sp)
    8000293a:	79e2                	ld	s3,56(sp)
    8000293c:	7a42                	ld	s4,48(sp)
    8000293e:	7aa2                	ld	s5,40(sp)
    80002940:	7b02                	ld	s6,32(sp)
    80002942:	6be2                	ld	s7,24(sp)
    80002944:	6c42                	ld	s8,16(sp)
    80002946:	6ca2                	ld	s9,8(sp)
    80002948:	6125                	addi	sp,sp,96
    8000294a:	8082                	ret
            release(&np->lock);
    8000294c:	8526                	mv	a0,s1
    8000294e:	ffffe097          	auipc	ra,0xffffe
    80002952:	3b6080e7          	jalr	950(ra) # 80000d04 <release>
            release(&wait_lock);
    80002956:	00012517          	auipc	a0,0x12
    8000295a:	96250513          	addi	a0,a0,-1694 # 800142b8 <wait_lock>
    8000295e:	ffffe097          	auipc	ra,0xffffe
    80002962:	3a6080e7          	jalr	934(ra) # 80000d04 <release>
            return -1;
    80002966:	59fd                	li	s3,-1
    80002968:	b7e1                	j	80002930 <waitx+0xb0>
    for(np = proc; np < &proc[NPROC]; np++){
    8000296a:	1c848493          	addi	s1,s1,456
    8000296e:	03348463          	beq	s1,s3,80002996 <waitx+0x116>
      if(np->parent == p){
    80002972:	7c9c                	ld	a5,56(s1)
    80002974:	ff279be3          	bne	a5,s2,8000296a <waitx+0xea>
        acquire(&np->lock);
    80002978:	8526                	mv	a0,s1
    8000297a:	ffffe097          	auipc	ra,0xffffe
    8000297e:	2da080e7          	jalr	730(ra) # 80000c54 <acquire>
        if(np->state == ZOMBIE){
    80002982:	4c9c                	lw	a5,24(s1)
    80002984:	f54786e3          	beq	a5,s4,800028d0 <waitx+0x50>
        release(&np->lock);
    80002988:	8526                	mv	a0,s1
    8000298a:	ffffe097          	auipc	ra,0xffffe
    8000298e:	37a080e7          	jalr	890(ra) # 80000d04 <release>
        havekids = 1;
    80002992:	8756                	mv	a4,s5
    80002994:	bfd9                	j	8000296a <waitx+0xea>
    if(!havekids || p->killed){
    80002996:	c305                	beqz	a4,800029b6 <waitx+0x136>
    80002998:	02892783          	lw	a5,40(s2)
    8000299c:	ef89                	bnez	a5,800029b6 <waitx+0x136>
    sleep(p, &wait_lock);
    8000299e:	85da                	mv	a1,s6
    800029a0:	854a                	mv	a0,s2
    800029a2:	00000097          	auipc	ra,0x0
    800029a6:	926080e7          	jalr	-1754(ra) # 800022c8 <sleep>
    havekids = 0;
    800029aa:	4701                	li	a4,0
    for(np = proc; np < &proc[NPROC]; np++){
    800029ac:	00012497          	auipc	s1,0x12
    800029b0:	d2448493          	addi	s1,s1,-732 # 800146d0 <proc>
    800029b4:	bf7d                	j	80002972 <waitx+0xf2>
      release(&wait_lock);
    800029b6:	00012517          	auipc	a0,0x12
    800029ba:	90250513          	addi	a0,a0,-1790 # 800142b8 <wait_lock>
    800029be:	ffffe097          	auipc	ra,0xffffe
    800029c2:	346080e7          	jalr	838(ra) # 80000d04 <release>
      return -1;
    800029c6:	59fd                	li	s3,-1
    800029c8:	b7a5                	j	80002930 <waitx+0xb0>

00000000800029ca <swtch>:
    800029ca:	00153023          	sd	ra,0(a0)
    800029ce:	00253423          	sd	sp,8(a0)
    800029d2:	e900                	sd	s0,16(a0)
    800029d4:	ed04                	sd	s1,24(a0)
    800029d6:	03253023          	sd	s2,32(a0)
    800029da:	03353423          	sd	s3,40(a0)
    800029de:	03453823          	sd	s4,48(a0)
    800029e2:	03553c23          	sd	s5,56(a0)
    800029e6:	05653023          	sd	s6,64(a0)
    800029ea:	05753423          	sd	s7,72(a0)
    800029ee:	05853823          	sd	s8,80(a0)
    800029f2:	05953c23          	sd	s9,88(a0)
    800029f6:	07a53023          	sd	s10,96(a0)
    800029fa:	07b53423          	sd	s11,104(a0)
    800029fe:	0005b083          	ld	ra,0(a1)
    80002a02:	0085b103          	ld	sp,8(a1)
    80002a06:	6980                	ld	s0,16(a1)
    80002a08:	6d84                	ld	s1,24(a1)
    80002a0a:	0205b903          	ld	s2,32(a1)
    80002a0e:	0285b983          	ld	s3,40(a1)
    80002a12:	0305ba03          	ld	s4,48(a1)
    80002a16:	0385ba83          	ld	s5,56(a1)
    80002a1a:	0405bb03          	ld	s6,64(a1)
    80002a1e:	0485bb83          	ld	s7,72(a1)
    80002a22:	0505bc03          	ld	s8,80(a1)
    80002a26:	0585bc83          	ld	s9,88(a1)
    80002a2a:	0605bd03          	ld	s10,96(a1)
    80002a2e:	0685bd83          	ld	s11,104(a1)
    80002a32:	8082                	ret

0000000080002a34 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002a34:	1141                	addi	sp,sp,-16
    80002a36:	e406                	sd	ra,8(sp)
    80002a38:	e022                	sd	s0,0(sp)
    80002a3a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002a3c:	00006597          	auipc	a1,0x6
    80002a40:	85c58593          	addi	a1,a1,-1956 # 80008298 <etext+0x298>
    80002a44:	00019517          	auipc	a0,0x19
    80002a48:	e8c50513          	addi	a0,a0,-372 # 8001b8d0 <tickslock>
    80002a4c:	ffffe097          	auipc	ra,0xffffe
    80002a50:	16e080e7          	jalr	366(ra) # 80000bba <initlock>
}
    80002a54:	60a2                	ld	ra,8(sp)
    80002a56:	6402                	ld	s0,0(sp)
    80002a58:	0141                	addi	sp,sp,16
    80002a5a:	8082                	ret

0000000080002a5c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002a5c:	1141                	addi	sp,sp,-16
    80002a5e:	e406                	sd	ra,8(sp)
    80002a60:	e022                	sd	s0,0(sp)
    80002a62:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a64:	00004797          	auipc	a5,0x4
    80002a68:	81c78793          	addi	a5,a5,-2020 # 80006280 <kernelvec>
    80002a6c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002a70:	60a2                	ld	ra,8(sp)
    80002a72:	6402                	ld	s0,0(sp)
    80002a74:	0141                	addi	sp,sp,16
    80002a76:	8082                	ret

0000000080002a78 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002a78:	1141                	addi	sp,sp,-16
    80002a7a:	e406                	sd	ra,8(sp)
    80002a7c:	e022                	sd	s0,0(sp)
    80002a7e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002a80:	fffff097          	auipc	ra,0xfffff
    80002a84:	006080e7          	jalr	6(ra) # 80001a86 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a88:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002a8c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a8e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002a92:	00004697          	auipc	a3,0x4
    80002a96:	56e68693          	addi	a3,a3,1390 # 80007000 <_trampoline>
    80002a9a:	00004717          	auipc	a4,0x4
    80002a9e:	56670713          	addi	a4,a4,1382 # 80007000 <_trampoline>
    80002aa2:	8f15                	sub	a4,a4,a3
    80002aa4:	040007b7          	lui	a5,0x4000
    80002aa8:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002aaa:	07b2                	slli	a5,a5,0xc
    80002aac:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002aae:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002ab2:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002ab4:	18002673          	csrr	a2,satp
    80002ab8:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002aba:	6d30                	ld	a2,88(a0)
    80002abc:	6138                	ld	a4,64(a0)
    80002abe:	6585                	lui	a1,0x1
    80002ac0:	972e                	add	a4,a4,a1
    80002ac2:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002ac4:	6d38                	ld	a4,88(a0)
    80002ac6:	00000617          	auipc	a2,0x0
    80002aca:	15260613          	addi	a2,a2,338 # 80002c18 <usertrap>
    80002ace:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002ad0:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002ad2:	8612                	mv	a2,tp
    80002ad4:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ad6:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002ada:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002ade:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ae2:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002ae6:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002ae8:	6f18                	ld	a4,24(a4)
    80002aea:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002aee:	692c                	ld	a1,80(a0)
    80002af0:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002af2:	00004717          	auipc	a4,0x4
    80002af6:	59e70713          	addi	a4,a4,1438 # 80007090 <userret>
    80002afa:	8f15                	sub	a4,a4,a3
    80002afc:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002afe:	577d                	li	a4,-1
    80002b00:	177e                	slli	a4,a4,0x3f
    80002b02:	8dd9                	or	a1,a1,a4
    80002b04:	02000537          	lui	a0,0x2000
    80002b08:	157d                	addi	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    80002b0a:	0536                	slli	a0,a0,0xd
    80002b0c:	9782                	jalr	a5
}
    80002b0e:	60a2                	ld	ra,8(sp)
    80002b10:	6402                	ld	s0,0(sp)
    80002b12:	0141                	addi	sp,sp,16
    80002b14:	8082                	ret

0000000080002b16 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002b16:	1141                	addi	sp,sp,-16
    80002b18:	e406                	sd	ra,8(sp)
    80002b1a:	e022                	sd	s0,0(sp)
    80002b1c:	0800                	addi	s0,sp,16
  acquire(&tickslock);
    80002b1e:	00019517          	auipc	a0,0x19
    80002b22:	db250513          	addi	a0,a0,-590 # 8001b8d0 <tickslock>
    80002b26:	ffffe097          	auipc	ra,0xffffe
    80002b2a:	12e080e7          	jalr	302(ra) # 80000c54 <acquire>
  ticks++;
    80002b2e:	00009717          	auipc	a4,0x9
    80002b32:	50270713          	addi	a4,a4,1282 # 8000c030 <ticks>
    80002b36:	431c                	lw	a5,0(a4)
    80002b38:	2785                	addiw	a5,a5,1
    80002b3a:	c31c                	sw	a5,0(a4)
  update_time();
    80002b3c:	00000097          	auipc	ra,0x0
    80002b40:	c44080e7          	jalr	-956(ra) # 80002780 <update_time>
  wakeup(&ticks);
    80002b44:	00009517          	auipc	a0,0x9
    80002b48:	4ec50513          	addi	a0,a0,1260 # 8000c030 <ticks>
    80002b4c:	00000097          	auipc	ra,0x0
    80002b50:	902080e7          	jalr	-1790(ra) # 8000244e <wakeup>
  release(&tickslock);
    80002b54:	00019517          	auipc	a0,0x19
    80002b58:	d7c50513          	addi	a0,a0,-644 # 8001b8d0 <tickslock>
    80002b5c:	ffffe097          	auipc	ra,0xffffe
    80002b60:	1a8080e7          	jalr	424(ra) # 80000d04 <release>
}
    80002b64:	60a2                	ld	ra,8(sp)
    80002b66:	6402                	ld	s0,0(sp)
    80002b68:	0141                	addi	sp,sp,16
    80002b6a:	8082                	ret

0000000080002b6c <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b6c:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002b70:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002b72:	0a07d263          	bgez	a5,80002c16 <devintr+0xaa>
{
    80002b76:	1101                	addi	sp,sp,-32
    80002b78:	ec06                	sd	ra,24(sp)
    80002b7a:	e822                	sd	s0,16(sp)
    80002b7c:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    80002b7e:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002b82:	46a5                	li	a3,9
    80002b84:	00d70c63          	beq	a4,a3,80002b9c <devintr+0x30>
  } else if(scause == 0x8000000000000001L){
    80002b88:	577d                	li	a4,-1
    80002b8a:	177e                	slli	a4,a4,0x3f
    80002b8c:	0705                	addi	a4,a4,1
    return 0;
    80002b8e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002b90:	06e78263          	beq	a5,a4,80002bf4 <devintr+0x88>
  }
}
    80002b94:	60e2                	ld	ra,24(sp)
    80002b96:	6442                	ld	s0,16(sp)
    80002b98:	6105                	addi	sp,sp,32
    80002b9a:	8082                	ret
    80002b9c:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002b9e:	00003097          	auipc	ra,0x3
    80002ba2:	7ee080e7          	jalr	2030(ra) # 8000638c <plic_claim>
    80002ba6:	872a                	mv	a4,a0
    80002ba8:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002baa:	47a9                	li	a5,10
    80002bac:	00f50963          	beq	a0,a5,80002bbe <devintr+0x52>
    } else if(irq == VIRTIO0_IRQ){
    80002bb0:	4785                	li	a5,1
    80002bb2:	00f50b63          	beq	a0,a5,80002bc8 <devintr+0x5c>
    return 1;
    80002bb6:	4505                	li	a0,1
    } else if(irq){
    80002bb8:	ef09                	bnez	a4,80002bd2 <devintr+0x66>
    80002bba:	64a2                	ld	s1,8(sp)
    80002bbc:	bfe1                	j	80002b94 <devintr+0x28>
      uartintr();
    80002bbe:	ffffe097          	auipc	ra,0xffffe
    80002bc2:	e3a080e7          	jalr	-454(ra) # 800009f8 <uartintr>
    if(irq)
    80002bc6:	a839                	j	80002be4 <devintr+0x78>
      virtio_disk_intr();
    80002bc8:	00004097          	auipc	ra,0x4
    80002bcc:	c7e080e7          	jalr	-898(ra) # 80006846 <virtio_disk_intr>
    if(irq)
    80002bd0:	a811                	j	80002be4 <devintr+0x78>
      printf("unexpected interrupt irq=%d\n", irq);
    80002bd2:	85ba                	mv	a1,a4
    80002bd4:	00005517          	auipc	a0,0x5
    80002bd8:	6cc50513          	addi	a0,a0,1740 # 800082a0 <etext+0x2a0>
    80002bdc:	ffffe097          	auipc	ra,0xffffe
    80002be0:	9c4080e7          	jalr	-1596(ra) # 800005a0 <printf>
      plic_complete(irq);
    80002be4:	8526                	mv	a0,s1
    80002be6:	00003097          	auipc	ra,0x3
    80002bea:	7ca080e7          	jalr	1994(ra) # 800063b0 <plic_complete>
    return 1;
    80002bee:	4505                	li	a0,1
    80002bf0:	64a2                	ld	s1,8(sp)
    80002bf2:	b74d                	j	80002b94 <devintr+0x28>
    if(cpuid() == 0){
    80002bf4:	fffff097          	auipc	ra,0xfffff
    80002bf8:	e5e080e7          	jalr	-418(ra) # 80001a52 <cpuid>
    80002bfc:	c901                	beqz	a0,80002c0c <devintr+0xa0>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002bfe:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002c02:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002c04:	14479073          	csrw	sip,a5
    return 2;
    80002c08:	4509                	li	a0,2
    80002c0a:	b769                	j	80002b94 <devintr+0x28>
      clockintr();
    80002c0c:	00000097          	auipc	ra,0x0
    80002c10:	f0a080e7          	jalr	-246(ra) # 80002b16 <clockintr>
    80002c14:	b7ed                	j	80002bfe <devintr+0x92>
}
    80002c16:	8082                	ret

0000000080002c18 <usertrap>:
{
    80002c18:	1101                	addi	sp,sp,-32
    80002c1a:	ec06                	sd	ra,24(sp)
    80002c1c:	e822                	sd	s0,16(sp)
    80002c1e:	e426                	sd	s1,8(sp)
    80002c20:	e04a                	sd	s2,0(sp)
    80002c22:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c24:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002c28:	1007f793          	andi	a5,a5,256
    80002c2c:	e3ad                	bnez	a5,80002c8e <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c2e:	00003797          	auipc	a5,0x3
    80002c32:	65278793          	addi	a5,a5,1618 # 80006280 <kernelvec>
    80002c36:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002c3a:	fffff097          	auipc	ra,0xfffff
    80002c3e:	e4c080e7          	jalr	-436(ra) # 80001a86 <myproc>
    80002c42:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002c44:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c46:	14102773          	csrr	a4,sepc
    80002c4a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c4c:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002c50:	47a1                	li	a5,8
    80002c52:	04f71c63          	bne	a4,a5,80002caa <usertrap+0x92>
    if(p->killed)
    80002c56:	551c                	lw	a5,40(a0)
    80002c58:	e3b9                	bnez	a5,80002c9e <usertrap+0x86>
    p->trapframe->epc += 4;
    80002c5a:	6cb8                	ld	a4,88(s1)
    80002c5c:	6f1c                	ld	a5,24(a4)
    80002c5e:	0791                	addi	a5,a5,4
    80002c60:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c62:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002c66:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c6a:	10079073          	csrw	sstatus,a5
    syscall();
    80002c6e:	00000097          	auipc	ra,0x0
    80002c72:	2e2080e7          	jalr	738(ra) # 80002f50 <syscall>
  if(p->killed)
    80002c76:	549c                	lw	a5,40(s1)
    80002c78:	ebc1                	bnez	a5,80002d08 <usertrap+0xf0>
  usertrapret();
    80002c7a:	00000097          	auipc	ra,0x0
    80002c7e:	dfe080e7          	jalr	-514(ra) # 80002a78 <usertrapret>
}
    80002c82:	60e2                	ld	ra,24(sp)
    80002c84:	6442                	ld	s0,16(sp)
    80002c86:	64a2                	ld	s1,8(sp)
    80002c88:	6902                	ld	s2,0(sp)
    80002c8a:	6105                	addi	sp,sp,32
    80002c8c:	8082                	ret
    panic("usertrap: not from user mode");
    80002c8e:	00005517          	auipc	a0,0x5
    80002c92:	63250513          	addi	a0,a0,1586 # 800082c0 <etext+0x2c0>
    80002c96:	ffffe097          	auipc	ra,0xffffe
    80002c9a:	8c0080e7          	jalr	-1856(ra) # 80000556 <panic>
      exit(-1);
    80002c9e:	557d                	li	a0,-1
    80002ca0:	00000097          	auipc	ra,0x0
    80002ca4:	87e080e7          	jalr	-1922(ra) # 8000251e <exit>
    80002ca8:	bf4d                	j	80002c5a <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002caa:	00000097          	auipc	ra,0x0
    80002cae:	ec2080e7          	jalr	-318(ra) # 80002b6c <devintr>
    80002cb2:	892a                	mv	s2,a0
    80002cb4:	c501                	beqz	a0,80002cbc <usertrap+0xa4>
  if(p->killed)
    80002cb6:	549c                	lw	a5,40(s1)
    80002cb8:	c3a1                	beqz	a5,80002cf8 <usertrap+0xe0>
    80002cba:	a815                	j	80002cee <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cbc:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002cc0:	5890                	lw	a2,48(s1)
    80002cc2:	00005517          	auipc	a0,0x5
    80002cc6:	61e50513          	addi	a0,a0,1566 # 800082e0 <etext+0x2e0>
    80002cca:	ffffe097          	auipc	ra,0xffffe
    80002cce:	8d6080e7          	jalr	-1834(ra) # 800005a0 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cd2:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cd6:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cda:	00005517          	auipc	a0,0x5
    80002cde:	63650513          	addi	a0,a0,1590 # 80008310 <etext+0x310>
    80002ce2:	ffffe097          	auipc	ra,0xffffe
    80002ce6:	8be080e7          	jalr	-1858(ra) # 800005a0 <printf>
    p->killed = 1;
    80002cea:	4785                	li	a5,1
    80002cec:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002cee:	557d                	li	a0,-1
    80002cf0:	00000097          	auipc	ra,0x0
    80002cf4:	82e080e7          	jalr	-2002(ra) # 8000251e <exit>
  if(which_dev == 2)
    80002cf8:	4789                	li	a5,2
    80002cfa:	f8f910e3          	bne	s2,a5,80002c7a <usertrap+0x62>
    yield();
    80002cfe:	fffff097          	auipc	ra,0xfffff
    80002d02:	58e080e7          	jalr	1422(ra) # 8000228c <yield>
    80002d06:	bf95                	j	80002c7a <usertrap+0x62>
  int which_dev = 0;
    80002d08:	4901                	li	s2,0
    80002d0a:	b7d5                	j	80002cee <usertrap+0xd6>

0000000080002d0c <kerneltrap>:
{
    80002d0c:	7179                	addi	sp,sp,-48
    80002d0e:	f406                	sd	ra,40(sp)
    80002d10:	f022                	sd	s0,32(sp)
    80002d12:	ec26                	sd	s1,24(sp)
    80002d14:	e84a                	sd	s2,16(sp)
    80002d16:	e44e                	sd	s3,8(sp)
    80002d18:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d1a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d1e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d22:	142027f3          	csrr	a5,scause
    80002d26:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    80002d28:	1004f793          	andi	a5,s1,256
    80002d2c:	cb85                	beqz	a5,80002d5c <kerneltrap+0x50>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d2e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002d32:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002d34:	ef85                	bnez	a5,80002d6c <kerneltrap+0x60>
  if((which_dev = devintr()) == 0){
    80002d36:	00000097          	auipc	ra,0x0
    80002d3a:	e36080e7          	jalr	-458(ra) # 80002b6c <devintr>
    80002d3e:	cd1d                	beqz	a0,80002d7c <kerneltrap+0x70>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d40:	4789                	li	a5,2
    80002d42:	06f50a63          	beq	a0,a5,80002db6 <kerneltrap+0xaa>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d46:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d4a:	10049073          	csrw	sstatus,s1
}
    80002d4e:	70a2                	ld	ra,40(sp)
    80002d50:	7402                	ld	s0,32(sp)
    80002d52:	64e2                	ld	s1,24(sp)
    80002d54:	6942                	ld	s2,16(sp)
    80002d56:	69a2                	ld	s3,8(sp)
    80002d58:	6145                	addi	sp,sp,48
    80002d5a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002d5c:	00005517          	auipc	a0,0x5
    80002d60:	5d450513          	addi	a0,a0,1492 # 80008330 <etext+0x330>
    80002d64:	ffffd097          	auipc	ra,0xffffd
    80002d68:	7f2080e7          	jalr	2034(ra) # 80000556 <panic>
    panic("kerneltrap: interrupts enabled");
    80002d6c:	00005517          	auipc	a0,0x5
    80002d70:	5ec50513          	addi	a0,a0,1516 # 80008358 <etext+0x358>
    80002d74:	ffffd097          	auipc	ra,0xffffd
    80002d78:	7e2080e7          	jalr	2018(ra) # 80000556 <panic>
    printf("scause %p\n", scause);
    80002d7c:	85ce                	mv	a1,s3
    80002d7e:	00005517          	auipc	a0,0x5
    80002d82:	5fa50513          	addi	a0,a0,1530 # 80008378 <etext+0x378>
    80002d86:	ffffe097          	auipc	ra,0xffffe
    80002d8a:	81a080e7          	jalr	-2022(ra) # 800005a0 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d8e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d92:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d96:	00005517          	auipc	a0,0x5
    80002d9a:	5f250513          	addi	a0,a0,1522 # 80008388 <etext+0x388>
    80002d9e:	ffffe097          	auipc	ra,0xffffe
    80002da2:	802080e7          	jalr	-2046(ra) # 800005a0 <printf>
    panic("kerneltrap");
    80002da6:	00005517          	auipc	a0,0x5
    80002daa:	5fa50513          	addi	a0,a0,1530 # 800083a0 <etext+0x3a0>
    80002dae:	ffffd097          	auipc	ra,0xffffd
    80002db2:	7a8080e7          	jalr	1960(ra) # 80000556 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002db6:	fffff097          	auipc	ra,0xfffff
    80002dba:	cd0080e7          	jalr	-816(ra) # 80001a86 <myproc>
    80002dbe:	d541                	beqz	a0,80002d46 <kerneltrap+0x3a>
    80002dc0:	fffff097          	auipc	ra,0xfffff
    80002dc4:	cc6080e7          	jalr	-826(ra) # 80001a86 <myproc>
    80002dc8:	4d18                	lw	a4,24(a0)
    80002dca:	4791                	li	a5,4
    80002dcc:	f6f71de3          	bne	a4,a5,80002d46 <kerneltrap+0x3a>
    yield();
    80002dd0:	fffff097          	auipc	ra,0xfffff
    80002dd4:	4bc080e7          	jalr	1212(ra) # 8000228c <yield>
    80002dd8:	b7bd                	j	80002d46 <kerneltrap+0x3a>

0000000080002dda <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002dda:	1101                	addi	sp,sp,-32
    80002ddc:	ec06                	sd	ra,24(sp)
    80002dde:	e822                	sd	s0,16(sp)
    80002de0:	e426                	sd	s1,8(sp)
    80002de2:	1000                	addi	s0,sp,32
    80002de4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002de6:	fffff097          	auipc	ra,0xfffff
    80002dea:	ca0080e7          	jalr	-864(ra) # 80001a86 <myproc>
  switch (n) {
    80002dee:	4795                	li	a5,5
    80002df0:	0497e163          	bltu	a5,s1,80002e32 <argraw+0x58>
    80002df4:	048a                	slli	s1,s1,0x2
    80002df6:	00006717          	auipc	a4,0x6
    80002dfa:	9fa70713          	addi	a4,a4,-1542 # 800087f0 <digits+0x18>
    80002dfe:	94ba                	add	s1,s1,a4
    80002e00:	409c                	lw	a5,0(s1)
    80002e02:	97ba                	add	a5,a5,a4
    80002e04:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002e06:	6d3c                	ld	a5,88(a0)
    80002e08:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002e0a:	60e2                	ld	ra,24(sp)
    80002e0c:	6442                	ld	s0,16(sp)
    80002e0e:	64a2                	ld	s1,8(sp)
    80002e10:	6105                	addi	sp,sp,32
    80002e12:	8082                	ret
    return p->trapframe->a1;
    80002e14:	6d3c                	ld	a5,88(a0)
    80002e16:	7fa8                	ld	a0,120(a5)
    80002e18:	bfcd                	j	80002e0a <argraw+0x30>
    return p->trapframe->a2;
    80002e1a:	6d3c                	ld	a5,88(a0)
    80002e1c:	63c8                	ld	a0,128(a5)
    80002e1e:	b7f5                	j	80002e0a <argraw+0x30>
    return p->trapframe->a3;
    80002e20:	6d3c                	ld	a5,88(a0)
    80002e22:	67c8                	ld	a0,136(a5)
    80002e24:	b7dd                	j	80002e0a <argraw+0x30>
    return p->trapframe->a4;
    80002e26:	6d3c                	ld	a5,88(a0)
    80002e28:	6bc8                	ld	a0,144(a5)
    80002e2a:	b7c5                	j	80002e0a <argraw+0x30>
    return p->trapframe->a5;
    80002e2c:	6d3c                	ld	a5,88(a0)
    80002e2e:	6fc8                	ld	a0,152(a5)
    80002e30:	bfe9                	j	80002e0a <argraw+0x30>
  panic("argraw");
    80002e32:	00005517          	auipc	a0,0x5
    80002e36:	57e50513          	addi	a0,a0,1406 # 800083b0 <etext+0x3b0>
    80002e3a:	ffffd097          	auipc	ra,0xffffd
    80002e3e:	71c080e7          	jalr	1820(ra) # 80000556 <panic>

0000000080002e42 <fetchaddr>:
{
    80002e42:	1101                	addi	sp,sp,-32
    80002e44:	ec06                	sd	ra,24(sp)
    80002e46:	e822                	sd	s0,16(sp)
    80002e48:	e426                	sd	s1,8(sp)
    80002e4a:	e04a                	sd	s2,0(sp)
    80002e4c:	1000                	addi	s0,sp,32
    80002e4e:	84aa                	mv	s1,a0
    80002e50:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002e52:	fffff097          	auipc	ra,0xfffff
    80002e56:	c34080e7          	jalr	-972(ra) # 80001a86 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002e5a:	653c                	ld	a5,72(a0)
    80002e5c:	02f4f863          	bgeu	s1,a5,80002e8c <fetchaddr+0x4a>
    80002e60:	00848713          	addi	a4,s1,8
    80002e64:	02e7e663          	bltu	a5,a4,80002e90 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002e68:	46a1                	li	a3,8
    80002e6a:	8626                	mv	a2,s1
    80002e6c:	85ca                	mv	a1,s2
    80002e6e:	6928                	ld	a0,80(a0)
    80002e70:	fffff097          	auipc	ra,0xfffff
    80002e74:	926080e7          	jalr	-1754(ra) # 80001796 <copyin>
    80002e78:	00a03533          	snez	a0,a0
    80002e7c:	40a0053b          	negw	a0,a0
}
    80002e80:	60e2                	ld	ra,24(sp)
    80002e82:	6442                	ld	s0,16(sp)
    80002e84:	64a2                	ld	s1,8(sp)
    80002e86:	6902                	ld	s2,0(sp)
    80002e88:	6105                	addi	sp,sp,32
    80002e8a:	8082                	ret
    return -1;
    80002e8c:	557d                	li	a0,-1
    80002e8e:	bfcd                	j	80002e80 <fetchaddr+0x3e>
    80002e90:	557d                	li	a0,-1
    80002e92:	b7fd                	j	80002e80 <fetchaddr+0x3e>

0000000080002e94 <fetchstr>:
{
    80002e94:	7179                	addi	sp,sp,-48
    80002e96:	f406                	sd	ra,40(sp)
    80002e98:	f022                	sd	s0,32(sp)
    80002e9a:	ec26                	sd	s1,24(sp)
    80002e9c:	e84a                	sd	s2,16(sp)
    80002e9e:	e44e                	sd	s3,8(sp)
    80002ea0:	1800                	addi	s0,sp,48
    80002ea2:	89aa                	mv	s3,a0
    80002ea4:	84ae                	mv	s1,a1
    80002ea6:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002ea8:	fffff097          	auipc	ra,0xfffff
    80002eac:	bde080e7          	jalr	-1058(ra) # 80001a86 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002eb0:	86ca                	mv	a3,s2
    80002eb2:	864e                	mv	a2,s3
    80002eb4:	85a6                	mv	a1,s1
    80002eb6:	6928                	ld	a0,80(a0)
    80002eb8:	fffff097          	auipc	ra,0xfffff
    80002ebc:	96c080e7          	jalr	-1684(ra) # 80001824 <copyinstr>
  if(err < 0)
    80002ec0:	00054763          	bltz	a0,80002ece <fetchstr+0x3a>
  return strlen(buf);
    80002ec4:	8526                	mv	a0,s1
    80002ec6:	ffffe097          	auipc	ra,0xffffe
    80002eca:	014080e7          	jalr	20(ra) # 80000eda <strlen>
}
    80002ece:	70a2                	ld	ra,40(sp)
    80002ed0:	7402                	ld	s0,32(sp)
    80002ed2:	64e2                	ld	s1,24(sp)
    80002ed4:	6942                	ld	s2,16(sp)
    80002ed6:	69a2                	ld	s3,8(sp)
    80002ed8:	6145                	addi	sp,sp,48
    80002eda:	8082                	ret

0000000080002edc <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002edc:	1101                	addi	sp,sp,-32
    80002ede:	ec06                	sd	ra,24(sp)
    80002ee0:	e822                	sd	s0,16(sp)
    80002ee2:	e426                	sd	s1,8(sp)
    80002ee4:	1000                	addi	s0,sp,32
    80002ee6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ee8:	00000097          	auipc	ra,0x0
    80002eec:	ef2080e7          	jalr	-270(ra) # 80002dda <argraw>
    80002ef0:	c088                	sw	a0,0(s1)
  return 0;
}
    80002ef2:	4501                	li	a0,0
    80002ef4:	60e2                	ld	ra,24(sp)
    80002ef6:	6442                	ld	s0,16(sp)
    80002ef8:	64a2                	ld	s1,8(sp)
    80002efa:	6105                	addi	sp,sp,32
    80002efc:	8082                	ret

0000000080002efe <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002efe:	1101                	addi	sp,sp,-32
    80002f00:	ec06                	sd	ra,24(sp)
    80002f02:	e822                	sd	s0,16(sp)
    80002f04:	e426                	sd	s1,8(sp)
    80002f06:	1000                	addi	s0,sp,32
    80002f08:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f0a:	00000097          	auipc	ra,0x0
    80002f0e:	ed0080e7          	jalr	-304(ra) # 80002dda <argraw>
    80002f12:	e088                	sd	a0,0(s1)
  return 0;
}
    80002f14:	4501                	li	a0,0
    80002f16:	60e2                	ld	ra,24(sp)
    80002f18:	6442                	ld	s0,16(sp)
    80002f1a:	64a2                	ld	s1,8(sp)
    80002f1c:	6105                	addi	sp,sp,32
    80002f1e:	8082                	ret

0000000080002f20 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002f20:	1101                	addi	sp,sp,-32
    80002f22:	ec06                	sd	ra,24(sp)
    80002f24:	e822                	sd	s0,16(sp)
    80002f26:	e426                	sd	s1,8(sp)
    80002f28:	e04a                	sd	s2,0(sp)
    80002f2a:	1000                	addi	s0,sp,32
    80002f2c:	892e                	mv	s2,a1
    80002f2e:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002f30:	00000097          	auipc	ra,0x0
    80002f34:	eaa080e7          	jalr	-342(ra) # 80002dda <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002f38:	8626                	mv	a2,s1
    80002f3a:	85ca                	mv	a1,s2
    80002f3c:	00000097          	auipc	ra,0x0
    80002f40:	f58080e7          	jalr	-168(ra) # 80002e94 <fetchstr>
}
    80002f44:	60e2                	ld	ra,24(sp)
    80002f46:	6442                	ld	s0,16(sp)
    80002f48:	64a2                	ld	s1,8(sp)
    80002f4a:	6902                	ld	s2,0(sp)
    80002f4c:	6105                	addi	sp,sp,32
    80002f4e:	8082                	ret

0000000080002f50 <syscall>:
[SYS_setpriority] 2,
};

void
syscall(void)
{
    80002f50:	715d                	addi	sp,sp,-80
    80002f52:	e486                	sd	ra,72(sp)
    80002f54:	e0a2                	sd	s0,64(sp)
    80002f56:	fc26                	sd	s1,56(sp)
    80002f58:	f84a                	sd	s2,48(sp)
    80002f5a:	f44e                	sd	s3,40(sp)
    80002f5c:	f052                	sd	s4,32(sp)
    80002f5e:	ec56                	sd	s5,24(sp)
    80002f60:	e85a                	sd	s6,16(sp)
    80002f62:	e45e                	sd	s7,8(sp)
    80002f64:	e062                	sd	s8,0(sp)
    80002f66:	0880                	addi	s0,sp,80
  int num, num_args;
  struct proc *p = myproc();
    80002f68:	fffff097          	auipc	ra,0xfffff
    80002f6c:	b1e080e7          	jalr	-1250(ra) # 80001a86 <myproc>
    80002f70:	8a2a                	mv	s4,a0

  num = p->trapframe->a7;
    80002f72:	6d3c                	ld	a5,88(a0)
    80002f74:	0a87ba83          	ld	s5,168(a5)
    80002f78:	000a8b1b          	sext.w	s6,s5
  num_args = syscall_num[num];
    80002f7c:	002b1713          	slli	a4,s6,0x2
    80002f80:	00006797          	auipc	a5,0x6
    80002f84:	88878793          	addi	a5,a5,-1912 # 80008808 <syscall_num>
    80002f88:	97ba                	add	a5,a5,a4
    80002f8a:	0007a983          	lw	s3,0(a5)
  
  int arr[num_args];
    80002f8e:	00299b93          	slli	s7,s3,0x2
    80002f92:	00fb8793          	addi	a5,s7,15 # 100f <_entry-0x7fffeff1>
    80002f96:	9bc1                	andi	a5,a5,-16
    80002f98:	40f10133          	sub	sp,sp,a5
    80002f9c:	8c0a                	mv	s8,sp
  for(int i = 0; i < num_args ; i++){
    80002f9e:	01305f63          	blez	s3,80002fbc <syscall+0x6c>
    80002fa2:	890a                	mv	s2,sp
    80002fa4:	4481                	li	s1,0
    arr[i] = argraw(i);
    80002fa6:	8526                	mv	a0,s1
    80002fa8:	00000097          	auipc	ra,0x0
    80002fac:	e32080e7          	jalr	-462(ra) # 80002dda <argraw>
    80002fb0:	00a92023          	sw	a0,0(s2)
  for(int i = 0; i < num_args ; i++){
    80002fb4:	2485                	addiw	s1,s1,1
    80002fb6:	0911                	addi	s2,s2,4
    80002fb8:	fe9997e3          	bne	s3,s1,80002fa6 <syscall+0x56>
  }

  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002fbc:	3afd                	addiw	s5,s5,-1
    80002fbe:	47dd                	li	a5,23
    80002fc0:	0b57e763          	bltu	a5,s5,8000306e <syscall+0x11e>
    80002fc4:	003b1713          	slli	a4,s6,0x3
    80002fc8:	00006797          	auipc	a5,0x6
    80002fcc:	84078793          	addi	a5,a5,-1984 # 80008808 <syscall_num>
    80002fd0:	97ba                	add	a5,a5,a4
    80002fd2:	77bc                	ld	a5,104(a5)
    80002fd4:	cfc9                	beqz	a5,8000306e <syscall+0x11e>
    p->trapframe->a0 = syscalls[num]();
    80002fd6:	058a3483          	ld	s1,88(s4)
    80002fda:	9782                	jalr	a5
    80002fdc:	f8a8                	sd	a0,112(s1)
    if((p -> mask >> num) & 1)
    80002fde:	168a2783          	lw	a5,360(s4)
    80002fe2:	4167d7bb          	sraw	a5,a5,s6
    80002fe6:	8b85                	andi	a5,a5,1
    80002fe8:	c7c5                	beqz	a5,80003090 <syscall+0x140>
    {
      printf("%d: syscall %s (", p -> pid, syscall_names[num]);
    80002fea:	0b0e                	slli	s6,s6,0x3
    80002fec:	00006797          	auipc	a5,0x6
    80002ff0:	81c78793          	addi	a5,a5,-2020 # 80008808 <syscall_num>
    80002ff4:	97da                	add	a5,a5,s6
    80002ff6:	1307b603          	ld	a2,304(a5)
    80002ffa:	030a2583          	lw	a1,48(s4)
    80002ffe:	00005517          	auipc	a0,0x5
    80003002:	3ba50513          	addi	a0,a0,954 # 800083b8 <etext+0x3b8>
    80003006:	ffffd097          	auipc	ra,0xffffd
    8000300a:	59a080e7          	jalr	1434(ra) # 800005a0 <printf>

      for(int i = 0; i < syscall_num[num]; i++)
    8000300e:	03305163          	blez	s3,80003030 <syscall+0xe0>
    80003012:	84e2                	mv	s1,s8
    80003014:	9be2                	add	s7,s7,s8
      {
        printf("%d ", arr[i]);
    80003016:	00005997          	auipc	s3,0x5
    8000301a:	3ba98993          	addi	s3,s3,954 # 800083d0 <etext+0x3d0>
    8000301e:	408c                	lw	a1,0(s1)
    80003020:	854e                	mv	a0,s3
    80003022:	ffffd097          	auipc	ra,0xffffd
    80003026:	57e080e7          	jalr	1406(ra) # 800005a0 <printf>
      for(int i = 0; i < syscall_num[num]; i++)
    8000302a:	0491                	addi	s1,s1,4
    8000302c:	ff7499e3          	bne	s1,s7,8000301e <syscall+0xce>
      }

      printf("\b");
    80003030:	00005517          	auipc	a0,0x5
    80003034:	3a850513          	addi	a0,a0,936 # 800083d8 <etext+0x3d8>
    80003038:	ffffd097          	auipc	ra,0xffffd
    8000303c:	568080e7          	jalr	1384(ra) # 800005a0 <printf>
      printf(") -> %d", argraw(0));  
    80003040:	4501                	li	a0,0
    80003042:	00000097          	auipc	ra,0x0
    80003046:	d98080e7          	jalr	-616(ra) # 80002dda <argraw>
    8000304a:	85aa                	mv	a1,a0
    8000304c:	00005517          	auipc	a0,0x5
    80003050:	39450513          	addi	a0,a0,916 # 800083e0 <etext+0x3e0>
    80003054:	ffffd097          	auipc	ra,0xffffd
    80003058:	54c080e7          	jalr	1356(ra) # 800005a0 <printf>
      printf("\n");
    8000305c:	00005517          	auipc	a0,0x5
    80003060:	fb450513          	addi	a0,a0,-76 # 80008010 <etext+0x10>
    80003064:	ffffd097          	auipc	ra,0xffffd
    80003068:	53c080e7          	jalr	1340(ra) # 800005a0 <printf>
    8000306c:	a015                	j	80003090 <syscall+0x140>
    }
  } else {
    printf("%d %s: unknown sys call %d\n",p->pid, p->name, num);
    8000306e:	86da                	mv	a3,s6
    80003070:	158a0613          	addi	a2,s4,344
    80003074:	030a2583          	lw	a1,48(s4)
    80003078:	00005517          	auipc	a0,0x5
    8000307c:	37050513          	addi	a0,a0,880 # 800083e8 <etext+0x3e8>
    80003080:	ffffd097          	auipc	ra,0xffffd
    80003084:	520080e7          	jalr	1312(ra) # 800005a0 <printf>
    p->trapframe->a0 = -1;
    80003088:	058a3783          	ld	a5,88(s4)
    8000308c:	577d                	li	a4,-1
    8000308e:	fbb8                	sd	a4,112(a5)
  }
}
    80003090:	fb040113          	addi	sp,s0,-80
    80003094:	60a6                	ld	ra,72(sp)
    80003096:	6406                	ld	s0,64(sp)
    80003098:	74e2                	ld	s1,56(sp)
    8000309a:	7942                	ld	s2,48(sp)
    8000309c:	79a2                	ld	s3,40(sp)
    8000309e:	7a02                	ld	s4,32(sp)
    800030a0:	6ae2                	ld	s5,24(sp)
    800030a2:	6b42                	ld	s6,16(sp)
    800030a4:	6ba2                	ld	s7,8(sp)
    800030a6:	6c02                	ld	s8,0(sp)
    800030a8:	6161                	addi	sp,sp,80
    800030aa:	8082                	ret

00000000800030ac <sys_setmemlimit>:

uint64
sys_setmemlimit(void)
{
    800030ac:	1101                	addi	sp,sp,-32
    800030ae:	ec06                	sd	ra,24(sp)
    800030b0:	e822                	sd	s0,16(sp)
    800030b2:	e426                	sd	s1,8(sp)
    800030b4:	1000                	addi	s0,sp,32
  *ip = argraw(n);
    800030b6:	4501                	li	a0,0
    800030b8:	00000097          	auipc	ra,0x0
    800030bc:	d22080e7          	jalr	-734(ra) # 80002dda <argraw>
    800030c0:	84aa                	mv	s1,a0
    int lim;
    argint(0, &lim);
    struct proc *p = myproc();
    800030c2:	fffff097          	auipc	ra,0xfffff
    800030c6:	9c4080e7          	jalr	-1596(ra) # 80001a86 <myproc>
    p->max_mem = lim;
    800030ca:	0004879b          	sext.w	a5,s1
    800030ce:	1af53c23          	sd	a5,440(a0)
    return 0;
}
    800030d2:	4501                	li	a0,0
    800030d4:	60e2                	ld	ra,24(sp)
    800030d6:	6442                	ld	s0,16(sp)
    800030d8:	64a2                	ld	s1,8(sp)
    800030da:	6105                	addi	sp,sp,32
    800030dc:	8082                	ret

00000000800030de <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800030de:	1101                	addi	sp,sp,-32
    800030e0:	ec06                	sd	ra,24(sp)
    800030e2:	e822                	sd	s0,16(sp)
    800030e4:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    800030e6:	fec40593          	addi	a1,s0,-20
    800030ea:	4501                	li	a0,0
    800030ec:	00000097          	auipc	ra,0x0
    800030f0:	df0080e7          	jalr	-528(ra) # 80002edc <argint>
    return -1;
    800030f4:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800030f6:	00054963          	bltz	a0,80003108 <sys_exit+0x2a>
  exit(n);
    800030fa:	fec42503          	lw	a0,-20(s0)
    800030fe:	fffff097          	auipc	ra,0xfffff
    80003102:	420080e7          	jalr	1056(ra) # 8000251e <exit>
  return 0;  // not reached
    80003106:	4781                	li	a5,0
}
    80003108:	853e                	mv	a0,a5
    8000310a:	60e2                	ld	ra,24(sp)
    8000310c:	6442                	ld	s0,16(sp)
    8000310e:	6105                	addi	sp,sp,32
    80003110:	8082                	ret

0000000080003112 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003112:	1141                	addi	sp,sp,-16
    80003114:	e406                	sd	ra,8(sp)
    80003116:	e022                	sd	s0,0(sp)
    80003118:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000311a:	fffff097          	auipc	ra,0xfffff
    8000311e:	96c080e7          	jalr	-1684(ra) # 80001a86 <myproc>
}
    80003122:	5908                	lw	a0,48(a0)
    80003124:	60a2                	ld	ra,8(sp)
    80003126:	6402                	ld	s0,0(sp)
    80003128:	0141                	addi	sp,sp,16
    8000312a:	8082                	ret

000000008000312c <sys_fork>:

uint64
sys_fork(void)
{
    8000312c:	1141                	addi	sp,sp,-16
    8000312e:	e406                	sd	ra,8(sp)
    80003130:	e022                	sd	s0,0(sp)
    80003132:	0800                	addi	s0,sp,16
  return fork();
    80003134:	fffff097          	auipc	ra,0xfffff
    80003138:	d7a080e7          	jalr	-646(ra) # 80001eae <fork>
}
    8000313c:	60a2                	ld	ra,8(sp)
    8000313e:	6402                	ld	s0,0(sp)
    80003140:	0141                	addi	sp,sp,16
    80003142:	8082                	ret

0000000080003144 <sys_wait>:

uint64
sys_wait(void)
{
    80003144:	1101                	addi	sp,sp,-32
    80003146:	ec06                	sd	ra,24(sp)
    80003148:	e822                	sd	s0,16(sp)
    8000314a:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    8000314c:	fe840593          	addi	a1,s0,-24
    80003150:	4501                	li	a0,0
    80003152:	00000097          	auipc	ra,0x0
    80003156:	dac080e7          	jalr	-596(ra) # 80002efe <argaddr>
    8000315a:	87aa                	mv	a5,a0
    return -1;
    8000315c:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    8000315e:	0007c863          	bltz	a5,8000316e <sys_wait+0x2a>
  return wait(p);
    80003162:	fe843503          	ld	a0,-24(s0)
    80003166:	fffff097          	auipc	ra,0xfffff
    8000316a:	1c6080e7          	jalr	454(ra) # 8000232c <wait>
}
    8000316e:	60e2                	ld	ra,24(sp)
    80003170:	6442                	ld	s0,16(sp)
    80003172:	6105                	addi	sp,sp,32
    80003174:	8082                	ret

0000000080003176 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003176:	7179                	addi	sp,sp,-48
    80003178:	f406                	sd	ra,40(sp)
    8000317a:	f022                	sd	s0,32(sp)
    8000317c:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    8000317e:	fdc40593          	addi	a1,s0,-36
    80003182:	4501                	li	a0,0
    80003184:	00000097          	auipc	ra,0x0
    80003188:	d58080e7          	jalr	-680(ra) # 80002edc <argint>
    return -1;
    8000318c:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000318e:	02054363          	bltz	a0,800031b4 <sys_sbrk+0x3e>
    80003192:	ec26                	sd	s1,24(sp)
  addr = myproc()->sz;
    80003194:	fffff097          	auipc	ra,0xfffff
    80003198:	8f2080e7          	jalr	-1806(ra) # 80001a86 <myproc>
    8000319c:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    8000319e:	fdc42503          	lw	a0,-36(s0)
    800031a2:	fffff097          	auipc	ra,0xfffff
    800031a6:	c74080e7          	jalr	-908(ra) # 80001e16 <growproc>
    800031aa:	00054a63          	bltz	a0,800031be <sys_sbrk+0x48>
    return -1;
  return addr;
    800031ae:	0004879b          	sext.w	a5,s1
    800031b2:	64e2                	ld	s1,24(sp)
}
    800031b4:	853e                	mv	a0,a5
    800031b6:	70a2                	ld	ra,40(sp)
    800031b8:	7402                	ld	s0,32(sp)
    800031ba:	6145                	addi	sp,sp,48
    800031bc:	8082                	ret
    return -1;
    800031be:	57fd                	li	a5,-1
    800031c0:	64e2                	ld	s1,24(sp)
    800031c2:	bfcd                	j	800031b4 <sys_sbrk+0x3e>

00000000800031c4 <sys_sleep>:

uint64
sys_sleep(void)
{
    800031c4:	7139                	addi	sp,sp,-64
    800031c6:	fc06                	sd	ra,56(sp)
    800031c8:	f822                	sd	s0,48(sp)
    800031ca:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    800031cc:	fcc40593          	addi	a1,s0,-52
    800031d0:	4501                	li	a0,0
    800031d2:	00000097          	auipc	ra,0x0
    800031d6:	d0a080e7          	jalr	-758(ra) # 80002edc <argint>
    return -1;
    800031da:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800031dc:	06054b63          	bltz	a0,80003252 <sys_sleep+0x8e>
  acquire(&tickslock);
    800031e0:	00018517          	auipc	a0,0x18
    800031e4:	6f050513          	addi	a0,a0,1776 # 8001b8d0 <tickslock>
    800031e8:	ffffe097          	auipc	ra,0xffffe
    800031ec:	a6c080e7          	jalr	-1428(ra) # 80000c54 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    800031f0:	fcc42783          	lw	a5,-52(s0)
    800031f4:	c7b1                	beqz	a5,80003240 <sys_sleep+0x7c>
    800031f6:	f426                	sd	s1,40(sp)
    800031f8:	f04a                	sd	s2,32(sp)
    800031fa:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    800031fc:	00009997          	auipc	s3,0x9
    80003200:	e349a983          	lw	s3,-460(s3) # 8000c030 <ticks>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003204:	00018917          	auipc	s2,0x18
    80003208:	6cc90913          	addi	s2,s2,1740 # 8001b8d0 <tickslock>
    8000320c:	00009497          	auipc	s1,0x9
    80003210:	e2448493          	addi	s1,s1,-476 # 8000c030 <ticks>
    if(myproc()->killed){
    80003214:	fffff097          	auipc	ra,0xfffff
    80003218:	872080e7          	jalr	-1934(ra) # 80001a86 <myproc>
    8000321c:	551c                	lw	a5,40(a0)
    8000321e:	ef9d                	bnez	a5,8000325c <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003220:	85ca                	mv	a1,s2
    80003222:	8526                	mv	a0,s1
    80003224:	fffff097          	auipc	ra,0xfffff
    80003228:	0a4080e7          	jalr	164(ra) # 800022c8 <sleep>
  while(ticks - ticks0 < n){
    8000322c:	409c                	lw	a5,0(s1)
    8000322e:	413787bb          	subw	a5,a5,s3
    80003232:	fcc42703          	lw	a4,-52(s0)
    80003236:	fce7efe3          	bltu	a5,a4,80003214 <sys_sleep+0x50>
    8000323a:	74a2                	ld	s1,40(sp)
    8000323c:	7902                	ld	s2,32(sp)
    8000323e:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80003240:	00018517          	auipc	a0,0x18
    80003244:	69050513          	addi	a0,a0,1680 # 8001b8d0 <tickslock>
    80003248:	ffffe097          	auipc	ra,0xffffe
    8000324c:	abc080e7          	jalr	-1348(ra) # 80000d04 <release>
  return 0;
    80003250:	4781                	li	a5,0
}
    80003252:	853e                	mv	a0,a5
    80003254:	70e2                	ld	ra,56(sp)
    80003256:	7442                	ld	s0,48(sp)
    80003258:	6121                	addi	sp,sp,64
    8000325a:	8082                	ret
      release(&tickslock);
    8000325c:	00018517          	auipc	a0,0x18
    80003260:	67450513          	addi	a0,a0,1652 # 8001b8d0 <tickslock>
    80003264:	ffffe097          	auipc	ra,0xffffe
    80003268:	aa0080e7          	jalr	-1376(ra) # 80000d04 <release>
      return -1;
    8000326c:	57fd                	li	a5,-1
    8000326e:	74a2                	ld	s1,40(sp)
    80003270:	7902                	ld	s2,32(sp)
    80003272:	69e2                	ld	s3,24(sp)
    80003274:	bff9                	j	80003252 <sys_sleep+0x8e>

0000000080003276 <sys_kill>:

uint64
sys_kill(void)
{
    80003276:	1101                	addi	sp,sp,-32
    80003278:	ec06                	sd	ra,24(sp)
    8000327a:	e822                	sd	s0,16(sp)
    8000327c:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    8000327e:	fec40593          	addi	a1,s0,-20
    80003282:	4501                	li	a0,0
    80003284:	00000097          	auipc	ra,0x0
    80003288:	c58080e7          	jalr	-936(ra) # 80002edc <argint>
    8000328c:	87aa                	mv	a5,a0
    return -1;
    8000328e:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003290:	0007c863          	bltz	a5,800032a0 <sys_kill+0x2a>
  return kill(pid);
    80003294:	fec42503          	lw	a0,-20(s0)
    80003298:	fffff097          	auipc	ra,0xfffff
    8000329c:	36c080e7          	jalr	876(ra) # 80002604 <kill>
}
    800032a0:	60e2                	ld	ra,24(sp)
    800032a2:	6442                	ld	s0,16(sp)
    800032a4:	6105                	addi	sp,sp,32
    800032a6:	8082                	ret

00000000800032a8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800032a8:	1101                	addi	sp,sp,-32
    800032aa:	ec06                	sd	ra,24(sp)
    800032ac:	e822                	sd	s0,16(sp)
    800032ae:	e426                	sd	s1,8(sp)
    800032b0:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800032b2:	00018517          	auipc	a0,0x18
    800032b6:	61e50513          	addi	a0,a0,1566 # 8001b8d0 <tickslock>
    800032ba:	ffffe097          	auipc	ra,0xffffe
    800032be:	99a080e7          	jalr	-1638(ra) # 80000c54 <acquire>
  xticks = ticks;
    800032c2:	00009797          	auipc	a5,0x9
    800032c6:	d6e7a783          	lw	a5,-658(a5) # 8000c030 <ticks>
    800032ca:	84be                	mv	s1,a5
  release(&tickslock);
    800032cc:	00018517          	auipc	a0,0x18
    800032d0:	60450513          	addi	a0,a0,1540 # 8001b8d0 <tickslock>
    800032d4:	ffffe097          	auipc	ra,0xffffe
    800032d8:	a30080e7          	jalr	-1488(ra) # 80000d04 <release>
  return xticks;
}
    800032dc:	02049513          	slli	a0,s1,0x20
    800032e0:	9101                	srli	a0,a0,0x20
    800032e2:	60e2                	ld	ra,24(sp)
    800032e4:	6442                	ld	s0,16(sp)
    800032e6:	64a2                	ld	s1,8(sp)
    800032e8:	6105                	addi	sp,sp,32
    800032ea:	8082                	ret

00000000800032ec <sys_trace>:

uint64
sys_trace()
{
    800032ec:	1101                	addi	sp,sp,-32
    800032ee:	ec06                	sd	ra,24(sp)
    800032f0:	e822                	sd	s0,16(sp)
    800032f2:	1000                	addi	s0,sp,32
  int mask;
  int arg_num = 0;

  if(argint(arg_num, &mask) >= 0)
    800032f4:	fec40593          	addi	a1,s0,-20
    800032f8:	4501                	li	a0,0
    800032fa:	00000097          	auipc	ra,0x0
    800032fe:	be2080e7          	jalr	-1054(ra) # 80002edc <argint>
    myproc() -> mask = mask;
    return 0;
  }
  else
  {
    return -1;
    80003302:	57fd                	li	a5,-1
  if(argint(arg_num, &mask) >= 0)
    80003304:	00054b63          	bltz	a0,8000331a <sys_trace+0x2e>
    myproc() -> mask = mask;
    80003308:	ffffe097          	auipc	ra,0xffffe
    8000330c:	77e080e7          	jalr	1918(ra) # 80001a86 <myproc>
    80003310:	fec42783          	lw	a5,-20(s0)
    80003314:	16f52423          	sw	a5,360(a0)
    return 0;
    80003318:	4781                	li	a5,0
  }  
}
    8000331a:	853e                	mv	a0,a5
    8000331c:	60e2                	ld	ra,24(sp)
    8000331e:	6442                	ld	s0,16(sp)
    80003320:	6105                	addi	sp,sp,32
    80003322:	8082                	ret

0000000080003324 <sys_setpriority>:

uint64
sys_setpriority()
{
    80003324:	1101                	addi	sp,sp,-32
    80003326:	ec06                	sd	ra,24(sp)
    80003328:	e822                	sd	s0,16(sp)
    8000332a:	1000                	addi	s0,sp,32
  int pid, priority;
  int arg_num[2] = {0, 1};

  if(argint(arg_num[0], &priority) < 0)
    8000332c:	fe840593          	addi	a1,s0,-24
    80003330:	4501                	li	a0,0
    80003332:	00000097          	auipc	ra,0x0
    80003336:	baa080e7          	jalr	-1110(ra) # 80002edc <argint>
  {
    return -1;
    8000333a:	57fd                	li	a5,-1
  if(argint(arg_num[0], &priority) < 0)
    8000333c:	02054563          	bltz	a0,80003366 <sys_setpriority+0x42>
  }
  if(argint(arg_num[1], &pid) < 0)
    80003340:	fec40593          	addi	a1,s0,-20
    80003344:	4505                	li	a0,1
    80003346:	00000097          	auipc	ra,0x0
    8000334a:	b96080e7          	jalr	-1130(ra) # 80002edc <argint>
  {
    return -1;
    8000334e:	57fd                	li	a5,-1
  if(argint(arg_num[1], &pid) < 0)
    80003350:	00054b63          	bltz	a0,80003366 <sys_setpriority+0x42>
  }
   
  return setpriority(priority, pid);
    80003354:	fec42583          	lw	a1,-20(s0)
    80003358:	fe842503          	lw	a0,-24(s0)
    8000335c:	fffff097          	auipc	ra,0xfffff
    80003360:	4a0080e7          	jalr	1184(ra) # 800027fc <setpriority>
    80003364:	87aa                	mv	a5,a0
}
    80003366:	853e                	mv	a0,a5
    80003368:	60e2                	ld	ra,24(sp)
    8000336a:	6442                	ld	s0,16(sp)
    8000336c:	6105                	addi	sp,sp,32
    8000336e:	8082                	ret

0000000080003370 <sys_waitx>:

uint64
sys_waitx(void)
{
    80003370:	7139                	addi	sp,sp,-64
    80003372:	fc06                	sd	ra,56(sp)
    80003374:	f822                	sd	s0,48(sp)
    80003376:	f426                	sd	s1,40(sp)
    80003378:	0080                	addi	s0,sp,64
  uint64 p, rt, wt;
  int rtime, wtime;

  // argumentos desde el usuario
  argaddr(0, &p);   // int *status
    8000337a:	fd840593          	addi	a1,s0,-40
    8000337e:	4501                	li	a0,0
    80003380:	00000097          	auipc	ra,0x0
    80003384:	b7e080e7          	jalr	-1154(ra) # 80002efe <argaddr>
  argaddr(1, &rt);  // int *rtime
    80003388:	fd040593          	addi	a1,s0,-48
    8000338c:	4505                	li	a0,1
    8000338e:	00000097          	auipc	ra,0x0
    80003392:	b70080e7          	jalr	-1168(ra) # 80002efe <argaddr>
  argaddr(2, &wt);  // int *wtime
    80003396:	fc840593          	addi	a1,s0,-56
    8000339a:	4509                	li	a0,2
    8000339c:	00000097          	auipc	ra,0x0
    800033a0:	b62080e7          	jalr	-1182(ra) # 80002efe <argaddr>

  int pid = waitx(p, &rtime, &wtime);
    800033a4:	fc040613          	addi	a2,s0,-64
    800033a8:	fc440593          	addi	a1,s0,-60
    800033ac:	fd843503          	ld	a0,-40(s0)
    800033b0:	fffff097          	auipc	ra,0xfffff
    800033b4:	4d0080e7          	jalr	1232(ra) # 80002880 <waitx>
    800033b8:	84aa                	mv	s1,a0

  if (pid < 0)
    return -1;
    800033ba:	557d                	li	a0,-1
  if (pid < 0)
    800033bc:	0404c563          	bltz	s1,80003406 <sys_waitx+0x96>

  // copiar rtime al espacio de usuario
  if (copyout(myproc()->pagetable, rt, (char*)&rtime, sizeof(rtime)) < 0)
    800033c0:	ffffe097          	auipc	ra,0xffffe
    800033c4:	6c6080e7          	jalr	1734(ra) # 80001a86 <myproc>
    800033c8:	4691                	li	a3,4
    800033ca:	fc440613          	addi	a2,s0,-60
    800033ce:	fd043583          	ld	a1,-48(s0)
    800033d2:	6928                	ld	a0,80(a0)
    800033d4:	ffffe097          	auipc	ra,0xffffe
    800033d8:	336080e7          	jalr	822(ra) # 8000170a <copyout>
    800033dc:	87aa                	mv	a5,a0
    return -1;
    800033de:	557d                	li	a0,-1
  if (copyout(myproc()->pagetable, rt, (char*)&rtime, sizeof(rtime)) < 0)
    800033e0:	0207c363          	bltz	a5,80003406 <sys_waitx+0x96>

  // copiar wtime al espacio de usuario
  if (copyout(myproc()->pagetable, wt, (char*)&wtime, sizeof(wtime)) < 0)
    800033e4:	ffffe097          	auipc	ra,0xffffe
    800033e8:	6a2080e7          	jalr	1698(ra) # 80001a86 <myproc>
    800033ec:	4691                	li	a3,4
    800033ee:	fc040613          	addi	a2,s0,-64
    800033f2:	fc843583          	ld	a1,-56(s0)
    800033f6:	6928                	ld	a0,80(a0)
    800033f8:	ffffe097          	auipc	ra,0xffffe
    800033fc:	312080e7          	jalr	786(ra) # 8000170a <copyout>
    80003400:	00054863          	bltz	a0,80003410 <sys_waitx+0xa0>
    return -1;

  return pid;
    80003404:	8526                	mv	a0,s1
}
    80003406:	70e2                	ld	ra,56(sp)
    80003408:	7442                	ld	s0,48(sp)
    8000340a:	74a2                	ld	s1,40(sp)
    8000340c:	6121                	addi	sp,sp,64
    8000340e:	8082                	ret
    return -1;
    80003410:	557d                	li	a0,-1
    80003412:	bfd5                	j	80003406 <sys_waitx+0x96>

0000000080003414 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003414:	7179                	addi	sp,sp,-48
    80003416:	f406                	sd	ra,40(sp)
    80003418:	f022                	sd	s0,32(sp)
    8000341a:	ec26                	sd	s1,24(sp)
    8000341c:	e84a                	sd	s2,16(sp)
    8000341e:	e44e                	sd	s3,8(sp)
    80003420:	e052                	sd	s4,0(sp)
    80003422:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003424:	00005597          	auipc	a1,0x5
    80003428:	0a458593          	addi	a1,a1,164 # 800084c8 <etext+0x4c8>
    8000342c:	00018517          	auipc	a0,0x18
    80003430:	4bc50513          	addi	a0,a0,1212 # 8001b8e8 <bcache>
    80003434:	ffffd097          	auipc	ra,0xffffd
    80003438:	786080e7          	jalr	1926(ra) # 80000bba <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000343c:	00020797          	auipc	a5,0x20
    80003440:	4ac78793          	addi	a5,a5,1196 # 800238e8 <bcache+0x8000>
    80003444:	00020717          	auipc	a4,0x20
    80003448:	70c70713          	addi	a4,a4,1804 # 80023b50 <bcache+0x8268>
    8000344c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003450:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003454:	00018497          	auipc	s1,0x18
    80003458:	4ac48493          	addi	s1,s1,1196 # 8001b900 <bcache+0x18>
    b->next = bcache.head.next;
    8000345c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000345e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003460:	00005a17          	auipc	s4,0x5
    80003464:	070a0a13          	addi	s4,s4,112 # 800084d0 <etext+0x4d0>
    b->next = bcache.head.next;
    80003468:	2b893783          	ld	a5,696(s2)
    8000346c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000346e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003472:	85d2                	mv	a1,s4
    80003474:	01048513          	addi	a0,s1,16
    80003478:	00001097          	auipc	ra,0x1
    8000347c:	4c2080e7          	jalr	1218(ra) # 8000493a <initsleeplock>
    bcache.head.next->prev = b;
    80003480:	2b893783          	ld	a5,696(s2)
    80003484:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003486:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000348a:	45848493          	addi	s1,s1,1112
    8000348e:	fd349de3          	bne	s1,s3,80003468 <binit+0x54>
  }
}
    80003492:	70a2                	ld	ra,40(sp)
    80003494:	7402                	ld	s0,32(sp)
    80003496:	64e2                	ld	s1,24(sp)
    80003498:	6942                	ld	s2,16(sp)
    8000349a:	69a2                	ld	s3,8(sp)
    8000349c:	6a02                	ld	s4,0(sp)
    8000349e:	6145                	addi	sp,sp,48
    800034a0:	8082                	ret

00000000800034a2 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800034a2:	7179                	addi	sp,sp,-48
    800034a4:	f406                	sd	ra,40(sp)
    800034a6:	f022                	sd	s0,32(sp)
    800034a8:	ec26                	sd	s1,24(sp)
    800034aa:	e84a                	sd	s2,16(sp)
    800034ac:	e44e                	sd	s3,8(sp)
    800034ae:	1800                	addi	s0,sp,48
    800034b0:	892a                	mv	s2,a0
    800034b2:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800034b4:	00018517          	auipc	a0,0x18
    800034b8:	43450513          	addi	a0,a0,1076 # 8001b8e8 <bcache>
    800034bc:	ffffd097          	auipc	ra,0xffffd
    800034c0:	798080e7          	jalr	1944(ra) # 80000c54 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800034c4:	00020497          	auipc	s1,0x20
    800034c8:	6dc4b483          	ld	s1,1756(s1) # 80023ba0 <bcache+0x82b8>
    800034cc:	00020797          	auipc	a5,0x20
    800034d0:	68478793          	addi	a5,a5,1668 # 80023b50 <bcache+0x8268>
    800034d4:	02f48f63          	beq	s1,a5,80003512 <bread+0x70>
    800034d8:	873e                	mv	a4,a5
    800034da:	a021                	j	800034e2 <bread+0x40>
    800034dc:	68a4                	ld	s1,80(s1)
    800034de:	02e48a63          	beq	s1,a4,80003512 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800034e2:	449c                	lw	a5,8(s1)
    800034e4:	ff279ce3          	bne	a5,s2,800034dc <bread+0x3a>
    800034e8:	44dc                	lw	a5,12(s1)
    800034ea:	ff3799e3          	bne	a5,s3,800034dc <bread+0x3a>
      b->refcnt++;
    800034ee:	40bc                	lw	a5,64(s1)
    800034f0:	2785                	addiw	a5,a5,1
    800034f2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800034f4:	00018517          	auipc	a0,0x18
    800034f8:	3f450513          	addi	a0,a0,1012 # 8001b8e8 <bcache>
    800034fc:	ffffe097          	auipc	ra,0xffffe
    80003500:	808080e7          	jalr	-2040(ra) # 80000d04 <release>
      acquiresleep(&b->lock);
    80003504:	01048513          	addi	a0,s1,16
    80003508:	00001097          	auipc	ra,0x1
    8000350c:	46c080e7          	jalr	1132(ra) # 80004974 <acquiresleep>
      return b;
    80003510:	a8b9                	j	8000356e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003512:	00020497          	auipc	s1,0x20
    80003516:	6864b483          	ld	s1,1670(s1) # 80023b98 <bcache+0x82b0>
    8000351a:	00020797          	auipc	a5,0x20
    8000351e:	63678793          	addi	a5,a5,1590 # 80023b50 <bcache+0x8268>
    80003522:	00f48863          	beq	s1,a5,80003532 <bread+0x90>
    80003526:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003528:	40bc                	lw	a5,64(s1)
    8000352a:	cf81                	beqz	a5,80003542 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000352c:	64a4                	ld	s1,72(s1)
    8000352e:	fee49de3          	bne	s1,a4,80003528 <bread+0x86>
  panic("bget: no buffers");
    80003532:	00005517          	auipc	a0,0x5
    80003536:	fa650513          	addi	a0,a0,-90 # 800084d8 <etext+0x4d8>
    8000353a:	ffffd097          	auipc	ra,0xffffd
    8000353e:	01c080e7          	jalr	28(ra) # 80000556 <panic>
      b->dev = dev;
    80003542:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003546:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000354a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000354e:	4785                	li	a5,1
    80003550:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003552:	00018517          	auipc	a0,0x18
    80003556:	39650513          	addi	a0,a0,918 # 8001b8e8 <bcache>
    8000355a:	ffffd097          	auipc	ra,0xffffd
    8000355e:	7aa080e7          	jalr	1962(ra) # 80000d04 <release>
      acquiresleep(&b->lock);
    80003562:	01048513          	addi	a0,s1,16
    80003566:	00001097          	auipc	ra,0x1
    8000356a:	40e080e7          	jalr	1038(ra) # 80004974 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000356e:	409c                	lw	a5,0(s1)
    80003570:	cb89                	beqz	a5,80003582 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003572:	8526                	mv	a0,s1
    80003574:	70a2                	ld	ra,40(sp)
    80003576:	7402                	ld	s0,32(sp)
    80003578:	64e2                	ld	s1,24(sp)
    8000357a:	6942                	ld	s2,16(sp)
    8000357c:	69a2                	ld	s3,8(sp)
    8000357e:	6145                	addi	sp,sp,48
    80003580:	8082                	ret
    virtio_disk_rw(b, 0);
    80003582:	4581                	li	a1,0
    80003584:	8526                	mv	a0,s1
    80003586:	00003097          	auipc	ra,0x3
    8000358a:	038080e7          	jalr	56(ra) # 800065be <virtio_disk_rw>
    b->valid = 1;
    8000358e:	4785                	li	a5,1
    80003590:	c09c                	sw	a5,0(s1)
  return b;
    80003592:	b7c5                	j	80003572 <bread+0xd0>

0000000080003594 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003594:	1101                	addi	sp,sp,-32
    80003596:	ec06                	sd	ra,24(sp)
    80003598:	e822                	sd	s0,16(sp)
    8000359a:	e426                	sd	s1,8(sp)
    8000359c:	1000                	addi	s0,sp,32
    8000359e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800035a0:	0541                	addi	a0,a0,16
    800035a2:	00001097          	auipc	ra,0x1
    800035a6:	46c080e7          	jalr	1132(ra) # 80004a0e <holdingsleep>
    800035aa:	cd01                	beqz	a0,800035c2 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800035ac:	4585                	li	a1,1
    800035ae:	8526                	mv	a0,s1
    800035b0:	00003097          	auipc	ra,0x3
    800035b4:	00e080e7          	jalr	14(ra) # 800065be <virtio_disk_rw>
}
    800035b8:	60e2                	ld	ra,24(sp)
    800035ba:	6442                	ld	s0,16(sp)
    800035bc:	64a2                	ld	s1,8(sp)
    800035be:	6105                	addi	sp,sp,32
    800035c0:	8082                	ret
    panic("bwrite");
    800035c2:	00005517          	auipc	a0,0x5
    800035c6:	f2e50513          	addi	a0,a0,-210 # 800084f0 <etext+0x4f0>
    800035ca:	ffffd097          	auipc	ra,0xffffd
    800035ce:	f8c080e7          	jalr	-116(ra) # 80000556 <panic>

00000000800035d2 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800035d2:	1101                	addi	sp,sp,-32
    800035d4:	ec06                	sd	ra,24(sp)
    800035d6:	e822                	sd	s0,16(sp)
    800035d8:	e426                	sd	s1,8(sp)
    800035da:	e04a                	sd	s2,0(sp)
    800035dc:	1000                	addi	s0,sp,32
    800035de:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800035e0:	01050913          	addi	s2,a0,16
    800035e4:	854a                	mv	a0,s2
    800035e6:	00001097          	auipc	ra,0x1
    800035ea:	428080e7          	jalr	1064(ra) # 80004a0e <holdingsleep>
    800035ee:	c535                	beqz	a0,8000365a <brelse+0x88>
    panic("brelse");

  releasesleep(&b->lock);
    800035f0:	854a                	mv	a0,s2
    800035f2:	00001097          	auipc	ra,0x1
    800035f6:	3d8080e7          	jalr	984(ra) # 800049ca <releasesleep>

  acquire(&bcache.lock);
    800035fa:	00018517          	auipc	a0,0x18
    800035fe:	2ee50513          	addi	a0,a0,750 # 8001b8e8 <bcache>
    80003602:	ffffd097          	auipc	ra,0xffffd
    80003606:	652080e7          	jalr	1618(ra) # 80000c54 <acquire>
  b->refcnt--;
    8000360a:	40bc                	lw	a5,64(s1)
    8000360c:	37fd                	addiw	a5,a5,-1
    8000360e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003610:	e79d                	bnez	a5,8000363e <brelse+0x6c>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003612:	68b8                	ld	a4,80(s1)
    80003614:	64bc                	ld	a5,72(s1)
    80003616:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003618:	68b8                	ld	a4,80(s1)
    8000361a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000361c:	00020797          	auipc	a5,0x20
    80003620:	2cc78793          	addi	a5,a5,716 # 800238e8 <bcache+0x8000>
    80003624:	2b87b703          	ld	a4,696(a5)
    80003628:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000362a:	00020717          	auipc	a4,0x20
    8000362e:	52670713          	addi	a4,a4,1318 # 80023b50 <bcache+0x8268>
    80003632:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003634:	2b87b703          	ld	a4,696(a5)
    80003638:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000363a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000363e:	00018517          	auipc	a0,0x18
    80003642:	2aa50513          	addi	a0,a0,682 # 8001b8e8 <bcache>
    80003646:	ffffd097          	auipc	ra,0xffffd
    8000364a:	6be080e7          	jalr	1726(ra) # 80000d04 <release>
}
    8000364e:	60e2                	ld	ra,24(sp)
    80003650:	6442                	ld	s0,16(sp)
    80003652:	64a2                	ld	s1,8(sp)
    80003654:	6902                	ld	s2,0(sp)
    80003656:	6105                	addi	sp,sp,32
    80003658:	8082                	ret
    panic("brelse");
    8000365a:	00005517          	auipc	a0,0x5
    8000365e:	e9e50513          	addi	a0,a0,-354 # 800084f8 <etext+0x4f8>
    80003662:	ffffd097          	auipc	ra,0xffffd
    80003666:	ef4080e7          	jalr	-268(ra) # 80000556 <panic>

000000008000366a <bpin>:

void
bpin(struct buf *b) {
    8000366a:	1101                	addi	sp,sp,-32
    8000366c:	ec06                	sd	ra,24(sp)
    8000366e:	e822                	sd	s0,16(sp)
    80003670:	e426                	sd	s1,8(sp)
    80003672:	1000                	addi	s0,sp,32
    80003674:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003676:	00018517          	auipc	a0,0x18
    8000367a:	27250513          	addi	a0,a0,626 # 8001b8e8 <bcache>
    8000367e:	ffffd097          	auipc	ra,0xffffd
    80003682:	5d6080e7          	jalr	1494(ra) # 80000c54 <acquire>
  b->refcnt++;
    80003686:	40bc                	lw	a5,64(s1)
    80003688:	2785                	addiw	a5,a5,1
    8000368a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000368c:	00018517          	auipc	a0,0x18
    80003690:	25c50513          	addi	a0,a0,604 # 8001b8e8 <bcache>
    80003694:	ffffd097          	auipc	ra,0xffffd
    80003698:	670080e7          	jalr	1648(ra) # 80000d04 <release>
}
    8000369c:	60e2                	ld	ra,24(sp)
    8000369e:	6442                	ld	s0,16(sp)
    800036a0:	64a2                	ld	s1,8(sp)
    800036a2:	6105                	addi	sp,sp,32
    800036a4:	8082                	ret

00000000800036a6 <bunpin>:

void
bunpin(struct buf *b) {
    800036a6:	1101                	addi	sp,sp,-32
    800036a8:	ec06                	sd	ra,24(sp)
    800036aa:	e822                	sd	s0,16(sp)
    800036ac:	e426                	sd	s1,8(sp)
    800036ae:	1000                	addi	s0,sp,32
    800036b0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800036b2:	00018517          	auipc	a0,0x18
    800036b6:	23650513          	addi	a0,a0,566 # 8001b8e8 <bcache>
    800036ba:	ffffd097          	auipc	ra,0xffffd
    800036be:	59a080e7          	jalr	1434(ra) # 80000c54 <acquire>
  b->refcnt--;
    800036c2:	40bc                	lw	a5,64(s1)
    800036c4:	37fd                	addiw	a5,a5,-1
    800036c6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800036c8:	00018517          	auipc	a0,0x18
    800036cc:	22050513          	addi	a0,a0,544 # 8001b8e8 <bcache>
    800036d0:	ffffd097          	auipc	ra,0xffffd
    800036d4:	634080e7          	jalr	1588(ra) # 80000d04 <release>
}
    800036d8:	60e2                	ld	ra,24(sp)
    800036da:	6442                	ld	s0,16(sp)
    800036dc:	64a2                	ld	s1,8(sp)
    800036de:	6105                	addi	sp,sp,32
    800036e0:	8082                	ret

00000000800036e2 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800036e2:	1101                	addi	sp,sp,-32
    800036e4:	ec06                	sd	ra,24(sp)
    800036e6:	e822                	sd	s0,16(sp)
    800036e8:	e426                	sd	s1,8(sp)
    800036ea:	e04a                	sd	s2,0(sp)
    800036ec:	1000                	addi	s0,sp,32
    800036ee:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800036f0:	00d5d79b          	srliw	a5,a1,0xd
    800036f4:	00021597          	auipc	a1,0x21
    800036f8:	8d05a583          	lw	a1,-1840(a1) # 80023fc4 <sb+0x1c>
    800036fc:	9dbd                	addw	a1,a1,a5
    800036fe:	00000097          	auipc	ra,0x0
    80003702:	da4080e7          	jalr	-604(ra) # 800034a2 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003706:	0074f713          	andi	a4,s1,7
    8000370a:	4785                	li	a5,1
    8000370c:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80003710:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80003712:	90d9                	srli	s1,s1,0x36
    80003714:	00950733          	add	a4,a0,s1
    80003718:	05874703          	lbu	a4,88(a4)
    8000371c:	00e7f6b3          	and	a3,a5,a4
    80003720:	c69d                	beqz	a3,8000374e <bfree+0x6c>
    80003722:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003724:	94aa                	add	s1,s1,a0
    80003726:	fff7c793          	not	a5,a5
    8000372a:	8f7d                	and	a4,a4,a5
    8000372c:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003730:	00001097          	auipc	ra,0x1
    80003734:	124080e7          	jalr	292(ra) # 80004854 <log_write>
  brelse(bp);
    80003738:	854a                	mv	a0,s2
    8000373a:	00000097          	auipc	ra,0x0
    8000373e:	e98080e7          	jalr	-360(ra) # 800035d2 <brelse>
}
    80003742:	60e2                	ld	ra,24(sp)
    80003744:	6442                	ld	s0,16(sp)
    80003746:	64a2                	ld	s1,8(sp)
    80003748:	6902                	ld	s2,0(sp)
    8000374a:	6105                	addi	sp,sp,32
    8000374c:	8082                	ret
    panic("freeing free block");
    8000374e:	00005517          	auipc	a0,0x5
    80003752:	db250513          	addi	a0,a0,-590 # 80008500 <etext+0x500>
    80003756:	ffffd097          	auipc	ra,0xffffd
    8000375a:	e00080e7          	jalr	-512(ra) # 80000556 <panic>

000000008000375e <balloc>:
{
    8000375e:	715d                	addi	sp,sp,-80
    80003760:	e486                	sd	ra,72(sp)
    80003762:	e0a2                	sd	s0,64(sp)
    80003764:	fc26                	sd	s1,56(sp)
    80003766:	f84a                	sd	s2,48(sp)
    80003768:	f44e                	sd	s3,40(sp)
    8000376a:	f052                	sd	s4,32(sp)
    8000376c:	ec56                	sd	s5,24(sp)
    8000376e:	e85a                	sd	s6,16(sp)
    80003770:	e45e                	sd	s7,8(sp)
    80003772:	e062                	sd	s8,0(sp)
    80003774:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80003776:	00021797          	auipc	a5,0x21
    8000377a:	8367a783          	lw	a5,-1994(a5) # 80023fac <sb+0x4>
    8000377e:	cfb5                	beqz	a5,800037fa <balloc+0x9c>
    80003780:	8baa                	mv	s7,a0
    80003782:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003784:	00021b17          	auipc	s6,0x21
    80003788:	824b0b13          	addi	s6,s6,-2012 # 80023fa8 <sb>
      m = 1 << (bi % 8);
    8000378c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000378e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003790:	6c09                	lui	s8,0x2
    80003792:	a821                	j	800037aa <balloc+0x4c>
    brelse(bp);
    80003794:	854a                	mv	a0,s2
    80003796:	00000097          	auipc	ra,0x0
    8000379a:	e3c080e7          	jalr	-452(ra) # 800035d2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000379e:	015c0abb          	addw	s5,s8,s5
    800037a2:	004b2783          	lw	a5,4(s6)
    800037a6:	04fafa63          	bgeu	s5,a5,800037fa <balloc+0x9c>
    bp = bread(dev, BBLOCK(b, sb));
    800037aa:	40dad59b          	sraiw	a1,s5,0xd
    800037ae:	01cb2783          	lw	a5,28(s6)
    800037b2:	9dbd                	addw	a1,a1,a5
    800037b4:	855e                	mv	a0,s7
    800037b6:	00000097          	auipc	ra,0x0
    800037ba:	cec080e7          	jalr	-788(ra) # 800034a2 <bread>
    800037be:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037c0:	004b2503          	lw	a0,4(s6)
    800037c4:	84d6                	mv	s1,s5
    800037c6:	4701                	li	a4,0
    800037c8:	fca4f6e3          	bgeu	s1,a0,80003794 <balloc+0x36>
      m = 1 << (bi % 8);
    800037cc:	00777693          	andi	a3,a4,7
    800037d0:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800037d4:	41f7579b          	sraiw	a5,a4,0x1f
    800037d8:	01d7d79b          	srliw	a5,a5,0x1d
    800037dc:	9fb9                	addw	a5,a5,a4
    800037de:	4037d79b          	sraiw	a5,a5,0x3
    800037e2:	00f90633          	add	a2,s2,a5
    800037e6:	05864603          	lbu	a2,88(a2)
    800037ea:	00c6f5b3          	and	a1,a3,a2
    800037ee:	cd91                	beqz	a1,8000380a <balloc+0xac>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037f0:	2705                	addiw	a4,a4,1
    800037f2:	2485                	addiw	s1,s1,1
    800037f4:	fd471ae3          	bne	a4,s4,800037c8 <balloc+0x6a>
    800037f8:	bf71                	j	80003794 <balloc+0x36>
  panic("balloc: out of blocks");
    800037fa:	00005517          	auipc	a0,0x5
    800037fe:	d1e50513          	addi	a0,a0,-738 # 80008518 <etext+0x518>
    80003802:	ffffd097          	auipc	ra,0xffffd
    80003806:	d54080e7          	jalr	-684(ra) # 80000556 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000380a:	97ca                	add	a5,a5,s2
    8000380c:	8e55                	or	a2,a2,a3
    8000380e:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003812:	854a                	mv	a0,s2
    80003814:	00001097          	auipc	ra,0x1
    80003818:	040080e7          	jalr	64(ra) # 80004854 <log_write>
        brelse(bp);
    8000381c:	854a                	mv	a0,s2
    8000381e:	00000097          	auipc	ra,0x0
    80003822:	db4080e7          	jalr	-588(ra) # 800035d2 <brelse>
  bp = bread(dev, bno);
    80003826:	85a6                	mv	a1,s1
    80003828:	855e                	mv	a0,s7
    8000382a:	00000097          	auipc	ra,0x0
    8000382e:	c78080e7          	jalr	-904(ra) # 800034a2 <bread>
    80003832:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003834:	40000613          	li	a2,1024
    80003838:	4581                	li	a1,0
    8000383a:	05850513          	addi	a0,a0,88
    8000383e:	ffffd097          	auipc	ra,0xffffd
    80003842:	50e080e7          	jalr	1294(ra) # 80000d4c <memset>
  log_write(bp);
    80003846:	854a                	mv	a0,s2
    80003848:	00001097          	auipc	ra,0x1
    8000384c:	00c080e7          	jalr	12(ra) # 80004854 <log_write>
  brelse(bp);
    80003850:	854a                	mv	a0,s2
    80003852:	00000097          	auipc	ra,0x0
    80003856:	d80080e7          	jalr	-640(ra) # 800035d2 <brelse>
}
    8000385a:	8526                	mv	a0,s1
    8000385c:	60a6                	ld	ra,72(sp)
    8000385e:	6406                	ld	s0,64(sp)
    80003860:	74e2                	ld	s1,56(sp)
    80003862:	7942                	ld	s2,48(sp)
    80003864:	79a2                	ld	s3,40(sp)
    80003866:	7a02                	ld	s4,32(sp)
    80003868:	6ae2                	ld	s5,24(sp)
    8000386a:	6b42                	ld	s6,16(sp)
    8000386c:	6ba2                	ld	s7,8(sp)
    8000386e:	6c02                	ld	s8,0(sp)
    80003870:	6161                	addi	sp,sp,80
    80003872:	8082                	ret

0000000080003874 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003874:	7179                	addi	sp,sp,-48
    80003876:	f406                	sd	ra,40(sp)
    80003878:	f022                	sd	s0,32(sp)
    8000387a:	ec26                	sd	s1,24(sp)
    8000387c:	e84a                	sd	s2,16(sp)
    8000387e:	e44e                	sd	s3,8(sp)
    80003880:	1800                	addi	s0,sp,48
    80003882:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003884:	47ad                	li	a5,11
    80003886:	04b7fd63          	bgeu	a5,a1,800038e0 <bmap+0x6c>
    8000388a:	e052                	sd	s4,0(sp)
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000388c:	ff45849b          	addiw	s1,a1,-12

  if(bn < NINDIRECT){
    80003890:	0ff00793          	li	a5,255
    80003894:	0897ef63          	bltu	a5,s1,80003932 <bmap+0xbe>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003898:	08052583          	lw	a1,128(a0)
    8000389c:	c5a5                	beqz	a1,80003904 <bmap+0x90>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000389e:	00092503          	lw	a0,0(s2)
    800038a2:	00000097          	auipc	ra,0x0
    800038a6:	c00080e7          	jalr	-1024(ra) # 800034a2 <bread>
    800038aa:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800038ac:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800038b0:	02049713          	slli	a4,s1,0x20
    800038b4:	01e75593          	srli	a1,a4,0x1e
    800038b8:	00b784b3          	add	s1,a5,a1
    800038bc:	0004a983          	lw	s3,0(s1)
    800038c0:	04098b63          	beqz	s3,80003916 <bmap+0xa2>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800038c4:	8552                	mv	a0,s4
    800038c6:	00000097          	auipc	ra,0x0
    800038ca:	d0c080e7          	jalr	-756(ra) # 800035d2 <brelse>
    return addr;
    800038ce:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800038d0:	854e                	mv	a0,s3
    800038d2:	70a2                	ld	ra,40(sp)
    800038d4:	7402                	ld	s0,32(sp)
    800038d6:	64e2                	ld	s1,24(sp)
    800038d8:	6942                	ld	s2,16(sp)
    800038da:	69a2                	ld	s3,8(sp)
    800038dc:	6145                	addi	sp,sp,48
    800038de:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800038e0:	02059793          	slli	a5,a1,0x20
    800038e4:	01e7d593          	srli	a1,a5,0x1e
    800038e8:	00b504b3          	add	s1,a0,a1
    800038ec:	0504a983          	lw	s3,80(s1)
    800038f0:	fe0990e3          	bnez	s3,800038d0 <bmap+0x5c>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800038f4:	4108                	lw	a0,0(a0)
    800038f6:	00000097          	auipc	ra,0x0
    800038fa:	e68080e7          	jalr	-408(ra) # 8000375e <balloc>
    800038fe:	89aa                	mv	s3,a0
    80003900:	c8a8                	sw	a0,80(s1)
    80003902:	b7f9                	j	800038d0 <bmap+0x5c>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003904:	4108                	lw	a0,0(a0)
    80003906:	00000097          	auipc	ra,0x0
    8000390a:	e58080e7          	jalr	-424(ra) # 8000375e <balloc>
    8000390e:	85aa                	mv	a1,a0
    80003910:	08a92023          	sw	a0,128(s2)
    80003914:	b769                	j	8000389e <bmap+0x2a>
      a[bn] = addr = balloc(ip->dev);
    80003916:	00092503          	lw	a0,0(s2)
    8000391a:	00000097          	auipc	ra,0x0
    8000391e:	e44080e7          	jalr	-444(ra) # 8000375e <balloc>
    80003922:	89aa                	mv	s3,a0
    80003924:	c088                	sw	a0,0(s1)
      log_write(bp);
    80003926:	8552                	mv	a0,s4
    80003928:	00001097          	auipc	ra,0x1
    8000392c:	f2c080e7          	jalr	-212(ra) # 80004854 <log_write>
    80003930:	bf51                	j	800038c4 <bmap+0x50>
  panic("bmap: out of range");
    80003932:	00005517          	auipc	a0,0x5
    80003936:	bfe50513          	addi	a0,a0,-1026 # 80008530 <etext+0x530>
    8000393a:	ffffd097          	auipc	ra,0xffffd
    8000393e:	c1c080e7          	jalr	-996(ra) # 80000556 <panic>

0000000080003942 <iget>:
{
    80003942:	7179                	addi	sp,sp,-48
    80003944:	f406                	sd	ra,40(sp)
    80003946:	f022                	sd	s0,32(sp)
    80003948:	ec26                	sd	s1,24(sp)
    8000394a:	e84a                	sd	s2,16(sp)
    8000394c:	e44e                	sd	s3,8(sp)
    8000394e:	e052                	sd	s4,0(sp)
    80003950:	1800                	addi	s0,sp,48
    80003952:	892a                	mv	s2,a0
    80003954:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003956:	00020517          	auipc	a0,0x20
    8000395a:	67250513          	addi	a0,a0,1650 # 80023fc8 <itable>
    8000395e:	ffffd097          	auipc	ra,0xffffd
    80003962:	2f6080e7          	jalr	758(ra) # 80000c54 <acquire>
  empty = 0;
    80003966:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003968:	00020497          	auipc	s1,0x20
    8000396c:	67848493          	addi	s1,s1,1656 # 80023fe0 <itable+0x18>
    80003970:	00022697          	auipc	a3,0x22
    80003974:	10068693          	addi	a3,a3,256 # 80025a70 <log>
    80003978:	a809                	j	8000398a <iget+0x48>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000397a:	e781                	bnez	a5,80003982 <iget+0x40>
    8000397c:	00099363          	bnez	s3,80003982 <iget+0x40>
      empty = ip;
    80003980:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003982:	08848493          	addi	s1,s1,136
    80003986:	02d48763          	beq	s1,a3,800039b4 <iget+0x72>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000398a:	449c                	lw	a5,8(s1)
    8000398c:	fef057e3          	blez	a5,8000397a <iget+0x38>
    80003990:	4098                	lw	a4,0(s1)
    80003992:	ff2718e3          	bne	a4,s2,80003982 <iget+0x40>
    80003996:	40d8                	lw	a4,4(s1)
    80003998:	ff4715e3          	bne	a4,s4,80003982 <iget+0x40>
      ip->ref++;
    8000399c:	2785                	addiw	a5,a5,1
    8000399e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800039a0:	00020517          	auipc	a0,0x20
    800039a4:	62850513          	addi	a0,a0,1576 # 80023fc8 <itable>
    800039a8:	ffffd097          	auipc	ra,0xffffd
    800039ac:	35c080e7          	jalr	860(ra) # 80000d04 <release>
      return ip;
    800039b0:	89a6                	mv	s3,s1
    800039b2:	a025                	j	800039da <iget+0x98>
  if(empty == 0)
    800039b4:	02098c63          	beqz	s3,800039ec <iget+0xaa>
  ip->dev = dev;
    800039b8:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    800039bc:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    800039c0:	4785                	li	a5,1
    800039c2:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    800039c6:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    800039ca:	00020517          	auipc	a0,0x20
    800039ce:	5fe50513          	addi	a0,a0,1534 # 80023fc8 <itable>
    800039d2:	ffffd097          	auipc	ra,0xffffd
    800039d6:	332080e7          	jalr	818(ra) # 80000d04 <release>
}
    800039da:	854e                	mv	a0,s3
    800039dc:	70a2                	ld	ra,40(sp)
    800039de:	7402                	ld	s0,32(sp)
    800039e0:	64e2                	ld	s1,24(sp)
    800039e2:	6942                	ld	s2,16(sp)
    800039e4:	69a2                	ld	s3,8(sp)
    800039e6:	6a02                	ld	s4,0(sp)
    800039e8:	6145                	addi	sp,sp,48
    800039ea:	8082                	ret
    panic("iget: no inodes");
    800039ec:	00005517          	auipc	a0,0x5
    800039f0:	b5c50513          	addi	a0,a0,-1188 # 80008548 <etext+0x548>
    800039f4:	ffffd097          	auipc	ra,0xffffd
    800039f8:	b62080e7          	jalr	-1182(ra) # 80000556 <panic>

00000000800039fc <fsinit>:
fsinit(int dev) {
    800039fc:	1101                	addi	sp,sp,-32
    800039fe:	ec06                	sd	ra,24(sp)
    80003a00:	e822                	sd	s0,16(sp)
    80003a02:	e426                	sd	s1,8(sp)
    80003a04:	e04a                	sd	s2,0(sp)
    80003a06:	1000                	addi	s0,sp,32
    80003a08:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003a0a:	4585                	li	a1,1
    80003a0c:	00000097          	auipc	ra,0x0
    80003a10:	a96080e7          	jalr	-1386(ra) # 800034a2 <bread>
    80003a14:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003a16:	02000613          	li	a2,32
    80003a1a:	05850593          	addi	a1,a0,88
    80003a1e:	00020517          	auipc	a0,0x20
    80003a22:	58a50513          	addi	a0,a0,1418 # 80023fa8 <sb>
    80003a26:	ffffd097          	auipc	ra,0xffffd
    80003a2a:	386080e7          	jalr	902(ra) # 80000dac <memmove>
  brelse(bp);
    80003a2e:	8526                	mv	a0,s1
    80003a30:	00000097          	auipc	ra,0x0
    80003a34:	ba2080e7          	jalr	-1118(ra) # 800035d2 <brelse>
  if(sb.magic != FSMAGIC)
    80003a38:	00020717          	auipc	a4,0x20
    80003a3c:	57072703          	lw	a4,1392(a4) # 80023fa8 <sb>
    80003a40:	102037b7          	lui	a5,0x10203
    80003a44:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003a48:	02f71163          	bne	a4,a5,80003a6a <fsinit+0x6e>
  initlog(dev, &sb);
    80003a4c:	00020597          	auipc	a1,0x20
    80003a50:	55c58593          	addi	a1,a1,1372 # 80023fa8 <sb>
    80003a54:	854a                	mv	a0,s2
    80003a56:	00001097          	auipc	ra,0x1
    80003a5a:	b78080e7          	jalr	-1160(ra) # 800045ce <initlog>
}
    80003a5e:	60e2                	ld	ra,24(sp)
    80003a60:	6442                	ld	s0,16(sp)
    80003a62:	64a2                	ld	s1,8(sp)
    80003a64:	6902                	ld	s2,0(sp)
    80003a66:	6105                	addi	sp,sp,32
    80003a68:	8082                	ret
    panic("invalid file system");
    80003a6a:	00005517          	auipc	a0,0x5
    80003a6e:	aee50513          	addi	a0,a0,-1298 # 80008558 <etext+0x558>
    80003a72:	ffffd097          	auipc	ra,0xffffd
    80003a76:	ae4080e7          	jalr	-1308(ra) # 80000556 <panic>

0000000080003a7a <iinit>:
{
    80003a7a:	7179                	addi	sp,sp,-48
    80003a7c:	f406                	sd	ra,40(sp)
    80003a7e:	f022                	sd	s0,32(sp)
    80003a80:	ec26                	sd	s1,24(sp)
    80003a82:	e84a                	sd	s2,16(sp)
    80003a84:	e44e                	sd	s3,8(sp)
    80003a86:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003a88:	00005597          	auipc	a1,0x5
    80003a8c:	ae858593          	addi	a1,a1,-1304 # 80008570 <etext+0x570>
    80003a90:	00020517          	auipc	a0,0x20
    80003a94:	53850513          	addi	a0,a0,1336 # 80023fc8 <itable>
    80003a98:	ffffd097          	auipc	ra,0xffffd
    80003a9c:	122080e7          	jalr	290(ra) # 80000bba <initlock>
  for(i = 0; i < NINODE; i++) {
    80003aa0:	00020497          	auipc	s1,0x20
    80003aa4:	55048493          	addi	s1,s1,1360 # 80023ff0 <itable+0x28>
    80003aa8:	00022997          	auipc	s3,0x22
    80003aac:	fd898993          	addi	s3,s3,-40 # 80025a80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003ab0:	00005917          	auipc	s2,0x5
    80003ab4:	ac890913          	addi	s2,s2,-1336 # 80008578 <etext+0x578>
    80003ab8:	85ca                	mv	a1,s2
    80003aba:	8526                	mv	a0,s1
    80003abc:	00001097          	auipc	ra,0x1
    80003ac0:	e7e080e7          	jalr	-386(ra) # 8000493a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003ac4:	08848493          	addi	s1,s1,136
    80003ac8:	ff3498e3          	bne	s1,s3,80003ab8 <iinit+0x3e>
}
    80003acc:	70a2                	ld	ra,40(sp)
    80003ace:	7402                	ld	s0,32(sp)
    80003ad0:	64e2                	ld	s1,24(sp)
    80003ad2:	6942                	ld	s2,16(sp)
    80003ad4:	69a2                	ld	s3,8(sp)
    80003ad6:	6145                	addi	sp,sp,48
    80003ad8:	8082                	ret

0000000080003ada <ialloc>:
{
    80003ada:	7139                	addi	sp,sp,-64
    80003adc:	fc06                	sd	ra,56(sp)
    80003ade:	f822                	sd	s0,48(sp)
    80003ae0:	f426                	sd	s1,40(sp)
    80003ae2:	f04a                	sd	s2,32(sp)
    80003ae4:	ec4e                	sd	s3,24(sp)
    80003ae6:	e852                	sd	s4,16(sp)
    80003ae8:	e456                	sd	s5,8(sp)
    80003aea:	e05a                	sd	s6,0(sp)
    80003aec:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003aee:	00020717          	auipc	a4,0x20
    80003af2:	4c672703          	lw	a4,1222(a4) # 80023fb4 <sb+0xc>
    80003af6:	4785                	li	a5,1
    80003af8:	04e7f863          	bgeu	a5,a4,80003b48 <ialloc+0x6e>
    80003afc:	8aaa                	mv	s5,a0
    80003afe:	8b2e                	mv	s6,a1
    80003b00:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003b02:	00020a17          	auipc	s4,0x20
    80003b06:	4a6a0a13          	addi	s4,s4,1190 # 80023fa8 <sb>
    80003b0a:	00495593          	srli	a1,s2,0x4
    80003b0e:	018a2783          	lw	a5,24(s4)
    80003b12:	9dbd                	addw	a1,a1,a5
    80003b14:	8556                	mv	a0,s5
    80003b16:	00000097          	auipc	ra,0x0
    80003b1a:	98c080e7          	jalr	-1652(ra) # 800034a2 <bread>
    80003b1e:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003b20:	05850993          	addi	s3,a0,88
    80003b24:	00f97793          	andi	a5,s2,15
    80003b28:	079a                	slli	a5,a5,0x6
    80003b2a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003b2c:	00099783          	lh	a5,0(s3)
    80003b30:	c785                	beqz	a5,80003b58 <ialloc+0x7e>
    brelse(bp);
    80003b32:	00000097          	auipc	ra,0x0
    80003b36:	aa0080e7          	jalr	-1376(ra) # 800035d2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b3a:	0905                	addi	s2,s2,1
    80003b3c:	00ca2703          	lw	a4,12(s4)
    80003b40:	0009079b          	sext.w	a5,s2
    80003b44:	fce7e3e3          	bltu	a5,a4,80003b0a <ialloc+0x30>
  panic("ialloc: no inodes");
    80003b48:	00005517          	auipc	a0,0x5
    80003b4c:	a3850513          	addi	a0,a0,-1480 # 80008580 <etext+0x580>
    80003b50:	ffffd097          	auipc	ra,0xffffd
    80003b54:	a06080e7          	jalr	-1530(ra) # 80000556 <panic>
      memset(dip, 0, sizeof(*dip));
    80003b58:	04000613          	li	a2,64
    80003b5c:	4581                	li	a1,0
    80003b5e:	854e                	mv	a0,s3
    80003b60:	ffffd097          	auipc	ra,0xffffd
    80003b64:	1ec080e7          	jalr	492(ra) # 80000d4c <memset>
      dip->type = type;
    80003b68:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003b6c:	8526                	mv	a0,s1
    80003b6e:	00001097          	auipc	ra,0x1
    80003b72:	ce6080e7          	jalr	-794(ra) # 80004854 <log_write>
      brelse(bp);
    80003b76:	8526                	mv	a0,s1
    80003b78:	00000097          	auipc	ra,0x0
    80003b7c:	a5a080e7          	jalr	-1446(ra) # 800035d2 <brelse>
      return iget(dev, inum);
    80003b80:	0009059b          	sext.w	a1,s2
    80003b84:	8556                	mv	a0,s5
    80003b86:	00000097          	auipc	ra,0x0
    80003b8a:	dbc080e7          	jalr	-580(ra) # 80003942 <iget>
}
    80003b8e:	70e2                	ld	ra,56(sp)
    80003b90:	7442                	ld	s0,48(sp)
    80003b92:	74a2                	ld	s1,40(sp)
    80003b94:	7902                	ld	s2,32(sp)
    80003b96:	69e2                	ld	s3,24(sp)
    80003b98:	6a42                	ld	s4,16(sp)
    80003b9a:	6aa2                	ld	s5,8(sp)
    80003b9c:	6b02                	ld	s6,0(sp)
    80003b9e:	6121                	addi	sp,sp,64
    80003ba0:	8082                	ret

0000000080003ba2 <iupdate>:
{
    80003ba2:	1101                	addi	sp,sp,-32
    80003ba4:	ec06                	sd	ra,24(sp)
    80003ba6:	e822                	sd	s0,16(sp)
    80003ba8:	e426                	sd	s1,8(sp)
    80003baa:	e04a                	sd	s2,0(sp)
    80003bac:	1000                	addi	s0,sp,32
    80003bae:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003bb0:	415c                	lw	a5,4(a0)
    80003bb2:	0047d79b          	srliw	a5,a5,0x4
    80003bb6:	00020597          	auipc	a1,0x20
    80003bba:	40a5a583          	lw	a1,1034(a1) # 80023fc0 <sb+0x18>
    80003bbe:	9dbd                	addw	a1,a1,a5
    80003bc0:	4108                	lw	a0,0(a0)
    80003bc2:	00000097          	auipc	ra,0x0
    80003bc6:	8e0080e7          	jalr	-1824(ra) # 800034a2 <bread>
    80003bca:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003bcc:	05850793          	addi	a5,a0,88
    80003bd0:	40d8                	lw	a4,4(s1)
    80003bd2:	8b3d                	andi	a4,a4,15
    80003bd4:	071a                	slli	a4,a4,0x6
    80003bd6:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003bd8:	04449703          	lh	a4,68(s1)
    80003bdc:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003be0:	04649703          	lh	a4,70(s1)
    80003be4:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003be8:	04849703          	lh	a4,72(s1)
    80003bec:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003bf0:	04a49703          	lh	a4,74(s1)
    80003bf4:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003bf8:	44f8                	lw	a4,76(s1)
    80003bfa:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003bfc:	03400613          	li	a2,52
    80003c00:	05048593          	addi	a1,s1,80
    80003c04:	00c78513          	addi	a0,a5,12
    80003c08:	ffffd097          	auipc	ra,0xffffd
    80003c0c:	1a4080e7          	jalr	420(ra) # 80000dac <memmove>
  log_write(bp);
    80003c10:	854a                	mv	a0,s2
    80003c12:	00001097          	auipc	ra,0x1
    80003c16:	c42080e7          	jalr	-958(ra) # 80004854 <log_write>
  brelse(bp);
    80003c1a:	854a                	mv	a0,s2
    80003c1c:	00000097          	auipc	ra,0x0
    80003c20:	9b6080e7          	jalr	-1610(ra) # 800035d2 <brelse>
}
    80003c24:	60e2                	ld	ra,24(sp)
    80003c26:	6442                	ld	s0,16(sp)
    80003c28:	64a2                	ld	s1,8(sp)
    80003c2a:	6902                	ld	s2,0(sp)
    80003c2c:	6105                	addi	sp,sp,32
    80003c2e:	8082                	ret

0000000080003c30 <idup>:
{
    80003c30:	1101                	addi	sp,sp,-32
    80003c32:	ec06                	sd	ra,24(sp)
    80003c34:	e822                	sd	s0,16(sp)
    80003c36:	e426                	sd	s1,8(sp)
    80003c38:	1000                	addi	s0,sp,32
    80003c3a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c3c:	00020517          	auipc	a0,0x20
    80003c40:	38c50513          	addi	a0,a0,908 # 80023fc8 <itable>
    80003c44:	ffffd097          	auipc	ra,0xffffd
    80003c48:	010080e7          	jalr	16(ra) # 80000c54 <acquire>
  ip->ref++;
    80003c4c:	449c                	lw	a5,8(s1)
    80003c4e:	2785                	addiw	a5,a5,1
    80003c50:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c52:	00020517          	auipc	a0,0x20
    80003c56:	37650513          	addi	a0,a0,886 # 80023fc8 <itable>
    80003c5a:	ffffd097          	auipc	ra,0xffffd
    80003c5e:	0aa080e7          	jalr	170(ra) # 80000d04 <release>
}
    80003c62:	8526                	mv	a0,s1
    80003c64:	60e2                	ld	ra,24(sp)
    80003c66:	6442                	ld	s0,16(sp)
    80003c68:	64a2                	ld	s1,8(sp)
    80003c6a:	6105                	addi	sp,sp,32
    80003c6c:	8082                	ret

0000000080003c6e <ilock>:
{
    80003c6e:	1101                	addi	sp,sp,-32
    80003c70:	ec06                	sd	ra,24(sp)
    80003c72:	e822                	sd	s0,16(sp)
    80003c74:	e426                	sd	s1,8(sp)
    80003c76:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003c78:	c10d                	beqz	a0,80003c9a <ilock+0x2c>
    80003c7a:	84aa                	mv	s1,a0
    80003c7c:	451c                	lw	a5,8(a0)
    80003c7e:	00f05e63          	blez	a5,80003c9a <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003c82:	0541                	addi	a0,a0,16
    80003c84:	00001097          	auipc	ra,0x1
    80003c88:	cf0080e7          	jalr	-784(ra) # 80004974 <acquiresleep>
  if(ip->valid == 0){
    80003c8c:	40bc                	lw	a5,64(s1)
    80003c8e:	cf99                	beqz	a5,80003cac <ilock+0x3e>
}
    80003c90:	60e2                	ld	ra,24(sp)
    80003c92:	6442                	ld	s0,16(sp)
    80003c94:	64a2                	ld	s1,8(sp)
    80003c96:	6105                	addi	sp,sp,32
    80003c98:	8082                	ret
    80003c9a:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003c9c:	00005517          	auipc	a0,0x5
    80003ca0:	8fc50513          	addi	a0,a0,-1796 # 80008598 <etext+0x598>
    80003ca4:	ffffd097          	auipc	ra,0xffffd
    80003ca8:	8b2080e7          	jalr	-1870(ra) # 80000556 <panic>
    80003cac:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003cae:	40dc                	lw	a5,4(s1)
    80003cb0:	0047d79b          	srliw	a5,a5,0x4
    80003cb4:	00020597          	auipc	a1,0x20
    80003cb8:	30c5a583          	lw	a1,780(a1) # 80023fc0 <sb+0x18>
    80003cbc:	9dbd                	addw	a1,a1,a5
    80003cbe:	4088                	lw	a0,0(s1)
    80003cc0:	fffff097          	auipc	ra,0xfffff
    80003cc4:	7e2080e7          	jalr	2018(ra) # 800034a2 <bread>
    80003cc8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003cca:	05850593          	addi	a1,a0,88
    80003cce:	40dc                	lw	a5,4(s1)
    80003cd0:	8bbd                	andi	a5,a5,15
    80003cd2:	079a                	slli	a5,a5,0x6
    80003cd4:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003cd6:	00059783          	lh	a5,0(a1)
    80003cda:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003cde:	00259783          	lh	a5,2(a1)
    80003ce2:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003ce6:	00459783          	lh	a5,4(a1)
    80003cea:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003cee:	00659783          	lh	a5,6(a1)
    80003cf2:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003cf6:	459c                	lw	a5,8(a1)
    80003cf8:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003cfa:	03400613          	li	a2,52
    80003cfe:	05b1                	addi	a1,a1,12
    80003d00:	05048513          	addi	a0,s1,80
    80003d04:	ffffd097          	auipc	ra,0xffffd
    80003d08:	0a8080e7          	jalr	168(ra) # 80000dac <memmove>
    brelse(bp);
    80003d0c:	854a                	mv	a0,s2
    80003d0e:	00000097          	auipc	ra,0x0
    80003d12:	8c4080e7          	jalr	-1852(ra) # 800035d2 <brelse>
    ip->valid = 1;
    80003d16:	4785                	li	a5,1
    80003d18:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003d1a:	04449783          	lh	a5,68(s1)
    80003d1e:	c399                	beqz	a5,80003d24 <ilock+0xb6>
    80003d20:	6902                	ld	s2,0(sp)
    80003d22:	b7bd                	j	80003c90 <ilock+0x22>
      panic("ilock: no type");
    80003d24:	00005517          	auipc	a0,0x5
    80003d28:	87c50513          	addi	a0,a0,-1924 # 800085a0 <etext+0x5a0>
    80003d2c:	ffffd097          	auipc	ra,0xffffd
    80003d30:	82a080e7          	jalr	-2006(ra) # 80000556 <panic>

0000000080003d34 <iunlock>:
{
    80003d34:	1101                	addi	sp,sp,-32
    80003d36:	ec06                	sd	ra,24(sp)
    80003d38:	e822                	sd	s0,16(sp)
    80003d3a:	e426                	sd	s1,8(sp)
    80003d3c:	e04a                	sd	s2,0(sp)
    80003d3e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003d40:	c905                	beqz	a0,80003d70 <iunlock+0x3c>
    80003d42:	84aa                	mv	s1,a0
    80003d44:	01050913          	addi	s2,a0,16
    80003d48:	854a                	mv	a0,s2
    80003d4a:	00001097          	auipc	ra,0x1
    80003d4e:	cc4080e7          	jalr	-828(ra) # 80004a0e <holdingsleep>
    80003d52:	cd19                	beqz	a0,80003d70 <iunlock+0x3c>
    80003d54:	449c                	lw	a5,8(s1)
    80003d56:	00f05d63          	blez	a5,80003d70 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003d5a:	854a                	mv	a0,s2
    80003d5c:	00001097          	auipc	ra,0x1
    80003d60:	c6e080e7          	jalr	-914(ra) # 800049ca <releasesleep>
}
    80003d64:	60e2                	ld	ra,24(sp)
    80003d66:	6442                	ld	s0,16(sp)
    80003d68:	64a2                	ld	s1,8(sp)
    80003d6a:	6902                	ld	s2,0(sp)
    80003d6c:	6105                	addi	sp,sp,32
    80003d6e:	8082                	ret
    panic("iunlock");
    80003d70:	00005517          	auipc	a0,0x5
    80003d74:	84050513          	addi	a0,a0,-1984 # 800085b0 <etext+0x5b0>
    80003d78:	ffffc097          	auipc	ra,0xffffc
    80003d7c:	7de080e7          	jalr	2014(ra) # 80000556 <panic>

0000000080003d80 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003d80:	7179                	addi	sp,sp,-48
    80003d82:	f406                	sd	ra,40(sp)
    80003d84:	f022                	sd	s0,32(sp)
    80003d86:	ec26                	sd	s1,24(sp)
    80003d88:	e84a                	sd	s2,16(sp)
    80003d8a:	e44e                	sd	s3,8(sp)
    80003d8c:	1800                	addi	s0,sp,48
    80003d8e:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003d90:	05050493          	addi	s1,a0,80
    80003d94:	08050913          	addi	s2,a0,128
    80003d98:	a021                	j	80003da0 <itrunc+0x20>
    80003d9a:	0491                	addi	s1,s1,4
    80003d9c:	01248d63          	beq	s1,s2,80003db6 <itrunc+0x36>
    if(ip->addrs[i]){
    80003da0:	408c                	lw	a1,0(s1)
    80003da2:	dde5                	beqz	a1,80003d9a <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003da4:	0009a503          	lw	a0,0(s3)
    80003da8:	00000097          	auipc	ra,0x0
    80003dac:	93a080e7          	jalr	-1734(ra) # 800036e2 <bfree>
      ip->addrs[i] = 0;
    80003db0:	0004a023          	sw	zero,0(s1)
    80003db4:	b7dd                	j	80003d9a <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003db6:	0809a583          	lw	a1,128(s3)
    80003dba:	ed99                	bnez	a1,80003dd8 <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003dbc:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003dc0:	854e                	mv	a0,s3
    80003dc2:	00000097          	auipc	ra,0x0
    80003dc6:	de0080e7          	jalr	-544(ra) # 80003ba2 <iupdate>
}
    80003dca:	70a2                	ld	ra,40(sp)
    80003dcc:	7402                	ld	s0,32(sp)
    80003dce:	64e2                	ld	s1,24(sp)
    80003dd0:	6942                	ld	s2,16(sp)
    80003dd2:	69a2                	ld	s3,8(sp)
    80003dd4:	6145                	addi	sp,sp,48
    80003dd6:	8082                	ret
    80003dd8:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003dda:	0009a503          	lw	a0,0(s3)
    80003dde:	fffff097          	auipc	ra,0xfffff
    80003de2:	6c4080e7          	jalr	1732(ra) # 800034a2 <bread>
    80003de6:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003de8:	05850493          	addi	s1,a0,88
    80003dec:	45850913          	addi	s2,a0,1112
    80003df0:	a021                	j	80003df8 <itrunc+0x78>
    80003df2:	0491                	addi	s1,s1,4
    80003df4:	01248b63          	beq	s1,s2,80003e0a <itrunc+0x8a>
      if(a[j])
    80003df8:	408c                	lw	a1,0(s1)
    80003dfa:	dde5                	beqz	a1,80003df2 <itrunc+0x72>
        bfree(ip->dev, a[j]);
    80003dfc:	0009a503          	lw	a0,0(s3)
    80003e00:	00000097          	auipc	ra,0x0
    80003e04:	8e2080e7          	jalr	-1822(ra) # 800036e2 <bfree>
    80003e08:	b7ed                	j	80003df2 <itrunc+0x72>
    brelse(bp);
    80003e0a:	8552                	mv	a0,s4
    80003e0c:	fffff097          	auipc	ra,0xfffff
    80003e10:	7c6080e7          	jalr	1990(ra) # 800035d2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003e14:	0809a583          	lw	a1,128(s3)
    80003e18:	0009a503          	lw	a0,0(s3)
    80003e1c:	00000097          	auipc	ra,0x0
    80003e20:	8c6080e7          	jalr	-1850(ra) # 800036e2 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003e24:	0809a023          	sw	zero,128(s3)
    80003e28:	6a02                	ld	s4,0(sp)
    80003e2a:	bf49                	j	80003dbc <itrunc+0x3c>

0000000080003e2c <iput>:
{
    80003e2c:	1101                	addi	sp,sp,-32
    80003e2e:	ec06                	sd	ra,24(sp)
    80003e30:	e822                	sd	s0,16(sp)
    80003e32:	e426                	sd	s1,8(sp)
    80003e34:	1000                	addi	s0,sp,32
    80003e36:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e38:	00020517          	auipc	a0,0x20
    80003e3c:	19050513          	addi	a0,a0,400 # 80023fc8 <itable>
    80003e40:	ffffd097          	auipc	ra,0xffffd
    80003e44:	e14080e7          	jalr	-492(ra) # 80000c54 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e48:	4498                	lw	a4,8(s1)
    80003e4a:	4785                	li	a5,1
    80003e4c:	02f70263          	beq	a4,a5,80003e70 <iput+0x44>
  ip->ref--;
    80003e50:	449c                	lw	a5,8(s1)
    80003e52:	37fd                	addiw	a5,a5,-1
    80003e54:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e56:	00020517          	auipc	a0,0x20
    80003e5a:	17250513          	addi	a0,a0,370 # 80023fc8 <itable>
    80003e5e:	ffffd097          	auipc	ra,0xffffd
    80003e62:	ea6080e7          	jalr	-346(ra) # 80000d04 <release>
}
    80003e66:	60e2                	ld	ra,24(sp)
    80003e68:	6442                	ld	s0,16(sp)
    80003e6a:	64a2                	ld	s1,8(sp)
    80003e6c:	6105                	addi	sp,sp,32
    80003e6e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e70:	40bc                	lw	a5,64(s1)
    80003e72:	dff9                	beqz	a5,80003e50 <iput+0x24>
    80003e74:	04a49783          	lh	a5,74(s1)
    80003e78:	ffe1                	bnez	a5,80003e50 <iput+0x24>
    80003e7a:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003e7c:	01048793          	addi	a5,s1,16
    80003e80:	893e                	mv	s2,a5
    80003e82:	853e                	mv	a0,a5
    80003e84:	00001097          	auipc	ra,0x1
    80003e88:	af0080e7          	jalr	-1296(ra) # 80004974 <acquiresleep>
    release(&itable.lock);
    80003e8c:	00020517          	auipc	a0,0x20
    80003e90:	13c50513          	addi	a0,a0,316 # 80023fc8 <itable>
    80003e94:	ffffd097          	auipc	ra,0xffffd
    80003e98:	e70080e7          	jalr	-400(ra) # 80000d04 <release>
    itrunc(ip);
    80003e9c:	8526                	mv	a0,s1
    80003e9e:	00000097          	auipc	ra,0x0
    80003ea2:	ee2080e7          	jalr	-286(ra) # 80003d80 <itrunc>
    ip->type = 0;
    80003ea6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003eaa:	8526                	mv	a0,s1
    80003eac:	00000097          	auipc	ra,0x0
    80003eb0:	cf6080e7          	jalr	-778(ra) # 80003ba2 <iupdate>
    ip->valid = 0;
    80003eb4:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003eb8:	854a                	mv	a0,s2
    80003eba:	00001097          	auipc	ra,0x1
    80003ebe:	b10080e7          	jalr	-1264(ra) # 800049ca <releasesleep>
    acquire(&itable.lock);
    80003ec2:	00020517          	auipc	a0,0x20
    80003ec6:	10650513          	addi	a0,a0,262 # 80023fc8 <itable>
    80003eca:	ffffd097          	auipc	ra,0xffffd
    80003ece:	d8a080e7          	jalr	-630(ra) # 80000c54 <acquire>
    80003ed2:	6902                	ld	s2,0(sp)
    80003ed4:	bfb5                	j	80003e50 <iput+0x24>

0000000080003ed6 <iunlockput>:
{
    80003ed6:	1101                	addi	sp,sp,-32
    80003ed8:	ec06                	sd	ra,24(sp)
    80003eda:	e822                	sd	s0,16(sp)
    80003edc:	e426                	sd	s1,8(sp)
    80003ede:	1000                	addi	s0,sp,32
    80003ee0:	84aa                	mv	s1,a0
  iunlock(ip);
    80003ee2:	00000097          	auipc	ra,0x0
    80003ee6:	e52080e7          	jalr	-430(ra) # 80003d34 <iunlock>
  iput(ip);
    80003eea:	8526                	mv	a0,s1
    80003eec:	00000097          	auipc	ra,0x0
    80003ef0:	f40080e7          	jalr	-192(ra) # 80003e2c <iput>
}
    80003ef4:	60e2                	ld	ra,24(sp)
    80003ef6:	6442                	ld	s0,16(sp)
    80003ef8:	64a2                	ld	s1,8(sp)
    80003efa:	6105                	addi	sp,sp,32
    80003efc:	8082                	ret

0000000080003efe <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003efe:	1141                	addi	sp,sp,-16
    80003f00:	e406                	sd	ra,8(sp)
    80003f02:	e022                	sd	s0,0(sp)
    80003f04:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003f06:	411c                	lw	a5,0(a0)
    80003f08:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003f0a:	415c                	lw	a5,4(a0)
    80003f0c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003f0e:	04451783          	lh	a5,68(a0)
    80003f12:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003f16:	04a51783          	lh	a5,74(a0)
    80003f1a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003f1e:	04c56783          	lwu	a5,76(a0)
    80003f22:	e99c                	sd	a5,16(a1)
}
    80003f24:	60a2                	ld	ra,8(sp)
    80003f26:	6402                	ld	s0,0(sp)
    80003f28:	0141                	addi	sp,sp,16
    80003f2a:	8082                	ret

0000000080003f2c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f2c:	457c                	lw	a5,76(a0)
    80003f2e:	0ed7ea63          	bltu	a5,a3,80004022 <readi+0xf6>
{
    80003f32:	7159                	addi	sp,sp,-112
    80003f34:	f486                	sd	ra,104(sp)
    80003f36:	f0a2                	sd	s0,96(sp)
    80003f38:	eca6                	sd	s1,88(sp)
    80003f3a:	fc56                	sd	s5,56(sp)
    80003f3c:	f85a                	sd	s6,48(sp)
    80003f3e:	f45e                	sd	s7,40(sp)
    80003f40:	ec66                	sd	s9,24(sp)
    80003f42:	1880                	addi	s0,sp,112
    80003f44:	8baa                	mv	s7,a0
    80003f46:	8cae                	mv	s9,a1
    80003f48:	8ab2                	mv	s5,a2
    80003f4a:	84b6                	mv	s1,a3
    80003f4c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003f4e:	9f35                	addw	a4,a4,a3
    return 0;
    80003f50:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003f52:	0ad76763          	bltu	a4,a3,80004000 <readi+0xd4>
    80003f56:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003f58:	00e7f463          	bgeu	a5,a4,80003f60 <readi+0x34>
    n = ip->size - off;
    80003f5c:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f60:	0a0b0f63          	beqz	s6,8000401e <readi+0xf2>
    80003f64:	e8ca                	sd	s2,80(sp)
    80003f66:	e0d2                	sd	s4,64(sp)
    80003f68:	f062                	sd	s8,32(sp)
    80003f6a:	e86a                	sd	s10,16(sp)
    80003f6c:	e46e                	sd	s11,8(sp)
    80003f6e:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f70:	40000d93          	li	s11,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003f74:	5d7d                	li	s10,-1
    80003f76:	a82d                	j	80003fb0 <readi+0x84>
    80003f78:	020a1c13          	slli	s8,s4,0x20
    80003f7c:	020c5c13          	srli	s8,s8,0x20
    80003f80:	05890613          	addi	a2,s2,88
    80003f84:	86e2                	mv	a3,s8
    80003f86:	963e                	add	a2,a2,a5
    80003f88:	85d6                	mv	a1,s5
    80003f8a:	8566                	mv	a0,s9
    80003f8c:	ffffe097          	auipc	ra,0xffffe
    80003f90:	6ea080e7          	jalr	1770(ra) # 80002676 <either_copyout>
    80003f94:	05a50963          	beq	a0,s10,80003fe6 <readi+0xba>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003f98:	854a                	mv	a0,s2
    80003f9a:	fffff097          	auipc	ra,0xfffff
    80003f9e:	638080e7          	jalr	1592(ra) # 800035d2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fa2:	013a09bb          	addw	s3,s4,s3
    80003fa6:	009a04bb          	addw	s1,s4,s1
    80003faa:	9ae2                	add	s5,s5,s8
    80003fac:	0769f363          	bgeu	s3,s6,80004012 <readi+0xe6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003fb0:	000ba903          	lw	s2,0(s7)
    80003fb4:	00a4d59b          	srliw	a1,s1,0xa
    80003fb8:	855e                	mv	a0,s7
    80003fba:	00000097          	auipc	ra,0x0
    80003fbe:	8ba080e7          	jalr	-1862(ra) # 80003874 <bmap>
    80003fc2:	85aa                	mv	a1,a0
    80003fc4:	854a                	mv	a0,s2
    80003fc6:	fffff097          	auipc	ra,0xfffff
    80003fca:	4dc080e7          	jalr	1244(ra) # 800034a2 <bread>
    80003fce:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fd0:	3ff4f793          	andi	a5,s1,1023
    80003fd4:	40fd873b          	subw	a4,s11,a5
    80003fd8:	413b06bb          	subw	a3,s6,s3
    80003fdc:	8a3a                	mv	s4,a4
    80003fde:	f8e6fde3          	bgeu	a3,a4,80003f78 <readi+0x4c>
    80003fe2:	8a36                	mv	s4,a3
    80003fe4:	bf51                	j	80003f78 <readi+0x4c>
      brelse(bp);
    80003fe6:	854a                	mv	a0,s2
    80003fe8:	fffff097          	auipc	ra,0xfffff
    80003fec:	5ea080e7          	jalr	1514(ra) # 800035d2 <brelse>
      tot = -1;
    80003ff0:	59fd                	li	s3,-1
      break;
    80003ff2:	6946                	ld	s2,80(sp)
    80003ff4:	6a06                	ld	s4,64(sp)
    80003ff6:	7c02                	ld	s8,32(sp)
    80003ff8:	6d42                	ld	s10,16(sp)
    80003ffa:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003ffc:	854e                	mv	a0,s3
    80003ffe:	69a6                	ld	s3,72(sp)
}
    80004000:	70a6                	ld	ra,104(sp)
    80004002:	7406                	ld	s0,96(sp)
    80004004:	64e6                	ld	s1,88(sp)
    80004006:	7ae2                	ld	s5,56(sp)
    80004008:	7b42                	ld	s6,48(sp)
    8000400a:	7ba2                	ld	s7,40(sp)
    8000400c:	6ce2                	ld	s9,24(sp)
    8000400e:	6165                	addi	sp,sp,112
    80004010:	8082                	ret
    80004012:	6946                	ld	s2,80(sp)
    80004014:	6a06                	ld	s4,64(sp)
    80004016:	7c02                	ld	s8,32(sp)
    80004018:	6d42                	ld	s10,16(sp)
    8000401a:	6da2                	ld	s11,8(sp)
    8000401c:	b7c5                	j	80003ffc <readi+0xd0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000401e:	89da                	mv	s3,s6
    80004020:	bff1                	j	80003ffc <readi+0xd0>
    return 0;
    80004022:	4501                	li	a0,0
}
    80004024:	8082                	ret

0000000080004026 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004026:	457c                	lw	a5,76(a0)
    80004028:	10d7e963          	bltu	a5,a3,8000413a <writei+0x114>
{
    8000402c:	7159                	addi	sp,sp,-112
    8000402e:	f486                	sd	ra,104(sp)
    80004030:	f0a2                	sd	s0,96(sp)
    80004032:	e8ca                	sd	s2,80(sp)
    80004034:	fc56                	sd	s5,56(sp)
    80004036:	f45e                	sd	s7,40(sp)
    80004038:	f062                	sd	s8,32(sp)
    8000403a:	ec66                	sd	s9,24(sp)
    8000403c:	1880                	addi	s0,sp,112
    8000403e:	8baa                	mv	s7,a0
    80004040:	8cae                	mv	s9,a1
    80004042:	8ab2                	mv	s5,a2
    80004044:	8936                	mv	s2,a3
    80004046:	8c3a                	mv	s8,a4
  if(off > ip->size || off + n < off)
    80004048:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000404c:	00043737          	lui	a4,0x43
    80004050:	0ef76763          	bltu	a4,a5,8000413e <writei+0x118>
    80004054:	0ed7e563          	bltu	a5,a3,8000413e <writei+0x118>
    80004058:	e0d2                	sd	s4,64(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000405a:	0c0c0863          	beqz	s8,8000412a <writei+0x104>
    8000405e:	eca6                	sd	s1,88(sp)
    80004060:	e4ce                	sd	s3,72(sp)
    80004062:	f85a                	sd	s6,48(sp)
    80004064:	e86a                	sd	s10,16(sp)
    80004066:	e46e                	sd	s11,8(sp)
    80004068:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000406a:	40000d93          	li	s11,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000406e:	5d7d                	li	s10,-1
    80004070:	a091                	j	800040b4 <writei+0x8e>
    80004072:	02099b13          	slli	s6,s3,0x20
    80004076:	020b5b13          	srli	s6,s6,0x20
    8000407a:	05848513          	addi	a0,s1,88
    8000407e:	86da                	mv	a3,s6
    80004080:	8656                	mv	a2,s5
    80004082:	85e6                	mv	a1,s9
    80004084:	953e                	add	a0,a0,a5
    80004086:	ffffe097          	auipc	ra,0xffffe
    8000408a:	646080e7          	jalr	1606(ra) # 800026cc <either_copyin>
    8000408e:	05a50e63          	beq	a0,s10,800040ea <writei+0xc4>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004092:	8526                	mv	a0,s1
    80004094:	00000097          	auipc	ra,0x0
    80004098:	7c0080e7          	jalr	1984(ra) # 80004854 <log_write>
    brelse(bp);
    8000409c:	8526                	mv	a0,s1
    8000409e:	fffff097          	auipc	ra,0xfffff
    800040a2:	534080e7          	jalr	1332(ra) # 800035d2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040a6:	01498a3b          	addw	s4,s3,s4
    800040aa:	0129893b          	addw	s2,s3,s2
    800040ae:	9ada                	add	s5,s5,s6
    800040b0:	058a7263          	bgeu	s4,s8,800040f4 <writei+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800040b4:	000ba483          	lw	s1,0(s7)
    800040b8:	00a9559b          	srliw	a1,s2,0xa
    800040bc:	855e                	mv	a0,s7
    800040be:	fffff097          	auipc	ra,0xfffff
    800040c2:	7b6080e7          	jalr	1974(ra) # 80003874 <bmap>
    800040c6:	85aa                	mv	a1,a0
    800040c8:	8526                	mv	a0,s1
    800040ca:	fffff097          	auipc	ra,0xfffff
    800040ce:	3d8080e7          	jalr	984(ra) # 800034a2 <bread>
    800040d2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800040d4:	3ff97793          	andi	a5,s2,1023
    800040d8:	40fd873b          	subw	a4,s11,a5
    800040dc:	414c06bb          	subw	a3,s8,s4
    800040e0:	89ba                	mv	s3,a4
    800040e2:	f8e6f8e3          	bgeu	a3,a4,80004072 <writei+0x4c>
    800040e6:	89b6                	mv	s3,a3
    800040e8:	b769                	j	80004072 <writei+0x4c>
      brelse(bp);
    800040ea:	8526                	mv	a0,s1
    800040ec:	fffff097          	auipc	ra,0xfffff
    800040f0:	4e6080e7          	jalr	1254(ra) # 800035d2 <brelse>
  }

  if(off > ip->size)
    800040f4:	04cba783          	lw	a5,76(s7)
    800040f8:	0327fb63          	bgeu	a5,s2,8000412e <writei+0x108>
    ip->size = off;
    800040fc:	052ba623          	sw	s2,76(s7)
    80004100:	64e6                	ld	s1,88(sp)
    80004102:	69a6                	ld	s3,72(sp)
    80004104:	7b42                	ld	s6,48(sp)
    80004106:	6d42                	ld	s10,16(sp)
    80004108:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000410a:	855e                	mv	a0,s7
    8000410c:	00000097          	auipc	ra,0x0
    80004110:	a96080e7          	jalr	-1386(ra) # 80003ba2 <iupdate>

  return tot;
    80004114:	8552                	mv	a0,s4
    80004116:	6a06                	ld	s4,64(sp)
}
    80004118:	70a6                	ld	ra,104(sp)
    8000411a:	7406                	ld	s0,96(sp)
    8000411c:	6946                	ld	s2,80(sp)
    8000411e:	7ae2                	ld	s5,56(sp)
    80004120:	7ba2                	ld	s7,40(sp)
    80004122:	7c02                	ld	s8,32(sp)
    80004124:	6ce2                	ld	s9,24(sp)
    80004126:	6165                	addi	sp,sp,112
    80004128:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000412a:	8a62                	mv	s4,s8
    8000412c:	bff9                	j	8000410a <writei+0xe4>
    8000412e:	64e6                	ld	s1,88(sp)
    80004130:	69a6                	ld	s3,72(sp)
    80004132:	7b42                	ld	s6,48(sp)
    80004134:	6d42                	ld	s10,16(sp)
    80004136:	6da2                	ld	s11,8(sp)
    80004138:	bfc9                	j	8000410a <writei+0xe4>
    return -1;
    8000413a:	557d                	li	a0,-1
}
    8000413c:	8082                	ret
    return -1;
    8000413e:	557d                	li	a0,-1
    80004140:	bfe1                	j	80004118 <writei+0xf2>

0000000080004142 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004142:	1141                	addi	sp,sp,-16
    80004144:	e406                	sd	ra,8(sp)
    80004146:	e022                	sd	s0,0(sp)
    80004148:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000414a:	4639                	li	a2,14
    8000414c:	ffffd097          	auipc	ra,0xffffd
    80004150:	cd8080e7          	jalr	-808(ra) # 80000e24 <strncmp>
}
    80004154:	60a2                	ld	ra,8(sp)
    80004156:	6402                	ld	s0,0(sp)
    80004158:	0141                	addi	sp,sp,16
    8000415a:	8082                	ret

000000008000415c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000415c:	711d                	addi	sp,sp,-96
    8000415e:	ec86                	sd	ra,88(sp)
    80004160:	e8a2                	sd	s0,80(sp)
    80004162:	e4a6                	sd	s1,72(sp)
    80004164:	e0ca                	sd	s2,64(sp)
    80004166:	fc4e                	sd	s3,56(sp)
    80004168:	f852                	sd	s4,48(sp)
    8000416a:	f456                	sd	s5,40(sp)
    8000416c:	f05a                	sd	s6,32(sp)
    8000416e:	ec5e                	sd	s7,24(sp)
    80004170:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004172:	04451703          	lh	a4,68(a0)
    80004176:	4785                	li	a5,1
    80004178:	00f71f63          	bne	a4,a5,80004196 <dirlookup+0x3a>
    8000417c:	892a                	mv	s2,a0
    8000417e:	8aae                	mv	s5,a1
    80004180:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004182:	457c                	lw	a5,76(a0)
    80004184:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004186:	fa040a13          	addi	s4,s0,-96
    8000418a:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    8000418c:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004190:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004192:	e79d                	bnez	a5,800041c0 <dirlookup+0x64>
    80004194:	a88d                	j	80004206 <dirlookup+0xaa>
    panic("dirlookup not DIR");
    80004196:	00004517          	auipc	a0,0x4
    8000419a:	42250513          	addi	a0,a0,1058 # 800085b8 <etext+0x5b8>
    8000419e:	ffffc097          	auipc	ra,0xffffc
    800041a2:	3b8080e7          	jalr	952(ra) # 80000556 <panic>
      panic("dirlookup read");
    800041a6:	00004517          	auipc	a0,0x4
    800041aa:	42a50513          	addi	a0,a0,1066 # 800085d0 <etext+0x5d0>
    800041ae:	ffffc097          	auipc	ra,0xffffc
    800041b2:	3a8080e7          	jalr	936(ra) # 80000556 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041b6:	24c1                	addiw	s1,s1,16
    800041b8:	04c92783          	lw	a5,76(s2)
    800041bc:	04f4f463          	bgeu	s1,a5,80004204 <dirlookup+0xa8>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041c0:	874e                	mv	a4,s3
    800041c2:	86a6                	mv	a3,s1
    800041c4:	8652                	mv	a2,s4
    800041c6:	4581                	li	a1,0
    800041c8:	854a                	mv	a0,s2
    800041ca:	00000097          	auipc	ra,0x0
    800041ce:	d62080e7          	jalr	-670(ra) # 80003f2c <readi>
    800041d2:	fd351ae3          	bne	a0,s3,800041a6 <dirlookup+0x4a>
    if(de.inum == 0)
    800041d6:	fa045783          	lhu	a5,-96(s0)
    800041da:	dff1                	beqz	a5,800041b6 <dirlookup+0x5a>
    if(namecmp(name, de.name) == 0){
    800041dc:	85da                	mv	a1,s6
    800041de:	8556                	mv	a0,s5
    800041e0:	00000097          	auipc	ra,0x0
    800041e4:	f62080e7          	jalr	-158(ra) # 80004142 <namecmp>
    800041e8:	f579                	bnez	a0,800041b6 <dirlookup+0x5a>
      if(poff)
    800041ea:	000b8463          	beqz	s7,800041f2 <dirlookup+0x96>
        *poff = off;
    800041ee:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    800041f2:	fa045583          	lhu	a1,-96(s0)
    800041f6:	00092503          	lw	a0,0(s2)
    800041fa:	fffff097          	auipc	ra,0xfffff
    800041fe:	748080e7          	jalr	1864(ra) # 80003942 <iget>
    80004202:	a011                	j	80004206 <dirlookup+0xaa>
  return 0;
    80004204:	4501                	li	a0,0
}
    80004206:	60e6                	ld	ra,88(sp)
    80004208:	6446                	ld	s0,80(sp)
    8000420a:	64a6                	ld	s1,72(sp)
    8000420c:	6906                	ld	s2,64(sp)
    8000420e:	79e2                	ld	s3,56(sp)
    80004210:	7a42                	ld	s4,48(sp)
    80004212:	7aa2                	ld	s5,40(sp)
    80004214:	7b02                	ld	s6,32(sp)
    80004216:	6be2                	ld	s7,24(sp)
    80004218:	6125                	addi	sp,sp,96
    8000421a:	8082                	ret

000000008000421c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000421c:	711d                	addi	sp,sp,-96
    8000421e:	ec86                	sd	ra,88(sp)
    80004220:	e8a2                	sd	s0,80(sp)
    80004222:	e4a6                	sd	s1,72(sp)
    80004224:	e0ca                	sd	s2,64(sp)
    80004226:	fc4e                	sd	s3,56(sp)
    80004228:	f852                	sd	s4,48(sp)
    8000422a:	f456                	sd	s5,40(sp)
    8000422c:	f05a                	sd	s6,32(sp)
    8000422e:	ec5e                	sd	s7,24(sp)
    80004230:	e862                	sd	s8,16(sp)
    80004232:	e466                	sd	s9,8(sp)
    80004234:	e06a                	sd	s10,0(sp)
    80004236:	1080                	addi	s0,sp,96
    80004238:	84aa                	mv	s1,a0
    8000423a:	8b2e                	mv	s6,a1
    8000423c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000423e:	00054703          	lbu	a4,0(a0)
    80004242:	02f00793          	li	a5,47
    80004246:	02f70363          	beq	a4,a5,8000426c <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000424a:	ffffe097          	auipc	ra,0xffffe
    8000424e:	83c080e7          	jalr	-1988(ra) # 80001a86 <myproc>
    80004252:	15053503          	ld	a0,336(a0)
    80004256:	00000097          	auipc	ra,0x0
    8000425a:	9da080e7          	jalr	-1574(ra) # 80003c30 <idup>
    8000425e:	8a2a                	mv	s4,a0
  while(*path == '/')
    80004260:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80004264:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80004266:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004268:	4b85                	li	s7,1
    8000426a:	a87d                	j	80004328 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    8000426c:	4585                	li	a1,1
    8000426e:	852e                	mv	a0,a1
    80004270:	fffff097          	auipc	ra,0xfffff
    80004274:	6d2080e7          	jalr	1746(ra) # 80003942 <iget>
    80004278:	8a2a                	mv	s4,a0
    8000427a:	b7dd                	j	80004260 <namex+0x44>
      iunlockput(ip);
    8000427c:	8552                	mv	a0,s4
    8000427e:	00000097          	auipc	ra,0x0
    80004282:	c58080e7          	jalr	-936(ra) # 80003ed6 <iunlockput>
      return 0;
    80004286:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004288:	8552                	mv	a0,s4
    8000428a:	60e6                	ld	ra,88(sp)
    8000428c:	6446                	ld	s0,80(sp)
    8000428e:	64a6                	ld	s1,72(sp)
    80004290:	6906                	ld	s2,64(sp)
    80004292:	79e2                	ld	s3,56(sp)
    80004294:	7a42                	ld	s4,48(sp)
    80004296:	7aa2                	ld	s5,40(sp)
    80004298:	7b02                	ld	s6,32(sp)
    8000429a:	6be2                	ld	s7,24(sp)
    8000429c:	6c42                	ld	s8,16(sp)
    8000429e:	6ca2                	ld	s9,8(sp)
    800042a0:	6d02                	ld	s10,0(sp)
    800042a2:	6125                	addi	sp,sp,96
    800042a4:	8082                	ret
      iunlock(ip);
    800042a6:	8552                	mv	a0,s4
    800042a8:	00000097          	auipc	ra,0x0
    800042ac:	a8c080e7          	jalr	-1396(ra) # 80003d34 <iunlock>
      return ip;
    800042b0:	bfe1                	j	80004288 <namex+0x6c>
      iunlockput(ip);
    800042b2:	8552                	mv	a0,s4
    800042b4:	00000097          	auipc	ra,0x0
    800042b8:	c22080e7          	jalr	-990(ra) # 80003ed6 <iunlockput>
      return 0;
    800042bc:	8a4a                	mv	s4,s2
    800042be:	b7e9                	j	80004288 <namex+0x6c>
  len = path - s;
    800042c0:	40990633          	sub	a2,s2,s1
    800042c4:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    800042c8:	09ac5c63          	bge	s8,s10,80004360 <namex+0x144>
    memmove(name, s, DIRSIZ);
    800042cc:	8666                	mv	a2,s9
    800042ce:	85a6                	mv	a1,s1
    800042d0:	8556                	mv	a0,s5
    800042d2:	ffffd097          	auipc	ra,0xffffd
    800042d6:	ada080e7          	jalr	-1318(ra) # 80000dac <memmove>
    800042da:	84ca                	mv	s1,s2
  while(*path == '/')
    800042dc:	0004c783          	lbu	a5,0(s1)
    800042e0:	01379763          	bne	a5,s3,800042ee <namex+0xd2>
    path++;
    800042e4:	0485                	addi	s1,s1,1
  while(*path == '/')
    800042e6:	0004c783          	lbu	a5,0(s1)
    800042ea:	ff378de3          	beq	a5,s3,800042e4 <namex+0xc8>
    ilock(ip);
    800042ee:	8552                	mv	a0,s4
    800042f0:	00000097          	auipc	ra,0x0
    800042f4:	97e080e7          	jalr	-1666(ra) # 80003c6e <ilock>
    if(ip->type != T_DIR){
    800042f8:	044a1783          	lh	a5,68(s4)
    800042fc:	f97790e3          	bne	a5,s7,8000427c <namex+0x60>
    if(nameiparent && *path == '\0'){
    80004300:	000b0563          	beqz	s6,8000430a <namex+0xee>
    80004304:	0004c783          	lbu	a5,0(s1)
    80004308:	dfd9                	beqz	a5,800042a6 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000430a:	4601                	li	a2,0
    8000430c:	85d6                	mv	a1,s5
    8000430e:	8552                	mv	a0,s4
    80004310:	00000097          	auipc	ra,0x0
    80004314:	e4c080e7          	jalr	-436(ra) # 8000415c <dirlookup>
    80004318:	892a                	mv	s2,a0
    8000431a:	dd41                	beqz	a0,800042b2 <namex+0x96>
    iunlockput(ip);
    8000431c:	8552                	mv	a0,s4
    8000431e:	00000097          	auipc	ra,0x0
    80004322:	bb8080e7          	jalr	-1096(ra) # 80003ed6 <iunlockput>
    ip = next;
    80004326:	8a4a                	mv	s4,s2
  while(*path == '/')
    80004328:	0004c783          	lbu	a5,0(s1)
    8000432c:	01379763          	bne	a5,s3,8000433a <namex+0x11e>
    path++;
    80004330:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004332:	0004c783          	lbu	a5,0(s1)
    80004336:	ff378de3          	beq	a5,s3,80004330 <namex+0x114>
  if(*path == 0)
    8000433a:	cf9d                	beqz	a5,80004378 <namex+0x15c>
  while(*path != '/' && *path != 0)
    8000433c:	0004c783          	lbu	a5,0(s1)
    80004340:	fd178713          	addi	a4,a5,-47
    80004344:	cb19                	beqz	a4,8000435a <namex+0x13e>
    80004346:	cb91                	beqz	a5,8000435a <namex+0x13e>
    80004348:	8926                	mv	s2,s1
    path++;
    8000434a:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    8000434c:	00094783          	lbu	a5,0(s2)
    80004350:	fd178713          	addi	a4,a5,-47
    80004354:	d735                	beqz	a4,800042c0 <namex+0xa4>
    80004356:	fbf5                	bnez	a5,8000434a <namex+0x12e>
    80004358:	b7a5                	j	800042c0 <namex+0xa4>
    8000435a:	8926                	mv	s2,s1
  len = path - s;
    8000435c:	4d01                	li	s10,0
    8000435e:	4601                	li	a2,0
    memmove(name, s, len);
    80004360:	2601                	sext.w	a2,a2
    80004362:	85a6                	mv	a1,s1
    80004364:	8556                	mv	a0,s5
    80004366:	ffffd097          	auipc	ra,0xffffd
    8000436a:	a46080e7          	jalr	-1466(ra) # 80000dac <memmove>
    name[len] = 0;
    8000436e:	9d56                	add	s10,s10,s5
    80004370:	000d0023          	sb	zero,0(s10)
    80004374:	84ca                	mv	s1,s2
    80004376:	b79d                	j	800042dc <namex+0xc0>
  if(nameiparent){
    80004378:	f00b08e3          	beqz	s6,80004288 <namex+0x6c>
    iput(ip);
    8000437c:	8552                	mv	a0,s4
    8000437e:	00000097          	auipc	ra,0x0
    80004382:	aae080e7          	jalr	-1362(ra) # 80003e2c <iput>
    return 0;
    80004386:	4a01                	li	s4,0
    80004388:	b701                	j	80004288 <namex+0x6c>

000000008000438a <dirlink>:
{
    8000438a:	715d                	addi	sp,sp,-80
    8000438c:	e486                	sd	ra,72(sp)
    8000438e:	e0a2                	sd	s0,64(sp)
    80004390:	f84a                	sd	s2,48(sp)
    80004392:	ec56                	sd	s5,24(sp)
    80004394:	e85a                	sd	s6,16(sp)
    80004396:	0880                	addi	s0,sp,80
    80004398:	892a                	mv	s2,a0
    8000439a:	8aae                	mv	s5,a1
    8000439c:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000439e:	4601                	li	a2,0
    800043a0:	00000097          	auipc	ra,0x0
    800043a4:	dbc080e7          	jalr	-580(ra) # 8000415c <dirlookup>
    800043a8:	e129                	bnez	a0,800043ea <dirlink+0x60>
    800043aa:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043ac:	04c92483          	lw	s1,76(s2)
    800043b0:	cca9                	beqz	s1,8000440a <dirlink+0x80>
    800043b2:	f44e                	sd	s3,40(sp)
    800043b4:	f052                	sd	s4,32(sp)
    800043b6:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043b8:	fb040a13          	addi	s4,s0,-80
    800043bc:	49c1                	li	s3,16
    800043be:	874e                	mv	a4,s3
    800043c0:	86a6                	mv	a3,s1
    800043c2:	8652                	mv	a2,s4
    800043c4:	4581                	li	a1,0
    800043c6:	854a                	mv	a0,s2
    800043c8:	00000097          	auipc	ra,0x0
    800043cc:	b64080e7          	jalr	-1180(ra) # 80003f2c <readi>
    800043d0:	03351363          	bne	a0,s3,800043f6 <dirlink+0x6c>
    if(de.inum == 0)
    800043d4:	fb045783          	lhu	a5,-80(s0)
    800043d8:	c79d                	beqz	a5,80004406 <dirlink+0x7c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043da:	24c1                	addiw	s1,s1,16
    800043dc:	04c92783          	lw	a5,76(s2)
    800043e0:	fcf4efe3          	bltu	s1,a5,800043be <dirlink+0x34>
    800043e4:	79a2                	ld	s3,40(sp)
    800043e6:	7a02                	ld	s4,32(sp)
    800043e8:	a00d                	j	8000440a <dirlink+0x80>
    iput(ip);
    800043ea:	00000097          	auipc	ra,0x0
    800043ee:	a42080e7          	jalr	-1470(ra) # 80003e2c <iput>
    return -1;
    800043f2:	557d                	li	a0,-1
    800043f4:	a0a9                	j	8000443e <dirlink+0xb4>
      panic("dirlink read");
    800043f6:	00004517          	auipc	a0,0x4
    800043fa:	1ea50513          	addi	a0,a0,490 # 800085e0 <etext+0x5e0>
    800043fe:	ffffc097          	auipc	ra,0xffffc
    80004402:	158080e7          	jalr	344(ra) # 80000556 <panic>
    80004406:	79a2                	ld	s3,40(sp)
    80004408:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    8000440a:	4639                	li	a2,14
    8000440c:	85d6                	mv	a1,s5
    8000440e:	fb240513          	addi	a0,s0,-78
    80004412:	ffffd097          	auipc	ra,0xffffd
    80004416:	a4c080e7          	jalr	-1460(ra) # 80000e5e <strncpy>
  de.inum = inum;
    8000441a:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000441e:	4741                	li	a4,16
    80004420:	86a6                	mv	a3,s1
    80004422:	fb040613          	addi	a2,s0,-80
    80004426:	4581                	li	a1,0
    80004428:	854a                	mv	a0,s2
    8000442a:	00000097          	auipc	ra,0x0
    8000442e:	bfc080e7          	jalr	-1028(ra) # 80004026 <writei>
    80004432:	872a                	mv	a4,a0
    80004434:	47c1                	li	a5,16
  return 0;
    80004436:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004438:	00f71a63          	bne	a4,a5,8000444c <dirlink+0xc2>
    8000443c:	74e2                	ld	s1,56(sp)
}
    8000443e:	60a6                	ld	ra,72(sp)
    80004440:	6406                	ld	s0,64(sp)
    80004442:	7942                	ld	s2,48(sp)
    80004444:	6ae2                	ld	s5,24(sp)
    80004446:	6b42                	ld	s6,16(sp)
    80004448:	6161                	addi	sp,sp,80
    8000444a:	8082                	ret
    8000444c:	f44e                	sd	s3,40(sp)
    8000444e:	f052                	sd	s4,32(sp)
    panic("dirlink");
    80004450:	00004517          	auipc	a0,0x4
    80004454:	29850513          	addi	a0,a0,664 # 800086e8 <etext+0x6e8>
    80004458:	ffffc097          	auipc	ra,0xffffc
    8000445c:	0fe080e7          	jalr	254(ra) # 80000556 <panic>

0000000080004460 <namei>:

struct inode*
namei(char *path)
{
    80004460:	1101                	addi	sp,sp,-32
    80004462:	ec06                	sd	ra,24(sp)
    80004464:	e822                	sd	s0,16(sp)
    80004466:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004468:	fe040613          	addi	a2,s0,-32
    8000446c:	4581                	li	a1,0
    8000446e:	00000097          	auipc	ra,0x0
    80004472:	dae080e7          	jalr	-594(ra) # 8000421c <namex>
}
    80004476:	60e2                	ld	ra,24(sp)
    80004478:	6442                	ld	s0,16(sp)
    8000447a:	6105                	addi	sp,sp,32
    8000447c:	8082                	ret

000000008000447e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000447e:	1141                	addi	sp,sp,-16
    80004480:	e406                	sd	ra,8(sp)
    80004482:	e022                	sd	s0,0(sp)
    80004484:	0800                	addi	s0,sp,16
    80004486:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004488:	4585                	li	a1,1
    8000448a:	00000097          	auipc	ra,0x0
    8000448e:	d92080e7          	jalr	-622(ra) # 8000421c <namex>
}
    80004492:	60a2                	ld	ra,8(sp)
    80004494:	6402                	ld	s0,0(sp)
    80004496:	0141                	addi	sp,sp,16
    80004498:	8082                	ret

000000008000449a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000449a:	1101                	addi	sp,sp,-32
    8000449c:	ec06                	sd	ra,24(sp)
    8000449e:	e822                	sd	s0,16(sp)
    800044a0:	e426                	sd	s1,8(sp)
    800044a2:	e04a                	sd	s2,0(sp)
    800044a4:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800044a6:	00021917          	auipc	s2,0x21
    800044aa:	5ca90913          	addi	s2,s2,1482 # 80025a70 <log>
    800044ae:	01892583          	lw	a1,24(s2)
    800044b2:	02892503          	lw	a0,40(s2)
    800044b6:	fffff097          	auipc	ra,0xfffff
    800044ba:	fec080e7          	jalr	-20(ra) # 800034a2 <bread>
    800044be:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800044c0:	02c92603          	lw	a2,44(s2)
    800044c4:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800044c6:	00c05f63          	blez	a2,800044e4 <write_head+0x4a>
    800044ca:	00021717          	auipc	a4,0x21
    800044ce:	5d670713          	addi	a4,a4,1494 # 80025aa0 <log+0x30>
    800044d2:	87aa                	mv	a5,a0
    800044d4:	060a                	slli	a2,a2,0x2
    800044d6:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800044d8:	4314                	lw	a3,0(a4)
    800044da:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800044dc:	0711                	addi	a4,a4,4
    800044de:	0791                	addi	a5,a5,4
    800044e0:	fec79ce3          	bne	a5,a2,800044d8 <write_head+0x3e>
  }
  bwrite(buf);
    800044e4:	8526                	mv	a0,s1
    800044e6:	fffff097          	auipc	ra,0xfffff
    800044ea:	0ae080e7          	jalr	174(ra) # 80003594 <bwrite>
  brelse(buf);
    800044ee:	8526                	mv	a0,s1
    800044f0:	fffff097          	auipc	ra,0xfffff
    800044f4:	0e2080e7          	jalr	226(ra) # 800035d2 <brelse>
}
    800044f8:	60e2                	ld	ra,24(sp)
    800044fa:	6442                	ld	s0,16(sp)
    800044fc:	64a2                	ld	s1,8(sp)
    800044fe:	6902                	ld	s2,0(sp)
    80004500:	6105                	addi	sp,sp,32
    80004502:	8082                	ret

0000000080004504 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004504:	00021797          	auipc	a5,0x21
    80004508:	5987a783          	lw	a5,1432(a5) # 80025a9c <log+0x2c>
    8000450c:	0cf05063          	blez	a5,800045cc <install_trans+0xc8>
{
    80004510:	715d                	addi	sp,sp,-80
    80004512:	e486                	sd	ra,72(sp)
    80004514:	e0a2                	sd	s0,64(sp)
    80004516:	fc26                	sd	s1,56(sp)
    80004518:	f84a                	sd	s2,48(sp)
    8000451a:	f44e                	sd	s3,40(sp)
    8000451c:	f052                	sd	s4,32(sp)
    8000451e:	ec56                	sd	s5,24(sp)
    80004520:	e85a                	sd	s6,16(sp)
    80004522:	e45e                	sd	s7,8(sp)
    80004524:	0880                	addi	s0,sp,80
    80004526:	8b2a                	mv	s6,a0
    80004528:	00021a97          	auipc	s5,0x21
    8000452c:	578a8a93          	addi	s5,s5,1400 # 80025aa0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004530:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004532:	00021997          	auipc	s3,0x21
    80004536:	53e98993          	addi	s3,s3,1342 # 80025a70 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000453a:	40000b93          	li	s7,1024
    8000453e:	a00d                	j	80004560 <install_trans+0x5c>
    brelse(lbuf);
    80004540:	854a                	mv	a0,s2
    80004542:	fffff097          	auipc	ra,0xfffff
    80004546:	090080e7          	jalr	144(ra) # 800035d2 <brelse>
    brelse(dbuf);
    8000454a:	8526                	mv	a0,s1
    8000454c:	fffff097          	auipc	ra,0xfffff
    80004550:	086080e7          	jalr	134(ra) # 800035d2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004554:	2a05                	addiw	s4,s4,1
    80004556:	0a91                	addi	s5,s5,4
    80004558:	02c9a783          	lw	a5,44(s3)
    8000455c:	04fa5d63          	bge	s4,a5,800045b6 <install_trans+0xb2>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004560:	0189a583          	lw	a1,24(s3)
    80004564:	014585bb          	addw	a1,a1,s4
    80004568:	2585                	addiw	a1,a1,1
    8000456a:	0289a503          	lw	a0,40(s3)
    8000456e:	fffff097          	auipc	ra,0xfffff
    80004572:	f34080e7          	jalr	-204(ra) # 800034a2 <bread>
    80004576:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004578:	000aa583          	lw	a1,0(s5)
    8000457c:	0289a503          	lw	a0,40(s3)
    80004580:	fffff097          	auipc	ra,0xfffff
    80004584:	f22080e7          	jalr	-222(ra) # 800034a2 <bread>
    80004588:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000458a:	865e                	mv	a2,s7
    8000458c:	05890593          	addi	a1,s2,88
    80004590:	05850513          	addi	a0,a0,88
    80004594:	ffffd097          	auipc	ra,0xffffd
    80004598:	818080e7          	jalr	-2024(ra) # 80000dac <memmove>
    bwrite(dbuf);  // write dst to disk
    8000459c:	8526                	mv	a0,s1
    8000459e:	fffff097          	auipc	ra,0xfffff
    800045a2:	ff6080e7          	jalr	-10(ra) # 80003594 <bwrite>
    if(recovering == 0)
    800045a6:	f80b1de3          	bnez	s6,80004540 <install_trans+0x3c>
      bunpin(dbuf);
    800045aa:	8526                	mv	a0,s1
    800045ac:	fffff097          	auipc	ra,0xfffff
    800045b0:	0fa080e7          	jalr	250(ra) # 800036a6 <bunpin>
    800045b4:	b771                	j	80004540 <install_trans+0x3c>
}
    800045b6:	60a6                	ld	ra,72(sp)
    800045b8:	6406                	ld	s0,64(sp)
    800045ba:	74e2                	ld	s1,56(sp)
    800045bc:	7942                	ld	s2,48(sp)
    800045be:	79a2                	ld	s3,40(sp)
    800045c0:	7a02                	ld	s4,32(sp)
    800045c2:	6ae2                	ld	s5,24(sp)
    800045c4:	6b42                	ld	s6,16(sp)
    800045c6:	6ba2                	ld	s7,8(sp)
    800045c8:	6161                	addi	sp,sp,80
    800045ca:	8082                	ret
    800045cc:	8082                	ret

00000000800045ce <initlog>:
{
    800045ce:	7179                	addi	sp,sp,-48
    800045d0:	f406                	sd	ra,40(sp)
    800045d2:	f022                	sd	s0,32(sp)
    800045d4:	ec26                	sd	s1,24(sp)
    800045d6:	e84a                	sd	s2,16(sp)
    800045d8:	e44e                	sd	s3,8(sp)
    800045da:	1800                	addi	s0,sp,48
    800045dc:	892a                	mv	s2,a0
    800045de:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800045e0:	00021497          	auipc	s1,0x21
    800045e4:	49048493          	addi	s1,s1,1168 # 80025a70 <log>
    800045e8:	00004597          	auipc	a1,0x4
    800045ec:	00858593          	addi	a1,a1,8 # 800085f0 <etext+0x5f0>
    800045f0:	8526                	mv	a0,s1
    800045f2:	ffffc097          	auipc	ra,0xffffc
    800045f6:	5c8080e7          	jalr	1480(ra) # 80000bba <initlock>
  log.start = sb->logstart;
    800045fa:	0149a583          	lw	a1,20(s3)
    800045fe:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004600:	0109a783          	lw	a5,16(s3)
    80004604:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004606:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000460a:	854a                	mv	a0,s2
    8000460c:	fffff097          	auipc	ra,0xfffff
    80004610:	e96080e7          	jalr	-362(ra) # 800034a2 <bread>
  log.lh.n = lh->n;
    80004614:	4d30                	lw	a2,88(a0)
    80004616:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004618:	00c05f63          	blez	a2,80004636 <initlog+0x68>
    8000461c:	87aa                	mv	a5,a0
    8000461e:	00021717          	auipc	a4,0x21
    80004622:	48270713          	addi	a4,a4,1154 # 80025aa0 <log+0x30>
    80004626:	060a                	slli	a2,a2,0x2
    80004628:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    8000462a:	4ff4                	lw	a3,92(a5)
    8000462c:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000462e:	0791                	addi	a5,a5,4
    80004630:	0711                	addi	a4,a4,4
    80004632:	fec79ce3          	bne	a5,a2,8000462a <initlog+0x5c>
  brelse(buf);
    80004636:	fffff097          	auipc	ra,0xfffff
    8000463a:	f9c080e7          	jalr	-100(ra) # 800035d2 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000463e:	4505                	li	a0,1
    80004640:	00000097          	auipc	ra,0x0
    80004644:	ec4080e7          	jalr	-316(ra) # 80004504 <install_trans>
  log.lh.n = 0;
    80004648:	00021797          	auipc	a5,0x21
    8000464c:	4407aa23          	sw	zero,1108(a5) # 80025a9c <log+0x2c>
  write_head(); // clear the log
    80004650:	00000097          	auipc	ra,0x0
    80004654:	e4a080e7          	jalr	-438(ra) # 8000449a <write_head>
}
    80004658:	70a2                	ld	ra,40(sp)
    8000465a:	7402                	ld	s0,32(sp)
    8000465c:	64e2                	ld	s1,24(sp)
    8000465e:	6942                	ld	s2,16(sp)
    80004660:	69a2                	ld	s3,8(sp)
    80004662:	6145                	addi	sp,sp,48
    80004664:	8082                	ret

0000000080004666 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004666:	1101                	addi	sp,sp,-32
    80004668:	ec06                	sd	ra,24(sp)
    8000466a:	e822                	sd	s0,16(sp)
    8000466c:	e426                	sd	s1,8(sp)
    8000466e:	e04a                	sd	s2,0(sp)
    80004670:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004672:	00021517          	auipc	a0,0x21
    80004676:	3fe50513          	addi	a0,a0,1022 # 80025a70 <log>
    8000467a:	ffffc097          	auipc	ra,0xffffc
    8000467e:	5da080e7          	jalr	1498(ra) # 80000c54 <acquire>
  while(1){
    if(log.committing){
    80004682:	00021497          	auipc	s1,0x21
    80004686:	3ee48493          	addi	s1,s1,1006 # 80025a70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000468a:	4979                	li	s2,30
    8000468c:	a039                	j	8000469a <begin_op+0x34>
      sleep(&log, &log.lock);
    8000468e:	85a6                	mv	a1,s1
    80004690:	8526                	mv	a0,s1
    80004692:	ffffe097          	auipc	ra,0xffffe
    80004696:	c36080e7          	jalr	-970(ra) # 800022c8 <sleep>
    if(log.committing){
    8000469a:	50dc                	lw	a5,36(s1)
    8000469c:	fbed                	bnez	a5,8000468e <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000469e:	5098                	lw	a4,32(s1)
    800046a0:	2705                	addiw	a4,a4,1
    800046a2:	0027179b          	slliw	a5,a4,0x2
    800046a6:	9fb9                	addw	a5,a5,a4
    800046a8:	0017979b          	slliw	a5,a5,0x1
    800046ac:	54d4                	lw	a3,44(s1)
    800046ae:	9fb5                	addw	a5,a5,a3
    800046b0:	00f95963          	bge	s2,a5,800046c2 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800046b4:	85a6                	mv	a1,s1
    800046b6:	8526                	mv	a0,s1
    800046b8:	ffffe097          	auipc	ra,0xffffe
    800046bc:	c10080e7          	jalr	-1008(ra) # 800022c8 <sleep>
    800046c0:	bfe9                	j	8000469a <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800046c2:	00021797          	auipc	a5,0x21
    800046c6:	3ce7a723          	sw	a4,974(a5) # 80025a90 <log+0x20>
      release(&log.lock);
    800046ca:	00021517          	auipc	a0,0x21
    800046ce:	3a650513          	addi	a0,a0,934 # 80025a70 <log>
    800046d2:	ffffc097          	auipc	ra,0xffffc
    800046d6:	632080e7          	jalr	1586(ra) # 80000d04 <release>
      break;
    }
  }
}
    800046da:	60e2                	ld	ra,24(sp)
    800046dc:	6442                	ld	s0,16(sp)
    800046de:	64a2                	ld	s1,8(sp)
    800046e0:	6902                	ld	s2,0(sp)
    800046e2:	6105                	addi	sp,sp,32
    800046e4:	8082                	ret

00000000800046e6 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800046e6:	7139                	addi	sp,sp,-64
    800046e8:	fc06                	sd	ra,56(sp)
    800046ea:	f822                	sd	s0,48(sp)
    800046ec:	f426                	sd	s1,40(sp)
    800046ee:	f04a                	sd	s2,32(sp)
    800046f0:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800046f2:	00021497          	auipc	s1,0x21
    800046f6:	37e48493          	addi	s1,s1,894 # 80025a70 <log>
    800046fa:	8526                	mv	a0,s1
    800046fc:	ffffc097          	auipc	ra,0xffffc
    80004700:	558080e7          	jalr	1368(ra) # 80000c54 <acquire>
  log.outstanding -= 1;
    80004704:	509c                	lw	a5,32(s1)
    80004706:	37fd                	addiw	a5,a5,-1
    80004708:	893e                	mv	s2,a5
    8000470a:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000470c:	50dc                	lw	a5,36(s1)
    8000470e:	efb1                	bnez	a5,8000476a <end_op+0x84>
    panic("log.committing");
  if(log.outstanding == 0){
    80004710:	06091863          	bnez	s2,80004780 <end_op+0x9a>
    do_commit = 1;
    log.committing = 1;
    80004714:	00021497          	auipc	s1,0x21
    80004718:	35c48493          	addi	s1,s1,860 # 80025a70 <log>
    8000471c:	4785                	li	a5,1
    8000471e:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004720:	8526                	mv	a0,s1
    80004722:	ffffc097          	auipc	ra,0xffffc
    80004726:	5e2080e7          	jalr	1506(ra) # 80000d04 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000472a:	54dc                	lw	a5,44(s1)
    8000472c:	08f04063          	bgtz	a5,800047ac <end_op+0xc6>
    acquire(&log.lock);
    80004730:	00021517          	auipc	a0,0x21
    80004734:	34050513          	addi	a0,a0,832 # 80025a70 <log>
    80004738:	ffffc097          	auipc	ra,0xffffc
    8000473c:	51c080e7          	jalr	1308(ra) # 80000c54 <acquire>
    log.committing = 0;
    80004740:	00021797          	auipc	a5,0x21
    80004744:	3407aa23          	sw	zero,852(a5) # 80025a94 <log+0x24>
    wakeup(&log);
    80004748:	00021517          	auipc	a0,0x21
    8000474c:	32850513          	addi	a0,a0,808 # 80025a70 <log>
    80004750:	ffffe097          	auipc	ra,0xffffe
    80004754:	cfe080e7          	jalr	-770(ra) # 8000244e <wakeup>
    release(&log.lock);
    80004758:	00021517          	auipc	a0,0x21
    8000475c:	31850513          	addi	a0,a0,792 # 80025a70 <log>
    80004760:	ffffc097          	auipc	ra,0xffffc
    80004764:	5a4080e7          	jalr	1444(ra) # 80000d04 <release>
}
    80004768:	a825                	j	800047a0 <end_op+0xba>
    8000476a:	ec4e                	sd	s3,24(sp)
    8000476c:	e852                	sd	s4,16(sp)
    8000476e:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004770:	00004517          	auipc	a0,0x4
    80004774:	e8850513          	addi	a0,a0,-376 # 800085f8 <etext+0x5f8>
    80004778:	ffffc097          	auipc	ra,0xffffc
    8000477c:	dde080e7          	jalr	-546(ra) # 80000556 <panic>
    wakeup(&log);
    80004780:	00021517          	auipc	a0,0x21
    80004784:	2f050513          	addi	a0,a0,752 # 80025a70 <log>
    80004788:	ffffe097          	auipc	ra,0xffffe
    8000478c:	cc6080e7          	jalr	-826(ra) # 8000244e <wakeup>
  release(&log.lock);
    80004790:	00021517          	auipc	a0,0x21
    80004794:	2e050513          	addi	a0,a0,736 # 80025a70 <log>
    80004798:	ffffc097          	auipc	ra,0xffffc
    8000479c:	56c080e7          	jalr	1388(ra) # 80000d04 <release>
}
    800047a0:	70e2                	ld	ra,56(sp)
    800047a2:	7442                	ld	s0,48(sp)
    800047a4:	74a2                	ld	s1,40(sp)
    800047a6:	7902                	ld	s2,32(sp)
    800047a8:	6121                	addi	sp,sp,64
    800047aa:	8082                	ret
    800047ac:	ec4e                	sd	s3,24(sp)
    800047ae:	e852                	sd	s4,16(sp)
    800047b0:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800047b2:	00021a97          	auipc	s5,0x21
    800047b6:	2eea8a93          	addi	s5,s5,750 # 80025aa0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800047ba:	00021a17          	auipc	s4,0x21
    800047be:	2b6a0a13          	addi	s4,s4,694 # 80025a70 <log>
    800047c2:	018a2583          	lw	a1,24(s4)
    800047c6:	012585bb          	addw	a1,a1,s2
    800047ca:	2585                	addiw	a1,a1,1
    800047cc:	028a2503          	lw	a0,40(s4)
    800047d0:	fffff097          	auipc	ra,0xfffff
    800047d4:	cd2080e7          	jalr	-814(ra) # 800034a2 <bread>
    800047d8:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800047da:	000aa583          	lw	a1,0(s5)
    800047de:	028a2503          	lw	a0,40(s4)
    800047e2:	fffff097          	auipc	ra,0xfffff
    800047e6:	cc0080e7          	jalr	-832(ra) # 800034a2 <bread>
    800047ea:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800047ec:	40000613          	li	a2,1024
    800047f0:	05850593          	addi	a1,a0,88
    800047f4:	05848513          	addi	a0,s1,88
    800047f8:	ffffc097          	auipc	ra,0xffffc
    800047fc:	5b4080e7          	jalr	1460(ra) # 80000dac <memmove>
    bwrite(to);  // write the log
    80004800:	8526                	mv	a0,s1
    80004802:	fffff097          	auipc	ra,0xfffff
    80004806:	d92080e7          	jalr	-622(ra) # 80003594 <bwrite>
    brelse(from);
    8000480a:	854e                	mv	a0,s3
    8000480c:	fffff097          	auipc	ra,0xfffff
    80004810:	dc6080e7          	jalr	-570(ra) # 800035d2 <brelse>
    brelse(to);
    80004814:	8526                	mv	a0,s1
    80004816:	fffff097          	auipc	ra,0xfffff
    8000481a:	dbc080e7          	jalr	-580(ra) # 800035d2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000481e:	2905                	addiw	s2,s2,1
    80004820:	0a91                	addi	s5,s5,4
    80004822:	02ca2783          	lw	a5,44(s4)
    80004826:	f8f94ee3          	blt	s2,a5,800047c2 <end_op+0xdc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000482a:	00000097          	auipc	ra,0x0
    8000482e:	c70080e7          	jalr	-912(ra) # 8000449a <write_head>
    install_trans(0); // Now install writes to home locations
    80004832:	4501                	li	a0,0
    80004834:	00000097          	auipc	ra,0x0
    80004838:	cd0080e7          	jalr	-816(ra) # 80004504 <install_trans>
    log.lh.n = 0;
    8000483c:	00021797          	auipc	a5,0x21
    80004840:	2607a023          	sw	zero,608(a5) # 80025a9c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004844:	00000097          	auipc	ra,0x0
    80004848:	c56080e7          	jalr	-938(ra) # 8000449a <write_head>
    8000484c:	69e2                	ld	s3,24(sp)
    8000484e:	6a42                	ld	s4,16(sp)
    80004850:	6aa2                	ld	s5,8(sp)
    80004852:	bdf9                	j	80004730 <end_op+0x4a>

0000000080004854 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004854:	1101                	addi	sp,sp,-32
    80004856:	ec06                	sd	ra,24(sp)
    80004858:	e822                	sd	s0,16(sp)
    8000485a:	e426                	sd	s1,8(sp)
    8000485c:	1000                	addi	s0,sp,32
    8000485e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004860:	00021517          	auipc	a0,0x21
    80004864:	21050513          	addi	a0,a0,528 # 80025a70 <log>
    80004868:	ffffc097          	auipc	ra,0xffffc
    8000486c:	3ec080e7          	jalr	1004(ra) # 80000c54 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004870:	00021617          	auipc	a2,0x21
    80004874:	22c62603          	lw	a2,556(a2) # 80025a9c <log+0x2c>
    80004878:	47f5                	li	a5,29
    8000487a:	06c7c663          	blt	a5,a2,800048e6 <log_write+0x92>
    8000487e:	00021797          	auipc	a5,0x21
    80004882:	20e7a783          	lw	a5,526(a5) # 80025a8c <log+0x1c>
    80004886:	37fd                	addiw	a5,a5,-1
    80004888:	04f65f63          	bge	a2,a5,800048e6 <log_write+0x92>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000488c:	00021797          	auipc	a5,0x21
    80004890:	2047a783          	lw	a5,516(a5) # 80025a90 <log+0x20>
    80004894:	06f05163          	blez	a5,800048f6 <log_write+0xa2>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004898:	4781                	li	a5,0
    8000489a:	06c05663          	blez	a2,80004906 <log_write+0xb2>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000489e:	44cc                	lw	a1,12(s1)
    800048a0:	00021717          	auipc	a4,0x21
    800048a4:	20070713          	addi	a4,a4,512 # 80025aa0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800048a8:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800048aa:	4314                	lw	a3,0(a4)
    800048ac:	04b68d63          	beq	a3,a1,80004906 <log_write+0xb2>
  for (i = 0; i < log.lh.n; i++) {
    800048b0:	2785                	addiw	a5,a5,1
    800048b2:	0711                	addi	a4,a4,4
    800048b4:	fef61be3          	bne	a2,a5,800048aa <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800048b8:	060a                	slli	a2,a2,0x2
    800048ba:	02060613          	addi	a2,a2,32
    800048be:	00021797          	auipc	a5,0x21
    800048c2:	1b278793          	addi	a5,a5,434 # 80025a70 <log>
    800048c6:	97b2                	add	a5,a5,a2
    800048c8:	44d8                	lw	a4,12(s1)
    800048ca:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800048cc:	8526                	mv	a0,s1
    800048ce:	fffff097          	auipc	ra,0xfffff
    800048d2:	d9c080e7          	jalr	-612(ra) # 8000366a <bpin>
    log.lh.n++;
    800048d6:	00021717          	auipc	a4,0x21
    800048da:	19a70713          	addi	a4,a4,410 # 80025a70 <log>
    800048de:	575c                	lw	a5,44(a4)
    800048e0:	2785                	addiw	a5,a5,1
    800048e2:	d75c                	sw	a5,44(a4)
    800048e4:	a835                	j	80004920 <log_write+0xcc>
    panic("too big a transaction");
    800048e6:	00004517          	auipc	a0,0x4
    800048ea:	d2250513          	addi	a0,a0,-734 # 80008608 <etext+0x608>
    800048ee:	ffffc097          	auipc	ra,0xffffc
    800048f2:	c68080e7          	jalr	-920(ra) # 80000556 <panic>
    panic("log_write outside of trans");
    800048f6:	00004517          	auipc	a0,0x4
    800048fa:	d2a50513          	addi	a0,a0,-726 # 80008620 <etext+0x620>
    800048fe:	ffffc097          	auipc	ra,0xffffc
    80004902:	c58080e7          	jalr	-936(ra) # 80000556 <panic>
  log.lh.block[i] = b->blockno;
    80004906:	00279693          	slli	a3,a5,0x2
    8000490a:	02068693          	addi	a3,a3,32
    8000490e:	00021717          	auipc	a4,0x21
    80004912:	16270713          	addi	a4,a4,354 # 80025a70 <log>
    80004916:	9736                	add	a4,a4,a3
    80004918:	44d4                	lw	a3,12(s1)
    8000491a:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000491c:	faf608e3          	beq	a2,a5,800048cc <log_write+0x78>
  }
  release(&log.lock);
    80004920:	00021517          	auipc	a0,0x21
    80004924:	15050513          	addi	a0,a0,336 # 80025a70 <log>
    80004928:	ffffc097          	auipc	ra,0xffffc
    8000492c:	3dc080e7          	jalr	988(ra) # 80000d04 <release>
}
    80004930:	60e2                	ld	ra,24(sp)
    80004932:	6442                	ld	s0,16(sp)
    80004934:	64a2                	ld	s1,8(sp)
    80004936:	6105                	addi	sp,sp,32
    80004938:	8082                	ret

000000008000493a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000493a:	1101                	addi	sp,sp,-32
    8000493c:	ec06                	sd	ra,24(sp)
    8000493e:	e822                	sd	s0,16(sp)
    80004940:	e426                	sd	s1,8(sp)
    80004942:	e04a                	sd	s2,0(sp)
    80004944:	1000                	addi	s0,sp,32
    80004946:	84aa                	mv	s1,a0
    80004948:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000494a:	00004597          	auipc	a1,0x4
    8000494e:	cf658593          	addi	a1,a1,-778 # 80008640 <etext+0x640>
    80004952:	0521                	addi	a0,a0,8
    80004954:	ffffc097          	auipc	ra,0xffffc
    80004958:	266080e7          	jalr	614(ra) # 80000bba <initlock>
  lk->name = name;
    8000495c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004960:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004964:	0204a423          	sw	zero,40(s1)
}
    80004968:	60e2                	ld	ra,24(sp)
    8000496a:	6442                	ld	s0,16(sp)
    8000496c:	64a2                	ld	s1,8(sp)
    8000496e:	6902                	ld	s2,0(sp)
    80004970:	6105                	addi	sp,sp,32
    80004972:	8082                	ret

0000000080004974 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004974:	1101                	addi	sp,sp,-32
    80004976:	ec06                	sd	ra,24(sp)
    80004978:	e822                	sd	s0,16(sp)
    8000497a:	e426                	sd	s1,8(sp)
    8000497c:	e04a                	sd	s2,0(sp)
    8000497e:	1000                	addi	s0,sp,32
    80004980:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004982:	00850913          	addi	s2,a0,8
    80004986:	854a                	mv	a0,s2
    80004988:	ffffc097          	auipc	ra,0xffffc
    8000498c:	2cc080e7          	jalr	716(ra) # 80000c54 <acquire>
  while (lk->locked) {
    80004990:	409c                	lw	a5,0(s1)
    80004992:	cb89                	beqz	a5,800049a4 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004994:	85ca                	mv	a1,s2
    80004996:	8526                	mv	a0,s1
    80004998:	ffffe097          	auipc	ra,0xffffe
    8000499c:	930080e7          	jalr	-1744(ra) # 800022c8 <sleep>
  while (lk->locked) {
    800049a0:	409c                	lw	a5,0(s1)
    800049a2:	fbed                	bnez	a5,80004994 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800049a4:	4785                	li	a5,1
    800049a6:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800049a8:	ffffd097          	auipc	ra,0xffffd
    800049ac:	0de080e7          	jalr	222(ra) # 80001a86 <myproc>
    800049b0:	591c                	lw	a5,48(a0)
    800049b2:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800049b4:	854a                	mv	a0,s2
    800049b6:	ffffc097          	auipc	ra,0xffffc
    800049ba:	34e080e7          	jalr	846(ra) # 80000d04 <release>
}
    800049be:	60e2                	ld	ra,24(sp)
    800049c0:	6442                	ld	s0,16(sp)
    800049c2:	64a2                	ld	s1,8(sp)
    800049c4:	6902                	ld	s2,0(sp)
    800049c6:	6105                	addi	sp,sp,32
    800049c8:	8082                	ret

00000000800049ca <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800049ca:	1101                	addi	sp,sp,-32
    800049cc:	ec06                	sd	ra,24(sp)
    800049ce:	e822                	sd	s0,16(sp)
    800049d0:	e426                	sd	s1,8(sp)
    800049d2:	e04a                	sd	s2,0(sp)
    800049d4:	1000                	addi	s0,sp,32
    800049d6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800049d8:	00850913          	addi	s2,a0,8
    800049dc:	854a                	mv	a0,s2
    800049de:	ffffc097          	auipc	ra,0xffffc
    800049e2:	276080e7          	jalr	630(ra) # 80000c54 <acquire>
  lk->locked = 0;
    800049e6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800049ea:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800049ee:	8526                	mv	a0,s1
    800049f0:	ffffe097          	auipc	ra,0xffffe
    800049f4:	a5e080e7          	jalr	-1442(ra) # 8000244e <wakeup>
  release(&lk->lk);
    800049f8:	854a                	mv	a0,s2
    800049fa:	ffffc097          	auipc	ra,0xffffc
    800049fe:	30a080e7          	jalr	778(ra) # 80000d04 <release>
}
    80004a02:	60e2                	ld	ra,24(sp)
    80004a04:	6442                	ld	s0,16(sp)
    80004a06:	64a2                	ld	s1,8(sp)
    80004a08:	6902                	ld	s2,0(sp)
    80004a0a:	6105                	addi	sp,sp,32
    80004a0c:	8082                	ret

0000000080004a0e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004a0e:	7179                	addi	sp,sp,-48
    80004a10:	f406                	sd	ra,40(sp)
    80004a12:	f022                	sd	s0,32(sp)
    80004a14:	ec26                	sd	s1,24(sp)
    80004a16:	e84a                	sd	s2,16(sp)
    80004a18:	1800                	addi	s0,sp,48
    80004a1a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004a1c:	00850913          	addi	s2,a0,8
    80004a20:	854a                	mv	a0,s2
    80004a22:	ffffc097          	auipc	ra,0xffffc
    80004a26:	232080e7          	jalr	562(ra) # 80000c54 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a2a:	409c                	lw	a5,0(s1)
    80004a2c:	ef91                	bnez	a5,80004a48 <holdingsleep+0x3a>
    80004a2e:	4481                	li	s1,0
  release(&lk->lk);
    80004a30:	854a                	mv	a0,s2
    80004a32:	ffffc097          	auipc	ra,0xffffc
    80004a36:	2d2080e7          	jalr	722(ra) # 80000d04 <release>
  return r;
}
    80004a3a:	8526                	mv	a0,s1
    80004a3c:	70a2                	ld	ra,40(sp)
    80004a3e:	7402                	ld	s0,32(sp)
    80004a40:	64e2                	ld	s1,24(sp)
    80004a42:	6942                	ld	s2,16(sp)
    80004a44:	6145                	addi	sp,sp,48
    80004a46:	8082                	ret
    80004a48:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a4a:	0284a983          	lw	s3,40(s1)
    80004a4e:	ffffd097          	auipc	ra,0xffffd
    80004a52:	038080e7          	jalr	56(ra) # 80001a86 <myproc>
    80004a56:	5904                	lw	s1,48(a0)
    80004a58:	413484b3          	sub	s1,s1,s3
    80004a5c:	0014b493          	seqz	s1,s1
    80004a60:	69a2                	ld	s3,8(sp)
    80004a62:	b7f9                	j	80004a30 <holdingsleep+0x22>

0000000080004a64 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004a64:	1141                	addi	sp,sp,-16
    80004a66:	e406                	sd	ra,8(sp)
    80004a68:	e022                	sd	s0,0(sp)
    80004a6a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004a6c:	00004597          	auipc	a1,0x4
    80004a70:	be458593          	addi	a1,a1,-1052 # 80008650 <etext+0x650>
    80004a74:	00021517          	auipc	a0,0x21
    80004a78:	14450513          	addi	a0,a0,324 # 80025bb8 <ftable>
    80004a7c:	ffffc097          	auipc	ra,0xffffc
    80004a80:	13e080e7          	jalr	318(ra) # 80000bba <initlock>
}
    80004a84:	60a2                	ld	ra,8(sp)
    80004a86:	6402                	ld	s0,0(sp)
    80004a88:	0141                	addi	sp,sp,16
    80004a8a:	8082                	ret

0000000080004a8c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004a8c:	1101                	addi	sp,sp,-32
    80004a8e:	ec06                	sd	ra,24(sp)
    80004a90:	e822                	sd	s0,16(sp)
    80004a92:	e426                	sd	s1,8(sp)
    80004a94:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004a96:	00021517          	auipc	a0,0x21
    80004a9a:	12250513          	addi	a0,a0,290 # 80025bb8 <ftable>
    80004a9e:	ffffc097          	auipc	ra,0xffffc
    80004aa2:	1b6080e7          	jalr	438(ra) # 80000c54 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004aa6:	00021497          	auipc	s1,0x21
    80004aaa:	12a48493          	addi	s1,s1,298 # 80025bd0 <ftable+0x18>
    80004aae:	00022717          	auipc	a4,0x22
    80004ab2:	0c270713          	addi	a4,a4,194 # 80026b70 <ftable+0xfb8>
    if(f->ref == 0){
    80004ab6:	40dc                	lw	a5,4(s1)
    80004ab8:	cf99                	beqz	a5,80004ad6 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004aba:	02848493          	addi	s1,s1,40
    80004abe:	fee49ce3          	bne	s1,a4,80004ab6 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004ac2:	00021517          	auipc	a0,0x21
    80004ac6:	0f650513          	addi	a0,a0,246 # 80025bb8 <ftable>
    80004aca:	ffffc097          	auipc	ra,0xffffc
    80004ace:	23a080e7          	jalr	570(ra) # 80000d04 <release>
  return 0;
    80004ad2:	4481                	li	s1,0
    80004ad4:	a819                	j	80004aea <filealloc+0x5e>
      f->ref = 1;
    80004ad6:	4785                	li	a5,1
    80004ad8:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004ada:	00021517          	auipc	a0,0x21
    80004ade:	0de50513          	addi	a0,a0,222 # 80025bb8 <ftable>
    80004ae2:	ffffc097          	auipc	ra,0xffffc
    80004ae6:	222080e7          	jalr	546(ra) # 80000d04 <release>
}
    80004aea:	8526                	mv	a0,s1
    80004aec:	60e2                	ld	ra,24(sp)
    80004aee:	6442                	ld	s0,16(sp)
    80004af0:	64a2                	ld	s1,8(sp)
    80004af2:	6105                	addi	sp,sp,32
    80004af4:	8082                	ret

0000000080004af6 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004af6:	1101                	addi	sp,sp,-32
    80004af8:	ec06                	sd	ra,24(sp)
    80004afa:	e822                	sd	s0,16(sp)
    80004afc:	e426                	sd	s1,8(sp)
    80004afe:	1000                	addi	s0,sp,32
    80004b00:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004b02:	00021517          	auipc	a0,0x21
    80004b06:	0b650513          	addi	a0,a0,182 # 80025bb8 <ftable>
    80004b0a:	ffffc097          	auipc	ra,0xffffc
    80004b0e:	14a080e7          	jalr	330(ra) # 80000c54 <acquire>
  if(f->ref < 1)
    80004b12:	40dc                	lw	a5,4(s1)
    80004b14:	02f05263          	blez	a5,80004b38 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004b18:	2785                	addiw	a5,a5,1
    80004b1a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004b1c:	00021517          	auipc	a0,0x21
    80004b20:	09c50513          	addi	a0,a0,156 # 80025bb8 <ftable>
    80004b24:	ffffc097          	auipc	ra,0xffffc
    80004b28:	1e0080e7          	jalr	480(ra) # 80000d04 <release>
  return f;
}
    80004b2c:	8526                	mv	a0,s1
    80004b2e:	60e2                	ld	ra,24(sp)
    80004b30:	6442                	ld	s0,16(sp)
    80004b32:	64a2                	ld	s1,8(sp)
    80004b34:	6105                	addi	sp,sp,32
    80004b36:	8082                	ret
    panic("filedup");
    80004b38:	00004517          	auipc	a0,0x4
    80004b3c:	b2050513          	addi	a0,a0,-1248 # 80008658 <etext+0x658>
    80004b40:	ffffc097          	auipc	ra,0xffffc
    80004b44:	a16080e7          	jalr	-1514(ra) # 80000556 <panic>

0000000080004b48 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004b48:	7139                	addi	sp,sp,-64
    80004b4a:	fc06                	sd	ra,56(sp)
    80004b4c:	f822                	sd	s0,48(sp)
    80004b4e:	f426                	sd	s1,40(sp)
    80004b50:	0080                	addi	s0,sp,64
    80004b52:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004b54:	00021517          	auipc	a0,0x21
    80004b58:	06450513          	addi	a0,a0,100 # 80025bb8 <ftable>
    80004b5c:	ffffc097          	auipc	ra,0xffffc
    80004b60:	0f8080e7          	jalr	248(ra) # 80000c54 <acquire>
  if(f->ref < 1)
    80004b64:	40dc                	lw	a5,4(s1)
    80004b66:	04f05c63          	blez	a5,80004bbe <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    80004b6a:	37fd                	addiw	a5,a5,-1
    80004b6c:	c0dc                	sw	a5,4(s1)
    80004b6e:	06f04463          	bgtz	a5,80004bd6 <fileclose+0x8e>
    80004b72:	f04a                	sd	s2,32(sp)
    80004b74:	ec4e                	sd	s3,24(sp)
    80004b76:	e852                	sd	s4,16(sp)
    80004b78:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004b7a:	0004a903          	lw	s2,0(s1)
    80004b7e:	0094c783          	lbu	a5,9(s1)
    80004b82:	89be                	mv	s3,a5
    80004b84:	689c                	ld	a5,16(s1)
    80004b86:	8a3e                	mv	s4,a5
    80004b88:	6c9c                	ld	a5,24(s1)
    80004b8a:	8abe                	mv	s5,a5
  f->ref = 0;
    80004b8c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004b90:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004b94:	00021517          	auipc	a0,0x21
    80004b98:	02450513          	addi	a0,a0,36 # 80025bb8 <ftable>
    80004b9c:	ffffc097          	auipc	ra,0xffffc
    80004ba0:	168080e7          	jalr	360(ra) # 80000d04 <release>

  if(ff.type == FD_PIPE){
    80004ba4:	4785                	li	a5,1
    80004ba6:	04f90563          	beq	s2,a5,80004bf0 <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004baa:	ffe9079b          	addiw	a5,s2,-2
    80004bae:	4705                	li	a4,1
    80004bb0:	04f77b63          	bgeu	a4,a5,80004c06 <fileclose+0xbe>
    80004bb4:	7902                	ld	s2,32(sp)
    80004bb6:	69e2                	ld	s3,24(sp)
    80004bb8:	6a42                	ld	s4,16(sp)
    80004bba:	6aa2                	ld	s5,8(sp)
    80004bbc:	a02d                	j	80004be6 <fileclose+0x9e>
    80004bbe:	f04a                	sd	s2,32(sp)
    80004bc0:	ec4e                	sd	s3,24(sp)
    80004bc2:	e852                	sd	s4,16(sp)
    80004bc4:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004bc6:	00004517          	auipc	a0,0x4
    80004bca:	a9a50513          	addi	a0,a0,-1382 # 80008660 <etext+0x660>
    80004bce:	ffffc097          	auipc	ra,0xffffc
    80004bd2:	988080e7          	jalr	-1656(ra) # 80000556 <panic>
    release(&ftable.lock);
    80004bd6:	00021517          	auipc	a0,0x21
    80004bda:	fe250513          	addi	a0,a0,-30 # 80025bb8 <ftable>
    80004bde:	ffffc097          	auipc	ra,0xffffc
    80004be2:	126080e7          	jalr	294(ra) # 80000d04 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004be6:	70e2                	ld	ra,56(sp)
    80004be8:	7442                	ld	s0,48(sp)
    80004bea:	74a2                	ld	s1,40(sp)
    80004bec:	6121                	addi	sp,sp,64
    80004bee:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004bf0:	85ce                	mv	a1,s3
    80004bf2:	8552                	mv	a0,s4
    80004bf4:	00000097          	auipc	ra,0x0
    80004bf8:	3b4080e7          	jalr	948(ra) # 80004fa8 <pipeclose>
    80004bfc:	7902                	ld	s2,32(sp)
    80004bfe:	69e2                	ld	s3,24(sp)
    80004c00:	6a42                	ld	s4,16(sp)
    80004c02:	6aa2                	ld	s5,8(sp)
    80004c04:	b7cd                	j	80004be6 <fileclose+0x9e>
    begin_op();
    80004c06:	00000097          	auipc	ra,0x0
    80004c0a:	a60080e7          	jalr	-1440(ra) # 80004666 <begin_op>
    iput(ff.ip);
    80004c0e:	8556                	mv	a0,s5
    80004c10:	fffff097          	auipc	ra,0xfffff
    80004c14:	21c080e7          	jalr	540(ra) # 80003e2c <iput>
    end_op();
    80004c18:	00000097          	auipc	ra,0x0
    80004c1c:	ace080e7          	jalr	-1330(ra) # 800046e6 <end_op>
    80004c20:	7902                	ld	s2,32(sp)
    80004c22:	69e2                	ld	s3,24(sp)
    80004c24:	6a42                	ld	s4,16(sp)
    80004c26:	6aa2                	ld	s5,8(sp)
    80004c28:	bf7d                	j	80004be6 <fileclose+0x9e>

0000000080004c2a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004c2a:	715d                	addi	sp,sp,-80
    80004c2c:	e486                	sd	ra,72(sp)
    80004c2e:	e0a2                	sd	s0,64(sp)
    80004c30:	fc26                	sd	s1,56(sp)
    80004c32:	f052                	sd	s4,32(sp)
    80004c34:	0880                	addi	s0,sp,80
    80004c36:	84aa                	mv	s1,a0
    80004c38:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004c3a:	ffffd097          	auipc	ra,0xffffd
    80004c3e:	e4c080e7          	jalr	-436(ra) # 80001a86 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004c42:	409c                	lw	a5,0(s1)
    80004c44:	37f9                	addiw	a5,a5,-2
    80004c46:	4705                	li	a4,1
    80004c48:	04f76a63          	bltu	a4,a5,80004c9c <filestat+0x72>
    80004c4c:	f84a                	sd	s2,48(sp)
    80004c4e:	f44e                	sd	s3,40(sp)
    80004c50:	89aa                	mv	s3,a0
    ilock(f->ip);
    80004c52:	6c88                	ld	a0,24(s1)
    80004c54:	fffff097          	auipc	ra,0xfffff
    80004c58:	01a080e7          	jalr	26(ra) # 80003c6e <ilock>
    stati(f->ip, &st);
    80004c5c:	fb840913          	addi	s2,s0,-72
    80004c60:	85ca                	mv	a1,s2
    80004c62:	6c88                	ld	a0,24(s1)
    80004c64:	fffff097          	auipc	ra,0xfffff
    80004c68:	29a080e7          	jalr	666(ra) # 80003efe <stati>
    iunlock(f->ip);
    80004c6c:	6c88                	ld	a0,24(s1)
    80004c6e:	fffff097          	auipc	ra,0xfffff
    80004c72:	0c6080e7          	jalr	198(ra) # 80003d34 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004c76:	46e1                	li	a3,24
    80004c78:	864a                	mv	a2,s2
    80004c7a:	85d2                	mv	a1,s4
    80004c7c:	0509b503          	ld	a0,80(s3)
    80004c80:	ffffd097          	auipc	ra,0xffffd
    80004c84:	a8a080e7          	jalr	-1398(ra) # 8000170a <copyout>
    80004c88:	41f5551b          	sraiw	a0,a0,0x1f
    80004c8c:	7942                	ld	s2,48(sp)
    80004c8e:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004c90:	60a6                	ld	ra,72(sp)
    80004c92:	6406                	ld	s0,64(sp)
    80004c94:	74e2                	ld	s1,56(sp)
    80004c96:	7a02                	ld	s4,32(sp)
    80004c98:	6161                	addi	sp,sp,80
    80004c9a:	8082                	ret
  return -1;
    80004c9c:	557d                	li	a0,-1
    80004c9e:	bfcd                	j	80004c90 <filestat+0x66>

0000000080004ca0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004ca0:	7179                	addi	sp,sp,-48
    80004ca2:	f406                	sd	ra,40(sp)
    80004ca4:	f022                	sd	s0,32(sp)
    80004ca6:	e84a                	sd	s2,16(sp)
    80004ca8:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004caa:	00854783          	lbu	a5,8(a0)
    80004cae:	cbc5                	beqz	a5,80004d5e <fileread+0xbe>
    80004cb0:	ec26                	sd	s1,24(sp)
    80004cb2:	e44e                	sd	s3,8(sp)
    80004cb4:	84aa                	mv	s1,a0
    80004cb6:	892e                	mv	s2,a1
    80004cb8:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    80004cba:	411c                	lw	a5,0(a0)
    80004cbc:	4705                	li	a4,1
    80004cbe:	04e78963          	beq	a5,a4,80004d10 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004cc2:	470d                	li	a4,3
    80004cc4:	04e78f63          	beq	a5,a4,80004d22 <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004cc8:	4709                	li	a4,2
    80004cca:	08e79263          	bne	a5,a4,80004d4e <fileread+0xae>
    ilock(f->ip);
    80004cce:	6d08                	ld	a0,24(a0)
    80004cd0:	fffff097          	auipc	ra,0xfffff
    80004cd4:	f9e080e7          	jalr	-98(ra) # 80003c6e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004cd8:	874e                	mv	a4,s3
    80004cda:	5094                	lw	a3,32(s1)
    80004cdc:	864a                	mv	a2,s2
    80004cde:	4585                	li	a1,1
    80004ce0:	6c88                	ld	a0,24(s1)
    80004ce2:	fffff097          	auipc	ra,0xfffff
    80004ce6:	24a080e7          	jalr	586(ra) # 80003f2c <readi>
    80004cea:	892a                	mv	s2,a0
    80004cec:	00a05563          	blez	a0,80004cf6 <fileread+0x56>
      f->off += r;
    80004cf0:	509c                	lw	a5,32(s1)
    80004cf2:	9fa9                	addw	a5,a5,a0
    80004cf4:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004cf6:	6c88                	ld	a0,24(s1)
    80004cf8:	fffff097          	auipc	ra,0xfffff
    80004cfc:	03c080e7          	jalr	60(ra) # 80003d34 <iunlock>
    80004d00:	64e2                	ld	s1,24(sp)
    80004d02:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004d04:	854a                	mv	a0,s2
    80004d06:	70a2                	ld	ra,40(sp)
    80004d08:	7402                	ld	s0,32(sp)
    80004d0a:	6942                	ld	s2,16(sp)
    80004d0c:	6145                	addi	sp,sp,48
    80004d0e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004d10:	6908                	ld	a0,16(a0)
    80004d12:	00000097          	auipc	ra,0x0
    80004d16:	422080e7          	jalr	1058(ra) # 80005134 <piperead>
    80004d1a:	892a                	mv	s2,a0
    80004d1c:	64e2                	ld	s1,24(sp)
    80004d1e:	69a2                	ld	s3,8(sp)
    80004d20:	b7d5                	j	80004d04 <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004d22:	02451783          	lh	a5,36(a0)
    80004d26:	03079693          	slli	a3,a5,0x30
    80004d2a:	92c1                	srli	a3,a3,0x30
    80004d2c:	4725                	li	a4,9
    80004d2e:	02d76b63          	bltu	a4,a3,80004d64 <fileread+0xc4>
    80004d32:	0792                	slli	a5,a5,0x4
    80004d34:	00021717          	auipc	a4,0x21
    80004d38:	de470713          	addi	a4,a4,-540 # 80025b18 <devsw>
    80004d3c:	97ba                	add	a5,a5,a4
    80004d3e:	639c                	ld	a5,0(a5)
    80004d40:	c79d                	beqz	a5,80004d6e <fileread+0xce>
    r = devsw[f->major].read(1, addr, n);
    80004d42:	4505                	li	a0,1
    80004d44:	9782                	jalr	a5
    80004d46:	892a                	mv	s2,a0
    80004d48:	64e2                	ld	s1,24(sp)
    80004d4a:	69a2                	ld	s3,8(sp)
    80004d4c:	bf65                	j	80004d04 <fileread+0x64>
    panic("fileread");
    80004d4e:	00004517          	auipc	a0,0x4
    80004d52:	92250513          	addi	a0,a0,-1758 # 80008670 <etext+0x670>
    80004d56:	ffffc097          	auipc	ra,0xffffc
    80004d5a:	800080e7          	jalr	-2048(ra) # 80000556 <panic>
    return -1;
    80004d5e:	57fd                	li	a5,-1
    80004d60:	893e                	mv	s2,a5
    80004d62:	b74d                	j	80004d04 <fileread+0x64>
      return -1;
    80004d64:	57fd                	li	a5,-1
    80004d66:	893e                	mv	s2,a5
    80004d68:	64e2                	ld	s1,24(sp)
    80004d6a:	69a2                	ld	s3,8(sp)
    80004d6c:	bf61                	j	80004d04 <fileread+0x64>
    80004d6e:	57fd                	li	a5,-1
    80004d70:	893e                	mv	s2,a5
    80004d72:	64e2                	ld	s1,24(sp)
    80004d74:	69a2                	ld	s3,8(sp)
    80004d76:	b779                	j	80004d04 <fileread+0x64>

0000000080004d78 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004d78:	00954783          	lbu	a5,9(a0)
    80004d7c:	12078d63          	beqz	a5,80004eb6 <filewrite+0x13e>
{
    80004d80:	711d                	addi	sp,sp,-96
    80004d82:	ec86                	sd	ra,88(sp)
    80004d84:	e8a2                	sd	s0,80(sp)
    80004d86:	e0ca                	sd	s2,64(sp)
    80004d88:	f456                	sd	s5,40(sp)
    80004d8a:	f05a                	sd	s6,32(sp)
    80004d8c:	1080                	addi	s0,sp,96
    80004d8e:	892a                	mv	s2,a0
    80004d90:	8b2e                	mv	s6,a1
    80004d92:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    80004d94:	411c                	lw	a5,0(a0)
    80004d96:	4705                	li	a4,1
    80004d98:	02e78a63          	beq	a5,a4,80004dcc <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004d9c:	470d                	li	a4,3
    80004d9e:	02e78d63          	beq	a5,a4,80004dd8 <filewrite+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004da2:	4709                	li	a4,2
    80004da4:	0ee79b63          	bne	a5,a4,80004e9a <filewrite+0x122>
    80004da8:	f852                	sd	s4,48(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004daa:	0cc05663          	blez	a2,80004e76 <filewrite+0xfe>
    80004dae:	e4a6                	sd	s1,72(sp)
    80004db0:	fc4e                	sd	s3,56(sp)
    80004db2:	ec5e                	sd	s7,24(sp)
    80004db4:	e862                	sd	s8,16(sp)
    80004db6:	e466                	sd	s9,8(sp)
    int i = 0;
    80004db8:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80004dba:	6b85                	lui	s7,0x1
    80004dbc:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004dc0:	6785                	lui	a5,0x1
    80004dc2:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80004dc6:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004dc8:	4c05                	li	s8,1
    80004dca:	a849                	j	80004e5c <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004dcc:	6908                	ld	a0,16(a0)
    80004dce:	00000097          	auipc	ra,0x0
    80004dd2:	250080e7          	jalr	592(ra) # 8000501e <pipewrite>
    80004dd6:	a85d                	j	80004e8c <filewrite+0x114>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004dd8:	02451783          	lh	a5,36(a0)
    80004ddc:	03079693          	slli	a3,a5,0x30
    80004de0:	92c1                	srli	a3,a3,0x30
    80004de2:	4725                	li	a4,9
    80004de4:	0cd76b63          	bltu	a4,a3,80004eba <filewrite+0x142>
    80004de8:	0792                	slli	a5,a5,0x4
    80004dea:	00021717          	auipc	a4,0x21
    80004dee:	d2e70713          	addi	a4,a4,-722 # 80025b18 <devsw>
    80004df2:	97ba                	add	a5,a5,a4
    80004df4:	679c                	ld	a5,8(a5)
    80004df6:	c7e1                	beqz	a5,80004ebe <filewrite+0x146>
    ret = devsw[f->major].write(1, addr, n);
    80004df8:	4505                	li	a0,1
    80004dfa:	9782                	jalr	a5
    80004dfc:	a841                	j	80004e8c <filewrite+0x114>
      if(n1 > max)
    80004dfe:	2981                	sext.w	s3,s3
      begin_op();
    80004e00:	00000097          	auipc	ra,0x0
    80004e04:	866080e7          	jalr	-1946(ra) # 80004666 <begin_op>
      ilock(f->ip);
    80004e08:	01893503          	ld	a0,24(s2)
    80004e0c:	fffff097          	auipc	ra,0xfffff
    80004e10:	e62080e7          	jalr	-414(ra) # 80003c6e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004e14:	874e                	mv	a4,s3
    80004e16:	02092683          	lw	a3,32(s2)
    80004e1a:	016a0633          	add	a2,s4,s6
    80004e1e:	85e2                	mv	a1,s8
    80004e20:	01893503          	ld	a0,24(s2)
    80004e24:	fffff097          	auipc	ra,0xfffff
    80004e28:	202080e7          	jalr	514(ra) # 80004026 <writei>
    80004e2c:	84aa                	mv	s1,a0
    80004e2e:	00a05763          	blez	a0,80004e3c <filewrite+0xc4>
        f->off += r;
    80004e32:	02092783          	lw	a5,32(s2)
    80004e36:	9fa9                	addw	a5,a5,a0
    80004e38:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004e3c:	01893503          	ld	a0,24(s2)
    80004e40:	fffff097          	auipc	ra,0xfffff
    80004e44:	ef4080e7          	jalr	-268(ra) # 80003d34 <iunlock>
      end_op();
    80004e48:	00000097          	auipc	ra,0x0
    80004e4c:	89e080e7          	jalr	-1890(ra) # 800046e6 <end_op>

      if(r != n1){
    80004e50:	02999563          	bne	s3,s1,80004e7a <filewrite+0x102>
        // error from writei
        break;
      }
      i += r;
    80004e54:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    80004e58:	015a5963          	bge	s4,s5,80004e6a <filewrite+0xf2>
      int n1 = n - i;
    80004e5c:	414a87bb          	subw	a5,s5,s4
    80004e60:	89be                	mv	s3,a5
      if(n1 > max)
    80004e62:	f8fbdee3          	bge	s7,a5,80004dfe <filewrite+0x86>
    80004e66:	89e6                	mv	s3,s9
    80004e68:	bf59                	j	80004dfe <filewrite+0x86>
    80004e6a:	64a6                	ld	s1,72(sp)
    80004e6c:	79e2                	ld	s3,56(sp)
    80004e6e:	6be2                	ld	s7,24(sp)
    80004e70:	6c42                	ld	s8,16(sp)
    80004e72:	6ca2                	ld	s9,8(sp)
    80004e74:	a801                	j	80004e84 <filewrite+0x10c>
    int i = 0;
    80004e76:	4a01                	li	s4,0
    80004e78:	a031                	j	80004e84 <filewrite+0x10c>
    80004e7a:	64a6                	ld	s1,72(sp)
    80004e7c:	79e2                	ld	s3,56(sp)
    80004e7e:	6be2                	ld	s7,24(sp)
    80004e80:	6c42                	ld	s8,16(sp)
    80004e82:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004e84:	034a9f63          	bne	s5,s4,80004ec2 <filewrite+0x14a>
    80004e88:	8556                	mv	a0,s5
    80004e8a:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004e8c:	60e6                	ld	ra,88(sp)
    80004e8e:	6446                	ld	s0,80(sp)
    80004e90:	6906                	ld	s2,64(sp)
    80004e92:	7aa2                	ld	s5,40(sp)
    80004e94:	7b02                	ld	s6,32(sp)
    80004e96:	6125                	addi	sp,sp,96
    80004e98:	8082                	ret
    80004e9a:	e4a6                	sd	s1,72(sp)
    80004e9c:	fc4e                	sd	s3,56(sp)
    80004e9e:	f852                	sd	s4,48(sp)
    80004ea0:	ec5e                	sd	s7,24(sp)
    80004ea2:	e862                	sd	s8,16(sp)
    80004ea4:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004ea6:	00003517          	auipc	a0,0x3
    80004eaa:	7da50513          	addi	a0,a0,2010 # 80008680 <etext+0x680>
    80004eae:	ffffb097          	auipc	ra,0xffffb
    80004eb2:	6a8080e7          	jalr	1704(ra) # 80000556 <panic>
    return -1;
    80004eb6:	557d                	li	a0,-1
}
    80004eb8:	8082                	ret
      return -1;
    80004eba:	557d                	li	a0,-1
    80004ebc:	bfc1                	j	80004e8c <filewrite+0x114>
    80004ebe:	557d                	li	a0,-1
    80004ec0:	b7f1                	j	80004e8c <filewrite+0x114>
    ret = (i == n ? n : -1);
    80004ec2:	557d                	li	a0,-1
    80004ec4:	7a42                	ld	s4,48(sp)
    80004ec6:	b7d9                	j	80004e8c <filewrite+0x114>

0000000080004ec8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ec8:	7179                	addi	sp,sp,-48
    80004eca:	f406                	sd	ra,40(sp)
    80004ecc:	f022                	sd	s0,32(sp)
    80004ece:	ec26                	sd	s1,24(sp)
    80004ed0:	e052                	sd	s4,0(sp)
    80004ed2:	1800                	addi	s0,sp,48
    80004ed4:	84aa                	mv	s1,a0
    80004ed6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004ed8:	0005b023          	sd	zero,0(a1)
    80004edc:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004ee0:	00000097          	auipc	ra,0x0
    80004ee4:	bac080e7          	jalr	-1108(ra) # 80004a8c <filealloc>
    80004ee8:	e088                	sd	a0,0(s1)
    80004eea:	cd49                	beqz	a0,80004f84 <pipealloc+0xbc>
    80004eec:	00000097          	auipc	ra,0x0
    80004ef0:	ba0080e7          	jalr	-1120(ra) # 80004a8c <filealloc>
    80004ef4:	00aa3023          	sd	a0,0(s4)
    80004ef8:	c141                	beqz	a0,80004f78 <pipealloc+0xb0>
    80004efa:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004efc:	ffffc097          	auipc	ra,0xffffc
    80004f00:	c54080e7          	jalr	-940(ra) # 80000b50 <kalloc>
    80004f04:	892a                	mv	s2,a0
    80004f06:	c13d                	beqz	a0,80004f6c <pipealloc+0xa4>
    80004f08:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004f0a:	4985                	li	s3,1
    80004f0c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004f10:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004f14:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004f18:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004f1c:	00003597          	auipc	a1,0x3
    80004f20:	50458593          	addi	a1,a1,1284 # 80008420 <etext+0x420>
    80004f24:	ffffc097          	auipc	ra,0xffffc
    80004f28:	c96080e7          	jalr	-874(ra) # 80000bba <initlock>
  (*f0)->type = FD_PIPE;
    80004f2c:	609c                	ld	a5,0(s1)
    80004f2e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004f32:	609c                	ld	a5,0(s1)
    80004f34:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004f38:	609c                	ld	a5,0(s1)
    80004f3a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004f3e:	609c                	ld	a5,0(s1)
    80004f40:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004f44:	000a3783          	ld	a5,0(s4)
    80004f48:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004f4c:	000a3783          	ld	a5,0(s4)
    80004f50:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004f54:	000a3783          	ld	a5,0(s4)
    80004f58:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004f5c:	000a3783          	ld	a5,0(s4)
    80004f60:	0127b823          	sd	s2,16(a5)
  return 0;
    80004f64:	4501                	li	a0,0
    80004f66:	6942                	ld	s2,16(sp)
    80004f68:	69a2                	ld	s3,8(sp)
    80004f6a:	a03d                	j	80004f98 <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004f6c:	6088                	ld	a0,0(s1)
    80004f6e:	c119                	beqz	a0,80004f74 <pipealloc+0xac>
    80004f70:	6942                	ld	s2,16(sp)
    80004f72:	a029                	j	80004f7c <pipealloc+0xb4>
    80004f74:	6942                	ld	s2,16(sp)
    80004f76:	a039                	j	80004f84 <pipealloc+0xbc>
    80004f78:	6088                	ld	a0,0(s1)
    80004f7a:	c50d                	beqz	a0,80004fa4 <pipealloc+0xdc>
    fileclose(*f0);
    80004f7c:	00000097          	auipc	ra,0x0
    80004f80:	bcc080e7          	jalr	-1076(ra) # 80004b48 <fileclose>
  if(*f1)
    80004f84:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004f88:	557d                	li	a0,-1
  if(*f1)
    80004f8a:	c799                	beqz	a5,80004f98 <pipealloc+0xd0>
    fileclose(*f1);
    80004f8c:	853e                	mv	a0,a5
    80004f8e:	00000097          	auipc	ra,0x0
    80004f92:	bba080e7          	jalr	-1094(ra) # 80004b48 <fileclose>
  return -1;
    80004f96:	557d                	li	a0,-1
}
    80004f98:	70a2                	ld	ra,40(sp)
    80004f9a:	7402                	ld	s0,32(sp)
    80004f9c:	64e2                	ld	s1,24(sp)
    80004f9e:	6a02                	ld	s4,0(sp)
    80004fa0:	6145                	addi	sp,sp,48
    80004fa2:	8082                	ret
  return -1;
    80004fa4:	557d                	li	a0,-1
    80004fa6:	bfcd                	j	80004f98 <pipealloc+0xd0>

0000000080004fa8 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004fa8:	1101                	addi	sp,sp,-32
    80004faa:	ec06                	sd	ra,24(sp)
    80004fac:	e822                	sd	s0,16(sp)
    80004fae:	e426                	sd	s1,8(sp)
    80004fb0:	e04a                	sd	s2,0(sp)
    80004fb2:	1000                	addi	s0,sp,32
    80004fb4:	84aa                	mv	s1,a0
    80004fb6:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004fb8:	ffffc097          	auipc	ra,0xffffc
    80004fbc:	c9c080e7          	jalr	-868(ra) # 80000c54 <acquire>
  if(writable){
    80004fc0:	02090b63          	beqz	s2,80004ff6 <pipeclose+0x4e>
    pi->writeopen = 0;
    80004fc4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004fc8:	21848513          	addi	a0,s1,536
    80004fcc:	ffffd097          	auipc	ra,0xffffd
    80004fd0:	482080e7          	jalr	1154(ra) # 8000244e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004fd4:	2204a783          	lw	a5,544(s1)
    80004fd8:	e781                	bnez	a5,80004fe0 <pipeclose+0x38>
    80004fda:	2244a783          	lw	a5,548(s1)
    80004fde:	c78d                	beqz	a5,80005008 <pipeclose+0x60>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    80004fe0:	8526                	mv	a0,s1
    80004fe2:	ffffc097          	auipc	ra,0xffffc
    80004fe6:	d22080e7          	jalr	-734(ra) # 80000d04 <release>
}
    80004fea:	60e2                	ld	ra,24(sp)
    80004fec:	6442                	ld	s0,16(sp)
    80004fee:	64a2                	ld	s1,8(sp)
    80004ff0:	6902                	ld	s2,0(sp)
    80004ff2:	6105                	addi	sp,sp,32
    80004ff4:	8082                	ret
    pi->readopen = 0;
    80004ff6:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004ffa:	21c48513          	addi	a0,s1,540
    80004ffe:	ffffd097          	auipc	ra,0xffffd
    80005002:	450080e7          	jalr	1104(ra) # 8000244e <wakeup>
    80005006:	b7f9                	j	80004fd4 <pipeclose+0x2c>
    release(&pi->lock);
    80005008:	8526                	mv	a0,s1
    8000500a:	ffffc097          	auipc	ra,0xffffc
    8000500e:	cfa080e7          	jalr	-774(ra) # 80000d04 <release>
    kfree((char*)pi);
    80005012:	8526                	mv	a0,s1
    80005014:	ffffc097          	auipc	ra,0xffffc
    80005018:	a38080e7          	jalr	-1480(ra) # 80000a4c <kfree>
    8000501c:	b7f9                	j	80004fea <pipeclose+0x42>

000000008000501e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000501e:	7159                	addi	sp,sp,-112
    80005020:	f486                	sd	ra,104(sp)
    80005022:	f0a2                	sd	s0,96(sp)
    80005024:	eca6                	sd	s1,88(sp)
    80005026:	e8ca                	sd	s2,80(sp)
    80005028:	e4ce                	sd	s3,72(sp)
    8000502a:	e0d2                	sd	s4,64(sp)
    8000502c:	fc56                	sd	s5,56(sp)
    8000502e:	1880                	addi	s0,sp,112
    80005030:	84aa                	mv	s1,a0
    80005032:	8aae                	mv	s5,a1
    80005034:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005036:	ffffd097          	auipc	ra,0xffffd
    8000503a:	a50080e7          	jalr	-1456(ra) # 80001a86 <myproc>
    8000503e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005040:	8526                	mv	a0,s1
    80005042:	ffffc097          	auipc	ra,0xffffc
    80005046:	c12080e7          	jalr	-1006(ra) # 80000c54 <acquire>
  while(i < n){
    8000504a:	0d405d63          	blez	s4,80005124 <pipewrite+0x106>
    8000504e:	f85a                	sd	s6,48(sp)
    80005050:	f45e                	sd	s7,40(sp)
    80005052:	f062                	sd	s8,32(sp)
    80005054:	ec66                	sd	s9,24(sp)
    80005056:	e86a                	sd	s10,16(sp)
  int i = 0;
    80005058:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000505a:	f9f40c13          	addi	s8,s0,-97
    8000505e:	4b85                	li	s7,1
    80005060:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005062:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005066:	21c48c93          	addi	s9,s1,540
    8000506a:	a099                	j	800050b0 <pipewrite+0x92>
      release(&pi->lock);
    8000506c:	8526                	mv	a0,s1
    8000506e:	ffffc097          	auipc	ra,0xffffc
    80005072:	c96080e7          	jalr	-874(ra) # 80000d04 <release>
      return -1;
    80005076:	597d                	li	s2,-1
    80005078:	7b42                	ld	s6,48(sp)
    8000507a:	7ba2                	ld	s7,40(sp)
    8000507c:	7c02                	ld	s8,32(sp)
    8000507e:	6ce2                	ld	s9,24(sp)
    80005080:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005082:	854a                	mv	a0,s2
    80005084:	70a6                	ld	ra,104(sp)
    80005086:	7406                	ld	s0,96(sp)
    80005088:	64e6                	ld	s1,88(sp)
    8000508a:	6946                	ld	s2,80(sp)
    8000508c:	69a6                	ld	s3,72(sp)
    8000508e:	6a06                	ld	s4,64(sp)
    80005090:	7ae2                	ld	s5,56(sp)
    80005092:	6165                	addi	sp,sp,112
    80005094:	8082                	ret
      wakeup(&pi->nread);
    80005096:	856a                	mv	a0,s10
    80005098:	ffffd097          	auipc	ra,0xffffd
    8000509c:	3b6080e7          	jalr	950(ra) # 8000244e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800050a0:	85a6                	mv	a1,s1
    800050a2:	8566                	mv	a0,s9
    800050a4:	ffffd097          	auipc	ra,0xffffd
    800050a8:	224080e7          	jalr	548(ra) # 800022c8 <sleep>
  while(i < n){
    800050ac:	05495b63          	bge	s2,s4,80005102 <pipewrite+0xe4>
    if(pi->readopen == 0 || pr->killed){
    800050b0:	2204a783          	lw	a5,544(s1)
    800050b4:	dfc5                	beqz	a5,8000506c <pipewrite+0x4e>
    800050b6:	0289a783          	lw	a5,40(s3)
    800050ba:	fbcd                	bnez	a5,8000506c <pipewrite+0x4e>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800050bc:	2184a783          	lw	a5,536(s1)
    800050c0:	21c4a703          	lw	a4,540(s1)
    800050c4:	2007879b          	addiw	a5,a5,512
    800050c8:	fcf707e3          	beq	a4,a5,80005096 <pipewrite+0x78>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800050cc:	86de                	mv	a3,s7
    800050ce:	01590633          	add	a2,s2,s5
    800050d2:	85e2                	mv	a1,s8
    800050d4:	0509b503          	ld	a0,80(s3)
    800050d8:	ffffc097          	auipc	ra,0xffffc
    800050dc:	6be080e7          	jalr	1726(ra) # 80001796 <copyin>
    800050e0:	05650463          	beq	a0,s6,80005128 <pipewrite+0x10a>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800050e4:	21c4a783          	lw	a5,540(s1)
    800050e8:	0017871b          	addiw	a4,a5,1
    800050ec:	20e4ae23          	sw	a4,540(s1)
    800050f0:	1ff7f793          	andi	a5,a5,511
    800050f4:	97a6                	add	a5,a5,s1
    800050f6:	f9f44703          	lbu	a4,-97(s0)
    800050fa:	00e78c23          	sb	a4,24(a5)
      i++;
    800050fe:	2905                	addiw	s2,s2,1
    80005100:	b775                	j	800050ac <pipewrite+0x8e>
    80005102:	7b42                	ld	s6,48(sp)
    80005104:	7ba2                	ld	s7,40(sp)
    80005106:	7c02                	ld	s8,32(sp)
    80005108:	6ce2                	ld	s9,24(sp)
    8000510a:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    8000510c:	21848513          	addi	a0,s1,536
    80005110:	ffffd097          	auipc	ra,0xffffd
    80005114:	33e080e7          	jalr	830(ra) # 8000244e <wakeup>
  release(&pi->lock);
    80005118:	8526                	mv	a0,s1
    8000511a:	ffffc097          	auipc	ra,0xffffc
    8000511e:	bea080e7          	jalr	-1046(ra) # 80000d04 <release>
  return i;
    80005122:	b785                	j	80005082 <pipewrite+0x64>
  int i = 0;
    80005124:	4901                	li	s2,0
    80005126:	b7dd                	j	8000510c <pipewrite+0xee>
    80005128:	7b42                	ld	s6,48(sp)
    8000512a:	7ba2                	ld	s7,40(sp)
    8000512c:	7c02                	ld	s8,32(sp)
    8000512e:	6ce2                	ld	s9,24(sp)
    80005130:	6d42                	ld	s10,16(sp)
    80005132:	bfe9                	j	8000510c <pipewrite+0xee>

0000000080005134 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005134:	711d                	addi	sp,sp,-96
    80005136:	ec86                	sd	ra,88(sp)
    80005138:	e8a2                	sd	s0,80(sp)
    8000513a:	e4a6                	sd	s1,72(sp)
    8000513c:	e0ca                	sd	s2,64(sp)
    8000513e:	fc4e                	sd	s3,56(sp)
    80005140:	f852                	sd	s4,48(sp)
    80005142:	f456                	sd	s5,40(sp)
    80005144:	1080                	addi	s0,sp,96
    80005146:	84aa                	mv	s1,a0
    80005148:	892e                	mv	s2,a1
    8000514a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000514c:	ffffd097          	auipc	ra,0xffffd
    80005150:	93a080e7          	jalr	-1734(ra) # 80001a86 <myproc>
    80005154:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005156:	8526                	mv	a0,s1
    80005158:	ffffc097          	auipc	ra,0xffffc
    8000515c:	afc080e7          	jalr	-1284(ra) # 80000c54 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005160:	2184a703          	lw	a4,536(s1)
    80005164:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005168:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000516c:	02f71863          	bne	a4,a5,8000519c <piperead+0x68>
    80005170:	2244a783          	lw	a5,548(s1)
    80005174:	cf9d                	beqz	a5,800051b2 <piperead+0x7e>
    if(pr->killed){
    80005176:	028a2783          	lw	a5,40(s4)
    8000517a:	e78d                	bnez	a5,800051a4 <piperead+0x70>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000517c:	85a6                	mv	a1,s1
    8000517e:	854e                	mv	a0,s3
    80005180:	ffffd097          	auipc	ra,0xffffd
    80005184:	148080e7          	jalr	328(ra) # 800022c8 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005188:	2184a703          	lw	a4,536(s1)
    8000518c:	21c4a783          	lw	a5,540(s1)
    80005190:	fef700e3          	beq	a4,a5,80005170 <piperead+0x3c>
    80005194:	f05a                	sd	s6,32(sp)
    80005196:	ec5e                	sd	s7,24(sp)
    80005198:	e862                	sd	s8,16(sp)
    8000519a:	a839                	j	800051b8 <piperead+0x84>
    8000519c:	f05a                	sd	s6,32(sp)
    8000519e:	ec5e                	sd	s7,24(sp)
    800051a0:	e862                	sd	s8,16(sp)
    800051a2:	a819                	j	800051b8 <piperead+0x84>
      release(&pi->lock);
    800051a4:	8526                	mv	a0,s1
    800051a6:	ffffc097          	auipc	ra,0xffffc
    800051aa:	b5e080e7          	jalr	-1186(ra) # 80000d04 <release>
      return -1;
    800051ae:	59fd                	li	s3,-1
    800051b0:	a88d                	j	80005222 <piperead+0xee>
    800051b2:	f05a                	sd	s6,32(sp)
    800051b4:	ec5e                	sd	s7,24(sp)
    800051b6:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051b8:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800051ba:	faf40c13          	addi	s8,s0,-81
    800051be:	4b85                	li	s7,1
    800051c0:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051c2:	05505263          	blez	s5,80005206 <piperead+0xd2>
    if(pi->nread == pi->nwrite)
    800051c6:	2184a783          	lw	a5,536(s1)
    800051ca:	21c4a703          	lw	a4,540(s1)
    800051ce:	02f70c63          	beq	a4,a5,80005206 <piperead+0xd2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800051d2:	0017871b          	addiw	a4,a5,1
    800051d6:	20e4ac23          	sw	a4,536(s1)
    800051da:	1ff7f793          	andi	a5,a5,511
    800051de:	97a6                	add	a5,a5,s1
    800051e0:	0187c783          	lbu	a5,24(a5)
    800051e4:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800051e8:	86de                	mv	a3,s7
    800051ea:	8662                	mv	a2,s8
    800051ec:	85ca                	mv	a1,s2
    800051ee:	050a3503          	ld	a0,80(s4)
    800051f2:	ffffc097          	auipc	ra,0xffffc
    800051f6:	518080e7          	jalr	1304(ra) # 8000170a <copyout>
    800051fa:	01650663          	beq	a0,s6,80005206 <piperead+0xd2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051fe:	2985                	addiw	s3,s3,1
    80005200:	0905                	addi	s2,s2,1
    80005202:	fd3a92e3          	bne	s5,s3,800051c6 <piperead+0x92>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005206:	21c48513          	addi	a0,s1,540
    8000520a:	ffffd097          	auipc	ra,0xffffd
    8000520e:	244080e7          	jalr	580(ra) # 8000244e <wakeup>
  release(&pi->lock);
    80005212:	8526                	mv	a0,s1
    80005214:	ffffc097          	auipc	ra,0xffffc
    80005218:	af0080e7          	jalr	-1296(ra) # 80000d04 <release>
    8000521c:	7b02                	ld	s6,32(sp)
    8000521e:	6be2                	ld	s7,24(sp)
    80005220:	6c42                	ld	s8,16(sp)
  return i;
}
    80005222:	854e                	mv	a0,s3
    80005224:	60e6                	ld	ra,88(sp)
    80005226:	6446                	ld	s0,80(sp)
    80005228:	64a6                	ld	s1,72(sp)
    8000522a:	6906                	ld	s2,64(sp)
    8000522c:	79e2                	ld	s3,56(sp)
    8000522e:	7a42                	ld	s4,48(sp)
    80005230:	7aa2                	ld	s5,40(sp)
    80005232:	6125                	addi	sp,sp,96
    80005234:	8082                	ret

0000000080005236 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005236:	de010113          	addi	sp,sp,-544
    8000523a:	20113c23          	sd	ra,536(sp)
    8000523e:	20813823          	sd	s0,528(sp)
    80005242:	20913423          	sd	s1,520(sp)
    80005246:	21213023          	sd	s2,512(sp)
    8000524a:	1400                	addi	s0,sp,544
    8000524c:	892a                	mv	s2,a0
    8000524e:	dea43823          	sd	a0,-528(s0)
    80005252:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005256:	ffffd097          	auipc	ra,0xffffd
    8000525a:	830080e7          	jalr	-2000(ra) # 80001a86 <myproc>
    8000525e:	84aa                	mv	s1,a0

  begin_op();
    80005260:	fffff097          	auipc	ra,0xfffff
    80005264:	406080e7          	jalr	1030(ra) # 80004666 <begin_op>

  if((ip = namei(path)) == 0){
    80005268:	854a                	mv	a0,s2
    8000526a:	fffff097          	auipc	ra,0xfffff
    8000526e:	1f6080e7          	jalr	502(ra) # 80004460 <namei>
    80005272:	c525                	beqz	a0,800052da <exec+0xa4>
    80005274:	fbd2                	sd	s4,496(sp)
    80005276:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005278:	fffff097          	auipc	ra,0xfffff
    8000527c:	9f6080e7          	jalr	-1546(ra) # 80003c6e <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005280:	04000713          	li	a4,64
    80005284:	4681                	li	a3,0
    80005286:	e5040613          	addi	a2,s0,-432
    8000528a:	4581                	li	a1,0
    8000528c:	8552                	mv	a0,s4
    8000528e:	fffff097          	auipc	ra,0xfffff
    80005292:	c9e080e7          	jalr	-866(ra) # 80003f2c <readi>
    80005296:	04000793          	li	a5,64
    8000529a:	00f51a63          	bne	a0,a5,800052ae <exec+0x78>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    8000529e:	e5042703          	lw	a4,-432(s0)
    800052a2:	464c47b7          	lui	a5,0x464c4
    800052a6:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800052aa:	02f70e63          	beq	a4,a5,800052e6 <exec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800052ae:	8552                	mv	a0,s4
    800052b0:	fffff097          	auipc	ra,0xfffff
    800052b4:	c26080e7          	jalr	-986(ra) # 80003ed6 <iunlockput>
    end_op();
    800052b8:	fffff097          	auipc	ra,0xfffff
    800052bc:	42e080e7          	jalr	1070(ra) # 800046e6 <end_op>
  }
  return -1;
    800052c0:	557d                	li	a0,-1
    800052c2:	7a5e                	ld	s4,496(sp)
}
    800052c4:	21813083          	ld	ra,536(sp)
    800052c8:	21013403          	ld	s0,528(sp)
    800052cc:	20813483          	ld	s1,520(sp)
    800052d0:	20013903          	ld	s2,512(sp)
    800052d4:	22010113          	addi	sp,sp,544
    800052d8:	8082                	ret
    end_op();
    800052da:	fffff097          	auipc	ra,0xfffff
    800052de:	40c080e7          	jalr	1036(ra) # 800046e6 <end_op>
    return -1;
    800052e2:	557d                	li	a0,-1
    800052e4:	b7c5                	j	800052c4 <exec+0x8e>
    800052e6:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800052e8:	8526                	mv	a0,s1
    800052ea:	ffffd097          	auipc	ra,0xffffd
    800052ee:	862080e7          	jalr	-1950(ra) # 80001b4c <proc_pagetable>
    800052f2:	8b2a                	mv	s6,a0
    800052f4:	2a050a63          	beqz	a0,800055a8 <exec+0x372>
    800052f8:	ffce                	sd	s3,504(sp)
    800052fa:	f7d6                	sd	s5,488(sp)
    800052fc:	efde                	sd	s7,472(sp)
    800052fe:	ebe2                	sd	s8,464(sp)
    80005300:	e7e6                	sd	s9,456(sp)
    80005302:	e3ea                	sd	s10,448(sp)
    80005304:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005306:	e8845783          	lhu	a5,-376(s0)
    8000530a:	cfed                	beqz	a5,80005404 <exec+0x1ce>
    8000530c:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005310:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005312:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005314:	03800d93          	li	s11,56
    if((ph.vaddr % PGSIZE) != 0)
    80005318:	6c85                	lui	s9,0x1
    8000531a:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000531e:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80005322:	6a85                	lui	s5,0x1
    80005324:	a0b5                	j	80005390 <exec+0x15a>
      panic("loadseg: address should exist");
    80005326:	00003517          	auipc	a0,0x3
    8000532a:	36a50513          	addi	a0,a0,874 # 80008690 <etext+0x690>
    8000532e:	ffffb097          	auipc	ra,0xffffb
    80005332:	228080e7          	jalr	552(ra) # 80000556 <panic>
    if(sz - i < PGSIZE)
    80005336:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005338:	874a                	mv	a4,s2
    8000533a:	009c06bb          	addw	a3,s8,s1
    8000533e:	4581                	li	a1,0
    80005340:	8552                	mv	a0,s4
    80005342:	fffff097          	auipc	ra,0xfffff
    80005346:	bea080e7          	jalr	-1046(ra) # 80003f2c <readi>
    8000534a:	26a91363          	bne	s2,a0,800055b0 <exec+0x37a>
  for(i = 0; i < sz; i += PGSIZE){
    8000534e:	009a84bb          	addw	s1,s5,s1
    80005352:	0334f463          	bgeu	s1,s3,8000537a <exec+0x144>
    pa = walkaddr(pagetable, va + i);
    80005356:	02049593          	slli	a1,s1,0x20
    8000535a:	9181                	srli	a1,a1,0x20
    8000535c:	95de                	add	a1,a1,s7
    8000535e:	855a                	mv	a0,s6
    80005360:	ffffc097          	auipc	ra,0xffffc
    80005364:	d8a080e7          	jalr	-630(ra) # 800010ea <walkaddr>
    80005368:	862a                	mv	a2,a0
    if(pa == 0)
    8000536a:	dd55                	beqz	a0,80005326 <exec+0xf0>
    if(sz - i < PGSIZE)
    8000536c:	409987bb          	subw	a5,s3,s1
    80005370:	893e                	mv	s2,a5
    80005372:	fcfcf2e3          	bgeu	s9,a5,80005336 <exec+0x100>
    80005376:	8956                	mv	s2,s5
    80005378:	bf7d                	j	80005336 <exec+0x100>
    sz = sz1;
    8000537a:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000537e:	2d05                	addiw	s10,s10,1
    80005380:	e0843783          	ld	a5,-504(s0)
    80005384:	0387869b          	addiw	a3,a5,56
    80005388:	e8845783          	lhu	a5,-376(s0)
    8000538c:	06fd5d63          	bge	s10,a5,80005406 <exec+0x1d0>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005390:	e0d43423          	sd	a3,-504(s0)
    80005394:	876e                	mv	a4,s11
    80005396:	e1840613          	addi	a2,s0,-488
    8000539a:	4581                	li	a1,0
    8000539c:	8552                	mv	a0,s4
    8000539e:	fffff097          	auipc	ra,0xfffff
    800053a2:	b8e080e7          	jalr	-1138(ra) # 80003f2c <readi>
    800053a6:	21b51363          	bne	a0,s11,800055ac <exec+0x376>
    if(ph.type != ELF_PROG_LOAD)
    800053aa:	e1842783          	lw	a5,-488(s0)
    800053ae:	4705                	li	a4,1
    800053b0:	fce797e3          	bne	a5,a4,8000537e <exec+0x148>
    if(ph.memsz < ph.filesz)
    800053b4:	e4043603          	ld	a2,-448(s0)
    800053b8:	e3843783          	ld	a5,-456(s0)
    800053bc:	20f66a63          	bltu	a2,a5,800055d0 <exec+0x39a>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800053c0:	e2843783          	ld	a5,-472(s0)
    800053c4:	963e                	add	a2,a2,a5
    800053c6:	20f66863          	bltu	a2,a5,800055d6 <exec+0x3a0>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800053ca:	85a6                	mv	a1,s1
    800053cc:	855a                	mv	a0,s6
    800053ce:	ffffc097          	auipc	ra,0xffffc
    800053d2:	0da080e7          	jalr	218(ra) # 800014a8 <uvmalloc>
    800053d6:	dea43c23          	sd	a0,-520(s0)
    800053da:	20050163          	beqz	a0,800055dc <exec+0x3a6>
    if((ph.vaddr % PGSIZE) != 0)
    800053de:	e2843b83          	ld	s7,-472(s0)
    800053e2:	de843783          	ld	a5,-536(s0)
    800053e6:	00fbf7b3          	and	a5,s7,a5
    800053ea:	1c079363          	bnez	a5,800055b0 <exec+0x37a>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800053ee:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800053f2:	00098663          	beqz	s3,800053fe <exec+0x1c8>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800053f6:	e2042c03          	lw	s8,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800053fa:	4481                	li	s1,0
    800053fc:	bfa9                	j	80005356 <exec+0x120>
    sz = sz1;
    800053fe:	df843483          	ld	s1,-520(s0)
    80005402:	bfb5                	j	8000537e <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005404:	4481                	li	s1,0
  iunlockput(ip);
    80005406:	8552                	mv	a0,s4
    80005408:	fffff097          	auipc	ra,0xfffff
    8000540c:	ace080e7          	jalr	-1330(ra) # 80003ed6 <iunlockput>
  end_op();
    80005410:	fffff097          	auipc	ra,0xfffff
    80005414:	2d6080e7          	jalr	726(ra) # 800046e6 <end_op>
  p = myproc();
    80005418:	ffffc097          	auipc	ra,0xffffc
    8000541c:	66e080e7          	jalr	1646(ra) # 80001a86 <myproc>
    80005420:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005422:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005426:	6985                	lui	s3,0x1
    80005428:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    8000542a:	99a6                	add	s3,s3,s1
    8000542c:	77fd                	lui	a5,0xfffff
    8000542e:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005432:	6609                	lui	a2,0x2
    80005434:	964e                	add	a2,a2,s3
    80005436:	85ce                	mv	a1,s3
    80005438:	855a                	mv	a0,s6
    8000543a:	ffffc097          	auipc	ra,0xffffc
    8000543e:	06e080e7          	jalr	110(ra) # 800014a8 <uvmalloc>
    80005442:	8a2a                	mv	s4,a0
    80005444:	e115                	bnez	a0,80005468 <exec+0x232>
    proc_freepagetable(pagetable, sz);
    80005446:	85ce                	mv	a1,s3
    80005448:	855a                	mv	a0,s6
    8000544a:	ffffc097          	auipc	ra,0xffffc
    8000544e:	79e080e7          	jalr	1950(ra) # 80001be8 <proc_freepagetable>
  return -1;
    80005452:	557d                	li	a0,-1
    80005454:	79fe                	ld	s3,504(sp)
    80005456:	7a5e                	ld	s4,496(sp)
    80005458:	7abe                	ld	s5,488(sp)
    8000545a:	7b1e                	ld	s6,480(sp)
    8000545c:	6bfe                	ld	s7,472(sp)
    8000545e:	6c5e                	ld	s8,464(sp)
    80005460:	6cbe                	ld	s9,456(sp)
    80005462:	6d1e                	ld	s10,448(sp)
    80005464:	7dfa                	ld	s11,440(sp)
    80005466:	bdb9                	j	800052c4 <exec+0x8e>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005468:	75f9                	lui	a1,0xffffe
    8000546a:	95aa                	add	a1,a1,a0
    8000546c:	855a                	mv	a0,s6
    8000546e:	ffffc097          	auipc	ra,0xffffc
    80005472:	26a080e7          	jalr	618(ra) # 800016d8 <uvmclear>
  stackbase = sp - PGSIZE;
    80005476:	800a0b93          	addi	s7,s4,-2048
    8000547a:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    8000547e:	e0043783          	ld	a5,-512(s0)
    80005482:	6388                	ld	a0,0(a5)
  sp = sz;
    80005484:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80005486:	4481                	li	s1,0
    ustack[argc] = sp;
    80005488:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    8000548c:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80005490:	c135                	beqz	a0,800054f4 <exec+0x2be>
    sp -= strlen(argv[argc]) + 1;
    80005492:	ffffc097          	auipc	ra,0xffffc
    80005496:	a48080e7          	jalr	-1464(ra) # 80000eda <strlen>
    8000549a:	0015079b          	addiw	a5,a0,1
    8000549e:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800054a2:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800054a6:	13796e63          	bltu	s2,s7,800055e2 <exec+0x3ac>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800054aa:	e0043d83          	ld	s11,-512(s0)
    800054ae:	000db983          	ld	s3,0(s11)
    800054b2:	854e                	mv	a0,s3
    800054b4:	ffffc097          	auipc	ra,0xffffc
    800054b8:	a26080e7          	jalr	-1498(ra) # 80000eda <strlen>
    800054bc:	0015069b          	addiw	a3,a0,1
    800054c0:	864e                	mv	a2,s3
    800054c2:	85ca                	mv	a1,s2
    800054c4:	855a                	mv	a0,s6
    800054c6:	ffffc097          	auipc	ra,0xffffc
    800054ca:	244080e7          	jalr	580(ra) # 8000170a <copyout>
    800054ce:	10054c63          	bltz	a0,800055e6 <exec+0x3b0>
    ustack[argc] = sp;
    800054d2:	00349793          	slli	a5,s1,0x3
    800054d6:	97e6                	add	a5,a5,s9
    800054d8:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffd5000>
  for(argc = 0; argv[argc]; argc++) {
    800054dc:	0485                	addi	s1,s1,1
    800054de:	008d8793          	addi	a5,s11,8
    800054e2:	e0f43023          	sd	a5,-512(s0)
    800054e6:	008db503          	ld	a0,8(s11)
    800054ea:	c509                	beqz	a0,800054f4 <exec+0x2be>
    if(argc >= MAXARG)
    800054ec:	fb8493e3          	bne	s1,s8,80005492 <exec+0x25c>
  sz = sz1;
    800054f0:	89d2                	mv	s3,s4
    800054f2:	bf91                	j	80005446 <exec+0x210>
  ustack[argc] = 0;
    800054f4:	00349793          	slli	a5,s1,0x3
    800054f8:	f9078793          	addi	a5,a5,-112
    800054fc:	97a2                	add	a5,a5,s0
    800054fe:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005502:	00349693          	slli	a3,s1,0x3
    80005506:	06a1                	addi	a3,a3,8
    80005508:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000550c:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80005510:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80005512:	f3796ae3          	bltu	s2,s7,80005446 <exec+0x210>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005516:	e9040613          	addi	a2,s0,-368
    8000551a:	85ca                	mv	a1,s2
    8000551c:	855a                	mv	a0,s6
    8000551e:	ffffc097          	auipc	ra,0xffffc
    80005522:	1ec080e7          	jalr	492(ra) # 8000170a <copyout>
    80005526:	f20540e3          	bltz	a0,80005446 <exec+0x210>
  p->trapframe->a1 = sp;
    8000552a:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    8000552e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005532:	df043783          	ld	a5,-528(s0)
    80005536:	0007c703          	lbu	a4,0(a5)
    8000553a:	cf11                	beqz	a4,80005556 <exec+0x320>
    8000553c:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000553e:	02f00693          	li	a3,47
    80005542:	a029                	j	8000554c <exec+0x316>
  for(last=s=path; *s; s++)
    80005544:	0785                	addi	a5,a5,1
    80005546:	fff7c703          	lbu	a4,-1(a5)
    8000554a:	c711                	beqz	a4,80005556 <exec+0x320>
    if(*s == '/')
    8000554c:	fed71ce3          	bne	a4,a3,80005544 <exec+0x30e>
      last = s+1;
    80005550:	def43823          	sd	a5,-528(s0)
    80005554:	bfc5                	j	80005544 <exec+0x30e>
  safestrcpy(p->name, last, sizeof(p->name));
    80005556:	4641                	li	a2,16
    80005558:	df043583          	ld	a1,-528(s0)
    8000555c:	158a8513          	addi	a0,s5,344
    80005560:	ffffc097          	auipc	ra,0xffffc
    80005564:	944080e7          	jalr	-1724(ra) # 80000ea4 <safestrcpy>
  oldpagetable = p->pagetable;
    80005568:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000556c:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80005570:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005574:	058ab783          	ld	a5,88(s5)
    80005578:	e6843703          	ld	a4,-408(s0)
    8000557c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000557e:	058ab783          	ld	a5,88(s5)
    80005582:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005586:	85ea                	mv	a1,s10
    80005588:	ffffc097          	auipc	ra,0xffffc
    8000558c:	660080e7          	jalr	1632(ra) # 80001be8 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005590:	0004851b          	sext.w	a0,s1
    80005594:	79fe                	ld	s3,504(sp)
    80005596:	7a5e                	ld	s4,496(sp)
    80005598:	7abe                	ld	s5,488(sp)
    8000559a:	7b1e                	ld	s6,480(sp)
    8000559c:	6bfe                	ld	s7,472(sp)
    8000559e:	6c5e                	ld	s8,464(sp)
    800055a0:	6cbe                	ld	s9,456(sp)
    800055a2:	6d1e                	ld	s10,448(sp)
    800055a4:	7dfa                	ld	s11,440(sp)
    800055a6:	bb39                	j	800052c4 <exec+0x8e>
    800055a8:	7b1e                	ld	s6,480(sp)
    800055aa:	b311                	j	800052ae <exec+0x78>
    800055ac:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    800055b0:	df843583          	ld	a1,-520(s0)
    800055b4:	855a                	mv	a0,s6
    800055b6:	ffffc097          	auipc	ra,0xffffc
    800055ba:	632080e7          	jalr	1586(ra) # 80001be8 <proc_freepagetable>
  if(ip){
    800055be:	79fe                	ld	s3,504(sp)
    800055c0:	7abe                	ld	s5,488(sp)
    800055c2:	7b1e                	ld	s6,480(sp)
    800055c4:	6bfe                	ld	s7,472(sp)
    800055c6:	6c5e                	ld	s8,464(sp)
    800055c8:	6cbe                	ld	s9,456(sp)
    800055ca:	6d1e                	ld	s10,448(sp)
    800055cc:	7dfa                	ld	s11,440(sp)
    800055ce:	b1c5                	j	800052ae <exec+0x78>
    800055d0:	de943c23          	sd	s1,-520(s0)
    800055d4:	bff1                	j	800055b0 <exec+0x37a>
    800055d6:	de943c23          	sd	s1,-520(s0)
    800055da:	bfd9                	j	800055b0 <exec+0x37a>
    800055dc:	de943c23          	sd	s1,-520(s0)
    800055e0:	bfc1                	j	800055b0 <exec+0x37a>
  sz = sz1;
    800055e2:	89d2                	mv	s3,s4
    800055e4:	b58d                	j	80005446 <exec+0x210>
    800055e6:	89d2                	mv	s3,s4
    800055e8:	bdb9                	j	80005446 <exec+0x210>

00000000800055ea <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800055ea:	7179                	addi	sp,sp,-48
    800055ec:	f406                	sd	ra,40(sp)
    800055ee:	f022                	sd	s0,32(sp)
    800055f0:	ec26                	sd	s1,24(sp)
    800055f2:	e84a                	sd	s2,16(sp)
    800055f4:	1800                	addi	s0,sp,48
    800055f6:	892e                	mv	s2,a1
    800055f8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800055fa:	fdc40593          	addi	a1,s0,-36
    800055fe:	ffffe097          	auipc	ra,0xffffe
    80005602:	8de080e7          	jalr	-1826(ra) # 80002edc <argint>
    80005606:	04054163          	bltz	a0,80005648 <argfd+0x5e>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000560a:	fdc42703          	lw	a4,-36(s0)
    8000560e:	47bd                	li	a5,15
    80005610:	02e7ee63          	bltu	a5,a4,8000564c <argfd+0x62>
    80005614:	ffffc097          	auipc	ra,0xffffc
    80005618:	472080e7          	jalr	1138(ra) # 80001a86 <myproc>
    8000561c:	fdc42703          	lw	a4,-36(s0)
    80005620:	00371793          	slli	a5,a4,0x3
    80005624:	0d078793          	addi	a5,a5,208
    80005628:	953e                	add	a0,a0,a5
    8000562a:	611c                	ld	a5,0(a0)
    8000562c:	c395                	beqz	a5,80005650 <argfd+0x66>
    return -1;
  if(pfd)
    8000562e:	00090463          	beqz	s2,80005636 <argfd+0x4c>
    *pfd = fd;
    80005632:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005636:	4501                	li	a0,0
  if(pf)
    80005638:	c091                	beqz	s1,8000563c <argfd+0x52>
    *pf = f;
    8000563a:	e09c                	sd	a5,0(s1)
}
    8000563c:	70a2                	ld	ra,40(sp)
    8000563e:	7402                	ld	s0,32(sp)
    80005640:	64e2                	ld	s1,24(sp)
    80005642:	6942                	ld	s2,16(sp)
    80005644:	6145                	addi	sp,sp,48
    80005646:	8082                	ret
    return -1;
    80005648:	557d                	li	a0,-1
    8000564a:	bfcd                	j	8000563c <argfd+0x52>
    return -1;
    8000564c:	557d                	li	a0,-1
    8000564e:	b7fd                	j	8000563c <argfd+0x52>
    80005650:	557d                	li	a0,-1
    80005652:	b7ed                	j	8000563c <argfd+0x52>

0000000080005654 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005654:	1101                	addi	sp,sp,-32
    80005656:	ec06                	sd	ra,24(sp)
    80005658:	e822                	sd	s0,16(sp)
    8000565a:	e426                	sd	s1,8(sp)
    8000565c:	1000                	addi	s0,sp,32
    8000565e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005660:	ffffc097          	auipc	ra,0xffffc
    80005664:	426080e7          	jalr	1062(ra) # 80001a86 <myproc>
    80005668:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000566a:	0d050793          	addi	a5,a0,208
    8000566e:	4501                	li	a0,0
    80005670:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005672:	6398                	ld	a4,0(a5)
    80005674:	cb19                	beqz	a4,8000568a <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005676:	2505                	addiw	a0,a0,1
    80005678:	07a1                	addi	a5,a5,8
    8000567a:	fed51ce3          	bne	a0,a3,80005672 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000567e:	557d                	li	a0,-1
}
    80005680:	60e2                	ld	ra,24(sp)
    80005682:	6442                	ld	s0,16(sp)
    80005684:	64a2                	ld	s1,8(sp)
    80005686:	6105                	addi	sp,sp,32
    80005688:	8082                	ret
      p->ofile[fd] = f;
    8000568a:	00351793          	slli	a5,a0,0x3
    8000568e:	0d078793          	addi	a5,a5,208
    80005692:	963e                	add	a2,a2,a5
    80005694:	e204                	sd	s1,0(a2)
      return fd;
    80005696:	b7ed                	j	80005680 <fdalloc+0x2c>

0000000080005698 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005698:	715d                	addi	sp,sp,-80
    8000569a:	e486                	sd	ra,72(sp)
    8000569c:	e0a2                	sd	s0,64(sp)
    8000569e:	fc26                	sd	s1,56(sp)
    800056a0:	f84a                	sd	s2,48(sp)
    800056a2:	f44e                	sd	s3,40(sp)
    800056a4:	f052                	sd	s4,32(sp)
    800056a6:	ec56                	sd	s5,24(sp)
    800056a8:	0880                	addi	s0,sp,80
    800056aa:	89ae                	mv	s3,a1
    800056ac:	8a32                	mv	s4,a2
    800056ae:	8ab6                	mv	s5,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800056b0:	fb040593          	addi	a1,s0,-80
    800056b4:	fffff097          	auipc	ra,0xfffff
    800056b8:	dca080e7          	jalr	-566(ra) # 8000447e <nameiparent>
    800056bc:	892a                	mv	s2,a0
    800056be:	12050d63          	beqz	a0,800057f8 <create+0x160>
    return 0;

  ilock(dp);
    800056c2:	ffffe097          	auipc	ra,0xffffe
    800056c6:	5ac080e7          	jalr	1452(ra) # 80003c6e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800056ca:	4601                	li	a2,0
    800056cc:	fb040593          	addi	a1,s0,-80
    800056d0:	854a                	mv	a0,s2
    800056d2:	fffff097          	auipc	ra,0xfffff
    800056d6:	a8a080e7          	jalr	-1398(ra) # 8000415c <dirlookup>
    800056da:	84aa                	mv	s1,a0
    800056dc:	c539                	beqz	a0,8000572a <create+0x92>
    iunlockput(dp);
    800056de:	854a                	mv	a0,s2
    800056e0:	ffffe097          	auipc	ra,0xffffe
    800056e4:	7f6080e7          	jalr	2038(ra) # 80003ed6 <iunlockput>
    ilock(ip);
    800056e8:	8526                	mv	a0,s1
    800056ea:	ffffe097          	auipc	ra,0xffffe
    800056ee:	584080e7          	jalr	1412(ra) # 80003c6e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800056f2:	4789                	li	a5,2
    800056f4:	02f99463          	bne	s3,a5,8000571c <create+0x84>
    800056f8:	0444d783          	lhu	a5,68(s1)
    800056fc:	37f9                	addiw	a5,a5,-2
    800056fe:	17c2                	slli	a5,a5,0x30
    80005700:	93c1                	srli	a5,a5,0x30
    80005702:	4705                	li	a4,1
    80005704:	00f76c63          	bltu	a4,a5,8000571c <create+0x84>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005708:	8526                	mv	a0,s1
    8000570a:	60a6                	ld	ra,72(sp)
    8000570c:	6406                	ld	s0,64(sp)
    8000570e:	74e2                	ld	s1,56(sp)
    80005710:	7942                	ld	s2,48(sp)
    80005712:	79a2                	ld	s3,40(sp)
    80005714:	7a02                	ld	s4,32(sp)
    80005716:	6ae2                	ld	s5,24(sp)
    80005718:	6161                	addi	sp,sp,80
    8000571a:	8082                	ret
    iunlockput(ip);
    8000571c:	8526                	mv	a0,s1
    8000571e:	ffffe097          	auipc	ra,0xffffe
    80005722:	7b8080e7          	jalr	1976(ra) # 80003ed6 <iunlockput>
    return 0;
    80005726:	4481                	li	s1,0
    80005728:	b7c5                	j	80005708 <create+0x70>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000572a:	85ce                	mv	a1,s3
    8000572c:	00092503          	lw	a0,0(s2)
    80005730:	ffffe097          	auipc	ra,0xffffe
    80005734:	3aa080e7          	jalr	938(ra) # 80003ada <ialloc>
    80005738:	84aa                	mv	s1,a0
    8000573a:	c521                	beqz	a0,80005782 <create+0xea>
  ilock(ip);
    8000573c:	ffffe097          	auipc	ra,0xffffe
    80005740:	532080e7          	jalr	1330(ra) # 80003c6e <ilock>
  ip->major = major;
    80005744:	05449323          	sh	s4,70(s1)
  ip->minor = minor;
    80005748:	05549423          	sh	s5,72(s1)
  ip->nlink = 1;
    8000574c:	4785                	li	a5,1
    8000574e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005752:	8526                	mv	a0,s1
    80005754:	ffffe097          	auipc	ra,0xffffe
    80005758:	44e080e7          	jalr	1102(ra) # 80003ba2 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000575c:	4705                	li	a4,1
    8000575e:	02e98a63          	beq	s3,a4,80005792 <create+0xfa>
  if(dirlink(dp, name, ip->inum) < 0)
    80005762:	40d0                	lw	a2,4(s1)
    80005764:	fb040593          	addi	a1,s0,-80
    80005768:	854a                	mv	a0,s2
    8000576a:	fffff097          	auipc	ra,0xfffff
    8000576e:	c20080e7          	jalr	-992(ra) # 8000438a <dirlink>
    80005772:	06054b63          	bltz	a0,800057e8 <create+0x150>
  iunlockput(dp);
    80005776:	854a                	mv	a0,s2
    80005778:	ffffe097          	auipc	ra,0xffffe
    8000577c:	75e080e7          	jalr	1886(ra) # 80003ed6 <iunlockput>
  return ip;
    80005780:	b761                	j	80005708 <create+0x70>
    panic("create: ialloc");
    80005782:	00003517          	auipc	a0,0x3
    80005786:	f2e50513          	addi	a0,a0,-210 # 800086b0 <etext+0x6b0>
    8000578a:	ffffb097          	auipc	ra,0xffffb
    8000578e:	dcc080e7          	jalr	-564(ra) # 80000556 <panic>
    dp->nlink++;  // for ".."
    80005792:	04a95783          	lhu	a5,74(s2)
    80005796:	2785                	addiw	a5,a5,1
    80005798:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000579c:	854a                	mv	a0,s2
    8000579e:	ffffe097          	auipc	ra,0xffffe
    800057a2:	404080e7          	jalr	1028(ra) # 80003ba2 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800057a6:	40d0                	lw	a2,4(s1)
    800057a8:	00003597          	auipc	a1,0x3
    800057ac:	f1858593          	addi	a1,a1,-232 # 800086c0 <etext+0x6c0>
    800057b0:	8526                	mv	a0,s1
    800057b2:	fffff097          	auipc	ra,0xfffff
    800057b6:	bd8080e7          	jalr	-1064(ra) # 8000438a <dirlink>
    800057ba:	00054f63          	bltz	a0,800057d8 <create+0x140>
    800057be:	00492603          	lw	a2,4(s2)
    800057c2:	00003597          	auipc	a1,0x3
    800057c6:	f0658593          	addi	a1,a1,-250 # 800086c8 <etext+0x6c8>
    800057ca:	8526                	mv	a0,s1
    800057cc:	fffff097          	auipc	ra,0xfffff
    800057d0:	bbe080e7          	jalr	-1090(ra) # 8000438a <dirlink>
    800057d4:	f80557e3          	bgez	a0,80005762 <create+0xca>
      panic("create dots");
    800057d8:	00003517          	auipc	a0,0x3
    800057dc:	ef850513          	addi	a0,a0,-264 # 800086d0 <etext+0x6d0>
    800057e0:	ffffb097          	auipc	ra,0xffffb
    800057e4:	d76080e7          	jalr	-650(ra) # 80000556 <panic>
    panic("create: dirlink");
    800057e8:	00003517          	auipc	a0,0x3
    800057ec:	ef850513          	addi	a0,a0,-264 # 800086e0 <etext+0x6e0>
    800057f0:	ffffb097          	auipc	ra,0xffffb
    800057f4:	d66080e7          	jalr	-666(ra) # 80000556 <panic>
    return 0;
    800057f8:	84aa                	mv	s1,a0
    800057fa:	b739                	j	80005708 <create+0x70>

00000000800057fc <sys_dup>:
{
    800057fc:	7179                	addi	sp,sp,-48
    800057fe:	f406                	sd	ra,40(sp)
    80005800:	f022                	sd	s0,32(sp)
    80005802:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005804:	fd840613          	addi	a2,s0,-40
    80005808:	4581                	li	a1,0
    8000580a:	4501                	li	a0,0
    8000580c:	00000097          	auipc	ra,0x0
    80005810:	dde080e7          	jalr	-546(ra) # 800055ea <argfd>
    return -1;
    80005814:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005816:	02054763          	bltz	a0,80005844 <sys_dup+0x48>
    8000581a:	ec26                	sd	s1,24(sp)
    8000581c:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    8000581e:	fd843483          	ld	s1,-40(s0)
    80005822:	8526                	mv	a0,s1
    80005824:	00000097          	auipc	ra,0x0
    80005828:	e30080e7          	jalr	-464(ra) # 80005654 <fdalloc>
    8000582c:	892a                	mv	s2,a0
    return -1;
    8000582e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005830:	00054f63          	bltz	a0,8000584e <sys_dup+0x52>
  filedup(f);
    80005834:	8526                	mv	a0,s1
    80005836:	fffff097          	auipc	ra,0xfffff
    8000583a:	2c0080e7          	jalr	704(ra) # 80004af6 <filedup>
  return fd;
    8000583e:	87ca                	mv	a5,s2
    80005840:	64e2                	ld	s1,24(sp)
    80005842:	6942                	ld	s2,16(sp)
}
    80005844:	853e                	mv	a0,a5
    80005846:	70a2                	ld	ra,40(sp)
    80005848:	7402                	ld	s0,32(sp)
    8000584a:	6145                	addi	sp,sp,48
    8000584c:	8082                	ret
    8000584e:	64e2                	ld	s1,24(sp)
    80005850:	6942                	ld	s2,16(sp)
    80005852:	bfcd                	j	80005844 <sys_dup+0x48>

0000000080005854 <sys_read>:
{
    80005854:	7179                	addi	sp,sp,-48
    80005856:	f406                	sd	ra,40(sp)
    80005858:	f022                	sd	s0,32(sp)
    8000585a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000585c:	fe840613          	addi	a2,s0,-24
    80005860:	4581                	li	a1,0
    80005862:	4501                	li	a0,0
    80005864:	00000097          	auipc	ra,0x0
    80005868:	d86080e7          	jalr	-634(ra) # 800055ea <argfd>
    return -1;
    8000586c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000586e:	04054163          	bltz	a0,800058b0 <sys_read+0x5c>
    80005872:	fe440593          	addi	a1,s0,-28
    80005876:	4509                	li	a0,2
    80005878:	ffffd097          	auipc	ra,0xffffd
    8000587c:	664080e7          	jalr	1636(ra) # 80002edc <argint>
    return -1;
    80005880:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005882:	02054763          	bltz	a0,800058b0 <sys_read+0x5c>
    80005886:	fd840593          	addi	a1,s0,-40
    8000588a:	4505                	li	a0,1
    8000588c:	ffffd097          	auipc	ra,0xffffd
    80005890:	672080e7          	jalr	1650(ra) # 80002efe <argaddr>
    return -1;
    80005894:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005896:	00054d63          	bltz	a0,800058b0 <sys_read+0x5c>
  return fileread(f, p, n);
    8000589a:	fe442603          	lw	a2,-28(s0)
    8000589e:	fd843583          	ld	a1,-40(s0)
    800058a2:	fe843503          	ld	a0,-24(s0)
    800058a6:	fffff097          	auipc	ra,0xfffff
    800058aa:	3fa080e7          	jalr	1018(ra) # 80004ca0 <fileread>
    800058ae:	87aa                	mv	a5,a0
}
    800058b0:	853e                	mv	a0,a5
    800058b2:	70a2                	ld	ra,40(sp)
    800058b4:	7402                	ld	s0,32(sp)
    800058b6:	6145                	addi	sp,sp,48
    800058b8:	8082                	ret

00000000800058ba <sys_write>:
{
    800058ba:	7179                	addi	sp,sp,-48
    800058bc:	f406                	sd	ra,40(sp)
    800058be:	f022                	sd	s0,32(sp)
    800058c0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058c2:	fe840613          	addi	a2,s0,-24
    800058c6:	4581                	li	a1,0
    800058c8:	4501                	li	a0,0
    800058ca:	00000097          	auipc	ra,0x0
    800058ce:	d20080e7          	jalr	-736(ra) # 800055ea <argfd>
    return -1;
    800058d2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058d4:	04054163          	bltz	a0,80005916 <sys_write+0x5c>
    800058d8:	fe440593          	addi	a1,s0,-28
    800058dc:	4509                	li	a0,2
    800058de:	ffffd097          	auipc	ra,0xffffd
    800058e2:	5fe080e7          	jalr	1534(ra) # 80002edc <argint>
    return -1;
    800058e6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058e8:	02054763          	bltz	a0,80005916 <sys_write+0x5c>
    800058ec:	fd840593          	addi	a1,s0,-40
    800058f0:	4505                	li	a0,1
    800058f2:	ffffd097          	auipc	ra,0xffffd
    800058f6:	60c080e7          	jalr	1548(ra) # 80002efe <argaddr>
    return -1;
    800058fa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058fc:	00054d63          	bltz	a0,80005916 <sys_write+0x5c>
  return filewrite(f, p, n);
    80005900:	fe442603          	lw	a2,-28(s0)
    80005904:	fd843583          	ld	a1,-40(s0)
    80005908:	fe843503          	ld	a0,-24(s0)
    8000590c:	fffff097          	auipc	ra,0xfffff
    80005910:	46c080e7          	jalr	1132(ra) # 80004d78 <filewrite>
    80005914:	87aa                	mv	a5,a0
}
    80005916:	853e                	mv	a0,a5
    80005918:	70a2                	ld	ra,40(sp)
    8000591a:	7402                	ld	s0,32(sp)
    8000591c:	6145                	addi	sp,sp,48
    8000591e:	8082                	ret

0000000080005920 <sys_close>:
{
    80005920:	1101                	addi	sp,sp,-32
    80005922:	ec06                	sd	ra,24(sp)
    80005924:	e822                	sd	s0,16(sp)
    80005926:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005928:	fe040613          	addi	a2,s0,-32
    8000592c:	fec40593          	addi	a1,s0,-20
    80005930:	4501                	li	a0,0
    80005932:	00000097          	auipc	ra,0x0
    80005936:	cb8080e7          	jalr	-840(ra) # 800055ea <argfd>
    return -1;
    8000593a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000593c:	02054563          	bltz	a0,80005966 <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    80005940:	ffffc097          	auipc	ra,0xffffc
    80005944:	146080e7          	jalr	326(ra) # 80001a86 <myproc>
    80005948:	fec42783          	lw	a5,-20(s0)
    8000594c:	078e                	slli	a5,a5,0x3
    8000594e:	0d078793          	addi	a5,a5,208
    80005952:	953e                	add	a0,a0,a5
    80005954:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005958:	fe043503          	ld	a0,-32(s0)
    8000595c:	fffff097          	auipc	ra,0xfffff
    80005960:	1ec080e7          	jalr	492(ra) # 80004b48 <fileclose>
  return 0;
    80005964:	4781                	li	a5,0
}
    80005966:	853e                	mv	a0,a5
    80005968:	60e2                	ld	ra,24(sp)
    8000596a:	6442                	ld	s0,16(sp)
    8000596c:	6105                	addi	sp,sp,32
    8000596e:	8082                	ret

0000000080005970 <sys_fstat>:
{
    80005970:	1101                	addi	sp,sp,-32
    80005972:	ec06                	sd	ra,24(sp)
    80005974:	e822                	sd	s0,16(sp)
    80005976:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005978:	fe840613          	addi	a2,s0,-24
    8000597c:	4581                	li	a1,0
    8000597e:	4501                	li	a0,0
    80005980:	00000097          	auipc	ra,0x0
    80005984:	c6a080e7          	jalr	-918(ra) # 800055ea <argfd>
    return -1;
    80005988:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000598a:	02054563          	bltz	a0,800059b4 <sys_fstat+0x44>
    8000598e:	fe040593          	addi	a1,s0,-32
    80005992:	4505                	li	a0,1
    80005994:	ffffd097          	auipc	ra,0xffffd
    80005998:	56a080e7          	jalr	1386(ra) # 80002efe <argaddr>
    return -1;
    8000599c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000599e:	00054b63          	bltz	a0,800059b4 <sys_fstat+0x44>
  return filestat(f, st);
    800059a2:	fe043583          	ld	a1,-32(s0)
    800059a6:	fe843503          	ld	a0,-24(s0)
    800059aa:	fffff097          	auipc	ra,0xfffff
    800059ae:	280080e7          	jalr	640(ra) # 80004c2a <filestat>
    800059b2:	87aa                	mv	a5,a0
}
    800059b4:	853e                	mv	a0,a5
    800059b6:	60e2                	ld	ra,24(sp)
    800059b8:	6442                	ld	s0,16(sp)
    800059ba:	6105                	addi	sp,sp,32
    800059bc:	8082                	ret

00000000800059be <sys_link>:
{
    800059be:	7169                	addi	sp,sp,-304
    800059c0:	f606                	sd	ra,296(sp)
    800059c2:	f222                	sd	s0,288(sp)
    800059c4:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059c6:	08000613          	li	a2,128
    800059ca:	ed040593          	addi	a1,s0,-304
    800059ce:	4501                	li	a0,0
    800059d0:	ffffd097          	auipc	ra,0xffffd
    800059d4:	550080e7          	jalr	1360(ra) # 80002f20 <argstr>
    return -1;
    800059d8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059da:	12054663          	bltz	a0,80005b06 <sys_link+0x148>
    800059de:	08000613          	li	a2,128
    800059e2:	f5040593          	addi	a1,s0,-176
    800059e6:	4505                	li	a0,1
    800059e8:	ffffd097          	auipc	ra,0xffffd
    800059ec:	538080e7          	jalr	1336(ra) # 80002f20 <argstr>
    return -1;
    800059f0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059f2:	10054a63          	bltz	a0,80005b06 <sys_link+0x148>
    800059f6:	ee26                	sd	s1,280(sp)
  begin_op();
    800059f8:	fffff097          	auipc	ra,0xfffff
    800059fc:	c6e080e7          	jalr	-914(ra) # 80004666 <begin_op>
  if((ip = namei(old)) == 0){
    80005a00:	ed040513          	addi	a0,s0,-304
    80005a04:	fffff097          	auipc	ra,0xfffff
    80005a08:	a5c080e7          	jalr	-1444(ra) # 80004460 <namei>
    80005a0c:	84aa                	mv	s1,a0
    80005a0e:	c949                	beqz	a0,80005aa0 <sys_link+0xe2>
  ilock(ip);
    80005a10:	ffffe097          	auipc	ra,0xffffe
    80005a14:	25e080e7          	jalr	606(ra) # 80003c6e <ilock>
  if(ip->type == T_DIR){
    80005a18:	04449703          	lh	a4,68(s1)
    80005a1c:	4785                	li	a5,1
    80005a1e:	08f70863          	beq	a4,a5,80005aae <sys_link+0xf0>
    80005a22:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005a24:	04a4d783          	lhu	a5,74(s1)
    80005a28:	2785                	addiw	a5,a5,1
    80005a2a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a2e:	8526                	mv	a0,s1
    80005a30:	ffffe097          	auipc	ra,0xffffe
    80005a34:	172080e7          	jalr	370(ra) # 80003ba2 <iupdate>
  iunlock(ip);
    80005a38:	8526                	mv	a0,s1
    80005a3a:	ffffe097          	auipc	ra,0xffffe
    80005a3e:	2fa080e7          	jalr	762(ra) # 80003d34 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005a42:	fd040593          	addi	a1,s0,-48
    80005a46:	f5040513          	addi	a0,s0,-176
    80005a4a:	fffff097          	auipc	ra,0xfffff
    80005a4e:	a34080e7          	jalr	-1484(ra) # 8000447e <nameiparent>
    80005a52:	892a                	mv	s2,a0
    80005a54:	cd35                	beqz	a0,80005ad0 <sys_link+0x112>
  ilock(dp);
    80005a56:	ffffe097          	auipc	ra,0xffffe
    80005a5a:	218080e7          	jalr	536(ra) # 80003c6e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005a5e:	854a                	mv	a0,s2
    80005a60:	00092703          	lw	a4,0(s2)
    80005a64:	409c                	lw	a5,0(s1)
    80005a66:	06f71063          	bne	a4,a5,80005ac6 <sys_link+0x108>
    80005a6a:	40d0                	lw	a2,4(s1)
    80005a6c:	fd040593          	addi	a1,s0,-48
    80005a70:	fffff097          	auipc	ra,0xfffff
    80005a74:	91a080e7          	jalr	-1766(ra) # 8000438a <dirlink>
    80005a78:	04054763          	bltz	a0,80005ac6 <sys_link+0x108>
  iunlockput(dp);
    80005a7c:	854a                	mv	a0,s2
    80005a7e:	ffffe097          	auipc	ra,0xffffe
    80005a82:	458080e7          	jalr	1112(ra) # 80003ed6 <iunlockput>
  iput(ip);
    80005a86:	8526                	mv	a0,s1
    80005a88:	ffffe097          	auipc	ra,0xffffe
    80005a8c:	3a4080e7          	jalr	932(ra) # 80003e2c <iput>
  end_op();
    80005a90:	fffff097          	auipc	ra,0xfffff
    80005a94:	c56080e7          	jalr	-938(ra) # 800046e6 <end_op>
  return 0;
    80005a98:	4781                	li	a5,0
    80005a9a:	64f2                	ld	s1,280(sp)
    80005a9c:	6952                	ld	s2,272(sp)
    80005a9e:	a0a5                	j	80005b06 <sys_link+0x148>
    end_op();
    80005aa0:	fffff097          	auipc	ra,0xfffff
    80005aa4:	c46080e7          	jalr	-954(ra) # 800046e6 <end_op>
    return -1;
    80005aa8:	57fd                	li	a5,-1
    80005aaa:	64f2                	ld	s1,280(sp)
    80005aac:	a8a9                	j	80005b06 <sys_link+0x148>
    iunlockput(ip);
    80005aae:	8526                	mv	a0,s1
    80005ab0:	ffffe097          	auipc	ra,0xffffe
    80005ab4:	426080e7          	jalr	1062(ra) # 80003ed6 <iunlockput>
    end_op();
    80005ab8:	fffff097          	auipc	ra,0xfffff
    80005abc:	c2e080e7          	jalr	-978(ra) # 800046e6 <end_op>
    return -1;
    80005ac0:	57fd                	li	a5,-1
    80005ac2:	64f2                	ld	s1,280(sp)
    80005ac4:	a089                	j	80005b06 <sys_link+0x148>
    iunlockput(dp);
    80005ac6:	854a                	mv	a0,s2
    80005ac8:	ffffe097          	auipc	ra,0xffffe
    80005acc:	40e080e7          	jalr	1038(ra) # 80003ed6 <iunlockput>
  ilock(ip);
    80005ad0:	8526                	mv	a0,s1
    80005ad2:	ffffe097          	auipc	ra,0xffffe
    80005ad6:	19c080e7          	jalr	412(ra) # 80003c6e <ilock>
  ip->nlink--;
    80005ada:	04a4d783          	lhu	a5,74(s1)
    80005ade:	37fd                	addiw	a5,a5,-1
    80005ae0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005ae4:	8526                	mv	a0,s1
    80005ae6:	ffffe097          	auipc	ra,0xffffe
    80005aea:	0bc080e7          	jalr	188(ra) # 80003ba2 <iupdate>
  iunlockput(ip);
    80005aee:	8526                	mv	a0,s1
    80005af0:	ffffe097          	auipc	ra,0xffffe
    80005af4:	3e6080e7          	jalr	998(ra) # 80003ed6 <iunlockput>
  end_op();
    80005af8:	fffff097          	auipc	ra,0xfffff
    80005afc:	bee080e7          	jalr	-1042(ra) # 800046e6 <end_op>
  return -1;
    80005b00:	57fd                	li	a5,-1
    80005b02:	64f2                	ld	s1,280(sp)
    80005b04:	6952                	ld	s2,272(sp)
}
    80005b06:	853e                	mv	a0,a5
    80005b08:	70b2                	ld	ra,296(sp)
    80005b0a:	7412                	ld	s0,288(sp)
    80005b0c:	6155                	addi	sp,sp,304
    80005b0e:	8082                	ret

0000000080005b10 <sys_unlink>:
{
    80005b10:	7151                	addi	sp,sp,-240
    80005b12:	f586                	sd	ra,232(sp)
    80005b14:	f1a2                	sd	s0,224(sp)
    80005b16:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005b18:	08000613          	li	a2,128
    80005b1c:	f3040593          	addi	a1,s0,-208
    80005b20:	4501                	li	a0,0
    80005b22:	ffffd097          	auipc	ra,0xffffd
    80005b26:	3fe080e7          	jalr	1022(ra) # 80002f20 <argstr>
    80005b2a:	1a054763          	bltz	a0,80005cd8 <sys_unlink+0x1c8>
    80005b2e:	eda6                	sd	s1,216(sp)
  begin_op();
    80005b30:	fffff097          	auipc	ra,0xfffff
    80005b34:	b36080e7          	jalr	-1226(ra) # 80004666 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005b38:	fb040593          	addi	a1,s0,-80
    80005b3c:	f3040513          	addi	a0,s0,-208
    80005b40:	fffff097          	auipc	ra,0xfffff
    80005b44:	93e080e7          	jalr	-1730(ra) # 8000447e <nameiparent>
    80005b48:	84aa                	mv	s1,a0
    80005b4a:	c165                	beqz	a0,80005c2a <sys_unlink+0x11a>
  ilock(dp);
    80005b4c:	ffffe097          	auipc	ra,0xffffe
    80005b50:	122080e7          	jalr	290(ra) # 80003c6e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005b54:	00003597          	auipc	a1,0x3
    80005b58:	b6c58593          	addi	a1,a1,-1172 # 800086c0 <etext+0x6c0>
    80005b5c:	fb040513          	addi	a0,s0,-80
    80005b60:	ffffe097          	auipc	ra,0xffffe
    80005b64:	5e2080e7          	jalr	1506(ra) # 80004142 <namecmp>
    80005b68:	14050963          	beqz	a0,80005cba <sys_unlink+0x1aa>
    80005b6c:	00003597          	auipc	a1,0x3
    80005b70:	b5c58593          	addi	a1,a1,-1188 # 800086c8 <etext+0x6c8>
    80005b74:	fb040513          	addi	a0,s0,-80
    80005b78:	ffffe097          	auipc	ra,0xffffe
    80005b7c:	5ca080e7          	jalr	1482(ra) # 80004142 <namecmp>
    80005b80:	12050d63          	beqz	a0,80005cba <sys_unlink+0x1aa>
    80005b84:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005b86:	f2c40613          	addi	a2,s0,-212
    80005b8a:	fb040593          	addi	a1,s0,-80
    80005b8e:	8526                	mv	a0,s1
    80005b90:	ffffe097          	auipc	ra,0xffffe
    80005b94:	5cc080e7          	jalr	1484(ra) # 8000415c <dirlookup>
    80005b98:	892a                	mv	s2,a0
    80005b9a:	10050f63          	beqz	a0,80005cb8 <sys_unlink+0x1a8>
    80005b9e:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80005ba0:	ffffe097          	auipc	ra,0xffffe
    80005ba4:	0ce080e7          	jalr	206(ra) # 80003c6e <ilock>
  if(ip->nlink < 1)
    80005ba8:	04a91783          	lh	a5,74(s2)
    80005bac:	08f05663          	blez	a5,80005c38 <sys_unlink+0x128>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005bb0:	04491703          	lh	a4,68(s2)
    80005bb4:	4785                	li	a5,1
    80005bb6:	08f70963          	beq	a4,a5,80005c48 <sys_unlink+0x138>
  memset(&de, 0, sizeof(de));
    80005bba:	fc040993          	addi	s3,s0,-64
    80005bbe:	4641                	li	a2,16
    80005bc0:	4581                	li	a1,0
    80005bc2:	854e                	mv	a0,s3
    80005bc4:	ffffb097          	auipc	ra,0xffffb
    80005bc8:	188080e7          	jalr	392(ra) # 80000d4c <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005bcc:	4741                	li	a4,16
    80005bce:	f2c42683          	lw	a3,-212(s0)
    80005bd2:	864e                	mv	a2,s3
    80005bd4:	4581                	li	a1,0
    80005bd6:	8526                	mv	a0,s1
    80005bd8:	ffffe097          	auipc	ra,0xffffe
    80005bdc:	44e080e7          	jalr	1102(ra) # 80004026 <writei>
    80005be0:	47c1                	li	a5,16
    80005be2:	0af51863          	bne	a0,a5,80005c92 <sys_unlink+0x182>
  if(ip->type == T_DIR){
    80005be6:	04491703          	lh	a4,68(s2)
    80005bea:	4785                	li	a5,1
    80005bec:	0af70b63          	beq	a4,a5,80005ca2 <sys_unlink+0x192>
  iunlockput(dp);
    80005bf0:	8526                	mv	a0,s1
    80005bf2:	ffffe097          	auipc	ra,0xffffe
    80005bf6:	2e4080e7          	jalr	740(ra) # 80003ed6 <iunlockput>
  ip->nlink--;
    80005bfa:	04a95783          	lhu	a5,74(s2)
    80005bfe:	37fd                	addiw	a5,a5,-1
    80005c00:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005c04:	854a                	mv	a0,s2
    80005c06:	ffffe097          	auipc	ra,0xffffe
    80005c0a:	f9c080e7          	jalr	-100(ra) # 80003ba2 <iupdate>
  iunlockput(ip);
    80005c0e:	854a                	mv	a0,s2
    80005c10:	ffffe097          	auipc	ra,0xffffe
    80005c14:	2c6080e7          	jalr	710(ra) # 80003ed6 <iunlockput>
  end_op();
    80005c18:	fffff097          	auipc	ra,0xfffff
    80005c1c:	ace080e7          	jalr	-1330(ra) # 800046e6 <end_op>
  return 0;
    80005c20:	4501                	li	a0,0
    80005c22:	64ee                	ld	s1,216(sp)
    80005c24:	694e                	ld	s2,208(sp)
    80005c26:	69ae                	ld	s3,200(sp)
    80005c28:	a065                	j	80005cd0 <sys_unlink+0x1c0>
    end_op();
    80005c2a:	fffff097          	auipc	ra,0xfffff
    80005c2e:	abc080e7          	jalr	-1348(ra) # 800046e6 <end_op>
    return -1;
    80005c32:	557d                	li	a0,-1
    80005c34:	64ee                	ld	s1,216(sp)
    80005c36:	a869                	j	80005cd0 <sys_unlink+0x1c0>
    panic("unlink: nlink < 1");
    80005c38:	00003517          	auipc	a0,0x3
    80005c3c:	ab850513          	addi	a0,a0,-1352 # 800086f0 <etext+0x6f0>
    80005c40:	ffffb097          	auipc	ra,0xffffb
    80005c44:	916080e7          	jalr	-1770(ra) # 80000556 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005c48:	04c92703          	lw	a4,76(s2)
    80005c4c:	02000793          	li	a5,32
    80005c50:	f6e7f5e3          	bgeu	a5,a4,80005bba <sys_unlink+0xaa>
    80005c54:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005c56:	4741                	li	a4,16
    80005c58:	86ce                	mv	a3,s3
    80005c5a:	f1840613          	addi	a2,s0,-232
    80005c5e:	4581                	li	a1,0
    80005c60:	854a                	mv	a0,s2
    80005c62:	ffffe097          	auipc	ra,0xffffe
    80005c66:	2ca080e7          	jalr	714(ra) # 80003f2c <readi>
    80005c6a:	47c1                	li	a5,16
    80005c6c:	00f51b63          	bne	a0,a5,80005c82 <sys_unlink+0x172>
    if(de.inum != 0)
    80005c70:	f1845783          	lhu	a5,-232(s0)
    80005c74:	e7a5                	bnez	a5,80005cdc <sys_unlink+0x1cc>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005c76:	29c1                	addiw	s3,s3,16
    80005c78:	04c92783          	lw	a5,76(s2)
    80005c7c:	fcf9ede3          	bltu	s3,a5,80005c56 <sys_unlink+0x146>
    80005c80:	bf2d                	j	80005bba <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005c82:	00003517          	auipc	a0,0x3
    80005c86:	a8650513          	addi	a0,a0,-1402 # 80008708 <etext+0x708>
    80005c8a:	ffffb097          	auipc	ra,0xffffb
    80005c8e:	8cc080e7          	jalr	-1844(ra) # 80000556 <panic>
    panic("unlink: writei");
    80005c92:	00003517          	auipc	a0,0x3
    80005c96:	a8e50513          	addi	a0,a0,-1394 # 80008720 <etext+0x720>
    80005c9a:	ffffb097          	auipc	ra,0xffffb
    80005c9e:	8bc080e7          	jalr	-1860(ra) # 80000556 <panic>
    dp->nlink--;
    80005ca2:	04a4d783          	lhu	a5,74(s1)
    80005ca6:	37fd                	addiw	a5,a5,-1
    80005ca8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005cac:	8526                	mv	a0,s1
    80005cae:	ffffe097          	auipc	ra,0xffffe
    80005cb2:	ef4080e7          	jalr	-268(ra) # 80003ba2 <iupdate>
    80005cb6:	bf2d                	j	80005bf0 <sys_unlink+0xe0>
    80005cb8:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005cba:	8526                	mv	a0,s1
    80005cbc:	ffffe097          	auipc	ra,0xffffe
    80005cc0:	21a080e7          	jalr	538(ra) # 80003ed6 <iunlockput>
  end_op();
    80005cc4:	fffff097          	auipc	ra,0xfffff
    80005cc8:	a22080e7          	jalr	-1502(ra) # 800046e6 <end_op>
  return -1;
    80005ccc:	557d                	li	a0,-1
    80005cce:	64ee                	ld	s1,216(sp)
}
    80005cd0:	70ae                	ld	ra,232(sp)
    80005cd2:	740e                	ld	s0,224(sp)
    80005cd4:	616d                	addi	sp,sp,240
    80005cd6:	8082                	ret
    return -1;
    80005cd8:	557d                	li	a0,-1
    80005cda:	bfdd                	j	80005cd0 <sys_unlink+0x1c0>
    iunlockput(ip);
    80005cdc:	854a                	mv	a0,s2
    80005cde:	ffffe097          	auipc	ra,0xffffe
    80005ce2:	1f8080e7          	jalr	504(ra) # 80003ed6 <iunlockput>
    goto bad;
    80005ce6:	694e                	ld	s2,208(sp)
    80005ce8:	69ae                	ld	s3,200(sp)
    80005cea:	bfc1                	j	80005cba <sys_unlink+0x1aa>

0000000080005cec <sys_open>:

uint64
sys_open(void)
{
    80005cec:	7131                	addi	sp,sp,-192
    80005cee:	fd06                	sd	ra,184(sp)
    80005cf0:	f922                	sd	s0,176(sp)
    80005cf2:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005cf4:	08000613          	li	a2,128
    80005cf8:	f5040593          	addi	a1,s0,-176
    80005cfc:	4501                	li	a0,0
    80005cfe:	ffffd097          	auipc	ra,0xffffd
    80005d02:	222080e7          	jalr	546(ra) # 80002f20 <argstr>
    return -1;
    80005d06:	57fd                	li	a5,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005d08:	0c054963          	bltz	a0,80005dda <sys_open+0xee>
    80005d0c:	f4c40593          	addi	a1,s0,-180
    80005d10:	4505                	li	a0,1
    80005d12:	ffffd097          	auipc	ra,0xffffd
    80005d16:	1ca080e7          	jalr	458(ra) # 80002edc <argint>
    return -1;
    80005d1a:	57fd                	li	a5,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005d1c:	0a054f63          	bltz	a0,80005dda <sys_open+0xee>
    80005d20:	f526                	sd	s1,168(sp)

  begin_op();
    80005d22:	fffff097          	auipc	ra,0xfffff
    80005d26:	944080e7          	jalr	-1724(ra) # 80004666 <begin_op>

  if(omode & O_CREATE){
    80005d2a:	f4c42783          	lw	a5,-180(s0)
    80005d2e:	2007f793          	andi	a5,a5,512
    80005d32:	c3e1                	beqz	a5,80005df2 <sys_open+0x106>
    ip = create(path, T_FILE, 0, 0);
    80005d34:	4681                	li	a3,0
    80005d36:	4601                	li	a2,0
    80005d38:	4589                	li	a1,2
    80005d3a:	f5040513          	addi	a0,s0,-176
    80005d3e:	00000097          	auipc	ra,0x0
    80005d42:	95a080e7          	jalr	-1702(ra) # 80005698 <create>
    80005d46:	84aa                	mv	s1,a0
    if(ip == 0){
    80005d48:	cd51                	beqz	a0,80005de4 <sys_open+0xf8>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005d4a:	04449703          	lh	a4,68(s1)
    80005d4e:	478d                	li	a5,3
    80005d50:	00f71763          	bne	a4,a5,80005d5e <sys_open+0x72>
    80005d54:	0464d703          	lhu	a4,70(s1)
    80005d58:	47a5                	li	a5,9
    80005d5a:	0ee7e363          	bltu	a5,a4,80005e40 <sys_open+0x154>
    80005d5e:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005d60:	fffff097          	auipc	ra,0xfffff
    80005d64:	d2c080e7          	jalr	-724(ra) # 80004a8c <filealloc>
    80005d68:	892a                	mv	s2,a0
    80005d6a:	cd6d                	beqz	a0,80005e64 <sys_open+0x178>
    80005d6c:	ed4e                	sd	s3,152(sp)
    80005d6e:	00000097          	auipc	ra,0x0
    80005d72:	8e6080e7          	jalr	-1818(ra) # 80005654 <fdalloc>
    80005d76:	89aa                	mv	s3,a0
    80005d78:	0e054063          	bltz	a0,80005e58 <sys_open+0x16c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005d7c:	04449703          	lh	a4,68(s1)
    80005d80:	478d                	li	a5,3
    80005d82:	0ef70e63          	beq	a4,a5,80005e7e <sys_open+0x192>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005d86:	4789                	li	a5,2
    80005d88:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005d8c:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005d90:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005d94:	f4c42783          	lw	a5,-180(s0)
    80005d98:	0017f713          	andi	a4,a5,1
    80005d9c:	00174713          	xori	a4,a4,1
    80005da0:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005da4:	0037f713          	andi	a4,a5,3
    80005da8:	00e03733          	snez	a4,a4
    80005dac:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005db0:	4007f793          	andi	a5,a5,1024
    80005db4:	c791                	beqz	a5,80005dc0 <sys_open+0xd4>
    80005db6:	04449703          	lh	a4,68(s1)
    80005dba:	4789                	li	a5,2
    80005dbc:	0cf70863          	beq	a4,a5,80005e8c <sys_open+0x1a0>
    itrunc(ip);
  }

  iunlock(ip);
    80005dc0:	8526                	mv	a0,s1
    80005dc2:	ffffe097          	auipc	ra,0xffffe
    80005dc6:	f72080e7          	jalr	-142(ra) # 80003d34 <iunlock>
  end_op();
    80005dca:	fffff097          	auipc	ra,0xfffff
    80005dce:	91c080e7          	jalr	-1764(ra) # 800046e6 <end_op>

  return fd;
    80005dd2:	87ce                	mv	a5,s3
    80005dd4:	74aa                	ld	s1,168(sp)
    80005dd6:	790a                	ld	s2,160(sp)
    80005dd8:	69ea                	ld	s3,152(sp)
}
    80005dda:	853e                	mv	a0,a5
    80005ddc:	70ea                	ld	ra,184(sp)
    80005dde:	744a                	ld	s0,176(sp)
    80005de0:	6129                	addi	sp,sp,192
    80005de2:	8082                	ret
      end_op();
    80005de4:	fffff097          	auipc	ra,0xfffff
    80005de8:	902080e7          	jalr	-1790(ra) # 800046e6 <end_op>
      return -1;
    80005dec:	57fd                	li	a5,-1
    80005dee:	74aa                	ld	s1,168(sp)
    80005df0:	b7ed                	j	80005dda <sys_open+0xee>
    if((ip = namei(path)) == 0){
    80005df2:	f5040513          	addi	a0,s0,-176
    80005df6:	ffffe097          	auipc	ra,0xffffe
    80005dfa:	66a080e7          	jalr	1642(ra) # 80004460 <namei>
    80005dfe:	84aa                	mv	s1,a0
    80005e00:	c90d                	beqz	a0,80005e32 <sys_open+0x146>
    ilock(ip);
    80005e02:	ffffe097          	auipc	ra,0xffffe
    80005e06:	e6c080e7          	jalr	-404(ra) # 80003c6e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005e0a:	04449703          	lh	a4,68(s1)
    80005e0e:	4785                	li	a5,1
    80005e10:	f2f71de3          	bne	a4,a5,80005d4a <sys_open+0x5e>
    80005e14:	f4c42783          	lw	a5,-180(s0)
    80005e18:	d3b9                	beqz	a5,80005d5e <sys_open+0x72>
      iunlockput(ip);
    80005e1a:	8526                	mv	a0,s1
    80005e1c:	ffffe097          	auipc	ra,0xffffe
    80005e20:	0ba080e7          	jalr	186(ra) # 80003ed6 <iunlockput>
      end_op();
    80005e24:	fffff097          	auipc	ra,0xfffff
    80005e28:	8c2080e7          	jalr	-1854(ra) # 800046e6 <end_op>
      return -1;
    80005e2c:	57fd                	li	a5,-1
    80005e2e:	74aa                	ld	s1,168(sp)
    80005e30:	b76d                	j	80005dda <sys_open+0xee>
      end_op();
    80005e32:	fffff097          	auipc	ra,0xfffff
    80005e36:	8b4080e7          	jalr	-1868(ra) # 800046e6 <end_op>
      return -1;
    80005e3a:	57fd                	li	a5,-1
    80005e3c:	74aa                	ld	s1,168(sp)
    80005e3e:	bf71                	j	80005dda <sys_open+0xee>
    iunlockput(ip);
    80005e40:	8526                	mv	a0,s1
    80005e42:	ffffe097          	auipc	ra,0xffffe
    80005e46:	094080e7          	jalr	148(ra) # 80003ed6 <iunlockput>
    end_op();
    80005e4a:	fffff097          	auipc	ra,0xfffff
    80005e4e:	89c080e7          	jalr	-1892(ra) # 800046e6 <end_op>
    return -1;
    80005e52:	57fd                	li	a5,-1
    80005e54:	74aa                	ld	s1,168(sp)
    80005e56:	b751                	j	80005dda <sys_open+0xee>
      fileclose(f);
    80005e58:	854a                	mv	a0,s2
    80005e5a:	fffff097          	auipc	ra,0xfffff
    80005e5e:	cee080e7          	jalr	-786(ra) # 80004b48 <fileclose>
    80005e62:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005e64:	8526                	mv	a0,s1
    80005e66:	ffffe097          	auipc	ra,0xffffe
    80005e6a:	070080e7          	jalr	112(ra) # 80003ed6 <iunlockput>
    end_op();
    80005e6e:	fffff097          	auipc	ra,0xfffff
    80005e72:	878080e7          	jalr	-1928(ra) # 800046e6 <end_op>
    return -1;
    80005e76:	57fd                	li	a5,-1
    80005e78:	74aa                	ld	s1,168(sp)
    80005e7a:	790a                	ld	s2,160(sp)
    80005e7c:	bfb9                	j	80005dda <sys_open+0xee>
    f->type = FD_DEVICE;
    80005e7e:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005e82:	04649783          	lh	a5,70(s1)
    80005e86:	02f91223          	sh	a5,36(s2)
    80005e8a:	b719                	j	80005d90 <sys_open+0xa4>
    itrunc(ip);
    80005e8c:	8526                	mv	a0,s1
    80005e8e:	ffffe097          	auipc	ra,0xffffe
    80005e92:	ef2080e7          	jalr	-270(ra) # 80003d80 <itrunc>
    80005e96:	b72d                	j	80005dc0 <sys_open+0xd4>

0000000080005e98 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005e98:	7175                	addi	sp,sp,-144
    80005e9a:	e506                	sd	ra,136(sp)
    80005e9c:	e122                	sd	s0,128(sp)
    80005e9e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005ea0:	ffffe097          	auipc	ra,0xffffe
    80005ea4:	7c6080e7          	jalr	1990(ra) # 80004666 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005ea8:	08000613          	li	a2,128
    80005eac:	f7040593          	addi	a1,s0,-144
    80005eb0:	4501                	li	a0,0
    80005eb2:	ffffd097          	auipc	ra,0xffffd
    80005eb6:	06e080e7          	jalr	110(ra) # 80002f20 <argstr>
    80005eba:	02054963          	bltz	a0,80005eec <sys_mkdir+0x54>
    80005ebe:	4681                	li	a3,0
    80005ec0:	4601                	li	a2,0
    80005ec2:	4585                	li	a1,1
    80005ec4:	f7040513          	addi	a0,s0,-144
    80005ec8:	fffff097          	auipc	ra,0xfffff
    80005ecc:	7d0080e7          	jalr	2000(ra) # 80005698 <create>
    80005ed0:	cd11                	beqz	a0,80005eec <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ed2:	ffffe097          	auipc	ra,0xffffe
    80005ed6:	004080e7          	jalr	4(ra) # 80003ed6 <iunlockput>
  end_op();
    80005eda:	fffff097          	auipc	ra,0xfffff
    80005ede:	80c080e7          	jalr	-2036(ra) # 800046e6 <end_op>
  return 0;
    80005ee2:	4501                	li	a0,0
}
    80005ee4:	60aa                	ld	ra,136(sp)
    80005ee6:	640a                	ld	s0,128(sp)
    80005ee8:	6149                	addi	sp,sp,144
    80005eea:	8082                	ret
    end_op();
    80005eec:	ffffe097          	auipc	ra,0xffffe
    80005ef0:	7fa080e7          	jalr	2042(ra) # 800046e6 <end_op>
    return -1;
    80005ef4:	557d                	li	a0,-1
    80005ef6:	b7fd                	j	80005ee4 <sys_mkdir+0x4c>

0000000080005ef8 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005ef8:	7135                	addi	sp,sp,-160
    80005efa:	ed06                	sd	ra,152(sp)
    80005efc:	e922                	sd	s0,144(sp)
    80005efe:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005f00:	ffffe097          	auipc	ra,0xffffe
    80005f04:	766080e7          	jalr	1894(ra) # 80004666 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005f08:	08000613          	li	a2,128
    80005f0c:	f7040593          	addi	a1,s0,-144
    80005f10:	4501                	li	a0,0
    80005f12:	ffffd097          	auipc	ra,0xffffd
    80005f16:	00e080e7          	jalr	14(ra) # 80002f20 <argstr>
    80005f1a:	04054a63          	bltz	a0,80005f6e <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005f1e:	f6c40593          	addi	a1,s0,-148
    80005f22:	4505                	li	a0,1
    80005f24:	ffffd097          	auipc	ra,0xffffd
    80005f28:	fb8080e7          	jalr	-72(ra) # 80002edc <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005f2c:	04054163          	bltz	a0,80005f6e <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005f30:	f6840593          	addi	a1,s0,-152
    80005f34:	4509                	li	a0,2
    80005f36:	ffffd097          	auipc	ra,0xffffd
    80005f3a:	fa6080e7          	jalr	-90(ra) # 80002edc <argint>
     argint(1, &major) < 0 ||
    80005f3e:	02054863          	bltz	a0,80005f6e <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005f42:	f6841683          	lh	a3,-152(s0)
    80005f46:	f6c41603          	lh	a2,-148(s0)
    80005f4a:	458d                	li	a1,3
    80005f4c:	f7040513          	addi	a0,s0,-144
    80005f50:	fffff097          	auipc	ra,0xfffff
    80005f54:	748080e7          	jalr	1864(ra) # 80005698 <create>
     argint(2, &minor) < 0 ||
    80005f58:	c919                	beqz	a0,80005f6e <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005f5a:	ffffe097          	auipc	ra,0xffffe
    80005f5e:	f7c080e7          	jalr	-132(ra) # 80003ed6 <iunlockput>
  end_op();
    80005f62:	ffffe097          	auipc	ra,0xffffe
    80005f66:	784080e7          	jalr	1924(ra) # 800046e6 <end_op>
  return 0;
    80005f6a:	4501                	li	a0,0
    80005f6c:	a031                	j	80005f78 <sys_mknod+0x80>
    end_op();
    80005f6e:	ffffe097          	auipc	ra,0xffffe
    80005f72:	778080e7          	jalr	1912(ra) # 800046e6 <end_op>
    return -1;
    80005f76:	557d                	li	a0,-1
}
    80005f78:	60ea                	ld	ra,152(sp)
    80005f7a:	644a                	ld	s0,144(sp)
    80005f7c:	610d                	addi	sp,sp,160
    80005f7e:	8082                	ret

0000000080005f80 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005f80:	7135                	addi	sp,sp,-160
    80005f82:	ed06                	sd	ra,152(sp)
    80005f84:	e922                	sd	s0,144(sp)
    80005f86:	e14a                	sd	s2,128(sp)
    80005f88:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005f8a:	ffffc097          	auipc	ra,0xffffc
    80005f8e:	afc080e7          	jalr	-1284(ra) # 80001a86 <myproc>
    80005f92:	892a                	mv	s2,a0
  
  begin_op();
    80005f94:	ffffe097          	auipc	ra,0xffffe
    80005f98:	6d2080e7          	jalr	1746(ra) # 80004666 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005f9c:	08000613          	li	a2,128
    80005fa0:	f6040593          	addi	a1,s0,-160
    80005fa4:	4501                	li	a0,0
    80005fa6:	ffffd097          	auipc	ra,0xffffd
    80005faa:	f7a080e7          	jalr	-134(ra) # 80002f20 <argstr>
    80005fae:	04054d63          	bltz	a0,80006008 <sys_chdir+0x88>
    80005fb2:	e526                	sd	s1,136(sp)
    80005fb4:	f6040513          	addi	a0,s0,-160
    80005fb8:	ffffe097          	auipc	ra,0xffffe
    80005fbc:	4a8080e7          	jalr	1192(ra) # 80004460 <namei>
    80005fc0:	84aa                	mv	s1,a0
    80005fc2:	c131                	beqz	a0,80006006 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005fc4:	ffffe097          	auipc	ra,0xffffe
    80005fc8:	caa080e7          	jalr	-854(ra) # 80003c6e <ilock>
  if(ip->type != T_DIR){
    80005fcc:	04449703          	lh	a4,68(s1)
    80005fd0:	4785                	li	a5,1
    80005fd2:	04f71163          	bne	a4,a5,80006014 <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005fd6:	8526                	mv	a0,s1
    80005fd8:	ffffe097          	auipc	ra,0xffffe
    80005fdc:	d5c080e7          	jalr	-676(ra) # 80003d34 <iunlock>
  iput(p->cwd);
    80005fe0:	15093503          	ld	a0,336(s2)
    80005fe4:	ffffe097          	auipc	ra,0xffffe
    80005fe8:	e48080e7          	jalr	-440(ra) # 80003e2c <iput>
  end_op();
    80005fec:	ffffe097          	auipc	ra,0xffffe
    80005ff0:	6fa080e7          	jalr	1786(ra) # 800046e6 <end_op>
  p->cwd = ip;
    80005ff4:	14993823          	sd	s1,336(s2)
  return 0;
    80005ff8:	4501                	li	a0,0
    80005ffa:	64aa                	ld	s1,136(sp)
}
    80005ffc:	60ea                	ld	ra,152(sp)
    80005ffe:	644a                	ld	s0,144(sp)
    80006000:	690a                	ld	s2,128(sp)
    80006002:	610d                	addi	sp,sp,160
    80006004:	8082                	ret
    80006006:	64aa                	ld	s1,136(sp)
    end_op();
    80006008:	ffffe097          	auipc	ra,0xffffe
    8000600c:	6de080e7          	jalr	1758(ra) # 800046e6 <end_op>
    return -1;
    80006010:	557d                	li	a0,-1
    80006012:	b7ed                	j	80005ffc <sys_chdir+0x7c>
    iunlockput(ip);
    80006014:	8526                	mv	a0,s1
    80006016:	ffffe097          	auipc	ra,0xffffe
    8000601a:	ec0080e7          	jalr	-320(ra) # 80003ed6 <iunlockput>
    end_op();
    8000601e:	ffffe097          	auipc	ra,0xffffe
    80006022:	6c8080e7          	jalr	1736(ra) # 800046e6 <end_op>
    return -1;
    80006026:	557d                	li	a0,-1
    80006028:	64aa                	ld	s1,136(sp)
    8000602a:	bfc9                	j	80005ffc <sys_chdir+0x7c>

000000008000602c <sys_exec>:

uint64
sys_exec(void)
{
    8000602c:	7145                	addi	sp,sp,-464
    8000602e:	e786                	sd	ra,456(sp)
    80006030:	e3a2                	sd	s0,448(sp)
    80006032:	fb4a                	sd	s2,432(sp)
    80006034:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006036:	08000613          	li	a2,128
    8000603a:	f4040593          	addi	a1,s0,-192
    8000603e:	4501                	li	a0,0
    80006040:	ffffd097          	auipc	ra,0xffffd
    80006044:	ee0080e7          	jalr	-288(ra) # 80002f20 <argstr>
    return -1;
    80006048:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    8000604a:	10054463          	bltz	a0,80006152 <sys_exec+0x126>
    8000604e:	e3840593          	addi	a1,s0,-456
    80006052:	4505                	li	a0,1
    80006054:	ffffd097          	auipc	ra,0xffffd
    80006058:	eaa080e7          	jalr	-342(ra) # 80002efe <argaddr>
    8000605c:	0e054b63          	bltz	a0,80006152 <sys_exec+0x126>
    80006060:	ff26                	sd	s1,440(sp)
    80006062:	f74e                	sd	s3,424(sp)
    80006064:	f352                	sd	s4,416(sp)
    80006066:	ef56                	sd	s5,408(sp)
    80006068:	eb5a                	sd	s6,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000606a:	10000613          	li	a2,256
    8000606e:	4581                	li	a1,0
    80006070:	e4040513          	addi	a0,s0,-448
    80006074:	ffffb097          	auipc	ra,0xffffb
    80006078:	cd8080e7          	jalr	-808(ra) # 80000d4c <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000607c:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006080:	89a6                	mv	s3,s1
    80006082:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006084:	e3040a13          	addi	s4,s0,-464
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006088:	6a85                	lui	s5,0x1
    if(i >= NELEM(argv)){
    8000608a:	02000b13          	li	s6,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000608e:	00391513          	slli	a0,s2,0x3
    80006092:	85d2                	mv	a1,s4
    80006094:	e3843783          	ld	a5,-456(s0)
    80006098:	953e                	add	a0,a0,a5
    8000609a:	ffffd097          	auipc	ra,0xffffd
    8000609e:	da8080e7          	jalr	-600(ra) # 80002e42 <fetchaddr>
    800060a2:	02054a63          	bltz	a0,800060d6 <sys_exec+0xaa>
    if(uarg == 0){
    800060a6:	e3043783          	ld	a5,-464(s0)
    800060aa:	cba1                	beqz	a5,800060fa <sys_exec+0xce>
    argv[i] = kalloc();
    800060ac:	ffffb097          	auipc	ra,0xffffb
    800060b0:	aa4080e7          	jalr	-1372(ra) # 80000b50 <kalloc>
    800060b4:	85aa                	mv	a1,a0
    800060b6:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800060ba:	cd11                	beqz	a0,800060d6 <sys_exec+0xaa>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800060bc:	8656                	mv	a2,s5
    800060be:	e3043503          	ld	a0,-464(s0)
    800060c2:	ffffd097          	auipc	ra,0xffffd
    800060c6:	dd2080e7          	jalr	-558(ra) # 80002e94 <fetchstr>
    800060ca:	00054663          	bltz	a0,800060d6 <sys_exec+0xaa>
    if(i >= NELEM(argv)){
    800060ce:	0905                	addi	s2,s2,1
    800060d0:	09a1                	addi	s3,s3,8
    800060d2:	fb691ee3          	bne	s2,s6,8000608e <sys_exec+0x62>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060d6:	f4040913          	addi	s2,s0,-192
    800060da:	6088                	ld	a0,0(s1)
    800060dc:	c52d                	beqz	a0,80006146 <sys_exec+0x11a>
    kfree(argv[i]);
    800060de:	ffffb097          	auipc	ra,0xffffb
    800060e2:	96e080e7          	jalr	-1682(ra) # 80000a4c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060e6:	04a1                	addi	s1,s1,8
    800060e8:	ff2499e3          	bne	s1,s2,800060da <sys_exec+0xae>
  return -1;
    800060ec:	597d                	li	s2,-1
    800060ee:	74fa                	ld	s1,440(sp)
    800060f0:	79ba                	ld	s3,424(sp)
    800060f2:	7a1a                	ld	s4,416(sp)
    800060f4:	6afa                	ld	s5,408(sp)
    800060f6:	6b5a                	ld	s6,400(sp)
    800060f8:	a8a9                	j	80006152 <sys_exec+0x126>
      argv[i] = 0;
    800060fa:	0009079b          	sext.w	a5,s2
    800060fe:	e4040593          	addi	a1,s0,-448
    80006102:	078e                	slli	a5,a5,0x3
    80006104:	97ae                	add	a5,a5,a1
    80006106:	0007b023          	sd	zero,0(a5)
  int ret = exec(path, argv);
    8000610a:	f4040513          	addi	a0,s0,-192
    8000610e:	fffff097          	auipc	ra,0xfffff
    80006112:	128080e7          	jalr	296(ra) # 80005236 <exec>
    80006116:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006118:	f4040993          	addi	s3,s0,-192
    8000611c:	6088                	ld	a0,0(s1)
    8000611e:	cd11                	beqz	a0,8000613a <sys_exec+0x10e>
    kfree(argv[i]);
    80006120:	ffffb097          	auipc	ra,0xffffb
    80006124:	92c080e7          	jalr	-1748(ra) # 80000a4c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006128:	04a1                	addi	s1,s1,8
    8000612a:	ff3499e3          	bne	s1,s3,8000611c <sys_exec+0xf0>
    8000612e:	74fa                	ld	s1,440(sp)
    80006130:	79ba                	ld	s3,424(sp)
    80006132:	7a1a                	ld	s4,416(sp)
    80006134:	6afa                	ld	s5,408(sp)
    80006136:	6b5a                	ld	s6,400(sp)
    80006138:	a829                	j	80006152 <sys_exec+0x126>
  return ret;
    8000613a:	74fa                	ld	s1,440(sp)
    8000613c:	79ba                	ld	s3,424(sp)
    8000613e:	7a1a                	ld	s4,416(sp)
    80006140:	6afa                	ld	s5,408(sp)
    80006142:	6b5a                	ld	s6,400(sp)
    80006144:	a039                	j	80006152 <sys_exec+0x126>
  return -1;
    80006146:	597d                	li	s2,-1
    80006148:	74fa                	ld	s1,440(sp)
    8000614a:	79ba                	ld	s3,424(sp)
    8000614c:	7a1a                	ld	s4,416(sp)
    8000614e:	6afa                	ld	s5,408(sp)
    80006150:	6b5a                	ld	s6,400(sp)
}
    80006152:	854a                	mv	a0,s2
    80006154:	60be                	ld	ra,456(sp)
    80006156:	641e                	ld	s0,448(sp)
    80006158:	795a                	ld	s2,432(sp)
    8000615a:	6179                	addi	sp,sp,464
    8000615c:	8082                	ret

000000008000615e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000615e:	7139                	addi	sp,sp,-64
    80006160:	fc06                	sd	ra,56(sp)
    80006162:	f822                	sd	s0,48(sp)
    80006164:	f426                	sd	s1,40(sp)
    80006166:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006168:	ffffc097          	auipc	ra,0xffffc
    8000616c:	91e080e7          	jalr	-1762(ra) # 80001a86 <myproc>
    80006170:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006172:	fd840593          	addi	a1,s0,-40
    80006176:	4501                	li	a0,0
    80006178:	ffffd097          	auipc	ra,0xffffd
    8000617c:	d86080e7          	jalr	-634(ra) # 80002efe <argaddr>
    return -1;
    80006180:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006182:	0e054363          	bltz	a0,80006268 <sys_pipe+0x10a>
  if(pipealloc(&rf, &wf) < 0)
    80006186:	fc840593          	addi	a1,s0,-56
    8000618a:	fd040513          	addi	a0,s0,-48
    8000618e:	fffff097          	auipc	ra,0xfffff
    80006192:	d3a080e7          	jalr	-710(ra) # 80004ec8 <pipealloc>
    return -1;
    80006196:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006198:	0c054863          	bltz	a0,80006268 <sys_pipe+0x10a>
  fd0 = -1;
    8000619c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800061a0:	fd043503          	ld	a0,-48(s0)
    800061a4:	fffff097          	auipc	ra,0xfffff
    800061a8:	4b0080e7          	jalr	1200(ra) # 80005654 <fdalloc>
    800061ac:	fca42223          	sw	a0,-60(s0)
    800061b0:	08054f63          	bltz	a0,8000624e <sys_pipe+0xf0>
    800061b4:	fc843503          	ld	a0,-56(s0)
    800061b8:	fffff097          	auipc	ra,0xfffff
    800061bc:	49c080e7          	jalr	1180(ra) # 80005654 <fdalloc>
    800061c0:	fca42023          	sw	a0,-64(s0)
    800061c4:	06054b63          	bltz	a0,8000623a <sys_pipe+0xdc>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800061c8:	4691                	li	a3,4
    800061ca:	fc440613          	addi	a2,s0,-60
    800061ce:	fd843583          	ld	a1,-40(s0)
    800061d2:	68a8                	ld	a0,80(s1)
    800061d4:	ffffb097          	auipc	ra,0xffffb
    800061d8:	536080e7          	jalr	1334(ra) # 8000170a <copyout>
    800061dc:	02054063          	bltz	a0,800061fc <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800061e0:	4691                	li	a3,4
    800061e2:	fc040613          	addi	a2,s0,-64
    800061e6:	fd843583          	ld	a1,-40(s0)
    800061ea:	95b6                	add	a1,a1,a3
    800061ec:	68a8                	ld	a0,80(s1)
    800061ee:	ffffb097          	auipc	ra,0xffffb
    800061f2:	51c080e7          	jalr	1308(ra) # 8000170a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800061f6:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800061f8:	06055863          	bgez	a0,80006268 <sys_pipe+0x10a>
    p->ofile[fd0] = 0;
    800061fc:	fc442783          	lw	a5,-60(s0)
    80006200:	078e                	slli	a5,a5,0x3
    80006202:	0d078793          	addi	a5,a5,208
    80006206:	97a6                	add	a5,a5,s1
    80006208:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000620c:	fc042783          	lw	a5,-64(s0)
    80006210:	078e                	slli	a5,a5,0x3
    80006212:	0d078793          	addi	a5,a5,208
    80006216:	00f48533          	add	a0,s1,a5
    8000621a:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    8000621e:	fd043503          	ld	a0,-48(s0)
    80006222:	fffff097          	auipc	ra,0xfffff
    80006226:	926080e7          	jalr	-1754(ra) # 80004b48 <fileclose>
    fileclose(wf);
    8000622a:	fc843503          	ld	a0,-56(s0)
    8000622e:	fffff097          	auipc	ra,0xfffff
    80006232:	91a080e7          	jalr	-1766(ra) # 80004b48 <fileclose>
    return -1;
    80006236:	57fd                	li	a5,-1
    80006238:	a805                	j	80006268 <sys_pipe+0x10a>
    if(fd0 >= 0)
    8000623a:	fc442783          	lw	a5,-60(s0)
    8000623e:	0007c863          	bltz	a5,8000624e <sys_pipe+0xf0>
      p->ofile[fd0] = 0;
    80006242:	078e                	slli	a5,a5,0x3
    80006244:	0d078793          	addi	a5,a5,208
    80006248:	97a6                	add	a5,a5,s1
    8000624a:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000624e:	fd043503          	ld	a0,-48(s0)
    80006252:	fffff097          	auipc	ra,0xfffff
    80006256:	8f6080e7          	jalr	-1802(ra) # 80004b48 <fileclose>
    fileclose(wf);
    8000625a:	fc843503          	ld	a0,-56(s0)
    8000625e:	fffff097          	auipc	ra,0xfffff
    80006262:	8ea080e7          	jalr	-1814(ra) # 80004b48 <fileclose>
    return -1;
    80006266:	57fd                	li	a5,-1
}
    80006268:	853e                	mv	a0,a5
    8000626a:	70e2                	ld	ra,56(sp)
    8000626c:	7442                	ld	s0,48(sp)
    8000626e:	74a2                	ld	s1,40(sp)
    80006270:	6121                	addi	sp,sp,64
    80006272:	8082                	ret
	...

0000000080006280 <kernelvec>:
    80006280:	7111                	addi	sp,sp,-256
    80006282:	e006                	sd	ra,0(sp)
    80006284:	e40a                	sd	sp,8(sp)
    80006286:	e80e                	sd	gp,16(sp)
    80006288:	ec12                	sd	tp,24(sp)
    8000628a:	f016                	sd	t0,32(sp)
    8000628c:	f41a                	sd	t1,40(sp)
    8000628e:	f81e                	sd	t2,48(sp)
    80006290:	fc22                	sd	s0,56(sp)
    80006292:	e0a6                	sd	s1,64(sp)
    80006294:	e4aa                	sd	a0,72(sp)
    80006296:	e8ae                	sd	a1,80(sp)
    80006298:	ecb2                	sd	a2,88(sp)
    8000629a:	f0b6                	sd	a3,96(sp)
    8000629c:	f4ba                	sd	a4,104(sp)
    8000629e:	f8be                	sd	a5,112(sp)
    800062a0:	fcc2                	sd	a6,120(sp)
    800062a2:	e146                	sd	a7,128(sp)
    800062a4:	e54a                	sd	s2,136(sp)
    800062a6:	e94e                	sd	s3,144(sp)
    800062a8:	ed52                	sd	s4,152(sp)
    800062aa:	f156                	sd	s5,160(sp)
    800062ac:	f55a                	sd	s6,168(sp)
    800062ae:	f95e                	sd	s7,176(sp)
    800062b0:	fd62                	sd	s8,184(sp)
    800062b2:	e1e6                	sd	s9,192(sp)
    800062b4:	e5ea                	sd	s10,200(sp)
    800062b6:	e9ee                	sd	s11,208(sp)
    800062b8:	edf2                	sd	t3,216(sp)
    800062ba:	f1f6                	sd	t4,224(sp)
    800062bc:	f5fa                	sd	t5,232(sp)
    800062be:	f9fe                	sd	t6,240(sp)
    800062c0:	a4dfc0ef          	jal	80002d0c <kerneltrap>
    800062c4:	6082                	ld	ra,0(sp)
    800062c6:	6122                	ld	sp,8(sp)
    800062c8:	61c2                	ld	gp,16(sp)
    800062ca:	7282                	ld	t0,32(sp)
    800062cc:	7322                	ld	t1,40(sp)
    800062ce:	73c2                	ld	t2,48(sp)
    800062d0:	7462                	ld	s0,56(sp)
    800062d2:	6486                	ld	s1,64(sp)
    800062d4:	6526                	ld	a0,72(sp)
    800062d6:	65c6                	ld	a1,80(sp)
    800062d8:	6666                	ld	a2,88(sp)
    800062da:	7686                	ld	a3,96(sp)
    800062dc:	7726                	ld	a4,104(sp)
    800062de:	77c6                	ld	a5,112(sp)
    800062e0:	7866                	ld	a6,120(sp)
    800062e2:	688a                	ld	a7,128(sp)
    800062e4:	692a                	ld	s2,136(sp)
    800062e6:	69ca                	ld	s3,144(sp)
    800062e8:	6a6a                	ld	s4,152(sp)
    800062ea:	7a8a                	ld	s5,160(sp)
    800062ec:	7b2a                	ld	s6,168(sp)
    800062ee:	7bca                	ld	s7,176(sp)
    800062f0:	7c6a                	ld	s8,184(sp)
    800062f2:	6c8e                	ld	s9,192(sp)
    800062f4:	6d2e                	ld	s10,200(sp)
    800062f6:	6dce                	ld	s11,208(sp)
    800062f8:	6e6e                	ld	t3,216(sp)
    800062fa:	7e8e                	ld	t4,224(sp)
    800062fc:	7f2e                	ld	t5,232(sp)
    800062fe:	7fce                	ld	t6,240(sp)
    80006300:	6111                	addi	sp,sp,256
    80006302:	10200073          	sret
    80006306:	00000013          	nop
    8000630a:	00000013          	nop
    8000630e:	0001                	nop

0000000080006310 <timervec>:
    80006310:	34051573          	csrrw	a0,mscratch,a0
    80006314:	e10c                	sd	a1,0(a0)
    80006316:	e510                	sd	a2,8(a0)
    80006318:	e914                	sd	a3,16(a0)
    8000631a:	6d0c                	ld	a1,24(a0)
    8000631c:	7110                	ld	a2,32(a0)
    8000631e:	6194                	ld	a3,0(a1)
    80006320:	96b2                	add	a3,a3,a2
    80006322:	e194                	sd	a3,0(a1)
    80006324:	4589                	li	a1,2
    80006326:	14459073          	csrw	sip,a1
    8000632a:	6914                	ld	a3,16(a0)
    8000632c:	6510                	ld	a2,8(a0)
    8000632e:	610c                	ld	a1,0(a0)
    80006330:	34051573          	csrrw	a0,mscratch,a0
    80006334:	30200073          	mret
    80006338:	0001                	nop

000000008000633a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000633a:	1141                	addi	sp,sp,-16
    8000633c:	e406                	sd	ra,8(sp)
    8000633e:	e022                	sd	s0,0(sp)
    80006340:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006342:	0c000737          	lui	a4,0xc000
    80006346:	4785                	li	a5,1
    80006348:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000634a:	c35c                	sw	a5,4(a4)
}
    8000634c:	60a2                	ld	ra,8(sp)
    8000634e:	6402                	ld	s0,0(sp)
    80006350:	0141                	addi	sp,sp,16
    80006352:	8082                	ret

0000000080006354 <plicinithart>:

void
plicinithart(void)
{
    80006354:	1141                	addi	sp,sp,-16
    80006356:	e406                	sd	ra,8(sp)
    80006358:	e022                	sd	s0,0(sp)
    8000635a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000635c:	ffffb097          	auipc	ra,0xffffb
    80006360:	6f6080e7          	jalr	1782(ra) # 80001a52 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006364:	0085171b          	slliw	a4,a0,0x8
    80006368:	0c0027b7          	lui	a5,0xc002
    8000636c:	97ba                	add	a5,a5,a4
    8000636e:	40200713          	li	a4,1026
    80006372:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006376:	00d5151b          	slliw	a0,a0,0xd
    8000637a:	0c2017b7          	lui	a5,0xc201
    8000637e:	97aa                	add	a5,a5,a0
    80006380:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006384:	60a2                	ld	ra,8(sp)
    80006386:	6402                	ld	s0,0(sp)
    80006388:	0141                	addi	sp,sp,16
    8000638a:	8082                	ret

000000008000638c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000638c:	1141                	addi	sp,sp,-16
    8000638e:	e406                	sd	ra,8(sp)
    80006390:	e022                	sd	s0,0(sp)
    80006392:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006394:	ffffb097          	auipc	ra,0xffffb
    80006398:	6be080e7          	jalr	1726(ra) # 80001a52 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    8000639c:	00d5151b          	slliw	a0,a0,0xd
    800063a0:	0c2017b7          	lui	a5,0xc201
    800063a4:	97aa                	add	a5,a5,a0
  return irq;
}
    800063a6:	43c8                	lw	a0,4(a5)
    800063a8:	60a2                	ld	ra,8(sp)
    800063aa:	6402                	ld	s0,0(sp)
    800063ac:	0141                	addi	sp,sp,16
    800063ae:	8082                	ret

00000000800063b0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800063b0:	1101                	addi	sp,sp,-32
    800063b2:	ec06                	sd	ra,24(sp)
    800063b4:	e822                	sd	s0,16(sp)
    800063b6:	e426                	sd	s1,8(sp)
    800063b8:	1000                	addi	s0,sp,32
    800063ba:	84aa                	mv	s1,a0
  int hart = cpuid();
    800063bc:	ffffb097          	auipc	ra,0xffffb
    800063c0:	696080e7          	jalr	1686(ra) # 80001a52 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800063c4:	00d5179b          	slliw	a5,a0,0xd
    800063c8:	0c201737          	lui	a4,0xc201
    800063cc:	97ba                	add	a5,a5,a4
    800063ce:	c3c4                	sw	s1,4(a5)
}
    800063d0:	60e2                	ld	ra,24(sp)
    800063d2:	6442                	ld	s0,16(sp)
    800063d4:	64a2                	ld	s1,8(sp)
    800063d6:	6105                	addi	sp,sp,32
    800063d8:	8082                	ret

00000000800063da <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800063da:	1141                	addi	sp,sp,-16
    800063dc:	e406                	sd	ra,8(sp)
    800063de:	e022                	sd	s0,0(sp)
    800063e0:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800063e2:	479d                	li	a5,7
    800063e4:	06a7c863          	blt	a5,a0,80006454 <free_desc+0x7a>
    panic("free_desc 1");
  if(disk.free[i])
    800063e8:	00021717          	auipc	a4,0x21
    800063ec:	c1870713          	addi	a4,a4,-1000 # 80027000 <disk>
    800063f0:	972a                	add	a4,a4,a0
    800063f2:	6789                	lui	a5,0x2
    800063f4:	97ba                	add	a5,a5,a4
    800063f6:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800063fa:	e7ad                	bnez	a5,80006464 <free_desc+0x8a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800063fc:	00451793          	slli	a5,a0,0x4
    80006400:	00023717          	auipc	a4,0x23
    80006404:	c0070713          	addi	a4,a4,-1024 # 80029000 <disk+0x2000>
    80006408:	6314                	ld	a3,0(a4)
    8000640a:	96be                	add	a3,a3,a5
    8000640c:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006410:	6314                	ld	a3,0(a4)
    80006412:	96be                	add	a3,a3,a5
    80006414:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006418:	6314                	ld	a3,0(a4)
    8000641a:	96be                	add	a3,a3,a5
    8000641c:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80006420:	6318                	ld	a4,0(a4)
    80006422:	97ba                	add	a5,a5,a4
    80006424:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006428:	00021717          	auipc	a4,0x21
    8000642c:	bd870713          	addi	a4,a4,-1064 # 80027000 <disk>
    80006430:	972a                	add	a4,a4,a0
    80006432:	6789                	lui	a5,0x2
    80006434:	97ba                	add	a5,a5,a4
    80006436:	4705                	li	a4,1
    80006438:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000643c:	00023517          	auipc	a0,0x23
    80006440:	bdc50513          	addi	a0,a0,-1060 # 80029018 <disk+0x2018>
    80006444:	ffffc097          	auipc	ra,0xffffc
    80006448:	00a080e7          	jalr	10(ra) # 8000244e <wakeup>
}
    8000644c:	60a2                	ld	ra,8(sp)
    8000644e:	6402                	ld	s0,0(sp)
    80006450:	0141                	addi	sp,sp,16
    80006452:	8082                	ret
    panic("free_desc 1");
    80006454:	00002517          	auipc	a0,0x2
    80006458:	2dc50513          	addi	a0,a0,732 # 80008730 <etext+0x730>
    8000645c:	ffffa097          	auipc	ra,0xffffa
    80006460:	0fa080e7          	jalr	250(ra) # 80000556 <panic>
    panic("free_desc 2");
    80006464:	00002517          	auipc	a0,0x2
    80006468:	2dc50513          	addi	a0,a0,732 # 80008740 <etext+0x740>
    8000646c:	ffffa097          	auipc	ra,0xffffa
    80006470:	0ea080e7          	jalr	234(ra) # 80000556 <panic>

0000000080006474 <virtio_disk_init>:
{
    80006474:	1141                	addi	sp,sp,-16
    80006476:	e406                	sd	ra,8(sp)
    80006478:	e022                	sd	s0,0(sp)
    8000647a:	0800                	addi	s0,sp,16
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000647c:	00002597          	auipc	a1,0x2
    80006480:	2d458593          	addi	a1,a1,724 # 80008750 <etext+0x750>
    80006484:	00023517          	auipc	a0,0x23
    80006488:	ca450513          	addi	a0,a0,-860 # 80029128 <disk+0x2128>
    8000648c:	ffffa097          	auipc	ra,0xffffa
    80006490:	72e080e7          	jalr	1838(ra) # 80000bba <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006494:	100017b7          	lui	a5,0x10001
    80006498:	4398                	lw	a4,0(a5)
    8000649a:	2701                	sext.w	a4,a4
    8000649c:	747277b7          	lui	a5,0x74727
    800064a0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800064a4:	0ef71563          	bne	a4,a5,8000658e <virtio_disk_init+0x11a>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800064a8:	100017b7          	lui	a5,0x10001
    800064ac:	43dc                	lw	a5,4(a5)
    800064ae:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800064b0:	4705                	li	a4,1
    800064b2:	0ce79e63          	bne	a5,a4,8000658e <virtio_disk_init+0x11a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800064b6:	100017b7          	lui	a5,0x10001
    800064ba:	479c                	lw	a5,8(a5)
    800064bc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800064be:	4709                	li	a4,2
    800064c0:	0ce79763          	bne	a5,a4,8000658e <virtio_disk_init+0x11a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800064c4:	100017b7          	lui	a5,0x10001
    800064c8:	47d8                	lw	a4,12(a5)
    800064ca:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800064cc:	554d47b7          	lui	a5,0x554d4
    800064d0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800064d4:	0af71d63          	bne	a4,a5,8000658e <virtio_disk_init+0x11a>
  *R(VIRTIO_MMIO_STATUS) = status;
    800064d8:	100017b7          	lui	a5,0x10001
    800064dc:	4705                	li	a4,1
    800064de:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800064e0:	470d                	li	a4,3
    800064e2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800064e4:	10001737          	lui	a4,0x10001
    800064e8:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800064ea:	c7ffe6b7          	lui	a3,0xc7ffe
    800064ee:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd475f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800064f2:	8f75                	and	a4,a4,a3
    800064f4:	100016b7          	lui	a3,0x10001
    800064f8:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    800064fa:	472d                	li	a4,11
    800064fc:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800064fe:	473d                	li	a4,15
    80006500:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006502:	6705                	lui	a4,0x1
    80006504:	d698                	sw	a4,40(a3)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006506:	0206a823          	sw	zero,48(a3) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000650a:	5adc                	lw	a5,52(a3)
    8000650c:	2781                	sext.w	a5,a5
  if(max == 0)
    8000650e:	cbc1                	beqz	a5,8000659e <virtio_disk_init+0x12a>
  if(max < NUM)
    80006510:	471d                	li	a4,7
    80006512:	08f77e63          	bgeu	a4,a5,800065ae <virtio_disk_init+0x13a>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006516:	100017b7          	lui	a5,0x10001
    8000651a:	4721                	li	a4,8
    8000651c:	df98                	sw	a4,56(a5)
  memset(disk.pages, 0, sizeof(disk.pages));
    8000651e:	6609                	lui	a2,0x2
    80006520:	4581                	li	a1,0
    80006522:	00021517          	auipc	a0,0x21
    80006526:	ade50513          	addi	a0,a0,-1314 # 80027000 <disk>
    8000652a:	ffffb097          	auipc	ra,0xffffb
    8000652e:	822080e7          	jalr	-2014(ra) # 80000d4c <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006532:	00021717          	auipc	a4,0x21
    80006536:	ace70713          	addi	a4,a4,-1330 # 80027000 <disk>
    8000653a:	00c75793          	srli	a5,a4,0xc
    8000653e:	2781                	sext.w	a5,a5
    80006540:	100016b7          	lui	a3,0x10001
    80006544:	c2bc                	sw	a5,64(a3)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006546:	00023797          	auipc	a5,0x23
    8000654a:	aba78793          	addi	a5,a5,-1350 # 80029000 <disk+0x2000>
    8000654e:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006550:	00021717          	auipc	a4,0x21
    80006554:	b3070713          	addi	a4,a4,-1232 # 80027080 <disk+0x80>
    80006558:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    8000655a:	00022717          	auipc	a4,0x22
    8000655e:	aa670713          	addi	a4,a4,-1370 # 80028000 <disk+0x1000>
    80006562:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006564:	4705                	li	a4,1
    80006566:	00e78c23          	sb	a4,24(a5)
    8000656a:	00e78ca3          	sb	a4,25(a5)
    8000656e:	00e78d23          	sb	a4,26(a5)
    80006572:	00e78da3          	sb	a4,27(a5)
    80006576:	00e78e23          	sb	a4,28(a5)
    8000657a:	00e78ea3          	sb	a4,29(a5)
    8000657e:	00e78f23          	sb	a4,30(a5)
    80006582:	00e78fa3          	sb	a4,31(a5)
}
    80006586:	60a2                	ld	ra,8(sp)
    80006588:	6402                	ld	s0,0(sp)
    8000658a:	0141                	addi	sp,sp,16
    8000658c:	8082                	ret
    panic("could not find virtio disk");
    8000658e:	00002517          	auipc	a0,0x2
    80006592:	1d250513          	addi	a0,a0,466 # 80008760 <etext+0x760>
    80006596:	ffffa097          	auipc	ra,0xffffa
    8000659a:	fc0080e7          	jalr	-64(ra) # 80000556 <panic>
    panic("virtio disk has no queue 0");
    8000659e:	00002517          	auipc	a0,0x2
    800065a2:	1e250513          	addi	a0,a0,482 # 80008780 <etext+0x780>
    800065a6:	ffffa097          	auipc	ra,0xffffa
    800065aa:	fb0080e7          	jalr	-80(ra) # 80000556 <panic>
    panic("virtio disk max queue too short");
    800065ae:	00002517          	auipc	a0,0x2
    800065b2:	1f250513          	addi	a0,a0,498 # 800087a0 <etext+0x7a0>
    800065b6:	ffffa097          	auipc	ra,0xffffa
    800065ba:	fa0080e7          	jalr	-96(ra) # 80000556 <panic>

00000000800065be <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800065be:	711d                	addi	sp,sp,-96
    800065c0:	ec86                	sd	ra,88(sp)
    800065c2:	e8a2                	sd	s0,80(sp)
    800065c4:	e4a6                	sd	s1,72(sp)
    800065c6:	e0ca                	sd	s2,64(sp)
    800065c8:	fc4e                	sd	s3,56(sp)
    800065ca:	f852                	sd	s4,48(sp)
    800065cc:	f456                	sd	s5,40(sp)
    800065ce:	f05a                	sd	s6,32(sp)
    800065d0:	ec5e                	sd	s7,24(sp)
    800065d2:	e862                	sd	s8,16(sp)
    800065d4:	1080                	addi	s0,sp,96
    800065d6:	89aa                	mv	s3,a0
    800065d8:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800065da:	00c52b83          	lw	s7,12(a0)
    800065de:	001b9b9b          	slliw	s7,s7,0x1
    800065e2:	1b82                	slli	s7,s7,0x20
    800065e4:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    800065e8:	00023517          	auipc	a0,0x23
    800065ec:	b4050513          	addi	a0,a0,-1216 # 80029128 <disk+0x2128>
    800065f0:	ffffa097          	auipc	ra,0xffffa
    800065f4:	664080e7          	jalr	1636(ra) # 80000c54 <acquire>
  for(int i = 0; i < NUM; i++){
    800065f8:	44a1                	li	s1,8
      disk.free[i] = 0;
    800065fa:	00021b17          	auipc	s6,0x21
    800065fe:	a06b0b13          	addi	s6,s6,-1530 # 80027000 <disk>
    80006602:	6a89                	lui	s5,0x2
  for(int i = 0; i < 3; i++){
    80006604:	4a0d                	li	s4,3
    80006606:	a88d                	j	80006678 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006608:	00fb0733          	add	a4,s6,a5
    8000660c:	9756                	add	a4,a4,s5
    8000660e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006612:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006614:	0207c563          	bltz	a5,8000663e <virtio_disk_rw+0x80>
  for(int i = 0; i < 3; i++){
    80006618:	2905                	addiw	s2,s2,1
    8000661a:	0611                	addi	a2,a2,4 # 2004 <_entry-0x7fffdffc>
    8000661c:	1b490063          	beq	s2,s4,800067bc <virtio_disk_rw+0x1fe>
    idx[i] = alloc_desc();
    80006620:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006622:	00023717          	auipc	a4,0x23
    80006626:	9f670713          	addi	a4,a4,-1546 # 80029018 <disk+0x2018>
    8000662a:	4781                	li	a5,0
    if(disk.free[i]){
    8000662c:	00074683          	lbu	a3,0(a4)
    80006630:	fee1                	bnez	a3,80006608 <virtio_disk_rw+0x4a>
  for(int i = 0; i < NUM; i++){
    80006632:	2785                	addiw	a5,a5,1
    80006634:	0705                	addi	a4,a4,1
    80006636:	fe979be3          	bne	a5,s1,8000662c <virtio_disk_rw+0x6e>
    idx[i] = alloc_desc();
    8000663a:	57fd                	li	a5,-1
    8000663c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000663e:	03205163          	blez	s2,80006660 <virtio_disk_rw+0xa2>
        free_desc(idx[j]);
    80006642:	fa042503          	lw	a0,-96(s0)
    80006646:	00000097          	auipc	ra,0x0
    8000664a:	d94080e7          	jalr	-620(ra) # 800063da <free_desc>
      for(int j = 0; j < i; j++)
    8000664e:	4785                	li	a5,1
    80006650:	0127d863          	bge	a5,s2,80006660 <virtio_disk_rw+0xa2>
        free_desc(idx[j]);
    80006654:	fa442503          	lw	a0,-92(s0)
    80006658:	00000097          	auipc	ra,0x0
    8000665c:	d82080e7          	jalr	-638(ra) # 800063da <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006660:	00023597          	auipc	a1,0x23
    80006664:	ac858593          	addi	a1,a1,-1336 # 80029128 <disk+0x2128>
    80006668:	00023517          	auipc	a0,0x23
    8000666c:	9b050513          	addi	a0,a0,-1616 # 80029018 <disk+0x2018>
    80006670:	ffffc097          	auipc	ra,0xffffc
    80006674:	c58080e7          	jalr	-936(ra) # 800022c8 <sleep>
  for(int i = 0; i < 3; i++){
    80006678:	fa040613          	addi	a2,s0,-96
    8000667c:	4901                	li	s2,0
    8000667e:	b74d                	j	80006620 <virtio_disk_rw+0x62>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006680:	00023717          	auipc	a4,0x23
    80006684:	98073703          	ld	a4,-1664(a4) # 80029000 <disk+0x2000>
    80006688:	973e                	add	a4,a4,a5
    8000668a:	00071623          	sh	zero,12(a4)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000668e:	00021897          	auipc	a7,0x21
    80006692:	97288893          	addi	a7,a7,-1678 # 80027000 <disk>
    80006696:	00023717          	auipc	a4,0x23
    8000669a:	96a70713          	addi	a4,a4,-1686 # 80029000 <disk+0x2000>
    8000669e:	6314                	ld	a3,0(a4)
    800066a0:	96be                	add	a3,a3,a5
    800066a2:	00c6d583          	lhu	a1,12(a3) # 1000100c <_entry-0x6fffeff4>
    800066a6:	0015e593          	ori	a1,a1,1
    800066aa:	00b69623          	sh	a1,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800066ae:	fa842683          	lw	a3,-88(s0)
    800066b2:	630c                	ld	a1,0(a4)
    800066b4:	97ae                	add	a5,a5,a1
    800066b6:	00d79723          	sh	a3,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800066ba:	20050593          	addi	a1,a0,512
    800066be:	0592                	slli	a1,a1,0x4
    800066c0:	95c6                	add	a1,a1,a7
    800066c2:	57fd                	li	a5,-1
    800066c4:	02f58823          	sb	a5,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800066c8:	00469793          	slli	a5,a3,0x4
    800066cc:	00073803          	ld	a6,0(a4)
    800066d0:	983e                	add	a6,a6,a5
    800066d2:	6689                	lui	a3,0x2
    800066d4:	03068693          	addi	a3,a3,48 # 2030 <_entry-0x7fffdfd0>
    800066d8:	96b2                	add	a3,a3,a2
    800066da:	96c6                	add	a3,a3,a7
    800066dc:	00d83023          	sd	a3,0(a6)
  disk.desc[idx[2]].len = 1;
    800066e0:	6314                	ld	a3,0(a4)
    800066e2:	96be                	add	a3,a3,a5
    800066e4:	4605                	li	a2,1
    800066e6:	c690                	sw	a2,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800066e8:	6314                	ld	a3,0(a4)
    800066ea:	96be                	add	a3,a3,a5
    800066ec:	4809                	li	a6,2
    800066ee:	01069623          	sh	a6,12(a3)
  disk.desc[idx[2]].next = 0;
    800066f2:	6314                	ld	a3,0(a4)
    800066f4:	97b6                	add	a5,a5,a3
    800066f6:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800066fa:	00c9a223          	sw	a2,4(s3)
  disk.info[idx[0]].b = b;
    800066fe:	0335b423          	sd	s3,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006702:	6714                	ld	a3,8(a4)
    80006704:	0026d783          	lhu	a5,2(a3)
    80006708:	8b9d                	andi	a5,a5,7
    8000670a:	0786                	slli	a5,a5,0x1
    8000670c:	96be                	add	a3,a3,a5
    8000670e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006712:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006716:	6718                	ld	a4,8(a4)
    80006718:	00275783          	lhu	a5,2(a4)
    8000671c:	2785                	addiw	a5,a5,1
    8000671e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006722:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006726:	100017b7          	lui	a5,0x10001
    8000672a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000672e:	0049a783          	lw	a5,4(s3)
    80006732:	02c79163          	bne	a5,a2,80006754 <virtio_disk_rw+0x196>
    sleep(b, &disk.vdisk_lock);
    80006736:	00023917          	auipc	s2,0x23
    8000673a:	9f290913          	addi	s2,s2,-1550 # 80029128 <disk+0x2128>
  while(b->disk == 1) {
    8000673e:	84be                	mv	s1,a5
    sleep(b, &disk.vdisk_lock);
    80006740:	85ca                	mv	a1,s2
    80006742:	854e                	mv	a0,s3
    80006744:	ffffc097          	auipc	ra,0xffffc
    80006748:	b84080e7          	jalr	-1148(ra) # 800022c8 <sleep>
  while(b->disk == 1) {
    8000674c:	0049a783          	lw	a5,4(s3)
    80006750:	fe9788e3          	beq	a5,s1,80006740 <virtio_disk_rw+0x182>
  }

  disk.info[idx[0]].b = 0;
    80006754:	fa042903          	lw	s2,-96(s0)
    80006758:	20090713          	addi	a4,s2,512
    8000675c:	0712                	slli	a4,a4,0x4
    8000675e:	00021797          	auipc	a5,0x21
    80006762:	8a278793          	addi	a5,a5,-1886 # 80027000 <disk>
    80006766:	97ba                	add	a5,a5,a4
    80006768:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    8000676c:	00023997          	auipc	s3,0x23
    80006770:	89498993          	addi	s3,s3,-1900 # 80029000 <disk+0x2000>
    80006774:	00491713          	slli	a4,s2,0x4
    80006778:	0009b783          	ld	a5,0(s3)
    8000677c:	97ba                	add	a5,a5,a4
    8000677e:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006782:	854a                	mv	a0,s2
    80006784:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006788:	00000097          	auipc	ra,0x0
    8000678c:	c52080e7          	jalr	-942(ra) # 800063da <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006790:	8885                	andi	s1,s1,1
    80006792:	f0ed                	bnez	s1,80006774 <virtio_disk_rw+0x1b6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006794:	00023517          	auipc	a0,0x23
    80006798:	99450513          	addi	a0,a0,-1644 # 80029128 <disk+0x2128>
    8000679c:	ffffa097          	auipc	ra,0xffffa
    800067a0:	568080e7          	jalr	1384(ra) # 80000d04 <release>
}
    800067a4:	60e6                	ld	ra,88(sp)
    800067a6:	6446                	ld	s0,80(sp)
    800067a8:	64a6                	ld	s1,72(sp)
    800067aa:	6906                	ld	s2,64(sp)
    800067ac:	79e2                	ld	s3,56(sp)
    800067ae:	7a42                	ld	s4,48(sp)
    800067b0:	7aa2                	ld	s5,40(sp)
    800067b2:	7b02                	ld	s6,32(sp)
    800067b4:	6be2                	ld	s7,24(sp)
    800067b6:	6c42                	ld	s8,16(sp)
    800067b8:	6125                	addi	sp,sp,96
    800067ba:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800067bc:	fa042503          	lw	a0,-96(s0)
    800067c0:	00451613          	slli	a2,a0,0x4
  if(write)
    800067c4:	00021597          	auipc	a1,0x21
    800067c8:	83c58593          	addi	a1,a1,-1988 # 80027000 <disk>
    800067cc:	20050793          	addi	a5,a0,512
    800067d0:	0792                	slli	a5,a5,0x4
    800067d2:	97ae                	add	a5,a5,a1
    800067d4:	01803733          	snez	a4,s8
    800067d8:	0ae7a423          	sw	a4,168(a5)
  buf0->reserved = 0;
    800067dc:	0a07a623          	sw	zero,172(a5)
  buf0->sector = sector;
    800067e0:	0b77b823          	sd	s7,176(a5)
  disk.desc[idx[0]].addr = (uint64) buf0;
    800067e4:	00023717          	auipc	a4,0x23
    800067e8:	81c70713          	addi	a4,a4,-2020 # 80029000 <disk+0x2000>
    800067ec:	6314                	ld	a3,0(a4)
    800067ee:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800067f0:	6789                	lui	a5,0x2
    800067f2:	0a878793          	addi	a5,a5,168 # 20a8 <_entry-0x7fffdf58>
    800067f6:	97b2                	add	a5,a5,a2
    800067f8:	97ae                	add	a5,a5,a1
  disk.desc[idx[0]].addr = (uint64) buf0;
    800067fa:	e29c                	sd	a5,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800067fc:	631c                	ld	a5,0(a4)
    800067fe:	97b2                	add	a5,a5,a2
    80006800:	46c1                	li	a3,16
    80006802:	c794                	sw	a3,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006804:	631c                	ld	a5,0(a4)
    80006806:	97b2                	add	a5,a5,a2
    80006808:	4685                	li	a3,1
    8000680a:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[0]].next = idx[1];
    8000680e:	fa442783          	lw	a5,-92(s0)
    80006812:	6314                	ld	a3,0(a4)
    80006814:	96b2                	add	a3,a3,a2
    80006816:	00f69723          	sh	a5,14(a3)
  disk.desc[idx[1]].addr = (uint64) b->data;
    8000681a:	0792                	slli	a5,a5,0x4
    8000681c:	6314                	ld	a3,0(a4)
    8000681e:	96be                	add	a3,a3,a5
    80006820:	05898593          	addi	a1,s3,88
    80006824:	e28c                	sd	a1,0(a3)
  disk.desc[idx[1]].len = BSIZE;
    80006826:	6318                	ld	a4,0(a4)
    80006828:	973e                	add	a4,a4,a5
    8000682a:	40000693          	li	a3,1024
    8000682e:	c714                	sw	a3,8(a4)
  if(write)
    80006830:	e40c18e3          	bnez	s8,80006680 <virtio_disk_rw+0xc2>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006834:	00022717          	auipc	a4,0x22
    80006838:	7cc73703          	ld	a4,1996(a4) # 80029000 <disk+0x2000>
    8000683c:	973e                	add	a4,a4,a5
    8000683e:	4689                	li	a3,2
    80006840:	00d71623          	sh	a3,12(a4)
    80006844:	b5a9                	j	8000668e <virtio_disk_rw+0xd0>

0000000080006846 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006846:	1101                	addi	sp,sp,-32
    80006848:	ec06                	sd	ra,24(sp)
    8000684a:	e822                	sd	s0,16(sp)
    8000684c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000684e:	00023517          	auipc	a0,0x23
    80006852:	8da50513          	addi	a0,a0,-1830 # 80029128 <disk+0x2128>
    80006856:	ffffa097          	auipc	ra,0xffffa
    8000685a:	3fe080e7          	jalr	1022(ra) # 80000c54 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000685e:	100017b7          	lui	a5,0x10001
    80006862:	53bc                	lw	a5,96(a5)
    80006864:	8b8d                	andi	a5,a5,3
    80006866:	10001737          	lui	a4,0x10001
    8000686a:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000686c:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006870:	00022797          	auipc	a5,0x22
    80006874:	79078793          	addi	a5,a5,1936 # 80029000 <disk+0x2000>
    80006878:	6b94                	ld	a3,16(a5)
    8000687a:	0207d703          	lhu	a4,32(a5)
    8000687e:	0026d783          	lhu	a5,2(a3)
    80006882:	06f70563          	beq	a4,a5,800068ec <virtio_disk_intr+0xa6>
    80006886:	e426                	sd	s1,8(sp)
    80006888:	e04a                	sd	s2,0(sp)
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000688a:	00020917          	auipc	s2,0x20
    8000688e:	77690913          	addi	s2,s2,1910 # 80027000 <disk>
    80006892:	00022497          	auipc	s1,0x22
    80006896:	76e48493          	addi	s1,s1,1902 # 80029000 <disk+0x2000>
    __sync_synchronize();
    8000689a:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000689e:	6898                	ld	a4,16(s1)
    800068a0:	0204d783          	lhu	a5,32(s1)
    800068a4:	8b9d                	andi	a5,a5,7
    800068a6:	078e                	slli	a5,a5,0x3
    800068a8:	97ba                	add	a5,a5,a4
    800068aa:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800068ac:	20078713          	addi	a4,a5,512
    800068b0:	0712                	slli	a4,a4,0x4
    800068b2:	974a                	add	a4,a4,s2
    800068b4:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800068b8:	e731                	bnez	a4,80006904 <virtio_disk_intr+0xbe>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800068ba:	20078793          	addi	a5,a5,512
    800068be:	0792                	slli	a5,a5,0x4
    800068c0:	97ca                	add	a5,a5,s2
    800068c2:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800068c4:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800068c8:	ffffc097          	auipc	ra,0xffffc
    800068cc:	b86080e7          	jalr	-1146(ra) # 8000244e <wakeup>

    disk.used_idx += 1;
    800068d0:	0204d783          	lhu	a5,32(s1)
    800068d4:	2785                	addiw	a5,a5,1
    800068d6:	17c2                	slli	a5,a5,0x30
    800068d8:	93c1                	srli	a5,a5,0x30
    800068da:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800068de:	6898                	ld	a4,16(s1)
    800068e0:	00275703          	lhu	a4,2(a4)
    800068e4:	faf71be3          	bne	a4,a5,8000689a <virtio_disk_intr+0x54>
    800068e8:	64a2                	ld	s1,8(sp)
    800068ea:	6902                	ld	s2,0(sp)
  }

  release(&disk.vdisk_lock);
    800068ec:	00023517          	auipc	a0,0x23
    800068f0:	83c50513          	addi	a0,a0,-1988 # 80029128 <disk+0x2128>
    800068f4:	ffffa097          	auipc	ra,0xffffa
    800068f8:	410080e7          	jalr	1040(ra) # 80000d04 <release>
}
    800068fc:	60e2                	ld	ra,24(sp)
    800068fe:	6442                	ld	s0,16(sp)
    80006900:	6105                	addi	sp,sp,32
    80006902:	8082                	ret
      panic("virtio_disk_intr status");
    80006904:	00002517          	auipc	a0,0x2
    80006908:	ebc50513          	addi	a0,a0,-324 # 800087c0 <etext+0x7c0>
    8000690c:	ffffa097          	auipc	ra,0xffffa
    80006910:	c4a080e7          	jalr	-950(ra) # 80000556 <panic>
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
