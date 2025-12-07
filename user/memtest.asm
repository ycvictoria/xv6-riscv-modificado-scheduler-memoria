
user/_memtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main() {
   0:	711d                	addi	sp,sp,-96
   2:	ec86                	sd	ra,88(sp)
   4:	e8a2                	sd	s0,80(sp)
   6:	e4a6                	sd	s1,72(sp)
   8:	e0ca                	sd	s2,64(sp)
   a:	fc4e                	sd	s3,56(sp)
   c:	f852                	sd	s4,48(sp)
   e:	f456                	sd	s5,40(sp)
  10:	f05a                	sd	s6,32(sp)
  12:	ec5e                	sd	s7,24(sp)
  14:	e862                	sd	s8,16(sp)
  16:	e466                	sd	s9,8(sp)
  18:	e06a                	sd	s10,0(sp)
  1a:	1080                	addi	s0,sp,96

  printf("\n====== Prueba del limite de memoria ======\n\n");
  1c:	00001517          	auipc	a0,0x1
  20:	94c50513          	addi	a0,a0,-1716 # 968 <malloc+0xfc>
  24:	00000097          	auipc	ra,0x0
  28:	78c080e7          	jalr	1932(ra) # 7b0 <printf>

  uint64 total = 0;   // memoria total solicitada

  for(int i = 0; i < 200000; i++){
  2c:	4901                	li	s2,0
  uint64 total = 0;   // memoria total solicitada
  2e:	4481                	li	s1,0

    printf("[Iter %d] Memoria actual: %d bytes\n", i, total);
  30:	00001b17          	auipc	s6,0x1
  34:	970b0b13          	addi	s6,s6,-1680 # 9a0 <malloc+0x134>

    // CASO 1: solicitar 4 KB
    void *r1 = sbrk(4096);
  38:	6a05                	lui	s4,0x1
    if((long)r1 == -1){
  3a:	59fd                	li	s3,-1
      printf("❌ ERROR: Memoria denegada al pedir 4096 bytes (4 KB) en iteracion %d\n", i);
      printf("Memoria total alcanzada: %d bytes\n", total);
      exit(0);
    }
    total += 4096;
    printf("  ✓ Se asignaron 4096 bytes, total = %d\n", total);
  3c:	00001c17          	auipc	s8,0x1
  40:	9fcc0c13          	addi	s8,s8,-1540 # a38 <malloc+0x1cc>

    // CASO 2: solicitar 128 bytes
    void *r2 = sbrk(128);
  44:	08000b93          	li	s7,128
    if((long)r2 == -1){
      printf("❌ ERROR: Memoria denegada al pedir 128 bytes en iteracion %d\n", i);
      printf("Memoria total alcanzada: %d bytes\n", total);
      exit(0);
    }
    total += 128;
  48:	017a0ab3          	add	s5,s4,s7
    printf("  ✓ Se asignaron 128 bytes, total = %d\n", total);
  4c:	00001c97          	auipc	s9,0x1
  50:	a5cc8c93          	addi	s9,s9,-1444 # aa8 <malloc+0x23c>
    printf("[Iter %d] Memoria actual: %d bytes\n", i, total);
  54:	8626                	mv	a2,s1
  56:	85ca                	mv	a1,s2
  58:	855a                	mv	a0,s6
  5a:	00000097          	auipc	ra,0x0
  5e:	756080e7          	jalr	1878(ra) # 7b0 <printf>
    void *r1 = sbrk(4096);
  62:	8552                	mv	a0,s4
  64:	00000097          	auipc	ra,0x0
  68:	456080e7          	jalr	1110(ra) # 4ba <sbrk>
    if((long)r1 == -1){
  6c:	0b350763          	beq	a0,s3,11a <main+0x11a>
    total += 4096;
  70:	01448d33          	add	s10,s1,s4
    printf("  ✓ Se asignaron 4096 bytes, total = %d\n", total);
  74:	85ea                	mv	a1,s10
  76:	8562                	mv	a0,s8
  78:	00000097          	auipc	ra,0x0
  7c:	738080e7          	jalr	1848(ra) # 7b0 <printf>
    void *r2 = sbrk(128);
  80:	855e                	mv	a0,s7
  82:	00000097          	auipc	ra,0x0
  86:	438080e7          	jalr	1080(ra) # 4ba <sbrk>
    if((long)r2 == -1){
  8a:	0b350f63          	beq	a0,s3,148 <main+0x148>
    total += 128;
  8e:	01548d33          	add	s10,s1,s5
    printf("  ✓ Se asignaron 128 bytes, total = %d\n", total);
  92:	85ea                	mv	a1,s10
  94:	8566                	mv	a0,s9
  96:	00000097          	auipc	ra,0x0
  9a:	71a080e7          	jalr	1818(ra) # 7b0 <printf>

    // CASO 3: solicitar 1 byte (prueba fina)
    void *r3 = sbrk(1);
  9e:	4505                	li	a0,1
  a0:	00000097          	auipc	ra,0x0
  a4:	41a080e7          	jalr	1050(ra) # 4ba <sbrk>
    if((long)r3 == -1){
  a8:	0d350763          	beq	a0,s3,176 <main+0x176>
      printf("❌ ERROR: Memoria denegada al pedir 1 byte en iteracion %d\n", i);
      printf("Memoria total alcanzada: %d bytes\n", total);
      exit(0);
    }
    total += 1;
  ac:	6785                	lui	a5,0x1
  ae:	08178793          	addi	a5,a5,129 # 1081 <__BSS_END__+0x29>
  b2:	94be                	add	s1,s1,a5
    printf("  ✓ Se asigno 1 byte, total = %d\n", total);
  b4:	85a6                	mv	a1,s1
  b6:	00001517          	auipc	a0,0x1
  ba:	a6250513          	addi	a0,a0,-1438 # b18 <malloc+0x2ac>
  be:	00000097          	auipc	ra,0x0
  c2:	6f2080e7          	jalr	1778(ra) # 7b0 <printf>

    // CASO 4: solicitar 0 bytes (solo verificar direccion)
    void *addr = sbrk(0);
  c6:	4501                	li	a0,0
  c8:	00000097          	auipc	ra,0x0
  cc:	3f2080e7          	jalr	1010(ra) # 4ba <sbrk>
  d0:	85aa                	mv	a1,a0
    printf("  ➤ Direccion final del break: %p\n", addr);
  d2:	00001517          	auipc	a0,0x1
  d6:	a6e50513          	addi	a0,a0,-1426 # b40 <malloc+0x2d4>
  da:	00000097          	auipc	ra,0x0
  de:	6d6080e7          	jalr	1750(ra) # 7b0 <printf>
    
    printf("-----------------------------------------------\n");
  e2:	00001517          	auipc	a0,0x1
  e6:	a8650513          	addi	a0,a0,-1402 # b68 <malloc+0x2fc>
  ea:	00000097          	auipc	ra,0x0
  ee:	6c6080e7          	jalr	1734(ra) # 7b0 <printf>
  for(int i = 0; i < 200000; i++){
  f2:	2905                	addiw	s2,s2,1
  f4:	325db7b7          	lui	a5,0x325db
  f8:	d4078793          	addi	a5,a5,-704 # 325dad40 <__global_pointer$+0x325d9504>
  fc:	f4f49ce3          	bne	s1,a5,54 <main+0x54>
  }

  printf("❗ ERROR CRITICO: el proceso crecio sin limite\n");
 100:	00001517          	auipc	a0,0x1
 104:	aa050513          	addi	a0,a0,-1376 # ba0 <malloc+0x334>
 108:	00000097          	auipc	ra,0x0
 10c:	6a8080e7          	jalr	1704(ra) # 7b0 <printf>
  exit(0);
 110:	4501                	li	a0,0
 112:	00000097          	auipc	ra,0x0
 116:	320080e7          	jalr	800(ra) # 432 <exit>
      printf("❌ ERROR: Memoria denegada al pedir 4096 bytes (4 KB) en iteracion %d\n", i);
 11a:	85ca                	mv	a1,s2
 11c:	00001517          	auipc	a0,0x1
 120:	8ac50513          	addi	a0,a0,-1876 # 9c8 <malloc+0x15c>
 124:	00000097          	auipc	ra,0x0
 128:	68c080e7          	jalr	1676(ra) # 7b0 <printf>
      printf("Memoria total alcanzada: %d bytes\n", total);
 12c:	85a6                	mv	a1,s1
 12e:	00001517          	auipc	a0,0x1
 132:	8e250513          	addi	a0,a0,-1822 # a10 <malloc+0x1a4>
 136:	00000097          	auipc	ra,0x0
 13a:	67a080e7          	jalr	1658(ra) # 7b0 <printf>
      exit(0);
 13e:	4501                	li	a0,0
 140:	00000097          	auipc	ra,0x0
 144:	2f2080e7          	jalr	754(ra) # 432 <exit>
      printf("❌ ERROR: Memoria denegada al pedir 128 bytes en iteracion %d\n", i);
 148:	85ca                	mv	a1,s2
 14a:	00001517          	auipc	a0,0x1
 14e:	91e50513          	addi	a0,a0,-1762 # a68 <malloc+0x1fc>
 152:	00000097          	auipc	ra,0x0
 156:	65e080e7          	jalr	1630(ra) # 7b0 <printf>
      printf("Memoria total alcanzada: %d bytes\n", total);
 15a:	85ea                	mv	a1,s10
 15c:	00001517          	auipc	a0,0x1
 160:	8b450513          	addi	a0,a0,-1868 # a10 <malloc+0x1a4>
 164:	00000097          	auipc	ra,0x0
 168:	64c080e7          	jalr	1612(ra) # 7b0 <printf>
      exit(0);
 16c:	4501                	li	a0,0
 16e:	00000097          	auipc	ra,0x0
 172:	2c4080e7          	jalr	708(ra) # 432 <exit>
      printf("❌ ERROR: Memoria denegada al pedir 1 byte en iteracion %d\n", i);
 176:	85ca                	mv	a1,s2
 178:	00001517          	auipc	a0,0x1
 17c:	96050513          	addi	a0,a0,-1696 # ad8 <malloc+0x26c>
 180:	00000097          	auipc	ra,0x0
 184:	630080e7          	jalr	1584(ra) # 7b0 <printf>
      printf("Memoria total alcanzada: %d bytes\n", total);
 188:	85ea                	mv	a1,s10
 18a:	00001517          	auipc	a0,0x1
 18e:	88650513          	addi	a0,a0,-1914 # a10 <malloc+0x1a4>
 192:	00000097          	auipc	ra,0x0
 196:	61e080e7          	jalr	1566(ra) # 7b0 <printf>
      exit(0);
 19a:	4501                	li	a0,0
 19c:	00000097          	auipc	ra,0x0
 1a0:	296080e7          	jalr	662(ra) # 432 <exit>

00000000000001a4 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 1a4:	1141                	addi	sp,sp,-16
 1a6:	e406                	sd	ra,8(sp)
 1a8:	e022                	sd	s0,0(sp)
 1aa:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1ac:	87aa                	mv	a5,a0
 1ae:	0585                	addi	a1,a1,1
 1b0:	0785                	addi	a5,a5,1
 1b2:	fff5c703          	lbu	a4,-1(a1)
 1b6:	fee78fa3          	sb	a4,-1(a5)
 1ba:	fb75                	bnez	a4,1ae <strcpy+0xa>
    ;
  return os;
}
 1bc:	60a2                	ld	ra,8(sp)
 1be:	6402                	ld	s0,0(sp)
 1c0:	0141                	addi	sp,sp,16
 1c2:	8082                	ret

00000000000001c4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1c4:	1141                	addi	sp,sp,-16
 1c6:	e406                	sd	ra,8(sp)
 1c8:	e022                	sd	s0,0(sp)
 1ca:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1cc:	00054783          	lbu	a5,0(a0)
 1d0:	cb91                	beqz	a5,1e4 <strcmp+0x20>
 1d2:	0005c703          	lbu	a4,0(a1)
 1d6:	00f71763          	bne	a4,a5,1e4 <strcmp+0x20>
    p++, q++;
 1da:	0505                	addi	a0,a0,1
 1dc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1de:	00054783          	lbu	a5,0(a0)
 1e2:	fbe5                	bnez	a5,1d2 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 1e4:	0005c503          	lbu	a0,0(a1)
}
 1e8:	40a7853b          	subw	a0,a5,a0
 1ec:	60a2                	ld	ra,8(sp)
 1ee:	6402                	ld	s0,0(sp)
 1f0:	0141                	addi	sp,sp,16
 1f2:	8082                	ret

00000000000001f4 <strlen>:

uint
strlen(const char *s)
{
 1f4:	1141                	addi	sp,sp,-16
 1f6:	e406                	sd	ra,8(sp)
 1f8:	e022                	sd	s0,0(sp)
 1fa:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1fc:	00054783          	lbu	a5,0(a0)
 200:	cf91                	beqz	a5,21c <strlen+0x28>
 202:	00150793          	addi	a5,a0,1
 206:	86be                	mv	a3,a5
 208:	0785                	addi	a5,a5,1
 20a:	fff7c703          	lbu	a4,-1(a5)
 20e:	ff65                	bnez	a4,206 <strlen+0x12>
 210:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 214:	60a2                	ld	ra,8(sp)
 216:	6402                	ld	s0,0(sp)
 218:	0141                	addi	sp,sp,16
 21a:	8082                	ret
  for(n = 0; s[n]; n++)
 21c:	4501                	li	a0,0
 21e:	bfdd                	j	214 <strlen+0x20>

0000000000000220 <memset>:

void*
memset(void *dst, int c, uint n)
{
 220:	1141                	addi	sp,sp,-16
 222:	e406                	sd	ra,8(sp)
 224:	e022                	sd	s0,0(sp)
 226:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 228:	ca19                	beqz	a2,23e <memset+0x1e>
 22a:	87aa                	mv	a5,a0
 22c:	1602                	slli	a2,a2,0x20
 22e:	9201                	srli	a2,a2,0x20
 230:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 234:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 238:	0785                	addi	a5,a5,1
 23a:	fee79de3          	bne	a5,a4,234 <memset+0x14>
  }
  return dst;
}
 23e:	60a2                	ld	ra,8(sp)
 240:	6402                	ld	s0,0(sp)
 242:	0141                	addi	sp,sp,16
 244:	8082                	ret

0000000000000246 <strchr>:

char*
strchr(const char *s, char c)
{
 246:	1141                	addi	sp,sp,-16
 248:	e406                	sd	ra,8(sp)
 24a:	e022                	sd	s0,0(sp)
 24c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 24e:	00054783          	lbu	a5,0(a0)
 252:	cf81                	beqz	a5,26a <strchr+0x24>
    if(*s == c)
 254:	00f58763          	beq	a1,a5,262 <strchr+0x1c>
  for(; *s; s++)
 258:	0505                	addi	a0,a0,1
 25a:	00054783          	lbu	a5,0(a0)
 25e:	fbfd                	bnez	a5,254 <strchr+0xe>
      return (char*)s;
  return 0;
 260:	4501                	li	a0,0
}
 262:	60a2                	ld	ra,8(sp)
 264:	6402                	ld	s0,0(sp)
 266:	0141                	addi	sp,sp,16
 268:	8082                	ret
  return 0;
 26a:	4501                	li	a0,0
 26c:	bfdd                	j	262 <strchr+0x1c>

000000000000026e <gets>:

char*
gets(char *buf, int max)
{
 26e:	711d                	addi	sp,sp,-96
 270:	ec86                	sd	ra,88(sp)
 272:	e8a2                	sd	s0,80(sp)
 274:	e4a6                	sd	s1,72(sp)
 276:	e0ca                	sd	s2,64(sp)
 278:	fc4e                	sd	s3,56(sp)
 27a:	f852                	sd	s4,48(sp)
 27c:	f456                	sd	s5,40(sp)
 27e:	f05a                	sd	s6,32(sp)
 280:	ec5e                	sd	s7,24(sp)
 282:	e862                	sd	s8,16(sp)
 284:	1080                	addi	s0,sp,96
 286:	8baa                	mv	s7,a0
 288:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 28a:	892a                	mv	s2,a0
 28c:	4481                	li	s1,0
    cc = read(0, &c, 1);
 28e:	faf40b13          	addi	s6,s0,-81
 292:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 294:	8c26                	mv	s8,s1
 296:	0014899b          	addiw	s3,s1,1
 29a:	84ce                	mv	s1,s3
 29c:	0349d663          	bge	s3,s4,2c8 <gets+0x5a>
    cc = read(0, &c, 1);
 2a0:	8656                	mv	a2,s5
 2a2:	85da                	mv	a1,s6
 2a4:	4501                	li	a0,0
 2a6:	00000097          	auipc	ra,0x0
 2aa:	1a4080e7          	jalr	420(ra) # 44a <read>
    if(cc < 1)
 2ae:	00a05d63          	blez	a0,2c8 <gets+0x5a>
      break;
    buf[i++] = c;
 2b2:	faf44783          	lbu	a5,-81(s0)
 2b6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2ba:	0905                	addi	s2,s2,1
 2bc:	ff678713          	addi	a4,a5,-10
 2c0:	c319                	beqz	a4,2c6 <gets+0x58>
 2c2:	17cd                	addi	a5,a5,-13
 2c4:	fbe1                	bnez	a5,294 <gets+0x26>
    buf[i++] = c;
 2c6:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 2c8:	9c5e                	add	s8,s8,s7
 2ca:	000c0023          	sb	zero,0(s8)
  return buf;
}
 2ce:	855e                	mv	a0,s7
 2d0:	60e6                	ld	ra,88(sp)
 2d2:	6446                	ld	s0,80(sp)
 2d4:	64a6                	ld	s1,72(sp)
 2d6:	6906                	ld	s2,64(sp)
 2d8:	79e2                	ld	s3,56(sp)
 2da:	7a42                	ld	s4,48(sp)
 2dc:	7aa2                	ld	s5,40(sp)
 2de:	7b02                	ld	s6,32(sp)
 2e0:	6be2                	ld	s7,24(sp)
 2e2:	6c42                	ld	s8,16(sp)
 2e4:	6125                	addi	sp,sp,96
 2e6:	8082                	ret

00000000000002e8 <stat>:

int
stat(const char *n, struct stat *st)
{
 2e8:	1101                	addi	sp,sp,-32
 2ea:	ec06                	sd	ra,24(sp)
 2ec:	e822                	sd	s0,16(sp)
 2ee:	e04a                	sd	s2,0(sp)
 2f0:	1000                	addi	s0,sp,32
 2f2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2f4:	4581                	li	a1,0
 2f6:	00000097          	auipc	ra,0x0
 2fa:	17c080e7          	jalr	380(ra) # 472 <open>
  if(fd < 0)
 2fe:	02054663          	bltz	a0,32a <stat+0x42>
 302:	e426                	sd	s1,8(sp)
 304:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 306:	85ca                	mv	a1,s2
 308:	00000097          	auipc	ra,0x0
 30c:	182080e7          	jalr	386(ra) # 48a <fstat>
 310:	892a                	mv	s2,a0
  close(fd);
 312:	8526                	mv	a0,s1
 314:	00000097          	auipc	ra,0x0
 318:	146080e7          	jalr	326(ra) # 45a <close>
  return r;
 31c:	64a2                	ld	s1,8(sp)
}
 31e:	854a                	mv	a0,s2
 320:	60e2                	ld	ra,24(sp)
 322:	6442                	ld	s0,16(sp)
 324:	6902                	ld	s2,0(sp)
 326:	6105                	addi	sp,sp,32
 328:	8082                	ret
    return -1;
 32a:	57fd                	li	a5,-1
 32c:	893e                	mv	s2,a5
 32e:	bfc5                	j	31e <stat+0x36>

0000000000000330 <atoi>:

int
atoi(const char *s)
{
 330:	1141                	addi	sp,sp,-16
 332:	e406                	sd	ra,8(sp)
 334:	e022                	sd	s0,0(sp)
 336:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 338:	00054683          	lbu	a3,0(a0)
 33c:	fd06879b          	addiw	a5,a3,-48
 340:	0ff7f793          	zext.b	a5,a5
 344:	4625                	li	a2,9
 346:	02f66963          	bltu	a2,a5,378 <atoi+0x48>
 34a:	872a                	mv	a4,a0
  n = 0;
 34c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 34e:	0705                	addi	a4,a4,1
 350:	0025179b          	slliw	a5,a0,0x2
 354:	9fa9                	addw	a5,a5,a0
 356:	0017979b          	slliw	a5,a5,0x1
 35a:	9fb5                	addw	a5,a5,a3
 35c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 360:	00074683          	lbu	a3,0(a4)
 364:	fd06879b          	addiw	a5,a3,-48
 368:	0ff7f793          	zext.b	a5,a5
 36c:	fef671e3          	bgeu	a2,a5,34e <atoi+0x1e>
  return n;
}
 370:	60a2                	ld	ra,8(sp)
 372:	6402                	ld	s0,0(sp)
 374:	0141                	addi	sp,sp,16
 376:	8082                	ret
  n = 0;
 378:	4501                	li	a0,0
 37a:	bfdd                	j	370 <atoi+0x40>

000000000000037c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 37c:	1141                	addi	sp,sp,-16
 37e:	e406                	sd	ra,8(sp)
 380:	e022                	sd	s0,0(sp)
 382:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 384:	02b57563          	bgeu	a0,a1,3ae <memmove+0x32>
    while(n-- > 0)
 388:	00c05f63          	blez	a2,3a6 <memmove+0x2a>
 38c:	1602                	slli	a2,a2,0x20
 38e:	9201                	srli	a2,a2,0x20
 390:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 394:	872a                	mv	a4,a0
      *dst++ = *src++;
 396:	0585                	addi	a1,a1,1
 398:	0705                	addi	a4,a4,1
 39a:	fff5c683          	lbu	a3,-1(a1)
 39e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3a2:	fee79ae3          	bne	a5,a4,396 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3a6:	60a2                	ld	ra,8(sp)
 3a8:	6402                	ld	s0,0(sp)
 3aa:	0141                	addi	sp,sp,16
 3ac:	8082                	ret
    while(n-- > 0)
 3ae:	fec05ce3          	blez	a2,3a6 <memmove+0x2a>
    dst += n;
 3b2:	00c50733          	add	a4,a0,a2
    src += n;
 3b6:	95b2                	add	a1,a1,a2
 3b8:	fff6079b          	addiw	a5,a2,-1
 3bc:	1782                	slli	a5,a5,0x20
 3be:	9381                	srli	a5,a5,0x20
 3c0:	fff7c793          	not	a5,a5
 3c4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3c6:	15fd                	addi	a1,a1,-1
 3c8:	177d                	addi	a4,a4,-1
 3ca:	0005c683          	lbu	a3,0(a1)
 3ce:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3d2:	fef71ae3          	bne	a4,a5,3c6 <memmove+0x4a>
 3d6:	bfc1                	j	3a6 <memmove+0x2a>

00000000000003d8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3d8:	1141                	addi	sp,sp,-16
 3da:	e406                	sd	ra,8(sp)
 3dc:	e022                	sd	s0,0(sp)
 3de:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3e0:	c61d                	beqz	a2,40e <memcmp+0x36>
 3e2:	1602                	slli	a2,a2,0x20
 3e4:	9201                	srli	a2,a2,0x20
 3e6:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 3ea:	00054783          	lbu	a5,0(a0)
 3ee:	0005c703          	lbu	a4,0(a1)
 3f2:	00e79863          	bne	a5,a4,402 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 3f6:	0505                	addi	a0,a0,1
    p2++;
 3f8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3fa:	fed518e3          	bne	a0,a3,3ea <memcmp+0x12>
  }
  return 0;
 3fe:	4501                	li	a0,0
 400:	a019                	j	406 <memcmp+0x2e>
      return *p1 - *p2;
 402:	40e7853b          	subw	a0,a5,a4
}
 406:	60a2                	ld	ra,8(sp)
 408:	6402                	ld	s0,0(sp)
 40a:	0141                	addi	sp,sp,16
 40c:	8082                	ret
  return 0;
 40e:	4501                	li	a0,0
 410:	bfdd                	j	406 <memcmp+0x2e>

