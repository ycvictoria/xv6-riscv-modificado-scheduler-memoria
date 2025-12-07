
user/_init:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   c:	4589                	li	a1,2
   e:	00001517          	auipc	a0,0x1
  12:	8b250513          	addi	a0,a0,-1870 # 8c0 <malloc+0x100>
  16:	00000097          	auipc	ra,0x0
  1a:	3b0080e7          	jalr	944(ra) # 3c6 <open>
  1e:	06054363          	bltz	a0,84 <main+0x84>
    mknod("console", CONSOLE, 0);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  22:	4501                	li	a0,0
  24:	00000097          	auipc	ra,0x0
  28:	3da080e7          	jalr	986(ra) # 3fe <dup>
  dup(0);  // stderr
  2c:	4501                	li	a0,0
  2e:	00000097          	auipc	ra,0x0
  32:	3d0080e7          	jalr	976(ra) # 3fe <dup>

  for(;;){
    printf("init: starting sh\n");
  36:	00001917          	auipc	s2,0x1
  3a:	89290913          	addi	s2,s2,-1902 # 8c8 <malloc+0x108>
  3e:	854a                	mv	a0,s2
  40:	00000097          	auipc	ra,0x0
  44:	6c4080e7          	jalr	1732(ra) # 704 <printf>
    pid = fork();
  48:	00000097          	auipc	ra,0x0
  4c:	336080e7          	jalr	822(ra) # 37e <fork>
  50:	84aa                	mv	s1,a0
    if(pid < 0){
  52:	04054d63          	bltz	a0,ac <main+0xac>
      printf("init: fork failed\n");
      exit(1);
    }
    if(pid == 0){
  56:	c925                	beqz	a0,c6 <main+0xc6>
    }

    for(;;){
      // this call to wait() returns if the shell exits,
      // or if a parentless process exits.
      wpid = wait((int *) 0);
  58:	4501                	li	a0,0
  5a:	00000097          	auipc	ra,0x0
  5e:	334080e7          	jalr	820(ra) # 38e <wait>
      if(wpid == pid){
  62:	fca48ee3          	beq	s1,a0,3e <main+0x3e>
        // the shell exited; restart it.
        break;
      } else if(wpid < 0){
  66:	fe0559e3          	bgez	a0,58 <main+0x58>
        printf("init: wait returned an error\n");
  6a:	00001517          	auipc	a0,0x1
  6e:	8ae50513          	addi	a0,a0,-1874 # 918 <malloc+0x158>
  72:	00000097          	auipc	ra,0x0
  76:	692080e7          	jalr	1682(ra) # 704 <printf>
        exit(1);
  7a:	4505                	li	a0,1
  7c:	00000097          	auipc	ra,0x0
  80:	30a080e7          	jalr	778(ra) # 386 <exit>
    mknod("console", CONSOLE, 0);
  84:	4601                	li	a2,0
  86:	4585                	li	a1,1
  88:	00001517          	auipc	a0,0x1
  8c:	83850513          	addi	a0,a0,-1992 # 8c0 <malloc+0x100>
  90:	00000097          	auipc	ra,0x0
  94:	33e080e7          	jalr	830(ra) # 3ce <mknod>
    open("console", O_RDWR);
  98:	4589                	li	a1,2
  9a:	00001517          	auipc	a0,0x1
  9e:	82650513          	addi	a0,a0,-2010 # 8c0 <malloc+0x100>
  a2:	00000097          	auipc	ra,0x0
  a6:	324080e7          	jalr	804(ra) # 3c6 <open>
  aa:	bfa5                	j	22 <main+0x22>
      printf("init: fork failed\n");
  ac:	00001517          	auipc	a0,0x1
  b0:	83450513          	addi	a0,a0,-1996 # 8e0 <malloc+0x120>
  b4:	00000097          	auipc	ra,0x0
  b8:	650080e7          	jalr	1616(ra) # 704 <printf>
      exit(1);
  bc:	4505                	li	a0,1
  be:	00000097          	auipc	ra,0x0
  c2:	2c8080e7          	jalr	712(ra) # 386 <exit>
      exec("sh", argv);
  c6:	00001597          	auipc	a1,0x1
  ca:	cca58593          	addi	a1,a1,-822 # d90 <argv>
  ce:	00001517          	auipc	a0,0x1
  d2:	82a50513          	addi	a0,a0,-2006 # 8f8 <malloc+0x138>
  d6:	00000097          	auipc	ra,0x0
  da:	2e8080e7          	jalr	744(ra) # 3be <exec>
      printf("init: exec sh failed\n");
  de:	00001517          	auipc	a0,0x1
  e2:	82250513          	addi	a0,a0,-2014 # 900 <malloc+0x140>
  e6:	00000097          	auipc	ra,0x0
  ea:	61e080e7          	jalr	1566(ra) # 704 <printf>
      exit(1);
  ee:	4505                	li	a0,1
  f0:	00000097          	auipc	ra,0x0
  f4:	296080e7          	jalr	662(ra) # 386 <exit>

00000000000000f8 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  f8:	1141                	addi	sp,sp,-16
  fa:	e406                	sd	ra,8(sp)
  fc:	e022                	sd	s0,0(sp)
  fe:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 100:	87aa                	mv	a5,a0
 102:	0585                	addi	a1,a1,1
 104:	0785                	addi	a5,a5,1
 106:	fff5c703          	lbu	a4,-1(a1)
 10a:	fee78fa3          	sb	a4,-1(a5)
 10e:	fb75                	bnez	a4,102 <strcpy+0xa>
    ;
  return os;
}
 110:	60a2                	ld	ra,8(sp)
 112:	6402                	ld	s0,0(sp)
 114:	0141                	addi	sp,sp,16
 116:	8082                	ret

0000000000000118 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 118:	1141                	addi	sp,sp,-16
 11a:	e406                	sd	ra,8(sp)
 11c:	e022                	sd	s0,0(sp)
 11e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 120:	00054783          	lbu	a5,0(a0)
 124:	cb91                	beqz	a5,138 <strcmp+0x20>
 126:	0005c703          	lbu	a4,0(a1)
 12a:	00f71763          	bne	a4,a5,138 <strcmp+0x20>
    p++, q++;
 12e:	0505                	addi	a0,a0,1
 130:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 132:	00054783          	lbu	a5,0(a0)
 136:	fbe5                	bnez	a5,126 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 138:	0005c503          	lbu	a0,0(a1)
}
 13c:	40a7853b          	subw	a0,a5,a0
 140:	60a2                	ld	ra,8(sp)
 142:	6402                	ld	s0,0(sp)
 144:	0141                	addi	sp,sp,16
 146:	8082                	ret

0000000000000148 <strlen>:

uint
strlen(const char *s)
{
 148:	1141                	addi	sp,sp,-16
 14a:	e406                	sd	ra,8(sp)
 14c:	e022                	sd	s0,0(sp)
 14e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 150:	00054783          	lbu	a5,0(a0)
 154:	cf91                	beqz	a5,170 <strlen+0x28>
 156:	00150793          	addi	a5,a0,1
 15a:	86be                	mv	a3,a5
 15c:	0785                	addi	a5,a5,1
 15e:	fff7c703          	lbu	a4,-1(a5)
 162:	ff65                	bnez	a4,15a <strlen+0x12>
 164:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 168:	60a2                	ld	ra,8(sp)
 16a:	6402                	ld	s0,0(sp)
 16c:	0141                	addi	sp,sp,16
 16e:	8082                	ret
  for(n = 0; s[n]; n++)
 170:	4501                	li	a0,0
 172:	bfdd                	j	168 <strlen+0x20>

0000000000000174 <memset>:

void*
memset(void *dst, int c, uint n)
{
 174:	1141                	addi	sp,sp,-16
 176:	e406                	sd	ra,8(sp)
 178:	e022                	sd	s0,0(sp)
 17a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 17c:	ca19                	beqz	a2,192 <memset+0x1e>
 17e:	87aa                	mv	a5,a0
 180:	1602                	slli	a2,a2,0x20
 182:	9201                	srli	a2,a2,0x20
 184:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 188:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 18c:	0785                	addi	a5,a5,1
 18e:	fee79de3          	bne	a5,a4,188 <memset+0x14>
  }
  return dst;
}
 192:	60a2                	ld	ra,8(sp)
 194:	6402                	ld	s0,0(sp)
 196:	0141                	addi	sp,sp,16
 198:	8082                	ret

000000000000019a <strchr>:

char*
strchr(const char *s, char c)
{
 19a:	1141                	addi	sp,sp,-16
 19c:	e406                	sd	ra,8(sp)
 19e:	e022                	sd	s0,0(sp)
 1a0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1a2:	00054783          	lbu	a5,0(a0)
 1a6:	cf81                	beqz	a5,1be <strchr+0x24>
    if(*s == c)
 1a8:	00f58763          	beq	a1,a5,1b6 <strchr+0x1c>
  for(; *s; s++)
 1ac:	0505                	addi	a0,a0,1
 1ae:	00054783          	lbu	a5,0(a0)
 1b2:	fbfd                	bnez	a5,1a8 <strchr+0xe>
      return (char*)s;
  return 0;
 1b4:	4501                	li	a0,0
}
 1b6:	60a2                	ld	ra,8(sp)
 1b8:	6402                	ld	s0,0(sp)
 1ba:	0141                	addi	sp,sp,16
 1bc:	8082                	ret
  return 0;
 1be:	4501                	li	a0,0
 1c0:	bfdd                	j	1b6 <strchr+0x1c>

00000000000001c2 <gets>:

char*
gets(char *buf, int max)
{
 1c2:	711d                	addi	sp,sp,-96
 1c4:	ec86                	sd	ra,88(sp)
 1c6:	e8a2                	sd	s0,80(sp)
 1c8:	e4a6                	sd	s1,72(sp)
 1ca:	e0ca                	sd	s2,64(sp)
 1cc:	fc4e                	sd	s3,56(sp)
 1ce:	f852                	sd	s4,48(sp)
 1d0:	f456                	sd	s5,40(sp)
 1d2:	f05a                	sd	s6,32(sp)
 1d4:	ec5e                	sd	s7,24(sp)
 1d6:	e862                	sd	s8,16(sp)
 1d8:	1080                	addi	s0,sp,96
 1da:	8baa                	mv	s7,a0
 1dc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1de:	892a                	mv	s2,a0
 1e0:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1e2:	faf40b13          	addi	s6,s0,-81
 1e6:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 1e8:	8c26                	mv	s8,s1
 1ea:	0014899b          	addiw	s3,s1,1
 1ee:	84ce                	mv	s1,s3
 1f0:	0349d663          	bge	s3,s4,21c <gets+0x5a>
    cc = read(0, &c, 1);
 1f4:	8656                	mv	a2,s5
 1f6:	85da                	mv	a1,s6
 1f8:	4501                	li	a0,0
 1fa:	00000097          	auipc	ra,0x0
 1fe:	1a4080e7          	jalr	420(ra) # 39e <read>
    if(cc < 1)
 202:	00a05d63          	blez	a0,21c <gets+0x5a>
      break;
    buf[i++] = c;
 206:	faf44783          	lbu	a5,-81(s0)
 20a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 20e:	0905                	addi	s2,s2,1
 210:	ff678713          	addi	a4,a5,-10
 214:	c319                	beqz	a4,21a <gets+0x58>
 216:	17cd                	addi	a5,a5,-13
 218:	fbe1                	bnez	a5,1e8 <gets+0x26>
    buf[i++] = c;
 21a:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 21c:	9c5e                	add	s8,s8,s7
 21e:	000c0023          	sb	zero,0(s8)
  return buf;
}
 222:	855e                	mv	a0,s7
 224:	60e6                	ld	ra,88(sp)
 226:	6446                	ld	s0,80(sp)
 228:	64a6                	ld	s1,72(sp)
 22a:	6906                	ld	s2,64(sp)
 22c:	79e2                	ld	s3,56(sp)
 22e:	7a42                	ld	s4,48(sp)
 230:	7aa2                	ld	s5,40(sp)
 232:	7b02                	ld	s6,32(sp)
 234:	6be2                	ld	s7,24(sp)
 236:	6c42                	ld	s8,16(sp)
 238:	6125                	addi	sp,sp,96
 23a:	8082                	ret

000000000000023c <stat>:

int
stat(const char *n, struct stat *st)
{
 23c:	1101                	addi	sp,sp,-32
 23e:	ec06                	sd	ra,24(sp)
 240:	e822                	sd	s0,16(sp)
 242:	e04a                	sd	s2,0(sp)
 244:	1000                	addi	s0,sp,32
 246:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 248:	4581                	li	a1,0
 24a:	00000097          	auipc	ra,0x0
 24e:	17c080e7          	jalr	380(ra) # 3c6 <open>
  if(fd < 0)
 252:	02054663          	bltz	a0,27e <stat+0x42>
 256:	e426                	sd	s1,8(sp)
 258:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 25a:	85ca                	mv	a1,s2
 25c:	00000097          	auipc	ra,0x0
 260:	182080e7          	jalr	386(ra) # 3de <fstat>
 264:	892a                	mv	s2,a0
  close(fd);
 266:	8526                	mv	a0,s1
 268:	00000097          	auipc	ra,0x0
 26c:	146080e7          	jalr	326(ra) # 3ae <close>
  return r;
 270:	64a2                	ld	s1,8(sp)
}
 272:	854a                	mv	a0,s2
 274:	60e2                	ld	ra,24(sp)
 276:	6442                	ld	s0,16(sp)
 278:	6902                	ld	s2,0(sp)
 27a:	6105                	addi	sp,sp,32
 27c:	8082                	ret
    return -1;
 27e:	57fd                	li	a5,-1
 280:	893e                	mv	s2,a5
 282:	bfc5                	j	272 <stat+0x36>

0000000000000284 <atoi>:

int
atoi(const char *s)
{
 284:	1141                	addi	sp,sp,-16
 286:	e406                	sd	ra,8(sp)
 288:	e022                	sd	s0,0(sp)
 28a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 28c:	00054683          	lbu	a3,0(a0)
 290:	fd06879b          	addiw	a5,a3,-48
 294:	0ff7f793          	zext.b	a5,a5
 298:	4625                	li	a2,9
 29a:	02f66963          	bltu	a2,a5,2cc <atoi+0x48>
 29e:	872a                	mv	a4,a0
  n = 0;
 2a0:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2a2:	0705                	addi	a4,a4,1
 2a4:	0025179b          	slliw	a5,a0,0x2
 2a8:	9fa9                	addw	a5,a5,a0
 2aa:	0017979b          	slliw	a5,a5,0x1
 2ae:	9fb5                	addw	a5,a5,a3
 2b0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2b4:	00074683          	lbu	a3,0(a4)
 2b8:	fd06879b          	addiw	a5,a3,-48
 2bc:	0ff7f793          	zext.b	a5,a5
 2c0:	fef671e3          	bgeu	a2,a5,2a2 <atoi+0x1e>
  return n;
}
 2c4:	60a2                	ld	ra,8(sp)
 2c6:	6402                	ld	s0,0(sp)
 2c8:	0141                	addi	sp,sp,16
 2ca:	8082                	ret
  n = 0;
 2cc:	4501                	li	a0,0
 2ce:	bfdd                	j	2c4 <atoi+0x40>

00000000000002d0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2d0:	1141                	addi	sp,sp,-16
 2d2:	e406                	sd	ra,8(sp)
 2d4:	e022                	sd	s0,0(sp)
 2d6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2d8:	02b57563          	bgeu	a0,a1,302 <memmove+0x32>
    while(n-- > 0)
 2dc:	00c05f63          	blez	a2,2fa <memmove+0x2a>
 2e0:	1602                	slli	a2,a2,0x20
 2e2:	9201                	srli	a2,a2,0x20
 2e4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2e8:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ea:	0585                	addi	a1,a1,1
 2ec:	0705                	addi	a4,a4,1
 2ee:	fff5c683          	lbu	a3,-1(a1)
 2f2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2f6:	fee79ae3          	bne	a5,a4,2ea <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2fa:	60a2                	ld	ra,8(sp)
 2fc:	6402                	ld	s0,0(sp)
 2fe:	0141                	addi	sp,sp,16
 300:	8082                	ret
    while(n-- > 0)
 302:	fec05ce3          	blez	a2,2fa <memmove+0x2a>
    dst += n;
 306:	00c50733          	add	a4,a0,a2
    src += n;
 30a:	95b2                	add	a1,a1,a2
 30c:	fff6079b          	addiw	a5,a2,-1
 310:	1782                	slli	a5,a5,0x20
 312:	9381                	srli	a5,a5,0x20
 314:	fff7c793          	not	a5,a5
 318:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 31a:	15fd                	addi	a1,a1,-1
 31c:	177d                	addi	a4,a4,-1
 31e:	0005c683          	lbu	a3,0(a1)
 322:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 326:	fef71ae3          	bne	a4,a5,31a <memmove+0x4a>
 32a:	bfc1                	j	2fa <memmove+0x2a>

000000000000032c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 32c:	1141                	addi	sp,sp,-16
 32e:	e406                	sd	ra,8(sp)
 330:	e022                	sd	s0,0(sp)
 332:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 334:	c61d                	beqz	a2,362 <memcmp+0x36>
 336:	1602                	slli	a2,a2,0x20
 338:	9201                	srli	a2,a2,0x20
 33a:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 33e:	00054783          	lbu	a5,0(a0)
 342:	0005c703          	lbu	a4,0(a1)
 346:	00e79863          	bne	a5,a4,356 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 34a:	0505                	addi	a0,a0,1
    p2++;
 34c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 34e:	fed518e3          	bne	a0,a3,33e <memcmp+0x12>
  }
  return 0;
 352:	4501                	li	a0,0
 354:	a019                	j	35a <memcmp+0x2e>
      return *p1 - *p2;
 356:	40e7853b          	subw	a0,a5,a4
}
 35a:	60a2                	ld	ra,8(sp)
 35c:	6402                	ld	s0,0(sp)
 35e:	0141                	addi	sp,sp,16
 360:	8082                	ret
  return 0;
 362:	4501                	li	a0,0
 364:	bfdd                	j	35a <memcmp+0x2e>

