#!/bin/bash

echo "[1/7] Quitando -Werror del user/Makefile..."
sed -i 's/-Werror//g' user/Makefile

echo "[2/7] Quitando -Werror del kernel/Makefile..."
sed -i 's/-Werror//g' kernel/Makefile

echo "[3/7] Añadiendo -Wno-infinite-recursion..."
grep -q "Wno-infinite-recursion" user/Makefile || echo 'CFLAGS += -Wno-infinite-recursion' >> user/Makefile

echo "[4/7] Reparando rwsbrk(char *unused) en usertests..."
sed -i 's/^rwsbrk()$/rwsbrk(char *unused)/' user/usertests.c
sed -i 's/rwsbrk(void)/rwsbrk(char *unused)/' user/usertests.c

echo "[5/7] Arreglando prototipos sbrk si existen..."
sed -i 's/sbrk(void)/sbrk(int)/' user/usertests.c 2>/dev/null

echo "[6/7] Corrigiendo llamadas a funciones sin argumentos..."
sed -i 's/char \*sbrk()/char *sbrk(int)/' user/usertests.c 2>/dev/null

echo "[7/7] Sincronizando permisos..."
chmod +x fix-xv6.sh

echo "---------------------------------------------"
echo "Arreglos completados."
echo "Ahora ejecuta:"
echo "   make clean"
echo "   make qemu SCHEDULER=PBS"
echo "---------------------------------------------"
