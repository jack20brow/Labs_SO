#include <stdio.h>      
#include <stdlib.h>     
#include <unistd.h>     
#include <signal.h>     
#include <sys/wait.h>   

// Definimos todas las macros, valores que serán estáticos, y que si necesitamos modificarlos, con modificarlos aquí no hace falta tocar más código.
#define AGUA_INICIAL    1000.0
#define NIVEL_ALTO      750.0
#define NIVEL_MEDIO     450.0
#define PROB_SECO       90      // 75-89 = 15% año seco
#define PROB_LLUVIOSO   75      // 90-99 = 10% año lluvioso
#define RECUP_ALTO      5.0
#define RECUP_MEDIO     20.0
#define RECUP_BAJO      5.0
#define VAR_SECO       -15.0
#define VAR_LLUVIOSO    10.0

// Utilizamos dos señales para definir los dos sentidos de la comunicación. Padre -> Hijo e Hijo -> Padre. Cada proceso queda suspendido y despierta cuando recibe la señal del proceso
// complementario. Usamos dos porque sino el padre podría confundir una señal que es para su proceso hijo como una señal para el.
void handler_sigusr1(int sig){}
void handler_sigusr2(int sig){}

// Esta es la función que ejecutará cada proceso hijo, le pasamos como params, su propio pipe, su regante, Norte o Sur, y el numero de años a simular.
void proceso_hijo(int pipe[2], char *nombre, int N){
    // Sembramos el generador aleatorio con el PID del hijo para que cada proceso genere solicitudes distintas.
    srand(getpid());
    // Instalamos el handler para recibir SIGUSR1 del padre.
    signal(SIGUSR1, handler_sigusr1);

    sigset_t mask, old_mask;
    sigemptyset(&mask);
    sigaddset(&mask, SIGUSR1);
    sigprocmask(SIG_BLOCK, &mask, &old_mask);

    // Iteración de N años
    for (int i = 0; i < N; i++) {
        // El hijo espera hasta que el padre le envie señal.
        sigsuspend(&old_mask);

        double limite;
        // Leemos el limite que ha escrito el padre en el pipe.
        read(pipe[0], &limite, sizeof(double));
        printf("[Regantes %s - PID %d] He recibido limite de %.2f m3\n", nombre, getpid(), limite);

        // Hace su solicitud y la escribe en el pipe, envía señal al padre para continuar la ejecución
        double solicitud = ((double)rand() / RAND_MAX) * limite;
        printf("[Regantes %s - PID %d] Solicito %.2f m3\n", nombre, getpid(), solicitud);

        write(pipe[1], &solicitud, sizeof(double));
        kill(getppid(), SIGUSR2);
    }

    exit(EXIT_SUCCESS);
}

// Funcion auxiliar para calcular el limite de agua.
double calcular_limite(double agua, double limite_alto, double limite_medio, double limite_bajo) {
    if (agua > NIVEL_ALTO) return limite_alto;
    else if (agua > NIVEL_MEDIO) return limite_medio;
    else return limite_bajo;
}

// Funcion auxiliar para la recuperación del deposito
double calcular_recuperacion(double agua)
{
    double porcentaje_base;
    if (agua > NIVEL_ALTO)
        porcentaje_base = 5.0;
    else if (agua > NIVEL_MEDIO)
        porcentaje_base = 20.0;
    else
        porcentaje_base = 5.0;
    int evento = rand() % 100;
    double variacion;
    if (evento < PROB_LLUVIOSO) {
        printf("[Evento] Año con lluvias normales\n");
        variacion = 0.0;
    } else if (evento < PROB_SECO) {
        printf("[Evento] Año seco\n");
        variacion = VAR_SECO;   
    } else {
        printf("[Evento] Año lluvioso\n");
        variacion = VAR_LLUVIOSO;
    }

    double porcentaje_final = porcentaje_base + variacion;
    if (porcentaje_final < 0) porcentaje_final = 0.0;

    printf("[Evento] Porcentaje de recuperacion aplicado: %.2f%%\n", porcentaje_final);

    return agua * porcentaje_final / 100.0;
}

