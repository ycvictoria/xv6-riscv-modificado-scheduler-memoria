#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

// Numero total de procesos que se van a crear
#define NFORK 10

// Numero de procesos que se comportaran como IO-bound
#define IO 5

int main() {
  int n, pid;
  int wtime, rtime;        // variables para recibir tiempos de wait y run de waitx()
  int twtime = 0, trtime = 0;  // acumuladores para promedios

  // Bucle principal donde se crean los procesos hijos
  for(n = 0; n < NFORK; n++) {

      // Crear proceso hijo
      pid = fork();

      // Error al crear proceso
      if (pid < 0)
          break;

      // ------------------------------------------------------------------
      // CODIGO DEL HIJO
      if (pid == 0) {

#ifndef FCFS
          // Si el hijo esta dentro de los primeros IO procesos
          if (n < IO) {
            // Simula un proceso IO-bound, se duerme 200 ticks
            sleep(200);
          } else {
#endif
            // Simula un proceso CPU-bound ejecutando un ciclo muy largo
            for (volatile int i = 0; i < 1000000000; i++) {}
#ifndef FCFS
          }
#endif

          // Indica que el hijo termino su ejecucion
          printf("Process %d finished\n", n);
          
          // Termina el hijo
          exit(0);
      } 
      
      // ------------------------------------------------------------------
      // CODIGO DEL PADRE (solo para PBS)
      // ------------------------------------------------------------------
      else {
#ifdef PBS
        // Asigna prioridad estatica al hijo
        // En PBS, una prioridad mas baja significa mayor prioridad
        // Aqui se asigna 80 por defecto (baja prioridad)
        setpriority(80, pid);
#endif
      }
  }

  // Bucle donde el padre espera a todos los hijos y acumula estadisticas
  for(; n > 0; n--) {

      // waitx recibe los tiempos de ejecucion y espera de cada hijo
      if(waitx(0, &rtime, &wtime) >= 0) {
          trtime += rtime;   // acumula tiempo de CPU
          twtime += wtime;   // acumula tiempo de espera
      }
  }
  // Impresion de promedios finales
  printf("Average rtime %d,  wtime %d\n", trtime / NFORK, twtime / NFORK);

  exit(0);
}
