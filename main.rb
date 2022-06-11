char=''
numChar=0
nextstate=Array.new
sourceCode=Array.new
tableLexem=Array.new
state='q0'
lexem = Array.new
#Як це працює:
#зчитуємо посимвольно файл (спочатку один символ, потім до нього приєднується другий, умовно нанизуємо символи, як намистини на нитку)
# перевіряємо, чи наша нитка має кінцевий стан
#Якщо має кінцевий стан, то визначаємо тип, що в нас конкретно нанизалось - токен, літера чи ще щось....
#формуємо таблицю програми
# Проблема 1. масив зчитаних значень перезаписується.
# Проблема 3. не рахує рядки
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

###значає значення слова
def getToken(state,lexem)
  tablesOfLanguageTokens = { ['q2','program']=>'keyword', ['q2','begin']=>'keyword',['q2','end']=>'keyword', ['q2','let']=>'keyword', ['q2','for']=>'keyword', ['q2','to']=>'keyword', ['q2','do']=>'keyword', ['q2','if']=>'keyword', ['q2','goto']=>'keyword', ['q11',':='] =>'assign', ['q4','.']=>'dot', ['q3',';']=>'nl', ['q4','+']=>'math_op', ['q4','-']=>'math_op', ['q4','*']=>'math_op', ['q4','/']=>'math_op', ['q4','^']=>'math_op', ['q14','<']=>'log_op', ['q14','<=']=>'log_op', ['q14','>']=>'log_op', ['q14','>='] =>'log_op', ['q14','~']=>'log_op', ['q2','true']=>'boolean', ['q2','false']=>'boolean' }
  tablesOfLanguageTokens[[state,lexem]]
end

def getId(state)
tableIdentRealInt = {['q2']=>'identificator', ['q7']=>'real', ['q8']=>'integer'}
  tableIdentRealInt [[state]]
end

def nextState(state, classCh)
   stf={ ['q0', 'ws']=>'q0', ['q0', ' ']=>'q0',['q0', 'Letter']=> 'q1', ['q1', 'Letter']=> 'q1', ['q1', 'Digit']=> 'q1', ['q1', 'other']=> 'q2', ['q0', ';']=> 'q3', ['q0', 'nl']=> 'q3', ['q0', '+']=> 'q4', ['q0', '-']=> 'q4', ['q0', '*']=> 'q4', ['q0', '/']=> 'q4', ['q0', '^']=> 'q4', ['q0', '(']=> 'q4', ['q0', ') ']=> 'q4', ['q0', 'Digit'] =>'q5', ['q5', 'Digit']=> 'q6', ['q5', 'dot']=> 'q6', ['q0', '.']=> 'q6', ['q6', 'Digit']=> 'q6', ['q6', 'other']=> 'q7', ['q5', 'other']=> 'q8', ['q0', 'dot']=> 'q10', ['q10', 'dot']=> 'q9', ['q10', 'other']=> 'q102', ['q9', 'other']=> 'q11', ['q0', 'other']=> 'q103', ['q0', '>']=> 'q14',['q0', '<']=> 'q14',['q0', '<=']=> 'q14',['q0', '>=']=> 'q14',['q0', '~']=> 'q14'}
    if stf[[state,classCh]] then stf[[state, classCh]]
    else  stf[[state, 'other']] end
end




def lexema
 lexem=''
 n_rec = {'numLine'=>nil, 'lexem'=>'', 'token'=>'', 'id'=>''}
result =Hash.new

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
              puts "#{n_rec}"
            )
          elsif (state=='q4'||state=='q11'||state=='q14') then
            (lexem+=char
              token=getToken(state,lexem)
            n_rec['lexem']=lexem
            n_rec['token']=token
            n_rec['id']=''
            puts "#{n_rec}"
            lexem=''
            state=initState)
          elsif (state=='q102'||state=='q103') then
            (puts "Error #{state}"
            state=initState)
          end)
      else (lexem+=char)
      end
    i +=1
  end

  puts 'Lexical analyse is finished'
end
  lexema