int main(int argc, char *argv[])
{
    // Comprobavación de numero de params en la ejecución.
    if (argc != 5) {
        fprintf(stderr, "Uso: %s <limite_alto> <limite_medio> <limite_bajo> <N>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    double limite_alto = atof(argv[1]);
    double limite_medio = atof(argv[2]);
    double limite_bajo = atof(argv[3]);
    int N = atoi(argv[4]);

    // Declaramos los dos pipes y los inicializamos
    int pipe_norte[2];
    int pipe_sur[2];

    pipe(pipe_norte);
    pipe(pipe_sur);

    // Creamos los dos hijos y ejecutamos su proceso_hijo, función implementada anteriormente.
    pid_t pid_norte = fork();
    if (pid_norte == 0) {
        proceso_hijo(pipe_norte, "Norte", N);
    }

    pid_t pid_sur = fork();
    if (pid_sur == 0) {
        proceso_hijo(pipe_sur, "Sur", N);
    }

    // Inicializamos variables
    double agua = AGUA_INICIAL;
    double total_norte = 0.0;
    double total_sur = 0.0;

    srand(getpid());
    signal(SIGUSR2, handler_sigusr2);

    // Definimos las máscara la asociamos a nuestra señal
    sigset_t mask, old_mask;
    sigemptyset(&mask);
    sigaddset(&mask, SIGUSR2);
    sigprocmask(SIG_BLOCK, &mask, &old_mask); // Bloquea SIGUSR2 y guarda la máscara anterior.

    // Bucle del padre en los años.
    for (int i = 0; i < N; i++) {
        printf("\n* AÑO %d\n", i + 1);
        printf("[Coordinador] Agua disponible al inicio: %.2f m3\n", agua);

        // Calcula el limite
        double limite = calcular_limite(agua, limite_alto, limite_medio, limite_bajo);
        printf("[Coordinador] Limite aplicado este año: %.2f m3\n", limite);

        // Regantes Norte
        write(pipe_norte[1], &limite, sizeof(double)); // Escribimos el límite
        kill(pid_norte, SIGUSR1); // señal al hijo
        sigsuspend(&old_mask); // Esperamos a que devuelva la señal
        double solicitud_norte; 
        read(pipe_norte[0], &solicitud_norte, sizeof(double)); // Cojemos la solicitud
        printf("[Coordinador] Regantes Norte solicitan: %.2f m3\n", solicitud_norte);

        // Definimos si la podemos conceder o no
        double concedido_norte;
        if (solicitud_norte <= agua) {
            concedido_norte = solicitud_norte;
            printf("[Coordinador] Solicitud aprobada para Regantes Norte\n");
        } else {
            concedido_norte = agua;
            printf("[Coordinador] Solicitud parcial para Regantes Norte\n");
        }
        printf("[Coordinador] Agua concedida a Regantes Norte: %.2f m3\n", concedido_norte);
        agua -= concedido_norte;
        if (agua < 0) agua = 0;
        total_norte += concedido_norte;

        // Regantes Sur - Mismo uso que regante norte
        write(pipe_sur[1], &limite, sizeof(double));
        kill(pid_sur, SIGUSR1);
        sigsuspend(&old_mask);
        double solicitud_sur;
        read(pipe_sur[0], &solicitud_sur, sizeof(double));
        printf("[Coordinador] Regantes Sur solicitan: %.2f m3\n", solicitud_sur);

        double concedido_sur;
        if (solicitud_sur <= agua) {
            concedido_sur = solicitud_sur;
            printf("[Coordinador] Solicitud aprobada para Regantes Sur\n");
        } else {
            concedido_sur = agua;
            printf("[Coordinador] Solicitud parcial para Regantes Sur\n");
        }
        printf("[Coordinador] Agua concedida a Regantes Sur: %.2f m3\n", concedido_sur);
        agua -= concedido_sur;
        if (agua < 0) agua = 0;
        total_sur += concedido_sur;

        // Recuperacion
        double recuperacion = calcular_recuperacion(agua);
        printf("[Coordinador] Agua recuperada: %.2f m3\n", recuperacion);
        agua += recuperacion;
        if (agua > AGUA_INICIAL) agua = AGUA_INICIAL;
        printf("[Coordinador] Agua disponible al final del año: %.2f m3\n", agua);
    }

    // Resumen final
    printf("\nLa simulacion ha finalizado.\n");
    printf("Agua concedida a Regantes Norte: %.2f m3\n", total_norte);
    printf("Agua concedida a Regantes Sur: %.2f m3\n", total_sur);
    printf("Total agua concedida: %.2f m3\n", total_norte + total_sur);
    printf("Agua final en el deposito: %.2f m3\n", agua);

    wait(NULL);
    wait(NULL);

    return 0;
}