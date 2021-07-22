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
        

        // Create 2d array
        mutable _2dArray = [
            [0, 200],
            [100, 255]
        ];

        // Create index array of qubits 
        // The length of the index array is 2* the log base 2 of the size 
        // Ex a 2x2 is 2*logbase2(2) = 2
        let indexLength = 2 * Round(Lg(IntAsDouble(Length(_2dArray))));
        use index = Qubit[indexLength];

        // Intensity index for holding the greyscale values
        // Length is 2^q = size of scale 
        // Ex greyscale of 256 2^8 = 256
        use intensity = Qubit[8];


        mutable i = 0; 
        mutable uniqueNum = 0;
        mutable values = new String[0];

        // These are the values that the encoded register should hold
        mutable correctValues = ["0000000000","0111001000","1001100100","1111111111"];

        repeat 
        {
            // Call encoding operation 
            Operation(_2dArray,intensity, index);

            // Create a result array from the index+intensity qubit registers
            let resultArray = MultiM(index + intensity);

            // Reset Qubits
            ResetAll(index + intensity);

            // Convert result array to string
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

            // If new string is not unique set contains == true so it is not re-added
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
        

        // Repeat for 100 tries or four unique numbers. If you fail because
        // i > 100 the implementation is either incorrect or you are very unlucky 
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
    operation ArrayTest4x4 () : Unit {

        // Create 2d array
        mutable _2dArray4 = [
            [0, 200, 100, 50],
            [255, 75, 175, 200],
            [100, 170, 190, 220],
            [20, 245, 135, 140]
        ];

        //Create index array of qubits 
        //The length of the index array is 2* the log base 2 of the size 
        //Ex a 2x2 is 2*logbase2(2) = 2
        let indexLength = 2 * Round(Lg(IntAsDouble(Length(_2dArray4))));
        use index = Qubit[indexLength];
        
        //Intensity index for holding the greyscale values
        //Length is 2^q = size of scale 
        //Ex greyscale of 256 2^8 = 256
        use intensity = Qubit[8];

        mutable i = 0;
        mutable uniqueNum = 0;
        mutable values = new String[0];

        // Calculate + store correct values
        mutable correctValues = new String[0];
        mutable grayValue = 1;
        mutable grayString = "";
        mutable indexString = "";
        mutable grayB = new Bool[0];
        mutable indexB = new Bool[0];
        for row in 0 .. Length(_2dArray4[0])-1 {
            for col in 0 .. Length(_2dArray4[0])-1 {
                set grayValue = _2dArray4[row][col];
                //Message($"gray value: {grayValue}");
                set grayB = convertToBinary(grayValue);
                set grayB = padWithZeros(grayB, Length(intensity));
                //Message($"gray binary: {grayB}");
                set indexB = padWithZeros(convertToBinary(row), 2) + padWithZeros(convertToBinary(col), 2); 
                //Message($"index binary: {indexB}");
                set grayString = BooleanToString(grayB);
                set indexString = BooleanToString(indexB);
                set correctValues += [indexString + grayString];
            }
        }


        repeat 
        {
            //Call encoding operation 
            Operation(_2dArray4,intensity, index);
            let resultArray = MultiM(index + intensity);
            ResetAll(index + intensity);

            // Convert result array to String
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

		}until(i == 100 or uniqueNum == 16)
        fixup{}

        Message($"Correct Values: {correctValues}");
        Message($"Found Values: {values}");

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

    function convertToBinary (value: Int) : Bool[] {
        mutable cBinary = new Bool[0];

        // Save new variable so we can modify the value
        mutable val = value;

        mutable run = true;

        // Standard conversion to binary
        while (run) {
            set cBinary += [val % 2 != 0];
            set val = val / 2;

            set run = val != 0;
        }

        // Returns in big endian
        return cBinary[Length(cBinary) - 1 .. -1 .. 0];
    }
    
    function padWithZeros (binary : Bool[], targetLen : Int) : Bool[] {
        let diff = targetLen - Length(binary);
        mutable pad = new Bool[0];

        for i in 1 .. diff {
            set pad += [false];
        }

        return pad + binary;
    }

    function BooleanToString (valuesB: Bool[]) : String {
        mutable bString = "";
        
        for valB in valuesB {
            if valB {
                set bString = bString + "1";
            }
            else {
                set bString = bString + "0";
            }
        }

        return bString;

    }


@Test("QuantumSimulator")
    operation RandomSizeAndIntensities () : Unit {
        
        // Loop through several sizes
        for scaleExp in 1 .. 5 {
            // Loop through several grayscale ranges
            for rangeExp in 1 .. 8 {

                // The size of the conventional 2D array
                mutable size = PowI(2, scaleExp);
                // The range for this iteration
                mutable grayscaleRange = PowI(2, rangeExp) - 1;

                // Conventional array creation in Q#
                // Shield your eyes children

                // The 2D array containing the pseudorandom values
                mutable _2dRand = new Int[][0];

                // Populate the array with random values in range
                for row in 0 .. size - 1 {
                    mutable tempArr = new Int[0];
                    for col in 0 .. size - 1 {
                        set tempArr += [DrawRandomInt(0, grayscaleRange)];
                    }

                    set _2dRand += [tempArr];
                }

                mutable i = 0;
                mutable uniqueNum = 0;
                mutable values = new String[0];
                mutable indexLength = 2 * scaleExp;

                // Length to pad to is the number of intensity qubits
                // plus the number of index qubits
                mutable correctValues = FindCorrectValues(
                    _2dRand, rangeExp, indexLength
                );

                use (intensity, index) = (
                    Qubit[rangeExp], 
                    Qubit[indexLength]
                ) {
                    Message($"Grayscale Range: {grayscaleRange} ({rangeExp} qubits)");
                    Message($"Index Length: {indexLength}");
                    Message("");

                    Message("2D Array: ");
                    
                    for line in _2dRand {
                        Message($"{line}");
                    }

                    Message($"Correct Values: {correctValues}");

                    DumpRegister((), index);
                

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

                for value in values {
                    mutable found = false; 

                    for correct in correctValues {
                        if value == correct {
                            set found = true;
                        }
                    }

                    if found == false {
                        fail $"The value {value} is incorrect ";
                    }
                    
                }

                
                Message("Found!");
                Message("\n");

            }
        }
    }

    function FindCorrectValues(
        _2dArray : Int[][], 
        regLength : Int, 
        indexLength : Int
    ) : String[] {
        mutable correctValuesBool = new Bool[][0];

        for row in 0 .. Length(_2dArray) - 1 {
            for col in 0 .. Length(_2dArray[row]) - 1 {
                // Create index values and pad with zeros
                mutable index = padWithZeros(convertToBinary(row), indexLength/2);
                set index += padWithZeros(convertToBinary(col), indexLength/2);

                //Message($"Index for {row}, {col}: {index}");

                set correctValuesBool += [
                    index + 
                    padWithZeros(
                        convertToBinary(_2dArray[row][col]), regLength
                    )
                ];
            }
        }

        // Message("Array before padding:");
        // for line in correctValuesBool {
        //     Message($"{line}");
        // }

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