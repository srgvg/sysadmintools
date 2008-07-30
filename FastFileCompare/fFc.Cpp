/* Fast File Compare */

#include <afx.h>

int main( int argc, char *argv[])
{
	CFileStatus fs1, fs2;
	int ret = 1;	// Default return errorlevel 1: files are different

	if ( argc != 3)
		printf( "Compares the timestamp and size of two files\n"
				"Returns errorlevel 0 when equal, 1 when not\n\n"
				"FFC filename1 filename2\n");
	else
	{
		printf( "\"%s\" versus \"%s\"\n", argv[1], argv[2]);

		if ( !CFile::GetStatus( argv[1], fs1))
			printf( "First file does not exist\n");
		else if ( !CFile::GetStatus( argv[2], fs2))
			printf( "Second file does not exist\n");
		else if ( fs1.m_size != fs2.m_size)
			printf( "Files are of different size\n");
		else if ( fs1.m_mtime != fs2.m_mtime)
		{
			if ((fs1.m_mtime.GetTime() > fs2.m_mtime.GetTime()
				&& fs1.m_mtime.GetTime() - fs2.m_mtime.GetTime() == 1)
				|| fs2.m_mtime.GetTime() - fs1.m_mtime.GetTime() == 1)
			{
				printf( "Files are probably equal (only 1 second difference)\n");
				ret = 0;	// return errorlevel 0: files are equal
			}
			else
				printf( "Files are modified on a different date/time\n");
		}
		else
		{
			printf( "Files are probably equal\n");
			ret = 0;	// return errorlevel 0: files are equal
		}
	}

	return ret;
}