module LexicalAnalyzersHelper

  def class_of_char(char)
    abc =['a','b','c','d','e','f','g','h','e','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']
    dig = ['0','1','2','3','4','5','6','7','8','9']
    math = ['+','-','*','/','^','(',')']
    log = ['>','>=','<','<=','~']

    if char == '.' || char == ':' || char=='=' || char==';' then 'dot'
    elsif abc.find_all{ |elem| elem == char}.size !=0 then'Letter'
    elsif dig.find_all{ |elem| elem == char}.size !=0 then 'Digit'
    elsif math.find_all{ |elem| elem == char}.size !=0 then 'Math'
    elsif log.find_all{ |elem| elem == char}.size !=0 then 'Log'
    else 'other'
    end
  end

  def get_n_line(char)
    result=get_id(char)
    if result=='new_line'
      @n_line+=1
    else @n_line
    end
  end

  def get_idx_id(char)
    result=get_id(char)
    @idx_ident+=1 if (result=='identificator')
  end

  def get_idx_math(char)
    result=get_id(char)
    @idx_math+=1 if result=='real'||result=='integer'
  end

  def get_id(char)
    hook=Array.new
    char.split('').each do |item|
      hook.push(class_of_char(item))
    end
    if (hook.first=='Letter'&& (hook.include?('Math') ||  hook.include?('Log'))) then t('error.102')
    elsif (hook.first=='Letter') then get_lexem_type(char)
    elsif (hook.first=='Digit' && hook.include?('dot')&& hook.exclude?('Letter')&& hook.exclude?('Math')&& hook.exclude?('Log')) then 'real'
    elsif (hook.first=='Digit' && hook.exclude?('dot') && hook.exclude?('Letter')&& hook.exclude?('Math') && hook.exclude?('Log')) then 'integer'
    elsif (hook.first=='Digit' && hook.include?('dot')&& hook.include?('Letter')) then t('error.102')
    elsif hook.include?('dot') || hook.include?('Math') then get_lexem_type(char) #assign, order, etc
    elsif hook.include?('other') then  t('error.103')
    else t('error.104')
    end
  end

  def get_lexem_type(lexem)
    tokenHash = {
      'keyword' => ['program', 'begin', 'end', 'let', 'for', 'to', 'do', 'if', 'goto'],
      'add_op' => ['+','-'],
      'math_op' => ['*','/','^'],
      "log_op" => ['<','<=','>','>=','~'],
      'boolean' => ['true','false'],
      'assign' => [':='],
      'order_opp' => ['(', ')'],
      'new_line' => [';']
    }
    find_token = tokenHash.find {|key, values| values.include?(lexem)}
    if find_token !=nil
      find_token.first
    else 'identificator'
    end
  end

  def get_lexan(worddiv)
  hash_token ={}
  array_lexem = []
  worddiv.each do |item|
    hash_token[:num_line]=get_n_line(item)
    hash_token[:lexem_type] = get_id(item)
    hash_token[:lexema] = item
    hash_token[:idx] = get_idx_id(item) if hash_token[:lexem_type]=='identificator'
    hash_token[:idx] = get_idx_math(item) if hash_token[:lexem_type]=='real' || hash_token[:lexem_type]=='integer'
    array_lexem.push(hash_token)
    hash_token=Hash.new
  end
  return array_lexem
  end

end
