module LexicalAnalyzersHelper

  def classOfChar(char)
    abc =['a','b','c','d','e','f','g','h','e','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']
    dig = ['0','1','2','3','4','5','6','7','8','9']

    if char == '.' then 'dot'
      elsif abc.find_all{ |elem| elem == char}.size !=0 then'Letter'
      elsif dig.find_all{ |elem| elem == char}.size !=0 then 'Digit'
      else 'other'
    end
  end

  def getId(char)
    hook=Array.new
    char.split('').each do |item|
      hook.push(classOfChar(item))
    end
    if (hook[0]=='Letter' && hook.exclude?('other')) then getLexemType(char)
    elsif (hook.include?('other')) then getLexemType(char)
    elsif (hook[0]=='Digit' && hook.include?('dot')) then 'real'
    elsif (hook.include?('Digit') && hook.exclude?('Letter')) then 'integer'
    else t('error.103')
    end

  end

  def getLexemType(lexem)
    tokenHash = {
      'keyword' => ['program', 'begin', 'end', 'let', 'for', 'to', 'do', 'if', 'goto'],
      'add_op' => ['+','-'],
      'math_op' => ['*','/','^'],
      "log_op" => ['<','<=','>','>=','~'],
      'boolean' => ['true','false'],
      'assign' => [':='],
      'order_opp' => ['(', ')']
    }
    find_token = tokenHash.find {|key, values| values.include?(lexem)}
    if find_token !=nil
      find_token.first
    else 'identificator'
    end
  end

end