0000000000000412 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 412:	1141                	addi	sp,sp,-16
 414:	e406                	sd	ra,8(sp)
 416:	e022                	sd	s0,0(sp)
 418:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 41a:	00000097          	auipc	ra,0x0
 41e:	f62080e7          	jalr	-158(ra) # 37c <memmove>
}
 422:	60a2                	ld	ra,8(sp)
 424:	6402                	ld	s0,0(sp)
 426:	0141                	addi	sp,sp,16
 428:	8082                	ret

000000000000042a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 42a:	4885                	li	a7,1
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <exit>:
.global exit
exit:
 li a7, SYS_exit
 432:	4889                	li	a7,2
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <wait>:
.global wait
wait:
 li a7, SYS_wait
 43a:	488d                	li	a7,3
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 442:	4891                	li	a7,4
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <read>:
.global read
read:
 li a7, SYS_read
 44a:	4895                	li	a7,5
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <write>:
.global write
write:
 li a7, SYS_write
 452:	48c1                	li	a7,16
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <close>:
.global close
close:
 li a7, SYS_close
 45a:	48d5                	li	a7,21
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <kill>:
.global kill
kill:
 li a7, SYS_kill
 462:	4899                	li	a7,6
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <exec>:
.global exec
exec:
 li a7, SYS_exec
 46a:	489d                	li	a7,7
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <open>:
.global open
open:
 li a7, SYS_open
 472:	48bd                	li	a7,15
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 47a:	48c5                	li	a7,17
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 482:	48c9                	li	a7,18
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 48a:	48a1                	li	a7,8
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <link>:
.global link
link:
 li a7, SYS_link
 492:	48cd                	li	a7,19
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 49a:	48d1                	li	a7,20
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4a2:	48a5                	li	a7,9
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <dup>:
.global dup
dup:
 li a7, SYS_dup
 4aa:	48a9                	li	a7,10
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4b2:	48ad                	li	a7,11
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4ba:	48b1                	li	a7,12
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4c2:	48b5                	li	a7,13
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4ca:	48b9                	li	a7,14
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <trace>:
.global trace
trace:
 li a7, SYS_trace
 4d2:	48d9                	li	a7,22
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 4da:	48dd                	li	a7,23
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 4e2:	48e1                	li	a7,24
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ea:	1101                	addi	sp,sp,-32
 4ec:	ec06                	sd	ra,24(sp)
 4ee:	e822                	sd	s0,16(sp)
 4f0:	1000                	addi	s0,sp,32
 4f2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4f6:	4605                	li	a2,1
 4f8:	fef40593          	addi	a1,s0,-17
 4fc:	00000097          	auipc	ra,0x0
 500:	f56080e7          	jalr	-170(ra) # 452 <write>
}
 504:	60e2                	ld	ra,24(sp)
 506:	6442                	ld	s0,16(sp)
 508:	6105                	addi	sp,sp,32
 50a:	8082                	ret

