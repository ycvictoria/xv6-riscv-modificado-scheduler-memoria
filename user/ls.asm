
user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "user/user.h"
#include "kernel/fs.h"

char*
fmtname(char *path)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	84aa                	mv	s1,a0
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   c:	00000097          	auipc	ra,0x0
  10:	30c080e7          	jalr	780(ra) # 318 <strlen>
  14:	02051793          	slli	a5,a0,0x20
  18:	9381                	srli	a5,a5,0x20
  1a:	97a6                	add	a5,a5,s1
  1c:	02f00693          	li	a3,47
  20:	0097e963          	bltu	a5,s1,32 <fmtname+0x32>
  24:	0007c703          	lbu	a4,0(a5)
  28:	00d70563          	beq	a4,a3,32 <fmtname+0x32>
  2c:	17fd                	addi	a5,a5,-1
  2e:	fe97fbe3          	bgeu	a5,s1,24 <fmtname+0x24>
    ;
  p++;
  32:	00178493          	addi	s1,a5,1

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  36:	8526                	mv	a0,s1
  38:	00000097          	auipc	ra,0x0
  3c:	2e0080e7          	jalr	736(ra) # 318 <strlen>
  40:	47b5                	li	a5,13
  42:	00a7f863          	bgeu	a5,a0,52 <fmtname+0x52>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  return buf;
}
  46:	8526                	mv	a0,s1
  48:	60e2                	ld	ra,24(sp)
  4a:	6442                	ld	s0,16(sp)
  4c:	64a2                	ld	s1,8(sp)
  4e:	6105                	addi	sp,sp,32
  50:	8082                	ret
  52:	e04a                	sd	s2,0(sp)
  memmove(buf, p, strlen(p));
  54:	8526                	mv	a0,s1
  56:	00000097          	auipc	ra,0x0
  5a:	2c2080e7          	jalr	706(ra) # 318 <strlen>
  5e:	862a                	mv	a2,a0
  60:	85a6                	mv	a1,s1
  62:	00001517          	auipc	a0,0x1
  66:	f8650513          	addi	a0,a0,-122 # fe8 <buf.0>
  6a:	00000097          	auipc	ra,0x0
  6e:	436080e7          	jalr	1078(ra) # 4a0 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  72:	8526                	mv	a0,s1
  74:	00000097          	auipc	ra,0x0
  78:	2a4080e7          	jalr	676(ra) # 318 <strlen>
  7c:	892a                	mv	s2,a0
  7e:	8526                	mv	a0,s1
  80:	00000097          	auipc	ra,0x0
  84:	298080e7          	jalr	664(ra) # 318 <strlen>
  88:	02091793          	slli	a5,s2,0x20
  8c:	9381                	srli	a5,a5,0x20
  8e:	4639                	li	a2,14
  90:	9e09                	subw	a2,a2,a0
  92:	02000593          	li	a1,32
  96:	00001517          	auipc	a0,0x1
  9a:	f5250513          	addi	a0,a0,-174 # fe8 <buf.0>
  9e:	953e                	add	a0,a0,a5
  a0:	00000097          	auipc	ra,0x0
  a4:	2a4080e7          	jalr	676(ra) # 344 <memset>
  return buf;
  a8:	00001497          	auipc	s1,0x1
  ac:	f4048493          	addi	s1,s1,-192 # fe8 <buf.0>
  b0:	6902                	ld	s2,0(sp)
  b2:	bf51                	j	46 <fmtname+0x46>

00000000000000b4 <ls>:

