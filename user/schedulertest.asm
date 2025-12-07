
user/_schedulertest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#define NFORK 10

// Numero de procesos que se comportaran como IO-bound
#define IO 5

int main() {
   0:	715d                	addi	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	fc26                	sd	s1,56(sp)
   8:	f84a                	sd	s2,48(sp)
   a:	f44e                	sd	s3,40(sp)
   c:	f052                	sd	s4,32(sp)
   e:	ec56                	sd	s5,24(sp)
  10:	0880                	addi	s0,sp,80
  int n, pid;
  int wtime, rtime;        // variables para recibir tiempos de wait y run de waitx()
  int twtime = 0, trtime = 0;  // acumuladores para promedios

  // Bucle principal donde se crean los procesos hijos
  for(n = 0; n < NFORK; n++) {
  12:	4481                	li	s1,0
  14:	4929                	li	s2,10

      // Crear proceso hijo
      pid = fork();
  16:	00000097          	auipc	ra,0x0
  1a:	372080e7          	jalr	882(ra) # 388 <fork>

      // Error al crear proceso
      if (pid < 0)
  1e:	00054d63          	bltz	a0,38 <main+0x38>
          break;

      // ------------------------------------------------------------------
      // CODIGO DEL HIJO
      if (pid == 0) {
  22:	cd31                	beqz	a0,7e <main+0x7e>
  for(n = 0; n < NFORK; n++) {
  24:	2485                	addiw	s1,s1,1
  26:	ff2498e3          	bne	s1,s2,16 <main+0x16>
  2a:	4901                	li	s2,0
  2c:	4981                	li	s3,0

  // Bucle donde el padre espera a todos los hijos y acumula estadisticas
  for(; n > 0; n--) {

      // waitx recibe los tiempos de ejecucion y espera de cada hijo
      if(waitx(0, &rtime, &wtime) >= 0) {
  2e:	fbc40a93          	addi	s5,s0,-68
  32:	fb840a13          	addi	s4,s0,-72
  36:	a065                	j	de <main+0xde>
  for(; n > 0; n--) {
  38:	fe9049e3          	bgtz	s1,2a <main+0x2a>
  3c:	4901                	li	s2,0
  3e:	4981                	li	s3,0
          trtime += rtime;   // acumula tiempo de CPU
          twtime += wtime;   // acumula tiempo de espera
      }
  }
  // Impresion de promedios finales
  printf("Average rtime %d,  wtime %d\n", trtime / NFORK, twtime / NFORK);
  40:	666665b7          	lui	a1,0x66666
  44:	66758593          	addi	a1,a1,1639 # 66666667 <__global_pointer$+0x6666510b>
  48:	02b98633          	mul	a2,s3,a1
  4c:	9609                	srai	a2,a2,0x22
  4e:	41f9d99b          	sraiw	s3,s3,0x1f
  52:	02b905b3          	mul	a1,s2,a1
  56:	9589                	srai	a1,a1,0x22
  58:	41f9591b          	sraiw	s2,s2,0x1f
  5c:	4136063b          	subw	a2,a2,s3
  60:	412585bb          	subw	a1,a1,s2
  64:	00001517          	auipc	a0,0x1
  68:	87c50513          	addi	a0,a0,-1924 # 8e0 <malloc+0x116>
  6c:	00000097          	auipc	ra,0x0
  70:	6a2080e7          	jalr	1698(ra) # 70e <printf>

  exit(0);
  74:	4501                	li	a0,0
  76:	00000097          	auipc	ra,0x0
  7a:	31a080e7          	jalr	794(ra) # 390 <exit>
          if (n < IO) {
  7e:	4791                	li	a5,4
  80:	0497d663          	bge	a5,s1,cc <main+0xcc>
            for (volatile int i = 0; i < 1000000000; i++) {}
  84:	fa042a23          	sw	zero,-76(s0)
  88:	fb442703          	lw	a4,-76(s0)
  8c:	2701                	sext.w	a4,a4
  8e:	3b9ad7b7          	lui	a5,0x3b9ad
  92:	9ff78793          	addi	a5,a5,-1537 # 3b9ac9ff <__global_pointer$+0x3b9ab4a3>
  96:	00e7cd63          	blt	a5,a4,b0 <main+0xb0>
  9a:	873e                	mv	a4,a5
  9c:	fb442783          	lw	a5,-76(s0)
  a0:	2785                	addiw	a5,a5,1
  a2:	faf42a23          	sw	a5,-76(s0)
  a6:	fb442783          	lw	a5,-76(s0)
  aa:	2781                	sext.w	a5,a5
  ac:	fef758e3          	bge	a4,a5,9c <main+0x9c>
          printf("Process %d finished\n", n);
  b0:	85a6                	mv	a1,s1
  b2:	00001517          	auipc	a0,0x1
  b6:	81650513          	addi	a0,a0,-2026 # 8c8 <malloc+0xfe>
  ba:	00000097          	auipc	ra,0x0
  be:	654080e7          	jalr	1620(ra) # 70e <printf>
          exit(0);
  c2:	4501                	li	a0,0
  c4:	00000097          	auipc	ra,0x0
  c8:	2cc080e7          	jalr	716(ra) # 390 <exit>
            sleep(200);
  cc:	0c800513          	li	a0,200
  d0:	00000097          	auipc	ra,0x0
  d4:	350080e7          	jalr	848(ra) # 420 <sleep>
  d8:	bfe1                	j	b0 <main+0xb0>
  for(; n > 0; n--) {
  da:	34fd                	addiw	s1,s1,-1
  dc:	d0b5                	beqz	s1,40 <main+0x40>
      if(waitx(0, &rtime, &wtime) >= 0) {
  de:	8656                	mv	a2,s5
  e0:	85d2                	mv	a1,s4
  e2:	4501                	li	a0,0
  e4:	00000097          	auipc	ra,0x0
  e8:	35c080e7          	jalr	860(ra) # 440 <waitx>
  ec:	fe0547e3          	bltz	a0,da <main+0xda>
          trtime += rtime;   // acumula tiempo de CPU
  f0:	fb842783          	lw	a5,-72(s0)
  f4:	0127893b          	addw	s2,a5,s2
          twtime += wtime;   // acumula tiempo de espera
  f8:	fbc42783          	lw	a5,-68(s0)
  fc:	013789bb          	addw	s3,a5,s3
 100:	bfe9                	j	da <main+0xda>

0000000000000102 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 102:	1141                	addi	sp,sp,-16
 104:	e406                	sd	ra,8(sp)
 106:	e022                	sd	s0,0(sp)
 108:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 10a:	87aa                	mv	a5,a0
 10c:	0585                	addi	a1,a1,1
 10e:	0785                	addi	a5,a5,1
 110:	fff5c703          	lbu	a4,-1(a1)
 114:	fee78fa3          	sb	a4,-1(a5)
 118:	fb75                	bnez	a4,10c <strcpy+0xa>
    ;
  return os;
}
 11a:	60a2                	ld	ra,8(sp)
 11c:	6402                	ld	s0,0(sp)
 11e:	0141                	addi	sp,sp,16
 120:	8082                	ret

0000000000000122 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 122:	1141                	addi	sp,sp,-16
 124:	e406                	sd	ra,8(sp)
 126:	e022                	sd	s0,0(sp)
 128:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 12a:	00054783          	lbu	a5,0(a0)
 12e:	cb91                	beqz	a5,142 <strcmp+0x20>
 130:	0005c703          	lbu	a4,0(a1)
 134:	00f71763          	bne	a4,a5,142 <strcmp+0x20>
    p++, q++;
 138:	0505                	addi	a0,a0,1
 13a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 13c:	00054783          	lbu	a5,0(a0)
 140:	fbe5                	bnez	a5,130 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 142:	0005c503          	lbu	a0,0(a1)
}
 146:	40a7853b          	subw	a0,a5,a0
 14a:	60a2                	ld	ra,8(sp)
 14c:	6402                	ld	s0,0(sp)
 14e:	0141                	addi	sp,sp,16
 150:	8082                	ret

0000000000000152 <strlen>:

uint
strlen(const char *s)
{
 152:	1141                	addi	sp,sp,-16
 154:	e406                	sd	ra,8(sp)
 156:	e022                	sd	s0,0(sp)
 158:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 15a:	00054783          	lbu	a5,0(a0)
 15e:	cf91                	beqz	a5,17a <strlen+0x28>
 160:	00150793          	addi	a5,a0,1
 164:	86be                	mv	a3,a5
 166:	0785                	addi	a5,a5,1
 168:	fff7c703          	lbu	a4,-1(a5)
 16c:	ff65                	bnez	a4,164 <strlen+0x12>
 16e:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 172:	60a2                	ld	ra,8(sp)
 174:	6402                	ld	s0,0(sp)
 176:	0141                	addi	sp,sp,16
 178:	8082                	ret
  for(n = 0; s[n]; n++)
 17a:	4501                	li	a0,0
 17c:	bfdd                	j	172 <strlen+0x20>

000000000000017e <memset>:

void*
memset(void *dst, int c, uint n)
{
 17e:	1141                	addi	sp,sp,-16
 180:	e406                	sd	ra,8(sp)
 182:	e022                	sd	s0,0(sp)
 184:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 186:	ca19                	beqz	a2,19c <memset+0x1e>
 188:	87aa                	mv	a5,a0
 18a:	1602                	slli	a2,a2,0x20
 18c:	9201                	srli	a2,a2,0x20
 18e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 192:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 196:	0785                	addi	a5,a5,1
 198:	fee79de3          	bne	a5,a4,192 <memset+0x14>
  }
  return dst;
}
 19c:	60a2                	ld	ra,8(sp)
 19e:	6402                	ld	s0,0(sp)
 1a0:	0141                	addi	sp,sp,16
 1a2:	8082                	ret

00000000000001a4 <strchr>:

char*
strchr(const char *s, char c)
{
 1a4:	1141                	addi	sp,sp,-16
 1a6:	e406                	sd	ra,8(sp)
 1a8:	e022                	sd	s0,0(sp)
 1aa:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1ac:	00054783          	lbu	a5,0(a0)
 1b0:	cf81                	beqz	a5,1c8 <strchr+0x24>
    if(*s == c)
 1b2:	00f58763          	beq	a1,a5,1c0 <strchr+0x1c>
  for(; *s; s++)
 1b6:	0505                	addi	a0,a0,1
 1b8:	00054783          	lbu	a5,0(a0)
 1bc:	fbfd                	bnez	a5,1b2 <strchr+0xe>
      return (char*)s;
  return 0;
 1be:	4501                	li	a0,0
}
 1c0:	60a2                	ld	ra,8(sp)
 1c2:	6402                	ld	s0,0(sp)
 1c4:	0141                	addi	sp,sp,16
 1c6:	8082                	ret
  return 0;
 1c8:	4501                	li	a0,0
 1ca:	bfdd                	j	1c0 <strchr+0x1c>

00000000000001cc <gets>:

char*
gets(char *buf, int max)
{
 1cc:	711d                	addi	sp,sp,-96
 1ce:	ec86                	sd	ra,88(sp)
 1d0:	e8a2                	sd	s0,80(sp)
 1d2:	e4a6                	sd	s1,72(sp)
 1d4:	e0ca                	sd	s2,64(sp)
 1d6:	fc4e                	sd	s3,56(sp)
 1d8:	f852                	sd	s4,48(sp)
 1da:	f456                	sd	s5,40(sp)
 1dc:	f05a                	sd	s6,32(sp)
 1de:	ec5e                	sd	s7,24(sp)
 1e0:	e862                	sd	s8,16(sp)
 1e2:	1080                	addi	s0,sp,96
 1e4:	8baa                	mv	s7,a0
 1e6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e8:	892a                	mv	s2,a0
 1ea:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1ec:	faf40b13          	addi	s6,s0,-81
 1f0:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 1f2:	8c26                	mv	s8,s1
 1f4:	0014899b          	addiw	s3,s1,1
 1f8:	84ce                	mv	s1,s3
 1fa:	0349d663          	bge	s3,s4,226 <gets+0x5a>
    cc = read(0, &c, 1);
 1fe:	8656                	mv	a2,s5
 200:	85da                	mv	a1,s6
 202:	4501                	li	a0,0
 204:	00000097          	auipc	ra,0x0
 208:	1a4080e7          	jalr	420(ra) # 3a8 <read>
    if(cc < 1)
 20c:	00a05d63          	blez	a0,226 <gets+0x5a>
      break;
    buf[i++] = c;
 210:	faf44783          	lbu	a5,-81(s0)
 214:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 218:	0905                	addi	s2,s2,1
 21a:	ff678713          	addi	a4,a5,-10
 21e:	c319                	beqz	a4,224 <gets+0x58>
 220:	17cd                	addi	a5,a5,-13
 222:	fbe1                	bnez	a5,1f2 <gets+0x26>
    buf[i++] = c;
 224:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 226:	9c5e                	add	s8,s8,s7
 228:	000c0023          	sb	zero,0(s8)
  return buf;
}
 22c:	855e                	mv	a0,s7
 22e:	60e6                	ld	ra,88(sp)
 230:	6446                	ld	s0,80(sp)
 232:	64a6                	ld	s1,72(sp)
 234:	6906                	ld	s2,64(sp)
 236:	79e2                	ld	s3,56(sp)
 238:	7a42                	ld	s4,48(sp)
 23a:	7aa2                	ld	s5,40(sp)
 23c:	7b02                	ld	s6,32(sp)
 23e:	6be2                	ld	s7,24(sp)
 240:	6c42                	ld	s8,16(sp)
 242:	6125                	addi	sp,sp,96
 244:	8082                	ret

0000000000000246 <stat>:

int
stat(const char *n, struct stat *st)
{
 246:	1101                	addi	sp,sp,-32
 248:	ec06                	sd	ra,24(sp)
 24a:	e822                	sd	s0,16(sp)
 24c:	e04a                	sd	s2,0(sp)
 24e:	1000                	addi	s0,sp,32
 250:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 252:	4581                	li	a1,0
 254:	00000097          	auipc	ra,0x0
 258:	17c080e7          	jalr	380(ra) # 3d0 <open>
  if(fd < 0)
 25c:	02054663          	bltz	a0,288 <stat+0x42>
 260:	e426                	sd	s1,8(sp)
 262:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 264:	85ca                	mv	a1,s2
 266:	00000097          	auipc	ra,0x0
 26a:	182080e7          	jalr	386(ra) # 3e8 <fstat>
 26e:	892a                	mv	s2,a0
  close(fd);
 270:	8526                	mv	a0,s1
 272:	00000097          	auipc	ra,0x0
 276:	146080e7          	jalr	326(ra) # 3b8 <close>
  return r;
 27a:	64a2                	ld	s1,8(sp)
}
 27c:	854a                	mv	a0,s2
 27e:	60e2                	ld	ra,24(sp)
 280:	6442                	ld	s0,16(sp)
 282:	6902                	ld	s2,0(sp)
 284:	6105                	addi	sp,sp,32
 286:	8082                	ret
    return -1;
 288:	57fd                	li	a5,-1
 28a:	893e                	mv	s2,a5
 28c:	bfc5                	j	27c <stat+0x36>

000000000000028e <atoi>:

int
atoi(const char *s)
{
 28e:	1141                	addi	sp,sp,-16
 290:	e406                	sd	ra,8(sp)
 292:	e022                	sd	s0,0(sp)
 294:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 296:	00054683          	lbu	a3,0(a0)
 29a:	fd06879b          	addiw	a5,a3,-48
 29e:	0ff7f793          	zext.b	a5,a5
 2a2:	4625                	li	a2,9
 2a4:	02f66963          	bltu	a2,a5,2d6 <atoi+0x48>
 2a8:	872a                	mv	a4,a0
  n = 0;
 2aa:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2ac:	0705                	addi	a4,a4,1
 2ae:	0025179b          	slliw	a5,a0,0x2
 2b2:	9fa9                	addw	a5,a5,a0
 2b4:	0017979b          	slliw	a5,a5,0x1
 2b8:	9fb5                	addw	a5,a5,a3
 2ba:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2be:	00074683          	lbu	a3,0(a4)
 2c2:	fd06879b          	addiw	a5,a3,-48
 2c6:	0ff7f793          	zext.b	a5,a5
 2ca:	fef671e3          	bgeu	a2,a5,2ac <atoi+0x1e>
  return n;
}
 2ce:	60a2                	ld	ra,8(sp)
 2d0:	6402                	ld	s0,0(sp)
 2d2:	0141                	addi	sp,sp,16
 2d4:	8082                	ret
  n = 0;
 2d6:	4501                	li	a0,0
 2d8:	bfdd                	j	2ce <atoi+0x40>

00000000000002da <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2da:	1141                	addi	sp,sp,-16
 2dc:	e406                	sd	ra,8(sp)
 2de:	e022                	sd	s0,0(sp)
 2e0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2e2:	02b57563          	bgeu	a0,a1,30c <memmove+0x32>
    while(n-- > 0)
 2e6:	00c05f63          	blez	a2,304 <memmove+0x2a>
 2ea:	1602                	slli	a2,a2,0x20
 2ec:	9201                	srli	a2,a2,0x20
 2ee:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2f2:	872a                	mv	a4,a0
      *dst++ = *src++;
 2f4:	0585                	addi	a1,a1,1
 2f6:	0705                	addi	a4,a4,1
 2f8:	fff5c683          	lbu	a3,-1(a1)
 2fc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 300:	fee79ae3          	bne	a5,a4,2f4 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 304:	60a2                	ld	ra,8(sp)
 306:	6402                	ld	s0,0(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret
    while(n-- > 0)
 30c:	fec05ce3          	blez	a2,304 <memmove+0x2a>
    dst += n;
 310:	00c50733          	add	a4,a0,a2
    src += n;
 314:	95b2                	add	a1,a1,a2
 316:	fff6079b          	addiw	a5,a2,-1
 31a:	1782                	slli	a5,a5,0x20
 31c:	9381                	srli	a5,a5,0x20
 31e:	fff7c793          	not	a5,a5
 322:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 324:	15fd                	addi	a1,a1,-1
 326:	177d                	addi	a4,a4,-1
 328:	0005c683          	lbu	a3,0(a1)
 32c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 330:	fef71ae3          	bne	a4,a5,324 <memmove+0x4a>
 334:	bfc1                	j	304 <memmove+0x2a>

0000000000000336 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 336:	1141                	addi	sp,sp,-16
 338:	e406                	sd	ra,8(sp)
 33a:	e022                	sd	s0,0(sp)
 33c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 33e:	c61d                	beqz	a2,36c <memcmp+0x36>
 340:	1602                	slli	a2,a2,0x20
 342:	9201                	srli	a2,a2,0x20
 344:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 348:	00054783          	lbu	a5,0(a0)
 34c:	0005c703          	lbu	a4,0(a1)
 350:	00e79863          	bne	a5,a4,360 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 354:	0505                	addi	a0,a0,1
    p2++;
 356:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 358:	fed518e3          	bne	a0,a3,348 <memcmp+0x12>
  }
  return 0;
 35c:	4501                	li	a0,0
 35e:	a019                	j	364 <memcmp+0x2e>
      return *p1 - *p2;
 360:	40e7853b          	subw	a0,a5,a4
}
 364:	60a2                	ld	ra,8(sp)
 366:	6402                	ld	s0,0(sp)
 368:	0141                	addi	sp,sp,16
 36a:	8082                	ret
  return 0;
 36c:	4501                	li	a0,0
 36e:	bfdd                	j	364 <memcmp+0x2e>

0000000000000370 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 370:	1141                	addi	sp,sp,-16
 372:	e406                	sd	ra,8(sp)
 374:	e022                	sd	s0,0(sp)
 376:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 378:	00000097          	auipc	ra,0x0
 37c:	f62080e7          	jalr	-158(ra) # 2da <memmove>
}
 380:	60a2                	ld	ra,8(sp)
 382:	6402                	ld	s0,0(sp)
 384:	0141                	addi	sp,sp,16
 386:	8082                	ret

0000000000000388 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 388:	4885                	li	a7,1
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <exit>:
.global exit
exit:
 li a7, SYS_exit
 390:	4889                	li	a7,2
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <wait>:
.global wait
wait:
 li a7, SYS_wait
 398:	488d                	li	a7,3
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3a0:	4891                	li	a7,4
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <read>:
.global read
read:
 li a7, SYS_read
 3a8:	4895                	li	a7,5
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <write>:
.global write
write:
 li a7, SYS_write
 3b0:	48c1                	li	a7,16
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <close>:
.global close
close:
 li a7, SYS_close
 3b8:	48d5                	li	a7,21
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3c0:	4899                	li	a7,6
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3c8:	489d                	li	a7,7
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <open>:
.global open
open:
 li a7, SYS_open
 3d0:	48bd                	li	a7,15
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3d8:	48c5                	li	a7,17
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3e0:	48c9                	li	a7,18
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3e8:	48a1                	li	a7,8
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <link>:
.global link
link:
 li a7, SYS_link
 3f0:	48cd                	li	a7,19
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3f8:	48d1                	li	a7,20
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 400:	48a5                	li	a7,9
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <dup>:
.global dup
dup:
 li a7, SYS_dup
 408:	48a9                	li	a7,10
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 410:	48ad                	li	a7,11
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 418:	48b1                	li	a7,12
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 420:	48b5                	li	a7,13
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 428:	48b9                	li	a7,14
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <trace>:
.global trace
trace:
 li a7, SYS_trace
 430:	48d9                	li	a7,22
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 438:	48dd                	li	a7,23
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 440:	48e1                	li	a7,24
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 448:	1101                	addi	sp,sp,-32
 44a:	ec06                	sd	ra,24(sp)
 44c:	e822                	sd	s0,16(sp)
 44e:	1000                	addi	s0,sp,32
 450:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 454:	4605                	li	a2,1
 456:	fef40593          	addi	a1,s0,-17
 45a:	00000097          	auipc	ra,0x0
 45e:	f56080e7          	jalr	-170(ra) # 3b0 <write>
}
 462:	60e2                	ld	ra,24(sp)
 464:	6442                	ld	s0,16(sp)
 466:	6105                	addi	sp,sp,32
 468:	8082                	ret

000000000000046a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 46a:	7139                	addi	sp,sp,-64
 46c:	fc06                	sd	ra,56(sp)
 46e:	f822                	sd	s0,48(sp)
 470:	f04a                	sd	s2,32(sp)
 472:	ec4e                	sd	s3,24(sp)
 474:	0080                	addi	s0,sp,64
 476:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 478:	cad9                	beqz	a3,50e <printint+0xa4>
 47a:	01f5d79b          	srliw	a5,a1,0x1f
 47e:	cbc1                	beqz	a5,50e <printint+0xa4>
    neg = 1;
    x = -xx;
 480:	40b005bb          	negw	a1,a1
    neg = 1;
 484:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 486:	fc040993          	addi	s3,s0,-64
  neg = 0;
 48a:	86ce                	mv	a3,s3
  i = 0;
 48c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 48e:	00000817          	auipc	a6,0x0
 492:	4d280813          	addi	a6,a6,1234 # 960 <digits>
 496:	88ba                	mv	a7,a4
 498:	0017051b          	addiw	a0,a4,1
 49c:	872a                	mv	a4,a0
 49e:	02c5f7bb          	remuw	a5,a1,a2
 4a2:	1782                	slli	a5,a5,0x20
 4a4:	9381                	srli	a5,a5,0x20
 4a6:	97c2                	add	a5,a5,a6
 4a8:	0007c783          	lbu	a5,0(a5)
 4ac:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4b0:	87ae                	mv	a5,a1
 4b2:	02c5d5bb          	divuw	a1,a1,a2
 4b6:	0685                	addi	a3,a3,1
 4b8:	fcc7ffe3          	bgeu	a5,a2,496 <printint+0x2c>
  if(neg)
 4bc:	00030c63          	beqz	t1,4d4 <printint+0x6a>
    buf[i++] = '-';
 4c0:	fd050793          	addi	a5,a0,-48
 4c4:	00878533          	add	a0,a5,s0
 4c8:	02d00793          	li	a5,45
 4cc:	fef50823          	sb	a5,-16(a0)
 4d0:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 4d4:	02e05763          	blez	a4,502 <printint+0x98>
 4d8:	f426                	sd	s1,40(sp)
 4da:	377d                	addiw	a4,a4,-1
 4dc:	00e984b3          	add	s1,s3,a4
 4e0:	19fd                	addi	s3,s3,-1
 4e2:	99ba                	add	s3,s3,a4
 4e4:	1702                	slli	a4,a4,0x20
 4e6:	9301                	srli	a4,a4,0x20
 4e8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4ec:	0004c583          	lbu	a1,0(s1)
 4f0:	854a                	mv	a0,s2
 4f2:	00000097          	auipc	ra,0x0
 4f6:	f56080e7          	jalr	-170(ra) # 448 <putc>
  while(--i >= 0)
 4fa:	14fd                	addi	s1,s1,-1
 4fc:	ff3498e3          	bne	s1,s3,4ec <printint+0x82>
 500:	74a2                	ld	s1,40(sp)
}
 502:	70e2                	ld	ra,56(sp)
 504:	7442                	ld	s0,48(sp)
 506:	7902                	ld	s2,32(sp)
 508:	69e2                	ld	s3,24(sp)
 50a:	6121                	addi	sp,sp,64
 50c:	8082                	ret
  neg = 0;
 50e:	4301                	li	t1,0
 510:	bf9d                	j	486 <printint+0x1c>

0000000000000512 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 512:	715d                	addi	sp,sp,-80
 514:	e486                	sd	ra,72(sp)
 516:	e0a2                	sd	s0,64(sp)
 518:	f84a                	sd	s2,48(sp)
 51a:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 51c:	0005c903          	lbu	s2,0(a1)
 520:	1a090b63          	beqz	s2,6d6 <vprintf+0x1c4>
 524:	fc26                	sd	s1,56(sp)
 526:	f44e                	sd	s3,40(sp)
 528:	f052                	sd	s4,32(sp)
 52a:	ec56                	sd	s5,24(sp)
 52c:	e85a                	sd	s6,16(sp)
 52e:	e45e                	sd	s7,8(sp)
 530:	8aaa                	mv	s5,a0
 532:	8bb2                	mv	s7,a2
 534:	00158493          	addi	s1,a1,1
  state = 0;
 538:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 53a:	02500a13          	li	s4,37
 53e:	4b55                	li	s6,21
 540:	a839                	j	55e <vprintf+0x4c>
        putc(fd, c);
 542:	85ca                	mv	a1,s2
 544:	8556                	mv	a0,s5
 546:	00000097          	auipc	ra,0x0
 54a:	f02080e7          	jalr	-254(ra) # 448 <putc>
 54e:	a019                	j	554 <vprintf+0x42>
    } else if(state == '%'){
 550:	01498d63          	beq	s3,s4,56a <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 554:	0485                	addi	s1,s1,1
 556:	fff4c903          	lbu	s2,-1(s1)
 55a:	16090863          	beqz	s2,6ca <vprintf+0x1b8>
    if(state == 0){
 55e:	fe0999e3          	bnez	s3,550 <vprintf+0x3e>
      if(c == '%'){
 562:	ff4910e3          	bne	s2,s4,542 <vprintf+0x30>
        state = '%';
 566:	89d2                	mv	s3,s4
 568:	b7f5                	j	554 <vprintf+0x42>
      if(c == 'd'){
 56a:	13490563          	beq	s2,s4,694 <vprintf+0x182>
 56e:	f9d9079b          	addiw	a5,s2,-99
 572:	0ff7f793          	zext.b	a5,a5
 576:	12fb6863          	bltu	s6,a5,6a6 <vprintf+0x194>
 57a:	f9d9079b          	addiw	a5,s2,-99
 57e:	0ff7f713          	zext.b	a4,a5
 582:	12eb6263          	bltu	s6,a4,6a6 <vprintf+0x194>
 586:	00271793          	slli	a5,a4,0x2
 58a:	00000717          	auipc	a4,0x0
 58e:	37e70713          	addi	a4,a4,894 # 908 <malloc+0x13e>
 592:	97ba                	add	a5,a5,a4
 594:	439c                	lw	a5,0(a5)
 596:	97ba                	add	a5,a5,a4
 598:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 59a:	008b8913          	addi	s2,s7,8
 59e:	4685                	li	a3,1
 5a0:	4629                	li	a2,10
 5a2:	000ba583          	lw	a1,0(s7)
 5a6:	8556                	mv	a0,s5
 5a8:	00000097          	auipc	ra,0x0
 5ac:	ec2080e7          	jalr	-318(ra) # 46a <printint>
 5b0:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5b2:	4981                	li	s3,0
 5b4:	b745                	j	554 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5b6:	008b8913          	addi	s2,s7,8
 5ba:	4681                	li	a3,0
 5bc:	4629                	li	a2,10
 5be:	000ba583          	lw	a1,0(s7)
 5c2:	8556                	mv	a0,s5
 5c4:	00000097          	auipc	ra,0x0
 5c8:	ea6080e7          	jalr	-346(ra) # 46a <printint>
 5cc:	8bca                	mv	s7,s2
      state = 0;
 5ce:	4981                	li	s3,0
 5d0:	b751                	j	554 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 5d2:	008b8913          	addi	s2,s7,8
 5d6:	4681                	li	a3,0
 5d8:	4641                	li	a2,16
 5da:	000ba583          	lw	a1,0(s7)
 5de:	8556                	mv	a0,s5
 5e0:	00000097          	auipc	ra,0x0
 5e4:	e8a080e7          	jalr	-374(ra) # 46a <printint>
 5e8:	8bca                	mv	s7,s2
      state = 0;
 5ea:	4981                	li	s3,0
 5ec:	b7a5                	j	554 <vprintf+0x42>
 5ee:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 5f0:	008b8793          	addi	a5,s7,8
 5f4:	8c3e                	mv	s8,a5
 5f6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5fa:	03000593          	li	a1,48
 5fe:	8556                	mv	a0,s5
 600:	00000097          	auipc	ra,0x0
 604:	e48080e7          	jalr	-440(ra) # 448 <putc>
  putc(fd, 'x');
 608:	07800593          	li	a1,120
 60c:	8556                	mv	a0,s5
 60e:	00000097          	auipc	ra,0x0
 612:	e3a080e7          	jalr	-454(ra) # 448 <putc>
 616:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 618:	00000b97          	auipc	s7,0x0
 61c:	348b8b93          	addi	s7,s7,840 # 960 <digits>
 620:	03c9d793          	srli	a5,s3,0x3c
 624:	97de                	add	a5,a5,s7
 626:	0007c583          	lbu	a1,0(a5)
 62a:	8556                	mv	a0,s5
 62c:	00000097          	auipc	ra,0x0
 630:	e1c080e7          	jalr	-484(ra) # 448 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 634:	0992                	slli	s3,s3,0x4
 636:	397d                	addiw	s2,s2,-1
 638:	fe0914e3          	bnez	s2,620 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
 63c:	8be2                	mv	s7,s8
      state = 0;
 63e:	4981                	li	s3,0
 640:	6c02                	ld	s8,0(sp)
 642:	bf09                	j	554 <vprintf+0x42>
        s = va_arg(ap, char*);
 644:	008b8993          	addi	s3,s7,8
 648:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 64c:	02090163          	beqz	s2,66e <vprintf+0x15c>
        while(*s != 0){
 650:	00094583          	lbu	a1,0(s2)
 654:	c9a5                	beqz	a1,6c4 <vprintf+0x1b2>
          putc(fd, *s);
 656:	8556                	mv	a0,s5
 658:	00000097          	auipc	ra,0x0
 65c:	df0080e7          	jalr	-528(ra) # 448 <putc>
          s++;
 660:	0905                	addi	s2,s2,1
        while(*s != 0){
 662:	00094583          	lbu	a1,0(s2)
 666:	f9e5                	bnez	a1,656 <vprintf+0x144>
        s = va_arg(ap, char*);
 668:	8bce                	mv	s7,s3
      state = 0;
 66a:	4981                	li	s3,0
 66c:	b5e5                	j	554 <vprintf+0x42>
          s = "(null)";
 66e:	00000917          	auipc	s2,0x0
 672:	29290913          	addi	s2,s2,658 # 900 <malloc+0x136>
        while(*s != 0){
 676:	02800593          	li	a1,40
 67a:	bff1                	j	656 <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
 67c:	008b8913          	addi	s2,s7,8
 680:	000bc583          	lbu	a1,0(s7)
 684:	8556                	mv	a0,s5
 686:	00000097          	auipc	ra,0x0
 68a:	dc2080e7          	jalr	-574(ra) # 448 <putc>
 68e:	8bca                	mv	s7,s2
      state = 0;
 690:	4981                	li	s3,0
 692:	b5c9                	j	554 <vprintf+0x42>
        putc(fd, c);
 694:	02500593          	li	a1,37
 698:	8556                	mv	a0,s5
 69a:	00000097          	auipc	ra,0x0
 69e:	dae080e7          	jalr	-594(ra) # 448 <putc>
      state = 0;
 6a2:	4981                	li	s3,0
 6a4:	bd45                	j	554 <vprintf+0x42>
        putc(fd, '%');
 6a6:	02500593          	li	a1,37
 6aa:	8556                	mv	a0,s5
 6ac:	00000097          	auipc	ra,0x0
 6b0:	d9c080e7          	jalr	-612(ra) # 448 <putc>
        putc(fd, c);
 6b4:	85ca                	mv	a1,s2
 6b6:	8556                	mv	a0,s5
 6b8:	00000097          	auipc	ra,0x0
 6bc:	d90080e7          	jalr	-624(ra) # 448 <putc>
      state = 0;
 6c0:	4981                	li	s3,0
 6c2:	bd49                	j	554 <vprintf+0x42>
        s = va_arg(ap, char*);
 6c4:	8bce                	mv	s7,s3
      state = 0;
 6c6:	4981                	li	s3,0
 6c8:	b571                	j	554 <vprintf+0x42>
 6ca:	74e2                	ld	s1,56(sp)
 6cc:	79a2                	ld	s3,40(sp)
 6ce:	7a02                	ld	s4,32(sp)
 6d0:	6ae2                	ld	s5,24(sp)
 6d2:	6b42                	ld	s6,16(sp)
 6d4:	6ba2                	ld	s7,8(sp)
    }
  }
}
 6d6:	60a6                	ld	ra,72(sp)
 6d8:	6406                	ld	s0,64(sp)
 6da:	7942                	ld	s2,48(sp)
 6dc:	6161                	addi	sp,sp,80
 6de:	8082                	ret

00000000000006e0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6e0:	715d                	addi	sp,sp,-80
 6e2:	ec06                	sd	ra,24(sp)
 6e4:	e822                	sd	s0,16(sp)
 6e6:	1000                	addi	s0,sp,32
 6e8:	e010                	sd	a2,0(s0)
 6ea:	e414                	sd	a3,8(s0)
 6ec:	e818                	sd	a4,16(s0)
 6ee:	ec1c                	sd	a5,24(s0)
 6f0:	03043023          	sd	a6,32(s0)
 6f4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6f8:	8622                	mv	a2,s0
 6fa:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6fe:	00000097          	auipc	ra,0x0
 702:	e14080e7          	jalr	-492(ra) # 512 <vprintf>
}
 706:	60e2                	ld	ra,24(sp)
 708:	6442                	ld	s0,16(sp)
 70a:	6161                	addi	sp,sp,80
 70c:	8082                	ret

000000000000070e <printf>:

void
printf(const char *fmt, ...)
{
 70e:	711d                	addi	sp,sp,-96
 710:	ec06                	sd	ra,24(sp)
 712:	e822                	sd	s0,16(sp)
 714:	1000                	addi	s0,sp,32
 716:	e40c                	sd	a1,8(s0)
 718:	e810                	sd	a2,16(s0)
 71a:	ec14                	sd	a3,24(s0)
 71c:	f018                	sd	a4,32(s0)
 71e:	f41c                	sd	a5,40(s0)
 720:	03043823          	sd	a6,48(s0)
 724:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 728:	00840613          	addi	a2,s0,8
 72c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 730:	85aa                	mv	a1,a0
 732:	4505                	li	a0,1
 734:	00000097          	auipc	ra,0x0
 738:	dde080e7          	jalr	-546(ra) # 512 <vprintf>
}
 73c:	60e2                	ld	ra,24(sp)
 73e:	6442                	ld	s0,16(sp)
 740:	6125                	addi	sp,sp,96
 742:	8082                	ret

0000000000000744 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 744:	1141                	addi	sp,sp,-16
 746:	e406                	sd	ra,8(sp)
 748:	e022                	sd	s0,0(sp)
 74a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 74c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 750:	00000797          	auipc	a5,0x0
 754:	6107b783          	ld	a5,1552(a5) # d60 <freep>
 758:	a039                	j	766 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 75a:	6398                	ld	a4,0(a5)
 75c:	00e7e463          	bltu	a5,a4,764 <free+0x20>
 760:	00e6ea63          	bltu	a3,a4,774 <free+0x30>
{
 764:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 766:	fed7fae3          	bgeu	a5,a3,75a <free+0x16>
 76a:	6398                	ld	a4,0(a5)
 76c:	00e6e463          	bltu	a3,a4,774 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 770:	fee7eae3          	bltu	a5,a4,764 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 774:	ff852583          	lw	a1,-8(a0)
 778:	6390                	ld	a2,0(a5)
 77a:	02059813          	slli	a6,a1,0x20
 77e:	01c85713          	srli	a4,a6,0x1c
 782:	9736                	add	a4,a4,a3
 784:	02e60563          	beq	a2,a4,7ae <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 788:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 78c:	4790                	lw	a2,8(a5)
 78e:	02061593          	slli	a1,a2,0x20
 792:	01c5d713          	srli	a4,a1,0x1c
 796:	973e                	add	a4,a4,a5
 798:	02e68263          	beq	a3,a4,7bc <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 79c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 79e:	00000717          	auipc	a4,0x0
 7a2:	5cf73123          	sd	a5,1474(a4) # d60 <freep>
}
 7a6:	60a2                	ld	ra,8(sp)
 7a8:	6402                	ld	s0,0(sp)
 7aa:	0141                	addi	sp,sp,16
 7ac:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 7ae:	4618                	lw	a4,8(a2)
 7b0:	9f2d                	addw	a4,a4,a1
 7b2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7b6:	6398                	ld	a4,0(a5)
 7b8:	6310                	ld	a2,0(a4)
 7ba:	b7f9                	j	788 <free+0x44>
    p->s.size += bp->s.size;
 7bc:	ff852703          	lw	a4,-8(a0)
 7c0:	9f31                	addw	a4,a4,a2
 7c2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7c4:	ff053683          	ld	a3,-16(a0)
 7c8:	bfd1                	j	79c <free+0x58>

00000000000007ca <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7ca:	7139                	addi	sp,sp,-64
 7cc:	fc06                	sd	ra,56(sp)
 7ce:	f822                	sd	s0,48(sp)
 7d0:	f04a                	sd	s2,32(sp)
 7d2:	ec4e                	sd	s3,24(sp)
 7d4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7d6:	02051993          	slli	s3,a0,0x20
 7da:	0209d993          	srli	s3,s3,0x20
 7de:	09bd                	addi	s3,s3,15
 7e0:	0049d993          	srli	s3,s3,0x4
 7e4:	2985                	addiw	s3,s3,1
 7e6:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 7e8:	00000517          	auipc	a0,0x0
 7ec:	57853503          	ld	a0,1400(a0) # d60 <freep>
 7f0:	c905                	beqz	a0,820 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7f4:	4798                	lw	a4,8(a5)
 7f6:	09377a63          	bgeu	a4,s3,88a <malloc+0xc0>
 7fa:	f426                	sd	s1,40(sp)
 7fc:	e852                	sd	s4,16(sp)
 7fe:	e456                	sd	s5,8(sp)
 800:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 802:	8a4e                	mv	s4,s3
 804:	6705                	lui	a4,0x1
 806:	00e9f363          	bgeu	s3,a4,80c <malloc+0x42>
 80a:	6a05                	lui	s4,0x1
 80c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 810:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 814:	00000497          	auipc	s1,0x0
 818:	54c48493          	addi	s1,s1,1356 # d60 <freep>
  if(p == (char*)-1)
 81c:	5afd                	li	s5,-1
 81e:	a089                	j	860 <malloc+0x96>
 820:	f426                	sd	s1,40(sp)
 822:	e852                	sd	s4,16(sp)
 824:	e456                	sd	s5,8(sp)
 826:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 828:	00000797          	auipc	a5,0x0
 82c:	54078793          	addi	a5,a5,1344 # d68 <base>
 830:	00000717          	auipc	a4,0x0
 834:	52f73823          	sd	a5,1328(a4) # d60 <freep>
 838:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 83a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 83e:	b7d1                	j	802 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 840:	6398                	ld	a4,0(a5)
 842:	e118                	sd	a4,0(a0)
 844:	a8b9                	j	8a2 <malloc+0xd8>
  hp->s.size = nu;
 846:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 84a:	0541                	addi	a0,a0,16
 84c:	00000097          	auipc	ra,0x0
 850:	ef8080e7          	jalr	-264(ra) # 744 <free>
  return freep;
 854:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 856:	c135                	beqz	a0,8ba <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 858:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 85a:	4798                	lw	a4,8(a5)
 85c:	03277363          	bgeu	a4,s2,882 <malloc+0xb8>
    if(p == freep)
 860:	6098                	ld	a4,0(s1)
 862:	853e                	mv	a0,a5
 864:	fef71ae3          	bne	a4,a5,858 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 868:	8552                	mv	a0,s4
 86a:	00000097          	auipc	ra,0x0
 86e:	bae080e7          	jalr	-1106(ra) # 418 <sbrk>
  if(p == (char*)-1)
 872:	fd551ae3          	bne	a0,s5,846 <malloc+0x7c>
        return 0;
 876:	4501                	li	a0,0
 878:	74a2                	ld	s1,40(sp)
 87a:	6a42                	ld	s4,16(sp)
 87c:	6aa2                	ld	s5,8(sp)
 87e:	6b02                	ld	s6,0(sp)
 880:	a03d                	j	8ae <malloc+0xe4>
 882:	74a2                	ld	s1,40(sp)
 884:	6a42                	ld	s4,16(sp)
 886:	6aa2                	ld	s5,8(sp)
 888:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 88a:	fae90be3          	beq	s2,a4,840 <malloc+0x76>
        p->s.size -= nunits;
 88e:	4137073b          	subw	a4,a4,s3
 892:	c798                	sw	a4,8(a5)
        p += p->s.size;
 894:	02071693          	slli	a3,a4,0x20
 898:	01c6d713          	srli	a4,a3,0x1c
 89c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 89e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8a2:	00000717          	auipc	a4,0x0
 8a6:	4aa73f23          	sd	a0,1214(a4) # d60 <freep>
      return (void*)(p + 1);
 8aa:	01078513          	addi	a0,a5,16
  }
}
 8ae:	70e2                	ld	ra,56(sp)
 8b0:	7442                	ld	s0,48(sp)
 8b2:	7902                	ld	s2,32(sp)
 8b4:	69e2                	ld	s3,24(sp)
 8b6:	6121                	addi	sp,sp,64
 8b8:	8082                	ret
 8ba:	74a2                	ld	s1,40(sp)
 8bc:	6a42                	ld	s4,16(sp)
 8be:	6aa2                	ld	s5,8(sp)
 8c0:	6b02                	ld	s6,0(sp)
 8c2:	b7f5                	j	8ae <malloc+0xe4>