000000000000050c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 50c:	7139                	addi	sp,sp,-64
 50e:	fc06                	sd	ra,56(sp)
 510:	f822                	sd	s0,48(sp)
 512:	f04a                	sd	s2,32(sp)
 514:	ec4e                	sd	s3,24(sp)
 516:	0080                	addi	s0,sp,64
 518:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 51a:	cad9                	beqz	a3,5b0 <printint+0xa4>
 51c:	01f5d79b          	srliw	a5,a1,0x1f
 520:	cbc1                	beqz	a5,5b0 <printint+0xa4>
    neg = 1;
    x = -xx;
 522:	40b005bb          	negw	a1,a1
    neg = 1;
 526:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 528:	fc040993          	addi	s3,s0,-64
  neg = 0;
 52c:	86ce                	mv	a3,s3
  i = 0;
 52e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 530:	00000817          	auipc	a6,0x0
 534:	70880813          	addi	a6,a6,1800 # c38 <digits>
 538:	88ba                	mv	a7,a4
 53a:	0017051b          	addiw	a0,a4,1
 53e:	872a                	mv	a4,a0
 540:	02c5f7bb          	remuw	a5,a1,a2
 544:	1782                	slli	a5,a5,0x20
 546:	9381                	srli	a5,a5,0x20
 548:	97c2                	add	a5,a5,a6
 54a:	0007c783          	lbu	a5,0(a5)
 54e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 552:	87ae                	mv	a5,a1
 554:	02c5d5bb          	divuw	a1,a1,a2
 558:	0685                	addi	a3,a3,1
 55a:	fcc7ffe3          	bgeu	a5,a2,538 <printint+0x2c>
  if(neg)
 55e:	00030c63          	beqz	t1,576 <printint+0x6a>
    buf[i++] = '-';
 562:	fd050793          	addi	a5,a0,-48
 566:	00878533          	add	a0,a5,s0
 56a:	02d00793          	li	a5,45
 56e:	fef50823          	sb	a5,-16(a0)
 572:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 576:	02e05763          	blez	a4,5a4 <printint+0x98>
 57a:	f426                	sd	s1,40(sp)
 57c:	377d                	addiw	a4,a4,-1
 57e:	00e984b3          	add	s1,s3,a4
 582:	19fd                	addi	s3,s3,-1
 584:	99ba                	add	s3,s3,a4
 586:	1702                	slli	a4,a4,0x20
 588:	9301                	srli	a4,a4,0x20
 58a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 58e:	0004c583          	lbu	a1,0(s1)
 592:	854a                	mv	a0,s2
 594:	00000097          	auipc	ra,0x0
 598:	f56080e7          	jalr	-170(ra) # 4ea <putc>
  while(--i >= 0)
 59c:	14fd                	addi	s1,s1,-1
 59e:	ff3498e3          	bne	s1,s3,58e <printint+0x82>
 5a2:	74a2                	ld	s1,40(sp)
}
 5a4:	70e2                	ld	ra,56(sp)
 5a6:	7442                	ld	s0,48(sp)
 5a8:	7902                	ld	s2,32(sp)
 5aa:	69e2                	ld	s3,24(sp)
 5ac:	6121                	addi	sp,sp,64
 5ae:	8082                	ret
  neg = 0;
 5b0:	4301                	li	t1,0
 5b2:	bf9d                	j	528 <printint+0x1c>

