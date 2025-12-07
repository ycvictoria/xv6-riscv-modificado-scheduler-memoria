#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

// Arreglo que representa los CPUs del sistema
struct cpu cpus[NCPU];

// Tabla de procesos global
struct proc proc[NPROC];

// Proceso init, primer proceso de usuario
struct proc *initproc;

// Siguiente PID disponible
int nextpid = 1;

// Lock para proteger la generacion de PIDs
struct spinlock pid_lock;

extern void forkret(void);
static void freeproc(struct proc *p);

// Codigo del trampolin usado para manejar interrupciones y traps
extern char trampoline[]; 

// Lock global usado por wait() para evitar condiciones de carrera
struct spinlock wait_lock;

// Mapea un stack de kernel para cada proceso
void
proc_mapstacks(pagetable_t kpgtbl) {
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    char *pa = kalloc(); // se reserva memoria fisica
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc)); // direccion virtual del stack del proceso
    // Se mapea el stack del kernel en el espacio del kernel
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
  }
}

// Inicializa la tabla de procesos al arrancar el sistema
void
procinit(void)
{
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");   // lock para generar PIDs
  initlock(&wait_lock, "wait_lock");// lock para wait()

  for(p = proc; p < &proc[NPROC]; p++) {
      initlock(&p->lock, "proc");   // lock por proceso
      p->kstack = KSTACK((int) (p - proc)); // direccion del stack del kernel
  }
}

// Retorna el ID del CPU actual
int
cpuid()
{
  int id = r_tp(); // tp contiene el hartid
  return id;
}

// Retorna la estructura cpu correspondiente al CPU actual
struct cpu*
mycpu(void) {
  int id = cpuid();
  struct cpu *c = &cpus[id];
  return c;
}

// Retorna el proceso actual en ejecucion
struct proc*
myproc(void) {
  push_off(); // deshabilitar interrupciones
  struct cpu *c = mycpu(); 
  struct proc *p = c->proc;
  pop_off();
  return p;
}

// Genera un nuevo PID usando un lock
int
allocpid() {
  int pid;
  
  acquire(&pid_lock);
  pid = nextpid;
  nextpid = nextpid + 1; // incrementa PID
  release(&pid_lock);

  return pid;
}

// Busca un proceso en estado UNUSED para inicializarlo
static struct proc*
allocproc(void)
{
  struct proc *p;

  // Se recorre la tabla de procesos
  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);

    if(p->state == UNUSED) {
      goto found; // proceso libre encontrado
    } else {
      release(&p->lock);
    }
  }
  return 0;

found:
  p->pid = allocpid();   // asignar un PID
  p->state = USED;       // el proceso ahora esta ocupado

  // Inicializar estadisticas de tiempos
  p->create_time = ticks;
  p->run_time = 0;
  p->start_time = 0;
  p->sleep_time = 0;
  p->total_run_time = 0;
  p->exit_time = 0;
  p->n_runs = 0;

  p->priority = 60; // prioridad por defecto usada en PBS

  // Reservar la trapframe para syscalls y traps
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    freeproc(p); // si falla memoria se limpia el proceso
    release(&p->lock);
    return 0;
  }

  // Crear la tabla de paginas del usuario
  p->pagetable = proc_pagetable(p);
  if(p->pagetable == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // Inicializar el contexto del proceso
  memset(&p->context, 0, sizeof(p->context));
  p->context.ra = (uint64)forkret;     // direccion de retorno para fork()
  p->context.sp = p->kstack + PGSIZE;  // stack pointer del kernel

  return p;
}

// Libera paginas y datos asociados a un proceso
static void
freeproc(struct proc *p)
{
  if(p->trapframe)
    kfree((void*)p->trapframe);

  p->trapframe = 0;

  if(p->pagetable)
    proc_freepagetable(p->pagetable, p->sz); // liberar memoria del usuario

  p->pagetable = 0;
  p->sz = 0;
  p->pid = 0;
  p->parent = 0;
  p->name[0] = 0;   // limpiar nombre
  p->chan = 0;      // canal de sleep
  p->killed = 0;
  p->xstate = 0;
  p->state = UNUSED; // disponible nuevamente
}

