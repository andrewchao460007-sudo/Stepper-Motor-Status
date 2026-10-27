
#include "SysClock.h"
#include "OLED_I2C.h"
#include "ssd1306.h"
#include "ssd1306_fonts.h"

// Initialize the clock and OLED
void OLED_Setup(void)
{
    System_Clock_Init();
    OLED_I2C_Init();
    ssd1306_Init();
}

// Display motor status
void OLED_Motor_Status(uint32_t mode)
{
    ssd1306_Fill(Black);

    ssd1306_SetCursor(0, 0);
    ssd1306_WriteString("STEPPER MOTOR", Font_7x10, White);

    ssd1306_SetCursor(0, 20);

    if (mode == 1)
    {
        ssd1306_WriteString("FULL STEP", Font_11x18, White);
    }
    else if (mode == 2)
    {
        ssd1306_WriteString("HALF STEP", Font_11x18, White);
    }
    else
    {
        ssd1306_WriteString("COMPLETE", Font_11x18, White);
    }

    ssd1306_SetCursor(0, 45);

    if (mode == 3)
    {
        ssd1306_WriteString("Status: Done", Font_7x10, White);
    }
    else
    {
        ssd1306_WriteString("Status: Running", Font_7x10, White);
    }

    ssd1306_UpdateScreen();
}
