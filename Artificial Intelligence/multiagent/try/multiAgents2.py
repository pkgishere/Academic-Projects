# multiAgents.py
# --------------
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


from util import manhattanDistance
from util import EuclideanDistance
from game import Directions
import random, util

from game import Agent

class ReflexAgent(Agent):
    """
      A reflex agent chooses an action at each choice point by examining
      its alternatives via a state evaluation function.

      The code below is provided as a guide.  You are welcome to change
      it in any way you see fit, so long as you don't touch our method
      headers.
    """

    def getAction(self, gameState):
        """
        You do not need to change this method, but you're welcome to.

        getAction chooses among the best options according to the evaluation function.

        Just like in the previous project, getAction takes a GameState and returns
        some Directions.X for some X in the set {North, South, West, East, Stop}
        """
        # Collect legal moves and successor states
        legalMoves = gameState.getLegalActions()

        # Choose one of the best actions
        scores = [self.evaluationFunction(gameState, action) for action in legalMoves]
        bestScore = max(scores)
        bestIndices = [index for index in range(len(scores)) if scores[index] == bestScore]
        chosenIndex = random.choice(bestIndices) # Pick randomly among the best

        "Add more of your code here if you want to"

        return legalMoves[chosenIndex]

    def evaluationFunction(self, currentGameState, action):
        """
        Design a better evaluation function here.

        The evaluation function takes in the current and proposed successor
        GameStates (pacman.py) and returns a number, where higher numbers are better.

        The code below extracts some useful information from the state, like the
        remaining food (newFood) and Pacman position after moving (newPos).
        newScaredTimes holds the number of moves that each ghost will remain
        scared because of Pacman having eaten a power pellet.

        Print out these variables to see what you're getting, then combine them
        to create a masterful evaluation function.
        """

        successorGameState = currentGameState.generatePacmanSuccessor(action)
	newPos = successorGameState.getPacmanPosition()
        newFood = successorGameState.getFood()
        newGhostStates = successorGameState.getGhostStates()
        newScaredTimes = [ghostState.scaredTimer for ghostState in newGhostStates]
	
	List=[];
	Tuple=();
	manHattanList=[];
	FoodDistance=0.0
	for row,value in enumerate(newFood):
		for column,Value in enumerate(value):
			if(Value):
				Tuple=(row,column)
				List.append(Tuple)
				manHattanList.append(manhattanDistance(newPos,Tuple))
	if(len(manHattanList)==0):
		manHattanList.append(0);
	FoodDistance=min(manHattanList);
	
	score=0.0
	GhostDistance=-1000.0
	EuclideanList=[]
	GhostManhattanList=[]
	for Ghost in newGhostStates:
		GhostManhattanList.append(manhattanDistance(Ghost.getPosition(),newPos))
		EuclideanList.append(EuclideanDistance(Ghost.getPosition(),newPos))
	GhostDistance1=min(EuclideanList)
	GhostDistance2=min(GhostManhattanList)
	
	
	CapsuleDistance=float("inf");
	CapsulesList=[];
	for capsules in successorGameState.getCapsules():
		CapsulesList.append(EuclideanDistance(capsules,newPos))
	if(successorGameState.getCapsules()):
		CapsuleDistance=min(CapsulesList)
	if(CapsuleDistance<GhostDistance2):
		score+= 1


	if(successorGameState.isWin()):
		return float("inf")

	Value=0
	if(GhostDistance1<=2):
		if(GhostDistance2==1):
			Value = 100
		elif(GhostDistance2<2):
			Value = 10
		else:
			Value = 5
	if(min(newScaredTimes)>4):
		Value=-Value
	score = score - Value
	score+=float(1)/float(len(List))
	score += float(1.0)/float(FoodDistance)			

	return successorGameState.getScore()+score



def scoreEvaluationFunction(currentGameState):
    """
      This default evaluation function just returns the score of the state.
      The score is the same one displayed in the Pacman GUI.

      This evaluation function is meant for use with adversarial search agents
      (not reflex agents).
    """
    return currentGameState.getScore()

