#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main() {

  printf("\n====== Prueba del limite de memoria ======\n\n");

  uint64 total = 0;   // memoria total solicitada

  for(int i = 0; i < 200000; i++){

    printf("[Iter %d] Memoria actual: %d bytes\n", i, total);

    // CASO 1: solicitar 4 KB
    void *r1 = sbrk(4096);
    if((long)r1 == -1){
      printf("❌ ERROR: Memoria denegada al pedir 4096 bytes (4 KB) en iteracion %d\n", i);
      printf("Memoria total alcanzada: %d bytes\n", total);
      exit(0);
    }
    total += 4096;
    printf("  ✓ Se asignaron 4096 bytes, total = %d\n", total);

    // CASO 2: solicitar 128 bytes
    void *r2 = sbrk(128);
    if((long)r2 == -1){
      printf("❌ ERROR: Memoria denegada al pedir 128 bytes en iteracion %d\n", i);
      printf("Memoria total alcanzada: %d bytes\n", total);
      exit(0);
    }
    total += 128;
    printf("  ✓ Se asignaron 128 bytes, total = %d\n", total);

    // CASO 3: solicitar 1 byte (prueba fina)
    void *r3 = sbrk(1);
    if((long)r3 == -1){
      printf("❌ ERROR: Memoria denegada al pedir 1 byte en iteracion %d\n", i);
      printf("Memoria total alcanzada: %d bytes\n", total);
      exit(0);
    }
    total += 1;
    printf("  ✓ Se asigno 1 byte, total = %d\n", total);

    // CASO 4: solicitar 0 bytes (solo verificar direccion)
    void *addr = sbrk(0);
    printf("  ➤ Direccion final del break: %p\n", addr);
    
    printf("-----------------------------------------------\n");
  }

  printf("❗ ERROR CRITICO: el proceso crecio sin limite\n");
  exit(0);
}
