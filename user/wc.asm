
user/_wc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	f862                	sd	s8,48(sp)
  16:	f466                	sd	s9,40(sp)
  18:	f06a                	sd	s10,32(sp)
  1a:	ec6e                	sd	s11,24(sp)
  1c:	0100                	addi	s0,sp,128
  1e:	f8a43423          	sd	a0,-120(s0)
  22:	f8b43023          	sd	a1,-128(s0)
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  26:	4901                	li	s2,0
  l = w = c = 0;
  28:	4c81                	li	s9,0
  2a:	4c01                	li	s8,0
  2c:	4b81                	li	s7,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  2e:	20000d93          	li	s11,512
  32:	00001d17          	auipc	s10,0x1
  36:	e36d0d13          	addi	s10,s10,-458 # e68 <buf>
    for(i=0; i<n; i++){
      c++;
      if(buf[i] == '\n')
  3a:	4aa9                	li	s5,10
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
  3c:	00001a17          	auipc	s4,0x1
  40:	91ca0a13          	addi	s4,s4,-1764 # 958 <malloc+0x100>
  while((n = read(fd, buf, sizeof(buf))) > 0){
  44:	a805                	j	74 <wc+0x74>
      if(strchr(" \r\t\n\v", buf[i]))
  46:	8552                	mv	a0,s4
  48:	00000097          	auipc	ra,0x0
  4c:	1ea080e7          	jalr	490(ra) # 232 <strchr>
  50:	c919                	beqz	a0,66 <wc+0x66>
        inword = 0;
  52:	4901                	li	s2,0
    for(i=0; i<n; i++){
  54:	0485                	addi	s1,s1,1
  56:	01348d63          	beq	s1,s3,70 <wc+0x70>
      if(buf[i] == '\n')
  5a:	0004c583          	lbu	a1,0(s1)
  5e:	ff5594e3          	bne	a1,s5,46 <wc+0x46>
        l++;
  62:	2b85                	addiw	s7,s7,1
  64:	b7cd                	j	46 <wc+0x46>
      else if(!inword){
  66:	fe0917e3          	bnez	s2,54 <wc+0x54>
        w++;
  6a:	2c05                	addiw	s8,s8,1
        inword = 1;
  6c:	4905                	li	s2,1
  6e:	b7dd                	j	54 <wc+0x54>
  70:	019b0cbb          	addw	s9,s6,s9
  while((n = read(fd, buf, sizeof(buf))) > 0){
  74:	866e                	mv	a2,s11
  76:	85ea                	mv	a1,s10
  78:	f8843503          	ld	a0,-120(s0)
  7c:	00000097          	auipc	ra,0x0
  80:	3ba080e7          	jalr	954(ra) # 436 <read>
  84:	8b2a                	mv	s6,a0
  86:	00a05963          	blez	a0,98 <wc+0x98>
  8a:	00001497          	auipc	s1,0x1
  8e:	dde48493          	addi	s1,s1,-546 # e68 <buf>
  92:	009b09b3          	add	s3,s6,s1
  96:	b7d1                	j	5a <wc+0x5a>
      }
    }
  }
  if(n < 0){
  98:	02054e63          	bltz	a0,d4 <wc+0xd4>
    printf("wc: read error\n");
    exit(1);
  }
  printf("%d %d %d %s\n", l, w, c, name);
  9c:	f8043703          	ld	a4,-128(s0)
  a0:	86e6                	mv	a3,s9
  a2:	8662                	mv	a2,s8
  a4:	85de                	mv	a1,s7
  a6:	00001517          	auipc	a0,0x1
  aa:	8d250513          	addi	a0,a0,-1838 # 978 <malloc+0x120>
  ae:	00000097          	auipc	ra,0x0
  b2:	6ee080e7          	jalr	1774(ra) # 79c <printf>
}
  b6:	70e6                	ld	ra,120(sp)
  b8:	7446                	ld	s0,112(sp)
  ba:	74a6                	ld	s1,104(sp)
  bc:	7906                	ld	s2,96(sp)
  be:	69e6                	ld	s3,88(sp)
  c0:	6a46                	ld	s4,80(sp)
  c2:	6aa6                	ld	s5,72(sp)
  c4:	6b06                	ld	s6,64(sp)
  c6:	7be2                	ld	s7,56(sp)
  c8:	7c42                	ld	s8,48(sp)
  ca:	7ca2                	ld	s9,40(sp)
  cc:	7d02                	ld	s10,32(sp)
  ce:	6de2                	ld	s11,24(sp)
  d0:	6109                	addi	sp,sp,128
  d2:	8082                	ret
    printf("wc: read error\n");
  d4:	00001517          	auipc	a0,0x1
  d8:	89450513          	addi	a0,a0,-1900 # 968 <malloc+0x110>
  dc:	00000097          	auipc	ra,0x0
  e0:	6c0080e7          	jalr	1728(ra) # 79c <printf>
    exit(1);
  e4:	4505                	li	a0,1
  e6:	00000097          	auipc	ra,0x0
  ea:	338080e7          	jalr	824(ra) # 41e <exit>

00000000000000ee <main>:

int
main(int argc, char *argv[])
{
  ee:	7179                	addi	sp,sp,-48
  f0:	f406                	sd	ra,40(sp)
  f2:	f022                	sd	s0,32(sp)
  f4:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  f6:	4785                	li	a5,1
  f8:	04a7dc63          	bge	a5,a0,150 <main+0x62>
  fc:	ec26                	sd	s1,24(sp)
  fe:	e84a                	sd	s2,16(sp)
 100:	e44e                	sd	s3,8(sp)
 102:	00858913          	addi	s2,a1,8
 106:	ffe5099b          	addiw	s3,a0,-2
 10a:	02099793          	slli	a5,s3,0x20
 10e:	01d7d993          	srli	s3,a5,0x1d
 112:	05c1                	addi	a1,a1,16
 114:	99ae                	add	s3,s3,a1
    wc(0, "");
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
 116:	4581                	li	a1,0
 118:	00093503          	ld	a0,0(s2)
 11c:	00000097          	auipc	ra,0x0
 120:	342080e7          	jalr	834(ra) # 45e <open>
 124:	84aa                	mv	s1,a0
 126:	04054663          	bltz	a0,172 <main+0x84>
      printf("wc: cannot open %s\n", argv[i]);
      exit(1);
    }
    wc(fd, argv[i]);
 12a:	00093583          	ld	a1,0(s2)
 12e:	00000097          	auipc	ra,0x0
 132:	ed2080e7          	jalr	-302(ra) # 0 <wc>
    close(fd);
 136:	8526                	mv	a0,s1
 138:	00000097          	auipc	ra,0x0
 13c:	30e080e7          	jalr	782(ra) # 446 <close>
  for(i = 1; i < argc; i++){
 140:	0921                	addi	s2,s2,8
 142:	fd391ae3          	bne	s2,s3,116 <main+0x28>
  }
  exit(0);
 146:	4501                	li	a0,0
 148:	00000097          	auipc	ra,0x0
 14c:	2d6080e7          	jalr	726(ra) # 41e <exit>
 150:	ec26                	sd	s1,24(sp)
 152:	e84a                	sd	s2,16(sp)
 154:	e44e                	sd	s3,8(sp)
    wc(0, "");
 156:	00001597          	auipc	a1,0x1
 15a:	80a58593          	addi	a1,a1,-2038 # 960 <malloc+0x108>
 15e:	4501                	li	a0,0
 160:	00000097          	auipc	ra,0x0
 164:	ea0080e7          	jalr	-352(ra) # 0 <wc>
    exit(0);
 168:	4501                	li	a0,0
 16a:	00000097          	auipc	ra,0x0
 16e:	2b4080e7          	jalr	692(ra) # 41e <exit>
      printf("wc: cannot open %s\n", argv[i]);
 172:	00093583          	ld	a1,0(s2)
 176:	00001517          	auipc	a0,0x1
 17a:	81250513          	addi	a0,a0,-2030 # 988 <malloc+0x130>
 17e:	00000097          	auipc	ra,0x0
 182:	61e080e7          	jalr	1566(ra) # 79c <printf>
      exit(1);
 186:	4505                	li	a0,1
 188:	00000097          	auipc	ra,0x0
 18c:	296080e7          	jalr	662(ra) # 41e <exit>

0000000000000190 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 190:	1141                	addi	sp,sp,-16
 192:	e406                	sd	ra,8(sp)
 194:	e022                	sd	s0,0(sp)
 196:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 198:	87aa                	mv	a5,a0
 19a:	0585                	addi	a1,a1,1
 19c:	0785                	addi	a5,a5,1
 19e:	fff5c703          	lbu	a4,-1(a1)
 1a2:	fee78fa3          	sb	a4,-1(a5)
 1a6:	fb75                	bnez	a4,19a <strcpy+0xa>
    ;
  return os;
}
 1a8:	60a2                	ld	ra,8(sp)
 1aa:	6402                	ld	s0,0(sp)
 1ac:	0141                	addi	sp,sp,16
 1ae:	8082                	ret

