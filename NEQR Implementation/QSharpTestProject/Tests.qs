namespace Quantum.QSharpTestProject {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
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

}