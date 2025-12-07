
user/_setpriority:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <check_priority_range>:
#include "../kernel/types.h"
#include "../kernel/param.h"
#include "../kernel/stat.h"
#include "./user.h"

int check_priority_range(int priority){
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16

    if(priority >= 0 || priority <= 100){
        return 1;
    }
    return 0;
}
   8:	4505                	li	a0,1
   a:	60a2                	ld	ra,8(sp)
   c:	6402                	ld	s0,0(sp)
   e:	0141                	addi	sp,sp,16
  10:	8082                	ret

0000000000000012 <main>:

int main(int argc, char *argv[]){
  12:	1101                	addi	sp,sp,-32
  14:	ec06                	sd	ra,24(sp)
  16:	e822                	sd	s0,16(sp)
  18:	1000                	addi	s0,sp,32
    
    if(argc < 3){
  1a:	4789                	li	a5,2
  1c:	02a7cb63          	blt	a5,a0,52 <main+0x40>
  20:	e426                	sd	s1,8(sp)
  22:	e04a                	sd	s2,0(sp)
        fprintf(2, "Incorrect Input !\n");
  24:	00001597          	auipc	a1,0x1
  28:	82458593          	addi	a1,a1,-2012 # 848 <malloc+0xfc>
  2c:	853e                	mv	a0,a5
  2e:	00000097          	auipc	ra,0x0
  32:	634080e7          	jalr	1588(ra) # 662 <fprintf>
        fprintf(2, "Correct usage: setpriority <priority> <pid>\n");
  36:	00001597          	auipc	a1,0x1
  3a:	82a58593          	addi	a1,a1,-2006 # 860 <malloc+0x114>
  3e:	4509                	li	a0,2
  40:	00000097          	auipc	ra,0x0
  44:	622080e7          	jalr	1570(ra) # 662 <fprintf>
        exit(1);
  48:	4505                	li	a0,1
  4a:	00000097          	auipc	ra,0x0
  4e:	2c8080e7          	jalr	712(ra) # 312 <exit>
  52:	e426                	sd	s1,8(sp)
  54:	e04a                	sd	s2,0(sp)
  56:	84ae                	mv	s1,a1
    }

    int priority = atoi(argv[1]);
  58:	6588                	ld	a0,8(a1)
  5a:	00000097          	auipc	ra,0x0
  5e:	1b6080e7          	jalr	438(ra) # 210 <atoi>
  62:	892a                	mv	s2,a0
    int pid = atoi(argv[2]);
  64:	6888                	ld	a0,16(s1)
  66:	00000097          	auipc	ra,0x0
  6a:	1aa080e7          	jalr	426(ra) # 210 <atoi>
  6e:	85aa                	mv	a1,a0
        fprintf(2, "Incorrect Range !\n");
        fprintf(2, "Correct Range: [0,100]\n");
        exit(1);
    }

    setpriority(priority, pid);
  70:	854a                	mv	a0,s2
  72:	00000097          	auipc	ra,0x0
  76:	348080e7          	jalr	840(ra) # 3ba <setpriority>
    exit(1);
  7a:	4505                	li	a0,1
  7c:	00000097          	auipc	ra,0x0
  80:	296080e7          	jalr	662(ra) # 312 <exit>

0000000000000084 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  84:	1141                	addi	sp,sp,-16
  86:	e406                	sd	ra,8(sp)
  88:	e022                	sd	s0,0(sp)
  8a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  8c:	87aa                	mv	a5,a0
  8e:	0585                	addi	a1,a1,1
  90:	0785                	addi	a5,a5,1
  92:	fff5c703          	lbu	a4,-1(a1)
  96:	fee78fa3          	sb	a4,-1(a5)
  9a:	fb75                	bnez	a4,8e <strcpy+0xa>
    ;
  return os;
}
  9c:	60a2                	ld	ra,8(sp)
  9e:	6402                	ld	s0,0(sp)
  a0:	0141                	addi	sp,sp,16
  a2:	8082                	ret

00000000000000a4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a4:	1141                	addi	sp,sp,-16
  a6:	e406                	sd	ra,8(sp)
  a8:	e022                	sd	s0,0(sp)
  aa:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ac:	00054783          	lbu	a5,0(a0)
  b0:	cb91                	beqz	a5,c4 <strcmp+0x20>
  b2:	0005c703          	lbu	a4,0(a1)
  b6:	00f71763          	bne	a4,a5,c4 <strcmp+0x20>
    p++, q++;
  ba:	0505                	addi	a0,a0,1
  bc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  be:	00054783          	lbu	a5,0(a0)
  c2:	fbe5                	bnez	a5,b2 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  c4:	0005c503          	lbu	a0,0(a1)
}
  c8:	40a7853b          	subw	a0,a5,a0
  cc:	60a2                	ld	ra,8(sp)
  ce:	6402                	ld	s0,0(sp)
  d0:	0141                	addi	sp,sp,16
  d2:	8082                	ret

00000000000000d4 <strlen>:

uint
strlen(const char *s)
{
  d4:	1141                	addi	sp,sp,-16
  d6:	e406                	sd	ra,8(sp)
  d8:	e022                	sd	s0,0(sp)
  da:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  dc:	00054783          	lbu	a5,0(a0)
  e0:	cf91                	beqz	a5,fc <strlen+0x28>
  e2:	00150793          	addi	a5,a0,1
  e6:	86be                	mv	a3,a5
  e8:	0785                	addi	a5,a5,1
  ea:	fff7c703          	lbu	a4,-1(a5)
  ee:	ff65                	bnez	a4,e6 <strlen+0x12>
  f0:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
  f4:	60a2                	ld	ra,8(sp)
  f6:	6402                	ld	s0,0(sp)
  f8:	0141                	addi	sp,sp,16
  fa:	8082                	ret
  for(n = 0; s[n]; n++)
  fc:	4501                	li	a0,0
  fe:	bfdd                	j	f4 <strlen+0x20>

0000000000000100 <memset>:

void*
memset(void *dst, int c, uint n)
{
 100:	1141                	addi	sp,sp,-16
 102:	e406                	sd	ra,8(sp)
 104:	e022                	sd	s0,0(sp)
 106:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 108:	ca19                	beqz	a2,11e <memset+0x1e>
 10a:	87aa                	mv	a5,a0
 10c:	1602                	slli	a2,a2,0x20
 10e:	9201                	srli	a2,a2,0x20
 110:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 114:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 118:	0785                	addi	a5,a5,1
 11a:	fee79de3          	bne	a5,a4,114 <memset+0x14>
  }
  return dst;
}
 11e:	60a2                	ld	ra,8(sp)
 120:	6402                	ld	s0,0(sp)
 122:	0141                	addi	sp,sp,16
 124:	8082                	ret

0000000000000126 <strchr>:

char*
strchr(const char *s, char c)
{
 126:	1141                	addi	sp,sp,-16
 128:	e406                	sd	ra,8(sp)
 12a:	e022                	sd	s0,0(sp)
 12c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 12e:	00054783          	lbu	a5,0(a0)
 132:	cf81                	beqz	a5,14a <strchr+0x24>
    if(*s == c)
 134:	00f58763          	beq	a1,a5,142 <strchr+0x1c>
  for(; *s; s++)
 138:	0505                	addi	a0,a0,1
 13a:	00054783          	lbu	a5,0(a0)
 13e:	fbfd                	bnez	a5,134 <strchr+0xe>
      return (char*)s;
  return 0;
 140:	4501                	li	a0,0
}
 142:	60a2                	ld	ra,8(sp)
 144:	6402                	ld	s0,0(sp)
 146:	0141                	addi	sp,sp,16
 148:	8082                	ret
  return 0;
 14a:	4501                	li	a0,0
 14c:	bfdd                	j	142 <strchr+0x1c>

000000000000014e <gets>:

char*
gets(char *buf, int max)
{
 14e:	711d                	addi	sp,sp,-96
 150:	ec86                	sd	ra,88(sp)
 152:	e8a2                	sd	s0,80(sp)
 154:	e4a6                	sd	s1,72(sp)
 156:	e0ca                	sd	s2,64(sp)
 158:	fc4e                	sd	s3,56(sp)
 15a:	f852                	sd	s4,48(sp)
 15c:	f456                	sd	s5,40(sp)
 15e:	f05a                	sd	s6,32(sp)
 160:	ec5e                	sd	s7,24(sp)
 162:	e862                	sd	s8,16(sp)
 164:	1080                	addi	s0,sp,96
 166:	8baa                	mv	s7,a0
 168:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 16a:	892a                	mv	s2,a0
 16c:	4481                	li	s1,0
    cc = read(0, &c, 1);
 16e:	faf40b13          	addi	s6,s0,-81
 172:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 174:	8c26                	mv	s8,s1
 176:	0014899b          	addiw	s3,s1,1
 17a:	84ce                	mv	s1,s3
 17c:	0349d663          	bge	s3,s4,1a8 <gets+0x5a>
    cc = read(0, &c, 1);
 180:	8656                	mv	a2,s5
 182:	85da                	mv	a1,s6
 184:	4501                	li	a0,0
 186:	00000097          	auipc	ra,0x0
 18a:	1a4080e7          	jalr	420(ra) # 32a <read>
    if(cc < 1)
 18e:	00a05d63          	blez	a0,1a8 <gets+0x5a>
      break;
    buf[i++] = c;
 192:	faf44783          	lbu	a5,-81(s0)
 196:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 19a:	0905                	addi	s2,s2,1
 19c:	ff678713          	addi	a4,a5,-10
 1a0:	c319                	beqz	a4,1a6 <gets+0x58>
 1a2:	17cd                	addi	a5,a5,-13
 1a4:	fbe1                	bnez	a5,174 <gets+0x26>
    buf[i++] = c;
 1a6:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 1a8:	9c5e                	add	s8,s8,s7
 1aa:	000c0023          	sb	zero,0(s8)
  return buf;
}
 1ae:	855e                	mv	a0,s7
 1b0:	60e6                	ld	ra,88(sp)
 1b2:	6446                	ld	s0,80(sp)
 1b4:	64a6                	ld	s1,72(sp)
 1b6:	6906                	ld	s2,64(sp)
 1b8:	79e2                	ld	s3,56(sp)
 1ba:	7a42                	ld	s4,48(sp)
 1bc:	7aa2                	ld	s5,40(sp)
 1be:	7b02                	ld	s6,32(sp)
 1c0:	6be2                	ld	s7,24(sp)
 1c2:	6c42                	ld	s8,16(sp)
 1c4:	6125                	addi	sp,sp,96
 1c6:	8082                	ret

