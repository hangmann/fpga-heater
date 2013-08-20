/*******************************************************************
*
* TIME_BASE.H
*
* Offers wait_for_ms(x) 
* 
* VERSION: 19.04.2013
*
* by Andreas Agne, Hendrik Hangmann
*
*******************************************************************/


// calculates difference for 32 bit register
unsigned int calc_timediff( unsigned int start, unsigned int stop )
{
	if ( start <= stop ) 
	{
		return ( stop - start );
	} 
	return ( 4294967295UL - start + stop ); 
}


// busy waiting for 'duration' milliseconds
void wait_for_ms(int duration)
{	
	unsigned int * timebase 			= (unsigned int *) (XPAR_SIMPLE_TIMEBASE_0_BASEADDR);	
	unsigned int time_in_ms = 0, t_stop, t_start = *timebase;
	// busy waiting
	while (time_in_ms < duration)
	{
		print("");
		t_stop = *timebase;
		time_in_ms = (calc_timediff(t_start, t_stop) / 100000);
	}
}