00000000000001b0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1b0:	1141                	addi	sp,sp,-16
 1b2:	e406                	sd	ra,8(sp)
 1b4:	e022                	sd	s0,0(sp)
 1b6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1b8:	00054783          	lbu	a5,0(a0)
 1bc:	cb91                	beqz	a5,1d0 <strcmp+0x20>
 1be:	0005c703          	lbu	a4,0(a1)
 1c2:	00f71763          	bne	a4,a5,1d0 <strcmp+0x20>
    p++, q++;
 1c6:	0505                	addi	a0,a0,1
 1c8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1ca:	00054783          	lbu	a5,0(a0)
 1ce:	fbe5                	bnez	a5,1be <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 1d0:	0005c503          	lbu	a0,0(a1)
}
 1d4:	40a7853b          	subw	a0,a5,a0
 1d8:	60a2                	ld	ra,8(sp)
 1da:	6402                	ld	s0,0(sp)
 1dc:	0141                	addi	sp,sp,16
 1de:	8082                	ret

00000000000001e0 <strlen>:

uint
strlen(const char *s)
{
 1e0:	1141                	addi	sp,sp,-16
 1e2:	e406                	sd	ra,8(sp)
 1e4:	e022                	sd	s0,0(sp)
 1e6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1e8:	00054783          	lbu	a5,0(a0)
 1ec:	cf91                	beqz	a5,208 <strlen+0x28>
 1ee:	00150793          	addi	a5,a0,1
 1f2:	86be                	mv	a3,a5
 1f4:	0785                	addi	a5,a5,1
 1f6:	fff7c703          	lbu	a4,-1(a5)
 1fa:	ff65                	bnez	a4,1f2 <strlen+0x12>
 1fc:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 200:	60a2                	ld	ra,8(sp)
 202:	6402                	ld	s0,0(sp)
 204:	0141                	addi	sp,sp,16
 206:	8082                	ret
  for(n = 0; s[n]; n++)
 208:	4501                	li	a0,0
 20a:	bfdd                	j	200 <strlen+0x20>

000000000000020c <memset>:

void*
memset(void *dst, int c, uint n)
{
 20c:	1141                	addi	sp,sp,-16
 20e:	e406                	sd	ra,8(sp)
 210:	e022                	sd	s0,0(sp)
 212:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 214:	ca19                	beqz	a2,22a <memset+0x1e>
 216:	87aa                	mv	a5,a0
 218:	1602                	slli	a2,a2,0x20
 21a:	9201                	srli	a2,a2,0x20
 21c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 220:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 224:	0785                	addi	a5,a5,1
 226:	fee79de3          	bne	a5,a4,220 <memset+0x14>
  }
  return dst;
}
 22a:	60a2                	ld	ra,8(sp)
 22c:	6402                	ld	s0,0(sp)
 22e:	0141                	addi	sp,sp,16
 230:	8082                	ret

