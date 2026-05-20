delimeter:
    .ascii "------------------------------------------------------------------------------------------\0"
other_delimeter:
    .ascii "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-\0"
add_line:
    .ascii "___________\0"
add_half_space:
    .ascii " \0"
add_space:
    .ascii "           \0"
add_top:
    .ascii " ___________\0"
add_bottom:
    .ascii "|___________\0"
three_bottom:
    .ascii "___________\0"

one_string:
    .ascii "%s\0"
newline:
    .ascii "\n\0"
four_newline:
    .ascii "\n\n\n\n\0"
two_string:
    .ascii "%s%s\0"
three_string:
    .ascii "%s%s%s\0"
five_string:
    .ascii "%s%s%s%s%s\0"
int:
    .ascii "%-8d\0"
addr_int:
    .ascii "%-10d\0"
one_str_int_str:
    .ascii "%s%s%d%s\0"
string_int:
    .ascii "%s%d%s%s\0"
string_string:
    .ascii "%s%s%s%s\0"
line:
    .ascii "________\0"
one_space:
    .ascii " \0"
two_space:
    .ascii "  \0"
three_space:
    .ascii "   \0"
four_space:
    .ascii "    \0"
quarter_space:
    .ascii "    \0"
five_space:
    .ascii "     \0"
six_space:
    .ascii "      \0"
seven_space:
    .ascii "       \0"
eight_space:
    .ascii "        \0"
nine_space:
    .ascii "         \0"
ten_space:
    .ascii "          \0"

avail_space:
    .ascii "   \0"

num_space:
    .ascii "     \0"
decimal_space:
    .ascii "     \0"
hundreds_space:
    .ascii "    \0"
thousands_space:
    .ascii "    \0"
ten_thousands_space:
    .ascii "   \0"

num_space_af:
    .ascii "     \0"
decimal_space_af:
    .ascii "    \0"
hundreds_space_af:
    .ascii "    \0"
thousands_space_af:
    .ascii "   \0"
ten_thousands_space_af:
    .ascii "   \0"

space:
    .ascii "        \0"
top:
    .ascii " ________\0"
side:
    .ascii "|\0"
bottom:
    .ascii "|________\0"

mapped:
    .ascii "mapped\0"
start:
    .ascii "start\0"
end:
    .ascii "break\0"    
heap_start:
    .ascii "heap_start:\0"    
heap_end:
    .ascii "heap_break:\0"    
heap_size:
    .ascii "heap_size :\0"    
hash:
    .ascii "#\0"  
state:
    .ascii "state\0"   
address:
    .ascii "addr\0"
addr_end:
    .ascii "end\0"
size:
    .ascii "size\0"   
gap:
    .ascii "gap\0"
free:
    .ascii "FREE\0"
used:
    .ascii "USED\0"
arrow:
    .ascii " -> \0"
next:
    .ascii "next\0"
prev:
    .ascii "prev\0"
    

flag:
    .ascii "flag\0"    
ptr_size:
    .ascii "size\0"    
ptr_addr:
    .ascii "address\0"    

title:
    .ascii "%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\0"
header:
    .ascii "%s%s%s%d%s%s%s%s%d%s%s%s%s%d\0"