00000000000001c8 <stat>:

int
stat(const char *n, struct stat *st)
{
 1c8:	1101                	addi	sp,sp,-32
 1ca:	ec06                	sd	ra,24(sp)
 1cc:	e822                	sd	s0,16(sp)
 1ce:	e04a                	sd	s2,0(sp)
 1d0:	1000                	addi	s0,sp,32
 1d2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1d4:	4581                	li	a1,0
 1d6:	00000097          	auipc	ra,0x0
 1da:	17c080e7          	jalr	380(ra) # 352 <open>
  if(fd < 0)
 1de:	02054663          	bltz	a0,20a <stat+0x42>
 1e2:	e426                	sd	s1,8(sp)
 1e4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1e6:	85ca                	mv	a1,s2
 1e8:	00000097          	auipc	ra,0x0
 1ec:	182080e7          	jalr	386(ra) # 36a <fstat>
 1f0:	892a                	mv	s2,a0
  close(fd);
 1f2:	8526                	mv	a0,s1
 1f4:	00000097          	auipc	ra,0x0
 1f8:	146080e7          	jalr	326(ra) # 33a <close>
  return r;
 1fc:	64a2                	ld	s1,8(sp)
}
 1fe:	854a                	mv	a0,s2
 200:	60e2                	ld	ra,24(sp)
 202:	6442                	ld	s0,16(sp)
 204:	6902                	ld	s2,0(sp)
 206:	6105                	addi	sp,sp,32
 208:	8082                	ret
    return -1;
 20a:	57fd                	li	a5,-1
 20c:	893e                	mv	s2,a5
 20e:	bfc5                	j	1fe <stat+0x36>

0000000000000210 <atoi>:

int
atoi(const char *s)
{
 210:	1141                	addi	sp,sp,-16
 212:	e406                	sd	ra,8(sp)
 214:	e022                	sd	s0,0(sp)
 216:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 218:	00054683          	lbu	a3,0(a0)
 21c:	fd06879b          	addiw	a5,a3,-48
 220:	0ff7f793          	zext.b	a5,a5
 224:	4625                	li	a2,9
 226:	02f66963          	bltu	a2,a5,258 <atoi+0x48>
 22a:	872a                	mv	a4,a0
  n = 0;
 22c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 22e:	0705                	addi	a4,a4,1
 230:	0025179b          	slliw	a5,a0,0x2
 234:	9fa9                	addw	a5,a5,a0
 236:	0017979b          	slliw	a5,a5,0x1
 23a:	9fb5                	addw	a5,a5,a3
 23c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 240:	00074683          	lbu	a3,0(a4)
 244:	fd06879b          	addiw	a5,a3,-48
 248:	0ff7f793          	zext.b	a5,a5
 24c:	fef671e3          	bgeu	a2,a5,22e <atoi+0x1e>
  return n;
}
 250:	60a2                	ld	ra,8(sp)
 252:	6402                	ld	s0,0(sp)
 254:	0141                	addi	sp,sp,16
 256:	8082                	ret
  n = 0;
 258:	4501                	li	a0,0
 25a:	bfdd                	j	250 <atoi+0x40>

000000000000025c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 25c:	1141                	addi	sp,sp,-16
 25e:	e406                	sd	ra,8(sp)
 260:	e022                	sd	s0,0(sp)
 262:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 264:	02b57563          	bgeu	a0,a1,28e <memmove+0x32>
    while(n-- > 0)
 268:	00c05f63          	blez	a2,286 <memmove+0x2a>
 26c:	1602                	slli	a2,a2,0x20
 26e:	9201                	srli	a2,a2,0x20
 270:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 274:	872a                	mv	a4,a0
      *dst++ = *src++;
 276:	0585                	addi	a1,a1,1
 278:	0705                	addi	a4,a4,1
 27a:	fff5c683          	lbu	a3,-1(a1)
 27e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 282:	fee79ae3          	bne	a5,a4,276 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 286:	60a2                	ld	ra,8(sp)
 288:	6402                	ld	s0,0(sp)
 28a:	0141                	addi	sp,sp,16
 28c:	8082                	ret
    while(n-- > 0)
 28e:	fec05ce3          	blez	a2,286 <memmove+0x2a>
    dst += n;
 292:	00c50733          	add	a4,a0,a2
    src += n;
 296:	95b2                	add	a1,a1,a2
 298:	fff6079b          	addiw	a5,a2,-1
 29c:	1782                	slli	a5,a5,0x20
 29e:	9381                	srli	a5,a5,0x20
 2a0:	fff7c793          	not	a5,a5
 2a4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2a6:	15fd                	addi	a1,a1,-1
 2a8:	177d                	addi	a4,a4,-1
 2aa:	0005c683          	lbu	a3,0(a1)
 2ae:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2b2:	fef71ae3          	bne	a4,a5,2a6 <memmove+0x4a>
 2b6:	bfc1                	j	286 <memmove+0x2a>