0000000000000366 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 366:	1141                	addi	sp,sp,-16
 368:	e406                	sd	ra,8(sp)
 36a:	e022                	sd	s0,0(sp)
 36c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 36e:	00000097          	auipc	ra,0x0
 372:	f62080e7          	jalr	-158(ra) # 2d0 <memmove>
}
 376:	60a2                	ld	ra,8(sp)
 378:	6402                	ld	s0,0(sp)
 37a:	0141                	addi	sp,sp,16
 37c:	8082                	ret

000000000000037e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 37e:	4885                	li	a7,1
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <exit>:
.global exit
exit:
 li a7, SYS_exit
 386:	4889                	li	a7,2
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <wait>:
.global wait
wait:
 li a7, SYS_wait
 38e:	488d                	li	a7,3
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 396:	4891                	li	a7,4
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <read>:
.global read
read:
 li a7, SYS_read
 39e:	4895                	li	a7,5
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <write>:
.global write
write:
 li a7, SYS_write
 3a6:	48c1                	li	a7,16
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <close>:
.global close
close:
 li a7, SYS_close
 3ae:	48d5                	li	a7,21
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3b6:	4899                	li	a7,6
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <exec>:
.global exec
exec:
 li a7, SYS_exec
 3be:	489d                	li	a7,7
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <open>:
.global open
open:
 li a7, SYS_open
 3c6:	48bd                	li	a7,15
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3ce:	48c5                	li	a7,17
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3d6:	48c9                	li	a7,18
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3de:	48a1                	li	a7,8
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <link>:
.global link
link:
 li a7, SYS_link
 3e6:	48cd                	li	a7,19
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3ee:	48d1                	li	a7,20
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3f6:	48a5                	li	a7,9
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <dup>:
.global dup
dup:
 li a7, SYS_dup
 3fe:	48a9                	li	a7,10
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 406:	48ad                	li	a7,11
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 40e:	48b1                	li	a7,12
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 416:	48b5                	li	a7,13
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 41e:	48b9                	li	a7,14
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <trace>:
.global trace
trace:
 li a7, SYS_trace
 426:	48d9                	li	a7,22
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 42e:	48dd                	li	a7,23
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 436:	48e1                	li	a7,24
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 43e:	1101                	addi	sp,sp,-32
 440:	ec06                	sd	ra,24(sp)
 442:	e822                	sd	s0,16(sp)
 444:	1000                	addi	s0,sp,32
 446:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 44a:	4605                	li	a2,1
 44c:	fef40593          	addi	a1,s0,-17
 450:	00000097          	auipc	ra,0x0
 454:	f56080e7          	jalr	-170(ra) # 3a6 <write>
}
 458:	60e2                	ld	ra,24(sp)
 45a:	6442                	ld	s0,16(sp)
 45c:	6105                	addi	sp,sp,32
 45e:	8082                	ret

