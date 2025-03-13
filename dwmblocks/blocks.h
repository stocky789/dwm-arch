/* Modify this file to change what commands output to your status bar, and recompile using the make command. */
static const Block blocks[] = {
    /*Icon*/   /*Command*/                                                      /*Update Interval*/     /*Update Signal*/
    {" ", "top -bn1 | grep 'Cpu(s)' | awk '{print $2 + $4\"%\"}'",            5,                      0},
    {" ", "ip -br a | awk '/UP/ {print $1\": \"$3}' | cut -d/ -f1",           10,                     0},
    {"󰾅 ", "free -h | awk '/^Mem/ { print $3\"/\"$2 }' | sed s/i//g", 30, 0},
    {" ", "pamixer --get-volume", 1, 10},
    {" ", "date '+%b %d (%a) %I:%M%p'", 5, 12},
};

/* Sets delimiter between status commands. NULL character ('\0') means no delimiter. */
static char delim[] = " | ";
static unsigned int delimLen = 5;