void
ls(char *path)
{
  b4:	da010113          	addi	sp,sp,-608
  b8:	24113c23          	sd	ra,600(sp)
  bc:	24813823          	sd	s0,592(sp)
  c0:	25213023          	sd	s2,576(sp)
  c4:	1480                	addi	s0,sp,608
  c6:	892a                	mv	s2,a0
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
  c8:	4581                	li	a1,0
  ca:	00000097          	auipc	ra,0x0
  ce:	4cc080e7          	jalr	1228(ra) # 596 <open>
  d2:	06054963          	bltz	a0,144 <ls+0x90>
  d6:	24913423          	sd	s1,584(sp)
  da:	84aa                	mv	s1,a0
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  dc:	da840593          	addi	a1,s0,-600
  e0:	00000097          	auipc	ra,0x0
  e4:	4ce080e7          	jalr	1230(ra) # 5ae <fstat>
  e8:	06054963          	bltz	a0,15a <ls+0xa6>
    fprintf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
  ec:	db041783          	lh	a5,-592(s0)
  f0:	4705                	li	a4,1
  f2:	08e78663          	beq	a5,a4,17e <ls+0xca>
  f6:	4709                	li	a4,2
  f8:	02e79663          	bne	a5,a4,124 <ls+0x70>
  case T_FILE:
    printf("%s %d %d %l\n", fmtname(path), st.type, st.ino, st.size);
  fc:	854a                	mv	a0,s2
  fe:	00000097          	auipc	ra,0x0
 102:	f02080e7          	jalr	-254(ra) # 0 <fmtname>
 106:	85aa                	mv	a1,a0
 108:	db843703          	ld	a4,-584(s0)
 10c:	dac42683          	lw	a3,-596(s0)
 110:	db041603          	lh	a2,-592(s0)
 114:	00001517          	auipc	a0,0x1
 118:	9ac50513          	addi	a0,a0,-1620 # ac0 <malloc+0x130>
 11c:	00000097          	auipc	ra,0x0
 120:	7b8080e7          	jalr	1976(ra) # 8d4 <printf>
      }
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
  }
  close(fd);
 124:	8526                	mv	a0,s1
 126:	00000097          	auipc	ra,0x0
 12a:	458080e7          	jalr	1112(ra) # 57e <close>
 12e:	24813483          	ld	s1,584(sp)
}
 132:	25813083          	ld	ra,600(sp)
 136:	25013403          	ld	s0,592(sp)
 13a:	24013903          	ld	s2,576(sp)
 13e:	26010113          	addi	sp,sp,608
 142:	8082                	ret
    fprintf(2, "ls: cannot open %s\n", path);
 144:	864a                	mv	a2,s2
 146:	00001597          	auipc	a1,0x1
 14a:	94a58593          	addi	a1,a1,-1718 # a90 <malloc+0x100>
 14e:	4509                	li	a0,2
 150:	00000097          	auipc	ra,0x0
 154:	756080e7          	jalr	1878(ra) # 8a6 <fprintf>
    return;
 158:	bfe9                	j	132 <ls+0x7e>
    fprintf(2, "ls: cannot stat %s\n", path);
 15a:	864a                	mv	a2,s2
 15c:	00001597          	auipc	a1,0x1
 160:	94c58593          	addi	a1,a1,-1716 # aa8 <malloc+0x118>
 164:	4509                	li	a0,2
 166:	00000097          	auipc	ra,0x0
 16a:	740080e7          	jalr	1856(ra) # 8a6 <fprintf>
    close(fd);
 16e:	8526                	mv	a0,s1
 170:	00000097          	auipc	ra,0x0
 174:	40e080e7          	jalr	1038(ra) # 57e <close>
    return;
 178:	24813483          	ld	s1,584(sp)
 17c:	bf5d                	j	132 <ls+0x7e>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 17e:	854a                	mv	a0,s2
 180:	00000097          	auipc	ra,0x0
 184:	198080e7          	jalr	408(ra) # 318 <strlen>
 188:	2541                	addiw	a0,a0,16
 18a:	20000793          	li	a5,512
 18e:	00a7fb63          	bgeu	a5,a0,1a4 <ls+0xf0>
      printf("ls: path too long\n");
 192:	00001517          	auipc	a0,0x1
 196:	93e50513          	addi	a0,a0,-1730 # ad0 <malloc+0x140>
 19a:	00000097          	auipc	ra,0x0
 19e:	73a080e7          	jalr	1850(ra) # 8d4 <printf>
      break;
 1a2:	b749                	j	124 <ls+0x70>
 1a4:	23313c23          	sd	s3,568(sp)
    strcpy(buf, path);
 1a8:	85ca                	mv	a1,s2
 1aa:	dd040513          	addi	a0,s0,-560
 1ae:	00000097          	auipc	ra,0x0
 1b2:	11a080e7          	jalr	282(ra) # 2c8 <strcpy>
    p = buf+strlen(buf);
 1b6:	dd040513          	addi	a0,s0,-560
 1ba:	00000097          	auipc	ra,0x0
 1be:	15e080e7          	jalr	350(ra) # 318 <strlen>
 1c2:	1502                	slli	a0,a0,0x20
 1c4:	9101                	srli	a0,a0,0x20
 1c6:	dd040793          	addi	a5,s0,-560
 1ca:	00a78733          	add	a4,a5,a0
 1ce:	893a                	mv	s2,a4
    *p++ = '/';
 1d0:	00170793          	addi	a5,a4,1
 1d4:	89be                	mv	s3,a5
 1d6:	02f00793          	li	a5,47
 1da:	00f70023          	sb	a5,0(a4)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1de:	a819                	j	1f4 <ls+0x140>
        printf("ls: cannot stat %s\n", buf);
 1e0:	dd040593          	addi	a1,s0,-560
 1e4:	00001517          	auipc	a0,0x1
 1e8:	8c450513          	addi	a0,a0,-1852 # aa8 <malloc+0x118>
 1ec:	00000097          	auipc	ra,0x0
 1f0:	6e8080e7          	jalr	1768(ra) # 8d4 <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1f4:	4641                	li	a2,16
 1f6:	dc040593          	addi	a1,s0,-576
 1fa:	8526                	mv	a0,s1
 1fc:	00000097          	auipc	ra,0x0
 200:	372080e7          	jalr	882(ra) # 56e <read>
 204:	47c1                	li	a5,16
 206:	04f51f63          	bne	a0,a5,264 <ls+0x1b0>
      if(de.inum == 0)
 20a:	dc045783          	lhu	a5,-576(s0)
 20e:	d3fd                	beqz	a5,1f4 <ls+0x140>
      memmove(p, de.name, DIRSIZ);
 210:	4639                	li	a2,14
 212:	dc240593          	addi	a1,s0,-574
 216:	854e                	mv	a0,s3
 218:	00000097          	auipc	ra,0x0
 21c:	288080e7          	jalr	648(ra) # 4a0 <memmove>
      p[DIRSIZ] = 0;
 220:	000907a3          	sb	zero,15(s2)
      if(stat(buf, &st) < 0){
 224:	da840593          	addi	a1,s0,-600
 228:	dd040513          	addi	a0,s0,-560
 22c:	00000097          	auipc	ra,0x0
 230:	1e0080e7          	jalr	480(ra) # 40c <stat>
 234:	fa0546e3          	bltz	a0,1e0 <ls+0x12c>
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 238:	dd040513          	addi	a0,s0,-560
 23c:	00000097          	auipc	ra,0x0
 240:	dc4080e7          	jalr	-572(ra) # 0 <fmtname>
 244:	85aa                	mv	a1,a0
 246:	db843703          	ld	a4,-584(s0)
 24a:	dac42683          	lw	a3,-596(s0)
 24e:	db041603          	lh	a2,-592(s0)
 252:	00001517          	auipc	a0,0x1
 256:	89650513          	addi	a0,a0,-1898 # ae8 <malloc+0x158>
 25a:	00000097          	auipc	ra,0x0
 25e:	67a080e7          	jalr	1658(ra) # 8d4 <printf>
 262:	bf49                	j	1f4 <ls+0x140>
 264:	23813983          	ld	s3,568(sp)
 268:	bd75                	j	124 <ls+0x70>

000000000000026a <main>:

int
main(int argc, char *argv[])
{
 26a:	1101                	addi	sp,sp,-32
 26c:	ec06                	sd	ra,24(sp)
 26e:	e822                	sd	s0,16(sp)
 270:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
 272:	4785                	li	a5,1
 274:	02a7db63          	bge	a5,a0,2aa <main+0x40>
 278:	e426                	sd	s1,8(sp)
 27a:	e04a                	sd	s2,0(sp)
 27c:	00858493          	addi	s1,a1,8
 280:	ffe5091b          	addiw	s2,a0,-2
 284:	02091793          	slli	a5,s2,0x20
 288:	01d7d913          	srli	s2,a5,0x1d
 28c:	05c1                	addi	a1,a1,16
 28e:	992e                	add	s2,s2,a1
    ls(".");
    exit(0);
  }
  for(i=1; i<argc; i++)
    ls(argv[i]);
 290:	6088                	ld	a0,0(s1)
 292:	00000097          	auipc	ra,0x0
 296:	e22080e7          	jalr	-478(ra) # b4 <ls>
  for(i=1; i<argc; i++)
 29a:	04a1                	addi	s1,s1,8
 29c:	ff249ae3          	bne	s1,s2,290 <main+0x26>
  exit(0);
 2a0:	4501                	li	a0,0
 2a2:	00000097          	auipc	ra,0x0
 2a6:	2b4080e7          	jalr	692(ra) # 556 <exit>
 2aa:	e426                	sd	s1,8(sp)
 2ac:	e04a                	sd	s2,0(sp)
    ls(".");
 2ae:	00001517          	auipc	a0,0x1
 2b2:	84a50513          	addi	a0,a0,-1974 # af8 <malloc+0x168>
 2b6:	00000097          	auipc	ra,0x0
 2ba:	dfe080e7          	jalr	-514(ra) # b4 <ls>
    exit(0);
 2be:	4501                	li	a0,0
 2c0:	00000097          	auipc	ra,0x0
 2c4:	296080e7          	jalr	662(ra) # 556 <exit>

00000000000002c8 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 2c8:	1141                	addi	sp,sp,-16
 2ca:	e406                	sd	ra,8(sp)
 2cc:	e022                	sd	s0,0(sp)
 2ce:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2d0:	87aa                	mv	a5,a0
 2d2:	0585                	addi	a1,a1,1
 2d4:	0785                	addi	a5,a5,1
 2d6:	fff5c703          	lbu	a4,-1(a1)
 2da:	fee78fa3          	sb	a4,-1(a5)
 2de:	fb75                	bnez	a4,2d2 <strcpy+0xa>
    ;
  return os;
}
 2e0:	60a2                	ld	ra,8(sp)
 2e2:	6402                	ld	s0,0(sp)
 2e4:	0141                	addi	sp,sp,16
 2e6:	8082                	ret

