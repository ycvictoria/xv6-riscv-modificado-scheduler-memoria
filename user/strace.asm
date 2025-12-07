
user/_strace:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <is_num>:
#include "../kernel/param.h"
#include "../kernel/stat.h"
#include "./user.h"

int is_num(char s[])
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    for(int i = 0; s[i] != '\0' ; i++)
   8:	00054783          	lbu	a5,0(a0)
   c:	cf99                	beqz	a5,2a <is_num+0x2a>
   e:	0505                	addi	a0,a0,1
    {
        if(s[i] < '0' || s[i] > '9')
  10:	4725                	li	a4,9
  12:	fd07879b          	addiw	a5,a5,-48
  16:	0ff7f793          	zext.b	a5,a5
  1a:	00f76a63          	bltu	a4,a5,2e <is_num+0x2e>
    for(int i = 0; s[i] != '\0' ; i++)
  1e:	0505                	addi	a0,a0,1
  20:	fff54783          	lbu	a5,-1(a0)
  24:	f7fd                	bnez	a5,12 <is_num+0x12>
        {
            return 0;
        }
    }

    return 1;
  26:	4505                	li	a0,1
  28:	a021                	j	30 <is_num+0x30>
  2a:	4505                	li	a0,1
  2c:	a011                	j	30 <is_num+0x30>
            return 0;
  2e:	4501                	li	a0,0
}
  30:	60a2                	ld	ra,8(sp)
  32:	6402                	ld	s0,0(sp)
  34:	0141                	addi	sp,sp,16
  36:	8082                	ret

0000000000000038 <main>:


int main(int argc, char*argv[])
{
  38:	7169                	addi	sp,sp,-304
  3a:	f606                	sd	ra,296(sp)
  3c:	f222                	sd	s0,288(sp)
  3e:	ee26                	sd	s1,280(sp)
  40:	ea4a                	sd	s2,272(sp)
  42:	e64e                	sd	s3,264(sp)
  44:	1a00                	addi	s0,sp,304
  46:	892a                	mv	s2,a0
  48:	84ae                	mv	s1,a1
    char *nargv[MAXARG];

    int check;
    check = is_num(argv[1]);
  4a:	0085b983          	ld	s3,8(a1)
  4e:	854e                	mv	a0,s3
  50:	00000097          	auipc	ra,0x0
  54:	fb0080e7          	jalr	-80(ra) # 0 <is_num>
    
    // checking for incorrect input
    if(argc < 3 || check == 0)
  58:	00392793          	slti	a5,s2,3
  5c:	efb1                	bnez	a5,b8 <main+0x80>
  5e:	cd29                	beqz	a0,b8 <main+0x80>
        fprintf(2, "Correct usage: strace <mask> <command>\n");
        exit(1);
    }

    int temp, temp_num;
    temp_num = atoi(argv[1]);
  60:	854e                	mv	a0,s3
  62:	00000097          	auipc	ra,0x0
  66:	224080e7          	jalr	548(ra) # 286 <atoi>
    temp = trace(temp_num);
  6a:	00000097          	auipc	ra,0x0
  6e:	3be080e7          	jalr	958(ra) # 428 <trace>

    if(temp < 0)
  72:	06054a63          	bltz	a0,e6 <main+0xae>
    {
        fprintf(2, "strace: trace failed\n");
    }

    // copying the command
    for(int i = 2; i < argc && i < MAXARG; i++)
  76:	01048593          	addi	a1,s1,16
  7a:	ed040713          	addi	a4,s0,-304
{
  7e:	4689                	li	a3,2
    {
        nargv[i - 2] = argv[i];
  80:	619c                	ld	a5,0(a1)
  82:	e31c                	sd	a5,0(a4)
    for(int i = 2; i < argc && i < MAXARG; i++)
  84:	0016879b          	addiw	a5,a3,1
  88:	86be                	mv	a3,a5
  8a:	05a1                	addi	a1,a1,8
  8c:	0721                	addi	a4,a4,8
  8e:	0127d563          	bge	a5,s2,98 <main+0x60>
  92:	0207a793          	slti	a5,a5,32
  96:	f7ed                	bnez	a5,80 <main+0x48>
    }

    exec(nargv[0], nargv);   // executing command
  98:	ed040593          	addi	a1,s0,-304
  9c:	ed043503          	ld	a0,-304(s0)
  a0:	00000097          	auipc	ra,0x0
  a4:	320080e7          	jalr	800(ra) # 3c0 <exec>

    return 0;
  a8:	4501                	li	a0,0
  aa:	70b2                	ld	ra,296(sp)
  ac:	7412                	ld	s0,288(sp)
  ae:	64f2                	ld	s1,280(sp)
  b0:	6952                	ld	s2,272(sp)
  b2:	69b2                	ld	s3,264(sp)
  b4:	6155                	addi	sp,sp,304
  b6:	8082                	ret
        fprintf(2, "Incorrect Input !\n");
  b8:	00001597          	auipc	a1,0x1
  bc:	80858593          	addi	a1,a1,-2040 # 8c0 <malloc+0xfe>
  c0:	4509                	li	a0,2
  c2:	00000097          	auipc	ra,0x0
  c6:	616080e7          	jalr	1558(ra) # 6d8 <fprintf>
        fprintf(2, "Correct usage: strace <mask> <command>\n");
  ca:	00001597          	auipc	a1,0x1
  ce:	80e58593          	addi	a1,a1,-2034 # 8d8 <malloc+0x116>
  d2:	4509                	li	a0,2
  d4:	00000097          	auipc	ra,0x0
  d8:	604080e7          	jalr	1540(ra) # 6d8 <fprintf>
        exit(1);
  dc:	4505                	li	a0,1
  de:	00000097          	auipc	ra,0x0
  e2:	2aa080e7          	jalr	682(ra) # 388 <exit>
        fprintf(2, "strace: trace failed\n");
  e6:	00001597          	auipc	a1,0x1
  ea:	81a58593          	addi	a1,a1,-2022 # 900 <malloc+0x13e>
  ee:	4509                	li	a0,2
  f0:	00000097          	auipc	ra,0x0
  f4:	5e8080e7          	jalr	1512(ra) # 6d8 <fprintf>
  f8:	bfbd                	j	76 <main+0x3e>

00000000000000fa <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  fa:	1141                	addi	sp,sp,-16
  fc:	e406                	sd	ra,8(sp)
  fe:	e022                	sd	s0,0(sp)
 100:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 102:	87aa                	mv	a5,a0
 104:	0585                	addi	a1,a1,1
 106:	0785                	addi	a5,a5,1
 108:	fff5c703          	lbu	a4,-1(a1)
 10c:	fee78fa3          	sb	a4,-1(a5)
 110:	fb75                	bnez	a4,104 <strcpy+0xa>
    ;
  return os;
}
 112:	60a2                	ld	ra,8(sp)
 114:	6402                	ld	s0,0(sp)
 116:	0141                	addi	sp,sp,16
 118:	8082                	ret