// Crea la tabla de paginas del proceso
pagetable_t
proc_pagetable(struct proc *p)
{
  pagetable_t pagetable;

  pagetable = uvmcreate(); // tabla vacia
  if(pagetable == 0)
    return 0;

  // Mapear trampoline: manejo de traps
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
              (uint64)trampoline, PTE_R | PTE_X) < 0){
    uvmfree(pagetable, 0);
    return 0;
  }

  // Mapear trapframe del proceso
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
              (uint64)(p->trapframe), PTE_R | PTE_W) < 0){
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}

// Libera tabla de paginas del proceso
void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
  uvmfree(pagetable, sz); // liberar memoria
}

// initcode: primer programa de usuario
uchar initcode[] = {
  0x17, 0x05, 0x00, 0x00, 0x13, 0x05, 0x45, 0x02,
  0x97, 0x05, 0x00, 0x00, 0x93, 0x85, 0x35, 0x02,
  0x93, 0x08, 0x70, 0x00, 0x73, 0x00, 0x00, 0x00,
  0x93, 0x08, 0x20, 0x00, 0x73, 0x00, 0x00, 0x00,
  0xef, 0xf0, 0x9f, 0xff, 0x2f, 0x69, 0x6e, 0x69,
  0x74, 0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00
};

// Inicializa el proceso init
void
userinit(void)
{
  struct proc *p;

  p = allocproc(); // nuevo proceso
  initproc = p;

  // Crear memoria de usuario con initcode
  uvminit(p->pagetable, initcode, sizeof(initcode));
  p->sz = PGSIZE;

  // Establecer PC y SP del proceso
  p->trapframe->epc = 0;
  p->trapframe->sp = PGSIZE;

  safestrcpy(p->name, "initcode", sizeof(p->name));

  p->cwd = namei("/"); // directorio raiz

  p->state = RUNNABLE; // listo para ejecutar

  release(&p->lock);
}

// Maneja sbrk: crecer o reducir memoria del usuario
int
growproc(int n)
{
  uint sz;
  struct proc *p = myproc();

  sz = p->sz;
  if(n > 0){
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }

  p->sz = sz;
  return 0;
}

// fork: crea un proceso hijo copiando al padre
int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();

  if((np = allocproc()) == 0) // nuevo proceso
    return -1;

  np->mask = p->mask; // copiar mascara de syscalls

  // Copiar memoria del usuario
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    freeproc(np);
    release(&np->lock);
    return -1;
  }

  np->sz = p->sz;

  // Copiar registros de usuario
  *(np->trapframe) = *(p->trapframe);

  // fork retorna 0 en el hijo
  np->trapframe->a0 = 0;

  // Copiar descriptores de archivo
  for(i = 0; i < NOFILE; i++)
    if(p->ofile[i])
      np->ofile[i] = filedup(p->ofile[i]);

  np->cwd = idup(p->cwd);

  safestrcpy(np->name, p->name, sizeof(p->name));

  pid = np->pid;

  release(&np->lock);

  acquire(&wait_lock);
  np->parent = p; // asignar padre
  release(&wait_lock);

  acquire(&np->lock);
  np->state = RUNNABLE; // listo para ejecutar
  release(&np->lock);

  return pid;
}

// Reasigna hijos huerfanos del proceso p al proceso init
void
reparent(struct proc *p)
{
  struct proc *pp;

  for(pp = proc; pp < &proc[NPROC]; pp++){
    if(pp->parent == p){
      pp->parent = initproc;
      wakeup(initproc);
    }
  }
}

// exit: termina el proceso actual
void
exit(int status)
{
  struct proc *p = myproc();

  // init no puede morir
  if(p == initproc)
    panic("init exiting");

  // Cerrar archivos
  for(int fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd]){
      struct file *f = p->ofile[fd];
      fileclose(f);
      p->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(p->cwd);
  end_op();
  p->cwd = 0;

  acquire(&wait_lock);

  // Reasignar hijos
  reparent(p);

  // Despertar al padre
  wakeup(p->parent);
  
  acquire(&p->lock);
  p->xstate = status;  // codigo de salida
  p->state = ZOMBIE;   // proceso muerto
  p->exit_time = ticks;// registrar tiempo de salida
  release(&wait_lock);

  sched(); // ceder CPU
  panic("zombie exit");
}