00000000000002b8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2b8:	1141                	addi	sp,sp,-16
 2ba:	e406                	sd	ra,8(sp)
 2bc:	e022                	sd	s0,0(sp)
 2be:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2c0:	c61d                	beqz	a2,2ee <memcmp+0x36>
 2c2:	1602                	slli	a2,a2,0x20
 2c4:	9201                	srli	a2,a2,0x20
 2c6:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 2ca:	00054783          	lbu	a5,0(a0)
 2ce:	0005c703          	lbu	a4,0(a1)
 2d2:	00e79863          	bne	a5,a4,2e2 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 2d6:	0505                	addi	a0,a0,1
    p2++;
 2d8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2da:	fed518e3          	bne	a0,a3,2ca <memcmp+0x12>
  }
  return 0;
 2de:	4501                	li	a0,0
 2e0:	a019                	j	2e6 <memcmp+0x2e>
      return *p1 - *p2;
 2e2:	40e7853b          	subw	a0,a5,a4
}
 2e6:	60a2                	ld	ra,8(sp)
 2e8:	6402                	ld	s0,0(sp)
 2ea:	0141                	addi	sp,sp,16
 2ec:	8082                	ret
  return 0;
 2ee:	4501                	li	a0,0
 2f0:	bfdd                	j	2e6 <memcmp+0x2e>

00000000000002f2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2f2:	1141                	addi	sp,sp,-16
 2f4:	e406                	sd	ra,8(sp)
 2f6:	e022                	sd	s0,0(sp)
 2f8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2fa:	00000097          	auipc	ra,0x0
 2fe:	f62080e7          	jalr	-158(ra) # 25c <memmove>
}
 302:	60a2                	ld	ra,8(sp)
 304:	6402                	ld	s0,0(sp)
 306:	0141                	addi	sp,sp,16
 308:	8082                	ret

000000000000030a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 30a:	4885                	li	a7,1
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <exit>:
.global exit
exit:
 li a7, SYS_exit
 312:	4889                	li	a7,2
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <wait>:
.global wait
wait:
 li a7, SYS_wait
 31a:	488d                	li	a7,3
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 322:	4891                	li	a7,4
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <read>:
.global read
read:
 li a7, SYS_read
 32a:	4895                	li	a7,5
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <write>:
.global write
write:
 li a7, SYS_write
 332:	48c1                	li	a7,16
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <close>:
.global close
close:
 li a7, SYS_close
 33a:	48d5                	li	a7,21
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <kill>:
.global kill
kill:
 li a7, SYS_kill
 342:	4899                	li	a7,6
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <exec>:
.global exec
exec:
 li a7, SYS_exec
 34a:	489d                	li	a7,7
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <open>:
.global open
open:
 li a7, SYS_open
 352:	48bd                	li	a7,15
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 35a:	48c5                	li	a7,17
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 362:	48c9                	li	a7,18
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 36a:	48a1                	li	a7,8
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <link>:
.global link
link:
 li a7, SYS_link
 372:	48cd                	li	a7,19
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 37a:	48d1                	li	a7,20
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 382:	48a5                	li	a7,9
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <dup>:
.global dup
dup:
 li a7, SYS_dup
 38a:	48a9                	li	a7,10
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 392:	48ad                	li	a7,11
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 39a:	48b1                	li	a7,12
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3a2:	48b5                	li	a7,13
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3aa:	48b9                	li	a7,14
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <trace>:
.global trace
trace:
 li a7, SYS_trace
 3b2:	48d9                	li	a7,22
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 3ba:	48dd                	li	a7,23
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 3c2:	48e1                	li	a7,24
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3ca:	1101                	addi	sp,sp,-32
 3cc:	ec06                	sd	ra,24(sp)
 3ce:	e822                	sd	s0,16(sp)
 3d0:	1000                	addi	s0,sp,32
 3d2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3d6:	4605                	li	a2,1
 3d8:	fef40593          	addi	a1,s0,-17
 3dc:	00000097          	auipc	ra,0x0
 3e0:	f56080e7          	jalr	-170(ra) # 332 <write>
}
 3e4:	60e2                	ld	ra,24(sp)
 3e6:	6442                	ld	s0,16(sp)
 3e8:	6105                	addi	sp,sp,32
 3ea:	8082                	ret

