//
//  Chip8
//
//  This is the main bulk of the logic used for the chip8 machine.
//  Each component is seperated by class.
//      http://devernay.free.fr/hacks/chip8/C8TECH10.HTM#3xkk was used as reference for opcodes and general
//      structure of the CHIP8 machine.



import Foundation


class Display{

    //Screen graphics.  On and off (1 or 0).  Change to array of bits?
    public var graphics = [UInt8](repeating:0, count: 64*32)
    
    //Variable indicating if we should draw the above graphics to the screen.
    public var drawFlag : Bool = true;
    
    //Do display initialization here
    public init(){
        
    }
    
    /**
     Resets the display to be blank.
    */
    public func reset() -> Void{
        for i in 0..<(64*32) {
            graphics[i] = 0;
        }
    }
    
}


class Keyboard {
    
    //Keypad to store keypresses
    public var keyPad = [UInt8](repeating: 0, count: 16);

    //Key dictionary lookup for location in keypad array
    private let KEYS = [
        "a": 0x7,
        "s": 0x8,
        "d": 0x9,
        "f": 0xE,
        "z": 0xA,
        "x": 0x0,
        "c": 0xB,
        "v": 0xF,
        "1": 0x1,
        "2": 0x2,
        "3": 0x3,
        "4": 0xC,
        "q": 0x4,
        "w": 0x5,
        "e": 0x6,
        "r": 0xD
    ]
    
    
    /**
     Enumeration that is used to indicate on/off keys.
    */
    public enum On_Status: UInt8 {
        case ON = 1
        case OFF = 0
    }
    
    
    public init(){}
    
    /**
     function to set the key value to a 1 or 0
    */
    public func setKey(key: String, onOff: On_Status) {
        if let val = KEYS[key] {
            keyPad[val] = onOff.rawValue
        }
    }
    
    
    /**
     Resets the keyboard values to all ZERO
    */
    public func reset() -> Void{
        for i in 0..<16{
            keyPad[i] = On_Status.OFF.rawValue;
        }
    }
    
}



class Memory {
    
    //Chip 8 4k memory
    public var memory = [UInt8](repeating: 0, count: 4096);
    
    
    //Chip8 fontset
    private var fontSet : [UInt8] =
    [
    0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
    0x20, 0x60, 0x20, 0x20, 0x70, // 1
    0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
    0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
    0x90, 0x90, 0xF0, 0x10, 0x10, // 4
    0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
    0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
    0xF0, 0x10, 0x20, 0x40, 0x40, // 7
    0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
    0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
    0xF0, 0x90, 0xF0, 0x90, 0x90, // A
    0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
    0xF0, 0x80, 0x80, 0x80, 0xF0, // C
    0xE0, 0x90, 0x90, 0x90, 0xE0, // D
    0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
    0xF0, 0x80, 0xF0, 0x80, 0x80  // F
    ]

    /**
     Sets the fontset into memory.
    */
    public init() {
        //Set fontset
        for i in 0..<(80) {
            memory[i] = self.fontSet[i]
        }
    }
    
    /**
     Reset chip8 memory
    */
    public func reset() -> Void{
        //Reset memory
        for i in 0..<(4096) {
            memory[i] = 0;
        }
        
        //Set fontset
        for i in 0..<(80) {
            memory[i] = self.fontSet[i]
        }
        
    }
    
    /**
     Loads a program, in this case UFO, into the CHIP8 machine.
    */
    public func loadProgram(){
        
        //In the future we may want to take this path and pass it in.  Maybe the user can choose it from a list of programs.  Just one for WWDC because of the 3 minute experience limitation.
        let url : URL = Bundle.main.url(forResource: "UFO", withExtension: "c8")!
        print("Got here!")
        
        //Is our resource reachable?
        guard let reachable = try? url.checkResourceIsReachable() else {
            print("Not reachable")
            return
        }
        
        //Prints out reachable to ignore the warning.
        print(reachable)

        guard let data = try? Data(contentsOf: url) else {
            //Log some error or throw some exception here
            print("Error loading in file")
            return
        }
        
        print("Found file.  Loading into memory.")
        
        var count = 0;
        for item in data {
            memory[count+512] = item
            count += 1
        }

        
        print("Finished loading the data")
        
        
    }
}

