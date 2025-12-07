
user/_cat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	0080                	addi	s0,sp,64
  12:	89aa                	mv	s3,a0
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
  14:	20000a13          	li	s4,512
  18:	00001917          	auipc	s2,0x1
  1c:	dd090913          	addi	s2,s2,-560 # de8 <buf>
    if (write(1, buf, n) != n) {
  20:	4a85                	li	s5,1
  while((n = read(fd, buf, sizeof(buf))) > 0) {
  22:	8652                	mv	a2,s4
  24:	85ca                	mv	a1,s2
  26:	854e                	mv	a0,s3
  28:	00000097          	auipc	ra,0x0
  2c:	3ac080e7          	jalr	940(ra) # 3d4 <read>
  30:	84aa                	mv	s1,a0
  32:	02a05963          	blez	a0,64 <cat+0x64>
    if (write(1, buf, n) != n) {
  36:	8626                	mv	a2,s1
  38:	85ca                	mv	a1,s2
  3a:	8556                	mv	a0,s5
  3c:	00000097          	auipc	ra,0x0
  40:	3a0080e7          	jalr	928(ra) # 3dc <write>
  44:	fc950fe3          	beq	a0,s1,22 <cat+0x22>
      fprintf(2, "cat: write error\n");
  48:	00001597          	auipc	a1,0x1
  4c:	8a858593          	addi	a1,a1,-1880 # 8f0 <malloc+0xfa>
  50:	4509                	li	a0,2
  52:	00000097          	auipc	ra,0x0
  56:	6ba080e7          	jalr	1722(ra) # 70c <fprintf>
      exit(1);
  5a:	4505                	li	a0,1
  5c:	00000097          	auipc	ra,0x0
  60:	360080e7          	jalr	864(ra) # 3bc <exit>
    }
  }
  if(n < 0){
  64:	00054b63          	bltz	a0,7a <cat+0x7a>
    fprintf(2, "cat: read error\n");
    exit(1);
  }
}
  68:	70e2                	ld	ra,56(sp)
  6a:	7442                	ld	s0,48(sp)
  6c:	74a2                	ld	s1,40(sp)
  6e:	7902                	ld	s2,32(sp)
  70:	69e2                	ld	s3,24(sp)
  72:	6a42                	ld	s4,16(sp)
  74:	6aa2                	ld	s5,8(sp)
  76:	6121                	addi	sp,sp,64
  78:	8082                	ret
    fprintf(2, "cat: read error\n");
  7a:	00001597          	auipc	a1,0x1
  7e:	88e58593          	addi	a1,a1,-1906 # 908 <malloc+0x112>
  82:	4509                	li	a0,2
  84:	00000097          	auipc	ra,0x0
  88:	688080e7          	jalr	1672(ra) # 70c <fprintf>
    exit(1);
  8c:	4505                	li	a0,1
  8e:	00000097          	auipc	ra,0x0
  92:	32e080e7          	jalr	814(ra) # 3bc <exit>

0000000000000096 <main>:

int
main(int argc, char *argv[])
{
  96:	7179                	addi	sp,sp,-48
  98:	f406                	sd	ra,40(sp)
  9a:	f022                	sd	s0,32(sp)
  9c:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  9e:	4785                	li	a5,1
  a0:	04a7da63          	bge	a5,a0,f4 <main+0x5e>
  a4:	ec26                	sd	s1,24(sp)
  a6:	e84a                	sd	s2,16(sp)
  a8:	e44e                	sd	s3,8(sp)
  aa:	00858913          	addi	s2,a1,8
  ae:	ffe5099b          	addiw	s3,a0,-2
  b2:	02099793          	slli	a5,s3,0x20
  b6:	01d7d993          	srli	s3,a5,0x1d
  ba:	05c1                	addi	a1,a1,16
  bc:	99ae                	add	s3,s3,a1
    cat(0);
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
  be:	4581                	li	a1,0
  c0:	00093503          	ld	a0,0(s2)
  c4:	00000097          	auipc	ra,0x0
  c8:	338080e7          	jalr	824(ra) # 3fc <open>
  cc:	84aa                	mv	s1,a0
  ce:	04054063          	bltz	a0,10e <main+0x78>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
      exit(1);
    }
    cat(fd);
  d2:	00000097          	auipc	ra,0x0
  d6:	f2e080e7          	jalr	-210(ra) # 0 <cat>
    close(fd);
  da:	8526                	mv	a0,s1
  dc:	00000097          	auipc	ra,0x0
  e0:	308080e7          	jalr	776(ra) # 3e4 <close>
  for(i = 1; i < argc; i++){
  e4:	0921                	addi	s2,s2,8
  e6:	fd391ce3          	bne	s2,s3,be <main+0x28>
  }
  exit(0);
  ea:	4501                	li	a0,0
  ec:	00000097          	auipc	ra,0x0
  f0:	2d0080e7          	jalr	720(ra) # 3bc <exit>
  f4:	ec26                	sd	s1,24(sp)
  f6:	e84a                	sd	s2,16(sp)
  f8:	e44e                	sd	s3,8(sp)
    cat(0);
  fa:	4501                	li	a0,0
  fc:	00000097          	auipc	ra,0x0
 100:	f04080e7          	jalr	-252(ra) # 0 <cat>
    exit(0);
 104:	4501                	li	a0,0
 106:	00000097          	auipc	ra,0x0
 10a:	2b6080e7          	jalr	694(ra) # 3bc <exit>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
 10e:	00093603          	ld	a2,0(s2)
 112:	00001597          	auipc	a1,0x1
 116:	80e58593          	addi	a1,a1,-2034 # 920 <malloc+0x12a>
 11a:	4509                	li	a0,2
 11c:	00000097          	auipc	ra,0x0
 120:	5f0080e7          	jalr	1520(ra) # 70c <fprintf>
      exit(1);
 124:	4505                	li	a0,1
 126:	00000097          	auipc	ra,0x0
 12a:	296080e7          	jalr	662(ra) # 3bc <exit>