00000000000003ec <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3ec:	7139                	addi	sp,sp,-64
 3ee:	fc06                	sd	ra,56(sp)
 3f0:	f822                	sd	s0,48(sp)
 3f2:	f04a                	sd	s2,32(sp)
 3f4:	ec4e                	sd	s3,24(sp)
 3f6:	0080                	addi	s0,sp,64
 3f8:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3fa:	cad9                	beqz	a3,490 <printint+0xa4>
 3fc:	01f5d79b          	srliw	a5,a1,0x1f
 400:	cbc1                	beqz	a5,490 <printint+0xa4>
    neg = 1;
    x = -xx;
 402:	40b005bb          	negw	a1,a1
    neg = 1;
 406:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 408:	fc040993          	addi	s3,s0,-64
  neg = 0;
 40c:	86ce                	mv	a3,s3
  i = 0;
 40e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 410:	00000817          	auipc	a6,0x0
 414:	4e080813          	addi	a6,a6,1248 # 8f0 <digits>
 418:	88ba                	mv	a7,a4
 41a:	0017051b          	addiw	a0,a4,1
 41e:	872a                	mv	a4,a0
 420:	02c5f7bb          	remuw	a5,a1,a2
 424:	1782                	slli	a5,a5,0x20
 426:	9381                	srli	a5,a5,0x20
 428:	97c2                	add	a5,a5,a6
 42a:	0007c783          	lbu	a5,0(a5)
 42e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 432:	87ae                	mv	a5,a1
 434:	02c5d5bb          	divuw	a1,a1,a2
 438:	0685                	addi	a3,a3,1
 43a:	fcc7ffe3          	bgeu	a5,a2,418 <printint+0x2c>
  if(neg)
 43e:	00030c63          	beqz	t1,456 <printint+0x6a>
    buf[i++] = '-';
 442:	fd050793          	addi	a5,a0,-48
 446:	00878533          	add	a0,a5,s0
 44a:	02d00793          	li	a5,45
 44e:	fef50823          	sb	a5,-16(a0)
 452:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 456:	02e05763          	blez	a4,484 <printint+0x98>
 45a:	f426                	sd	s1,40(sp)
 45c:	377d                	addiw	a4,a4,-1
 45e:	00e984b3          	add	s1,s3,a4
 462:	19fd                	addi	s3,s3,-1
 464:	99ba                	add	s3,s3,a4
 466:	1702                	slli	a4,a4,0x20
 468:	9301                	srli	a4,a4,0x20
 46a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 46e:	0004c583          	lbu	a1,0(s1)
 472:	854a                	mv	a0,s2
 474:	00000097          	auipc	ra,0x0
 478:	f56080e7          	jalr	-170(ra) # 3ca <putc>
  while(--i >= 0)
 47c:	14fd                	addi	s1,s1,-1
 47e:	ff3498e3          	bne	s1,s3,46e <printint+0x82>
 482:	74a2                	ld	s1,40(sp)
}
 484:	70e2                	ld	ra,56(sp)
 486:	7442                	ld	s0,48(sp)
 488:	7902                	ld	s2,32(sp)
 48a:	69e2                	ld	s3,24(sp)
 48c:	6121                	addi	sp,sp,64
 48e:	8082                	ret
  neg = 0;
 490:	4301                	li	t1,0
 492:	bf9d                	j	408 <printint+0x1c>