class CPU {
    
    //Current opcode 2 bytes
    public var currOppCodeStorage: UInt16;
    
    //16 8 bit registers.  First 15 are general purpose.  16 is carry flag.
    public var registers = [UInt8](repeating: 0, count: 16);
    
    //Index regester
    public var indexRegister: UInt16;
    
    //Program counter
    public var programCounter: UInt16;
    
    //Delay timer register
    public var delayTimer: UInt8;
    
    //Sound timer register.  They count downwards to zero
    public var soundTimer: UInt8;
    
    //Stack
    public var stack = [UInt16](repeating:0, count: 16);
    
    //Stack pointer
    public var stackPointer: UInt16;
    
    
    
    
    //Display - Think of this as a bus
    private var display : Display;
    //Memory - Think of this as a bus
    private var memory : Memory;
    //Keyboard - Think of this as a bus
    private var keyBoard : Keyboard;
    
    
    
    
    //Flag to tell if the cpu is running or not
    public var isRunning = true
    
    
    /**
     Initializes the default values
     */
    init(display: Display, memory: Memory, keyBoard: Keyboard) {
        currOppCodeStorage = 0x0;
        indexRegister = 0x0;
        programCounter = 0x200;//Chip8 Programs load at 0x200
        delayTimer = 0x0;
        soundTimer = 0x0;
        stackPointer = 0x0;
        self.memory = memory;
        self.display = display;
        self.keyBoard = keyBoard;
    }
    
    
    public func reset() -> Void{
        currOppCodeStorage = 0x0;
        indexRegister = 0x0;
        programCounter = 0x200;
        delayTimer = 0x0;
        soundTimer = 0x0;
        stackPointer = 0x0;
        self.memory.reset()
        self.display.reset()
    }
    