000000000000011a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 11a:	1141                	addi	sp,sp,-16
 11c:	e406                	sd	ra,8(sp)
 11e:	e022                	sd	s0,0(sp)
 120:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 122:	00054783          	lbu	a5,0(a0)
 126:	cb91                	beqz	a5,13a <strcmp+0x20>
 128:	0005c703          	lbu	a4,0(a1)
 12c:	00f71763          	bne	a4,a5,13a <strcmp+0x20>
    p++, q++;
 130:	0505                	addi	a0,a0,1
 132:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 134:	00054783          	lbu	a5,0(a0)
 138:	fbe5                	bnez	a5,128 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 13a:	0005c503          	lbu	a0,0(a1)
}
 13e:	40a7853b          	subw	a0,a5,a0
 142:	60a2                	ld	ra,8(sp)
 144:	6402                	ld	s0,0(sp)
 146:	0141                	addi	sp,sp,16
 148:	8082                	ret

000000000000014a <strlen>:

uint
strlen(const char *s)
{
 14a:	1141                	addi	sp,sp,-16
 14c:	e406                	sd	ra,8(sp)
 14e:	e022                	sd	s0,0(sp)
 150:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 152:	00054783          	lbu	a5,0(a0)
 156:	cf91                	beqz	a5,172 <strlen+0x28>
 158:	00150793          	addi	a5,a0,1
 15c:	86be                	mv	a3,a5
 15e:	0785                	addi	a5,a5,1
 160:	fff7c703          	lbu	a4,-1(a5)
 164:	ff65                	bnez	a4,15c <strlen+0x12>
 166:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 16a:	60a2                	ld	ra,8(sp)
 16c:	6402                	ld	s0,0(sp)
 16e:	0141                	addi	sp,sp,16
 170:	8082                	ret
  for(n = 0; s[n]; n++)
 172:	4501                	li	a0,0
 174:	bfdd                	j	16a <strlen+0x20>

0000000000000176 <memset>:

void*
memset(void *dst, int c, uint n)
{
 176:	1141                	addi	sp,sp,-16
 178:	e406                	sd	ra,8(sp)
 17a:	e022                	sd	s0,0(sp)
 17c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 17e:	ca19                	beqz	a2,194 <memset+0x1e>
 180:	87aa                	mv	a5,a0
 182:	1602                	slli	a2,a2,0x20
 184:	9201                	srli	a2,a2,0x20
 186:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 18a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 18e:	0785                	addi	a5,a5,1
 190:	fee79de3          	bne	a5,a4,18a <memset+0x14>
  }
  return dst;
}
 194:	60a2                	ld	ra,8(sp)
 196:	6402                	ld	s0,0(sp)
 198:	0141                	addi	sp,sp,16
 19a:	8082                	ret

000000000000019c <strchr>:

char*
strchr(const char *s, char c)
{
 19c:	1141                	addi	sp,sp,-16
 19e:	e406                	sd	ra,8(sp)
 1a0:	e022                	sd	s0,0(sp)
 1a2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1a4:	00054783          	lbu	a5,0(a0)
 1a8:	cf81                	beqz	a5,1c0 <strchr+0x24>
    if(*s == c)
 1aa:	00f58763          	beq	a1,a5,1b8 <strchr+0x1c>
  for(; *s; s++)
 1ae:	0505                	addi	a0,a0,1
 1b0:	00054783          	lbu	a5,0(a0)
 1b4:	fbfd                	bnez	a5,1aa <strchr+0xe>
      return (char*)s;
  return 0;
 1b6:	4501                	li	a0,0
}
 1b8:	60a2                	ld	ra,8(sp)
 1ba:	6402                	ld	s0,0(sp)
 1bc:	0141                	addi	sp,sp,16
 1be:	8082                	ret
  return 0;
 1c0:	4501                	li	a0,0
 1c2:	bfdd                	j	1b8 <strchr+0x1c>

00000000000001c4 <gets>:

char*
gets(char *buf, int max)
{
 1c4:	711d                	addi	sp,sp,-96
 1c6:	ec86                	sd	ra,88(sp)
 1c8:	e8a2                	sd	s0,80(sp)
 1ca:	e4a6                	sd	s1,72(sp)
 1cc:	e0ca                	sd	s2,64(sp)
 1ce:	fc4e                	sd	s3,56(sp)
 1d0:	f852                	sd	s4,48(sp)
 1d2:	f456                	sd	s5,40(sp)
 1d4:	f05a                	sd	s6,32(sp)
 1d6:	ec5e                	sd	s7,24(sp)
 1d8:	e862                	sd	s8,16(sp)
 1da:	1080                	addi	s0,sp,96
 1dc:	8baa                	mv	s7,a0
 1de:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e0:	892a                	mv	s2,a0
 1e2:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1e4:	faf40b13          	addi	s6,s0,-81
 1e8:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 1ea:	8c26                	mv	s8,s1
 1ec:	0014899b          	addiw	s3,s1,1
 1f0:	84ce                	mv	s1,s3
 1f2:	0349d663          	bge	s3,s4,21e <gets+0x5a>
    cc = read(0, &c, 1);
 1f6:	8656                	mv	a2,s5
 1f8:	85da                	mv	a1,s6
 1fa:	4501                	li	a0,0
 1fc:	00000097          	auipc	ra,0x0
 200:	1a4080e7          	jalr	420(ra) # 3a0 <read>
    if(cc < 1)
 204:	00a05d63          	blez	a0,21e <gets+0x5a>
      break;
    buf[i++] = c;
 208:	faf44783          	lbu	a5,-81(s0)
 20c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 210:	0905                	addi	s2,s2,1
 212:	ff678713          	addi	a4,a5,-10
 216:	c319                	beqz	a4,21c <gets+0x58>
 218:	17cd                	addi	a5,a5,-13
 21a:	fbe1                	bnez	a5,1ea <gets+0x26>
    buf[i++] = c;
 21c:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 21e:	9c5e                	add	s8,s8,s7
 220:	000c0023          	sb	zero,0(s8)
  return buf;
}
 224:	855e                	mv	a0,s7
 226:	60e6                	ld	ra,88(sp)
 228:	6446                	ld	s0,80(sp)
 22a:	64a6                	ld	s1,72(sp)
 22c:	6906                	ld	s2,64(sp)
 22e:	79e2                	ld	s3,56(sp)
 230:	7a42                	ld	s4,48(sp)
 232:	7aa2                	ld	s5,40(sp)
 234:	7b02                	ld	s6,32(sp)
 236:	6be2                	ld	s7,24(sp)
 238:	6c42                	ld	s8,16(sp)
 23a:	6125                	addi	sp,sp,96
 23c:	8082                	ret

000000000000023e <stat>:

int
stat(const char *n, struct stat *st)
{
 23e:	1101                	addi	sp,sp,-32
 240:	ec06                	sd	ra,24(sp)
 242:	e822                	sd	s0,16(sp)
 244:	e04a                	sd	s2,0(sp)
 246:	1000                	addi	s0,sp,32
 248:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 24a:	4581                	li	a1,0
 24c:	00000097          	auipc	ra,0x0
 250:	17c080e7          	jalr	380(ra) # 3c8 <open>
  if(fd < 0)
 254:	02054663          	bltz	a0,280 <stat+0x42>
 258:	e426                	sd	s1,8(sp)
 25a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 25c:	85ca                	mv	a1,s2
 25e:	00000097          	auipc	ra,0x0
 262:	182080e7          	jalr	386(ra) # 3e0 <fstat>
 266:	892a                	mv	s2,a0
  close(fd);
 268:	8526                	mv	a0,s1
 26a:	00000097          	auipc	ra,0x0
 26e:	146080e7          	jalr	326(ra) # 3b0 <close>
  return r;
 272:	64a2                	ld	s1,8(sp)
}
 274:	854a                	mv	a0,s2
 276:	60e2                	ld	ra,24(sp)
 278:	6442                	ld	s0,16(sp)
 27a:	6902                	ld	s2,0(sp)
 27c:	6105                	addi	sp,sp,32
 27e:	8082                	ret
    return -1;
 280:	57fd                	li	a5,-1
 282:	893e                	mv	s2,a5
 284:	bfc5                	j	274 <stat+0x36>

0000000000000286 <atoi>:

int
atoi(const char *s)
{
 286:	1141                	addi	sp,sp,-16
 288:	e406                	sd	ra,8(sp)
 28a:	e022                	sd	s0,0(sp)
 28c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 28e:	00054683          	lbu	a3,0(a0)
 292:	fd06879b          	addiw	a5,a3,-48
 296:	0ff7f793          	zext.b	a5,a5
 29a:	4625                	li	a2,9
 29c:	02f66963          	bltu	a2,a5,2ce <atoi+0x48>
 2a0:	872a                	mv	a4,a0
  n = 0;
 2a2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2a4:	0705                	addi	a4,a4,1
 2a6:	0025179b          	slliw	a5,a0,0x2
 2aa:	9fa9                	addw	a5,a5,a0
 2ac:	0017979b          	slliw	a5,a5,0x1
 2b0:	9fb5                	addw	a5,a5,a3
 2b2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2b6:	00074683          	lbu	a3,0(a4)
 2ba:	fd06879b          	addiw	a5,a3,-48
 2be:	0ff7f793          	zext.b	a5,a5
 2c2:	fef671e3          	bgeu	a2,a5,2a4 <atoi+0x1e>
  return n;
}
 2c6:	60a2                	ld	ra,8(sp)
 2c8:	6402                	ld	s0,0(sp)
 2ca:	0141                	addi	sp,sp,16
 2cc:	8082                	ret
  n = 0;
 2ce:	4501                	li	a0,0
 2d0:	bfdd                	j	2c6 <atoi+0x40>

