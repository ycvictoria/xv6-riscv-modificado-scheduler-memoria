#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main() {
  printf("Probando limite de memoria...\n");

  for(int i = 0; i < 200000; i++){
    if((int)sbrk(4096) == -1){
      printf("Memoria denegada en iteracion %d\n", i);
      exit(0);
    }
  }

  printf("ERROR: el proceso crecio sin limite\n");
  exit(0);
}
