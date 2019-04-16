//
// High level class to interact with the chip8 machine.
//


import Foundation



/**
 *  This is more or less an interface to the chip8 machine with all the top level functions that
 *  the main UIController will need for the system.  It provides the display content to update,
 *  a way to interface with the "keyboard", loading of games, and an emulation cycle instruction.
 */
public class Chip8 {
    
    
    //CPU object
    private var cpu: CPU;
    
    //Memory object
    private var memory: Memory;
    
    //Display memory object
    private var display: Display;
    
    //Keyboard object
    private var keyPad: Keyboard;
    
    /**
     Create the components needed for the chip8 machine.
    */
    public init(){
        //Initialzie all components
        memory = Memory();
        display = Display();
        keyPad = Keyboard();
        cpu = CPU(display: display, memory: memory, keyBoard: keyPad);
    }
    
    
    /**
     Get the array in the display each time.
    */
    public func displayArray() -> [UInt8]{
        return display.graphics;
    }
    
    
    
    /**
     Sets the key down.  Equivilant of pressing a physical key
    */
    public func setKeyDown(key: String) {
        keyPad.setKey(key: key, onOff: Keyboard.On_Status.ON)
    }
    
    /**
     Releases the key.  Equivilant of releasing a physical key
    */
    public func setKeyUp(key: String) {
        keyPad.setKey(key: key, onOff: Keyboard.On_Status.OFF)
    }
    
    /**
     Runs a single emulation cycle.
    */
    public func emulationCycle() {
            cpu.emulateCycle();
    }
    
    /**
     Loads a program.
     FUTURE IMPROVEMENT: Replace with an enumeration that links to other programs.
    */
    public func loadGame() {
        memory.loadProgram()
    }
    
    
    /**
    Returns an indicator if the Chip8 should draw.
    */
    public func shouldDraw() -> Bool{
        return display.drawFlag
    }
    
    /**
     Set the machines draw flag.
    */
    public func setShouldDraw(shouldDraw: Bool) {
        display.drawFlag = shouldDraw
    }
    
    
}
