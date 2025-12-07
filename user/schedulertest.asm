
user/_schedulertest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#define IO 5

// Importante: usar NPROC (max procesos en xv6, usualmente 64)
#define NPROC 64

int main() {
   0:	d9010113          	addi	sp,sp,-624
   4:	26113423          	sd	ra,616(sp)
   8:	26813023          	sd	s0,608(sp)
   c:	24913c23          	sd	s1,600(sp)
  10:	25213823          	sd	s2,592(sp)
  14:	25313423          	sd	s3,584(sp)
  18:	25413023          	sd	s4,576(sp)
  1c:	23513c23          	sd	s5,568(sp)
  20:	23613823          	sd	s6,560(sp)
  24:	23713423          	sd	s7,552(sp)
  28:	23813023          	sd	s8,544(sp)
  2c:	21913c23          	sd	s9,536(sp)
  30:	21a13823          	sd	s10,528(sp)
  34:	1c80                	addi	s0,sp,624
    int wtime, rtime;

    int tipo[NPROC];
    int prioridad[NPROC];

    printf("\n===== Test PBS Mejorado =====\n");
  36:	00001517          	auipc	a0,0x1
  3a:	a0a50513          	addi	a0,a0,-1526 # a40 <malloc+0x10c>
  3e:	00001097          	auipc	ra,0x1
  42:	83a080e7          	jalr	-1990(ra) # 878 <printf>
    printf("Creando %d procesos (%d IO-bound, %d CPU-bound)\n\n",
  46:	46bd                	li	a3,15
  48:	4615                	li	a2,5
  4a:	45d1                	li	a1,20
  4c:	00001517          	auipc	a0,0x1
  50:	a1450513          	addi	a0,a0,-1516 # a60 <malloc+0x12c>
  54:	00001097          	auipc	ra,0x1
  58:	824080e7          	jalr	-2012(ra) # 878 <printf>
           NFORK, IO, NFORK - IO);

    for (n = 0; n < NFORK; n++) {
  5c:	4901                	li	s2,0
                for (volatile int i = 0; i < 1000000000; i++) {}
            }
            exit(0);
        }
        else {
            if (pid < NPROC)
  5e:	03f00b13          	li	s6,63
                tipo[pid] = (n < IO);

#ifdef PBS
            int pr = (n < IO) ? 80 : 60;
  62:	4a91                	li	s5,4

            setpriority(pr, pid);
  64:	03c00993          	li	s3,60
                tipo[pid] = (n < IO);
  68:	e9840c13          	addi	s8,s0,-360

            if (pid < NPROC)
                prioridad[pid] = pr;
  6c:	d9840b93          	addi	s7,s0,-616
    for (n = 0; n < NFORK; n++) {
  70:	4a51                	li	s4,20
  72:	aab9                	j	1d0 <main+0x1d0>
            if (n < IO) {
  74:	4791                	li	a5,4
  76:	0327dd63          	bge	a5,s2,b0 <main+0xb0>
                for (volatile int i = 0; i < 1000000000; i++) {}
  7a:	d8042a23          	sw	zero,-620(s0)
  7e:	d9442703          	lw	a4,-620(s0)
  82:	2701                	sext.w	a4,a4
  84:	3b9ad7b7          	lui	a5,0x3b9ad
  88:	9ff78793          	addi	a5,a5,-1537 # 3b9ac9ff <__global_pointer$+0x3b9ab20b>
  8c:	00e7cd63          	blt	a5,a4,a6 <main+0xa6>
  90:	873e                	mv	a4,a5
  92:	d9442783          	lw	a5,-620(s0)
  96:	2785                	addiw	a5,a5,1
  98:	d8f42a23          	sw	a5,-620(s0)
  9c:	d9442783          	lw	a5,-620(s0)
  a0:	2781                	sext.w	a5,a5
  a2:	fef758e3          	bge	a4,a5,92 <main+0x92>
            exit(0);
  a6:	4501                	li	a0,0
  a8:	00000097          	auipc	ra,0x0
  ac:	452080e7          	jalr	1106(ra) # 4fa <exit>
                sleep(200);
  b0:	0c800513          	li	a0,200
  b4:	00000097          	auipc	ra,0x0
  b8:	4d6080e7          	jalr	1238(ra) # 58a <sleep>
  bc:	b7ed                	j	a6 <main+0xa6>
                prioridad[pid] = -1;
#endif
        }
    }

    printf("PID   TIPO   PRIO   RTIME   WTIME   TURNAROUND\n");
  be:	00001517          	auipc	a0,0x1
  c2:	9da50513          	addi	a0,a0,-1574 # a98 <malloc+0x164>
  c6:	00000097          	auipc	ra,0x0
  ca:	7b2080e7          	jalr	1970(ra) # 878 <printf>
    printf("-----------------------------------------------------\n");
  ce:	00001517          	auipc	a0,0x1
  d2:	9fa50513          	addi	a0,a0,-1542 # ac8 <malloc+0x194>
  d6:	00000097          	auipc	ra,0x0
  da:	7a2080e7          	jalr	1954(ra) # 878 <printf>

    int total_r = 0, total_w = 0;

    for (; n > 0; n--) {
  de:	15204d63          	bgtz	s2,238 <main+0x238>
    int total_r = 0, total_w = 0;
  e2:	4481                	li	s1,0
  e4:	4981                	li	s3,0
               wtime,
               turnaround
        );
    }

    printf("-----------------------------------------------------\n");
  e6:	00001517          	auipc	a0,0x1
  ea:	9e250513          	addi	a0,a0,-1566 # ac8 <malloc+0x194>
  ee:	00000097          	auipc	ra,0x0
  f2:	78a080e7          	jalr	1930(ra) # 878 <printf>
    printf("Promedio rtime: %d\n", total_r / NFORK);
  f6:	66666937          	lui	s2,0x66666
  fa:	66790913          	addi	s2,s2,1639 # 66666667 <__global_pointer$+0x66664e73>
  fe:	032985b3          	mul	a1,s3,s2
 102:	958d                	srai	a1,a1,0x23
 104:	41f9d99b          	sraiw	s3,s3,0x1f
 108:	413585bb          	subw	a1,a1,s3
 10c:	00001517          	auipc	a0,0x1
 110:	a1c50513          	addi	a0,a0,-1508 # b28 <malloc+0x1f4>
 114:	00000097          	auipc	ra,0x0
 118:	764080e7          	jalr	1892(ra) # 878 <printf>
    printf("Promedio wtime: %d\n", total_w / NFORK);
 11c:	032485b3          	mul	a1,s1,s2
 120:	958d                	srai	a1,a1,0x23
 122:	41f4d49b          	sraiw	s1,s1,0x1f
 126:	9d85                	subw	a1,a1,s1
 128:	00001517          	auipc	a0,0x1
 12c:	a1850513          	addi	a0,a0,-1512 # b40 <malloc+0x20c>
 130:	00000097          	auipc	ra,0x0
 134:	748080e7          	jalr	1864(ra) # 878 <printf>
    printf("=====================================================\n\n");
 138:	00001517          	auipc	a0,0x1
 13c:	a2050513          	addi	a0,a0,-1504 # b58 <malloc+0x224>
 140:	00000097          	auipc	ra,0x0
 144:	738080e7          	jalr	1848(ra) # 878 <printf>

    exit(0);
 148:	4501                	li	a0,0
 14a:	00000097          	auipc	ra,0x0
 14e:	3b0080e7          	jalr	944(ra) # 4fa <exit>
        printf("%3d   %4s   %4d   %5d   %5d   %8d\n",
 152:	00259693          	slli	a3,a1,0x2
 156:	96e2                	add	a3,a3,s8
 158:	4294                	lw	a3,0(a3)
 15a:	00001517          	auipc	a0,0x1
 15e:	9a650513          	addi	a0,a0,-1626 # b00 <malloc+0x1cc>
 162:	00000097          	auipc	ra,0x0
 166:	716080e7          	jalr	1814(ra) # 878 <printf>
    for (; n > 0; n--) {
 16a:	397d                	addiw	s2,s2,-1
 16c:	f6090de3          	beqz	s2,e6 <main+0xe6>
        pid = waitx(0, &rtime, &wtime);
 170:	865a                	mv	a2,s6
 172:	85d6                	mv	a1,s5
 174:	4501                	li	a0,0
 176:	00000097          	auipc	ra,0x0
 17a:	434080e7          	jalr	1076(ra) # 5aa <waitx>
 17e:	85aa                	mv	a1,a0
        int turnaround = rtime + wtime;
 180:	f9842703          	lw	a4,-104(s0)
 184:	f9c42783          	lw	a5,-100(s0)
 188:	00f7083b          	addw	a6,a4,a5
        total_r += rtime;
 18c:	013709bb          	addw	s3,a4,s3
        total_w += wtime;
 190:	9cbd                	addw	s1,s1,a5
        printf("%3d   %4s   %4d   %5d   %5d   %8d\n",
 192:	00aa4d63          	blt	s4,a0,1ac <main+0x1ac>
               (pid < NPROC && tipo[pid]) ? "IO" : "CPU",
 196:	00251693          	slli	a3,a0,0x2
 19a:	96e6                	add	a3,a3,s9
 19c:	4294                	lw	a3,0(a3)
        printf("%3d   %4s   %4d   %5d   %5d   %8d\n",
 19e:	865e                	mv	a2,s7
               (pid < NPROC && tipo[pid]) ? "IO" : "CPU",
 1a0:	dacd                	beqz	a3,152 <main+0x152>
        printf("%3d   %4s   %4d   %5d   %5d   %8d\n",
 1a2:	00001617          	auipc	a2,0x1
 1a6:	88e60613          	addi	a2,a2,-1906 # a30 <malloc+0xfc>
 1aa:	b765                	j	152 <main+0x152>
 1ac:	865e                	mv	a2,s7
 1ae:	86ea                	mv	a3,s10
 1b0:	b76d                	j	15a <main+0x15a>
            setpriority(pr, pid);
 1b2:	85aa                	mv	a1,a0
 1b4:	05000513          	li	a0,80
 1b8:	00000097          	auipc	ra,0x0
 1bc:	3ea080e7          	jalr	1002(ra) # 5a2 <setpriority>
            int pr = (n < IO) ? 80 : 60;
 1c0:	05000793          	li	a5,80
                prioridad[pid] = pr;
 1c4:	048a                	slli	s1,s1,0x2
 1c6:	94de                	add	s1,s1,s7
 1c8:	c09c                	sw	a5,0(s1)
    for (n = 0; n < NFORK; n++) {
 1ca:	2905                	addiw	s2,s2,1
 1cc:	05490663          	beq	s2,s4,218 <main+0x218>
        pid = fork();
 1d0:	00000097          	auipc	ra,0x0
 1d4:	322080e7          	jalr	802(ra) # 4f2 <fork>
 1d8:	84aa                	mv	s1,a0
        if (pid < 0) break;
 1da:	ee0542e3          	bltz	a0,be <main+0xbe>
        if (pid == 0) {
 1de:	e8050be3          	beqz	a0,74 <main+0x74>
            if (pid < NPROC)
 1e2:	02ab4263          	blt	s6,a0,206 <main+0x206>
                tipo[pid] = (n < IO);
 1e6:	00251793          	slli	a5,a0,0x2
 1ea:	97e2                	add	a5,a5,s8
 1ec:	00592713          	slti	a4,s2,5
 1f0:	c398                	sw	a4,0(a5)
            int pr = (n < IO) ? 80 : 60;
 1f2:	fd2ad0e3          	bge	s5,s2,1b2 <main+0x1b2>
            setpriority(pr, pid);
 1f6:	85aa                	mv	a1,a0
 1f8:	854e                	mv	a0,s3
 1fa:	00000097          	auipc	ra,0x0
 1fe:	3a8080e7          	jalr	936(ra) # 5a2 <setpriority>
            int pr = (n < IO) ? 80 : 60;
 202:	87ce                	mv	a5,s3
 204:	b7c1                	j	1c4 <main+0x1c4>
 206:	052adb63          	bge	s5,s2,25c <main+0x25c>
            setpriority(pr, pid);
 20a:	85a6                	mv	a1,s1
 20c:	854e                	mv	a0,s3
 20e:	00000097          	auipc	ra,0x0
 212:	394080e7          	jalr	916(ra) # 5a2 <setpriority>
            if (pid < NPROC)
 216:	bf55                	j	1ca <main+0x1ca>
    printf("PID   TIPO   PRIO   RTIME   WTIME   TURNAROUND\n");
 218:	00001517          	auipc	a0,0x1
 21c:	88050513          	addi	a0,a0,-1920 # a98 <malloc+0x164>
 220:	00000097          	auipc	ra,0x0
 224:	658080e7          	jalr	1624(ra) # 878 <printf>
    printf("-----------------------------------------------------\n");
 228:	00001517          	auipc	a0,0x1
 22c:	8a050513          	addi	a0,a0,-1888 # ac8 <malloc+0x194>
 230:	00000097          	auipc	ra,0x0
 234:	648080e7          	jalr	1608(ra) # 878 <printf>
            int pr = (n < IO) ? 80 : 60;
 238:	4481                	li	s1,0
 23a:	4981                	li	s3,0
        pid = waitx(0, &rtime, &wtime);
 23c:	f9c40b13          	addi	s6,s0,-100
 240:	f9840a93          	addi	s5,s0,-104
        printf("%3d   %4s   %4d   %5d   %5d   %8d\n",
 244:	03f00a13          	li	s4,63
 248:	00000b97          	auipc	s7,0x0
 24c:	7f0b8b93          	addi	s7,s7,2032 # a38 <malloc+0x104>
 250:	5d7d                	li	s10,-1
               (pid < NPROC && tipo[pid]) ? "IO" : "CPU",
 252:	e9840c93          	addi	s9,s0,-360
        printf("%3d   %4s   %4d   %5d   %5d   %8d\n",
 256:	d9840c13          	addi	s8,s0,-616
 25a:	bf19                	j	170 <main+0x170>
            setpriority(pr, pid);
 25c:	85aa                	mv	a1,a0
 25e:	05000513          	li	a0,80
 262:	00000097          	auipc	ra,0x0
 266:	340080e7          	jalr	832(ra) # 5a2 <setpriority>
            if (pid < NPROC)
 26a:	b785                	j	1ca <main+0x1ca>

000000000000026c <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e406                	sd	ra,8(sp)
 270:	e022                	sd	s0,0(sp)
 272:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 274:	87aa                	mv	a5,a0
 276:	0585                	addi	a1,a1,1
 278:	0785                	addi	a5,a5,1
 27a:	fff5c703          	lbu	a4,-1(a1)
 27e:	fee78fa3          	sb	a4,-1(a5)
 282:	fb75                	bnez	a4,276 <strcpy+0xa>
    ;
  return os;
}
 284:	60a2                	ld	ra,8(sp)
 286:	6402                	ld	s0,0(sp)
 288:	0141                	addi	sp,sp,16
 28a:	8082                	ret

000000000000028c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 28c:	1141                	addi	sp,sp,-16
 28e:	e406                	sd	ra,8(sp)
 290:	e022                	sd	s0,0(sp)
 292:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 294:	00054783          	lbu	a5,0(a0)
 298:	cb91                	beqz	a5,2ac <strcmp+0x20>
 29a:	0005c703          	lbu	a4,0(a1)
 29e:	00f71763          	bne	a4,a5,2ac <strcmp+0x20>
    p++, q++;
 2a2:	0505                	addi	a0,a0,1
 2a4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2a6:	00054783          	lbu	a5,0(a0)
 2aa:	fbe5                	bnez	a5,29a <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 2ac:	0005c503          	lbu	a0,0(a1)
}
 2b0:	40a7853b          	subw	a0,a5,a0
 2b4:	60a2                	ld	ra,8(sp)
 2b6:	6402                	ld	s0,0(sp)
 2b8:	0141                	addi	sp,sp,16
 2ba:	8082                	ret

00000000000002bc <strlen>:

uint
strlen(const char *s)
{
 2bc:	1141                	addi	sp,sp,-16
 2be:	e406                	sd	ra,8(sp)
 2c0:	e022                	sd	s0,0(sp)
 2c2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2c4:	00054783          	lbu	a5,0(a0)
 2c8:	cf91                	beqz	a5,2e4 <strlen+0x28>
 2ca:	00150793          	addi	a5,a0,1
 2ce:	86be                	mv	a3,a5
 2d0:	0785                	addi	a5,a5,1
 2d2:	fff7c703          	lbu	a4,-1(a5)
 2d6:	ff65                	bnez	a4,2ce <strlen+0x12>
 2d8:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 2dc:	60a2                	ld	ra,8(sp)
 2de:	6402                	ld	s0,0(sp)
 2e0:	0141                	addi	sp,sp,16
 2e2:	8082                	ret
  for(n = 0; s[n]; n++)
 2e4:	4501                	li	a0,0
 2e6:	bfdd                	j	2dc <strlen+0x20>

00000000000002e8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2e8:	1141                	addi	sp,sp,-16
 2ea:	e406                	sd	ra,8(sp)
 2ec:	e022                	sd	s0,0(sp)
 2ee:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2f0:	ca19                	beqz	a2,306 <memset+0x1e>
 2f2:	87aa                	mv	a5,a0
 2f4:	1602                	slli	a2,a2,0x20
 2f6:	9201                	srli	a2,a2,0x20
 2f8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2fc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 300:	0785                	addi	a5,a5,1
 302:	fee79de3          	bne	a5,a4,2fc <memset+0x14>
  }
  return dst;
}
 306:	60a2                	ld	ra,8(sp)
 308:	6402                	ld	s0,0(sp)
 30a:	0141                	addi	sp,sp,16
 30c:	8082                	ret

000000000000030e <strchr>:

char*
strchr(const char *s, char c)
{
 30e:	1141                	addi	sp,sp,-16
 310:	e406                	sd	ra,8(sp)
 312:	e022                	sd	s0,0(sp)
 314:	0800                	addi	s0,sp,16
  for(; *s; s++)
 316:	00054783          	lbu	a5,0(a0)
 31a:	cf81                	beqz	a5,332 <strchr+0x24>
    if(*s == c)
 31c:	00f58763          	beq	a1,a5,32a <strchr+0x1c>
  for(; *s; s++)
 320:	0505                	addi	a0,a0,1
 322:	00054783          	lbu	a5,0(a0)
 326:	fbfd                	bnez	a5,31c <strchr+0xe>
      return (char*)s;
  return 0;
 328:	4501                	li	a0,0
}
 32a:	60a2                	ld	ra,8(sp)
 32c:	6402                	ld	s0,0(sp)
 32e:	0141                	addi	sp,sp,16
 330:	8082                	ret
  return 0;
 332:	4501                	li	a0,0
 334:	bfdd                	j	32a <strchr+0x1c>

0000000000000336 <gets>:

char*
gets(char *buf, int max)
{
 336:	711d                	addi	sp,sp,-96
 338:	ec86                	sd	ra,88(sp)
 33a:	e8a2                	sd	s0,80(sp)
 33c:	e4a6                	sd	s1,72(sp)
 33e:	e0ca                	sd	s2,64(sp)
 340:	fc4e                	sd	s3,56(sp)
 342:	f852                	sd	s4,48(sp)
 344:	f456                	sd	s5,40(sp)
 346:	f05a                	sd	s6,32(sp)
 348:	ec5e                	sd	s7,24(sp)
 34a:	e862                	sd	s8,16(sp)
 34c:	1080                	addi	s0,sp,96
 34e:	8baa                	mv	s7,a0
 350:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 352:	892a                	mv	s2,a0
 354:	4481                	li	s1,0
    cc = read(0, &c, 1);
 356:	faf40b13          	addi	s6,s0,-81
 35a:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 35c:	8c26                	mv	s8,s1
 35e:	0014899b          	addiw	s3,s1,1
 362:	84ce                	mv	s1,s3
 364:	0349d663          	bge	s3,s4,390 <gets+0x5a>
    cc = read(0, &c, 1);
 368:	8656                	mv	a2,s5
 36a:	85da                	mv	a1,s6
 36c:	4501                	li	a0,0
 36e:	00000097          	auipc	ra,0x0
 372:	1a4080e7          	jalr	420(ra) # 512 <read>
    if(cc < 1)
 376:	00a05d63          	blez	a0,390 <gets+0x5a>
      break;
    buf[i++] = c;
 37a:	faf44783          	lbu	a5,-81(s0)
 37e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 382:	0905                	addi	s2,s2,1
 384:	ff678713          	addi	a4,a5,-10
 388:	c319                	beqz	a4,38e <gets+0x58>
 38a:	17cd                	addi	a5,a5,-13
 38c:	fbe1                	bnez	a5,35c <gets+0x26>
    buf[i++] = c;
 38e:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 390:	9c5e                	add	s8,s8,s7
 392:	000c0023          	sb	zero,0(s8)
  return buf;
}
 396:	855e                	mv	a0,s7
 398:	60e6                	ld	ra,88(sp)
 39a:	6446                	ld	s0,80(sp)
 39c:	64a6                	ld	s1,72(sp)
 39e:	6906                	ld	s2,64(sp)
 3a0:	79e2                	ld	s3,56(sp)
 3a2:	7a42                	ld	s4,48(sp)
 3a4:	7aa2                	ld	s5,40(sp)
 3a6:	7b02                	ld	s6,32(sp)
 3a8:	6be2                	ld	s7,24(sp)
 3aa:	6c42                	ld	s8,16(sp)
 3ac:	6125                	addi	sp,sp,96
 3ae:	8082                	ret

00000000000003b0 <stat>:

int
stat(const char *n, struct stat *st)
{
 3b0:	1101                	addi	sp,sp,-32
 3b2:	ec06                	sd	ra,24(sp)
 3b4:	e822                	sd	s0,16(sp)
 3b6:	e04a                	sd	s2,0(sp)
 3b8:	1000                	addi	s0,sp,32
 3ba:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3bc:	4581                	li	a1,0
 3be:	00000097          	auipc	ra,0x0
 3c2:	17c080e7          	jalr	380(ra) # 53a <open>
  if(fd < 0)
 3c6:	02054663          	bltz	a0,3f2 <stat+0x42>
 3ca:	e426                	sd	s1,8(sp)
 3cc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3ce:	85ca                	mv	a1,s2
 3d0:	00000097          	auipc	ra,0x0
 3d4:	182080e7          	jalr	386(ra) # 552 <fstat>
 3d8:	892a                	mv	s2,a0
  close(fd);
 3da:	8526                	mv	a0,s1
 3dc:	00000097          	auipc	ra,0x0
 3e0:	146080e7          	jalr	326(ra) # 522 <close>
  return r;
 3e4:	64a2                	ld	s1,8(sp)
}
 3e6:	854a                	mv	a0,s2
 3e8:	60e2                	ld	ra,24(sp)
 3ea:	6442                	ld	s0,16(sp)
 3ec:	6902                	ld	s2,0(sp)
 3ee:	6105                	addi	sp,sp,32
 3f0:	8082                	ret
    return -1;
 3f2:	57fd                	li	a5,-1
 3f4:	893e                	mv	s2,a5
 3f6:	bfc5                	j	3e6 <stat+0x36>

00000000000003f8 <atoi>:

int
atoi(const char *s)
{
 3f8:	1141                	addi	sp,sp,-16
 3fa:	e406                	sd	ra,8(sp)
 3fc:	e022                	sd	s0,0(sp)
 3fe:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 400:	00054683          	lbu	a3,0(a0)
 404:	fd06879b          	addiw	a5,a3,-48
 408:	0ff7f793          	zext.b	a5,a5
 40c:	4625                	li	a2,9
 40e:	02f66963          	bltu	a2,a5,440 <atoi+0x48>
 412:	872a                	mv	a4,a0
  n = 0;
 414:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 416:	0705                	addi	a4,a4,1
 418:	0025179b          	slliw	a5,a0,0x2
 41c:	9fa9                	addw	a5,a5,a0
 41e:	0017979b          	slliw	a5,a5,0x1
 422:	9fb5                	addw	a5,a5,a3
 424:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 428:	00074683          	lbu	a3,0(a4)
 42c:	fd06879b          	addiw	a5,a3,-48
 430:	0ff7f793          	zext.b	a5,a5
 434:	fef671e3          	bgeu	a2,a5,416 <atoi+0x1e>
  return n;
}
 438:	60a2                	ld	ra,8(sp)
 43a:	6402                	ld	s0,0(sp)
 43c:	0141                	addi	sp,sp,16
 43e:	8082                	ret
  n = 0;
 440:	4501                	li	a0,0
 442:	bfdd                	j	438 <atoi+0x40>

0000000000000444 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 444:	1141                	addi	sp,sp,-16
 446:	e406                	sd	ra,8(sp)
 448:	e022                	sd	s0,0(sp)
 44a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 44c:	02b57563          	bgeu	a0,a1,476 <memmove+0x32>
    while(n-- > 0)
 450:	00c05f63          	blez	a2,46e <memmove+0x2a>
 454:	1602                	slli	a2,a2,0x20
 456:	9201                	srli	a2,a2,0x20
 458:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 45c:	872a                	mv	a4,a0
      *dst++ = *src++;
 45e:	0585                	addi	a1,a1,1
 460:	0705                	addi	a4,a4,1
 462:	fff5c683          	lbu	a3,-1(a1)
 466:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 46a:	fee79ae3          	bne	a5,a4,45e <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 46e:	60a2                	ld	ra,8(sp)
 470:	6402                	ld	s0,0(sp)
 472:	0141                	addi	sp,sp,16
 474:	8082                	ret
    while(n-- > 0)
 476:	fec05ce3          	blez	a2,46e <memmove+0x2a>
    dst += n;
 47a:	00c50733          	add	a4,a0,a2
    src += n;
 47e:	95b2                	add	a1,a1,a2
 480:	fff6079b          	addiw	a5,a2,-1
 484:	1782                	slli	a5,a5,0x20
 486:	9381                	srli	a5,a5,0x20
 488:	fff7c793          	not	a5,a5
 48c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 48e:	15fd                	addi	a1,a1,-1
 490:	177d                	addi	a4,a4,-1
 492:	0005c683          	lbu	a3,0(a1)
 496:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 49a:	fef71ae3          	bne	a4,a5,48e <memmove+0x4a>
 49e:	bfc1                	j	46e <memmove+0x2a>

00000000000004a0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4a0:	1141                	addi	sp,sp,-16
 4a2:	e406                	sd	ra,8(sp)
 4a4:	e022                	sd	s0,0(sp)
 4a6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4a8:	c61d                	beqz	a2,4d6 <memcmp+0x36>
 4aa:	1602                	slli	a2,a2,0x20
 4ac:	9201                	srli	a2,a2,0x20
 4ae:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 4b2:	00054783          	lbu	a5,0(a0)
 4b6:	0005c703          	lbu	a4,0(a1)
 4ba:	00e79863          	bne	a5,a4,4ca <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 4be:	0505                	addi	a0,a0,1
    p2++;
 4c0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4c2:	fed518e3          	bne	a0,a3,4b2 <memcmp+0x12>
  }
  return 0;
 4c6:	4501                	li	a0,0
 4c8:	a019                	j	4ce <memcmp+0x2e>
      return *p1 - *p2;
 4ca:	40e7853b          	subw	a0,a5,a4
}
 4ce:	60a2                	ld	ra,8(sp)
 4d0:	6402                	ld	s0,0(sp)
 4d2:	0141                	addi	sp,sp,16
 4d4:	8082                	ret
  return 0;
 4d6:	4501                	li	a0,0
 4d8:	bfdd                	j	4ce <memcmp+0x2e>

00000000000004da <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4da:	1141                	addi	sp,sp,-16
 4dc:	e406                	sd	ra,8(sp)
 4de:	e022                	sd	s0,0(sp)
 4e0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4e2:	00000097          	auipc	ra,0x0
 4e6:	f62080e7          	jalr	-158(ra) # 444 <memmove>
}
 4ea:	60a2                	ld	ra,8(sp)
 4ec:	6402                	ld	s0,0(sp)
 4ee:	0141                	addi	sp,sp,16
 4f0:	8082                	ret

00000000000004f2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4f2:	4885                	li	a7,1
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <exit>:
.global exit
exit:
 li a7, SYS_exit
 4fa:	4889                	li	a7,2
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <wait>:
.global wait
wait:
 li a7, SYS_wait
 502:	488d                	li	a7,3
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 50a:	4891                	li	a7,4
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <read>:
.global read
read:
 li a7, SYS_read
 512:	4895                	li	a7,5
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <write>:
.global write
write:
 li a7, SYS_write
 51a:	48c1                	li	a7,16
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <close>:
.global close
close:
 li a7, SYS_close
 522:	48d5                	li	a7,21
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <kill>:
.global kill
kill:
 li a7, SYS_kill
 52a:	4899                	li	a7,6
 ecall
 52c:	00000073          	ecall
 ret
 530:	8082                	ret

0000000000000532 <exec>:
.global exec
exec:
 li a7, SYS_exec
 532:	489d                	li	a7,7
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <open>:
.global open
open:
 li a7, SYS_open
 53a:	48bd                	li	a7,15
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 542:	48c5                	li	a7,17
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 54a:	48c9                	li	a7,18
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 552:	48a1                	li	a7,8
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <link>:
.global link
link:
 li a7, SYS_link
 55a:	48cd                	li	a7,19
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 562:	48d1                	li	a7,20
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 56a:	48a5                	li	a7,9
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <dup>:
.global dup
dup:
 li a7, SYS_dup
 572:	48a9                	li	a7,10
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 57a:	48ad                	li	a7,11
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 582:	48b1                	li	a7,12
 ecall
 584:	00000073          	ecall
 ret
 588:	8082                	ret

000000000000058a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 58a:	48b5                	li	a7,13
 ecall
 58c:	00000073          	ecall
 ret
 590:	8082                	ret

0000000000000592 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 592:	48b9                	li	a7,14
 ecall
 594:	00000073          	ecall
 ret
 598:	8082                	ret

000000000000059a <trace>:
.global trace
trace:
 li a7, SYS_trace
 59a:	48d9                	li	a7,22
 ecall
 59c:	00000073          	ecall
 ret
 5a0:	8082                	ret

00000000000005a2 <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 5a2:	48dd                	li	a7,23
 ecall
 5a4:	00000073          	ecall
 ret
 5a8:	8082                	ret

00000000000005aa <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 5aa:	48e1                	li	a7,24
 ecall
 5ac:	00000073          	ecall
 ret
 5b0:	8082                	ret

00000000000005b2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5b2:	1101                	addi	sp,sp,-32
 5b4:	ec06                	sd	ra,24(sp)
 5b6:	e822                	sd	s0,16(sp)
 5b8:	1000                	addi	s0,sp,32
 5ba:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5be:	4605                	li	a2,1
 5c0:	fef40593          	addi	a1,s0,-17
 5c4:	00000097          	auipc	ra,0x0
 5c8:	f56080e7          	jalr	-170(ra) # 51a <write>
}
 5cc:	60e2                	ld	ra,24(sp)
 5ce:	6442                	ld	s0,16(sp)
 5d0:	6105                	addi	sp,sp,32
 5d2:	8082                	ret

00000000000005d4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5d4:	7139                	addi	sp,sp,-64
 5d6:	fc06                	sd	ra,56(sp)
 5d8:	f822                	sd	s0,48(sp)
 5da:	f04a                	sd	s2,32(sp)
 5dc:	ec4e                	sd	s3,24(sp)
 5de:	0080                	addi	s0,sp,64
 5e0:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5e2:	cad9                	beqz	a3,678 <printint+0xa4>
 5e4:	01f5d79b          	srliw	a5,a1,0x1f
 5e8:	cbc1                	beqz	a5,678 <printint+0xa4>
    neg = 1;
    x = -xx;
 5ea:	40b005bb          	negw	a1,a1
    neg = 1;
 5ee:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 5f0:	fc040993          	addi	s3,s0,-64
  neg = 0;
 5f4:	86ce                	mv	a3,s3
  i = 0;
 5f6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5f8:	00000817          	auipc	a6,0x0
 5fc:	5f880813          	addi	a6,a6,1528 # bf0 <digits>
 600:	88ba                	mv	a7,a4
 602:	0017051b          	addiw	a0,a4,1
 606:	872a                	mv	a4,a0
 608:	02c5f7bb          	remuw	a5,a1,a2
 60c:	1782                	slli	a5,a5,0x20
 60e:	9381                	srli	a5,a5,0x20
 610:	97c2                	add	a5,a5,a6
 612:	0007c783          	lbu	a5,0(a5)
 616:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 61a:	87ae                	mv	a5,a1
 61c:	02c5d5bb          	divuw	a1,a1,a2
 620:	0685                	addi	a3,a3,1
 622:	fcc7ffe3          	bgeu	a5,a2,600 <printint+0x2c>
  if(neg)
 626:	00030c63          	beqz	t1,63e <printint+0x6a>
    buf[i++] = '-';
 62a:	fd050793          	addi	a5,a0,-48
 62e:	00878533          	add	a0,a5,s0
 632:	02d00793          	li	a5,45
 636:	fef50823          	sb	a5,-16(a0)
 63a:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 63e:	02e05763          	blez	a4,66c <printint+0x98>
 642:	f426                	sd	s1,40(sp)
 644:	377d                	addiw	a4,a4,-1
 646:	00e984b3          	add	s1,s3,a4
 64a:	19fd                	addi	s3,s3,-1
 64c:	99ba                	add	s3,s3,a4
 64e:	1702                	slli	a4,a4,0x20
 650:	9301                	srli	a4,a4,0x20
 652:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 656:	0004c583          	lbu	a1,0(s1)
 65a:	854a                	mv	a0,s2
 65c:	00000097          	auipc	ra,0x0
 660:	f56080e7          	jalr	-170(ra) # 5b2 <putc>
  while(--i >= 0)
 664:	14fd                	addi	s1,s1,-1
 666:	ff3498e3          	bne	s1,s3,656 <printint+0x82>
 66a:	74a2                	ld	s1,40(sp)
}
 66c:	70e2                	ld	ra,56(sp)
 66e:	7442                	ld	s0,48(sp)
 670:	7902                	ld	s2,32(sp)
 672:	69e2                	ld	s3,24(sp)
 674:	6121                	addi	sp,sp,64
 676:	8082                	ret
  neg = 0;
 678:	4301                	li	t1,0
 67a:	bf9d                	j	5f0 <printint+0x1c>

000000000000067c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 67c:	715d                	addi	sp,sp,-80
 67e:	e486                	sd	ra,72(sp)
 680:	e0a2                	sd	s0,64(sp)
 682:	f84a                	sd	s2,48(sp)
 684:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 686:	0005c903          	lbu	s2,0(a1)
 68a:	1a090b63          	beqz	s2,840 <vprintf+0x1c4>
 68e:	fc26                	sd	s1,56(sp)
 690:	f44e                	sd	s3,40(sp)
 692:	f052                	sd	s4,32(sp)
 694:	ec56                	sd	s5,24(sp)
 696:	e85a                	sd	s6,16(sp)
 698:	e45e                	sd	s7,8(sp)
 69a:	8aaa                	mv	s5,a0
 69c:	8bb2                	mv	s7,a2
 69e:	00158493          	addi	s1,a1,1
  state = 0;
 6a2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 6a4:	02500a13          	li	s4,37
 6a8:	4b55                	li	s6,21
 6aa:	a839                	j	6c8 <vprintf+0x4c>
        putc(fd, c);
 6ac:	85ca                	mv	a1,s2
 6ae:	8556                	mv	a0,s5
 6b0:	00000097          	auipc	ra,0x0
 6b4:	f02080e7          	jalr	-254(ra) # 5b2 <putc>
 6b8:	a019                	j	6be <vprintf+0x42>
    } else if(state == '%'){
 6ba:	01498d63          	beq	s3,s4,6d4 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 6be:	0485                	addi	s1,s1,1
 6c0:	fff4c903          	lbu	s2,-1(s1)
 6c4:	16090863          	beqz	s2,834 <vprintf+0x1b8>
    if(state == 0){
 6c8:	fe0999e3          	bnez	s3,6ba <vprintf+0x3e>
      if(c == '%'){
 6cc:	ff4910e3          	bne	s2,s4,6ac <vprintf+0x30>
        state = '%';
 6d0:	89d2                	mv	s3,s4
 6d2:	b7f5                	j	6be <vprintf+0x42>
      if(c == 'd'){
 6d4:	13490563          	beq	s2,s4,7fe <vprintf+0x182>
 6d8:	f9d9079b          	addiw	a5,s2,-99
 6dc:	0ff7f793          	zext.b	a5,a5
 6e0:	12fb6863          	bltu	s6,a5,810 <vprintf+0x194>
 6e4:	f9d9079b          	addiw	a5,s2,-99
 6e8:	0ff7f713          	zext.b	a4,a5
 6ec:	12eb6263          	bltu	s6,a4,810 <vprintf+0x194>
 6f0:	00271793          	slli	a5,a4,0x2
 6f4:	00000717          	auipc	a4,0x0
 6f8:	4a470713          	addi	a4,a4,1188 # b98 <malloc+0x264>
 6fc:	97ba                	add	a5,a5,a4
 6fe:	439c                	lw	a5,0(a5)
 700:	97ba                	add	a5,a5,a4
 702:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 704:	008b8913          	addi	s2,s7,8
 708:	4685                	li	a3,1
 70a:	4629                	li	a2,10
 70c:	000ba583          	lw	a1,0(s7)
 710:	8556                	mv	a0,s5
 712:	00000097          	auipc	ra,0x0
 716:	ec2080e7          	jalr	-318(ra) # 5d4 <printint>
 71a:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 71c:	4981                	li	s3,0
 71e:	b745                	j	6be <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 720:	008b8913          	addi	s2,s7,8
 724:	4681                	li	a3,0
 726:	4629                	li	a2,10
 728:	000ba583          	lw	a1,0(s7)
 72c:	8556                	mv	a0,s5
 72e:	00000097          	auipc	ra,0x0
 732:	ea6080e7          	jalr	-346(ra) # 5d4 <printint>
 736:	8bca                	mv	s7,s2
      state = 0;
 738:	4981                	li	s3,0
 73a:	b751                	j	6be <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 73c:	008b8913          	addi	s2,s7,8
 740:	4681                	li	a3,0
 742:	4641                	li	a2,16
 744:	000ba583          	lw	a1,0(s7)
 748:	8556                	mv	a0,s5
 74a:	00000097          	auipc	ra,0x0
 74e:	e8a080e7          	jalr	-374(ra) # 5d4 <printint>
 752:	8bca                	mv	s7,s2
      state = 0;
 754:	4981                	li	s3,0
 756:	b7a5                	j	6be <vprintf+0x42>
 758:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 75a:	008b8793          	addi	a5,s7,8
 75e:	8c3e                	mv	s8,a5
 760:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 764:	03000593          	li	a1,48
 768:	8556                	mv	a0,s5
 76a:	00000097          	auipc	ra,0x0
 76e:	e48080e7          	jalr	-440(ra) # 5b2 <putc>
  putc(fd, 'x');
 772:	07800593          	li	a1,120
 776:	8556                	mv	a0,s5
 778:	00000097          	auipc	ra,0x0
 77c:	e3a080e7          	jalr	-454(ra) # 5b2 <putc>
 780:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 782:	00000b97          	auipc	s7,0x0
 786:	46eb8b93          	addi	s7,s7,1134 # bf0 <digits>
 78a:	03c9d793          	srli	a5,s3,0x3c
 78e:	97de                	add	a5,a5,s7
 790:	0007c583          	lbu	a1,0(a5)
 794:	8556                	mv	a0,s5
 796:	00000097          	auipc	ra,0x0
 79a:	e1c080e7          	jalr	-484(ra) # 5b2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 79e:	0992                	slli	s3,s3,0x4
 7a0:	397d                	addiw	s2,s2,-1
 7a2:	fe0914e3          	bnez	s2,78a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
 7a6:	8be2                	mv	s7,s8
      state = 0;
 7a8:	4981                	li	s3,0
 7aa:	6c02                	ld	s8,0(sp)
 7ac:	bf09                	j	6be <vprintf+0x42>
        s = va_arg(ap, char*);
 7ae:	008b8993          	addi	s3,s7,8
 7b2:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 7b6:	02090163          	beqz	s2,7d8 <vprintf+0x15c>
        while(*s != 0){
 7ba:	00094583          	lbu	a1,0(s2)
 7be:	c9a5                	beqz	a1,82e <vprintf+0x1b2>
          putc(fd, *s);
 7c0:	8556                	mv	a0,s5
 7c2:	00000097          	auipc	ra,0x0
 7c6:	df0080e7          	jalr	-528(ra) # 5b2 <putc>
          s++;
 7ca:	0905                	addi	s2,s2,1
        while(*s != 0){
 7cc:	00094583          	lbu	a1,0(s2)
 7d0:	f9e5                	bnez	a1,7c0 <vprintf+0x144>
        s = va_arg(ap, char*);
 7d2:	8bce                	mv	s7,s3
      state = 0;
 7d4:	4981                	li	s3,0
 7d6:	b5e5                	j	6be <vprintf+0x42>
          s = "(null)";
 7d8:	00000917          	auipc	s2,0x0
 7dc:	3b890913          	addi	s2,s2,952 # b90 <malloc+0x25c>
        while(*s != 0){
 7e0:	02800593          	li	a1,40
 7e4:	bff1                	j	7c0 <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
 7e6:	008b8913          	addi	s2,s7,8
 7ea:	000bc583          	lbu	a1,0(s7)
 7ee:	8556                	mv	a0,s5
 7f0:	00000097          	auipc	ra,0x0
 7f4:	dc2080e7          	jalr	-574(ra) # 5b2 <putc>
 7f8:	8bca                	mv	s7,s2
      state = 0;
 7fa:	4981                	li	s3,0
 7fc:	b5c9                	j	6be <vprintf+0x42>
        putc(fd, c);
 7fe:	02500593          	li	a1,37
 802:	8556                	mv	a0,s5
 804:	00000097          	auipc	ra,0x0
 808:	dae080e7          	jalr	-594(ra) # 5b2 <putc>
      state = 0;
 80c:	4981                	li	s3,0
 80e:	bd45                	j	6be <vprintf+0x42>
        putc(fd, '%');
 810:	02500593          	li	a1,37
 814:	8556                	mv	a0,s5
 816:	00000097          	auipc	ra,0x0
 81a:	d9c080e7          	jalr	-612(ra) # 5b2 <putc>
        putc(fd, c);
 81e:	85ca                	mv	a1,s2
 820:	8556                	mv	a0,s5
 822:	00000097          	auipc	ra,0x0
 826:	d90080e7          	jalr	-624(ra) # 5b2 <putc>
      state = 0;
 82a:	4981                	li	s3,0
 82c:	bd49                	j	6be <vprintf+0x42>
        s = va_arg(ap, char*);
 82e:	8bce                	mv	s7,s3
      state = 0;
 830:	4981                	li	s3,0
 832:	b571                	j	6be <vprintf+0x42>
 834:	74e2                	ld	s1,56(sp)
 836:	79a2                	ld	s3,40(sp)
 838:	7a02                	ld	s4,32(sp)
 83a:	6ae2                	ld	s5,24(sp)
 83c:	6b42                	ld	s6,16(sp)
 83e:	6ba2                	ld	s7,8(sp)
    }
  }
}
 840:	60a6                	ld	ra,72(sp)
 842:	6406                	ld	s0,64(sp)
 844:	7942                	ld	s2,48(sp)
 846:	6161                	addi	sp,sp,80
 848:	8082                	ret

000000000000084a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 84a:	715d                	addi	sp,sp,-80
 84c:	ec06                	sd	ra,24(sp)
 84e:	e822                	sd	s0,16(sp)
 850:	1000                	addi	s0,sp,32
 852:	e010                	sd	a2,0(s0)
 854:	e414                	sd	a3,8(s0)
 856:	e818                	sd	a4,16(s0)
 858:	ec1c                	sd	a5,24(s0)
 85a:	03043023          	sd	a6,32(s0)
 85e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 862:	8622                	mv	a2,s0
 864:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 868:	00000097          	auipc	ra,0x0
 86c:	e14080e7          	jalr	-492(ra) # 67c <vprintf>
}
 870:	60e2                	ld	ra,24(sp)
 872:	6442                	ld	s0,16(sp)
 874:	6161                	addi	sp,sp,80
 876:	8082                	ret

0000000000000878 <printf>:

void
printf(const char *fmt, ...)
{
 878:	711d                	addi	sp,sp,-96
 87a:	ec06                	sd	ra,24(sp)
 87c:	e822                	sd	s0,16(sp)
 87e:	1000                	addi	s0,sp,32
 880:	e40c                	sd	a1,8(s0)
 882:	e810                	sd	a2,16(s0)
 884:	ec14                	sd	a3,24(s0)
 886:	f018                	sd	a4,32(s0)
 888:	f41c                	sd	a5,40(s0)
 88a:	03043823          	sd	a6,48(s0)
 88e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 892:	00840613          	addi	a2,s0,8
 896:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 89a:	85aa                	mv	a1,a0
 89c:	4505                	li	a0,1
 89e:	00000097          	auipc	ra,0x0
 8a2:	dde080e7          	jalr	-546(ra) # 67c <vprintf>
}
 8a6:	60e2                	ld	ra,24(sp)
 8a8:	6442                	ld	s0,16(sp)
 8aa:	6125                	addi	sp,sp,96
 8ac:	8082                	ret

00000000000008ae <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8ae:	1141                	addi	sp,sp,-16
 8b0:	e406                	sd	ra,8(sp)
 8b2:	e022                	sd	s0,0(sp)
 8b4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8b6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ba:	00000797          	auipc	a5,0x0
 8be:	73e7b783          	ld	a5,1854(a5) # ff8 <freep>
 8c2:	a039                	j	8d0 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8c4:	6398                	ld	a4,0(a5)
 8c6:	00e7e463          	bltu	a5,a4,8ce <free+0x20>
 8ca:	00e6ea63          	bltu	a3,a4,8de <free+0x30>
{
 8ce:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8d0:	fed7fae3          	bgeu	a5,a3,8c4 <free+0x16>
 8d4:	6398                	ld	a4,0(a5)
 8d6:	00e6e463          	bltu	a3,a4,8de <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8da:	fee7eae3          	bltu	a5,a4,8ce <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8de:	ff852583          	lw	a1,-8(a0)
 8e2:	6390                	ld	a2,0(a5)
 8e4:	02059813          	slli	a6,a1,0x20
 8e8:	01c85713          	srli	a4,a6,0x1c
 8ec:	9736                	add	a4,a4,a3
 8ee:	02e60563          	beq	a2,a4,918 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 8f2:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 8f6:	4790                	lw	a2,8(a5)
 8f8:	02061593          	slli	a1,a2,0x20
 8fc:	01c5d713          	srli	a4,a1,0x1c
 900:	973e                	add	a4,a4,a5
 902:	02e68263          	beq	a3,a4,926 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 906:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 908:	00000717          	auipc	a4,0x0
 90c:	6ef73823          	sd	a5,1776(a4) # ff8 <freep>
}
 910:	60a2                	ld	ra,8(sp)
 912:	6402                	ld	s0,0(sp)
 914:	0141                	addi	sp,sp,16
 916:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 918:	4618                	lw	a4,8(a2)
 91a:	9f2d                	addw	a4,a4,a1
 91c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 920:	6398                	ld	a4,0(a5)
 922:	6310                	ld	a2,0(a4)
 924:	b7f9                	j	8f2 <free+0x44>
    p->s.size += bp->s.size;
 926:	ff852703          	lw	a4,-8(a0)
 92a:	9f31                	addw	a4,a4,a2
 92c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 92e:	ff053683          	ld	a3,-16(a0)
 932:	bfd1                	j	906 <free+0x58>

0000000000000934 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 934:	7139                	addi	sp,sp,-64
 936:	fc06                	sd	ra,56(sp)
 938:	f822                	sd	s0,48(sp)
 93a:	f04a                	sd	s2,32(sp)
 93c:	ec4e                	sd	s3,24(sp)
 93e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 940:	02051993          	slli	s3,a0,0x20
 944:	0209d993          	srli	s3,s3,0x20
 948:	09bd                	addi	s3,s3,15
 94a:	0049d993          	srli	s3,s3,0x4
 94e:	2985                	addiw	s3,s3,1
 950:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 952:	00000517          	auipc	a0,0x0
 956:	6a653503          	ld	a0,1702(a0) # ff8 <freep>
 95a:	c905                	beqz	a0,98a <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 95c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 95e:	4798                	lw	a4,8(a5)
 960:	09377a63          	bgeu	a4,s3,9f4 <malloc+0xc0>
 964:	f426                	sd	s1,40(sp)
 966:	e852                	sd	s4,16(sp)
 968:	e456                	sd	s5,8(sp)
 96a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 96c:	8a4e                	mv	s4,s3
 96e:	6705                	lui	a4,0x1
 970:	00e9f363          	bgeu	s3,a4,976 <malloc+0x42>
 974:	6a05                	lui	s4,0x1
 976:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 97a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 97e:	00000497          	auipc	s1,0x0
 982:	67a48493          	addi	s1,s1,1658 # ff8 <freep>
  if(p == (char*)-1)
 986:	5afd                	li	s5,-1
 988:	a089                	j	9ca <malloc+0x96>
 98a:	f426                	sd	s1,40(sp)
 98c:	e852                	sd	s4,16(sp)
 98e:	e456                	sd	s5,8(sp)
 990:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 992:	00000797          	auipc	a5,0x0
 996:	66e78793          	addi	a5,a5,1646 # 1000 <base>
 99a:	00000717          	auipc	a4,0x0
 99e:	64f73f23          	sd	a5,1630(a4) # ff8 <freep>
 9a2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9a4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9a8:	b7d1                	j	96c <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 9aa:	6398                	ld	a4,0(a5)
 9ac:	e118                	sd	a4,0(a0)
 9ae:	a8b9                	j	a0c <malloc+0xd8>
  hp->s.size = nu;
 9b0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9b4:	0541                	addi	a0,a0,16
 9b6:	00000097          	auipc	ra,0x0
 9ba:	ef8080e7          	jalr	-264(ra) # 8ae <free>
  return freep;
 9be:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 9c0:	c135                	beqz	a0,a24 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9c2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9c4:	4798                	lw	a4,8(a5)
 9c6:	03277363          	bgeu	a4,s2,9ec <malloc+0xb8>
    if(p == freep)
 9ca:	6098                	ld	a4,0(s1)
 9cc:	853e                	mv	a0,a5
 9ce:	fef71ae3          	bne	a4,a5,9c2 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 9d2:	8552                	mv	a0,s4
 9d4:	00000097          	auipc	ra,0x0
 9d8:	bae080e7          	jalr	-1106(ra) # 582 <sbrk>
  if(p == (char*)-1)
 9dc:	fd551ae3          	bne	a0,s5,9b0 <malloc+0x7c>
        return 0;
 9e0:	4501                	li	a0,0
 9e2:	74a2                	ld	s1,40(sp)
 9e4:	6a42                	ld	s4,16(sp)
 9e6:	6aa2                	ld	s5,8(sp)
 9e8:	6b02                	ld	s6,0(sp)
 9ea:	a03d                	j	a18 <malloc+0xe4>
 9ec:	74a2                	ld	s1,40(sp)
 9ee:	6a42                	ld	s4,16(sp)
 9f0:	6aa2                	ld	s5,8(sp)
 9f2:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9f4:	fae90be3          	beq	s2,a4,9aa <malloc+0x76>
        p->s.size -= nunits;
 9f8:	4137073b          	subw	a4,a4,s3
 9fc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9fe:	02071693          	slli	a3,a4,0x20
 a02:	01c6d713          	srli	a4,a3,0x1c
 a06:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a08:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a0c:	00000717          	auipc	a4,0x0
 a10:	5ea73623          	sd	a0,1516(a4) # ff8 <freep>
      return (void*)(p + 1);
 a14:	01078513          	addi	a0,a5,16
  }
}
 a18:	70e2                	ld	ra,56(sp)
 a1a:	7442                	ld	s0,48(sp)
 a1c:	7902                	ld	s2,32(sp)
 a1e:	69e2                	ld	s3,24(sp)
 a20:	6121                	addi	sp,sp,64
 a22:	8082                	ret
 a24:	74a2                	ld	s1,40(sp)
 a26:	6a42                	ld	s4,16(sp)
 a28:	6aa2                	ld	s5,8(sp)
 a2a:	6b02                	ld	s6,0(sp)
 a2c:	b7f5                	j	a18 <malloc+0xe4>