class MultiAgentSearchAgent(Agent):
    """
      This class provides some common elements to all of your
      multi-agent searchers.  Any methods defined here will be available
      to the MinimaxPacmanAgent, AlphaBetaPacmanAgent & ExpectimaxPacmanAgent.

      You *do not* need to make any changes here, but you can if you want to
      add functionality to all your adversarial search agents.  Please do not
      remove anything, however.

      Note: this is an abstract class: one that should not be instantiated.  It's
      only partially specified, and designed to be extended.  Agent (game.py)
      is another abstract class.
    """

    def __init__(self, evalFn = 'scoreEvaluationFunction', depth = '2'):
        self.index = 0 # Pacman is always agent index 0
        self.evaluationFunction = util.lookup(evalFn, globals())
        self.depth = int(depth)

class MinimaxAgent(MultiAgentSearchAgent):
	

	def Max(self, gameState, depth,  AgentNo ):
		if depth==self.depth or gameState.isWin() or gameState.isLose():
			return self.evaluationFunction(gameState)
		MaxEval=float("-inf")
		for action in gameState.getLegalActions(AgentNo):
        		successor = gameState.generateSuccessor(AgentNo, action)
			MaxEval=max(MaxEval,self.Min(successor, depth, AgentNo+1))
		return MaxEval

	


	def Min(self, gameState, depth, AgentNo):
		if depth==self.depth or gameState.isWin() or gameState.isLose():
			return self.evaluationFunction(gameState)
		MinEval=float("inf")
		for action in gameState.getLegalActions(AgentNo):
			if AgentNo== gameState.getNumAgents() -1 :
				Value=self.Max(gameState.generateSuccessor(AgentNo,action),depth + 1 ,0)
			else:
				Value=self.Min(gameState.generateSuccessor(AgentNo,action),depth,AgentNo+1)
			MinEval=min(Value,MinEval)
				
		return MinEval


	def getAction(self, gameState):
		Value=float("-inf")
		Action=Directions.STOP
		for action in gameState.getLegalActions(0):
			Val=self.Min(gameState.generateSuccessor(0,action),0,1)
			if(Val > Value):
				Value = Val
				Action=action
		return Action





	

class AlphaBetaAgent(MultiAgentSearchAgent):
	
	def getAction(self, gameState):
        	"""
        	  Returns the minimax action using self.depth and self.evaluationFunction
        	"""
        	"*** YOUR CODE HERE ***"

		
		Value=float('-inf')
		Alpha=float('-inf')

		Beta=float('inf')
		Action=Directions.STOP
		for action in gameState.getLegalActions(0):
			Val=self.Min(gameState.generateSuccessor(0,action),0,1,Alpha,Beta)
			if(Val > Value):
				Value = Val
				Action=action
			if(Value > Beta):
				return Action
			Alpha=max(Value,Alpha)
		return Action


	def Max(self, gameState, depth,  AgentNo, Alpha,Beta ):
		if depth==self.depth or gameState.isWin() or gameState.isLose():
			return self.evaluationFunction(gameState)
		MaxEval=float('-inf')
		for action in gameState.getLegalActions(AgentNo):
			if(len(action))==0:
				return self.evaluationFunction(gameState)
        		successor = gameState.generateSuccessor(AgentNo, action)
			MaxEval=max(MaxEval,self.Min(successor, depth, AgentNo+1,Alpha,Beta))
			if (MaxEval > Beta):
				return MaxEval
			Alpha=max(Alpha,MaxEval)
		return MaxEval

	

	def Min(self, gameState, depth, AgentNo,Alpha,Beta):
		if depth==self.depth or gameState.isWin() or gameState.isLose():
			return self.evaluationFunction(gameState)
		MinEval=float('inf')
		for action in gameState.getLegalActions(AgentNo):
			if(len(action)==0):
				return self.evaluationFunction(gameState)
			if AgentNo== gameState.getNumAgents() -1 :
				Value=self.Max(gameState.generateSuccessor(AgentNo,action),depth + 1 ,0,Alpha,Beta)
			else:
				Value=self.Min(gameState.generateSuccessor(AgentNo,action),depth,AgentNo+1,Alpha,Beta)
			MinEval=min(Value,MinEval)
			if(MinEval< Alpha):
				return MinEval
			Beta=min(Beta,MinEval)
		return MinEval






