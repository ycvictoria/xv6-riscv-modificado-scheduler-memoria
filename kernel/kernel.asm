
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
    80000066:	2de78793          	addi	a5,a5,734 # 80006340 <timervec>
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
    80000138:	58c080e7          	jalr	1420(ra) # 800026c0 <either_copyin>
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
    800001de:	0e2080e7          	jalr	226(ra) # 800022bc <sleep>
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
    80000226:	448080e7          	jalr	1096(ra) # 8000266a <either_copyout>
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
    80000310:	40a080e7          	jalr	1034(ra) # 80002716 <procdump>
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
    80000466:	fe0080e7          	jalr	-32(ra) # 80002442 <wakeup>
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
    800004d6:	35680813          	addi	a6,a6,854 # 80008828 <digits>
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
    80000606:	226a8a93          	addi	s5,s5,550 # 80008828 <digits>
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
    800008ec:	b5a080e7          	jalr	-1190(ra) # 80002442 <wakeup>
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
    8000097a:	946080e7          	jalr	-1722(ra) # 800022bc <sleep>
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

static inline uint64
r_sstatus()
{
  uint64 x;
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c0e:	100027f3          	csrr	a5,sstatus
    80000c12:	84be                	mv	s1,a5
    80000c14:	100027f3          	csrr	a5,sstatus

// disable device interrupts
static inline void
intr_off()
{
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
// are device interrupts enabled?
static inline int
intr_get()
{
  uint64 x = r_sstatus();
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
    80000f50:	b86080e7          	jalr	-1146(ra) # 80002ad2 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f54:	00005097          	auipc	ra,0x5
    80000f58:	430080e7          	jalr	1072(ra) # 80006384 <plicinithart>
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
    80000fc8:	ae6080e7          	jalr	-1306(ra) # 80002aaa <trapinit>
    trapinithart();  // install kernel trap vector
    80000fcc:	00002097          	auipc	ra,0x2
    80000fd0:	b06080e7          	jalr	-1274(ra) # 80002ad2 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fd4:	00005097          	auipc	ra,0x5
    80000fd8:	396080e7          	jalr	918(ra) # 8000636a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fdc:	00005097          	auipc	ra,0x5
    80000fe0:	3a8080e7          	jalr	936(ra) # 80006384 <plicinithart>
    binit();         // buffer cache
    80000fe4:	00002097          	auipc	ra,0x2
    80000fe8:	45e080e7          	jalr	1118(ra) # 80003442 <binit>
    iinit();         // inode table
    80000fec:	00003097          	auipc	ra,0x3
    80000ff0:	abc080e7          	jalr	-1348(ra) # 80003aa8 <iinit>
    fileinit();      // file table
    80000ff4:	00004097          	auipc	ra,0x4
    80000ff8:	a9e080e7          	jalr	-1378(ra) # 80004a92 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ffc:	00005097          	auipc	ra,0x5
    80001000:	4a8080e7          	jalr	1192(ra) # 800064a4 <virtio_disk_init>
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
// this core's hartid (core number), the index into cpus[].
static inline uint64
r_tp()
{
  uint64 x;
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
    80001adc:	9f87a783          	lw	a5,-1544(a5) # 8000b4d0 <first.1>
    80001ae0:	eb89                	bnez	a5,80001af2 <forkret+0x32>
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001ae2:	00001097          	auipc	ra,0x1
    80001ae6:	00c080e7          	jalr	12(ra) # 80002aee <usertrapret>
}
    80001aea:	60a2                	ld	ra,8(sp)
    80001aec:	6402                	ld	s0,0(sp)
    80001aee:	0141                	addi	sp,sp,16
    80001af0:	8082                	ret
    first = 0;
    80001af2:	0000a797          	auipc	a5,0xa
    80001af6:	9c07af23          	sw	zero,-1570(a5) # 8000b4d0 <first.1>
    fsinit(ROOTDEV);
    80001afa:	4505                	li	a0,1
    80001afc:	00002097          	auipc	ra,0x2
    80001b00:	f2e080e7          	jalr	-210(ra) # 80003a2a <fsinit>
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
    80001b24:	9b478793          	addi	a5,a5,-1612 # 8000b4d4 <nextpid>
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
    80001db8:	72c58593          	addi	a1,a1,1836 # 8000b4e0 <initcode>
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
    80001df6:	69c080e7          	jalr	1692(ra) # 8000448e <namei>
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
    80001f68:	bc0080e7          	jalr	-1088(ra) # 80004b24 <filedup>
    80001f6c:	00a93023          	sd	a0,0(s2)
    80001f70:	b7e5                	j	80001f58 <fork+0xaa>
  np->cwd = idup(p->cwd);
    80001f72:	150ab503          	ld	a0,336(s5)
    80001f76:	00002097          	auipc	ra,0x2
    80001f7a:	ce8080e7          	jalr	-792(ra) # 80003c5e <idup>
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
    8000204e:	8792                	mv	a5,tp
  int id = r_tp(); // tp contiene el hartid
    80002050:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002052:	00779693          	slli	a3,a5,0x7
    80002056:	00012717          	auipc	a4,0x12
    8000205a:	24a70713          	addi	a4,a4,586 # 800142a0 <pid_lock>
    8000205e:	9736                	add	a4,a4,a3
    80002060:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &high_priority_proc->context);
    80002064:	00012717          	auipc	a4,0x12
    80002068:	27470713          	addi	a4,a4,628 # 800142d8 <cpus+0x8>
    8000206c:	9736                	add	a4,a4,a3
    8000206e:	f8e43423          	sd	a4,-120(s0)
        nice = 5;
    80002072:	4c15                	li	s8,5
  if(a < b) return a;
    80002074:	06400c93          	li	s9,100
    for(p = proc; p < &proc[NPROC]; p++) {
    80002078:	0001ab97          	auipc	s7,0x1a
    8000207c:	858b8b93          	addi	s7,s7,-1960 # 8001b8d0 <tickslock>
      c->proc = high_priority_proc;
    80002080:	00012d97          	auipc	s11,0x12
    80002084:	220d8d93          	addi	s11,s11,544 # 800142a0 <pid_lock>
    80002088:	9db6                	add	s11,s11,a3
    8000208a:	a8ed                	j	80002184 <scheduler+0x154>
  if(a > b) return a;
    8000208c:	4901                	li	s2,0
    8000208e:	a849                	j	80002120 <scheduler+0xf0>
            dp_check && p->n_runs < high_priority_proc->n_runs;
    80002090:	1a84b683          	ld	a3,424(s1)
    80002094:	1a89b703          	ld	a4,424(s3)
    80002098:	00e6b633          	sltu	a2,a3,a4
            high_priority_proc->n_runs == p->n_runs &&
    8000209c:	4781                	li	a5,0
            dp_check &&
    8000209e:	02e68163          	beq	a3,a4,800020c0 <scheduler+0x90>
           check_1 ||
    800020a2:	8fd1                	or	a5,a5,a2
    800020a4:	c78d                	beqz	a5,800020ce <scheduler+0x9e>
            release(&high_priority_proc->lock);
    800020a6:	854e                	mv	a0,s3
    800020a8:	fffff097          	auipc	ra,0xfffff
    800020ac:	c5c080e7          	jalr	-932(ra) # 80000d04 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800020b0:	1c848793          	addi	a5,s1,456
    800020b4:	09778663          	beq	a5,s7,80002140 <scheduler+0x110>
    800020b8:	8a4a                	mv	s4,s2
    800020ba:	89a6                	mv	s3,s1
    800020bc:	84be                	mv	s1,a5
    800020be:	a00d                	j	800020e0 <scheduler+0xb0>
            high_priority_proc->n_runs == p->n_runs &&
    800020c0:	1704b783          	ld	a5,368(s1)
    800020c4:	1709b703          	ld	a4,368(s3)
    800020c8:	00e7b7b3          	sltu	a5,a5,a4
    800020cc:	bfd9                	j	800020a2 <scheduler+0x72>
      release(&p->lock);
    800020ce:	8526                	mv	a0,s1
    800020d0:	fffff097          	auipc	ra,0xfffff
    800020d4:	c34080e7          	jalr	-972(ra) # 80000d04 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800020d8:	1c848493          	addi	s1,s1,456
    800020dc:	05748f63          	beq	s1,s7,8000213a <scheduler+0x10a>
      acquire(&p->lock);
    800020e0:	8526                	mv	a0,s1
    800020e2:	fffff097          	auipc	ra,0xfffff
    800020e6:	b72080e7          	jalr	-1166(ra) # 80000c54 <acquire>
      if(p->run_time + p->sleep_time > 0){
    800020ea:	1984b683          	ld	a3,408(s1)
    800020ee:	1784b783          	ld	a5,376(s1)
    800020f2:	97b6                	add	a5,a5,a3
        nice = 5;
    800020f4:	8762                	mv	a4,s8
      if(p->run_time + p->sleep_time > 0){
    800020f6:	cb89                	beqz	a5,80002108 <scheduler+0xd8>
        nice = p->sleep_time * 10;
    800020f8:	0026971b          	slliw	a4,a3,0x2
    800020fc:	9f35                	addw	a4,a4,a3
    800020fe:	0017171b          	slliw	a4,a4,0x1
        nice = nice / (p->sleep_time + p->run_time);
    80002102:	02f75733          	divu	a4,a4,a5
    80002106:	2701                	sext.w	a4,a4
          max(0, min(p->priority - nice + 5, 100));
    80002108:	1b04b783          	ld	a5,432(s1)
    8000210c:	2795                	addiw	a5,a5,5
    8000210e:	9f99                	subw	a5,a5,a4
    80002110:	893e                	mv	s2,a5
  if(a < b) return a;
    80002112:	00fb5363          	bge	s6,a5,80002118 <scheduler+0xe8>
    80002116:	8966                	mv	s2,s9
  if(a > b) return a;
    80002118:	02091793          	slli	a5,s2,0x20
    8000211c:	f607c8e3          	bltz	a5,8000208c <scheduler+0x5c>
    80002120:	2901                	sext.w	s2,s2
      if(p->state == RUNNABLE){
    80002122:	4c9c                	lw	a5,24(s1)
    80002124:	fb5795e3          	bne	a5,s5,800020ce <scheduler+0x9e>
            dp_check && p->n_runs < high_priority_proc->n_runs;
    80002128:	f74904e3          	beq	s2,s4,80002090 <scheduler+0x60>
        if(high_priority_proc == 0 ||
    8000212c:	00098463          	beqz	s3,80002134 <scheduler+0x104>
    80002130:	f92a5fe3          	bge	s4,s2,800020ce <scheduler+0x9e>
          if(high_priority_proc != 0)
    80002134:	f6098ee3          	beqz	s3,800020b0 <scheduler+0x80>
    80002138:	b7bd                	j	800020a6 <scheduler+0x76>
    if(high_priority_proc != 0){
    8000213a:	04098a63          	beqz	s3,8000218e <scheduler+0x15e>
    8000213e:	84ce                	mv	s1,s3
      high_priority_proc->state = RUNNING;
    80002140:	4791                	li	a5,4
    80002142:	cc9c                	sw	a5,24(s1)
      high_priority_proc->start_time = ticks;
    80002144:	0000a797          	auipc	a5,0xa
    80002148:	eec7e783          	lwu	a5,-276(a5) # 8000c030 <ticks>
    8000214c:	18f4b823          	sd	a5,400(s1)
      high_priority_proc->run_time = 0;
    80002150:	1604bc23          	sd	zero,376(s1)
      high_priority_proc->sleep_time = 0;
    80002154:	1804bc23          	sd	zero,408(s1)
      high_priority_proc->n_runs += 1;
    80002158:	1a84b783          	ld	a5,424(s1)
    8000215c:	0785                	addi	a5,a5,1
    8000215e:	1af4b423          	sd	a5,424(s1)
      c->proc = high_priority_proc;
    80002162:	029db823          	sd	s1,48(s11)
      swtch(&c->context, &high_priority_proc->context);
    80002166:	06048593          	addi	a1,s1,96
    8000216a:	f8843503          	ld	a0,-120(s0)
    8000216e:	00001097          	auipc	ra,0x1
    80002172:	8d2080e7          	jalr	-1838(ra) # 80002a40 <swtch>
      c->proc = 0;
    80002176:	020db823          	sd	zero,48(s11)
      release(&high_priority_proc->lock);
    8000217a:	8526                	mv	a0,s1
    8000217c:	fffff097          	auipc	ra,0xfffff
    80002180:	b88080e7          	jalr	-1144(ra) # 80000d04 <release>
    int dynamic_priority = 101;
    80002184:	06500d13          	li	s10,101
  if(a < b) return a;
    80002188:	06400b13          	li	s6,100
      if(p->state == RUNNABLE){
    8000218c:	4a8d                	li	s5,3
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000218e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002192:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002196:	10079073          	csrw	sstatus,a5
    int dynamic_priority = 101;
    8000219a:	8a6a                	mv	s4,s10
    struct proc* high_priority_proc = 0;
    8000219c:	4981                	li	s3,0
    for(p = proc; p < &proc[NPROC]; p++) {
    8000219e:	00012497          	auipc	s1,0x12
    800021a2:	53248493          	addi	s1,s1,1330 # 800146d0 <proc>
    800021a6:	bf2d                	j	800020e0 <scheduler+0xb0>

00000000800021a8 <sched>:
{
    800021a8:	7179                	addi	sp,sp,-48
    800021aa:	f406                	sd	ra,40(sp)
    800021ac:	f022                	sd	s0,32(sp)
    800021ae:	ec26                	sd	s1,24(sp)
    800021b0:	e84a                	sd	s2,16(sp)
    800021b2:	e44e                	sd	s3,8(sp)
    800021b4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800021b6:	00000097          	auipc	ra,0x0
    800021ba:	8d0080e7          	jalr	-1840(ra) # 80001a86 <myproc>
    800021be:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800021c0:	fffff097          	auipc	ra,0xfffff
    800021c4:	a14080e7          	jalr	-1516(ra) # 80000bd4 <holding>
    800021c8:	cd25                	beqz	a0,80002240 <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    800021ca:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800021cc:	2781                	sext.w	a5,a5
    800021ce:	079e                	slli	a5,a5,0x7
    800021d0:	00012717          	auipc	a4,0x12
    800021d4:	0d070713          	addi	a4,a4,208 # 800142a0 <pid_lock>
    800021d8:	97ba                	add	a5,a5,a4
    800021da:	0a87a703          	lw	a4,168(a5)
    800021de:	4785                	li	a5,1
    800021e0:	06f71863          	bne	a4,a5,80002250 <sched+0xa8>
  if(p->state == RUNNING)
    800021e4:	4c98                	lw	a4,24(s1)
    800021e6:	4791                	li	a5,4
    800021e8:	06f70c63          	beq	a4,a5,80002260 <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800021ec:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800021f0:	8b89                	andi	a5,a5,2
  if(intr_get())
    800021f2:	efbd                	bnez	a5,80002270 <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    800021f4:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800021f6:	00012917          	auipc	s2,0x12
    800021fa:	0aa90913          	addi	s2,s2,170 # 800142a0 <pid_lock>
    800021fe:	2781                	sext.w	a5,a5
    80002200:	079e                	slli	a5,a5,0x7
    80002202:	97ca                	add	a5,a5,s2
    80002204:	0ac7a983          	lw	s3,172(a5)
    80002208:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000220a:	2781                	sext.w	a5,a5
    8000220c:	079e                	slli	a5,a5,0x7
    8000220e:	07a1                	addi	a5,a5,8
    80002210:	00012597          	auipc	a1,0x12
    80002214:	0c058593          	addi	a1,a1,192 # 800142d0 <cpus>
    80002218:	95be                	add	a1,a1,a5
    8000221a:	06048513          	addi	a0,s1,96
    8000221e:	00001097          	auipc	ra,0x1
    80002222:	822080e7          	jalr	-2014(ra) # 80002a40 <swtch>
    80002226:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002228:	2781                	sext.w	a5,a5
    8000222a:	079e                	slli	a5,a5,0x7
    8000222c:	993e                	add	s2,s2,a5
    8000222e:	0b392623          	sw	s3,172(s2)
}
    80002232:	70a2                	ld	ra,40(sp)
    80002234:	7402                	ld	s0,32(sp)
    80002236:	64e2                	ld	s1,24(sp)
    80002238:	6942                	ld	s2,16(sp)
    8000223a:	69a2                	ld	s3,8(sp)
    8000223c:	6145                	addi	sp,sp,48
    8000223e:	8082                	ret
    panic("sched p->lock");
    80002240:	00006517          	auipc	a0,0x6
    80002244:	ff050513          	addi	a0,a0,-16 # 80008230 <etext+0x230>
    80002248:	ffffe097          	auipc	ra,0xffffe
    8000224c:	30e080e7          	jalr	782(ra) # 80000556 <panic>
    panic("sched locks");
    80002250:	00006517          	auipc	a0,0x6
    80002254:	ff050513          	addi	a0,a0,-16 # 80008240 <etext+0x240>
    80002258:	ffffe097          	auipc	ra,0xffffe
    8000225c:	2fe080e7          	jalr	766(ra) # 80000556 <panic>
    panic("sched running");
    80002260:	00006517          	auipc	a0,0x6
    80002264:	ff050513          	addi	a0,a0,-16 # 80008250 <etext+0x250>
    80002268:	ffffe097          	auipc	ra,0xffffe
    8000226c:	2ee080e7          	jalr	750(ra) # 80000556 <panic>
    panic("sched interruptible");
    80002270:	00006517          	auipc	a0,0x6
    80002274:	ff050513          	addi	a0,a0,-16 # 80008260 <etext+0x260>
    80002278:	ffffe097          	auipc	ra,0xffffe
    8000227c:	2de080e7          	jalr	734(ra) # 80000556 <panic>

0000000080002280 <yield>:
{
    80002280:	1101                	addi	sp,sp,-32
    80002282:	ec06                	sd	ra,24(sp)
    80002284:	e822                	sd	s0,16(sp)
    80002286:	e426                	sd	s1,8(sp)
    80002288:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000228a:	fffff097          	auipc	ra,0xfffff
    8000228e:	7fc080e7          	jalr	2044(ra) # 80001a86 <myproc>
    80002292:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002294:	fffff097          	auipc	ra,0xfffff
    80002298:	9c0080e7          	jalr	-1600(ra) # 80000c54 <acquire>
  p->state = RUNNABLE;
    8000229c:	478d                	li	a5,3
    8000229e:	cc9c                	sw	a5,24(s1)
  sched();
    800022a0:	00000097          	auipc	ra,0x0
    800022a4:	f08080e7          	jalr	-248(ra) # 800021a8 <sched>
  release(&p->lock);
    800022a8:	8526                	mv	a0,s1
    800022aa:	fffff097          	auipc	ra,0xfffff
    800022ae:	a5a080e7          	jalr	-1446(ra) # 80000d04 <release>
}
    800022b2:	60e2                	ld	ra,24(sp)
    800022b4:	6442                	ld	s0,16(sp)
    800022b6:	64a2                	ld	s1,8(sp)
    800022b8:	6105                	addi	sp,sp,32
    800022ba:	8082                	ret

00000000800022bc <sleep>:

// Pone un proceso a dormir
void
sleep(void *chan, struct spinlock *lk)
{
    800022bc:	7179                	addi	sp,sp,-48
    800022be:	f406                	sd	ra,40(sp)
    800022c0:	f022                	sd	s0,32(sp)
    800022c2:	ec26                	sd	s1,24(sp)
    800022c4:	e84a                	sd	s2,16(sp)
    800022c6:	e44e                	sd	s3,8(sp)
    800022c8:	1800                	addi	s0,sp,48
    800022ca:	89aa                	mv	s3,a0
    800022cc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800022ce:	fffff097          	auipc	ra,0xfffff
    800022d2:	7b8080e7          	jalr	1976(ra) # 80001a86 <myproc>
    800022d6:	84aa                	mv	s1,a0
  
  acquire(&p->lock);
    800022d8:	fffff097          	auipc	ra,0xfffff
    800022dc:	97c080e7          	jalr	-1668(ra) # 80000c54 <acquire>
  release(lk);
    800022e0:	854a                	mv	a0,s2
    800022e2:	fffff097          	auipc	ra,0xfffff
    800022e6:	a22080e7          	jalr	-1502(ra) # 80000d04 <release>

  p->chan = chan;
    800022ea:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800022ee:	4789                	li	a5,2
    800022f0:	cc9c                	sw	a5,24(s1)

  sched();
    800022f2:	00000097          	auipc	ra,0x0
    800022f6:	eb6080e7          	jalr	-330(ra) # 800021a8 <sched>

  p->chan = 0;
    800022fa:	0204b023          	sd	zero,32(s1)

  release(&p->lock);
    800022fe:	8526                	mv	a0,s1
    80002300:	fffff097          	auipc	ra,0xfffff
    80002304:	a04080e7          	jalr	-1532(ra) # 80000d04 <release>
  acquire(lk);
    80002308:	854a                	mv	a0,s2
    8000230a:	fffff097          	auipc	ra,0xfffff
    8000230e:	94a080e7          	jalr	-1718(ra) # 80000c54 <acquire>
}
    80002312:	70a2                	ld	ra,40(sp)
    80002314:	7402                	ld	s0,32(sp)
    80002316:	64e2                	ld	s1,24(sp)
    80002318:	6942                	ld	s2,16(sp)
    8000231a:	69a2                	ld	s3,8(sp)
    8000231c:	6145                	addi	sp,sp,48
    8000231e:	8082                	ret

0000000080002320 <wait>:
{
    80002320:	715d                	addi	sp,sp,-80
    80002322:	e486                	sd	ra,72(sp)
    80002324:	e0a2                	sd	s0,64(sp)
    80002326:	fc26                	sd	s1,56(sp)
    80002328:	f84a                	sd	s2,48(sp)
    8000232a:	f44e                	sd	s3,40(sp)
    8000232c:	f052                	sd	s4,32(sp)
    8000232e:	ec56                	sd	s5,24(sp)
    80002330:	e85a                	sd	s6,16(sp)
    80002332:	e45e                	sd	s7,8(sp)
    80002334:	0880                	addi	s0,sp,80
    80002336:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002338:	fffff097          	auipc	ra,0xfffff
    8000233c:	74e080e7          	jalr	1870(ra) # 80001a86 <myproc>
    80002340:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002342:	00012517          	auipc	a0,0x12
    80002346:	f7650513          	addi	a0,a0,-138 # 800142b8 <wait_lock>
    8000234a:	fffff097          	auipc	ra,0xfffff
    8000234e:	90a080e7          	jalr	-1782(ra) # 80000c54 <acquire>
        if(np->state == ZOMBIE){
    80002352:	4a15                	li	s4,5
        havekids = 1;
    80002354:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002356:	00019997          	auipc	s3,0x19
    8000235a:	57a98993          	addi	s3,s3,1402 # 8001b8d0 <tickslock>
    sleep(p, &wait_lock);
    8000235e:	00012b17          	auipc	s6,0x12
    80002362:	f5ab0b13          	addi	s6,s6,-166 # 800142b8 <wait_lock>
    80002366:	a875                	j	80002422 <wait+0x102>
          pid = np->pid;
    80002368:	0304a983          	lw	s3,48(s1)
          if(addr != 0 &&
    8000236c:	000b8e63          	beqz	s7,80002388 <wait+0x68>
             copyout(p->pagetable, addr,
    80002370:	4691                	li	a3,4
    80002372:	02c48613          	addi	a2,s1,44
    80002376:	85de                	mv	a1,s7
    80002378:	05093503          	ld	a0,80(s2)
    8000237c:	fffff097          	auipc	ra,0xfffff
    80002380:	38e080e7          	jalr	910(ra) # 8000170a <copyout>
          if(addr != 0 &&
    80002384:	04054063          	bltz	a0,800023c4 <wait+0xa4>
          freeproc(np); // liberar proceso
    80002388:	8526                	mv	a0,s1
    8000238a:	00000097          	auipc	ra,0x0
    8000238e:	8b0080e7          	jalr	-1872(ra) # 80001c3a <freeproc>
          release(&np->lock);
    80002392:	8526                	mv	a0,s1
    80002394:	fffff097          	auipc	ra,0xfffff
    80002398:	970080e7          	jalr	-1680(ra) # 80000d04 <release>
          release(&wait_lock);
    8000239c:	00012517          	auipc	a0,0x12
    800023a0:	f1c50513          	addi	a0,a0,-228 # 800142b8 <wait_lock>
    800023a4:	fffff097          	auipc	ra,0xfffff
    800023a8:	960080e7          	jalr	-1696(ra) # 80000d04 <release>
}
    800023ac:	854e                	mv	a0,s3
    800023ae:	60a6                	ld	ra,72(sp)
    800023b0:	6406                	ld	s0,64(sp)
    800023b2:	74e2                	ld	s1,56(sp)
    800023b4:	7942                	ld	s2,48(sp)
    800023b6:	79a2                	ld	s3,40(sp)
    800023b8:	7a02                	ld	s4,32(sp)
    800023ba:	6ae2                	ld	s5,24(sp)
    800023bc:	6b42                	ld	s6,16(sp)
    800023be:	6ba2                	ld	s7,8(sp)
    800023c0:	6161                	addi	sp,sp,80
    800023c2:	8082                	ret
            release(&np->lock);
    800023c4:	8526                	mv	a0,s1
    800023c6:	fffff097          	auipc	ra,0xfffff
    800023ca:	93e080e7          	jalr	-1730(ra) # 80000d04 <release>
            release(&wait_lock);
    800023ce:	00012517          	auipc	a0,0x12
    800023d2:	eea50513          	addi	a0,a0,-278 # 800142b8 <wait_lock>
    800023d6:	fffff097          	auipc	ra,0xfffff
    800023da:	92e080e7          	jalr	-1746(ra) # 80000d04 <release>
            return -1;
    800023de:	59fd                	li	s3,-1
    800023e0:	b7f1                	j	800023ac <wait+0x8c>
    for(np = proc; np < &proc[NPROC]; np++){
    800023e2:	1c848493          	addi	s1,s1,456
    800023e6:	03348463          	beq	s1,s3,8000240e <wait+0xee>
      if(np->parent == p){
    800023ea:	7c9c                	ld	a5,56(s1)
    800023ec:	ff279be3          	bne	a5,s2,800023e2 <wait+0xc2>
        acquire(&np->lock);
    800023f0:	8526                	mv	a0,s1
    800023f2:	fffff097          	auipc	ra,0xfffff
    800023f6:	862080e7          	jalr	-1950(ra) # 80000c54 <acquire>
        if(np->state == ZOMBIE){
    800023fa:	4c9c                	lw	a5,24(s1)
    800023fc:	f74786e3          	beq	a5,s4,80002368 <wait+0x48>
        release(&np->lock);
    80002400:	8526                	mv	a0,s1
    80002402:	fffff097          	auipc	ra,0xfffff
    80002406:	902080e7          	jalr	-1790(ra) # 80000d04 <release>
        havekids = 1;
    8000240a:	8756                	mv	a4,s5
    8000240c:	bfd9                	j	800023e2 <wait+0xc2>
    if(!havekids || p->killed){
    8000240e:	c305                	beqz	a4,8000242e <wait+0x10e>
    80002410:	02892783          	lw	a5,40(s2)
    80002414:	ef89                	bnez	a5,8000242e <wait+0x10e>
    sleep(p, &wait_lock);
    80002416:	85da                	mv	a1,s6
    80002418:	854a                	mv	a0,s2
    8000241a:	00000097          	auipc	ra,0x0
    8000241e:	ea2080e7          	jalr	-350(ra) # 800022bc <sleep>
    havekids = 0;
    80002422:	4701                	li	a4,0
    for(np = proc; np < &proc[NPROC]; np++){
    80002424:	00012497          	auipc	s1,0x12
    80002428:	2ac48493          	addi	s1,s1,684 # 800146d0 <proc>
    8000242c:	bf7d                	j	800023ea <wait+0xca>
      release(&wait_lock);
    8000242e:	00012517          	auipc	a0,0x12
    80002432:	e8a50513          	addi	a0,a0,-374 # 800142b8 <wait_lock>
    80002436:	fffff097          	auipc	ra,0xfffff
    8000243a:	8ce080e7          	jalr	-1842(ra) # 80000d04 <release>
      return -1;
    8000243e:	59fd                	li	s3,-1
    80002440:	b7b5                	j	800023ac <wait+0x8c>

0000000080002442 <wakeup>:

// Despertar procesos dormidos
void
wakeup(void *chan)
{
    80002442:	7139                	addi	sp,sp,-64
    80002444:	fc06                	sd	ra,56(sp)
    80002446:	f822                	sd	s0,48(sp)
    80002448:	f426                	sd	s1,40(sp)
    8000244a:	f04a                	sd	s2,32(sp)
    8000244c:	ec4e                	sd	s3,24(sp)
    8000244e:	e852                	sd	s4,16(sp)
    80002450:	e456                	sd	s5,8(sp)
    80002452:	0080                	addi	s0,sp,64
    80002454:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002456:	00012497          	auipc	s1,0x12
    8000245a:	27a48493          	addi	s1,s1,634 # 800146d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);

      if(p->state == SLEEPING && p->chan == chan)
    8000245e:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002460:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002462:	00019917          	auipc	s2,0x19
    80002466:	46e90913          	addi	s2,s2,1134 # 8001b8d0 <tickslock>
    8000246a:	a811                	j	8000247e <wakeup+0x3c>

      release(&p->lock);
    8000246c:	8526                	mv	a0,s1
    8000246e:	fffff097          	auipc	ra,0xfffff
    80002472:	896080e7          	jalr	-1898(ra) # 80000d04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002476:	1c848493          	addi	s1,s1,456
    8000247a:	03248663          	beq	s1,s2,800024a6 <wakeup+0x64>
    if(p != myproc()){
    8000247e:	fffff097          	auipc	ra,0xfffff
    80002482:	608080e7          	jalr	1544(ra) # 80001a86 <myproc>
    80002486:	fe9508e3          	beq	a0,s1,80002476 <wakeup+0x34>
      acquire(&p->lock);
    8000248a:	8526                	mv	a0,s1
    8000248c:	ffffe097          	auipc	ra,0xffffe
    80002490:	7c8080e7          	jalr	1992(ra) # 80000c54 <acquire>
      if(p->state == SLEEPING && p->chan == chan)
    80002494:	4c9c                	lw	a5,24(s1)
    80002496:	fd379be3          	bne	a5,s3,8000246c <wakeup+0x2a>
    8000249a:	709c                	ld	a5,32(s1)
    8000249c:	fd4798e3          	bne	a5,s4,8000246c <wakeup+0x2a>
        p->state = RUNNABLE;
    800024a0:	0154ac23          	sw	s5,24(s1)
    800024a4:	b7e1                	j	8000246c <wakeup+0x2a>
    }
  }
}
    800024a6:	70e2                	ld	ra,56(sp)
    800024a8:	7442                	ld	s0,48(sp)
    800024aa:	74a2                	ld	s1,40(sp)
    800024ac:	7902                	ld	s2,32(sp)
    800024ae:	69e2                	ld	s3,24(sp)
    800024b0:	6a42                	ld	s4,16(sp)
    800024b2:	6aa2                	ld	s5,8(sp)
    800024b4:	6121                	addi	sp,sp,64
    800024b6:	8082                	ret

00000000800024b8 <reparent>:
{
    800024b8:	7179                	addi	sp,sp,-48
    800024ba:	f406                	sd	ra,40(sp)
    800024bc:	f022                	sd	s0,32(sp)
    800024be:	ec26                	sd	s1,24(sp)
    800024c0:	e84a                	sd	s2,16(sp)
    800024c2:	e44e                	sd	s3,8(sp)
    800024c4:	e052                	sd	s4,0(sp)
    800024c6:	1800                	addi	s0,sp,48
    800024c8:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800024ca:	00012497          	auipc	s1,0x12
    800024ce:	20648493          	addi	s1,s1,518 # 800146d0 <proc>
      pp->parent = initproc;
    800024d2:	0000aa17          	auipc	s4,0xa
    800024d6:	b56a0a13          	addi	s4,s4,-1194 # 8000c028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800024da:	00019997          	auipc	s3,0x19
    800024de:	3f698993          	addi	s3,s3,1014 # 8001b8d0 <tickslock>
    800024e2:	a029                	j	800024ec <reparent+0x34>
    800024e4:	1c848493          	addi	s1,s1,456
    800024e8:	01348d63          	beq	s1,s3,80002502 <reparent+0x4a>
    if(pp->parent == p){
    800024ec:	7c9c                	ld	a5,56(s1)
    800024ee:	ff279be3          	bne	a5,s2,800024e4 <reparent+0x2c>
      pp->parent = initproc;
    800024f2:	000a3503          	ld	a0,0(s4)
    800024f6:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800024f8:	00000097          	auipc	ra,0x0
    800024fc:	f4a080e7          	jalr	-182(ra) # 80002442 <wakeup>
    80002500:	b7d5                	j	800024e4 <reparent+0x2c>
}
    80002502:	70a2                	ld	ra,40(sp)
    80002504:	7402                	ld	s0,32(sp)
    80002506:	64e2                	ld	s1,24(sp)
    80002508:	6942                	ld	s2,16(sp)
    8000250a:	69a2                	ld	s3,8(sp)
    8000250c:	6a02                	ld	s4,0(sp)
    8000250e:	6145                	addi	sp,sp,48
    80002510:	8082                	ret

0000000080002512 <exit>:
{
    80002512:	7179                	addi	sp,sp,-48
    80002514:	f406                	sd	ra,40(sp)
    80002516:	f022                	sd	s0,32(sp)
    80002518:	ec26                	sd	s1,24(sp)
    8000251a:	e84a                	sd	s2,16(sp)
    8000251c:	e44e                	sd	s3,8(sp)
    8000251e:	e052                	sd	s4,0(sp)
    80002520:	1800                	addi	s0,sp,48
    80002522:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002524:	fffff097          	auipc	ra,0xfffff
    80002528:	562080e7          	jalr	1378(ra) # 80001a86 <myproc>
    8000252c:	89aa                	mv	s3,a0
  if(p == initproc)
    8000252e:	0000a797          	auipc	a5,0xa
    80002532:	afa7b783          	ld	a5,-1286(a5) # 8000c028 <initproc>
    80002536:	0d050493          	addi	s1,a0,208
    8000253a:	15050913          	addi	s2,a0,336
    8000253e:	00a79d63          	bne	a5,a0,80002558 <exit+0x46>
    panic("init exiting");
    80002542:	00006517          	auipc	a0,0x6
    80002546:	d3650513          	addi	a0,a0,-714 # 80008278 <etext+0x278>
    8000254a:	ffffe097          	auipc	ra,0xffffe
    8000254e:	00c080e7          	jalr	12(ra) # 80000556 <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    80002552:	04a1                	addi	s1,s1,8
    80002554:	01248b63          	beq	s1,s2,8000256a <exit+0x58>
    if(p->ofile[fd]){
    80002558:	6088                	ld	a0,0(s1)
    8000255a:	dd65                	beqz	a0,80002552 <exit+0x40>
      fileclose(f);
    8000255c:	00002097          	auipc	ra,0x2
    80002560:	61a080e7          	jalr	1562(ra) # 80004b76 <fileclose>
      p->ofile[fd] = 0;
    80002564:	0004b023          	sd	zero,0(s1)
    80002568:	b7ed                	j	80002552 <exit+0x40>
  begin_op();
    8000256a:	00002097          	auipc	ra,0x2
    8000256e:	12a080e7          	jalr	298(ra) # 80004694 <begin_op>
  iput(p->cwd);
    80002572:	1509b503          	ld	a0,336(s3)
    80002576:	00002097          	auipc	ra,0x2
    8000257a:	8e4080e7          	jalr	-1820(ra) # 80003e5a <iput>
  end_op();
    8000257e:	00002097          	auipc	ra,0x2
    80002582:	196080e7          	jalr	406(ra) # 80004714 <end_op>
  p->cwd = 0;
    80002586:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000258a:	00012517          	auipc	a0,0x12
    8000258e:	d2e50513          	addi	a0,a0,-722 # 800142b8 <wait_lock>
    80002592:	ffffe097          	auipc	ra,0xffffe
    80002596:	6c2080e7          	jalr	1730(ra) # 80000c54 <acquire>
  reparent(p);
    8000259a:	854e                	mv	a0,s3
    8000259c:	00000097          	auipc	ra,0x0
    800025a0:	f1c080e7          	jalr	-228(ra) # 800024b8 <reparent>
  wakeup(p->parent);
    800025a4:	0389b503          	ld	a0,56(s3)
    800025a8:	00000097          	auipc	ra,0x0
    800025ac:	e9a080e7          	jalr	-358(ra) # 80002442 <wakeup>
  acquire(&p->lock);
    800025b0:	854e                	mv	a0,s3
    800025b2:	ffffe097          	auipc	ra,0xffffe
    800025b6:	6a2080e7          	jalr	1698(ra) # 80000c54 <acquire>
  p->xstate = status;  // codigo de salida
    800025ba:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;   // proceso muerto
    800025be:	4795                	li	a5,5
    800025c0:	00f9ac23          	sw	a5,24(s3)
  p->exit_time = ticks;// registrar tiempo de salida
    800025c4:	0000a797          	auipc	a5,0xa
    800025c8:	a6c7e783          	lwu	a5,-1428(a5) # 8000c030 <ticks>
    800025cc:	1af9b023          	sd	a5,416(s3)
  release(&wait_lock);
    800025d0:	00012517          	auipc	a0,0x12
    800025d4:	ce850513          	addi	a0,a0,-792 # 800142b8 <wait_lock>
    800025d8:	ffffe097          	auipc	ra,0xffffe
    800025dc:	72c080e7          	jalr	1836(ra) # 80000d04 <release>
  sched(); // ceder CPU
    800025e0:	00000097          	auipc	ra,0x0
    800025e4:	bc8080e7          	jalr	-1080(ra) # 800021a8 <sched>
  panic("zombie exit");
    800025e8:	00006517          	auipc	a0,0x6
    800025ec:	ca050513          	addi	a0,a0,-864 # 80008288 <etext+0x288>
    800025f0:	ffffe097          	auipc	ra,0xffffe
    800025f4:	f66080e7          	jalr	-154(ra) # 80000556 <panic>

00000000800025f8 <kill>:

// Mata un proceso por pid
int
kill(int pid)
{
    800025f8:	7179                	addi	sp,sp,-48
    800025fa:	f406                	sd	ra,40(sp)
    800025fc:	f022                	sd	s0,32(sp)
    800025fe:	ec26                	sd	s1,24(sp)
    80002600:	e84a                	sd	s2,16(sp)
    80002602:	e44e                	sd	s3,8(sp)
    80002604:	1800                	addi	s0,sp,48
    80002606:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002608:	00012497          	auipc	s1,0x12
    8000260c:	0c848493          	addi	s1,s1,200 # 800146d0 <proc>
    80002610:	00019997          	auipc	s3,0x19
    80002614:	2c098993          	addi	s3,s3,704 # 8001b8d0 <tickslock>
    acquire(&p->lock);
    80002618:	8526                	mv	a0,s1
    8000261a:	ffffe097          	auipc	ra,0xffffe
    8000261e:	63a080e7          	jalr	1594(ra) # 80000c54 <acquire>

    if(p->pid == pid){
    80002622:	589c                	lw	a5,48(s1)
    80002624:	01278d63          	beq	a5,s2,8000263e <kill+0x46>

      release(&p->lock);
      return 0;
    }

    release(&p->lock);
    80002628:	8526                	mv	a0,s1
    8000262a:	ffffe097          	auipc	ra,0xffffe
    8000262e:	6da080e7          	jalr	1754(ra) # 80000d04 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002632:	1c848493          	addi	s1,s1,456
    80002636:	ff3491e3          	bne	s1,s3,80002618 <kill+0x20>
  }

  return -1;
    8000263a:	557d                	li	a0,-1
    8000263c:	a829                	j	80002656 <kill+0x5e>
      p->killed = 1;
    8000263e:	4785                	li	a5,1
    80002640:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING)
    80002642:	4c98                	lw	a4,24(s1)
    80002644:	4789                	li	a5,2
    80002646:	00f70f63          	beq	a4,a5,80002664 <kill+0x6c>
      release(&p->lock);
    8000264a:	8526                	mv	a0,s1
    8000264c:	ffffe097          	auipc	ra,0xffffe
    80002650:	6b8080e7          	jalr	1720(ra) # 80000d04 <release>
      return 0;
    80002654:	4501                	li	a0,0
}
    80002656:	70a2                	ld	ra,40(sp)
    80002658:	7402                	ld	s0,32(sp)
    8000265a:	64e2                	ld	s1,24(sp)
    8000265c:	6942                	ld	s2,16(sp)
    8000265e:	69a2                	ld	s3,8(sp)
    80002660:	6145                	addi	sp,sp,48
    80002662:	8082                	ret
        p->state = RUNNABLE;
    80002664:	478d                	li	a5,3
    80002666:	cc9c                	sw	a5,24(s1)
    80002668:	b7cd                	j	8000264a <kill+0x52>

000000008000266a <either_copyout>:

// Copia datos a espacio de usuario o kernel
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000266a:	7179                	addi	sp,sp,-48
    8000266c:	f406                	sd	ra,40(sp)
    8000266e:	f022                	sd	s0,32(sp)
    80002670:	ec26                	sd	s1,24(sp)
    80002672:	e84a                	sd	s2,16(sp)
    80002674:	e44e                	sd	s3,8(sp)
    80002676:	e052                	sd	s4,0(sp)
    80002678:	1800                	addi	s0,sp,48
    8000267a:	84aa                	mv	s1,a0
    8000267c:	8a2e                	mv	s4,a1
    8000267e:	89b2                	mv	s3,a2
    80002680:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002682:	fffff097          	auipc	ra,0xfffff
    80002686:	404080e7          	jalr	1028(ra) # 80001a86 <myproc>

  if(user_dst)
    8000268a:	c08d                	beqz	s1,800026ac <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000268c:	86ca                	mv	a3,s2
    8000268e:	864e                	mv	a2,s3
    80002690:	85d2                	mv	a1,s4
    80002692:	6928                	ld	a0,80(a0)
    80002694:	fffff097          	auipc	ra,0xfffff
    80002698:	076080e7          	jalr	118(ra) # 8000170a <copyout>
  else{
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000269c:	70a2                	ld	ra,40(sp)
    8000269e:	7402                	ld	s0,32(sp)
    800026a0:	64e2                	ld	s1,24(sp)
    800026a2:	6942                	ld	s2,16(sp)
    800026a4:	69a2                	ld	s3,8(sp)
    800026a6:	6a02                	ld	s4,0(sp)
    800026a8:	6145                	addi	sp,sp,48
    800026aa:	8082                	ret
    memmove((char *)dst, src, len);
    800026ac:	0009061b          	sext.w	a2,s2
    800026b0:	85ce                	mv	a1,s3
    800026b2:	8552                	mv	a0,s4
    800026b4:	ffffe097          	auipc	ra,0xffffe
    800026b8:	6f8080e7          	jalr	1784(ra) # 80000dac <memmove>
    return 0;
    800026bc:	8526                	mv	a0,s1
    800026be:	bff9                	j	8000269c <either_copyout+0x32>

00000000800026c0 <either_copyin>:

// Copia datos desde espacio de usuario o kernel
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800026c0:	7179                	addi	sp,sp,-48
    800026c2:	f406                	sd	ra,40(sp)
    800026c4:	f022                	sd	s0,32(sp)
    800026c6:	ec26                	sd	s1,24(sp)
    800026c8:	e84a                	sd	s2,16(sp)
    800026ca:	e44e                	sd	s3,8(sp)
    800026cc:	e052                	sd	s4,0(sp)
    800026ce:	1800                	addi	s0,sp,48
    800026d0:	8a2a                	mv	s4,a0
    800026d2:	84ae                	mv	s1,a1
    800026d4:	89b2                	mv	s3,a2
    800026d6:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800026d8:	fffff097          	auipc	ra,0xfffff
    800026dc:	3ae080e7          	jalr	942(ra) # 80001a86 <myproc>

  if(user_src)
    800026e0:	c08d                	beqz	s1,80002702 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800026e2:	86ca                	mv	a3,s2
    800026e4:	864e                	mv	a2,s3
    800026e6:	85d2                	mv	a1,s4
    800026e8:	6928                	ld	a0,80(a0)
    800026ea:	fffff097          	auipc	ra,0xfffff
    800026ee:	0ac080e7          	jalr	172(ra) # 80001796 <copyin>
  else{
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800026f2:	70a2                	ld	ra,40(sp)
    800026f4:	7402                	ld	s0,32(sp)
    800026f6:	64e2                	ld	s1,24(sp)
    800026f8:	6942                	ld	s2,16(sp)
    800026fa:	69a2                	ld	s3,8(sp)
    800026fc:	6a02                	ld	s4,0(sp)
    800026fe:	6145                	addi	sp,sp,48
    80002700:	8082                	ret
    memmove(dst, (char*)src, len);
    80002702:	0009061b          	sext.w	a2,s2
    80002706:	85ce                	mv	a1,s3
    80002708:	8552                	mv	a0,s4
    8000270a:	ffffe097          	auipc	ra,0xffffe
    8000270e:	6a2080e7          	jalr	1698(ra) # 80000dac <memmove>
    return 0;
    80002712:	8526                	mv	a0,s1
    80002714:	bff9                	j	800026f2 <either_copyin+0x32>

0000000080002716 <procdump>:

// Imprime informacion de procesos (Ctrl+P)
void
procdump(void)
{
    80002716:	715d                	addi	sp,sp,-80
    80002718:	e486                	sd	ra,72(sp)
    8000271a:	e0a2                	sd	s0,64(sp)
    8000271c:	fc26                	sd	s1,56(sp)
    8000271e:	f84a                	sd	s2,48(sp)
    80002720:	f44e                	sd	s3,40(sp)
    80002722:	f052                	sd	s4,32(sp)
    80002724:	ec56                	sd	s5,24(sp)
    80002726:	e85a                	sd	s6,16(sp)
    80002728:	e45e                	sd	s7,8(sp)
    8000272a:	e062                	sd	s8,0(sp)
    8000272c:	0880                	addi	s0,sp,80
  };

  struct proc *p;
  char *state;

  printf("\n");
    8000272e:	00006517          	auipc	a0,0x6
    80002732:	8e250513          	addi	a0,a0,-1822 # 80008010 <etext+0x10>
    80002736:	ffffe097          	auipc	ra,0xffffe
    8000273a:	e6a080e7          	jalr	-406(ra) # 800005a0 <printf>

  for(p = proc; p < &proc[NPROC]; p++){
    8000273e:	00012497          	auipc	s1,0x12
    80002742:	f9248493          	addi	s1,s1,-110 # 800146d0 <proc>
    if(p->state == UNUSED)
      continue;

    if(p->state >= 0 && p->state < NELEM(states))
    80002746:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002748:	00006a97          	auipc	s5,0x6
    8000274c:	b50a8a93          	addi	s5,s5,-1200 # 80008298 <etext+0x298>
    if(p->exit_time > 0)
      wait_time = p->exit_time - p->create_time - p->total_run_time;
    else
      wait_time = ticks - p->create_time - p->total_run_time;

    printf("%d %d %s %d %d %d",
    80002750:	00006a17          	auipc	s4,0x6
    80002754:	b50a0a13          	addi	s4,s4,-1200 # 800082a0 <etext+0x2a0>
           p->total_run_time,
           wait_time,
           p->n_runs);
#endif

    printf("\n");
    80002758:	00006997          	auipc	s3,0x6
    8000275c:	8b898993          	addi	s3,s3,-1864 # 80008010 <etext+0x10>
      wait_time = ticks - p->create_time - p->total_run_time;
    80002760:	0000ac17          	auipc	s8,0xa
    80002764:	8d0c0c13          	addi	s8,s8,-1840 # 8000c030 <ticks>
      state = states[p->state];
    80002768:	00006b97          	auipc	s7,0x6
    8000276c:	0d8b8b93          	addi	s7,s7,216 # 80008840 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    80002770:	00019917          	auipc	s2,0x19
    80002774:	16090913          	addi	s2,s2,352 # 8001b8d0 <tickslock>
    80002778:	a835                	j	800027b4 <procdump+0x9e>
      wait_time = ticks - p->create_time - p->total_run_time;
    8000277a:	1704b703          	ld	a4,368(s1)
    8000277e:	1804b783          	ld	a5,384(s1)
    80002782:	9f3d                	addw	a4,a4,a5
    80002784:	000c2783          	lw	a5,0(s8)
    80002788:	9f99                	subw	a5,a5,a4
    printf("%d %d %s %d %d %d",
    8000278a:	1a84b803          	ld	a6,424(s1)
    8000278e:	1804b703          	ld	a4,384(s1)
    80002792:	1b04b603          	ld	a2,432(s1)
    80002796:	588c                	lw	a1,48(s1)
    80002798:	8552                	mv	a0,s4
    8000279a:	ffffe097          	auipc	ra,0xffffe
    8000279e:	e06080e7          	jalr	-506(ra) # 800005a0 <printf>
    printf("\n");
    800027a2:	854e                	mv	a0,s3
    800027a4:	ffffe097          	auipc	ra,0xffffe
    800027a8:	dfc080e7          	jalr	-516(ra) # 800005a0 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800027ac:	1c848493          	addi	s1,s1,456
    800027b0:	03248763          	beq	s1,s2,800027de <procdump+0xc8>
    if(p->state == UNUSED)
    800027b4:	4c9c                	lw	a5,24(s1)
    800027b6:	dbfd                	beqz	a5,800027ac <procdump+0x96>
      state = "???";
    800027b8:	86d6                	mv	a3,s5
    if(p->state >= 0 && p->state < NELEM(states))
    800027ba:	00fb6863          	bltu	s6,a5,800027ca <procdump+0xb4>
      state = states[p->state];
    800027be:	02079713          	slli	a4,a5,0x20
    800027c2:	01d75793          	srli	a5,a4,0x1d
    800027c6:	97de                	add	a5,a5,s7
    800027c8:	6394                	ld	a3,0(a5)
    if(p->exit_time > 0)
    800027ca:	1a04b783          	ld	a5,416(s1)
    800027ce:	d7d5                	beqz	a5,8000277a <procdump+0x64>
      wait_time = p->exit_time - p->create_time - p->total_run_time;
    800027d0:	1704b703          	ld	a4,368(s1)
    800027d4:	1804b603          	ld	a2,384(s1)
    800027d8:	9f31                	addw	a4,a4,a2
    800027da:	9f99                	subw	a5,a5,a4
    800027dc:	b77d                	j	8000278a <procdump+0x74>
  }
}
    800027de:	60a6                	ld	ra,72(sp)
    800027e0:	6406                	ld	s0,64(sp)
    800027e2:	74e2                	ld	s1,56(sp)
    800027e4:	7942                	ld	s2,48(sp)
    800027e6:	79a2                	ld	s3,40(sp)
    800027e8:	7a02                	ld	s4,32(sp)
    800027ea:	6ae2                	ld	s5,24(sp)
    800027ec:	6b42                	ld	s6,16(sp)
    800027ee:	6ba2                	ld	s7,8(sp)
    800027f0:	6c02                	ld	s8,0(sp)
    800027f2:	6161                	addi	sp,sp,80
    800027f4:	8082                	ret

00000000800027f6 <update_time>:

// Actualiza run_time y sleep_time cada tick
void
update_time(void)
{
    800027f6:	7179                	addi	sp,sp,-48
    800027f8:	f406                	sd	ra,40(sp)
    800027fa:	f022                	sd	s0,32(sp)
    800027fc:	ec26                	sd	s1,24(sp)
    800027fe:	e84a                	sd	s2,16(sp)
    80002800:	e44e                	sd	s3,8(sp)
    80002802:	e052                	sd	s4,0(sp)
    80002804:	1800                	addi	s0,sp,48
  struct proc* p;

  for(p = proc; p < &proc[NPROC]; p++)
    80002806:	00012497          	auipc	s1,0x12
    8000280a:	eca48493          	addi	s1,s1,-310 # 800146d0 <proc>
  {
    acquire(&p->lock);

    if(p->state == RUNNING){
    8000280e:	4991                	li	s3,4
      p->run_time += 1;
      p->total_run_time += 1;
    }
    else if(p->state == SLEEPING){
    80002810:	4a09                	li	s4,2
  for(p = proc; p < &proc[NPROC]; p++)
    80002812:	00019917          	auipc	s2,0x19
    80002816:	0be90913          	addi	s2,s2,190 # 8001b8d0 <tickslock>
    8000281a:	a025                	j	80002842 <update_time+0x4c>
      p->run_time += 1;
    8000281c:	1784b783          	ld	a5,376(s1)
    80002820:	0785                	addi	a5,a5,1
    80002822:	16f4bc23          	sd	a5,376(s1)
      p->total_run_time += 1;
    80002826:	1804b783          	ld	a5,384(s1)
    8000282a:	0785                	addi	a5,a5,1
    8000282c:	18f4b023          	sd	a5,384(s1)
      p->sleep_time += 1;
    }

    release(&p->lock);
    80002830:	8526                	mv	a0,s1
    80002832:	ffffe097          	auipc	ra,0xffffe
    80002836:	4d2080e7          	jalr	1234(ra) # 80000d04 <release>
  for(p = proc; p < &proc[NPROC]; p++)
    8000283a:	1c848493          	addi	s1,s1,456
    8000283e:	03248263          	beq	s1,s2,80002862 <update_time+0x6c>
    acquire(&p->lock);
    80002842:	8526                	mv	a0,s1
    80002844:	ffffe097          	auipc	ra,0xffffe
    80002848:	410080e7          	jalr	1040(ra) # 80000c54 <acquire>
    if(p->state == RUNNING){
    8000284c:	4c9c                	lw	a5,24(s1)
    8000284e:	fd3787e3          	beq	a5,s3,8000281c <update_time+0x26>
    else if(p->state == SLEEPING){
    80002852:	fd479fe3          	bne	a5,s4,80002830 <update_time+0x3a>
      p->sleep_time += 1;
    80002856:	1984b783          	ld	a5,408(s1)
    8000285a:	0785                	addi	a5,a5,1
    8000285c:	18f4bc23          	sd	a5,408(s1)
    80002860:	bfc1                	j	80002830 <update_time+0x3a>
  }
}
    80002862:	70a2                	ld	ra,40(sp)
    80002864:	7402                	ld	s0,32(sp)
    80002866:	64e2                	ld	s1,24(sp)
    80002868:	6942                	ld	s2,16(sp)
    8000286a:	69a2                	ld	s3,8(sp)
    8000286c:	6a02                	ld	s4,0(sp)
    8000286e:	6145                	addi	sp,sp,48
    80002870:	8082                	ret

0000000080002872 <setpriority>:

// Cambia prioridad estatica PBS
int
setpriority(int new_priority, int pid)
{
    80002872:	7179                	addi	sp,sp,-48
    80002874:	f406                	sd	ra,40(sp)
    80002876:	f022                	sd	s0,32(sp)
    80002878:	ec26                	sd	s1,24(sp)
    8000287a:	e84a                	sd	s2,16(sp)
    8000287c:	e44e                	sd	s3,8(sp)
    8000287e:	e052                	sd	s4,0(sp)
    80002880:	1800                	addi	s0,sp,48
    80002882:	8a2a                	mv	s4,a0
    80002884:	892e                	mv	s2,a1
  int prev_priority = 0;
  struct proc* p;

  for(p = proc; p < &proc[NPROC]; p++)
    80002886:	00012497          	auipc	s1,0x12
    8000288a:	e4a48493          	addi	s1,s1,-438 # 800146d0 <proc>
    8000288e:	00019997          	auipc	s3,0x19
    80002892:	04298993          	addi	s3,s3,66 # 8001b8d0 <tickslock>
  {
    acquire(&p->lock);
    80002896:	8526                	mv	a0,s1
    80002898:	ffffe097          	auipc	ra,0xffffe
    8000289c:	3bc080e7          	jalr	956(ra) # 80000c54 <acquire>

    if(p->pid == pid)
    800028a0:	589c                	lw	a5,48(s1)
    800028a2:	01278d63          	beq	a5,s2,800028bc <setpriority+0x4a>
        yield();

      break;
    }

    release(&p->lock);
    800028a6:	8526                	mv	a0,s1
    800028a8:	ffffe097          	auipc	ra,0xffffe
    800028ac:	45c080e7          	jalr	1116(ra) # 80000d04 <release>
  for(p = proc; p < &proc[NPROC]; p++)
    800028b0:	1c848493          	addi	s1,s1,456
    800028b4:	ff3491e3          	bne	s1,s3,80002896 <setpriority+0x24>
  int prev_priority = 0;
    800028b8:	4901                	li	s2,0
    800028ba:	a005                	j	800028da <setpriority+0x68>
      prev_priority = p->priority;
    800028bc:	1b04a903          	lw	s2,432(s1)
      p->priority = new_priority;
    800028c0:	1b44b823          	sd	s4,432(s1)
      p->sleep_time = 0;
    800028c4:	1804bc23          	sd	zero,408(s1)
      p->run_time = 0;
    800028c8:	1604bc23          	sd	zero,376(s1)
      release(&p->lock);
    800028cc:	8526                	mv	a0,s1
    800028ce:	ffffe097          	auipc	ra,0xffffe
    800028d2:	436080e7          	jalr	1078(ra) # 80000d04 <release>
      if(reschedule)
    800028d6:	012a4b63          	blt	s4,s2,800028ec <setpriority+0x7a>
  }

  return prev_priority;
}
    800028da:	854a                	mv	a0,s2
    800028dc:	70a2                	ld	ra,40(sp)
    800028de:	7402                	ld	s0,32(sp)
    800028e0:	64e2                	ld	s1,24(sp)
    800028e2:	6942                	ld	s2,16(sp)
    800028e4:	69a2                	ld	s3,8(sp)
    800028e6:	6a02                	ld	s4,0(sp)
    800028e8:	6145                	addi	sp,sp,48
    800028ea:	8082                	ret
        yield();
    800028ec:	00000097          	auipc	ra,0x0
    800028f0:	994080e7          	jalr	-1644(ra) # 80002280 <yield>
    800028f4:	b7dd                	j	800028da <setpriority+0x68>

00000000800028f6 <waitx>:

// waitx: igual que wait pero devuelve tiempos rtime y wtime
int
waitx(uint64 addr, uint* rtime, uint* wtime)
{
    800028f6:	711d                	addi	sp,sp,-96
    800028f8:	ec86                	sd	ra,88(sp)
    800028fa:	e8a2                	sd	s0,80(sp)
    800028fc:	e4a6                	sd	s1,72(sp)
    800028fe:	e0ca                	sd	s2,64(sp)
    80002900:	fc4e                	sd	s3,56(sp)
    80002902:	f852                	sd	s4,48(sp)
    80002904:	f456                	sd	s5,40(sp)
    80002906:	f05a                	sd	s6,32(sp)
    80002908:	ec5e                	sd	s7,24(sp)
    8000290a:	e862                	sd	s8,16(sp)
    8000290c:	e466                	sd	s9,8(sp)
    8000290e:	1080                	addi	s0,sp,96
    80002910:	8baa                	mv	s7,a0
    80002912:	8c2e                	mv	s8,a1
    80002914:	8cb2                	mv	s9,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    80002916:	fffff097          	auipc	ra,0xfffff
    8000291a:	170080e7          	jalr	368(ra) # 80001a86 <myproc>
    8000291e:	892a                	mv	s2,a0

  acquire(&wait_lock);
    80002920:	00012517          	auipc	a0,0x12
    80002924:	99850513          	addi	a0,a0,-1640 # 800142b8 <wait_lock>
    80002928:	ffffe097          	auipc	ra,0xffffe
    8000292c:	32c080e7          	jalr	812(ra) # 80000c54 <acquire>
      if(np->parent == p){

        acquire(&np->lock);
        havekids = 1;

        if(np->state == ZOMBIE){
    80002930:	4a15                	li	s4,5
        havekids = 1;
    80002932:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002934:	00019997          	auipc	s3,0x19
    80002938:	f9c98993          	addi	s3,s3,-100 # 8001b8d0 <tickslock>
    if(!havekids || p->killed){
      release(&wait_lock);
      return -1;
    }

    sleep(p, &wait_lock);
    8000293c:	00012b17          	auipc	s6,0x12
    80002940:	97cb0b13          	addi	s6,s6,-1668 # 800142b8 <wait_lock>
    80002944:	a8f1                	j	80002a20 <waitx+0x12a>
          pid = np->pid;
    80002946:	0304a983          	lw	s3,48(s1)
          *rtime = np->run_time;
    8000294a:	1784b783          	ld	a5,376(s1)
    8000294e:	00fc2023          	sw	a5,0(s8)
          *wtime = np->exit_time - np->create_time - np->run_time;
    80002952:	1a04b783          	ld	a5,416(s1)
    80002956:	1704b703          	ld	a4,368(s1)
    8000295a:	1784b683          	ld	a3,376(s1)
    8000295e:	9f35                	addw	a4,a4,a3
    80002960:	9f99                	subw	a5,a5,a4
    80002962:	00fca023          	sw	a5,0(s9)
          if(addr != 0 &&
    80002966:	000b8e63          	beqz	s7,80002982 <waitx+0x8c>
             copyout(p->pagetable,
    8000296a:	4691                	li	a3,4
    8000296c:	02c48613          	addi	a2,s1,44
    80002970:	85de                	mv	a1,s7
    80002972:	05093503          	ld	a0,80(s2)
    80002976:	fffff097          	auipc	ra,0xfffff
    8000297a:	d94080e7          	jalr	-620(ra) # 8000170a <copyout>
          if(addr != 0 &&
    8000297e:	04054263          	bltz	a0,800029c2 <waitx+0xcc>
          freeproc(np);
    80002982:	8526                	mv	a0,s1
    80002984:	fffff097          	auipc	ra,0xfffff
    80002988:	2b6080e7          	jalr	694(ra) # 80001c3a <freeproc>
          release(&np->lock);
    8000298c:	8526                	mv	a0,s1
    8000298e:	ffffe097          	auipc	ra,0xffffe
    80002992:	376080e7          	jalr	886(ra) # 80000d04 <release>
          release(&wait_lock);
    80002996:	00012517          	auipc	a0,0x12
    8000299a:	92250513          	addi	a0,a0,-1758 # 800142b8 <wait_lock>
    8000299e:	ffffe097          	auipc	ra,0xffffe
    800029a2:	366080e7          	jalr	870(ra) # 80000d04 <release>
  }
}
    800029a6:	854e                	mv	a0,s3
    800029a8:	60e6                	ld	ra,88(sp)
    800029aa:	6446                	ld	s0,80(sp)
    800029ac:	64a6                	ld	s1,72(sp)
    800029ae:	6906                	ld	s2,64(sp)
    800029b0:	79e2                	ld	s3,56(sp)
    800029b2:	7a42                	ld	s4,48(sp)
    800029b4:	7aa2                	ld	s5,40(sp)
    800029b6:	7b02                	ld	s6,32(sp)
    800029b8:	6be2                	ld	s7,24(sp)
    800029ba:	6c42                	ld	s8,16(sp)
    800029bc:	6ca2                	ld	s9,8(sp)
    800029be:	6125                	addi	sp,sp,96
    800029c0:	8082                	ret
            release(&np->lock);
    800029c2:	8526                	mv	a0,s1
    800029c4:	ffffe097          	auipc	ra,0xffffe
    800029c8:	340080e7          	jalr	832(ra) # 80000d04 <release>
            release(&wait_lock);
    800029cc:	00012517          	auipc	a0,0x12
    800029d0:	8ec50513          	addi	a0,a0,-1812 # 800142b8 <wait_lock>
    800029d4:	ffffe097          	auipc	ra,0xffffe
    800029d8:	330080e7          	jalr	816(ra) # 80000d04 <release>
            return -1;
    800029dc:	59fd                	li	s3,-1
    800029de:	b7e1                	j	800029a6 <waitx+0xb0>
    for(np = proc; np < &proc[NPROC]; np++){
    800029e0:	1c848493          	addi	s1,s1,456
    800029e4:	03348463          	beq	s1,s3,80002a0c <waitx+0x116>
      if(np->parent == p){
    800029e8:	7c9c                	ld	a5,56(s1)
    800029ea:	ff279be3          	bne	a5,s2,800029e0 <waitx+0xea>
        acquire(&np->lock);
    800029ee:	8526                	mv	a0,s1
    800029f0:	ffffe097          	auipc	ra,0xffffe
    800029f4:	264080e7          	jalr	612(ra) # 80000c54 <acquire>
        if(np->state == ZOMBIE){
    800029f8:	4c9c                	lw	a5,24(s1)
    800029fa:	f54786e3          	beq	a5,s4,80002946 <waitx+0x50>
        release(&np->lock);
    800029fe:	8526                	mv	a0,s1
    80002a00:	ffffe097          	auipc	ra,0xffffe
    80002a04:	304080e7          	jalr	772(ra) # 80000d04 <release>
        havekids = 1;
    80002a08:	8756                	mv	a4,s5
    80002a0a:	bfd9                	j	800029e0 <waitx+0xea>
    if(!havekids || p->killed){
    80002a0c:	c305                	beqz	a4,80002a2c <waitx+0x136>
    80002a0e:	02892783          	lw	a5,40(s2)
    80002a12:	ef89                	bnez	a5,80002a2c <waitx+0x136>
    sleep(p, &wait_lock);
    80002a14:	85da                	mv	a1,s6
    80002a16:	854a                	mv	a0,s2
    80002a18:	00000097          	auipc	ra,0x0
    80002a1c:	8a4080e7          	jalr	-1884(ra) # 800022bc <sleep>
    havekids = 0;
    80002a20:	4701                	li	a4,0
    for(np = proc; np < &proc[NPROC]; np++){
    80002a22:	00012497          	auipc	s1,0x12
    80002a26:	cae48493          	addi	s1,s1,-850 # 800146d0 <proc>
    80002a2a:	bf7d                	j	800029e8 <waitx+0xf2>
      release(&wait_lock);
    80002a2c:	00012517          	auipc	a0,0x12
    80002a30:	88c50513          	addi	a0,a0,-1908 # 800142b8 <wait_lock>
    80002a34:	ffffe097          	auipc	ra,0xffffe
    80002a38:	2d0080e7          	jalr	720(ra) # 80000d04 <release>
      return -1;
    80002a3c:	59fd                	li	s3,-1
    80002a3e:	b7a5                	j	800029a6 <waitx+0xb0>

0000000080002a40 <swtch>:
    80002a40:	00153023          	sd	ra,0(a0)
    80002a44:	00253423          	sd	sp,8(a0)
    80002a48:	e900                	sd	s0,16(a0)
    80002a4a:	ed04                	sd	s1,24(a0)
    80002a4c:	03253023          	sd	s2,32(a0)
    80002a50:	03353423          	sd	s3,40(a0)
    80002a54:	03453823          	sd	s4,48(a0)
    80002a58:	03553c23          	sd	s5,56(a0)
    80002a5c:	05653023          	sd	s6,64(a0)
    80002a60:	05753423          	sd	s7,72(a0)
    80002a64:	05853823          	sd	s8,80(a0)
    80002a68:	05953c23          	sd	s9,88(a0)
    80002a6c:	07a53023          	sd	s10,96(a0)
    80002a70:	07b53423          	sd	s11,104(a0)
    80002a74:	0005b083          	ld	ra,0(a1)
    80002a78:	0085b103          	ld	sp,8(a1)
    80002a7c:	6980                	ld	s0,16(a1)
    80002a7e:	6d84                	ld	s1,24(a1)
    80002a80:	0205b903          	ld	s2,32(a1)
    80002a84:	0285b983          	ld	s3,40(a1)
    80002a88:	0305ba03          	ld	s4,48(a1)
    80002a8c:	0385ba83          	ld	s5,56(a1)
    80002a90:	0405bb03          	ld	s6,64(a1)
    80002a94:	0485bb83          	ld	s7,72(a1)
    80002a98:	0505bc03          	ld	s8,80(a1)
    80002a9c:	0585bc83          	ld	s9,88(a1)
    80002aa0:	0605bd03          	ld	s10,96(a1)
    80002aa4:	0685bd83          	ld	s11,104(a1)
    80002aa8:	8082                	ret

0000000080002aaa <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002aaa:	1141                	addi	sp,sp,-16
    80002aac:	e406                	sd	ra,8(sp)
    80002aae:	e022                	sd	s0,0(sp)
    80002ab0:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002ab2:	00006597          	auipc	a1,0x6
    80002ab6:	83658593          	addi	a1,a1,-1994 # 800082e8 <etext+0x2e8>
    80002aba:	00019517          	auipc	a0,0x19
    80002abe:	e1650513          	addi	a0,a0,-490 # 8001b8d0 <tickslock>
    80002ac2:	ffffe097          	auipc	ra,0xffffe
    80002ac6:	0f8080e7          	jalr	248(ra) # 80000bba <initlock>
}
    80002aca:	60a2                	ld	ra,8(sp)
    80002acc:	6402                	ld	s0,0(sp)
    80002ace:	0141                	addi	sp,sp,16
    80002ad0:	8082                	ret

0000000080002ad2 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002ad2:	1141                	addi	sp,sp,-16
    80002ad4:	e406                	sd	ra,8(sp)
    80002ad6:	e022                	sd	s0,0(sp)
    80002ad8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ada:	00003797          	auipc	a5,0x3
    80002ade:	7d678793          	addi	a5,a5,2006 # 800062b0 <kernelvec>
    80002ae2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002ae6:	60a2                	ld	ra,8(sp)
    80002ae8:	6402                	ld	s0,0(sp)
    80002aea:	0141                	addi	sp,sp,16
    80002aec:	8082                	ret

0000000080002aee <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002aee:	1141                	addi	sp,sp,-16
    80002af0:	e406                	sd	ra,8(sp)
    80002af2:	e022                	sd	s0,0(sp)
    80002af4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002af6:	fffff097          	auipc	ra,0xfffff
    80002afa:	f90080e7          	jalr	-112(ra) # 80001a86 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002afe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002b02:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b04:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002b08:	00004697          	auipc	a3,0x4
    80002b0c:	4f868693          	addi	a3,a3,1272 # 80007000 <_trampoline>
    80002b10:	00004717          	auipc	a4,0x4
    80002b14:	4f070713          	addi	a4,a4,1264 # 80007000 <_trampoline>
    80002b18:	8f15                	sub	a4,a4,a3
    80002b1a:	040007b7          	lui	a5,0x4000
    80002b1e:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002b20:	07b2                	slli	a5,a5,0xc
    80002b22:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b24:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002b28:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002b2a:	18002673          	csrr	a2,satp
    80002b2e:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002b30:	6d30                	ld	a2,88(a0)
    80002b32:	6138                	ld	a4,64(a0)
    80002b34:	6585                	lui	a1,0x1
    80002b36:	972e                	add	a4,a4,a1
    80002b38:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002b3a:	6d38                	ld	a4,88(a0)
    80002b3c:	00000617          	auipc	a2,0x0
    80002b40:	15260613          	addi	a2,a2,338 # 80002c8e <usertrap>
    80002b44:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002b46:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002b48:	8612                	mv	a2,tp
    80002b4a:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b4c:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002b50:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002b54:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b58:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002b5c:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b5e:	6f18                	ld	a4,24(a4)
    80002b60:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b64:	692c                	ld	a1,80(a0)
    80002b66:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002b68:	00004717          	auipc	a4,0x4
    80002b6c:	52870713          	addi	a4,a4,1320 # 80007090 <userret>
    80002b70:	8f15                	sub	a4,a4,a3
    80002b72:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002b74:	577d                	li	a4,-1
    80002b76:	177e                	slli	a4,a4,0x3f
    80002b78:	8dd9                	or	a1,a1,a4
    80002b7a:	02000537          	lui	a0,0x2000
    80002b7e:	157d                	addi	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    80002b80:	0536                	slli	a0,a0,0xd
    80002b82:	9782                	jalr	a5
}
    80002b84:	60a2                	ld	ra,8(sp)
    80002b86:	6402                	ld	s0,0(sp)
    80002b88:	0141                	addi	sp,sp,16
    80002b8a:	8082                	ret

0000000080002b8c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002b8c:	1141                	addi	sp,sp,-16
    80002b8e:	e406                	sd	ra,8(sp)
    80002b90:	e022                	sd	s0,0(sp)
    80002b92:	0800                	addi	s0,sp,16
  acquire(&tickslock);
    80002b94:	00019517          	auipc	a0,0x19
    80002b98:	d3c50513          	addi	a0,a0,-708 # 8001b8d0 <tickslock>
    80002b9c:	ffffe097          	auipc	ra,0xffffe
    80002ba0:	0b8080e7          	jalr	184(ra) # 80000c54 <acquire>
  ticks++;
    80002ba4:	00009717          	auipc	a4,0x9
    80002ba8:	48c70713          	addi	a4,a4,1164 # 8000c030 <ticks>
    80002bac:	431c                	lw	a5,0(a4)
    80002bae:	2785                	addiw	a5,a5,1
    80002bb0:	c31c                	sw	a5,0(a4)
  update_time();
    80002bb2:	00000097          	auipc	ra,0x0
    80002bb6:	c44080e7          	jalr	-956(ra) # 800027f6 <update_time>
  wakeup(&ticks);
    80002bba:	00009517          	auipc	a0,0x9
    80002bbe:	47650513          	addi	a0,a0,1142 # 8000c030 <ticks>
    80002bc2:	00000097          	auipc	ra,0x0
    80002bc6:	880080e7          	jalr	-1920(ra) # 80002442 <wakeup>
  release(&tickslock);
    80002bca:	00019517          	auipc	a0,0x19
    80002bce:	d0650513          	addi	a0,a0,-762 # 8001b8d0 <tickslock>
    80002bd2:	ffffe097          	auipc	ra,0xffffe
    80002bd6:	132080e7          	jalr	306(ra) # 80000d04 <release>
}
    80002bda:	60a2                	ld	ra,8(sp)
    80002bdc:	6402                	ld	s0,0(sp)
    80002bde:	0141                	addi	sp,sp,16
    80002be0:	8082                	ret

0000000080002be2 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002be2:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002be6:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002be8:	0a07d263          	bgez	a5,80002c8c <devintr+0xaa>
{
    80002bec:	1101                	addi	sp,sp,-32
    80002bee:	ec06                	sd	ra,24(sp)
    80002bf0:	e822                	sd	s0,16(sp)
    80002bf2:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    80002bf4:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002bf8:	46a5                	li	a3,9
    80002bfa:	00d70c63          	beq	a4,a3,80002c12 <devintr+0x30>
  } else if(scause == 0x8000000000000001L){
    80002bfe:	577d                	li	a4,-1
    80002c00:	177e                	slli	a4,a4,0x3f
    80002c02:	0705                	addi	a4,a4,1
    return 0;
    80002c04:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002c06:	06e78263          	beq	a5,a4,80002c6a <devintr+0x88>
  }
}
    80002c0a:	60e2                	ld	ra,24(sp)
    80002c0c:	6442                	ld	s0,16(sp)
    80002c0e:	6105                	addi	sp,sp,32
    80002c10:	8082                	ret
    80002c12:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002c14:	00003097          	auipc	ra,0x3
    80002c18:	7a8080e7          	jalr	1960(ra) # 800063bc <plic_claim>
    80002c1c:	872a                	mv	a4,a0
    80002c1e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002c20:	47a9                	li	a5,10
    80002c22:	00f50963          	beq	a0,a5,80002c34 <devintr+0x52>
    } else if(irq == VIRTIO0_IRQ){
    80002c26:	4785                	li	a5,1
    80002c28:	00f50b63          	beq	a0,a5,80002c3e <devintr+0x5c>
    return 1;
    80002c2c:	4505                	li	a0,1
    } else if(irq){
    80002c2e:	ef09                	bnez	a4,80002c48 <devintr+0x66>
    80002c30:	64a2                	ld	s1,8(sp)
    80002c32:	bfe1                	j	80002c0a <devintr+0x28>
      uartintr();
    80002c34:	ffffe097          	auipc	ra,0xffffe
    80002c38:	dc4080e7          	jalr	-572(ra) # 800009f8 <uartintr>
    if(irq)
    80002c3c:	a839                	j	80002c5a <devintr+0x78>
      virtio_disk_intr();
    80002c3e:	00004097          	auipc	ra,0x4
    80002c42:	c38080e7          	jalr	-968(ra) # 80006876 <virtio_disk_intr>
    if(irq)
    80002c46:	a811                	j	80002c5a <devintr+0x78>
      printf("unexpected interrupt irq=%d\n", irq);
    80002c48:	85ba                	mv	a1,a4
    80002c4a:	00005517          	auipc	a0,0x5
    80002c4e:	6a650513          	addi	a0,a0,1702 # 800082f0 <etext+0x2f0>
    80002c52:	ffffe097          	auipc	ra,0xffffe
    80002c56:	94e080e7          	jalr	-1714(ra) # 800005a0 <printf>
      plic_complete(irq);
    80002c5a:	8526                	mv	a0,s1
    80002c5c:	00003097          	auipc	ra,0x3
    80002c60:	784080e7          	jalr	1924(ra) # 800063e0 <plic_complete>
    return 1;
    80002c64:	4505                	li	a0,1
    80002c66:	64a2                	ld	s1,8(sp)
    80002c68:	b74d                	j	80002c0a <devintr+0x28>
    if(cpuid() == 0){
    80002c6a:	fffff097          	auipc	ra,0xfffff
    80002c6e:	de8080e7          	jalr	-536(ra) # 80001a52 <cpuid>
    80002c72:	c901                	beqz	a0,80002c82 <devintr+0xa0>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002c74:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002c78:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002c7a:	14479073          	csrw	sip,a5
    return 2;
    80002c7e:	4509                	li	a0,2
    80002c80:	b769                	j	80002c0a <devintr+0x28>
      clockintr();
    80002c82:	00000097          	auipc	ra,0x0
    80002c86:	f0a080e7          	jalr	-246(ra) # 80002b8c <clockintr>
    80002c8a:	b7ed                	j	80002c74 <devintr+0x92>
}
    80002c8c:	8082                	ret

0000000080002c8e <usertrap>:
{
    80002c8e:	1101                	addi	sp,sp,-32
    80002c90:	ec06                	sd	ra,24(sp)
    80002c92:	e822                	sd	s0,16(sp)
    80002c94:	e426                	sd	s1,8(sp)
    80002c96:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c98:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002c9c:	1007f793          	andi	a5,a5,256
    80002ca0:	e3a5                	bnez	a5,80002d00 <usertrap+0x72>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ca2:	00003797          	auipc	a5,0x3
    80002ca6:	60e78793          	addi	a5,a5,1550 # 800062b0 <kernelvec>
    80002caa:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002cae:	fffff097          	auipc	ra,0xfffff
    80002cb2:	dd8080e7          	jalr	-552(ra) # 80001a86 <myproc>
    80002cb6:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002cb8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cba:	14102773          	csrr	a4,sepc
    80002cbe:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cc0:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002cc4:	47a1                	li	a5,8
    80002cc6:	04f71b63          	bne	a4,a5,80002d1c <usertrap+0x8e>
    if(p->killed)
    80002cca:	551c                	lw	a5,40(a0)
    80002ccc:	e3b1                	bnez	a5,80002d10 <usertrap+0x82>
    p->trapframe->epc += 4;
    80002cce:	6cb8                	ld	a4,88(s1)
    80002cd0:	6f1c                	ld	a5,24(a4)
    80002cd2:	0791                	addi	a5,a5,4
    80002cd4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cd6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002cda:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002cde:	10079073          	csrw	sstatus,a5
    syscall();
    80002ce2:	00000097          	auipc	ra,0x0
    80002ce6:	29c080e7          	jalr	668(ra) # 80002f7e <syscall>
  if(p->killed)
    80002cea:	549c                	lw	a5,40(s1)
    80002cec:	e7b5                	bnez	a5,80002d58 <usertrap+0xca>
  usertrapret();
    80002cee:	00000097          	auipc	ra,0x0
    80002cf2:	e00080e7          	jalr	-512(ra) # 80002aee <usertrapret>
}
    80002cf6:	60e2                	ld	ra,24(sp)
    80002cf8:	6442                	ld	s0,16(sp)
    80002cfa:	64a2                	ld	s1,8(sp)
    80002cfc:	6105                	addi	sp,sp,32
    80002cfe:	8082                	ret
    panic("usertrap: not from user mode");
    80002d00:	00005517          	auipc	a0,0x5
    80002d04:	61050513          	addi	a0,a0,1552 # 80008310 <etext+0x310>
    80002d08:	ffffe097          	auipc	ra,0xffffe
    80002d0c:	84e080e7          	jalr	-1970(ra) # 80000556 <panic>
      exit(-1);
    80002d10:	557d                	li	a0,-1
    80002d12:	00000097          	auipc	ra,0x0
    80002d16:	800080e7          	jalr	-2048(ra) # 80002512 <exit>
    80002d1a:	bf55                	j	80002cce <usertrap+0x40>
  } else if((which_dev = devintr()) != 0){
    80002d1c:	00000097          	auipc	ra,0x0
    80002d20:	ec6080e7          	jalr	-314(ra) # 80002be2 <devintr>
    80002d24:	f179                	bnez	a0,80002cea <usertrap+0x5c>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d26:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002d2a:	5890                	lw	a2,48(s1)
    80002d2c:	00005517          	auipc	a0,0x5
    80002d30:	60450513          	addi	a0,a0,1540 # 80008330 <etext+0x330>
    80002d34:	ffffe097          	auipc	ra,0xffffe
    80002d38:	86c080e7          	jalr	-1940(ra) # 800005a0 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d3c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d40:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d44:	00005517          	auipc	a0,0x5
    80002d48:	61c50513          	addi	a0,a0,1564 # 80008360 <etext+0x360>
    80002d4c:	ffffe097          	auipc	ra,0xffffe
    80002d50:	854080e7          	jalr	-1964(ra) # 800005a0 <printf>
    p->killed = 1;
    80002d54:	4785                	li	a5,1
    80002d56:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002d58:	557d                	li	a0,-1
    80002d5a:	fffff097          	auipc	ra,0xfffff
    80002d5e:	7b8080e7          	jalr	1976(ra) # 80002512 <exit>
    80002d62:	b771                	j	80002cee <usertrap+0x60>

0000000080002d64 <kerneltrap>:
{
    80002d64:	7179                	addi	sp,sp,-48
    80002d66:	f406                	sd	ra,40(sp)
    80002d68:	f022                	sd	s0,32(sp)
    80002d6a:	ec26                	sd	s1,24(sp)
    80002d6c:	e84a                	sd	s2,16(sp)
    80002d6e:	e44e                	sd	s3,8(sp)
    80002d70:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d72:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d76:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d7a:	142027f3          	csrr	a5,scause
    80002d7e:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    80002d80:	1004f793          	andi	a5,s1,256
    80002d84:	c78d                	beqz	a5,80002dae <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d86:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002d8a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002d8c:	eb8d                	bnez	a5,80002dbe <kerneltrap+0x5a>
  if((which_dev = devintr()) == 0){
    80002d8e:	00000097          	auipc	ra,0x0
    80002d92:	e54080e7          	jalr	-428(ra) # 80002be2 <devintr>
    80002d96:	cd05                	beqz	a0,80002dce <kerneltrap+0x6a>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d98:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d9c:	10049073          	csrw	sstatus,s1
}
    80002da0:	70a2                	ld	ra,40(sp)
    80002da2:	7402                	ld	s0,32(sp)
    80002da4:	64e2                	ld	s1,24(sp)
    80002da6:	6942                	ld	s2,16(sp)
    80002da8:	69a2                	ld	s3,8(sp)
    80002daa:	6145                	addi	sp,sp,48
    80002dac:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002dae:	00005517          	auipc	a0,0x5
    80002db2:	5d250513          	addi	a0,a0,1490 # 80008380 <etext+0x380>
    80002db6:	ffffd097          	auipc	ra,0xffffd
    80002dba:	7a0080e7          	jalr	1952(ra) # 80000556 <panic>
    panic("kerneltrap: interrupts enabled");
    80002dbe:	00005517          	auipc	a0,0x5
    80002dc2:	5ea50513          	addi	a0,a0,1514 # 800083a8 <etext+0x3a8>
    80002dc6:	ffffd097          	auipc	ra,0xffffd
    80002dca:	790080e7          	jalr	1936(ra) # 80000556 <panic>
    printf("scause %p\n", scause);
    80002dce:	85ce                	mv	a1,s3
    80002dd0:	00005517          	auipc	a0,0x5
    80002dd4:	5f850513          	addi	a0,a0,1528 # 800083c8 <etext+0x3c8>
    80002dd8:	ffffd097          	auipc	ra,0xffffd
    80002ddc:	7c8080e7          	jalr	1992(ra) # 800005a0 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002de0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002de4:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002de8:	00005517          	auipc	a0,0x5
    80002dec:	5f050513          	addi	a0,a0,1520 # 800083d8 <etext+0x3d8>
    80002df0:	ffffd097          	auipc	ra,0xffffd
    80002df4:	7b0080e7          	jalr	1968(ra) # 800005a0 <printf>
    panic("kerneltrap");
    80002df8:	00005517          	auipc	a0,0x5
    80002dfc:	5f850513          	addi	a0,a0,1528 # 800083f0 <etext+0x3f0>
    80002e00:	ffffd097          	auipc	ra,0xffffd
    80002e04:	756080e7          	jalr	1878(ra) # 80000556 <panic>

0000000080002e08 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002e08:	1101                	addi	sp,sp,-32
    80002e0a:	ec06                	sd	ra,24(sp)
    80002e0c:	e822                	sd	s0,16(sp)
    80002e0e:	e426                	sd	s1,8(sp)
    80002e10:	1000                	addi	s0,sp,32
    80002e12:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002e14:	fffff097          	auipc	ra,0xfffff
    80002e18:	c72080e7          	jalr	-910(ra) # 80001a86 <myproc>
  switch (n) {
    80002e1c:	4795                	li	a5,5
    80002e1e:	0497e163          	bltu	a5,s1,80002e60 <argraw+0x58>
    80002e22:	048a                	slli	s1,s1,0x2
    80002e24:	00006717          	auipc	a4,0x6
    80002e28:	a4c70713          	addi	a4,a4,-1460 # 80008870 <states.0+0x30>
    80002e2c:	94ba                	add	s1,s1,a4
    80002e2e:	409c                	lw	a5,0(s1)
    80002e30:	97ba                	add	a5,a5,a4
    80002e32:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002e34:	6d3c                	ld	a5,88(a0)
    80002e36:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002e38:	60e2                	ld	ra,24(sp)
    80002e3a:	6442                	ld	s0,16(sp)
    80002e3c:	64a2                	ld	s1,8(sp)
    80002e3e:	6105                	addi	sp,sp,32
    80002e40:	8082                	ret
    return p->trapframe->a1;
    80002e42:	6d3c                	ld	a5,88(a0)
    80002e44:	7fa8                	ld	a0,120(a5)
    80002e46:	bfcd                	j	80002e38 <argraw+0x30>
    return p->trapframe->a2;
    80002e48:	6d3c                	ld	a5,88(a0)
    80002e4a:	63c8                	ld	a0,128(a5)
    80002e4c:	b7f5                	j	80002e38 <argraw+0x30>
    return p->trapframe->a3;
    80002e4e:	6d3c                	ld	a5,88(a0)
    80002e50:	67c8                	ld	a0,136(a5)
    80002e52:	b7dd                	j	80002e38 <argraw+0x30>
    return p->trapframe->a4;
    80002e54:	6d3c                	ld	a5,88(a0)
    80002e56:	6bc8                	ld	a0,144(a5)
    80002e58:	b7c5                	j	80002e38 <argraw+0x30>
    return p->trapframe->a5;
    80002e5a:	6d3c                	ld	a5,88(a0)
    80002e5c:	6fc8                	ld	a0,152(a5)
    80002e5e:	bfe9                	j	80002e38 <argraw+0x30>
  panic("argraw");
    80002e60:	00005517          	auipc	a0,0x5
    80002e64:	5a050513          	addi	a0,a0,1440 # 80008400 <etext+0x400>
    80002e68:	ffffd097          	auipc	ra,0xffffd
    80002e6c:	6ee080e7          	jalr	1774(ra) # 80000556 <panic>

0000000080002e70 <fetchaddr>:
{
    80002e70:	1101                	addi	sp,sp,-32
    80002e72:	ec06                	sd	ra,24(sp)
    80002e74:	e822                	sd	s0,16(sp)
    80002e76:	e426                	sd	s1,8(sp)
    80002e78:	e04a                	sd	s2,0(sp)
    80002e7a:	1000                	addi	s0,sp,32
    80002e7c:	84aa                	mv	s1,a0
    80002e7e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002e80:	fffff097          	auipc	ra,0xfffff
    80002e84:	c06080e7          	jalr	-1018(ra) # 80001a86 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002e88:	653c                	ld	a5,72(a0)
    80002e8a:	02f4f863          	bgeu	s1,a5,80002eba <fetchaddr+0x4a>
    80002e8e:	00848713          	addi	a4,s1,8
    80002e92:	02e7e663          	bltu	a5,a4,80002ebe <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002e96:	46a1                	li	a3,8
    80002e98:	8626                	mv	a2,s1
    80002e9a:	85ca                	mv	a1,s2
    80002e9c:	6928                	ld	a0,80(a0)
    80002e9e:	fffff097          	auipc	ra,0xfffff
    80002ea2:	8f8080e7          	jalr	-1800(ra) # 80001796 <copyin>
    80002ea6:	00a03533          	snez	a0,a0
    80002eaa:	40a0053b          	negw	a0,a0
}
    80002eae:	60e2                	ld	ra,24(sp)
    80002eb0:	6442                	ld	s0,16(sp)
    80002eb2:	64a2                	ld	s1,8(sp)
    80002eb4:	6902                	ld	s2,0(sp)
    80002eb6:	6105                	addi	sp,sp,32
    80002eb8:	8082                	ret
    return -1;
    80002eba:	557d                	li	a0,-1
    80002ebc:	bfcd                	j	80002eae <fetchaddr+0x3e>
    80002ebe:	557d                	li	a0,-1
    80002ec0:	b7fd                	j	80002eae <fetchaddr+0x3e>

0000000080002ec2 <fetchstr>:
{
    80002ec2:	7179                	addi	sp,sp,-48
    80002ec4:	f406                	sd	ra,40(sp)
    80002ec6:	f022                	sd	s0,32(sp)
    80002ec8:	ec26                	sd	s1,24(sp)
    80002eca:	e84a                	sd	s2,16(sp)
    80002ecc:	e44e                	sd	s3,8(sp)
    80002ece:	1800                	addi	s0,sp,48
    80002ed0:	89aa                	mv	s3,a0
    80002ed2:	84ae                	mv	s1,a1
    80002ed4:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002ed6:	fffff097          	auipc	ra,0xfffff
    80002eda:	bb0080e7          	jalr	-1104(ra) # 80001a86 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002ede:	86ca                	mv	a3,s2
    80002ee0:	864e                	mv	a2,s3
    80002ee2:	85a6                	mv	a1,s1
    80002ee4:	6928                	ld	a0,80(a0)
    80002ee6:	fffff097          	auipc	ra,0xfffff
    80002eea:	93e080e7          	jalr	-1730(ra) # 80001824 <copyinstr>
  if(err < 0)
    80002eee:	00054763          	bltz	a0,80002efc <fetchstr+0x3a>
  return strlen(buf);
    80002ef2:	8526                	mv	a0,s1
    80002ef4:	ffffe097          	auipc	ra,0xffffe
    80002ef8:	fe6080e7          	jalr	-26(ra) # 80000eda <strlen>
}
    80002efc:	70a2                	ld	ra,40(sp)
    80002efe:	7402                	ld	s0,32(sp)
    80002f00:	64e2                	ld	s1,24(sp)
    80002f02:	6942                	ld	s2,16(sp)
    80002f04:	69a2                	ld	s3,8(sp)
    80002f06:	6145                	addi	sp,sp,48
    80002f08:	8082                	ret

0000000080002f0a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002f0a:	1101                	addi	sp,sp,-32
    80002f0c:	ec06                	sd	ra,24(sp)
    80002f0e:	e822                	sd	s0,16(sp)
    80002f10:	e426                	sd	s1,8(sp)
    80002f12:	1000                	addi	s0,sp,32
    80002f14:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f16:	00000097          	auipc	ra,0x0
    80002f1a:	ef2080e7          	jalr	-270(ra) # 80002e08 <argraw>
    80002f1e:	c088                	sw	a0,0(s1)
  return 0;
}
    80002f20:	4501                	li	a0,0
    80002f22:	60e2                	ld	ra,24(sp)
    80002f24:	6442                	ld	s0,16(sp)
    80002f26:	64a2                	ld	s1,8(sp)
    80002f28:	6105                	addi	sp,sp,32
    80002f2a:	8082                	ret

0000000080002f2c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002f2c:	1101                	addi	sp,sp,-32
    80002f2e:	ec06                	sd	ra,24(sp)
    80002f30:	e822                	sd	s0,16(sp)
    80002f32:	e426                	sd	s1,8(sp)
    80002f34:	1000                	addi	s0,sp,32
    80002f36:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f38:	00000097          	auipc	ra,0x0
    80002f3c:	ed0080e7          	jalr	-304(ra) # 80002e08 <argraw>
    80002f40:	e088                	sd	a0,0(s1)
  return 0;
}
    80002f42:	4501                	li	a0,0
    80002f44:	60e2                	ld	ra,24(sp)
    80002f46:	6442                	ld	s0,16(sp)
    80002f48:	64a2                	ld	s1,8(sp)
    80002f4a:	6105                	addi	sp,sp,32
    80002f4c:	8082                	ret

0000000080002f4e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002f4e:	1101                	addi	sp,sp,-32
    80002f50:	ec06                	sd	ra,24(sp)
    80002f52:	e822                	sd	s0,16(sp)
    80002f54:	e426                	sd	s1,8(sp)
    80002f56:	e04a                	sd	s2,0(sp)
    80002f58:	1000                	addi	s0,sp,32
    80002f5a:	892e                	mv	s2,a1
    80002f5c:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002f5e:	00000097          	auipc	ra,0x0
    80002f62:	eaa080e7          	jalr	-342(ra) # 80002e08 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002f66:	8626                	mv	a2,s1
    80002f68:	85ca                	mv	a1,s2
    80002f6a:	00000097          	auipc	ra,0x0
    80002f6e:	f58080e7          	jalr	-168(ra) # 80002ec2 <fetchstr>
}
    80002f72:	60e2                	ld	ra,24(sp)
    80002f74:	6442                	ld	s0,16(sp)
    80002f76:	64a2                	ld	s1,8(sp)
    80002f78:	6902                	ld	s2,0(sp)
    80002f7a:	6105                	addi	sp,sp,32
    80002f7c:	8082                	ret

0000000080002f7e <syscall>:
[SYS_setpriority] 2,
};

void
syscall(void)
{
    80002f7e:	715d                	addi	sp,sp,-80
    80002f80:	e486                	sd	ra,72(sp)
    80002f82:	e0a2                	sd	s0,64(sp)
    80002f84:	fc26                	sd	s1,56(sp)
    80002f86:	f84a                	sd	s2,48(sp)
    80002f88:	f44e                	sd	s3,40(sp)
    80002f8a:	f052                	sd	s4,32(sp)
    80002f8c:	ec56                	sd	s5,24(sp)
    80002f8e:	e85a                	sd	s6,16(sp)
    80002f90:	e45e                	sd	s7,8(sp)
    80002f92:	e062                	sd	s8,0(sp)
    80002f94:	0880                	addi	s0,sp,80
  int num, num_args;
  struct proc *p = myproc();
    80002f96:	fffff097          	auipc	ra,0xfffff
    80002f9a:	af0080e7          	jalr	-1296(ra) # 80001a86 <myproc>
    80002f9e:	8a2a                	mv	s4,a0

  num = p->trapframe->a7;
    80002fa0:	6d3c                	ld	a5,88(a0)
    80002fa2:	0a87ba83          	ld	s5,168(a5)
    80002fa6:	000a8b1b          	sext.w	s6,s5
  num_args = syscall_num[num];
    80002faa:	002b1713          	slli	a4,s6,0x2
    80002fae:	00006797          	auipc	a5,0x6
    80002fb2:	8da78793          	addi	a5,a5,-1830 # 80008888 <syscall_num>
    80002fb6:	97ba                	add	a5,a5,a4
    80002fb8:	0007a983          	lw	s3,0(a5)
  
  int arr[num_args];
    80002fbc:	00299b93          	slli	s7,s3,0x2
    80002fc0:	00fb8793          	addi	a5,s7,15
    80002fc4:	9bc1                	andi	a5,a5,-16
    80002fc6:	40f10133          	sub	sp,sp,a5
    80002fca:	8c0a                	mv	s8,sp
  for(int i = 0; i < num_args ; i++){
    80002fcc:	01305f63          	blez	s3,80002fea <syscall+0x6c>
    80002fd0:	890a                	mv	s2,sp
    80002fd2:	4481                	li	s1,0
    arr[i] = argraw(i);
    80002fd4:	8526                	mv	a0,s1
    80002fd6:	00000097          	auipc	ra,0x0
    80002fda:	e32080e7          	jalr	-462(ra) # 80002e08 <argraw>
    80002fde:	00a92023          	sw	a0,0(s2)
  for(int i = 0; i < num_args ; i++){
    80002fe2:	2485                	addiw	s1,s1,1
    80002fe4:	0911                	addi	s2,s2,4
    80002fe6:	fe9997e3          	bne	s3,s1,80002fd4 <syscall+0x56>
  }

  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002fea:	3afd                	addiw	s5,s5,-1
    80002fec:	47dd                	li	a5,23
    80002fee:	0b57e763          	bltu	a5,s5,8000309c <syscall+0x11e>
    80002ff2:	003b1713          	slli	a4,s6,0x3
    80002ff6:	00006797          	auipc	a5,0x6
    80002ffa:	89278793          	addi	a5,a5,-1902 # 80008888 <syscall_num>
    80002ffe:	97ba                	add	a5,a5,a4
    80003000:	77bc                	ld	a5,104(a5)
    80003002:	cfc9                	beqz	a5,8000309c <syscall+0x11e>
    p->trapframe->a0 = syscalls[num]();
    80003004:	058a3483          	ld	s1,88(s4)
    80003008:	9782                	jalr	a5
    8000300a:	f8a8                	sd	a0,112(s1)
    if((p -> mask >> num) & 1)
    8000300c:	168a2783          	lw	a5,360(s4)
    80003010:	4167d7bb          	sraw	a5,a5,s6
    80003014:	8b85                	andi	a5,a5,1
    80003016:	c7c5                	beqz	a5,800030be <syscall+0x140>
    {
      printf("%d: syscall %s (", p -> pid, syscall_names[num]);
    80003018:	0b0e                	slli	s6,s6,0x3
    8000301a:	00006797          	auipc	a5,0x6
    8000301e:	86e78793          	addi	a5,a5,-1938 # 80008888 <syscall_num>
    80003022:	97da                	add	a5,a5,s6
    80003024:	1307b603          	ld	a2,304(a5)
    80003028:	030a2583          	lw	a1,48(s4)
    8000302c:	00005517          	auipc	a0,0x5
    80003030:	3dc50513          	addi	a0,a0,988 # 80008408 <etext+0x408>
    80003034:	ffffd097          	auipc	ra,0xffffd
    80003038:	56c080e7          	jalr	1388(ra) # 800005a0 <printf>

      for(int i = 0; i < syscall_num[num]; i++)
    8000303c:	03305163          	blez	s3,8000305e <syscall+0xe0>
    80003040:	84e2                	mv	s1,s8
    80003042:	9be2                	add	s7,s7,s8
      {
        printf("%d ", arr[i]);
    80003044:	00005997          	auipc	s3,0x5
    80003048:	3dc98993          	addi	s3,s3,988 # 80008420 <etext+0x420>
    8000304c:	408c                	lw	a1,0(s1)
    8000304e:	854e                	mv	a0,s3
    80003050:	ffffd097          	auipc	ra,0xffffd
    80003054:	550080e7          	jalr	1360(ra) # 800005a0 <printf>
      for(int i = 0; i < syscall_num[num]; i++)
    80003058:	0491                	addi	s1,s1,4
    8000305a:	ff7499e3          	bne	s1,s7,8000304c <syscall+0xce>
      }

      printf("\b");
    8000305e:	00005517          	auipc	a0,0x5
    80003062:	3ca50513          	addi	a0,a0,970 # 80008428 <etext+0x428>
    80003066:	ffffd097          	auipc	ra,0xffffd
    8000306a:	53a080e7          	jalr	1338(ra) # 800005a0 <printf>
      printf(") -> %d", argraw(0));  
    8000306e:	4501                	li	a0,0
    80003070:	00000097          	auipc	ra,0x0
    80003074:	d98080e7          	jalr	-616(ra) # 80002e08 <argraw>
    80003078:	85aa                	mv	a1,a0
    8000307a:	00005517          	auipc	a0,0x5
    8000307e:	3b650513          	addi	a0,a0,950 # 80008430 <etext+0x430>
    80003082:	ffffd097          	auipc	ra,0xffffd
    80003086:	51e080e7          	jalr	1310(ra) # 800005a0 <printf>
      printf("\n");
    8000308a:	00005517          	auipc	a0,0x5
    8000308e:	f8650513          	addi	a0,a0,-122 # 80008010 <etext+0x10>
    80003092:	ffffd097          	auipc	ra,0xffffd
    80003096:	50e080e7          	jalr	1294(ra) # 800005a0 <printf>
    8000309a:	a015                	j	800030be <syscall+0x140>
    }
  } else {
    printf("%d %s: unknown sys call %d\n",p->pid, p->name, num);
    8000309c:	86da                	mv	a3,s6
    8000309e:	158a0613          	addi	a2,s4,344
    800030a2:	030a2583          	lw	a1,48(s4)
    800030a6:	00005517          	auipc	a0,0x5
    800030aa:	39250513          	addi	a0,a0,914 # 80008438 <etext+0x438>
    800030ae:	ffffd097          	auipc	ra,0xffffd
    800030b2:	4f2080e7          	jalr	1266(ra) # 800005a0 <printf>
    p->trapframe->a0 = -1;
    800030b6:	058a3783          	ld	a5,88(s4)
    800030ba:	577d                	li	a4,-1
    800030bc:	fbb8                	sd	a4,112(a5)
  }
}
    800030be:	fb040113          	addi	sp,s0,-80
    800030c2:	60a6                	ld	ra,72(sp)
    800030c4:	6406                	ld	s0,64(sp)
    800030c6:	74e2                	ld	s1,56(sp)
    800030c8:	7942                	ld	s2,48(sp)
    800030ca:	79a2                	ld	s3,40(sp)
    800030cc:	7a02                	ld	s4,32(sp)
    800030ce:	6ae2                	ld	s5,24(sp)
    800030d0:	6b42                	ld	s6,16(sp)
    800030d2:	6ba2                	ld	s7,8(sp)
    800030d4:	6c02                	ld	s8,0(sp)
    800030d6:	6161                	addi	sp,sp,80
    800030d8:	8082                	ret

00000000800030da <sys_setmemlimit>:

uint64
sys_setmemlimit(void)
{
    800030da:	1101                	addi	sp,sp,-32
    800030dc:	ec06                	sd	ra,24(sp)
    800030de:	e822                	sd	s0,16(sp)
    800030e0:	e426                	sd	s1,8(sp)
    800030e2:	1000                	addi	s0,sp,32
  *ip = argraw(n);
    800030e4:	4501                	li	a0,0
    800030e6:	00000097          	auipc	ra,0x0
    800030ea:	d22080e7          	jalr	-734(ra) # 80002e08 <argraw>
    800030ee:	84aa                	mv	s1,a0
    int lim;
    argint(0, &lim);
    struct proc *p = myproc();
    800030f0:	fffff097          	auipc	ra,0xfffff
    800030f4:	996080e7          	jalr	-1642(ra) # 80001a86 <myproc>
    p->max_mem = lim;
    800030f8:	0004879b          	sext.w	a5,s1
    800030fc:	1af53c23          	sd	a5,440(a0)
    return 0;
}
    80003100:	4501                	li	a0,0
    80003102:	60e2                	ld	ra,24(sp)
    80003104:	6442                	ld	s0,16(sp)
    80003106:	64a2                	ld	s1,8(sp)
    80003108:	6105                	addi	sp,sp,32
    8000310a:	8082                	ret

000000008000310c <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    8000310c:	1101                	addi	sp,sp,-32
    8000310e:	ec06                	sd	ra,24(sp)
    80003110:	e822                	sd	s0,16(sp)
    80003112:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003114:	fec40593          	addi	a1,s0,-20
    80003118:	4501                	li	a0,0
    8000311a:	00000097          	auipc	ra,0x0
    8000311e:	df0080e7          	jalr	-528(ra) # 80002f0a <argint>
    return -1;
    80003122:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003124:	00054963          	bltz	a0,80003136 <sys_exit+0x2a>
  exit(n);
    80003128:	fec42503          	lw	a0,-20(s0)
    8000312c:	fffff097          	auipc	ra,0xfffff
    80003130:	3e6080e7          	jalr	998(ra) # 80002512 <exit>
  return 0;  // not reached
    80003134:	4781                	li	a5,0
}
    80003136:	853e                	mv	a0,a5
    80003138:	60e2                	ld	ra,24(sp)
    8000313a:	6442                	ld	s0,16(sp)
    8000313c:	6105                	addi	sp,sp,32
    8000313e:	8082                	ret

0000000080003140 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003140:	1141                	addi	sp,sp,-16
    80003142:	e406                	sd	ra,8(sp)
    80003144:	e022                	sd	s0,0(sp)
    80003146:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003148:	fffff097          	auipc	ra,0xfffff
    8000314c:	93e080e7          	jalr	-1730(ra) # 80001a86 <myproc>
}
    80003150:	5908                	lw	a0,48(a0)
    80003152:	60a2                	ld	ra,8(sp)
    80003154:	6402                	ld	s0,0(sp)
    80003156:	0141                	addi	sp,sp,16
    80003158:	8082                	ret

000000008000315a <sys_fork>:

uint64
sys_fork(void)
{
    8000315a:	1141                	addi	sp,sp,-16
    8000315c:	e406                	sd	ra,8(sp)
    8000315e:	e022                	sd	s0,0(sp)
    80003160:	0800                	addi	s0,sp,16
  return fork();
    80003162:	fffff097          	auipc	ra,0xfffff
    80003166:	d4c080e7          	jalr	-692(ra) # 80001eae <fork>
}
    8000316a:	60a2                	ld	ra,8(sp)
    8000316c:	6402                	ld	s0,0(sp)
    8000316e:	0141                	addi	sp,sp,16
    80003170:	8082                	ret

0000000080003172 <sys_wait>:

uint64
sys_wait(void)
{
    80003172:	1101                	addi	sp,sp,-32
    80003174:	ec06                	sd	ra,24(sp)
    80003176:	e822                	sd	s0,16(sp)
    80003178:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    8000317a:	fe840593          	addi	a1,s0,-24
    8000317e:	4501                	li	a0,0
    80003180:	00000097          	auipc	ra,0x0
    80003184:	dac080e7          	jalr	-596(ra) # 80002f2c <argaddr>
    80003188:	87aa                	mv	a5,a0
    return -1;
    8000318a:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    8000318c:	0007c863          	bltz	a5,8000319c <sys_wait+0x2a>
  return wait(p);
    80003190:	fe843503          	ld	a0,-24(s0)
    80003194:	fffff097          	auipc	ra,0xfffff
    80003198:	18c080e7          	jalr	396(ra) # 80002320 <wait>
}
    8000319c:	60e2                	ld	ra,24(sp)
    8000319e:	6442                	ld	s0,16(sp)
    800031a0:	6105                	addi	sp,sp,32
    800031a2:	8082                	ret

00000000800031a4 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800031a4:	7179                	addi	sp,sp,-48
    800031a6:	f406                	sd	ra,40(sp)
    800031a8:	f022                	sd	s0,32(sp)
    800031aa:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    800031ac:	fdc40593          	addi	a1,s0,-36
    800031b0:	4501                	li	a0,0
    800031b2:	00000097          	auipc	ra,0x0
    800031b6:	d58080e7          	jalr	-680(ra) # 80002f0a <argint>
    return -1;
    800031ba:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800031bc:	02054363          	bltz	a0,800031e2 <sys_sbrk+0x3e>
    800031c0:	ec26                	sd	s1,24(sp)
  addr = myproc()->sz;
    800031c2:	fffff097          	auipc	ra,0xfffff
    800031c6:	8c4080e7          	jalr	-1852(ra) # 80001a86 <myproc>
    800031ca:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    800031cc:	fdc42503          	lw	a0,-36(s0)
    800031d0:	fffff097          	auipc	ra,0xfffff
    800031d4:	c46080e7          	jalr	-954(ra) # 80001e16 <growproc>
    800031d8:	00054a63          	bltz	a0,800031ec <sys_sbrk+0x48>
    return -1;
  return addr;
    800031dc:	0004879b          	sext.w	a5,s1
    800031e0:	64e2                	ld	s1,24(sp)
}
    800031e2:	853e                	mv	a0,a5
    800031e4:	70a2                	ld	ra,40(sp)
    800031e6:	7402                	ld	s0,32(sp)
    800031e8:	6145                	addi	sp,sp,48
    800031ea:	8082                	ret
    return -1;
    800031ec:	57fd                	li	a5,-1
    800031ee:	64e2                	ld	s1,24(sp)
    800031f0:	bfcd                	j	800031e2 <sys_sbrk+0x3e>

00000000800031f2 <sys_sleep>:

uint64
sys_sleep(void)
{
    800031f2:	7139                	addi	sp,sp,-64
    800031f4:	fc06                	sd	ra,56(sp)
    800031f6:	f822                	sd	s0,48(sp)
    800031f8:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    800031fa:	fcc40593          	addi	a1,s0,-52
    800031fe:	4501                	li	a0,0
    80003200:	00000097          	auipc	ra,0x0
    80003204:	d0a080e7          	jalr	-758(ra) # 80002f0a <argint>
    return -1;
    80003208:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000320a:	06054b63          	bltz	a0,80003280 <sys_sleep+0x8e>
  acquire(&tickslock);
    8000320e:	00018517          	auipc	a0,0x18
    80003212:	6c250513          	addi	a0,a0,1730 # 8001b8d0 <tickslock>
    80003216:	ffffe097          	auipc	ra,0xffffe
    8000321a:	a3e080e7          	jalr	-1474(ra) # 80000c54 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    8000321e:	fcc42783          	lw	a5,-52(s0)
    80003222:	c7b1                	beqz	a5,8000326e <sys_sleep+0x7c>
    80003224:	f426                	sd	s1,40(sp)
    80003226:	f04a                	sd	s2,32(sp)
    80003228:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    8000322a:	00009997          	auipc	s3,0x9
    8000322e:	e069a983          	lw	s3,-506(s3) # 8000c030 <ticks>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003232:	00018917          	auipc	s2,0x18
    80003236:	69e90913          	addi	s2,s2,1694 # 8001b8d0 <tickslock>
    8000323a:	00009497          	auipc	s1,0x9
    8000323e:	df648493          	addi	s1,s1,-522 # 8000c030 <ticks>
    if(myproc()->killed){
    80003242:	fffff097          	auipc	ra,0xfffff
    80003246:	844080e7          	jalr	-1980(ra) # 80001a86 <myproc>
    8000324a:	551c                	lw	a5,40(a0)
    8000324c:	ef9d                	bnez	a5,8000328a <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    8000324e:	85ca                	mv	a1,s2
    80003250:	8526                	mv	a0,s1
    80003252:	fffff097          	auipc	ra,0xfffff
    80003256:	06a080e7          	jalr	106(ra) # 800022bc <sleep>
  while(ticks - ticks0 < n){
    8000325a:	409c                	lw	a5,0(s1)
    8000325c:	413787bb          	subw	a5,a5,s3
    80003260:	fcc42703          	lw	a4,-52(s0)
    80003264:	fce7efe3          	bltu	a5,a4,80003242 <sys_sleep+0x50>
    80003268:	74a2                	ld	s1,40(sp)
    8000326a:	7902                	ld	s2,32(sp)
    8000326c:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    8000326e:	00018517          	auipc	a0,0x18
    80003272:	66250513          	addi	a0,a0,1634 # 8001b8d0 <tickslock>
    80003276:	ffffe097          	auipc	ra,0xffffe
    8000327a:	a8e080e7          	jalr	-1394(ra) # 80000d04 <release>
  return 0;
    8000327e:	4781                	li	a5,0
}
    80003280:	853e                	mv	a0,a5
    80003282:	70e2                	ld	ra,56(sp)
    80003284:	7442                	ld	s0,48(sp)
    80003286:	6121                	addi	sp,sp,64
    80003288:	8082                	ret
      release(&tickslock);
    8000328a:	00018517          	auipc	a0,0x18
    8000328e:	64650513          	addi	a0,a0,1606 # 8001b8d0 <tickslock>
    80003292:	ffffe097          	auipc	ra,0xffffe
    80003296:	a72080e7          	jalr	-1422(ra) # 80000d04 <release>
      return -1;
    8000329a:	57fd                	li	a5,-1
    8000329c:	74a2                	ld	s1,40(sp)
    8000329e:	7902                	ld	s2,32(sp)
    800032a0:	69e2                	ld	s3,24(sp)
    800032a2:	bff9                	j	80003280 <sys_sleep+0x8e>

00000000800032a4 <sys_kill>:

uint64
sys_kill(void)
{
    800032a4:	1101                	addi	sp,sp,-32
    800032a6:	ec06                	sd	ra,24(sp)
    800032a8:	e822                	sd	s0,16(sp)
    800032aa:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    800032ac:	fec40593          	addi	a1,s0,-20
    800032b0:	4501                	li	a0,0
    800032b2:	00000097          	auipc	ra,0x0
    800032b6:	c58080e7          	jalr	-936(ra) # 80002f0a <argint>
    800032ba:	87aa                	mv	a5,a0
    return -1;
    800032bc:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    800032be:	0007c863          	bltz	a5,800032ce <sys_kill+0x2a>
  return kill(pid);
    800032c2:	fec42503          	lw	a0,-20(s0)
    800032c6:	fffff097          	auipc	ra,0xfffff
    800032ca:	332080e7          	jalr	818(ra) # 800025f8 <kill>
}
    800032ce:	60e2                	ld	ra,24(sp)
    800032d0:	6442                	ld	s0,16(sp)
    800032d2:	6105                	addi	sp,sp,32
    800032d4:	8082                	ret

00000000800032d6 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800032d6:	1101                	addi	sp,sp,-32
    800032d8:	ec06                	sd	ra,24(sp)
    800032da:	e822                	sd	s0,16(sp)
    800032dc:	e426                	sd	s1,8(sp)
    800032de:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800032e0:	00018517          	auipc	a0,0x18
    800032e4:	5f050513          	addi	a0,a0,1520 # 8001b8d0 <tickslock>
    800032e8:	ffffe097          	auipc	ra,0xffffe
    800032ec:	96c080e7          	jalr	-1684(ra) # 80000c54 <acquire>
  xticks = ticks;
    800032f0:	00009797          	auipc	a5,0x9
    800032f4:	d407a783          	lw	a5,-704(a5) # 8000c030 <ticks>
    800032f8:	84be                	mv	s1,a5
  release(&tickslock);
    800032fa:	00018517          	auipc	a0,0x18
    800032fe:	5d650513          	addi	a0,a0,1494 # 8001b8d0 <tickslock>
    80003302:	ffffe097          	auipc	ra,0xffffe
    80003306:	a02080e7          	jalr	-1534(ra) # 80000d04 <release>
  return xticks;
}
    8000330a:	02049513          	slli	a0,s1,0x20
    8000330e:	9101                	srli	a0,a0,0x20
    80003310:	60e2                	ld	ra,24(sp)
    80003312:	6442                	ld	s0,16(sp)
    80003314:	64a2                	ld	s1,8(sp)
    80003316:	6105                	addi	sp,sp,32
    80003318:	8082                	ret

000000008000331a <sys_trace>:

uint64
sys_trace()
{
    8000331a:	1101                	addi	sp,sp,-32
    8000331c:	ec06                	sd	ra,24(sp)
    8000331e:	e822                	sd	s0,16(sp)
    80003320:	1000                	addi	s0,sp,32
  int mask;
  int arg_num = 0;

  if(argint(arg_num, &mask) >= 0)
    80003322:	fec40593          	addi	a1,s0,-20
    80003326:	4501                	li	a0,0
    80003328:	00000097          	auipc	ra,0x0
    8000332c:	be2080e7          	jalr	-1054(ra) # 80002f0a <argint>
    myproc() -> mask = mask;
    return 0;
  }
  else
  {
    return -1;
    80003330:	57fd                	li	a5,-1
  if(argint(arg_num, &mask) >= 0)
    80003332:	00054b63          	bltz	a0,80003348 <sys_trace+0x2e>
    myproc() -> mask = mask;
    80003336:	ffffe097          	auipc	ra,0xffffe
    8000333a:	750080e7          	jalr	1872(ra) # 80001a86 <myproc>
    8000333e:	fec42783          	lw	a5,-20(s0)
    80003342:	16f52423          	sw	a5,360(a0)
    return 0;
    80003346:	4781                	li	a5,0
  }  
}
    80003348:	853e                	mv	a0,a5
    8000334a:	60e2                	ld	ra,24(sp)
    8000334c:	6442                	ld	s0,16(sp)
    8000334e:	6105                	addi	sp,sp,32
    80003350:	8082                	ret

0000000080003352 <sys_setpriority>:

uint64
sys_setpriority()
{
    80003352:	1101                	addi	sp,sp,-32
    80003354:	ec06                	sd	ra,24(sp)
    80003356:	e822                	sd	s0,16(sp)
    80003358:	1000                	addi	s0,sp,32
  int pid, priority;
  int arg_num[2] = {0, 1};

  if(argint(arg_num[0], &priority) < 0)
    8000335a:	fe840593          	addi	a1,s0,-24
    8000335e:	4501                	li	a0,0
    80003360:	00000097          	auipc	ra,0x0
    80003364:	baa080e7          	jalr	-1110(ra) # 80002f0a <argint>
  {
    return -1;
    80003368:	57fd                	li	a5,-1
  if(argint(arg_num[0], &priority) < 0)
    8000336a:	02054563          	bltz	a0,80003394 <sys_setpriority+0x42>
  }
  if(argint(arg_num[1], &pid) < 0)
    8000336e:	fec40593          	addi	a1,s0,-20
    80003372:	4505                	li	a0,1
    80003374:	00000097          	auipc	ra,0x0
    80003378:	b96080e7          	jalr	-1130(ra) # 80002f0a <argint>
  {
    return -1;
    8000337c:	57fd                	li	a5,-1
  if(argint(arg_num[1], &pid) < 0)
    8000337e:	00054b63          	bltz	a0,80003394 <sys_setpriority+0x42>
  }
   
  return setpriority(priority, pid);
    80003382:	fec42583          	lw	a1,-20(s0)
    80003386:	fe842503          	lw	a0,-24(s0)
    8000338a:	fffff097          	auipc	ra,0xfffff
    8000338e:	4e8080e7          	jalr	1256(ra) # 80002872 <setpriority>
    80003392:	87aa                	mv	a5,a0
}
    80003394:	853e                	mv	a0,a5
    80003396:	60e2                	ld	ra,24(sp)
    80003398:	6442                	ld	s0,16(sp)
    8000339a:	6105                	addi	sp,sp,32
    8000339c:	8082                	ret

000000008000339e <sys_waitx>:

uint64
sys_waitx(void)
{
    8000339e:	7139                	addi	sp,sp,-64
    800033a0:	fc06                	sd	ra,56(sp)
    800033a2:	f822                	sd	s0,48(sp)
    800033a4:	f426                	sd	s1,40(sp)
    800033a6:	0080                	addi	s0,sp,64
  uint64 p, rt, wt;
  int rtime, wtime;

  // argumentos desde el usuario
  argaddr(0, &p);   // int *status
    800033a8:	fd840593          	addi	a1,s0,-40
    800033ac:	4501                	li	a0,0
    800033ae:	00000097          	auipc	ra,0x0
    800033b2:	b7e080e7          	jalr	-1154(ra) # 80002f2c <argaddr>
  argaddr(1, &rt);  // int *rtime
    800033b6:	fd040593          	addi	a1,s0,-48
    800033ba:	4505                	li	a0,1
    800033bc:	00000097          	auipc	ra,0x0
    800033c0:	b70080e7          	jalr	-1168(ra) # 80002f2c <argaddr>
  argaddr(2, &wt);  // int *wtime
    800033c4:	fc840593          	addi	a1,s0,-56
    800033c8:	4509                	li	a0,2
    800033ca:	00000097          	auipc	ra,0x0
    800033ce:	b62080e7          	jalr	-1182(ra) # 80002f2c <argaddr>

  int pid = waitx(p, &rtime, &wtime);
    800033d2:	fc040613          	addi	a2,s0,-64
    800033d6:	fc440593          	addi	a1,s0,-60
    800033da:	fd843503          	ld	a0,-40(s0)
    800033de:	fffff097          	auipc	ra,0xfffff
    800033e2:	518080e7          	jalr	1304(ra) # 800028f6 <waitx>
    800033e6:	84aa                	mv	s1,a0

  if (pid < 0)
    return -1;
    800033e8:	557d                	li	a0,-1
  if (pid < 0)
    800033ea:	0404c563          	bltz	s1,80003434 <sys_waitx+0x96>

  // copiar rtime al espacio de usuario
  if (copyout(myproc()->pagetable, rt, (char*)&rtime, sizeof(rtime)) < 0)
    800033ee:	ffffe097          	auipc	ra,0xffffe
    800033f2:	698080e7          	jalr	1688(ra) # 80001a86 <myproc>
    800033f6:	4691                	li	a3,4
    800033f8:	fc440613          	addi	a2,s0,-60
    800033fc:	fd043583          	ld	a1,-48(s0)
    80003400:	6928                	ld	a0,80(a0)
    80003402:	ffffe097          	auipc	ra,0xffffe
    80003406:	308080e7          	jalr	776(ra) # 8000170a <copyout>
    8000340a:	87aa                	mv	a5,a0
    return -1;
    8000340c:	557d                	li	a0,-1
  if (copyout(myproc()->pagetable, rt, (char*)&rtime, sizeof(rtime)) < 0)
    8000340e:	0207c363          	bltz	a5,80003434 <sys_waitx+0x96>

  // copiar wtime al espacio de usuario
  if (copyout(myproc()->pagetable, wt, (char*)&wtime, sizeof(wtime)) < 0)
    80003412:	ffffe097          	auipc	ra,0xffffe
    80003416:	674080e7          	jalr	1652(ra) # 80001a86 <myproc>
    8000341a:	4691                	li	a3,4
    8000341c:	fc040613          	addi	a2,s0,-64
    80003420:	fc843583          	ld	a1,-56(s0)
    80003424:	6928                	ld	a0,80(a0)
    80003426:	ffffe097          	auipc	ra,0xffffe
    8000342a:	2e4080e7          	jalr	740(ra) # 8000170a <copyout>
    8000342e:	00054863          	bltz	a0,8000343e <sys_waitx+0xa0>
    return -1;

  return pid;
    80003432:	8526                	mv	a0,s1
}
    80003434:	70e2                	ld	ra,56(sp)
    80003436:	7442                	ld	s0,48(sp)
    80003438:	74a2                	ld	s1,40(sp)
    8000343a:	6121                	addi	sp,sp,64
    8000343c:	8082                	ret
    return -1;
    8000343e:	557d                	li	a0,-1
    80003440:	bfd5                	j	80003434 <sys_waitx+0x96>

0000000080003442 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003442:	7179                	addi	sp,sp,-48
    80003444:	f406                	sd	ra,40(sp)
    80003446:	f022                	sd	s0,32(sp)
    80003448:	ec26                	sd	s1,24(sp)
    8000344a:	e84a                	sd	s2,16(sp)
    8000344c:	e44e                	sd	s3,8(sp)
    8000344e:	e052                	sd	s4,0(sp)
    80003450:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003452:	00005597          	auipc	a1,0x5
    80003456:	0c658593          	addi	a1,a1,198 # 80008518 <etext+0x518>
    8000345a:	00018517          	auipc	a0,0x18
    8000345e:	48e50513          	addi	a0,a0,1166 # 8001b8e8 <bcache>
    80003462:	ffffd097          	auipc	ra,0xffffd
    80003466:	758080e7          	jalr	1880(ra) # 80000bba <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000346a:	00020797          	auipc	a5,0x20
    8000346e:	47e78793          	addi	a5,a5,1150 # 800238e8 <bcache+0x8000>
    80003472:	00020717          	auipc	a4,0x20
    80003476:	6de70713          	addi	a4,a4,1758 # 80023b50 <bcache+0x8268>
    8000347a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000347e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003482:	00018497          	auipc	s1,0x18
    80003486:	47e48493          	addi	s1,s1,1150 # 8001b900 <bcache+0x18>
    b->next = bcache.head.next;
    8000348a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000348c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000348e:	00005a17          	auipc	s4,0x5
    80003492:	092a0a13          	addi	s4,s4,146 # 80008520 <etext+0x520>
    b->next = bcache.head.next;
    80003496:	2b893783          	ld	a5,696(s2)
    8000349a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000349c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800034a0:	85d2                	mv	a1,s4
    800034a2:	01048513          	addi	a0,s1,16
    800034a6:	00001097          	auipc	ra,0x1
    800034aa:	4c2080e7          	jalr	1218(ra) # 80004968 <initsleeplock>
    bcache.head.next->prev = b;
    800034ae:	2b893783          	ld	a5,696(s2)
    800034b2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800034b4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800034b8:	45848493          	addi	s1,s1,1112
    800034bc:	fd349de3          	bne	s1,s3,80003496 <binit+0x54>
  }
}
    800034c0:	70a2                	ld	ra,40(sp)
    800034c2:	7402                	ld	s0,32(sp)
    800034c4:	64e2                	ld	s1,24(sp)
    800034c6:	6942                	ld	s2,16(sp)
    800034c8:	69a2                	ld	s3,8(sp)
    800034ca:	6a02                	ld	s4,0(sp)
    800034cc:	6145                	addi	sp,sp,48
    800034ce:	8082                	ret

00000000800034d0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800034d0:	7179                	addi	sp,sp,-48
    800034d2:	f406                	sd	ra,40(sp)
    800034d4:	f022                	sd	s0,32(sp)
    800034d6:	ec26                	sd	s1,24(sp)
    800034d8:	e84a                	sd	s2,16(sp)
    800034da:	e44e                	sd	s3,8(sp)
    800034dc:	1800                	addi	s0,sp,48
    800034de:	892a                	mv	s2,a0
    800034e0:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800034e2:	00018517          	auipc	a0,0x18
    800034e6:	40650513          	addi	a0,a0,1030 # 8001b8e8 <bcache>
    800034ea:	ffffd097          	auipc	ra,0xffffd
    800034ee:	76a080e7          	jalr	1898(ra) # 80000c54 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800034f2:	00020497          	auipc	s1,0x20
    800034f6:	6ae4b483          	ld	s1,1710(s1) # 80023ba0 <bcache+0x82b8>
    800034fa:	00020797          	auipc	a5,0x20
    800034fe:	65678793          	addi	a5,a5,1622 # 80023b50 <bcache+0x8268>
    80003502:	02f48f63          	beq	s1,a5,80003540 <bread+0x70>
    80003506:	873e                	mv	a4,a5
    80003508:	a021                	j	80003510 <bread+0x40>
    8000350a:	68a4                	ld	s1,80(s1)
    8000350c:	02e48a63          	beq	s1,a4,80003540 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003510:	449c                	lw	a5,8(s1)
    80003512:	ff279ce3          	bne	a5,s2,8000350a <bread+0x3a>
    80003516:	44dc                	lw	a5,12(s1)
    80003518:	ff3799e3          	bne	a5,s3,8000350a <bread+0x3a>
      b->refcnt++;
    8000351c:	40bc                	lw	a5,64(s1)
    8000351e:	2785                	addiw	a5,a5,1
    80003520:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003522:	00018517          	auipc	a0,0x18
    80003526:	3c650513          	addi	a0,a0,966 # 8001b8e8 <bcache>
    8000352a:	ffffd097          	auipc	ra,0xffffd
    8000352e:	7da080e7          	jalr	2010(ra) # 80000d04 <release>
      acquiresleep(&b->lock);
    80003532:	01048513          	addi	a0,s1,16
    80003536:	00001097          	auipc	ra,0x1
    8000353a:	46c080e7          	jalr	1132(ra) # 800049a2 <acquiresleep>
      return b;
    8000353e:	a8b9                	j	8000359c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003540:	00020497          	auipc	s1,0x20
    80003544:	6584b483          	ld	s1,1624(s1) # 80023b98 <bcache+0x82b0>
    80003548:	00020797          	auipc	a5,0x20
    8000354c:	60878793          	addi	a5,a5,1544 # 80023b50 <bcache+0x8268>
    80003550:	00f48863          	beq	s1,a5,80003560 <bread+0x90>
    80003554:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003556:	40bc                	lw	a5,64(s1)
    80003558:	cf81                	beqz	a5,80003570 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000355a:	64a4                	ld	s1,72(s1)
    8000355c:	fee49de3          	bne	s1,a4,80003556 <bread+0x86>
  panic("bget: no buffers");
    80003560:	00005517          	auipc	a0,0x5
    80003564:	fc850513          	addi	a0,a0,-56 # 80008528 <etext+0x528>
    80003568:	ffffd097          	auipc	ra,0xffffd
    8000356c:	fee080e7          	jalr	-18(ra) # 80000556 <panic>
      b->dev = dev;
    80003570:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003574:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003578:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000357c:	4785                	li	a5,1
    8000357e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003580:	00018517          	auipc	a0,0x18
    80003584:	36850513          	addi	a0,a0,872 # 8001b8e8 <bcache>
    80003588:	ffffd097          	auipc	ra,0xffffd
    8000358c:	77c080e7          	jalr	1916(ra) # 80000d04 <release>
      acquiresleep(&b->lock);
    80003590:	01048513          	addi	a0,s1,16
    80003594:	00001097          	auipc	ra,0x1
    80003598:	40e080e7          	jalr	1038(ra) # 800049a2 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000359c:	409c                	lw	a5,0(s1)
    8000359e:	cb89                	beqz	a5,800035b0 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800035a0:	8526                	mv	a0,s1
    800035a2:	70a2                	ld	ra,40(sp)
    800035a4:	7402                	ld	s0,32(sp)
    800035a6:	64e2                	ld	s1,24(sp)
    800035a8:	6942                	ld	s2,16(sp)
    800035aa:	69a2                	ld	s3,8(sp)
    800035ac:	6145                	addi	sp,sp,48
    800035ae:	8082                	ret
    virtio_disk_rw(b, 0);
    800035b0:	4581                	li	a1,0
    800035b2:	8526                	mv	a0,s1
    800035b4:	00003097          	auipc	ra,0x3
    800035b8:	03a080e7          	jalr	58(ra) # 800065ee <virtio_disk_rw>
    b->valid = 1;
    800035bc:	4785                	li	a5,1
    800035be:	c09c                	sw	a5,0(s1)
  return b;
    800035c0:	b7c5                	j	800035a0 <bread+0xd0>

00000000800035c2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800035c2:	1101                	addi	sp,sp,-32
    800035c4:	ec06                	sd	ra,24(sp)
    800035c6:	e822                	sd	s0,16(sp)
    800035c8:	e426                	sd	s1,8(sp)
    800035ca:	1000                	addi	s0,sp,32
    800035cc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800035ce:	0541                	addi	a0,a0,16
    800035d0:	00001097          	auipc	ra,0x1
    800035d4:	46c080e7          	jalr	1132(ra) # 80004a3c <holdingsleep>
    800035d8:	cd01                	beqz	a0,800035f0 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800035da:	4585                	li	a1,1
    800035dc:	8526                	mv	a0,s1
    800035de:	00003097          	auipc	ra,0x3
    800035e2:	010080e7          	jalr	16(ra) # 800065ee <virtio_disk_rw>
}
    800035e6:	60e2                	ld	ra,24(sp)
    800035e8:	6442                	ld	s0,16(sp)
    800035ea:	64a2                	ld	s1,8(sp)
    800035ec:	6105                	addi	sp,sp,32
    800035ee:	8082                	ret
    panic("bwrite");
    800035f0:	00005517          	auipc	a0,0x5
    800035f4:	f5050513          	addi	a0,a0,-176 # 80008540 <etext+0x540>
    800035f8:	ffffd097          	auipc	ra,0xffffd
    800035fc:	f5e080e7          	jalr	-162(ra) # 80000556 <panic>

0000000080003600 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003600:	1101                	addi	sp,sp,-32
    80003602:	ec06                	sd	ra,24(sp)
    80003604:	e822                	sd	s0,16(sp)
    80003606:	e426                	sd	s1,8(sp)
    80003608:	e04a                	sd	s2,0(sp)
    8000360a:	1000                	addi	s0,sp,32
    8000360c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000360e:	01050913          	addi	s2,a0,16
    80003612:	854a                	mv	a0,s2
    80003614:	00001097          	auipc	ra,0x1
    80003618:	428080e7          	jalr	1064(ra) # 80004a3c <holdingsleep>
    8000361c:	c535                	beqz	a0,80003688 <brelse+0x88>
    panic("brelse");

  releasesleep(&b->lock);
    8000361e:	854a                	mv	a0,s2
    80003620:	00001097          	auipc	ra,0x1
    80003624:	3d8080e7          	jalr	984(ra) # 800049f8 <releasesleep>

  acquire(&bcache.lock);
    80003628:	00018517          	auipc	a0,0x18
    8000362c:	2c050513          	addi	a0,a0,704 # 8001b8e8 <bcache>
    80003630:	ffffd097          	auipc	ra,0xffffd
    80003634:	624080e7          	jalr	1572(ra) # 80000c54 <acquire>
  b->refcnt--;
    80003638:	40bc                	lw	a5,64(s1)
    8000363a:	37fd                	addiw	a5,a5,-1
    8000363c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000363e:	e79d                	bnez	a5,8000366c <brelse+0x6c>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003640:	68b8                	ld	a4,80(s1)
    80003642:	64bc                	ld	a5,72(s1)
    80003644:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003646:	68b8                	ld	a4,80(s1)
    80003648:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000364a:	00020797          	auipc	a5,0x20
    8000364e:	29e78793          	addi	a5,a5,670 # 800238e8 <bcache+0x8000>
    80003652:	2b87b703          	ld	a4,696(a5)
    80003656:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003658:	00020717          	auipc	a4,0x20
    8000365c:	4f870713          	addi	a4,a4,1272 # 80023b50 <bcache+0x8268>
    80003660:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003662:	2b87b703          	ld	a4,696(a5)
    80003666:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003668:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000366c:	00018517          	auipc	a0,0x18
    80003670:	27c50513          	addi	a0,a0,636 # 8001b8e8 <bcache>
    80003674:	ffffd097          	auipc	ra,0xffffd
    80003678:	690080e7          	jalr	1680(ra) # 80000d04 <release>
}
    8000367c:	60e2                	ld	ra,24(sp)
    8000367e:	6442                	ld	s0,16(sp)
    80003680:	64a2                	ld	s1,8(sp)
    80003682:	6902                	ld	s2,0(sp)
    80003684:	6105                	addi	sp,sp,32
    80003686:	8082                	ret
    panic("brelse");
    80003688:	00005517          	auipc	a0,0x5
    8000368c:	ec050513          	addi	a0,a0,-320 # 80008548 <etext+0x548>
    80003690:	ffffd097          	auipc	ra,0xffffd
    80003694:	ec6080e7          	jalr	-314(ra) # 80000556 <panic>

0000000080003698 <bpin>:

void
bpin(struct buf *b) {
    80003698:	1101                	addi	sp,sp,-32
    8000369a:	ec06                	sd	ra,24(sp)
    8000369c:	e822                	sd	s0,16(sp)
    8000369e:	e426                	sd	s1,8(sp)
    800036a0:	1000                	addi	s0,sp,32
    800036a2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800036a4:	00018517          	auipc	a0,0x18
    800036a8:	24450513          	addi	a0,a0,580 # 8001b8e8 <bcache>
    800036ac:	ffffd097          	auipc	ra,0xffffd
    800036b0:	5a8080e7          	jalr	1448(ra) # 80000c54 <acquire>
  b->refcnt++;
    800036b4:	40bc                	lw	a5,64(s1)
    800036b6:	2785                	addiw	a5,a5,1
    800036b8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800036ba:	00018517          	auipc	a0,0x18
    800036be:	22e50513          	addi	a0,a0,558 # 8001b8e8 <bcache>
    800036c2:	ffffd097          	auipc	ra,0xffffd
    800036c6:	642080e7          	jalr	1602(ra) # 80000d04 <release>
}
    800036ca:	60e2                	ld	ra,24(sp)
    800036cc:	6442                	ld	s0,16(sp)
    800036ce:	64a2                	ld	s1,8(sp)
    800036d0:	6105                	addi	sp,sp,32
    800036d2:	8082                	ret

00000000800036d4 <bunpin>:

void
bunpin(struct buf *b) {
    800036d4:	1101                	addi	sp,sp,-32
    800036d6:	ec06                	sd	ra,24(sp)
    800036d8:	e822                	sd	s0,16(sp)
    800036da:	e426                	sd	s1,8(sp)
    800036dc:	1000                	addi	s0,sp,32
    800036de:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800036e0:	00018517          	auipc	a0,0x18
    800036e4:	20850513          	addi	a0,a0,520 # 8001b8e8 <bcache>
    800036e8:	ffffd097          	auipc	ra,0xffffd
    800036ec:	56c080e7          	jalr	1388(ra) # 80000c54 <acquire>
  b->refcnt--;
    800036f0:	40bc                	lw	a5,64(s1)
    800036f2:	37fd                	addiw	a5,a5,-1
    800036f4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800036f6:	00018517          	auipc	a0,0x18
    800036fa:	1f250513          	addi	a0,a0,498 # 8001b8e8 <bcache>
    800036fe:	ffffd097          	auipc	ra,0xffffd
    80003702:	606080e7          	jalr	1542(ra) # 80000d04 <release>
}
    80003706:	60e2                	ld	ra,24(sp)
    80003708:	6442                	ld	s0,16(sp)
    8000370a:	64a2                	ld	s1,8(sp)
    8000370c:	6105                	addi	sp,sp,32
    8000370e:	8082                	ret

0000000080003710 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003710:	1101                	addi	sp,sp,-32
    80003712:	ec06                	sd	ra,24(sp)
    80003714:	e822                	sd	s0,16(sp)
    80003716:	e426                	sd	s1,8(sp)
    80003718:	e04a                	sd	s2,0(sp)
    8000371a:	1000                	addi	s0,sp,32
    8000371c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000371e:	00d5d79b          	srliw	a5,a1,0xd
    80003722:	00021597          	auipc	a1,0x21
    80003726:	8a25a583          	lw	a1,-1886(a1) # 80023fc4 <sb+0x1c>
    8000372a:	9dbd                	addw	a1,a1,a5
    8000372c:	00000097          	auipc	ra,0x0
    80003730:	da4080e7          	jalr	-604(ra) # 800034d0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003734:	0074f713          	andi	a4,s1,7
    80003738:	4785                	li	a5,1
    8000373a:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    8000373e:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80003740:	90d9                	srli	s1,s1,0x36
    80003742:	00950733          	add	a4,a0,s1
    80003746:	05874703          	lbu	a4,88(a4)
    8000374a:	00e7f6b3          	and	a3,a5,a4
    8000374e:	c69d                	beqz	a3,8000377c <bfree+0x6c>
    80003750:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003752:	94aa                	add	s1,s1,a0
    80003754:	fff7c793          	not	a5,a5
    80003758:	8f7d                	and	a4,a4,a5
    8000375a:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000375e:	00001097          	auipc	ra,0x1
    80003762:	124080e7          	jalr	292(ra) # 80004882 <log_write>
  brelse(bp);
    80003766:	854a                	mv	a0,s2
    80003768:	00000097          	auipc	ra,0x0
    8000376c:	e98080e7          	jalr	-360(ra) # 80003600 <brelse>
}
    80003770:	60e2                	ld	ra,24(sp)
    80003772:	6442                	ld	s0,16(sp)
    80003774:	64a2                	ld	s1,8(sp)
    80003776:	6902                	ld	s2,0(sp)
    80003778:	6105                	addi	sp,sp,32
    8000377a:	8082                	ret
    panic("freeing free block");
    8000377c:	00005517          	auipc	a0,0x5
    80003780:	dd450513          	addi	a0,a0,-556 # 80008550 <etext+0x550>
    80003784:	ffffd097          	auipc	ra,0xffffd
    80003788:	dd2080e7          	jalr	-558(ra) # 80000556 <panic>

000000008000378c <balloc>:
{
    8000378c:	715d                	addi	sp,sp,-80
    8000378e:	e486                	sd	ra,72(sp)
    80003790:	e0a2                	sd	s0,64(sp)
    80003792:	fc26                	sd	s1,56(sp)
    80003794:	f84a                	sd	s2,48(sp)
    80003796:	f44e                	sd	s3,40(sp)
    80003798:	f052                	sd	s4,32(sp)
    8000379a:	ec56                	sd	s5,24(sp)
    8000379c:	e85a                	sd	s6,16(sp)
    8000379e:	e45e                	sd	s7,8(sp)
    800037a0:	e062                	sd	s8,0(sp)
    800037a2:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    800037a4:	00021797          	auipc	a5,0x21
    800037a8:	8087a783          	lw	a5,-2040(a5) # 80023fac <sb+0x4>
    800037ac:	cfb5                	beqz	a5,80003828 <balloc+0x9c>
    800037ae:	8baa                	mv	s7,a0
    800037b0:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800037b2:	00020b17          	auipc	s6,0x20
    800037b6:	7f6b0b13          	addi	s6,s6,2038 # 80023fa8 <sb>
      m = 1 << (bi % 8);
    800037ba:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037bc:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800037be:	6c09                	lui	s8,0x2
    800037c0:	a821                	j	800037d8 <balloc+0x4c>
    brelse(bp);
    800037c2:	854a                	mv	a0,s2
    800037c4:	00000097          	auipc	ra,0x0
    800037c8:	e3c080e7          	jalr	-452(ra) # 80003600 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800037cc:	015c0abb          	addw	s5,s8,s5
    800037d0:	004b2783          	lw	a5,4(s6)
    800037d4:	04fafa63          	bgeu	s5,a5,80003828 <balloc+0x9c>
    bp = bread(dev, BBLOCK(b, sb));
    800037d8:	40dad59b          	sraiw	a1,s5,0xd
    800037dc:	01cb2783          	lw	a5,28(s6)
    800037e0:	9dbd                	addw	a1,a1,a5
    800037e2:	855e                	mv	a0,s7
    800037e4:	00000097          	auipc	ra,0x0
    800037e8:	cec080e7          	jalr	-788(ra) # 800034d0 <bread>
    800037ec:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037ee:	004b2503          	lw	a0,4(s6)
    800037f2:	84d6                	mv	s1,s5
    800037f4:	4701                	li	a4,0
    800037f6:	fca4f6e3          	bgeu	s1,a0,800037c2 <balloc+0x36>
      m = 1 << (bi % 8);
    800037fa:	00777693          	andi	a3,a4,7
    800037fe:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003802:	41f7579b          	sraiw	a5,a4,0x1f
    80003806:	01d7d79b          	srliw	a5,a5,0x1d
    8000380a:	9fb9                	addw	a5,a5,a4
    8000380c:	4037d79b          	sraiw	a5,a5,0x3
    80003810:	00f90633          	add	a2,s2,a5
    80003814:	05864603          	lbu	a2,88(a2)
    80003818:	00c6f5b3          	and	a1,a3,a2
    8000381c:	cd91                	beqz	a1,80003838 <balloc+0xac>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000381e:	2705                	addiw	a4,a4,1
    80003820:	2485                	addiw	s1,s1,1
    80003822:	fd471ae3          	bne	a4,s4,800037f6 <balloc+0x6a>
    80003826:	bf71                	j	800037c2 <balloc+0x36>
  panic("balloc: out of blocks");
    80003828:	00005517          	auipc	a0,0x5
    8000382c:	d4050513          	addi	a0,a0,-704 # 80008568 <etext+0x568>
    80003830:	ffffd097          	auipc	ra,0xffffd
    80003834:	d26080e7          	jalr	-730(ra) # 80000556 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003838:	97ca                	add	a5,a5,s2
    8000383a:	8e55                	or	a2,a2,a3
    8000383c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003840:	854a                	mv	a0,s2
    80003842:	00001097          	auipc	ra,0x1
    80003846:	040080e7          	jalr	64(ra) # 80004882 <log_write>
        brelse(bp);
    8000384a:	854a                	mv	a0,s2
    8000384c:	00000097          	auipc	ra,0x0
    80003850:	db4080e7          	jalr	-588(ra) # 80003600 <brelse>
  bp = bread(dev, bno);
    80003854:	85a6                	mv	a1,s1
    80003856:	855e                	mv	a0,s7
    80003858:	00000097          	auipc	ra,0x0
    8000385c:	c78080e7          	jalr	-904(ra) # 800034d0 <bread>
    80003860:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003862:	40000613          	li	a2,1024
    80003866:	4581                	li	a1,0
    80003868:	05850513          	addi	a0,a0,88
    8000386c:	ffffd097          	auipc	ra,0xffffd
    80003870:	4e0080e7          	jalr	1248(ra) # 80000d4c <memset>
  log_write(bp);
    80003874:	854a                	mv	a0,s2
    80003876:	00001097          	auipc	ra,0x1
    8000387a:	00c080e7          	jalr	12(ra) # 80004882 <log_write>
  brelse(bp);
    8000387e:	854a                	mv	a0,s2
    80003880:	00000097          	auipc	ra,0x0
    80003884:	d80080e7          	jalr	-640(ra) # 80003600 <brelse>
}
    80003888:	8526                	mv	a0,s1
    8000388a:	60a6                	ld	ra,72(sp)
    8000388c:	6406                	ld	s0,64(sp)
    8000388e:	74e2                	ld	s1,56(sp)
    80003890:	7942                	ld	s2,48(sp)
    80003892:	79a2                	ld	s3,40(sp)
    80003894:	7a02                	ld	s4,32(sp)
    80003896:	6ae2                	ld	s5,24(sp)
    80003898:	6b42                	ld	s6,16(sp)
    8000389a:	6ba2                	ld	s7,8(sp)
    8000389c:	6c02                	ld	s8,0(sp)
    8000389e:	6161                	addi	sp,sp,80
    800038a0:	8082                	ret

00000000800038a2 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800038a2:	7179                	addi	sp,sp,-48
    800038a4:	f406                	sd	ra,40(sp)
    800038a6:	f022                	sd	s0,32(sp)
    800038a8:	ec26                	sd	s1,24(sp)
    800038aa:	e84a                	sd	s2,16(sp)
    800038ac:	e44e                	sd	s3,8(sp)
    800038ae:	1800                	addi	s0,sp,48
    800038b0:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800038b2:	47ad                	li	a5,11
    800038b4:	04b7fd63          	bgeu	a5,a1,8000390e <bmap+0x6c>
    800038b8:	e052                	sd	s4,0(sp)
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800038ba:	ff45849b          	addiw	s1,a1,-12

  if(bn < NINDIRECT){
    800038be:	0ff00793          	li	a5,255
    800038c2:	0897ef63          	bltu	a5,s1,80003960 <bmap+0xbe>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800038c6:	08052583          	lw	a1,128(a0)
    800038ca:	c5a5                	beqz	a1,80003932 <bmap+0x90>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800038cc:	00092503          	lw	a0,0(s2)
    800038d0:	00000097          	auipc	ra,0x0
    800038d4:	c00080e7          	jalr	-1024(ra) # 800034d0 <bread>
    800038d8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800038da:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800038de:	02049713          	slli	a4,s1,0x20
    800038e2:	01e75593          	srli	a1,a4,0x1e
    800038e6:	00b784b3          	add	s1,a5,a1
    800038ea:	0004a983          	lw	s3,0(s1)
    800038ee:	04098b63          	beqz	s3,80003944 <bmap+0xa2>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800038f2:	8552                	mv	a0,s4
    800038f4:	00000097          	auipc	ra,0x0
    800038f8:	d0c080e7          	jalr	-756(ra) # 80003600 <brelse>
    return addr;
    800038fc:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800038fe:	854e                	mv	a0,s3
    80003900:	70a2                	ld	ra,40(sp)
    80003902:	7402                	ld	s0,32(sp)
    80003904:	64e2                	ld	s1,24(sp)
    80003906:	6942                	ld	s2,16(sp)
    80003908:	69a2                	ld	s3,8(sp)
    8000390a:	6145                	addi	sp,sp,48
    8000390c:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    8000390e:	02059793          	slli	a5,a1,0x20
    80003912:	01e7d593          	srli	a1,a5,0x1e
    80003916:	00b504b3          	add	s1,a0,a1
    8000391a:	0504a983          	lw	s3,80(s1)
    8000391e:	fe0990e3          	bnez	s3,800038fe <bmap+0x5c>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003922:	4108                	lw	a0,0(a0)
    80003924:	00000097          	auipc	ra,0x0
    80003928:	e68080e7          	jalr	-408(ra) # 8000378c <balloc>
    8000392c:	89aa                	mv	s3,a0
    8000392e:	c8a8                	sw	a0,80(s1)
    80003930:	b7f9                	j	800038fe <bmap+0x5c>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003932:	4108                	lw	a0,0(a0)
    80003934:	00000097          	auipc	ra,0x0
    80003938:	e58080e7          	jalr	-424(ra) # 8000378c <balloc>
    8000393c:	85aa                	mv	a1,a0
    8000393e:	08a92023          	sw	a0,128(s2)
    80003942:	b769                	j	800038cc <bmap+0x2a>
      a[bn] = addr = balloc(ip->dev);
    80003944:	00092503          	lw	a0,0(s2)
    80003948:	00000097          	auipc	ra,0x0
    8000394c:	e44080e7          	jalr	-444(ra) # 8000378c <balloc>
    80003950:	89aa                	mv	s3,a0
    80003952:	c088                	sw	a0,0(s1)
      log_write(bp);
    80003954:	8552                	mv	a0,s4
    80003956:	00001097          	auipc	ra,0x1
    8000395a:	f2c080e7          	jalr	-212(ra) # 80004882 <log_write>
    8000395e:	bf51                	j	800038f2 <bmap+0x50>
  panic("bmap: out of range");
    80003960:	00005517          	auipc	a0,0x5
    80003964:	c2050513          	addi	a0,a0,-992 # 80008580 <etext+0x580>
    80003968:	ffffd097          	auipc	ra,0xffffd
    8000396c:	bee080e7          	jalr	-1042(ra) # 80000556 <panic>

0000000080003970 <iget>:
{
    80003970:	7179                	addi	sp,sp,-48
    80003972:	f406                	sd	ra,40(sp)
    80003974:	f022                	sd	s0,32(sp)
    80003976:	ec26                	sd	s1,24(sp)
    80003978:	e84a                	sd	s2,16(sp)
    8000397a:	e44e                	sd	s3,8(sp)
    8000397c:	e052                	sd	s4,0(sp)
    8000397e:	1800                	addi	s0,sp,48
    80003980:	892a                	mv	s2,a0
    80003982:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003984:	00020517          	auipc	a0,0x20
    80003988:	64450513          	addi	a0,a0,1604 # 80023fc8 <itable>
    8000398c:	ffffd097          	auipc	ra,0xffffd
    80003990:	2c8080e7          	jalr	712(ra) # 80000c54 <acquire>
  empty = 0;
    80003994:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003996:	00020497          	auipc	s1,0x20
    8000399a:	64a48493          	addi	s1,s1,1610 # 80023fe0 <itable+0x18>
    8000399e:	00022697          	auipc	a3,0x22
    800039a2:	0d268693          	addi	a3,a3,210 # 80025a70 <log>
    800039a6:	a809                	j	800039b8 <iget+0x48>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800039a8:	e781                	bnez	a5,800039b0 <iget+0x40>
    800039aa:	00099363          	bnez	s3,800039b0 <iget+0x40>
      empty = ip;
    800039ae:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800039b0:	08848493          	addi	s1,s1,136
    800039b4:	02d48763          	beq	s1,a3,800039e2 <iget+0x72>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800039b8:	449c                	lw	a5,8(s1)
    800039ba:	fef057e3          	blez	a5,800039a8 <iget+0x38>
    800039be:	4098                	lw	a4,0(s1)
    800039c0:	ff2718e3          	bne	a4,s2,800039b0 <iget+0x40>
    800039c4:	40d8                	lw	a4,4(s1)
    800039c6:	ff4715e3          	bne	a4,s4,800039b0 <iget+0x40>
      ip->ref++;
    800039ca:	2785                	addiw	a5,a5,1
    800039cc:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800039ce:	00020517          	auipc	a0,0x20
    800039d2:	5fa50513          	addi	a0,a0,1530 # 80023fc8 <itable>
    800039d6:	ffffd097          	auipc	ra,0xffffd
    800039da:	32e080e7          	jalr	814(ra) # 80000d04 <release>
      return ip;
    800039de:	89a6                	mv	s3,s1
    800039e0:	a025                	j	80003a08 <iget+0x98>
  if(empty == 0)
    800039e2:	02098c63          	beqz	s3,80003a1a <iget+0xaa>
  ip->dev = dev;
    800039e6:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    800039ea:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    800039ee:	4785                	li	a5,1
    800039f0:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    800039f4:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    800039f8:	00020517          	auipc	a0,0x20
    800039fc:	5d050513          	addi	a0,a0,1488 # 80023fc8 <itable>
    80003a00:	ffffd097          	auipc	ra,0xffffd
    80003a04:	304080e7          	jalr	772(ra) # 80000d04 <release>
}
    80003a08:	854e                	mv	a0,s3
    80003a0a:	70a2                	ld	ra,40(sp)
    80003a0c:	7402                	ld	s0,32(sp)
    80003a0e:	64e2                	ld	s1,24(sp)
    80003a10:	6942                	ld	s2,16(sp)
    80003a12:	69a2                	ld	s3,8(sp)
    80003a14:	6a02                	ld	s4,0(sp)
    80003a16:	6145                	addi	sp,sp,48
    80003a18:	8082                	ret
    panic("iget: no inodes");
    80003a1a:	00005517          	auipc	a0,0x5
    80003a1e:	b7e50513          	addi	a0,a0,-1154 # 80008598 <etext+0x598>
    80003a22:	ffffd097          	auipc	ra,0xffffd
    80003a26:	b34080e7          	jalr	-1228(ra) # 80000556 <panic>

0000000080003a2a <fsinit>:
fsinit(int dev) {
    80003a2a:	1101                	addi	sp,sp,-32
    80003a2c:	ec06                	sd	ra,24(sp)
    80003a2e:	e822                	sd	s0,16(sp)
    80003a30:	e426                	sd	s1,8(sp)
    80003a32:	e04a                	sd	s2,0(sp)
    80003a34:	1000                	addi	s0,sp,32
    80003a36:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003a38:	4585                	li	a1,1
    80003a3a:	00000097          	auipc	ra,0x0
    80003a3e:	a96080e7          	jalr	-1386(ra) # 800034d0 <bread>
    80003a42:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003a44:	02000613          	li	a2,32
    80003a48:	05850593          	addi	a1,a0,88
    80003a4c:	00020517          	auipc	a0,0x20
    80003a50:	55c50513          	addi	a0,a0,1372 # 80023fa8 <sb>
    80003a54:	ffffd097          	auipc	ra,0xffffd
    80003a58:	358080e7          	jalr	856(ra) # 80000dac <memmove>
  brelse(bp);
    80003a5c:	8526                	mv	a0,s1
    80003a5e:	00000097          	auipc	ra,0x0
    80003a62:	ba2080e7          	jalr	-1118(ra) # 80003600 <brelse>
  if(sb.magic != FSMAGIC)
    80003a66:	00020717          	auipc	a4,0x20
    80003a6a:	54272703          	lw	a4,1346(a4) # 80023fa8 <sb>
    80003a6e:	102037b7          	lui	a5,0x10203
    80003a72:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003a76:	02f71163          	bne	a4,a5,80003a98 <fsinit+0x6e>
  initlog(dev, &sb);
    80003a7a:	00020597          	auipc	a1,0x20
    80003a7e:	52e58593          	addi	a1,a1,1326 # 80023fa8 <sb>
    80003a82:	854a                	mv	a0,s2
    80003a84:	00001097          	auipc	ra,0x1
    80003a88:	b78080e7          	jalr	-1160(ra) # 800045fc <initlog>
}
    80003a8c:	60e2                	ld	ra,24(sp)
    80003a8e:	6442                	ld	s0,16(sp)
    80003a90:	64a2                	ld	s1,8(sp)
    80003a92:	6902                	ld	s2,0(sp)
    80003a94:	6105                	addi	sp,sp,32
    80003a96:	8082                	ret
    panic("invalid file system");
    80003a98:	00005517          	auipc	a0,0x5
    80003a9c:	b1050513          	addi	a0,a0,-1264 # 800085a8 <etext+0x5a8>
    80003aa0:	ffffd097          	auipc	ra,0xffffd
    80003aa4:	ab6080e7          	jalr	-1354(ra) # 80000556 <panic>

0000000080003aa8 <iinit>:
{
    80003aa8:	7179                	addi	sp,sp,-48
    80003aaa:	f406                	sd	ra,40(sp)
    80003aac:	f022                	sd	s0,32(sp)
    80003aae:	ec26                	sd	s1,24(sp)
    80003ab0:	e84a                	sd	s2,16(sp)
    80003ab2:	e44e                	sd	s3,8(sp)
    80003ab4:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003ab6:	00005597          	auipc	a1,0x5
    80003aba:	b0a58593          	addi	a1,a1,-1270 # 800085c0 <etext+0x5c0>
    80003abe:	00020517          	auipc	a0,0x20
    80003ac2:	50a50513          	addi	a0,a0,1290 # 80023fc8 <itable>
    80003ac6:	ffffd097          	auipc	ra,0xffffd
    80003aca:	0f4080e7          	jalr	244(ra) # 80000bba <initlock>
  for(i = 0; i < NINODE; i++) {
    80003ace:	00020497          	auipc	s1,0x20
    80003ad2:	52248493          	addi	s1,s1,1314 # 80023ff0 <itable+0x28>
    80003ad6:	00022997          	auipc	s3,0x22
    80003ada:	faa98993          	addi	s3,s3,-86 # 80025a80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003ade:	00005917          	auipc	s2,0x5
    80003ae2:	aea90913          	addi	s2,s2,-1302 # 800085c8 <etext+0x5c8>
    80003ae6:	85ca                	mv	a1,s2
    80003ae8:	8526                	mv	a0,s1
    80003aea:	00001097          	auipc	ra,0x1
    80003aee:	e7e080e7          	jalr	-386(ra) # 80004968 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003af2:	08848493          	addi	s1,s1,136
    80003af6:	ff3498e3          	bne	s1,s3,80003ae6 <iinit+0x3e>
}
    80003afa:	70a2                	ld	ra,40(sp)
    80003afc:	7402                	ld	s0,32(sp)
    80003afe:	64e2                	ld	s1,24(sp)
    80003b00:	6942                	ld	s2,16(sp)
    80003b02:	69a2                	ld	s3,8(sp)
    80003b04:	6145                	addi	sp,sp,48
    80003b06:	8082                	ret

0000000080003b08 <ialloc>:
{
    80003b08:	7139                	addi	sp,sp,-64
    80003b0a:	fc06                	sd	ra,56(sp)
    80003b0c:	f822                	sd	s0,48(sp)
    80003b0e:	f426                	sd	s1,40(sp)
    80003b10:	f04a                	sd	s2,32(sp)
    80003b12:	ec4e                	sd	s3,24(sp)
    80003b14:	e852                	sd	s4,16(sp)
    80003b16:	e456                	sd	s5,8(sp)
    80003b18:	e05a                	sd	s6,0(sp)
    80003b1a:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b1c:	00020717          	auipc	a4,0x20
    80003b20:	49872703          	lw	a4,1176(a4) # 80023fb4 <sb+0xc>
    80003b24:	4785                	li	a5,1
    80003b26:	04e7f863          	bgeu	a5,a4,80003b76 <ialloc+0x6e>
    80003b2a:	8aaa                	mv	s5,a0
    80003b2c:	8b2e                	mv	s6,a1
    80003b2e:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003b30:	00020a17          	auipc	s4,0x20
    80003b34:	478a0a13          	addi	s4,s4,1144 # 80023fa8 <sb>
    80003b38:	00495593          	srli	a1,s2,0x4
    80003b3c:	018a2783          	lw	a5,24(s4)
    80003b40:	9dbd                	addw	a1,a1,a5
    80003b42:	8556                	mv	a0,s5
    80003b44:	00000097          	auipc	ra,0x0
    80003b48:	98c080e7          	jalr	-1652(ra) # 800034d0 <bread>
    80003b4c:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003b4e:	05850993          	addi	s3,a0,88
    80003b52:	00f97793          	andi	a5,s2,15
    80003b56:	079a                	slli	a5,a5,0x6
    80003b58:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003b5a:	00099783          	lh	a5,0(s3)
    80003b5e:	c785                	beqz	a5,80003b86 <ialloc+0x7e>
    brelse(bp);
    80003b60:	00000097          	auipc	ra,0x0
    80003b64:	aa0080e7          	jalr	-1376(ra) # 80003600 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b68:	0905                	addi	s2,s2,1
    80003b6a:	00ca2703          	lw	a4,12(s4)
    80003b6e:	0009079b          	sext.w	a5,s2
    80003b72:	fce7e3e3          	bltu	a5,a4,80003b38 <ialloc+0x30>
  panic("ialloc: no inodes");
    80003b76:	00005517          	auipc	a0,0x5
    80003b7a:	a5a50513          	addi	a0,a0,-1446 # 800085d0 <etext+0x5d0>
    80003b7e:	ffffd097          	auipc	ra,0xffffd
    80003b82:	9d8080e7          	jalr	-1576(ra) # 80000556 <panic>
      memset(dip, 0, sizeof(*dip));
    80003b86:	04000613          	li	a2,64
    80003b8a:	4581                	li	a1,0
    80003b8c:	854e                	mv	a0,s3
    80003b8e:	ffffd097          	auipc	ra,0xffffd
    80003b92:	1be080e7          	jalr	446(ra) # 80000d4c <memset>
      dip->type = type;
    80003b96:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003b9a:	8526                	mv	a0,s1
    80003b9c:	00001097          	auipc	ra,0x1
    80003ba0:	ce6080e7          	jalr	-794(ra) # 80004882 <log_write>
      brelse(bp);
    80003ba4:	8526                	mv	a0,s1
    80003ba6:	00000097          	auipc	ra,0x0
    80003baa:	a5a080e7          	jalr	-1446(ra) # 80003600 <brelse>
      return iget(dev, inum);
    80003bae:	0009059b          	sext.w	a1,s2
    80003bb2:	8556                	mv	a0,s5
    80003bb4:	00000097          	auipc	ra,0x0
    80003bb8:	dbc080e7          	jalr	-580(ra) # 80003970 <iget>
}
    80003bbc:	70e2                	ld	ra,56(sp)
    80003bbe:	7442                	ld	s0,48(sp)
    80003bc0:	74a2                	ld	s1,40(sp)
    80003bc2:	7902                	ld	s2,32(sp)
    80003bc4:	69e2                	ld	s3,24(sp)
    80003bc6:	6a42                	ld	s4,16(sp)
    80003bc8:	6aa2                	ld	s5,8(sp)
    80003bca:	6b02                	ld	s6,0(sp)
    80003bcc:	6121                	addi	sp,sp,64
    80003bce:	8082                	ret

0000000080003bd0 <iupdate>:
{
    80003bd0:	1101                	addi	sp,sp,-32
    80003bd2:	ec06                	sd	ra,24(sp)
    80003bd4:	e822                	sd	s0,16(sp)
    80003bd6:	e426                	sd	s1,8(sp)
    80003bd8:	e04a                	sd	s2,0(sp)
    80003bda:	1000                	addi	s0,sp,32
    80003bdc:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003bde:	415c                	lw	a5,4(a0)
    80003be0:	0047d79b          	srliw	a5,a5,0x4
    80003be4:	00020597          	auipc	a1,0x20
    80003be8:	3dc5a583          	lw	a1,988(a1) # 80023fc0 <sb+0x18>
    80003bec:	9dbd                	addw	a1,a1,a5
    80003bee:	4108                	lw	a0,0(a0)
    80003bf0:	00000097          	auipc	ra,0x0
    80003bf4:	8e0080e7          	jalr	-1824(ra) # 800034d0 <bread>
    80003bf8:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003bfa:	05850793          	addi	a5,a0,88
    80003bfe:	40d8                	lw	a4,4(s1)
    80003c00:	8b3d                	andi	a4,a4,15
    80003c02:	071a                	slli	a4,a4,0x6
    80003c04:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003c06:	04449703          	lh	a4,68(s1)
    80003c0a:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003c0e:	04649703          	lh	a4,70(s1)
    80003c12:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003c16:	04849703          	lh	a4,72(s1)
    80003c1a:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003c1e:	04a49703          	lh	a4,74(s1)
    80003c22:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003c26:	44f8                	lw	a4,76(s1)
    80003c28:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003c2a:	03400613          	li	a2,52
    80003c2e:	05048593          	addi	a1,s1,80
    80003c32:	00c78513          	addi	a0,a5,12
    80003c36:	ffffd097          	auipc	ra,0xffffd
    80003c3a:	176080e7          	jalr	374(ra) # 80000dac <memmove>
  log_write(bp);
    80003c3e:	854a                	mv	a0,s2
    80003c40:	00001097          	auipc	ra,0x1
    80003c44:	c42080e7          	jalr	-958(ra) # 80004882 <log_write>
  brelse(bp);
    80003c48:	854a                	mv	a0,s2
    80003c4a:	00000097          	auipc	ra,0x0
    80003c4e:	9b6080e7          	jalr	-1610(ra) # 80003600 <brelse>
}
    80003c52:	60e2                	ld	ra,24(sp)
    80003c54:	6442                	ld	s0,16(sp)
    80003c56:	64a2                	ld	s1,8(sp)
    80003c58:	6902                	ld	s2,0(sp)
    80003c5a:	6105                	addi	sp,sp,32
    80003c5c:	8082                	ret

0000000080003c5e <idup>:
{
    80003c5e:	1101                	addi	sp,sp,-32
    80003c60:	ec06                	sd	ra,24(sp)
    80003c62:	e822                	sd	s0,16(sp)
    80003c64:	e426                	sd	s1,8(sp)
    80003c66:	1000                	addi	s0,sp,32
    80003c68:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c6a:	00020517          	auipc	a0,0x20
    80003c6e:	35e50513          	addi	a0,a0,862 # 80023fc8 <itable>
    80003c72:	ffffd097          	auipc	ra,0xffffd
    80003c76:	fe2080e7          	jalr	-30(ra) # 80000c54 <acquire>
  ip->ref++;
    80003c7a:	449c                	lw	a5,8(s1)
    80003c7c:	2785                	addiw	a5,a5,1
    80003c7e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c80:	00020517          	auipc	a0,0x20
    80003c84:	34850513          	addi	a0,a0,840 # 80023fc8 <itable>
    80003c88:	ffffd097          	auipc	ra,0xffffd
    80003c8c:	07c080e7          	jalr	124(ra) # 80000d04 <release>
}
    80003c90:	8526                	mv	a0,s1
    80003c92:	60e2                	ld	ra,24(sp)
    80003c94:	6442                	ld	s0,16(sp)
    80003c96:	64a2                	ld	s1,8(sp)
    80003c98:	6105                	addi	sp,sp,32
    80003c9a:	8082                	ret

0000000080003c9c <ilock>:
{
    80003c9c:	1101                	addi	sp,sp,-32
    80003c9e:	ec06                	sd	ra,24(sp)
    80003ca0:	e822                	sd	s0,16(sp)
    80003ca2:	e426                	sd	s1,8(sp)
    80003ca4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003ca6:	c10d                	beqz	a0,80003cc8 <ilock+0x2c>
    80003ca8:	84aa                	mv	s1,a0
    80003caa:	451c                	lw	a5,8(a0)
    80003cac:	00f05e63          	blez	a5,80003cc8 <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003cb0:	0541                	addi	a0,a0,16
    80003cb2:	00001097          	auipc	ra,0x1
    80003cb6:	cf0080e7          	jalr	-784(ra) # 800049a2 <acquiresleep>
  if(ip->valid == 0){
    80003cba:	40bc                	lw	a5,64(s1)
    80003cbc:	cf99                	beqz	a5,80003cda <ilock+0x3e>
}
    80003cbe:	60e2                	ld	ra,24(sp)
    80003cc0:	6442                	ld	s0,16(sp)
    80003cc2:	64a2                	ld	s1,8(sp)
    80003cc4:	6105                	addi	sp,sp,32
    80003cc6:	8082                	ret
    80003cc8:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003cca:	00005517          	auipc	a0,0x5
    80003cce:	91e50513          	addi	a0,a0,-1762 # 800085e8 <etext+0x5e8>
    80003cd2:	ffffd097          	auipc	ra,0xffffd
    80003cd6:	884080e7          	jalr	-1916(ra) # 80000556 <panic>
    80003cda:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003cdc:	40dc                	lw	a5,4(s1)
    80003cde:	0047d79b          	srliw	a5,a5,0x4
    80003ce2:	00020597          	auipc	a1,0x20
    80003ce6:	2de5a583          	lw	a1,734(a1) # 80023fc0 <sb+0x18>
    80003cea:	9dbd                	addw	a1,a1,a5
    80003cec:	4088                	lw	a0,0(s1)
    80003cee:	fffff097          	auipc	ra,0xfffff
    80003cf2:	7e2080e7          	jalr	2018(ra) # 800034d0 <bread>
    80003cf6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003cf8:	05850593          	addi	a1,a0,88
    80003cfc:	40dc                	lw	a5,4(s1)
    80003cfe:	8bbd                	andi	a5,a5,15
    80003d00:	079a                	slli	a5,a5,0x6
    80003d02:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003d04:	00059783          	lh	a5,0(a1)
    80003d08:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003d0c:	00259783          	lh	a5,2(a1)
    80003d10:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003d14:	00459783          	lh	a5,4(a1)
    80003d18:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003d1c:	00659783          	lh	a5,6(a1)
    80003d20:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003d24:	459c                	lw	a5,8(a1)
    80003d26:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003d28:	03400613          	li	a2,52
    80003d2c:	05b1                	addi	a1,a1,12
    80003d2e:	05048513          	addi	a0,s1,80
    80003d32:	ffffd097          	auipc	ra,0xffffd
    80003d36:	07a080e7          	jalr	122(ra) # 80000dac <memmove>
    brelse(bp);
    80003d3a:	854a                	mv	a0,s2
    80003d3c:	00000097          	auipc	ra,0x0
    80003d40:	8c4080e7          	jalr	-1852(ra) # 80003600 <brelse>
    ip->valid = 1;
    80003d44:	4785                	li	a5,1
    80003d46:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003d48:	04449783          	lh	a5,68(s1)
    80003d4c:	c399                	beqz	a5,80003d52 <ilock+0xb6>
    80003d4e:	6902                	ld	s2,0(sp)
    80003d50:	b7bd                	j	80003cbe <ilock+0x22>
      panic("ilock: no type");
    80003d52:	00005517          	auipc	a0,0x5
    80003d56:	89e50513          	addi	a0,a0,-1890 # 800085f0 <etext+0x5f0>
    80003d5a:	ffffc097          	auipc	ra,0xffffc
    80003d5e:	7fc080e7          	jalr	2044(ra) # 80000556 <panic>

0000000080003d62 <iunlock>:
{
    80003d62:	1101                	addi	sp,sp,-32
    80003d64:	ec06                	sd	ra,24(sp)
    80003d66:	e822                	sd	s0,16(sp)
    80003d68:	e426                	sd	s1,8(sp)
    80003d6a:	e04a                	sd	s2,0(sp)
    80003d6c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003d6e:	c905                	beqz	a0,80003d9e <iunlock+0x3c>
    80003d70:	84aa                	mv	s1,a0
    80003d72:	01050913          	addi	s2,a0,16
    80003d76:	854a                	mv	a0,s2
    80003d78:	00001097          	auipc	ra,0x1
    80003d7c:	cc4080e7          	jalr	-828(ra) # 80004a3c <holdingsleep>
    80003d80:	cd19                	beqz	a0,80003d9e <iunlock+0x3c>
    80003d82:	449c                	lw	a5,8(s1)
    80003d84:	00f05d63          	blez	a5,80003d9e <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003d88:	854a                	mv	a0,s2
    80003d8a:	00001097          	auipc	ra,0x1
    80003d8e:	c6e080e7          	jalr	-914(ra) # 800049f8 <releasesleep>
}
    80003d92:	60e2                	ld	ra,24(sp)
    80003d94:	6442                	ld	s0,16(sp)
    80003d96:	64a2                	ld	s1,8(sp)
    80003d98:	6902                	ld	s2,0(sp)
    80003d9a:	6105                	addi	sp,sp,32
    80003d9c:	8082                	ret
    panic("iunlock");
    80003d9e:	00005517          	auipc	a0,0x5
    80003da2:	86250513          	addi	a0,a0,-1950 # 80008600 <etext+0x600>
    80003da6:	ffffc097          	auipc	ra,0xffffc
    80003daa:	7b0080e7          	jalr	1968(ra) # 80000556 <panic>

0000000080003dae <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003dae:	7179                	addi	sp,sp,-48
    80003db0:	f406                	sd	ra,40(sp)
    80003db2:	f022                	sd	s0,32(sp)
    80003db4:	ec26                	sd	s1,24(sp)
    80003db6:	e84a                	sd	s2,16(sp)
    80003db8:	e44e                	sd	s3,8(sp)
    80003dba:	1800                	addi	s0,sp,48
    80003dbc:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003dbe:	05050493          	addi	s1,a0,80
    80003dc2:	08050913          	addi	s2,a0,128
    80003dc6:	a021                	j	80003dce <itrunc+0x20>
    80003dc8:	0491                	addi	s1,s1,4
    80003dca:	01248d63          	beq	s1,s2,80003de4 <itrunc+0x36>
    if(ip->addrs[i]){
    80003dce:	408c                	lw	a1,0(s1)
    80003dd0:	dde5                	beqz	a1,80003dc8 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003dd2:	0009a503          	lw	a0,0(s3)
    80003dd6:	00000097          	auipc	ra,0x0
    80003dda:	93a080e7          	jalr	-1734(ra) # 80003710 <bfree>
      ip->addrs[i] = 0;
    80003dde:	0004a023          	sw	zero,0(s1)
    80003de2:	b7dd                	j	80003dc8 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003de4:	0809a583          	lw	a1,128(s3)
    80003de8:	ed99                	bnez	a1,80003e06 <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003dea:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003dee:	854e                	mv	a0,s3
    80003df0:	00000097          	auipc	ra,0x0
    80003df4:	de0080e7          	jalr	-544(ra) # 80003bd0 <iupdate>
}
    80003df8:	70a2                	ld	ra,40(sp)
    80003dfa:	7402                	ld	s0,32(sp)
    80003dfc:	64e2                	ld	s1,24(sp)
    80003dfe:	6942                	ld	s2,16(sp)
    80003e00:	69a2                	ld	s3,8(sp)
    80003e02:	6145                	addi	sp,sp,48
    80003e04:	8082                	ret
    80003e06:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003e08:	0009a503          	lw	a0,0(s3)
    80003e0c:	fffff097          	auipc	ra,0xfffff
    80003e10:	6c4080e7          	jalr	1732(ra) # 800034d0 <bread>
    80003e14:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003e16:	05850493          	addi	s1,a0,88
    80003e1a:	45850913          	addi	s2,a0,1112
    80003e1e:	a021                	j	80003e26 <itrunc+0x78>
    80003e20:	0491                	addi	s1,s1,4
    80003e22:	01248b63          	beq	s1,s2,80003e38 <itrunc+0x8a>
      if(a[j])
    80003e26:	408c                	lw	a1,0(s1)
    80003e28:	dde5                	beqz	a1,80003e20 <itrunc+0x72>
        bfree(ip->dev, a[j]);
    80003e2a:	0009a503          	lw	a0,0(s3)
    80003e2e:	00000097          	auipc	ra,0x0
    80003e32:	8e2080e7          	jalr	-1822(ra) # 80003710 <bfree>
    80003e36:	b7ed                	j	80003e20 <itrunc+0x72>
    brelse(bp);
    80003e38:	8552                	mv	a0,s4
    80003e3a:	fffff097          	auipc	ra,0xfffff
    80003e3e:	7c6080e7          	jalr	1990(ra) # 80003600 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003e42:	0809a583          	lw	a1,128(s3)
    80003e46:	0009a503          	lw	a0,0(s3)
    80003e4a:	00000097          	auipc	ra,0x0
    80003e4e:	8c6080e7          	jalr	-1850(ra) # 80003710 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003e52:	0809a023          	sw	zero,128(s3)
    80003e56:	6a02                	ld	s4,0(sp)
    80003e58:	bf49                	j	80003dea <itrunc+0x3c>

0000000080003e5a <iput>:
{
    80003e5a:	1101                	addi	sp,sp,-32
    80003e5c:	ec06                	sd	ra,24(sp)
    80003e5e:	e822                	sd	s0,16(sp)
    80003e60:	e426                	sd	s1,8(sp)
    80003e62:	1000                	addi	s0,sp,32
    80003e64:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e66:	00020517          	auipc	a0,0x20
    80003e6a:	16250513          	addi	a0,a0,354 # 80023fc8 <itable>
    80003e6e:	ffffd097          	auipc	ra,0xffffd
    80003e72:	de6080e7          	jalr	-538(ra) # 80000c54 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e76:	4498                	lw	a4,8(s1)
    80003e78:	4785                	li	a5,1
    80003e7a:	02f70263          	beq	a4,a5,80003e9e <iput+0x44>
  ip->ref--;
    80003e7e:	449c                	lw	a5,8(s1)
    80003e80:	37fd                	addiw	a5,a5,-1
    80003e82:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e84:	00020517          	auipc	a0,0x20
    80003e88:	14450513          	addi	a0,a0,324 # 80023fc8 <itable>
    80003e8c:	ffffd097          	auipc	ra,0xffffd
    80003e90:	e78080e7          	jalr	-392(ra) # 80000d04 <release>
}
    80003e94:	60e2                	ld	ra,24(sp)
    80003e96:	6442                	ld	s0,16(sp)
    80003e98:	64a2                	ld	s1,8(sp)
    80003e9a:	6105                	addi	sp,sp,32
    80003e9c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e9e:	40bc                	lw	a5,64(s1)
    80003ea0:	dff9                	beqz	a5,80003e7e <iput+0x24>
    80003ea2:	04a49783          	lh	a5,74(s1)
    80003ea6:	ffe1                	bnez	a5,80003e7e <iput+0x24>
    80003ea8:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003eaa:	01048793          	addi	a5,s1,16
    80003eae:	893e                	mv	s2,a5
    80003eb0:	853e                	mv	a0,a5
    80003eb2:	00001097          	auipc	ra,0x1
    80003eb6:	af0080e7          	jalr	-1296(ra) # 800049a2 <acquiresleep>
    release(&itable.lock);
    80003eba:	00020517          	auipc	a0,0x20
    80003ebe:	10e50513          	addi	a0,a0,270 # 80023fc8 <itable>
    80003ec2:	ffffd097          	auipc	ra,0xffffd
    80003ec6:	e42080e7          	jalr	-446(ra) # 80000d04 <release>
    itrunc(ip);
    80003eca:	8526                	mv	a0,s1
    80003ecc:	00000097          	auipc	ra,0x0
    80003ed0:	ee2080e7          	jalr	-286(ra) # 80003dae <itrunc>
    ip->type = 0;
    80003ed4:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003ed8:	8526                	mv	a0,s1
    80003eda:	00000097          	auipc	ra,0x0
    80003ede:	cf6080e7          	jalr	-778(ra) # 80003bd0 <iupdate>
    ip->valid = 0;
    80003ee2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003ee6:	854a                	mv	a0,s2
    80003ee8:	00001097          	auipc	ra,0x1
    80003eec:	b10080e7          	jalr	-1264(ra) # 800049f8 <releasesleep>
    acquire(&itable.lock);
    80003ef0:	00020517          	auipc	a0,0x20
    80003ef4:	0d850513          	addi	a0,a0,216 # 80023fc8 <itable>
    80003ef8:	ffffd097          	auipc	ra,0xffffd
    80003efc:	d5c080e7          	jalr	-676(ra) # 80000c54 <acquire>
    80003f00:	6902                	ld	s2,0(sp)
    80003f02:	bfb5                	j	80003e7e <iput+0x24>

0000000080003f04 <iunlockput>:
{
    80003f04:	1101                	addi	sp,sp,-32
    80003f06:	ec06                	sd	ra,24(sp)
    80003f08:	e822                	sd	s0,16(sp)
    80003f0a:	e426                	sd	s1,8(sp)
    80003f0c:	1000                	addi	s0,sp,32
    80003f0e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003f10:	00000097          	auipc	ra,0x0
    80003f14:	e52080e7          	jalr	-430(ra) # 80003d62 <iunlock>
  iput(ip);
    80003f18:	8526                	mv	a0,s1
    80003f1a:	00000097          	auipc	ra,0x0
    80003f1e:	f40080e7          	jalr	-192(ra) # 80003e5a <iput>
}
    80003f22:	60e2                	ld	ra,24(sp)
    80003f24:	6442                	ld	s0,16(sp)
    80003f26:	64a2                	ld	s1,8(sp)
    80003f28:	6105                	addi	sp,sp,32
    80003f2a:	8082                	ret

0000000080003f2c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003f2c:	1141                	addi	sp,sp,-16
    80003f2e:	e406                	sd	ra,8(sp)
    80003f30:	e022                	sd	s0,0(sp)
    80003f32:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003f34:	411c                	lw	a5,0(a0)
    80003f36:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003f38:	415c                	lw	a5,4(a0)
    80003f3a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003f3c:	04451783          	lh	a5,68(a0)
    80003f40:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003f44:	04a51783          	lh	a5,74(a0)
    80003f48:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003f4c:	04c56783          	lwu	a5,76(a0)
    80003f50:	e99c                	sd	a5,16(a1)
}
    80003f52:	60a2                	ld	ra,8(sp)
    80003f54:	6402                	ld	s0,0(sp)
    80003f56:	0141                	addi	sp,sp,16
    80003f58:	8082                	ret

0000000080003f5a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f5a:	457c                	lw	a5,76(a0)
    80003f5c:	0ed7ea63          	bltu	a5,a3,80004050 <readi+0xf6>
{
    80003f60:	7159                	addi	sp,sp,-112
    80003f62:	f486                	sd	ra,104(sp)
    80003f64:	f0a2                	sd	s0,96(sp)
    80003f66:	eca6                	sd	s1,88(sp)
    80003f68:	fc56                	sd	s5,56(sp)
    80003f6a:	f85a                	sd	s6,48(sp)
    80003f6c:	f45e                	sd	s7,40(sp)
    80003f6e:	ec66                	sd	s9,24(sp)
    80003f70:	1880                	addi	s0,sp,112
    80003f72:	8baa                	mv	s7,a0
    80003f74:	8cae                	mv	s9,a1
    80003f76:	8ab2                	mv	s5,a2
    80003f78:	84b6                	mv	s1,a3
    80003f7a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003f7c:	9f35                	addw	a4,a4,a3
    return 0;
    80003f7e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003f80:	0ad76763          	bltu	a4,a3,8000402e <readi+0xd4>
    80003f84:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003f86:	00e7f463          	bgeu	a5,a4,80003f8e <readi+0x34>
    n = ip->size - off;
    80003f8a:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f8e:	0a0b0f63          	beqz	s6,8000404c <readi+0xf2>
    80003f92:	e8ca                	sd	s2,80(sp)
    80003f94:	e0d2                	sd	s4,64(sp)
    80003f96:	f062                	sd	s8,32(sp)
    80003f98:	e86a                	sd	s10,16(sp)
    80003f9a:	e46e                	sd	s11,8(sp)
    80003f9c:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f9e:	40000d93          	li	s11,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003fa2:	5d7d                	li	s10,-1
    80003fa4:	a82d                	j	80003fde <readi+0x84>
    80003fa6:	020a1c13          	slli	s8,s4,0x20
    80003faa:	020c5c13          	srli	s8,s8,0x20
    80003fae:	05890613          	addi	a2,s2,88
    80003fb2:	86e2                	mv	a3,s8
    80003fb4:	963e                	add	a2,a2,a5
    80003fb6:	85d6                	mv	a1,s5
    80003fb8:	8566                	mv	a0,s9
    80003fba:	ffffe097          	auipc	ra,0xffffe
    80003fbe:	6b0080e7          	jalr	1712(ra) # 8000266a <either_copyout>
    80003fc2:	05a50963          	beq	a0,s10,80004014 <readi+0xba>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003fc6:	854a                	mv	a0,s2
    80003fc8:	fffff097          	auipc	ra,0xfffff
    80003fcc:	638080e7          	jalr	1592(ra) # 80003600 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fd0:	013a09bb          	addw	s3,s4,s3
    80003fd4:	009a04bb          	addw	s1,s4,s1
    80003fd8:	9ae2                	add	s5,s5,s8
    80003fda:	0769f363          	bgeu	s3,s6,80004040 <readi+0xe6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003fde:	000ba903          	lw	s2,0(s7)
    80003fe2:	00a4d59b          	srliw	a1,s1,0xa
    80003fe6:	855e                	mv	a0,s7
    80003fe8:	00000097          	auipc	ra,0x0
    80003fec:	8ba080e7          	jalr	-1862(ra) # 800038a2 <bmap>
    80003ff0:	85aa                	mv	a1,a0
    80003ff2:	854a                	mv	a0,s2
    80003ff4:	fffff097          	auipc	ra,0xfffff
    80003ff8:	4dc080e7          	jalr	1244(ra) # 800034d0 <bread>
    80003ffc:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ffe:	3ff4f793          	andi	a5,s1,1023
    80004002:	40fd873b          	subw	a4,s11,a5
    80004006:	413b06bb          	subw	a3,s6,s3
    8000400a:	8a3a                	mv	s4,a4
    8000400c:	f8e6fde3          	bgeu	a3,a4,80003fa6 <readi+0x4c>
    80004010:	8a36                	mv	s4,a3
    80004012:	bf51                	j	80003fa6 <readi+0x4c>
      brelse(bp);
    80004014:	854a                	mv	a0,s2
    80004016:	fffff097          	auipc	ra,0xfffff
    8000401a:	5ea080e7          	jalr	1514(ra) # 80003600 <brelse>
      tot = -1;
    8000401e:	59fd                	li	s3,-1
      break;
    80004020:	6946                	ld	s2,80(sp)
    80004022:	6a06                	ld	s4,64(sp)
    80004024:	7c02                	ld	s8,32(sp)
    80004026:	6d42                	ld	s10,16(sp)
    80004028:	6da2                	ld	s11,8(sp)
  }
  return tot;
    8000402a:	854e                	mv	a0,s3
    8000402c:	69a6                	ld	s3,72(sp)
}
    8000402e:	70a6                	ld	ra,104(sp)
    80004030:	7406                	ld	s0,96(sp)
    80004032:	64e6                	ld	s1,88(sp)
    80004034:	7ae2                	ld	s5,56(sp)
    80004036:	7b42                	ld	s6,48(sp)
    80004038:	7ba2                	ld	s7,40(sp)
    8000403a:	6ce2                	ld	s9,24(sp)
    8000403c:	6165                	addi	sp,sp,112
    8000403e:	8082                	ret
    80004040:	6946                	ld	s2,80(sp)
    80004042:	6a06                	ld	s4,64(sp)
    80004044:	7c02                	ld	s8,32(sp)
    80004046:	6d42                	ld	s10,16(sp)
    80004048:	6da2                	ld	s11,8(sp)
    8000404a:	b7c5                	j	8000402a <readi+0xd0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000404c:	89da                	mv	s3,s6
    8000404e:	bff1                	j	8000402a <readi+0xd0>
    return 0;
    80004050:	4501                	li	a0,0
}
    80004052:	8082                	ret

0000000080004054 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004054:	457c                	lw	a5,76(a0)
    80004056:	10d7e963          	bltu	a5,a3,80004168 <writei+0x114>
{
    8000405a:	7159                	addi	sp,sp,-112
    8000405c:	f486                	sd	ra,104(sp)
    8000405e:	f0a2                	sd	s0,96(sp)
    80004060:	e8ca                	sd	s2,80(sp)
    80004062:	fc56                	sd	s5,56(sp)
    80004064:	f45e                	sd	s7,40(sp)
    80004066:	f062                	sd	s8,32(sp)
    80004068:	ec66                	sd	s9,24(sp)
    8000406a:	1880                	addi	s0,sp,112
    8000406c:	8baa                	mv	s7,a0
    8000406e:	8cae                	mv	s9,a1
    80004070:	8ab2                	mv	s5,a2
    80004072:	8936                	mv	s2,a3
    80004074:	8c3a                	mv	s8,a4
  if(off > ip->size || off + n < off)
    80004076:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000407a:	00043737          	lui	a4,0x43
    8000407e:	0ef76763          	bltu	a4,a5,8000416c <writei+0x118>
    80004082:	0ed7e563          	bltu	a5,a3,8000416c <writei+0x118>
    80004086:	e0d2                	sd	s4,64(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004088:	0c0c0863          	beqz	s8,80004158 <writei+0x104>
    8000408c:	eca6                	sd	s1,88(sp)
    8000408e:	e4ce                	sd	s3,72(sp)
    80004090:	f85a                	sd	s6,48(sp)
    80004092:	e86a                	sd	s10,16(sp)
    80004094:	e46e                	sd	s11,8(sp)
    80004096:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004098:	40000d93          	li	s11,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000409c:	5d7d                	li	s10,-1
    8000409e:	a091                	j	800040e2 <writei+0x8e>
    800040a0:	02099b13          	slli	s6,s3,0x20
    800040a4:	020b5b13          	srli	s6,s6,0x20
    800040a8:	05848513          	addi	a0,s1,88
    800040ac:	86da                	mv	a3,s6
    800040ae:	8656                	mv	a2,s5
    800040b0:	85e6                	mv	a1,s9
    800040b2:	953e                	add	a0,a0,a5
    800040b4:	ffffe097          	auipc	ra,0xffffe
    800040b8:	60c080e7          	jalr	1548(ra) # 800026c0 <either_copyin>
    800040bc:	05a50e63          	beq	a0,s10,80004118 <writei+0xc4>
      brelse(bp);
      break;
    }
    log_write(bp);
    800040c0:	8526                	mv	a0,s1
    800040c2:	00000097          	auipc	ra,0x0
    800040c6:	7c0080e7          	jalr	1984(ra) # 80004882 <log_write>
    brelse(bp);
    800040ca:	8526                	mv	a0,s1
    800040cc:	fffff097          	auipc	ra,0xfffff
    800040d0:	534080e7          	jalr	1332(ra) # 80003600 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040d4:	01498a3b          	addw	s4,s3,s4
    800040d8:	0129893b          	addw	s2,s3,s2
    800040dc:	9ada                	add	s5,s5,s6
    800040de:	058a7263          	bgeu	s4,s8,80004122 <writei+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800040e2:	000ba483          	lw	s1,0(s7)
    800040e6:	00a9559b          	srliw	a1,s2,0xa
    800040ea:	855e                	mv	a0,s7
    800040ec:	fffff097          	auipc	ra,0xfffff
    800040f0:	7b6080e7          	jalr	1974(ra) # 800038a2 <bmap>
    800040f4:	85aa                	mv	a1,a0
    800040f6:	8526                	mv	a0,s1
    800040f8:	fffff097          	auipc	ra,0xfffff
    800040fc:	3d8080e7          	jalr	984(ra) # 800034d0 <bread>
    80004100:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004102:	3ff97793          	andi	a5,s2,1023
    80004106:	40fd873b          	subw	a4,s11,a5
    8000410a:	414c06bb          	subw	a3,s8,s4
    8000410e:	89ba                	mv	s3,a4
    80004110:	f8e6f8e3          	bgeu	a3,a4,800040a0 <writei+0x4c>
    80004114:	89b6                	mv	s3,a3
    80004116:	b769                	j	800040a0 <writei+0x4c>
      brelse(bp);
    80004118:	8526                	mv	a0,s1
    8000411a:	fffff097          	auipc	ra,0xfffff
    8000411e:	4e6080e7          	jalr	1254(ra) # 80003600 <brelse>
  }

  if(off > ip->size)
    80004122:	04cba783          	lw	a5,76(s7)
    80004126:	0327fb63          	bgeu	a5,s2,8000415c <writei+0x108>
    ip->size = off;
    8000412a:	052ba623          	sw	s2,76(s7)
    8000412e:	64e6                	ld	s1,88(sp)
    80004130:	69a6                	ld	s3,72(sp)
    80004132:	7b42                	ld	s6,48(sp)
    80004134:	6d42                	ld	s10,16(sp)
    80004136:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004138:	855e                	mv	a0,s7
    8000413a:	00000097          	auipc	ra,0x0
    8000413e:	a96080e7          	jalr	-1386(ra) # 80003bd0 <iupdate>

  return tot;
    80004142:	8552                	mv	a0,s4
    80004144:	6a06                	ld	s4,64(sp)
}
    80004146:	70a6                	ld	ra,104(sp)
    80004148:	7406                	ld	s0,96(sp)
    8000414a:	6946                	ld	s2,80(sp)
    8000414c:	7ae2                	ld	s5,56(sp)
    8000414e:	7ba2                	ld	s7,40(sp)
    80004150:	7c02                	ld	s8,32(sp)
    80004152:	6ce2                	ld	s9,24(sp)
    80004154:	6165                	addi	sp,sp,112
    80004156:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004158:	8a62                	mv	s4,s8
    8000415a:	bff9                	j	80004138 <writei+0xe4>
    8000415c:	64e6                	ld	s1,88(sp)
    8000415e:	69a6                	ld	s3,72(sp)
    80004160:	7b42                	ld	s6,48(sp)
    80004162:	6d42                	ld	s10,16(sp)
    80004164:	6da2                	ld	s11,8(sp)
    80004166:	bfc9                	j	80004138 <writei+0xe4>
    return -1;
    80004168:	557d                	li	a0,-1
}
    8000416a:	8082                	ret
    return -1;
    8000416c:	557d                	li	a0,-1
    8000416e:	bfe1                	j	80004146 <writei+0xf2>

0000000080004170 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004170:	1141                	addi	sp,sp,-16
    80004172:	e406                	sd	ra,8(sp)
    80004174:	e022                	sd	s0,0(sp)
    80004176:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004178:	4639                	li	a2,14
    8000417a:	ffffd097          	auipc	ra,0xffffd
    8000417e:	caa080e7          	jalr	-854(ra) # 80000e24 <strncmp>
}
    80004182:	60a2                	ld	ra,8(sp)
    80004184:	6402                	ld	s0,0(sp)
    80004186:	0141                	addi	sp,sp,16
    80004188:	8082                	ret

000000008000418a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000418a:	711d                	addi	sp,sp,-96
    8000418c:	ec86                	sd	ra,88(sp)
    8000418e:	e8a2                	sd	s0,80(sp)
    80004190:	e4a6                	sd	s1,72(sp)
    80004192:	e0ca                	sd	s2,64(sp)
    80004194:	fc4e                	sd	s3,56(sp)
    80004196:	f852                	sd	s4,48(sp)
    80004198:	f456                	sd	s5,40(sp)
    8000419a:	f05a                	sd	s6,32(sp)
    8000419c:	ec5e                	sd	s7,24(sp)
    8000419e:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800041a0:	04451703          	lh	a4,68(a0)
    800041a4:	4785                	li	a5,1
    800041a6:	00f71f63          	bne	a4,a5,800041c4 <dirlookup+0x3a>
    800041aa:	892a                	mv	s2,a0
    800041ac:	8aae                	mv	s5,a1
    800041ae:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800041b0:	457c                	lw	a5,76(a0)
    800041b2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041b4:	fa040a13          	addi	s4,s0,-96
    800041b8:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    800041ba:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800041be:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041c0:	e79d                	bnez	a5,800041ee <dirlookup+0x64>
    800041c2:	a88d                	j	80004234 <dirlookup+0xaa>
    panic("dirlookup not DIR");
    800041c4:	00004517          	auipc	a0,0x4
    800041c8:	44450513          	addi	a0,a0,1092 # 80008608 <etext+0x608>
    800041cc:	ffffc097          	auipc	ra,0xffffc
    800041d0:	38a080e7          	jalr	906(ra) # 80000556 <panic>
      panic("dirlookup read");
    800041d4:	00004517          	auipc	a0,0x4
    800041d8:	44c50513          	addi	a0,a0,1100 # 80008620 <etext+0x620>
    800041dc:	ffffc097          	auipc	ra,0xffffc
    800041e0:	37a080e7          	jalr	890(ra) # 80000556 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041e4:	24c1                	addiw	s1,s1,16
    800041e6:	04c92783          	lw	a5,76(s2)
    800041ea:	04f4f463          	bgeu	s1,a5,80004232 <dirlookup+0xa8>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041ee:	874e                	mv	a4,s3
    800041f0:	86a6                	mv	a3,s1
    800041f2:	8652                	mv	a2,s4
    800041f4:	4581                	li	a1,0
    800041f6:	854a                	mv	a0,s2
    800041f8:	00000097          	auipc	ra,0x0
    800041fc:	d62080e7          	jalr	-670(ra) # 80003f5a <readi>
    80004200:	fd351ae3          	bne	a0,s3,800041d4 <dirlookup+0x4a>
    if(de.inum == 0)
    80004204:	fa045783          	lhu	a5,-96(s0)
    80004208:	dff1                	beqz	a5,800041e4 <dirlookup+0x5a>
    if(namecmp(name, de.name) == 0){
    8000420a:	85da                	mv	a1,s6
    8000420c:	8556                	mv	a0,s5
    8000420e:	00000097          	auipc	ra,0x0
    80004212:	f62080e7          	jalr	-158(ra) # 80004170 <namecmp>
    80004216:	f579                	bnez	a0,800041e4 <dirlookup+0x5a>
      if(poff)
    80004218:	000b8463          	beqz	s7,80004220 <dirlookup+0x96>
        *poff = off;
    8000421c:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80004220:	fa045583          	lhu	a1,-96(s0)
    80004224:	00092503          	lw	a0,0(s2)
    80004228:	fffff097          	auipc	ra,0xfffff
    8000422c:	748080e7          	jalr	1864(ra) # 80003970 <iget>
    80004230:	a011                	j	80004234 <dirlookup+0xaa>
  return 0;
    80004232:	4501                	li	a0,0
}
    80004234:	60e6                	ld	ra,88(sp)
    80004236:	6446                	ld	s0,80(sp)
    80004238:	64a6                	ld	s1,72(sp)
    8000423a:	6906                	ld	s2,64(sp)
    8000423c:	79e2                	ld	s3,56(sp)
    8000423e:	7a42                	ld	s4,48(sp)
    80004240:	7aa2                	ld	s5,40(sp)
    80004242:	7b02                	ld	s6,32(sp)
    80004244:	6be2                	ld	s7,24(sp)
    80004246:	6125                	addi	sp,sp,96
    80004248:	8082                	ret

000000008000424a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000424a:	711d                	addi	sp,sp,-96
    8000424c:	ec86                	sd	ra,88(sp)
    8000424e:	e8a2                	sd	s0,80(sp)
    80004250:	e4a6                	sd	s1,72(sp)
    80004252:	e0ca                	sd	s2,64(sp)
    80004254:	fc4e                	sd	s3,56(sp)
    80004256:	f852                	sd	s4,48(sp)
    80004258:	f456                	sd	s5,40(sp)
    8000425a:	f05a                	sd	s6,32(sp)
    8000425c:	ec5e                	sd	s7,24(sp)
    8000425e:	e862                	sd	s8,16(sp)
    80004260:	e466                	sd	s9,8(sp)
    80004262:	e06a                	sd	s10,0(sp)
    80004264:	1080                	addi	s0,sp,96
    80004266:	84aa                	mv	s1,a0
    80004268:	8b2e                	mv	s6,a1
    8000426a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000426c:	00054703          	lbu	a4,0(a0)
    80004270:	02f00793          	li	a5,47
    80004274:	02f70363          	beq	a4,a5,8000429a <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004278:	ffffe097          	auipc	ra,0xffffe
    8000427c:	80e080e7          	jalr	-2034(ra) # 80001a86 <myproc>
    80004280:	15053503          	ld	a0,336(a0)
    80004284:	00000097          	auipc	ra,0x0
    80004288:	9da080e7          	jalr	-1574(ra) # 80003c5e <idup>
    8000428c:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000428e:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80004292:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80004294:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004296:	4b85                	li	s7,1
    80004298:	a87d                	j	80004356 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    8000429a:	4585                	li	a1,1
    8000429c:	852e                	mv	a0,a1
    8000429e:	fffff097          	auipc	ra,0xfffff
    800042a2:	6d2080e7          	jalr	1746(ra) # 80003970 <iget>
    800042a6:	8a2a                	mv	s4,a0
    800042a8:	b7dd                	j	8000428e <namex+0x44>
      iunlockput(ip);
    800042aa:	8552                	mv	a0,s4
    800042ac:	00000097          	auipc	ra,0x0
    800042b0:	c58080e7          	jalr	-936(ra) # 80003f04 <iunlockput>
      return 0;
    800042b4:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800042b6:	8552                	mv	a0,s4
    800042b8:	60e6                	ld	ra,88(sp)
    800042ba:	6446                	ld	s0,80(sp)
    800042bc:	64a6                	ld	s1,72(sp)
    800042be:	6906                	ld	s2,64(sp)
    800042c0:	79e2                	ld	s3,56(sp)
    800042c2:	7a42                	ld	s4,48(sp)
    800042c4:	7aa2                	ld	s5,40(sp)
    800042c6:	7b02                	ld	s6,32(sp)
    800042c8:	6be2                	ld	s7,24(sp)
    800042ca:	6c42                	ld	s8,16(sp)
    800042cc:	6ca2                	ld	s9,8(sp)
    800042ce:	6d02                	ld	s10,0(sp)
    800042d0:	6125                	addi	sp,sp,96
    800042d2:	8082                	ret
      iunlock(ip);
    800042d4:	8552                	mv	a0,s4
    800042d6:	00000097          	auipc	ra,0x0
    800042da:	a8c080e7          	jalr	-1396(ra) # 80003d62 <iunlock>
      return ip;
    800042de:	bfe1                	j	800042b6 <namex+0x6c>
      iunlockput(ip);
    800042e0:	8552                	mv	a0,s4
    800042e2:	00000097          	auipc	ra,0x0
    800042e6:	c22080e7          	jalr	-990(ra) # 80003f04 <iunlockput>
      return 0;
    800042ea:	8a4a                	mv	s4,s2
    800042ec:	b7e9                	j	800042b6 <namex+0x6c>
  len = path - s;
    800042ee:	40990633          	sub	a2,s2,s1
    800042f2:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    800042f6:	09ac5c63          	bge	s8,s10,8000438e <namex+0x144>
    memmove(name, s, DIRSIZ);
    800042fa:	8666                	mv	a2,s9
    800042fc:	85a6                	mv	a1,s1
    800042fe:	8556                	mv	a0,s5
    80004300:	ffffd097          	auipc	ra,0xffffd
    80004304:	aac080e7          	jalr	-1364(ra) # 80000dac <memmove>
    80004308:	84ca                	mv	s1,s2
  while(*path == '/')
    8000430a:	0004c783          	lbu	a5,0(s1)
    8000430e:	01379763          	bne	a5,s3,8000431c <namex+0xd2>
    path++;
    80004312:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004314:	0004c783          	lbu	a5,0(s1)
    80004318:	ff378de3          	beq	a5,s3,80004312 <namex+0xc8>
    ilock(ip);
    8000431c:	8552                	mv	a0,s4
    8000431e:	00000097          	auipc	ra,0x0
    80004322:	97e080e7          	jalr	-1666(ra) # 80003c9c <ilock>
    if(ip->type != T_DIR){
    80004326:	044a1783          	lh	a5,68(s4)
    8000432a:	f97790e3          	bne	a5,s7,800042aa <namex+0x60>
    if(nameiparent && *path == '\0'){
    8000432e:	000b0563          	beqz	s6,80004338 <namex+0xee>
    80004332:	0004c783          	lbu	a5,0(s1)
    80004336:	dfd9                	beqz	a5,800042d4 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004338:	4601                	li	a2,0
    8000433a:	85d6                	mv	a1,s5
    8000433c:	8552                	mv	a0,s4
    8000433e:	00000097          	auipc	ra,0x0
    80004342:	e4c080e7          	jalr	-436(ra) # 8000418a <dirlookup>
    80004346:	892a                	mv	s2,a0
    80004348:	dd41                	beqz	a0,800042e0 <namex+0x96>
    iunlockput(ip);
    8000434a:	8552                	mv	a0,s4
    8000434c:	00000097          	auipc	ra,0x0
    80004350:	bb8080e7          	jalr	-1096(ra) # 80003f04 <iunlockput>
    ip = next;
    80004354:	8a4a                	mv	s4,s2
  while(*path == '/')
    80004356:	0004c783          	lbu	a5,0(s1)
    8000435a:	01379763          	bne	a5,s3,80004368 <namex+0x11e>
    path++;
    8000435e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004360:	0004c783          	lbu	a5,0(s1)
    80004364:	ff378de3          	beq	a5,s3,8000435e <namex+0x114>
  if(*path == 0)
    80004368:	cf9d                	beqz	a5,800043a6 <namex+0x15c>
  while(*path != '/' && *path != 0)
    8000436a:	0004c783          	lbu	a5,0(s1)
    8000436e:	fd178713          	addi	a4,a5,-47
    80004372:	cb19                	beqz	a4,80004388 <namex+0x13e>
    80004374:	cb91                	beqz	a5,80004388 <namex+0x13e>
    80004376:	8926                	mv	s2,s1
    path++;
    80004378:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    8000437a:	00094783          	lbu	a5,0(s2)
    8000437e:	fd178713          	addi	a4,a5,-47
    80004382:	d735                	beqz	a4,800042ee <namex+0xa4>
    80004384:	fbf5                	bnez	a5,80004378 <namex+0x12e>
    80004386:	b7a5                	j	800042ee <namex+0xa4>
    80004388:	8926                	mv	s2,s1
  len = path - s;
    8000438a:	4d01                	li	s10,0
    8000438c:	4601                	li	a2,0
    memmove(name, s, len);
    8000438e:	2601                	sext.w	a2,a2
    80004390:	85a6                	mv	a1,s1
    80004392:	8556                	mv	a0,s5
    80004394:	ffffd097          	auipc	ra,0xffffd
    80004398:	a18080e7          	jalr	-1512(ra) # 80000dac <memmove>
    name[len] = 0;
    8000439c:	9d56                	add	s10,s10,s5
    8000439e:	000d0023          	sb	zero,0(s10)
    800043a2:	84ca                	mv	s1,s2
    800043a4:	b79d                	j	8000430a <namex+0xc0>
  if(nameiparent){
    800043a6:	f00b08e3          	beqz	s6,800042b6 <namex+0x6c>
    iput(ip);
    800043aa:	8552                	mv	a0,s4
    800043ac:	00000097          	auipc	ra,0x0
    800043b0:	aae080e7          	jalr	-1362(ra) # 80003e5a <iput>
    return 0;
    800043b4:	4a01                	li	s4,0
    800043b6:	b701                	j	800042b6 <namex+0x6c>

00000000800043b8 <dirlink>:
{
    800043b8:	715d                	addi	sp,sp,-80
    800043ba:	e486                	sd	ra,72(sp)
    800043bc:	e0a2                	sd	s0,64(sp)
    800043be:	f84a                	sd	s2,48(sp)
    800043c0:	ec56                	sd	s5,24(sp)
    800043c2:	e85a                	sd	s6,16(sp)
    800043c4:	0880                	addi	s0,sp,80
    800043c6:	892a                	mv	s2,a0
    800043c8:	8aae                	mv	s5,a1
    800043ca:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800043cc:	4601                	li	a2,0
    800043ce:	00000097          	auipc	ra,0x0
    800043d2:	dbc080e7          	jalr	-580(ra) # 8000418a <dirlookup>
    800043d6:	e129                	bnez	a0,80004418 <dirlink+0x60>
    800043d8:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043da:	04c92483          	lw	s1,76(s2)
    800043de:	cca9                	beqz	s1,80004438 <dirlink+0x80>
    800043e0:	f44e                	sd	s3,40(sp)
    800043e2:	f052                	sd	s4,32(sp)
    800043e4:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043e6:	fb040a13          	addi	s4,s0,-80
    800043ea:	49c1                	li	s3,16
    800043ec:	874e                	mv	a4,s3
    800043ee:	86a6                	mv	a3,s1
    800043f0:	8652                	mv	a2,s4
    800043f2:	4581                	li	a1,0
    800043f4:	854a                	mv	a0,s2
    800043f6:	00000097          	auipc	ra,0x0
    800043fa:	b64080e7          	jalr	-1180(ra) # 80003f5a <readi>
    800043fe:	03351363          	bne	a0,s3,80004424 <dirlink+0x6c>
    if(de.inum == 0)
    80004402:	fb045783          	lhu	a5,-80(s0)
    80004406:	c79d                	beqz	a5,80004434 <dirlink+0x7c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004408:	24c1                	addiw	s1,s1,16
    8000440a:	04c92783          	lw	a5,76(s2)
    8000440e:	fcf4efe3          	bltu	s1,a5,800043ec <dirlink+0x34>
    80004412:	79a2                	ld	s3,40(sp)
    80004414:	7a02                	ld	s4,32(sp)
    80004416:	a00d                	j	80004438 <dirlink+0x80>
    iput(ip);
    80004418:	00000097          	auipc	ra,0x0
    8000441c:	a42080e7          	jalr	-1470(ra) # 80003e5a <iput>
    return -1;
    80004420:	557d                	li	a0,-1
    80004422:	a0a9                	j	8000446c <dirlink+0xb4>
      panic("dirlink read");
    80004424:	00004517          	auipc	a0,0x4
    80004428:	20c50513          	addi	a0,a0,524 # 80008630 <etext+0x630>
    8000442c:	ffffc097          	auipc	ra,0xffffc
    80004430:	12a080e7          	jalr	298(ra) # 80000556 <panic>
    80004434:	79a2                	ld	s3,40(sp)
    80004436:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80004438:	4639                	li	a2,14
    8000443a:	85d6                	mv	a1,s5
    8000443c:	fb240513          	addi	a0,s0,-78
    80004440:	ffffd097          	auipc	ra,0xffffd
    80004444:	a1e080e7          	jalr	-1506(ra) # 80000e5e <strncpy>
  de.inum = inum;
    80004448:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000444c:	4741                	li	a4,16
    8000444e:	86a6                	mv	a3,s1
    80004450:	fb040613          	addi	a2,s0,-80
    80004454:	4581                	li	a1,0
    80004456:	854a                	mv	a0,s2
    80004458:	00000097          	auipc	ra,0x0
    8000445c:	bfc080e7          	jalr	-1028(ra) # 80004054 <writei>
    80004460:	872a                	mv	a4,a0
    80004462:	47c1                	li	a5,16
  return 0;
    80004464:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004466:	00f71a63          	bne	a4,a5,8000447a <dirlink+0xc2>
    8000446a:	74e2                	ld	s1,56(sp)
}
    8000446c:	60a6                	ld	ra,72(sp)
    8000446e:	6406                	ld	s0,64(sp)
    80004470:	7942                	ld	s2,48(sp)
    80004472:	6ae2                	ld	s5,24(sp)
    80004474:	6b42                	ld	s6,16(sp)
    80004476:	6161                	addi	sp,sp,80
    80004478:	8082                	ret
    8000447a:	f44e                	sd	s3,40(sp)
    8000447c:	f052                	sd	s4,32(sp)
    panic("dirlink");
    8000447e:	00004517          	auipc	a0,0x4
    80004482:	2ba50513          	addi	a0,a0,698 # 80008738 <etext+0x738>
    80004486:	ffffc097          	auipc	ra,0xffffc
    8000448a:	0d0080e7          	jalr	208(ra) # 80000556 <panic>

000000008000448e <namei>:

struct inode*
namei(char *path)
{
    8000448e:	1101                	addi	sp,sp,-32
    80004490:	ec06                	sd	ra,24(sp)
    80004492:	e822                	sd	s0,16(sp)
    80004494:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004496:	fe040613          	addi	a2,s0,-32
    8000449a:	4581                	li	a1,0
    8000449c:	00000097          	auipc	ra,0x0
    800044a0:	dae080e7          	jalr	-594(ra) # 8000424a <namex>
}
    800044a4:	60e2                	ld	ra,24(sp)
    800044a6:	6442                	ld	s0,16(sp)
    800044a8:	6105                	addi	sp,sp,32
    800044aa:	8082                	ret

00000000800044ac <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800044ac:	1141                	addi	sp,sp,-16
    800044ae:	e406                	sd	ra,8(sp)
    800044b0:	e022                	sd	s0,0(sp)
    800044b2:	0800                	addi	s0,sp,16
    800044b4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800044b6:	4585                	li	a1,1
    800044b8:	00000097          	auipc	ra,0x0
    800044bc:	d92080e7          	jalr	-622(ra) # 8000424a <namex>
}
    800044c0:	60a2                	ld	ra,8(sp)
    800044c2:	6402                	ld	s0,0(sp)
    800044c4:	0141                	addi	sp,sp,16
    800044c6:	8082                	ret

00000000800044c8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800044c8:	1101                	addi	sp,sp,-32
    800044ca:	ec06                	sd	ra,24(sp)
    800044cc:	e822                	sd	s0,16(sp)
    800044ce:	e426                	sd	s1,8(sp)
    800044d0:	e04a                	sd	s2,0(sp)
    800044d2:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800044d4:	00021917          	auipc	s2,0x21
    800044d8:	59c90913          	addi	s2,s2,1436 # 80025a70 <log>
    800044dc:	01892583          	lw	a1,24(s2)
    800044e0:	02892503          	lw	a0,40(s2)
    800044e4:	fffff097          	auipc	ra,0xfffff
    800044e8:	fec080e7          	jalr	-20(ra) # 800034d0 <bread>
    800044ec:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800044ee:	02c92603          	lw	a2,44(s2)
    800044f2:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800044f4:	00c05f63          	blez	a2,80004512 <write_head+0x4a>
    800044f8:	00021717          	auipc	a4,0x21
    800044fc:	5a870713          	addi	a4,a4,1448 # 80025aa0 <log+0x30>
    80004500:	87aa                	mv	a5,a0
    80004502:	060a                	slli	a2,a2,0x2
    80004504:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004506:	4314                	lw	a3,0(a4)
    80004508:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000450a:	0711                	addi	a4,a4,4
    8000450c:	0791                	addi	a5,a5,4
    8000450e:	fec79ce3          	bne	a5,a2,80004506 <write_head+0x3e>
  }
  bwrite(buf);
    80004512:	8526                	mv	a0,s1
    80004514:	fffff097          	auipc	ra,0xfffff
    80004518:	0ae080e7          	jalr	174(ra) # 800035c2 <bwrite>
  brelse(buf);
    8000451c:	8526                	mv	a0,s1
    8000451e:	fffff097          	auipc	ra,0xfffff
    80004522:	0e2080e7          	jalr	226(ra) # 80003600 <brelse>
}
    80004526:	60e2                	ld	ra,24(sp)
    80004528:	6442                	ld	s0,16(sp)
    8000452a:	64a2                	ld	s1,8(sp)
    8000452c:	6902                	ld	s2,0(sp)
    8000452e:	6105                	addi	sp,sp,32
    80004530:	8082                	ret

0000000080004532 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004532:	00021797          	auipc	a5,0x21
    80004536:	56a7a783          	lw	a5,1386(a5) # 80025a9c <log+0x2c>
    8000453a:	0cf05063          	blez	a5,800045fa <install_trans+0xc8>
{
    8000453e:	715d                	addi	sp,sp,-80
    80004540:	e486                	sd	ra,72(sp)
    80004542:	e0a2                	sd	s0,64(sp)
    80004544:	fc26                	sd	s1,56(sp)
    80004546:	f84a                	sd	s2,48(sp)
    80004548:	f44e                	sd	s3,40(sp)
    8000454a:	f052                	sd	s4,32(sp)
    8000454c:	ec56                	sd	s5,24(sp)
    8000454e:	e85a                	sd	s6,16(sp)
    80004550:	e45e                	sd	s7,8(sp)
    80004552:	0880                	addi	s0,sp,80
    80004554:	8b2a                	mv	s6,a0
    80004556:	00021a97          	auipc	s5,0x21
    8000455a:	54aa8a93          	addi	s5,s5,1354 # 80025aa0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000455e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004560:	00021997          	auipc	s3,0x21
    80004564:	51098993          	addi	s3,s3,1296 # 80025a70 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004568:	40000b93          	li	s7,1024
    8000456c:	a00d                	j	8000458e <install_trans+0x5c>
    brelse(lbuf);
    8000456e:	854a                	mv	a0,s2
    80004570:	fffff097          	auipc	ra,0xfffff
    80004574:	090080e7          	jalr	144(ra) # 80003600 <brelse>
    brelse(dbuf);
    80004578:	8526                	mv	a0,s1
    8000457a:	fffff097          	auipc	ra,0xfffff
    8000457e:	086080e7          	jalr	134(ra) # 80003600 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004582:	2a05                	addiw	s4,s4,1
    80004584:	0a91                	addi	s5,s5,4
    80004586:	02c9a783          	lw	a5,44(s3)
    8000458a:	04fa5d63          	bge	s4,a5,800045e4 <install_trans+0xb2>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000458e:	0189a583          	lw	a1,24(s3)
    80004592:	014585bb          	addw	a1,a1,s4
    80004596:	2585                	addiw	a1,a1,1
    80004598:	0289a503          	lw	a0,40(s3)
    8000459c:	fffff097          	auipc	ra,0xfffff
    800045a0:	f34080e7          	jalr	-204(ra) # 800034d0 <bread>
    800045a4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800045a6:	000aa583          	lw	a1,0(s5)
    800045aa:	0289a503          	lw	a0,40(s3)
    800045ae:	fffff097          	auipc	ra,0xfffff
    800045b2:	f22080e7          	jalr	-222(ra) # 800034d0 <bread>
    800045b6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800045b8:	865e                	mv	a2,s7
    800045ba:	05890593          	addi	a1,s2,88
    800045be:	05850513          	addi	a0,a0,88
    800045c2:	ffffc097          	auipc	ra,0xffffc
    800045c6:	7ea080e7          	jalr	2026(ra) # 80000dac <memmove>
    bwrite(dbuf);  // write dst to disk
    800045ca:	8526                	mv	a0,s1
    800045cc:	fffff097          	auipc	ra,0xfffff
    800045d0:	ff6080e7          	jalr	-10(ra) # 800035c2 <bwrite>
    if(recovering == 0)
    800045d4:	f80b1de3          	bnez	s6,8000456e <install_trans+0x3c>
      bunpin(dbuf);
    800045d8:	8526                	mv	a0,s1
    800045da:	fffff097          	auipc	ra,0xfffff
    800045de:	0fa080e7          	jalr	250(ra) # 800036d4 <bunpin>
    800045e2:	b771                	j	8000456e <install_trans+0x3c>
}
    800045e4:	60a6                	ld	ra,72(sp)
    800045e6:	6406                	ld	s0,64(sp)
    800045e8:	74e2                	ld	s1,56(sp)
    800045ea:	7942                	ld	s2,48(sp)
    800045ec:	79a2                	ld	s3,40(sp)
    800045ee:	7a02                	ld	s4,32(sp)
    800045f0:	6ae2                	ld	s5,24(sp)
    800045f2:	6b42                	ld	s6,16(sp)
    800045f4:	6ba2                	ld	s7,8(sp)
    800045f6:	6161                	addi	sp,sp,80
    800045f8:	8082                	ret
    800045fa:	8082                	ret

00000000800045fc <initlog>:
{
    800045fc:	7179                	addi	sp,sp,-48
    800045fe:	f406                	sd	ra,40(sp)
    80004600:	f022                	sd	s0,32(sp)
    80004602:	ec26                	sd	s1,24(sp)
    80004604:	e84a                	sd	s2,16(sp)
    80004606:	e44e                	sd	s3,8(sp)
    80004608:	1800                	addi	s0,sp,48
    8000460a:	892a                	mv	s2,a0
    8000460c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000460e:	00021497          	auipc	s1,0x21
    80004612:	46248493          	addi	s1,s1,1122 # 80025a70 <log>
    80004616:	00004597          	auipc	a1,0x4
    8000461a:	02a58593          	addi	a1,a1,42 # 80008640 <etext+0x640>
    8000461e:	8526                	mv	a0,s1
    80004620:	ffffc097          	auipc	ra,0xffffc
    80004624:	59a080e7          	jalr	1434(ra) # 80000bba <initlock>
  log.start = sb->logstart;
    80004628:	0149a583          	lw	a1,20(s3)
    8000462c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000462e:	0109a783          	lw	a5,16(s3)
    80004632:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004634:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004638:	854a                	mv	a0,s2
    8000463a:	fffff097          	auipc	ra,0xfffff
    8000463e:	e96080e7          	jalr	-362(ra) # 800034d0 <bread>
  log.lh.n = lh->n;
    80004642:	4d30                	lw	a2,88(a0)
    80004644:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004646:	00c05f63          	blez	a2,80004664 <initlog+0x68>
    8000464a:	87aa                	mv	a5,a0
    8000464c:	00021717          	auipc	a4,0x21
    80004650:	45470713          	addi	a4,a4,1108 # 80025aa0 <log+0x30>
    80004654:	060a                	slli	a2,a2,0x2
    80004656:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004658:	4ff4                	lw	a3,92(a5)
    8000465a:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000465c:	0791                	addi	a5,a5,4
    8000465e:	0711                	addi	a4,a4,4
    80004660:	fec79ce3          	bne	a5,a2,80004658 <initlog+0x5c>
  brelse(buf);
    80004664:	fffff097          	auipc	ra,0xfffff
    80004668:	f9c080e7          	jalr	-100(ra) # 80003600 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000466c:	4505                	li	a0,1
    8000466e:	00000097          	auipc	ra,0x0
    80004672:	ec4080e7          	jalr	-316(ra) # 80004532 <install_trans>
  log.lh.n = 0;
    80004676:	00021797          	auipc	a5,0x21
    8000467a:	4207a323          	sw	zero,1062(a5) # 80025a9c <log+0x2c>
  write_head(); // clear the log
    8000467e:	00000097          	auipc	ra,0x0
    80004682:	e4a080e7          	jalr	-438(ra) # 800044c8 <write_head>
}
    80004686:	70a2                	ld	ra,40(sp)
    80004688:	7402                	ld	s0,32(sp)
    8000468a:	64e2                	ld	s1,24(sp)
    8000468c:	6942                	ld	s2,16(sp)
    8000468e:	69a2                	ld	s3,8(sp)
    80004690:	6145                	addi	sp,sp,48
    80004692:	8082                	ret

0000000080004694 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004694:	1101                	addi	sp,sp,-32
    80004696:	ec06                	sd	ra,24(sp)
    80004698:	e822                	sd	s0,16(sp)
    8000469a:	e426                	sd	s1,8(sp)
    8000469c:	e04a                	sd	s2,0(sp)
    8000469e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800046a0:	00021517          	auipc	a0,0x21
    800046a4:	3d050513          	addi	a0,a0,976 # 80025a70 <log>
    800046a8:	ffffc097          	auipc	ra,0xffffc
    800046ac:	5ac080e7          	jalr	1452(ra) # 80000c54 <acquire>
  while(1){
    if(log.committing){
    800046b0:	00021497          	auipc	s1,0x21
    800046b4:	3c048493          	addi	s1,s1,960 # 80025a70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800046b8:	4979                	li	s2,30
    800046ba:	a039                	j	800046c8 <begin_op+0x34>
      sleep(&log, &log.lock);
    800046bc:	85a6                	mv	a1,s1
    800046be:	8526                	mv	a0,s1
    800046c0:	ffffe097          	auipc	ra,0xffffe
    800046c4:	bfc080e7          	jalr	-1028(ra) # 800022bc <sleep>
    if(log.committing){
    800046c8:	50dc                	lw	a5,36(s1)
    800046ca:	fbed                	bnez	a5,800046bc <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800046cc:	5098                	lw	a4,32(s1)
    800046ce:	2705                	addiw	a4,a4,1
    800046d0:	0027179b          	slliw	a5,a4,0x2
    800046d4:	9fb9                	addw	a5,a5,a4
    800046d6:	0017979b          	slliw	a5,a5,0x1
    800046da:	54d4                	lw	a3,44(s1)
    800046dc:	9fb5                	addw	a5,a5,a3
    800046de:	00f95963          	bge	s2,a5,800046f0 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800046e2:	85a6                	mv	a1,s1
    800046e4:	8526                	mv	a0,s1
    800046e6:	ffffe097          	auipc	ra,0xffffe
    800046ea:	bd6080e7          	jalr	-1066(ra) # 800022bc <sleep>
    800046ee:	bfe9                	j	800046c8 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800046f0:	00021797          	auipc	a5,0x21
    800046f4:	3ae7a023          	sw	a4,928(a5) # 80025a90 <log+0x20>
      release(&log.lock);
    800046f8:	00021517          	auipc	a0,0x21
    800046fc:	37850513          	addi	a0,a0,888 # 80025a70 <log>
    80004700:	ffffc097          	auipc	ra,0xffffc
    80004704:	604080e7          	jalr	1540(ra) # 80000d04 <release>
      break;
    }
  }
}
    80004708:	60e2                	ld	ra,24(sp)
    8000470a:	6442                	ld	s0,16(sp)
    8000470c:	64a2                	ld	s1,8(sp)
    8000470e:	6902                	ld	s2,0(sp)
    80004710:	6105                	addi	sp,sp,32
    80004712:	8082                	ret

0000000080004714 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004714:	7139                	addi	sp,sp,-64
    80004716:	fc06                	sd	ra,56(sp)
    80004718:	f822                	sd	s0,48(sp)
    8000471a:	f426                	sd	s1,40(sp)
    8000471c:	f04a                	sd	s2,32(sp)
    8000471e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004720:	00021497          	auipc	s1,0x21
    80004724:	35048493          	addi	s1,s1,848 # 80025a70 <log>
    80004728:	8526                	mv	a0,s1
    8000472a:	ffffc097          	auipc	ra,0xffffc
    8000472e:	52a080e7          	jalr	1322(ra) # 80000c54 <acquire>
  log.outstanding -= 1;
    80004732:	509c                	lw	a5,32(s1)
    80004734:	37fd                	addiw	a5,a5,-1
    80004736:	893e                	mv	s2,a5
    80004738:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000473a:	50dc                	lw	a5,36(s1)
    8000473c:	efb1                	bnez	a5,80004798 <end_op+0x84>
    panic("log.committing");
  if(log.outstanding == 0){
    8000473e:	06091863          	bnez	s2,800047ae <end_op+0x9a>
    do_commit = 1;
    log.committing = 1;
    80004742:	00021497          	auipc	s1,0x21
    80004746:	32e48493          	addi	s1,s1,814 # 80025a70 <log>
    8000474a:	4785                	li	a5,1
    8000474c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000474e:	8526                	mv	a0,s1
    80004750:	ffffc097          	auipc	ra,0xffffc
    80004754:	5b4080e7          	jalr	1460(ra) # 80000d04 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004758:	54dc                	lw	a5,44(s1)
    8000475a:	08f04063          	bgtz	a5,800047da <end_op+0xc6>
    acquire(&log.lock);
    8000475e:	00021517          	auipc	a0,0x21
    80004762:	31250513          	addi	a0,a0,786 # 80025a70 <log>
    80004766:	ffffc097          	auipc	ra,0xffffc
    8000476a:	4ee080e7          	jalr	1262(ra) # 80000c54 <acquire>
    log.committing = 0;
    8000476e:	00021797          	auipc	a5,0x21
    80004772:	3207a323          	sw	zero,806(a5) # 80025a94 <log+0x24>
    wakeup(&log);
    80004776:	00021517          	auipc	a0,0x21
    8000477a:	2fa50513          	addi	a0,a0,762 # 80025a70 <log>
    8000477e:	ffffe097          	auipc	ra,0xffffe
    80004782:	cc4080e7          	jalr	-828(ra) # 80002442 <wakeup>
    release(&log.lock);
    80004786:	00021517          	auipc	a0,0x21
    8000478a:	2ea50513          	addi	a0,a0,746 # 80025a70 <log>
    8000478e:	ffffc097          	auipc	ra,0xffffc
    80004792:	576080e7          	jalr	1398(ra) # 80000d04 <release>
}
    80004796:	a825                	j	800047ce <end_op+0xba>
    80004798:	ec4e                	sd	s3,24(sp)
    8000479a:	e852                	sd	s4,16(sp)
    8000479c:	e456                	sd	s5,8(sp)
    panic("log.committing");
    8000479e:	00004517          	auipc	a0,0x4
    800047a2:	eaa50513          	addi	a0,a0,-342 # 80008648 <etext+0x648>
    800047a6:	ffffc097          	auipc	ra,0xffffc
    800047aa:	db0080e7          	jalr	-592(ra) # 80000556 <panic>
    wakeup(&log);
    800047ae:	00021517          	auipc	a0,0x21
    800047b2:	2c250513          	addi	a0,a0,706 # 80025a70 <log>
    800047b6:	ffffe097          	auipc	ra,0xffffe
    800047ba:	c8c080e7          	jalr	-884(ra) # 80002442 <wakeup>
  release(&log.lock);
    800047be:	00021517          	auipc	a0,0x21
    800047c2:	2b250513          	addi	a0,a0,690 # 80025a70 <log>
    800047c6:	ffffc097          	auipc	ra,0xffffc
    800047ca:	53e080e7          	jalr	1342(ra) # 80000d04 <release>
}
    800047ce:	70e2                	ld	ra,56(sp)
    800047d0:	7442                	ld	s0,48(sp)
    800047d2:	74a2                	ld	s1,40(sp)
    800047d4:	7902                	ld	s2,32(sp)
    800047d6:	6121                	addi	sp,sp,64
    800047d8:	8082                	ret
    800047da:	ec4e                	sd	s3,24(sp)
    800047dc:	e852                	sd	s4,16(sp)
    800047de:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800047e0:	00021a97          	auipc	s5,0x21
    800047e4:	2c0a8a93          	addi	s5,s5,704 # 80025aa0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800047e8:	00021a17          	auipc	s4,0x21
    800047ec:	288a0a13          	addi	s4,s4,648 # 80025a70 <log>
    800047f0:	018a2583          	lw	a1,24(s4)
    800047f4:	012585bb          	addw	a1,a1,s2
    800047f8:	2585                	addiw	a1,a1,1
    800047fa:	028a2503          	lw	a0,40(s4)
    800047fe:	fffff097          	auipc	ra,0xfffff
    80004802:	cd2080e7          	jalr	-814(ra) # 800034d0 <bread>
    80004806:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004808:	000aa583          	lw	a1,0(s5)
    8000480c:	028a2503          	lw	a0,40(s4)
    80004810:	fffff097          	auipc	ra,0xfffff
    80004814:	cc0080e7          	jalr	-832(ra) # 800034d0 <bread>
    80004818:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000481a:	40000613          	li	a2,1024
    8000481e:	05850593          	addi	a1,a0,88
    80004822:	05848513          	addi	a0,s1,88
    80004826:	ffffc097          	auipc	ra,0xffffc
    8000482a:	586080e7          	jalr	1414(ra) # 80000dac <memmove>
    bwrite(to);  // write the log
    8000482e:	8526                	mv	a0,s1
    80004830:	fffff097          	auipc	ra,0xfffff
    80004834:	d92080e7          	jalr	-622(ra) # 800035c2 <bwrite>
    brelse(from);
    80004838:	854e                	mv	a0,s3
    8000483a:	fffff097          	auipc	ra,0xfffff
    8000483e:	dc6080e7          	jalr	-570(ra) # 80003600 <brelse>
    brelse(to);
    80004842:	8526                	mv	a0,s1
    80004844:	fffff097          	auipc	ra,0xfffff
    80004848:	dbc080e7          	jalr	-580(ra) # 80003600 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000484c:	2905                	addiw	s2,s2,1
    8000484e:	0a91                	addi	s5,s5,4
    80004850:	02ca2783          	lw	a5,44(s4)
    80004854:	f8f94ee3          	blt	s2,a5,800047f0 <end_op+0xdc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004858:	00000097          	auipc	ra,0x0
    8000485c:	c70080e7          	jalr	-912(ra) # 800044c8 <write_head>
    install_trans(0); // Now install writes to home locations
    80004860:	4501                	li	a0,0
    80004862:	00000097          	auipc	ra,0x0
    80004866:	cd0080e7          	jalr	-816(ra) # 80004532 <install_trans>
    log.lh.n = 0;
    8000486a:	00021797          	auipc	a5,0x21
    8000486e:	2207a923          	sw	zero,562(a5) # 80025a9c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004872:	00000097          	auipc	ra,0x0
    80004876:	c56080e7          	jalr	-938(ra) # 800044c8 <write_head>
    8000487a:	69e2                	ld	s3,24(sp)
    8000487c:	6a42                	ld	s4,16(sp)
    8000487e:	6aa2                	ld	s5,8(sp)
    80004880:	bdf9                	j	8000475e <end_op+0x4a>

0000000080004882 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004882:	1101                	addi	sp,sp,-32
    80004884:	ec06                	sd	ra,24(sp)
    80004886:	e822                	sd	s0,16(sp)
    80004888:	e426                	sd	s1,8(sp)
    8000488a:	1000                	addi	s0,sp,32
    8000488c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000488e:	00021517          	auipc	a0,0x21
    80004892:	1e250513          	addi	a0,a0,482 # 80025a70 <log>
    80004896:	ffffc097          	auipc	ra,0xffffc
    8000489a:	3be080e7          	jalr	958(ra) # 80000c54 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000489e:	00021617          	auipc	a2,0x21
    800048a2:	1fe62603          	lw	a2,510(a2) # 80025a9c <log+0x2c>
    800048a6:	47f5                	li	a5,29
    800048a8:	06c7c663          	blt	a5,a2,80004914 <log_write+0x92>
    800048ac:	00021797          	auipc	a5,0x21
    800048b0:	1e07a783          	lw	a5,480(a5) # 80025a8c <log+0x1c>
    800048b4:	37fd                	addiw	a5,a5,-1
    800048b6:	04f65f63          	bge	a2,a5,80004914 <log_write+0x92>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800048ba:	00021797          	auipc	a5,0x21
    800048be:	1d67a783          	lw	a5,470(a5) # 80025a90 <log+0x20>
    800048c2:	06f05163          	blez	a5,80004924 <log_write+0xa2>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800048c6:	4781                	li	a5,0
    800048c8:	06c05663          	blez	a2,80004934 <log_write+0xb2>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800048cc:	44cc                	lw	a1,12(s1)
    800048ce:	00021717          	auipc	a4,0x21
    800048d2:	1d270713          	addi	a4,a4,466 # 80025aa0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800048d6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800048d8:	4314                	lw	a3,0(a4)
    800048da:	04b68d63          	beq	a3,a1,80004934 <log_write+0xb2>
  for (i = 0; i < log.lh.n; i++) {
    800048de:	2785                	addiw	a5,a5,1
    800048e0:	0711                	addi	a4,a4,4
    800048e2:	fef61be3          	bne	a2,a5,800048d8 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800048e6:	060a                	slli	a2,a2,0x2
    800048e8:	02060613          	addi	a2,a2,32
    800048ec:	00021797          	auipc	a5,0x21
    800048f0:	18478793          	addi	a5,a5,388 # 80025a70 <log>
    800048f4:	97b2                	add	a5,a5,a2
    800048f6:	44d8                	lw	a4,12(s1)
    800048f8:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800048fa:	8526                	mv	a0,s1
    800048fc:	fffff097          	auipc	ra,0xfffff
    80004900:	d9c080e7          	jalr	-612(ra) # 80003698 <bpin>
    log.lh.n++;
    80004904:	00021717          	auipc	a4,0x21
    80004908:	16c70713          	addi	a4,a4,364 # 80025a70 <log>
    8000490c:	575c                	lw	a5,44(a4)
    8000490e:	2785                	addiw	a5,a5,1
    80004910:	d75c                	sw	a5,44(a4)
    80004912:	a835                	j	8000494e <log_write+0xcc>
    panic("too big a transaction");
    80004914:	00004517          	auipc	a0,0x4
    80004918:	d4450513          	addi	a0,a0,-700 # 80008658 <etext+0x658>
    8000491c:	ffffc097          	auipc	ra,0xffffc
    80004920:	c3a080e7          	jalr	-966(ra) # 80000556 <panic>
    panic("log_write outside of trans");
    80004924:	00004517          	auipc	a0,0x4
    80004928:	d4c50513          	addi	a0,a0,-692 # 80008670 <etext+0x670>
    8000492c:	ffffc097          	auipc	ra,0xffffc
    80004930:	c2a080e7          	jalr	-982(ra) # 80000556 <panic>
  log.lh.block[i] = b->blockno;
    80004934:	00279693          	slli	a3,a5,0x2
    80004938:	02068693          	addi	a3,a3,32
    8000493c:	00021717          	auipc	a4,0x21
    80004940:	13470713          	addi	a4,a4,308 # 80025a70 <log>
    80004944:	9736                	add	a4,a4,a3
    80004946:	44d4                	lw	a3,12(s1)
    80004948:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000494a:	faf608e3          	beq	a2,a5,800048fa <log_write+0x78>
  }
  release(&log.lock);
    8000494e:	00021517          	auipc	a0,0x21
    80004952:	12250513          	addi	a0,a0,290 # 80025a70 <log>
    80004956:	ffffc097          	auipc	ra,0xffffc
    8000495a:	3ae080e7          	jalr	942(ra) # 80000d04 <release>
}
    8000495e:	60e2                	ld	ra,24(sp)
    80004960:	6442                	ld	s0,16(sp)
    80004962:	64a2                	ld	s1,8(sp)
    80004964:	6105                	addi	sp,sp,32
    80004966:	8082                	ret

0000000080004968 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004968:	1101                	addi	sp,sp,-32
    8000496a:	ec06                	sd	ra,24(sp)
    8000496c:	e822                	sd	s0,16(sp)
    8000496e:	e426                	sd	s1,8(sp)
    80004970:	e04a                	sd	s2,0(sp)
    80004972:	1000                	addi	s0,sp,32
    80004974:	84aa                	mv	s1,a0
    80004976:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004978:	00004597          	auipc	a1,0x4
    8000497c:	d1858593          	addi	a1,a1,-744 # 80008690 <etext+0x690>
    80004980:	0521                	addi	a0,a0,8
    80004982:	ffffc097          	auipc	ra,0xffffc
    80004986:	238080e7          	jalr	568(ra) # 80000bba <initlock>
  lk->name = name;
    8000498a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000498e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004992:	0204a423          	sw	zero,40(s1)
}
    80004996:	60e2                	ld	ra,24(sp)
    80004998:	6442                	ld	s0,16(sp)
    8000499a:	64a2                	ld	s1,8(sp)
    8000499c:	6902                	ld	s2,0(sp)
    8000499e:	6105                	addi	sp,sp,32
    800049a0:	8082                	ret

00000000800049a2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800049a2:	1101                	addi	sp,sp,-32
    800049a4:	ec06                	sd	ra,24(sp)
    800049a6:	e822                	sd	s0,16(sp)
    800049a8:	e426                	sd	s1,8(sp)
    800049aa:	e04a                	sd	s2,0(sp)
    800049ac:	1000                	addi	s0,sp,32
    800049ae:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800049b0:	00850913          	addi	s2,a0,8
    800049b4:	854a                	mv	a0,s2
    800049b6:	ffffc097          	auipc	ra,0xffffc
    800049ba:	29e080e7          	jalr	670(ra) # 80000c54 <acquire>
  while (lk->locked) {
    800049be:	409c                	lw	a5,0(s1)
    800049c0:	cb89                	beqz	a5,800049d2 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800049c2:	85ca                	mv	a1,s2
    800049c4:	8526                	mv	a0,s1
    800049c6:	ffffe097          	auipc	ra,0xffffe
    800049ca:	8f6080e7          	jalr	-1802(ra) # 800022bc <sleep>
  while (lk->locked) {
    800049ce:	409c                	lw	a5,0(s1)
    800049d0:	fbed                	bnez	a5,800049c2 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800049d2:	4785                	li	a5,1
    800049d4:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800049d6:	ffffd097          	auipc	ra,0xffffd
    800049da:	0b0080e7          	jalr	176(ra) # 80001a86 <myproc>
    800049de:	591c                	lw	a5,48(a0)
    800049e0:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800049e2:	854a                	mv	a0,s2
    800049e4:	ffffc097          	auipc	ra,0xffffc
    800049e8:	320080e7          	jalr	800(ra) # 80000d04 <release>
}
    800049ec:	60e2                	ld	ra,24(sp)
    800049ee:	6442                	ld	s0,16(sp)
    800049f0:	64a2                	ld	s1,8(sp)
    800049f2:	6902                	ld	s2,0(sp)
    800049f4:	6105                	addi	sp,sp,32
    800049f6:	8082                	ret

00000000800049f8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800049f8:	1101                	addi	sp,sp,-32
    800049fa:	ec06                	sd	ra,24(sp)
    800049fc:	e822                	sd	s0,16(sp)
    800049fe:	e426                	sd	s1,8(sp)
    80004a00:	e04a                	sd	s2,0(sp)
    80004a02:	1000                	addi	s0,sp,32
    80004a04:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004a06:	00850913          	addi	s2,a0,8
    80004a0a:	854a                	mv	a0,s2
    80004a0c:	ffffc097          	auipc	ra,0xffffc
    80004a10:	248080e7          	jalr	584(ra) # 80000c54 <acquire>
  lk->locked = 0;
    80004a14:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a18:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004a1c:	8526                	mv	a0,s1
    80004a1e:	ffffe097          	auipc	ra,0xffffe
    80004a22:	a24080e7          	jalr	-1500(ra) # 80002442 <wakeup>
  release(&lk->lk);
    80004a26:	854a                	mv	a0,s2
    80004a28:	ffffc097          	auipc	ra,0xffffc
    80004a2c:	2dc080e7          	jalr	732(ra) # 80000d04 <release>
}
    80004a30:	60e2                	ld	ra,24(sp)
    80004a32:	6442                	ld	s0,16(sp)
    80004a34:	64a2                	ld	s1,8(sp)
    80004a36:	6902                	ld	s2,0(sp)
    80004a38:	6105                	addi	sp,sp,32
    80004a3a:	8082                	ret

0000000080004a3c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004a3c:	7179                	addi	sp,sp,-48
    80004a3e:	f406                	sd	ra,40(sp)
    80004a40:	f022                	sd	s0,32(sp)
    80004a42:	ec26                	sd	s1,24(sp)
    80004a44:	e84a                	sd	s2,16(sp)
    80004a46:	1800                	addi	s0,sp,48
    80004a48:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004a4a:	00850913          	addi	s2,a0,8
    80004a4e:	854a                	mv	a0,s2
    80004a50:	ffffc097          	auipc	ra,0xffffc
    80004a54:	204080e7          	jalr	516(ra) # 80000c54 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a58:	409c                	lw	a5,0(s1)
    80004a5a:	ef91                	bnez	a5,80004a76 <holdingsleep+0x3a>
    80004a5c:	4481                	li	s1,0
  release(&lk->lk);
    80004a5e:	854a                	mv	a0,s2
    80004a60:	ffffc097          	auipc	ra,0xffffc
    80004a64:	2a4080e7          	jalr	676(ra) # 80000d04 <release>
  return r;
}
    80004a68:	8526                	mv	a0,s1
    80004a6a:	70a2                	ld	ra,40(sp)
    80004a6c:	7402                	ld	s0,32(sp)
    80004a6e:	64e2                	ld	s1,24(sp)
    80004a70:	6942                	ld	s2,16(sp)
    80004a72:	6145                	addi	sp,sp,48
    80004a74:	8082                	ret
    80004a76:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a78:	0284a983          	lw	s3,40(s1)
    80004a7c:	ffffd097          	auipc	ra,0xffffd
    80004a80:	00a080e7          	jalr	10(ra) # 80001a86 <myproc>
    80004a84:	5904                	lw	s1,48(a0)
    80004a86:	413484b3          	sub	s1,s1,s3
    80004a8a:	0014b493          	seqz	s1,s1
    80004a8e:	69a2                	ld	s3,8(sp)
    80004a90:	b7f9                	j	80004a5e <holdingsleep+0x22>

0000000080004a92 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004a92:	1141                	addi	sp,sp,-16
    80004a94:	e406                	sd	ra,8(sp)
    80004a96:	e022                	sd	s0,0(sp)
    80004a98:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004a9a:	00004597          	auipc	a1,0x4
    80004a9e:	c0658593          	addi	a1,a1,-1018 # 800086a0 <etext+0x6a0>
    80004aa2:	00021517          	auipc	a0,0x21
    80004aa6:	11650513          	addi	a0,a0,278 # 80025bb8 <ftable>
    80004aaa:	ffffc097          	auipc	ra,0xffffc
    80004aae:	110080e7          	jalr	272(ra) # 80000bba <initlock>
}
    80004ab2:	60a2                	ld	ra,8(sp)
    80004ab4:	6402                	ld	s0,0(sp)
    80004ab6:	0141                	addi	sp,sp,16
    80004ab8:	8082                	ret

0000000080004aba <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004aba:	1101                	addi	sp,sp,-32
    80004abc:	ec06                	sd	ra,24(sp)
    80004abe:	e822                	sd	s0,16(sp)
    80004ac0:	e426                	sd	s1,8(sp)
    80004ac2:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004ac4:	00021517          	auipc	a0,0x21
    80004ac8:	0f450513          	addi	a0,a0,244 # 80025bb8 <ftable>
    80004acc:	ffffc097          	auipc	ra,0xffffc
    80004ad0:	188080e7          	jalr	392(ra) # 80000c54 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004ad4:	00021497          	auipc	s1,0x21
    80004ad8:	0fc48493          	addi	s1,s1,252 # 80025bd0 <ftable+0x18>
    80004adc:	00022717          	auipc	a4,0x22
    80004ae0:	09470713          	addi	a4,a4,148 # 80026b70 <ftable+0xfb8>
    if(f->ref == 0){
    80004ae4:	40dc                	lw	a5,4(s1)
    80004ae6:	cf99                	beqz	a5,80004b04 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004ae8:	02848493          	addi	s1,s1,40
    80004aec:	fee49ce3          	bne	s1,a4,80004ae4 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004af0:	00021517          	auipc	a0,0x21
    80004af4:	0c850513          	addi	a0,a0,200 # 80025bb8 <ftable>
    80004af8:	ffffc097          	auipc	ra,0xffffc
    80004afc:	20c080e7          	jalr	524(ra) # 80000d04 <release>
  return 0;
    80004b00:	4481                	li	s1,0
    80004b02:	a819                	j	80004b18 <filealloc+0x5e>
      f->ref = 1;
    80004b04:	4785                	li	a5,1
    80004b06:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004b08:	00021517          	auipc	a0,0x21
    80004b0c:	0b050513          	addi	a0,a0,176 # 80025bb8 <ftable>
    80004b10:	ffffc097          	auipc	ra,0xffffc
    80004b14:	1f4080e7          	jalr	500(ra) # 80000d04 <release>
}
    80004b18:	8526                	mv	a0,s1
    80004b1a:	60e2                	ld	ra,24(sp)
    80004b1c:	6442                	ld	s0,16(sp)
    80004b1e:	64a2                	ld	s1,8(sp)
    80004b20:	6105                	addi	sp,sp,32
    80004b22:	8082                	ret

0000000080004b24 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004b24:	1101                	addi	sp,sp,-32
    80004b26:	ec06                	sd	ra,24(sp)
    80004b28:	e822                	sd	s0,16(sp)
    80004b2a:	e426                	sd	s1,8(sp)
    80004b2c:	1000                	addi	s0,sp,32
    80004b2e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004b30:	00021517          	auipc	a0,0x21
    80004b34:	08850513          	addi	a0,a0,136 # 80025bb8 <ftable>
    80004b38:	ffffc097          	auipc	ra,0xffffc
    80004b3c:	11c080e7          	jalr	284(ra) # 80000c54 <acquire>
  if(f->ref < 1)
    80004b40:	40dc                	lw	a5,4(s1)
    80004b42:	02f05263          	blez	a5,80004b66 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004b46:	2785                	addiw	a5,a5,1
    80004b48:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004b4a:	00021517          	auipc	a0,0x21
    80004b4e:	06e50513          	addi	a0,a0,110 # 80025bb8 <ftable>
    80004b52:	ffffc097          	auipc	ra,0xffffc
    80004b56:	1b2080e7          	jalr	434(ra) # 80000d04 <release>
  return f;
}
    80004b5a:	8526                	mv	a0,s1
    80004b5c:	60e2                	ld	ra,24(sp)
    80004b5e:	6442                	ld	s0,16(sp)
    80004b60:	64a2                	ld	s1,8(sp)
    80004b62:	6105                	addi	sp,sp,32
    80004b64:	8082                	ret
    panic("filedup");
    80004b66:	00004517          	auipc	a0,0x4
    80004b6a:	b4250513          	addi	a0,a0,-1214 # 800086a8 <etext+0x6a8>
    80004b6e:	ffffc097          	auipc	ra,0xffffc
    80004b72:	9e8080e7          	jalr	-1560(ra) # 80000556 <panic>

0000000080004b76 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004b76:	7139                	addi	sp,sp,-64
    80004b78:	fc06                	sd	ra,56(sp)
    80004b7a:	f822                	sd	s0,48(sp)
    80004b7c:	f426                	sd	s1,40(sp)
    80004b7e:	0080                	addi	s0,sp,64
    80004b80:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004b82:	00021517          	auipc	a0,0x21
    80004b86:	03650513          	addi	a0,a0,54 # 80025bb8 <ftable>
    80004b8a:	ffffc097          	auipc	ra,0xffffc
    80004b8e:	0ca080e7          	jalr	202(ra) # 80000c54 <acquire>
  if(f->ref < 1)
    80004b92:	40dc                	lw	a5,4(s1)
    80004b94:	04f05c63          	blez	a5,80004bec <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    80004b98:	37fd                	addiw	a5,a5,-1
    80004b9a:	c0dc                	sw	a5,4(s1)
    80004b9c:	06f04463          	bgtz	a5,80004c04 <fileclose+0x8e>
    80004ba0:	f04a                	sd	s2,32(sp)
    80004ba2:	ec4e                	sd	s3,24(sp)
    80004ba4:	e852                	sd	s4,16(sp)
    80004ba6:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004ba8:	0004a903          	lw	s2,0(s1)
    80004bac:	0094c783          	lbu	a5,9(s1)
    80004bb0:	89be                	mv	s3,a5
    80004bb2:	689c                	ld	a5,16(s1)
    80004bb4:	8a3e                	mv	s4,a5
    80004bb6:	6c9c                	ld	a5,24(s1)
    80004bb8:	8abe                	mv	s5,a5
  f->ref = 0;
    80004bba:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004bbe:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004bc2:	00021517          	auipc	a0,0x21
    80004bc6:	ff650513          	addi	a0,a0,-10 # 80025bb8 <ftable>
    80004bca:	ffffc097          	auipc	ra,0xffffc
    80004bce:	13a080e7          	jalr	314(ra) # 80000d04 <release>

  if(ff.type == FD_PIPE){
    80004bd2:	4785                	li	a5,1
    80004bd4:	04f90563          	beq	s2,a5,80004c1e <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004bd8:	ffe9079b          	addiw	a5,s2,-2
    80004bdc:	4705                	li	a4,1
    80004bde:	04f77b63          	bgeu	a4,a5,80004c34 <fileclose+0xbe>
    80004be2:	7902                	ld	s2,32(sp)
    80004be4:	69e2                	ld	s3,24(sp)
    80004be6:	6a42                	ld	s4,16(sp)
    80004be8:	6aa2                	ld	s5,8(sp)
    80004bea:	a02d                	j	80004c14 <fileclose+0x9e>
    80004bec:	f04a                	sd	s2,32(sp)
    80004bee:	ec4e                	sd	s3,24(sp)
    80004bf0:	e852                	sd	s4,16(sp)
    80004bf2:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004bf4:	00004517          	auipc	a0,0x4
    80004bf8:	abc50513          	addi	a0,a0,-1348 # 800086b0 <etext+0x6b0>
    80004bfc:	ffffc097          	auipc	ra,0xffffc
    80004c00:	95a080e7          	jalr	-1702(ra) # 80000556 <panic>
    release(&ftable.lock);
    80004c04:	00021517          	auipc	a0,0x21
    80004c08:	fb450513          	addi	a0,a0,-76 # 80025bb8 <ftable>
    80004c0c:	ffffc097          	auipc	ra,0xffffc
    80004c10:	0f8080e7          	jalr	248(ra) # 80000d04 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004c14:	70e2                	ld	ra,56(sp)
    80004c16:	7442                	ld	s0,48(sp)
    80004c18:	74a2                	ld	s1,40(sp)
    80004c1a:	6121                	addi	sp,sp,64
    80004c1c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004c1e:	85ce                	mv	a1,s3
    80004c20:	8552                	mv	a0,s4
    80004c22:	00000097          	auipc	ra,0x0
    80004c26:	3b4080e7          	jalr	948(ra) # 80004fd6 <pipeclose>
    80004c2a:	7902                	ld	s2,32(sp)
    80004c2c:	69e2                	ld	s3,24(sp)
    80004c2e:	6a42                	ld	s4,16(sp)
    80004c30:	6aa2                	ld	s5,8(sp)
    80004c32:	b7cd                	j	80004c14 <fileclose+0x9e>
    begin_op();
    80004c34:	00000097          	auipc	ra,0x0
    80004c38:	a60080e7          	jalr	-1440(ra) # 80004694 <begin_op>
    iput(ff.ip);
    80004c3c:	8556                	mv	a0,s5
    80004c3e:	fffff097          	auipc	ra,0xfffff
    80004c42:	21c080e7          	jalr	540(ra) # 80003e5a <iput>
    end_op();
    80004c46:	00000097          	auipc	ra,0x0
    80004c4a:	ace080e7          	jalr	-1330(ra) # 80004714 <end_op>
    80004c4e:	7902                	ld	s2,32(sp)
    80004c50:	69e2                	ld	s3,24(sp)
    80004c52:	6a42                	ld	s4,16(sp)
    80004c54:	6aa2                	ld	s5,8(sp)
    80004c56:	bf7d                	j	80004c14 <fileclose+0x9e>

0000000080004c58 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004c58:	715d                	addi	sp,sp,-80
    80004c5a:	e486                	sd	ra,72(sp)
    80004c5c:	e0a2                	sd	s0,64(sp)
    80004c5e:	fc26                	sd	s1,56(sp)
    80004c60:	f052                	sd	s4,32(sp)
    80004c62:	0880                	addi	s0,sp,80
    80004c64:	84aa                	mv	s1,a0
    80004c66:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004c68:	ffffd097          	auipc	ra,0xffffd
    80004c6c:	e1e080e7          	jalr	-482(ra) # 80001a86 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004c70:	409c                	lw	a5,0(s1)
    80004c72:	37f9                	addiw	a5,a5,-2
    80004c74:	4705                	li	a4,1
    80004c76:	04f76a63          	bltu	a4,a5,80004cca <filestat+0x72>
    80004c7a:	f84a                	sd	s2,48(sp)
    80004c7c:	f44e                	sd	s3,40(sp)
    80004c7e:	89aa                	mv	s3,a0
    ilock(f->ip);
    80004c80:	6c88                	ld	a0,24(s1)
    80004c82:	fffff097          	auipc	ra,0xfffff
    80004c86:	01a080e7          	jalr	26(ra) # 80003c9c <ilock>
    stati(f->ip, &st);
    80004c8a:	fb840913          	addi	s2,s0,-72
    80004c8e:	85ca                	mv	a1,s2
    80004c90:	6c88                	ld	a0,24(s1)
    80004c92:	fffff097          	auipc	ra,0xfffff
    80004c96:	29a080e7          	jalr	666(ra) # 80003f2c <stati>
    iunlock(f->ip);
    80004c9a:	6c88                	ld	a0,24(s1)
    80004c9c:	fffff097          	auipc	ra,0xfffff
    80004ca0:	0c6080e7          	jalr	198(ra) # 80003d62 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004ca4:	46e1                	li	a3,24
    80004ca6:	864a                	mv	a2,s2
    80004ca8:	85d2                	mv	a1,s4
    80004caa:	0509b503          	ld	a0,80(s3)
    80004cae:	ffffd097          	auipc	ra,0xffffd
    80004cb2:	a5c080e7          	jalr	-1444(ra) # 8000170a <copyout>
    80004cb6:	41f5551b          	sraiw	a0,a0,0x1f
    80004cba:	7942                	ld	s2,48(sp)
    80004cbc:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004cbe:	60a6                	ld	ra,72(sp)
    80004cc0:	6406                	ld	s0,64(sp)
    80004cc2:	74e2                	ld	s1,56(sp)
    80004cc4:	7a02                	ld	s4,32(sp)
    80004cc6:	6161                	addi	sp,sp,80
    80004cc8:	8082                	ret
  return -1;
    80004cca:	557d                	li	a0,-1
    80004ccc:	bfcd                	j	80004cbe <filestat+0x66>

0000000080004cce <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004cce:	7179                	addi	sp,sp,-48
    80004cd0:	f406                	sd	ra,40(sp)
    80004cd2:	f022                	sd	s0,32(sp)
    80004cd4:	e84a                	sd	s2,16(sp)
    80004cd6:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004cd8:	00854783          	lbu	a5,8(a0)
    80004cdc:	cbc5                	beqz	a5,80004d8c <fileread+0xbe>
    80004cde:	ec26                	sd	s1,24(sp)
    80004ce0:	e44e                	sd	s3,8(sp)
    80004ce2:	84aa                	mv	s1,a0
    80004ce4:	892e                	mv	s2,a1
    80004ce6:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    80004ce8:	411c                	lw	a5,0(a0)
    80004cea:	4705                	li	a4,1
    80004cec:	04e78963          	beq	a5,a4,80004d3e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004cf0:	470d                	li	a4,3
    80004cf2:	04e78f63          	beq	a5,a4,80004d50 <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004cf6:	4709                	li	a4,2
    80004cf8:	08e79263          	bne	a5,a4,80004d7c <fileread+0xae>
    ilock(f->ip);
    80004cfc:	6d08                	ld	a0,24(a0)
    80004cfe:	fffff097          	auipc	ra,0xfffff
    80004d02:	f9e080e7          	jalr	-98(ra) # 80003c9c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004d06:	874e                	mv	a4,s3
    80004d08:	5094                	lw	a3,32(s1)
    80004d0a:	864a                	mv	a2,s2
    80004d0c:	4585                	li	a1,1
    80004d0e:	6c88                	ld	a0,24(s1)
    80004d10:	fffff097          	auipc	ra,0xfffff
    80004d14:	24a080e7          	jalr	586(ra) # 80003f5a <readi>
    80004d18:	892a                	mv	s2,a0
    80004d1a:	00a05563          	blez	a0,80004d24 <fileread+0x56>
      f->off += r;
    80004d1e:	509c                	lw	a5,32(s1)
    80004d20:	9fa9                	addw	a5,a5,a0
    80004d22:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004d24:	6c88                	ld	a0,24(s1)
    80004d26:	fffff097          	auipc	ra,0xfffff
    80004d2a:	03c080e7          	jalr	60(ra) # 80003d62 <iunlock>
    80004d2e:	64e2                	ld	s1,24(sp)
    80004d30:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004d32:	854a                	mv	a0,s2
    80004d34:	70a2                	ld	ra,40(sp)
    80004d36:	7402                	ld	s0,32(sp)
    80004d38:	6942                	ld	s2,16(sp)
    80004d3a:	6145                	addi	sp,sp,48
    80004d3c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004d3e:	6908                	ld	a0,16(a0)
    80004d40:	00000097          	auipc	ra,0x0
    80004d44:	422080e7          	jalr	1058(ra) # 80005162 <piperead>
    80004d48:	892a                	mv	s2,a0
    80004d4a:	64e2                	ld	s1,24(sp)
    80004d4c:	69a2                	ld	s3,8(sp)
    80004d4e:	b7d5                	j	80004d32 <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004d50:	02451783          	lh	a5,36(a0)
    80004d54:	03079693          	slli	a3,a5,0x30
    80004d58:	92c1                	srli	a3,a3,0x30
    80004d5a:	4725                	li	a4,9
    80004d5c:	02d76b63          	bltu	a4,a3,80004d92 <fileread+0xc4>
    80004d60:	0792                	slli	a5,a5,0x4
    80004d62:	00021717          	auipc	a4,0x21
    80004d66:	db670713          	addi	a4,a4,-586 # 80025b18 <devsw>
    80004d6a:	97ba                	add	a5,a5,a4
    80004d6c:	639c                	ld	a5,0(a5)
    80004d6e:	c79d                	beqz	a5,80004d9c <fileread+0xce>
    r = devsw[f->major].read(1, addr, n);
    80004d70:	4505                	li	a0,1
    80004d72:	9782                	jalr	a5
    80004d74:	892a                	mv	s2,a0
    80004d76:	64e2                	ld	s1,24(sp)
    80004d78:	69a2                	ld	s3,8(sp)
    80004d7a:	bf65                	j	80004d32 <fileread+0x64>
    panic("fileread");
    80004d7c:	00004517          	auipc	a0,0x4
    80004d80:	94450513          	addi	a0,a0,-1724 # 800086c0 <etext+0x6c0>
    80004d84:	ffffb097          	auipc	ra,0xffffb
    80004d88:	7d2080e7          	jalr	2002(ra) # 80000556 <panic>
    return -1;
    80004d8c:	57fd                	li	a5,-1
    80004d8e:	893e                	mv	s2,a5
    80004d90:	b74d                	j	80004d32 <fileread+0x64>
      return -1;
    80004d92:	57fd                	li	a5,-1
    80004d94:	893e                	mv	s2,a5
    80004d96:	64e2                	ld	s1,24(sp)
    80004d98:	69a2                	ld	s3,8(sp)
    80004d9a:	bf61                	j	80004d32 <fileread+0x64>
    80004d9c:	57fd                	li	a5,-1
    80004d9e:	893e                	mv	s2,a5
    80004da0:	64e2                	ld	s1,24(sp)
    80004da2:	69a2                	ld	s3,8(sp)
    80004da4:	b779                	j	80004d32 <fileread+0x64>

0000000080004da6 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004da6:	00954783          	lbu	a5,9(a0)
    80004daa:	12078d63          	beqz	a5,80004ee4 <filewrite+0x13e>
{
    80004dae:	711d                	addi	sp,sp,-96
    80004db0:	ec86                	sd	ra,88(sp)
    80004db2:	e8a2                	sd	s0,80(sp)
    80004db4:	e0ca                	sd	s2,64(sp)
    80004db6:	f456                	sd	s5,40(sp)
    80004db8:	f05a                	sd	s6,32(sp)
    80004dba:	1080                	addi	s0,sp,96
    80004dbc:	892a                	mv	s2,a0
    80004dbe:	8b2e                	mv	s6,a1
    80004dc0:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    80004dc2:	411c                	lw	a5,0(a0)
    80004dc4:	4705                	li	a4,1
    80004dc6:	02e78a63          	beq	a5,a4,80004dfa <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004dca:	470d                	li	a4,3
    80004dcc:	02e78d63          	beq	a5,a4,80004e06 <filewrite+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004dd0:	4709                	li	a4,2
    80004dd2:	0ee79b63          	bne	a5,a4,80004ec8 <filewrite+0x122>
    80004dd6:	f852                	sd	s4,48(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004dd8:	0cc05663          	blez	a2,80004ea4 <filewrite+0xfe>
    80004ddc:	e4a6                	sd	s1,72(sp)
    80004dde:	fc4e                	sd	s3,56(sp)
    80004de0:	ec5e                	sd	s7,24(sp)
    80004de2:	e862                	sd	s8,16(sp)
    80004de4:	e466                	sd	s9,8(sp)
    int i = 0;
    80004de6:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80004de8:	6b85                	lui	s7,0x1
    80004dea:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004dee:	6785                	lui	a5,0x1
    80004df0:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80004df4:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004df6:	4c05                	li	s8,1
    80004df8:	a849                	j	80004e8a <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004dfa:	6908                	ld	a0,16(a0)
    80004dfc:	00000097          	auipc	ra,0x0
    80004e00:	250080e7          	jalr	592(ra) # 8000504c <pipewrite>
    80004e04:	a85d                	j	80004eba <filewrite+0x114>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004e06:	02451783          	lh	a5,36(a0)
    80004e0a:	03079693          	slli	a3,a5,0x30
    80004e0e:	92c1                	srli	a3,a3,0x30
    80004e10:	4725                	li	a4,9
    80004e12:	0cd76b63          	bltu	a4,a3,80004ee8 <filewrite+0x142>
    80004e16:	0792                	slli	a5,a5,0x4
    80004e18:	00021717          	auipc	a4,0x21
    80004e1c:	d0070713          	addi	a4,a4,-768 # 80025b18 <devsw>
    80004e20:	97ba                	add	a5,a5,a4
    80004e22:	679c                	ld	a5,8(a5)
    80004e24:	c7e1                	beqz	a5,80004eec <filewrite+0x146>
    ret = devsw[f->major].write(1, addr, n);
    80004e26:	4505                	li	a0,1
    80004e28:	9782                	jalr	a5
    80004e2a:	a841                	j	80004eba <filewrite+0x114>
      if(n1 > max)
    80004e2c:	2981                	sext.w	s3,s3
      begin_op();
    80004e2e:	00000097          	auipc	ra,0x0
    80004e32:	866080e7          	jalr	-1946(ra) # 80004694 <begin_op>
      ilock(f->ip);
    80004e36:	01893503          	ld	a0,24(s2)
    80004e3a:	fffff097          	auipc	ra,0xfffff
    80004e3e:	e62080e7          	jalr	-414(ra) # 80003c9c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004e42:	874e                	mv	a4,s3
    80004e44:	02092683          	lw	a3,32(s2)
    80004e48:	016a0633          	add	a2,s4,s6
    80004e4c:	85e2                	mv	a1,s8
    80004e4e:	01893503          	ld	a0,24(s2)
    80004e52:	fffff097          	auipc	ra,0xfffff
    80004e56:	202080e7          	jalr	514(ra) # 80004054 <writei>
    80004e5a:	84aa                	mv	s1,a0
    80004e5c:	00a05763          	blez	a0,80004e6a <filewrite+0xc4>
        f->off += r;
    80004e60:	02092783          	lw	a5,32(s2)
    80004e64:	9fa9                	addw	a5,a5,a0
    80004e66:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004e6a:	01893503          	ld	a0,24(s2)
    80004e6e:	fffff097          	auipc	ra,0xfffff
    80004e72:	ef4080e7          	jalr	-268(ra) # 80003d62 <iunlock>
      end_op();
    80004e76:	00000097          	auipc	ra,0x0
    80004e7a:	89e080e7          	jalr	-1890(ra) # 80004714 <end_op>

      if(r != n1){
    80004e7e:	02999563          	bne	s3,s1,80004ea8 <filewrite+0x102>
        // error from writei
        break;
      }
      i += r;
    80004e82:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    80004e86:	015a5963          	bge	s4,s5,80004e98 <filewrite+0xf2>
      int n1 = n - i;
    80004e8a:	414a87bb          	subw	a5,s5,s4
    80004e8e:	89be                	mv	s3,a5
      if(n1 > max)
    80004e90:	f8fbdee3          	bge	s7,a5,80004e2c <filewrite+0x86>
    80004e94:	89e6                	mv	s3,s9
    80004e96:	bf59                	j	80004e2c <filewrite+0x86>
    80004e98:	64a6                	ld	s1,72(sp)
    80004e9a:	79e2                	ld	s3,56(sp)
    80004e9c:	6be2                	ld	s7,24(sp)
    80004e9e:	6c42                	ld	s8,16(sp)
    80004ea0:	6ca2                	ld	s9,8(sp)
    80004ea2:	a801                	j	80004eb2 <filewrite+0x10c>
    int i = 0;
    80004ea4:	4a01                	li	s4,0
    80004ea6:	a031                	j	80004eb2 <filewrite+0x10c>
    80004ea8:	64a6                	ld	s1,72(sp)
    80004eaa:	79e2                	ld	s3,56(sp)
    80004eac:	6be2                	ld	s7,24(sp)
    80004eae:	6c42                	ld	s8,16(sp)
    80004eb0:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004eb2:	034a9f63          	bne	s5,s4,80004ef0 <filewrite+0x14a>
    80004eb6:	8556                	mv	a0,s5
    80004eb8:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004eba:	60e6                	ld	ra,88(sp)
    80004ebc:	6446                	ld	s0,80(sp)
    80004ebe:	6906                	ld	s2,64(sp)
    80004ec0:	7aa2                	ld	s5,40(sp)
    80004ec2:	7b02                	ld	s6,32(sp)
    80004ec4:	6125                	addi	sp,sp,96
    80004ec6:	8082                	ret
    80004ec8:	e4a6                	sd	s1,72(sp)
    80004eca:	fc4e                	sd	s3,56(sp)
    80004ecc:	f852                	sd	s4,48(sp)
    80004ece:	ec5e                	sd	s7,24(sp)
    80004ed0:	e862                	sd	s8,16(sp)
    80004ed2:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004ed4:	00003517          	auipc	a0,0x3
    80004ed8:	7fc50513          	addi	a0,a0,2044 # 800086d0 <etext+0x6d0>
    80004edc:	ffffb097          	auipc	ra,0xffffb
    80004ee0:	67a080e7          	jalr	1658(ra) # 80000556 <panic>
    return -1;
    80004ee4:	557d                	li	a0,-1
}
    80004ee6:	8082                	ret
      return -1;
    80004ee8:	557d                	li	a0,-1
    80004eea:	bfc1                	j	80004eba <filewrite+0x114>
    80004eec:	557d                	li	a0,-1
    80004eee:	b7f1                	j	80004eba <filewrite+0x114>
    ret = (i == n ? n : -1);
    80004ef0:	557d                	li	a0,-1
    80004ef2:	7a42                	ld	s4,48(sp)
    80004ef4:	b7d9                	j	80004eba <filewrite+0x114>

0000000080004ef6 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ef6:	7179                	addi	sp,sp,-48
    80004ef8:	f406                	sd	ra,40(sp)
    80004efa:	f022                	sd	s0,32(sp)
    80004efc:	ec26                	sd	s1,24(sp)
    80004efe:	e052                	sd	s4,0(sp)
    80004f00:	1800                	addi	s0,sp,48
    80004f02:	84aa                	mv	s1,a0
    80004f04:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004f06:	0005b023          	sd	zero,0(a1)
    80004f0a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004f0e:	00000097          	auipc	ra,0x0
    80004f12:	bac080e7          	jalr	-1108(ra) # 80004aba <filealloc>
    80004f16:	e088                	sd	a0,0(s1)
    80004f18:	cd49                	beqz	a0,80004fb2 <pipealloc+0xbc>
    80004f1a:	00000097          	auipc	ra,0x0
    80004f1e:	ba0080e7          	jalr	-1120(ra) # 80004aba <filealloc>
    80004f22:	00aa3023          	sd	a0,0(s4)
    80004f26:	c141                	beqz	a0,80004fa6 <pipealloc+0xb0>
    80004f28:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004f2a:	ffffc097          	auipc	ra,0xffffc
    80004f2e:	c26080e7          	jalr	-986(ra) # 80000b50 <kalloc>
    80004f32:	892a                	mv	s2,a0
    80004f34:	c13d                	beqz	a0,80004f9a <pipealloc+0xa4>
    80004f36:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004f38:	4985                	li	s3,1
    80004f3a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004f3e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004f42:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004f46:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004f4a:	00003597          	auipc	a1,0x3
    80004f4e:	52658593          	addi	a1,a1,1318 # 80008470 <etext+0x470>
    80004f52:	ffffc097          	auipc	ra,0xffffc
    80004f56:	c68080e7          	jalr	-920(ra) # 80000bba <initlock>
  (*f0)->type = FD_PIPE;
    80004f5a:	609c                	ld	a5,0(s1)
    80004f5c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004f60:	609c                	ld	a5,0(s1)
    80004f62:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004f66:	609c                	ld	a5,0(s1)
    80004f68:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004f6c:	609c                	ld	a5,0(s1)
    80004f6e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004f72:	000a3783          	ld	a5,0(s4)
    80004f76:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004f7a:	000a3783          	ld	a5,0(s4)
    80004f7e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004f82:	000a3783          	ld	a5,0(s4)
    80004f86:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004f8a:	000a3783          	ld	a5,0(s4)
    80004f8e:	0127b823          	sd	s2,16(a5)
  return 0;
    80004f92:	4501                	li	a0,0
    80004f94:	6942                	ld	s2,16(sp)
    80004f96:	69a2                	ld	s3,8(sp)
    80004f98:	a03d                	j	80004fc6 <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004f9a:	6088                	ld	a0,0(s1)
    80004f9c:	c119                	beqz	a0,80004fa2 <pipealloc+0xac>
    80004f9e:	6942                	ld	s2,16(sp)
    80004fa0:	a029                	j	80004faa <pipealloc+0xb4>
    80004fa2:	6942                	ld	s2,16(sp)
    80004fa4:	a039                	j	80004fb2 <pipealloc+0xbc>
    80004fa6:	6088                	ld	a0,0(s1)
    80004fa8:	c50d                	beqz	a0,80004fd2 <pipealloc+0xdc>
    fileclose(*f0);
    80004faa:	00000097          	auipc	ra,0x0
    80004fae:	bcc080e7          	jalr	-1076(ra) # 80004b76 <fileclose>
  if(*f1)
    80004fb2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004fb6:	557d                	li	a0,-1
  if(*f1)
    80004fb8:	c799                	beqz	a5,80004fc6 <pipealloc+0xd0>
    fileclose(*f1);
    80004fba:	853e                	mv	a0,a5
    80004fbc:	00000097          	auipc	ra,0x0
    80004fc0:	bba080e7          	jalr	-1094(ra) # 80004b76 <fileclose>
  return -1;
    80004fc4:	557d                	li	a0,-1
}
    80004fc6:	70a2                	ld	ra,40(sp)
    80004fc8:	7402                	ld	s0,32(sp)
    80004fca:	64e2                	ld	s1,24(sp)
    80004fcc:	6a02                	ld	s4,0(sp)
    80004fce:	6145                	addi	sp,sp,48
    80004fd0:	8082                	ret
  return -1;
    80004fd2:	557d                	li	a0,-1
    80004fd4:	bfcd                	j	80004fc6 <pipealloc+0xd0>

0000000080004fd6 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004fd6:	1101                	addi	sp,sp,-32
    80004fd8:	ec06                	sd	ra,24(sp)
    80004fda:	e822                	sd	s0,16(sp)
    80004fdc:	e426                	sd	s1,8(sp)
    80004fde:	e04a                	sd	s2,0(sp)
    80004fe0:	1000                	addi	s0,sp,32
    80004fe2:	84aa                	mv	s1,a0
    80004fe4:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004fe6:	ffffc097          	auipc	ra,0xffffc
    80004fea:	c6e080e7          	jalr	-914(ra) # 80000c54 <acquire>
  if(writable){
    80004fee:	02090b63          	beqz	s2,80005024 <pipeclose+0x4e>
    pi->writeopen = 0;
    80004ff2:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004ff6:	21848513          	addi	a0,s1,536
    80004ffa:	ffffd097          	auipc	ra,0xffffd
    80004ffe:	448080e7          	jalr	1096(ra) # 80002442 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005002:	2204a783          	lw	a5,544(s1)
    80005006:	e781                	bnez	a5,8000500e <pipeclose+0x38>
    80005008:	2244a783          	lw	a5,548(s1)
    8000500c:	c78d                	beqz	a5,80005036 <pipeclose+0x60>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    8000500e:	8526                	mv	a0,s1
    80005010:	ffffc097          	auipc	ra,0xffffc
    80005014:	cf4080e7          	jalr	-780(ra) # 80000d04 <release>
}
    80005018:	60e2                	ld	ra,24(sp)
    8000501a:	6442                	ld	s0,16(sp)
    8000501c:	64a2                	ld	s1,8(sp)
    8000501e:	6902                	ld	s2,0(sp)
    80005020:	6105                	addi	sp,sp,32
    80005022:	8082                	ret
    pi->readopen = 0;
    80005024:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005028:	21c48513          	addi	a0,s1,540
    8000502c:	ffffd097          	auipc	ra,0xffffd
    80005030:	416080e7          	jalr	1046(ra) # 80002442 <wakeup>
    80005034:	b7f9                	j	80005002 <pipeclose+0x2c>
    release(&pi->lock);
    80005036:	8526                	mv	a0,s1
    80005038:	ffffc097          	auipc	ra,0xffffc
    8000503c:	ccc080e7          	jalr	-820(ra) # 80000d04 <release>
    kfree((char*)pi);
    80005040:	8526                	mv	a0,s1
    80005042:	ffffc097          	auipc	ra,0xffffc
    80005046:	a0a080e7          	jalr	-1526(ra) # 80000a4c <kfree>
    8000504a:	b7f9                	j	80005018 <pipeclose+0x42>

000000008000504c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000504c:	7159                	addi	sp,sp,-112
    8000504e:	f486                	sd	ra,104(sp)
    80005050:	f0a2                	sd	s0,96(sp)
    80005052:	eca6                	sd	s1,88(sp)
    80005054:	e8ca                	sd	s2,80(sp)
    80005056:	e4ce                	sd	s3,72(sp)
    80005058:	e0d2                	sd	s4,64(sp)
    8000505a:	fc56                	sd	s5,56(sp)
    8000505c:	1880                	addi	s0,sp,112
    8000505e:	84aa                	mv	s1,a0
    80005060:	8aae                	mv	s5,a1
    80005062:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005064:	ffffd097          	auipc	ra,0xffffd
    80005068:	a22080e7          	jalr	-1502(ra) # 80001a86 <myproc>
    8000506c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000506e:	8526                	mv	a0,s1
    80005070:	ffffc097          	auipc	ra,0xffffc
    80005074:	be4080e7          	jalr	-1052(ra) # 80000c54 <acquire>
  while(i < n){
    80005078:	0d405d63          	blez	s4,80005152 <pipewrite+0x106>
    8000507c:	f85a                	sd	s6,48(sp)
    8000507e:	f45e                	sd	s7,40(sp)
    80005080:	f062                	sd	s8,32(sp)
    80005082:	ec66                	sd	s9,24(sp)
    80005084:	e86a                	sd	s10,16(sp)
  int i = 0;
    80005086:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005088:	f9f40c13          	addi	s8,s0,-97
    8000508c:	4b85                	li	s7,1
    8000508e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005090:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005094:	21c48c93          	addi	s9,s1,540
    80005098:	a099                	j	800050de <pipewrite+0x92>
      release(&pi->lock);
    8000509a:	8526                	mv	a0,s1
    8000509c:	ffffc097          	auipc	ra,0xffffc
    800050a0:	c68080e7          	jalr	-920(ra) # 80000d04 <release>
      return -1;
    800050a4:	597d                	li	s2,-1
    800050a6:	7b42                	ld	s6,48(sp)
    800050a8:	7ba2                	ld	s7,40(sp)
    800050aa:	7c02                	ld	s8,32(sp)
    800050ac:	6ce2                	ld	s9,24(sp)
    800050ae:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800050b0:	854a                	mv	a0,s2
    800050b2:	70a6                	ld	ra,104(sp)
    800050b4:	7406                	ld	s0,96(sp)
    800050b6:	64e6                	ld	s1,88(sp)
    800050b8:	6946                	ld	s2,80(sp)
    800050ba:	69a6                	ld	s3,72(sp)
    800050bc:	6a06                	ld	s4,64(sp)
    800050be:	7ae2                	ld	s5,56(sp)
    800050c0:	6165                	addi	sp,sp,112
    800050c2:	8082                	ret
      wakeup(&pi->nread);
    800050c4:	856a                	mv	a0,s10
    800050c6:	ffffd097          	auipc	ra,0xffffd
    800050ca:	37c080e7          	jalr	892(ra) # 80002442 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800050ce:	85a6                	mv	a1,s1
    800050d0:	8566                	mv	a0,s9
    800050d2:	ffffd097          	auipc	ra,0xffffd
    800050d6:	1ea080e7          	jalr	490(ra) # 800022bc <sleep>
  while(i < n){
    800050da:	05495b63          	bge	s2,s4,80005130 <pipewrite+0xe4>
    if(pi->readopen == 0 || pr->killed){
    800050de:	2204a783          	lw	a5,544(s1)
    800050e2:	dfc5                	beqz	a5,8000509a <pipewrite+0x4e>
    800050e4:	0289a783          	lw	a5,40(s3)
    800050e8:	fbcd                	bnez	a5,8000509a <pipewrite+0x4e>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800050ea:	2184a783          	lw	a5,536(s1)
    800050ee:	21c4a703          	lw	a4,540(s1)
    800050f2:	2007879b          	addiw	a5,a5,512
    800050f6:	fcf707e3          	beq	a4,a5,800050c4 <pipewrite+0x78>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800050fa:	86de                	mv	a3,s7
    800050fc:	01590633          	add	a2,s2,s5
    80005100:	85e2                	mv	a1,s8
    80005102:	0509b503          	ld	a0,80(s3)
    80005106:	ffffc097          	auipc	ra,0xffffc
    8000510a:	690080e7          	jalr	1680(ra) # 80001796 <copyin>
    8000510e:	05650463          	beq	a0,s6,80005156 <pipewrite+0x10a>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005112:	21c4a783          	lw	a5,540(s1)
    80005116:	0017871b          	addiw	a4,a5,1
    8000511a:	20e4ae23          	sw	a4,540(s1)
    8000511e:	1ff7f793          	andi	a5,a5,511
    80005122:	97a6                	add	a5,a5,s1
    80005124:	f9f44703          	lbu	a4,-97(s0)
    80005128:	00e78c23          	sb	a4,24(a5)
      i++;
    8000512c:	2905                	addiw	s2,s2,1
    8000512e:	b775                	j	800050da <pipewrite+0x8e>
    80005130:	7b42                	ld	s6,48(sp)
    80005132:	7ba2                	ld	s7,40(sp)
    80005134:	7c02                	ld	s8,32(sp)
    80005136:	6ce2                	ld	s9,24(sp)
    80005138:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    8000513a:	21848513          	addi	a0,s1,536
    8000513e:	ffffd097          	auipc	ra,0xffffd
    80005142:	304080e7          	jalr	772(ra) # 80002442 <wakeup>
  release(&pi->lock);
    80005146:	8526                	mv	a0,s1
    80005148:	ffffc097          	auipc	ra,0xffffc
    8000514c:	bbc080e7          	jalr	-1092(ra) # 80000d04 <release>
  return i;
    80005150:	b785                	j	800050b0 <pipewrite+0x64>
  int i = 0;
    80005152:	4901                	li	s2,0
    80005154:	b7dd                	j	8000513a <pipewrite+0xee>
    80005156:	7b42                	ld	s6,48(sp)
    80005158:	7ba2                	ld	s7,40(sp)
    8000515a:	7c02                	ld	s8,32(sp)
    8000515c:	6ce2                	ld	s9,24(sp)
    8000515e:	6d42                	ld	s10,16(sp)
    80005160:	bfe9                	j	8000513a <pipewrite+0xee>

0000000080005162 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005162:	711d                	addi	sp,sp,-96
    80005164:	ec86                	sd	ra,88(sp)
    80005166:	e8a2                	sd	s0,80(sp)
    80005168:	e4a6                	sd	s1,72(sp)
    8000516a:	e0ca                	sd	s2,64(sp)
    8000516c:	fc4e                	sd	s3,56(sp)
    8000516e:	f852                	sd	s4,48(sp)
    80005170:	f456                	sd	s5,40(sp)
    80005172:	1080                	addi	s0,sp,96
    80005174:	84aa                	mv	s1,a0
    80005176:	892e                	mv	s2,a1
    80005178:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000517a:	ffffd097          	auipc	ra,0xffffd
    8000517e:	90c080e7          	jalr	-1780(ra) # 80001a86 <myproc>
    80005182:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005184:	8526                	mv	a0,s1
    80005186:	ffffc097          	auipc	ra,0xffffc
    8000518a:	ace080e7          	jalr	-1330(ra) # 80000c54 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000518e:	2184a703          	lw	a4,536(s1)
    80005192:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005196:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000519a:	02f71863          	bne	a4,a5,800051ca <piperead+0x68>
    8000519e:	2244a783          	lw	a5,548(s1)
    800051a2:	cf9d                	beqz	a5,800051e0 <piperead+0x7e>
    if(pr->killed){
    800051a4:	028a2783          	lw	a5,40(s4)
    800051a8:	e78d                	bnez	a5,800051d2 <piperead+0x70>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800051aa:	85a6                	mv	a1,s1
    800051ac:	854e                	mv	a0,s3
    800051ae:	ffffd097          	auipc	ra,0xffffd
    800051b2:	10e080e7          	jalr	270(ra) # 800022bc <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800051b6:	2184a703          	lw	a4,536(s1)
    800051ba:	21c4a783          	lw	a5,540(s1)
    800051be:	fef700e3          	beq	a4,a5,8000519e <piperead+0x3c>
    800051c2:	f05a                	sd	s6,32(sp)
    800051c4:	ec5e                	sd	s7,24(sp)
    800051c6:	e862                	sd	s8,16(sp)
    800051c8:	a839                	j	800051e6 <piperead+0x84>
    800051ca:	f05a                	sd	s6,32(sp)
    800051cc:	ec5e                	sd	s7,24(sp)
    800051ce:	e862                	sd	s8,16(sp)
    800051d0:	a819                	j	800051e6 <piperead+0x84>
      release(&pi->lock);
    800051d2:	8526                	mv	a0,s1
    800051d4:	ffffc097          	auipc	ra,0xffffc
    800051d8:	b30080e7          	jalr	-1232(ra) # 80000d04 <release>
      return -1;
    800051dc:	59fd                	li	s3,-1
    800051de:	a88d                	j	80005250 <piperead+0xee>
    800051e0:	f05a                	sd	s6,32(sp)
    800051e2:	ec5e                	sd	s7,24(sp)
    800051e4:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051e6:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800051e8:	faf40c13          	addi	s8,s0,-81
    800051ec:	4b85                	li	s7,1
    800051ee:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051f0:	05505263          	blez	s5,80005234 <piperead+0xd2>
    if(pi->nread == pi->nwrite)
    800051f4:	2184a783          	lw	a5,536(s1)
    800051f8:	21c4a703          	lw	a4,540(s1)
    800051fc:	02f70c63          	beq	a4,a5,80005234 <piperead+0xd2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005200:	0017871b          	addiw	a4,a5,1
    80005204:	20e4ac23          	sw	a4,536(s1)
    80005208:	1ff7f793          	andi	a5,a5,511
    8000520c:	97a6                	add	a5,a5,s1
    8000520e:	0187c783          	lbu	a5,24(a5)
    80005212:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005216:	86de                	mv	a3,s7
    80005218:	8662                	mv	a2,s8
    8000521a:	85ca                	mv	a1,s2
    8000521c:	050a3503          	ld	a0,80(s4)
    80005220:	ffffc097          	auipc	ra,0xffffc
    80005224:	4ea080e7          	jalr	1258(ra) # 8000170a <copyout>
    80005228:	01650663          	beq	a0,s6,80005234 <piperead+0xd2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000522c:	2985                	addiw	s3,s3,1
    8000522e:	0905                	addi	s2,s2,1
    80005230:	fd3a92e3          	bne	s5,s3,800051f4 <piperead+0x92>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005234:	21c48513          	addi	a0,s1,540
    80005238:	ffffd097          	auipc	ra,0xffffd
    8000523c:	20a080e7          	jalr	522(ra) # 80002442 <wakeup>
  release(&pi->lock);
    80005240:	8526                	mv	a0,s1
    80005242:	ffffc097          	auipc	ra,0xffffc
    80005246:	ac2080e7          	jalr	-1342(ra) # 80000d04 <release>
    8000524a:	7b02                	ld	s6,32(sp)
    8000524c:	6be2                	ld	s7,24(sp)
    8000524e:	6c42                	ld	s8,16(sp)
  return i;
}
    80005250:	854e                	mv	a0,s3
    80005252:	60e6                	ld	ra,88(sp)
    80005254:	6446                	ld	s0,80(sp)
    80005256:	64a6                	ld	s1,72(sp)
    80005258:	6906                	ld	s2,64(sp)
    8000525a:	79e2                	ld	s3,56(sp)
    8000525c:	7a42                	ld	s4,48(sp)
    8000525e:	7aa2                	ld	s5,40(sp)
    80005260:	6125                	addi	sp,sp,96
    80005262:	8082                	ret

0000000080005264 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005264:	de010113          	addi	sp,sp,-544
    80005268:	20113c23          	sd	ra,536(sp)
    8000526c:	20813823          	sd	s0,528(sp)
    80005270:	20913423          	sd	s1,520(sp)
    80005274:	21213023          	sd	s2,512(sp)
    80005278:	1400                	addi	s0,sp,544
    8000527a:	892a                	mv	s2,a0
    8000527c:	dea43823          	sd	a0,-528(s0)
    80005280:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005284:	ffffd097          	auipc	ra,0xffffd
    80005288:	802080e7          	jalr	-2046(ra) # 80001a86 <myproc>
    8000528c:	84aa                	mv	s1,a0

  begin_op();
    8000528e:	fffff097          	auipc	ra,0xfffff
    80005292:	406080e7          	jalr	1030(ra) # 80004694 <begin_op>

  if((ip = namei(path)) == 0){
    80005296:	854a                	mv	a0,s2
    80005298:	fffff097          	auipc	ra,0xfffff
    8000529c:	1f6080e7          	jalr	502(ra) # 8000448e <namei>
    800052a0:	c525                	beqz	a0,80005308 <exec+0xa4>
    800052a2:	fbd2                	sd	s4,496(sp)
    800052a4:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800052a6:	fffff097          	auipc	ra,0xfffff
    800052aa:	9f6080e7          	jalr	-1546(ra) # 80003c9c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800052ae:	04000713          	li	a4,64
    800052b2:	4681                	li	a3,0
    800052b4:	e5040613          	addi	a2,s0,-432
    800052b8:	4581                	li	a1,0
    800052ba:	8552                	mv	a0,s4
    800052bc:	fffff097          	auipc	ra,0xfffff
    800052c0:	c9e080e7          	jalr	-866(ra) # 80003f5a <readi>
    800052c4:	04000793          	li	a5,64
    800052c8:	00f51a63          	bne	a0,a5,800052dc <exec+0x78>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    800052cc:	e5042703          	lw	a4,-432(s0)
    800052d0:	464c47b7          	lui	a5,0x464c4
    800052d4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800052d8:	02f70e63          	beq	a4,a5,80005314 <exec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800052dc:	8552                	mv	a0,s4
    800052de:	fffff097          	auipc	ra,0xfffff
    800052e2:	c26080e7          	jalr	-986(ra) # 80003f04 <iunlockput>
    end_op();
    800052e6:	fffff097          	auipc	ra,0xfffff
    800052ea:	42e080e7          	jalr	1070(ra) # 80004714 <end_op>
  }
  return -1;
    800052ee:	557d                	li	a0,-1
    800052f0:	7a5e                	ld	s4,496(sp)
}
    800052f2:	21813083          	ld	ra,536(sp)
    800052f6:	21013403          	ld	s0,528(sp)
    800052fa:	20813483          	ld	s1,520(sp)
    800052fe:	20013903          	ld	s2,512(sp)
    80005302:	22010113          	addi	sp,sp,544
    80005306:	8082                	ret
    end_op();
    80005308:	fffff097          	auipc	ra,0xfffff
    8000530c:	40c080e7          	jalr	1036(ra) # 80004714 <end_op>
    return -1;
    80005310:	557d                	li	a0,-1
    80005312:	b7c5                	j	800052f2 <exec+0x8e>
    80005314:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80005316:	8526                	mv	a0,s1
    80005318:	ffffd097          	auipc	ra,0xffffd
    8000531c:	834080e7          	jalr	-1996(ra) # 80001b4c <proc_pagetable>
    80005320:	8b2a                	mv	s6,a0
    80005322:	2a050a63          	beqz	a0,800055d6 <exec+0x372>
    80005326:	ffce                	sd	s3,504(sp)
    80005328:	f7d6                	sd	s5,488(sp)
    8000532a:	efde                	sd	s7,472(sp)
    8000532c:	ebe2                	sd	s8,464(sp)
    8000532e:	e7e6                	sd	s9,456(sp)
    80005330:	e3ea                	sd	s10,448(sp)
    80005332:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005334:	e8845783          	lhu	a5,-376(s0)
    80005338:	cfed                	beqz	a5,80005432 <exec+0x1ce>
    8000533a:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000533e:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005340:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005342:	03800d93          	li	s11,56
    if((ph.vaddr % PGSIZE) != 0)
    80005346:	6c85                	lui	s9,0x1
    80005348:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000534c:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80005350:	6a85                	lui	s5,0x1
    80005352:	a0b5                	j	800053be <exec+0x15a>
      panic("loadseg: address should exist");
    80005354:	00003517          	auipc	a0,0x3
    80005358:	38c50513          	addi	a0,a0,908 # 800086e0 <etext+0x6e0>
    8000535c:	ffffb097          	auipc	ra,0xffffb
    80005360:	1fa080e7          	jalr	506(ra) # 80000556 <panic>
    if(sz - i < PGSIZE)
    80005364:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005366:	874a                	mv	a4,s2
    80005368:	009c06bb          	addw	a3,s8,s1
    8000536c:	4581                	li	a1,0
    8000536e:	8552                	mv	a0,s4
    80005370:	fffff097          	auipc	ra,0xfffff
    80005374:	bea080e7          	jalr	-1046(ra) # 80003f5a <readi>
    80005378:	26a91363          	bne	s2,a0,800055de <exec+0x37a>
  for(i = 0; i < sz; i += PGSIZE){
    8000537c:	009a84bb          	addw	s1,s5,s1
    80005380:	0334f463          	bgeu	s1,s3,800053a8 <exec+0x144>
    pa = walkaddr(pagetable, va + i);
    80005384:	02049593          	slli	a1,s1,0x20
    80005388:	9181                	srli	a1,a1,0x20
    8000538a:	95de                	add	a1,a1,s7
    8000538c:	855a                	mv	a0,s6
    8000538e:	ffffc097          	auipc	ra,0xffffc
    80005392:	d5c080e7          	jalr	-676(ra) # 800010ea <walkaddr>
    80005396:	862a                	mv	a2,a0
    if(pa == 0)
    80005398:	dd55                	beqz	a0,80005354 <exec+0xf0>
    if(sz - i < PGSIZE)
    8000539a:	409987bb          	subw	a5,s3,s1
    8000539e:	893e                	mv	s2,a5
    800053a0:	fcfcf2e3          	bgeu	s9,a5,80005364 <exec+0x100>
    800053a4:	8956                	mv	s2,s5
    800053a6:	bf7d                	j	80005364 <exec+0x100>
    sz = sz1;
    800053a8:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800053ac:	2d05                	addiw	s10,s10,1
    800053ae:	e0843783          	ld	a5,-504(s0)
    800053b2:	0387869b          	addiw	a3,a5,56
    800053b6:	e8845783          	lhu	a5,-376(s0)
    800053ba:	06fd5d63          	bge	s10,a5,80005434 <exec+0x1d0>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800053be:	e0d43423          	sd	a3,-504(s0)
    800053c2:	876e                	mv	a4,s11
    800053c4:	e1840613          	addi	a2,s0,-488
    800053c8:	4581                	li	a1,0
    800053ca:	8552                	mv	a0,s4
    800053cc:	fffff097          	auipc	ra,0xfffff
    800053d0:	b8e080e7          	jalr	-1138(ra) # 80003f5a <readi>
    800053d4:	21b51363          	bne	a0,s11,800055da <exec+0x376>
    if(ph.type != ELF_PROG_LOAD)
    800053d8:	e1842783          	lw	a5,-488(s0)
    800053dc:	4705                	li	a4,1
    800053de:	fce797e3          	bne	a5,a4,800053ac <exec+0x148>
    if(ph.memsz < ph.filesz)
    800053e2:	e4043603          	ld	a2,-448(s0)
    800053e6:	e3843783          	ld	a5,-456(s0)
    800053ea:	20f66a63          	bltu	a2,a5,800055fe <exec+0x39a>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800053ee:	e2843783          	ld	a5,-472(s0)
    800053f2:	963e                	add	a2,a2,a5
    800053f4:	20f66863          	bltu	a2,a5,80005604 <exec+0x3a0>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800053f8:	85a6                	mv	a1,s1
    800053fa:	855a                	mv	a0,s6
    800053fc:	ffffc097          	auipc	ra,0xffffc
    80005400:	0ac080e7          	jalr	172(ra) # 800014a8 <uvmalloc>
    80005404:	dea43c23          	sd	a0,-520(s0)
    80005408:	20050163          	beqz	a0,8000560a <exec+0x3a6>
    if((ph.vaddr % PGSIZE) != 0)
    8000540c:	e2843b83          	ld	s7,-472(s0)
    80005410:	de843783          	ld	a5,-536(s0)
    80005414:	00fbf7b3          	and	a5,s7,a5
    80005418:	1c079363          	bnez	a5,800055de <exec+0x37a>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000541c:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005420:	00098663          	beqz	s3,8000542c <exec+0x1c8>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005424:	e2042c03          	lw	s8,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005428:	4481                	li	s1,0
    8000542a:	bfa9                	j	80005384 <exec+0x120>
    sz = sz1;
    8000542c:	df843483          	ld	s1,-520(s0)
    80005430:	bfb5                	j	800053ac <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005432:	4481                	li	s1,0
  iunlockput(ip);
    80005434:	8552                	mv	a0,s4
    80005436:	fffff097          	auipc	ra,0xfffff
    8000543a:	ace080e7          	jalr	-1330(ra) # 80003f04 <iunlockput>
  end_op();
    8000543e:	fffff097          	auipc	ra,0xfffff
    80005442:	2d6080e7          	jalr	726(ra) # 80004714 <end_op>
  p = myproc();
    80005446:	ffffc097          	auipc	ra,0xffffc
    8000544a:	640080e7          	jalr	1600(ra) # 80001a86 <myproc>
    8000544e:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005450:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005454:	6985                	lui	s3,0x1
    80005456:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80005458:	99a6                	add	s3,s3,s1
    8000545a:	77fd                	lui	a5,0xfffff
    8000545c:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005460:	6609                	lui	a2,0x2
    80005462:	964e                	add	a2,a2,s3
    80005464:	85ce                	mv	a1,s3
    80005466:	855a                	mv	a0,s6
    80005468:	ffffc097          	auipc	ra,0xffffc
    8000546c:	040080e7          	jalr	64(ra) # 800014a8 <uvmalloc>
    80005470:	8a2a                	mv	s4,a0
    80005472:	e115                	bnez	a0,80005496 <exec+0x232>
    proc_freepagetable(pagetable, sz);
    80005474:	85ce                	mv	a1,s3
    80005476:	855a                	mv	a0,s6
    80005478:	ffffc097          	auipc	ra,0xffffc
    8000547c:	770080e7          	jalr	1904(ra) # 80001be8 <proc_freepagetable>
  return -1;
    80005480:	557d                	li	a0,-1
    80005482:	79fe                	ld	s3,504(sp)
    80005484:	7a5e                	ld	s4,496(sp)
    80005486:	7abe                	ld	s5,488(sp)
    80005488:	7b1e                	ld	s6,480(sp)
    8000548a:	6bfe                	ld	s7,472(sp)
    8000548c:	6c5e                	ld	s8,464(sp)
    8000548e:	6cbe                	ld	s9,456(sp)
    80005490:	6d1e                	ld	s10,448(sp)
    80005492:	7dfa                	ld	s11,440(sp)
    80005494:	bdb9                	j	800052f2 <exec+0x8e>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005496:	75f9                	lui	a1,0xffffe
    80005498:	95aa                	add	a1,a1,a0
    8000549a:	855a                	mv	a0,s6
    8000549c:	ffffc097          	auipc	ra,0xffffc
    800054a0:	23c080e7          	jalr	572(ra) # 800016d8 <uvmclear>
  stackbase = sp - PGSIZE;
    800054a4:	800a0b93          	addi	s7,s4,-2048
    800054a8:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    800054ac:	e0043783          	ld	a5,-512(s0)
    800054b0:	6388                	ld	a0,0(a5)
  sp = sz;
    800054b2:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    800054b4:	4481                	li	s1,0
    ustack[argc] = sp;
    800054b6:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    800054ba:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    800054be:	c135                	beqz	a0,80005522 <exec+0x2be>
    sp -= strlen(argv[argc]) + 1;
    800054c0:	ffffc097          	auipc	ra,0xffffc
    800054c4:	a1a080e7          	jalr	-1510(ra) # 80000eda <strlen>
    800054c8:	0015079b          	addiw	a5,a0,1
    800054cc:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800054d0:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800054d4:	13796e63          	bltu	s2,s7,80005610 <exec+0x3ac>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800054d8:	e0043d83          	ld	s11,-512(s0)
    800054dc:	000db983          	ld	s3,0(s11)
    800054e0:	854e                	mv	a0,s3
    800054e2:	ffffc097          	auipc	ra,0xffffc
    800054e6:	9f8080e7          	jalr	-1544(ra) # 80000eda <strlen>
    800054ea:	0015069b          	addiw	a3,a0,1
    800054ee:	864e                	mv	a2,s3
    800054f0:	85ca                	mv	a1,s2
    800054f2:	855a                	mv	a0,s6
    800054f4:	ffffc097          	auipc	ra,0xffffc
    800054f8:	216080e7          	jalr	534(ra) # 8000170a <copyout>
    800054fc:	10054c63          	bltz	a0,80005614 <exec+0x3b0>
    ustack[argc] = sp;
    80005500:	00349793          	slli	a5,s1,0x3
    80005504:	97e6                	add	a5,a5,s9
    80005506:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffd5000>
  for(argc = 0; argv[argc]; argc++) {
    8000550a:	0485                	addi	s1,s1,1
    8000550c:	008d8793          	addi	a5,s11,8
    80005510:	e0f43023          	sd	a5,-512(s0)
    80005514:	008db503          	ld	a0,8(s11)
    80005518:	c509                	beqz	a0,80005522 <exec+0x2be>
    if(argc >= MAXARG)
    8000551a:	fb8493e3          	bne	s1,s8,800054c0 <exec+0x25c>
  sz = sz1;
    8000551e:	89d2                	mv	s3,s4
    80005520:	bf91                	j	80005474 <exec+0x210>
  ustack[argc] = 0;
    80005522:	00349793          	slli	a5,s1,0x3
    80005526:	f9078793          	addi	a5,a5,-112
    8000552a:	97a2                	add	a5,a5,s0
    8000552c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005530:	00349693          	slli	a3,s1,0x3
    80005534:	06a1                	addi	a3,a3,8
    80005536:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000553a:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    8000553e:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80005540:	f3796ae3          	bltu	s2,s7,80005474 <exec+0x210>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005544:	e9040613          	addi	a2,s0,-368
    80005548:	85ca                	mv	a1,s2
    8000554a:	855a                	mv	a0,s6
    8000554c:	ffffc097          	auipc	ra,0xffffc
    80005550:	1be080e7          	jalr	446(ra) # 8000170a <copyout>
    80005554:	f20540e3          	bltz	a0,80005474 <exec+0x210>
  p->trapframe->a1 = sp;
    80005558:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    8000555c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005560:	df043783          	ld	a5,-528(s0)
    80005564:	0007c703          	lbu	a4,0(a5)
    80005568:	cf11                	beqz	a4,80005584 <exec+0x320>
    8000556a:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000556c:	02f00693          	li	a3,47
    80005570:	a029                	j	8000557a <exec+0x316>
  for(last=s=path; *s; s++)
    80005572:	0785                	addi	a5,a5,1
    80005574:	fff7c703          	lbu	a4,-1(a5)
    80005578:	c711                	beqz	a4,80005584 <exec+0x320>
    if(*s == '/')
    8000557a:	fed71ce3          	bne	a4,a3,80005572 <exec+0x30e>
      last = s+1;
    8000557e:	def43823          	sd	a5,-528(s0)
    80005582:	bfc5                	j	80005572 <exec+0x30e>
  safestrcpy(p->name, last, sizeof(p->name));
    80005584:	4641                	li	a2,16
    80005586:	df043583          	ld	a1,-528(s0)
    8000558a:	158a8513          	addi	a0,s5,344
    8000558e:	ffffc097          	auipc	ra,0xffffc
    80005592:	916080e7          	jalr	-1770(ra) # 80000ea4 <safestrcpy>
  oldpagetable = p->pagetable;
    80005596:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000559a:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    8000559e:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800055a2:	058ab783          	ld	a5,88(s5)
    800055a6:	e6843703          	ld	a4,-408(s0)
    800055aa:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800055ac:	058ab783          	ld	a5,88(s5)
    800055b0:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800055b4:	85ea                	mv	a1,s10
    800055b6:	ffffc097          	auipc	ra,0xffffc
    800055ba:	632080e7          	jalr	1586(ra) # 80001be8 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800055be:	0004851b          	sext.w	a0,s1
    800055c2:	79fe                	ld	s3,504(sp)
    800055c4:	7a5e                	ld	s4,496(sp)
    800055c6:	7abe                	ld	s5,488(sp)
    800055c8:	7b1e                	ld	s6,480(sp)
    800055ca:	6bfe                	ld	s7,472(sp)
    800055cc:	6c5e                	ld	s8,464(sp)
    800055ce:	6cbe                	ld	s9,456(sp)
    800055d0:	6d1e                	ld	s10,448(sp)
    800055d2:	7dfa                	ld	s11,440(sp)
    800055d4:	bb39                	j	800052f2 <exec+0x8e>
    800055d6:	7b1e                	ld	s6,480(sp)
    800055d8:	b311                	j	800052dc <exec+0x78>
    800055da:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    800055de:	df843583          	ld	a1,-520(s0)
    800055e2:	855a                	mv	a0,s6
    800055e4:	ffffc097          	auipc	ra,0xffffc
    800055e8:	604080e7          	jalr	1540(ra) # 80001be8 <proc_freepagetable>
  if(ip){
    800055ec:	79fe                	ld	s3,504(sp)
    800055ee:	7abe                	ld	s5,488(sp)
    800055f0:	7b1e                	ld	s6,480(sp)
    800055f2:	6bfe                	ld	s7,472(sp)
    800055f4:	6c5e                	ld	s8,464(sp)
    800055f6:	6cbe                	ld	s9,456(sp)
    800055f8:	6d1e                	ld	s10,448(sp)
    800055fa:	7dfa                	ld	s11,440(sp)
    800055fc:	b1c5                	j	800052dc <exec+0x78>
    800055fe:	de943c23          	sd	s1,-520(s0)
    80005602:	bff1                	j	800055de <exec+0x37a>
    80005604:	de943c23          	sd	s1,-520(s0)
    80005608:	bfd9                	j	800055de <exec+0x37a>
    8000560a:	de943c23          	sd	s1,-520(s0)
    8000560e:	bfc1                	j	800055de <exec+0x37a>
  sz = sz1;
    80005610:	89d2                	mv	s3,s4
    80005612:	b58d                	j	80005474 <exec+0x210>
    80005614:	89d2                	mv	s3,s4
    80005616:	bdb9                	j	80005474 <exec+0x210>

0000000080005618 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005618:	7179                	addi	sp,sp,-48
    8000561a:	f406                	sd	ra,40(sp)
    8000561c:	f022                	sd	s0,32(sp)
    8000561e:	ec26                	sd	s1,24(sp)
    80005620:	e84a                	sd	s2,16(sp)
    80005622:	1800                	addi	s0,sp,48
    80005624:	892e                	mv	s2,a1
    80005626:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005628:	fdc40593          	addi	a1,s0,-36
    8000562c:	ffffe097          	auipc	ra,0xffffe
    80005630:	8de080e7          	jalr	-1826(ra) # 80002f0a <argint>
    80005634:	04054163          	bltz	a0,80005676 <argfd+0x5e>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005638:	fdc42703          	lw	a4,-36(s0)
    8000563c:	47bd                	li	a5,15
    8000563e:	02e7ee63          	bltu	a5,a4,8000567a <argfd+0x62>
    80005642:	ffffc097          	auipc	ra,0xffffc
    80005646:	444080e7          	jalr	1092(ra) # 80001a86 <myproc>
    8000564a:	fdc42703          	lw	a4,-36(s0)
    8000564e:	00371793          	slli	a5,a4,0x3
    80005652:	0d078793          	addi	a5,a5,208
    80005656:	953e                	add	a0,a0,a5
    80005658:	611c                	ld	a5,0(a0)
    8000565a:	c395                	beqz	a5,8000567e <argfd+0x66>
    return -1;
  if(pfd)
    8000565c:	00090463          	beqz	s2,80005664 <argfd+0x4c>
    *pfd = fd;
    80005660:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005664:	4501                	li	a0,0
  if(pf)
    80005666:	c091                	beqz	s1,8000566a <argfd+0x52>
    *pf = f;
    80005668:	e09c                	sd	a5,0(s1)
}
    8000566a:	70a2                	ld	ra,40(sp)
    8000566c:	7402                	ld	s0,32(sp)
    8000566e:	64e2                	ld	s1,24(sp)
    80005670:	6942                	ld	s2,16(sp)
    80005672:	6145                	addi	sp,sp,48
    80005674:	8082                	ret
    return -1;
    80005676:	557d                	li	a0,-1
    80005678:	bfcd                	j	8000566a <argfd+0x52>
    return -1;
    8000567a:	557d                	li	a0,-1
    8000567c:	b7fd                	j	8000566a <argfd+0x52>
    8000567e:	557d                	li	a0,-1
    80005680:	b7ed                	j	8000566a <argfd+0x52>

0000000080005682 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005682:	1101                	addi	sp,sp,-32
    80005684:	ec06                	sd	ra,24(sp)
    80005686:	e822                	sd	s0,16(sp)
    80005688:	e426                	sd	s1,8(sp)
    8000568a:	1000                	addi	s0,sp,32
    8000568c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000568e:	ffffc097          	auipc	ra,0xffffc
    80005692:	3f8080e7          	jalr	1016(ra) # 80001a86 <myproc>
    80005696:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005698:	0d050793          	addi	a5,a0,208
    8000569c:	4501                	li	a0,0
    8000569e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800056a0:	6398                	ld	a4,0(a5)
    800056a2:	cb19                	beqz	a4,800056b8 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800056a4:	2505                	addiw	a0,a0,1
    800056a6:	07a1                	addi	a5,a5,8
    800056a8:	fed51ce3          	bne	a0,a3,800056a0 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800056ac:	557d                	li	a0,-1
}
    800056ae:	60e2                	ld	ra,24(sp)
    800056b0:	6442                	ld	s0,16(sp)
    800056b2:	64a2                	ld	s1,8(sp)
    800056b4:	6105                	addi	sp,sp,32
    800056b6:	8082                	ret
      p->ofile[fd] = f;
    800056b8:	00351793          	slli	a5,a0,0x3
    800056bc:	0d078793          	addi	a5,a5,208
    800056c0:	963e                	add	a2,a2,a5
    800056c2:	e204                	sd	s1,0(a2)
      return fd;
    800056c4:	b7ed                	j	800056ae <fdalloc+0x2c>

00000000800056c6 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800056c6:	715d                	addi	sp,sp,-80
    800056c8:	e486                	sd	ra,72(sp)
    800056ca:	e0a2                	sd	s0,64(sp)
    800056cc:	fc26                	sd	s1,56(sp)
    800056ce:	f84a                	sd	s2,48(sp)
    800056d0:	f44e                	sd	s3,40(sp)
    800056d2:	f052                	sd	s4,32(sp)
    800056d4:	ec56                	sd	s5,24(sp)
    800056d6:	0880                	addi	s0,sp,80
    800056d8:	89ae                	mv	s3,a1
    800056da:	8a32                	mv	s4,a2
    800056dc:	8ab6                	mv	s5,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800056de:	fb040593          	addi	a1,s0,-80
    800056e2:	fffff097          	auipc	ra,0xfffff
    800056e6:	dca080e7          	jalr	-566(ra) # 800044ac <nameiparent>
    800056ea:	892a                	mv	s2,a0
    800056ec:	12050d63          	beqz	a0,80005826 <create+0x160>
    return 0;

  ilock(dp);
    800056f0:	ffffe097          	auipc	ra,0xffffe
    800056f4:	5ac080e7          	jalr	1452(ra) # 80003c9c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800056f8:	4601                	li	a2,0
    800056fa:	fb040593          	addi	a1,s0,-80
    800056fe:	854a                	mv	a0,s2
    80005700:	fffff097          	auipc	ra,0xfffff
    80005704:	a8a080e7          	jalr	-1398(ra) # 8000418a <dirlookup>
    80005708:	84aa                	mv	s1,a0
    8000570a:	c539                	beqz	a0,80005758 <create+0x92>
    iunlockput(dp);
    8000570c:	854a                	mv	a0,s2
    8000570e:	ffffe097          	auipc	ra,0xffffe
    80005712:	7f6080e7          	jalr	2038(ra) # 80003f04 <iunlockput>
    ilock(ip);
    80005716:	8526                	mv	a0,s1
    80005718:	ffffe097          	auipc	ra,0xffffe
    8000571c:	584080e7          	jalr	1412(ra) # 80003c9c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005720:	4789                	li	a5,2
    80005722:	02f99463          	bne	s3,a5,8000574a <create+0x84>
    80005726:	0444d783          	lhu	a5,68(s1)
    8000572a:	37f9                	addiw	a5,a5,-2
    8000572c:	17c2                	slli	a5,a5,0x30
    8000572e:	93c1                	srli	a5,a5,0x30
    80005730:	4705                	li	a4,1
    80005732:	00f76c63          	bltu	a4,a5,8000574a <create+0x84>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005736:	8526                	mv	a0,s1
    80005738:	60a6                	ld	ra,72(sp)
    8000573a:	6406                	ld	s0,64(sp)
    8000573c:	74e2                	ld	s1,56(sp)
    8000573e:	7942                	ld	s2,48(sp)
    80005740:	79a2                	ld	s3,40(sp)
    80005742:	7a02                	ld	s4,32(sp)
    80005744:	6ae2                	ld	s5,24(sp)
    80005746:	6161                	addi	sp,sp,80
    80005748:	8082                	ret
    iunlockput(ip);
    8000574a:	8526                	mv	a0,s1
    8000574c:	ffffe097          	auipc	ra,0xffffe
    80005750:	7b8080e7          	jalr	1976(ra) # 80003f04 <iunlockput>
    return 0;
    80005754:	4481                	li	s1,0
    80005756:	b7c5                	j	80005736 <create+0x70>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005758:	85ce                	mv	a1,s3
    8000575a:	00092503          	lw	a0,0(s2)
    8000575e:	ffffe097          	auipc	ra,0xffffe
    80005762:	3aa080e7          	jalr	938(ra) # 80003b08 <ialloc>
    80005766:	84aa                	mv	s1,a0
    80005768:	c521                	beqz	a0,800057b0 <create+0xea>
  ilock(ip);
    8000576a:	ffffe097          	auipc	ra,0xffffe
    8000576e:	532080e7          	jalr	1330(ra) # 80003c9c <ilock>
  ip->major = major;
    80005772:	05449323          	sh	s4,70(s1)
  ip->minor = minor;
    80005776:	05549423          	sh	s5,72(s1)
  ip->nlink = 1;
    8000577a:	4785                	li	a5,1
    8000577c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005780:	8526                	mv	a0,s1
    80005782:	ffffe097          	auipc	ra,0xffffe
    80005786:	44e080e7          	jalr	1102(ra) # 80003bd0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000578a:	4705                	li	a4,1
    8000578c:	02e98a63          	beq	s3,a4,800057c0 <create+0xfa>
  if(dirlink(dp, name, ip->inum) < 0)
    80005790:	40d0                	lw	a2,4(s1)
    80005792:	fb040593          	addi	a1,s0,-80
    80005796:	854a                	mv	a0,s2
    80005798:	fffff097          	auipc	ra,0xfffff
    8000579c:	c20080e7          	jalr	-992(ra) # 800043b8 <dirlink>
    800057a0:	06054b63          	bltz	a0,80005816 <create+0x150>
  iunlockput(dp);
    800057a4:	854a                	mv	a0,s2
    800057a6:	ffffe097          	auipc	ra,0xffffe
    800057aa:	75e080e7          	jalr	1886(ra) # 80003f04 <iunlockput>
  return ip;
    800057ae:	b761                	j	80005736 <create+0x70>
    panic("create: ialloc");
    800057b0:	00003517          	auipc	a0,0x3
    800057b4:	f5050513          	addi	a0,a0,-176 # 80008700 <etext+0x700>
    800057b8:	ffffb097          	auipc	ra,0xffffb
    800057bc:	d9e080e7          	jalr	-610(ra) # 80000556 <panic>
    dp->nlink++;  // for ".."
    800057c0:	04a95783          	lhu	a5,74(s2)
    800057c4:	2785                	addiw	a5,a5,1
    800057c6:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800057ca:	854a                	mv	a0,s2
    800057cc:	ffffe097          	auipc	ra,0xffffe
    800057d0:	404080e7          	jalr	1028(ra) # 80003bd0 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800057d4:	40d0                	lw	a2,4(s1)
    800057d6:	00003597          	auipc	a1,0x3
    800057da:	f3a58593          	addi	a1,a1,-198 # 80008710 <etext+0x710>
    800057de:	8526                	mv	a0,s1
    800057e0:	fffff097          	auipc	ra,0xfffff
    800057e4:	bd8080e7          	jalr	-1064(ra) # 800043b8 <dirlink>
    800057e8:	00054f63          	bltz	a0,80005806 <create+0x140>
    800057ec:	00492603          	lw	a2,4(s2)
    800057f0:	00003597          	auipc	a1,0x3
    800057f4:	f2858593          	addi	a1,a1,-216 # 80008718 <etext+0x718>
    800057f8:	8526                	mv	a0,s1
    800057fa:	fffff097          	auipc	ra,0xfffff
    800057fe:	bbe080e7          	jalr	-1090(ra) # 800043b8 <dirlink>
    80005802:	f80557e3          	bgez	a0,80005790 <create+0xca>
      panic("create dots");
    80005806:	00003517          	auipc	a0,0x3
    8000580a:	f1a50513          	addi	a0,a0,-230 # 80008720 <etext+0x720>
    8000580e:	ffffb097          	auipc	ra,0xffffb
    80005812:	d48080e7          	jalr	-696(ra) # 80000556 <panic>
    panic("create: dirlink");
    80005816:	00003517          	auipc	a0,0x3
    8000581a:	f1a50513          	addi	a0,a0,-230 # 80008730 <etext+0x730>
    8000581e:	ffffb097          	auipc	ra,0xffffb
    80005822:	d38080e7          	jalr	-712(ra) # 80000556 <panic>
    return 0;
    80005826:	84aa                	mv	s1,a0
    80005828:	b739                	j	80005736 <create+0x70>

000000008000582a <sys_dup>:
{
    8000582a:	7179                	addi	sp,sp,-48
    8000582c:	f406                	sd	ra,40(sp)
    8000582e:	f022                	sd	s0,32(sp)
    80005830:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005832:	fd840613          	addi	a2,s0,-40
    80005836:	4581                	li	a1,0
    80005838:	4501                	li	a0,0
    8000583a:	00000097          	auipc	ra,0x0
    8000583e:	dde080e7          	jalr	-546(ra) # 80005618 <argfd>
    return -1;
    80005842:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005844:	02054763          	bltz	a0,80005872 <sys_dup+0x48>
    80005848:	ec26                	sd	s1,24(sp)
    8000584a:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    8000584c:	fd843483          	ld	s1,-40(s0)
    80005850:	8526                	mv	a0,s1
    80005852:	00000097          	auipc	ra,0x0
    80005856:	e30080e7          	jalr	-464(ra) # 80005682 <fdalloc>
    8000585a:	892a                	mv	s2,a0
    return -1;
    8000585c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000585e:	00054f63          	bltz	a0,8000587c <sys_dup+0x52>
  filedup(f);
    80005862:	8526                	mv	a0,s1
    80005864:	fffff097          	auipc	ra,0xfffff
    80005868:	2c0080e7          	jalr	704(ra) # 80004b24 <filedup>
  return fd;
    8000586c:	87ca                	mv	a5,s2
    8000586e:	64e2                	ld	s1,24(sp)
    80005870:	6942                	ld	s2,16(sp)
}
    80005872:	853e                	mv	a0,a5
    80005874:	70a2                	ld	ra,40(sp)
    80005876:	7402                	ld	s0,32(sp)
    80005878:	6145                	addi	sp,sp,48
    8000587a:	8082                	ret
    8000587c:	64e2                	ld	s1,24(sp)
    8000587e:	6942                	ld	s2,16(sp)
    80005880:	bfcd                	j	80005872 <sys_dup+0x48>

0000000080005882 <sys_read>:
{
    80005882:	7179                	addi	sp,sp,-48
    80005884:	f406                	sd	ra,40(sp)
    80005886:	f022                	sd	s0,32(sp)
    80005888:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000588a:	fe840613          	addi	a2,s0,-24
    8000588e:	4581                	li	a1,0
    80005890:	4501                	li	a0,0
    80005892:	00000097          	auipc	ra,0x0
    80005896:	d86080e7          	jalr	-634(ra) # 80005618 <argfd>
    return -1;
    8000589a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000589c:	04054163          	bltz	a0,800058de <sys_read+0x5c>
    800058a0:	fe440593          	addi	a1,s0,-28
    800058a4:	4509                	li	a0,2
    800058a6:	ffffd097          	auipc	ra,0xffffd
    800058aa:	664080e7          	jalr	1636(ra) # 80002f0a <argint>
    return -1;
    800058ae:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058b0:	02054763          	bltz	a0,800058de <sys_read+0x5c>
    800058b4:	fd840593          	addi	a1,s0,-40
    800058b8:	4505                	li	a0,1
    800058ba:	ffffd097          	auipc	ra,0xffffd
    800058be:	672080e7          	jalr	1650(ra) # 80002f2c <argaddr>
    return -1;
    800058c2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058c4:	00054d63          	bltz	a0,800058de <sys_read+0x5c>
  return fileread(f, p, n);
    800058c8:	fe442603          	lw	a2,-28(s0)
    800058cc:	fd843583          	ld	a1,-40(s0)
    800058d0:	fe843503          	ld	a0,-24(s0)
    800058d4:	fffff097          	auipc	ra,0xfffff
    800058d8:	3fa080e7          	jalr	1018(ra) # 80004cce <fileread>
    800058dc:	87aa                	mv	a5,a0
}
    800058de:	853e                	mv	a0,a5
    800058e0:	70a2                	ld	ra,40(sp)
    800058e2:	7402                	ld	s0,32(sp)
    800058e4:	6145                	addi	sp,sp,48
    800058e6:	8082                	ret

00000000800058e8 <sys_write>:
{
    800058e8:	7179                	addi	sp,sp,-48
    800058ea:	f406                	sd	ra,40(sp)
    800058ec:	f022                	sd	s0,32(sp)
    800058ee:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058f0:	fe840613          	addi	a2,s0,-24
    800058f4:	4581                	li	a1,0
    800058f6:	4501                	li	a0,0
    800058f8:	00000097          	auipc	ra,0x0
    800058fc:	d20080e7          	jalr	-736(ra) # 80005618 <argfd>
    return -1;
    80005900:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005902:	04054163          	bltz	a0,80005944 <sys_write+0x5c>
    80005906:	fe440593          	addi	a1,s0,-28
    8000590a:	4509                	li	a0,2
    8000590c:	ffffd097          	auipc	ra,0xffffd
    80005910:	5fe080e7          	jalr	1534(ra) # 80002f0a <argint>
    return -1;
    80005914:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005916:	02054763          	bltz	a0,80005944 <sys_write+0x5c>
    8000591a:	fd840593          	addi	a1,s0,-40
    8000591e:	4505                	li	a0,1
    80005920:	ffffd097          	auipc	ra,0xffffd
    80005924:	60c080e7          	jalr	1548(ra) # 80002f2c <argaddr>
    return -1;
    80005928:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000592a:	00054d63          	bltz	a0,80005944 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000592e:	fe442603          	lw	a2,-28(s0)
    80005932:	fd843583          	ld	a1,-40(s0)
    80005936:	fe843503          	ld	a0,-24(s0)
    8000593a:	fffff097          	auipc	ra,0xfffff
    8000593e:	46c080e7          	jalr	1132(ra) # 80004da6 <filewrite>
    80005942:	87aa                	mv	a5,a0
}
    80005944:	853e                	mv	a0,a5
    80005946:	70a2                	ld	ra,40(sp)
    80005948:	7402                	ld	s0,32(sp)
    8000594a:	6145                	addi	sp,sp,48
    8000594c:	8082                	ret

000000008000594e <sys_close>:
{
    8000594e:	1101                	addi	sp,sp,-32
    80005950:	ec06                	sd	ra,24(sp)
    80005952:	e822                	sd	s0,16(sp)
    80005954:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005956:	fe040613          	addi	a2,s0,-32
    8000595a:	fec40593          	addi	a1,s0,-20
    8000595e:	4501                	li	a0,0
    80005960:	00000097          	auipc	ra,0x0
    80005964:	cb8080e7          	jalr	-840(ra) # 80005618 <argfd>
    return -1;
    80005968:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000596a:	02054563          	bltz	a0,80005994 <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    8000596e:	ffffc097          	auipc	ra,0xffffc
    80005972:	118080e7          	jalr	280(ra) # 80001a86 <myproc>
    80005976:	fec42783          	lw	a5,-20(s0)
    8000597a:	078e                	slli	a5,a5,0x3
    8000597c:	0d078793          	addi	a5,a5,208
    80005980:	953e                	add	a0,a0,a5
    80005982:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005986:	fe043503          	ld	a0,-32(s0)
    8000598a:	fffff097          	auipc	ra,0xfffff
    8000598e:	1ec080e7          	jalr	492(ra) # 80004b76 <fileclose>
  return 0;
    80005992:	4781                	li	a5,0
}
    80005994:	853e                	mv	a0,a5
    80005996:	60e2                	ld	ra,24(sp)
    80005998:	6442                	ld	s0,16(sp)
    8000599a:	6105                	addi	sp,sp,32
    8000599c:	8082                	ret

000000008000599e <sys_fstat>:
{
    8000599e:	1101                	addi	sp,sp,-32
    800059a0:	ec06                	sd	ra,24(sp)
    800059a2:	e822                	sd	s0,16(sp)
    800059a4:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800059a6:	fe840613          	addi	a2,s0,-24
    800059aa:	4581                	li	a1,0
    800059ac:	4501                	li	a0,0
    800059ae:	00000097          	auipc	ra,0x0
    800059b2:	c6a080e7          	jalr	-918(ra) # 80005618 <argfd>
    return -1;
    800059b6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800059b8:	02054563          	bltz	a0,800059e2 <sys_fstat+0x44>
    800059bc:	fe040593          	addi	a1,s0,-32
    800059c0:	4505                	li	a0,1
    800059c2:	ffffd097          	auipc	ra,0xffffd
    800059c6:	56a080e7          	jalr	1386(ra) # 80002f2c <argaddr>
    return -1;
    800059ca:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800059cc:	00054b63          	bltz	a0,800059e2 <sys_fstat+0x44>
  return filestat(f, st);
    800059d0:	fe043583          	ld	a1,-32(s0)
    800059d4:	fe843503          	ld	a0,-24(s0)
    800059d8:	fffff097          	auipc	ra,0xfffff
    800059dc:	280080e7          	jalr	640(ra) # 80004c58 <filestat>
    800059e0:	87aa                	mv	a5,a0
}
    800059e2:	853e                	mv	a0,a5
    800059e4:	60e2                	ld	ra,24(sp)
    800059e6:	6442                	ld	s0,16(sp)
    800059e8:	6105                	addi	sp,sp,32
    800059ea:	8082                	ret

00000000800059ec <sys_link>:
{
    800059ec:	7169                	addi	sp,sp,-304
    800059ee:	f606                	sd	ra,296(sp)
    800059f0:	f222                	sd	s0,288(sp)
    800059f2:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059f4:	08000613          	li	a2,128
    800059f8:	ed040593          	addi	a1,s0,-304
    800059fc:	4501                	li	a0,0
    800059fe:	ffffd097          	auipc	ra,0xffffd
    80005a02:	550080e7          	jalr	1360(ra) # 80002f4e <argstr>
    return -1;
    80005a06:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a08:	12054663          	bltz	a0,80005b34 <sys_link+0x148>
    80005a0c:	08000613          	li	a2,128
    80005a10:	f5040593          	addi	a1,s0,-176
    80005a14:	4505                	li	a0,1
    80005a16:	ffffd097          	auipc	ra,0xffffd
    80005a1a:	538080e7          	jalr	1336(ra) # 80002f4e <argstr>
    return -1;
    80005a1e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a20:	10054a63          	bltz	a0,80005b34 <sys_link+0x148>
    80005a24:	ee26                	sd	s1,280(sp)
  begin_op();
    80005a26:	fffff097          	auipc	ra,0xfffff
    80005a2a:	c6e080e7          	jalr	-914(ra) # 80004694 <begin_op>
  if((ip = namei(old)) == 0){
    80005a2e:	ed040513          	addi	a0,s0,-304
    80005a32:	fffff097          	auipc	ra,0xfffff
    80005a36:	a5c080e7          	jalr	-1444(ra) # 8000448e <namei>
    80005a3a:	84aa                	mv	s1,a0
    80005a3c:	c949                	beqz	a0,80005ace <sys_link+0xe2>
  ilock(ip);
    80005a3e:	ffffe097          	auipc	ra,0xffffe
    80005a42:	25e080e7          	jalr	606(ra) # 80003c9c <ilock>
  if(ip->type == T_DIR){
    80005a46:	04449703          	lh	a4,68(s1)
    80005a4a:	4785                	li	a5,1
    80005a4c:	08f70863          	beq	a4,a5,80005adc <sys_link+0xf0>
    80005a50:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005a52:	04a4d783          	lhu	a5,74(s1)
    80005a56:	2785                	addiw	a5,a5,1
    80005a58:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a5c:	8526                	mv	a0,s1
    80005a5e:	ffffe097          	auipc	ra,0xffffe
    80005a62:	172080e7          	jalr	370(ra) # 80003bd0 <iupdate>
  iunlock(ip);
    80005a66:	8526                	mv	a0,s1
    80005a68:	ffffe097          	auipc	ra,0xffffe
    80005a6c:	2fa080e7          	jalr	762(ra) # 80003d62 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005a70:	fd040593          	addi	a1,s0,-48
    80005a74:	f5040513          	addi	a0,s0,-176
    80005a78:	fffff097          	auipc	ra,0xfffff
    80005a7c:	a34080e7          	jalr	-1484(ra) # 800044ac <nameiparent>
    80005a80:	892a                	mv	s2,a0
    80005a82:	cd35                	beqz	a0,80005afe <sys_link+0x112>
  ilock(dp);
    80005a84:	ffffe097          	auipc	ra,0xffffe
    80005a88:	218080e7          	jalr	536(ra) # 80003c9c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005a8c:	854a                	mv	a0,s2
    80005a8e:	00092703          	lw	a4,0(s2)
    80005a92:	409c                	lw	a5,0(s1)
    80005a94:	06f71063          	bne	a4,a5,80005af4 <sys_link+0x108>
    80005a98:	40d0                	lw	a2,4(s1)
    80005a9a:	fd040593          	addi	a1,s0,-48
    80005a9e:	fffff097          	auipc	ra,0xfffff
    80005aa2:	91a080e7          	jalr	-1766(ra) # 800043b8 <dirlink>
    80005aa6:	04054763          	bltz	a0,80005af4 <sys_link+0x108>
  iunlockput(dp);
    80005aaa:	854a                	mv	a0,s2
    80005aac:	ffffe097          	auipc	ra,0xffffe
    80005ab0:	458080e7          	jalr	1112(ra) # 80003f04 <iunlockput>
  iput(ip);
    80005ab4:	8526                	mv	a0,s1
    80005ab6:	ffffe097          	auipc	ra,0xffffe
    80005aba:	3a4080e7          	jalr	932(ra) # 80003e5a <iput>
  end_op();
    80005abe:	fffff097          	auipc	ra,0xfffff
    80005ac2:	c56080e7          	jalr	-938(ra) # 80004714 <end_op>
  return 0;
    80005ac6:	4781                	li	a5,0
    80005ac8:	64f2                	ld	s1,280(sp)
    80005aca:	6952                	ld	s2,272(sp)
    80005acc:	a0a5                	j	80005b34 <sys_link+0x148>
    end_op();
    80005ace:	fffff097          	auipc	ra,0xfffff
    80005ad2:	c46080e7          	jalr	-954(ra) # 80004714 <end_op>
    return -1;
    80005ad6:	57fd                	li	a5,-1
    80005ad8:	64f2                	ld	s1,280(sp)
    80005ada:	a8a9                	j	80005b34 <sys_link+0x148>
    iunlockput(ip);
    80005adc:	8526                	mv	a0,s1
    80005ade:	ffffe097          	auipc	ra,0xffffe
    80005ae2:	426080e7          	jalr	1062(ra) # 80003f04 <iunlockput>
    end_op();
    80005ae6:	fffff097          	auipc	ra,0xfffff
    80005aea:	c2e080e7          	jalr	-978(ra) # 80004714 <end_op>
    return -1;
    80005aee:	57fd                	li	a5,-1
    80005af0:	64f2                	ld	s1,280(sp)
    80005af2:	a089                	j	80005b34 <sys_link+0x148>
    iunlockput(dp);
    80005af4:	854a                	mv	a0,s2
    80005af6:	ffffe097          	auipc	ra,0xffffe
    80005afa:	40e080e7          	jalr	1038(ra) # 80003f04 <iunlockput>
  ilock(ip);
    80005afe:	8526                	mv	a0,s1
    80005b00:	ffffe097          	auipc	ra,0xffffe
    80005b04:	19c080e7          	jalr	412(ra) # 80003c9c <ilock>
  ip->nlink--;
    80005b08:	04a4d783          	lhu	a5,74(s1)
    80005b0c:	37fd                	addiw	a5,a5,-1
    80005b0e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005b12:	8526                	mv	a0,s1
    80005b14:	ffffe097          	auipc	ra,0xffffe
    80005b18:	0bc080e7          	jalr	188(ra) # 80003bd0 <iupdate>
  iunlockput(ip);
    80005b1c:	8526                	mv	a0,s1
    80005b1e:	ffffe097          	auipc	ra,0xffffe
    80005b22:	3e6080e7          	jalr	998(ra) # 80003f04 <iunlockput>
  end_op();
    80005b26:	fffff097          	auipc	ra,0xfffff
    80005b2a:	bee080e7          	jalr	-1042(ra) # 80004714 <end_op>
  return -1;
    80005b2e:	57fd                	li	a5,-1
    80005b30:	64f2                	ld	s1,280(sp)
    80005b32:	6952                	ld	s2,272(sp)
}
    80005b34:	853e                	mv	a0,a5
    80005b36:	70b2                	ld	ra,296(sp)
    80005b38:	7412                	ld	s0,288(sp)
    80005b3a:	6155                	addi	sp,sp,304
    80005b3c:	8082                	ret

0000000080005b3e <sys_unlink>:
{
    80005b3e:	7151                	addi	sp,sp,-240
    80005b40:	f586                	sd	ra,232(sp)
    80005b42:	f1a2                	sd	s0,224(sp)
    80005b44:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005b46:	08000613          	li	a2,128
    80005b4a:	f3040593          	addi	a1,s0,-208
    80005b4e:	4501                	li	a0,0
    80005b50:	ffffd097          	auipc	ra,0xffffd
    80005b54:	3fe080e7          	jalr	1022(ra) # 80002f4e <argstr>
    80005b58:	1a054763          	bltz	a0,80005d06 <sys_unlink+0x1c8>
    80005b5c:	eda6                	sd	s1,216(sp)
  begin_op();
    80005b5e:	fffff097          	auipc	ra,0xfffff
    80005b62:	b36080e7          	jalr	-1226(ra) # 80004694 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005b66:	fb040593          	addi	a1,s0,-80
    80005b6a:	f3040513          	addi	a0,s0,-208
    80005b6e:	fffff097          	auipc	ra,0xfffff
    80005b72:	93e080e7          	jalr	-1730(ra) # 800044ac <nameiparent>
    80005b76:	84aa                	mv	s1,a0
    80005b78:	c165                	beqz	a0,80005c58 <sys_unlink+0x11a>
  ilock(dp);
    80005b7a:	ffffe097          	auipc	ra,0xffffe
    80005b7e:	122080e7          	jalr	290(ra) # 80003c9c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005b82:	00003597          	auipc	a1,0x3
    80005b86:	b8e58593          	addi	a1,a1,-1138 # 80008710 <etext+0x710>
    80005b8a:	fb040513          	addi	a0,s0,-80
    80005b8e:	ffffe097          	auipc	ra,0xffffe
    80005b92:	5e2080e7          	jalr	1506(ra) # 80004170 <namecmp>
    80005b96:	14050963          	beqz	a0,80005ce8 <sys_unlink+0x1aa>
    80005b9a:	00003597          	auipc	a1,0x3
    80005b9e:	b7e58593          	addi	a1,a1,-1154 # 80008718 <etext+0x718>
    80005ba2:	fb040513          	addi	a0,s0,-80
    80005ba6:	ffffe097          	auipc	ra,0xffffe
    80005baa:	5ca080e7          	jalr	1482(ra) # 80004170 <namecmp>
    80005bae:	12050d63          	beqz	a0,80005ce8 <sys_unlink+0x1aa>
    80005bb2:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005bb4:	f2c40613          	addi	a2,s0,-212
    80005bb8:	fb040593          	addi	a1,s0,-80
    80005bbc:	8526                	mv	a0,s1
    80005bbe:	ffffe097          	auipc	ra,0xffffe
    80005bc2:	5cc080e7          	jalr	1484(ra) # 8000418a <dirlookup>
    80005bc6:	892a                	mv	s2,a0
    80005bc8:	10050f63          	beqz	a0,80005ce6 <sys_unlink+0x1a8>
    80005bcc:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80005bce:	ffffe097          	auipc	ra,0xffffe
    80005bd2:	0ce080e7          	jalr	206(ra) # 80003c9c <ilock>
  if(ip->nlink < 1)
    80005bd6:	04a91783          	lh	a5,74(s2)
    80005bda:	08f05663          	blez	a5,80005c66 <sys_unlink+0x128>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005bde:	04491703          	lh	a4,68(s2)
    80005be2:	4785                	li	a5,1
    80005be4:	08f70963          	beq	a4,a5,80005c76 <sys_unlink+0x138>
  memset(&de, 0, sizeof(de));
    80005be8:	fc040993          	addi	s3,s0,-64
    80005bec:	4641                	li	a2,16
    80005bee:	4581                	li	a1,0
    80005bf0:	854e                	mv	a0,s3
    80005bf2:	ffffb097          	auipc	ra,0xffffb
    80005bf6:	15a080e7          	jalr	346(ra) # 80000d4c <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005bfa:	4741                	li	a4,16
    80005bfc:	f2c42683          	lw	a3,-212(s0)
    80005c00:	864e                	mv	a2,s3
    80005c02:	4581                	li	a1,0
    80005c04:	8526                	mv	a0,s1
    80005c06:	ffffe097          	auipc	ra,0xffffe
    80005c0a:	44e080e7          	jalr	1102(ra) # 80004054 <writei>
    80005c0e:	47c1                	li	a5,16
    80005c10:	0af51863          	bne	a0,a5,80005cc0 <sys_unlink+0x182>
  if(ip->type == T_DIR){
    80005c14:	04491703          	lh	a4,68(s2)
    80005c18:	4785                	li	a5,1
    80005c1a:	0af70b63          	beq	a4,a5,80005cd0 <sys_unlink+0x192>
  iunlockput(dp);
    80005c1e:	8526                	mv	a0,s1
    80005c20:	ffffe097          	auipc	ra,0xffffe
    80005c24:	2e4080e7          	jalr	740(ra) # 80003f04 <iunlockput>
  ip->nlink--;
    80005c28:	04a95783          	lhu	a5,74(s2)
    80005c2c:	37fd                	addiw	a5,a5,-1
    80005c2e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005c32:	854a                	mv	a0,s2
    80005c34:	ffffe097          	auipc	ra,0xffffe
    80005c38:	f9c080e7          	jalr	-100(ra) # 80003bd0 <iupdate>
  iunlockput(ip);
    80005c3c:	854a                	mv	a0,s2
    80005c3e:	ffffe097          	auipc	ra,0xffffe
    80005c42:	2c6080e7          	jalr	710(ra) # 80003f04 <iunlockput>
  end_op();
    80005c46:	fffff097          	auipc	ra,0xfffff
    80005c4a:	ace080e7          	jalr	-1330(ra) # 80004714 <end_op>
  return 0;
    80005c4e:	4501                	li	a0,0
    80005c50:	64ee                	ld	s1,216(sp)
    80005c52:	694e                	ld	s2,208(sp)
    80005c54:	69ae                	ld	s3,200(sp)
    80005c56:	a065                	j	80005cfe <sys_unlink+0x1c0>
    end_op();
    80005c58:	fffff097          	auipc	ra,0xfffff
    80005c5c:	abc080e7          	jalr	-1348(ra) # 80004714 <end_op>
    return -1;
    80005c60:	557d                	li	a0,-1
    80005c62:	64ee                	ld	s1,216(sp)
    80005c64:	a869                	j	80005cfe <sys_unlink+0x1c0>
    panic("unlink: nlink < 1");
    80005c66:	00003517          	auipc	a0,0x3
    80005c6a:	ada50513          	addi	a0,a0,-1318 # 80008740 <etext+0x740>
    80005c6e:	ffffb097          	auipc	ra,0xffffb
    80005c72:	8e8080e7          	jalr	-1816(ra) # 80000556 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005c76:	04c92703          	lw	a4,76(s2)
    80005c7a:	02000793          	li	a5,32
    80005c7e:	f6e7f5e3          	bgeu	a5,a4,80005be8 <sys_unlink+0xaa>
    80005c82:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005c84:	4741                	li	a4,16
    80005c86:	86ce                	mv	a3,s3
    80005c88:	f1840613          	addi	a2,s0,-232
    80005c8c:	4581                	li	a1,0
    80005c8e:	854a                	mv	a0,s2
    80005c90:	ffffe097          	auipc	ra,0xffffe
    80005c94:	2ca080e7          	jalr	714(ra) # 80003f5a <readi>
    80005c98:	47c1                	li	a5,16
    80005c9a:	00f51b63          	bne	a0,a5,80005cb0 <sys_unlink+0x172>
    if(de.inum != 0)
    80005c9e:	f1845783          	lhu	a5,-232(s0)
    80005ca2:	e7a5                	bnez	a5,80005d0a <sys_unlink+0x1cc>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005ca4:	29c1                	addiw	s3,s3,16
    80005ca6:	04c92783          	lw	a5,76(s2)
    80005caa:	fcf9ede3          	bltu	s3,a5,80005c84 <sys_unlink+0x146>
    80005cae:	bf2d                	j	80005be8 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005cb0:	00003517          	auipc	a0,0x3
    80005cb4:	aa850513          	addi	a0,a0,-1368 # 80008758 <etext+0x758>
    80005cb8:	ffffb097          	auipc	ra,0xffffb
    80005cbc:	89e080e7          	jalr	-1890(ra) # 80000556 <panic>
    panic("unlink: writei");
    80005cc0:	00003517          	auipc	a0,0x3
    80005cc4:	ab050513          	addi	a0,a0,-1360 # 80008770 <etext+0x770>
    80005cc8:	ffffb097          	auipc	ra,0xffffb
    80005ccc:	88e080e7          	jalr	-1906(ra) # 80000556 <panic>
    dp->nlink--;
    80005cd0:	04a4d783          	lhu	a5,74(s1)
    80005cd4:	37fd                	addiw	a5,a5,-1
    80005cd6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005cda:	8526                	mv	a0,s1
    80005cdc:	ffffe097          	auipc	ra,0xffffe
    80005ce0:	ef4080e7          	jalr	-268(ra) # 80003bd0 <iupdate>
    80005ce4:	bf2d                	j	80005c1e <sys_unlink+0xe0>
    80005ce6:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005ce8:	8526                	mv	a0,s1
    80005cea:	ffffe097          	auipc	ra,0xffffe
    80005cee:	21a080e7          	jalr	538(ra) # 80003f04 <iunlockput>
  end_op();
    80005cf2:	fffff097          	auipc	ra,0xfffff
    80005cf6:	a22080e7          	jalr	-1502(ra) # 80004714 <end_op>
  return -1;
    80005cfa:	557d                	li	a0,-1
    80005cfc:	64ee                	ld	s1,216(sp)
}
    80005cfe:	70ae                	ld	ra,232(sp)
    80005d00:	740e                	ld	s0,224(sp)
    80005d02:	616d                	addi	sp,sp,240
    80005d04:	8082                	ret
    return -1;
    80005d06:	557d                	li	a0,-1
    80005d08:	bfdd                	j	80005cfe <sys_unlink+0x1c0>
    iunlockput(ip);
    80005d0a:	854a                	mv	a0,s2
    80005d0c:	ffffe097          	auipc	ra,0xffffe
    80005d10:	1f8080e7          	jalr	504(ra) # 80003f04 <iunlockput>
    goto bad;
    80005d14:	694e                	ld	s2,208(sp)
    80005d16:	69ae                	ld	s3,200(sp)
    80005d18:	bfc1                	j	80005ce8 <sys_unlink+0x1aa>

0000000080005d1a <sys_open>:

uint64
sys_open(void)
{
    80005d1a:	7131                	addi	sp,sp,-192
    80005d1c:	fd06                	sd	ra,184(sp)
    80005d1e:	f922                	sd	s0,176(sp)
    80005d20:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005d22:	08000613          	li	a2,128
    80005d26:	f5040593          	addi	a1,s0,-176
    80005d2a:	4501                	li	a0,0
    80005d2c:	ffffd097          	auipc	ra,0xffffd
    80005d30:	222080e7          	jalr	546(ra) # 80002f4e <argstr>
    return -1;
    80005d34:	57fd                	li	a5,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005d36:	0c054963          	bltz	a0,80005e08 <sys_open+0xee>
    80005d3a:	f4c40593          	addi	a1,s0,-180
    80005d3e:	4505                	li	a0,1
    80005d40:	ffffd097          	auipc	ra,0xffffd
    80005d44:	1ca080e7          	jalr	458(ra) # 80002f0a <argint>
    return -1;
    80005d48:	57fd                	li	a5,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005d4a:	0a054f63          	bltz	a0,80005e08 <sys_open+0xee>
    80005d4e:	f526                	sd	s1,168(sp)

  begin_op();
    80005d50:	fffff097          	auipc	ra,0xfffff
    80005d54:	944080e7          	jalr	-1724(ra) # 80004694 <begin_op>

  if(omode & O_CREATE){
    80005d58:	f4c42783          	lw	a5,-180(s0)
    80005d5c:	2007f793          	andi	a5,a5,512
    80005d60:	c3e1                	beqz	a5,80005e20 <sys_open+0x106>
    ip = create(path, T_FILE, 0, 0);
    80005d62:	4681                	li	a3,0
    80005d64:	4601                	li	a2,0
    80005d66:	4589                	li	a1,2
    80005d68:	f5040513          	addi	a0,s0,-176
    80005d6c:	00000097          	auipc	ra,0x0
    80005d70:	95a080e7          	jalr	-1702(ra) # 800056c6 <create>
    80005d74:	84aa                	mv	s1,a0
    if(ip == 0){
    80005d76:	cd51                	beqz	a0,80005e12 <sys_open+0xf8>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005d78:	04449703          	lh	a4,68(s1)
    80005d7c:	478d                	li	a5,3
    80005d7e:	00f71763          	bne	a4,a5,80005d8c <sys_open+0x72>
    80005d82:	0464d703          	lhu	a4,70(s1)
    80005d86:	47a5                	li	a5,9
    80005d88:	0ee7e363          	bltu	a5,a4,80005e6e <sys_open+0x154>
    80005d8c:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005d8e:	fffff097          	auipc	ra,0xfffff
    80005d92:	d2c080e7          	jalr	-724(ra) # 80004aba <filealloc>
    80005d96:	892a                	mv	s2,a0
    80005d98:	cd6d                	beqz	a0,80005e92 <sys_open+0x178>
    80005d9a:	ed4e                	sd	s3,152(sp)
    80005d9c:	00000097          	auipc	ra,0x0
    80005da0:	8e6080e7          	jalr	-1818(ra) # 80005682 <fdalloc>
    80005da4:	89aa                	mv	s3,a0
    80005da6:	0e054063          	bltz	a0,80005e86 <sys_open+0x16c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005daa:	04449703          	lh	a4,68(s1)
    80005dae:	478d                	li	a5,3
    80005db0:	0ef70e63          	beq	a4,a5,80005eac <sys_open+0x192>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005db4:	4789                	li	a5,2
    80005db6:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005dba:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005dbe:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005dc2:	f4c42783          	lw	a5,-180(s0)
    80005dc6:	0017f713          	andi	a4,a5,1
    80005dca:	00174713          	xori	a4,a4,1
    80005dce:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005dd2:	0037f713          	andi	a4,a5,3
    80005dd6:	00e03733          	snez	a4,a4
    80005dda:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005dde:	4007f793          	andi	a5,a5,1024
    80005de2:	c791                	beqz	a5,80005dee <sys_open+0xd4>
    80005de4:	04449703          	lh	a4,68(s1)
    80005de8:	4789                	li	a5,2
    80005dea:	0cf70863          	beq	a4,a5,80005eba <sys_open+0x1a0>
    itrunc(ip);
  }

  iunlock(ip);
    80005dee:	8526                	mv	a0,s1
    80005df0:	ffffe097          	auipc	ra,0xffffe
    80005df4:	f72080e7          	jalr	-142(ra) # 80003d62 <iunlock>
  end_op();
    80005df8:	fffff097          	auipc	ra,0xfffff
    80005dfc:	91c080e7          	jalr	-1764(ra) # 80004714 <end_op>

  return fd;
    80005e00:	87ce                	mv	a5,s3
    80005e02:	74aa                	ld	s1,168(sp)
    80005e04:	790a                	ld	s2,160(sp)
    80005e06:	69ea                	ld	s3,152(sp)
}
    80005e08:	853e                	mv	a0,a5
    80005e0a:	70ea                	ld	ra,184(sp)
    80005e0c:	744a                	ld	s0,176(sp)
    80005e0e:	6129                	addi	sp,sp,192
    80005e10:	8082                	ret
      end_op();
    80005e12:	fffff097          	auipc	ra,0xfffff
    80005e16:	902080e7          	jalr	-1790(ra) # 80004714 <end_op>
      return -1;
    80005e1a:	57fd                	li	a5,-1
    80005e1c:	74aa                	ld	s1,168(sp)
    80005e1e:	b7ed                	j	80005e08 <sys_open+0xee>
    if((ip = namei(path)) == 0){
    80005e20:	f5040513          	addi	a0,s0,-176
    80005e24:	ffffe097          	auipc	ra,0xffffe
    80005e28:	66a080e7          	jalr	1642(ra) # 8000448e <namei>
    80005e2c:	84aa                	mv	s1,a0
    80005e2e:	c90d                	beqz	a0,80005e60 <sys_open+0x146>
    ilock(ip);
    80005e30:	ffffe097          	auipc	ra,0xffffe
    80005e34:	e6c080e7          	jalr	-404(ra) # 80003c9c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005e38:	04449703          	lh	a4,68(s1)
    80005e3c:	4785                	li	a5,1
    80005e3e:	f2f71de3          	bne	a4,a5,80005d78 <sys_open+0x5e>
    80005e42:	f4c42783          	lw	a5,-180(s0)
    80005e46:	d3b9                	beqz	a5,80005d8c <sys_open+0x72>
      iunlockput(ip);
    80005e48:	8526                	mv	a0,s1
    80005e4a:	ffffe097          	auipc	ra,0xffffe
    80005e4e:	0ba080e7          	jalr	186(ra) # 80003f04 <iunlockput>
      end_op();
    80005e52:	fffff097          	auipc	ra,0xfffff
    80005e56:	8c2080e7          	jalr	-1854(ra) # 80004714 <end_op>
      return -1;
    80005e5a:	57fd                	li	a5,-1
    80005e5c:	74aa                	ld	s1,168(sp)
    80005e5e:	b76d                	j	80005e08 <sys_open+0xee>
      end_op();
    80005e60:	fffff097          	auipc	ra,0xfffff
    80005e64:	8b4080e7          	jalr	-1868(ra) # 80004714 <end_op>
      return -1;
    80005e68:	57fd                	li	a5,-1
    80005e6a:	74aa                	ld	s1,168(sp)
    80005e6c:	bf71                	j	80005e08 <sys_open+0xee>
    iunlockput(ip);
    80005e6e:	8526                	mv	a0,s1
    80005e70:	ffffe097          	auipc	ra,0xffffe
    80005e74:	094080e7          	jalr	148(ra) # 80003f04 <iunlockput>
    end_op();
    80005e78:	fffff097          	auipc	ra,0xfffff
    80005e7c:	89c080e7          	jalr	-1892(ra) # 80004714 <end_op>
    return -1;
    80005e80:	57fd                	li	a5,-1
    80005e82:	74aa                	ld	s1,168(sp)
    80005e84:	b751                	j	80005e08 <sys_open+0xee>
      fileclose(f);
    80005e86:	854a                	mv	a0,s2
    80005e88:	fffff097          	auipc	ra,0xfffff
    80005e8c:	cee080e7          	jalr	-786(ra) # 80004b76 <fileclose>
    80005e90:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005e92:	8526                	mv	a0,s1
    80005e94:	ffffe097          	auipc	ra,0xffffe
    80005e98:	070080e7          	jalr	112(ra) # 80003f04 <iunlockput>
    end_op();
    80005e9c:	fffff097          	auipc	ra,0xfffff
    80005ea0:	878080e7          	jalr	-1928(ra) # 80004714 <end_op>
    return -1;
    80005ea4:	57fd                	li	a5,-1
    80005ea6:	74aa                	ld	s1,168(sp)
    80005ea8:	790a                	ld	s2,160(sp)
    80005eaa:	bfb9                	j	80005e08 <sys_open+0xee>
    f->type = FD_DEVICE;
    80005eac:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005eb0:	04649783          	lh	a5,70(s1)
    80005eb4:	02f91223          	sh	a5,36(s2)
    80005eb8:	b719                	j	80005dbe <sys_open+0xa4>
    itrunc(ip);
    80005eba:	8526                	mv	a0,s1
    80005ebc:	ffffe097          	auipc	ra,0xffffe
    80005ec0:	ef2080e7          	jalr	-270(ra) # 80003dae <itrunc>
    80005ec4:	b72d                	j	80005dee <sys_open+0xd4>

0000000080005ec6 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005ec6:	7175                	addi	sp,sp,-144
    80005ec8:	e506                	sd	ra,136(sp)
    80005eca:	e122                	sd	s0,128(sp)
    80005ecc:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005ece:	ffffe097          	auipc	ra,0xffffe
    80005ed2:	7c6080e7          	jalr	1990(ra) # 80004694 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005ed6:	08000613          	li	a2,128
    80005eda:	f7040593          	addi	a1,s0,-144
    80005ede:	4501                	li	a0,0
    80005ee0:	ffffd097          	auipc	ra,0xffffd
    80005ee4:	06e080e7          	jalr	110(ra) # 80002f4e <argstr>
    80005ee8:	02054963          	bltz	a0,80005f1a <sys_mkdir+0x54>
    80005eec:	4681                	li	a3,0
    80005eee:	4601                	li	a2,0
    80005ef0:	4585                	li	a1,1
    80005ef2:	f7040513          	addi	a0,s0,-144
    80005ef6:	fffff097          	auipc	ra,0xfffff
    80005efa:	7d0080e7          	jalr	2000(ra) # 800056c6 <create>
    80005efe:	cd11                	beqz	a0,80005f1a <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005f00:	ffffe097          	auipc	ra,0xffffe
    80005f04:	004080e7          	jalr	4(ra) # 80003f04 <iunlockput>
  end_op();
    80005f08:	fffff097          	auipc	ra,0xfffff
    80005f0c:	80c080e7          	jalr	-2036(ra) # 80004714 <end_op>
  return 0;
    80005f10:	4501                	li	a0,0
}
    80005f12:	60aa                	ld	ra,136(sp)
    80005f14:	640a                	ld	s0,128(sp)
    80005f16:	6149                	addi	sp,sp,144
    80005f18:	8082                	ret
    end_op();
    80005f1a:	ffffe097          	auipc	ra,0xffffe
    80005f1e:	7fa080e7          	jalr	2042(ra) # 80004714 <end_op>
    return -1;
    80005f22:	557d                	li	a0,-1
    80005f24:	b7fd                	j	80005f12 <sys_mkdir+0x4c>

0000000080005f26 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005f26:	7135                	addi	sp,sp,-160
    80005f28:	ed06                	sd	ra,152(sp)
    80005f2a:	e922                	sd	s0,144(sp)
    80005f2c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005f2e:	ffffe097          	auipc	ra,0xffffe
    80005f32:	766080e7          	jalr	1894(ra) # 80004694 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005f36:	08000613          	li	a2,128
    80005f3a:	f7040593          	addi	a1,s0,-144
    80005f3e:	4501                	li	a0,0
    80005f40:	ffffd097          	auipc	ra,0xffffd
    80005f44:	00e080e7          	jalr	14(ra) # 80002f4e <argstr>
    80005f48:	04054a63          	bltz	a0,80005f9c <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005f4c:	f6c40593          	addi	a1,s0,-148
    80005f50:	4505                	li	a0,1
    80005f52:	ffffd097          	auipc	ra,0xffffd
    80005f56:	fb8080e7          	jalr	-72(ra) # 80002f0a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005f5a:	04054163          	bltz	a0,80005f9c <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005f5e:	f6840593          	addi	a1,s0,-152
    80005f62:	4509                	li	a0,2
    80005f64:	ffffd097          	auipc	ra,0xffffd
    80005f68:	fa6080e7          	jalr	-90(ra) # 80002f0a <argint>
     argint(1, &major) < 0 ||
    80005f6c:	02054863          	bltz	a0,80005f9c <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005f70:	f6841683          	lh	a3,-152(s0)
    80005f74:	f6c41603          	lh	a2,-148(s0)
    80005f78:	458d                	li	a1,3
    80005f7a:	f7040513          	addi	a0,s0,-144
    80005f7e:	fffff097          	auipc	ra,0xfffff
    80005f82:	748080e7          	jalr	1864(ra) # 800056c6 <create>
     argint(2, &minor) < 0 ||
    80005f86:	c919                	beqz	a0,80005f9c <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005f88:	ffffe097          	auipc	ra,0xffffe
    80005f8c:	f7c080e7          	jalr	-132(ra) # 80003f04 <iunlockput>
  end_op();
    80005f90:	ffffe097          	auipc	ra,0xffffe
    80005f94:	784080e7          	jalr	1924(ra) # 80004714 <end_op>
  return 0;
    80005f98:	4501                	li	a0,0
    80005f9a:	a031                	j	80005fa6 <sys_mknod+0x80>
    end_op();
    80005f9c:	ffffe097          	auipc	ra,0xffffe
    80005fa0:	778080e7          	jalr	1912(ra) # 80004714 <end_op>
    return -1;
    80005fa4:	557d                	li	a0,-1
}
    80005fa6:	60ea                	ld	ra,152(sp)
    80005fa8:	644a                	ld	s0,144(sp)
    80005faa:	610d                	addi	sp,sp,160
    80005fac:	8082                	ret

0000000080005fae <sys_chdir>:

uint64
sys_chdir(void)
{
    80005fae:	7135                	addi	sp,sp,-160
    80005fb0:	ed06                	sd	ra,152(sp)
    80005fb2:	e922                	sd	s0,144(sp)
    80005fb4:	e14a                	sd	s2,128(sp)
    80005fb6:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005fb8:	ffffc097          	auipc	ra,0xffffc
    80005fbc:	ace080e7          	jalr	-1330(ra) # 80001a86 <myproc>
    80005fc0:	892a                	mv	s2,a0
  
  begin_op();
    80005fc2:	ffffe097          	auipc	ra,0xffffe
    80005fc6:	6d2080e7          	jalr	1746(ra) # 80004694 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005fca:	08000613          	li	a2,128
    80005fce:	f6040593          	addi	a1,s0,-160
    80005fd2:	4501                	li	a0,0
    80005fd4:	ffffd097          	auipc	ra,0xffffd
    80005fd8:	f7a080e7          	jalr	-134(ra) # 80002f4e <argstr>
    80005fdc:	04054d63          	bltz	a0,80006036 <sys_chdir+0x88>
    80005fe0:	e526                	sd	s1,136(sp)
    80005fe2:	f6040513          	addi	a0,s0,-160
    80005fe6:	ffffe097          	auipc	ra,0xffffe
    80005fea:	4a8080e7          	jalr	1192(ra) # 8000448e <namei>
    80005fee:	84aa                	mv	s1,a0
    80005ff0:	c131                	beqz	a0,80006034 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005ff2:	ffffe097          	auipc	ra,0xffffe
    80005ff6:	caa080e7          	jalr	-854(ra) # 80003c9c <ilock>
  if(ip->type != T_DIR){
    80005ffa:	04449703          	lh	a4,68(s1)
    80005ffe:	4785                	li	a5,1
    80006000:	04f71163          	bne	a4,a5,80006042 <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006004:	8526                	mv	a0,s1
    80006006:	ffffe097          	auipc	ra,0xffffe
    8000600a:	d5c080e7          	jalr	-676(ra) # 80003d62 <iunlock>
  iput(p->cwd);
    8000600e:	15093503          	ld	a0,336(s2)
    80006012:	ffffe097          	auipc	ra,0xffffe
    80006016:	e48080e7          	jalr	-440(ra) # 80003e5a <iput>
  end_op();
    8000601a:	ffffe097          	auipc	ra,0xffffe
    8000601e:	6fa080e7          	jalr	1786(ra) # 80004714 <end_op>
  p->cwd = ip;
    80006022:	14993823          	sd	s1,336(s2)
  return 0;
    80006026:	4501                	li	a0,0
    80006028:	64aa                	ld	s1,136(sp)
}
    8000602a:	60ea                	ld	ra,152(sp)
    8000602c:	644a                	ld	s0,144(sp)
    8000602e:	690a                	ld	s2,128(sp)
    80006030:	610d                	addi	sp,sp,160
    80006032:	8082                	ret
    80006034:	64aa                	ld	s1,136(sp)
    end_op();
    80006036:	ffffe097          	auipc	ra,0xffffe
    8000603a:	6de080e7          	jalr	1758(ra) # 80004714 <end_op>
    return -1;
    8000603e:	557d                	li	a0,-1
    80006040:	b7ed                	j	8000602a <sys_chdir+0x7c>
    iunlockput(ip);
    80006042:	8526                	mv	a0,s1
    80006044:	ffffe097          	auipc	ra,0xffffe
    80006048:	ec0080e7          	jalr	-320(ra) # 80003f04 <iunlockput>
    end_op();
    8000604c:	ffffe097          	auipc	ra,0xffffe
    80006050:	6c8080e7          	jalr	1736(ra) # 80004714 <end_op>
    return -1;
    80006054:	557d                	li	a0,-1
    80006056:	64aa                	ld	s1,136(sp)
    80006058:	bfc9                	j	8000602a <sys_chdir+0x7c>

000000008000605a <sys_exec>:

uint64
sys_exec(void)
{
    8000605a:	7145                	addi	sp,sp,-464
    8000605c:	e786                	sd	ra,456(sp)
    8000605e:	e3a2                	sd	s0,448(sp)
    80006060:	fb4a                	sd	s2,432(sp)
    80006062:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006064:	08000613          	li	a2,128
    80006068:	f4040593          	addi	a1,s0,-192
    8000606c:	4501                	li	a0,0
    8000606e:	ffffd097          	auipc	ra,0xffffd
    80006072:	ee0080e7          	jalr	-288(ra) # 80002f4e <argstr>
    return -1;
    80006076:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006078:	10054463          	bltz	a0,80006180 <sys_exec+0x126>
    8000607c:	e3840593          	addi	a1,s0,-456
    80006080:	4505                	li	a0,1
    80006082:	ffffd097          	auipc	ra,0xffffd
    80006086:	eaa080e7          	jalr	-342(ra) # 80002f2c <argaddr>
    8000608a:	0e054b63          	bltz	a0,80006180 <sys_exec+0x126>
    8000608e:	ff26                	sd	s1,440(sp)
    80006090:	f74e                	sd	s3,424(sp)
    80006092:	f352                	sd	s4,416(sp)
    80006094:	ef56                	sd	s5,408(sp)
    80006096:	eb5a                	sd	s6,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80006098:	10000613          	li	a2,256
    8000609c:	4581                	li	a1,0
    8000609e:	e4040513          	addi	a0,s0,-448
    800060a2:	ffffb097          	auipc	ra,0xffffb
    800060a6:	caa080e7          	jalr	-854(ra) # 80000d4c <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800060aa:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800060ae:	89a6                	mv	s3,s1
    800060b0:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800060b2:	e3040a13          	addi	s4,s0,-464
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800060b6:	6a85                	lui	s5,0x1
    if(i >= NELEM(argv)){
    800060b8:	02000b13          	li	s6,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800060bc:	00391513          	slli	a0,s2,0x3
    800060c0:	85d2                	mv	a1,s4
    800060c2:	e3843783          	ld	a5,-456(s0)
    800060c6:	953e                	add	a0,a0,a5
    800060c8:	ffffd097          	auipc	ra,0xffffd
    800060cc:	da8080e7          	jalr	-600(ra) # 80002e70 <fetchaddr>
    800060d0:	02054a63          	bltz	a0,80006104 <sys_exec+0xaa>
    if(uarg == 0){
    800060d4:	e3043783          	ld	a5,-464(s0)
    800060d8:	cba1                	beqz	a5,80006128 <sys_exec+0xce>
    argv[i] = kalloc();
    800060da:	ffffb097          	auipc	ra,0xffffb
    800060de:	a76080e7          	jalr	-1418(ra) # 80000b50 <kalloc>
    800060e2:	85aa                	mv	a1,a0
    800060e4:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800060e8:	cd11                	beqz	a0,80006104 <sys_exec+0xaa>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800060ea:	8656                	mv	a2,s5
    800060ec:	e3043503          	ld	a0,-464(s0)
    800060f0:	ffffd097          	auipc	ra,0xffffd
    800060f4:	dd2080e7          	jalr	-558(ra) # 80002ec2 <fetchstr>
    800060f8:	00054663          	bltz	a0,80006104 <sys_exec+0xaa>
    if(i >= NELEM(argv)){
    800060fc:	0905                	addi	s2,s2,1
    800060fe:	09a1                	addi	s3,s3,8
    80006100:	fb691ee3          	bne	s2,s6,800060bc <sys_exec+0x62>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006104:	f4040913          	addi	s2,s0,-192
    80006108:	6088                	ld	a0,0(s1)
    8000610a:	c52d                	beqz	a0,80006174 <sys_exec+0x11a>
    kfree(argv[i]);
    8000610c:	ffffb097          	auipc	ra,0xffffb
    80006110:	940080e7          	jalr	-1728(ra) # 80000a4c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006114:	04a1                	addi	s1,s1,8
    80006116:	ff2499e3          	bne	s1,s2,80006108 <sys_exec+0xae>
  return -1;
    8000611a:	597d                	li	s2,-1
    8000611c:	74fa                	ld	s1,440(sp)
    8000611e:	79ba                	ld	s3,424(sp)
    80006120:	7a1a                	ld	s4,416(sp)
    80006122:	6afa                	ld	s5,408(sp)
    80006124:	6b5a                	ld	s6,400(sp)
    80006126:	a8a9                	j	80006180 <sys_exec+0x126>
      argv[i] = 0;
    80006128:	0009079b          	sext.w	a5,s2
    8000612c:	e4040593          	addi	a1,s0,-448
    80006130:	078e                	slli	a5,a5,0x3
    80006132:	97ae                	add	a5,a5,a1
    80006134:	0007b023          	sd	zero,0(a5)
  int ret = exec(path, argv);
    80006138:	f4040513          	addi	a0,s0,-192
    8000613c:	fffff097          	auipc	ra,0xfffff
    80006140:	128080e7          	jalr	296(ra) # 80005264 <exec>
    80006144:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006146:	f4040993          	addi	s3,s0,-192
    8000614a:	6088                	ld	a0,0(s1)
    8000614c:	cd11                	beqz	a0,80006168 <sys_exec+0x10e>
    kfree(argv[i]);
    8000614e:	ffffb097          	auipc	ra,0xffffb
    80006152:	8fe080e7          	jalr	-1794(ra) # 80000a4c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006156:	04a1                	addi	s1,s1,8
    80006158:	ff3499e3          	bne	s1,s3,8000614a <sys_exec+0xf0>
    8000615c:	74fa                	ld	s1,440(sp)
    8000615e:	79ba                	ld	s3,424(sp)
    80006160:	7a1a                	ld	s4,416(sp)
    80006162:	6afa                	ld	s5,408(sp)
    80006164:	6b5a                	ld	s6,400(sp)
    80006166:	a829                	j	80006180 <sys_exec+0x126>
  return ret;
    80006168:	74fa                	ld	s1,440(sp)
    8000616a:	79ba                	ld	s3,424(sp)
    8000616c:	7a1a                	ld	s4,416(sp)
    8000616e:	6afa                	ld	s5,408(sp)
    80006170:	6b5a                	ld	s6,400(sp)
    80006172:	a039                	j	80006180 <sys_exec+0x126>
  return -1;
    80006174:	597d                	li	s2,-1
    80006176:	74fa                	ld	s1,440(sp)
    80006178:	79ba                	ld	s3,424(sp)
    8000617a:	7a1a                	ld	s4,416(sp)
    8000617c:	6afa                	ld	s5,408(sp)
    8000617e:	6b5a                	ld	s6,400(sp)
}
    80006180:	854a                	mv	a0,s2
    80006182:	60be                	ld	ra,456(sp)
    80006184:	641e                	ld	s0,448(sp)
    80006186:	795a                	ld	s2,432(sp)
    80006188:	6179                	addi	sp,sp,464
    8000618a:	8082                	ret

000000008000618c <sys_pipe>:

uint64
sys_pipe(void)
{
    8000618c:	7139                	addi	sp,sp,-64
    8000618e:	fc06                	sd	ra,56(sp)
    80006190:	f822                	sd	s0,48(sp)
    80006192:	f426                	sd	s1,40(sp)
    80006194:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006196:	ffffc097          	auipc	ra,0xffffc
    8000619a:	8f0080e7          	jalr	-1808(ra) # 80001a86 <myproc>
    8000619e:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    800061a0:	fd840593          	addi	a1,s0,-40
    800061a4:	4501                	li	a0,0
    800061a6:	ffffd097          	auipc	ra,0xffffd
    800061aa:	d86080e7          	jalr	-634(ra) # 80002f2c <argaddr>
    return -1;
    800061ae:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    800061b0:	0e054363          	bltz	a0,80006296 <sys_pipe+0x10a>
  if(pipealloc(&rf, &wf) < 0)
    800061b4:	fc840593          	addi	a1,s0,-56
    800061b8:	fd040513          	addi	a0,s0,-48
    800061bc:	fffff097          	auipc	ra,0xfffff
    800061c0:	d3a080e7          	jalr	-710(ra) # 80004ef6 <pipealloc>
    return -1;
    800061c4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800061c6:	0c054863          	bltz	a0,80006296 <sys_pipe+0x10a>
  fd0 = -1;
    800061ca:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800061ce:	fd043503          	ld	a0,-48(s0)
    800061d2:	fffff097          	auipc	ra,0xfffff
    800061d6:	4b0080e7          	jalr	1200(ra) # 80005682 <fdalloc>
    800061da:	fca42223          	sw	a0,-60(s0)
    800061de:	08054f63          	bltz	a0,8000627c <sys_pipe+0xf0>
    800061e2:	fc843503          	ld	a0,-56(s0)
    800061e6:	fffff097          	auipc	ra,0xfffff
    800061ea:	49c080e7          	jalr	1180(ra) # 80005682 <fdalloc>
    800061ee:	fca42023          	sw	a0,-64(s0)
    800061f2:	06054b63          	bltz	a0,80006268 <sys_pipe+0xdc>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800061f6:	4691                	li	a3,4
    800061f8:	fc440613          	addi	a2,s0,-60
    800061fc:	fd843583          	ld	a1,-40(s0)
    80006200:	68a8                	ld	a0,80(s1)
    80006202:	ffffb097          	auipc	ra,0xffffb
    80006206:	508080e7          	jalr	1288(ra) # 8000170a <copyout>
    8000620a:	02054063          	bltz	a0,8000622a <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000620e:	4691                	li	a3,4
    80006210:	fc040613          	addi	a2,s0,-64
    80006214:	fd843583          	ld	a1,-40(s0)
    80006218:	95b6                	add	a1,a1,a3
    8000621a:	68a8                	ld	a0,80(s1)
    8000621c:	ffffb097          	auipc	ra,0xffffb
    80006220:	4ee080e7          	jalr	1262(ra) # 8000170a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006224:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006226:	06055863          	bgez	a0,80006296 <sys_pipe+0x10a>
    p->ofile[fd0] = 0;
    8000622a:	fc442783          	lw	a5,-60(s0)
    8000622e:	078e                	slli	a5,a5,0x3
    80006230:	0d078793          	addi	a5,a5,208
    80006234:	97a6                	add	a5,a5,s1
    80006236:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000623a:	fc042783          	lw	a5,-64(s0)
    8000623e:	078e                	slli	a5,a5,0x3
    80006240:	0d078793          	addi	a5,a5,208
    80006244:	00f48533          	add	a0,s1,a5
    80006248:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    8000624c:	fd043503          	ld	a0,-48(s0)
    80006250:	fffff097          	auipc	ra,0xfffff
    80006254:	926080e7          	jalr	-1754(ra) # 80004b76 <fileclose>
    fileclose(wf);
    80006258:	fc843503          	ld	a0,-56(s0)
    8000625c:	fffff097          	auipc	ra,0xfffff
    80006260:	91a080e7          	jalr	-1766(ra) # 80004b76 <fileclose>
    return -1;
    80006264:	57fd                	li	a5,-1
    80006266:	a805                	j	80006296 <sys_pipe+0x10a>
    if(fd0 >= 0)
    80006268:	fc442783          	lw	a5,-60(s0)
    8000626c:	0007c863          	bltz	a5,8000627c <sys_pipe+0xf0>
      p->ofile[fd0] = 0;
    80006270:	078e                	slli	a5,a5,0x3
    80006272:	0d078793          	addi	a5,a5,208
    80006276:	97a6                	add	a5,a5,s1
    80006278:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000627c:	fd043503          	ld	a0,-48(s0)
    80006280:	fffff097          	auipc	ra,0xfffff
    80006284:	8f6080e7          	jalr	-1802(ra) # 80004b76 <fileclose>
    fileclose(wf);
    80006288:	fc843503          	ld	a0,-56(s0)
    8000628c:	fffff097          	auipc	ra,0xfffff
    80006290:	8ea080e7          	jalr	-1814(ra) # 80004b76 <fileclose>
    return -1;
    80006294:	57fd                	li	a5,-1
}
    80006296:	853e                	mv	a0,a5
    80006298:	70e2                	ld	ra,56(sp)
    8000629a:	7442                	ld	s0,48(sp)
    8000629c:	74a2                	ld	s1,40(sp)
    8000629e:	6121                	addi	sp,sp,64
    800062a0:	8082                	ret
	...

00000000800062b0 <kernelvec>:
    800062b0:	7111                	addi	sp,sp,-256
    800062b2:	e006                	sd	ra,0(sp)
    800062b4:	e40a                	sd	sp,8(sp)
    800062b6:	e80e                	sd	gp,16(sp)
    800062b8:	ec12                	sd	tp,24(sp)
    800062ba:	f016                	sd	t0,32(sp)
    800062bc:	f41a                	sd	t1,40(sp)
    800062be:	f81e                	sd	t2,48(sp)
    800062c0:	fc22                	sd	s0,56(sp)
    800062c2:	e0a6                	sd	s1,64(sp)
    800062c4:	e4aa                	sd	a0,72(sp)
    800062c6:	e8ae                	sd	a1,80(sp)
    800062c8:	ecb2                	sd	a2,88(sp)
    800062ca:	f0b6                	sd	a3,96(sp)
    800062cc:	f4ba                	sd	a4,104(sp)
    800062ce:	f8be                	sd	a5,112(sp)
    800062d0:	fcc2                	sd	a6,120(sp)
    800062d2:	e146                	sd	a7,128(sp)
    800062d4:	e54a                	sd	s2,136(sp)
    800062d6:	e94e                	sd	s3,144(sp)
    800062d8:	ed52                	sd	s4,152(sp)
    800062da:	f156                	sd	s5,160(sp)
    800062dc:	f55a                	sd	s6,168(sp)
    800062de:	f95e                	sd	s7,176(sp)
    800062e0:	fd62                	sd	s8,184(sp)
    800062e2:	e1e6                	sd	s9,192(sp)
    800062e4:	e5ea                	sd	s10,200(sp)
    800062e6:	e9ee                	sd	s11,208(sp)
    800062e8:	edf2                	sd	t3,216(sp)
    800062ea:	f1f6                	sd	t4,224(sp)
    800062ec:	f5fa                	sd	t5,232(sp)
    800062ee:	f9fe                	sd	t6,240(sp)
    800062f0:	a75fc0ef          	jal	80002d64 <kerneltrap>
    800062f4:	6082                	ld	ra,0(sp)
    800062f6:	6122                	ld	sp,8(sp)
    800062f8:	61c2                	ld	gp,16(sp)
    800062fa:	7282                	ld	t0,32(sp)
    800062fc:	7322                	ld	t1,40(sp)
    800062fe:	73c2                	ld	t2,48(sp)
    80006300:	7462                	ld	s0,56(sp)
    80006302:	6486                	ld	s1,64(sp)
    80006304:	6526                	ld	a0,72(sp)
    80006306:	65c6                	ld	a1,80(sp)
    80006308:	6666                	ld	a2,88(sp)
    8000630a:	7686                	ld	a3,96(sp)
    8000630c:	7726                	ld	a4,104(sp)
    8000630e:	77c6                	ld	a5,112(sp)
    80006310:	7866                	ld	a6,120(sp)
    80006312:	688a                	ld	a7,128(sp)
    80006314:	692a                	ld	s2,136(sp)
    80006316:	69ca                	ld	s3,144(sp)
    80006318:	6a6a                	ld	s4,152(sp)
    8000631a:	7a8a                	ld	s5,160(sp)
    8000631c:	7b2a                	ld	s6,168(sp)
    8000631e:	7bca                	ld	s7,176(sp)
    80006320:	7c6a                	ld	s8,184(sp)
    80006322:	6c8e                	ld	s9,192(sp)
    80006324:	6d2e                	ld	s10,200(sp)
    80006326:	6dce                	ld	s11,208(sp)
    80006328:	6e6e                	ld	t3,216(sp)
    8000632a:	7e8e                	ld	t4,224(sp)
    8000632c:	7f2e                	ld	t5,232(sp)
    8000632e:	7fce                	ld	t6,240(sp)
    80006330:	6111                	addi	sp,sp,256
    80006332:	10200073          	sret
    80006336:	00000013          	nop
    8000633a:	00000013          	nop
    8000633e:	0001                	nop

0000000080006340 <timervec>:
    80006340:	34051573          	csrrw	a0,mscratch,a0
    80006344:	e10c                	sd	a1,0(a0)
    80006346:	e510                	sd	a2,8(a0)
    80006348:	e914                	sd	a3,16(a0)
    8000634a:	6d0c                	ld	a1,24(a0)
    8000634c:	7110                	ld	a2,32(a0)
    8000634e:	6194                	ld	a3,0(a1)
    80006350:	96b2                	add	a3,a3,a2
    80006352:	e194                	sd	a3,0(a1)
    80006354:	4589                	li	a1,2
    80006356:	14459073          	csrw	sip,a1
    8000635a:	6914                	ld	a3,16(a0)
    8000635c:	6510                	ld	a2,8(a0)
    8000635e:	610c                	ld	a1,0(a0)
    80006360:	34051573          	csrrw	a0,mscratch,a0
    80006364:	30200073          	mret
    80006368:	0001                	nop

000000008000636a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000636a:	1141                	addi	sp,sp,-16
    8000636c:	e406                	sd	ra,8(sp)
    8000636e:	e022                	sd	s0,0(sp)
    80006370:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006372:	0c000737          	lui	a4,0xc000
    80006376:	4785                	li	a5,1
    80006378:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000637a:	c35c                	sw	a5,4(a4)
}
    8000637c:	60a2                	ld	ra,8(sp)
    8000637e:	6402                	ld	s0,0(sp)
    80006380:	0141                	addi	sp,sp,16
    80006382:	8082                	ret

0000000080006384 <plicinithart>:

void
plicinithart(void)
{
    80006384:	1141                	addi	sp,sp,-16
    80006386:	e406                	sd	ra,8(sp)
    80006388:	e022                	sd	s0,0(sp)
    8000638a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000638c:	ffffb097          	auipc	ra,0xffffb
    80006390:	6c6080e7          	jalr	1734(ra) # 80001a52 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006394:	0085171b          	slliw	a4,a0,0x8
    80006398:	0c0027b7          	lui	a5,0xc002
    8000639c:	97ba                	add	a5,a5,a4
    8000639e:	40200713          	li	a4,1026
    800063a2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800063a6:	00d5151b          	slliw	a0,a0,0xd
    800063aa:	0c2017b7          	lui	a5,0xc201
    800063ae:	97aa                	add	a5,a5,a0
    800063b0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800063b4:	60a2                	ld	ra,8(sp)
    800063b6:	6402                	ld	s0,0(sp)
    800063b8:	0141                	addi	sp,sp,16
    800063ba:	8082                	ret

00000000800063bc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800063bc:	1141                	addi	sp,sp,-16
    800063be:	e406                	sd	ra,8(sp)
    800063c0:	e022                	sd	s0,0(sp)
    800063c2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800063c4:	ffffb097          	auipc	ra,0xffffb
    800063c8:	68e080e7          	jalr	1678(ra) # 80001a52 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800063cc:	00d5151b          	slliw	a0,a0,0xd
    800063d0:	0c2017b7          	lui	a5,0xc201
    800063d4:	97aa                	add	a5,a5,a0
  return irq;
}
    800063d6:	43c8                	lw	a0,4(a5)
    800063d8:	60a2                	ld	ra,8(sp)
    800063da:	6402                	ld	s0,0(sp)
    800063dc:	0141                	addi	sp,sp,16
    800063de:	8082                	ret

00000000800063e0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800063e0:	1101                	addi	sp,sp,-32
    800063e2:	ec06                	sd	ra,24(sp)
    800063e4:	e822                	sd	s0,16(sp)
    800063e6:	e426                	sd	s1,8(sp)
    800063e8:	1000                	addi	s0,sp,32
    800063ea:	84aa                	mv	s1,a0
  int hart = cpuid();
    800063ec:	ffffb097          	auipc	ra,0xffffb
    800063f0:	666080e7          	jalr	1638(ra) # 80001a52 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800063f4:	00d5179b          	slliw	a5,a0,0xd
    800063f8:	0c201737          	lui	a4,0xc201
    800063fc:	97ba                	add	a5,a5,a4
    800063fe:	c3c4                	sw	s1,4(a5)
}
    80006400:	60e2                	ld	ra,24(sp)
    80006402:	6442                	ld	s0,16(sp)
    80006404:	64a2                	ld	s1,8(sp)
    80006406:	6105                	addi	sp,sp,32
    80006408:	8082                	ret

000000008000640a <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000640a:	1141                	addi	sp,sp,-16
    8000640c:	e406                	sd	ra,8(sp)
    8000640e:	e022                	sd	s0,0(sp)
    80006410:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006412:	479d                	li	a5,7
    80006414:	06a7c863          	blt	a5,a0,80006484 <free_desc+0x7a>
    panic("free_desc 1");
  if(disk.free[i])
    80006418:	00021717          	auipc	a4,0x21
    8000641c:	be870713          	addi	a4,a4,-1048 # 80027000 <disk>
    80006420:	972a                	add	a4,a4,a0
    80006422:	6789                	lui	a5,0x2
    80006424:	97ba                	add	a5,a5,a4
    80006426:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    8000642a:	e7ad                	bnez	a5,80006494 <free_desc+0x8a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000642c:	00451793          	slli	a5,a0,0x4
    80006430:	00023717          	auipc	a4,0x23
    80006434:	bd070713          	addi	a4,a4,-1072 # 80029000 <disk+0x2000>
    80006438:	6314                	ld	a3,0(a4)
    8000643a:	96be                	add	a3,a3,a5
    8000643c:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006440:	6314                	ld	a3,0(a4)
    80006442:	96be                	add	a3,a3,a5
    80006444:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006448:	6314                	ld	a3,0(a4)
    8000644a:	96be                	add	a3,a3,a5
    8000644c:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80006450:	6318                	ld	a4,0(a4)
    80006452:	97ba                	add	a5,a5,a4
    80006454:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006458:	00021717          	auipc	a4,0x21
    8000645c:	ba870713          	addi	a4,a4,-1112 # 80027000 <disk>
    80006460:	972a                	add	a4,a4,a0
    80006462:	6789                	lui	a5,0x2
    80006464:	97ba                	add	a5,a5,a4
    80006466:	4705                	li	a4,1
    80006468:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000646c:	00023517          	auipc	a0,0x23
    80006470:	bac50513          	addi	a0,a0,-1108 # 80029018 <disk+0x2018>
    80006474:	ffffc097          	auipc	ra,0xffffc
    80006478:	fce080e7          	jalr	-50(ra) # 80002442 <wakeup>
}
    8000647c:	60a2                	ld	ra,8(sp)
    8000647e:	6402                	ld	s0,0(sp)
    80006480:	0141                	addi	sp,sp,16
    80006482:	8082                	ret
    panic("free_desc 1");
    80006484:	00002517          	auipc	a0,0x2
    80006488:	2fc50513          	addi	a0,a0,764 # 80008780 <etext+0x780>
    8000648c:	ffffa097          	auipc	ra,0xffffa
    80006490:	0ca080e7          	jalr	202(ra) # 80000556 <panic>
    panic("free_desc 2");
    80006494:	00002517          	auipc	a0,0x2
    80006498:	2fc50513          	addi	a0,a0,764 # 80008790 <etext+0x790>
    8000649c:	ffffa097          	auipc	ra,0xffffa
    800064a0:	0ba080e7          	jalr	186(ra) # 80000556 <panic>

00000000800064a4 <virtio_disk_init>:
{
    800064a4:	1141                	addi	sp,sp,-16
    800064a6:	e406                	sd	ra,8(sp)
    800064a8:	e022                	sd	s0,0(sp)
    800064aa:	0800                	addi	s0,sp,16
  initlock(&disk.vdisk_lock, "virtio_disk");
    800064ac:	00002597          	auipc	a1,0x2
    800064b0:	2f458593          	addi	a1,a1,756 # 800087a0 <etext+0x7a0>
    800064b4:	00023517          	auipc	a0,0x23
    800064b8:	c7450513          	addi	a0,a0,-908 # 80029128 <disk+0x2128>
    800064bc:	ffffa097          	auipc	ra,0xffffa
    800064c0:	6fe080e7          	jalr	1790(ra) # 80000bba <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800064c4:	100017b7          	lui	a5,0x10001
    800064c8:	4398                	lw	a4,0(a5)
    800064ca:	2701                	sext.w	a4,a4
    800064cc:	747277b7          	lui	a5,0x74727
    800064d0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800064d4:	0ef71563          	bne	a4,a5,800065be <virtio_disk_init+0x11a>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800064d8:	100017b7          	lui	a5,0x10001
    800064dc:	43dc                	lw	a5,4(a5)
    800064de:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800064e0:	4705                	li	a4,1
    800064e2:	0ce79e63          	bne	a5,a4,800065be <virtio_disk_init+0x11a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800064e6:	100017b7          	lui	a5,0x10001
    800064ea:	479c                	lw	a5,8(a5)
    800064ec:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800064ee:	4709                	li	a4,2
    800064f0:	0ce79763          	bne	a5,a4,800065be <virtio_disk_init+0x11a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800064f4:	100017b7          	lui	a5,0x10001
    800064f8:	47d8                	lw	a4,12(a5)
    800064fa:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800064fc:	554d47b7          	lui	a5,0x554d4
    80006500:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006504:	0af71d63          	bne	a4,a5,800065be <virtio_disk_init+0x11a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006508:	100017b7          	lui	a5,0x10001
    8000650c:	4705                	li	a4,1
    8000650e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006510:	470d                	li	a4,3
    80006512:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006514:	10001737          	lui	a4,0x10001
    80006518:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000651a:	c7ffe6b7          	lui	a3,0xc7ffe
    8000651e:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd475f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006522:	8f75                	and	a4,a4,a3
    80006524:	100016b7          	lui	a3,0x10001
    80006528:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000652a:	472d                	li	a4,11
    8000652c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000652e:	473d                	li	a4,15
    80006530:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006532:	6705                	lui	a4,0x1
    80006534:	d698                	sw	a4,40(a3)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006536:	0206a823          	sw	zero,48(a3) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000653a:	5adc                	lw	a5,52(a3)
    8000653c:	2781                	sext.w	a5,a5
  if(max == 0)
    8000653e:	cbc1                	beqz	a5,800065ce <virtio_disk_init+0x12a>
  if(max < NUM)
    80006540:	471d                	li	a4,7
    80006542:	08f77e63          	bgeu	a4,a5,800065de <virtio_disk_init+0x13a>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006546:	100017b7          	lui	a5,0x10001
    8000654a:	4721                	li	a4,8
    8000654c:	df98                	sw	a4,56(a5)
  memset(disk.pages, 0, sizeof(disk.pages));
    8000654e:	6609                	lui	a2,0x2
    80006550:	4581                	li	a1,0
    80006552:	00021517          	auipc	a0,0x21
    80006556:	aae50513          	addi	a0,a0,-1362 # 80027000 <disk>
    8000655a:	ffffa097          	auipc	ra,0xffffa
    8000655e:	7f2080e7          	jalr	2034(ra) # 80000d4c <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006562:	00021717          	auipc	a4,0x21
    80006566:	a9e70713          	addi	a4,a4,-1378 # 80027000 <disk>
    8000656a:	00c75793          	srli	a5,a4,0xc
    8000656e:	2781                	sext.w	a5,a5
    80006570:	100016b7          	lui	a3,0x10001
    80006574:	c2bc                	sw	a5,64(a3)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006576:	00023797          	auipc	a5,0x23
    8000657a:	a8a78793          	addi	a5,a5,-1398 # 80029000 <disk+0x2000>
    8000657e:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006580:	00021717          	auipc	a4,0x21
    80006584:	b0070713          	addi	a4,a4,-1280 # 80027080 <disk+0x80>
    80006588:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    8000658a:	00022717          	auipc	a4,0x22
    8000658e:	a7670713          	addi	a4,a4,-1418 # 80028000 <disk+0x1000>
    80006592:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006594:	4705                	li	a4,1
    80006596:	00e78c23          	sb	a4,24(a5)
    8000659a:	00e78ca3          	sb	a4,25(a5)
    8000659e:	00e78d23          	sb	a4,26(a5)
    800065a2:	00e78da3          	sb	a4,27(a5)
    800065a6:	00e78e23          	sb	a4,28(a5)
    800065aa:	00e78ea3          	sb	a4,29(a5)
    800065ae:	00e78f23          	sb	a4,30(a5)
    800065b2:	00e78fa3          	sb	a4,31(a5)
}
    800065b6:	60a2                	ld	ra,8(sp)
    800065b8:	6402                	ld	s0,0(sp)
    800065ba:	0141                	addi	sp,sp,16
    800065bc:	8082                	ret
    panic("could not find virtio disk");
    800065be:	00002517          	auipc	a0,0x2
    800065c2:	1f250513          	addi	a0,a0,498 # 800087b0 <etext+0x7b0>
    800065c6:	ffffa097          	auipc	ra,0xffffa
    800065ca:	f90080e7          	jalr	-112(ra) # 80000556 <panic>
    panic("virtio disk has no queue 0");
    800065ce:	00002517          	auipc	a0,0x2
    800065d2:	20250513          	addi	a0,a0,514 # 800087d0 <etext+0x7d0>
    800065d6:	ffffa097          	auipc	ra,0xffffa
    800065da:	f80080e7          	jalr	-128(ra) # 80000556 <panic>
    panic("virtio disk max queue too short");
    800065de:	00002517          	auipc	a0,0x2
    800065e2:	21250513          	addi	a0,a0,530 # 800087f0 <etext+0x7f0>
    800065e6:	ffffa097          	auipc	ra,0xffffa
    800065ea:	f70080e7          	jalr	-144(ra) # 80000556 <panic>

00000000800065ee <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800065ee:	711d                	addi	sp,sp,-96
    800065f0:	ec86                	sd	ra,88(sp)
    800065f2:	e8a2                	sd	s0,80(sp)
    800065f4:	e4a6                	sd	s1,72(sp)
    800065f6:	e0ca                	sd	s2,64(sp)
    800065f8:	fc4e                	sd	s3,56(sp)
    800065fa:	f852                	sd	s4,48(sp)
    800065fc:	f456                	sd	s5,40(sp)
    800065fe:	f05a                	sd	s6,32(sp)
    80006600:	ec5e                	sd	s7,24(sp)
    80006602:	e862                	sd	s8,16(sp)
    80006604:	1080                	addi	s0,sp,96
    80006606:	89aa                	mv	s3,a0
    80006608:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000660a:	00c52b83          	lw	s7,12(a0)
    8000660e:	001b9b9b          	slliw	s7,s7,0x1
    80006612:	1b82                	slli	s7,s7,0x20
    80006614:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80006618:	00023517          	auipc	a0,0x23
    8000661c:	b1050513          	addi	a0,a0,-1264 # 80029128 <disk+0x2128>
    80006620:	ffffa097          	auipc	ra,0xffffa
    80006624:	634080e7          	jalr	1588(ra) # 80000c54 <acquire>
  for(int i = 0; i < NUM; i++){
    80006628:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000662a:	00021b17          	auipc	s6,0x21
    8000662e:	9d6b0b13          	addi	s6,s6,-1578 # 80027000 <disk>
    80006632:	6a89                	lui	s5,0x2
  for(int i = 0; i < 3; i++){
    80006634:	4a0d                	li	s4,3
    80006636:	a88d                	j	800066a8 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006638:	00fb0733          	add	a4,s6,a5
    8000663c:	9756                	add	a4,a4,s5
    8000663e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006642:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006644:	0207c563          	bltz	a5,8000666e <virtio_disk_rw+0x80>
  for(int i = 0; i < 3; i++){
    80006648:	2905                	addiw	s2,s2,1
    8000664a:	0611                	addi	a2,a2,4 # 2004 <_entry-0x7fffdffc>
    8000664c:	1b490063          	beq	s2,s4,800067ec <virtio_disk_rw+0x1fe>
    idx[i] = alloc_desc();
    80006650:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006652:	00023717          	auipc	a4,0x23
    80006656:	9c670713          	addi	a4,a4,-1594 # 80029018 <disk+0x2018>
    8000665a:	4781                	li	a5,0
    if(disk.free[i]){
    8000665c:	00074683          	lbu	a3,0(a4)
    80006660:	fee1                	bnez	a3,80006638 <virtio_disk_rw+0x4a>
  for(int i = 0; i < NUM; i++){
    80006662:	2785                	addiw	a5,a5,1
    80006664:	0705                	addi	a4,a4,1
    80006666:	fe979be3          	bne	a5,s1,8000665c <virtio_disk_rw+0x6e>
    idx[i] = alloc_desc();
    8000666a:	57fd                	li	a5,-1
    8000666c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000666e:	03205163          	blez	s2,80006690 <virtio_disk_rw+0xa2>
        free_desc(idx[j]);
    80006672:	fa042503          	lw	a0,-96(s0)
    80006676:	00000097          	auipc	ra,0x0
    8000667a:	d94080e7          	jalr	-620(ra) # 8000640a <free_desc>
      for(int j = 0; j < i; j++)
    8000667e:	4785                	li	a5,1
    80006680:	0127d863          	bge	a5,s2,80006690 <virtio_disk_rw+0xa2>
        free_desc(idx[j]);
    80006684:	fa442503          	lw	a0,-92(s0)
    80006688:	00000097          	auipc	ra,0x0
    8000668c:	d82080e7          	jalr	-638(ra) # 8000640a <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006690:	00023597          	auipc	a1,0x23
    80006694:	a9858593          	addi	a1,a1,-1384 # 80029128 <disk+0x2128>
    80006698:	00023517          	auipc	a0,0x23
    8000669c:	98050513          	addi	a0,a0,-1664 # 80029018 <disk+0x2018>
    800066a0:	ffffc097          	auipc	ra,0xffffc
    800066a4:	c1c080e7          	jalr	-996(ra) # 800022bc <sleep>
  for(int i = 0; i < 3; i++){
    800066a8:	fa040613          	addi	a2,s0,-96
    800066ac:	4901                	li	s2,0
    800066ae:	b74d                	j	80006650 <virtio_disk_rw+0x62>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800066b0:	00023717          	auipc	a4,0x23
    800066b4:	95073703          	ld	a4,-1712(a4) # 80029000 <disk+0x2000>
    800066b8:	973e                	add	a4,a4,a5
    800066ba:	00071623          	sh	zero,12(a4)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800066be:	00021897          	auipc	a7,0x21
    800066c2:	94288893          	addi	a7,a7,-1726 # 80027000 <disk>
    800066c6:	00023717          	auipc	a4,0x23
    800066ca:	93a70713          	addi	a4,a4,-1734 # 80029000 <disk+0x2000>
    800066ce:	6314                	ld	a3,0(a4)
    800066d0:	96be                	add	a3,a3,a5
    800066d2:	00c6d583          	lhu	a1,12(a3) # 1000100c <_entry-0x6fffeff4>
    800066d6:	0015e593          	ori	a1,a1,1
    800066da:	00b69623          	sh	a1,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800066de:	fa842683          	lw	a3,-88(s0)
    800066e2:	630c                	ld	a1,0(a4)
    800066e4:	97ae                	add	a5,a5,a1
    800066e6:	00d79723          	sh	a3,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800066ea:	20050593          	addi	a1,a0,512
    800066ee:	0592                	slli	a1,a1,0x4
    800066f0:	95c6                	add	a1,a1,a7
    800066f2:	57fd                	li	a5,-1
    800066f4:	02f58823          	sb	a5,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800066f8:	00469793          	slli	a5,a3,0x4
    800066fc:	00073803          	ld	a6,0(a4)
    80006700:	983e                	add	a6,a6,a5
    80006702:	6689                	lui	a3,0x2
    80006704:	03068693          	addi	a3,a3,48 # 2030 <_entry-0x7fffdfd0>
    80006708:	96b2                	add	a3,a3,a2
    8000670a:	96c6                	add	a3,a3,a7
    8000670c:	00d83023          	sd	a3,0(a6)
  disk.desc[idx[2]].len = 1;
    80006710:	6314                	ld	a3,0(a4)
    80006712:	96be                	add	a3,a3,a5
    80006714:	4605                	li	a2,1
    80006716:	c690                	sw	a2,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006718:	6314                	ld	a3,0(a4)
    8000671a:	96be                	add	a3,a3,a5
    8000671c:	4809                	li	a6,2
    8000671e:	01069623          	sh	a6,12(a3)
  disk.desc[idx[2]].next = 0;
    80006722:	6314                	ld	a3,0(a4)
    80006724:	97b6                	add	a5,a5,a3
    80006726:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000672a:	00c9a223          	sw	a2,4(s3)
  disk.info[idx[0]].b = b;
    8000672e:	0335b423          	sd	s3,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006732:	6714                	ld	a3,8(a4)
    80006734:	0026d783          	lhu	a5,2(a3)
    80006738:	8b9d                	andi	a5,a5,7
    8000673a:	0786                	slli	a5,a5,0x1
    8000673c:	96be                	add	a3,a3,a5
    8000673e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006742:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006746:	6718                	ld	a4,8(a4)
    80006748:	00275783          	lhu	a5,2(a4)
    8000674c:	2785                	addiw	a5,a5,1
    8000674e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006752:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006756:	100017b7          	lui	a5,0x10001
    8000675a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000675e:	0049a783          	lw	a5,4(s3)
    80006762:	02c79163          	bne	a5,a2,80006784 <virtio_disk_rw+0x196>
    sleep(b, &disk.vdisk_lock);
    80006766:	00023917          	auipc	s2,0x23
    8000676a:	9c290913          	addi	s2,s2,-1598 # 80029128 <disk+0x2128>
  while(b->disk == 1) {
    8000676e:	84be                	mv	s1,a5
    sleep(b, &disk.vdisk_lock);
    80006770:	85ca                	mv	a1,s2
    80006772:	854e                	mv	a0,s3
    80006774:	ffffc097          	auipc	ra,0xffffc
    80006778:	b48080e7          	jalr	-1208(ra) # 800022bc <sleep>
  while(b->disk == 1) {
    8000677c:	0049a783          	lw	a5,4(s3)
    80006780:	fe9788e3          	beq	a5,s1,80006770 <virtio_disk_rw+0x182>
  }

  disk.info[idx[0]].b = 0;
    80006784:	fa042903          	lw	s2,-96(s0)
    80006788:	20090713          	addi	a4,s2,512
    8000678c:	0712                	slli	a4,a4,0x4
    8000678e:	00021797          	auipc	a5,0x21
    80006792:	87278793          	addi	a5,a5,-1934 # 80027000 <disk>
    80006796:	97ba                	add	a5,a5,a4
    80006798:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    8000679c:	00023997          	auipc	s3,0x23
    800067a0:	86498993          	addi	s3,s3,-1948 # 80029000 <disk+0x2000>
    800067a4:	00491713          	slli	a4,s2,0x4
    800067a8:	0009b783          	ld	a5,0(s3)
    800067ac:	97ba                	add	a5,a5,a4
    800067ae:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800067b2:	854a                	mv	a0,s2
    800067b4:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800067b8:	00000097          	auipc	ra,0x0
    800067bc:	c52080e7          	jalr	-942(ra) # 8000640a <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800067c0:	8885                	andi	s1,s1,1
    800067c2:	f0ed                	bnez	s1,800067a4 <virtio_disk_rw+0x1b6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800067c4:	00023517          	auipc	a0,0x23
    800067c8:	96450513          	addi	a0,a0,-1692 # 80029128 <disk+0x2128>
    800067cc:	ffffa097          	auipc	ra,0xffffa
    800067d0:	538080e7          	jalr	1336(ra) # 80000d04 <release>
}
    800067d4:	60e6                	ld	ra,88(sp)
    800067d6:	6446                	ld	s0,80(sp)
    800067d8:	64a6                	ld	s1,72(sp)
    800067da:	6906                	ld	s2,64(sp)
    800067dc:	79e2                	ld	s3,56(sp)
    800067de:	7a42                	ld	s4,48(sp)
    800067e0:	7aa2                	ld	s5,40(sp)
    800067e2:	7b02                	ld	s6,32(sp)
    800067e4:	6be2                	ld	s7,24(sp)
    800067e6:	6c42                	ld	s8,16(sp)
    800067e8:	6125                	addi	sp,sp,96
    800067ea:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800067ec:	fa042503          	lw	a0,-96(s0)
    800067f0:	00451613          	slli	a2,a0,0x4
  if(write)
    800067f4:	00021597          	auipc	a1,0x21
    800067f8:	80c58593          	addi	a1,a1,-2036 # 80027000 <disk>
    800067fc:	20050793          	addi	a5,a0,512
    80006800:	0792                	slli	a5,a5,0x4
    80006802:	97ae                	add	a5,a5,a1
    80006804:	01803733          	snez	a4,s8
    80006808:	0ae7a423          	sw	a4,168(a5)
  buf0->reserved = 0;
    8000680c:	0a07a623          	sw	zero,172(a5)
  buf0->sector = sector;
    80006810:	0b77b823          	sd	s7,176(a5)
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006814:	00022717          	auipc	a4,0x22
    80006818:	7ec70713          	addi	a4,a4,2028 # 80029000 <disk+0x2000>
    8000681c:	6314                	ld	a3,0(a4)
    8000681e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006820:	6789                	lui	a5,0x2
    80006822:	0a878793          	addi	a5,a5,168 # 20a8 <_entry-0x7fffdf58>
    80006826:	97b2                	add	a5,a5,a2
    80006828:	97ae                	add	a5,a5,a1
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000682a:	e29c                	sd	a5,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000682c:	631c                	ld	a5,0(a4)
    8000682e:	97b2                	add	a5,a5,a2
    80006830:	46c1                	li	a3,16
    80006832:	c794                	sw	a3,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006834:	631c                	ld	a5,0(a4)
    80006836:	97b2                	add	a5,a5,a2
    80006838:	4685                	li	a3,1
    8000683a:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[0]].next = idx[1];
    8000683e:	fa442783          	lw	a5,-92(s0)
    80006842:	6314                	ld	a3,0(a4)
    80006844:	96b2                	add	a3,a3,a2
    80006846:	00f69723          	sh	a5,14(a3)
  disk.desc[idx[1]].addr = (uint64) b->data;
    8000684a:	0792                	slli	a5,a5,0x4
    8000684c:	6314                	ld	a3,0(a4)
    8000684e:	96be                	add	a3,a3,a5
    80006850:	05898593          	addi	a1,s3,88
    80006854:	e28c                	sd	a1,0(a3)
  disk.desc[idx[1]].len = BSIZE;
    80006856:	6318                	ld	a4,0(a4)
    80006858:	973e                	add	a4,a4,a5
    8000685a:	40000693          	li	a3,1024
    8000685e:	c714                	sw	a3,8(a4)
  if(write)
    80006860:	e40c18e3          	bnez	s8,800066b0 <virtio_disk_rw+0xc2>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006864:	00022717          	auipc	a4,0x22
    80006868:	79c73703          	ld	a4,1948(a4) # 80029000 <disk+0x2000>
    8000686c:	973e                	add	a4,a4,a5
    8000686e:	4689                	li	a3,2
    80006870:	00d71623          	sh	a3,12(a4)
    80006874:	b5a9                	j	800066be <virtio_disk_rw+0xd0>

0000000080006876 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006876:	1101                	addi	sp,sp,-32
    80006878:	ec06                	sd	ra,24(sp)
    8000687a:	e822                	sd	s0,16(sp)
    8000687c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000687e:	00023517          	auipc	a0,0x23
    80006882:	8aa50513          	addi	a0,a0,-1878 # 80029128 <disk+0x2128>
    80006886:	ffffa097          	auipc	ra,0xffffa
    8000688a:	3ce080e7          	jalr	974(ra) # 80000c54 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000688e:	100017b7          	lui	a5,0x10001
    80006892:	53bc                	lw	a5,96(a5)
    80006894:	8b8d                	andi	a5,a5,3
    80006896:	10001737          	lui	a4,0x10001
    8000689a:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000689c:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800068a0:	00022797          	auipc	a5,0x22
    800068a4:	76078793          	addi	a5,a5,1888 # 80029000 <disk+0x2000>
    800068a8:	6b94                	ld	a3,16(a5)
    800068aa:	0207d703          	lhu	a4,32(a5)
    800068ae:	0026d783          	lhu	a5,2(a3)
    800068b2:	06f70563          	beq	a4,a5,8000691c <virtio_disk_intr+0xa6>
    800068b6:	e426                	sd	s1,8(sp)
    800068b8:	e04a                	sd	s2,0(sp)
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800068ba:	00020917          	auipc	s2,0x20
    800068be:	74690913          	addi	s2,s2,1862 # 80027000 <disk>
    800068c2:	00022497          	auipc	s1,0x22
    800068c6:	73e48493          	addi	s1,s1,1854 # 80029000 <disk+0x2000>
    __sync_synchronize();
    800068ca:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800068ce:	6898                	ld	a4,16(s1)
    800068d0:	0204d783          	lhu	a5,32(s1)
    800068d4:	8b9d                	andi	a5,a5,7
    800068d6:	078e                	slli	a5,a5,0x3
    800068d8:	97ba                	add	a5,a5,a4
    800068da:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800068dc:	20078713          	addi	a4,a5,512
    800068e0:	0712                	slli	a4,a4,0x4
    800068e2:	974a                	add	a4,a4,s2
    800068e4:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800068e8:	e731                	bnez	a4,80006934 <virtio_disk_intr+0xbe>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800068ea:	20078793          	addi	a5,a5,512
    800068ee:	0792                	slli	a5,a5,0x4
    800068f0:	97ca                	add	a5,a5,s2
    800068f2:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800068f4:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800068f8:	ffffc097          	auipc	ra,0xffffc
    800068fc:	b4a080e7          	jalr	-1206(ra) # 80002442 <wakeup>

    disk.used_idx += 1;
    80006900:	0204d783          	lhu	a5,32(s1)
    80006904:	2785                	addiw	a5,a5,1
    80006906:	17c2                	slli	a5,a5,0x30
    80006908:	93c1                	srli	a5,a5,0x30
    8000690a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000690e:	6898                	ld	a4,16(s1)
    80006910:	00275703          	lhu	a4,2(a4)
    80006914:	faf71be3          	bne	a4,a5,800068ca <virtio_disk_intr+0x54>
    80006918:	64a2                	ld	s1,8(sp)
    8000691a:	6902                	ld	s2,0(sp)
  }

  release(&disk.vdisk_lock);
    8000691c:	00023517          	auipc	a0,0x23
    80006920:	80c50513          	addi	a0,a0,-2036 # 80029128 <disk+0x2128>
    80006924:	ffffa097          	auipc	ra,0xffffa
    80006928:	3e0080e7          	jalr	992(ra) # 80000d04 <release>
}
    8000692c:	60e2                	ld	ra,24(sp)
    8000692e:	6442                	ld	s0,16(sp)
    80006930:	6105                	addi	sp,sp,32
    80006932:	8082                	ret
      panic("virtio_disk_intr status");
    80006934:	00002517          	auipc	a0,0x2
    80006938:	edc50513          	addi	a0,a0,-292 # 80008810 <etext+0x810>
    8000693c:	ffffa097          	auipc	ra,0xffffa
    80006940:	c1a080e7          	jalr	-998(ra) # 80000556 <panic>
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
