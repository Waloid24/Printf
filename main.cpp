extern "C" void _printf (const char * str, ...);

int main (void)
{
	_printf ("Hello, %d", -55);

	return 0;
	
}