    /**
     This is where the real magic of the system happens.  It takes in the memory stored and
     does some bitwise operations on it in order to the pieces of information that are needed.
     An instruction may be something equivilant toZXXY where Z is some prefix and XX/Y are
     values for the operation.
     
     I documented some of the opcodes below so that the general structure can be observed.
     All opcodes can be found at the following page here...
     
     http://devernay.free.fr/hacks/chip8/C8TECH10.HTM
     
     For a future improvement I may decide to do some refactoring and use function pointers of
     some variety instead of the switch statement structure.
     */
    private func cycle(){

        let opcode = (UInt16)(memory.memory[(Int)(programCounter)]) << 8 | (UInt16)(memory.memory[(Int)(programCounter+1)]);

        programCounter += 2


        //Determine what operation to do.
        switch opcode & 0xF000{
        case 0x0000:
            let x = opcode
            
            //CLS clear display
            if x == 0x00E0 {
                display.reset()
                display.drawFlag = true
            //RET return from subroutine
            } else if x == 0x00EE {
                stackPointer = stackPointer &- 1
                programCounter = stack[(Int)(stackPointer)]
            } else {
                print("Error, incorrect opcode")
            }
        //JP address.  1nnn jumps to location nnn
        case 0x1000:
            programCounter = (opcode & 0xFFF)
        //CALL address.  Call subroutine at 2nnn
        case 0x2000:
            stack[(Int)(stackPointer)] = programCounter
            stackPointer += 1
            programCounter = opcode & 0x0FFF
        //3xkk.  Skip next instruction if the register register[x] = kk
        case 0x3000:
            let x = (Int)((opcode & 0x0F00) >> 8)
            if registers[x] == (opcode & 0x00FF) {
                //programCounter += 4
                programCounter += 2
            }
        //4xkk.  skip next instruction if register[x] != kk
        case 0x4000:
            let x = (Int)((opcode & 0x0F00) >> 8)
            if registers[x] != (opcode & 0x00FF) {
                programCounter += 2
                //programCounter += 4
            } else {
                //programCounter += 2
            }
        //5xy0 Skip next instruction if registers[x] = registers[y]
        case 0x5000:
            let x = (Int)((opcode & 0x0F00) >> 8)
            let y = (Int)((opcode & 0x00F0) >> 4)
            if registers[x] == registers[y] {
                programCounter += 2
                //programCounter += 4
            } else {
                //programCounter += 2
            }
        //6xkk.
        case 0x6000: //Looks pretty good.  Looks fine
            registers[(Int)((opcode & 0x0F00) >> 8)] = (UInt8)(opcode & 0x00FF)
        case 0x7000://TODO maybe here
            var val = (Int)(opcode & 0x00FF) + (Int)(registers[(Int)((opcode & 0x0F00) >> 8)])
            if val > 255 {
                val -= 256
            }
            registers[(Int)((opcode & 0x0F00) >> 8)] = UInt8(val)
            //programCounter += 2
        case 0x8000:
            let x2 = opcode & 0x000F
            if x2 == 0x0000 {
                let x = (Int)((opcode & 0x0F00) >> 8)
                let y = (Int)((opcode & 0x00F0) >> 4)
                registers[x] = registers[y]
            } else if x2 == 0x0001 {
                let x = (Int)((opcode & 0x0F00) >> 8)
                let y = (Int)((opcode & 0x00F0) >> 4)
                registers[x] |= registers[y]
            } else if x2 == 0x0002 {
                let x = (Int)((opcode & 0x0F00) >> 8)
                let y = (Int)((opcode & 0x00F0) >> 4)
                registers[x] &= registers[y]
            } else if x2 == 0x0003 {
                let x = (Int)((opcode & 0x0F00) >> 8)
                let y = (Int)((opcode & 0x00F0) >> 4)
                registers[x] ^= registers[y]
            } else if x2 == 0x0004 {
                let x = (Int)((opcode & 0x00F0) >> 4)
                let y = (Int)((opcode & 0x0F00) >> 8)
                if registers[x] > (0xFF - registers[y]) {
                    registers[0xF] = 1
                } else {
                    registers[0xF] = 0
                }
                registers[y] = registers[y] &+ registers[x]
            } else if x2 == 0x0005 {
                let x = (Int)((opcode & 0x00F0) >> 4)
                let y = (Int)((opcode & 0x0F00) >> 8)
                if registers[x] > registers[y] {
                    registers[0xF] = 0
                } else {
                    registers[0xF] = 1
                }
                registers[y] = registers[y] &- registers[x]
            } else if x2 == 0x0006 {
                registers[0xF] = (registers[(Int)((opcode & 0x0F00) >> 8)] & 0x1)
                registers[(Int)((opcode & 0x0F00) >> 8)] >>= 1
            } else if x2 == 0x0007 {
                let x = (Int)((opcode & 0x0F00) >> 8)
                let y = (Int)((opcode & 0x00F0) >> 4)
                if registers[x] > registers[y] {
                    registers[0xF] = 0
                } else {
                    registers[0xF] = 1
                }
                registers[x] = registers[y] - registers[x]
            } else if x2 == 0x000E {
                let x = (Int)((opcode & 0x0F00) >> 8)
                registers[0xF] = registers[x] & 0x80
                registers[x] <<= 1
            } else {
                print("Error, incorrect opcode")
            }
        case 0x9000:
            let x = (Int)((opcode & 0x0F00) >> 8)
            let y = (Int)((opcode & 0x00F0) >> 4)
            if registers[x] != registers[y] {
                programCounter += 2
            } else {
                //Originally had code for programCounter += 2 until top level add
            }
        case 0xA000:
            indexRegister = opcode & 0x0FFF
        case 0xB000:
            programCounter = ((opcode & 0x0FFF) + (UInt16)(registers[0]))
        case 0xC000:
            let x = (Int)((opcode & 0x0FFF) >> 8)
            registers[x] = UInt8.random(in: 0 ... 255) & (UInt8)(opcode & 0x00FF)
        case 0xD000:
            let first : UInt16 = (UInt16)(registers[(Int)((opcode & 0x0F00) >> 8)])
            let second : UInt16 = (UInt16)(registers[(Int)((opcode & 0x00F0) >> 4)])
            let height : UInt16 = (UInt16)(opcode & 0x000F);
            
            registers[0xF] = 0
            for y in 0..<height {
                let pixel = memory.memory[(Int)(indexRegister + (UInt16)(y))]
                for x in 0..<8 {
                    if (pixel & (0x80 >> x)) != 0 {
                        
                        let xPortion = ((Int)(first) + (Int)(x)) % 64
                        let yPortion = ((Int)(second) + (Int)(y)) % 32
                        
                        let index = xPortion + (yPortion * 64)
                        //index = index % display.graphics.count
                        if display.graphics[index] == 1 {
                            registers[0xF] = 1
                        }
                        display.graphics[index] ^= 1
                    }
                }
            }
            display.drawFlag = true
        case 0xE000:
            let x = opcode & 0x00FF
            let index = (opcode & 0x0F00)>>8
            if x == 0x009E{
                if keyBoard.keyPad[(Int)(registers[(Int)(index)])] != 0 {
                    programCounter += 2
                }else {
                }
            } else if x == 0x00A1 {
                
                if keyBoard.keyPad[(Int)(registers[(Int)(index)])] == 0 {
                    programCounter += 2
                    //programCounter += 4
                }else {
                    //programCounter += 2
                }
            } else {
                print("Error, be here")
            }
        case 0xF000:
            let x = opcode & 0x00FF
            let index = (Int)((opcode & 0x0F00) >> 8)
            if x == 0x0007 {
                registers[index] = delayTimer
                //programCounter += 2
            } else if x == 0x000A {
                var keypress = false
                for i in 0..<16 {
                    if keyBoard.keyPad[i] != 0 {
                        registers[index] = (UInt8)(i)
                        keypress = true
                    }
                }
                //Need to get a keypress to continue :)
                if keypress == false {
                    return
                }
                //programCounter += 2
            } else if x == 0x0015 {
                delayTimer = registers[index]
                //programCounter += 2
            } else if x == 0x0018 {
                soundTimer = registers[index]
                //programCounter += 2
            } else if x == 0x001E {
                indexRegister += (UInt16)(registers[index])
                //programCounter += 2
            } else if x == 0x0029 {
                indexRegister = ((UInt16)(registers[index]) * 5)
                //programCounter += 2
            } else if x == 0x0033 {
                memory.memory[(Int)(indexRegister)] = registers[index] / 100
                memory.memory[(Int)(indexRegister + 1)] = (registers[index] / 10) % 10
                memory.memory[(Int)(indexRegister + 2)] = (registers[index] % 100) % 10
                //programCounter += 2
            } else if x == 0x0055 {
                for i in 0...index {
                    memory.memory[(Int)(indexRegister.advanced(by: i))] = registers[i]
                }
                
                indexRegister = indexRegister.advanced(by: index + 1)
                //programCounter += 2
                
            } else if x == 0x0065 {
                for i in 0...index {
                    registers[i] = memory.memory[(Int)(indexRegister) + i]
                }
                
                indexRegister = indexRegister &+ (UInt16)(index) &+ 1
                //programCounter += 2
                
            } else {
                print("Error, invalid opcode")
            }
        //Default tells us which opcodes we still need to implement.  Useful for debugging
        default:
            print(opcode)
            print("Not recognized")
            print("")
            isRunning = false
        }
        
        //Update the timers
        if delayTimer > 0 {
            delayTimer = delayTimer - 1
        }
        if soundTimer > 0 {
            if soundTimer == 1 {
                //Do the beepy beep here
                print("Beepity beep, Boop bop...")
            }
            soundTimer = soundTimer - 1
            
        }
        
    }

    
    /**
     Emulate a single cycle of the CPU
    */
    public func emulateCycle(){
        //Emulate a cycle here
        cycle();
    }
    
    
    
}
