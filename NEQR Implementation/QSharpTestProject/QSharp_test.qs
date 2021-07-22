namespace Quantum.QSharpTestProject {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Random;
    open QSharpTestProject;

   
    @Test("QuantumSimulator")
    operation ArrayTest2x2 () : Unit {
        

        //Create 2d array
        mutable _2dArray = [
            [0, 200],
            [100, 255]
        ];

        //Create index array of qubits 
        //The length of the index array is 2* the log base 2 of the size 
        //Ex a 2x2 is 2*logbase2(2) = 2
        let indexLength = 2 * Round(Lg(IntAsDouble(Length(_2dArray))));
        use index = Qubit[indexLength];

        //Intensity index for holding the greyscale values
        //Length is 2^q = size of scale 
        //Ex greyscale of 256 2^8 = 256
        use intensity = Qubit[8];


        mutable i = 0; 
        mutable uniqueNum = 0;
        mutable values = new String[0];

        //These are the values that the encoded register should hold
        mutable correctValues = ["0000000000","0111001000","1001100100","1111111111"];

        repeat 
        {
            //Call encoding operation 
            Operation(_2dArray,intensity, index);

            //Create a result array from the index+intensity qubit registers
            let resultArray = MultiM(index + intensity);

            //Reset Qubits
            ResetAll(index + intensity);

            //Convert result array to string
            mutable s = "";
            for value in resultArray
            {
                if value == One
                {
                    set s+="1";
                }
                else
                {
                    set s+="0";
                }
            }


            Message($"Measured: {s}");

            mutable contains = false;

            //If new string is not unique set contains == true so it is not re-added
            for x in values
            {
                if s == x
                {
                    set contains = true;
                }
            }

            if contains == false
            {
                set values += [s];
                set uniqueNum = uniqueNum + 1;
                Message($"{s} was a unique value");
            }

            set i = i + 1; 
        

        //Repeat for 100 tries or four unique numbers. If you fail because i > 100 the implementation is either incorrect or you are very unlucky 
		}until(i == 100 or uniqueNum == 4)
        fixup{}

        Message($"Correct Values: {correctValues}");
        Message($"Found Values: {values}");


        //Check for correct values
        for value in values
        {
            mutable found = false; 

            for correct in correctValues
            {
                if value == correct
                {
                    set found = true;
                }
            }

            if found == false
            {
                fail $"The value {value} is incorrect ";
            }
            
        }
        
    }

    @Test("QuantumSimulator")
    operation RandomSizeAndIntensities () : Unit {
        
        // Loop through several sizes
        for scaleExp in 1 .. 3 {
            // Loop through several grayscale ranges
            for rangeExp in 0 .. 8 {

                // The size of the conventional 2D array
                mutable size = PowI(2, scaleExp);
                // The range for this iteration
                mutable grayscaleRange = PowI(2, rangeExp) - 1;

                // Conventional array creation
                // Shield your eyes

                // The 2D array containing the pseudorandom values
                mutable _2dRand = new Int[][0];

                // Populate the array with random values in range
                for row in 0 .. size {
                    mutable tempArr = new Int[0];
                    for col in 0 .. size {
                        set tempArr += [DrawRandomInt(0, grayscaleRange)];
                    }

                    set _2dRand += [tempArr];
                }

                mutable i = 0;
                mutable uniqueNum = 0;
                mutable values = new String[0];

                mutable correctValues = FindCorrectValues(_2dRand, rangeExp);

                use (intensity, index) = (
                    Qubit[PowI(2, rangeExp)], 
                    Qubit[2 * scaleExp]
                ) {

                

                    // Quantum stuff 
                    repeat {
                        //Call encoding operation 
                        Operation(_2dRand, intensity, index);
                        let s = BoolArrayToString(
                            ResultArrayAsBoolArray(
                                MultiM(index + intensity)
                            )
                        );
                        ResetAll(index + intensity);

                        //mutable resultArray = Operation2(_2dArray); 

                        Message($"Measured: {s}");

                        mutable contains = false;

                        for x in values {
                            if x == s {
                                set contains = true;
                            }
                        }

                        if contains == false {
                            set values += [s];
                            set uniqueNum = uniqueNum + 1;
                            Message($"{s} was a unique value");
                        }

                        set i = i + 1; 

                    } until(i == 100 or uniqueNum == 4)
                    fixup{}
            }

                Message($"Correct Values: {correctValues}");
                Message($"Found Values: {values}");

                for correct in correctValues {
                    mutable found = false; 

                    for value in values {
                        if value == correct {
                            set found = true; 
                        }
                    }

                    if found == false {
                        fail "Fail";
                    }
                    
                }

            }
        }
    }

    function FindCorrectValues(_2dArray : Int[][], length : Int) : String[] {
        mutable correctValuesBool = new Bool[][0];

        for row in 0 .. Length(_2dArray) - 1 {
            for col in 0 .. Length(_2dArray[row]) - 1 {
                mutable index = convertToBinary(row);
                set index += convertToBinary(col);
                set correctValuesBool += [index + convertToBinary(_2dArray[row][col])];
            }
        }

        for i in 0 .. Length(correctValuesBool) - 1 {
            set correctValuesBool w/= i <- padWithZeros(correctValuesBool[i], length);
        }

        mutable correctValues = new String[0];

        for array in correctValuesBool {
            set correctValues += [BoolArrayToString(array)];
        }

        return correctValues;
    }

    function BoolArrayToString(array : Bool[]) : String {
        mutable s = "";

        for item in array {
            set s += item ? "1" | "0";
        }

        return s;
    }
}