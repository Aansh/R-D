/*********************************************************************************
 *                                                                               *
 *                                                                               *
 *    Name       : macros.S                                                      *
 *    Date       : 23-Feb-2014                                                   *
 *    Version    : 0.0.1                                                         *
 *    Source     : C                                                             *
 *    Author     : Ashakiran Bhatter                                             *
 *                                                                               *
 *    Description: This is the file that the stage0.bin loads and passes the     *
 *                 control of execution to it. The main functionality of this    *
 *                 program is to display a very simple splash screen and a       *
 *                 command prompt so that the user can type commands             *
 *    Caution    : It does not recognize any commands as they are not programmed *
 *                                                                               *
 *********************************************************************************/
/* generate 16 bit code                                                 */
__asm__(".code16\n");
/* jump to main function or program code                                */
__asm__("jmpl $0x1000, $main\n");

#define TRUE  0x01
#define FALSE 0x00

char str[] = "$> ";

/* this function is used to set-up the */
/* registers and stack as required     */
/* parameter(s): none                  */
void initEnvironment() {
     __asm__ __volatile__(
          "cli;"
          "movw $0x0000, %ax;"
          "movw %ax, %ss;"
          "movw $0xffff, %sp;"
          "cld;"
     );

     __asm__ __volatile__(
          "movw $0x1000, %ax;"
          "movw %ax, %ds;"
          "movw %ax, %es;"
          "movw %ax, %fs;"
          "movw %ax, %gs;"
     );
}

/* vga functions */
/* this function is used to set the   */
/* the VGA mode to 80*24              */
void setResolution() {
     __asm__ __volatile__(
          "int $0x10" : : "a"(0x0003)
     );
}

/* this function is used to clear the */
/* screen buffer by splitting spaces  */
void clearScreen() {
     __asm__ __volatile__ (
          "int $0x10" : : "a"(0x0200), "b"(0x0000), "d"(0x0000)
     );
     __asm__ __volatile__ (
          "int $0x10" : : "a"(0x0920), "b"(0x0007), "c"(0x2000)
     );
}

/* this function is used to set the   */
/* cursor position at a given column  */
/* and row                            */
void setCursor(short col, short row) {
     __asm__ __volatile__ (
          "int $0x10" : : "a"(0x0200), "d"((row <<= 8) | col)
     );
}

/* this function is used enable and   */
/* disable the cursor                 */
void showCursor(short choice) {
     if(choice == FALSE) {
          __asm__ __volatile__(
               "int $0x10" : : "a"(0x0100), "c"(0x3200)
          );
     } else {
          __asm__ __volatile__(
               "int $0x10" : : "a"(0x0100), "c"(0x0007)
          );
     }
}

/* this function is used to initialize*/
/* the VGA to 80 * 25 mode and then   */
/* clear the screen and set the cursor*/
/* position to (0,0)                  */
void initVGA() {
     setResolution();
     clearScreen();
     setCursor(0, 0);
}

/* io functions */
/* this function is used to get a chara*/
/* cter from keyboard with no echo     */
void getch() {
     __asm__ __volatile__ (
          "xorw %ax, %ax\n"
          "int $0x16\n"
     );
}

/* this function is same as getch()    */
/* but it returns the scan code and    */
/* ascii value of the key hit on the   */
/* keyboard                            */
short getchar() {
     short word;

     __asm__ __volatile__(
          "int $0x16" : : "a"(0x1000)
     );

     __asm__ __volatile__(
          "movw %%ax, %0" : "=r"(word)
     );

     return word;
}

/* this function is used to display the*/
/* key on the screen                   */
void putchar(short ch) {
     __asm__ __volatile__(
          "int $0x10" : : "a"(0x0e00 | (char)ch)
     );
}

/* this function is used to print the  */
/* null terminated string on the screen*/
void printString(const char* pStr) {
     while(*pStr) {
          __asm__ __volatile__ (
               "int $0x10" : : "a"(0x0e00 | *pStr), "b"(0x0002)
          );
          ++pStr;
     }
}

/* this function is used to sleep for  */
/* a given number of seconds           */
void delay(int seconds) {
     __asm__ __volatile__(
          "int $0x15" : : "a"(0x8600), "c"(0x000f * seconds), "d"(0x4240 * seconds)
     );
}

