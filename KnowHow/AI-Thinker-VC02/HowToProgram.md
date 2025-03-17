https://forum.arduino.cc/t/how-to-program-ai-thinker-vc-02/1132521/11
Finally, programming the Kit is rather simple ... if one understands the procedure ! 
AI-Thinker signalled me a sequence on YouTube and, after some testing and trying, I use this

You don't need any JTAG programmer. 
[Here is a very good Youtube guide](https://www.youtube.com/watch?v=dAqX4CmozfM)

These are the steps:

1) Create an IAI-Thinker account on [voice.ai-thinker.com](http://voice.ai-thinker.com/#/)
Make sure to switch the web page to English.
Follow the steps as explained here: [Registration Guide](https://www.youtube.com/redirect?event=comments&redir_token=QUFFLUhqbEFoR2JYdld4eDd2dXE2ZURHRGVlYTVTeF9uUXxBQ3Jtc0trQzZsRTh5VU1YaHBmd2dMQ1hOYm4zZmZiOUhhRGh6OXpRT2NkeTl2c1JuT3RVb0tObGlwVXdwQURiZjBBNmkyTWRMUkFzQlZmY0pxZVZXcXdCd0tmZWw1bE1mdDVnMEpZekgxR3VVZWhZbGV3TFVYNA&q=https://lnkd.in/gqM4NPZG)
    
2) Connect your kit via the USB and install the serial driver found on the Ai-Thinker page.
3) Login with your AI-Thinker account into WEB-SDK page  [voice.ai-thinker.com](http://voice.ai-thinker.com/#/)
4) Create a "New Product"
5) Define your product (wake up command, voice commands, responses, gpio pins), 
6) Creade the product (they say create the voice-SDK) via "make new version"
Now you have to wait until the system is ready (the boring “10 to 30 minutes”).  
7) The you can “download SDK”. You get an archive file beginning with “uni_hb_solution”. You have to unpack that RAR archive into a folder.
8) Upload the generated firmware onto your board.
In the folder, navigate to the subdir "image_demo\Hummingbird-M-Update-Tool" and double-click on the .exe file. 
This opens a new window, with a button labelled in Chinese at the bottom. Click on it, the COM related with Your kit will be highligted in yellow.
Now depress the reset button on the PCB and wait till the transfer has finished. And disconnect your board.

Warnings:
* In the Web SDK creating page (voice.ai-thinker.com), **NEVER** change the function of the pins in the first two lines : there is a warning about this. 
Otherwise You won't be no longer able to use this procedure. I use the pins at lines 7 and 8 as UARTS, the RX is useless and the output of TX is directly compatible with 5V systems.

* If you use the wake-up-free function, you will get an infinite activation but you must define a real wake-up word (despite of the fact that it will be useless), otherwise the building crashes. 
And it seems that the sensitivity to commands used as wake-ups is less than for standard commands.
"They" claim that it is possible to do a wake-up by hardware, but I never found such a possibility on the SDK page. So, It would be fine if anybody could help me in this direction, Ai-thinker does not respond about this, maybe it is not (yet) possible via their interface ?
