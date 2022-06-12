char=''
numChar=0
nextstate=Array.new
sourceCode=Array.new
tableLexem=Array.new
state='q0'
lexem = Array.new

##Alphabet Алфавіт - зчитуємо символ, взнаємо його клас
def classOfChar(char)
  abc =['a','b','c','d','e','f','g','h','e','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']
dig = ['0','1','2','3','4','5','6','7','8','9']
math = ['+','-','*','/','^','(',')']
log = ['>','>=','<','<=','~']
if char == '.' || char == ':' || char=='='
      result = 'dot'
    elsif abc.find_all{ |elem| elem == char}.size !=0
      result = 'Letter'
    elsif dig.find_all{ |elem| elem == char}.size !=0
      result = 'Digit'
    elsif char == ' '
      result = 'ws'
    elsif char=='\n' || char==';'
    result = 'nl'
    elsif math.find_all{ |elem| elem == char}.size !=0
      result = char
    elsif log.find_all{ |elem| elem == char}.size !=0
      result = char
    else result = 'other'
  end
end
### State Ключові стани (якщо аналізатор в цьому положенні, то )
initState = 'q0' # q0 – стартовий стан
def is_final(state)
  f= {'q2'=> 'q2', 'q3'=> 'q3', 'q4'=> 'q4', 'q7'=> 'q7', 'q8'=> 'q8', 'q11'=> 'q11', 'q14'=>'q14', 'q102'=> 'q102', 'q103'=> 'q103'} #–
  f[state]
end

def nextState(state, classCh)
   stf={ ['q0', 'ws']=>'q0', ['q0', ' ']=>'q0',['q0', 'Letter']=> 'q1', ['q1', 'Letter']=> 'q1', ['q1', 'Digit']=> 'q1', ['q1', 'other']=> 'q2', ['q0', ';']=> 'q3', ['q0', 'nl']=> 'q3', ['q0', '+']=> 'q4', ['q0', '-']=> 'q4', ['q0', '*']=> 'q4', ['q0', '/']=> 'q4', ['q0', '^']=> 'q4', ['q0', '(']=> 'q4', ['q0', ') ']=> 'q4', ['q0', 'Digit'] =>'q5', ['q5', 'Digit']=> 'q6', ['q5', 'dot']=> 'q6', ['q0', '.']=> 'q6', ['q6', 'Digit']=> 'q6', ['q6', 'other']=> 'q7', ['q5', 'other']=> 'q8', ['q0', 'dot']=> 'q10', ['q10', 'dot']=> 'q9', ['q10', 'other']=> 'q102', ['q9', 'other']=> 'q11', ['q0', 'other']=> 'q103', ['q0', '>']=> 'q14',['q0', '<']=> 'q14',['q0', '<=']=> 'q14',['q0', '>=']=> 'q14',['q0', '~']=> 'q14'}
    if stf[[state,classCh]] then stf[[state, classCh]]
    else  stf[[state, 'other']] end
end


###значає значення слова
def getToken(state,lexem)
  tablesOfLanguageTokens = { ['q2','program']=>'keyword', ['q2','begin']=>'keyword',['q2','end']=>'keyword', ['q2','let']=>'keyword', ['q2','for']=>'keyword', ['q2','to']=>'keyword', ['q2','do']=>'keyword', ['q2','if']=>'keyword', ['q2','goto']=>'keyword', ['q11',':='] =>'assign_op', ['q4','.']=>'dot', ['q3',';']=>'nl', ['q4','+']=>'add_op', ['q4','-']=>'add_op', ['q4','*']=>'math_op', ['q4','/']=>'math_op', ['q4','^']=>'math_op', ['q14','<']=>'log_op', ['q14','<=']=>'log_op', ['q14','>']=>'log_op', ['q14','>='] =>'log_op', ['q14','~']=>'log_op', ['q2','true']=>'boolean', ['q2','false']=>'boolean' }
  tablesOfLanguageTokens[[state,lexem]]
end

def getId(state)
tableIdentRealInt = {['q2']=>'identificator', ['q7']=>'real', ['q8']=>'integer'}
  tableIdentRealInt [[state]]
end

def lexer
 lexem=''
 n_rec = {'numLine'=>nil, 'lexem'=>'', 'token'=>'', 'id'=>''}
result =Hash.new

file = File.open('mnv.txt')
sourceCode=file.read
length =sourceCode.size
i=0
state='q0'
initState = 'q0'
numLine=1
  fr=File.new('read.txt','w')
  fr=File.open('read.txt','w')
  while i<length do
    char=sourceCode[i]
    classCh=classOfChar(char)
    state=nextState(state,classCh)
      if state==initState then
       ( lexem='')
      elsif (state==is_final(state)) then
         (if(state=='q3') then(
            numLine+=1
            state=initState)
          elsif (state=='q2'||state=='q7'||state=='q8')then
            (token=getToken(state,lexem)
              if token != 'keyword' then
                  (n_rec['numLine']=numLine
                  n_rec['lexem']=lexem
                  n_rec['token']=token
                  if token=='boolean' then
                     if lexem=='true' then n_rec['id']='1'
                     else n_rec['id']='0'end
                     else n_rec['id']=getId(state)
                  end)
              else (n_rec['numLine']=numLine
                  n_rec['lexem']=lexem
                  n_rec['token']=token
                  n_rec['id']='')
              end
              lexem=''
              i-=1
              state=initState
              # puts "#{n_rec}"
              fr.puts "#{n_rec}"
            )
          elsif (state=='q4'||state=='q11'||state=='q14') then
            (lexem+=char
              token=getToken(state,lexem)
            n_rec['lexem']=lexem
            n_rec['token']=token
            n_rec['id']=''
            # puts "#{n_rec}"
            fr.puts "#{n_rec}"
            lexem=''
            state=initState)
          elsif (state=='q102'||state=='q103') then
            # (puts "Error #{state}"
            (fr.puts "Error #{state}"
            state=initState)
          end)
      else (lexem+=char)
      end
    i +=1
  end
  puts 'Lexical analyse is finished'