00000000000002e8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2e8:	1141                	addi	sp,sp,-16
 2ea:	e406                	sd	ra,8(sp)
 2ec:	e022                	sd	s0,0(sp)
 2ee:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2f0:	00054783          	lbu	a5,0(a0)
 2f4:	cb91                	beqz	a5,308 <strcmp+0x20>
 2f6:	0005c703          	lbu	a4,0(a1)
 2fa:	00f71763          	bne	a4,a5,308 <strcmp+0x20>
    p++, q++;
 2fe:	0505                	addi	a0,a0,1
 300:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 302:	00054783          	lbu	a5,0(a0)
 306:	fbe5                	bnez	a5,2f6 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 308:	0005c503          	lbu	a0,0(a1)
}
 30c:	40a7853b          	subw	a0,a5,a0
 310:	60a2                	ld	ra,8(sp)
 312:	6402                	ld	s0,0(sp)
 314:	0141                	addi	sp,sp,16
 316:	8082                	ret

0000000000000318 <strlen>:

uint
strlen(const char *s)
{
 318:	1141                	addi	sp,sp,-16
 31a:	e406                	sd	ra,8(sp)
 31c:	e022                	sd	s0,0(sp)
 31e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 320:	00054783          	lbu	a5,0(a0)
 324:	cf91                	beqz	a5,340 <strlen+0x28>
 326:	00150793          	addi	a5,a0,1
 32a:	86be                	mv	a3,a5
 32c:	0785                	addi	a5,a5,1
 32e:	fff7c703          	lbu	a4,-1(a5)
 332:	ff65                	bnez	a4,32a <strlen+0x12>
 334:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 338:	60a2                	ld	ra,8(sp)
 33a:	6402                	ld	s0,0(sp)
 33c:	0141                	addi	sp,sp,16
 33e:	8082                	ret
  for(n = 0; s[n]; n++)
 340:	4501                	li	a0,0
 342:	bfdd                	j	338 <strlen+0x20>

0000000000000344 <memset>:

void*
memset(void *dst, int c, uint n)
{
 344:	1141                	addi	sp,sp,-16
 346:	e406                	sd	ra,8(sp)
 348:	e022                	sd	s0,0(sp)
 34a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 34c:	ca19                	beqz	a2,362 <memset+0x1e>
 34e:	87aa                	mv	a5,a0
 350:	1602                	slli	a2,a2,0x20
 352:	9201                	srli	a2,a2,0x20
 354:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 358:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 35c:	0785                	addi	a5,a5,1
 35e:	fee79de3          	bne	a5,a4,358 <memset+0x14>
  }
  return dst;
}
 362:	60a2                	ld	ra,8(sp)
 364:	6402                	ld	s0,0(sp)
 366:	0141                	addi	sp,sp,16
 368:	8082                	ret

000000000000036a <strchr>:

char*
strchr(const char *s, char c)
{
 36a:	1141                	addi	sp,sp,-16
 36c:	e406                	sd	ra,8(sp)
 36e:	e022                	sd	s0,0(sp)
 370:	0800                	addi	s0,sp,16
  for(; *s; s++)
 372:	00054783          	lbu	a5,0(a0)
 376:	cf81                	beqz	a5,38e <strchr+0x24>
    if(*s == c)
 378:	00f58763          	beq	a1,a5,386 <strchr+0x1c>
  for(; *s; s++)
 37c:	0505                	addi	a0,a0,1
 37e:	00054783          	lbu	a5,0(a0)
 382:	fbfd                	bnez	a5,378 <strchr+0xe>
      return (char*)s;
  return 0;
 384:	4501                	li	a0,0
}
 386:	60a2                	ld	ra,8(sp)
 388:	6402                	ld	s0,0(sp)
 38a:	0141                	addi	sp,sp,16
 38c:	8082                	ret
  return 0;
 38e:	4501                	li	a0,0
 390:	bfdd                	j	386 <strchr+0x1c>

0000000000000392 <gets>:

char*
gets(char *buf, int max)
{
 392:	711d                	addi	sp,sp,-96
 394:	ec86                	sd	ra,88(sp)
 396:	e8a2                	sd	s0,80(sp)
 398:	e4a6                	sd	s1,72(sp)
 39a:	e0ca                	sd	s2,64(sp)
 39c:	fc4e                	sd	s3,56(sp)
 39e:	f852                	sd	s4,48(sp)
 3a0:	f456                	sd	s5,40(sp)
 3a2:	f05a                	sd	s6,32(sp)
 3a4:	ec5e                	sd	s7,24(sp)
 3a6:	e862                	sd	s8,16(sp)
 3a8:	1080                	addi	s0,sp,96
 3aa:	8baa                	mv	s7,a0
 3ac:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3ae:	892a                	mv	s2,a0
 3b0:	4481                	li	s1,0
    cc = read(0, &c, 1);
 3b2:	faf40b13          	addi	s6,s0,-81
 3b6:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 3b8:	8c26                	mv	s8,s1
 3ba:	0014899b          	addiw	s3,s1,1
 3be:	84ce                	mv	s1,s3
 3c0:	0349d663          	bge	s3,s4,3ec <gets+0x5a>
    cc = read(0, &c, 1);
 3c4:	8656                	mv	a2,s5
 3c6:	85da                	mv	a1,s6
 3c8:	4501                	li	a0,0
 3ca:	00000097          	auipc	ra,0x0
 3ce:	1a4080e7          	jalr	420(ra) # 56e <read>
    if(cc < 1)
 3d2:	00a05d63          	blez	a0,3ec <gets+0x5a>
      break;
    buf[i++] = c;
 3d6:	faf44783          	lbu	a5,-81(s0)
 3da:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3de:	0905                	addi	s2,s2,1
 3e0:	ff678713          	addi	a4,a5,-10
 3e4:	c319                	beqz	a4,3ea <gets+0x58>
 3e6:	17cd                	addi	a5,a5,-13
 3e8:	fbe1                	bnez	a5,3b8 <gets+0x26>
    buf[i++] = c;
 3ea:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 3ec:	9c5e                	add	s8,s8,s7
 3ee:	000c0023          	sb	zero,0(s8)
  return buf;
}
 3f2:	855e                	mv	a0,s7
 3f4:	60e6                	ld	ra,88(sp)
 3f6:	6446                	ld	s0,80(sp)
 3f8:	64a6                	ld	s1,72(sp)
 3fa:	6906                	ld	s2,64(sp)
 3fc:	79e2                	ld	s3,56(sp)
 3fe:	7a42                	ld	s4,48(sp)
 400:	7aa2                	ld	s5,40(sp)
 402:	7b02                	ld	s6,32(sp)
 404:	6be2                	ld	s7,24(sp)
 406:	6c42                	ld	s8,16(sp)
 408:	6125                	addi	sp,sp,96
 40a:	8082                	ret

