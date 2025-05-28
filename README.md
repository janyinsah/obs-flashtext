# **Flash Text OBS Script** #

Very quick flashing text tool I decided to make as I started using countdown timers for comfort monitors in OBS. 

Note: Currently, this script only works GDI+ v3 text sources (As of current OBS version). 
      There is no real reason to use an older text source as of right now.
      If you want to, simply add the text source ID which you can find in the logs if you want FTS and older text source version.s

### **Functionality** ###

Choose Colors: Pick any two colors for the blink cycle.

Set Speed: Control the interval (50–2000ms).

Quick Source Selection: Dropdown or type in your text source name.

Auto-Restore: Goes back to the original color when you stop.

### **How To Use Tt....** ###

Place flash_text.lua in your OBS scripts folder.

In OBS, go to Tools → Scripts → +, then load flash_text.lua.

Select your GDI+ v3 text source, pick colors and interval.

In Settings → Hotkeys, bind Toggle Flashing.

Press your hotkey to start/stop the blink!

Enjoy.