file.close
fr.close
end

lexer

def checkToken(lexem,token)
  i=0
  helper=false
  file=File.open('read.txt','r+')
  tableOfSymb=file.readlines
  length=tableOfSymb.size
  while i<length do
    check = tableOfSymb[i].include?(lexem)&&tableOfSymb[i].include?(token)
    if (check ==true)
      then (puts "Token #{token} #{lexem} exist"
        helper=true) end
    i+=1
  end
  parseError(lexem,token,helper)
  puts 'Token checked'
  file.close
end

def stricktlyOrder(lexem1,lexem2,token)
  i=0
  j=0
  file=File.open('read.txt','r+')
  tableOfSymb=file.readlines
  length=tableOfSymb.size
  while i<length do
    j=i
    check1 = tableOfSymb[i].include?(lexem1)&&tableOfSymb[i].include?(token)
    (if (check1==true) then
      (while j<length do
      check2 = tableOfSymb[j].include?(lexem2)&&tableOfSymb[j].include?(token)
        j+=1
      if  (check2 ==true)
      then (puts "Tokens are on a right place" ) end
      end)
    end)
      i+=1
  end
  puts 'Order checked'
  file.close
end

def parseError(lexem,token,helper)
  if helper == false then puts "Parse Error. Token #{token} #{lexem} does not exist" end
end

def statementParse
  i=0
  file=File.open('read.txt','r+')
  tableOfSymb=file.readlines
  length=tableOfSymb.size
  assign('":="', 'token')
  file.close
end

def assign(lexem, token)
  i=0
  helper=false
  helperFull=false
  file=File.open('read.txt','r+')
  tableOfSymb=file.readlines
  length=tableOfSymb.size
  while i<length do
    check = tableOfSymb[i].include?(':=')&&tableOfSymb[i].include?('nil')
    if check==true then helper=true end
    checkFull=tableOfSymb[i].include?('(')
    if checkFull==true then (helper=false
      helperFull=true) end
    i+=1
  end
  if helper==true then (
    puts "Assign found"
    getExpression) end
  if helperFull==true then
    (puts "Assign found"
    getExpressionFull) end
  file.close
end

def getExpression
   getTerm
   getFactor
end

def getTerm
  i=0
  helper=true
  adder1=''
  adder2=''
  sign=''
  file=File.open('read.txt','r+')
  tableOfSymb=file.readlines
  length=tableOfSymb.size
  while i<length do
    if check = tableOfSymb[i].include?('add_op') then
    (helper=true
    adder1=tableOfSymb[i-1]
     sign=tableOfSymb[i]
    adder2=tableOfSymb[i+1])end
    i+=1
  end
  if helper==true then
    (puts "#{adder1}"
     puts "#{sign}"
    puts "#{adder2}"
    ) end
  file.close
end

def getFactor
    i=0
  helper=true
  adder1=''
  adder2=''
  sign=''
  file=File.open('read.txt','r+')
  tableOfSymb=file.readlines
  length=tableOfSymb.size
  while i<length do
    if check = tableOfSymb[i].include?('math_op') then
    (helper=true
    adder1=tableOfSymb[i-1]
     sign=tableOfSymb[i]
    adder2=tableOfSymb[i+1])end
    i+=1
  end
  if helper==true then
    (puts "#{adder1}"
     puts "#{sign}"
    puts "#{adder2}"
    )end
  file.close
end

def getExpressionFull
      i=0
  helper=true
  adder1=''
  adder2=''
  sign=''
  file=File.open('read.txt','r+')
  tableOfSymb=file.readlines
  length=tableOfSymb.size
  while i<length do
    if check = tableOfSymb[i].include?('(') then
    (getExpression
    helper=true
    adder1=tableOfSymb[i+1]
     sign=tableOfSymb[i+2]
    adder2=tableOfSymb[i+3]
    )end
    i+=1
  end
  file.close
end

def syntan
  i=0
  file=File.open('read.txt','r+')
  if file then
    (tableOfSymb=file.readlines
    length=tableOfSymb.size
    while i<length do
      puts "#{i+1}: #{tableOfSymb[i]}"
      i +=1
    end)
    else puts "Could not open the file."
  end
  file.close
  puts checkToken('"program"','"keyword"')
  statementParse
  puts stricktlyOrder('program','end','keyword')
  puts 'Syntax analyse is finished'
end

syntan
