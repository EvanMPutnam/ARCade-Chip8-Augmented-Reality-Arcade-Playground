//: # ARKit CHIP-8 Arcade Machine: ARcade

/*:
![Arcade!](IMG_0105.PNG)
 # Project Description:
This project involved creating an arcade machine in ARKit that runs the interpreted language known as CHIP-8.  This interpretation is done with a software description of a very simple machine that has ROM, a 64 by 32 screen, a keypad I/O device, as well as a processor with a number of opcodes.
 
 
 # Origin of the Project:
 
 ### History:
 CHIP-8 was an interpreted programming language that was created in the early 70's and it was used as a way to create games in a smaller footprint than something like BASIC.  This interpreted language relies heavily on registers and the manipulation of indexed memory.  The language itself is open source.
 
 The most common way to handle this language is to create a virtual machine type system that simulates memory, registers, and a stack pointer for execution of the programs.  I manually went through each opcode, determined the system requirements, and individually implemented each instruction the language has, to interpret CHIP-8 source files.
 
 While this system is not very complex, and technically not a real machine, it does highlight some principle elements in topics like emulation, virtual machines, and interpreters.  The knowledge I gained from this activity has helped me quite a bit and will lend itself to future projects.  I lately have been fascinated with retro and old hardware and plan to move on to looking at different arcade hardware setups.
 
 ### Personal Signifigance:
 Three things really appealed to me when I finally decided on this project for WWDC 2019.  The first of which was an opportunity to show my improvement of using Swift and Apple's libraries from last years submission.  My submission last year was technically challenging for myself then but now that I have more knowledge, and a better understanding of the Apple ecosystem, I felt I had to push myself a little bit harder then before.
 
 The second is my love of lower-level programming.  One of the areas of computing I really enjoy is messing with hardware on the bit level and this project was a great introduction into the realm of hardware simulation with a relatively simple system.  In the future I may try and work with a more complex system and create something for that.
 
 The third, and certainly most important to myself personally, is the connection to the arcade.  One of the things that I really loved doing with my dad growing up was going to this little arcade outside of Charlotte North Carolina.  Ever since I have been really interested in what goes into making arcade cabinets, old hardware that they work with, as well as the history of arcades.  Gaming, not just in the arcade, is a way to bring people together and it was really neat to make this virtual arcade machine that I will certainly be expanding on in the future.  I hope to get a better model of an arcade machine and expand to multiple platforms.
 
 # Noteworthy Components:
 ### ARKit:
 ARKit was used for the arcade machine.  I very well could have just showed the final interpreter and had the user interact with it on a screen however, I thought it would be much more fun, and more challenging to myself, to make that machine playable in an AR setting.  Apple's fantastic AR platform and libraries made that possible with a relatively easy learning curve.
 ### SceneKit and SpriteKit:
 These were used to dispaly the 3D objects and draw elements to the arcade display.
 ### CHIP-8 Interpreter/Machine:
 The bulk of the work went into creating the actual interpreter of the CHIP-8 language.  It was relatively low level programming work creating a software representation of a machine that could execute these instructions.
 
 # Included Game:
 The game I decided to include is called UFO (Or known also as Space Intercept), by Joseph Weisbecker, and is under public domain.  This was done because it would have taken a significant amount of time to write the code for an entire game, in a sudo assembly language, as well as the AR and CHIP-8 interpreter code.  In the future I do plan to try writing a game for it though because there are not a lot of them out there that are open source beyond UFO, that I could find at least.  I might decide to expand the device memory and write something a little bigger for it as well.
 
 # How to Play:
1. First turn your device to portrait mode.  Make it fullscreen.
2. Start the playground.  Wait for your device to generate marking dots and planes for horizontal surfaces.  Find a horizontal surface, preferably a floor. (See below image for an example)
 
 ![Dots!](IMG_0104.PNG)
 
3. Tap your screen on the horizontal surface (with the plane) to create an arcade machine on that surface. Note that you may only place one arcade and in order to reset the machine you must restart the playground.  This was done for performance reasons, as each cabinet would be an individual virtual CHIP-8 machine instantiation.
4. To control the game there are three buttons that will shoot your projectile.  These are left, center, and right.  Your goal is to hit the invading UFO's with your rocket.  You can only fire one projectile at a time and must wait for it to finish before the next one can be fired.  The game is over when you run out of shots, displayed on the right side of the screen.  Your score is on the left.  The UFO that scrolls horizontally across the screen really fast is worth 5 and the one above that is worth 15.  Compete with friends and see who can get the highest!  It is largely a game about patience and timing.
 
 # Resources and Attributions:
All resources were either created by myself, are public documentation, or are open source.  All details of external resources are found below.
 
 * All models and scenes were created by myself.  The arcade machine I created is fairly simplistic and that is largely due to the fact that I am not a 3D artist.  Another reason was that I could not find any public domain models of arcade machines.
 * CHIP-8 documentation helpful for finding which opcodes I needed to implement.
    * [CHIP-8 Opcode Documentation](http://devernay.free.fr/hacks/chip8/C8TECH10.HTM)
 * Apple ARKit, SceneKit, SpriteKit, and Swift documentation
 * Game that is being run is called UFO by Joseph Weisbecker, 1978, and it is licensed under public domain.  More information can be found in the section above on the game.
 */


import PlaygroundSupport
import ARKit

/*:
This is meant for simplicity and to improve performance to
include only the a couple lines of configure code.
 
Some devices have differing processor speeds so setting the time
delay up or down by a decimal place may help.
 
For example, on my 2018 iPad I set the timeDelay to 0.0005.
However, when testing on a pro model that number was 0.005.
 

 */
let timeDelay = 0.005 //Change the time delay
let ARCade = ArcadeViewController()
ARCade.timeDelay = timeDelay
PlaygroundPage.current.liveView = ARCade
