/*
*
* Program waits until the contents of the specified directory changes
* This is until a file gets created, deleted or renamed
* It returns errorlevel 1 when the wait is aborted, 0 when it is triggered
*
*/

#include <stdio.h>
#include <stdlib.h>
#include <windows.h>

int main( int argc, char *argv[])
{
	int ret = 1;

	if ( argc < 2)
		printf( "Program to wait until one file in the directory changes.\n"
				" (i.e. created/deleted/renamed)\n\n"
				"USAGE: WaitDirFile PathName\n");
	else
	{
		HANDLE hFileNotification; 

		// Initialise
		hFileNotification = FindFirstChangeNotification(
						(const char *) argv[1],			// Directory to watch
						FALSE,							// do not watch the subtree 
						FILE_NOTIFY_CHANGE_FILE_NAME);	// watch filename changes (includes 'create')
		if (hFileNotification == INVALID_HANDLE_VALUE)
			printf( "FindFirstChangeNotification(%s) failed (error %d)",
						(const char *) argv[1],
						GetLastError());
		else
		{
			printf( "Waiting for a change in <%s>.\n", argv[1]);
			while (1)
			{
				// Block till file notification (something changed)
				DWORD status = WaitForSingleObject(hFileNotification, INFINITE); 
				if (status == WAIT_OBJECT_0)
				{
					// A file was created (or renamed or deleted)
					printf("Triggered !");
					ret = 0;
					break;
				}
				// Prepare handle to block again for next change
				if (FindNextChangeNotification(hFileNotification) == FALSE) 
				{
					printf("FindNextChangeNotification(%s) failed (error %d)",
								(const char *) argv[1],
								GetLastError());
					break;
				}
			}
		}
		FindCloseChangeNotification(hFileNotification);
	}

	return ret;
}

