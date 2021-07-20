namespace QSharpTestProject {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;


    operation Operation1 (grayScaleValues : Int[][]) : Unit {
        mutable result = new Qubit[DoubleAsInt(Lg(IntAsDouble(grayScaleValues.GetLength(0))))];
        ApplyToEach(H, result);
        for col in 0 .. grayScaleValues.GetLength(0)-1 {
            for row in 0 .. grayScaleValues.GetLength(0)-1 {
                set (rowBinary, rowString) = convertToBinary(row);
                set (colBinary, colString) = convertToBinary(col);
                set indexBinary = new Qubit[0];
                indexBinary.append(rowBinary);
                indexBinary.append(colBinary);
                set indexString = new Int[0];
                indexString.append(rowString);
                indexString.append(colString);
                set (grayScaleBinary, grayScaleString) = convertToBinary(grayScaleValues[row][col]);
                within {
                    for index in 0 .. Length(indexString)-1 {
                    if indexString[index] == 0 {
                        X(indexBinary[index]);
                    }
                }
                    
                }
                apply {
                    for index in 0 .. Length(grayScaleString)-1 {
                    if grayScaleString[index] == 1 {
                        Controlled X(indexBinary, grayScaleBinary[index]);
                    }
                }
                
                }
                
                  



            }


        }
    }

    operation NEQRImageProcess (row: Int, col: Int, grayScaleValue: Int) : Unit {
        set grayScaleBinary = convertToBinary(grayScaleValue);
        
    }

    operation convertToBinary (value: Int) : (Qubit[], Int[]) {
        mutable cBinary = new Int[0];
        repeat {
            cBinary.append(value % 2);
            let value = value / 2;
        }
        until value == 0;
        mutable qubitArr = new Qubit[Length(cBinary)];
        for cBit in cBinary {
            if cBit == 0 {
                use qubit0 = Qubit();
                qubitArr.append(qubit0);
            }
            else {
                use qubit1 = Qubit();
                X(qubit1);
                qubitArr.append(qubit1);
            }
        }
        return (qubitArr, cBinary);
    }
}