// wait: espera que un hijo muera
int
wait(uint64 addr)
{
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();

  acquire(&wait_lock);

  for(;;){
    havekids = 0;

    for(np = proc; np < &proc[NPROC]; np++){
      if(np->parent == p){
        acquire(&np->lock);
        havekids = 1;

        if(np->state == ZOMBIE){
          pid = np->pid;

          // copiar codigo de salida al usuario
          if(addr != 0 &&
             copyout(p->pagetable, addr,
                     (char *)&np->xstate,
                     sizeof(np->xstate)) < 0){
            release(&np->lock);
            release(&wait_lock);
            return -1;
          }

          freeproc(np); // liberar proceso
          release(&np->lock);
          release(&wait_lock);

          return pid;
        }

        release(&np->lock);
      }
    }

    if(!havekids || p->killed){
      release(&wait_lock);
      return -1;
    }

    sleep(p, &wait_lock);
  }
}

// Funciones auxiliares
int max(int a, int b){
  if(a > b) return a;
  return b;
}

int min(int a, int b){
  if(a < b) return a;
  return b;
}

// Scheduler PBS
void
scheduler(void)
{
#ifdef PBS

  struct proc *p;
  struct cpu *c = mycpu();
  c->proc = 0;

  for(;;){
    intr_on(); // habilitar interrupciones

    struct proc* high_priority_proc = 0;
    int dynamic_priority = 101;

    for(p = proc; p < &proc[NPROC]; p++) {
      acquire(&p->lock);

      int nice;
      // Calculo del valor nice: relacion entre tiempo dormido y tiempo de ejecucion
      if(p->run_time + p->sleep_time > 0){
        nice = p->sleep_time * 10;
        nice = nice / (p->sleep_time + p->run_time);
      }
      else{
        nice = 5;
      }

      // Calcular prioridad dinamica PBS
      int curr_dynamic_priority =
          max(0, min(p->priority - nice + 5, 100));

      if(p->state == RUNNABLE){

        int dp_check = 
            (dynamic_priority == curr_dynamic_priority);

        int check_1 = 
            dp_check && p->n_runs < high_priority_proc->n_runs;

        int check_2 =
            dp_check &&
            high_priority_proc->n_runs == p->n_runs &&
            p->create_time < high_priority_proc->create_time;

        if(high_priority_proc == 0 ||
           curr_dynamic_priority > dynamic_priority ||
           check_1 ||
           check_2){

          if(high_priority_proc != 0)
            release(&high_priority_proc->lock);

          dynamic_priority = curr_dynamic_priority;
          high_priority_proc = p;

          continue;
        }
      }
      
      release(&p->lock);
    }

    if(high_priority_proc != 0){

      high_priority_proc->state = RUNNING;
      high_priority_proc->start_time = ticks;
      high_priority_proc->run_time = 0;
      high_priority_proc->sleep_time = 0;
      high_priority_proc->n_runs += 1;

      c->proc = high_priority_proc;

      // hacer contexto de cambio
      swtch(&c->context, &high_priority_proc->context);

      c->proc = 0;
      release(&high_priority_proc->lock);
    }
  }

#endif
}

// sched: transfiere control al scheduler
void
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&p->lock))
    panic("sched p->lock");

  if(mycpu()->noff != 1)
    panic("sched locks");

  if(p->state == RUNNING)
    panic("sched running");

  if(intr_get())
    panic("sched interruptible");

  intena = mycpu()->intena;

  swtch(&p->context, &mycpu()->context);

  mycpu()->intena = intena;
}

// yield: cede CPU voluntariamente
void
yield(void)
{
  struct proc *p = myproc();

  acquire(&p->lock);
  p->state = RUNNABLE;
  sched();
  release(&p->lock);
}

