#include <stdio.h>
#include <stdlib.h>

#define BIGENDIAN      0
#define LITTLEENDIAN   1

int main()
{
	short int word = 0x0001;
	char *byte = (char *) &word;
	int i=byte[0] ? LITTLEENDIAN : BIGENDIAN;
	printf("%d",i);
	return 0;
}