00000000000002d2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2d2:	1141                	addi	sp,sp,-16
 2d4:	e406                	sd	ra,8(sp)
 2d6:	e022                	sd	s0,0(sp)
 2d8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2da:	02b57563          	bgeu	a0,a1,304 <memmove+0x32>
    while(n-- > 0)
 2de:	00c05f63          	blez	a2,2fc <memmove+0x2a>
 2e2:	1602                	slli	a2,a2,0x20
 2e4:	9201                	srli	a2,a2,0x20
 2e6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2ea:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ec:	0585                	addi	a1,a1,1
 2ee:	0705                	addi	a4,a4,1
 2f0:	fff5c683          	lbu	a3,-1(a1)
 2f4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2f8:	fee79ae3          	bne	a5,a4,2ec <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2fc:	60a2                	ld	ra,8(sp)
 2fe:	6402                	ld	s0,0(sp)
 300:	0141                	addi	sp,sp,16
 302:	8082                	ret
    while(n-- > 0)
 304:	fec05ce3          	blez	a2,2fc <memmove+0x2a>
    dst += n;
 308:	00c50733          	add	a4,a0,a2
    src += n;
 30c:	95b2                	add	a1,a1,a2
 30e:	fff6079b          	addiw	a5,a2,-1
 312:	1782                	slli	a5,a5,0x20
 314:	9381                	srli	a5,a5,0x20
 316:	fff7c793          	not	a5,a5
 31a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 31c:	15fd                	addi	a1,a1,-1
 31e:	177d                	addi	a4,a4,-1
 320:	0005c683          	lbu	a3,0(a1)
 324:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 328:	fef71ae3          	bne	a4,a5,31c <memmove+0x4a>
 32c:	bfc1                	j	2fc <memmove+0x2a>

000000000000032e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 32e:	1141                	addi	sp,sp,-16
 330:	e406                	sd	ra,8(sp)
 332:	e022                	sd	s0,0(sp)
 334:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 336:	c61d                	beqz	a2,364 <memcmp+0x36>
 338:	1602                	slli	a2,a2,0x20
 33a:	9201                	srli	a2,a2,0x20
 33c:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 340:	00054783          	lbu	a5,0(a0)
 344:	0005c703          	lbu	a4,0(a1)
 348:	00e79863          	bne	a5,a4,358 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 34c:	0505                	addi	a0,a0,1
    p2++;
 34e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 350:	fed518e3          	bne	a0,a3,340 <memcmp+0x12>
  }
  return 0;
 354:	4501                	li	a0,0
 356:	a019                	j	35c <memcmp+0x2e>
      return *p1 - *p2;
 358:	40e7853b          	subw	a0,a5,a4
}
 35c:	60a2                	ld	ra,8(sp)
 35e:	6402                	ld	s0,0(sp)
 360:	0141                	addi	sp,sp,16
 362:	8082                	ret
  return 0;
 364:	4501                	li	a0,0
 366:	bfdd                	j	35c <memcmp+0x2e>

0000000000000368 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 368:	1141                	addi	sp,sp,-16
 36a:	e406                	sd	ra,8(sp)
 36c:	e022                	sd	s0,0(sp)
 36e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 370:	00000097          	auipc	ra,0x0
 374:	f62080e7          	jalr	-158(ra) # 2d2 <memmove>
}
 378:	60a2                	ld	ra,8(sp)
 37a:	6402                	ld	s0,0(sp)
 37c:	0141                	addi	sp,sp,16
 37e:	8082                	ret

0000000000000380 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 380:	4885                	li	a7,1
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <exit>:
.global exit
exit:
 li a7, SYS_exit
 388:	4889                	li	a7,2
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <wait>:
.global wait
wait:
 li a7, SYS_wait
 390:	488d                	li	a7,3
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 398:	4891                	li	a7,4
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <read>:
.global read
read:
 li a7, SYS_read
 3a0:	4895                	li	a7,5
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <write>:
.global write
write:
 li a7, SYS_write
 3a8:	48c1                	li	a7,16
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <close>:
.global close
close:
 li a7, SYS_close
 3b0:	48d5                	li	a7,21
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3b8:	4899                	li	a7,6
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3c0:	489d                	li	a7,7
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <open>:
.global open
open:
 li a7, SYS_open
 3c8:	48bd                	li	a7,15
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3d0:	48c5                	li	a7,17
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3d8:	48c9                	li	a7,18
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3e0:	48a1                	li	a7,8
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <link>:
.global link
link:
 li a7, SYS_link
 3e8:	48cd                	li	a7,19
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3f0:	48d1                	li	a7,20
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3f8:	48a5                	li	a7,9
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <dup>:
.global dup
dup:
 li a7, SYS_dup
 400:	48a9                	li	a7,10
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 408:	48ad                	li	a7,11
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 410:	48b1                	li	a7,12
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 418:	48b5                	li	a7,13
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 420:	48b9                	li	a7,14
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <trace>:
.global trace
trace:
 li a7, SYS_trace
 428:	48d9                	li	a7,22
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 430:	48dd                	li	a7,23
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 438:	48e1                	li	a7,24
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 440:	1101                	addi	sp,sp,-32
 442:	ec06                	sd	ra,24(sp)
 444:	e822                	sd	s0,16(sp)
 446:	1000                	addi	s0,sp,32
 448:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 44c:	4605                	li	a2,1
 44e:	fef40593          	addi	a1,s0,-17
 452:	00000097          	auipc	ra,0x0
 456:	f56080e7          	jalr	-170(ra) # 3a8 <write>
}
 45a:	60e2                	ld	ra,24(sp)
 45c:	6442                	ld	s0,16(sp)
 45e:	6105                	addi	sp,sp,32
 460:	8082                	ret