0000000000000460 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 460:	7139                	addi	sp,sp,-64
 462:	fc06                	sd	ra,56(sp)
 464:	f822                	sd	s0,48(sp)
 466:	f04a                	sd	s2,32(sp)
 468:	ec4e                	sd	s3,24(sp)
 46a:	0080                	addi	s0,sp,64
 46c:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 46e:	cad9                	beqz	a3,504 <printint+0xa4>
 470:	01f5d79b          	srliw	a5,a1,0x1f
 474:	cbc1                	beqz	a5,504 <printint+0xa4>
    neg = 1;
    x = -xx;
 476:	40b005bb          	negw	a1,a1
    neg = 1;
 47a:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 47c:	fc040993          	addi	s3,s0,-64
  neg = 0;
 480:	86ce                	mv	a3,s3
  i = 0;
 482:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 484:	00000817          	auipc	a6,0x0
 488:	51480813          	addi	a6,a6,1300 # 998 <digits>
 48c:	88ba                	mv	a7,a4
 48e:	0017051b          	addiw	a0,a4,1
 492:	872a                	mv	a4,a0
 494:	02c5f7bb          	remuw	a5,a1,a2
 498:	1782                	slli	a5,a5,0x20
 49a:	9381                	srli	a5,a5,0x20
 49c:	97c2                	add	a5,a5,a6
 49e:	0007c783          	lbu	a5,0(a5)
 4a2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4a6:	87ae                	mv	a5,a1
 4a8:	02c5d5bb          	divuw	a1,a1,a2
 4ac:	0685                	addi	a3,a3,1
 4ae:	fcc7ffe3          	bgeu	a5,a2,48c <printint+0x2c>
  if(neg)
 4b2:	00030c63          	beqz	t1,4ca <printint+0x6a>
    buf[i++] = '-';
 4b6:	fd050793          	addi	a5,a0,-48
 4ba:	00878533          	add	a0,a5,s0
 4be:	02d00793          	li	a5,45
 4c2:	fef50823          	sb	a5,-16(a0)
 4c6:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 4ca:	02e05763          	blez	a4,4f8 <printint+0x98>
 4ce:	f426                	sd	s1,40(sp)
 4d0:	377d                	addiw	a4,a4,-1
 4d2:	00e984b3          	add	s1,s3,a4
 4d6:	19fd                	addi	s3,s3,-1
 4d8:	99ba                	add	s3,s3,a4
 4da:	1702                	slli	a4,a4,0x20
 4dc:	9301                	srli	a4,a4,0x20
 4de:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4e2:	0004c583          	lbu	a1,0(s1)
 4e6:	854a                	mv	a0,s2
 4e8:	00000097          	auipc	ra,0x0
 4ec:	f56080e7          	jalr	-170(ra) # 43e <putc>
  while(--i >= 0)
 4f0:	14fd                	addi	s1,s1,-1
 4f2:	ff3498e3          	bne	s1,s3,4e2 <printint+0x82>
 4f6:	74a2                	ld	s1,40(sp)
}
 4f8:	70e2                	ld	ra,56(sp)
 4fa:	7442                	ld	s0,48(sp)
 4fc:	7902                	ld	s2,32(sp)
 4fe:	69e2                	ld	s3,24(sp)
 500:	6121                	addi	sp,sp,64
 502:	8082                	ret
  neg = 0;
 504:	4301                	li	t1,0
 506:	bf9d                	j	47c <printint+0x1c>