000000000000012e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 12e:	1141                	addi	sp,sp,-16
 130:	e406                	sd	ra,8(sp)
 132:	e022                	sd	s0,0(sp)
 134:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 136:	87aa                	mv	a5,a0
 138:	0585                	addi	a1,a1,1
 13a:	0785                	addi	a5,a5,1
 13c:	fff5c703          	lbu	a4,-1(a1)
 140:	fee78fa3          	sb	a4,-1(a5)
 144:	fb75                	bnez	a4,138 <strcpy+0xa>
    ;
  return os;
}
 146:	60a2                	ld	ra,8(sp)
 148:	6402                	ld	s0,0(sp)
 14a:	0141                	addi	sp,sp,16
 14c:	8082                	ret

000000000000014e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 14e:	1141                	addi	sp,sp,-16
 150:	e406                	sd	ra,8(sp)
 152:	e022                	sd	s0,0(sp)
 154:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 156:	00054783          	lbu	a5,0(a0)
 15a:	cb91                	beqz	a5,16e <strcmp+0x20>
 15c:	0005c703          	lbu	a4,0(a1)
 160:	00f71763          	bne	a4,a5,16e <strcmp+0x20>
    p++, q++;
 164:	0505                	addi	a0,a0,1
 166:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 168:	00054783          	lbu	a5,0(a0)
 16c:	fbe5                	bnez	a5,15c <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 16e:	0005c503          	lbu	a0,0(a1)
}
 172:	40a7853b          	subw	a0,a5,a0
 176:	60a2                	ld	ra,8(sp)
 178:	6402                	ld	s0,0(sp)
 17a:	0141                	addi	sp,sp,16
 17c:	8082                	ret

000000000000017e <strlen>:

uint
strlen(const char *s)
{
 17e:	1141                	addi	sp,sp,-16
 180:	e406                	sd	ra,8(sp)
 182:	e022                	sd	s0,0(sp)
 184:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 186:	00054783          	lbu	a5,0(a0)
 18a:	cf91                	beqz	a5,1a6 <strlen+0x28>
 18c:	00150793          	addi	a5,a0,1
 190:	86be                	mv	a3,a5
 192:	0785                	addi	a5,a5,1
 194:	fff7c703          	lbu	a4,-1(a5)
 198:	ff65                	bnez	a4,190 <strlen+0x12>
 19a:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 19e:	60a2                	ld	ra,8(sp)
 1a0:	6402                	ld	s0,0(sp)
 1a2:	0141                	addi	sp,sp,16
 1a4:	8082                	ret
  for(n = 0; s[n]; n++)
 1a6:	4501                	li	a0,0
 1a8:	bfdd                	j	19e <strlen+0x20>

00000000000001aa <memset>:

void*
memset(void *dst, int c, uint n)
{
 1aa:	1141                	addi	sp,sp,-16
 1ac:	e406                	sd	ra,8(sp)
 1ae:	e022                	sd	s0,0(sp)
 1b0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1b2:	ca19                	beqz	a2,1c8 <memset+0x1e>
 1b4:	87aa                	mv	a5,a0
 1b6:	1602                	slli	a2,a2,0x20
 1b8:	9201                	srli	a2,a2,0x20
 1ba:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1be:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1c2:	0785                	addi	a5,a5,1
 1c4:	fee79de3          	bne	a5,a4,1be <memset+0x14>
  }
  return dst;
}
 1c8:	60a2                	ld	ra,8(sp)
 1ca:	6402                	ld	s0,0(sp)
 1cc:	0141                	addi	sp,sp,16
 1ce:	8082                	ret

00000000000001d0 <strchr>:

char*
strchr(const char *s, char c)
{
 1d0:	1141                	addi	sp,sp,-16
 1d2:	e406                	sd	ra,8(sp)
 1d4:	e022                	sd	s0,0(sp)
 1d6:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1d8:	00054783          	lbu	a5,0(a0)
 1dc:	cf81                	beqz	a5,1f4 <strchr+0x24>
    if(*s == c)
 1de:	00f58763          	beq	a1,a5,1ec <strchr+0x1c>
  for(; *s; s++)
 1e2:	0505                	addi	a0,a0,1
 1e4:	00054783          	lbu	a5,0(a0)
 1e8:	fbfd                	bnez	a5,1de <strchr+0xe>
      return (char*)s;
  return 0;
 1ea:	4501                	li	a0,0
}
 1ec:	60a2                	ld	ra,8(sp)
 1ee:	6402                	ld	s0,0(sp)
 1f0:	0141                	addi	sp,sp,16
 1f2:	8082                	ret
  return 0;
 1f4:	4501                	li	a0,0
 1f6:	bfdd                	j	1ec <strchr+0x1c>

00000000000001f8 <gets>:

char*
gets(char *buf, int max)
{
 1f8:	711d                	addi	sp,sp,-96
 1fa:	ec86                	sd	ra,88(sp)
 1fc:	e8a2                	sd	s0,80(sp)
 1fe:	e4a6                	sd	s1,72(sp)
 200:	e0ca                	sd	s2,64(sp)
 202:	fc4e                	sd	s3,56(sp)
 204:	f852                	sd	s4,48(sp)
 206:	f456                	sd	s5,40(sp)
 208:	f05a                	sd	s6,32(sp)
 20a:	ec5e                	sd	s7,24(sp)
 20c:	e862                	sd	s8,16(sp)
 20e:	1080                	addi	s0,sp,96
 210:	8baa                	mv	s7,a0
 212:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 214:	892a                	mv	s2,a0
 216:	4481                	li	s1,0
    cc = read(0, &c, 1);
 218:	faf40b13          	addi	s6,s0,-81
 21c:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 21e:	8c26                	mv	s8,s1
 220:	0014899b          	addiw	s3,s1,1
 224:	84ce                	mv	s1,s3
 226:	0349d663          	bge	s3,s4,252 <gets+0x5a>
    cc = read(0, &c, 1);
 22a:	8656                	mv	a2,s5
 22c:	85da                	mv	a1,s6
 22e:	4501                	li	a0,0
 230:	00000097          	auipc	ra,0x0
 234:	1a4080e7          	jalr	420(ra) # 3d4 <read>
    if(cc < 1)
 238:	00a05d63          	blez	a0,252 <gets+0x5a>
      break;
    buf[i++] = c;
 23c:	faf44783          	lbu	a5,-81(s0)
 240:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 244:	0905                	addi	s2,s2,1
 246:	ff678713          	addi	a4,a5,-10
 24a:	c319                	beqz	a4,250 <gets+0x58>
 24c:	17cd                	addi	a5,a5,-13
 24e:	fbe1                	bnez	a5,21e <gets+0x26>
    buf[i++] = c;
 250:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 252:	9c5e                	add	s8,s8,s7
 254:	000c0023          	sb	zero,0(s8)
  return buf;
}
 258:	855e                	mv	a0,s7
 25a:	60e6                	ld	ra,88(sp)
 25c:	6446                	ld	s0,80(sp)
 25e:	64a6                	ld	s1,72(sp)
 260:	6906                	ld	s2,64(sp)
 262:	79e2                	ld	s3,56(sp)
 264:	7a42                	ld	s4,48(sp)
 266:	7aa2                	ld	s5,40(sp)
 268:	7b02                	ld	s6,32(sp)
 26a:	6be2                	ld	s7,24(sp)
 26c:	6c42                	ld	s8,16(sp)
 26e:	6125                	addi	sp,sp,96
 270:	8082                	ret

0000000000000272 <stat>:

int
stat(const char *n, struct stat *st)
{
 272:	1101                	addi	sp,sp,-32
 274:	ec06                	sd	ra,24(sp)
 276:	e822                	sd	s0,16(sp)
 278:	e04a                	sd	s2,0(sp)
 27a:	1000                	addi	s0,sp,32
 27c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 27e:	4581                	li	a1,0
 280:	00000097          	auipc	ra,0x0
 284:	17c080e7          	jalr	380(ra) # 3fc <open>
  if(fd < 0)
 288:	02054663          	bltz	a0,2b4 <stat+0x42>
 28c:	e426                	sd	s1,8(sp)
 28e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 290:	85ca                	mv	a1,s2
 292:	00000097          	auipc	ra,0x0
 296:	182080e7          	jalr	386(ra) # 414 <fstat>
 29a:	892a                	mv	s2,a0
  close(fd);
 29c:	8526                	mv	a0,s1
 29e:	00000097          	auipc	ra,0x0
 2a2:	146080e7          	jalr	326(ra) # 3e4 <close>
  return r;
 2a6:	64a2                	ld	s1,8(sp)
}
 2a8:	854a                	mv	a0,s2
 2aa:	60e2                	ld	ra,24(sp)
 2ac:	6442                	ld	s0,16(sp)
 2ae:	6902                	ld	s2,0(sp)
 2b0:	6105                	addi	sp,sp,32
 2b2:	8082                	ret
    return -1;
 2b4:	57fd                	li	a5,-1
 2b6:	893e                	mv	s2,a5
 2b8:	bfc5                	j	2a8 <stat+0x36>

00000000000002ba <atoi>:

int
atoi(const char *s)
{
 2ba:	1141                	addi	sp,sp,-16
 2bc:	e406                	sd	ra,8(sp)
 2be:	e022                	sd	s0,0(sp)
 2c0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2c2:	00054683          	lbu	a3,0(a0)
 2c6:	fd06879b          	addiw	a5,a3,-48
 2ca:	0ff7f793          	zext.b	a5,a5
 2ce:	4625                	li	a2,9
 2d0:	02f66963          	bltu	a2,a5,302 <atoi+0x48>
 2d4:	872a                	mv	a4,a0
  n = 0;
 2d6:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2d8:	0705                	addi	a4,a4,1
 2da:	0025179b          	slliw	a5,a0,0x2
 2de:	9fa9                	addw	a5,a5,a0
 2e0:	0017979b          	slliw	a5,a5,0x1
 2e4:	9fb5                	addw	a5,a5,a3
 2e6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2ea:	00074683          	lbu	a3,0(a4)
 2ee:	fd06879b          	addiw	a5,a3,-48
 2f2:	0ff7f793          	zext.b	a5,a5
 2f6:	fef671e3          	bgeu	a2,a5,2d8 <atoi+0x1e>
  return n;
}
 2fa:	60a2                	ld	ra,8(sp)
 2fc:	6402                	ld	s0,0(sp)
 2fe:	0141                	addi	sp,sp,16
 300:	8082                	ret
  n = 0;
 302:	4501                	li	a0,0
 304:	bfdd                	j	2fa <atoi+0x40>