class ExpectimaxAgent(MultiAgentSearchAgent):
	
	def Expectation(self, gameState,depth,AgentNo):
		if depth == self.depth or gameState.isWin() or gameState.isLose():
			return self.evaluationFunction(gameState)
		Eval = 0
		for action in gameState.getLegalActions(AgentNo):
			if AgentNo == gameState.getNumAgents() - 1:
				Eval += self.Max(gameState.generateSuccessor(AgentNo, action),depth +1 ,0)
			else:
				Eval =Eval+ self.Expectation(gameState.generateSuccessor(AgentNo, action),depth,AgentNo +1)
		Eval = float(Eval)/float(len(gameState.getLegalActions(AgentNo)))
		return Eval


	def Max(self, gameState, depth,  AgentNo ):
		if depth==self.depth or gameState.isWin() or gameState.isLose():
			return self.evaluationFunction(gameState)
		MaxEval=float("-inf")
		for action in gameState.getLegalActions(AgentNo):
        		successor = gameState.generateSuccessor(AgentNo, action)
			MaxEval=max(MaxEval,self.Min(successor, depth, AgentNo+1))
		return MaxEval


	def Min(self, gameState, depth, AgentNo):
		if depth==self.depth or gameState.isWin() or gameState.isLose():
			return self.evaluationFunction(gameState)
		MinEval=float("inf")
		for action in gameState.getLegalActions(AgentNo):
			if AgentNo== gameState.getNumAgents() -1 :
				Value=self.Max(gameState.generateSuccessor(AgentNo,action),depth + 1 ,0)
			else:
				Value=self.Min(gameState.generateSuccessor(AgentNo,action),depth,AgentNo+1)
			MinEval=min(Value,MinEval)
				
		return MinEval



	def getAction(self, gameState):
		"""
			Returns the expectimax action using self.depth and self.evaluationFunction
			All ghosts should be modeled as choosing uniformly at random from their
			legal moves.
		"""
		"*** YOUR CODE HERE ***"
		actions = gameState.getLegalActions(0)
		Eval = float('-inf')
		nextAction = Directions.STOP
		for action in actions:
			VAL = self.Expectation(gameState.generateSuccessor(0, action),0,1)
			if VAL > Eval:
				Eval = VAL
				nextAction = action
		return nextAction

def betterEvaluationFunction(currentGameState):
	
        
	newPos = currentGameState.getPacmanPosition()
	newGhostStates = currentGameState.getGhostStates()
	newFood = currentGameState.getFood()
	newScaredTimes= [ghostState.scaredTimer for ghostState in newGhostStates]
	
    	score = 0.0		
   	
	List=[]
	Tuple=()
	manHattanList=[] 
	FoodDistance=0.0
	for row,value in enumerate(newFood):
		for column,Value in enumerate(value):
			if(Value):
				Tuple=(row,column)
				List.append(Tuple)
				manHattanList.append(manhattanDistance(newPos,Tuple))
	if(len(manHattanList)==0):
		manHattanList.append(0);
	FoodDistance=min(manHattanList);

	GhostDistance=-1000.0
	EuclideanList=[]
	GhostManhattanList=[]
	for Ghost in newGhostStates:
		GhostDistance1=manhattanDistance(Ghost.getPosition(),newPos)
		GhostDistance2=EuclideanDistance(Ghost.getPosition(),newPos)
		GhostManhattanList.append(GhostDistance1)
		EuclideanList.append(GhostDistance2)
		Value=0
		if(GhostDistance1<=2):
			if(GhostDistance2==1):
				Value = 100
			elif(GhostDistance2<2):
				Value = 10
			else:
				Value = 5
		if(min(newScaredTimes)>4):
			Value=-Value
		score = score - Value
	
	
	CapsuleDistance=float("inf");
	CapsulesList=[];
	for capsules in currentGameState.getCapsules():
		CapsulesList.append(EuclideanDistance(capsules,newPos))
	if(currentGameState.getCapsules()):
		CapsuleDistance=min(CapsulesList)
	#if(CapsuleDistance<GhostDistance2):
	#	score+= 1

	score+=float(1)/float(len(List)+1)
	score += float(1.0)/float(FoodDistance+1)			
	
	return score + currentGameState.getScore()


# Abbreviation
better = betterEvaluationFunction