0000000000000508 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 508:	715d                	addi	sp,sp,-80
 50a:	e486                	sd	ra,72(sp)
 50c:	e0a2                	sd	s0,64(sp)
 50e:	f84a                	sd	s2,48(sp)
 510:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 512:	0005c903          	lbu	s2,0(a1)
 516:	1a090b63          	beqz	s2,6cc <vprintf+0x1c4>
 51a:	fc26                	sd	s1,56(sp)
 51c:	f44e                	sd	s3,40(sp)
 51e:	f052                	sd	s4,32(sp)
 520:	ec56                	sd	s5,24(sp)
 522:	e85a                	sd	s6,16(sp)
 524:	e45e                	sd	s7,8(sp)
 526:	8aaa                	mv	s5,a0
 528:	8bb2                	mv	s7,a2
 52a:	00158493          	addi	s1,a1,1
  state = 0;
 52e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 530:	02500a13          	li	s4,37
 534:	4b55                	li	s6,21
 536:	a839                	j	554 <vprintf+0x4c>
        putc(fd, c);
 538:	85ca                	mv	a1,s2
 53a:	8556                	mv	a0,s5
 53c:	00000097          	auipc	ra,0x0
 540:	f02080e7          	jalr	-254(ra) # 43e <putc>
 544:	a019                	j	54a <vprintf+0x42>
    } else if(state == '%'){
 546:	01498d63          	beq	s3,s4,560 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 54a:	0485                	addi	s1,s1,1
 54c:	fff4c903          	lbu	s2,-1(s1)
 550:	16090863          	beqz	s2,6c0 <vprintf+0x1b8>
    if(state == 0){
 554:	fe0999e3          	bnez	s3,546 <vprintf+0x3e>
      if(c == '%'){
 558:	ff4910e3          	bne	s2,s4,538 <vprintf+0x30>
        state = '%';
 55c:	89d2                	mv	s3,s4
 55e:	b7f5                	j	54a <vprintf+0x42>
      if(c == 'd'){
 560:	13490563          	beq	s2,s4,68a <vprintf+0x182>
 564:	f9d9079b          	addiw	a5,s2,-99
 568:	0ff7f793          	zext.b	a5,a5
 56c:	12fb6863          	bltu	s6,a5,69c <vprintf+0x194>
 570:	f9d9079b          	addiw	a5,s2,-99
 574:	0ff7f713          	zext.b	a4,a5
 578:	12eb6263          	bltu	s6,a4,69c <vprintf+0x194>
 57c:	00271793          	slli	a5,a4,0x2
 580:	00000717          	auipc	a4,0x0
 584:	3c070713          	addi	a4,a4,960 # 940 <malloc+0x180>
 588:	97ba                	add	a5,a5,a4
 58a:	439c                	lw	a5,0(a5)
 58c:	97ba                	add	a5,a5,a4
 58e:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 590:	008b8913          	addi	s2,s7,8
 594:	4685                	li	a3,1
 596:	4629                	li	a2,10
 598:	000ba583          	lw	a1,0(s7)
 59c:	8556                	mv	a0,s5
 59e:	00000097          	auipc	ra,0x0
 5a2:	ec2080e7          	jalr	-318(ra) # 460 <printint>
 5a6:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5a8:	4981                	li	s3,0
 5aa:	b745                	j	54a <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ac:	008b8913          	addi	s2,s7,8
 5b0:	4681                	li	a3,0
 5b2:	4629                	li	a2,10
 5b4:	000ba583          	lw	a1,0(s7)
 5b8:	8556                	mv	a0,s5
 5ba:	00000097          	auipc	ra,0x0
 5be:	ea6080e7          	jalr	-346(ra) # 460 <printint>
 5c2:	8bca                	mv	s7,s2
      state = 0;
 5c4:	4981                	li	s3,0
 5c6:	b751                	j	54a <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 5c8:	008b8913          	addi	s2,s7,8
 5cc:	4681                	li	a3,0
 5ce:	4641                	li	a2,16
 5d0:	000ba583          	lw	a1,0(s7)
 5d4:	8556                	mv	a0,s5
 5d6:	00000097          	auipc	ra,0x0
 5da:	e8a080e7          	jalr	-374(ra) # 460 <printint>
 5de:	8bca                	mv	s7,s2
      state = 0;
 5e0:	4981                	li	s3,0
 5e2:	b7a5                	j	54a <vprintf+0x42>
 5e4:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 5e6:	008b8793          	addi	a5,s7,8
 5ea:	8c3e                	mv	s8,a5
 5ec:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5f0:	03000593          	li	a1,48
 5f4:	8556                	mv	a0,s5
 5f6:	00000097          	auipc	ra,0x0
 5fa:	e48080e7          	jalr	-440(ra) # 43e <putc>
  putc(fd, 'x');
 5fe:	07800593          	li	a1,120
 602:	8556                	mv	a0,s5
 604:	00000097          	auipc	ra,0x0
 608:	e3a080e7          	jalr	-454(ra) # 43e <putc>
 60c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 60e:	00000b97          	auipc	s7,0x0
 612:	38ab8b93          	addi	s7,s7,906 # 998 <digits>
 616:	03c9d793          	srli	a5,s3,0x3c
 61a:	97de                	add	a5,a5,s7
 61c:	0007c583          	lbu	a1,0(a5)
 620:	8556                	mv	a0,s5
 622:	00000097          	auipc	ra,0x0
 626:	e1c080e7          	jalr	-484(ra) # 43e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 62a:	0992                	slli	s3,s3,0x4
 62c:	397d                	addiw	s2,s2,-1
 62e:	fe0914e3          	bnez	s2,616 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
 632:	8be2                	mv	s7,s8
      state = 0;
 634:	4981                	li	s3,0
 636:	6c02                	ld	s8,0(sp)
 638:	bf09                	j	54a <vprintf+0x42>
        s = va_arg(ap, char*);
 63a:	008b8993          	addi	s3,s7,8
 63e:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 642:	02090163          	beqz	s2,664 <vprintf+0x15c>
        while(*s != 0){
 646:	00094583          	lbu	a1,0(s2)
 64a:	c9a5                	beqz	a1,6ba <vprintf+0x1b2>
          putc(fd, *s);
 64c:	8556                	mv	a0,s5
 64e:	00000097          	auipc	ra,0x0
 652:	df0080e7          	jalr	-528(ra) # 43e <putc>
          s++;
 656:	0905                	addi	s2,s2,1
        while(*s != 0){
 658:	00094583          	lbu	a1,0(s2)
 65c:	f9e5                	bnez	a1,64c <vprintf+0x144>
        s = va_arg(ap, char*);
 65e:	8bce                	mv	s7,s3
      state = 0;
 660:	4981                	li	s3,0
 662:	b5e5                	j	54a <vprintf+0x42>
          s = "(null)";
 664:	00000917          	auipc	s2,0x0
 668:	2d490913          	addi	s2,s2,724 # 938 <malloc+0x178>
        while(*s != 0){
 66c:	02800593          	li	a1,40
 670:	bff1                	j	64c <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
 672:	008b8913          	addi	s2,s7,8
 676:	000bc583          	lbu	a1,0(s7)
 67a:	8556                	mv	a0,s5
 67c:	00000097          	auipc	ra,0x0
 680:	dc2080e7          	jalr	-574(ra) # 43e <putc>
 684:	8bca                	mv	s7,s2
      state = 0;
 686:	4981                	li	s3,0
 688:	b5c9                	j	54a <vprintf+0x42>
        putc(fd, c);
 68a:	02500593          	li	a1,37
 68e:	8556                	mv	a0,s5
 690:	00000097          	auipc	ra,0x0
 694:	dae080e7          	jalr	-594(ra) # 43e <putc>
      state = 0;
 698:	4981                	li	s3,0
 69a:	bd45                	j	54a <vprintf+0x42>
        putc(fd, '%');
 69c:	02500593          	li	a1,37
 6a0:	8556                	mv	a0,s5
 6a2:	00000097          	auipc	ra,0x0
 6a6:	d9c080e7          	jalr	-612(ra) # 43e <putc>
        putc(fd, c);
 6aa:	85ca                	mv	a1,s2
 6ac:	8556                	mv	a0,s5
 6ae:	00000097          	auipc	ra,0x0
 6b2:	d90080e7          	jalr	-624(ra) # 43e <putc>
      state = 0;
 6b6:	4981                	li	s3,0
 6b8:	bd49                	j	54a <vprintf+0x42>
        s = va_arg(ap, char*);
 6ba:	8bce                	mv	s7,s3
      state = 0;
 6bc:	4981                	li	s3,0
 6be:	b571                	j	54a <vprintf+0x42>
 6c0:	74e2                	ld	s1,56(sp)
 6c2:	79a2                	ld	s3,40(sp)
 6c4:	7a02                	ld	s4,32(sp)
 6c6:	6ae2                	ld	s5,24(sp)
 6c8:	6b42                	ld	s6,16(sp)
 6ca:	6ba2                	ld	s7,8(sp)
    }
  }
}
 6cc:	60a6                	ld	ra,72(sp)
 6ce:	6406                	ld	s0,64(sp)
 6d0:	7942                	ld	s2,48(sp)
 6d2:	6161                	addi	sp,sp,80
 6d4:	8082                	ret

00000000000006d6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6d6:	715d                	addi	sp,sp,-80
 6d8:	ec06                	sd	ra,24(sp)
 6da:	e822                	sd	s0,16(sp)
 6dc:	1000                	addi	s0,sp,32
 6de:	e010                	sd	a2,0(s0)
 6e0:	e414                	sd	a3,8(s0)
 6e2:	e818                	sd	a4,16(s0)
 6e4:	ec1c                	sd	a5,24(s0)
 6e6:	03043023          	sd	a6,32(s0)
 6ea:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6ee:	8622                	mv	a2,s0
 6f0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6f4:	00000097          	auipc	ra,0x0
 6f8:	e14080e7          	jalr	-492(ra) # 508 <vprintf>
}
 6fc:	60e2                	ld	ra,24(sp)
 6fe:	6442                	ld	s0,16(sp)
 700:	6161                	addi	sp,sp,80
 702:	8082                	ret

0000000000000704 <printf>:

void
printf(const char *fmt, ...)
{
 704:	711d                	addi	sp,sp,-96
 706:	ec06                	sd	ra,24(sp)
 708:	e822                	sd	s0,16(sp)
 70a:	1000                	addi	s0,sp,32
 70c:	e40c                	sd	a1,8(s0)
 70e:	e810                	sd	a2,16(s0)
 710:	ec14                	sd	a3,24(s0)
 712:	f018                	sd	a4,32(s0)
 714:	f41c                	sd	a5,40(s0)
 716:	03043823          	sd	a6,48(s0)
 71a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 71e:	00840613          	addi	a2,s0,8
 722:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 726:	85aa                	mv	a1,a0
 728:	4505                	li	a0,1
 72a:	00000097          	auipc	ra,0x0
 72e:	dde080e7          	jalr	-546(ra) # 508 <vprintf>
}
 732:	60e2                	ld	ra,24(sp)
 734:	6442                	ld	s0,16(sp)
 736:	6125                	addi	sp,sp,96
 738:	8082                	ret

000000000000073a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 73a:	1141                	addi	sp,sp,-16
 73c:	e406                	sd	ra,8(sp)
 73e:	e022                	sd	s0,0(sp)
 740:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 742:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 746:	00000797          	auipc	a5,0x0
 74a:	65a7b783          	ld	a5,1626(a5) # da0 <freep>
 74e:	a039                	j	75c <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 750:	6398                	ld	a4,0(a5)
 752:	00e7e463          	bltu	a5,a4,75a <free+0x20>
 756:	00e6ea63          	bltu	a3,a4,76a <free+0x30>
{
 75a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 75c:	fed7fae3          	bgeu	a5,a3,750 <free+0x16>
 760:	6398                	ld	a4,0(a5)
 762:	00e6e463          	bltu	a3,a4,76a <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 766:	fee7eae3          	bltu	a5,a4,75a <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 76a:	ff852583          	lw	a1,-8(a0)
 76e:	6390                	ld	a2,0(a5)
 770:	02059813          	slli	a6,a1,0x20
 774:	01c85713          	srli	a4,a6,0x1c
 778:	9736                	add	a4,a4,a3
 77a:	02e60563          	beq	a2,a4,7a4 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 77e:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 782:	4790                	lw	a2,8(a5)
 784:	02061593          	slli	a1,a2,0x20
 788:	01c5d713          	srli	a4,a1,0x1c
 78c:	973e                	add	a4,a4,a5
 78e:	02e68263          	beq	a3,a4,7b2 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 792:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 794:	00000717          	auipc	a4,0x0
 798:	60f73623          	sd	a5,1548(a4) # da0 <freep>
}
 79c:	60a2                	ld	ra,8(sp)
 79e:	6402                	ld	s0,0(sp)
 7a0:	0141                	addi	sp,sp,16
 7a2:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 7a4:	4618                	lw	a4,8(a2)
 7a6:	9f2d                	addw	a4,a4,a1
 7a8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7ac:	6398                	ld	a4,0(a5)
 7ae:	6310                	ld	a2,0(a4)
 7b0:	b7f9                	j	77e <free+0x44>
    p->s.size += bp->s.size;
 7b2:	ff852703          	lw	a4,-8(a0)
 7b6:	9f31                	addw	a4,a4,a2
 7b8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7ba:	ff053683          	ld	a3,-16(a0)
 7be:	bfd1                	j	792 <free+0x58>

00000000000007c0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7c0:	7139                	addi	sp,sp,-64
 7c2:	fc06                	sd	ra,56(sp)
 7c4:	f822                	sd	s0,48(sp)
 7c6:	f04a                	sd	s2,32(sp)
 7c8:	ec4e                	sd	s3,24(sp)
 7ca:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7cc:	02051993          	slli	s3,a0,0x20
 7d0:	0209d993          	srli	s3,s3,0x20
 7d4:	09bd                	addi	s3,s3,15
 7d6:	0049d993          	srli	s3,s3,0x4
 7da:	2985                	addiw	s3,s3,1
 7dc:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 7de:	00000517          	auipc	a0,0x0
 7e2:	5c253503          	ld	a0,1474(a0) # da0 <freep>
 7e6:	c905                	beqz	a0,816 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7e8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ea:	4798                	lw	a4,8(a5)
 7ec:	09377a63          	bgeu	a4,s3,880 <malloc+0xc0>
 7f0:	f426                	sd	s1,40(sp)
 7f2:	e852                	sd	s4,16(sp)
 7f4:	e456                	sd	s5,8(sp)
 7f6:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7f8:	8a4e                	mv	s4,s3
 7fa:	6705                	lui	a4,0x1
 7fc:	00e9f363          	bgeu	s3,a4,802 <malloc+0x42>
 800:	6a05                	lui	s4,0x1
 802:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 806:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 80a:	00000497          	auipc	s1,0x0
 80e:	59648493          	addi	s1,s1,1430 # da0 <freep>
  if(p == (char*)-1)
 812:	5afd                	li	s5,-1
 814:	a089                	j	856 <malloc+0x96>
 816:	f426                	sd	s1,40(sp)
 818:	e852                	sd	s4,16(sp)
 81a:	e456                	sd	s5,8(sp)
 81c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 81e:	00000797          	auipc	a5,0x0
 822:	58a78793          	addi	a5,a5,1418 # da8 <base>
 826:	00000717          	auipc	a4,0x0
 82a:	56f73d23          	sd	a5,1402(a4) # da0 <freep>
 82e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 830:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 834:	b7d1                	j	7f8 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 836:	6398                	ld	a4,0(a5)
 838:	e118                	sd	a4,0(a0)
 83a:	a8b9                	j	898 <malloc+0xd8>
  hp->s.size = nu;
 83c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 840:	0541                	addi	a0,a0,16
 842:	00000097          	auipc	ra,0x0
 846:	ef8080e7          	jalr	-264(ra) # 73a <free>
  return freep;
 84a:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 84c:	c135                	beqz	a0,8b0 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 84e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 850:	4798                	lw	a4,8(a5)
 852:	03277363          	bgeu	a4,s2,878 <malloc+0xb8>
    if(p == freep)
 856:	6098                	ld	a4,0(s1)
 858:	853e                	mv	a0,a5
 85a:	fef71ae3          	bne	a4,a5,84e <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 85e:	8552                	mv	a0,s4
 860:	00000097          	auipc	ra,0x0
 864:	bae080e7          	jalr	-1106(ra) # 40e <sbrk>
  if(p == (char*)-1)
 868:	fd551ae3          	bne	a0,s5,83c <malloc+0x7c>
        return 0;
 86c:	4501                	li	a0,0
 86e:	74a2                	ld	s1,40(sp)
 870:	6a42                	ld	s4,16(sp)
 872:	6aa2                	ld	s5,8(sp)
 874:	6b02                	ld	s6,0(sp)
 876:	a03d                	j	8a4 <malloc+0xe4>
 878:	74a2                	ld	s1,40(sp)
 87a:	6a42                	ld	s4,16(sp)
 87c:	6aa2                	ld	s5,8(sp)
 87e:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 880:	fae90be3          	beq	s2,a4,836 <malloc+0x76>
        p->s.size -= nunits;
 884:	4137073b          	subw	a4,a4,s3
 888:	c798                	sw	a4,8(a5)
        p += p->s.size;
 88a:	02071693          	slli	a3,a4,0x20
 88e:	01c6d713          	srli	a4,a3,0x1c
 892:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 894:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 898:	00000717          	auipc	a4,0x0
 89c:	50a73423          	sd	a0,1288(a4) # da0 <freep>
      return (void*)(p + 1);
 8a0:	01078513          	addi	a0,a5,16
  }
}
 8a4:	70e2                	ld	ra,56(sp)
 8a6:	7442                	ld	s0,48(sp)
 8a8:	7902                	ld	s2,32(sp)
 8aa:	69e2                	ld	s3,24(sp)
 8ac:	6121                	addi	sp,sp,64
 8ae:	8082                	ret
 8b0:	74a2                	ld	s1,40(sp)
 8b2:	6a42                	ld	s4,16(sp)
 8b4:	6aa2                	ld	s5,8(sp)
 8b6:	6b02                	ld	s6,0(sp)
 8b8:	b7f5                	j	8a4 <malloc+0xe4>