0000000000000232 <strchr>:

char*
strchr(const char *s, char c)
{
 232:	1141                	addi	sp,sp,-16
 234:	e406                	sd	ra,8(sp)
 236:	e022                	sd	s0,0(sp)
 238:	0800                	addi	s0,sp,16
  for(; *s; s++)
 23a:	00054783          	lbu	a5,0(a0)
 23e:	cf81                	beqz	a5,256 <strchr+0x24>
    if(*s == c)
 240:	00f58763          	beq	a1,a5,24e <strchr+0x1c>
  for(; *s; s++)
 244:	0505                	addi	a0,a0,1
 246:	00054783          	lbu	a5,0(a0)
 24a:	fbfd                	bnez	a5,240 <strchr+0xe>
      return (char*)s;
  return 0;
 24c:	4501                	li	a0,0
}
 24e:	60a2                	ld	ra,8(sp)
 250:	6402                	ld	s0,0(sp)
 252:	0141                	addi	sp,sp,16
 254:	8082                	ret
  return 0;
 256:	4501                	li	a0,0
 258:	bfdd                	j	24e <strchr+0x1c>

000000000000025a <gets>:

char*
gets(char *buf, int max)
{
 25a:	711d                	addi	sp,sp,-96
 25c:	ec86                	sd	ra,88(sp)
 25e:	e8a2                	sd	s0,80(sp)
 260:	e4a6                	sd	s1,72(sp)
 262:	e0ca                	sd	s2,64(sp)
 264:	fc4e                	sd	s3,56(sp)
 266:	f852                	sd	s4,48(sp)
 268:	f456                	sd	s5,40(sp)
 26a:	f05a                	sd	s6,32(sp)
 26c:	ec5e                	sd	s7,24(sp)
 26e:	e862                	sd	s8,16(sp)
 270:	1080                	addi	s0,sp,96
 272:	8baa                	mv	s7,a0
 274:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 276:	892a                	mv	s2,a0
 278:	4481                	li	s1,0
    cc = read(0, &c, 1);
 27a:	faf40b13          	addi	s6,s0,-81
 27e:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 280:	8c26                	mv	s8,s1
 282:	0014899b          	addiw	s3,s1,1
 286:	84ce                	mv	s1,s3
 288:	0349d663          	bge	s3,s4,2b4 <gets+0x5a>
    cc = read(0, &c, 1);
 28c:	8656                	mv	a2,s5
 28e:	85da                	mv	a1,s6
 290:	4501                	li	a0,0
 292:	00000097          	auipc	ra,0x0
 296:	1a4080e7          	jalr	420(ra) # 436 <read>
    if(cc < 1)
 29a:	00a05d63          	blez	a0,2b4 <gets+0x5a>
      break;
    buf[i++] = c;
 29e:	faf44783          	lbu	a5,-81(s0)
 2a2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2a6:	0905                	addi	s2,s2,1
 2a8:	ff678713          	addi	a4,a5,-10
 2ac:	c319                	beqz	a4,2b2 <gets+0x58>
 2ae:	17cd                	addi	a5,a5,-13
 2b0:	fbe1                	bnez	a5,280 <gets+0x26>
    buf[i++] = c;
 2b2:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 2b4:	9c5e                	add	s8,s8,s7
 2b6:	000c0023          	sb	zero,0(s8)
  return buf;
}
 2ba:	855e                	mv	a0,s7
 2bc:	60e6                	ld	ra,88(sp)
 2be:	6446                	ld	s0,80(sp)
 2c0:	64a6                	ld	s1,72(sp)
 2c2:	6906                	ld	s2,64(sp)
 2c4:	79e2                	ld	s3,56(sp)
 2c6:	7a42                	ld	s4,48(sp)
 2c8:	7aa2                	ld	s5,40(sp)
 2ca:	7b02                	ld	s6,32(sp)
 2cc:	6be2                	ld	s7,24(sp)
 2ce:	6c42                	ld	s8,16(sp)
 2d0:	6125                	addi	sp,sp,96
 2d2:	8082                	ret

00000000000002d4 <stat>:

int
stat(const char *n, struct stat *st)
{
 2d4:	1101                	addi	sp,sp,-32
 2d6:	ec06                	sd	ra,24(sp)
 2d8:	e822                	sd	s0,16(sp)
 2da:	e04a                	sd	s2,0(sp)
 2dc:	1000                	addi	s0,sp,32
 2de:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2e0:	4581                	li	a1,0
 2e2:	00000097          	auipc	ra,0x0
 2e6:	17c080e7          	jalr	380(ra) # 45e <open>
  if(fd < 0)
 2ea:	02054663          	bltz	a0,316 <stat+0x42>
 2ee:	e426                	sd	s1,8(sp)
 2f0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2f2:	85ca                	mv	a1,s2
 2f4:	00000097          	auipc	ra,0x0
 2f8:	182080e7          	jalr	386(ra) # 476 <fstat>
 2fc:	892a                	mv	s2,a0
  close(fd);
 2fe:	8526                	mv	a0,s1
 300:	00000097          	auipc	ra,0x0
 304:	146080e7          	jalr	326(ra) # 446 <close>
  return r;
 308:	64a2                	ld	s1,8(sp)
}
 30a:	854a                	mv	a0,s2
 30c:	60e2                	ld	ra,24(sp)
 30e:	6442                	ld	s0,16(sp)
 310:	6902                	ld	s2,0(sp)
 312:	6105                	addi	sp,sp,32
 314:	8082                	ret
    return -1;
 316:	57fd                	li	a5,-1
 318:	893e                	mv	s2,a5
 31a:	bfc5                	j	30a <stat+0x36>

000000000000031c <atoi>:

