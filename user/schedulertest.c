#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

#define NFORK 20
#define IO 5

// Importante: usar NPROC (max procesos en xv6, usualmente 64)
#define NPROC 64

int main() {
    int n, pid;
    int wtime, rtime;

    int tipo[NPROC];
    int prioridad[NPROC];

    printf("\n===== Test PBS Mejorado =====\n");
    printf("Creando %d procesos (%d IO-bound, %d CPU-bound)\n\n",
           NFORK, IO, NFORK - IO);

    for (n = 0; n < NFORK; n++) {

        pid = fork();
        if (pid < 0) break;

        if (pid == 0) {
            // Hijos
            if (n < IO) {
                sleep(200);
            } else {
                for (volatile int i = 0; i < 1000000000; i++) {}
            }
            exit(0);
        }
        else {
            if (pid < NPROC)
                tipo[pid] = (n < IO);

#ifdef PBS
            int pr = (n < IO) ? 80 : 60;

            setpriority(pr, pid);

            if (pid < NPROC)
                prioridad[pid] = pr;
#else
            if (pid < NPROC)
                prioridad[pid] = -1;
#endif
        }
    }

    printf("PID   TIPO   PRIO   RTIME   WTIME   TURNAROUND\n");
    printf("-----------------------------------------------------\n");

    int total_r = 0, total_w = 0;

    for (; n > 0; n--) {

        pid = waitx(0, &rtime, &wtime);
        int turnaround = rtime + wtime;

        total_r += rtime;
        total_w += wtime;

        printf("%3d   %4s   %4d   %5d   %5d   %8d\n",
               pid,
               (pid < NPROC && tipo[pid]) ? "IO" : "CPU",
               (pid < NPROC) ? prioridad[pid] : -1,
               rtime,
               wtime,
               turnaround
        );
    }

    printf("-----------------------------------------------------\n");
    printf("Promedio rtime: %d\n", total_r / NFORK);
    printf("Promedio wtime: %d\n", total_w / NFORK);
    printf("=====================================================\n\n");

    exit(0);
}
