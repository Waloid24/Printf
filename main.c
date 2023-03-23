extern void _printf (const char * str, ...);

int main (void)
{
	_printf ("Hello!", ##__VA_ARGS__);
	
	return 0;
}