int
atoi(const char *s)
{
 31c:	1141                	addi	sp,sp,-16
 31e:	e406                	sd	ra,8(sp)
 320:	e022                	sd	s0,0(sp)
 322:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 324:	00054683          	lbu	a3,0(a0)
 328:	fd06879b          	addiw	a5,a3,-48
 32c:	0ff7f793          	zext.b	a5,a5
 330:	4625                	li	a2,9
 332:	02f66963          	bltu	a2,a5,364 <atoi+0x48>
 336:	872a                	mv	a4,a0
  n = 0;
 338:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 33a:	0705                	addi	a4,a4,1
 33c:	0025179b          	slliw	a5,a0,0x2
 340:	9fa9                	addw	a5,a5,a0
 342:	0017979b          	slliw	a5,a5,0x1
 346:	9fb5                	addw	a5,a5,a3
 348:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 34c:	00074683          	lbu	a3,0(a4)
 350:	fd06879b          	addiw	a5,a3,-48
 354:	0ff7f793          	zext.b	a5,a5
 358:	fef671e3          	bgeu	a2,a5,33a <atoi+0x1e>
  return n;
}
 35c:	60a2                	ld	ra,8(sp)
 35e:	6402                	ld	s0,0(sp)
 360:	0141                	addi	sp,sp,16
 362:	8082                	ret
  n = 0;
 364:	4501                	li	a0,0
 366:	bfdd                	j	35c <atoi+0x40>

0000000000000368 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 368:	1141                	addi	sp,sp,-16
 36a:	e406                	sd	ra,8(sp)
 36c:	e022                	sd	s0,0(sp)
 36e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 370:	02b57563          	bgeu	a0,a1,39a <memmove+0x32>
    while(n-- > 0)
 374:	00c05f63          	blez	a2,392 <memmove+0x2a>
 378:	1602                	slli	a2,a2,0x20
 37a:	9201                	srli	a2,a2,0x20
 37c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 380:	872a                	mv	a4,a0
      *dst++ = *src++;
 382:	0585                	addi	a1,a1,1
 384:	0705                	addi	a4,a4,1
 386:	fff5c683          	lbu	a3,-1(a1)
 38a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 38e:	fee79ae3          	bne	a5,a4,382 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 392:	60a2                	ld	ra,8(sp)
 394:	6402                	ld	s0,0(sp)
 396:	0141                	addi	sp,sp,16
 398:	8082                	ret
    while(n-- > 0)
 39a:	fec05ce3          	blez	a2,392 <memmove+0x2a>
    dst += n;
 39e:	00c50733          	add	a4,a0,a2
    src += n;
 3a2:	95b2                	add	a1,a1,a2
 3a4:	fff6079b          	addiw	a5,a2,-1
 3a8:	1782                	slli	a5,a5,0x20
 3aa:	9381                	srli	a5,a5,0x20
 3ac:	fff7c793          	not	a5,a5
 3b0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3b2:	15fd                	addi	a1,a1,-1
 3b4:	177d                	addi	a4,a4,-1
 3b6:	0005c683          	lbu	a3,0(a1)
 3ba:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3be:	fef71ae3          	bne	a4,a5,3b2 <memmove+0x4a>
 3c2:	bfc1                	j	392 <memmove+0x2a>

00000000000003c4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3c4:	1141                	addi	sp,sp,-16
 3c6:	e406                	sd	ra,8(sp)
 3c8:	e022                	sd	s0,0(sp)
 3ca:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3cc:	c61d                	beqz	a2,3fa <memcmp+0x36>
 3ce:	1602                	slli	a2,a2,0x20
 3d0:	9201                	srli	a2,a2,0x20
 3d2:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 3d6:	00054783          	lbu	a5,0(a0)
 3da:	0005c703          	lbu	a4,0(a1)
 3de:	00e79863          	bne	a5,a4,3ee <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 3e2:	0505                	addi	a0,a0,1
    p2++;
 3e4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3e6:	fed518e3          	bne	a0,a3,3d6 <memcmp+0x12>
  }
  return 0;
 3ea:	4501                	li	a0,0
 3ec:	a019                	j	3f2 <memcmp+0x2e>
      return *p1 - *p2;
 3ee:	40e7853b          	subw	a0,a5,a4
}
 3f2:	60a2                	ld	ra,8(sp)
 3f4:	6402                	ld	s0,0(sp)
 3f6:	0141                	addi	sp,sp,16
 3f8:	8082                	ret
  return 0;
 3fa:	4501                	li	a0,0
 3fc:	bfdd                	j	3f2 <memcmp+0x2e>

00000000000003fe <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3fe:	1141                	addi	sp,sp,-16
 400:	e406                	sd	ra,8(sp)
 402:	e022                	sd	s0,0(sp)
 404:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 406:	00000097          	auipc	ra,0x0
 40a:	f62080e7          	jalr	-158(ra) # 368 <memmove>
}
 40e:	60a2                	ld	ra,8(sp)
 410:	6402                	ld	s0,0(sp)
 412:	0141                	addi	sp,sp,16
 414:	8082                	ret