/* string functions */
/* this function isused to calculate   */
/* length of the string and then return*/
/* it                                  */
int strlength(const char* pStr) {
     int i = 0;

     while(*pStr) {
          ++i;
     }
     return i;
}

/* UI functions */
/* this function is used to display the */
/* logo                                 */
void splashScreen(const char* pStr) {
     showCursor(FALSE);
     clearScreen();
     setCursor(0, 9);
     printString(pStr);
     delay(10);
}

/* shell */
/* this function is used to display a   */
/* dummy command prompt onto the screen */
/* and it automatically scrolls down if */
/* the user hits return key             */
void shell() {
     clearScreen();
     showCursor(TRUE);
     while(TRUE) {
          printString(str);
          short byte;
          while((byte = getchar())) {
               if((byte >> 8)  == 0x1c) {
                    putchar(10);
                    putchar(13);
                    break;
               } else {
                    putchar(byte);
               }
          }
     }
}

/* this is the main entry for the kernel*/
void main() {
     const char msgPicture[] = 
                               "                     ..                                              \n\r"
                               "                      ++`                                            \n\r"
                               "                       :ho.        `.-/++/.                          \n\r"
                               "                        `/hh+.         ``:sds:                       \n\r"
                               "                          `-odds/-`        .MNd/`                    \n\r"
                               "                             `.+ydmdyo/:--/yMMMMd/                   \n\r"
                               "                                `:+hMMMNNNMMMddNMMh:`                \n\r"
                               "                   `-:/+++/:-:ohmNMMMMMMMMMMMm+-+mMNd`               \n\r"
                               "                `-+oo+osdMMMNMMMMMMMMMMMMMMMMMMNmNMMM/`              \n\r"
                               "                ```   .+mMMMMMMMMMMMMMMMMMMMMMMMMMMMMNmho:.`         \n\r"
                               "                    `omMMMMMMMMMMMMMMMMMMNMdydMMdNMMMMMMMMdo+-       \n\r"
                               "                .:oymMMMMMMMMMMMMMNdo/hMMd+ds-:h/-yMdydMNdNdNN+      \n\r"
                               "              -oosdMMMMMMMMMMMMMMd:`  `yMM+.+h+.-  /y `/m.:mmmN      \n\r"
                               "             -:`  dMMMMMMMMMMMMMd.     `mMNo..+y/`  .   .  -/.s      \n\r"
                               "             `   -MMMMMMMMMMMMMM-       -mMMmo-./s/.`         `      \n\r"
                               "                `+MMMMMMMMMMMMMM-        .smMy:.``-+oo+//:-.`        \n\r"
                               "               .yNMMMMMMMMMMMMMMd.         .+dmh+:.  `-::/+:.        \n\r"
                               "               y+-mMMMMMMMMMMMMMMm/`          ./o+-`       .         \n\r"
                               "              :-  :MMMMMMMMMMMMMMMMmy/.`                             \n\r"
                               "              `   `hMMMMMMMMMMMMMMMMMMNds/.`                         \n\r"
                               "                  sNhNMMMMMMMMMMMMMMMMMMMMNh+.                       \n\r"
                               "                 -d. :mMMMMMMMMMMMMMMMMMMMMMMNh:`                    \n\r"
                               "                 /.   .hMMMMMMMMMMMMMMMMMMMMMMMMh.                   \n\r"
                               "                 .     `sMMMMMMMMMMMMMMMMMMMMMMMMN.                  \n\r"
                               "                         hMMMMMMMMMMMMMMMMMMMMMMMMy                  \n\r"
                               "                         +MMMMMMMMMMMMMMMMMMMMMMMMh                      ";
     const char msgWelcome[] = "              *******************************************************\n\r"
                               "              *                                                     *\n\r"
                               "              *        Welcome to kirUX Operating System            *\n\r"
                               "              *                                                     *\n\r"
                               "              *******************************************************\n\r"
                               "              *                                                     *\n\r" 
                               "              *                                                     *\n\r"
                               "              *        Author : Ashakiran Bhatter                   *\n\r"
                               "              *        Version: 0.0.1                               *\n\r"
                               "              *        Date   : 01-Mar-2014                         *\n\r"
                               "              *                                                     *\n\r"
                               "              ******************************************************";
     initEnvironment(); 
     initVGA();
     splashScreen(msgPicture);
     splashScreen(msgWelcome);

     shell(); 

     while(1);
}