000000000000040c <stat>:

int
stat(const char *n, struct stat *st)
{
 40c:	1101                	addi	sp,sp,-32
 40e:	ec06                	sd	ra,24(sp)
 410:	e822                	sd	s0,16(sp)
 412:	e04a                	sd	s2,0(sp)
 414:	1000                	addi	s0,sp,32
 416:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 418:	4581                	li	a1,0
 41a:	00000097          	auipc	ra,0x0
 41e:	17c080e7          	jalr	380(ra) # 596 <open>
  if(fd < 0)
 422:	02054663          	bltz	a0,44e <stat+0x42>
 426:	e426                	sd	s1,8(sp)
 428:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 42a:	85ca                	mv	a1,s2
 42c:	00000097          	auipc	ra,0x0
 430:	182080e7          	jalr	386(ra) # 5ae <fstat>
 434:	892a                	mv	s2,a0
  close(fd);
 436:	8526                	mv	a0,s1
 438:	00000097          	auipc	ra,0x0
 43c:	146080e7          	jalr	326(ra) # 57e <close>
  return r;
 440:	64a2                	ld	s1,8(sp)
}
 442:	854a                	mv	a0,s2
 444:	60e2                	ld	ra,24(sp)
 446:	6442                	ld	s0,16(sp)
 448:	6902                	ld	s2,0(sp)
 44a:	6105                	addi	sp,sp,32
 44c:	8082                	ret
    return -1;
 44e:	57fd                	li	a5,-1
 450:	893e                	mv	s2,a5
 452:	bfc5                	j	442 <stat+0x36>

0000000000000454 <atoi>:

int
atoi(const char *s)
{
 454:	1141                	addi	sp,sp,-16
 456:	e406                	sd	ra,8(sp)
 458:	e022                	sd	s0,0(sp)
 45a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 45c:	00054683          	lbu	a3,0(a0)
 460:	fd06879b          	addiw	a5,a3,-48
 464:	0ff7f793          	zext.b	a5,a5
 468:	4625                	li	a2,9
 46a:	02f66963          	bltu	a2,a5,49c <atoi+0x48>
 46e:	872a                	mv	a4,a0
  n = 0;
 470:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 472:	0705                	addi	a4,a4,1
 474:	0025179b          	slliw	a5,a0,0x2
 478:	9fa9                	addw	a5,a5,a0
 47a:	0017979b          	slliw	a5,a5,0x1
 47e:	9fb5                	addw	a5,a5,a3
 480:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 484:	00074683          	lbu	a3,0(a4)
 488:	fd06879b          	addiw	a5,a3,-48
 48c:	0ff7f793          	zext.b	a5,a5
 490:	fef671e3          	bgeu	a2,a5,472 <atoi+0x1e>
  return n;
}
 494:	60a2                	ld	ra,8(sp)
 496:	6402                	ld	s0,0(sp)
 498:	0141                	addi	sp,sp,16
 49a:	8082                	ret
  n = 0;
 49c:	4501                	li	a0,0
 49e:	bfdd                	j	494 <atoi+0x40>

00000000000004a0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4a0:	1141                	addi	sp,sp,-16
 4a2:	e406                	sd	ra,8(sp)
 4a4:	e022                	sd	s0,0(sp)
 4a6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4a8:	02b57563          	bgeu	a0,a1,4d2 <memmove+0x32>
    while(n-- > 0)
 4ac:	00c05f63          	blez	a2,4ca <memmove+0x2a>
 4b0:	1602                	slli	a2,a2,0x20
 4b2:	9201                	srli	a2,a2,0x20
 4b4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4b8:	872a                	mv	a4,a0
      *dst++ = *src++;
 4ba:	0585                	addi	a1,a1,1
 4bc:	0705                	addi	a4,a4,1
 4be:	fff5c683          	lbu	a3,-1(a1)
 4c2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4c6:	fee79ae3          	bne	a5,a4,4ba <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4ca:	60a2                	ld	ra,8(sp)
 4cc:	6402                	ld	s0,0(sp)
 4ce:	0141                	addi	sp,sp,16
 4d0:	8082                	ret
    while(n-- > 0)
 4d2:	fec05ce3          	blez	a2,4ca <memmove+0x2a>
    dst += n;
 4d6:	00c50733          	add	a4,a0,a2
    src += n;
 4da:	95b2                	add	a1,a1,a2
 4dc:	fff6079b          	addiw	a5,a2,-1
 4e0:	1782                	slli	a5,a5,0x20
 4e2:	9381                	srli	a5,a5,0x20
 4e4:	fff7c793          	not	a5,a5
 4e8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4ea:	15fd                	addi	a1,a1,-1
 4ec:	177d                	addi	a4,a4,-1
 4ee:	0005c683          	lbu	a3,0(a1)
 4f2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4f6:	fef71ae3          	bne	a4,a5,4ea <memmove+0x4a>
 4fa:	bfc1                	j	4ca <memmove+0x2a>

00000000000004fc <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4fc:	1141                	addi	sp,sp,-16
 4fe:	e406                	sd	ra,8(sp)
 500:	e022                	sd	s0,0(sp)
 502:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 504:	c61d                	beqz	a2,532 <memcmp+0x36>
 506:	1602                	slli	a2,a2,0x20
 508:	9201                	srli	a2,a2,0x20
 50a:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 50e:	00054783          	lbu	a5,0(a0)
 512:	0005c703          	lbu	a4,0(a1)
 516:	00e79863          	bne	a5,a4,526 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 51a:	0505                	addi	a0,a0,1
    p2++;
 51c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 51e:	fed518e3          	bne	a0,a3,50e <memcmp+0x12>
  }
  return 0;
 522:	4501                	li	a0,0
 524:	a019                	j	52a <memcmp+0x2e>
      return *p1 - *p2;
 526:	40e7853b          	subw	a0,a5,a4
}
 52a:	60a2                	ld	ra,8(sp)
 52c:	6402                	ld	s0,0(sp)
 52e:	0141                	addi	sp,sp,16
 530:	8082                	ret
  return 0;
 532:	4501                	li	a0,0
 534:	bfdd                	j	52a <memcmp+0x2e>

