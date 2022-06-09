char=''
numChar=0
state=Array.new
sourceCode=Array.new
tableLexem=Array.new
state='q0'
lexem = Array.new
### State Definition
   stf={ ['q0', 'ws']=>'q0', ['q0', 'Letter']=> 'q1', ['q1', 'Letter']=> 'q1', ['q1', 'Digit']=> 'q1', ['q1', 'other']=> 'q2', ['q0', '; ']=> 'q3', ['q0', 'nl']=> 'q3', ['q0', '+']=> 'q4', ['q0', '-']=> 'q4', ['q0', '*']=> 'q4', ['q0', '/']=> 'q4', ['q0', '^']=> 'q4', ['q0', '(']=> 'q4', ['q0', ') ']=> 'q4', ['q0', 'Digit'] =>'q5', ['q5', 'Digit']=> 'q6', ['q5', '.']=> 'q6', ['q0', '.']=> 'q6', ['q6', 'Digit']=> 'q6', ['q6', 'other']=> 'q7', ['q5', 'other']=> 'q8', ['q0', ':']=> 'q10', ['q10', '=']=> 'q9', ['q10', 'other']=> 'q102', ['q9', 'other']=> 'q11', ['q0', 'other']=> 'q103'}
initState = 'q0' # q0 – стартовий стан
def is_final(state)
  f= {'q2'=> 'q2', 'q3'=> 'q3', 'q4'=> 'q4', 'q7'=> 'q7', 'q8'=> 'q8', 'q11'=> 'q11', 'q14'=>'q14'} #–
  f[state]
end

def is_final_error(state)
  f= {'q102'=> 'Error', 'q103'=> 'Error'} #–
  f[state]
end
def getToken(lexem)
  tablesOfLanguageTokens = {'program'=>'keyword', 'end'=>'keyword', 'for'=>'keyword', 'to'=>'keyword', 'do'=>'keyword', 'if'=>'keyword', 'goto'=>'keyword', ':=' =>'assign', '.'=>'dot', ' '=>'ws', '\t'=>'ws', '\n'=>'nl', ';'=>'nl', '+'=>'math_op', '-'=>'math_op', '*'=>'math_op', '/'=>'math_op', '^+'=>'math_op', '<'=>'log_op', '<='=>'log_op', '>'=>'log_op', '>='=>'log_op', '~'=>'log_op'}
  tablesOfLanguageTokens[lexem]
end

tableIdentRealInt = {'q2'=>'identificator', 'q7'=>'real', 'q8'=>'integer'}
def nextState(state, classCh)
   stf={ ['q0', 'ws']=>'q0', ['q0', 'Letter']=> 'q1', ['q1', 'Letter']=> 'q1', ['q1', 'Digit']=> 'q1', ['q1', 'other']=> 'q2', ['q0', '; ']=> 'q3', ['q0', 'nl']=> 'q3', ['q0', '+']=> 'q4', ['q0', '-']=> 'q4', ['q0', '*']=> 'q4', ['q0', '/']=> 'q4', ['q0', '^']=> 'q4', ['q0', '(']=> 'q4', ['q0', ') ']=> 'q4', ['q0', 'Digit'] =>'q5', ['q5', 'Digit']=> 'q6', ['q5', '.']=> 'q6', ['q0', '.']=> 'q6', ['q6', 'Digit']=> 'q6', ['q6', 'other']=> 'q7', ['q5', 'other']=> 'q8', ['q0', ':']=> 'q10', ['q10', '=']=> 'q9', ['q10', 'other']=> 'q102', ['q9', 'other']=> 'q11', ['q0', 'other']=> 'q103'}
    stf[[state,classCh]]? stf[[state, classCh]] :  stf[[state, "other"]]
end

def classOfChar(char)
  abc =['a','b','c','d','e','f','g','h','e','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']
dig = ['0','1','2','3','4','5','6','7','8','9']
math = ['+','-','*','/','^','(',')']
log = ['>','>=','<','<=','~']
if char == '.'
      result = 'dot'
    elsif abc.find_all{ |elem| elem == char}.size !=0
      result = 'Letter'
    elsif dig.find_all{ |elem| elem == char}.size !=0
      result = 'Digit'
    elsif char == '\t'
      result = 'ws'
    elsif char=='\n' || char==';'
    result = 'nl'
    elsif math.find_all{ |elem| elem == char}.size !=0
      result = char
    elsif log.find_all{ |elem| elem == char}.size !=0
      result = char
    else result = "Symbol does not belonges to abs"
  end
end

tableOfSymb = {'num_line'=>'numLine', 'lexem'=>'lexem', 'token'=>'token', 'idxIdConst'=>'idxIdConst' }
tableOfId= {'id' => 'idxId'}
tableOfConst ={'Const' => 'idxConst'}
tableOfLabel ={'Label' => 'idxLbl'}


def lexema
lexem=''
file = File.open('mnv.txt')
sourceCode=file.read
length =sourceCode.size
i=0
state='q0'
initState = 'q0'
  numLine=0
while i<length do
  char=sourceCode[i]
  classCh=classOfChar(char)
  state=nextState(state,classCh)
  if is_final_error(state) then  puts 'Error "#{state}"'
    elsif is_final(state) then puts"1"#processing(state)
    elsif state==initState then lexem+=' '
    else lexem+= char
      puts lexem
  end
  i +=1

  end
end

  def processing(state)
    tablesOfLanguageTokens = {'program'=>'keyword', 'end'=>'keyword', 'for'=>'keyword', 'to'=>'keyword', 'do'=>'keyword', 'if'=>'keyword', 'goto'=>'keyword', ':=' =>'assign', '.'=>'dot', ' '=>'ws', '\t'=>'ws', '\n'=>'nl', ';'=>'nl', '+'=>'math_op', '-'=>'math_op', '*'=>'math_op', '/'=>'math_op', '^+'=>'math_op', '<'=>'log_op', '<='=>'log_op', '>'=>'log_op', '>='=>'log_op', '~'=>'log_op'}
    lexema
    if state=='q3' then numLine +=1 &&
      state=initState
    elsif state=='q2' || state=='q7' || state=='q8'
      then token= getToken(lexem)
    else puts 'x'
    end
    end


    lexema