// Entrada del primer scheduler despues de fork
void
forkret(void)
{
  static int first = 1;

  release(&myproc()->lock);

  if (first) {
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
}

// Pone un proceso a dormir
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  acquire(&p->lock);
  release(lk);

  p->chan = chan;
  p->state = SLEEPING;

  sched();

  p->chan = 0;

  release(&p->lock);
  acquire(lk);
}

// Despertar procesos dormidos
void
wakeup(void *chan)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    if(p != myproc()){
      acquire(&p->lock);

      if(p->state == SLEEPING && p->chan == chan)
        p->state = RUNNABLE;

      release(&p->lock);
    }
  }
}

// Mata un proceso por pid
int
kill(int pid)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);

    if(p->pid == pid){
      p->killed = 1;

      if(p->state == SLEEPING)
        p->state = RUNNABLE;

      release(&p->lock);
      return 0;
    }

    release(&p->lock);
  }

  return -1;
}

// Copia datos a espacio de usuario o kernel
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
  struct proc *p = myproc();

  if(user_dst)
    return copyout(p->pagetable, dst, src, len);
  else{
    memmove((char *)dst, src, len);
    return 0;
  }
}

// Copia datos desde espacio de usuario o kernel
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
  struct proc *p = myproc();

  if(user_src)
    return copyin(p->pagetable, dst, src, len);
  else{
    memmove(dst, (char*)src, len);
    return 0;
  }
}

// Imprime informacion de procesos (Ctrl+P)
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runnable",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };

  struct proc *p;
  char *state;

  printf("\n");

  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;

    if(p->state >= 0 && p->state < NELEM(states))
      state = states[p->state];
    else
      state = "???";

#ifdef PBS
    int wait_time;

    if(p->exit_time > 0)
      wait_time = p->exit_time - p->create_time - p->total_run_time;
    else
      wait_time = ticks - p->create_time - p->total_run_time;

    printf("%d %d %s %d %d %d",
           p->pid,
           p->priority,
           state,
           p->total_run_time,
           wait_time,
           p->n_runs);
#endif

    printf("\n");
  }
}

// Actualiza run_time y sleep_time cada tick
void
update_time(void)
{
  struct proc* p;

  for(p = proc; p < &proc[NPROC]; p++)
  {
    acquire(&p->lock);

    if(p->state == RUNNING){
      p->run_time += 1;
      p->total_run_time += 1;
    }
    else if(p->state == SLEEPING){
      p->sleep_time += 1;
    }

    release(&p->lock);
  }
}

// Cambia prioridad estatica PBS
int
setpriority(int new_priority, int pid)
{
  int prev_priority = 0;
  struct proc* p;

  for(p = proc; p < &proc[NPROC]; p++)
  {
    acquire(&p->lock);

    if(p->pid == pid)
    {
      prev_priority = p->priority;
      p->priority = new_priority;

      p->sleep_time = 0;
      p->run_time = 0;

      int reschedule = (new_priority < prev_priority);

      release(&p->lock);

      if(reschedule)
        yield();

      break;
    }

    release(&p->lock);
  }

  return prev_priority;
}

// waitx: igual que wait pero devuelve tiempos rtime y wtime
int
waitx(uint64 addr, uint* rtime, uint* wtime)
{
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();

  acquire(&wait_lock);

  for(;;){
    havekids = 0;

    for(np = proc; np < &proc[NPROC]; np++){
      if(np->parent == p){

        acquire(&np->lock);
        havekids = 1;

        if(np->state == ZOMBIE){
          pid = np->pid;

          *rtime = np->run_time;
          *wtime = np->exit_time - np->create_time - np->run_time;

          if(addr != 0 &&
             copyout(p->pagetable,
                     addr,
                     (char *)&np->xstate,
                     sizeof(np->xstate)) < 0){

            release(&np->lock);
            release(&wait_lock);
            return -1;
          }

          freeproc(np);

          release(&np->lock);
          release(&wait_lock);

          return pid;
        }

        release(&np->lock);
      }
    }

    if(!havekids || p->killed){
      release(&wait_lock);
      return -1;
    }

    sleep(p, &wait_lock);
  }
}