0000000000000306 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 306:	1141                	addi	sp,sp,-16
 308:	e406                	sd	ra,8(sp)
 30a:	e022                	sd	s0,0(sp)
 30c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 30e:	02b57563          	bgeu	a0,a1,338 <memmove+0x32>
    while(n-- > 0)
 312:	00c05f63          	blez	a2,330 <memmove+0x2a>
 316:	1602                	slli	a2,a2,0x20
 318:	9201                	srli	a2,a2,0x20
 31a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 31e:	872a                	mv	a4,a0
      *dst++ = *src++;
 320:	0585                	addi	a1,a1,1
 322:	0705                	addi	a4,a4,1
 324:	fff5c683          	lbu	a3,-1(a1)
 328:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 32c:	fee79ae3          	bne	a5,a4,320 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 330:	60a2                	ld	ra,8(sp)
 332:	6402                	ld	s0,0(sp)
 334:	0141                	addi	sp,sp,16
 336:	8082                	ret
    while(n-- > 0)
 338:	fec05ce3          	blez	a2,330 <memmove+0x2a>
    dst += n;
 33c:	00c50733          	add	a4,a0,a2
    src += n;
 340:	95b2                	add	a1,a1,a2
 342:	fff6079b          	addiw	a5,a2,-1
 346:	1782                	slli	a5,a5,0x20
 348:	9381                	srli	a5,a5,0x20
 34a:	fff7c793          	not	a5,a5
 34e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 350:	15fd                	addi	a1,a1,-1
 352:	177d                	addi	a4,a4,-1
 354:	0005c683          	lbu	a3,0(a1)
 358:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 35c:	fef71ae3          	bne	a4,a5,350 <memmove+0x4a>
 360:	bfc1                	j	330 <memmove+0x2a>

0000000000000362 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 362:	1141                	addi	sp,sp,-16
 364:	e406                	sd	ra,8(sp)
 366:	e022                	sd	s0,0(sp)
 368:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 36a:	c61d                	beqz	a2,398 <memcmp+0x36>
 36c:	1602                	slli	a2,a2,0x20
 36e:	9201                	srli	a2,a2,0x20
 370:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 374:	00054783          	lbu	a5,0(a0)
 378:	0005c703          	lbu	a4,0(a1)
 37c:	00e79863          	bne	a5,a4,38c <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 380:	0505                	addi	a0,a0,1
    p2++;
 382:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 384:	fed518e3          	bne	a0,a3,374 <memcmp+0x12>
  }
  return 0;
 388:	4501                	li	a0,0
 38a:	a019                	j	390 <memcmp+0x2e>
      return *p1 - *p2;
 38c:	40e7853b          	subw	a0,a5,a4
}
 390:	60a2                	ld	ra,8(sp)
 392:	6402                	ld	s0,0(sp)
 394:	0141                	addi	sp,sp,16
 396:	8082                	ret
  return 0;
 398:	4501                	li	a0,0
 39a:	bfdd                	j	390 <memcmp+0x2e>

000000000000039c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 39c:	1141                	addi	sp,sp,-16
 39e:	e406                	sd	ra,8(sp)
 3a0:	e022                	sd	s0,0(sp)
 3a2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3a4:	00000097          	auipc	ra,0x0
 3a8:	f62080e7          	jalr	-158(ra) # 306 <memmove>
}
 3ac:	60a2                	ld	ra,8(sp)
 3ae:	6402                	ld	s0,0(sp)
 3b0:	0141                	addi	sp,sp,16
 3b2:	8082                	ret

00000000000003b4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3b4:	4885                	li	a7,1
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <exit>:
.global exit
exit:
 li a7, SYS_exit
 3bc:	4889                	li	a7,2
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3c4:	488d                	li	a7,3
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3cc:	4891                	li	a7,4
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <read>:
.global read
read:
 li a7, SYS_read
 3d4:	4895                	li	a7,5
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <write>:
.global write
write:
 li a7, SYS_write
 3dc:	48c1                	li	a7,16
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <close>:
.global close
close:
 li a7, SYS_close
 3e4:	48d5                	li	a7,21
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <kill>:
.global kill
kill:
 li a7, SYS_kill
 3ec:	4899                	li	a7,6
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3f4:	489d                	li	a7,7
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <open>:
.global open
open:
 li a7, SYS_open
 3fc:	48bd                	li	a7,15
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 404:	48c5                	li	a7,17
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 40c:	48c9                	li	a7,18
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 414:	48a1                	li	a7,8
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <link>:
.global link
link:
 li a7, SYS_link
 41c:	48cd                	li	a7,19
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 424:	48d1                	li	a7,20
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 42c:	48a5                	li	a7,9
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <dup>:
.global dup
dup:
 li a7, SYS_dup
 434:	48a9                	li	a7,10
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 43c:	48ad                	li	a7,11
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 444:	48b1                	li	a7,12
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 44c:	48b5                	li	a7,13
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 454:	48b9                	li	a7,14
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <trace>:
.global trace
trace:
 li a7, SYS_trace
 45c:	48d9                	li	a7,22
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 464:	48dd                	li	a7,23
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 46c:	48e1                	li	a7,24
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 474:	1101                	addi	sp,sp,-32
 476:	ec06                	sd	ra,24(sp)
 478:	e822                	sd	s0,16(sp)
 47a:	1000                	addi	s0,sp,32
 47c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 480:	4605                	li	a2,1
 482:	fef40593          	addi	a1,s0,-17
 486:	00000097          	auipc	ra,0x0
 48a:	f56080e7          	jalr	-170(ra) # 3dc <write>
}
 48e:	60e2                	ld	ra,24(sp)
 490:	6442                	ld	s0,16(sp)
 492:	6105                	addi	sp,sp,32
 494:	8082                	ret