0000000000000536 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 536:	1141                	addi	sp,sp,-16
 538:	e406                	sd	ra,8(sp)
 53a:	e022                	sd	s0,0(sp)
 53c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 53e:	00000097          	auipc	ra,0x0
 542:	f62080e7          	jalr	-158(ra) # 4a0 <memmove>
}
 546:	60a2                	ld	ra,8(sp)
 548:	6402                	ld	s0,0(sp)
 54a:	0141                	addi	sp,sp,16
 54c:	8082                	ret

000000000000054e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 54e:	4885                	li	a7,1
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <exit>:
.global exit
exit:
 li a7, SYS_exit
 556:	4889                	li	a7,2
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <wait>:
.global wait
wait:
 li a7, SYS_wait
 55e:	488d                	li	a7,3
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 566:	4891                	li	a7,4
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <read>:
.global read
read:
 li a7, SYS_read
 56e:	4895                	li	a7,5
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <write>:
.global write
write:
 li a7, SYS_write
 576:	48c1                	li	a7,16
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <close>:
.global close
close:
 li a7, SYS_close
 57e:	48d5                	li	a7,21
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <kill>:
.global kill
kill:
 li a7, SYS_kill
 586:	4899                	li	a7,6
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <exec>:
.global exec
exec:
 li a7, SYS_exec
 58e:	489d                	li	a7,7
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <open>:
.global open
open:
 li a7, SYS_open
 596:	48bd                	li	a7,15
 ecall
 598:	00000073          	ecall
 ret
 59c:	8082                	ret

000000000000059e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 59e:	48c5                	li	a7,17
 ecall
 5a0:	00000073          	ecall
 ret
 5a4:	8082                	ret

00000000000005a6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5a6:	48c9                	li	a7,18
 ecall
 5a8:	00000073          	ecall
 ret
 5ac:	8082                	ret

00000000000005ae <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5ae:	48a1                	li	a7,8
 ecall
 5b0:	00000073          	ecall
 ret
 5b4:	8082                	ret

00000000000005b6 <link>:
.global link
link:
 li a7, SYS_link
 5b6:	48cd                	li	a7,19
 ecall
 5b8:	00000073          	ecall
 ret
 5bc:	8082                	ret

00000000000005be <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5be:	48d1                	li	a7,20
 ecall
 5c0:	00000073          	ecall
 ret
 5c4:	8082                	ret

00000000000005c6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5c6:	48a5                	li	a7,9
 ecall
 5c8:	00000073          	ecall
 ret
 5cc:	8082                	ret

00000000000005ce <dup>:
.global dup
dup:
 li a7, SYS_dup
 5ce:	48a9                	li	a7,10
 ecall
 5d0:	00000073          	ecall
 ret
 5d4:	8082                	ret

00000000000005d6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5d6:	48ad                	li	a7,11
 ecall
 5d8:	00000073          	ecall
 ret
 5dc:	8082                	ret

00000000000005de <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5de:	48b1                	li	a7,12
 ecall
 5e0:	00000073          	ecall
 ret
 5e4:	8082                	ret

00000000000005e6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5e6:	48b5                	li	a7,13
 ecall
 5e8:	00000073          	ecall
 ret
 5ec:	8082                	ret

00000000000005ee <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5ee:	48b9                	li	a7,14
 ecall
 5f0:	00000073          	ecall
 ret
 5f4:	8082                	ret

00000000000005f6 <trace>:
.global trace
trace:
 li a7, SYS_trace
 5f6:	48d9                	li	a7,22
 ecall
 5f8:	00000073          	ecall
 ret
 5fc:	8082                	ret

00000000000005fe <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 5fe:	48dd                	li	a7,23
 ecall
 600:	00000073          	ecall
 ret
 604:	8082                	ret

0000000000000606 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 606:	48e1                	li	a7,24
 ecall
 608:	00000073          	ecall
 ret
 60c:	8082                	ret

000000000000060e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 60e:	1101                	addi	sp,sp,-32
 610:	ec06                	sd	ra,24(sp)
 612:	e822                	sd	s0,16(sp)
 614:	1000                	addi	s0,sp,32
 616:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 61a:	4605                	li	a2,1
 61c:	fef40593          	addi	a1,s0,-17
 620:	00000097          	auipc	ra,0x0
 624:	f56080e7          	jalr	-170(ra) # 576 <write>
}
 628:	60e2                	ld	ra,24(sp)
 62a:	6442                	ld	s0,16(sp)
 62c:	6105                	addi	sp,sp,32
 62e:	8082                	ret

0000000000000630 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 630:	7139                	addi	sp,sp,-64
 632:	fc06                	sd	ra,56(sp)
 634:	f822                	sd	s0,48(sp)
 636:	f04a                	sd	s2,32(sp)
 638:	ec4e                	sd	s3,24(sp)
 63a:	0080                	addi	s0,sp,64
 63c:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 63e:	cad9                	beqz	a3,6d4 <printint+0xa4>
 640:	01f5d79b          	srliw	a5,a1,0x1f
 644:	cbc1                	beqz	a5,6d4 <printint+0xa4>
    neg = 1;
    x = -xx;
 646:	40b005bb          	negw	a1,a1
    neg = 1;
 64a:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 64c:	fc040993          	addi	s3,s0,-64
  neg = 0;
 650:	86ce                	mv	a3,s3
  i = 0;
 652:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 654:	00000817          	auipc	a6,0x0
 658:	50c80813          	addi	a6,a6,1292 # b60 <digits>
 65c:	88ba                	mv	a7,a4
 65e:	0017051b          	addiw	a0,a4,1
 662:	872a                	mv	a4,a0
 664:	02c5f7bb          	remuw	a5,a1,a2
 668:	1782                	slli	a5,a5,0x20
 66a:	9381                	srli	a5,a5,0x20
 66c:	97c2                	add	a5,a5,a6
 66e:	0007c783          	lbu	a5,0(a5)
 672:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 676:	87ae                	mv	a5,a1
 678:	02c5d5bb          	divuw	a1,a1,a2
 67c:	0685                	addi	a3,a3,1
 67e:	fcc7ffe3          	bgeu	a5,a2,65c <printint+0x2c>
  if(neg)
 682:	00030c63          	beqz	t1,69a <printint+0x6a>
    buf[i++] = '-';
 686:	fd050793          	addi	a5,a0,-48
 68a:	00878533          	add	a0,a5,s0
 68e:	02d00793          	li	a5,45
 692:	fef50823          	sb	a5,-16(a0)
 696:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 69a:	02e05763          	blez	a4,6c8 <printint+0x98>
 69e:	f426                	sd	s1,40(sp)
 6a0:	377d                	addiw	a4,a4,-1
 6a2:	00e984b3          	add	s1,s3,a4
 6a6:	19fd                	addi	s3,s3,-1
 6a8:	99ba                	add	s3,s3,a4
 6aa:	1702                	slli	a4,a4,0x20
 6ac:	9301                	srli	a4,a4,0x20
 6ae:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6b2:	0004c583          	lbu	a1,0(s1)
 6b6:	854a                	mv	a0,s2
 6b8:	00000097          	auipc	ra,0x0
 6bc:	f56080e7          	jalr	-170(ra) # 60e <putc>
  while(--i >= 0)
 6c0:	14fd                	addi	s1,s1,-1
 6c2:	ff3498e3          	bne	s1,s3,6b2 <printint+0x82>
 6c6:	74a2                	ld	s1,40(sp)
}
 6c8:	70e2                	ld	ra,56(sp)
 6ca:	7442                	ld	s0,48(sp)
 6cc:	7902                	ld	s2,32(sp)
 6ce:	69e2                	ld	s3,24(sp)
 6d0:	6121                	addi	sp,sp,64
 6d2:	8082                	ret
  neg = 0;
 6d4:	4301                	li	t1,0
 6d6:	bf9d                	j	64c <printint+0x1c>