0000000000000416 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 416:	4885                	li	a7,1
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <exit>:
.global exit
exit:
 li a7, SYS_exit
 41e:	4889                	li	a7,2
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <wait>:
.global wait
wait:
 li a7, SYS_wait
 426:	488d                	li	a7,3
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 42e:	4891                	li	a7,4
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <read>:
.global read
read:
 li a7, SYS_read
 436:	4895                	li	a7,5
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <write>:
.global write
write:
 li a7, SYS_write
 43e:	48c1                	li	a7,16
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <close>:
.global close
close:
 li a7, SYS_close
 446:	48d5                	li	a7,21
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <kill>:
.global kill
kill:
 li a7, SYS_kill
 44e:	4899                	li	a7,6
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <exec>:
.global exec
exec:
 li a7, SYS_exec
 456:	489d                	li	a7,7
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <open>:
.global open
open:
 li a7, SYS_open
 45e:	48bd                	li	a7,15
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 466:	48c5                	li	a7,17
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 46e:	48c9                	li	a7,18
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 476:	48a1                	li	a7,8
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <link>:
.global link
link:
 li a7, SYS_link
 47e:	48cd                	li	a7,19
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 486:	48d1                	li	a7,20
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 48e:	48a5                	li	a7,9
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <dup>:
.global dup
dup:
 li a7, SYS_dup
 496:	48a9                	li	a7,10
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 49e:	48ad                	li	a7,11
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4a6:	48b1                	li	a7,12
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4ae:	48b5                	li	a7,13
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4b6:	48b9                	li	a7,14
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <trace>:
.global trace
trace:
 li a7, SYS_trace
 4be:	48d9                	li	a7,22
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 4c6:	48dd                	li	a7,23
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 4ce:	48e1                	li	a7,24
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4d6:	1101                	addi	sp,sp,-32
 4d8:	ec06                	sd	ra,24(sp)
 4da:	e822                	sd	s0,16(sp)
 4dc:	1000                	addi	s0,sp,32
 4de:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4e2:	4605                	li	a2,1
 4e4:	fef40593          	addi	a1,s0,-17
 4e8:	00000097          	auipc	ra,0x0
 4ec:	f56080e7          	jalr	-170(ra) # 43e <write>
}
 4f0:	60e2                	ld	ra,24(sp)
 4f2:	6442                	ld	s0,16(sp)
 4f4:	6105                	addi	sp,sp,32
 4f6:	8082                	ret

00000000000004f8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4f8:	7139                	addi	sp,sp,-64
 4fa:	fc06                	sd	ra,56(sp)
 4fc:	f822                	sd	s0,48(sp)
 4fe:	f04a                	sd	s2,32(sp)
 500:	ec4e                	sd	s3,24(sp)
 502:	0080                	addi	s0,sp,64
 504:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 506:	cad9                	beqz	a3,59c <printint+0xa4>
 508:	01f5d79b          	srliw	a5,a1,0x1f
 50c:	cbc1                	beqz	a5,59c <printint+0xa4>
    neg = 1;
    x = -xx;
 50e:	40b005bb          	negw	a1,a1
    neg = 1;
 512:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 514:	fc040993          	addi	s3,s0,-64
  neg = 0;
 518:	86ce                	mv	a3,s3
  i = 0;
 51a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 51c:	00000817          	auipc	a6,0x0
 520:	4e480813          	addi	a6,a6,1252 # a00 <digits>
 524:	88ba                	mv	a7,a4
 526:	0017051b          	addiw	a0,a4,1
 52a:	872a                	mv	a4,a0
 52c:	02c5f7bb          	remuw	a5,a1,a2
 530:	1782                	slli	a5,a5,0x20
 532:	9381                	srli	a5,a5,0x20
 534:	97c2                	add	a5,a5,a6
 536:	0007c783          	lbu	a5,0(a5)
 53a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 53e:	87ae                	mv	a5,a1
 540:	02c5d5bb          	divuw	a1,a1,a2
 544:	0685                	addi	a3,a3,1
 546:	fcc7ffe3          	bgeu	a5,a2,524 <printint+0x2c>
  if(neg)
 54a:	00030c63          	beqz	t1,562 <printint+0x6a>
    buf[i++] = '-';
 54e:	fd050793          	addi	a5,a0,-48
 552:	00878533          	add	a0,a5,s0
 556:	02d00793          	li	a5,45
 55a:	fef50823          	sb	a5,-16(a0)
 55e:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 562:	02e05763          	blez	a4,590 <printint+0x98>
 566:	f426                	sd	s1,40(sp)
 568:	377d                	addiw	a4,a4,-1
 56a:	00e984b3          	add	s1,s3,a4
 56e:	19fd                	addi	s3,s3,-1
 570:	99ba                	add	s3,s3,a4
 572:	1702                	slli	a4,a4,0x20
 574:	9301                	srli	a4,a4,0x20
 576:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 57a:	0004c583          	lbu	a1,0(s1)
 57e:	854a                	mv	a0,s2
 580:	00000097          	auipc	ra,0x0
 584:	f56080e7          	jalr	-170(ra) # 4d6 <putc>
  while(--i >= 0)
 588:	14fd                	addi	s1,s1,-1
 58a:	ff3498e3          	bne	s1,s3,57a <printint+0x82>
 58e:	74a2                	ld	s1,40(sp)
}
 590:	70e2                	ld	ra,56(sp)
 592:	7442                	ld	s0,48(sp)
 594:	7902                	ld	s2,32(sp)
 596:	69e2                	ld	s3,24(sp)
 598:	6121                	addi	sp,sp,64
 59a:	8082                	ret
  neg = 0;
 59c:	4301                	li	t1,0
 59e:	bf9d                	j	514 <printint+0x1c>

