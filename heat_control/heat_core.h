/*******************************************************************
*
* HEAT_CORE.H
*
* Activation and configuration of heat cores.
* 
* VERSION: 19.04.2013
*
* by Hendrik Hangmann
*
*******************************************************************/

#include <math.h> 
#define B(x) ( \
  (x[0] == '1') << 31 | \
  (x[1] == '1') << 30 | \
  (x[2] == '1') << 29 | \
  (x[3] == '1') << 28 | \
  (x[4] == '1') << 27 | \
  (x[5] == '1') << 26 | \
  (x[6] == '1') << 25 | \
  (x[7] == '1') << 24 | \
  (x[8] == '1') << 23 | \
  (x[9] == '1') << 22| \
  (x[10] == '1') << 21 | \
  (x[11] == '1') << 20 | \
  (x[12] == '1') << 19 | \
  (x[13] == '1') << 18 | \
  (x[14] == '1') << 17 | \
  (x[15] == '1') << 16 | \
  (x[16] == '1') << 15 | \
  (x[17] == '1') << 14 | \
  (x[18] == '1') << 13 | \
  (x[19] == '1') << 12 | \
  (x[20] == '1') << 11 | \
  (x[21] == '1') << 10 | \
  (x[22] == '1') << 9 | \
  (x[23] == '1') << 8 | \
  (x[24] == '1') << 7 | \
  (x[25] == '1') << 6 | \
  (x[26] == '1') << 5 | \
  (x[27] == '1') << 4 | \
  (x[28] == '1') << 3 | \
  (x[29] == '1') << 2 | \
  (x[30] == '1') << 1 | \
  (x[31] == '1') << 0 )
  

int j =0;  
int active_heaters = 0;
char bin[] = "00000000000000000000000000000000";
char zero[] = "00000000000000000000000000000000";

// calculates 32 bit binary representation of an int
char *dec_to_bin (int number)
{
    char * digits;
    int n_digits;
    int i;
    int copy;
	 
    i = 0;
    copy = number;
    while (copy) {
        digits[i] = copy % 2;
        copy /= 2;
        i++;
    }
   return digits;
}

// get active heaters (1-32) in the heat core as char, representing 32 bit binary code
char *get_heater_activator( unsigned int* heat_core )
{
	return bin;
}

int read_active( unsigned int* heat_core)
{
	return heat_core[1];
}

// get active heaters (1-32) in the heat core
int get_active_heater( unsigned int* heat_core )
{
	int count = 0;
	int i;
	
	for ( i = 1 ; i <= 32; i++) 
	{
		if (bin[i] == '1')
			count++;
	}
	
	return count;
}


// set active heaters (1-32) in the heat core
void set_active_heater( unsigned int* heat_core, int active )
{
	int i;
	int temp = active;
	int active_heaters = active;
	
	for( i = 0; i < 32 ; i++)
	{ 	
		if (i < temp)
		{ bin[i] = '1';
		} else bin[i] = '0';
	}
	printf("%s\n", bin);
	int decimal = B(bin);
	heat_core[1] = decimal;
}	

// turns on heat core
void enable( unsigned int* heat_core )
{
	heat_core[0] = B("00000000000000000000000000000001");
}

//turns off heat core
void disable( unsigned int* heat_core)
{
	heat_core[0] = B("00000000000000000000000000000000");;
}

//increases to the next higher percentage
void increase( unsigned int* heat_core)
{
	for ( j = 31 ; j > 0; j--) 
	{
		bin[j] = bin[j-1];
	}
	bin[0] = '1';
	active_heaters = active_heaters + 1;
	heat_core[1] = B(bin);
}

//decreases to the next lower percentage
void decrease( unsigned int* heat_core)
{
	for ( j = 0 ; j < 31; j++) 
	{
		bin[j] = bin[j+1];
	}
	bin[31] = '0';
	active_heaters = active_heaters - 1;	
	heat_core[1] = B(bin);
}

// 1 if heater is heater enabled, 0 otherwise
int enabled( unsigned int* heat_core )
{
	return heat_core[0];
}