00000000000006d8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6d8:	715d                	addi	sp,sp,-80
 6da:	e486                	sd	ra,72(sp)
 6dc:	e0a2                	sd	s0,64(sp)
 6de:	f84a                	sd	s2,48(sp)
 6e0:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6e2:	0005c903          	lbu	s2,0(a1)
 6e6:	1a090b63          	beqz	s2,89c <vprintf+0x1c4>
 6ea:	fc26                	sd	s1,56(sp)
 6ec:	f44e                	sd	s3,40(sp)
 6ee:	f052                	sd	s4,32(sp)
 6f0:	ec56                	sd	s5,24(sp)
 6f2:	e85a                	sd	s6,16(sp)
 6f4:	e45e                	sd	s7,8(sp)
 6f6:	8aaa                	mv	s5,a0
 6f8:	8bb2                	mv	s7,a2
 6fa:	00158493          	addi	s1,a1,1
  state = 0;
 6fe:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 700:	02500a13          	li	s4,37
 704:	4b55                	li	s6,21
 706:	a839                	j	724 <vprintf+0x4c>
        putc(fd, c);
 708:	85ca                	mv	a1,s2
 70a:	8556                	mv	a0,s5
 70c:	00000097          	auipc	ra,0x0
 710:	f02080e7          	jalr	-254(ra) # 60e <putc>
 714:	a019                	j	71a <vprintf+0x42>
    } else if(state == '%'){
 716:	01498d63          	beq	s3,s4,730 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 71a:	0485                	addi	s1,s1,1
 71c:	fff4c903          	lbu	s2,-1(s1)
 720:	16090863          	beqz	s2,890 <vprintf+0x1b8>
    if(state == 0){
 724:	fe0999e3          	bnez	s3,716 <vprintf+0x3e>
      if(c == '%'){
 728:	ff4910e3          	bne	s2,s4,708 <vprintf+0x30>
        state = '%';
 72c:	89d2                	mv	s3,s4
 72e:	b7f5                	j	71a <vprintf+0x42>
      if(c == 'd'){
 730:	13490563          	beq	s2,s4,85a <vprintf+0x182>
 734:	f9d9079b          	addiw	a5,s2,-99
 738:	0ff7f793          	zext.b	a5,a5
 73c:	12fb6863          	bltu	s6,a5,86c <vprintf+0x194>
 740:	f9d9079b          	addiw	a5,s2,-99
 744:	0ff7f713          	zext.b	a4,a5
 748:	12eb6263          	bltu	s6,a4,86c <vprintf+0x194>
 74c:	00271793          	slli	a5,a4,0x2
 750:	00000717          	auipc	a4,0x0
 754:	3b870713          	addi	a4,a4,952 # b08 <malloc+0x178>
 758:	97ba                	add	a5,a5,a4
 75a:	439c                	lw	a5,0(a5)
 75c:	97ba                	add	a5,a5,a4
 75e:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 760:	008b8913          	addi	s2,s7,8
 764:	4685                	li	a3,1
 766:	4629                	li	a2,10
 768:	000ba583          	lw	a1,0(s7)
 76c:	8556                	mv	a0,s5
 76e:	00000097          	auipc	ra,0x0
 772:	ec2080e7          	jalr	-318(ra) # 630 <printint>
 776:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 778:	4981                	li	s3,0
 77a:	b745                	j	71a <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 77c:	008b8913          	addi	s2,s7,8
 780:	4681                	li	a3,0
 782:	4629                	li	a2,10
 784:	000ba583          	lw	a1,0(s7)
 788:	8556                	mv	a0,s5
 78a:	00000097          	auipc	ra,0x0
 78e:	ea6080e7          	jalr	-346(ra) # 630 <printint>
 792:	8bca                	mv	s7,s2
      state = 0;
 794:	4981                	li	s3,0
 796:	b751                	j	71a <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 798:	008b8913          	addi	s2,s7,8
 79c:	4681                	li	a3,0
 79e:	4641                	li	a2,16
 7a0:	000ba583          	lw	a1,0(s7)
 7a4:	8556                	mv	a0,s5
 7a6:	00000097          	auipc	ra,0x0
 7aa:	e8a080e7          	jalr	-374(ra) # 630 <printint>
 7ae:	8bca                	mv	s7,s2
      state = 0;
 7b0:	4981                	li	s3,0
 7b2:	b7a5                	j	71a <vprintf+0x42>
 7b4:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 7b6:	008b8793          	addi	a5,s7,8
 7ba:	8c3e                	mv	s8,a5
 7bc:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7c0:	03000593          	li	a1,48
 7c4:	8556                	mv	a0,s5
 7c6:	00000097          	auipc	ra,0x0
 7ca:	e48080e7          	jalr	-440(ra) # 60e <putc>
  putc(fd, 'x');
 7ce:	07800593          	li	a1,120
 7d2:	8556                	mv	a0,s5
 7d4:	00000097          	auipc	ra,0x0
 7d8:	e3a080e7          	jalr	-454(ra) # 60e <putc>
 7dc:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7de:	00000b97          	auipc	s7,0x0
 7e2:	382b8b93          	addi	s7,s7,898 # b60 <digits>
 7e6:	03c9d793          	srli	a5,s3,0x3c
 7ea:	97de                	add	a5,a5,s7
 7ec:	0007c583          	lbu	a1,0(a5)
 7f0:	8556                	mv	a0,s5
 7f2:	00000097          	auipc	ra,0x0
 7f6:	e1c080e7          	jalr	-484(ra) # 60e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7fa:	0992                	slli	s3,s3,0x4
 7fc:	397d                	addiw	s2,s2,-1
 7fe:	fe0914e3          	bnez	s2,7e6 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
 802:	8be2                	mv	s7,s8
      state = 0;
 804:	4981                	li	s3,0
 806:	6c02                	ld	s8,0(sp)
 808:	bf09                	j	71a <vprintf+0x42>
        s = va_arg(ap, char*);
 80a:	008b8993          	addi	s3,s7,8
 80e:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 812:	02090163          	beqz	s2,834 <vprintf+0x15c>
        while(*s != 0){
 816:	00094583          	lbu	a1,0(s2)
 81a:	c9a5                	beqz	a1,88a <vprintf+0x1b2>
          putc(fd, *s);
 81c:	8556                	mv	a0,s5
 81e:	00000097          	auipc	ra,0x0
 822:	df0080e7          	jalr	-528(ra) # 60e <putc>
          s++;
 826:	0905                	addi	s2,s2,1
        while(*s != 0){
 828:	00094583          	lbu	a1,0(s2)
 82c:	f9e5                	bnez	a1,81c <vprintf+0x144>
        s = va_arg(ap, char*);
 82e:	8bce                	mv	s7,s3
      state = 0;
 830:	4981                	li	s3,0
 832:	b5e5                	j	71a <vprintf+0x42>
          s = "(null)";
 834:	00000917          	auipc	s2,0x0
 838:	2cc90913          	addi	s2,s2,716 # b00 <malloc+0x170>
        while(*s != 0){
 83c:	02800593          	li	a1,40
 840:	bff1                	j	81c <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
 842:	008b8913          	addi	s2,s7,8
 846:	000bc583          	lbu	a1,0(s7)
 84a:	8556                	mv	a0,s5
 84c:	00000097          	auipc	ra,0x0
 850:	dc2080e7          	jalr	-574(ra) # 60e <putc>
 854:	8bca                	mv	s7,s2
      state = 0;
 856:	4981                	li	s3,0
 858:	b5c9                	j	71a <vprintf+0x42>
        putc(fd, c);
 85a:	02500593          	li	a1,37
 85e:	8556                	mv	a0,s5
 860:	00000097          	auipc	ra,0x0
 864:	dae080e7          	jalr	-594(ra) # 60e <putc>
      state = 0;
 868:	4981                	li	s3,0
 86a:	bd45                	j	71a <vprintf+0x42>
        putc(fd, '%');
 86c:	02500593          	li	a1,37
 870:	8556                	mv	a0,s5
 872:	00000097          	auipc	ra,0x0
 876:	d9c080e7          	jalr	-612(ra) # 60e <putc>
        putc(fd, c);
 87a:	85ca                	mv	a1,s2
 87c:	8556                	mv	a0,s5
 87e:	00000097          	auipc	ra,0x0
 882:	d90080e7          	jalr	-624(ra) # 60e <putc>
      state = 0;
 886:	4981                	li	s3,0
 888:	bd49                	j	71a <vprintf+0x42>
        s = va_arg(ap, char*);
 88a:	8bce                	mv	s7,s3
      state = 0;
 88c:	4981                	li	s3,0
 88e:	b571                	j	71a <vprintf+0x42>
 890:	74e2                	ld	s1,56(sp)
 892:	79a2                	ld	s3,40(sp)
 894:	7a02                	ld	s4,32(sp)
 896:	6ae2                	ld	s5,24(sp)
 898:	6b42                	ld	s6,16(sp)
 89a:	6ba2                	ld	s7,8(sp)
    }
  }
}
 89c:	60a6                	ld	ra,72(sp)
 89e:	6406                	ld	s0,64(sp)
 8a0:	7942                	ld	s2,48(sp)
 8a2:	6161                	addi	sp,sp,80
 8a4:	8082                	ret

00000000000008a6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8a6:	715d                	addi	sp,sp,-80
 8a8:	ec06                	sd	ra,24(sp)
 8aa:	e822                	sd	s0,16(sp)
 8ac:	1000                	addi	s0,sp,32
 8ae:	e010                	sd	a2,0(s0)
 8b0:	e414                	sd	a3,8(s0)
 8b2:	e818                	sd	a4,16(s0)
 8b4:	ec1c                	sd	a5,24(s0)
 8b6:	03043023          	sd	a6,32(s0)
 8ba:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8be:	8622                	mv	a2,s0
 8c0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8c4:	00000097          	auipc	ra,0x0
 8c8:	e14080e7          	jalr	-492(ra) # 6d8 <vprintf>
}
 8cc:	60e2                	ld	ra,24(sp)
 8ce:	6442                	ld	s0,16(sp)
 8d0:	6161                	addi	sp,sp,80
 8d2:	8082                	ret

00000000000008d4 <printf>:

void
printf(const char *fmt, ...)
{
 8d4:	711d                	addi	sp,sp,-96
 8d6:	ec06                	sd	ra,24(sp)
 8d8:	e822                	sd	s0,16(sp)
 8da:	1000                	addi	s0,sp,32
 8dc:	e40c                	sd	a1,8(s0)
 8de:	e810                	sd	a2,16(s0)
 8e0:	ec14                	sd	a3,24(s0)
 8e2:	f018                	sd	a4,32(s0)
 8e4:	f41c                	sd	a5,40(s0)
 8e6:	03043823          	sd	a6,48(s0)
 8ea:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8ee:	00840613          	addi	a2,s0,8
 8f2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8f6:	85aa                	mv	a1,a0
 8f8:	4505                	li	a0,1
 8fa:	00000097          	auipc	ra,0x0
 8fe:	dde080e7          	jalr	-546(ra) # 6d8 <vprintf>
}
 902:	60e2                	ld	ra,24(sp)
 904:	6442                	ld	s0,16(sp)
 906:	6125                	addi	sp,sp,96
 908:	8082                	ret

000000000000090a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 90a:	1141                	addi	sp,sp,-16
 90c:	e406                	sd	ra,8(sp)
 90e:	e022                	sd	s0,0(sp)
 910:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 912:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 916:	00000797          	auipc	a5,0x0
 91a:	6ca7b783          	ld	a5,1738(a5) # fe0 <freep>
 91e:	a039                	j	92c <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 920:	6398                	ld	a4,0(a5)
 922:	00e7e463          	bltu	a5,a4,92a <free+0x20>
 926:	00e6ea63          	bltu	a3,a4,93a <free+0x30>
{
 92a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 92c:	fed7fae3          	bgeu	a5,a3,920 <free+0x16>
 930:	6398                	ld	a4,0(a5)
 932:	00e6e463          	bltu	a3,a4,93a <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 936:	fee7eae3          	bltu	a5,a4,92a <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 93a:	ff852583          	lw	a1,-8(a0)
 93e:	6390                	ld	a2,0(a5)
 940:	02059813          	slli	a6,a1,0x20
 944:	01c85713          	srli	a4,a6,0x1c
 948:	9736                	add	a4,a4,a3
 94a:	02e60563          	beq	a2,a4,974 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 94e:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 952:	4790                	lw	a2,8(a5)
 954:	02061593          	slli	a1,a2,0x20
 958:	01c5d713          	srli	a4,a1,0x1c
 95c:	973e                	add	a4,a4,a5
 95e:	02e68263          	beq	a3,a4,982 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 962:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 964:	00000717          	auipc	a4,0x0
 968:	66f73e23          	sd	a5,1660(a4) # fe0 <freep>
}
 96c:	60a2                	ld	ra,8(sp)
 96e:	6402                	ld	s0,0(sp)
 970:	0141                	addi	sp,sp,16
 972:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 974:	4618                	lw	a4,8(a2)
 976:	9f2d                	addw	a4,a4,a1
 978:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 97c:	6398                	ld	a4,0(a5)
 97e:	6310                	ld	a2,0(a4)
 980:	b7f9                	j	94e <free+0x44>
    p->s.size += bp->s.size;
 982:	ff852703          	lw	a4,-8(a0)
 986:	9f31                	addw	a4,a4,a2
 988:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 98a:	ff053683          	ld	a3,-16(a0)
 98e:	bfd1                	j	962 <free+0x58>

0000000000000990 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 990:	7139                	addi	sp,sp,-64
 992:	fc06                	sd	ra,56(sp)
 994:	f822                	sd	s0,48(sp)
 996:	f04a                	sd	s2,32(sp)
 998:	ec4e                	sd	s3,24(sp)
 99a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 99c:	02051993          	slli	s3,a0,0x20
 9a0:	0209d993          	srli	s3,s3,0x20
 9a4:	09bd                	addi	s3,s3,15
 9a6:	0049d993          	srli	s3,s3,0x4
 9aa:	2985                	addiw	s3,s3,1
 9ac:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 9ae:	00000517          	auipc	a0,0x0
 9b2:	63253503          	ld	a0,1586(a0) # fe0 <freep>
 9b6:	c905                	beqz	a0,9e6 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9ba:	4798                	lw	a4,8(a5)
 9bc:	09377a63          	bgeu	a4,s3,a50 <malloc+0xc0>
 9c0:	f426                	sd	s1,40(sp)
 9c2:	e852                	sd	s4,16(sp)
 9c4:	e456                	sd	s5,8(sp)
 9c6:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 9c8:	8a4e                	mv	s4,s3
 9ca:	6705                	lui	a4,0x1
 9cc:	00e9f363          	bgeu	s3,a4,9d2 <malloc+0x42>
 9d0:	6a05                	lui	s4,0x1
 9d2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9d6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9da:	00000497          	auipc	s1,0x0
 9de:	60648493          	addi	s1,s1,1542 # fe0 <freep>
  if(p == (char*)-1)
 9e2:	5afd                	li	s5,-1
 9e4:	a089                	j	a26 <malloc+0x96>
 9e6:	f426                	sd	s1,40(sp)
 9e8:	e852                	sd	s4,16(sp)
 9ea:	e456                	sd	s5,8(sp)
 9ec:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9ee:	00000797          	auipc	a5,0x0
 9f2:	60a78793          	addi	a5,a5,1546 # ff8 <base>
 9f6:	00000717          	auipc	a4,0x0
 9fa:	5ef73523          	sd	a5,1514(a4) # fe0 <freep>
 9fe:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a00:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a04:	b7d1                	j	9c8 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 a06:	6398                	ld	a4,0(a5)
 a08:	e118                	sd	a4,0(a0)
 a0a:	a8b9                	j	a68 <malloc+0xd8>
  hp->s.size = nu;
 a0c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a10:	0541                	addi	a0,a0,16
 a12:	00000097          	auipc	ra,0x0
 a16:	ef8080e7          	jalr	-264(ra) # 90a <free>
  return freep;
 a1a:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 a1c:	c135                	beqz	a0,a80 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a1e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a20:	4798                	lw	a4,8(a5)
 a22:	03277363          	bgeu	a4,s2,a48 <malloc+0xb8>
    if(p == freep)
 a26:	6098                	ld	a4,0(s1)
 a28:	853e                	mv	a0,a5
 a2a:	fef71ae3          	bne	a4,a5,a1e <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 a2e:	8552                	mv	a0,s4
 a30:	00000097          	auipc	ra,0x0
 a34:	bae080e7          	jalr	-1106(ra) # 5de <sbrk>
  if(p == (char*)-1)
 a38:	fd551ae3          	bne	a0,s5,a0c <malloc+0x7c>
        return 0;
 a3c:	4501                	li	a0,0
 a3e:	74a2                	ld	s1,40(sp)
 a40:	6a42                	ld	s4,16(sp)
 a42:	6aa2                	ld	s5,8(sp)
 a44:	6b02                	ld	s6,0(sp)
 a46:	a03d                	j	a74 <malloc+0xe4>
 a48:	74a2                	ld	s1,40(sp)
 a4a:	6a42                	ld	s4,16(sp)
 a4c:	6aa2                	ld	s5,8(sp)
 a4e:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a50:	fae90be3          	beq	s2,a4,a06 <malloc+0x76>
        p->s.size -= nunits;
 a54:	4137073b          	subw	a4,a4,s3
 a58:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a5a:	02071693          	slli	a3,a4,0x20
 a5e:	01c6d713          	srli	a4,a3,0x1c
 a62:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a64:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a68:	00000717          	auipc	a4,0x0
 a6c:	56a73c23          	sd	a0,1400(a4) # fe0 <freep>
      return (void*)(p + 1);
 a70:	01078513          	addi	a0,a5,16
  }
}
 a74:	70e2                	ld	ra,56(sp)
 a76:	7442                	ld	s0,48(sp)
 a78:	7902                	ld	s2,32(sp)
 a7a:	69e2                	ld	s3,24(sp)
 a7c:	6121                	addi	sp,sp,64
 a7e:	8082                	ret
 a80:	74a2                	ld	s1,40(sp)
 a82:	6a42                	ld	s4,16(sp)
 a84:	6aa2                	ld	s5,8(sp)
 a86:	6b02                	ld	s6,0(sp)
 a88:	b7f5                	j	a74 <malloc+0xe4>