0000000000000494 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 494:	715d                	addi	sp,sp,-80
 496:	e486                	sd	ra,72(sp)
 498:	e0a2                	sd	s0,64(sp)
 49a:	f84a                	sd	s2,48(sp)
 49c:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 49e:	0005c903          	lbu	s2,0(a1)
 4a2:	1a090b63          	beqz	s2,658 <vprintf+0x1c4>
 4a6:	fc26                	sd	s1,56(sp)
 4a8:	f44e                	sd	s3,40(sp)
 4aa:	f052                	sd	s4,32(sp)
 4ac:	ec56                	sd	s5,24(sp)
 4ae:	e85a                	sd	s6,16(sp)
 4b0:	e45e                	sd	s7,8(sp)
 4b2:	8aaa                	mv	s5,a0
 4b4:	8bb2                	mv	s7,a2
 4b6:	00158493          	addi	s1,a1,1
  state = 0;
 4ba:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4bc:	02500a13          	li	s4,37
 4c0:	4b55                	li	s6,21
 4c2:	a839                	j	4e0 <vprintf+0x4c>
        putc(fd, c);
 4c4:	85ca                	mv	a1,s2
 4c6:	8556                	mv	a0,s5
 4c8:	00000097          	auipc	ra,0x0
 4cc:	f02080e7          	jalr	-254(ra) # 3ca <putc>
 4d0:	a019                	j	4d6 <vprintf+0x42>
    } else if(state == '%'){
 4d2:	01498d63          	beq	s3,s4,4ec <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 4d6:	0485                	addi	s1,s1,1
 4d8:	fff4c903          	lbu	s2,-1(s1)
 4dc:	16090863          	beqz	s2,64c <vprintf+0x1b8>
    if(state == 0){
 4e0:	fe0999e3          	bnez	s3,4d2 <vprintf+0x3e>
      if(c == '%'){
 4e4:	ff4910e3          	bne	s2,s4,4c4 <vprintf+0x30>
        state = '%';
 4e8:	89d2                	mv	s3,s4
 4ea:	b7f5                	j	4d6 <vprintf+0x42>
      if(c == 'd'){
 4ec:	13490563          	beq	s2,s4,616 <vprintf+0x182>
 4f0:	f9d9079b          	addiw	a5,s2,-99
 4f4:	0ff7f793          	zext.b	a5,a5
 4f8:	12fb6863          	bltu	s6,a5,628 <vprintf+0x194>
 4fc:	f9d9079b          	addiw	a5,s2,-99
 500:	0ff7f713          	zext.b	a4,a5
 504:	12eb6263          	bltu	s6,a4,628 <vprintf+0x194>
 508:	00271793          	slli	a5,a4,0x2
 50c:	00000717          	auipc	a4,0x0
 510:	38c70713          	addi	a4,a4,908 # 898 <malloc+0x14c>
 514:	97ba                	add	a5,a5,a4
 516:	439c                	lw	a5,0(a5)
 518:	97ba                	add	a5,a5,a4
 51a:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 51c:	008b8913          	addi	s2,s7,8
 520:	4685                	li	a3,1
 522:	4629                	li	a2,10
 524:	000ba583          	lw	a1,0(s7)
 528:	8556                	mv	a0,s5
 52a:	00000097          	auipc	ra,0x0
 52e:	ec2080e7          	jalr	-318(ra) # 3ec <printint>
 532:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 534:	4981                	li	s3,0
 536:	b745                	j	4d6 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 538:	008b8913          	addi	s2,s7,8
 53c:	4681                	li	a3,0
 53e:	4629                	li	a2,10
 540:	000ba583          	lw	a1,0(s7)
 544:	8556                	mv	a0,s5
 546:	00000097          	auipc	ra,0x0
 54a:	ea6080e7          	jalr	-346(ra) # 3ec <printint>
 54e:	8bca                	mv	s7,s2
      state = 0;
 550:	4981                	li	s3,0
 552:	b751                	j	4d6 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 554:	008b8913          	addi	s2,s7,8
 558:	4681                	li	a3,0
 55a:	4641                	li	a2,16
 55c:	000ba583          	lw	a1,0(s7)
 560:	8556                	mv	a0,s5
 562:	00000097          	auipc	ra,0x0
 566:	e8a080e7          	jalr	-374(ra) # 3ec <printint>
 56a:	8bca                	mv	s7,s2
      state = 0;
 56c:	4981                	li	s3,0
 56e:	b7a5                	j	4d6 <vprintf+0x42>
 570:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 572:	008b8793          	addi	a5,s7,8
 576:	8c3e                	mv	s8,a5
 578:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 57c:	03000593          	li	a1,48
 580:	8556                	mv	a0,s5
 582:	00000097          	auipc	ra,0x0
 586:	e48080e7          	jalr	-440(ra) # 3ca <putc>
  putc(fd, 'x');
 58a:	07800593          	li	a1,120
 58e:	8556                	mv	a0,s5
 590:	00000097          	auipc	ra,0x0
 594:	e3a080e7          	jalr	-454(ra) # 3ca <putc>
 598:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 59a:	00000b97          	auipc	s7,0x0
 59e:	356b8b93          	addi	s7,s7,854 # 8f0 <digits>
 5a2:	03c9d793          	srli	a5,s3,0x3c
 5a6:	97de                	add	a5,a5,s7
 5a8:	0007c583          	lbu	a1,0(a5)
 5ac:	8556                	mv	a0,s5
 5ae:	00000097          	auipc	ra,0x0
 5b2:	e1c080e7          	jalr	-484(ra) # 3ca <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5b6:	0992                	slli	s3,s3,0x4
 5b8:	397d                	addiw	s2,s2,-1
 5ba:	fe0914e3          	bnez	s2,5a2 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
 5be:	8be2                	mv	s7,s8
      state = 0;
 5c0:	4981                	li	s3,0
 5c2:	6c02                	ld	s8,0(sp)
 5c4:	bf09                	j	4d6 <vprintf+0x42>
        s = va_arg(ap, char*);
 5c6:	008b8993          	addi	s3,s7,8
 5ca:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5ce:	02090163          	beqz	s2,5f0 <vprintf+0x15c>
        while(*s != 0){
 5d2:	00094583          	lbu	a1,0(s2)
 5d6:	c9a5                	beqz	a1,646 <vprintf+0x1b2>
          putc(fd, *s);
 5d8:	8556                	mv	a0,s5
 5da:	00000097          	auipc	ra,0x0
 5de:	df0080e7          	jalr	-528(ra) # 3ca <putc>
          s++;
 5e2:	0905                	addi	s2,s2,1
        while(*s != 0){
 5e4:	00094583          	lbu	a1,0(s2)
 5e8:	f9e5                	bnez	a1,5d8 <vprintf+0x144>
        s = va_arg(ap, char*);
 5ea:	8bce                	mv	s7,s3
      state = 0;
 5ec:	4981                	li	s3,0
 5ee:	b5e5                	j	4d6 <vprintf+0x42>
          s = "(null)";
 5f0:	00000917          	auipc	s2,0x0
 5f4:	2a090913          	addi	s2,s2,672 # 890 <malloc+0x144>
        while(*s != 0){
 5f8:	02800593          	li	a1,40
 5fc:	bff1                	j	5d8 <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
 5fe:	008b8913          	addi	s2,s7,8
 602:	000bc583          	lbu	a1,0(s7)
 606:	8556                	mv	a0,s5
 608:	00000097          	auipc	ra,0x0
 60c:	dc2080e7          	jalr	-574(ra) # 3ca <putc>
 610:	8bca                	mv	s7,s2
      state = 0;
 612:	4981                	li	s3,0
 614:	b5c9                	j	4d6 <vprintf+0x42>
        putc(fd, c);
 616:	02500593          	li	a1,37
 61a:	8556                	mv	a0,s5
 61c:	00000097          	auipc	ra,0x0
 620:	dae080e7          	jalr	-594(ra) # 3ca <putc>
      state = 0;
 624:	4981                	li	s3,0
 626:	bd45                	j	4d6 <vprintf+0x42>
        putc(fd, '%');
 628:	02500593          	li	a1,37
 62c:	8556                	mv	a0,s5
 62e:	00000097          	auipc	ra,0x0
 632:	d9c080e7          	jalr	-612(ra) # 3ca <putc>
        putc(fd, c);
 636:	85ca                	mv	a1,s2
 638:	8556                	mv	a0,s5
 63a:	00000097          	auipc	ra,0x0
 63e:	d90080e7          	jalr	-624(ra) # 3ca <putc>
      state = 0;
 642:	4981                	li	s3,0
 644:	bd49                	j	4d6 <vprintf+0x42>
        s = va_arg(ap, char*);
 646:	8bce                	mv	s7,s3
      state = 0;
 648:	4981                	li	s3,0
 64a:	b571                	j	4d6 <vprintf+0x42>
 64c:	74e2                	ld	s1,56(sp)
 64e:	79a2                	ld	s3,40(sp)
 650:	7a02                	ld	s4,32(sp)
 652:	6ae2                	ld	s5,24(sp)
 654:	6b42                	ld	s6,16(sp)
 656:	6ba2                	ld	s7,8(sp)
    }
  }
}
 658:	60a6                	ld	ra,72(sp)
 65a:	6406                	ld	s0,64(sp)
 65c:	7942                	ld	s2,48(sp)
 65e:	6161                	addi	sp,sp,80
 660:	8082                	ret

0000000000000662 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 662:	715d                	addi	sp,sp,-80
 664:	ec06                	sd	ra,24(sp)
 666:	e822                	sd	s0,16(sp)
 668:	1000                	addi	s0,sp,32
 66a:	e010                	sd	a2,0(s0)
 66c:	e414                	sd	a3,8(s0)
 66e:	e818                	sd	a4,16(s0)
 670:	ec1c                	sd	a5,24(s0)
 672:	03043023          	sd	a6,32(s0)
 676:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 67a:	8622                	mv	a2,s0
 67c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 680:	00000097          	auipc	ra,0x0
 684:	e14080e7          	jalr	-492(ra) # 494 <vprintf>
}
 688:	60e2                	ld	ra,24(sp)
 68a:	6442                	ld	s0,16(sp)
 68c:	6161                	addi	sp,sp,80
 68e:	8082                	ret

0000000000000690 <printf>:

void
printf(const char *fmt, ...)
{
 690:	711d                	addi	sp,sp,-96
 692:	ec06                	sd	ra,24(sp)
 694:	e822                	sd	s0,16(sp)
 696:	1000                	addi	s0,sp,32
 698:	e40c                	sd	a1,8(s0)
 69a:	e810                	sd	a2,16(s0)
 69c:	ec14                	sd	a3,24(s0)
 69e:	f018                	sd	a4,32(s0)
 6a0:	f41c                	sd	a5,40(s0)
 6a2:	03043823          	sd	a6,48(s0)
 6a6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6aa:	00840613          	addi	a2,s0,8
 6ae:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6b2:	85aa                	mv	a1,a0
 6b4:	4505                	li	a0,1
 6b6:	00000097          	auipc	ra,0x0
 6ba:	dde080e7          	jalr	-546(ra) # 494 <vprintf>
}
 6be:	60e2                	ld	ra,24(sp)
 6c0:	6442                	ld	s0,16(sp)
 6c2:	6125                	addi	sp,sp,96
 6c4:	8082                	ret

00000000000006c6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6c6:	1141                	addi	sp,sp,-16
 6c8:	e406                	sd	ra,8(sp)
 6ca:	e022                	sd	s0,0(sp)
 6cc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6ce:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6d2:	00000797          	auipc	a5,0x0
 6d6:	6467b783          	ld	a5,1606(a5) # d18 <freep>
 6da:	a039                	j	6e8 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6dc:	6398                	ld	a4,0(a5)
 6de:	00e7e463          	bltu	a5,a4,6e6 <free+0x20>
 6e2:	00e6ea63          	bltu	a3,a4,6f6 <free+0x30>
{
 6e6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e8:	fed7fae3          	bgeu	a5,a3,6dc <free+0x16>
 6ec:	6398                	ld	a4,0(a5)
 6ee:	00e6e463          	bltu	a3,a4,6f6 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6f2:	fee7eae3          	bltu	a5,a4,6e6 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6f6:	ff852583          	lw	a1,-8(a0)
 6fa:	6390                	ld	a2,0(a5)
 6fc:	02059813          	slli	a6,a1,0x20
 700:	01c85713          	srli	a4,a6,0x1c
 704:	9736                	add	a4,a4,a3
 706:	02e60563          	beq	a2,a4,730 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 70a:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 70e:	4790                	lw	a2,8(a5)
 710:	02061593          	slli	a1,a2,0x20
 714:	01c5d713          	srli	a4,a1,0x1c
 718:	973e                	add	a4,a4,a5
 71a:	02e68263          	beq	a3,a4,73e <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 71e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 720:	00000717          	auipc	a4,0x0
 724:	5ef73c23          	sd	a5,1528(a4) # d18 <freep>
}
 728:	60a2                	ld	ra,8(sp)
 72a:	6402                	ld	s0,0(sp)
 72c:	0141                	addi	sp,sp,16
 72e:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 730:	4618                	lw	a4,8(a2)
 732:	9f2d                	addw	a4,a4,a1
 734:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 738:	6398                	ld	a4,0(a5)
 73a:	6310                	ld	a2,0(a4)
 73c:	b7f9                	j	70a <free+0x44>
    p->s.size += bp->s.size;
 73e:	ff852703          	lw	a4,-8(a0)
 742:	9f31                	addw	a4,a4,a2
 744:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 746:	ff053683          	ld	a3,-16(a0)
 74a:	bfd1                	j	71e <free+0x58>

000000000000074c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 74c:	7139                	addi	sp,sp,-64
 74e:	fc06                	sd	ra,56(sp)
 750:	f822                	sd	s0,48(sp)
 752:	f04a                	sd	s2,32(sp)
 754:	ec4e                	sd	s3,24(sp)
 756:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 758:	02051993          	slli	s3,a0,0x20
 75c:	0209d993          	srli	s3,s3,0x20
 760:	09bd                	addi	s3,s3,15
 762:	0049d993          	srli	s3,s3,0x4
 766:	2985                	addiw	s3,s3,1
 768:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 76a:	00000517          	auipc	a0,0x0
 76e:	5ae53503          	ld	a0,1454(a0) # d18 <freep>
 772:	c905                	beqz	a0,7a2 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 774:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 776:	4798                	lw	a4,8(a5)
 778:	09377a63          	bgeu	a4,s3,80c <malloc+0xc0>
 77c:	f426                	sd	s1,40(sp)
 77e:	e852                	sd	s4,16(sp)
 780:	e456                	sd	s5,8(sp)
 782:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 784:	8a4e                	mv	s4,s3
 786:	6705                	lui	a4,0x1
 788:	00e9f363          	bgeu	s3,a4,78e <malloc+0x42>
 78c:	6a05                	lui	s4,0x1
 78e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 792:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 796:	00000497          	auipc	s1,0x0
 79a:	58248493          	addi	s1,s1,1410 # d18 <freep>
  if(p == (char*)-1)
 79e:	5afd                	li	s5,-1
 7a0:	a089                	j	7e2 <malloc+0x96>
 7a2:	f426                	sd	s1,40(sp)
 7a4:	e852                	sd	s4,16(sp)
 7a6:	e456                	sd	s5,8(sp)
 7a8:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7aa:	00000797          	auipc	a5,0x0
 7ae:	57678793          	addi	a5,a5,1398 # d20 <base>
 7b2:	00000717          	auipc	a4,0x0
 7b6:	56f73323          	sd	a5,1382(a4) # d18 <freep>
 7ba:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7bc:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7c0:	b7d1                	j	784 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 7c2:	6398                	ld	a4,0(a5)
 7c4:	e118                	sd	a4,0(a0)
 7c6:	a8b9                	j	824 <malloc+0xd8>
  hp->s.size = nu;
 7c8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7cc:	0541                	addi	a0,a0,16
 7ce:	00000097          	auipc	ra,0x0
 7d2:	ef8080e7          	jalr	-264(ra) # 6c6 <free>
  return freep;
 7d6:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 7d8:	c135                	beqz	a0,83c <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7da:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7dc:	4798                	lw	a4,8(a5)
 7de:	03277363          	bgeu	a4,s2,804 <malloc+0xb8>
    if(p == freep)
 7e2:	6098                	ld	a4,0(s1)
 7e4:	853e                	mv	a0,a5
 7e6:	fef71ae3          	bne	a4,a5,7da <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 7ea:	8552                	mv	a0,s4
 7ec:	00000097          	auipc	ra,0x0
 7f0:	bae080e7          	jalr	-1106(ra) # 39a <sbrk>
  if(p == (char*)-1)
 7f4:	fd551ae3          	bne	a0,s5,7c8 <malloc+0x7c>
        return 0;
 7f8:	4501                	li	a0,0
 7fa:	74a2                	ld	s1,40(sp)
 7fc:	6a42                	ld	s4,16(sp)
 7fe:	6aa2                	ld	s5,8(sp)
 800:	6b02                	ld	s6,0(sp)
 802:	a03d                	j	830 <malloc+0xe4>
 804:	74a2                	ld	s1,40(sp)
 806:	6a42                	ld	s4,16(sp)
 808:	6aa2                	ld	s5,8(sp)
 80a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 80c:	fae90be3          	beq	s2,a4,7c2 <malloc+0x76>
        p->s.size -= nunits;
 810:	4137073b          	subw	a4,a4,s3
 814:	c798                	sw	a4,8(a5)
        p += p->s.size;
 816:	02071693          	slli	a3,a4,0x20
 81a:	01c6d713          	srli	a4,a3,0x1c
 81e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 820:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 824:	00000717          	auipc	a4,0x0
 828:	4ea73a23          	sd	a0,1268(a4) # d18 <freep>
      return (void*)(p + 1);
 82c:	01078513          	addi	a0,a5,16
  }
}
 830:	70e2                	ld	ra,56(sp)
 832:	7442                	ld	s0,48(sp)
 834:	7902                	ld	s2,32(sp)
 836:	69e2                	ld	s3,24(sp)
 838:	6121                	addi	sp,sp,64
 83a:	8082                	ret
 83c:	74a2                	ld	s1,40(sp)
 83e:	6a42                	ld	s4,16(sp)
 840:	6aa2                	ld	s5,8(sp)
 842:	6b02                	ld	s6,0(sp)
 844:	b7f5                	j	830 <malloc+0xe4>