00000000000005a0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5a0:	715d                	addi	sp,sp,-80
 5a2:	e486                	sd	ra,72(sp)
 5a4:	e0a2                	sd	s0,64(sp)
 5a6:	f84a                	sd	s2,48(sp)
 5a8:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5aa:	0005c903          	lbu	s2,0(a1)
 5ae:	1a090b63          	beqz	s2,764 <vprintf+0x1c4>
 5b2:	fc26                	sd	s1,56(sp)
 5b4:	f44e                	sd	s3,40(sp)
 5b6:	f052                	sd	s4,32(sp)
 5b8:	ec56                	sd	s5,24(sp)
 5ba:	e85a                	sd	s6,16(sp)
 5bc:	e45e                	sd	s7,8(sp)
 5be:	8aaa                	mv	s5,a0
 5c0:	8bb2                	mv	s7,a2
 5c2:	00158493          	addi	s1,a1,1
  state = 0;
 5c6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5c8:	02500a13          	li	s4,37
 5cc:	4b55                	li	s6,21
 5ce:	a839                	j	5ec <vprintf+0x4c>
        putc(fd, c);
 5d0:	85ca                	mv	a1,s2
 5d2:	8556                	mv	a0,s5
 5d4:	00000097          	auipc	ra,0x0
 5d8:	f02080e7          	jalr	-254(ra) # 4d6 <putc>
 5dc:	a019                	j	5e2 <vprintf+0x42>
    } else if(state == '%'){
 5de:	01498d63          	beq	s3,s4,5f8 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 5e2:	0485                	addi	s1,s1,1
 5e4:	fff4c903          	lbu	s2,-1(s1)
 5e8:	16090863          	beqz	s2,758 <vprintf+0x1b8>
    if(state == 0){
 5ec:	fe0999e3          	bnez	s3,5de <vprintf+0x3e>
      if(c == '%'){
 5f0:	ff4910e3          	bne	s2,s4,5d0 <vprintf+0x30>
        state = '%';
 5f4:	89d2                	mv	s3,s4
 5f6:	b7f5                	j	5e2 <vprintf+0x42>
      if(c == 'd'){
 5f8:	13490563          	beq	s2,s4,722 <vprintf+0x182>
 5fc:	f9d9079b          	addiw	a5,s2,-99
 600:	0ff7f793          	zext.b	a5,a5
 604:	12fb6863          	bltu	s6,a5,734 <vprintf+0x194>
 608:	f9d9079b          	addiw	a5,s2,-99
 60c:	0ff7f713          	zext.b	a4,a5
 610:	12eb6263          	bltu	s6,a4,734 <vprintf+0x194>
 614:	00271793          	slli	a5,a4,0x2
 618:	00000717          	auipc	a4,0x0
 61c:	39070713          	addi	a4,a4,912 # 9a8 <malloc+0x150>
 620:	97ba                	add	a5,a5,a4
 622:	439c                	lw	a5,0(a5)
 624:	97ba                	add	a5,a5,a4
 626:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 628:	008b8913          	addi	s2,s7,8
 62c:	4685                	li	a3,1
 62e:	4629                	li	a2,10
 630:	000ba583          	lw	a1,0(s7)
 634:	8556                	mv	a0,s5
 636:	00000097          	auipc	ra,0x0
 63a:	ec2080e7          	jalr	-318(ra) # 4f8 <printint>
 63e:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 640:	4981                	li	s3,0
 642:	b745                	j	5e2 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 644:	008b8913          	addi	s2,s7,8
 648:	4681                	li	a3,0
 64a:	4629                	li	a2,10
 64c:	000ba583          	lw	a1,0(s7)
 650:	8556                	mv	a0,s5
 652:	00000097          	auipc	ra,0x0
 656:	ea6080e7          	jalr	-346(ra) # 4f8 <printint>
 65a:	8bca                	mv	s7,s2
      state = 0;
 65c:	4981                	li	s3,0
 65e:	b751                	j	5e2 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 660:	008b8913          	addi	s2,s7,8
 664:	4681                	li	a3,0
 666:	4641                	li	a2,16
 668:	000ba583          	lw	a1,0(s7)
 66c:	8556                	mv	a0,s5
 66e:	00000097          	auipc	ra,0x0
 672:	e8a080e7          	jalr	-374(ra) # 4f8 <printint>
 676:	8bca                	mv	s7,s2
      state = 0;
 678:	4981                	li	s3,0
 67a:	b7a5                	j	5e2 <vprintf+0x42>
 67c:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 67e:	008b8793          	addi	a5,s7,8
 682:	8c3e                	mv	s8,a5
 684:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 688:	03000593          	li	a1,48
 68c:	8556                	mv	a0,s5
 68e:	00000097          	auipc	ra,0x0
 692:	e48080e7          	jalr	-440(ra) # 4d6 <putc>
  putc(fd, 'x');
 696:	07800593          	li	a1,120
 69a:	8556                	mv	a0,s5
 69c:	00000097          	auipc	ra,0x0
 6a0:	e3a080e7          	jalr	-454(ra) # 4d6 <putc>
 6a4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6a6:	00000b97          	auipc	s7,0x0
 6aa:	35ab8b93          	addi	s7,s7,858 # a00 <digits>
 6ae:	03c9d793          	srli	a5,s3,0x3c
 6b2:	97de                	add	a5,a5,s7
 6b4:	0007c583          	lbu	a1,0(a5)
 6b8:	8556                	mv	a0,s5
 6ba:	00000097          	auipc	ra,0x0
 6be:	e1c080e7          	jalr	-484(ra) # 4d6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6c2:	0992                	slli	s3,s3,0x4
 6c4:	397d                	addiw	s2,s2,-1
 6c6:	fe0914e3          	bnez	s2,6ae <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
 6ca:	8be2                	mv	s7,s8
      state = 0;
 6cc:	4981                	li	s3,0
 6ce:	6c02                	ld	s8,0(sp)
 6d0:	bf09                	j	5e2 <vprintf+0x42>
        s = va_arg(ap, char*);
 6d2:	008b8993          	addi	s3,s7,8
 6d6:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 6da:	02090163          	beqz	s2,6fc <vprintf+0x15c>
        while(*s != 0){
 6de:	00094583          	lbu	a1,0(s2)
 6e2:	c9a5                	beqz	a1,752 <vprintf+0x1b2>
          putc(fd, *s);
 6e4:	8556                	mv	a0,s5
 6e6:	00000097          	auipc	ra,0x0
 6ea:	df0080e7          	jalr	-528(ra) # 4d6 <putc>
          s++;
 6ee:	0905                	addi	s2,s2,1
        while(*s != 0){
 6f0:	00094583          	lbu	a1,0(s2)
 6f4:	f9e5                	bnez	a1,6e4 <vprintf+0x144>
        s = va_arg(ap, char*);
 6f6:	8bce                	mv	s7,s3
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	b5e5                	j	5e2 <vprintf+0x42>
          s = "(null)";
 6fc:	00000917          	auipc	s2,0x0
 700:	2a490913          	addi	s2,s2,676 # 9a0 <malloc+0x148>
        while(*s != 0){
 704:	02800593          	li	a1,40
 708:	bff1                	j	6e4 <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
 70a:	008b8913          	addi	s2,s7,8
 70e:	000bc583          	lbu	a1,0(s7)
 712:	8556                	mv	a0,s5
 714:	00000097          	auipc	ra,0x0
 718:	dc2080e7          	jalr	-574(ra) # 4d6 <putc>
 71c:	8bca                	mv	s7,s2
      state = 0;
 71e:	4981                	li	s3,0
 720:	b5c9                	j	5e2 <vprintf+0x42>
        putc(fd, c);
 722:	02500593          	li	a1,37
 726:	8556                	mv	a0,s5
 728:	00000097          	auipc	ra,0x0
 72c:	dae080e7          	jalr	-594(ra) # 4d6 <putc>
      state = 0;
 730:	4981                	li	s3,0
 732:	bd45                	j	5e2 <vprintf+0x42>
        putc(fd, '%');
 734:	02500593          	li	a1,37
 738:	8556                	mv	a0,s5
 73a:	00000097          	auipc	ra,0x0
 73e:	d9c080e7          	jalr	-612(ra) # 4d6 <putc>
        putc(fd, c);
 742:	85ca                	mv	a1,s2
 744:	8556                	mv	a0,s5
 746:	00000097          	auipc	ra,0x0
 74a:	d90080e7          	jalr	-624(ra) # 4d6 <putc>
      state = 0;
 74e:	4981                	li	s3,0
 750:	bd49                	j	5e2 <vprintf+0x42>
        s = va_arg(ap, char*);
 752:	8bce                	mv	s7,s3
      state = 0;
 754:	4981                	li	s3,0
 756:	b571                	j	5e2 <vprintf+0x42>
 758:	74e2                	ld	s1,56(sp)
 75a:	79a2                	ld	s3,40(sp)
 75c:	7a02                	ld	s4,32(sp)
 75e:	6ae2                	ld	s5,24(sp)
 760:	6b42                	ld	s6,16(sp)
 762:	6ba2                	ld	s7,8(sp)
    }
  }
}
 764:	60a6                	ld	ra,72(sp)
 766:	6406                	ld	s0,64(sp)
 768:	7942                	ld	s2,48(sp)
 76a:	6161                	addi	sp,sp,80
 76c:	8082                	ret

000000000000076e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 76e:	715d                	addi	sp,sp,-80
 770:	ec06                	sd	ra,24(sp)
 772:	e822                	sd	s0,16(sp)
 774:	1000                	addi	s0,sp,32
 776:	e010                	sd	a2,0(s0)
 778:	e414                	sd	a3,8(s0)
 77a:	e818                	sd	a4,16(s0)
 77c:	ec1c                	sd	a5,24(s0)
 77e:	03043023          	sd	a6,32(s0)
 782:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 786:	8622                	mv	a2,s0
 788:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 78c:	00000097          	auipc	ra,0x0
 790:	e14080e7          	jalr	-492(ra) # 5a0 <vprintf>
}
 794:	60e2                	ld	ra,24(sp)
 796:	6442                	ld	s0,16(sp)
 798:	6161                	addi	sp,sp,80
 79a:	8082                	ret

000000000000079c <printf>:

void
printf(const char *fmt, ...)
{
 79c:	711d                	addi	sp,sp,-96
 79e:	ec06                	sd	ra,24(sp)
 7a0:	e822                	sd	s0,16(sp)
 7a2:	1000                	addi	s0,sp,32
 7a4:	e40c                	sd	a1,8(s0)
 7a6:	e810                	sd	a2,16(s0)
 7a8:	ec14                	sd	a3,24(s0)
 7aa:	f018                	sd	a4,32(s0)
 7ac:	f41c                	sd	a5,40(s0)
 7ae:	03043823          	sd	a6,48(s0)
 7b2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7b6:	00840613          	addi	a2,s0,8
 7ba:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7be:	85aa                	mv	a1,a0
 7c0:	4505                	li	a0,1
 7c2:	00000097          	auipc	ra,0x0
 7c6:	dde080e7          	jalr	-546(ra) # 5a0 <vprintf>
}
 7ca:	60e2                	ld	ra,24(sp)
 7cc:	6442                	ld	s0,16(sp)
 7ce:	6125                	addi	sp,sp,96
 7d0:	8082                	ret

00000000000007d2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7d2:	1141                	addi	sp,sp,-16
 7d4:	e406                	sd	ra,8(sp)
 7d6:	e022                	sd	s0,0(sp)
 7d8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7da:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7de:	00000797          	auipc	a5,0x0
 7e2:	6827b783          	ld	a5,1666(a5) # e60 <freep>
 7e6:	a039                	j	7f4 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e8:	6398                	ld	a4,0(a5)
 7ea:	00e7e463          	bltu	a5,a4,7f2 <free+0x20>
 7ee:	00e6ea63          	bltu	a3,a4,802 <free+0x30>
{
 7f2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f4:	fed7fae3          	bgeu	a5,a3,7e8 <free+0x16>
 7f8:	6398                	ld	a4,0(a5)
 7fa:	00e6e463          	bltu	a3,a4,802 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7fe:	fee7eae3          	bltu	a5,a4,7f2 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 802:	ff852583          	lw	a1,-8(a0)
 806:	6390                	ld	a2,0(a5)
 808:	02059813          	slli	a6,a1,0x20
 80c:	01c85713          	srli	a4,a6,0x1c
 810:	9736                	add	a4,a4,a3
 812:	02e60563          	beq	a2,a4,83c <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 816:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 81a:	4790                	lw	a2,8(a5)
 81c:	02061593          	slli	a1,a2,0x20
 820:	01c5d713          	srli	a4,a1,0x1c
 824:	973e                	add	a4,a4,a5
 826:	02e68263          	beq	a3,a4,84a <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 82a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 82c:	00000717          	auipc	a4,0x0
 830:	62f73a23          	sd	a5,1588(a4) # e60 <freep>
}
 834:	60a2                	ld	ra,8(sp)
 836:	6402                	ld	s0,0(sp)
 838:	0141                	addi	sp,sp,16
 83a:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 83c:	4618                	lw	a4,8(a2)
 83e:	9f2d                	addw	a4,a4,a1
 840:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 844:	6398                	ld	a4,0(a5)
 846:	6310                	ld	a2,0(a4)
 848:	b7f9                	j	816 <free+0x44>
    p->s.size += bp->s.size;
 84a:	ff852703          	lw	a4,-8(a0)
 84e:	9f31                	addw	a4,a4,a2
 850:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 852:	ff053683          	ld	a3,-16(a0)
 856:	bfd1                	j	82a <free+0x58>

0000000000000858 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 858:	7139                	addi	sp,sp,-64
 85a:	fc06                	sd	ra,56(sp)
 85c:	f822                	sd	s0,48(sp)
 85e:	f04a                	sd	s2,32(sp)
 860:	ec4e                	sd	s3,24(sp)
 862:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 864:	02051993          	slli	s3,a0,0x20
 868:	0209d993          	srli	s3,s3,0x20
 86c:	09bd                	addi	s3,s3,15
 86e:	0049d993          	srli	s3,s3,0x4
 872:	2985                	addiw	s3,s3,1
 874:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 876:	00000517          	auipc	a0,0x0
 87a:	5ea53503          	ld	a0,1514(a0) # e60 <freep>
 87e:	c905                	beqz	a0,8ae <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 880:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 882:	4798                	lw	a4,8(a5)
 884:	09377a63          	bgeu	a4,s3,918 <malloc+0xc0>
 888:	f426                	sd	s1,40(sp)
 88a:	e852                	sd	s4,16(sp)
 88c:	e456                	sd	s5,8(sp)
 88e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 890:	8a4e                	mv	s4,s3
 892:	6705                	lui	a4,0x1
 894:	00e9f363          	bgeu	s3,a4,89a <malloc+0x42>
 898:	6a05                	lui	s4,0x1
 89a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 89e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8a2:	00000497          	auipc	s1,0x0
 8a6:	5be48493          	addi	s1,s1,1470 # e60 <freep>
  if(p == (char*)-1)
 8aa:	5afd                	li	s5,-1
 8ac:	a089                	j	8ee <malloc+0x96>
 8ae:	f426                	sd	s1,40(sp)
 8b0:	e852                	sd	s4,16(sp)
 8b2:	e456                	sd	s5,8(sp)
 8b4:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8b6:	00000797          	auipc	a5,0x0
 8ba:	7b278793          	addi	a5,a5,1970 # 1068 <base>
 8be:	00000717          	auipc	a4,0x0
 8c2:	5af73123          	sd	a5,1442(a4) # e60 <freep>
 8c6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8c8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8cc:	b7d1                	j	890 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8ce:	6398                	ld	a4,0(a5)
 8d0:	e118                	sd	a4,0(a0)
 8d2:	a8b9                	j	930 <malloc+0xd8>
  hp->s.size = nu;
 8d4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8d8:	0541                	addi	a0,a0,16
 8da:	00000097          	auipc	ra,0x0
 8de:	ef8080e7          	jalr	-264(ra) # 7d2 <free>
  return freep;
 8e2:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8e4:	c135                	beqz	a0,948 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e8:	4798                	lw	a4,8(a5)
 8ea:	03277363          	bgeu	a4,s2,910 <malloc+0xb8>
    if(p == freep)
 8ee:	6098                	ld	a4,0(s1)
 8f0:	853e                	mv	a0,a5
 8f2:	fef71ae3          	bne	a4,a5,8e6 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8f6:	8552                	mv	a0,s4
 8f8:	00000097          	auipc	ra,0x0
 8fc:	bae080e7          	jalr	-1106(ra) # 4a6 <sbrk>
  if(p == (char*)-1)
 900:	fd551ae3          	bne	a0,s5,8d4 <malloc+0x7c>
        return 0;
 904:	4501                	li	a0,0
 906:	74a2                	ld	s1,40(sp)
 908:	6a42                	ld	s4,16(sp)
 90a:	6aa2                	ld	s5,8(sp)
 90c:	6b02                	ld	s6,0(sp)
 90e:	a03d                	j	93c <malloc+0xe4>
 910:	74a2                	ld	s1,40(sp)
 912:	6a42                	ld	s4,16(sp)
 914:	6aa2                	ld	s5,8(sp)
 916:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 918:	fae90be3          	beq	s2,a4,8ce <malloc+0x76>
        p->s.size -= nunits;
 91c:	4137073b          	subw	a4,a4,s3
 920:	c798                	sw	a4,8(a5)
        p += p->s.size;
 922:	02071693          	slli	a3,a4,0x20
 926:	01c6d713          	srli	a4,a3,0x1c
 92a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 92c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 930:	00000717          	auipc	a4,0x0
 934:	52a73823          	sd	a0,1328(a4) # e60 <freep>
      return (void*)(p + 1);
 938:	01078513          	addi	a0,a5,16
  }
}
 93c:	70e2                	ld	ra,56(sp)
 93e:	7442                	ld	s0,48(sp)
 940:	7902                	ld	s2,32(sp)
 942:	69e2                	ld	s3,24(sp)
 944:	6121                	addi	sp,sp,64
 946:	8082                	ret
 948:	74a2                	ld	s1,40(sp)
 94a:	6a42                	ld	s4,16(sp)
 94c:	6aa2                	ld	s5,8(sp)
 94e:	6b02                	ld	s6,0(sp)
 950:	b7f5                	j	93c <malloc+0xe4>