0000000000000462 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 462:	7139                	addi	sp,sp,-64
 464:	fc06                	sd	ra,56(sp)
 466:	f822                	sd	s0,48(sp)
 468:	f04a                	sd	s2,32(sp)
 46a:	ec4e                	sd	s3,24(sp)
 46c:	0080                	addi	s0,sp,64
 46e:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 470:	cad9                	beqz	a3,506 <printint+0xa4>
 472:	01f5d79b          	srliw	a5,a1,0x1f
 476:	cbc1                	beqz	a5,506 <printint+0xa4>
    neg = 1;
    x = -xx;
 478:	40b005bb          	negw	a1,a1
    neg = 1;
 47c:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 47e:	fc040993          	addi	s3,s0,-64
  neg = 0;
 482:	86ce                	mv	a3,s3
  i = 0;
 484:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 486:	00000817          	auipc	a6,0x0
 48a:	4f280813          	addi	a6,a6,1266 # 978 <digits>
 48e:	88ba                	mv	a7,a4
 490:	0017051b          	addiw	a0,a4,1
 494:	872a                	mv	a4,a0
 496:	02c5f7bb          	remuw	a5,a1,a2
 49a:	1782                	slli	a5,a5,0x20
 49c:	9381                	srli	a5,a5,0x20
 49e:	97c2                	add	a5,a5,a6
 4a0:	0007c783          	lbu	a5,0(a5)
 4a4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4a8:	87ae                	mv	a5,a1
 4aa:	02c5d5bb          	divuw	a1,a1,a2
 4ae:	0685                	addi	a3,a3,1
 4b0:	fcc7ffe3          	bgeu	a5,a2,48e <printint+0x2c>
  if(neg)
 4b4:	00030c63          	beqz	t1,4cc <printint+0x6a>
    buf[i++] = '-';
 4b8:	fd050793          	addi	a5,a0,-48
 4bc:	00878533          	add	a0,a5,s0
 4c0:	02d00793          	li	a5,45
 4c4:	fef50823          	sb	a5,-16(a0)
 4c8:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 4cc:	02e05763          	blez	a4,4fa <printint+0x98>
 4d0:	f426                	sd	s1,40(sp)
 4d2:	377d                	addiw	a4,a4,-1
 4d4:	00e984b3          	add	s1,s3,a4
 4d8:	19fd                	addi	s3,s3,-1
 4da:	99ba                	add	s3,s3,a4
 4dc:	1702                	slli	a4,a4,0x20
 4de:	9301                	srli	a4,a4,0x20
 4e0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4e4:	0004c583          	lbu	a1,0(s1)
 4e8:	854a                	mv	a0,s2
 4ea:	00000097          	auipc	ra,0x0
 4ee:	f56080e7          	jalr	-170(ra) # 440 <putc>
  while(--i >= 0)
 4f2:	14fd                	addi	s1,s1,-1
 4f4:	ff3498e3          	bne	s1,s3,4e4 <printint+0x82>
 4f8:	74a2                	ld	s1,40(sp)
}
 4fa:	70e2                	ld	ra,56(sp)
 4fc:	7442                	ld	s0,48(sp)
 4fe:	7902                	ld	s2,32(sp)
 500:	69e2                	ld	s3,24(sp)
 502:	6121                	addi	sp,sp,64
 504:	8082                	ret
  neg = 0;
 506:	4301                	li	t1,0
 508:	bf9d                	j	47e <printint+0x1c>

