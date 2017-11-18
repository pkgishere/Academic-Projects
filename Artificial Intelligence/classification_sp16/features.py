# features.py
# -----------
# Licensing Information:  You are free to use or extend these projects for
# educational purposes provided that (1) you do not distribute or publish
# solutions, (2) you retain this notice, and (3) you provide clear
# attribution to UC Berkeley, including a link to http://ai.berkeley.edu.
# 
# Attribution Information: The Pacman AI projects were developed at UC Berkeley.
# The core projects and autograders were primarily created by John DeNero
# (denero@cs.berkeley.edu) and Dan Klein (klein@cs.berkeley.edu).
# Student side autograding was added by Brad Miller, Nick Hay, and
# Pieter Abbeel (pabbeel@cs.berkeley.edu).


import numpy as np
import util
import samples

DIGIT_DATUM_WIDTH=28
DIGIT_DATUM_HEIGHT=28

def basicFeatureExtractor(datum):
    """
    Returns a binarized and flattened version of the image datum.

    Args:
        datum: 2-dimensional numpy.array representing a single image.

    Returns:
        A 1-dimensional numpy.array of features indicating whether each pixel
            in the provided datum is white (0) or gray/black (1).
    """
    features = np.zeros_like(datum, dtype=int)
    features[datum > 0] = 1
    return features.flatten()

def enhancedFeatureExtractor(datum):
    features = basicFeatureExtractor(datum)
    feature = np.array(features)
    Flag = 0
    count =0
    Sum2=0
    List1=[]
    List3=[]

    for i in range(28):
        Sum=0;
        for j in range(28):
            if(abs(14-i) <12 and abs(14-j) <12 ):
                Sum2+=feature[i*28+j]
                List1.append(features[i*28+j])
            else:
                Sum+=features[i*28+j]
            length = 28*j+i
            Flag = feature[length]
            if Flag == 0:
                count+=1
                Padosi(i, j, feature)
        List3.append(min(1,Sum))
    List2=[0,0,0]
    count=count%4;
    List2[count-1]=count
    #List1.append(List3)
    List2 = np.array(List2)
    List3.append(min(abs(Sum2-521)/4,4))
    List3=np.array(List3)
    List2=np.concatenate((List3,List2),axis=0)
    return np.append(List1, List2)


def analysis(model, trainData, trainLabels, trainPredictions, valData, valLabels, validationPredictions):
     #Put any code here...
     #Example of use:
     #exit()
     for i in range(len(trainPredictions)):
         prediction = trainPredictions[i]
         truth = trainLabels[i]
         if (prediction != truth):
             print "==================================="
             print "Mistake on example %d" % i
             print "Predicted %d; truth is %d" % (prediction, truth)
             print "Image: "
             print_digit(trainData[i,:])


## =====================
## You don't have to modify any code below.
## =====================


def Padosi(X,Y, List):
    	if X < 27:
            Index = 28*Y+X+1
            if List[Index] == 0:
                List[Index] = 1
                Padosi(X+1, Y, List)
        if X >= 1:
            Index = 28* Y+X-1
            if List[Index] == 0:
                List[Index] = 1
                Padosi(X-1, Y, List)
        if Y < 27:
            Index = 28*(Y+1)+X
            if List[Index] == 0:
                List[Index] = 1
                Padosi(X,Y+1, List)
        if Y >= 1:
            Index = 28*(Y-1)+X
            if List[Index] == 0:
                List[Index] = 1
                Padosi(X, Y-1, List)

def print_features(features):
    str = ''
    width = DIGIT_DATUM_WIDTH
    height = DIGIT_DATUM_HEIGHT
    for i in range(width):
        for j in range(height):
            feature = i*height + j
            if feature in features:
                str += '#'
            else:
                str += ' '
        str += '\n'
    print(str)

def print_digit(pixels):
    width = DIGIT_DATUM_WIDTH
    height = DIGIT_DATUM_HEIGHT
    pixels = pixels[:width*height]
    image = pixels.reshape((width, height))
    datum = samples.Datum(samples.convertToTrinary(image),width,height)
    print(datum)

def _test():
    import datasets
    train_data = datasets.tinyMnistDataset()[0]
    for i, datum in enumerate(train_data):
        print_digit(datum)

if __name__ == "__main__":
    _test()
