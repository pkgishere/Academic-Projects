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
def getContiguousWhiteSpaces(graph):

    def getPixel(x, y, graph):
        return graph[y][x]
    
    def findSingleWhiteSpaceCoords(graph, closedSet1, closedSet2):
        """Finds a white space's coordinates on the graph that is not contained in the closed sets passed in"""

        N = 28
        
        for i in range(N):
            for j in range(N):
                randomPixel = getPixel(i, j, graph)
                if (randomPixel == 0) and ( (i,j) not in closedSet1) and ( (i,j) not in closedSet2):
                    
                    return (i, j)

        return (-1, -1)             #Couldn't find any more whitespace

    def addNeighborsToFringe(x, y, fringe):
        if x > 0:
            fringe.push( (x-1,y) )
        
        if x < len(graph)-1:
            fringe.push( (x+1,y) )
        
        if y > 0:
            fringe.push( (x,y-1) )

        if y < len(graph)-1:
            fringe.push( (x,y+1) )

    fringe = util.Queue()
    closedSet1      = set()
    closedSet2      = set()
    closedSet2Plus  = set()
    
    #Finding a first whitespace
    x, y = findSingleWhiteSpaceCoords(graph, closedSet1, closedSet2)

    #Adding it to the fringe
    fringe.push( (x,y) )

    #Keep going until I've found 1 total contiguous whitespace
    while not fringe.isEmpty():
        (x,y) = fringe.pop()

        if (x,y) not in closedSet1:
            closedSet1.add( (x,y) )

            #Only add white pixels' neighbors to fringe
            if 0 == getPixel( x, y, graph ):
                addNeighborsToFringe( x, y, fringe )

    #============
    #After finding one contiguous whitespace, another one may exist
    nextWhiteSpace = findSingleWhiteSpaceCoords(graph, closedSet1, closedSet2)

    #Handles case that I couldn't find another white space in a different group
    if nextWhiteSpace == (-1, -1):
        return [1, 0, 0]

    #Add this nextWhiteSpace to the fringe and find all its neighbors
    fringe.push( nextWhiteSpace )
    
    #Keep going until I've found my second contiguous whitespace
    while not fringe.isEmpty():
        (x,y) = fringe.pop()

        if (x,y) not in closedSet2:
            closedSet2.add( (x,y) )

            #Only add white pixels' neighbors to fringe
            if 0 == getPixel( x, y, graph ):
                addNeighborsToFringe( x, y, fringe )    
    
    #============
    #After finding two contiguous whitespaces, another one may exist
    nextWhiteSpace = findSingleWhiteSpaceCoords(graph, closedSet1, closedSet2)

    #Handles case that I couldn't find another white space in a different group (only have 2 whitespaces)
    if nextWhiteSpace == (-1, -1):
        return [0, 1, 0]
    else:
        return [0, 0, 1]


def enhancedFeatureExtractor(datum):
    features = basicFeatureExtractor(datum)
    List1=[]
    List2=[]
    List=[]
    Max=0
    Max1=0
    Sum2=0
    Sumx=0
    Sumy=0
    #for i in range(28):
	#for j in range(28):
		#if(i==0):
			#SetValue=feature(
    for i in range(28):
	
    	Sum=0
    	Sum1=0
        for j in range(28):
		if(abs(14-i) < 12 and abs(14-j)  <12):
			Sum2+=features[(i)*28+j]
			List1.append(features[(i-1)*28+j])
		else:
			Sum += features[(i-1)*28+j]
			Sum1+= features[(j-1)*28+i]
		if(i>j):
			Sumx+=features[(i-1)*28+j]
		else:
			Sumy+=features[(i-1)*28+j]
		
    	#List1.append(Sum1)
    	List2.append(Sum)
    #List1.append(min(1,max(List1)/4))
    #List1.append(min(1,max(List2)/5)) 
    #List1.append(Sum2/90)
    List =np.array(List)
    features=np.array(features)
    features=np.concatenate((List1,features),axis=0)
    return List1



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