00000000000005b4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5b4:	715d                	addi	sp,sp,-80
 5b6:	e486                	sd	ra,72(sp)
 5b8:	e0a2                	sd	s0,64(sp)
 5ba:	f84a                	sd	s2,48(sp)
 5bc:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5be:	0005c903          	lbu	s2,0(a1)
 5c2:	1a090b63          	beqz	s2,778 <vprintf+0x1c4>
 5c6:	fc26                	sd	s1,56(sp)
 5c8:	f44e                	sd	s3,40(sp)
 5ca:	f052                	sd	s4,32(sp)
 5cc:	ec56                	sd	s5,24(sp)
 5ce:	e85a                	sd	s6,16(sp)
 5d0:	e45e                	sd	s7,8(sp)
 5d2:	8aaa                	mv	s5,a0
 5d4:	8bb2                	mv	s7,a2
 5d6:	00158493          	addi	s1,a1,1
  state = 0;
 5da:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5dc:	02500a13          	li	s4,37
 5e0:	4b55                	li	s6,21
 5e2:	a839                	j	600 <vprintf+0x4c>
        putc(fd, c);
 5e4:	85ca                	mv	a1,s2
 5e6:	8556                	mv	a0,s5
 5e8:	00000097          	auipc	ra,0x0
 5ec:	f02080e7          	jalr	-254(ra) # 4ea <putc>
 5f0:	a019                	j	5f6 <vprintf+0x42>
    } else if(state == '%'){
 5f2:	01498d63          	beq	s3,s4,60c <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 5f6:	0485                	addi	s1,s1,1
 5f8:	fff4c903          	lbu	s2,-1(s1)
 5fc:	16090863          	beqz	s2,76c <vprintf+0x1b8>
    if(state == 0){
 600:	fe0999e3          	bnez	s3,5f2 <vprintf+0x3e>
      if(c == '%'){
 604:	ff4910e3          	bne	s2,s4,5e4 <vprintf+0x30>
        state = '%';
 608:	89d2                	mv	s3,s4
 60a:	b7f5                	j	5f6 <vprintf+0x42>
      if(c == 'd'){
 60c:	13490563          	beq	s2,s4,736 <vprintf+0x182>
 610:	f9d9079b          	addiw	a5,s2,-99
 614:	0ff7f793          	zext.b	a5,a5
 618:	12fb6863          	bltu	s6,a5,748 <vprintf+0x194>
 61c:	f9d9079b          	addiw	a5,s2,-99
 620:	0ff7f713          	zext.b	a4,a5
 624:	12eb6263          	bltu	s6,a4,748 <vprintf+0x194>
 628:	00271793          	slli	a5,a4,0x2
 62c:	00000717          	auipc	a4,0x0
 630:	5b470713          	addi	a4,a4,1460 # be0 <malloc+0x374>
 634:	97ba                	add	a5,a5,a4
 636:	439c                	lw	a5,0(a5)
 638:	97ba                	add	a5,a5,a4
 63a:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 63c:	008b8913          	addi	s2,s7,8
 640:	4685                	li	a3,1
 642:	4629                	li	a2,10
 644:	000ba583          	lw	a1,0(s7)
 648:	8556                	mv	a0,s5
 64a:	00000097          	auipc	ra,0x0
 64e:	ec2080e7          	jalr	-318(ra) # 50c <printint>
 652:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 654:	4981                	li	s3,0
 656:	b745                	j	5f6 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 658:	008b8913          	addi	s2,s7,8
 65c:	4681                	li	a3,0
 65e:	4629                	li	a2,10
 660:	000ba583          	lw	a1,0(s7)
 664:	8556                	mv	a0,s5
 666:	00000097          	auipc	ra,0x0
 66a:	ea6080e7          	jalr	-346(ra) # 50c <printint>
 66e:	8bca                	mv	s7,s2
      state = 0;
 670:	4981                	li	s3,0
 672:	b751                	j	5f6 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 674:	008b8913          	addi	s2,s7,8
 678:	4681                	li	a3,0
 67a:	4641                	li	a2,16
 67c:	000ba583          	lw	a1,0(s7)
 680:	8556                	mv	a0,s5
 682:	00000097          	auipc	ra,0x0
 686:	e8a080e7          	jalr	-374(ra) # 50c <printint>
 68a:	8bca                	mv	s7,s2
      state = 0;
 68c:	4981                	li	s3,0
 68e:	b7a5                	j	5f6 <vprintf+0x42>
 690:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 692:	008b8793          	addi	a5,s7,8
 696:	8c3e                	mv	s8,a5
 698:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 69c:	03000593          	li	a1,48
 6a0:	8556                	mv	a0,s5
 6a2:	00000097          	auipc	ra,0x0
 6a6:	e48080e7          	jalr	-440(ra) # 4ea <putc>
  putc(fd, 'x');
 6aa:	07800593          	li	a1,120
 6ae:	8556                	mv	a0,s5
 6b0:	00000097          	auipc	ra,0x0
 6b4:	e3a080e7          	jalr	-454(ra) # 4ea <putc>
 6b8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ba:	00000b97          	auipc	s7,0x0
 6be:	57eb8b93          	addi	s7,s7,1406 # c38 <digits>
 6c2:	03c9d793          	srli	a5,s3,0x3c
 6c6:	97de                	add	a5,a5,s7
 6c8:	0007c583          	lbu	a1,0(a5)
 6cc:	8556                	mv	a0,s5
 6ce:	00000097          	auipc	ra,0x0
 6d2:	e1c080e7          	jalr	-484(ra) # 4ea <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6d6:	0992                	slli	s3,s3,0x4
 6d8:	397d                	addiw	s2,s2,-1
 6da:	fe0914e3          	bnez	s2,6c2 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
 6de:	8be2                	mv	s7,s8
      state = 0;
 6e0:	4981                	li	s3,0
 6e2:	6c02                	ld	s8,0(sp)
 6e4:	bf09                	j	5f6 <vprintf+0x42>
        s = va_arg(ap, char*);
 6e6:	008b8993          	addi	s3,s7,8
 6ea:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 6ee:	02090163          	beqz	s2,710 <vprintf+0x15c>
        while(*s != 0){
 6f2:	00094583          	lbu	a1,0(s2)
 6f6:	c9a5                	beqz	a1,766 <vprintf+0x1b2>
          putc(fd, *s);
 6f8:	8556                	mv	a0,s5
 6fa:	00000097          	auipc	ra,0x0
 6fe:	df0080e7          	jalr	-528(ra) # 4ea <putc>
          s++;
 702:	0905                	addi	s2,s2,1
        while(*s != 0){
 704:	00094583          	lbu	a1,0(s2)
 708:	f9e5                	bnez	a1,6f8 <vprintf+0x144>
        s = va_arg(ap, char*);
 70a:	8bce                	mv	s7,s3
      state = 0;
 70c:	4981                	li	s3,0
 70e:	b5e5                	j	5f6 <vprintf+0x42>
          s = "(null)";
 710:	00000917          	auipc	s2,0x0
 714:	4c890913          	addi	s2,s2,1224 # bd8 <malloc+0x36c>
        while(*s != 0){
 718:	02800593          	li	a1,40
 71c:	bff1                	j	6f8 <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
 71e:	008b8913          	addi	s2,s7,8
 722:	000bc583          	lbu	a1,0(s7)
 726:	8556                	mv	a0,s5
 728:	00000097          	auipc	ra,0x0
 72c:	dc2080e7          	jalr	-574(ra) # 4ea <putc>
 730:	8bca                	mv	s7,s2
      state = 0;
 732:	4981                	li	s3,0
 734:	b5c9                	j	5f6 <vprintf+0x42>
        putc(fd, c);
 736:	02500593          	li	a1,37
 73a:	8556                	mv	a0,s5
 73c:	00000097          	auipc	ra,0x0
 740:	dae080e7          	jalr	-594(ra) # 4ea <putc>
      state = 0;
 744:	4981                	li	s3,0
 746:	bd45                	j	5f6 <vprintf+0x42>
        putc(fd, '%');
 748:	02500593          	li	a1,37
 74c:	8556                	mv	a0,s5
 74e:	00000097          	auipc	ra,0x0
 752:	d9c080e7          	jalr	-612(ra) # 4ea <putc>
        putc(fd, c);
 756:	85ca                	mv	a1,s2
 758:	8556                	mv	a0,s5
 75a:	00000097          	auipc	ra,0x0
 75e:	d90080e7          	jalr	-624(ra) # 4ea <putc>
      state = 0;
 762:	4981                	li	s3,0
 764:	bd49                	j	5f6 <vprintf+0x42>
        s = va_arg(ap, char*);
 766:	8bce                	mv	s7,s3
      state = 0;
 768:	4981                	li	s3,0
 76a:	b571                	j	5f6 <vprintf+0x42>
 76c:	74e2                	ld	s1,56(sp)
 76e:	79a2                	ld	s3,40(sp)
 770:	7a02                	ld	s4,32(sp)
 772:	6ae2                	ld	s5,24(sp)
 774:	6b42                	ld	s6,16(sp)
 776:	6ba2                	ld	s7,8(sp)
    }
  }
}
 778:	60a6                	ld	ra,72(sp)
 77a:	6406                	ld	s0,64(sp)
 77c:	7942                	ld	s2,48(sp)
 77e:	6161                	addi	sp,sp,80
 780:	8082                	ret

0000000000000782 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 782:	715d                	addi	sp,sp,-80
 784:	ec06                	sd	ra,24(sp)
 786:	e822                	sd	s0,16(sp)
 788:	1000                	addi	s0,sp,32
 78a:	e010                	sd	a2,0(s0)
 78c:	e414                	sd	a3,8(s0)
 78e:	e818                	sd	a4,16(s0)
 790:	ec1c                	sd	a5,24(s0)
 792:	03043023          	sd	a6,32(s0)
 796:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 79a:	8622                	mv	a2,s0
 79c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7a0:	00000097          	auipc	ra,0x0
 7a4:	e14080e7          	jalr	-492(ra) # 5b4 <vprintf>
}
 7a8:	60e2                	ld	ra,24(sp)
 7aa:	6442                	ld	s0,16(sp)
 7ac:	6161                	addi	sp,sp,80
 7ae:	8082                	ret

00000000000007b0 <printf>:

void
printf(const char *fmt, ...)
{
 7b0:	711d                	addi	sp,sp,-96
 7b2:	ec06                	sd	ra,24(sp)
 7b4:	e822                	sd	s0,16(sp)
 7b6:	1000                	addi	s0,sp,32
 7b8:	e40c                	sd	a1,8(s0)
 7ba:	e810                	sd	a2,16(s0)
 7bc:	ec14                	sd	a3,24(s0)
 7be:	f018                	sd	a4,32(s0)
 7c0:	f41c                	sd	a5,40(s0)
 7c2:	03043823          	sd	a6,48(s0)
 7c6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ca:	00840613          	addi	a2,s0,8
 7ce:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7d2:	85aa                	mv	a1,a0
 7d4:	4505                	li	a0,1
 7d6:	00000097          	auipc	ra,0x0
 7da:	dde080e7          	jalr	-546(ra) # 5b4 <vprintf>
}
 7de:	60e2                	ld	ra,24(sp)
 7e0:	6442                	ld	s0,16(sp)
 7e2:	6125                	addi	sp,sp,96
 7e4:	8082                	ret

00000000000007e6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7e6:	1141                	addi	sp,sp,-16
 7e8:	e406                	sd	ra,8(sp)
 7ea:	e022                	sd	s0,0(sp)
 7ec:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7ee:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f2:	00001797          	auipc	a5,0x1
 7f6:	84e7b783          	ld	a5,-1970(a5) # 1040 <freep>
 7fa:	a039                	j	808 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7fc:	6398                	ld	a4,0(a5)
 7fe:	00e7e463          	bltu	a5,a4,806 <free+0x20>
 802:	00e6ea63          	bltu	a3,a4,816 <free+0x30>
{
 806:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 808:	fed7fae3          	bgeu	a5,a3,7fc <free+0x16>
 80c:	6398                	ld	a4,0(a5)
 80e:	00e6e463          	bltu	a3,a4,816 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 812:	fee7eae3          	bltu	a5,a4,806 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 816:	ff852583          	lw	a1,-8(a0)
 81a:	6390                	ld	a2,0(a5)
 81c:	02059813          	slli	a6,a1,0x20
 820:	01c85713          	srli	a4,a6,0x1c
 824:	9736                	add	a4,a4,a3
 826:	02e60563          	beq	a2,a4,850 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 82a:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 82e:	4790                	lw	a2,8(a5)
 830:	02061593          	slli	a1,a2,0x20
 834:	01c5d713          	srli	a4,a1,0x1c
 838:	973e                	add	a4,a4,a5
 83a:	02e68263          	beq	a3,a4,85e <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 83e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 840:	00001717          	auipc	a4,0x1
 844:	80f73023          	sd	a5,-2048(a4) # 1040 <freep>
}
 848:	60a2                	ld	ra,8(sp)
 84a:	6402                	ld	s0,0(sp)
 84c:	0141                	addi	sp,sp,16
 84e:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 850:	4618                	lw	a4,8(a2)
 852:	9f2d                	addw	a4,a4,a1
 854:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 858:	6398                	ld	a4,0(a5)
 85a:	6310                	ld	a2,0(a4)
 85c:	b7f9                	j	82a <free+0x44>
    p->s.size += bp->s.size;
 85e:	ff852703          	lw	a4,-8(a0)
 862:	9f31                	addw	a4,a4,a2
 864:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 866:	ff053683          	ld	a3,-16(a0)
 86a:	bfd1                	j	83e <free+0x58>

000000000000086c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 86c:	7139                	addi	sp,sp,-64
 86e:	fc06                	sd	ra,56(sp)
 870:	f822                	sd	s0,48(sp)
 872:	f04a                	sd	s2,32(sp)
 874:	ec4e                	sd	s3,24(sp)
 876:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 878:	02051993          	slli	s3,a0,0x20
 87c:	0209d993          	srli	s3,s3,0x20
 880:	09bd                	addi	s3,s3,15
 882:	0049d993          	srli	s3,s3,0x4
 886:	2985                	addiw	s3,s3,1
 888:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 88a:	00000517          	auipc	a0,0x0
 88e:	7b653503          	ld	a0,1974(a0) # 1040 <freep>
 892:	c905                	beqz	a0,8c2 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 894:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 896:	4798                	lw	a4,8(a5)
 898:	09377a63          	bgeu	a4,s3,92c <malloc+0xc0>
 89c:	f426                	sd	s1,40(sp)
 89e:	e852                	sd	s4,16(sp)
 8a0:	e456                	sd	s5,8(sp)
 8a2:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8a4:	8a4e                	mv	s4,s3
 8a6:	6705                	lui	a4,0x1
 8a8:	00e9f363          	bgeu	s3,a4,8ae <malloc+0x42>
 8ac:	6a05                	lui	s4,0x1
 8ae:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8b2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8b6:	00000497          	auipc	s1,0x0
 8ba:	78a48493          	addi	s1,s1,1930 # 1040 <freep>
  if(p == (char*)-1)
 8be:	5afd                	li	s5,-1
 8c0:	a089                	j	902 <malloc+0x96>
 8c2:	f426                	sd	s1,40(sp)
 8c4:	e852                	sd	s4,16(sp)
 8c6:	e456                	sd	s5,8(sp)
 8c8:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8ca:	00000797          	auipc	a5,0x0
 8ce:	77e78793          	addi	a5,a5,1918 # 1048 <base>
 8d2:	00000717          	auipc	a4,0x0
 8d6:	76f73723          	sd	a5,1902(a4) # 1040 <freep>
 8da:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8dc:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8e0:	b7d1                	j	8a4 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8e2:	6398                	ld	a4,0(a5)
 8e4:	e118                	sd	a4,0(a0)
 8e6:	a8b9                	j	944 <malloc+0xd8>
  hp->s.size = nu;
 8e8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8ec:	0541                	addi	a0,a0,16
 8ee:	00000097          	auipc	ra,0x0
 8f2:	ef8080e7          	jalr	-264(ra) # 7e6 <free>
  return freep;
 8f6:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8f8:	c135                	beqz	a0,95c <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8fa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8fc:	4798                	lw	a4,8(a5)
 8fe:	03277363          	bgeu	a4,s2,924 <malloc+0xb8>
    if(p == freep)
 902:	6098                	ld	a4,0(s1)
 904:	853e                	mv	a0,a5
 906:	fef71ae3          	bne	a4,a5,8fa <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 90a:	8552                	mv	a0,s4
 90c:	00000097          	auipc	ra,0x0
 910:	bae080e7          	jalr	-1106(ra) # 4ba <sbrk>
  if(p == (char*)-1)
 914:	fd551ae3          	bne	a0,s5,8e8 <malloc+0x7c>
        return 0;
 918:	4501                	li	a0,0
 91a:	74a2                	ld	s1,40(sp)
 91c:	6a42                	ld	s4,16(sp)
 91e:	6aa2                	ld	s5,8(sp)
 920:	6b02                	ld	s6,0(sp)
 922:	a03d                	j	950 <malloc+0xe4>
 924:	74a2                	ld	s1,40(sp)
 926:	6a42                	ld	s4,16(sp)
 928:	6aa2                	ld	s5,8(sp)
 92a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 92c:	fae90be3          	beq	s2,a4,8e2 <malloc+0x76>
        p->s.size -= nunits;
 930:	4137073b          	subw	a4,a4,s3
 934:	c798                	sw	a4,8(a5)
        p += p->s.size;
 936:	02071693          	slli	a3,a4,0x20
 93a:	01c6d713          	srli	a4,a3,0x1c
 93e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 940:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 944:	00000717          	auipc	a4,0x0
 948:	6ea73e23          	sd	a0,1788(a4) # 1040 <freep>
      return (void*)(p + 1);
 94c:	01078513          	addi	a0,a5,16
  }
}
 950:	70e2                	ld	ra,56(sp)
 952:	7442                	ld	s0,48(sp)
 954:	7902                	ld	s2,32(sp)
 956:	69e2                	ld	s3,24(sp)
 958:	6121                	addi	sp,sp,64
 95a:	8082                	ret
 95c:	74a2                	ld	s1,40(sp)
 95e:	6a42                	ld	s4,16(sp)
 960:	6aa2                	ld	s5,8(sp)
 962:	6b02                	ld	s6,0(sp)
 964:	b7f5                	j	950 <malloc+0xe4>
