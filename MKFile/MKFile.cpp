/*
*
* Program to create an empty file of the given size
* When no size is specified, a files of 16MB is created
*
*/

#include <stdio.h>
#include <stdlib.h>

void main( int argc, char *argv[])
{
	FILE * fp;

	if ( argc < 2)
		printf( "Program to create an empty file of the requested size\n"
				"Usage: MKFILE filename {size}\n");
	else
	{
		// Get the size and display what we do
		long bytes = 16L * 1024L * 1024L;
		if ( argc >= 3)
			bytes = atol( argv[2]);

		// Open the file
		fp = fopen( argv[1], "wb" );
		if ( !fp)
			printf( "Can't create file <%s>.\n", argv[1]);
		else
		{
			// Display what we are doing
			printf( "Creating file <%s> of <%ld> bytes.\n", argv[1], bytes);

			// Seek to the specified position
			if ( bytes)
			{
				// don't care about any return values just try to do it...
				fseek( fp, bytes-1, SEEK_SET);
				fputc( 0, fp);
			}


			// And close the file
			fclose( fp);
		}
	}
}

