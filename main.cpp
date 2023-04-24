#include <stdio.h>
extern "C" void _printf (const char * str, ...);

int main (void)
{
	_printf ("Hello, %s, %d %c%c %d\n\n\n %d %s, %o", 
		 "Andrei", 18, 'K', 'I',
		 -15689, 4656, "aboba", 87);
	_printf ("Hi!");
	_printf ("");
	_printf ("%b", 20);
	_printf ("%a\n");
	_printf  ("%%\n");
	return 0;
	
}
