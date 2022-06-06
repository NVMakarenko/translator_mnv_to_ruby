
##### Class of char definition
def classOfChar( char )
####
char='6'
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
puts result
####
end
### State Definition
stf={ ['q0', 'ws']=>'q0', ['q0', 'Letter']=> 'q1', ['q1', 'Letter']=> 'q1', ['q1', 'Digit']=> 'q1', ['q1', 'other']=> 'q2', ['q0', '; ']=> 'q3', ['q0', 'nl']=> 'q3', ['q0', '+']=> 'q4', ['q0', '-']=> 'q4', ['q0', '*']=> 'q4', ['q0', '/']=> 'q4', ['q0', '^']=> 'q4', ['q0', '(']=> 'q4', ['q0', ') ']=> 'q4', ['q0', 'Digit'] =>'q5', ['q5', 'Digit']=> 'q6', ['q5', '.']=> 'q6', ['q0', '.']=> 'q6', ['q6', 'Digit']=> 'q6', ['q6', 'other']=> 'q7', ['q5', 'other']=> 'q8', ['q0', ':']=> 'q10', ['q10', '=']=> 'q9', ['q10', 'other']=> 'q102', ['q9', 'other']=> 'q11', ['q0', 'other']=> 'q103'}
initState = 'q0' # q0 – стартовий стан
F = {'q2'=>'q2', 'q3'=>'q3', 'q4'=>'q4', 'q7' =>'q7', 'q8'=>'q8', 'q11'=>'q11', 'q14'=>'q14', 'q102'=>'Error', 'q103'=>'Error'} #– множина заключних станів.
Ferror = {'q102', 'q103'} #– обробка помилок
Fstar = {'q2', 'q7', 'q8'} #– додаткова обробка
#puts stf[['q6', 'Digit']] #q6 expected
#puts initState #q0 expected
#puts F['q102'] #error expected

### Token's definition
tablesOfLanguageTokens = {'program'=>'keyword', 'end'=>'keyword', 'for'=>'keyword', 'to'=>'keyword', 'do'=>'keyword', 'if'=>'keyword', 'goto'=>'keyword', ':=' =>'assign', '.'=>'dot', ' '=>'ws', '\t'=>'ws', '\n'=>'nl', ';'=>'nl', '+'=>'math_op', '-'=>'math_op', '*'=>'math_op', '/'=>'math_op', '^+'=>'math_op', '<'=>'log_op', '<='=>'log_op', '>'=>'log_op', '>='=>'log_op', '~'=>'log_op'}
#puts tablesOfLanguageTokens['<=']
tableIdentRealInt = {'q2'=>'identificator', 'q7'=>'real', 'q8'=>'integer'}
# puts tableIdentRealInt['q2']
