package tools;

import cartago.*;

public class Converter extends Artifact {
    
    @OPERATION
    public void convert(Object valueInit, Object minInit, Object maxInit, Object minFinal, Object maxFinal,  OpFeedbackParam<Integer> valueFinal) {

        Double value0 = Double.valueOf(valueInit.toString());
        Double min0 = Double.valueOf(minInit.toString());
        Double max0 = Double.valueOf(maxInit.toString());
        Double min1 = Double.valueOf(minFinal.toString());;
        Double max1 = Double.valueOf(maxFinal.toString());;
        Double value1 = min1 + ((value0 - min0)*(max1 - min1)/(max0 - min0));
        valueFinal.set(value1.intValue());
      }
}