0000000000000496 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 496:	7139                	addi	sp,sp,-64
 498:	fc06                	sd	ra,56(sp)
 49a:	f822                	sd	s0,48(sp)
 49c:	f04a                	sd	s2,32(sp)
 49e:	ec4e                	sd	s3,24(sp)
 4a0:	0080                	addi	s0,sp,64
 4a2:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4a4:	cad9                	beqz	a3,53a <printint+0xa4>
 4a6:	01f5d79b          	srliw	a5,a1,0x1f
 4aa:	cbc1                	beqz	a5,53a <printint+0xa4>
    neg = 1;
    x = -xx;
 4ac:	40b005bb          	negw	a1,a1
    neg = 1;
 4b0:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 4b2:	fc040993          	addi	s3,s0,-64
  neg = 0;
 4b6:	86ce                	mv	a3,s3
  i = 0;
 4b8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4ba:	00000817          	auipc	a6,0x0
 4be:	4de80813          	addi	a6,a6,1246 # 998 <digits>
 4c2:	88ba                	mv	a7,a4
 4c4:	0017051b          	addiw	a0,a4,1
 4c8:	872a                	mv	a4,a0
 4ca:	02c5f7bb          	remuw	a5,a1,a2
 4ce:	1782                	slli	a5,a5,0x20
 4d0:	9381                	srli	a5,a5,0x20
 4d2:	97c2                	add	a5,a5,a6
 4d4:	0007c783          	lbu	a5,0(a5)
 4d8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4dc:	87ae                	mv	a5,a1
 4de:	02c5d5bb          	divuw	a1,a1,a2
 4e2:	0685                	addi	a3,a3,1
 4e4:	fcc7ffe3          	bgeu	a5,a2,4c2 <printint+0x2c>
  if(neg)
 4e8:	00030c63          	beqz	t1,500 <printint+0x6a>
    buf[i++] = '-';
 4ec:	fd050793          	addi	a5,a0,-48
 4f0:	00878533          	add	a0,a5,s0
 4f4:	02d00793          	li	a5,45
 4f8:	fef50823          	sb	a5,-16(a0)
 4fc:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 500:	02e05763          	blez	a4,52e <printint+0x98>
 504:	f426                	sd	s1,40(sp)
 506:	377d                	addiw	a4,a4,-1
 508:	00e984b3          	add	s1,s3,a4
 50c:	19fd                	addi	s3,s3,-1
 50e:	99ba                	add	s3,s3,a4
 510:	1702                	slli	a4,a4,0x20
 512:	9301                	srli	a4,a4,0x20
 514:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 518:	0004c583          	lbu	a1,0(s1)
 51c:	854a                	mv	a0,s2
 51e:	00000097          	auipc	ra,0x0
 522:	f56080e7          	jalr	-170(ra) # 474 <putc>
  while(--i >= 0)
 526:	14fd                	addi	s1,s1,-1
 528:	ff3498e3          	bne	s1,s3,518 <printint+0x82>
 52c:	74a2                	ld	s1,40(sp)
}
 52e:	70e2                	ld	ra,56(sp)
 530:	7442                	ld	s0,48(sp)
 532:	7902                	ld	s2,32(sp)
 534:	69e2                	ld	s3,24(sp)
 536:	6121                	addi	sp,sp,64
 538:	8082                	ret
  neg = 0;
 53a:	4301                	li	t1,0
 53c:	bf9d                	j	4b2 <printint+0x1c>