000000000000050a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 50a:	715d                	addi	sp,sp,-80
 50c:	e486                	sd	ra,72(sp)
 50e:	e0a2                	sd	s0,64(sp)
 510:	f84a                	sd	s2,48(sp)
 512:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 514:	0005c903          	lbu	s2,0(a1)
 518:	1a090b63          	beqz	s2,6ce <vprintf+0x1c4>
 51c:	fc26                	sd	s1,56(sp)
 51e:	f44e                	sd	s3,40(sp)
 520:	f052                	sd	s4,32(sp)
 522:	ec56                	sd	s5,24(sp)
 524:	e85a                	sd	s6,16(sp)
 526:	e45e                	sd	s7,8(sp)
 528:	8aaa                	mv	s5,a0
 52a:	8bb2                	mv	s7,a2
 52c:	00158493          	addi	s1,a1,1
  state = 0;
 530:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 532:	02500a13          	li	s4,37
 536:	4b55                	li	s6,21
 538:	a839                	j	556 <vprintf+0x4c>
        putc(fd, c);
 53a:	85ca                	mv	a1,s2
 53c:	8556                	mv	a0,s5
 53e:	00000097          	auipc	ra,0x0
 542:	f02080e7          	jalr	-254(ra) # 440 <putc>
 546:	a019                	j	54c <vprintf+0x42>
    } else if(state == '%'){
 548:	01498d63          	beq	s3,s4,562 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 54c:	0485                	addi	s1,s1,1
 54e:	fff4c903          	lbu	s2,-1(s1)
 552:	16090863          	beqz	s2,6c2 <vprintf+0x1b8>
    if(state == 0){
 556:	fe0999e3          	bnez	s3,548 <vprintf+0x3e>
      if(c == '%'){
 55a:	ff4910e3          	bne	s2,s4,53a <vprintf+0x30>
        state = '%';
 55e:	89d2                	mv	s3,s4
 560:	b7f5                	j	54c <vprintf+0x42>
      if(c == 'd'){
 562:	13490563          	beq	s2,s4,68c <vprintf+0x182>
 566:	f9d9079b          	addiw	a5,s2,-99
 56a:	0ff7f793          	zext.b	a5,a5
 56e:	12fb6863          	bltu	s6,a5,69e <vprintf+0x194>
 572:	f9d9079b          	addiw	a5,s2,-99
 576:	0ff7f713          	zext.b	a4,a5
 57a:	12eb6263          	bltu	s6,a4,69e <vprintf+0x194>
 57e:	00271793          	slli	a5,a4,0x2
 582:	00000717          	auipc	a4,0x0
 586:	39e70713          	addi	a4,a4,926 # 920 <malloc+0x15e>
 58a:	97ba                	add	a5,a5,a4
 58c:	439c                	lw	a5,0(a5)
 58e:	97ba                	add	a5,a5,a4
 590:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 592:	008b8913          	addi	s2,s7,8
 596:	4685                	li	a3,1
 598:	4629                	li	a2,10
 59a:	000ba583          	lw	a1,0(s7)
 59e:	8556                	mv	a0,s5
 5a0:	00000097          	auipc	ra,0x0
 5a4:	ec2080e7          	jalr	-318(ra) # 462 <printint>
 5a8:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5aa:	4981                	li	s3,0
 5ac:	b745                	j	54c <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ae:	008b8913          	addi	s2,s7,8
 5b2:	4681                	li	a3,0
 5b4:	4629                	li	a2,10
 5b6:	000ba583          	lw	a1,0(s7)
 5ba:	8556                	mv	a0,s5
 5bc:	00000097          	auipc	ra,0x0
 5c0:	ea6080e7          	jalr	-346(ra) # 462 <printint>
 5c4:	8bca                	mv	s7,s2
      state = 0;
 5c6:	4981                	li	s3,0
 5c8:	b751                	j	54c <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 5ca:	008b8913          	addi	s2,s7,8
 5ce:	4681                	li	a3,0
 5d0:	4641                	li	a2,16
 5d2:	000ba583          	lw	a1,0(s7)
 5d6:	8556                	mv	a0,s5
 5d8:	00000097          	auipc	ra,0x0
 5dc:	e8a080e7          	jalr	-374(ra) # 462 <printint>
 5e0:	8bca                	mv	s7,s2
      state = 0;
 5e2:	4981                	li	s3,0
 5e4:	b7a5                	j	54c <vprintf+0x42>
 5e6:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 5e8:	008b8793          	addi	a5,s7,8
 5ec:	8c3e                	mv	s8,a5
 5ee:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5f2:	03000593          	li	a1,48
 5f6:	8556                	mv	a0,s5
 5f8:	00000097          	auipc	ra,0x0
 5fc:	e48080e7          	jalr	-440(ra) # 440 <putc>
  putc(fd, 'x');
 600:	07800593          	li	a1,120
 604:	8556                	mv	a0,s5
 606:	00000097          	auipc	ra,0x0
 60a:	e3a080e7          	jalr	-454(ra) # 440 <putc>
 60e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 610:	00000b97          	auipc	s7,0x0
 614:	368b8b93          	addi	s7,s7,872 # 978 <digits>
 618:	03c9d793          	srli	a5,s3,0x3c
 61c:	97de                	add	a5,a5,s7
 61e:	0007c583          	lbu	a1,0(a5)
 622:	8556                	mv	a0,s5
 624:	00000097          	auipc	ra,0x0
 628:	e1c080e7          	jalr	-484(ra) # 440 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 62c:	0992                	slli	s3,s3,0x4
 62e:	397d                	addiw	s2,s2,-1
 630:	fe0914e3          	bnez	s2,618 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
 634:	8be2                	mv	s7,s8
      state = 0;
 636:	4981                	li	s3,0
 638:	6c02                	ld	s8,0(sp)
 63a:	bf09                	j	54c <vprintf+0x42>
        s = va_arg(ap, char*);
 63c:	008b8993          	addi	s3,s7,8
 640:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 644:	02090163          	beqz	s2,666 <vprintf+0x15c>
        while(*s != 0){
 648:	00094583          	lbu	a1,0(s2)
 64c:	c9a5                	beqz	a1,6bc <vprintf+0x1b2>
          putc(fd, *s);
 64e:	8556                	mv	a0,s5
 650:	00000097          	auipc	ra,0x0
 654:	df0080e7          	jalr	-528(ra) # 440 <putc>
          s++;
 658:	0905                	addi	s2,s2,1
        while(*s != 0){
 65a:	00094583          	lbu	a1,0(s2)
 65e:	f9e5                	bnez	a1,64e <vprintf+0x144>
        s = va_arg(ap, char*);
 660:	8bce                	mv	s7,s3
      state = 0;
 662:	4981                	li	s3,0
 664:	b5e5                	j	54c <vprintf+0x42>
          s = "(null)";
 666:	00000917          	auipc	s2,0x0
 66a:	2b290913          	addi	s2,s2,690 # 918 <malloc+0x156>
        while(*s != 0){
 66e:	02800593          	li	a1,40
 672:	bff1                	j	64e <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
 674:	008b8913          	addi	s2,s7,8
 678:	000bc583          	lbu	a1,0(s7)
 67c:	8556                	mv	a0,s5
 67e:	00000097          	auipc	ra,0x0
 682:	dc2080e7          	jalr	-574(ra) # 440 <putc>
 686:	8bca                	mv	s7,s2
      state = 0;
 688:	4981                	li	s3,0
 68a:	b5c9                	j	54c <vprintf+0x42>
        putc(fd, c);
 68c:	02500593          	li	a1,37
 690:	8556                	mv	a0,s5
 692:	00000097          	auipc	ra,0x0
 696:	dae080e7          	jalr	-594(ra) # 440 <putc>
      state = 0;
 69a:	4981                	li	s3,0
 69c:	bd45                	j	54c <vprintf+0x42>
        putc(fd, '%');
 69e:	02500593          	li	a1,37
 6a2:	8556                	mv	a0,s5
 6a4:	00000097          	auipc	ra,0x0
 6a8:	d9c080e7          	jalr	-612(ra) # 440 <putc>
        putc(fd, c);
 6ac:	85ca                	mv	a1,s2
 6ae:	8556                	mv	a0,s5
 6b0:	00000097          	auipc	ra,0x0
 6b4:	d90080e7          	jalr	-624(ra) # 440 <putc>
      state = 0;
 6b8:	4981                	li	s3,0
 6ba:	bd49                	j	54c <vprintf+0x42>
        s = va_arg(ap, char*);
 6bc:	8bce                	mv	s7,s3
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	b571                	j	54c <vprintf+0x42>
 6c2:	74e2                	ld	s1,56(sp)
 6c4:	79a2                	ld	s3,40(sp)
 6c6:	7a02                	ld	s4,32(sp)
 6c8:	6ae2                	ld	s5,24(sp)
 6ca:	6b42                	ld	s6,16(sp)
 6cc:	6ba2                	ld	s7,8(sp)
    }
  }
}
 6ce:	60a6                	ld	ra,72(sp)
 6d0:	6406                	ld	s0,64(sp)
 6d2:	7942                	ld	s2,48(sp)
 6d4:	6161                	addi	sp,sp,80
 6d6:	8082                	ret

00000000000006d8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6d8:	715d                	addi	sp,sp,-80
 6da:	ec06                	sd	ra,24(sp)
 6dc:	e822                	sd	s0,16(sp)
 6de:	1000                	addi	s0,sp,32
 6e0:	e010                	sd	a2,0(s0)
 6e2:	e414                	sd	a3,8(s0)
 6e4:	e818                	sd	a4,16(s0)
 6e6:	ec1c                	sd	a5,24(s0)
 6e8:	03043023          	sd	a6,32(s0)
 6ec:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6f0:	8622                	mv	a2,s0
 6f2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6f6:	00000097          	auipc	ra,0x0
 6fa:	e14080e7          	jalr	-492(ra) # 50a <vprintf>
}
 6fe:	60e2                	ld	ra,24(sp)
 700:	6442                	ld	s0,16(sp)
 702:	6161                	addi	sp,sp,80
 704:	8082                	ret

0000000000000706 <printf>:

void
printf(const char *fmt, ...)
{
 706:	711d                	addi	sp,sp,-96
 708:	ec06                	sd	ra,24(sp)
 70a:	e822                	sd	s0,16(sp)
 70c:	1000                	addi	s0,sp,32
 70e:	e40c                	sd	a1,8(s0)
 710:	e810                	sd	a2,16(s0)
 712:	ec14                	sd	a3,24(s0)
 714:	f018                	sd	a4,32(s0)
 716:	f41c                	sd	a5,40(s0)
 718:	03043823          	sd	a6,48(s0)
 71c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 720:	00840613          	addi	a2,s0,8
 724:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 728:	85aa                	mv	a1,a0
 72a:	4505                	li	a0,1
 72c:	00000097          	auipc	ra,0x0
 730:	dde080e7          	jalr	-546(ra) # 50a <vprintf>
}
 734:	60e2                	ld	ra,24(sp)
 736:	6442                	ld	s0,16(sp)
 738:	6125                	addi	sp,sp,96
 73a:	8082                	ret

000000000000073c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 73c:	1141                	addi	sp,sp,-16
 73e:	e406                	sd	ra,8(sp)
 740:	e022                	sd	s0,0(sp)
 742:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 744:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 748:	00000797          	auipc	a5,0x0
 74c:	6687b783          	ld	a5,1640(a5) # db0 <freep>
 750:	a039                	j	75e <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 752:	6398                	ld	a4,0(a5)
 754:	00e7e463          	bltu	a5,a4,75c <free+0x20>
 758:	00e6ea63          	bltu	a3,a4,76c <free+0x30>
{
 75c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 75e:	fed7fae3          	bgeu	a5,a3,752 <free+0x16>
 762:	6398                	ld	a4,0(a5)
 764:	00e6e463          	bltu	a3,a4,76c <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 768:	fee7eae3          	bltu	a5,a4,75c <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 76c:	ff852583          	lw	a1,-8(a0)
 770:	6390                	ld	a2,0(a5)
 772:	02059813          	slli	a6,a1,0x20
 776:	01c85713          	srli	a4,a6,0x1c
 77a:	9736                	add	a4,a4,a3
 77c:	02e60563          	beq	a2,a4,7a6 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 780:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 784:	4790                	lw	a2,8(a5)
 786:	02061593          	slli	a1,a2,0x20
 78a:	01c5d713          	srli	a4,a1,0x1c
 78e:	973e                	add	a4,a4,a5
 790:	02e68263          	beq	a3,a4,7b4 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 794:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 796:	00000717          	auipc	a4,0x0
 79a:	60f73d23          	sd	a5,1562(a4) # db0 <freep>
}
 79e:	60a2                	ld	ra,8(sp)
 7a0:	6402                	ld	s0,0(sp)
 7a2:	0141                	addi	sp,sp,16
 7a4:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 7a6:	4618                	lw	a4,8(a2)
 7a8:	9f2d                	addw	a4,a4,a1
 7aa:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7ae:	6398                	ld	a4,0(a5)
 7b0:	6310                	ld	a2,0(a4)
 7b2:	b7f9                	j	780 <free+0x44>
    p->s.size += bp->s.size;
 7b4:	ff852703          	lw	a4,-8(a0)
 7b8:	9f31                	addw	a4,a4,a2
 7ba:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7bc:	ff053683          	ld	a3,-16(a0)
 7c0:	bfd1                	j	794 <free+0x58>

00000000000007c2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7c2:	7139                	addi	sp,sp,-64
 7c4:	fc06                	sd	ra,56(sp)
 7c6:	f822                	sd	s0,48(sp)
 7c8:	f04a                	sd	s2,32(sp)
 7ca:	ec4e                	sd	s3,24(sp)
 7cc:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7ce:	02051993          	slli	s3,a0,0x20
 7d2:	0209d993          	srli	s3,s3,0x20
 7d6:	09bd                	addi	s3,s3,15
 7d8:	0049d993          	srli	s3,s3,0x4
 7dc:	2985                	addiw	s3,s3,1
 7de:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 7e0:	00000517          	auipc	a0,0x0
 7e4:	5d053503          	ld	a0,1488(a0) # db0 <freep>
 7e8:	c905                	beqz	a0,818 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ea:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ec:	4798                	lw	a4,8(a5)
 7ee:	09377a63          	bgeu	a4,s3,882 <malloc+0xc0>
 7f2:	f426                	sd	s1,40(sp)
 7f4:	e852                	sd	s4,16(sp)
 7f6:	e456                	sd	s5,8(sp)
 7f8:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7fa:	8a4e                	mv	s4,s3
 7fc:	6705                	lui	a4,0x1
 7fe:	00e9f363          	bgeu	s3,a4,804 <malloc+0x42>
 802:	6a05                	lui	s4,0x1
 804:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 808:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 80c:	00000497          	auipc	s1,0x0
 810:	5a448493          	addi	s1,s1,1444 # db0 <freep>
  if(p == (char*)-1)
 814:	5afd                	li	s5,-1
 816:	a089                	j	858 <malloc+0x96>
 818:	f426                	sd	s1,40(sp)
 81a:	e852                	sd	s4,16(sp)
 81c:	e456                	sd	s5,8(sp)
 81e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 820:	00000797          	auipc	a5,0x0
 824:	59878793          	addi	a5,a5,1432 # db8 <base>
 828:	00000717          	auipc	a4,0x0
 82c:	58f73423          	sd	a5,1416(a4) # db0 <freep>
 830:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 832:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 836:	b7d1                	j	7fa <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 838:	6398                	ld	a4,0(a5)
 83a:	e118                	sd	a4,0(a0)
 83c:	a8b9                	j	89a <malloc+0xd8>
  hp->s.size = nu;
 83e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 842:	0541                	addi	a0,a0,16
 844:	00000097          	auipc	ra,0x0
 848:	ef8080e7          	jalr	-264(ra) # 73c <free>
  return freep;
 84c:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 84e:	c135                	beqz	a0,8b2 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 850:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 852:	4798                	lw	a4,8(a5)
 854:	03277363          	bgeu	a4,s2,87a <malloc+0xb8>
    if(p == freep)
 858:	6098                	ld	a4,0(s1)
 85a:	853e                	mv	a0,a5
 85c:	fef71ae3          	bne	a4,a5,850 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 860:	8552                	mv	a0,s4
 862:	00000097          	auipc	ra,0x0
 866:	bae080e7          	jalr	-1106(ra) # 410 <sbrk>
  if(p == (char*)-1)
 86a:	fd551ae3          	bne	a0,s5,83e <malloc+0x7c>
        return 0;
 86e:	4501                	li	a0,0
 870:	74a2                	ld	s1,40(sp)
 872:	6a42                	ld	s4,16(sp)
 874:	6aa2                	ld	s5,8(sp)
 876:	6b02                	ld	s6,0(sp)
 878:	a03d                	j	8a6 <malloc+0xe4>
 87a:	74a2                	ld	s1,40(sp)
 87c:	6a42                	ld	s4,16(sp)
 87e:	6aa2                	ld	s5,8(sp)
 880:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 882:	fae90be3          	beq	s2,a4,838 <malloc+0x76>
        p->s.size -= nunits;
 886:	4137073b          	subw	a4,a4,s3
 88a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 88c:	02071693          	slli	a3,a4,0x20
 890:	01c6d713          	srli	a4,a3,0x1c
 894:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 896:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 89a:	00000717          	auipc	a4,0x0
 89e:	50a73b23          	sd	a0,1302(a4) # db0 <freep>
      return (void*)(p + 1);
 8a2:	01078513          	addi	a0,a5,16
  }
}
 8a6:	70e2                	ld	ra,56(sp)
 8a8:	7442                	ld	s0,48(sp)
 8aa:	7902                	ld	s2,32(sp)
 8ac:	69e2                	ld	s3,24(sp)
 8ae:	6121                	addi	sp,sp,64
 8b0:	8082                	ret
 8b2:	74a2                	ld	s1,40(sp)
 8b4:	6a42                	ld	s4,16(sp)
 8b6:	6aa2                	ld	s5,8(sp)
 8b8:	6b02                	ld	s6,0(sp)
 8ba:	b7f5                	j	8a6 <malloc+0xe4>
