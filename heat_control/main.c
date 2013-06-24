

/*******************************************************************
*
* MAIN.C
*
* This example depicts how to use the heat core on different 
* intensity levels.
* 
* VERSION: 24.06.2013
*
* by Hendrik Hangmann
*
*******************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <xparameters.h>
#include <time_base.h>
#include <system_monitor.h>
#include <heat_core.h>



// Instantiate heat cores by their base addresses (-> xparameters.h)
unsigned int * heat_core_0  		= (unsigned int *) (XPAR_HEAT_CORE_0_BASEADDR);
// unsigned int * heat_core_1  		= (unsigned int *) (XPAR_LUT_HEAT_CORE_1_BASEADDR);
// ...

int main (void) 
{
	int mc;
	int vcc;
	int second = 0;
	int running = 1;
	unsigned int intensity = 0;

	printf("\n");
	enable(heat_core_0); // enable heater
	intensity = 16;
	
	set_active_heater(heat_core_0, intensity); 			 // set amount of heating blocks (1 - 32)
	// printf("%d \n", get_active_heater(heat_core_0);  // get amount of heating blocks (1 - 32)
	// printf("%d \n", enabled(heat_core_0);				 // heater enabled?

	printf("\n\n-- Start of heat_core_0 --\n\n");
	while ( running )
	{
		set_active_heater(heat_core_0, intensity);
		mc = sysmon_get_mcelsius();  // read temperature  
		vcc = sysmon_get_vcc();		  // read vcc
	
		printf("%d \t", second);
		printf("%d.%03d \t\t", mc/1000, mc%1000);  // print temperature
		printf("%d.%03d \n", vcc/1000, vcc%1000);  // print vcc
		
		
		// change intensity of the heat core
		if (second == 20	) increase(heat_core_0); // increases heat core intensity level
		if (second == 40	) decrease(heat_core_0); // decreases heat core intensity level
		if (second == 50  ) intensity = 8;
		if (second == 70  ) intensity = 32;
		if (second == 100 ) disable(heat_core_0);
		if (second == 120 ) enable(heat_core_0);
		if (second == 140 ) running = 0;

		wait_for_ms(1000);
		second++;
	}
	printf("\n\n-- End of heat_core_0 --\n\n");
	
}