000000000000053e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 53e:	715d                	addi	sp,sp,-80
 540:	e486                	sd	ra,72(sp)
 542:	e0a2                	sd	s0,64(sp)
 544:	f84a                	sd	s2,48(sp)
 546:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 548:	0005c903          	lbu	s2,0(a1)
 54c:	1a090b63          	beqz	s2,702 <vprintf+0x1c4>
 550:	fc26                	sd	s1,56(sp)
 552:	f44e                	sd	s3,40(sp)
 554:	f052                	sd	s4,32(sp)
 556:	ec56                	sd	s5,24(sp)
 558:	e85a                	sd	s6,16(sp)
 55a:	e45e                	sd	s7,8(sp)
 55c:	8aaa                	mv	s5,a0
 55e:	8bb2                	mv	s7,a2
 560:	00158493          	addi	s1,a1,1
  state = 0;
 564:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 566:	02500a13          	li	s4,37
 56a:	4b55                	li	s6,21
 56c:	a839                	j	58a <vprintf+0x4c>
        putc(fd, c);
 56e:	85ca                	mv	a1,s2
 570:	8556                	mv	a0,s5
 572:	00000097          	auipc	ra,0x0
 576:	f02080e7          	jalr	-254(ra) # 474 <putc>
 57a:	a019                	j	580 <vprintf+0x42>
    } else if(state == '%'){
 57c:	01498d63          	beq	s3,s4,596 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 580:	0485                	addi	s1,s1,1
 582:	fff4c903          	lbu	s2,-1(s1)
 586:	16090863          	beqz	s2,6f6 <vprintf+0x1b8>
    if(state == 0){
 58a:	fe0999e3          	bnez	s3,57c <vprintf+0x3e>
      if(c == '%'){
 58e:	ff4910e3          	bne	s2,s4,56e <vprintf+0x30>
        state = '%';
 592:	89d2                	mv	s3,s4
 594:	b7f5                	j	580 <vprintf+0x42>
      if(c == 'd'){
 596:	13490563          	beq	s2,s4,6c0 <vprintf+0x182>
 59a:	f9d9079b          	addiw	a5,s2,-99
 59e:	0ff7f793          	zext.b	a5,a5
 5a2:	12fb6863          	bltu	s6,a5,6d2 <vprintf+0x194>
 5a6:	f9d9079b          	addiw	a5,s2,-99
 5aa:	0ff7f713          	zext.b	a4,a5
 5ae:	12eb6263          	bltu	s6,a4,6d2 <vprintf+0x194>
 5b2:	00271793          	slli	a5,a4,0x2
 5b6:	00000717          	auipc	a4,0x0
 5ba:	38a70713          	addi	a4,a4,906 # 940 <malloc+0x14a>
 5be:	97ba                	add	a5,a5,a4
 5c0:	439c                	lw	a5,0(a5)
 5c2:	97ba                	add	a5,a5,a4
 5c4:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5c6:	008b8913          	addi	s2,s7,8
 5ca:	4685                	li	a3,1
 5cc:	4629                	li	a2,10
 5ce:	000ba583          	lw	a1,0(s7)
 5d2:	8556                	mv	a0,s5
 5d4:	00000097          	auipc	ra,0x0
 5d8:	ec2080e7          	jalr	-318(ra) # 496 <printint>
 5dc:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5de:	4981                	li	s3,0
 5e0:	b745                	j	580 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5e2:	008b8913          	addi	s2,s7,8
 5e6:	4681                	li	a3,0
 5e8:	4629                	li	a2,10
 5ea:	000ba583          	lw	a1,0(s7)
 5ee:	8556                	mv	a0,s5
 5f0:	00000097          	auipc	ra,0x0
 5f4:	ea6080e7          	jalr	-346(ra) # 496 <printint>
 5f8:	8bca                	mv	s7,s2
      state = 0;
 5fa:	4981                	li	s3,0
 5fc:	b751                	j	580 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 5fe:	008b8913          	addi	s2,s7,8
 602:	4681                	li	a3,0
 604:	4641                	li	a2,16
 606:	000ba583          	lw	a1,0(s7)
 60a:	8556                	mv	a0,s5
 60c:	00000097          	auipc	ra,0x0
 610:	e8a080e7          	jalr	-374(ra) # 496 <printint>
 614:	8bca                	mv	s7,s2
      state = 0;
 616:	4981                	li	s3,0
 618:	b7a5                	j	580 <vprintf+0x42>
 61a:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 61c:	008b8793          	addi	a5,s7,8
 620:	8c3e                	mv	s8,a5
 622:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 626:	03000593          	li	a1,48
 62a:	8556                	mv	a0,s5
 62c:	00000097          	auipc	ra,0x0
 630:	e48080e7          	jalr	-440(ra) # 474 <putc>
  putc(fd, 'x');
 634:	07800593          	li	a1,120
 638:	8556                	mv	a0,s5
 63a:	00000097          	auipc	ra,0x0
 63e:	e3a080e7          	jalr	-454(ra) # 474 <putc>
 642:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 644:	00000b97          	auipc	s7,0x0
 648:	354b8b93          	addi	s7,s7,852 # 998 <digits>
 64c:	03c9d793          	srli	a5,s3,0x3c
 650:	97de                	add	a5,a5,s7
 652:	0007c583          	lbu	a1,0(a5)
 656:	8556                	mv	a0,s5
 658:	00000097          	auipc	ra,0x0
 65c:	e1c080e7          	jalr	-484(ra) # 474 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 660:	0992                	slli	s3,s3,0x4
 662:	397d                	addiw	s2,s2,-1
 664:	fe0914e3          	bnez	s2,64c <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
 668:	8be2                	mv	s7,s8
      state = 0;
 66a:	4981                	li	s3,0
 66c:	6c02                	ld	s8,0(sp)
 66e:	bf09                	j	580 <vprintf+0x42>
        s = va_arg(ap, char*);
 670:	008b8993          	addi	s3,s7,8
 674:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 678:	02090163          	beqz	s2,69a <vprintf+0x15c>
        while(*s != 0){
 67c:	00094583          	lbu	a1,0(s2)
 680:	c9a5                	beqz	a1,6f0 <vprintf+0x1b2>
          putc(fd, *s);
 682:	8556                	mv	a0,s5
 684:	00000097          	auipc	ra,0x0
 688:	df0080e7          	jalr	-528(ra) # 474 <putc>
          s++;
 68c:	0905                	addi	s2,s2,1
        while(*s != 0){
 68e:	00094583          	lbu	a1,0(s2)
 692:	f9e5                	bnez	a1,682 <vprintf+0x144>
        s = va_arg(ap, char*);
 694:	8bce                	mv	s7,s3
      state = 0;
 696:	4981                	li	s3,0
 698:	b5e5                	j	580 <vprintf+0x42>
          s = "(null)";
 69a:	00000917          	auipc	s2,0x0
 69e:	29e90913          	addi	s2,s2,670 # 938 <malloc+0x142>
        while(*s != 0){
 6a2:	02800593          	li	a1,40
 6a6:	bff1                	j	682 <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
 6a8:	008b8913          	addi	s2,s7,8
 6ac:	000bc583          	lbu	a1,0(s7)
 6b0:	8556                	mv	a0,s5
 6b2:	00000097          	auipc	ra,0x0
 6b6:	dc2080e7          	jalr	-574(ra) # 474 <putc>
 6ba:	8bca                	mv	s7,s2
      state = 0;
 6bc:	4981                	li	s3,0
 6be:	b5c9                	j	580 <vprintf+0x42>
        putc(fd, c);
 6c0:	02500593          	li	a1,37
 6c4:	8556                	mv	a0,s5
 6c6:	00000097          	auipc	ra,0x0
 6ca:	dae080e7          	jalr	-594(ra) # 474 <putc>
      state = 0;
 6ce:	4981                	li	s3,0
 6d0:	bd45                	j	580 <vprintf+0x42>
        putc(fd, '%');
 6d2:	02500593          	li	a1,37
 6d6:	8556                	mv	a0,s5
 6d8:	00000097          	auipc	ra,0x0
 6dc:	d9c080e7          	jalr	-612(ra) # 474 <putc>
        putc(fd, c);
 6e0:	85ca                	mv	a1,s2
 6e2:	8556                	mv	a0,s5
 6e4:	00000097          	auipc	ra,0x0
 6e8:	d90080e7          	jalr	-624(ra) # 474 <putc>
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	bd49                	j	580 <vprintf+0x42>
        s = va_arg(ap, char*);
 6f0:	8bce                	mv	s7,s3
      state = 0;
 6f2:	4981                	li	s3,0
 6f4:	b571                	j	580 <vprintf+0x42>
 6f6:	74e2                	ld	s1,56(sp)
 6f8:	79a2                	ld	s3,40(sp)
 6fa:	7a02                	ld	s4,32(sp)
 6fc:	6ae2                	ld	s5,24(sp)
 6fe:	6b42                	ld	s6,16(sp)
 700:	6ba2                	ld	s7,8(sp)
    }
  }
}
 702:	60a6                	ld	ra,72(sp)
 704:	6406                	ld	s0,64(sp)
 706:	7942                	ld	s2,48(sp)
 708:	6161                	addi	sp,sp,80
 70a:	8082                	ret

000000000000070c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 70c:	715d                	addi	sp,sp,-80
 70e:	ec06                	sd	ra,24(sp)
 710:	e822                	sd	s0,16(sp)
 712:	1000                	addi	s0,sp,32
 714:	e010                	sd	a2,0(s0)
 716:	e414                	sd	a3,8(s0)
 718:	e818                	sd	a4,16(s0)
 71a:	ec1c                	sd	a5,24(s0)
 71c:	03043023          	sd	a6,32(s0)
 720:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 724:	8622                	mv	a2,s0
 726:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 72a:	00000097          	auipc	ra,0x0
 72e:	e14080e7          	jalr	-492(ra) # 53e <vprintf>
}
 732:	60e2                	ld	ra,24(sp)
 734:	6442                	ld	s0,16(sp)
 736:	6161                	addi	sp,sp,80
 738:	8082                	ret

000000000000073a <printf>:

void
printf(const char *fmt, ...)
{
 73a:	711d                	addi	sp,sp,-96
 73c:	ec06                	sd	ra,24(sp)
 73e:	e822                	sd	s0,16(sp)
 740:	1000                	addi	s0,sp,32
 742:	e40c                	sd	a1,8(s0)
 744:	e810                	sd	a2,16(s0)
 746:	ec14                	sd	a3,24(s0)
 748:	f018                	sd	a4,32(s0)
 74a:	f41c                	sd	a5,40(s0)
 74c:	03043823          	sd	a6,48(s0)
 750:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 754:	00840613          	addi	a2,s0,8
 758:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 75c:	85aa                	mv	a1,a0
 75e:	4505                	li	a0,1
 760:	00000097          	auipc	ra,0x0
 764:	dde080e7          	jalr	-546(ra) # 53e <vprintf>
}
 768:	60e2                	ld	ra,24(sp)
 76a:	6442                	ld	s0,16(sp)
 76c:	6125                	addi	sp,sp,96
 76e:	8082                	ret

0000000000000770 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 770:	1141                	addi	sp,sp,-16
 772:	e406                	sd	ra,8(sp)
 774:	e022                	sd	s0,0(sp)
 776:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 778:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 77c:	00000797          	auipc	a5,0x0
 780:	6647b783          	ld	a5,1636(a5) # de0 <freep>
 784:	a039                	j	792 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 786:	6398                	ld	a4,0(a5)
 788:	00e7e463          	bltu	a5,a4,790 <free+0x20>
 78c:	00e6ea63          	bltu	a3,a4,7a0 <free+0x30>
{
 790:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 792:	fed7fae3          	bgeu	a5,a3,786 <free+0x16>
 796:	6398                	ld	a4,0(a5)
 798:	00e6e463          	bltu	a3,a4,7a0 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 79c:	fee7eae3          	bltu	a5,a4,790 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7a0:	ff852583          	lw	a1,-8(a0)
 7a4:	6390                	ld	a2,0(a5)
 7a6:	02059813          	slli	a6,a1,0x20
 7aa:	01c85713          	srli	a4,a6,0x1c
 7ae:	9736                	add	a4,a4,a3
 7b0:	02e60563          	beq	a2,a4,7da <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 7b4:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 7b8:	4790                	lw	a2,8(a5)
 7ba:	02061593          	slli	a1,a2,0x20
 7be:	01c5d713          	srli	a4,a1,0x1c
 7c2:	973e                	add	a4,a4,a5
 7c4:	02e68263          	beq	a3,a4,7e8 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 7c8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7ca:	00000717          	auipc	a4,0x0
 7ce:	60f73b23          	sd	a5,1558(a4) # de0 <freep>
}
 7d2:	60a2                	ld	ra,8(sp)
 7d4:	6402                	ld	s0,0(sp)
 7d6:	0141                	addi	sp,sp,16
 7d8:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 7da:	4618                	lw	a4,8(a2)
 7dc:	9f2d                	addw	a4,a4,a1
 7de:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7e2:	6398                	ld	a4,0(a5)
 7e4:	6310                	ld	a2,0(a4)
 7e6:	b7f9                	j	7b4 <free+0x44>
    p->s.size += bp->s.size;
 7e8:	ff852703          	lw	a4,-8(a0)
 7ec:	9f31                	addw	a4,a4,a2
 7ee:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7f0:	ff053683          	ld	a3,-16(a0)
 7f4:	bfd1                	j	7c8 <free+0x58>

00000000000007f6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7f6:	7139                	addi	sp,sp,-64
 7f8:	fc06                	sd	ra,56(sp)
 7fa:	f822                	sd	s0,48(sp)
 7fc:	f04a                	sd	s2,32(sp)
 7fe:	ec4e                	sd	s3,24(sp)
 800:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 802:	02051993          	slli	s3,a0,0x20
 806:	0209d993          	srli	s3,s3,0x20
 80a:	09bd                	addi	s3,s3,15
 80c:	0049d993          	srli	s3,s3,0x4
 810:	2985                	addiw	s3,s3,1
 812:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 814:	00000517          	auipc	a0,0x0
 818:	5cc53503          	ld	a0,1484(a0) # de0 <freep>
 81c:	c905                	beqz	a0,84c <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 81e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 820:	4798                	lw	a4,8(a5)
 822:	09377a63          	bgeu	a4,s3,8b6 <malloc+0xc0>
 826:	f426                	sd	s1,40(sp)
 828:	e852                	sd	s4,16(sp)
 82a:	e456                	sd	s5,8(sp)
 82c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 82e:	8a4e                	mv	s4,s3
 830:	6705                	lui	a4,0x1
 832:	00e9f363          	bgeu	s3,a4,838 <malloc+0x42>
 836:	6a05                	lui	s4,0x1
 838:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 83c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 840:	00000497          	auipc	s1,0x0
 844:	5a048493          	addi	s1,s1,1440 # de0 <freep>
  if(p == (char*)-1)
 848:	5afd                	li	s5,-1
 84a:	a089                	j	88c <malloc+0x96>
 84c:	f426                	sd	s1,40(sp)
 84e:	e852                	sd	s4,16(sp)
 850:	e456                	sd	s5,8(sp)
 852:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 854:	00000797          	auipc	a5,0x0
 858:	79478793          	addi	a5,a5,1940 # fe8 <base>
 85c:	00000717          	auipc	a4,0x0
 860:	58f73223          	sd	a5,1412(a4) # de0 <freep>
 864:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 866:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 86a:	b7d1                	j	82e <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 86c:	6398                	ld	a4,0(a5)
 86e:	e118                	sd	a4,0(a0)
 870:	a8b9                	j	8ce <malloc+0xd8>
  hp->s.size = nu;
 872:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 876:	0541                	addi	a0,a0,16
 878:	00000097          	auipc	ra,0x0
 87c:	ef8080e7          	jalr	-264(ra) # 770 <free>
  return freep;
 880:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 882:	c135                	beqz	a0,8e6 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 884:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 886:	4798                	lw	a4,8(a5)
 888:	03277363          	bgeu	a4,s2,8ae <malloc+0xb8>
    if(p == freep)
 88c:	6098                	ld	a4,0(s1)
 88e:	853e                	mv	a0,a5
 890:	fef71ae3          	bne	a4,a5,884 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 894:	8552                	mv	a0,s4
 896:	00000097          	auipc	ra,0x0
 89a:	bae080e7          	jalr	-1106(ra) # 444 <sbrk>
  if(p == (char*)-1)
 89e:	fd551ae3          	bne	a0,s5,872 <malloc+0x7c>
        return 0;
 8a2:	4501                	li	a0,0
 8a4:	74a2                	ld	s1,40(sp)
 8a6:	6a42                	ld	s4,16(sp)
 8a8:	6aa2                	ld	s5,8(sp)
 8aa:	6b02                	ld	s6,0(sp)
 8ac:	a03d                	j	8da <malloc+0xe4>
 8ae:	74a2                	ld	s1,40(sp)
 8b0:	6a42                	ld	s4,16(sp)
 8b2:	6aa2                	ld	s5,8(sp)
 8b4:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8b6:	fae90be3          	beq	s2,a4,86c <malloc+0x76>
        p->s.size -= nunits;
 8ba:	4137073b          	subw	a4,a4,s3
 8be:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8c0:	02071693          	slli	a3,a4,0x20
 8c4:	01c6d713          	srli	a4,a3,0x1c
 8c8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8ca:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ce:	00000717          	auipc	a4,0x0
 8d2:	50a73923          	sd	a0,1298(a4) # de0 <freep>
      return (void*)(p + 1);
 8d6:	01078513          	addi	a0,a5,16
  }
}
 8da:	70e2                	ld	ra,56(sp)
 8dc:	7442                	ld	s0,48(sp)
 8de:	7902                	ld	s2,32(sp)
 8e0:	69e2                	ld	s3,24(sp)
 8e2:	6121                	addi	sp,sp,64
 8e4:	8082                	ret
 8e6:	74a2                	ld	s1,40(sp)
 8e8:	6a42                	ld	s4,16(sp)
 8ea:	6aa2                	ld	s5,8(sp)
 8ec:	6b02                	ld	s6,0(sp)
 8ee:	b7f5                	j	8da <malloc+0xe4>
