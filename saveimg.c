#	include	<stdio.h>
#	include	<stdlib.h>
#	include	<unistd.h>


int
process_file(
	FILE	*raw)
	{
	unsigned char	sector[512];
	int	i=0;
	char	of[128];

	sprintf(of, "save_img_%3.3d.jpg", i);
	FILE	*img = fopen(of, "wb");

	fread(sector, 1, 512, raw);
	while(!feof(raw))
		{
		if (	sector[0] == 0xff &&
			sector[1] == 0xd8 &&
			sector[2] == 0xff &&
			sector[3] == 0xe1
//			sector[4] == 0x23 &&
//			sector[5] == 0xfe &&
//			sector[6] == 0x45 &&
//			sector[7] == 0x78 &&
//			sector[8] == 0x69 &&
//			sector[9] == 0x66
			)
			{
			fclose(img);
			++i;
			sprintf(of, "save_img_%3.3d.jpg", i);
			img = fopen(of, "wb");
			}
		fwrite(sector, 1, 512, img);
		fread(sector, 1, 512, raw);
		}
	fclose(raw);
	fclose(img);
	return(0);
	}

int
main(
	int		argc,
	char		*argv[])
	{
	if(argc!=2)
		{
		printf("usage: %s rawfile\n", argv[0]);
		return(1);
		}
	FILE	*raw = fopen(argv[1], "rb");
	process_file(raw);
	}
