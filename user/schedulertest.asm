
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
  3a:	9c250513          	addi	a0,a0,-1598 # 9f8 <malloc+0x110>
  3e:	00000097          	auipc	ra,0x0
  42:	7ee080e7          	jalr	2030(ra) # 82c <printf>
    printf("Creando %d procesos (%d IO-bound, %d CPU-bound)\n\n",
  46:	4695                	li	a3,5
  48:	8636                	mv	a2,a3
  4a:	45a9                	li	a1,10
  4c:	00001517          	auipc	a0,0x1
  50:	9cc50513          	addi	a0,a0,-1588 # a18 <malloc+0x130>
  54:	00000097          	auipc	ra,0x0
  58:	7d8080e7          	jalr	2008(ra) # 82c <printf>
           NFORK, IO, NFORK - IO);

    for (n = 0; n < NFORK; n++) {
  5c:	4481                	li	s1,0
                for (volatile int i = 0; i < 1000000000; i++) {}
            }
            exit(0);
        }
        else {
            if (pid < NPROC)
  5e:	03f00993          	li	s3,63
                tipo[pid] = (n < IO);
  62:	e9840b13          	addi	s6,s0,-360

            if (pid < NPROC)
                prioridad[pid] = pr;
#else
            if (pid < NPROC)
                prioridad[pid] = -1;
  66:	d9840a93          	addi	s5,s0,-616
  6a:	5a7d                	li	s4,-1
    for (n = 0; n < NFORK; n++) {
  6c:	4929                	li	s2,10
  6e:	a889                	j	c0 <main+0xc0>
            if (n < IO) {
  70:	4791                	li	a5,4
  72:	0297dd63          	bge	a5,s1,ac <main+0xac>
                for (volatile int i = 0; i < 1000000000; i++) {}
  76:	d8042a23          	sw	zero,-620(s0)
  7a:	d9442703          	lw	a4,-620(s0)
  7e:	2701                	sext.w	a4,a4
  80:	3b9ad7b7          	lui	a5,0x3b9ad
  84:	9ff78793          	addi	a5,a5,-1537 # 3b9ac9ff <__global_pointer$+0x3b9ab253>
  88:	00e7cd63          	blt	a5,a4,a2 <main+0xa2>
  8c:	873e                	mv	a4,a5
  8e:	d9442783          	lw	a5,-620(s0)
  92:	2785                	addiw	a5,a5,1
  94:	d8f42a23          	sw	a5,-620(s0)
  98:	d9442783          	lw	a5,-620(s0)
  9c:	2781                	sext.w	a5,a5
  9e:	fef758e3          	bge	a4,a5,8e <main+0x8e>
            exit(0);
  a2:	4501                	li	a0,0
  a4:	00000097          	auipc	ra,0x0
  a8:	40a080e7          	jalr	1034(ra) # 4ae <exit>
                sleep(200);
  ac:	0c800513          	li	a0,200
  b0:	00000097          	auipc	ra,0x0
  b4:	48e080e7          	jalr	1166(ra) # 53e <sleep>
  b8:	b7ed                	j	a2 <main+0xa2>
    for (n = 0; n < NFORK; n++) {
  ba:	2485                	addiw	s1,s1,1
  bc:	13248063          	beq	s1,s2,1dc <main+0x1dc>
        pid = fork();
  c0:	00000097          	auipc	ra,0x0
  c4:	3e6080e7          	jalr	998(ra) # 4a6 <fork>
        if (pid < 0) break;
  c8:	00054f63          	bltz	a0,e6 <main+0xe6>
        if (pid == 0) {
  cc:	d155                	beqz	a0,70 <main+0x70>
            if (pid < NPROC)
  ce:	fea9c6e3          	blt	s3,a0,ba <main+0xba>
                tipo[pid] = (n < IO);
  d2:	050a                	slli	a0,a0,0x2
  d4:	016507b3          	add	a5,a0,s6
  d8:	0054a713          	slti	a4,s1,5
  dc:	c398                	sw	a4,0(a5)
                prioridad[pid] = -1;
  de:	9556                	add	a0,a0,s5
  e0:	01452023          	sw	s4,0(a0)
  e4:	bfd9                	j	ba <main+0xba>
#endif
        }
    }

    printf("PID   TIPO   PRIO   RTIME   WTIME   TURNAROUND\n");
  e6:	00001517          	auipc	a0,0x1
  ea:	96a50513          	addi	a0,a0,-1686 # a50 <malloc+0x168>
  ee:	00000097          	auipc	ra,0x0
  f2:	73e080e7          	jalr	1854(ra) # 82c <printf>
    printf("-----------------------------------------------------\n");
  f6:	00001517          	auipc	a0,0x1
  fa:	98a50513          	addi	a0,a0,-1654 # a80 <malloc+0x198>
  fe:	00000097          	auipc	ra,0x0
 102:	72e080e7          	jalr	1838(ra) # 82c <printf>

    int total_r = 0, total_w = 0;

    for (; n > 0; n--) {
 106:	0e904b63          	bgtz	s1,1fc <main+0x1fc>
    int total_r = 0, total_w = 0;
 10a:	4901                	li	s2,0
 10c:	4981                	li	s3,0
               wtime,
               turnaround
        );
    }

    printf("-----------------------------------------------------\n");
 10e:	00001517          	auipc	a0,0x1
 112:	97250513          	addi	a0,a0,-1678 # a80 <malloc+0x198>
 116:	00000097          	auipc	ra,0x0
 11a:	716080e7          	jalr	1814(ra) # 82c <printf>
    printf("Promedio rtime: %d\n", total_r / NFORK);
 11e:	666664b7          	lui	s1,0x66666
 122:	66748493          	addi	s1,s1,1639 # 66666667 <__global_pointer$+0x66664ebb>
 126:	029985b3          	mul	a1,s3,s1
 12a:	9589                	srai	a1,a1,0x22
 12c:	41f9d99b          	sraiw	s3,s3,0x1f
 130:	413585bb          	subw	a1,a1,s3
 134:	00001517          	auipc	a0,0x1
 138:	9ac50513          	addi	a0,a0,-1620 # ae0 <malloc+0x1f8>
 13c:	00000097          	auipc	ra,0x0
 140:	6f0080e7          	jalr	1776(ra) # 82c <printf>
    printf("Promedio wtime: %d\n", total_w / NFORK);
 144:	029905b3          	mul	a1,s2,s1
 148:	9589                	srai	a1,a1,0x22
 14a:	41f9591b          	sraiw	s2,s2,0x1f
 14e:	412585bb          	subw	a1,a1,s2
 152:	00001517          	auipc	a0,0x1
 156:	9a650513          	addi	a0,a0,-1626 # af8 <malloc+0x210>
 15a:	00000097          	auipc	ra,0x0
 15e:	6d2080e7          	jalr	1746(ra) # 82c <printf>
    printf("=====================================================\n\n");
 162:	00001517          	auipc	a0,0x1
 166:	9ae50513          	addi	a0,a0,-1618 # b10 <malloc+0x228>
 16a:	00000097          	auipc	ra,0x0
 16e:	6c2080e7          	jalr	1730(ra) # 82c <printf>

    exit(0);
 172:	4501                	li	a0,0
 174:	00000097          	auipc	ra,0x0
 178:	33a080e7          	jalr	826(ra) # 4ae <exit>
        printf("%3d   %4s   %4d   %5d   %5d   %8d\n",
 17c:	00259693          	slli	a3,a1,0x2
 180:	96e2                	add	a3,a3,s8
 182:	4294                	lw	a3,0(a3)
 184:	00001517          	auipc	a0,0x1
 188:	93450513          	addi	a0,a0,-1740 # ab8 <malloc+0x1d0>
 18c:	00000097          	auipc	ra,0x0
 190:	6a0080e7          	jalr	1696(ra) # 82c <printf>
    for (; n > 0; n--) {
 194:	34fd                	addiw	s1,s1,-1
 196:	dca5                	beqz	s1,10e <main+0x10e>
        pid = waitx(0, &rtime, &wtime);
 198:	865e                	mv	a2,s7
 19a:	85da                	mv	a1,s6
 19c:	4501                	li	a0,0
 19e:	00000097          	auipc	ra,0x0
 1a2:	3c0080e7          	jalr	960(ra) # 55e <waitx>
 1a6:	85aa                	mv	a1,a0
        int turnaround = rtime + wtime;
 1a8:	f9842703          	lw	a4,-104(s0)
 1ac:	f9c42783          	lw	a5,-100(s0)
 1b0:	00f7083b          	addw	a6,a4,a5
        total_r += rtime;
 1b4:	013709bb          	addw	s3,a4,s3
        total_w += wtime;
 1b8:	0127893b          	addw	s2,a5,s2
        printf("%3d   %4s   %4d   %5d   %5d   %8d\n",
 1bc:	00aacd63          	blt	s5,a0,1d6 <main+0x1d6>
               (pid < NPROC && tipo[pid]) ? "IO" : "CPU",
 1c0:	00251693          	slli	a3,a0,0x2
 1c4:	96e6                	add	a3,a3,s9
 1c6:	4294                	lw	a3,0(a3)
        printf("%3d   %4s   %4d   %5d   %5d   %8d\n",
 1c8:	8652                	mv	a2,s4
               (pid < NPROC && tipo[pid]) ? "IO" : "CPU",
 1ca:	dacd                	beqz	a3,17c <main+0x17c>
        printf("%3d   %4s   %4d   %5d   %5d   %8d\n",
 1cc:	00001617          	auipc	a2,0x1
 1d0:	81c60613          	addi	a2,a2,-2020 # 9e8 <malloc+0x100>
 1d4:	b765                	j	17c <main+0x17c>
 1d6:	8652                	mv	a2,s4
 1d8:	86ea                	mv	a3,s10
 1da:	b76d                	j	184 <main+0x184>
    printf("PID   TIPO   PRIO   RTIME   WTIME   TURNAROUND\n");
 1dc:	00001517          	auipc	a0,0x1
 1e0:	87450513          	addi	a0,a0,-1932 # a50 <malloc+0x168>
 1e4:	00000097          	auipc	ra,0x0
 1e8:	648080e7          	jalr	1608(ra) # 82c <printf>
    printf("-----------------------------------------------------\n");
 1ec:	00001517          	auipc	a0,0x1
 1f0:	89450513          	addi	a0,a0,-1900 # a80 <malloc+0x198>
 1f4:	00000097          	auipc	ra,0x0
 1f8:	638080e7          	jalr	1592(ra) # 82c <printf>
    for (n = 0; n < NFORK; n++) {
 1fc:	4901                	li	s2,0
 1fe:	4981                	li	s3,0
        pid = waitx(0, &rtime, &wtime);
 200:	f9c40b93          	addi	s7,s0,-100
 204:	f9840b13          	addi	s6,s0,-104
        printf("%3d   %4s   %4d   %5d   %5d   %8d\n",
 208:	03f00a93          	li	s5,63
 20c:	00000a17          	auipc	s4,0x0
 210:	7e4a0a13          	addi	s4,s4,2020 # 9f0 <malloc+0x108>
 214:	5d7d                	li	s10,-1
               (pid < NPROC && tipo[pid]) ? "IO" : "CPU",
 216:	e9840c93          	addi	s9,s0,-360
        printf("%3d   %4s   %4d   %5d   %5d   %8d\n",
 21a:	d9840c13          	addi	s8,s0,-616
 21e:	bfad                	j	198 <main+0x198>

0000000000000220 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 220:	1141                	addi	sp,sp,-16
 222:	e406                	sd	ra,8(sp)
 224:	e022                	sd	s0,0(sp)
 226:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 228:	87aa                	mv	a5,a0
 22a:	0585                	addi	a1,a1,1
 22c:	0785                	addi	a5,a5,1
 22e:	fff5c703          	lbu	a4,-1(a1)
 232:	fee78fa3          	sb	a4,-1(a5)
 236:	fb75                	bnez	a4,22a <strcpy+0xa>
    ;
  return os;
}
 238:	60a2                	ld	ra,8(sp)
 23a:	6402                	ld	s0,0(sp)
 23c:	0141                	addi	sp,sp,16
 23e:	8082                	ret

0000000000000240 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 240:	1141                	addi	sp,sp,-16
 242:	e406                	sd	ra,8(sp)
 244:	e022                	sd	s0,0(sp)
 246:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 248:	00054783          	lbu	a5,0(a0)
 24c:	cb91                	beqz	a5,260 <strcmp+0x20>
 24e:	0005c703          	lbu	a4,0(a1)
 252:	00f71763          	bne	a4,a5,260 <strcmp+0x20>
    p++, q++;
 256:	0505                	addi	a0,a0,1
 258:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 25a:	00054783          	lbu	a5,0(a0)
 25e:	fbe5                	bnez	a5,24e <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 260:	0005c503          	lbu	a0,0(a1)
}
 264:	40a7853b          	subw	a0,a5,a0
 268:	60a2                	ld	ra,8(sp)
 26a:	6402                	ld	s0,0(sp)
 26c:	0141                	addi	sp,sp,16
 26e:	8082                	ret

0000000000000270 <strlen>:

uint
strlen(const char *s)
{
 270:	1141                	addi	sp,sp,-16
 272:	e406                	sd	ra,8(sp)
 274:	e022                	sd	s0,0(sp)
 276:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 278:	00054783          	lbu	a5,0(a0)
 27c:	cf91                	beqz	a5,298 <strlen+0x28>
 27e:	00150793          	addi	a5,a0,1
 282:	86be                	mv	a3,a5
 284:	0785                	addi	a5,a5,1
 286:	fff7c703          	lbu	a4,-1(a5)
 28a:	ff65                	bnez	a4,282 <strlen+0x12>
 28c:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 290:	60a2                	ld	ra,8(sp)
 292:	6402                	ld	s0,0(sp)
 294:	0141                	addi	sp,sp,16
 296:	8082                	ret
  for(n = 0; s[n]; n++)
 298:	4501                	li	a0,0
 29a:	bfdd                	j	290 <strlen+0x20>

000000000000029c <memset>:

void*
memset(void *dst, int c, uint n)
{
 29c:	1141                	addi	sp,sp,-16
 29e:	e406                	sd	ra,8(sp)
 2a0:	e022                	sd	s0,0(sp)
 2a2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2a4:	ca19                	beqz	a2,2ba <memset+0x1e>
 2a6:	87aa                	mv	a5,a0
 2a8:	1602                	slli	a2,a2,0x20
 2aa:	9201                	srli	a2,a2,0x20
 2ac:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2b0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2b4:	0785                	addi	a5,a5,1
 2b6:	fee79de3          	bne	a5,a4,2b0 <memset+0x14>
  }
  return dst;
}
 2ba:	60a2                	ld	ra,8(sp)
 2bc:	6402                	ld	s0,0(sp)
 2be:	0141                	addi	sp,sp,16
 2c0:	8082                	ret

00000000000002c2 <strchr>:

char*
strchr(const char *s, char c)
{
 2c2:	1141                	addi	sp,sp,-16
 2c4:	e406                	sd	ra,8(sp)
 2c6:	e022                	sd	s0,0(sp)
 2c8:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2ca:	00054783          	lbu	a5,0(a0)
 2ce:	cf81                	beqz	a5,2e6 <strchr+0x24>
    if(*s == c)
 2d0:	00f58763          	beq	a1,a5,2de <strchr+0x1c>
  for(; *s; s++)
 2d4:	0505                	addi	a0,a0,1
 2d6:	00054783          	lbu	a5,0(a0)
 2da:	fbfd                	bnez	a5,2d0 <strchr+0xe>
      return (char*)s;
  return 0;
 2dc:	4501                	li	a0,0
}
 2de:	60a2                	ld	ra,8(sp)
 2e0:	6402                	ld	s0,0(sp)
 2e2:	0141                	addi	sp,sp,16
 2e4:	8082                	ret
  return 0;
 2e6:	4501                	li	a0,0
 2e8:	bfdd                	j	2de <strchr+0x1c>

00000000000002ea <gets>:

char*
gets(char *buf, int max)
{
 2ea:	711d                	addi	sp,sp,-96
 2ec:	ec86                	sd	ra,88(sp)
 2ee:	e8a2                	sd	s0,80(sp)
 2f0:	e4a6                	sd	s1,72(sp)
 2f2:	e0ca                	sd	s2,64(sp)
 2f4:	fc4e                	sd	s3,56(sp)
 2f6:	f852                	sd	s4,48(sp)
 2f8:	f456                	sd	s5,40(sp)
 2fa:	f05a                	sd	s6,32(sp)
 2fc:	ec5e                	sd	s7,24(sp)
 2fe:	e862                	sd	s8,16(sp)
 300:	1080                	addi	s0,sp,96
 302:	8baa                	mv	s7,a0
 304:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 306:	892a                	mv	s2,a0
 308:	4481                	li	s1,0
    cc = read(0, &c, 1);
 30a:	faf40b13          	addi	s6,s0,-81
 30e:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 310:	8c26                	mv	s8,s1
 312:	0014899b          	addiw	s3,s1,1
 316:	84ce                	mv	s1,s3
 318:	0349d663          	bge	s3,s4,344 <gets+0x5a>
    cc = read(0, &c, 1);
 31c:	8656                	mv	a2,s5
 31e:	85da                	mv	a1,s6
 320:	4501                	li	a0,0
 322:	00000097          	auipc	ra,0x0
 326:	1a4080e7          	jalr	420(ra) # 4c6 <read>
    if(cc < 1)
 32a:	00a05d63          	blez	a0,344 <gets+0x5a>
      break;
    buf[i++] = c;
 32e:	faf44783          	lbu	a5,-81(s0)
 332:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 336:	0905                	addi	s2,s2,1
 338:	ff678713          	addi	a4,a5,-10
 33c:	c319                	beqz	a4,342 <gets+0x58>
 33e:	17cd                	addi	a5,a5,-13
 340:	fbe1                	bnez	a5,310 <gets+0x26>
    buf[i++] = c;
 342:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 344:	9c5e                	add	s8,s8,s7
 346:	000c0023          	sb	zero,0(s8)
  return buf;
}
 34a:	855e                	mv	a0,s7
 34c:	60e6                	ld	ra,88(sp)
 34e:	6446                	ld	s0,80(sp)
 350:	64a6                	ld	s1,72(sp)
 352:	6906                	ld	s2,64(sp)
 354:	79e2                	ld	s3,56(sp)
 356:	7a42                	ld	s4,48(sp)
 358:	7aa2                	ld	s5,40(sp)
 35a:	7b02                	ld	s6,32(sp)
 35c:	6be2                	ld	s7,24(sp)
 35e:	6c42                	ld	s8,16(sp)
 360:	6125                	addi	sp,sp,96
 362:	8082                	ret

0000000000000364 <stat>:

int
stat(const char *n, struct stat *st)
{
 364:	1101                	addi	sp,sp,-32
 366:	ec06                	sd	ra,24(sp)
 368:	e822                	sd	s0,16(sp)
 36a:	e04a                	sd	s2,0(sp)
 36c:	1000                	addi	s0,sp,32
 36e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 370:	4581                	li	a1,0
 372:	00000097          	auipc	ra,0x0
 376:	17c080e7          	jalr	380(ra) # 4ee <open>
  if(fd < 0)
 37a:	02054663          	bltz	a0,3a6 <stat+0x42>
 37e:	e426                	sd	s1,8(sp)
 380:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 382:	85ca                	mv	a1,s2
 384:	00000097          	auipc	ra,0x0
 388:	182080e7          	jalr	386(ra) # 506 <fstat>
 38c:	892a                	mv	s2,a0
  close(fd);
 38e:	8526                	mv	a0,s1
 390:	00000097          	auipc	ra,0x0
 394:	146080e7          	jalr	326(ra) # 4d6 <close>
  return r;
 398:	64a2                	ld	s1,8(sp)
}
 39a:	854a                	mv	a0,s2
 39c:	60e2                	ld	ra,24(sp)
 39e:	6442                	ld	s0,16(sp)
 3a0:	6902                	ld	s2,0(sp)
 3a2:	6105                	addi	sp,sp,32
 3a4:	8082                	ret
    return -1;
 3a6:	57fd                	li	a5,-1
 3a8:	893e                	mv	s2,a5
 3aa:	bfc5                	j	39a <stat+0x36>

00000000000003ac <atoi>:

int
atoi(const char *s)
{
 3ac:	1141                	addi	sp,sp,-16
 3ae:	e406                	sd	ra,8(sp)
 3b0:	e022                	sd	s0,0(sp)
 3b2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3b4:	00054683          	lbu	a3,0(a0)
 3b8:	fd06879b          	addiw	a5,a3,-48
 3bc:	0ff7f793          	zext.b	a5,a5
 3c0:	4625                	li	a2,9
 3c2:	02f66963          	bltu	a2,a5,3f4 <atoi+0x48>
 3c6:	872a                	mv	a4,a0
  n = 0;
 3c8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3ca:	0705                	addi	a4,a4,1
 3cc:	0025179b          	slliw	a5,a0,0x2
 3d0:	9fa9                	addw	a5,a5,a0
 3d2:	0017979b          	slliw	a5,a5,0x1
 3d6:	9fb5                	addw	a5,a5,a3
 3d8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3dc:	00074683          	lbu	a3,0(a4)
 3e0:	fd06879b          	addiw	a5,a3,-48
 3e4:	0ff7f793          	zext.b	a5,a5
 3e8:	fef671e3          	bgeu	a2,a5,3ca <atoi+0x1e>
  return n;
}
 3ec:	60a2                	ld	ra,8(sp)
 3ee:	6402                	ld	s0,0(sp)
 3f0:	0141                	addi	sp,sp,16
 3f2:	8082                	ret
  n = 0;
 3f4:	4501                	li	a0,0
 3f6:	bfdd                	j	3ec <atoi+0x40>

00000000000003f8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3f8:	1141                	addi	sp,sp,-16
 3fa:	e406                	sd	ra,8(sp)
 3fc:	e022                	sd	s0,0(sp)
 3fe:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 400:	02b57563          	bgeu	a0,a1,42a <memmove+0x32>
    while(n-- > 0)
 404:	00c05f63          	blez	a2,422 <memmove+0x2a>
 408:	1602                	slli	a2,a2,0x20
 40a:	9201                	srli	a2,a2,0x20
 40c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 410:	872a                	mv	a4,a0
      *dst++ = *src++;
 412:	0585                	addi	a1,a1,1
 414:	0705                	addi	a4,a4,1
 416:	fff5c683          	lbu	a3,-1(a1)
 41a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 41e:	fee79ae3          	bne	a5,a4,412 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 422:	60a2                	ld	ra,8(sp)
 424:	6402                	ld	s0,0(sp)
 426:	0141                	addi	sp,sp,16
 428:	8082                	ret
    while(n-- > 0)
 42a:	fec05ce3          	blez	a2,422 <memmove+0x2a>
    dst += n;
 42e:	00c50733          	add	a4,a0,a2
    src += n;
 432:	95b2                	add	a1,a1,a2
 434:	fff6079b          	addiw	a5,a2,-1
 438:	1782                	slli	a5,a5,0x20
 43a:	9381                	srli	a5,a5,0x20
 43c:	fff7c793          	not	a5,a5
 440:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 442:	15fd                	addi	a1,a1,-1
 444:	177d                	addi	a4,a4,-1
 446:	0005c683          	lbu	a3,0(a1)
 44a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 44e:	fef71ae3          	bne	a4,a5,442 <memmove+0x4a>
 452:	bfc1                	j	422 <memmove+0x2a>

0000000000000454 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 454:	1141                	addi	sp,sp,-16
 456:	e406                	sd	ra,8(sp)
 458:	e022                	sd	s0,0(sp)
 45a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 45c:	c61d                	beqz	a2,48a <memcmp+0x36>
 45e:	1602                	slli	a2,a2,0x20
 460:	9201                	srli	a2,a2,0x20
 462:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 466:	00054783          	lbu	a5,0(a0)
 46a:	0005c703          	lbu	a4,0(a1)
 46e:	00e79863          	bne	a5,a4,47e <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 472:	0505                	addi	a0,a0,1
    p2++;
 474:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 476:	fed518e3          	bne	a0,a3,466 <memcmp+0x12>
  }
  return 0;
 47a:	4501                	li	a0,0
 47c:	a019                	j	482 <memcmp+0x2e>
      return *p1 - *p2;
 47e:	40e7853b          	subw	a0,a5,a4
}
 482:	60a2                	ld	ra,8(sp)
 484:	6402                	ld	s0,0(sp)
 486:	0141                	addi	sp,sp,16
 488:	8082                	ret
  return 0;
 48a:	4501                	li	a0,0
 48c:	bfdd                	j	482 <memcmp+0x2e>

000000000000048e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 48e:	1141                	addi	sp,sp,-16
 490:	e406                	sd	ra,8(sp)
 492:	e022                	sd	s0,0(sp)
 494:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 496:	00000097          	auipc	ra,0x0
 49a:	f62080e7          	jalr	-158(ra) # 3f8 <memmove>
}
 49e:	60a2                	ld	ra,8(sp)
 4a0:	6402                	ld	s0,0(sp)
 4a2:	0141                	addi	sp,sp,16
 4a4:	8082                	ret

00000000000004a6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4a6:	4885                	li	a7,1
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <exit>:
.global exit
exit:
 li a7, SYS_exit
 4ae:	4889                	li	a7,2
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4b6:	488d                	li	a7,3
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4be:	4891                	li	a7,4
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <read>:
.global read
read:
 li a7, SYS_read
 4c6:	4895                	li	a7,5
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <write>:
.global write
write:
 li a7, SYS_write
 4ce:	48c1                	li	a7,16
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <close>:
.global close
close:
 li a7, SYS_close
 4d6:	48d5                	li	a7,21
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <kill>:
.global kill
kill:
 li a7, SYS_kill
 4de:	4899                	li	a7,6
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4e6:	489d                	li	a7,7
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <open>:
.global open
open:
 li a7, SYS_open
 4ee:	48bd                	li	a7,15
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4f6:	48c5                	li	a7,17
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4fe:	48c9                	li	a7,18
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 506:	48a1                	li	a7,8
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <link>:
.global link
link:
 li a7, SYS_link
 50e:	48cd                	li	a7,19
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 516:	48d1                	li	a7,20
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 51e:	48a5                	li	a7,9
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <dup>:
.global dup
dup:
 li a7, SYS_dup
 526:	48a9                	li	a7,10
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 52e:	48ad                	li	a7,11
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 536:	48b1                	li	a7,12
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 53e:	48b5                	li	a7,13
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 546:	48b9                	li	a7,14
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <trace>:
.global trace
trace:
 li a7, SYS_trace
 54e:	48d9                	li	a7,22
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 556:	48dd                	li	a7,23
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 55e:	48e1                	li	a7,24
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 566:	1101                	addi	sp,sp,-32
 568:	ec06                	sd	ra,24(sp)
 56a:	e822                	sd	s0,16(sp)
 56c:	1000                	addi	s0,sp,32
 56e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 572:	4605                	li	a2,1
 574:	fef40593          	addi	a1,s0,-17
 578:	00000097          	auipc	ra,0x0
 57c:	f56080e7          	jalr	-170(ra) # 4ce <write>
}
 580:	60e2                	ld	ra,24(sp)
 582:	6442                	ld	s0,16(sp)
 584:	6105                	addi	sp,sp,32
 586:	8082                	ret

0000000000000588 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 588:	7139                	addi	sp,sp,-64
 58a:	fc06                	sd	ra,56(sp)
 58c:	f822                	sd	s0,48(sp)
 58e:	f04a                	sd	s2,32(sp)
 590:	ec4e                	sd	s3,24(sp)
 592:	0080                	addi	s0,sp,64
 594:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 596:	cad9                	beqz	a3,62c <printint+0xa4>
 598:	01f5d79b          	srliw	a5,a1,0x1f
 59c:	cbc1                	beqz	a5,62c <printint+0xa4>
    neg = 1;
    x = -xx;
 59e:	40b005bb          	negw	a1,a1
    neg = 1;
 5a2:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 5a4:	fc040993          	addi	s3,s0,-64
  neg = 0;
 5a8:	86ce                	mv	a3,s3
  i = 0;
 5aa:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5ac:	00000817          	auipc	a6,0x0
 5b0:	5fc80813          	addi	a6,a6,1532 # ba8 <digits>
 5b4:	88ba                	mv	a7,a4
 5b6:	0017051b          	addiw	a0,a4,1
 5ba:	872a                	mv	a4,a0
 5bc:	02c5f7bb          	remuw	a5,a1,a2
 5c0:	1782                	slli	a5,a5,0x20
 5c2:	9381                	srli	a5,a5,0x20
 5c4:	97c2                	add	a5,a5,a6
 5c6:	0007c783          	lbu	a5,0(a5)
 5ca:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5ce:	87ae                	mv	a5,a1
 5d0:	02c5d5bb          	divuw	a1,a1,a2
 5d4:	0685                	addi	a3,a3,1
 5d6:	fcc7ffe3          	bgeu	a5,a2,5b4 <printint+0x2c>
  if(neg)
 5da:	00030c63          	beqz	t1,5f2 <printint+0x6a>
    buf[i++] = '-';
 5de:	fd050793          	addi	a5,a0,-48
 5e2:	00878533          	add	a0,a5,s0
 5e6:	02d00793          	li	a5,45
 5ea:	fef50823          	sb	a5,-16(a0)
 5ee:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 5f2:	02e05763          	blez	a4,620 <printint+0x98>
 5f6:	f426                	sd	s1,40(sp)
 5f8:	377d                	addiw	a4,a4,-1
 5fa:	00e984b3          	add	s1,s3,a4
 5fe:	19fd                	addi	s3,s3,-1
 600:	99ba                	add	s3,s3,a4
 602:	1702                	slli	a4,a4,0x20
 604:	9301                	srli	a4,a4,0x20
 606:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 60a:	0004c583          	lbu	a1,0(s1)
 60e:	854a                	mv	a0,s2
 610:	00000097          	auipc	ra,0x0
 614:	f56080e7          	jalr	-170(ra) # 566 <putc>
  while(--i >= 0)
 618:	14fd                	addi	s1,s1,-1
 61a:	ff3498e3          	bne	s1,s3,60a <printint+0x82>
 61e:	74a2                	ld	s1,40(sp)
}
 620:	70e2                	ld	ra,56(sp)
 622:	7442                	ld	s0,48(sp)
 624:	7902                	ld	s2,32(sp)
 626:	69e2                	ld	s3,24(sp)
 628:	6121                	addi	sp,sp,64
 62a:	8082                	ret
  neg = 0;
 62c:	4301                	li	t1,0
 62e:	bf9d                	j	5a4 <printint+0x1c>

0000000000000630 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 630:	715d                	addi	sp,sp,-80
 632:	e486                	sd	ra,72(sp)
 634:	e0a2                	sd	s0,64(sp)
 636:	f84a                	sd	s2,48(sp)
 638:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 63a:	0005c903          	lbu	s2,0(a1)
 63e:	1a090b63          	beqz	s2,7f4 <vprintf+0x1c4>
 642:	fc26                	sd	s1,56(sp)
 644:	f44e                	sd	s3,40(sp)
 646:	f052                	sd	s4,32(sp)
 648:	ec56                	sd	s5,24(sp)
 64a:	e85a                	sd	s6,16(sp)
 64c:	e45e                	sd	s7,8(sp)
 64e:	8aaa                	mv	s5,a0
 650:	8bb2                	mv	s7,a2
 652:	00158493          	addi	s1,a1,1
  state = 0;
 656:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 658:	02500a13          	li	s4,37
 65c:	4b55                	li	s6,21
 65e:	a839                	j	67c <vprintf+0x4c>
        putc(fd, c);
 660:	85ca                	mv	a1,s2
 662:	8556                	mv	a0,s5
 664:	00000097          	auipc	ra,0x0
 668:	f02080e7          	jalr	-254(ra) # 566 <putc>
 66c:	a019                	j	672 <vprintf+0x42>
    } else if(state == '%'){
 66e:	01498d63          	beq	s3,s4,688 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 672:	0485                	addi	s1,s1,1
 674:	fff4c903          	lbu	s2,-1(s1)
 678:	16090863          	beqz	s2,7e8 <vprintf+0x1b8>
    if(state == 0){
 67c:	fe0999e3          	bnez	s3,66e <vprintf+0x3e>
      if(c == '%'){
 680:	ff4910e3          	bne	s2,s4,660 <vprintf+0x30>
        state = '%';
 684:	89d2                	mv	s3,s4
 686:	b7f5                	j	672 <vprintf+0x42>
      if(c == 'd'){
 688:	13490563          	beq	s2,s4,7b2 <vprintf+0x182>
 68c:	f9d9079b          	addiw	a5,s2,-99
 690:	0ff7f793          	zext.b	a5,a5
 694:	12fb6863          	bltu	s6,a5,7c4 <vprintf+0x194>
 698:	f9d9079b          	addiw	a5,s2,-99
 69c:	0ff7f713          	zext.b	a4,a5
 6a0:	12eb6263          	bltu	s6,a4,7c4 <vprintf+0x194>
 6a4:	00271793          	slli	a5,a4,0x2
 6a8:	00000717          	auipc	a4,0x0
 6ac:	4a870713          	addi	a4,a4,1192 # b50 <malloc+0x268>
 6b0:	97ba                	add	a5,a5,a4
 6b2:	439c                	lw	a5,0(a5)
 6b4:	97ba                	add	a5,a5,a4
 6b6:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 6b8:	008b8913          	addi	s2,s7,8
 6bc:	4685                	li	a3,1
 6be:	4629                	li	a2,10
 6c0:	000ba583          	lw	a1,0(s7)
 6c4:	8556                	mv	a0,s5
 6c6:	00000097          	auipc	ra,0x0
 6ca:	ec2080e7          	jalr	-318(ra) # 588 <printint>
 6ce:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 6d0:	4981                	li	s3,0
 6d2:	b745                	j	672 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d4:	008b8913          	addi	s2,s7,8
 6d8:	4681                	li	a3,0
 6da:	4629                	li	a2,10
 6dc:	000ba583          	lw	a1,0(s7)
 6e0:	8556                	mv	a0,s5
 6e2:	00000097          	auipc	ra,0x0
 6e6:	ea6080e7          	jalr	-346(ra) # 588 <printint>
 6ea:	8bca                	mv	s7,s2
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	b751                	j	672 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 6f0:	008b8913          	addi	s2,s7,8
 6f4:	4681                	li	a3,0
 6f6:	4641                	li	a2,16
 6f8:	000ba583          	lw	a1,0(s7)
 6fc:	8556                	mv	a0,s5
 6fe:	00000097          	auipc	ra,0x0
 702:	e8a080e7          	jalr	-374(ra) # 588 <printint>
 706:	8bca                	mv	s7,s2
      state = 0;
 708:	4981                	li	s3,0
 70a:	b7a5                	j	672 <vprintf+0x42>
 70c:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 70e:	008b8793          	addi	a5,s7,8
 712:	8c3e                	mv	s8,a5
 714:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 718:	03000593          	li	a1,48
 71c:	8556                	mv	a0,s5
 71e:	00000097          	auipc	ra,0x0
 722:	e48080e7          	jalr	-440(ra) # 566 <putc>
  putc(fd, 'x');
 726:	07800593          	li	a1,120
 72a:	8556                	mv	a0,s5
 72c:	00000097          	auipc	ra,0x0
 730:	e3a080e7          	jalr	-454(ra) # 566 <putc>
 734:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 736:	00000b97          	auipc	s7,0x0
 73a:	472b8b93          	addi	s7,s7,1138 # ba8 <digits>
 73e:	03c9d793          	srli	a5,s3,0x3c
 742:	97de                	add	a5,a5,s7
 744:	0007c583          	lbu	a1,0(a5)
 748:	8556                	mv	a0,s5
 74a:	00000097          	auipc	ra,0x0
 74e:	e1c080e7          	jalr	-484(ra) # 566 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 752:	0992                	slli	s3,s3,0x4
 754:	397d                	addiw	s2,s2,-1
 756:	fe0914e3          	bnez	s2,73e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
 75a:	8be2                	mv	s7,s8
      state = 0;
 75c:	4981                	li	s3,0
 75e:	6c02                	ld	s8,0(sp)
 760:	bf09                	j	672 <vprintf+0x42>
        s = va_arg(ap, char*);
 762:	008b8993          	addi	s3,s7,8
 766:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 76a:	02090163          	beqz	s2,78c <vprintf+0x15c>
        while(*s != 0){
 76e:	00094583          	lbu	a1,0(s2)
 772:	c9a5                	beqz	a1,7e2 <vprintf+0x1b2>
          putc(fd, *s);
 774:	8556                	mv	a0,s5
 776:	00000097          	auipc	ra,0x0
 77a:	df0080e7          	jalr	-528(ra) # 566 <putc>
          s++;
 77e:	0905                	addi	s2,s2,1
        while(*s != 0){
 780:	00094583          	lbu	a1,0(s2)
 784:	f9e5                	bnez	a1,774 <vprintf+0x144>
        s = va_arg(ap, char*);
 786:	8bce                	mv	s7,s3
      state = 0;
 788:	4981                	li	s3,0
 78a:	b5e5                	j	672 <vprintf+0x42>
          s = "(null)";
 78c:	00000917          	auipc	s2,0x0
 790:	3bc90913          	addi	s2,s2,956 # b48 <malloc+0x260>
        while(*s != 0){
 794:	02800593          	li	a1,40
 798:	bff1                	j	774 <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
 79a:	008b8913          	addi	s2,s7,8
 79e:	000bc583          	lbu	a1,0(s7)
 7a2:	8556                	mv	a0,s5
 7a4:	00000097          	auipc	ra,0x0
 7a8:	dc2080e7          	jalr	-574(ra) # 566 <putc>
 7ac:	8bca                	mv	s7,s2
      state = 0;
 7ae:	4981                	li	s3,0
 7b0:	b5c9                	j	672 <vprintf+0x42>
        putc(fd, c);
 7b2:	02500593          	li	a1,37
 7b6:	8556                	mv	a0,s5
 7b8:	00000097          	auipc	ra,0x0
 7bc:	dae080e7          	jalr	-594(ra) # 566 <putc>
      state = 0;
 7c0:	4981                	li	s3,0
 7c2:	bd45                	j	672 <vprintf+0x42>
        putc(fd, '%');
 7c4:	02500593          	li	a1,37
 7c8:	8556                	mv	a0,s5
 7ca:	00000097          	auipc	ra,0x0
 7ce:	d9c080e7          	jalr	-612(ra) # 566 <putc>
        putc(fd, c);
 7d2:	85ca                	mv	a1,s2
 7d4:	8556                	mv	a0,s5
 7d6:	00000097          	auipc	ra,0x0
 7da:	d90080e7          	jalr	-624(ra) # 566 <putc>
      state = 0;
 7de:	4981                	li	s3,0
 7e0:	bd49                	j	672 <vprintf+0x42>
        s = va_arg(ap, char*);
 7e2:	8bce                	mv	s7,s3
      state = 0;
 7e4:	4981                	li	s3,0
 7e6:	b571                	j	672 <vprintf+0x42>
 7e8:	74e2                	ld	s1,56(sp)
 7ea:	79a2                	ld	s3,40(sp)
 7ec:	7a02                	ld	s4,32(sp)
 7ee:	6ae2                	ld	s5,24(sp)
 7f0:	6b42                	ld	s6,16(sp)
 7f2:	6ba2                	ld	s7,8(sp)
    }
  }
}
 7f4:	60a6                	ld	ra,72(sp)
 7f6:	6406                	ld	s0,64(sp)
 7f8:	7942                	ld	s2,48(sp)
 7fa:	6161                	addi	sp,sp,80
 7fc:	8082                	ret

00000000000007fe <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7fe:	715d                	addi	sp,sp,-80
 800:	ec06                	sd	ra,24(sp)
 802:	e822                	sd	s0,16(sp)
 804:	1000                	addi	s0,sp,32
 806:	e010                	sd	a2,0(s0)
 808:	e414                	sd	a3,8(s0)
 80a:	e818                	sd	a4,16(s0)
 80c:	ec1c                	sd	a5,24(s0)
 80e:	03043023          	sd	a6,32(s0)
 812:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 816:	8622                	mv	a2,s0
 818:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 81c:	00000097          	auipc	ra,0x0
 820:	e14080e7          	jalr	-492(ra) # 630 <vprintf>
}
 824:	60e2                	ld	ra,24(sp)
 826:	6442                	ld	s0,16(sp)
 828:	6161                	addi	sp,sp,80
 82a:	8082                	ret

000000000000082c <printf>:

void
printf(const char *fmt, ...)
{
 82c:	711d                	addi	sp,sp,-96
 82e:	ec06                	sd	ra,24(sp)
 830:	e822                	sd	s0,16(sp)
 832:	1000                	addi	s0,sp,32
 834:	e40c                	sd	a1,8(s0)
 836:	e810                	sd	a2,16(s0)
 838:	ec14                	sd	a3,24(s0)
 83a:	f018                	sd	a4,32(s0)
 83c:	f41c                	sd	a5,40(s0)
 83e:	03043823          	sd	a6,48(s0)
 842:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 846:	00840613          	addi	a2,s0,8
 84a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 84e:	85aa                	mv	a1,a0
 850:	4505                	li	a0,1
 852:	00000097          	auipc	ra,0x0
 856:	dde080e7          	jalr	-546(ra) # 630 <vprintf>
}
 85a:	60e2                	ld	ra,24(sp)
 85c:	6442                	ld	s0,16(sp)
 85e:	6125                	addi	sp,sp,96
 860:	8082                	ret

0000000000000862 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 862:	1141                	addi	sp,sp,-16
 864:	e406                	sd	ra,8(sp)
 866:	e022                	sd	s0,0(sp)
 868:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 86a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 86e:	00000797          	auipc	a5,0x0
 872:	7427b783          	ld	a5,1858(a5) # fb0 <freep>
 876:	a039                	j	884 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 878:	6398                	ld	a4,0(a5)
 87a:	00e7e463          	bltu	a5,a4,882 <free+0x20>
 87e:	00e6ea63          	bltu	a3,a4,892 <free+0x30>
{
 882:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 884:	fed7fae3          	bgeu	a5,a3,878 <free+0x16>
 888:	6398                	ld	a4,0(a5)
 88a:	00e6e463          	bltu	a3,a4,892 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 88e:	fee7eae3          	bltu	a5,a4,882 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 892:	ff852583          	lw	a1,-8(a0)
 896:	6390                	ld	a2,0(a5)
 898:	02059813          	slli	a6,a1,0x20
 89c:	01c85713          	srli	a4,a6,0x1c
 8a0:	9736                	add	a4,a4,a3
 8a2:	02e60563          	beq	a2,a4,8cc <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 8a6:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 8aa:	4790                	lw	a2,8(a5)
 8ac:	02061593          	slli	a1,a2,0x20
 8b0:	01c5d713          	srli	a4,a1,0x1c
 8b4:	973e                	add	a4,a4,a5
 8b6:	02e68263          	beq	a3,a4,8da <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 8ba:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8bc:	00000717          	auipc	a4,0x0
 8c0:	6ef73a23          	sd	a5,1780(a4) # fb0 <freep>
}
 8c4:	60a2                	ld	ra,8(sp)
 8c6:	6402                	ld	s0,0(sp)
 8c8:	0141                	addi	sp,sp,16
 8ca:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 8cc:	4618                	lw	a4,8(a2)
 8ce:	9f2d                	addw	a4,a4,a1
 8d0:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8d4:	6398                	ld	a4,0(a5)
 8d6:	6310                	ld	a2,0(a4)
 8d8:	b7f9                	j	8a6 <free+0x44>
    p->s.size += bp->s.size;
 8da:	ff852703          	lw	a4,-8(a0)
 8de:	9f31                	addw	a4,a4,a2
 8e0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8e2:	ff053683          	ld	a3,-16(a0)
 8e6:	bfd1                	j	8ba <free+0x58>

00000000000008e8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8e8:	7139                	addi	sp,sp,-64
 8ea:	fc06                	sd	ra,56(sp)
 8ec:	f822                	sd	s0,48(sp)
 8ee:	f04a                	sd	s2,32(sp)
 8f0:	ec4e                	sd	s3,24(sp)
 8f2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f4:	02051993          	slli	s3,a0,0x20
 8f8:	0209d993          	srli	s3,s3,0x20
 8fc:	09bd                	addi	s3,s3,15
 8fe:	0049d993          	srli	s3,s3,0x4
 902:	2985                	addiw	s3,s3,1
 904:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 906:	00000517          	auipc	a0,0x0
 90a:	6aa53503          	ld	a0,1706(a0) # fb0 <freep>
 90e:	c905                	beqz	a0,93e <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 910:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 912:	4798                	lw	a4,8(a5)
 914:	09377a63          	bgeu	a4,s3,9a8 <malloc+0xc0>
 918:	f426                	sd	s1,40(sp)
 91a:	e852                	sd	s4,16(sp)
 91c:	e456                	sd	s5,8(sp)
 91e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 920:	8a4e                	mv	s4,s3
 922:	6705                	lui	a4,0x1
 924:	00e9f363          	bgeu	s3,a4,92a <malloc+0x42>
 928:	6a05                	lui	s4,0x1
 92a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 92e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 932:	00000497          	auipc	s1,0x0
 936:	67e48493          	addi	s1,s1,1662 # fb0 <freep>
  if(p == (char*)-1)
 93a:	5afd                	li	s5,-1
 93c:	a089                	j	97e <malloc+0x96>
 93e:	f426                	sd	s1,40(sp)
 940:	e852                	sd	s4,16(sp)
 942:	e456                	sd	s5,8(sp)
 944:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 946:	00000797          	auipc	a5,0x0
 94a:	67278793          	addi	a5,a5,1650 # fb8 <base>
 94e:	00000717          	auipc	a4,0x0
 952:	66f73123          	sd	a5,1634(a4) # fb0 <freep>
 956:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 958:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 95c:	b7d1                	j	920 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 95e:	6398                	ld	a4,0(a5)
 960:	e118                	sd	a4,0(a0)
 962:	a8b9                	j	9c0 <malloc+0xd8>
  hp->s.size = nu;
 964:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 968:	0541                	addi	a0,a0,16
 96a:	00000097          	auipc	ra,0x0
 96e:	ef8080e7          	jalr	-264(ra) # 862 <free>
  return freep;
 972:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 974:	c135                	beqz	a0,9d8 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 976:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 978:	4798                	lw	a4,8(a5)
 97a:	03277363          	bgeu	a4,s2,9a0 <malloc+0xb8>
    if(p == freep)
 97e:	6098                	ld	a4,0(s1)
 980:	853e                	mv	a0,a5
 982:	fef71ae3          	bne	a4,a5,976 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 986:	8552                	mv	a0,s4
 988:	00000097          	auipc	ra,0x0
 98c:	bae080e7          	jalr	-1106(ra) # 536 <sbrk>
  if(p == (char*)-1)
 990:	fd551ae3          	bne	a0,s5,964 <malloc+0x7c>
        return 0;
 994:	4501                	li	a0,0
 996:	74a2                	ld	s1,40(sp)
 998:	6a42                	ld	s4,16(sp)
 99a:	6aa2                	ld	s5,8(sp)
 99c:	6b02                	ld	s6,0(sp)
 99e:	a03d                	j	9cc <malloc+0xe4>
 9a0:	74a2                	ld	s1,40(sp)
 9a2:	6a42                	ld	s4,16(sp)
 9a4:	6aa2                	ld	s5,8(sp)
 9a6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9a8:	fae90be3          	beq	s2,a4,95e <malloc+0x76>
        p->s.size -= nunits;
 9ac:	4137073b          	subw	a4,a4,s3
 9b0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9b2:	02071693          	slli	a3,a4,0x20
 9b6:	01c6d713          	srli	a4,a3,0x1c
 9ba:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9bc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9c0:	00000717          	auipc	a4,0x0
 9c4:	5ea73823          	sd	a0,1520(a4) # fb0 <freep>
      return (void*)(p + 1);
 9c8:	01078513          	addi	a0,a5,16
  }
}
 9cc:	70e2                	ld	ra,56(sp)
 9ce:	7442                	ld	s0,48(sp)
 9d0:	7902                	ld	s2,32(sp)
 9d2:	69e2                	ld	s3,24(sp)
 9d4:	6121                	addi	sp,sp,64
 9d6:	8082                	ret
 9d8:	74a2                	ld	s1,40(sp)
 9da:	6a42                	ld	s4,16(sp)
 9dc:	6aa2                	ld	s5,8(sp)
 9de:	6b02                	ld	s6,0(sp)
 9e0:	b7f5                	j	9cc <malloc+0xe4>
