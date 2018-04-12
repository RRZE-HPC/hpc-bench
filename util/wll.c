#include <stdio.h>
#include <stdlib.h>

#define WALL
#ifdef PentiumCPS
#include <sys/time.h>
#include <sys/types.h>
#include <stdlib.h>
#include <stdio.h>

#define CPS (PentiumCPS*1E6)
#ifndef CPS
   #define CPS (150*1E6)
#endif


static unsigned usec, sec;
static unsigned tusec, tsec;
static long long foo;

static inline void microtime(unsigned *lo, unsigned *hi)
{
  __asm __volatile (
        ".byte 0x0f; .byte 0x31 ; movl    %%edx,%0 ; movl    %%eax,%1  "
                : "=g" (*hi), "=g" (*lo) :: "eax", "edx");
}

double time00(void)
{
 again:
  microtime(&tusec, &tsec);
  microtime(&usec, &sec);
  if (tsec != sec) goto again;

  foo = sec;
  foo = foo << 32;
  foo |= usec;
  return ((double)foo/(double)CPS);
}
#else
#include <sys/time.h>
#ifndef UseTimes
#include <sys/resource.h>
#endif

double time00(void)
{
#ifdef WALL
  struct timeval tp;
  gettimeofday(&tp, NULL);
  return( (double) (tp.tv_sec + tp.tv_usec/1000000.0) ); /* wall clock time */
#else
#ifdef UseTimes
#include <unistd.h>
  struct tms ts;
  static double ClockTick=0.0;

  if (ClockTick == 0.0) ClockTick = (double) sysconf(_SC_CLK_TCK);
  times(&ts);
  return( (double) ts.tms_utime / ClockTick );
#else
  struct rusage ruse;
  getrusage(RUSAGE_SELF, &ruse);
  return( (double)(ruse.ru_utime.tv_sec+ruse.ru_utime.tv_usec / 1000000.0) );
#endif
#endif
}
#endif


int main(int argc, char* argv[])
{
  double x,y;
  if(argc==2)
    {
      /* exec a command and print the required time */
      x=time00();
      system(argv[1]);
      y=time00();
      printf("WangWanling5 %f\n",y-x);
    } 
  else 
    {
      /* print current time */
      x=time00();
      printf("%f\n",x);
    }
  return 0;
}

